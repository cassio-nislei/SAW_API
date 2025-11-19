<?php require_once("../../includes/padrao.inc.php"); ?>
<script type='text/javascript' src="cadastros/respostasrapidas/acoesListar.js"></script>
<?php
  $l = 1;
  $minhasRr = "";
  $todasRr = "";
  $iCountMinhas = 0;
  $iCountTodas = 0;

  $qryRespostasRapidas = mysqli_query(
    $conexao
    , "SELECT *
        FROM tbrespostasrapidas"
  );

  while( $qrrRespostasRapidas = mysqli_fetch_array($qryRespostasRapidas) ){
    $strResposta = (strlen($qrrRespostasRapidas["resposta"]) > 50) ? substr($qrrRespostasRapidas["resposta"], 0, 50) . " ..." : $qrrRespostasRapidas["resposta"];

    if( $qrrRespostasRapidas["id_usuario"] == $_SESSION["usuariosaw"]["id"] ){
      $minhasRr .= '<div class="uk-link-reset" id="linha'.$l.'">
                    <div class="uk-padding-small uk-card-default" style="height: 60px;">
                        <div style="position:absolute; right:0px"><i class="fas fa-remove"></i></div>
                        <div style="width: 90%; float: left;">
                          <p class="uk-text-bold uk-margin-remove" style="font-size: 14px; padding-bottom: 11px;">'.$qrrRespostasRapidas["titulo"].'</p>
                          <p class="uk-text-small uk-margin-remove addRespostaRapida" onclick="" style="cursor:pointer;">
                            '.$strResposta.'
                            <span style="display: none;">'.$qrrRespostasRapidas["resposta"].'</span>
                          </p>
                        </div>
                        <div class="uk-margin-small">
                          <input type="hidden" name="IdRespostaRapida" id="IdRespostaRapida" value="'.$qrrRespostasRapidas["id"].'" />
                          <button class="add" style="padding: 30px 10px;" title="Editar"><span uk-icon="pencil" class="btnAlterarRespostaRapida"></span></button>
                          <button class="add" style="padding: 30px 10px;" title="Excluir"><span uk-icon="trash" class="btnExcluirRespostaRapida"></span></button>
                        </div>
                    </div>
                </div>';
      $iCountMinhas++;
    }
    else{
      $todasRr .= '<div class="uk-link-reset" id="linha'.$l.'">
                    <div class="uk-padding-small uk-card-default" style="height: 60px;">
                        <div style="position:absolute; right:0px"><i class="fas fa-remove"></i></div>
                        <div style="width: 90%; float: left;">
                          <p class="uk-text-bold uk-margin-remove" style="font-size: 14px; padding-bottom: 11px;">'.$qrrRespostasRapidas["titulo"].'</p>
                          <p class="uk-text-small uk-margin-remove addRespostaRapida" onclick="" style="cursor:pointer;">
                            '.$strResposta.'
                            <span style="display: none;">'.$qrrRespostasRapidas["resposta"].'</span>
                          </p>
                        </div>
                        <div class="uk-margin-small">
                          <input type="hidden" name="IdRespostaRapida" id="IdRespostaRapida" value="'.$qrrRespostasRapidas["id"].'" />
                          <button class="add" style="padding: 30px 10px;" title="Editar"><span uk-icon="pencil" class="btnAlterarRespostaRapida"></span></button>
                          <button class="add" style="padding: 30px 10px;" title="Excluir"><span uk-icon="trash" class="btnExcluirRespostaRapida"></span></button>
                        </div>
                    </div>
                </div>';
      $iCountTodas++;
    }

    $l++;
  }
?>

<?php echo $todasRr ."#@#". $minhasRr ."#@#" . $iCountTodas ."#@#". $iCountMinhas; ?>
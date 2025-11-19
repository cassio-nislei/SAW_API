<?php require_once("../../includes/padrao.inc.php"); ?>
<script type='text/javascript' src="js/tagsinput.js"></script>
<script type='text/javascript' src="js/ajaxupload.js"></script>
<script type='text/javascript' src="js/quill.js"></script>
<script type='text/javascript' src="modulos/baseconhecimento/acoes.js"></script>
<link rel="stylesheet" href="css/quill.snow.css">
<link rel="stylesheet" href="css/styleupload.css">
<link rel="stylesheet" href="css/tagsinput.css">

<div class="box-modal" id="FormBC" style="display: none;">    
    <h2 class="title" id="titleCadastroBC">Adicionar Novo Usuário</h2>
    <div class="">
        <form method="post" id="gravaBC" name="gravaBC">
            <input type="hidden" id="idBC" name="idBC" value="0" />
            <input type="hidden" value="0" name="acaoBC" id="acaoBC" />

            <div>
                <div class="uk-width-1-1@m" style="width: 49%; float: left;">
                    <div class="uk-form-label"><b>Descrição do problema</b></div>
                    <div class="editor" id="editorProblema"></div>
                    <div id="valida_problema" style="display: none" class="msgValida">
                        Por favor, informe o [problema].
                    </div>
                </div>

                <div class="uk-width-1-1@m" style="width: 49%; float: right;">
                    <div class="uk-form-label"><b>Descrição da solução</b></div>
                    <div class="editor" id="editorSolucao"></div>
                    <div id="valida_solucao" style="display: none" class="msgValida">
                        Por favor, informe a [solução].
                    </div>
                </div>
			</div>

            <div>
                <div class="uk-width-1-1@m" style="width: 49%; float: left;">
                    <div class="uk-form-label"><label for="mensagem"><b>Tags EX: (NFe, SAT, Fiscal)</b></label></div>
                    <input type="text" data-role="tagsinput" id="categorias" name="categorias" value="" />
                </div>

                <div class="uk-width-1-1@m" id="mainbody" style="width: 49%; float: right;">
                    <div class="uk-form-label"><label for="mensagem"><b>Anexos</b></label></div>
                    <div id="uploadd" ><span>Anexar Arquivos<span></div><span id="statuss" ></span>		
                    <ul id="files"></ul>
                </div> 
                <div id="aguarde" style="margin:auto;text-align:center;z-index:9999;"></div>
                <div id="statuss" style='display:block;color:#F90;text-align:center'></div>
            </div>
        </form>
    </div>

    <p class="uk-text-right" style="margin-top: 2rem; margin-left: 33rem; float: right;">
        <button id="btnFecharCadastroBC" class="uk-button uk-button-default uk-modal-close" type="button">Cancelar</button>
        <button id="btnGravarBC" class="uk-button uk-button-primary" type="button">Salvar</button>
    </p>
</div>

<div class="box-modal" id="ListaBC">
    <h2 class="title">Base de Conhecimento 
        <a id="btnNovoBC" href="#" class="uk-align-right" uk-icon="plus-circle" title="+ Incluir Solução"></a>
    </h2>

    <div class="panel-body" id="ListarBC">
        <!-- Base de Conhecimento Cadastradas -->
        <table class="uk-table uk-table-striped">
            <tbody>
                <tr>
                    <form>
                        <input type="hidden" name="ordenacao" id="hstOrdenacao" value="ASC" />
                        <td width="86%">
                            <div class="uk-margin">
                                <input name="termo" id="termo" class="uk-input" type="text" placeholder="Informe o seu termo de busca">
                            </div>
                        </td>
                        <td><button type="button" id="btnPesquisar" class="uk-button"><i class="fas fa-search" style="margin-top: 15px"></i></button></td>
                        <td><button type="button" id="btnVerTodos" class="uk-button"><span uk-icon="refresh" style="margin-top: 12px;"></span></button></td>
                    </form>
                </tr>
            </tbody>
        </table>

        <div class="topLine" style="margin-top: -20px;">
            <div class="titlesTableTitulo w40p">Problema</div>
            <div class="titlesTableTitulo w40p">Solução</div>
            <div class="titlesTableTitulo w20p">Anexos</div>
            <div style="clear: both;"></div>
        </div>

        <ul uk-accordion style="margin-top: 0;">

        <?php	 
            // Busncando os Usuários cadastrados //
            $l = 1;
            $termo = isset($_REQUEST["termo"]) ? $_REQUEST["termo"] : null;
            $sqlBC = "SELECT * FROM base_conhecimento where ORDER BY problema";

            // Tratamento de Dados //
                if( $termo !== null ){
                    $sqlBC = str_replace("where","WHERE UPPER(problema) LIKE UPPER('%".$termo."%') OR UPPER(solucao) LIKE UPPER('%".$termo."%') ",$sqlBC);
                }
                else{ $sqlBC = str_replace("where","",$sqlBC); }
            // INI Tratamento de Dados //

            $registros = mysqli_query(
                $conexao
                , $sqlBC
            );
            
            while ($objResult = mysqli_fetch_object($registros)){
                // Declaração de Variáveis //
                    $tamanho = 50;
                    $downloads = '';
                // FIM Declaração de Variáveis //

                // Tratamento de Dados //
                    $objResult->problema = (strlen($objResult->problema) > $tamanho) ? substr($objResult->problema, 0, $tamanho) . "..." : $objResult->problema;
                    $objResult->solucao = (strlen($objResult->solucao) > $tamanho) ? substr($objResult->solucao, 0, $tamanho) . "..." : $objResult->solucao;
                // FIM Tratamento de Dados //
                
                // Buscando os Anexos //
                    $registrosAnxs = mysqli_query(
                        $conexao
                        , "SELECT id, nome_arquivo FROM base_conhecimento_anexos WHERE id_base_conhecimento = '".$objResult->id."'"
                    );
                    
                    while( $objResultAnexos = mysqli_fetch_object($registrosAnxs) ){
                        $downloads .= '<a href="modulos/baseconhecimento/anexo.php?id='.$objResultAnexos->id.'" target="_blank" title="'.$objResultAnexos->nome_arquivo.'" style="text-decoration:none">
                            <span uk-icon="cloud-download" class="ConfirmaExclusaoUsuario"></span>
                        </a>';
                    }
                // FIM Buscando os Anexos //

                echo '<li id="linha'.$l.'">
                        <input type="hidden" name="IdBC" id="IdBC" value="'.$objResult->id.'" />
                        <div class="titlesTable w41p">'.$objResult->problema.'</div>
                        <div class="titlesTable w41p">'.$objResult->solucao.'</div>
                        <div class="titlesTable w16p">
                            <button class="add" style="padding: 0 10px;" title="Excluir"><span uk-icon="trash" class="ConfirmaExclusaoBC"></span></button>
                            <button class="add" style="padding: 0 10px;" title="Editar"><span uk-icon="pencil" class="botaoAlterarBC"></span></button>
                            '.$downloads.'
                        </div>
                        <div style="clear: both;"></div>
                    </li>';
                $l = $l+1;
            }
            // FIM Busncando os Usuários cadastrados //		
        ?>

        </ul>
    </div>

    <p class="uk-text-right" style="margin-top:1rem">
        <button class="uk-button uk-button-default uk-modal-close fechar" type="button">Cancelar</button>
    </p>
</div>
<input type="hidden" name="qtdeFiles" id="qtdeFiles" value="0" />
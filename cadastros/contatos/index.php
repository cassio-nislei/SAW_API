<?php 
// Este arquivo é incluído de gestao/index.php que já carrega padrao.inc.php
?>

<style>
/* HIDE RADIO */
[type=radio] { 
  position: absolute;
  opacity: 0;
  width: 0;
  height: 0;
}

/* IMAGE STYLES */
[type=radio] + i {
  cursor: pointer;
}

/* CHECKED STYLES */
[type=radio]:checked + i {
  outline: 2px solid #f00;
}

          .red {
  background-color: red;
}


        </style>
</style>
<div class="box-modal">
    <form method="post" id="gravaContato" name="gravaContato" action="cadastros/contatos/ContatoController.php">
        <h2 class="title" id="titleCadastroContato">Adicionar Novo Contato</h2>
        <div class="">
            <input type="hidden" name="id" id="idContato" />
            <input type="hidden" value="1" name="acao" id="acaoContato" />

            <div class="uk-width-1-1@m">
                <div class="uk-form-label"> Celular com Whatsapp <b>(DDI Brasil 55)</b></div>
                <input type="text" id="numero_contato" name="numero_contato" class="uk-input" placeholder="Informe o Celular com DDD e DDI (com Whatsapp)" />
                <div id="valida_numero_contato" style="display: none" class="msgValida">
                    Por favor, informe o Número do Telefone com DDD e DDI.
                </div>
            </div>

            <div class="uk-width-1-1@m">
                <div class="uk-form-label"> Nome </div>
                <input type="text" id="nome_contato" name="nome_contato" class="uk-input" placeholder="Informe o Nome do Contato" />
                <div id="valida_nome_contato" style="display: none" class="msgValida">
                  Por favor, informe o NOME do Contato.
                </div>
            </div>

            <div class="uk-width-2-2@m">
                <div class="uk-form-label"> Razão Social </div>
                <input type="text" id="razao_social" name="razao_social" class="uk-input" placeholder="Informe a Razão Social" />
                <div id="valida_nome_contato" style="display: none" class="msgValida">
                  Por favor, informe a Razão Social.
                </div>
            </div>

            <div class="uk-width-2-2@m">
                <div class="uk-form-label">CPF/CNPJ </div>
                <input type="text" id="cpf_cnpj" name="cpf_cnpj" class="uk-input" placeholder="Informe o CPF ou CNPJ" />
                <div id="valida_cpf_cnpj" style="display: none" class="msgValida">
                  Por favor, informe um CPF ou CNPJ Válido.
                </div>
            </div>

        </div>

        <div class="uk-width-1-1@m">
          <div class="uk-form-label">Escolha a TAG </div>
          


          <select class="js-example-basic-multiple pesqEtiquetas" name="id_etiqueta2[]" multiple="multiple" id="id_etiqueta2" style="width:90%">
            <?php
           //Crio a lista de etiquetas e defino as cores a exibir
            $query = mysqli_query($conexao, "SELECT * FROM tbetiquetas");                       
            while ($ListarEtiquetas = mysqli_fetch_array($query)){       
               echo  '<option value="'.$ListarEtiquetas["id"].'" data-color="'.$ListarEtiquetas["cor"].'" >'.$ListarEtiquetas["descricao"].'</otpion>';                     
              }
            ?>
         </select>

               
   

       
   

        </div>
    </form>

    <p class="uk-text-right" style="margin-top:1rem">
        <button id="btnCancelaContato" class="uk-button uk-button-default uk-modal-close fechar" type="button">Cancelar</button>
        <input id="btnGravarContato" class="uk-button uk-button-primary" type="submit" value="Salvar">
    </p>
</div>


<script>
$(document).ready(function() {
  $('.pesqEtiquetas').select2({
    placeholder: 'TAGS',
    maximumSelectionLength: 10,
    "language": "pt-BR"
  });

  function ajustarCoresSelect2() {
    
  var selectedColors = {};

    $('.pesqEtiquetas').on('select2:select', function(e) {
    var selectedOption = e.params.data.element;
    var selectedColor = $(selectedOption).attr('data-color');
    var selectedId = $(selectedOption).val();
    var selectedTag = $(this).next().find('.select2-selection__choice[title="' + e.params.data.text + '"]');
    selectedColors[selectedId] = selectedColor;
    for (var id in selectedColors) {
      var selectedOption = $(this).find('option[value="' + id + '"]');
      selectedOption.css('background-color', selectedColors[id]);
      var selectedTag = $(this).next().find('.select2-selection__choice[title="' + selectedOption.text() + '"]');
      selectedTag.css('background-color', selectedColors[id]);
    }
    selectedTag.css('background-color', selectedColor);
  });
}

$('#id_etiqueta2').on('select2:open', function() {
  ajustarCoresSelect2();
});


  $('.pesqEtiquetas').on('select2:unselect', function(e) {
    var unselectedOption = e.params.data.element;
    var unselectedId = $(unselectedOption).val();
    delete selectedColors[unselectedId];
    $(this).find('option[value="' + unselectedId + '"]').css('background-color', '');
    var selectedTag = $(this).next().find('.select2-selection__choice[title="' + e.params.data.text + '"]');
    selectedTag.css('background-color', '');
  });

  // Fechar a Janela //
  $('.fechar').on("click", function() {
    fecharModal();
  });
});
</script>

<script src="gestao/js/funcoes.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.16/jquery.mask.min.js"></script>
<script src="../cadastros/contatos/contatosForms.js"></script>
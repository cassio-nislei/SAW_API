<?php require_once("../../includes/padrao.inc.php"); ?>

<!-- Htmls Novos -->
<div class="topLine">
    <div class="titlesTable w10p">Id</div>
    <div class="titlesTable w20p">COR</div>
    <div class="titlesTable w60p">DESCRICAO</div>
    <div class="titlesTable w10p">Ações</div>
    <div style="clear: both;"></div>
</div>

<div style="max-height: 400px; overflow-y: auto;">

<?php
    // Busncando os Usuários cadastrados //
    $l = 1;
    $query = mysqli_query($conexao, "SELECT * FROM tbetiquetas");
    
    while ($registros = mysqli_fetch_object($query)){

        echo '<div class="topLine" id="linha'.$l.'">
                <input type="hidden" name="IdEtiqueta" id="IdEtiqueta" value="'.$registros->id.'" />
                <div class="titlesTable w10p">'.$registros->id.'</div>
                <div class="titlesTable w20p"><i style="color:'.$registros->cor.'; font-size: 1.5rem;" class="fas fa-square"></i></div>
                <div class="titlesTable w60p">'. $registros->descricao.'</div>
                <div class="titlesTable w10p">
                    <button class="add" style="padding: 0 5px; background: none; border: none; cursor: pointer;" title="Excluir"><i class="fas fa-trash ConfirmaExclusaoEtiqueta" style="cursor: pointer; color: red; font-size: 1.1rem;"></i></button>
                    <button class="add" style="padding: 0 5px; background: none; border: none; cursor: pointer;" title="Editar"><i class="fas fa-pencil-alt botaoAlterarEtiqueta" style="cursor: pointer; color: blue; font-size: 1.1rem;"></i></button>
                </div>
            </div>';
          $l = $l+1;
      }
    // FIM Buscando as Etiquetas cadastradas //		
?>
</div>
<script>

// JavaScript Document
$( document ).ready(function() {		
	// Exclusão de Etiquetas //
	$('.ConfirmaExclusaoEtiqueta').on('click', function (){
	    var id = $(this).parent().parent().parent("li").find('#IdEtiqueta').val();
		abrirModal("#modalEtiquetaExclusao");
		$("#IdEtiqueta2").val(id);
	});

	// Remoção do Cadastro //
	$('#btnConfirmaRemoveEtiqueta').on('click', function (){
		$("#btnConfirmaRemoveEtiqueta").attr('value', 'Removendo ...');
        $('#btnConfirmaRemoveEtiqueta').attr('disabled', true);

		var idEtiqueta = $("#IdEtiqueta2").val();

		$.post("/cadastros/etiquetas/excluir.php",{IdEtiqueta:idEtiqueta},function(resultado){             
			var mensagem  = "<strong>Etiqueta Removido com sucesso!</strong>";
			var mensagem2 = 'Falha ao Remover Usuário!';

			if (resultado = 2) {
				mostraDialogo(mensagem, "success", 2500);	
                $("#btnConfirmaRemoveEtiqueta").attr('value', 'Confirmar Exclusão!');
                $('#btnConfirmaRemoveEtiqueta').attr('disabled', false);
				$.ajax("/cadastros/etiquetas/listar.php").done(function(data) {
					$('#ListarEtiqueta').html(data);
				});
			}
			else{ mostraDialogo(mensagem2, "danger", 2500); }

			// Fechando a Modal de Confirmação //
			$('#modalEtiquetaExclusao').attr('style', 'display: none');
		});
	});
	// FIM Remoção do Cadastro //

    $('#btnCancelaRemoveEtiqueta').on('click', function (){
        $('#modalEtiquetaExclusao').attr('style', 'display: none');
	});
    
	
	// Alteração de Usuário //
	$('.botaoAlterarEtiqueta').on('click', function (){
		// Busco os dados do Produto Selecionado  
		var codigo = $(this).parent().parent().parent("li").find('input:hidden').val();

		// Alterando Displays //
		$("#FormEtiquetas").css("display","block");
		$("#ListaEtiquetas").css("display","none");

		// Alterando o Título do Cadastro //
		$("#titleCadastroUser").html("Alteração de Etiquetas");

		$.getJSON('/cadastros/etiquetas/carregardados.php?codigo='+codigo, function(registro){			
			// Carregando os Dados //
			$("#id_Etiqueta").val(registro.id);
			$("#cor").val(registro.cor);
			$("#descricao").val(registro.descricao);
		});
			  
		// Mudo a Ação para Alterar    
		$("#acaoEtiqueta").val("2");
		$("#cor").focus();
	});
	// FIM Alteração de Usuário //

	// Fechar Cadastro do Usuário //
	$('#btnFecharCadastroEtiqueta').on('click', function (){
		$("#ListaEtiquetas").css("display","block");
		$("#FormEtiquetas").css("display","none");
	});
	$('#btnCancelaRemoveEtiqueta').on('click', function (){
		// Fechando a Modal de Confirmação //
		$('#modalEtiquetaExclusao').attr('style', 'display: none');
		
		$("#ListaEtiquetas").css("display","block");
		$("#FormEtiquetas").css("display","none");
	});
	// FIM Fechar Cadastro do Usuário //	
	

});

</script>
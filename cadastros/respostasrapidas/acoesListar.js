// JavaScript Document
$( document ).ready(function() {
    $('.btnExcluirRespostaRapida').on('click', function (){
        var id = $(this).parent().parent("div").find('#IdRespostaRapida').val();
		abrirModal("#modalRespostaRapidaExclusao");
		$("#IdRespostaRapida2").val(id);
    });	  

	// Remoção do Cadastro //
	$('#btnConfirmaExclusaoRespostaRapida').on('click', function (){
        $("#btnConfirmaExclusaoRespostaRapida").attr('value', 'Removendo ...');
        $('#btnConfirmaExclusaoRespostaRapida').attr('disabled', true);
        $('#btnCancelaExclusaoRespostaRapida').attr('disabled', true);

	    var id = $("#IdRespostaRapida2").val();
            
        $.post("cadastros/respostasrapidas/excluir.php",{id:id},function(resultado){
            var mensagem1  = "<strong>Resposta Rápida removido com sucesso!</strong>";
            var mensagem9 = 'Falha ao remover Resposta Rápidas!';
                
            if (resultado = 1) { mostraDialogo(mensagem1, "success", 2500); }
            else{ mostraDialogo(mensagem9, "danger", 2500); }

            // Recarrega a Modal de Respostas Rápidas //
            $.ajax("cadastros/respostasrapidas/listar.php").done(function(data) {
                var lista = data.split("#@#");
                $("#todaLista").html(lista[0]);
                $("#minhaLista").html(lista[1]);
                $("#countTodas").html(lista[2]);
                $("#countMinhas").html(lista[3]);
            });

            // Fechando a Modal de Confirmação //
            $('#modalRespostaRapidaExclusao').attr('style', 'display: none');
            $('#btnConfirmaExclusaoRespostaRapida').attr('disabled', false);
            $('#btnCancelaExclusaoRespostaRapida').attr('disabled', false);
        });
    });
    // FIM Remoção do Cadastro //
	
    // Alteração de Cadastro //
	$('.btnAlterarRespostaRapida').on('click', function (){
        // Busco os dados do Produto Selecionado  
        var codigo = $(this).parent().parent("div").find('input:hidden').val();

        // Alterando Displays //
        $("#FormRespostaRapida").css("display","block");
        $("#ListaRespostasRapidas").css("display","none");

        // Alterando o Título do Cadastro //
        $("#titleCadastroRespostaRapida").html("Alteração de Resposta Rápida");
        
	    $.getJSON('cadastros/respostasrapidas/carregardados.php?codigo='+codigo, function(registro){
            if( registro.id_usuario > 0 ){ registro.id_usuario = "2"; }
            else{ registro.id_usuario = "1"; }

            $("#IdRespostaRapida").val(registro.id);
            $("#titulo").val(registro.titulo);
            $("#id_usuario").val(registro.id_usuario);
            $("#resposta").val(registro.resposta);
        });
              
        // Mudo a Ação para Alterar    
		$("#acaoRespostaRapida").val("2");
		$("#titulo").focus();
	});
    // FIM Alteração de Cadastro //

	// Fechar Cadastro //
	$('#btnFecharCadastroRespostaRapida').on('click', function (){
		$("#ListaRespostasRapidas").css("display","block");
		$("#FormRespostaRapida").css("display","none");
	});
	$('#btnCancelaExclusaoRespostaRapida').on('click', function (){
		// Fechando a Modal de Confirmação //
		$('#modalRespostaRapidaExclusao').attr('style', 'display: none');
		
		$("#ListaRespostasRapidas").css("display","block");
		$("#FormRespostaRapida").css("display","none");
	});
	// FIM Fechar Cadastro //

    // Incluindo no TextArea a Resposta Rápida //
    $('.addRespostaRapida').on('click', function (){
        var respostaRapida = $(this).parent().find('span').text();
        $('#msg').val(respostaRapida);

        // Envio automático da Resposta Rápida //
        if( $('#parametrosRespRapidaAut').val() === "1" ){
            $('#btnEnviar').click();
        }
        else{
            // Habilitando o Envio da Imagem e Bloqueando as demais Opções //
                $("#btnEnviar").attr("style", "display: block");
                $("#divAudio").attr("style", "display: none");
            // FIM Habilitando o Envio da Imagem e Bloqueando as demais Opções //
        }

        // Fechando a Modal de Confirmação //
		$('#btnCancelarRespostasRapidas').click();
	});
    // FIM Incluindo no TextArea a Resposta Rápida //
});
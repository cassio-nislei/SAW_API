// JavaScript Document
$(document).ready(function() {
    // Adicionar Novo Registro //
		$('#btnNovaRespostaRapida').click(function(e){
			e.preventDefault();
			$("#gravarAgendamento")[0].reset();
			$("#FormAgendamento").css("display","block");
			$("#ListaAgendamento").css("display","none");
			$("#acaoAgendamento").val("0");
		});
	// Adicionar Novo Registro //

    // Cadastro/Alteração de Usuário //
	$('#btnGravarAgendamento').click(function(e){
        e.preventDefault();
	   
        var mensagem1 = "<strong>Agendamento Cadastrada com sucesso!</strong>";
        var mensagem2 = "<strong>Agendamento Atualizada com sucesso!</strong>";
        var mensagem3 = 'Agendamento já cadastrada anteriormente!';
        var mensagem9 = 'Falha ao Cadastrar/Atualizar o Registro!';
  
        $("input:text").css({"border-color" : "#999"});
        $(".msgValida").css({"display" : "none"});	

        if ($.trim($("#titulo").val()) == ''){
            $("#valida_titulo").css({"display" : "inline", "color" : "red"});
            $("#titulo").css({"border-color" : "red"});
            $("#titulo").focus();
            return false;
        }

        if ($.trim($("#id_usuario").val()) == ''){
            $("#valida_id_usuario").css({"display" : "inline", "color" : "red"});
            $("#id_usuario").css({"border-color" : "red"});
            $("#id_usuario").focus();
            return false;
        }
	    
        if ($.trim($("#resposta").val()) == ''){
            $("#valida_resposta").css({"display" : "inline", "color" : "red"});
            $("#resposta").css({"border-color" : "red"});
            $("#resposta").focus();
            return false;
        }
	  
	    $('#gravaAgendamento').ajaxForm({
		    resetForm: false, 			  
            beforeSend:function() { 
                $("#btnAgendamento").attr('value', 'Salvando ...');
                $('#btnAgendamento').attr('disabled', true);
				$('#btnFecharCadastroAgendamento').attr('disabled', true);
				$('#FormAgendamento').find('input, button').prop('disabled', true);
            },
            success: function( retorno ){
                // Mensagem de Cadastro efetuado //
                if (retorno == 1) { mostraDialogo(mensagem1, "success", 2500); }
                // Mensagem de Atualização Efetuada //
                else if (retorno == 2){ mostraDialogo(mensagem2, "success", 2500); }
                // Resposta Rápida já existe //
                else if (retorno == 3){ mostraDialogo(mensagem3, "danger", 2500); }
                // Mensagem de Falha no Cadastro //
                else{ mostraDialogo(mensagem9, "danger", 2500); }

                $.ajax("cadastros/agendamento/listar.php").done(function(data) {
                    var lista = data.split("#@#");
                    $("#todaLista").html(lista[0]);
                    $("#minhaLista").html(lista[1]);
                    $("#countTodas").html(lista[2]);
                    $("#countMinhas").html(lista[3]);
                });
            },		 
		    complete:function() {
                $("#btnGravarAgendamento").attr('value', 'Salvar');
                $('#btnGravarAgendamento').attr('disabled', false);
				$('#btnFecharCadastroAgendamento').attr('disabled', false);
				$('#FormAgendamento').find('input, button').prop('disabled', false);
				$("#ListAgendamento").css("display","block");
				$("#FormAgendamento").css("display","none");
            },
            error: function (retorno) { mostraDialogo(mensagem5, "danger", 2500); }
	    }).submit();
	});
    // FIM Novo Registro //
});
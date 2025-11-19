// JavaScript Document
// Formatando o 'Número do Telefone' //
    var behavior = function (val) {
        return val.replace(/\D/g, '').length === 13 ? '+00 (00) 00000-0000' : '+00 (00) 0000-00009';
    },
    options = {
        onKeyPress: function (val, e, field, options) {
            field.mask(behavior.apply({}, arguments), options);
        }
    };

    $('#numero_contato').mask(behavior, options);
// FIM Formatando o 'Número do Telefone' //

// Adicionar/Alterar Registro //
    $('#btnGravarContato').click(function(e){
        e.preventDefault();

        // Declaração de Variáveis //
            var mensagem  = "<strong>Contato Cadastrado com sucesso!</strong>";
            var mensagem2 = "<strong>Contato Atualizado com sucesso!</strong>";
            var mensagem3 = 'Já existe um Contato cadastrado com estes dados!';
            var mensagem4 = 'Falha ao Efetuar Cadastro!';
            var mensagem8 = 'Não é permitido o cadastro de Telefones Internacionais';
            var nome = $("#nome_contato").val();
            var numero = $("#numero_contato").val();
        // FIM Declaração de Variáveis //

        $("input:text").css({"border-color" : "#999"});
        $(".msgValida").css({"display" : "none"});

        // Tratamento de Exceções //
            if( numero.replace(/\D/g, '').length < 12 
                || numero.replace(/\D/g, '').length > 13 ){
                $("#valida_numero_contato").html("Número do Telefone fora do padrão. Por favor informe o número corretamente!");
                $("#valida_numero_contato").css({"display" : "inline", "color" : "red"});
                $("#numero_contato").css({"border-color" : "red"});
                $("#numero_contato").focus();
                return false;
            }
            
            if( $.trim(numero) == '' ){
                $("#valida_numero_contato").css({"display" : "inline", "color" : "red"});
                $("#numero_contato").css({"border-color" : "red"});
                $("#numero_contato").focus();
                return false;
            }

            if( $.trim(nome) == '' ){
                $("#valida_nome_contato").css({"display" : "inline", "color" : "red"});
                $("#nome_contato").css({"border-color" : "red"});
                $("#nome_contato").focus();
                return false;
            }
        // FIM Tratamento de Exceções //

        $('#gravaContato').ajaxForm({
            resetForm: false,
            beforeSend:function() {
                $('#gravaContato').find('input, button').prop('disabled', true);
                $("#btnGravarContato").attr('value', 'Salvando ...');
                $("#btnGravarContato").attr('disabled', true);
                $("#btnCancelaContato").attr('disabled', true);
            },
            success: function( retorno ){
             //   alert(retorno);
                if (retorno == 1){ mostraDialogo(mensagem, "success", 2500); }
                else if (retorno == 2) { mostraDialogo(mensagem2, "success", 2500); }
                else if (retorno == 3) { mostraDialogo(mensagem3, "danger", 2500); }
                else if (retorno == 8) { mostraDialogo(mensagem8, "danger", 2500); }
                else{
                    retorno = JSON.parse(retorno);
                    mostraDialogo(retorno.erro, "danger", 2500);
                }

                // Atualiza a Lista de Contatos //
                atualizaContatos();

                // Fechando a Modal //
                fecharModal();
            },		 
            complete:function() {
                $("#btnGravarContato").attr('value', 'Salvar');
                $("#btnGravarContato").attr('disabled', false);
            },
            error: function (retorno) { mostraDialogo(mensagem4, "danger", 2500); }
        }).submit();
    });
// FIM Adicionar/Alterar Registro //

// Exclusão de Registro //
    $('#btnConfirmaRemoveContato').on('click', function (){
        // Desabilitando os Botões //
        $("#btnConfirmaRemoveContato").attr('value', 'Removendo ...');
        $('#btnConfirmaRemoveContato').attr('disabled', true);
        $('#btnCancelaRemoveContato').attr('disabled', true);

        // Recupera o 'Número' do Contato Selecionado //
        var idContato = $("#idContatoExcluir").val();
        var acaoContato = $("#acaoContatoExcluir").val();

        $.post("cadastros/contatos/ContatoController.php",{id:idContato,acao:acaoContato},function(resultado){
            var mensagem  = "<strong>Contato Removido com sucesso!</strong>";
            var mensagem2 = 'Falha ao Remover Contato!';

            if (resultado = 2) {
                mostraDialogo(mensagem, "success", 2500);

                // Atualiza a Lista de Contatos //
                atualizaContatos();
            }
            else{ mostraDialogo(mensagem, "danger", 2500); }

            // Habilitando os Botões //
            $("#btnConfirmaRemoveContato").attr('value', 'Confirmar Exclusão!');
            $('#btnConfirmaRemoveContato').attr('disabled', false);
            $('#btnCancelaRemoveContato').attr('disabled', false);

            // Fechando a Modal //
            fecharModal();
        });
    });
// FIM Exclusão de Registro //
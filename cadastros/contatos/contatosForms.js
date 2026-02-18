// JavaScript Document
console.log("contatosForms.js carregado com sucesso!");

// Formatando o 'Número do Telefone' //
var behavior = function (val) {
    return val.replace(/\D/g, "").length === 13
      ? "+00 (00) 00000-0000"
      : "+00 (00) 0000-00009";
  },
  options = {
    onKeyPress: function (val, e, field, options) {
      field.mask(behavior.apply({}, arguments), options);
    },
  };

$("#numero_contato").mask(behavior, options);
// FIM Formatando o 'Número do Telefone' //

// Adicionar/Alterar Registro //
$("#btnGravarContato").click(function (e) {
  e.preventDefault();
  console.log("Botão Salvar clicado!");

  // Declaração de Variáveis //
  var mensagem = "<strong>Contato Cadastrado com sucesso!</strong>";
  var mensagem2 = "<strong>Contato Atualizado com sucesso!</strong>";
  var mensagem3 = "Já existe um Contato cadastrado com estes dados!";
  var mensagem4 = "Falha ao Efetuar Cadastro!";
  var mensagem8 = "Não é permitido o cadastro de Telefones Internacionais";
  var nome = $("#nome_contato").val();
  var numero = $("#numero_contato").val();
  // FIM Declaração de Variáveis //

  console.log("Nome:", nome, "Número:", numero);

  $("input:text").css({ "border-color": "#999" });
  $(".msgValida").css({ display: "none" });

  // Tratamento de Exceções //
  if (
    numero.replace(/\D/g, "").length < 12 ||
    numero.replace(/\D/g, "").length > 13
  ) {
    $("#valida_numero_contato").html(
      "Número do Telefone fora do padrão. Por favor informe o número corretamente!",
    );
    $("#valida_numero_contato").css({ display: "inline", color: "red" });
    $("#numero_contato").css({ "border-color": "red" });
    $("#numero_contato").focus();
    return false;
  }

  if ($.trim(numero) == "") {
    $("#valida_numero_contato").css({ display: "inline", color: "red" });
    $("#numero_contato").css({ "border-color": "red" });
    $("#numero_contato").focus();
    return false;
  }

  if ($.trim(nome) == "") {
    $("#valida_nome_contato").css({ display: "inline", color: "red" });
    $("#nome_contato").css({ "border-color": "red" });
    $("#nome_contato").focus();
    return false;
  }
  // FIM Tratamento de Exceções //

  console.log("Validações passaram, enviando formulário...");

  // Coleta os dados do formulário
  var formData = new FormData(document.getElementById('gravaContato'));
  
  $.ajax({
    url: "cadastros/contatos/ContatoController.php",
    type: "POST",
    data: formData,
    processData: false,
    contentType: false,
    beforeSend: function () {
      console.log("Enviando dados via AJAX para: cadastros/contatos/ContatoController.php");
      console.log("Dados:", {
        numero: numero,
        nome: nome,
        acao: $("#acaoContato").val(),
        razao_social: $("#razao_social").val(),
        cpf_cnpj: $("#cpf_cnpj").val(),
        id_etiqueta2: $("#id_etiqueta2").val()
      });
      $("#gravaContato").find("input, button").prop("disabled", true);
      $("#btnGravarContato").attr("value", "Salvando ...");
      $("#btnGravarContato").attr("disabled", true);
      $("#btnCancelaContato").attr("disabled", true);
    },
    success: function (retorno) {
      console.log("Resposta recebida:", retorno);

      if (retorno == 1) {
        console.log("Contato cadastrado com sucesso!");
        mostraDialogo(mensagem, "success", 2500);
      } else if (retorno == 2) {
        console.log("Contato atualizado com sucesso!");
        mostraDialogo(mensagem2, "success", 2500);
      } else if (retorno == 3) {
        console.log("Contato duplicado!");
        mostraDialogo(mensagem3, "danger", 2500);
      } else if (retorno == 8) {
        console.log("Número internacional não permitido!");
        mostraDialogo(mensagem8, "danger", 2500);
      } else {
        try {
          var jsonRetorno = JSON.parse(retorno);
          console.log("Erro:", jsonRetorno.erro);
          mostraDialogo(jsonRetorno.erro, "danger", 2500);
        } catch (e) {
          console.log("Resposta não esperada:", retorno);
          mostraDialogo("Erro: " + retorno, "danger", 2500);
        }
      }

      // Atualiza a Lista de Contatos //
      if (typeof atualizaContatos === "function") {
        atualizaContatos();
      }

      // Fechando a Modal //
      if (typeof fecharModal === "function") {
        fecharModal();
      }
    },
    complete: function () {
      console.log("Requisição completa");
      $("#btnGravarContato").attr("value", "Salvar");
      $("#btnGravarContato").attr("disabled", false);
    },
    error: function (xhr, status, error) {
      console.log("Erro na requisição:", status, error);
      console.log("Resposta do servidor:", xhr.responseText);
      mostraDialogo(mensagem4 + " - " + error, "danger", 2500);
    }
  });
});
});
// FIM Adicionar/Alterar Registro //

// Exclusão de Registro //
$("#btnConfirmaRemoveContato").on("click", function () {
  // Desabilitando os Botões //
  $("#btnConfirmaRemoveContato").attr("value", "Removendo ...");
  $("#btnConfirmaRemoveContato").attr("disabled", true);
  $("#btnCancelaRemoveContato").attr("disabled", true);

  // Recupera o 'Número' do Contato Selecionado //
  var idContato = $("#idContatoExcluir").val();
  var acaoContato = $("#acaoContatoExcluir").val();

  $.post(
    "cadastros/contatos/ContatoController.php",
    { id: idContato, acao: acaoContato },
    function (resultado) {
      var mensagem = "<strong>Contato Removido com sucesso!</strong>";
      var mensagem2 = "Falha ao Remover Contato!";

      if ((resultado = 2)) {
        mostraDialogo(mensagem, "success", 2500);

        // Atualiza a Lista de Contatos //
        atualizaContatos();
      } else {
        mostraDialogo(mensagem, "danger", 2500);
      }

      // Habilitando os Botões //
      $("#btnConfirmaRemoveContato").attr("value", "Confirmar Exclusão!");
      $("#btnConfirmaRemoveContato").attr("disabled", false);
      $("#btnCancelaRemoveContato").attr("disabled", false);

      // Fechando a Modal //
      fecharModal();
    },
  );
});
// FIM Exclusão de Registro //

<div class="_chat" id="Verchat">
	<div class="user-card-operadores">
        <div class="user-card-green-operadores">
            <p><img src="img/ico-chat-op.svg" width="35"> <span>Chat entre operadores</span> </p>      
		</div>
    </div>
		
	<div class="area_chat_op" id="conversas_chat">
		<!-- Mensagens do Chat -->
	</div>		
	
	<div style="padding-left: 10px;padding-right: 10px;padding-bottom: 0px;padding-top: 10px;">
		<input type="hidden" name="idDepartamentoChat" id="idDepartamentoChat" value="0" />

		<select id="mudaDepartamento" class="uk-select" style="margin-bottom:10px">
			<option value="0">Todos os setores</option>
			<?php 
				$qryDeptos = mysqli_query(
					$conexao
					, "SELECT id, departamento FROM tbdepartamentos"
				);
			
				while( $arrDeptos = mysqli_fetch_assoc($qryDeptos) ){
					echo '<option value="'.$arrDeptos["id"].'"> '.$arrDeptos["departamento"].'</option>';
				}
			?>
		</select>
		<textarea id="msgChat" class="uk-textarea type_msg" placeholder="Pressione ENTER para Enviar a sua Mensagem"></textarea>
	</div>
	
	<div id="btManipulaChat" class="action_arrow sair" title="" aria-expanded="false" style="background:#557cf2">
    	<div class="changebtchat">
			<span class="fa fa-chevron-left"></span>
		</div>
	</div>
</div>
<script>
    $(document).ready(function() {
		var form;
        form = new FormData();
		
		function ajustaScroll(){
            $("#divMsgChat").animate({
                scrollTop: $(this).height()*100 // aqui introduz o numero de px que quer no scroll, neste caso é a altura da propria div, o que faz com que venha para o fim
            }, 100);
        }

		function carregaChat(idDepartamentoChat) {
			// Só Carrega as Mensagens se o WebChat estiver Aberto //
			if( $('#carregaWebChat').val() === "1" ){
				$.ajax("webchat/listaMensagens.php?idDepto="+idDepartamentoChat).done(function(data) {
					$('#conversas_chat').html(data);
					ajustaScroll(); //desço a barra de rolagem da conversa
				});
			}
		}

		var intervalo = setInterval(function(){ carregaChat($("#idDepartamentoChat").val()); }, 15000);

		// Chamada Inicial //
        carregaChat(0);

		// Atualiza ao Selecionar um Departamento //
		$("#mudaDepartamento").change(function(){
			$("#idDepartamentoChat").val($(this).val());
			carregaChat($(this).val());
		});

		// Envia a Mensagem //
		$("#msgChat").keypress(function(){
			if ( event.which == 13 ) {
				var idDepto = $("#idDepartamentoChat").val();
				var strMensagem = $("#msgChat").val();

				form.append('idDepto', idDepto);
				form.append('strMensagem', strMensagem);

				// Executa a gravação da Mensagem //
				$.ajax({
					url: 'webchat/gravarMensagemChat.php'
					, data: form
					, processData: false
					, contentType: false
					, type: 'POST'
					, resetForm: true
					, success: function(retorno) {
						if (retorno == 1) {
							$("#msgChat").val("");
							carregaChat(idDepto);
							form = new FormData();
						}
						else{ mostraDialogo("Erro ao enviar a Mensagem!", "danger", 2500); }
					}
				});
			}
		});
	});
</script>
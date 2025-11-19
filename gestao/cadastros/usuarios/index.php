    <link href="css/estiloinputlabel.css" rel="stylesheet">	
	<script>
$( document ).ready(function() {	
	
	$('.form_campos').on('focus blur',
function (e) {
  $(this).parents('.form-group').toggleClass('focused', (e.type==='focus' || this.value.length > 0));
}
).trigger('blur');
 $('.select').on('change blur',
function (e) {
  $(this).parents('.form-group-select').toggleClass('focused', (e.type==='focus' || this.value !==''));
}
).trigger('blur');

document.getElementById("login").onkeypress = function(e) {
         var chr = String.fromCharCode(e.which);
         if ("1234567890qwertyuioplkjhgfdsazxcvbnmQWERTYUIOPLKJHGFDSAZXCVBNM.".indexOf(chr) < 0)
           return false;
       };
	
	});
</script>
	<h1>Usuários</h1>
	<form method="post" action="cadastros/usuarios/salvar.php" name="gravaUsuario" id="gravaUsuario">	
	<input type="hidden" id="id_usuarios" name="id_usuarios" value="0" />
    <input type="hidden" value="0" name="acaoUsuario" id="acaoUsuario" />
	 <div class="row">
		  <div class="col-md-6">
			<div class='form-group'>
			   <label class='control-label' for='inputNormal'>Nome</label>
			   <input type="text" id="nome_usuario" name="nome_usuario" class="form_campos"> 
			   <div id="valida_nome" style="display: none" class="msgValida">
					Por favor, informe o Nome .
				</div> 
			 </div>         
		  </div>  
		  <div class="col-md-3">
			<div class='form-group'>
			  <label class='control-label' for='inputNormal'>Login</label>
			  <input type="text" id="login" name="login" class="form_campos"> 
			    <div id="valida_login" style="display: none" class="msgValida">
					Por favor, informe o Nome .
				</div> 
			 </div>         
		  </div>  
		  <div class="col-md-3">
         <div class='form-group-select' style="width:100%">
           <label class='control-label'>Nível de Usuário*</label>
          <select class="select form_campos" id="perfil" name="perfil" style="width:100%">
             <option value="0">Administrador</option>
             <option value="2">Coordenador</option>
             <option value="1">Operador</option>            
         </select> 
         <div id="valida_categoria" style="display: none" class="msgValida">
            Por favor, informe o tipo do Produto .
        </div> 
      </div>  
     </div>
	 </div>	
	 <div class="row">
	 <div class="col-md-5">
			<div class='form-group'>
			  <label class='control-label' for='inputNormal'>Email</label>
			   <input type="text" id="email" name="email" class="form_campos">
			   
			 </div>         
		  </div>  
		  <div class="col-md-3">
			<div class='form-group'>
			   <label class='control-label' for='inputNormal'>Senha</label>
			   <input type="password" id="senha" name="senha" class="form_campos"> 
			    <div id="valida_senha" style="display: none" class="msgValida">
					Por favor, informe a Senha .
				</div>
			 </div>         
		  </div>  
		  <div class="col-md-3">
			<div class='form-group'>
			   <label class='control-label' for='inputNormal'>Confirmação de Senha</label>
			   <input type="password" id="senha2" name="senha2" class="form_campos"> 
			   <div id="valida_senha2" style="display: none" class="msgValida">
					Por favor, informe a confirmação da Senha .
				</div>
			 </div>         
		  </div>  
		  <div class="col-md-1">
		    <div class='form-group' style="padding-top:10px;padding-left:20px;">					  
			     <label class="form-check-label" for="exampleCheck1">Ativo</label>
			     <input type="checkbox" class="form-check-input" name="usuario_ativo" id="usuario_ativo">            			
			</div>
		  </div>
	 </div>		
	
	 <div class="row">			
			    <input type="hidden" id="acao" name="acao" value="0">
			    <input type="hidden" id="id" name="id" value="0">
				<input type="reset" value="Cancelar" id="btnCancelar" class="btn btn-danger ml-auto" style="visibility:hidden;">&nbsp;&nbsp;
				<input type="submit" value="Gravar" id="btnGravar" class="btn btn-primary">
		</div>
	</form>
	
	<div id="ListaUsuarios"></div>
	





    <script> 
        // wait for the DOM to be loaded 
        $(document).ready(function() { 
		//Botão Cancelar Ao CLicar deve ser oculto
		$("#btnCancelar").click(function(){
			$("#btnCancelar").css({"visibility" : "hidden"});
		})

		 // Cadastro/Alteração de Usuário //
	 $('#btnGravar').click(function(e){
	   	e.preventDefault();
	   
		var mensagemErro = 'Falha ao Efetuar Cadastro!';
	  
		$("input:text").css({"border-color" : "#999"});
		$("input:password").css({"border-color" : "#999"});
		$(".msgValida").css({"display" : "none"});
	    
		if ($.trim($("#nome_usuario").val()) == ''){
			$("#valida_nome").css({"display" : "inline", "color" : "red"});
			$("#nome_usuario").css({"border-color" : "red"});
			$("#nome_usuario").focus();
			return false;
		}

		if ($.trim($("#login").val()) == ''){	
			$("#valida_login").css({"display" : "inline", "color" : "red"});
			$("#login").css({"border-color" : "red"});
			$("#login").focus();
			return false;
		}	

		if ($.trim($("#senha").val()) == ''){	
			$("#valida_senha").html("Por favor, informe a Senha");
			$("#valida_senha").css({"display" : "inline", "color" : "red"});
			$("#senha").css({"border-color" : "red"});
			$("#senha").focus();
			return false;
		}

		if ($.trim($("#senha2").val()) == ''){	
			$("#valida_senha2").html("Por favor, informe a Senha");
			$("#valida_senha2").css({"display" : "inline", "color" : "red"});
			$("#senha2").css({"border-color" : "red"});
			$("#senha2").focus();
			return false;
		}

		if ($.trim($("#senha").val()) != $.trim($("#senha2").val())){	
			$("#valida_senha").html("A Senha e a confirmação não conferem");
			$("#valida_senha").css({"display" : "inline", "color" : "red"});
			$("#senha").css({"border-color" : "red"});
			$("#senha2").css({"border-color" : "red"});
			$("#senha").focus();
			return false;
		}

		// Gravando os dados do Usuário //
	    $('#gravaUsuario').ajaxForm({
			resetForm: true,
        	beforeSend:function() {
				$("#btnGravarUsuario").attr('value', 'Salvando ...');
				$('#btnGravarUsuario').attr('disabled', true);
				$('#btnFecharCadastro').attr('disabled', true);
				$('#FormUsuarios').find('input').prop('disabled', true);
        	},
			success: function( retorno ){			
				if (retorno == 1) { mostraDialogo("<strong>Usuário Cadastrado com sucesso!</strong>", "success", 2500); }
				else if (retorno == 2){ mostraDialogo('Usuário Atualizado com Sucesso!', "success", 2500); }
				else if (retorno == 3){ mostraDialogo('Usuário Já Cadastrado com este Login!', "warning", 2500); }
				else if (retorno == 4){ mostraDialogo('Você não pode desativar seu próprio Usuário!', "warning", 2500); return false }
				else if (retorno == 5){ mostraDialogo('Você não pode desativar o Administrador principal!', "danger", 2500); return false }
				else{ mostraDialogo(mensagemErro+retorno, "danger", 2500); }

				$.ajax("cadastros/usuarios/listar.php").done(function(data) {
					$("#btnCancelar").css({"visibility" : "hidden"});
					$("#ListaUsuarios").html("<img src='imgs/loader.gif'  width='100'>");
			        $("#ListaUsuarios").load("cadastros/usuarios/listar.php");					
				});
			},		 
			complete:function() {
				$("#btnGravarUsuario").attr('value', 'Salvar');
				$('#btnGravarUsuario').attr('disabled', false);
				$('#FormUsuarios').find('input, button').prop('disabled', false);
				$("#ListaUsuarios").css("display","block");
				$("#FormUsuarios").css("display","none");
				
		 	},
		 	error: function (retorno) {
				mostraDialogo(mensagemErro, "danger", 2500);
            }
		}).submit();
		// FIM Gravando os dados do Usuário //
	});
	// FIM Cadastro/Alteração de Usuário //
			
			$("#ListaUsuarios").html("<img src='imgs/loader.gif'  width='100'>");
			$("#ListaUsuarios").load("cadastros/usuarios/listar.php");
             
        }); 
    </script> 

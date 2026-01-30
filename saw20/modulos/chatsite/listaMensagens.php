<?php
session_start();

 require_once("includes/conexao.php");
  if ($_SESSION["chat"]["menu"]==true){
     echo'<div id="ListarMenu">'; 
     include("menu.php");
     echo '</div>';  
  }else{
    //MEnsagem Inicial
    echo '
    <div class="direct-chat-msg">
     <div class="direct-chat-info clearfix">
     <span class="direct-chat-name pull-left">Mensagem do Sistema</span>
     <span class="direct-chat-timestamp pull-right">23 Jan 2:00 pm</span>
    </div>
    <img class="direct-chat-img" src="https://img.icons8.com/color/36/000000/administrator-male.png" alt="message user image">
                
    <div class="direct-chat-text">
       Em breve um de nossos atendentes ira atende-lo, aguarde por favor.
    </div>

  </div> ';
     $numero = $_SESSION["chat"]["numero"];
     $mensagens = mysqli_query($conexao, "select * from tbmsgatendimento where canal = 0 and numero = '$numero'");
     while ($listarMensagens = mysqli_fetch_assoc($mensagens)){
    //Verifico se a mensagem é do Atendente ou do Cliente para exibir com estilos diferentes
      if ($listarMensagens["id_atend"]>0){
        echo '
        <div class="direct-chat-msg">
         <div class="direct-chat-info clearfix">
         <span class="direct-chat-name pull-left">'.$listarMensagens["nome_chat"].'</span>
         <span class="direct-chat-timestamp pull-right">23 Jan 2:00 pm</span>
        </div>
        <img class="direct-chat-img" src="https://img.icons8.com/color/36/000000/administrator-male.png" alt="message user image">
                    
        <div class="direct-chat-text">
          '.$listarMensagens["msg"].'
        </div>
 
      </div> ';
         
    }else{
    echo'
        <div class="direct-chat-msg right">
        <div class="direct-chat-info clearfix">
          <span class="direct-chat-name pull-right">'.$listarMensagens["nome_chat"].'</span>
          <span class="direct-chat-timestamp pull-left">23 Jan 2:05 pm</span>
        </div>
       
        <img class="direct-chat-img" src="https://img.icons8.com/office/36/000000/person-female.png" alt="message user image">
        
        <div class="direct-chat-text">
        '.$listarMensagens["msg"].'
        </div>
     
      </div>';
    } //Fim do IF que verifica se a mensagem é do atendente ou do cliente

  }//Fim do While que lista as mensagens
} //Fim da Verificação se é para exibir o Menu
?>


<?php
require_once("../../../includes/padrao.inc.php");

$acao           = $_POST['acaoUsuario'];
$id             = $_POST['id_usuarios'];
$nome           = $_POST['nome_usuario'];
$login          = $_POST['login'];
$email          = $_POST['email'];
$senha          = $_POST["senha"];
$perfil         = $_POST["perfil"];
if (trim($_POST['nome_usuario'])==''){
	exit();
}
//A: ATIVO; I: INATIVO
if (isset($_POST["usuario_ativo"])){
	$ativo         = 'A';
}else{
	$ativo         = 'I';
}
    

if( $acao == 0 ){
	$existe = mysqli_query($conexao, "SELECT * FROM tbusuario WHERE login = '".$login."'");

	if( mysqli_num_rows($existe) > 0 ){
		echo "3";
		exit();
	}

	
	$sql = "INSERT INTO tbusuario (nome, login, email, senha, situacao, nome_chat, perfil) VALUES ('$nome', '$login','$email', '$senha', '$ativo', '$nome', '$perfil')";
	$inserir = mysqli_query($conexao, $sql)
		or die($sql . "<br />" . mysqli_error($conexao));

	if( $inserir ){
		echo "1";
	}
}
else{   
	
	if ($ativo=='I'){
		if ($_SESSION["usuariosaw"]["id"] == $id){
			echo '4'; //Retorno 4 e aviso que não pode Desativar a si próprio
			exit();
		  }
	}
	
	  
	
	  if ($_SESSION["usuariosaw"]["perfil"] == 0){
		 //Busco o nome do usuario para saber se é o admin
		 $usuario = mysqli_query($conexao,"select login from tbusuario where id = '$id'") or die(mysqli_error($conexao));
		 $usuarioSelecionado = mysqli_fetch_assoc($usuario);
		if ($usuarioSelecionado["login"]=='admin'){
		  echo '5'; //Retorno 4 e aviso que não pode Desativar o Administrador Principal
		   exit();
		}
		
	  }


	$sql = "UPDATE tbusuario SET nome = '$nome', senha = '$senha', login = '$login', email = '$email', nome_chat = '$nome', perfil = '$perfil', situacao='$ativo' where id = '$id'";
	$atualizar = mysqli_query($conexao, $sql)
		or die($sql . "<br />" . mysqli_error($conexao));
   
	if( $atualizar ){
		echo "2";
   	}
}
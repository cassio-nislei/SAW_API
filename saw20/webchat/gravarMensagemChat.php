<?php
	require_once("../includes/padrao.inc.php");

	// Definição de Variáveis //
	$idUsuario = $_SESSION["usuariosaw"]["id"];
    $idDepto = $_POST["idDepto"];
	$strMensagem = $_POST["strMensagem"];
	$sqlInsert = "";

	// Montanto o Insert //
		if( intval($idDepto) > 0 ){
			$sqlInsert = "INSERT INTO tbchatoperadores(id_usuario,id_departamento,mensagem)
							VALUES('".$idUsuario."','".$idDepto."','".$strMensagem."')";
		}
		else{
			$sqlInsert = "INSERT INTO tbchatoperadores(id_usuario,mensagem)
							VALUES('".$idUsuario."','".$strMensagem."')";
		}
	// FIM Montanto o Insert //

  	$insert = mysqli_query(
		  $conexao
		  , $sqlInsert
	);

	if( $insert ){ echo "1"; }
	else{ echo "0"; }
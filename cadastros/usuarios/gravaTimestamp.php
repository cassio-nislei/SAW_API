<?php
	// Requires //
	require_once("../../includes/padrao.inc.php");

	// Verifica se o usuário está logado //
	if(!isset($_SESSION["usuariosaw"]["id"])){
		header("HTTP/1.1 401 Unauthorized");
		exit;
	}

	// Obtém o ID do usuário logado //
	$idUsuario = $_SESSION["usuariosaw"]["id"];

	// Atualiza o timestamp do usuário - usando datetime_online (compatível com SAW20) //
	$sqlUpdate = "UPDATE tbusuario SET datetime_online = NOW() WHERE id = '".$idUsuario."'";
	$qryUpdate = mysqli_query($conexao, $sqlUpdate) or die("Erro ao atualizar timestamp: " . mysqli_error($conexao));

	// Retorna o timestamp atual //
	echo json_encode(array(
		"status" => "success",
		"timestamp" => date("Y-m-d H:i:s"),
		"idUsuario" => $idUsuario
	));
?>

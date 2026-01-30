<?php
	require_once("../../includes/padrao.inc.php");

	if( isset($_SESSION["i"]) ){
		// Permito anexar no máximo 5 arquivos
		if( $_SESSION["i"] >= 5 ){
			echo "limite"; exit;
		}
	}

	$uploaddir = 'arquivos/';
	$file = $uploaddir . basename($_FILES['uploadfile']['name']);

	if (move_uploaded_file($_FILES['uploadfile']['tmp_name'], $file)) { 
		if (!isset($_SESSION["anexos"])){
			// $_SESSION["i"] = 1;
			$_SESSION["i"] = isset($_SESSION["i"]) ? $_SESSION["i"] : 1;
			$_SESSION["anexos"][$_SESSION["i"]] = $file;
		}
		else{
			$_SESSION["i"]++;
			$_SESSION["anexos"][$_SESSION["i"]] = $file;
		}

		echo "success"; 
	}
	else { echo "error"; }
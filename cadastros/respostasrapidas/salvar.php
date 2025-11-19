<?php
	require_once("../../includes/padrao.inc.php");
	$acao	= $_POST['acaoRespostaRapida'];
	$id		= $_POST['IdRespostaRapida'];
	$idUser	= (intval($_POST['id_usuario']) == 2) ? $_SESSION["usuariosaw"]["id"] : 0;
	$titulo	= $_POST['titulo'];
	$resposta = $_POST['resposta'];

	if( $acao == 0 ){
		// Verifico se já existe uma registro com o mesmo 'Título'
		$existe = mysqli_query(
			$conexao
			, "SELECT 1 
				FROM tbrespostasrapidas 
					WHERE titulo = '".$titulo."'"
		);
		
		if( mysqli_num_rows($existe) == 0 ){
			$sql = "INSERT INTO tbrespostasrapidas (id_usuario, titulo, resposta) VALUES (NULL, '".$titulo."', '".$resposta."')";

			// Substituindo o Id do Usuário ///
			if( intval($idUser) > 0 ){ $sql = str_replace("NULL", "'".$idUser."'", $sql); }

			$inserir = mysqli_query($conexao, $sql)
				or die(mysqli_error($conexao));
			
			if( $inserir ){ echo "1"; }
			else{ echo "9"; }
		}
		else{ echo "3"; }
	}
	else{
		$sql = "UPDATE tbrespostasrapidas 
					SET resposta = '".$resposta."'
						, titulo = '".$titulo."' WHERE id = '".$id."'";
		$atualizar = mysqli_query($conexao, $sql)
			or die($sql . "<br/>" . mysqli_error($conexao));

		if( $atualizar ){ echo "2"; }
		else{ echo "9"; }
	}
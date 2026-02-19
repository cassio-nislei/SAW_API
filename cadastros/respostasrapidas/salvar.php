<?php
	require_once($_SERVER['DOCUMENT_ROOT'] . "/includes/padrao.inc.php");
	$acao	= $_POST['acaoRespostaRapida'];
	$id		= $_POST['IdRespostaRapida'];
	$idUser	= (intval($_POST['id_usuario']) == 2) ? $_SESSION["usuariosaw"]["id"] : 0;
	$titulo	= $_POST['titulo'];
	$resposta = $_POST['resposta'];

	$arqData="";

	if(isset($_FILES['foto'])){
		$Nome_Arquivo   = $_FILES['foto']['name'];
		$file_tmp            = $_FILES['foto']['tmp_name'];
		$extensao = pathinfo($Nome_Arquivo, PATHINFO_EXTENSION);
		$caminhoArquivo = 'anexos/'.md5(uniqid()) . '-' . time() . '.'.$extensao;
		
	      move_uploaded_file($file_tmp,$caminhoArquivo);	
	}


	if( $acao == 0 ){
		// Verifico se já existe uma registro com o mesmo 'Título'
		$existe = mysqli_query(
			$conexao
			, "SELECT 1 
				FROM tbrespostasrapidas 
					WHERE titulo = '".$titulo."'"
		);
		
		if( mysqli_num_rows($existe) == 0 ){
			$sql = "INSERT INTO tbrespostasrapidas (id_usuario, titulo, resposta, arquivo, nome_arquivo) VALUES (NULL, '".$titulo."', '".$resposta."', '$caminhoArquivo', '$Nome_Arquivo')";

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
		if ($arqData!="") {
			$sql = "UPDATE tbrespostasrapidas 
					SET resposta = '$resposta'
						, titulo = '$titulo'
						, arquivo = '$caminhoArquivo'
						, nome_arquivo = '$Nome_Arquivo'
						 WHERE id = '".$id."'";			
		} else {
			$sql = "UPDATE tbrespostasrapidas 
					SET resposta = '".$resposta."'
						, titulo = '".$titulo."' WHERE id = '".$id."'";
		}
		
		$atualizar = mysqli_query($conexao, $sql)
			or die($sql . "<br/>" . mysqli_error($conexao));

		if( $atualizar ){ echo "2"; }
		else{ echo "9"; }
	}
<?php
	// Requires //
	require_once("../includes/padrao.inc.php");

	$htmlMensagens = "";
	$idDepto = $_GET['idDepto'];

	// SQL para Busca das Mensagens //
	$sqlMensagens = "SELECT tbu.id AS idUsuario, tbd.id AS idDepartamento, mensagem, nome, departamento, DATE_FORMAT(data_hora, '%d/%m/%Y %H:%i') AS data_hora
						FROM tbchatoperadores tbc
							INNER JOIN tbusuario tbu ON(tbu.id=tbc.id_usuario)
							LEFT JOIN tbdepartamentos tbd ON(tbd.id=tbc.id_departamento)
								WHERE ";

		// Filtro por Departamento //
		if( intval($idDepto) > 0 ){
			$sqlMensagens .= " tbc.id_departamento = '".intval($idDepto)."'";
		}
		else{ $sqlMensagens .= " tbc.id_departamento IS NULL"; }
	// FIM SQL para Busca das Mensagens //

	// Lista as conversas //
	$qryMensagens = mysqli_query(
		$conexao
		, $sqlMensagens .= " ORDER BY tbc.id"
	) or die("Erro ao listar as Conversas: " . mysqli_error($conexao));

	while( $arrMensagens = mysqli_fetch_assoc($qryMensagens) ){
		$dataHora = $arrMensagens["data_hora"];

		// Início da Mensagem //
		$htmlMensagens .= '<div class="message">';

		// Define se terá o destaque 'resposta' ou não no atributo 'class' //
		if( intval($arrMensagens["idDepartamento"]) > 0 ){
			$arrMensagens["nome"] = $arrMensagens["nome"] . " diz para (".$arrMensagens["departamento"]."):";
			$htmlMensagens .= '<div class="msg resposta">';
		}
		else{
			$arrMensagens["nome"] = $arrMensagens["nome"] . " diz para (Todos):";
			$htmlMensagens .= '<div class="msg">';
		}
		
		// Finaliza a Mensagem //
		$htmlMensagens .= '<strong>'.$arrMensagens["nome"].'</strong>
							<p>'.$arrMensagens["mensagem"].'</p>
							<span>'.$dataHora.'</span>
						</div>
					</div>';
	}
?>

<div class="central" id="divMsgChat">
	<?php echo $htmlMensagens; ?>
</div>
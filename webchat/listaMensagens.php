<?php
	require_once("../includes/padrao.inc.php");

	$htmlMensagens = "";
	$idDepto = intval($_GET['idDepto'] ?? 0);
	$usuarioAtualId = $_SESSION["usuariosaw"]["id"] ?? 0;

	// SQL para Busca das Mensagens
	$sqlMensagens = "SELECT 
						tbc.id,
						tbu.id AS idUsuario, 
						tbd.id AS idDepartamento, 
						tbc.mensagem, 
						tbu.nome, 
						tbd.departamento, 
						DATE_FORMAT(tbc.data_hora, '%d/%m %H:%i') AS data_hora,
						TIME_FORMAT(tbc.data_hora, '%H:%i') AS hora
					FROM tbchatoperadores tbc
					INNER JOIN tbusuario tbu ON(tbu.id=tbc.id_usuario)
					LEFT JOIN tbdepartamentos tbd ON(tbd.id=tbc.id_departamento)
					WHERE ";

	// Filtro por Departamento
	if( intval($idDepto) > 0 ){
		$sqlMensagens .= " tbc.id_departamento = '".intval($idDepto)."'";
	}
	else{ 
		$sqlMensagens .= " tbc.id_departamento IS NULL"; 
	}
	
	$sqlMensagens .= " ORDER BY tbc.id ASC";

	$qryMensagens = mysqli_query($conexao, $sqlMensagens) 
		or die("Erro ao listar as Conversas: " . mysqli_error($conexao));

	$totalMensagens = mysqli_num_rows($qryMensagens);

	if ($totalMensagens === 0) {
		echo '<div class="empty-state" style="margin: 40px 20px;">
				<i class="bi bi-chat-left"></i>
				<p>Nenhuma mensagem ainda</p>
				<small>Comece a conversa digitando sua primeira mensagem</small>
			</div>';
		exit;
	}

	$ultimoUsuarioId = null;
	$ultimaDataGrupo = null;

	while( $arrMensagens = mysqli_fetch_assoc($qryMensagens) ){
		$isOwnMessage = ($arrMensagens["idUsuario"] == $usuarioAtualId);
		$inicial = substr($arrMensagens["nome"], 0, 1);
		$temDestino = intval($arrMensagens["idDepartamento"]) > 0;
		
		// Criar grupo de mensagens se é novo usuário
		if ($ultimoUsuarioId !== $arrMensagens["idUsuario"]) {
			echo '<div class="message-group">';
			$ultimoUsuarioId = $arrMensagens["idUsuario"];
		}

		echo '<div class="message-item ' . ($isOwnMessage ? 'own' : '') . '" data-msg-id="' . $arrMensagens["id"] . '" data-msg-user="' . $arrMensagens["idUsuario"] . '">';
		
		// Avatar e ações (coluna vertical)
		echo '<div class="avatar-actions-wrapper">';
			echo '<div class="message-avatar" title="' . htmlspecialchars($arrMensagens["nome"]) . '">';
			echo strtoupper($inicial);
			echo '</div>';
			
			// Botões de ação (editar/deletar) - apenas para mensagens do usuário
			if ($isOwnMessage) {
				echo '<div class="message-actions">';
				echo '<button class="action-btn btn-edit" data-msg-id="' . $arrMensagens["id"] . '" title="Editar"><i class="bi bi-pencil"></i></button>';
				echo '<button class="action-btn btn-delete" data-msg-id="' . $arrMensagens["id"] . '" title="Deletar"><i class="bi bi-trash"></i></button>';
				echo '</div>';
			}
		echo '</div>';

		// Conteúdo
		echo '<div class="message-content">';
		echo '<div class="message-bubble">';
		
		// Header da mensagem
		$destinoInfo = '';
		if ($temDestino) {
			$destinoInfo = ' <span class="message-tag">' . htmlspecialchars($arrMensagens["departamento"]) . '</span>';
		} else {
			$destinoInfo = ' <span class="message-tag">Todos</span>';
		}
		
		echo '<div class="message-header">' . htmlspecialchars($arrMensagens["nome"]) . $destinoInfo . '</div>';
		
		// Texto da mensagem
		echo '<div class="message-text" data-original="' . htmlspecialchars($arrMensagens["mensagem"]) . '">' . nl2br(htmlspecialchars($arrMensagens["mensagem"])) . '</div>';
		
		// Timestamp
		echo '<div class="message-time">' . $arrMensagens["hora"] . '</div>';
		
		echo '</div>';
		echo '</div>';
		echo '</div>';
	}
?>
<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
require_once($_SERVER['DOCUMENT_ROOT'] . "/includes/padrao.inc.php");

header('Content-Type: application/json');

if (!isset($_GET['id']) || empty($_GET['id'])) {
    echo json_encode(['error' => 'ID inválido']);
    exit;
}

$idatendimento = intval($_GET['id']);

// Pega os dados da conversa
$queryConversa = "SELECT * FROM tbatendimento WHERE id = '$idatendimento'";
$resultConversa = mysqli_query($conexao, $queryConversa);
$conversa = mysqli_fetch_assoc($resultConversa);

if (!$conversa) {
    echo json_encode(['error' => 'Conversa não encontrada']);
    exit;
}

// Pega as mensagens
$queryMensagens = "
    SELECT 
        id,
        numero,
        seq,
        msg,
        nome_chat,
        id_atend,
        dt_msg,
        hr_msg
    FROM tbmsgatendimento 
    WHERE id_atendimento = '$idatendimento' AND canal = 0
    ORDER BY seq ASC
";

$resultMensagens = mysqli_query($conexao, $queryMensagens);
$mensagens = array();

while ($row = mysqli_fetch_assoc($resultMensagens)) {
    $mensagens[] = $row;
}

// Marca as mensagens como notificadas
mysqli_query($conexao, "UPDATE tbmsgatendimento SET notificada = true WHERE id_atendimento = '$idatendimento' AND canal = 0 AND id_atend > 0");

echo json_encode([
    'conversa' => $conversa,
    'mensagens' => $mensagens
]);
?>

<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
require_once($_SERVER['DOCUMENT_ROOT'] . "/includes/padrao.inc.php");

if (!isset($_POST['id_atendimento']) || !isset($_POST['mensagem'])) {
    echo 0;
    exit;
}

$idatendimento = intval($_POST['id_atendimento']);
$mensagem = mysqli_real_escape_string($conexao, $_POST['mensagem']);
$nome_atendente = isset($_SESSION["usuariosaw"]["nome"]) ? $_SESSION["usuariosaw"]["nome"] : 'Atendente';
$idatendente = isset($_SESSION["usuariosaw"]["id"]) ? intval($_SESSION["usuariosaw"]["id"]) : 0;

// Buscar o número da conversa
$queryNum = "SELECT numero FROM tbatendimento WHERE id = '$idatendimento'";
$resultNum = mysqli_query($conexao, $queryNum);
$rowNum = mysqli_fetch_assoc($resultNum);
$numero = $rowNum['numero'] ?? '';

// Buscar próxima sequência
$querySeq = "SELECT COALESCE(MAX(seq), 0) + 1 as newSeq FROM tbmsgatendimento WHERE id_atendimento = '$idatendimento' AND canal = 0";
$resultSeq = mysqli_query($conexao, $querySeq);
$rowSeq = mysqli_fetch_assoc($resultSeq);
$seq = $rowSeq['newSeq'] ?? 1;

// Inserir mensagem
$insertMsg = "
    INSERT INTO tbmsgatendimento 
    (id_atendimento, seq, numero, msg, nome_chat, id_atend, dt_msg, hr_msg, canal, situacao, notificada)
    VALUES 
    ('$idatendimento', '$seq', '$numero', '$mensagem', '$nome_atendente', '$idatendente', CURDATE(), CURTIME(), '0', 'E', true)
";

if (mysqli_query($conexao, $insertMsg)) {
    echo 1;
} else {
    echo 0;
}
?>

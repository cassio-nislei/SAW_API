<?php
require_once('api/v1/config.php');

$mysqli = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

if ($mysqli->connect_error) {
    die("Connection failed: " . $mysqli->connect_error);
}

// Test the exact SQL that Mensagem.php is trying to execute
$idAtendimento = 9;
$newSeq = 1;
$numero = $mysqli->real_escape_string('5511999998897');
$mensagem = $mysqli->real_escape_string('Teste direto');
$resposta = $mysqli->real_escape_string('');
$nomeChat = $mysqli->real_escape_string('');
$situacao = $mysqli->real_escape_string('E');
$idAtende = 0;
$canal = 1;
$chatId = $mysqli->real_escape_string(uniqid('API_'));
$chatIdResposta = "NULL";

$sql = "INSERT INTO tbmsgatendimento (id, seq, numero, msg, resp_msg, nome_chat, situacao, dt_msg, hr_msg, id_atend, canal, chatid, chatid_resposta) 
        VALUES ($idAtendimento, $newSeq, '$numero', '$mensagem', '$resposta', '$nomeChat', '$situacao', NOW(), CURTIME(), " . (int)$idAtende . ", " . (int)$canal . ", '$chatId', $chatIdResposta)";

echo "SQL: $sql\n\n";

if ($mysqli->query($sql)) {
    echo "SUCCESS! Message inserted.\n";
    echo "Insert ID: " . $mysqli->insert_id . "\n";
} else {
    echo "ERROR: " . $mysqli->error . "\n";
}

$mysqli->close();
?>

<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
require_once($_SERVER['DOCUMENT_ROOT'] . "/includes/padrao.inc.php");

if (!isset($_POST['nome']) || empty($_POST['nome'])) {
    echo 0;
    exit;
}

$nome = mysqli_real_escape_string($conexao, $_POST['nome']);

// Gerar número único
$ascii = implode('', range(0, 9));
$ascii = str_repeat($ascii, 5);
$numero = substr(str_shuffle($ascii), 0, 13);

// Inserir atendimento
$query = "
    INSERT INTO tbatendimento 
    (numero, nome_cliente, situacao, dt_inicio, canal)
    VALUES 
    ('$numero', '$nome', 'A', NOW(), '0')
";

if (mysqli_query($conexao, $query)) {
    // Inserir mensagem de sistema
    $idAtendimento = mysqli_insert_id($conexao);
    
    $queryMsgSistema = "
        INSERT INTO tbmsgatendimento 
        (id, seq, numero, msg, nome_chat, id_atend, dt_msg, hr_msg, canal, situacao, notificada)
        VALUES 
        ('$idAtendimento', 1, '$numero', 'Conversa iniciada pelo painel de atendimento.', 'Sistema', 0, CURDATE(), CURTIME(), '0', 'E', true)
    ";
    
    mysqli_query($conexao, $queryMsgSistema);
    
    echo 1;
} else {
    echo 0;
}
?>

<?php 
    require_once("../../includes/padrao.inc.php");

    $sqlUpdate = "UPDATE tbusuario SET datetime_online = NOW() WHERE id = '".$_SESSION["usuariosaw"]["id"]."'";
    $qryUpdate = mysqli_query($conexao, $sqlUpdate);

    // Tratamento de Erro //
    if( $qryUpdate ){ echo "Ok"; }
    else{ echo $sqlUpdate . "<br/>" . mysqli_error($conexao); }
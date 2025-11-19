<?php
  $usuarioBD = 'root';
  $senhaBD   = 'Ncm@647534';
  $servidorBD= '172.20.0.6';
  //Faz a conexão com o Banco de dados MYSQL
  @$conexao = mysqli_connect($servidorBD,$usuarioBD,$senhaBD,'saw15') or die("Não foi possivel conectar, aguarde um momento");
  mysqli_set_charset($conexao,"utf8mb4");
?>

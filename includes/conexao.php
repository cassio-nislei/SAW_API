<?php
  $usuarioBD = 'root';
  $senhaBD   = '';
  $servidorBD= 'localhost';
  //Faz a conexão com o Banco de dados MYSQL
  @$conexao = mysqli_connect($servidorBD,$usuarioBD,$senhaBD,'saw') or die("Não foi possivel conectar, aguarde um momento");
  mysqli_set_charset($conexao,"utf8mb4");
?>
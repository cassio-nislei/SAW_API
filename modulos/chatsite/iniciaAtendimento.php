<?php
  session_start();
  if (isset($_POST["nome"])){
    $_SESSION["chat"]["nome"] = $_POST["nome"];

 
    $ascii = implode('',  range(0, 9));
    $ascii = str_repeat($ascii, 5);
    $numero = substr(str_shuffle($ascii), 0, 13);
    $_SESSION["chat"]["numero"] = $numero;   

    $_SESSION["chat"]["menu"] = true;    

    echo 1;   
} 
?>
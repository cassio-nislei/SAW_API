<?php
session_start();
$arquivoexcluido = $_POST["file"];   

if (isset($_SESSION["anexos"])){ 
  foreach($_SESSION["anexos"] as $value){
	 if(file_exists($value) ){
		if ($value == 'arquivos/'.$arquivoexcluido){		
		  unlink($value);
		}
		if (isset($_SESSION["i"])){
	      $_SESSION["i"] = $_SESSION["i"] - 1;
	    }
		unset($_SESSION["anexos"][$value]);
	}
	}
  }

//$_SESSION["anexos"] = $newArr;	  
//print_r($_SESSION["anexos"]);
?>
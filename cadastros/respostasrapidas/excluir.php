<?php
  require_once("../../includes/padrao.inc.php");

  $id = $_POST['id'];
  $sql = "DELETE FROM tbrespostasrapidas WHERE id = '".$id."'";
	$excluir = mysqli_query($conexao,$sql);
   
  if( $excluir ){ echo "1"; }
  else{ echo "9"; }
<?php
	if( isset($_POST["image"]) ){
		$data = file_get_contents($_POST["image"]);
		echo 'data:image/jpeg;base64,'.base64_encode($data);
	}
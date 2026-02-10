<?php
  include "../../../includes/conexao.php";
  if (isset($_POST["de"])){
	//Formata data De para o BD
   $deF = explode('/', $_POST["de"]) ;
   $de = $deF[2].'-'.$deF[1].'-'.$deF[0];
	 //Formata data Até para o BD
   $ateF = explode('/', $_POST["ate"]) ;
   $ate = $ateF[2].'-'.$ateF[1].'-'.$ateF[0];
 }else{
   //$de = date('d-m-Y');  
   //$ate = date('d-m-Y'); 
   $de = date('Y-m-d');  
   $ate = date('Y-m-d');
 }
 //Verifico se possui etiquetas para filtrar
 if(isset($_POST['id_etiqueta'])){
	$etiquetas = $_POST['id_etiqueta'];

	//Mnto uma string separada por virgula
	$etiquetas_selecionadas = '';
	foreach ($etiquetas as $etiqueta) {
		$etiquetas_selecionadas .= $etiqueta . ','; 
	}
	$etiquetas_selecionadas = substr($etiquetas_selecionadas, 0, strlen($etiquetas_selecionadas) - 1);
  }else{
	$etiquetas_selecionadas = '0';
  }


   //Verifico se possui etiquetas para filtrar
 if(isset($_POST['id_atendente'])){
	$etiquetas = $_POST['id_atendente'];

	//Mnto uma string separada por virgula
	$atendentes_selecionados = '';
	foreach ($atendentes as $atendente) {
		$atendentes_selecionados .= $etiqueta . ','; 
	}
	$atendentes_selecionads = substr($atendentes_selecionados, 0, strlen($atendentes_selecionados) - 1);
  }else{
	$atendentes_selecionados = '0';
  }

 $situacao = $_POST["situacao"];
 $numero = $_POST["celular"];
 $protocolo = $_POST["protocolo"];

 //echo "De: $de Ate: $ate Etiqueta: $etiquetas_selecionadas Situacao: $situacao Numero: $numero protocolo:  ";
  
 $relatorio = mysqli_query($conexao, "CALL sprRelatorioAtendimentos('$de','$ate', '$situacao', '$etiquetas_selecionadas', '$numero', '$protocolo', '$atendentes_selecionados'  );");
 //$relatorio = mysqli_query($conexao, "CALL sprRelatorioAtendimentos('2023-05-04', '2023-05-04', '0', '0','','' );");
?>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" integrity="sha512-iecdLmaskl7CVkqkXNQ/ZH/XLlvWZOJyj7Yy7tcenmpD1ypASozpmT/E0iPtmFIB46ZmdtAc9eNBvH0H/ZpiBw==" crossorigin="anonymous" referrerpolicy="no-referrer" />
<div class="row">
	<div class="col-lg-12 col-md-12 col-sm-12 col-xs-12 col-12">
	  <div class="table-responsive w-auto small">
		<table class="table">
			<thead>
				<tr class="table-dark">
					<td>DATA</td>
					<td>CLIENTE</td>
					<td>NÚMERO</td>
					<td>ATENDENTE</td>
					<td>ETIQUETAS</td>
					<td>EXPORTAR CONVERSA</td>
					</tr>
			</thead>
			<tbody>
				<?php 
             
					while ($imprime = mysqli_fetch_assoc($relatorio)){
                        echo "<tr><td>".date("d/m/Y",strtotime($imprime["dt_atend"]))."</td>";
						echo "<td>".$imprime["nome"]."</td>";
						echo "<td>".$imprime["numero"]."</td>";
						echo "<td>".$imprime["nome_atend"]."</td>";
						echo "<td>".@$imprime["etiqueta"]."</td>";
						echo "<td>
						     <input type='hidden' id='id_atendimento' value='".$imprime["id"]."'>
							 <input type='hidden' id='numero' value='".$imprime["numero"]."'>
						<a href='' class='btnImprimir'><i class='fa-solid fa-file-pdf fa-lg'></i></a> &nbsp;&nbsp;
						<a href='' class='btnHtml'><i class='fa-brands fa-html5 fa-lg'></i></a>
						</td></tr>";

					}
				?>
				
			
				
			</tbody>
		
	  	  </table>
  	  </div>
	</div>


</div>
<script>

  	//Imprimir em PDF
		$('.btnHtml').click(function(e){
			e.preventDefault();
			var 	id_atendimento = $(this).parent().find("#id_atendimento").val(),
			        numero = $(this).parent().find("#numero").val();
		//	alert(id_atendimento);
			window.open('relatorios/atendimentos/conversa.php?id_atendimento='+id_atendimento+'&numero='+numero, '_blank');
		});

		$('.btnImprimir').click(function(e){
			e.preventDefault();
			var 	id_atendimento = $(this).parent().find("#id_atendimento").val(),
			        numero = $(this).parent().find("#numero").val();
		//	alert(id_atendimento);
			window.open('relatorios/atendimentos/imprimir.php?id_atendimento='+id_atendimento+'&numero='+numero, '_blank');
		});

</script>

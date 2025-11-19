<?php
  require_once("../../includes/padrao.inc.php");

                       mysqli_next_result($conexao);
                       // Definições de Variáveis //
                          $id = isset($_GET["idDepartamento"]) ? $_GET["idDepartamento"] : "";
                          $condicao = ($id !== "") ? " AND tud.id_departamento = '$id'" : " GROUP BY tu.id";
                      // FIM Definições de Variáveis //

                      $usuarios = mysqli_query(
                          $conexao
                          , "SELECT tu.id, tu.nome, tu.datetime_online
                              FROM tbusuario tu
                                INNER JOIN tbusuariodepartamento tud ON tud.id_usuario = tu.id
                                WHERE tu.situacao NOT IN('I')"
                                    . $condicao
                      );

                      // Recupera o Tempo para definir se o Usuário está Offline //
                      $qryParametros = mysqli_query($conexao , "SELECT minutos_offline FROM tbparametros");
                      $arrParametros = mysqli_fetch_assoc($qryParametros);
                    

                      if(mysqli_num_rows($usuarios) == 0){
                          echo  '<option value="0">'.htmlentities('Não há usuários nesse departamentos').'</option>';
                      }
                      else{


                        
       

        echo '<div class="contact-list">';
                          while($ln = mysqli_fetch_assoc($usuarios)){                            
                         
                            if( userOnline($ln["datetime_online"], $arrParametros["minutos_offline"]) ){
                                echo '
                                <div class="contact">
                                      <img src="../img/ico-contact.svg" alt="User 1">
                                      <p>'.$ln["nome"].'</p>
                                  </div>
                                 ';
                            }
                          }
                      }
                  
        echo '</div>';
                    ?>
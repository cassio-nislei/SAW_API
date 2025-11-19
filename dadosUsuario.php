<div tabindex="-1" id="panel-edit-profile" class="panel-left">
    <div class="_2fq0t copyable-area">
        <header class="_1FroB">
            <div class="Ghmsz" data-animate-drawer-title="true">
                <div class="SFEHG">
                    <button class="_1aTxu btn-close" id="btn-close-panel-edit-profile">
                        <span data-icon="back-light">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
                                <path fill="#FFF" d="M20 11H7.8l5.6-5.6L12 4l-8 8 8 8 1.4-1.4L7.8 13H20v-2z"></path>
                            </svg>
                        </span>
                    </button>
                </div>
                <div class="_1xGbt">Perfil</div>
            </div>
        </header>
        <div class="_2sNbV">
            <div class="_12fSF">
                <div class="_1wCju">
                    <div class="_2UkYn" dir="ltr">
                        <div class="_1WNtc">
                            <div class="IuYNx">
                                <div id="photo-container-edit-profile" style="width: 200px; height: 200px; top: 0px; left: 0px; position: absolute;">
                                    <img src="#" class="photo" id="img-panel-edit-profile" style="height: 100%; width: 100%; display:none">
                                    <div class="_3ZW2E no-photo-edit" id="img-default-panel-edit-profile">
                                        <span data-icon="default-user">
                                            <img src="<?php echo $_SESSION["parametros"]["imagem_perfil"]; ?>" class="rounded-circle user_img_msg">
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>
                    <input type="file" accept="image/gif,image/jpeg,image/jpg,image/png" style="display: none;" id="input-profile-photo">
                </div>
            </div>
            <div class="_1CRb5 _34vig _2phEY">
                <div class="_2VQzd">
                    <div>
                        <div class="LlZXr">
                            <div class="_3e7ko _1AUd-">
                                <span class="_1sYdX">Seu Nome</span>
                            </div>
                        </div>
                    </div>
                </div>
                <div tabindex="-1" class="ogWqZ  _2-h1L _31WRs">
                    <span class="_2rXhY CrwPM"></span>
                    <div class="_2OIDe"></div>
                    <div class="_1DTd4">
                        <div tabindex="-1" class="_3F6QL bsmJe">
                            <div class="_39LWd" style="visibility: hidden;"></div>
                            <div id="input-name-panel-edit-profile" class="_2S1VP copyable-text selectable-text input-name" contenteditable="true" dir="ltr">
                                <?php echo $_SESSION["usuariosaw"]["nome_chat"]; ?>
                            </div>
                        </div>
                        <div class="_2YmC2">
                            <span class="_3jFFV">
                                <div class="_3cyFx btn-save" id="btn-save-panel-edit-profile" title="Clique para salvar" style="transform: scaleX(1) scaleY(1); opacity: 1;">
                                    <span data-icon="checkmark">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
                                            <path opacity=".45" fill="#263238" d="M9 17.2l-4-4-1.4 1.3L9 19.9 20.4 8.5 19 7.1 9 17.2z"></path>
                                        </svg>
                                    </span>
                                </div>
                            </span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="_idKB">
                <span class="Cpiae">Este nome será visível para seus contatos.</span>
            </div>
            <div class="_idKB">
                <span class="Cpiae"><input type="checkbox" name="horario_almoco" id="horario_almoco">Em horario de almoço.</span><br>
                <span id="spanHorarioAlmoco">
                    <textarea id="msgAlmocoAtendente" name="msgAlmocoAtendente" style="width: 100%; height: 100px;"></textarea>
                </span>
            </div>
        </div>
    </div>
</div>



<script>
$(document).ready(function() {

    
function listarAlmocoAtendente(){
     
        $.post("gravarHorarioAlmoco.php", function(retorno){
            var dadosalomoco = JSON.parse(retorno);    

              //Verifico se o Checkbox está marcado para mostrar ou oculta o campo da mensagem de almoço             
                 if( dadosalomoco.em_almoco==1 ){                    
                    $('#horario_almoco').prop('checked', true);                   
                    $("#mdlAlmocando").modal("show");         
                      
                } else{ 

                    $('#horario_almoco').prop('checked', false);   
                    $("#mdlAlmocando").modal("hide");                 
                }
            $('#msgAlmocoAtendente').val(dadosalomoco.msg_almoco);
        })
     }

     listarAlmocoAtendente();

 

     function gravaAlmocoAtendente(){
        var em_almoco = $("#horario_almoco").prop("checked");
            msgAlmoco  = $("#msgAlmocoAtendente").val();
       
        $.post("gravarHorarioAlmoco.php",{em_almoco:em_almoco, msgAlmoco:msgAlmoco}, function(retorno){
            listarAlmocoAtendente();
        })
     }
     $('#horario_almoco').change(function(){
        gravaAlmocoAtendente();
     })

     $('#msgAlmocoAtendente').change(function(){
        gravaAlmocoAtendente();
     })
    

     $('#horario_almoco').click(function() {
        // Verifica se o campo está 'checado' //
        if( $("#horario_almoco").prop("checked") ){
            $("#spanHorarioAlmoco").attr("style", "display:block");  
            document.location.reload(true);                        
        }
        else{ $("#spanHorarioAlmoco").attr("style", "display:none"); }
    });

    $('#btnVoltardoAlmoco').click(function() {
        $('#horario_almoco').prop('checked', false);
        gravaAlmocoAtendente();
        listarAlmocoAtendente();
    });



   


 });

</script>
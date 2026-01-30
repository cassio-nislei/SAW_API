<?php
require_once("../../includes/padrao.inc.php");
?>

<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kanban - Atendimentos</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body {
            background-color: #f5f5f5;
            padding: 15px;
        }
        
        .kanban-header-title {
            margin-bottom: 20px;
            padding: 0 10px;
        }
        
        .kanban-container {
            display: flex;
            gap: 15px;
            overflow-x: auto;
            overflow-y: hidden;
            padding: 0;
            height: calc(100vh - 150px);
            max-width: 100%;
        }
        
        .kanban-column {
            background-color: #e8eef5;
            border-radius: 8px;
            padding: 12px;
            min-width: 280px;
            max-width: 280px;
            flex-shrink: 0;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        
        .kanban-column-header {
            font-weight: bold;
            font-size: 15px;
            margin-bottom: 12px;
            color: #333;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-bottom: 8px;
            border-bottom: 2px solid #ccc;
            flex-shrink: 0;
        }
        
        .kanban-column-content {
            overflow-y: auto;
            flex: 1;
            padding-right: 5px;
        }
        
        .kanban-column-content::-webkit-scrollbar {
            width: 6px;
        }
        
        .kanban-column-content::-webkit-scrollbar-track {
            background: transparent;
        }
        
        .kanban-column-content::-webkit-scrollbar-thumb {
            background: #ccc;
            border-radius: 3px;
        }
        
        .kanban-column-content::-webkit-scrollbar-thumb:hover {
            background: #999;
        }
        
        .kanban-badge {
            background-color: #999;
            color: white;
            padding: 2px 8px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: bold;
        }
        
        .kanban-card {
            background-color: white;
            border-radius: 6px;
            padding: 10px;
            margin-bottom: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            cursor: pointer;
            transition: all 0.3s ease;
            border-left: 4px solid #4e73df;
            flex-shrink: 0;
            position: relative;
        }
        
        .kanban-card-foto {
            position: absolute;
            top: 8px;
            right: 8px;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            border: 2px solid #ddd;
            object-fit: cover;
            background-color: #f0f0f0;
        }
        
        .kanban-card-avatar {
            position: absolute;
            top: 8px;
            right: 8px;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            border: 2px solid #ddd;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            color: white;
            font-size: 16px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        .kanban-card-content {
            padding-right: 45px;
        }
        
        .kanban-card-visualizar {
            position: absolute;
            bottom: 8px;
            right: 8px;
            width: 15px;
            height: 15px;
            background: none;
            border: none;
            color: #4e73df;
            cursor: pointer;
            padding: 0;
            font-size: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s ease;
        }
        
        .kanban-card-visualizar:hover {
            color: #2e5090;
            transform: scale(1.2);
        }
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
            transform: translateY(-2px);
        }
        
        .kanban-card-title {
            font-weight: bold;
            color: #333;
            margin-bottom: 4px;
            font-size: 13px;
            word-wrap: break-word;
        }
        
        .kanban-card-text {
            font-size: 11px;
            color: #666;
            margin: 2px 0;
            word-wrap: break-word;
        }
        
        .kanban-card-numero {
            color: #4e73df;
            font-weight: bold;
            font-size: 10px;
        }
        
        .kanban-card-hora {
            color: #999;
            font-size: 10px;
            margin-top: 4px;
        }
        
        /* Cores por coluna */
        .triagem .kanban-column-header {
            background-color: #fff3cd;
            color: #856404;
            border-color: #ffc107;
        }
        
        .triagem .kanban-card {
            border-left-color: #ffc107;
        }
        
        .espera .kanban-column-header {
            background-color: #d1ecf1;
            color: #0c5460;
            border-color: #17a2b8;
        }
        
        .espera .kanban-card {
            border-left-color: #17a2b8;
        }
        
        .andamento .kanban-column-header {
            background-color: #d4edda;
            color: #155724;
            border-color: #28a745;
        }
        
        .andamento .kanban-card {
            border-left-color: #28a745;
        }
        
        .encerrados .kanban-column-header {
            background-color: #f8d7da;
            color: #721c24;
            border-color: #dc3545;
        }
        
        .encerrados .kanban-card {
            border-left-color: #dc3545;
        }
        
        .kanban-empty {
            padding: 15px;
            text-align: center;
            color: #999;
            font-style: italic;
            font-size: 12px;
        }
        
        /* Responsivo */
        @media (max-width: 768px) {
            .kanban-column {
                min-width: 250px;
                max-width: 250px;
            }
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <h2 class="kanban-header-title"><i class="fas fa-tasks"></i> Kanban - Atendimentos</h2>
        
        <div class="kanban-container">
            <!-- COLUNA TRIAGEM -->
            <div class="kanban-column triagem">
                <div class="kanban-column-header">
                    <span>📋 Triagem</span>
                    <span class="kanban-badge" id="badge-triagem">0</span>
                </div>
                <div id="col-triagem" class="kanban-column-content">
                </div>
            </div>
            
            <!-- COLUNA AGUARDANDO -->
            <div class="kanban-column espera">
                <div class="kanban-column-header">
                    <span>⏳ Aguardando</span>
                    <span class="kanban-badge" id="badge-espera">0</span>
                </div>
                <div id="col-espera" class="kanban-column-content">
                </div>
            </div>
            
            <!-- COLUNA EM ANDAMENTO -->
            <div class="kanban-column andamento">
                <div class="kanban-column-header">
                    <span>💬 Em Andamento</span>
                    <span class="kanban-badge" id="badge-andamento">0</span>
                </div>
                <div id="col-andamento" class="kanban-column-content">
                </div>
            </div>
            
            <!-- COLUNA ENCERRADOS -->
            <div class="kanban-column encerrados">
                <div class="kanban-column-header">
                    <span>✓ Encerrados</span>
                    <span class="kanban-badge" id="badge-encerrados">0</span>
                </div>
                <div id="col-encerrados" class="kanban-column-content">
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
    
    <!-- Modal de Histórico -->
    <div class="window maior" id="modalHistorico" style="display: none;">
        <div id="HistoricoAberto" class="_1GX8_">
            <div class="YUoyu" data-asset-chat-background="true"></div>
            <header class="_3AwwN">
                <div class="_18tv-" role="button">
                    <div class="_1WliW" style="height: 40px; width: 40px;">
                        <img src="#" class="Qgzj8 gqwaM" style="display:none;" id="active-photo-historico">
                        <div class="_3ZW2E">
                            <span data-icon="default-user">
                                <img src="images/cliente.png" class="rounded-circle user_img" id="foto-historico">
                            </span>
                        </div>
                    </div>
                </div>
                <div class="_1WBXd" role="button">
                    <div class="_2EbF-">
                        <div class="_2zCDG">
                            <span dir="auto" title="Histórico de Mensagens" class="_1wjpf" id="active-name-historico">Histórico</span>
                        </div>
                    </div>
                    <div class="_3sgkv Gd51Q">
                        <span id="numero-historico"></span>
                        Total de mensagens: (<span id="TotalMensagensHistorico" style="font-size:10px">0</span>)
                    </div>
                </div>
                <div class="_1i0-u">
                    <ul class="user-options alt">
                        <li class="tooltip">
                            <a href="javascript:;" id="fecharHistorico">
                                <i class="far fa-times-circle" style="font-size:24px" alt="Fechar Histórico" title="Fechar Histórico"></i>
                            </a>
                        </li>
                    </ul>
                </div>
            </header>
            <div class="_3zJZ2 ">
                <div class="copyable-area">
                    <div class="messages-container" id="panel-messages-container2" tabindex="0">
                        <div id="mensagensHistorico"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        function abrirHistorico(numero, nome) {
            // Mostrar modal
            $('#modalHistorico').css('display', 'block');
            
            // Atualizar header
            $('#active-name-historico').text(nome || 'Histórico');
            $('#numero-historico').text(numero);
            
            // Carregar histórico de mensagens
            var nome_encoded = encodeURIComponent(nome || '');
            var idCanal = '1';
            
            $.post("../../atendimento/qtdConversas.php", {
                numero: numero,
                id: 'all',
                id_canal: idCanal
            }, function(retorno) {
                $.ajax("../../atendimento/listaConversas.php?id=all&numero=" + numero + "&nome=" + nome_encoded + "&id_canal=" + idCanal).done(function(data) {
                    $('#mensagensHistorico').html(data);
                    scrollToHistoricoBottom();
                });
                $("#TotalMensagensHistorico").html(retorno);
            });
            
            // Fechar modal ao clicar em X
            $("#fecharHistorico").click(function() {
                $.post("../../includes/deletarArquivos.php", {numero: numero}, function() {
                    $('#modalHistorico').css('display', 'none');
                });
            });
        }
        
        function scrollToHistoricoBottom() {
            $("#panel-messages-container2").animate({ scrollTop: $("#panel-messages-container2")[0].scrollHeight }, 1000);
            if( $("#mensagensHistorico").length ){
                var rolagem = document.getElementById('mensagensHistorico');
                var target = $('#mensagensHistorico');
                target.animate({ scrollTop: rolagem.scrollHeight }, 200);
            }
        }
        
        // Fechar modal ao clicar fora
        $(document).on('click', function(event) {
            if($(event.target).attr('id') === 'modalHistorico') {
                $('#modalHistorico').css('display', 'none');
            }
        });
    </script>
        function carregarKanban() {
            console.log('Carregando kanban...');
            $.ajax({
                url: 'dados.php',
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    console.log('Dados recebidos:', data);
                    
                    // Limpar colunas
                    $('#col-triagem').html('');
                    $('#col-espera').html('');
                    $('#col-andamento').html('');
                    $('#col-encerrados').html('');
                    
                    let counts = {
                        triagem: 0,
                        espera: 0,
                        andamento: 0,
                        encerrados: 0
                    };
                    
                    // Processar atendimentos
                    if(Array.isArray(data) && data.length > 0) {
                        $.each(data, function(idx, atendimento) {
                            console.log('Processando:', atendimento.situacao);
                            let card = criarCard(atendimento);
                            let coluna = atendimento.situacao;
                            
                            // Mapear situação para o padrão esperado
                            if(coluna === 'T' || coluna === 'TRIAGEM') {
                                $('#col-triagem').append(card);
                                counts.triagem++;
                            } else if(coluna === 'P' || coluna === 'PENDENTE') {
                                $('#col-espera').append(card);
                                counts.espera++;
                            } else if(coluna === 'A' || coluna === 'ATENDENDO') {
                                $('#col-andamento').append(card);
                                counts.andamento++;
                            } else if(coluna === 'F' || coluna === 'FINALIZADO') {
                                $('#col-encerrados').append(card);
                                counts.encerrados++;
                            }
                        });
                    } else {
                        console.log('Nenhum dado recebido ou array vazio');
                    }
                    
                    // Atualizar badges
                    $('#badge-triagem').text(counts.triagem);
                    $('#badge-espera').text(counts.espera);
                    $('#badge-andamento').text(counts.andamento);
                    $('#badge-encerrados').text(counts.encerrados);
                    
                    // Adicionar mensagens vazias
                    if(counts.triagem === 0) $('#col-triagem').html('<div class="kanban-empty">Nenhum atendimento</div>');
                    if(counts.espera === 0) $('#col-espera').html('<div class="kanban-empty">Nenhum atendimento</div>');
                    if(counts.andamento === 0) $('#col-andamento').html('<div class="kanban-empty">Nenhum atendimento</div>');
                    if(counts.encerrados === 0) $('#col-encerrados').html('<div class="kanban-empty">Nenhum atendimento</div>');
                    
                    console.log('Totais:', counts);
                },
                error: function(err) {
                    console.error('Erro ao carregar kanban:', err);
                    $('#col-triagem').html('<div class="kanban-empty">Erro ao carregar</div>');
                }
            });
        }
        
        function criarCard(atendimento) {
            let nome = (atendimento.nome && atendimento.nome.trim()) ? atendimento.nome : 'Sem nome';
            let departamento = (atendimento.departamento && atendimento.departamento.trim()) ? atendimento.departamento : 'Sem Departamento';
            let atendente = (atendimento.atendente && atendimento.atendente.trim()) ? atendimento.atendente : 'Não atribuído';
            let fotoPerfil = (atendimento.foto_perfil && atendimento.foto_perfil.trim()) ? atendimento.foto_perfil : '';
            
            let fotoHtml = '';
            if(fotoPerfil) {
                fotoHtml = `<img src="${fotoPerfil}" alt="Foto" class="kanban-card-foto">`;
            } else {
                // Gerar iniciais do nome
                let iniciais = nome.split(' ')
                    .map(n => n.charAt(0).toUpperCase())
                    .slice(0, 2)
                    .join('');
                fotoHtml = `<div class="kanban-card-avatar">${iniciais}</div>`;
            }
            
            return `
                <div class="kanban-card" onclick="abrirConversa('${atendimento.id}', '${atendimento.numero}', '${nome}', '${atendimento.id_canal}')">
                    ${fotoHtml}
                    <button class="kanban-card-visualizar" onclick="event.stopPropagation(); abrirHistorico('${atendimento.numero}', '${nome}')" title="Visualizar histórico">
                        <i class="fas fa-eye"></i>
                    </button>
                    <div class="kanban-card-content">
                        <div class="kanban-card-title">${nome}</div>
                        <div class="kanban-card-numero">📱 ${atendimento.numero}</div>
                        <div class="kanban-card-text">Depto: ${departamento}</div>
                        <div class="kanban-card-text">Atendente: ${atendente}</div>
                        <div class="kanban-card-hora">🕐 ${atendimento.hora}</div>
                    </div>
                </div>
            `;
        }
        
        function abrirConversa(id, numero, nome, id_canal) {
            let url = '../../atendimento/conversa.php?id=' + encodeURIComponent(id) + 
                      '&numero=' + encodeURIComponent(numero) + 
                      '&nome=' + encodeURIComponent(nome) + 
                      '&id_canal=' + encodeURIComponent(id_canal);
            window.location.href = url;
        }
        
        // Carregar kanban ao abrir a página
        $(document).ready(function() {
            console.log('Página pronta, carregando kanban');
            carregarKanban();
            // Atualizar a cada 30 segundos
            setInterval(carregarKanban, 30000);
        });
    </script>
</body>
</html>

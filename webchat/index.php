<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chat Operadores</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            background: #f0f2f5;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .webchat-container {
            display: flex;
            flex-direction: column;
            height: 100%;
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        /* Header */
        .webchat-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
        }

        .webchat-header-title {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 18px;
            font-weight: 600;
        }

        .webchat-header-title i {
            font-size: 24px;
        }

        .department-selector {
            min-width: 200px;
        }

        .department-selector select {
            border-radius: 20px;
            border: 2px solid rgba(255, 255, 255, 0.3);
            background: rgba(255, 255, 255, 0.1);
            color: white;
            padding: 8px 12px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .department-selector select:hover {
            background: rgba(255, 255, 255, 0.2);
            border-color: rgba(255, 255, 255, 0.5);
        }

        .department-selector select option {
            background: #667eea;
            color: white;
        }

        /* Messages Area */
        .webchat-messages {
            flex: 1;
            overflow-y: auto;
            padding: 20px;
            display: flex;
            flex-direction: column;
            gap: 15px;
            background: #f8f9fa;
        }

        .webchat-messages::-webkit-scrollbar {
            width: 6px;
        }

        .webchat-messages::-webkit-scrollbar-track {
            background: transparent;
        }

        .webchat-messages::-webkit-scrollbar-thumb {
            background: #ccc;
            border-radius: 3px;
        }

        .webchat-messages::-webkit-scrollbar-thumb:hover {
            background: #999;
        }

        /* Message Styles */
        .message-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .message-item {
            display: flex;
            align-items: flex-start;
            gap: 8px;
            animation: slideIn 0.3s ease;
        }

        .message-item.own {
            justify-content: flex-end;
        }

        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .message-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            font-size: 12px;
            flex-shrink: 0;
        }

        .message-item.own .message-avatar {
            order: 2;
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }

        .message-content {
            flex: 1;
            max-width: 70%;
        }

        .message-item.own .message-content {
            text-align: right;
        }

        .message-bubble {
            background: white;
            border-radius: 12px;
            padding: 10px 14px;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.08);
            word-wrap: break-word;
        }

        .message-item.own .message-bubble {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-bottom-right-radius: 4px;
        }

        .message-item:not(.own) .message-bubble {
            border-bottom-left-radius: 4px;
        }

        .message-header {
            font-weight: 600;
            font-size: 13px;
            color: #333;
            margin-bottom: 4px;
        }

        .message-item.own .message-header {
            color: rgba(255, 255, 255, 0.9);
        }

        .message-text {
            font-size: 14px;
            line-height: 1.4;
            color: #333;
            word-wrap: break-word;
        }

        .message-item.own .message-text {
            color: white;
        }

        .message-time {
            font-size: 11px;
            color: #999;
            margin-top: 4px;
        }

        .message-item.own .message-time {
            color: rgba(255, 255, 255, 0.7);
        }

        .message-tag {
            display: inline-block;
            background: #e7f3ff;
            color: #0066cc;
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 600;
            margin-left: 4px;
        }

        .message-item.own .message-tag {
            background: rgba(255, 255, 255, 0.2);
            color: white;
        }

        /* Empty State */
        .empty-state {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100%;
            color: #999;
        }

        .empty-state i {
            font-size: 48px;
            margin-bottom: 15px;
            opacity: 0.5;
        }

        /* Input Area */
        .webchat-input-area {
            background: white;
            border-top: 1px solid #e0e0e0;
            padding: 15px 20px;
            display: flex;
            gap: 10px;
            align-items: flex-end;
        }

        .input-wrapper {
            flex: 1;
            display: flex;
            gap: 8px;
        }

        #msgChat {
            flex: 1;
            border: 2px solid #e0e0e0;
            border-radius: 20px;
            padding: 10px 15px;
            resize: none;
            font-family: inherit;
            font-size: 14px;
            transition: all 0.3s ease;
            max-height: 100px;
            min-height: 40px;
        }

        #msgChat:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .btn-send {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            color: white;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
            flex-shrink: 0;
        }

        .btn-send:hover {
            transform: scale(1.05);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        }

        .btn-send:active {
            transform: scale(0.95);
        }

        .btn-send i {
            font-size: 18px;
        }

        /* Loading indicator */
        .loading-spinner {
            display: inline-block;
            width: 12px;
            height: 12px;
            border: 2px solid #f3f3f3;
            border-top: 2px solid #667eea;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* Status indicator */
        .status-indicator {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            color: #666;
            margin-top: 4px;
        }

        .status-dot {
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: #4caf50;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .webchat-header {
                flex-direction: column;
                align-items: flex-start;
            }

            .department-selector {
                width: 100%;
            }

            .department-selector select {
                width: 100%;
            }

            .message-content {
                max-width: 85%;
            }
        }
    </style>
</head>
<body style="padding: 10px;">
    <input type="hidden" id="idDepartamentoChat" value="0" />
    <input type="hidden" id="carregaWebChat" value="1" />

    <div class="webchat-container">
        <!-- Header -->
        <div class="webchat-header">
            <div class="webchat-header-title">
                <i class="bi bi-chat-dots"></i>
                <span>Chat Operadores</span>
            </div>
            <div class="department-selector">
                <select id="mudaDepartamento">
                    <option value="0">📌 Todos os setores</option>
                    <?php 
                    require_once("../includes/padrao.inc.php");
                    $qryDeptos = mysqli_query(
                        $conexao,
                        "SELECT id, departamento FROM tbdepartamentos ORDER BY departamento"
                    );
                
                    while( $arrDeptos = mysqli_fetch_assoc($qryDeptos) ){
                        echo '<option value="'.$arrDeptos["id"].'">🏢 '.$arrDeptos["departamento"].'</option>';
                    }
                    ?>
                </select>
            </div>
        </div>

        <!-- Messages -->
        <div class="webchat-messages" id="conversas_chat">
            <div class="empty-state">
                <i class="bi bi-chat-left"></i>
                <p>Nenhuma mensagem ainda</p>
                <small>Comece digitando sua primeira mensagem abaixo</small>
            </div>
        </div>

        <!-- Input -->
        <div class="webchat-input-area">
            <div class="input-wrapper">
                <textarea 
                    id="msgChat" 
                    placeholder="Escreva sua mensagem..." 
                    data-lpignore="true"
                ></textarea>
                <button class="btn-send" id="btnSendMsg" title="Enviar (Enter)" disabled>
                    <i class="bi bi-send-fill"></i>
                </button>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        $(document).ready(function() {
            const chatContainer = $('#conversas_chat');
            const departamentoInput = $('#idDepartamentoChat');
            const msgInput = $('#msgChat');
            const btnSend = $('#btnSendMsg');
            let lastMessageId = 0;
            let isLoading = false;

            // Auto-resize textarea
            msgInput.on('input', function() {
                this.style.height = 'auto';
                this.style.height = Math.min(this.scrollHeight, 100) + 'px';
                btnSend.prop('disabled', !$(this).val().trim());
            });

            // Enable/disable send button
            msgInput.on('keyup', function() {
                btnSend.prop('disabled', !$(this).val().trim());
            });

            // Load messages
            function carregaChat(idDepartamento) {
                if (isLoading || $('#carregaWebChat').val() !== "1") return;
                
                isLoading = true;

                $.ajax({
                    url: 'webchat/listaMensagens.php?idDepto=' + idDepartamento,
                    type: 'GET',
                    dataType: 'html',
                    timeout: 10000,
                    success: function(data) {
                        if (data.trim()) {
                            chatContainer.html(data);
                            scrollToBottom();
                        }
                        isLoading = false;
                    },
                    error: function(xhr, status, error) {
                        console.error('Erro ao carregar mensagens:', error);
                        isLoading = false;
                    }
                });
            }

            // Scroll to bottom
            function scrollToBottom() {
                chatContainer.animate({
                    scrollTop: chatContainer.prop('scrollHeight')
                }, 300);
            }

            // Send message
            function enviarMensagem() {
                const mensagem = msgInput.val().trim();
                const idDepto = departamentoInput.val();

                if (!mensagem) return;

                btnSend.prop('disabled', true).html('<div class="loading-spinner"></div>');

                $.ajax({
                    url: 'webchat/gravarMensagemChat.php',
                    type: 'POST',
                    dataType: 'json',
                    data: {
                        idDepto: idDepto,
                        strMensagem: mensagem
                    },
                    timeout: 10000,
                    success: function(response) {
                        if (response.success) {
                            msgInput.val('').trigger('input');
                            carregaChat(idDepto);
                        } else {
                            console.error('Erro:', response.error);
                            alert('Erro ao enviar mensagem: ' + (response.error || 'Tente novamente'));
                            btnSend.prop('disabled', false).html('<i class="bi bi-send-fill"></i>');
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error('Erro:', error, status);
                        let mensagemErro = 'Erro ao enviar mensagem.';
                        
                        if (status === 'timeout') {
                            mensagemErro += ' Tempo limite excedido.';
                        } else if (xhr.responseJSON && xhr.responseJSON.error) {
                            mensagemErro += ' ' + xhr.responseJSON.error;
                        }
                        
                        alert(mensagemErro);
                        btnSend.prop('disabled', false).html('<i class="bi bi-send-fill"></i>');
                    }
                });
            }

            // Send button click
            btnSend.on('click', enviarMensagem);

            // Send with Enter (Shift+Enter for new line)
            msgInput.on('keydown', function(e) {
                if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    if (!btnSend.prop('disabled')) {
                        enviarMensagem();
                    }
                }
            });

            // Department change
            $('#mudaDepartamento').on('change', function() {
                departamentoInput.val($(this).val());
                carregaChat($(this).val());
            });

            // Auto-refresh messages every 5 seconds
            setInterval(function() {
                carregaChat(departamentoInput.val());
            }, 5000);

            // Initial load
            carregaChat(0);
        });
    </script>
</body>
</html>
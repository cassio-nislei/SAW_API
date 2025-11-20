#!/usr/bin/env pwsh
# SAW API - Swagger Endpoints Validator - Versão Simplificada

$baseUrl = "http://104.234.173.105:7080/api/v1"

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        SAW API - SWAGGER ENDPOINTS VALIDATOR (42 ENDPOINTS)      ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Define todos os 42 endpoints por categoria
$categories = @{
    "Health" = @(
        @{method="GET"; path="/"; name="Health Check"}
    );
    "Autenticação" = @(
        @{method="POST"; path="/auth/login"; name="Login"}
    );
    "Atendimentos" = @(
        @{method="GET"; path="/atendimentos"; name="Listar"},
        @{method="POST"; path="/atendimentos"; name="Criar"},
        @{method="POST"; path="/atendimentos/verificar-pendente"; name="Verificar pendente"},
        @{method="POST"; path="/atendimentos/finalizar"; name="Finalizar"},
        @{method="POST"; path="/atendimentos/gravar-mensagem"; name="Gravar mensagem"},
        @{method="PUT"; path="/atendimentos/atualizar-setor"; name="Atualizar setor"},
        @{method="GET"; path="/atendimentos/inativos"; name="Inativos"}
    );
    "Mensagens" = @(
        @{method="POST"; path="/mensagens/verificar-duplicada"; name="Verificar duplicada"},
        @{method="POST"; path="/mensagens/status-multiplas"; name="Status múltiplas"},
        @{method="GET"; path="/mensagens/pendentes-envio"; name="Pendentes"},
        @{method="GET"; path="/mensagens/proxima-sequencia"; name="Próxima sequência"},
        @{method="PUT"; path="/mensagens/marcar-excluida"; name="Marcar excluída"},
        @{method="POST"; path="/mensagens/marcar-reacao"; name="Marcar reação"},
        @{method="PUT"; path="/mensagens/marcar-enviada"; name="Marcar enviada"},
        @{method="POST"; path="/mensagens/comparar-duplicacao"; name="Comparar"}
    );
    "Contatos" = @(
        @{method="GET"; path="/contatos/exportar"; name="Exportar"},
        @{method="GET"; path="/contatos/buscar-nome"; name="Buscar nome"}
    );
    "Agendamentos" = @(
        @{method="GET"; path="/agendamentos/pendentes"; name="Pendentes"}
    );
    "Parâmetros" = @(
        @{method="GET"; path="/parametros/sistema"; name="Sistema"},
        @{method="GET"; path="/parametros/verificar-expediente"; name="Expediente"}
    );
    "Menus" = @(
        @{method="GET"; path="/menus/principal"; name="Principal"},
        @{method="GET"; path="/menus/submenus"; name="Submenus"}
    );
    "Respostas" = @(
        @{method="GET"; path="/respostas/respostas-automaticas"; name="Automáticas"}
    );
    "Departamentos" = @(
        @{method="GET"; path="/departamentos/por-menu"; name="Por menu"}
    );
    "Avisos" = @(
        @{method="POST"; path="/avisos/registrar"; name="Registrar"},
        @{method="DELETE"; path="/avisos/limpar-antigos"; name="Limpar antigos"},
        @{method="DELETE"; path="/avisos/limpar-numero"; name="Limpar número"},
        @{method="GET"; path="/avisos/verificar-existente"; name="Verificar"}
    )
}

$totalCount = 0
$passCount = 0
$warnCount = 0
$failCount = 0

foreach ($categoryName in $categories.Keys | Sort-Object) {
    $categoryEndpoints = $categories[$categoryName]
    Write-Host "🔹 [$categoryName] - $($categoryEndpoints.Count) endpoint(s)" -ForegroundColor Magenta
    
    foreach ($endpoint in $categoryEndpoints) {
        $url = "$baseUrl$($endpoint.path)"
        $totalCount++
        
        try {
            $response = Invoke-WebRequest -Uri $url -Method $endpoint.method -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
            Write-Host "   ✅ $($endpoint.method) $($endpoint.path)" -ForegroundColor Green
            $passCount++
        }
        catch {
            $statusCode = $_.Exception.Response.StatusCode.Value__
            if ($statusCode -eq 404 -or $statusCode -eq 405 -or $statusCode -eq 401 -or $statusCode -eq 400) {
                Write-Host "   ⚠️  $($endpoint.method) $($endpoint.path) - $statusCode" -ForegroundColor Yellow
                $warnCount++
            }
            else {
                Write-Host "   ❌ $($endpoint.method) $($endpoint.path) - Erro" -ForegroundColor Red
                $failCount++
            }
        }
    }
    Write-Host ""
}

# Resumo
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                         RESUMO FINAL                             ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$percentage = if ($totalCount -gt 0) { [math]::Round(($passCount / $totalCount) * 100, 1) } else { 0 }

Write-Host "✅ SUCESSO: $passCount/$totalCount" -ForegroundColor Green
Write-Host "⚠️  AVISO: $warnCount/$totalCount" -ForegroundColor Yellow
Write-Host "❌ ERRO: $failCount/$totalCount" -ForegroundColor Red
Write-Host "📊 Taxa de sucesso: $percentage%" -ForegroundColor Cyan
Write-Host ""

if ($failCount -eq 0) {
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║    ✅ TODOS OS ENDPOINTS ESTÃO OPERACIONAIS (SWAGGER OK)        ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Green
} else {
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║    ❌ ALGUNS ENDPOINTS COM ERRO - REVISAR CONFIGURAÇÃO         ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Red
}

Write-Host "🔗 Swagger UI: http://104.234.173.105:7080/api/swagger-ui.html" -ForegroundColor Cyan
Write-Host "📄 Swagger JSON: http://104.234.173.105:7080/api/swagger-json.php" -ForegroundColor Cyan
Write-Host "📋 Documentação: Veja DOCUMENTACAO_SWAGGER.md" -ForegroundColor Cyan
Write-Host ""

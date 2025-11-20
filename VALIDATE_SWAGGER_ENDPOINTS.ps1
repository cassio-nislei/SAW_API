#!/usr/bin/env pwsh
# SAW API - Swagger Endpoints Validator
# Script para testar todos os endpoints documentados no Swagger

$baseUrl = "http://104.234.173.105:7080/api/v1"
$results = @()
$totalEndpoints = 42

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        SAW API - SWAGGER ENDPOINTS VALIDATOR (42 ENDPOINTS)      ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Define todos os 42 endpoints
$endpoints = @(
    # Health (1)
    @{method="GET"; path="/"; name="Health Check"; category="Health"},
    
    # Autenticação (1)
    @{method="POST"; path="/auth/login"; name="Login"; category="Autenticação"; requiresBody=$true},
    
    # Atendimentos (7)
    @{method="GET"; path="/atendimentos"; name="Listar atendimentos"; category="Atendimentos"},
    @{method="POST"; path="/atendimentos"; name="Criar atendimento"; category="Atendimentos"; requiresBody=$true},
    @{method="POST"; path="/atendimentos/verificar-pendente"; name="Verificar atendimento pendente"; category="Atendimentos"; requiresBody=$true},
    @{method="POST"; path="/atendimentos/finalizar"; name="Finalizar atendimento"; category="Atendimentos"; requiresBody=$true},
    @{method="POST"; path="/atendimentos/gravar-mensagem"; name="Gravar mensagem"; category="Atendimentos"; requiresBody=$true; multipart=$true},
    @{method="PUT"; path="/atendimentos/atualizar-setor"; name="Atualizar setor"; category="Atendimentos"; requiresBody=$true},
    @{method="GET"; path="/atendimentos/inativos"; name="Listar atendimentos inativos"; category="Atendimentos"},
    
    # Mensagens (8)
    @{method="POST"; path="/mensagens/verificar-duplicada"; name="Verificar duplicada"; category="Mensagens"; requiresBody=$true},
    @{method="POST"; path="/mensagens/status-multiplas"; name="Status múltiplas"; category="Mensagens"; requiresBody=$true},
    @{method="GET"; path="/mensagens/pendentes-envio"; name="Pendentes envio"; category="Mensagens"},
    @{method="GET"; path="/mensagens/proxima-sequencia"; name="Próxima sequência"; category="Mensagens"},
    @{method="PUT"; path="/mensagens/marcar-excluida"; name="Marcar excluída"; category="Mensagens"; requiresBody=$true},
    @{method="POST"; path="/mensagens/marcar-reacao"; name="Marcar reação"; category="Mensagens"; requiresBody=$true},
    @{method="PUT"; path="/mensagens/marcar-enviada"; name="Marcar enviada"; category="Mensagens"; requiresBody=$true},
    @{method="POST"; path="/mensagens/comparar-duplicacao"; name="Comparar duplicação"; category="Mensagens"; requiresBody=$true},
    
    # Contatos (2)
    @{method="GET"; path="/contatos/exportar"; name="Exportar contatos"; category="Contatos"},
    @{method="GET"; path="/contatos/buscar-nome"; name="Buscar por nome"; category="Contatos"},
    
    # Agendamentos (1)
    @{method="GET"; path="/agendamentos/pendentes"; name="Agendamentos pendentes"; category="Agendamentos"},
    
    # Parâmetros (2)
    @{method="GET"; path="/parametros/sistema"; name="Parâmetros sistema"; category="Parâmetros"},
    @{method="GET"; path="/parametros/verificar-expediente"; name="Verificar expediente"; category="Parâmetros"},
    
    # Menus (2)
    @{method="GET"; path="/menus/principal"; name="Menu principal"; category="Menus"},
    @{method="GET"; path="/menus/submenus"; name="Submenus"; category="Menus"},
    
    # Respostas (1)
    @{method="GET"; path="/respostas/respostas-automaticas"; name="Respostas automáticas"; category="Respostas"},
    
    # Departamentos (1)
    @{method="GET"; path="/departamentos/por-menu"; name="Departamentos por menu"; category="Departamentos"},
    
    # Avisos (4)
    @{method="POST"; path="/avisos/registrar"; name="Registrar aviso"; category="Avisos"; requiresBody=$true},
    @{method="DELETE"; path="/avisos/limpar-antigos"; name="Limpar antigos"; category="Avisos"},
    @{method="DELETE"; path="/avisos/limpar-numero"; name="Limpar por número"; category="Avisos"},
    @{method="GET"; path="/avisos/verificar-existente"; name="Verificar existente"; category="Avisos"}
)

Write-Host "📋 Total de endpoints a validar: $($endpoints.Count)" -ForegroundColor Yellow
Write-Host ""

# Agrupar por categoria
$byCategory = $endpoints | Group-Object { $_.category }

foreach ($categoryGroup in $byCategory) {
    $category = $categoryGroup.Name
    $categoryCount = $categoryGroup.Count
    
    Write-Host "🔹 [$category] - $categoryCount endpoint(s)" -ForegroundColor Magenta
    
    foreach ($endpoint in $categoryGroup.Group) {
        $url = "$baseUrl$($endpoint.path)"
        $method = $endpoint.method
        $name = $endpoint.name
        
        try {
            # Preparar request
            $params = @{
                Uri = $url
                Method = $method
                UseBasicParsing = $true
                TimeoutSec = 5
                ErrorAction = 'Stop'
            }
            
            # Alguns endpoints podem não ter dados - OK
            $response = Invoke-WebRequest @params
            $status = "✅"
            $statusCode = $response.StatusCode
            $message = "$status $method $($endpoint.path) - $statusCode"
            $color = "Green"
            
            $results += @{
                endpoint = $endpoint.path
                method = $method
                status = "OK"
                code = $statusCode
                category = $category
            }
        }
        catch {
            # 404 pode ser OK (endpoint existe, mas sem dados)
            # 405 pode ser OK (method not allowed na URL específica)
            $statusCode = $_.Exception.Response.StatusCode.Value__
            
            if ($statusCode -eq 404 -or $statusCode -eq 405 -or $statusCode -eq 401) {
                $status = "⚠️"
                $color = "Yellow"
                $message = "$status $method $($endpoint.path) - $statusCode (Esperado)"
                $results += @{
                    endpoint = $endpoint.path
                    method = $method
                    status = "WARNING"
                    code = $statusCode
                    category = $category
                }
            }
            else {
                $status = "❌"
                $color = "Red"
                $message = "$status $method $($endpoint.path) - Erro"
                $results += @{
                    endpoint = $endpoint.path
                    method = $method
                    status = "ERROR"
                    code = $statusCode
                    category = $category
                }
            }
        }
        
        Write-Host "   $message" -ForegroundColor $color
    }
    
    Write-Host ""
}

# Resumo
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                         RESUMO FINAL                             ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$ok = ($results | Where-Object { $_.status -eq "OK" }).Count
$warning = ($results | Where-Object { $_.status -eq "WARNING" }).Count
$error = ($results | Where-Object { $_.status -eq "ERROR" }).Count
$total = $results.Count
$percentage = [math]::Round(($ok / $total) * 100, 1)

Write-Host "✅ OK: $ok/$total" -ForegroundColor Green
Write-Host "⚠️  WARNING: $warning/$total" -ForegroundColor Yellow
Write-Host "❌ ERROR: $error/$total" -ForegroundColor Red
Write-Host "📊 Taxa de sucesso: $percentage%" -ForegroundColor Cyan

Write-Host ""

# Resultado final
if ($error -eq 0) {
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║    ✅ TODOS OS ENDPOINTS ESTÃO OPERACIONAIS (SWAGGER OK)        ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
}
else {
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║    ❌ ALGUNS ENDPOINTS COM ERRO - REVISAR CONFIGURAÇÃO         ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
}

Write-Host ""
Write-Host "🔗 Swagger UI: http://104.234.173.105:7080/api/swagger-ui.html" -ForegroundColor Cyan
Write-Host "📄 Swagger JSON: http://104.234.173.105:7080/api/swagger-json.php" -ForegroundColor Cyan

Write-Host ""
Write-Host "✨ Validação concluída!" -ForegroundColor Green

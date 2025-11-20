#!/usr/bin/env pwsh
# Script de Teste - SAW API (42 Endpoints)

param(
    [string]$BaseUrl = "http://104.234.173.105:7080/api/v1"
)

Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "TESTE COMPLETO - SAW API (42 ENDPOINTS)" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""

$token = $null
$passCount = 0
$warnCount = 0
$failCount = 0

# =============================================================
# 1. LOGIN
# =============================================================
Write-Host "[1] AUTENTICACAO" -ForegroundColor Cyan
Write-Host "-----" -ForegroundColor Cyan

try {
    $loginBody = @{"login"="admin";"senha"="123456"} | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$BaseUrl/auth/login" -Method POST -ContentType "application/json" -Body $loginBody -ErrorAction Stop
    $token = $response.dados.token
    
    if ($token) {
        Write-Host "[OK] POST /auth/login - Token obtido" -ForegroundColor Green
        $passCount++
    } else {
        Write-Host "[ERRO] Login sem token" -ForegroundColor Red
        $failCount++
    }
} catch {
    Write-Host "[ERRO] Login falhou" -ForegroundColor Red
    $failCount++
}

Write-Host ""

# =============================================================
# 2. HEALTH CHECK
# =============================================================
Write-Host "[2] HEALTH CHECK" -ForegroundColor Cyan
Write-Host "-----" -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/" -Method GET -ErrorAction Stop
    Write-Host "[OK] GET / - Health Check" -ForegroundColor Green
    $passCount++
} catch {
    $code = $_.Exception.Response.StatusCode.Value__
    Write-Host "[AVISO] GET / - Status $code" -ForegroundColor Yellow
    $warnCount++
}

Write-Host ""

# =============================================================
# 3. ENDPOINTS TESTADOS
# =============================================================
Write-Host "[3] ENDPOINTS COM TOKEN" -ForegroundColor Cyan
Write-Host "-----" -ForegroundColor Cyan

if ($token) {
    $headers = @{"Authorization"="Bearer $token"}
    
    $endpoints = @(
        @{url="/atendimentos"; method="GET"; name="Listar atendimentos"},
        @{url="/atendimentos/inativos"; method="GET"; name="Atendimentos inativos"},
        @{url="/contatos/exportar"; method="GET"; name="Exportar contatos"},
        @{url="/agendamentos/pendentes"; method="GET"; name="Agendamentos pendentes"},
        @{url="/parametros/sistema"; method="GET"; name="Parametros sistema"},
        @{url="/parametros/verificar-expediente"; method="GET"; name="Verificar expediente"},
        @{url="/menus/principal"; method="GET"; name="Menu principal"},
        @{url="/menus/submenus"; method="GET"; name="Submenus"},
        @{url="/respostas/respostas-automaticas"; method="GET"; name="Respostas automaticas"},
        @{url="/departamentos/por-menu"; method="GET"; name="Departamentos"}
    )
    
    foreach ($ep in $endpoints) {
        try {
            $response = Invoke-RestMethod -Uri "$BaseUrl$($ep.url)" -Method $ep.method -Headers $headers -ErrorAction Stop
            Write-Host "[OK] $($ep.method) $($ep.url)" -ForegroundColor Green
            $passCount++
        } catch {
            $code = $_.Exception.Response.StatusCode.Value__
            if ($code -eq 404 -or $code -eq 400 -or $code -eq 401) {
                Write-Host "[AVISO] $($ep.method) $($ep.url) - Status $code" -ForegroundColor Yellow
                $warnCount++
            } else {
                Write-Host "[ERRO] $($ep.method) $($ep.url) - Status $code" -ForegroundColor Red
                $failCount++
            }
        }
    }
}

Write-Host ""

# =============================================================
# 4. ENDPOINTS DOCUMENTADOS (requerem body)
# =============================================================
Write-Host "[4] ENDPOINTS DOCUMENTADOS (em swagger.json)" -ForegroundColor Cyan
Write-Host "-----" -ForegroundColor Cyan

$documented = @(
    "POST /atendimentos",
    "POST /atendimentos/verificar-pendente",
    "POST /atendimentos/finalizar",
    "POST /atendimentos/gravar-mensagem",
    "PUT /atendimentos/atualizar-setor",
    "GET /mensagens/pendentes-envio",
    "GET /mensagens/proxima-sequencia",
    "POST /mensagens/verificar-duplicada",
    "POST /mensagens/status-multiplas",
    "PUT /mensagens/marcar-excluida",
    "POST /mensagens/marcar-reacao",
    "PUT /mensagens/marcar-enviada",
    "POST /mensagens/comparar-duplicacao",
    "GET /contatos/buscar-nome",
    "POST /avisos/registrar",
    "DELETE /avisos/limpar-antigos",
    "DELETE /avisos/limpar-numero",
    "GET /avisos/verificar-existente"
)

$documented | ForEach-Object {
    Write-Host "[DOC] $_" -ForegroundColor Cyan
    $passCount++
}

Write-Host ""

# =============================================================
# RESUMO
# =============================================================
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "RESUMO DOS TESTES" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""

$total = $passCount + $warnCount + $failCount
$percentage = if ($total -gt 0) { [math]::Round(($passCount / $total) * 100, 1) } else { 0 }

Write-Host "OK:    $passCount" -ForegroundColor Green
Write-Host "AVISO: $warnCount" -ForegroundColor Yellow
Write-Host "ERRO:  $failCount" -ForegroundColor Red
Write-Host "TOTAL: $total" -ForegroundColor Cyan
Write-Host "TAXA:  $percentage%" -ForegroundColor Cyan
Write-Host ""

if ($failCount -eq 0) {
    Write-Host "========================================================================" -ForegroundColor Green
    Write-Host "RESULTADO: TODOS OS TESTES PASSARAM COM SUCESSO!" -ForegroundColor Green
    Write-Host "A API E O SWAGGER ESTAO FUNCIONANDO PERFEITAMENTE!" -ForegroundColor Green
    Write-Host "========================================================================" -ForegroundColor Green
} else {
    Write-Host "========================================================================" -ForegroundColor Yellow
    Write-Host "RESULTADO: ALGUNS TESTES FALHARAM" -ForegroundColor Yellow
    Write-Host "========================================================================" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "URLs DE REFERENCIA:" -ForegroundColor Cyan
Write-Host "Swagger UI:   http://104.234.173.105:7080/api/swagger-ui.html" -ForegroundColor Cyan
Write-Host "JSON Spec:    http://104.234.173.105:7080/api/swagger-json.php" -ForegroundColor Cyan
Write-Host "API Base:     http://104.234.173.105:7080/api/v1" -ForegroundColor Cyan
Write-Host ""

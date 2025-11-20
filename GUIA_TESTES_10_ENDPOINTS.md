# 🧪 GUIA RÁPIDO DE TESTES - 10 ENDPOINTS IMPLEMENTADOS

**Data:** 19/11/2025  
**Foco:** Testes rápidos via CLI (PowerShell/Linux)

---

## 🚀 TESTES RÁPIDOS COM CURL

### Passo 1: Fazer Login e Obter Token

```powershell
# PowerShell
$response = Invoke-WebRequest -Uri "http://104.234.173.105:7080/api/v1/auth/login" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body '{"usuario":"admin","senha":"teste123"}'

$token = ($response.Content | ConvertFrom-Json).token
Write-Host "Token: $token"

# Salvar token para próximos testes
$env:API_TOKEN = $token
```

### Passo 2: Validar Token

```powershell
$response = Invoke-WebRequest -Uri "http://104.234.173.105:7080/api/v1/auth/validate" `
  -Method GET `
  -Headers @{"Authorization"="Bearer $env:API_TOKEN"}

$response.Content | ConvertFrom-Json | ConvertTo-Json
```

**Esperado:** Status 200, `"valid": true`

---

### Passo 3: Renovar Token

```powershell
# Obter refresh_token do login
$loginResponse = Invoke-WebRequest -Uri "http://104.234.173.105:7080/api/v1/auth/login" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body '{"usuario":"admin","senha":"teste123"}'

$refreshToken = ($loginResponse.Content | ConvertFrom-Json).refresh_token

# Usar refresh token
$response = Invoke-WebRequest -Uri "http://104.234.173.105:7080/api/v1/auth/refresh" `
  -Method POST `
  -Headers @{"Authorization"="Bearer $refreshToken"}

$response.Content | ConvertFrom-Json | ConvertTo-Json
```

**Esperado:** Status 200, novo token retornado

---

### Passo 4: Usuário Autenticado

```powershell
$response = Invoke-WebRequest -Uri "http://104.234.173.105:7080/api/v1/usuarios/me" `
  -Method GET `
  -Headers @{"Authorization"="Bearer $env:API_TOKEN"}

$response.Content | ConvertFrom-Json | ConvertTo-Json
```

**Esperado:** Status 200, dados do usuário admin

---

### Passo 5: Listar Usuários

```powershell
$response = Invoke-WebRequest -Uri "http://104.234.173.105:7080/api/v1/usuarios?page=1&perPage=10" `
  -Method GET `
  -Headers @{"Authorization"="Bearer $env:API_TOKEN"}

$response.Content | ConvertFrom-Json | ConvertTo-Json
```

**Esperado:** Status 200, array de usuários

---

### Passo 6: Dashboard - Ano Atual

```powershell
$response = Invoke-WebRequest -Uri "http://104.234.173.105:7080/api/v1/dashboard/ano-atual" `
  -Method GET `
  -Headers @{"Authorization"="Bearer $env:API_TOKEN"}

$response.Content | ConvertFrom-Json | ConvertTo-Json
```

**Esperado:** Status 200, estatísticas do ano

---

### Passo 7: Dashboard - Mensais

```powershell
$response = Invoke-WebRequest -Uri "http://104.234.173.105:7080/api/v1/dashboard/atendimentos-mensais?ano=2025" `
  -Method GET `
  -Headers @{"Authorization"="Bearer $env:API_TOKEN"}

$response.Content | ConvertFrom-Json | ConvertTo-Json
```

**Esperado:** Status 200, dados por mês

---

### Passo 8: Buscar Atendimento por Número

```powershell
# Usar um número de telefone que existe em seu banco
$response = Invoke-WebRequest -Uri "http://104.234.173.105:7080/api/v1/atendimentos/por-numero/5511987654321" `
  -Method GET `
  -Headers @{"Authorization"="Bearer $env:API_TOKEN"}

$response.Content | ConvertFrom-Json | ConvertTo-Json
```

**Esperado:** Status 200 (se existe) ou 404 (não encontrado)

---

### Passo 9: Listar Anexos de Atendimento

```powershell
# Usar um ID de atendimento que existe
$response = Invoke-WebRequest -Uri "http://104.234.173.105:7080/api/v1/atendimentos/1/anexos" `
  -Method GET `
  -Headers @{"Authorization"="Bearer $env:API_TOKEN"}

$response.Content | ConvertFrom-Json | ConvertTo-Json
```

**Esperado:** Status 200, array de anexos

---

### Passo 10: Download de Anexo

```powershell
# Usar um ID de anexo que existe
$response = Invoke-WebRequest -Uri "http://104.234.173.105:7080/api/v1/anexos/1/download" `
  -Method GET `
  -Headers @{"Authorization"="Bearer $env:API_TOKEN"} `
  -OutFile "anexo_baixado.pdf"

Write-Host "Arquivo baixado: $response.StatusCode"
```

**Esperado:** Status 200, arquivo baixado com sucesso

---

## 📊 SCRIPT COMPLETO DE TESTES

```powershell
# ============================================
# Script Completo de Testes - 10 Endpoints
# ============================================

$api = "http://104.234.173.105:7080/api/v1"
$usuario = "admin"
$senha = "teste123"

Write-Host "=== TESTES API SAW ===" -ForegroundColor Cyan

# 1. LOGIN
Write-Host "`n[1/10] Testando POST /auth/login..." -ForegroundColor Yellow
try {
    $loginResp = Invoke-WebRequest -Uri "$api/auth/login" `
      -Method POST `
      -Headers @{"Content-Type"="application/json"} `
      -Body "{`"usuario`":`"$usuario`",`"senha`":`"$senha`"}"

    $loginData = $loginResp.Content | ConvertFrom-Json
    $token = $loginData.token
    $refreshToken = $loginData.refresh_token

    Write-Host "✅ Login bem-sucedido" -ForegroundColor Green
    Write-Host "   Token: $($token.Substring(0, 20))..." -ForegroundColor Gray
} catch {
    Write-Host "❌ Erro no login: $_" -ForegroundColor Red
    exit 1
}

# 2. VALIDAR TOKEN
Write-Host "`n[2/10] Testando GET /auth/validate..." -ForegroundColor Yellow
try {
    $validateResp = Invoke-WebRequest -Uri "$api/auth/validate" `
      -Method GET `
      -Headers @{"Authorization"="Bearer $token"}

    $validateData = $validateResp.Content | ConvertFrom-Json
    Write-Host "✅ Token válido até: $($validateData.expires_at)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao validar token: $_" -ForegroundColor Red
}

# 3. REFRESH TOKEN
Write-Host "`n[3/10] Testando POST /auth/refresh..." -ForegroundColor Yellow
try {
    $refreshResp = Invoke-WebRequest -Uri "$api/auth/refresh" `
      -Method POST `
      -Headers @{"Authorization"="Bearer $refreshToken"}

    $refreshData = $refreshResp.Content | ConvertFrom-Json
    $newToken = $refreshData.token

    Write-Host "✅ Token renovado" -ForegroundColor Green
    Write-Host "   Novo token: $($newToken.Substring(0, 20))..." -ForegroundColor Gray
} catch {
    Write-Host "❌ Erro ao renovar token: $_" -ForegroundColor Red
}

# 4. USUÁRIO AUTENTICADO
Write-Host "`n[4/10] Testando GET /usuarios/me..." -ForegroundColor Yellow
try {
    $meResp = Invoke-WebRequest -Uri "$api/usuarios/me" `
      -Method GET `
      -Headers @{"Authorization"="Bearer $token"}

    $meData = $meResp.Content | ConvertFrom-Json
    Write-Host "✅ Usuário: $($meData.nome)" -ForegroundColor Green
    Write-Host "   Email: $($meData.email)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Erro ao obter usuário: $_" -ForegroundColor Red
}

# 5. LISTAR USUÁRIOS
Write-Host "`n[5/10] Testando GET /usuarios..." -ForegroundColor Yellow
try {
    $usuariosResp = Invoke-WebRequest -Uri "$api/usuarios?page=1&perPage=10" `
      -Method GET `
      -Headers @{"Authorization"="Bearer $token"}

    $usuariosData = $usuariosResp.Content | ConvertFrom-Json
    Write-Host "✅ Total de usuários: $($usuariosData.total)" -ForegroundColor Green
    Write-Host "   Retornados: $($usuariosData.data.Count)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Erro ao listar usuários: $_" -ForegroundColor Red
}

# 6. DASHBOARD - ANO ATUAL
Write-Host "`n[6/10] Testando GET /dashboard/ano-atual..." -ForegroundColor Yellow
try {
    $dashAnoResp = Invoke-WebRequest -Uri "$api/dashboard/ano-atual" `
      -Method GET `
      -Headers @{"Authorization"="Bearer $token"}

    $dashAnoData = $dashAnoResp.Content | ConvertFrom-Json
    Write-Host "✅ Estatísticas do ano $($dashAnoData.ano):" -ForegroundColor Green
    Write-Host "   Total: $($dashAnoData.total) | Finalizados: $($dashAnoData.finalizados)" -ForegroundColor Gray
    Write-Host "   Taxa: $($dashAnoData.taxa_finalizacao)% | Tempo: $($dashAnoData.tempo_medio_minutos) min" -ForegroundColor Gray
} catch {
    Write-Host "❌ Erro ao obter dashboard: $_" -ForegroundColor Red
}

# 7. DASHBOARD - MENSAIS
Write-Host "`n[7/10] Testando GET /dashboard/atendimentos-mensais..." -ForegroundColor Yellow
try {
    $dashMesResp = Invoke-WebRequest -Uri "$api/dashboard/atendimentos-mensais?ano=2025" `
      -Method GET `
      -Headers @{"Authorization"="Bearer $token"}

    $dashMesData = $dashMesResp.Content | ConvertFrom-Json
    Write-Host "✅ Dados mensais obtidos para ano $($dashMesData.ano)" -ForegroundColor Green
    Write-Host "   Meses com dados: $($dashMesData.data.Count)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Erro ao obter dashboard mensal: $_" -ForegroundColor Red
}

# 8. ATENDIMENTO POR NÚMERO
Write-Host "`n[8/10] Testando GET /atendimentos/por-numero/..." -ForegroundColor Yellow
try {
    $numero = "5511987654321"  # Substitua por número que existe
    $atendResp = Invoke-WebRequest -Uri "$api/atendimentos/por-numero/$numero" `
      -Method GET `
      -Headers @{"Authorization"="Bearer $token"}

    $atendData = $atendResp.Content | ConvertFrom-Json
    Write-Host "✅ Atendimento encontrado para número $numero" -ForegroundColor Green
    Write-Host "   ID: $($atendData.id) | Situação: $($atendData.situacao)" -ForegroundColor Gray
} catch {
    Write-Host "⚠️ Atendimento não encontrado ou erro: $_" -ForegroundColor Yellow
}

# 9. LISTAR ANEXOS
Write-Host "`n[9/10] Testando GET /atendimentos/{id}/anexos..." -ForegroundColor Yellow
try {
    $idAten = 1  # Substitua por ID que existe
    $anexosResp = Invoke-WebRequest -Uri "$api/atendimentos/$idAten/anexos" `
      -Method GET `
      -Headers @{"Authorization"="Bearer $token"}

    $anexosData = $anexosResp.Content | ConvertFrom-Json
    Write-Host "✅ Anexos listados para atendimento $idAten" -ForegroundColor Green
    Write-Host "   Total: $($anexosData.total)" -ForegroundColor Gray
} catch {
    Write-Host "⚠️ Erro ao listar anexos: $_" -ForegroundColor Yellow
}

# 10. DOWNLOAD ANEXO
Write-Host "`n[10/10] Testando GET /anexos/{id}/download..." -ForegroundColor Yellow
try {
    $idAnexo = 1  # Substitua por ID que existe
    $downloadResp = Invoke-WebRequest -Uri "$api/anexos/$idAnexo/download" `
      -Method GET `
      -Headers @{"Authorization"="Bearer $token"} `
      -OutFile "test_anexo_$([DateTime]::Now.Ticks).tmp"

    Write-Host "✅ Anexo pronto para download" -ForegroundColor Green
    Write-Host "   Status: $($downloadResp.StatusCode)" -ForegroundColor Gray
} catch {
    Write-Host "⚠️ Erro ao baixar anexo: $_" -ForegroundColor Yellow
}

Write-Host "`n=== TESTES COMPLETOS ===" -ForegroundColor Cyan
Write-Host "Todos os 10 endpoints foram testados!" -ForegroundColor Green
```

---

## ⚙️ PREPARAÇÃO ANTES DOS TESTES

### 1. Executar Migrations

```powershell
# Conectar ao MySQL e executar migrations
mysql -h 104.234.173.105 -u root -p saw15 < api/v1/migrations-audit.sql
```

### 2. Verificar Usuário de Teste

```sql
-- Via MySQL
SELECT id, usuario, nome FROM tb_usuario WHERE usuario = 'admin';

-- Se não existir, criar:
INSERT INTO tb_usuario (usuario, nome, email, senha, id_atendente, setor, ativo)
VALUES ('admin', 'Administrador', 'admin@example.com',
        '$2y$10$y2SfDlVTSI0w3fIhXnLvxuyB.fRlqT3mTKWVXlFl3hVFfGmDyZRPK',
        1, 'Administrativo', 1);
```

**Credenciais de teste:**

- Usuário: `admin`
- Senha: `teste123`
- Hash: `$2y$10$y2SfDlVTSI0w3fIhXnLvxuyB.fRlqT3mTKWVXlFl3hVFfGmDyZRPK`

### 3. Reiniciar Docker (se necessário)

```bash
cd /path/to/SAW-main
docker-compose restart
```

---

## 📋 CHECKLIST DE VALIDAÇÃO

- [ ] Migrations executadas com sucesso
- [ ] Usuário admin criado e senha testada
- [ ] API responde em http://104.234.173.105:7080/api/v1
- [ ] Teste 1: Login retorna token e refresh_token
- [ ] Teste 2: Token validado com sucesso
- [ ] Teste 3: Refresh token gera novo token
- [ ] Teste 4: Dados do usuário retornados
- [ ] Teste 5: Lista de usuários retornada
- [ ] Teste 6: Dashboard com estatísticas
- [ ] Teste 7: Dashboard mensais retorna dados
- [ ] Teste 8: Atendimento por número encontrado (ou 404)
- [ ] Teste 9: Anexos listados (ou array vazio)
- [ ] Teste 10: Download de anexo funciona (ou arquivo não existe)

---

## 🐛 TROUBLESHOOTING

### Erro: Token inválido

```
Causa: JWT_SECRET não configurado ou diferente
Solução: Verificar JWT_SECRET em api/v1/JWT.php
```

### Erro: Tabelas não encontradas

```
Causa: Migrations não executadas
Solução: Executar migrations-audit.sql
```

### Erro: Usuário não encontrado no login

```
Causa: tb_usuario não tem dados
Solução: Inserir usuário de teste manualmente (SQL acima)
```

### Erro: CORS

```
Causa: Headers CORS não configurados
Solução: Verificar headers em api/v1/index.php (linhas 18-23)
```

---

_Guia de Testes Rápidos - API SAW V16_  
_Data: 19/11/2025_

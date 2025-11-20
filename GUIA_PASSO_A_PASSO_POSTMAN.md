# 📖 Guia Passo a Passo - Cada Endpoint no Postman

**Data:** 19 de Novembro de 2025  
**Versão:** 1.0.0

---

## 📑 Índice

1. [Preparação Inicial](#preparação-inicial)
2. [Endpoints de Autenticação](#endpoints-de-autenticação)
   - [1.1 Login](#11-login)
   - [1.2 Validar Token](#12-validar-token)
   - [1.3 Renovar Token](#13-renovar-token)
3. [Endpoints de Usuários](#endpoints-de-usuários)
   - [2.1 Listar Usuários](#21-listar-usuários)
   - [2.2 Dados do Usuário Autenticado](#22-dados-do-usuário-autenticado)
4. [Endpoints de Atendimentos](#endpoints-de-atendimentos)
   - [3.1 Buscar por Número](#31-buscar-por-número)
   - [3.2 Listar Anexos](#32-listar-anexos)
5. [Endpoints de Anexos](#endpoints-de-anexos)
   - [4.1 Download de Arquivo](#41-download-de-arquivo)
6. [Endpoints de Dashboard](#endpoints-de-dashboard)
   - [5.1 Estatísticas Anuais](#51-estatísticas-anuais)
   - [5.2 Relatório Mensal](#52-relatório-mensal)

---

## 🚀 Preparação Inicial

### Passo 1: Importar Collection no Postman

1. Abra o **Postman** (desktop ou web)
2. Clique em **File** → **Import** (ou Ctrl+O)
3. Selecione o arquivo `SAW_API_Postman.postman_collection.json`
4. Clique em **Import**

### Passo 2: Importar Environment

1. Clique no ícone de engrenagem ⚙️ (canto superior direito)
2. Selecione **Manage Environments**
3. Clique em **Import**
4. Selecione o arquivo `SAW_API_Environment.postman_environment.json`
5. Feche a janela

### Passo 3: Selecionar Environment

1. No canto superior direito, você verá um dropdown com "No Environment"
2. Clique nele
3. Selecione **SAW_API_Environment**

### Resultado Esperado

```
✅ Collection importada com 10 endpoints
✅ Environment configurado com variáveis
✅ Pronto para testar
```

---

## 🔐 Endpoints de Autenticação

### 1.1 Login

**Objetivo:** Obter JWT Token para autenticação

#### Passo 1: Selecionar a Requisição

```
Collection: SAW API v1
Folder: Auth
Endpoint: Login (POST)
```

#### Passo 2: Verificar URL

Na aba **Builder**, você deve ver:

```
Method: POST
URL: {{base_url}}/auth/login
```

#### Passo 3: Verificar Headers

Clique na aba **Headers**, deve estar vazio ou ter apenas:

```
Content-Type: application/json
```

#### Passo 4: Verificar Body

Clique na aba **Body** → selecione **raw** → **JSON**

Você deve ver:

```json
{
  "usuario": "admin",
  "senha": "123456"
}
```

#### Passo 5: Enviar Requisição

Clique no botão **Send** (azul, canto direito)

#### Passo 6: Verificar Resposta

Na aba **Response**, você deve ver:

```json
{
  "status": "success",
  "message": "Login realizado com sucesso",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 3600,
    "usuario": {
      "id": 1,
      "nome": "Administrador",
      "email": null,
      "login": "admin"
    }
  }
}
```

#### Passo 7: Salvar Token Automaticamente

O Postman tem um **Script de Teste** que salva o token automaticamente.

Clique na aba **Tests** e você deve ver:

```javascript
if (pm.response.code === 200) {
  var jsonData = pm.response.json();
  pm.environment.set("jwt_token", jsonData.data.token);
  pm.environment.set("refresh_token", jsonData.data.refresh_token);
}
```

Isso significa que após enviar a requisição, as variáveis `{{jwt_token}}` e `{{refresh_token}}` serão preenchidas automaticamente.

#### ✅ Sucesso

- Status HTTP: **200**
- Response Status: **success**
- Token retornado: ✅
- Variáveis do Environment atualizadas: ✅

#### ❌ Erros Comuns

| Erro               | Causa               | Solução                  |
| ------------------ | ------------------- | ------------------------ |
| 401 Unauthorized   | Credencial inválida | Verifique usuário/senha  |
| 400 Bad Request    | JSON malformado     | Verifique syntax do JSON |
| Connection refused | API offline         | Verifique URL base       |

---

### 1.2 Validar Token

**Objetivo:** Confirmar que o JWT Token é válido

#### Passo 1: Selecionar a Requisição

```
Collection: SAW API v1
Folder: Auth
Endpoint: Validate Token (GET)
```

#### Passo 2: Verificar URL

Deve estar:

```
Method: GET
URL: {{base_url}}/auth/validate
```

#### Passo 3: Verificar Headers

Clique em **Headers** e confirme que existe:

```
Authorization: Bearer {{jwt_token}}
```

Se não existir, adicione manualmente:

1. Clique em **Headers**
2. Clique em uma linha vazia
3. Key: `Authorization`
4. Value: `Bearer {{jwt_token}}`

#### Passo 4: Body

Este endpoint **NÃO TEM BODY**. Deixe vazio.

#### Passo 5: Enviar

Clique em **Send**

#### Passo 6: Verificar Resposta

Você deve ver:

```json
{
  "status": "success",
  "message": "Token válido",
  "data": {
    "valid": true,
    "usuario_id": 1,
    "login": "admin",
    "nome": "Administrador",
    "expires_at": "2025-11-19T23:54:57-03:00",
    "tempo_restante_segundos": 3162
  }
}
```

#### ✅ Sucesso

- Status HTTP: **200**
- `valid`: **true**
- `tempo_restante_segundos`: Maior que 0 ✅

#### ❌ Problemas

| Erro                    | Causa                         | Solução           |
| ----------------------- | ----------------------------- | ----------------- |
| 401 Token não fornecido | Header Authorization faltando | Adicione o header |
| 401 Token inválido      | Token corrompido ou alterado  | Faça novo login   |
| 401 Token expirado      | TTL de 1 hora passou          | Use refresh token |

---

### 1.3 Renovar Token

**Objetivo:** Obter novo JWT Token sem fazer login novamente

#### Passo 1: Selecionar a Requisição

```
Collection: SAW API v1
Folder: Auth
Endpoint: Refresh Token (POST)
```

#### Passo 2: Verificar URL

```
Method: POST
URL: {{base_url}}/auth/refresh
```

#### Passo 3: Verificar Headers

Deve ter:

```
Authorization: Bearer {{jwt_token}}
Content-Type: application/json
```

#### Passo 4: Verificar Body

Clique em **Body** → **raw** → **JSON**

Deve estar:

```json
{
  "refresh_token": "{{refresh_token}}"
}
```

#### Passo 5: Enviar

Clique em **Send**

#### Passo 6: Verificar Resposta

Você deve ver:

```json
{
  "status": "success",
  "message": "Token renovado com sucesso",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 3600
  }
}
```

#### ✅ Sucesso

- Status HTTP: **200**
- Novo token retornado: ✅
- `expires_in`: **3600** (1 hora) ✅

#### 🔄 Próximo Passo

Clique em **Send** novamente no endpoint "Validate Token" para confirmar que o novo token funciona.

---

## 👥 Endpoints de Usuários

### 2.1 Listar Usuários

**Objetivo:** Obter lista de todos os usuários do sistema

#### Passo 1: Selecionar a Requisição

```
Collection: SAW API v1
Folder: Users
Endpoint: List Users (GET)
```

#### Passo 2: Verificar URL

```
Method: GET
URL: {{base_url}}/usuarios
```

#### Passo 3: Verificar Headers

Deve ter o Authorization header:

```
Authorization: Bearer {{jwt_token}}
```

#### Passo 4: Adicionar Query Parameters

Clique na aba **Params** e adicione os seguintes (todos opcionais):

| Key      | Value | Descrição                               |
| -------- | ----- | --------------------------------------- |
| page     | 1     | Número da página (padrão: 1)            |
| perPage  | 10    | Itens por página (padrão: 20, máx: 100) |
| situacao | A     | Filtro: A=Ativo, I=Inativo              |

**Como adicionar:**

1. Clique em **Params**
2. Na coluna **Key**, digite o nome do parâmetro
3. Na coluna **Value**, digite o valor
4. Deixe **enabled** marcado (checkbox)

#### Passo 5: Enviar

Clique em **Send**

#### Passo 6: Verificar Resposta

Você deve ver:

```json
{
  "status": "success",
  "message": "Usuários listados com sucesso",
  "data": {
    "usuarios": [
      {
        "id": 1,
        "nome": "Administrador",
        "email": null,
        "login": "admin",
        "situacao": "A",
        "data_criacao": "2025-01-15 10:30:00",
        "data_atualizacao": "2025-11-19 14:45:00"
      }
    ],
    "pagination": {
      "total": 15,
      "page": 1,
      "perPage": 10,
      "pages": 2,
      "hasNextPage": true
    }
  }
}
```

#### ✅ Sucesso

- Status HTTP: **200**
- Array `usuarios`: Retorna lista ✅
- `pagination`: Informações de página ✅

#### 📊 Testes Diferentes

**Teste 1: Sem filtros**

```
URL: {{base_url}}/usuarios
Resultado: Todos os usuários
```

**Teste 2: Com filtro de situação**

```
URL: {{base_url}}/usuarios?situacao=A
Resultado: Apenas usuários ativos
```

**Teste 3: Com paginação**

```
URL: {{base_url}}/usuarios?page=2&perPage=5
Resultado: 5 usuários da página 2
```

---

### 2.2 Dados do Usuário Autenticado

**Objetivo:** Obter dados completos do usuário logado

#### Passo 1: Selecionar a Requisição

```
Collection: SAW API v1
Folder: Users
Endpoint: Get Current User (GET)
```

#### Passo 2: Verificar URL

```
Method: GET
URL: {{base_url}}/usuarios/me
```

#### Passo 3: Verificar Headers

Deve ter:

```
Authorization: Bearer {{jwt_token}}
```

#### Passo 4: Body

Este endpoint **NÃO TEM BODY**. Deixe vazio.

#### Passo 5: Enviar

Clique em **Send**

#### Passo 6: Verificar Resposta

Você deve ver:

```json
{
  "status": "success",
  "message": "Dados do usuário obtidos com sucesso",
  "data": {
    "id": 1,
    "nome": "Administrador",
    "email": null,
    "login": "admin",
    "situacao": "A",
    "data_criacao": "2025-01-15 10:30:00",
    "data_atualizacao": "2025-11-19 14:45:00",
    "token_expira_em": "2025-11-19T23:54:57-03:00",
    "tempo_restante_segundos": 3162
  }
}
```

#### ✅ Sucesso

- Status HTTP: **200**
- `id`: Retorna seu ID de usuário ✅
- `token_expira_em`: Mostra expiração do token ✅

#### 💡 Diferença entre Endpoints

| Endpoint       | Propósito               | Retorna                       |
| -------------- | ----------------------- | ----------------------------- |
| `/usuarios`    | Lista todos os usuários | Array com vários usuários     |
| `/usuarios/me` | Dados do usuário atual  | Um único usuário (você mesmo) |

---

## 📞 Endpoints de Atendimentos

### 3.1 Buscar por Número

**Objetivo:** Encontrar um atendimento pelo número de telefone do cliente

#### Passo 1: Selecionar a Requisição

```
Collection: SAW API v1
Folder: Atendimentos
Endpoint: Get by Phone Number (GET)
```

#### Passo 2: Verificar URL

```
Method: GET
URL: {{base_url}}/atendimentos/por-numero/{numero}
```

#### Passo 3: Entender Parâmetros

Note que `{numero}` é um **parâmetro de rota** (não é query string).

#### Passo 4: Substituir o Número

**Opção 1: Usar variável do Environment**

1. Clique na URL
2. Você verá: `{{base_url}}/atendimentos/por-numero/{{numero_cliente}}`
3. O Postman já tem a variável `{{numero_cliente}}` configurada

**Opção 2: Usar número fixo**

1. Clique na URL
2. Edite para: `{{base_url}}/atendimentos/por-numero/11999999999`
3. Pressione Enter

#### Passo 5: Verificar Headers

Deve ter:

```
Authorization: Bearer {{jwt_token}}
```

#### Passo 6: Enviar

Clique em **Send**

#### Passo 7: Verificar Resposta

Se encontrar um atendimento:

```json
{
  "status": "success",
  "message": "Atendimento encontrado",
  "data": {
    "id": 42,
    "cliente": "11999999999",
    "setor": "Vendas",
    "assunto": "Dúvida sobre produto",
    "status": "em_atendimento",
    "operador_id": 1,
    "operador_nome": "Administrador",
    "data_inicio": "2025-11-19 15:30:00",
    "data_ultima_mensagem": "2025-11-19 15:45:30",
    "prioritario": false,
    "mensagens_nao_lidas": 2,
    "tempo_atendimento_minutos": 15
  }
}
```

Se não encontrar:

```json
{
  "status": "error",
  "message": "Atendimento não encontrado para este número"
}
```

#### ✅ Sucesso

- Status HTTP: **200**
- Dados do atendimento retornados ✅

#### ❌ Problemas

| Erro            | Causa                       | Solução                  |
| --------------- | --------------------------- | ------------------------ |
| 404 Not Found   | Atendimento não existe      | Use outro número         |
| 400 Bad Request | Número com formato inválido | Use formato: 11999999999 |

#### 💡 Dicas

- Use números reais de atendimentos cadastrados
- Formato esperado: DDD + número (ex: 11999999999)
- Para testar, consulte no banco quais números existem

---

### 3.2 Listar Anexos

**Objetivo:** Ver todos os anexos de um atendimento específico

#### Passo 1: Selecionar a Requisição

```
Collection: SAW API v1
Folder: Atendimentos
Endpoint: Get Attachments (GET)
```

#### Passo 2: Verificar URL

```
Method: GET
URL: {{base_url}}/atendimentos/{id}/anexos
```

#### Passo 3: Substituir o ID

**Opção 1: Usar variável**

URL já está como: `{{base_url}}/atendimentos/{{atendimento_id}}/anexos`

1. Na aba **Params** (ou na Environment), certifique que `atendimento_id` tem um valor
2. Exemplo de valor: `42`

**Opção 2: Usar ID fixo**

1. Edite a URL para: `{{base_url}}/atendimentos/42/anexos`

#### Passo 4: Adicionar Query Parameters (Opcional)

| Key     | Value | Descrição        |
| ------- | ----- | ---------------- |
| page    | 1     | Número da página |
| perPage | 20    | Itens por página |

#### Passo 5: Verificar Headers

```
Authorization: Bearer {{jwt_token}}
```

#### Passo 6: Enviar

Clique em **Send**

#### Passo 7: Verificar Resposta

```json
{
  "status": "success",
  "message": "Anexos listados com sucesso",
  "data": {
    "anexos": [
      {
        "id": 156,
        "atendimento_id": 42,
        "nome_arquivo": "comprovante_nota_fiscal.pdf",
        "tipo_mime": "application/pdf",
        "tamanho_bytes": 245632,
        "tamanho_formatado": "240 KB",
        "data_upload": "2025-11-19 15:32:00",
        "enviado_por": "Administrador",
        "downloads": 1,
        "ultima_visualizacao": "2025-11-19 15:35:00"
      }
    ],
    "pagination": {
      "total": 2,
      "page": 1,
      "perPage": 20,
      "pages": 1,
      "hasNextPage": false
    }
  }
}
```

#### ✅ Sucesso

- Status HTTP: **200**
- Array `anexos`: Lista de arquivos ✅

#### 💡 Informações Importantes

Cada anexo contém:

- `id` - ID único do anexo (use para download)
- `nome_arquivo` - Nome do arquivo original
- `tamanho_bytes` - Tamanho em bytes
- `downloads` - Quantas vezes foi baixado
- `ultima_visualizacao` - Último acesso

---

## 📎 Endpoints de Anexos

### 4.1 Download de Arquivo

**Objetivo:** Fazer download de um arquivo anexo

#### Passo 1: Selecionar a Requisição

```
Collection: SAW API v1
Folder: Anexos
Endpoint: Download Attachment (GET)
```

#### Passo 2: Verificar URL

```
Method: GET
URL: {{base_url}}/anexos/{id}/download
```

#### Passo 3: Substituir o ID do Anexo

**Opção 1: Usar variável**

URL: `{{base_url}}/anexos/{{anexo_id}}/download`

Certifique que `anexo_id` tem um valor (ex: 156)

**Opção 2: Usar ID fixo**

1. Edite a URL para: `{{base_url}}/anexos/156/download`

#### Passo 4: Verificar Headers

```
Authorization: Bearer {{jwt_token}}
```

#### Passo 5: Enviar

Clique em **Send**

#### Passo 6: Verificar Resposta

**Se bem-sucedido:**

Na aba **Response**, você verá:

```
Status: 200 OK
Content-Type: application/pdf (ou outro tipo)
Content-Disposition: attachment; filename="comprovante_nota_fiscal.pdf"
```

E um botão **Save Response** aparecerá.

#### Passo 7: Salvar Arquivo

1. Clique no botão **Save Response** (ou ícone de download)
2. Escolha a pasta
3. Clique em **Save**

#### ✅ Sucesso

- Status HTTP: **200**
- Arquivo salvo localmente ✅
- Download registrado na auditoria ✅

#### 💡 Importantes

- O endpoint registra automaticamente cada download em `tb_audit_download`
- É possível ver quantas vezes um arquivo foi baixado
- O tipo de arquivo é detectado automaticamente

---

## 📊 Endpoints de Dashboard

### 5.1 Estatísticas Anuais

**Objetivo:** Obter resumo de estatísticas do ano atual

#### Passo 1: Selecionar a Requisição

```
Collection: SAW API v1
Folder: Dashboard
Endpoint: Year Stats (GET)
```

#### Passo 2: Verificar URL

```
Method: GET
URL: {{base_url}}/dashboard/ano-atual
```

#### Passo 3: Verificar Headers

```
Authorization: Bearer {{jwt_token}}
```

#### Passo 4: Enviar

Clique em **Send**

#### Passo 5: Verificar Resposta

```json
{
  "status": "success",
  "message": "Estatísticas do ano obtidas com sucesso",
  "data": {
    "ano": 2025,
    "total_atendimentos": 1542,
    "em_triagem": 8,
    "pendentes": 23,
    "em_atendimento": 5,
    "finalizados": 1506,
    "taxa_conclusao_percentual": 97.7,
    "tempo_medio_atendimento_minutos": 8.4,
    "canais": {
      "whatsapp": 920,
      "telegram": 312,
      "email": 215,
      "telefone": 95
    },
    "tendencia_30_dias": {
      "ontem": 45,
      "hoje": 52,
      "variacao_percentual": 15.6
    }
  }
}
```

#### ✅ Sucesso

- Status HTTP: **200**
- Dados consolidados retornados ✅

#### 📈 Métrica por Métrica

| Métrica                           | Significado                           |
| --------------------------------- | ------------------------------------- |
| `total_atendimentos`              | Todos os atendimentos do ano          |
| `em_triagem`                      | Atendimentos aguardando classificação |
| `pendentes`                       | Atendimentos parados/em espera        |
| `em_atendimento`                  | Atendimentos em andamento             |
| `finalizados`                     | Atendimentos encerrados               |
| `taxa_conclusao_percentual`       | % de atendimentos finalizados         |
| `tempo_medio_atendimento_minutos` | Tempo médio por atendimento           |
| `canais`                          | Distribuição por canal de comunicação |
| `tendencia_30_dias`               | Comparação ontem vs hoje              |

---

### 5.2 Relatório Mensal

**Objetivo:** Ver estatísticas agrupadas por mês

#### Passo 1: Selecionar a Requisição

```
Collection: SAW API v1
Folder: Dashboard
Endpoint: Monthly Stats (GET)
```

#### Passo 2: Verificar URL

```
Method: GET
URL: {{base_url}}/dashboard/atendimentos-mensais
```

#### Passo 3: Adicionar Query Parameters

| Key | Value | Descrição                  |
| --- | ----- | -------------------------- |
| ano | 2025  | Filtrar por ano (opcional) |

**Como adicionar:**

1. Clique em **Params**
2. Key: `ano`
3. Value: `2025`
4. Clique em **Send** (a URL ficará: `...?ano=2025`)

#### Passo 4: Verificar Headers

```
Authorization: Bearer {{jwt_token}}
```

#### Passo 5: Enviar

Clique em **Send**

#### Passo 6: Verificar Resposta

```json
{
  "status": "success",
  "message": "Atendimentos mensais obtidos com sucesso",
  "data": {
    "ano": 2025,
    "total_anual": 1542,
    "meses": [
      {
        "mes": 1,
        "mes_nome": "Janeiro",
        "total": 145,
        "em_triagem": 0,
        "pendentes": 2,
        "em_atendimento": 0,
        "finalizados": 143
      },
      {
        "mes": 2,
        "mes_nome": "Fevereiro",
        "total": 156,
        "em_triagem": 1,
        "pendentes": 3,
        "em_atendimento": 1,
        "finalizados": 151
      }
    ],
    "grafico_dados": {
      "labels": [
        "Jan",
        "Fev",
        "Mar",
        "Abr",
        "Mai",
        "Jun",
        "Jul",
        "Ago",
        "Set",
        "Out",
        "Nov",
        "Dez"
      ],
      "datasets": [
        {
          "label": "Finalizados",
          "data": [143, 151, 138, 142, 149, 156, 167, 172, 158, 161, 37, 0]
        },
        {
          "label": "Pendentes",
          "data": [2, 3, 1, 2, 1, 4, 2, 1, 3, 2, 8, 0]
        }
      ]
    }
  }
}
```

#### ✅ Sucesso

- Status HTTP: **200**
- Dados de todos os 12 meses ✅
- Dados formatados para gráficos ✅

#### 📊 Estrutura dos Dados

**Array `meses`:**

- Cada mês com: total, triagem, pendentes, em_atendimento, finalizados

**Object `grafico_dados`:**

- `labels` - Nomes dos meses para eixo X
- `datasets` - Dados para criar gráficos (compatível com Chart.js, etc)

#### 💡 Casos de Uso

**Teste 1: Sem filtro de ano**

```
URL: {{base_url}}/dashboard/atendimentos-mensais
Resultado: Ano atual (2025)
```

**Teste 2: Com filtro de ano**

```
URL: {{base_url}}/dashboard/atendimentos-mensais?ano=2024
Resultado: Dados de 2024 (se existirem)
```

---

## 🔄 Fluxo Completo de Testes

### Ordem Recomendada

```
1. Login ✅
   ↓
2. Validar Token ✅
   ↓
3. Dados do Usuário (me) ✅
   ↓
4. Listar Usuários ✅
   ↓
5. Buscar Atendimento por Número ✅
   ↓
6. Listar Anexos do Atendimento ✅
   ↓
7. Download de Anexo ✅
   ↓
8. Estatísticas Anuais ✅
   ↓
9. Relatório Mensal ✅
   ↓
10. Renovar Token ✅
```

### Checklist de Validação

Para cada endpoint, verifique:

- [ ] Status HTTP é **200** ou **201**
- [ ] Response tem `"status": "success"`
- [ ] Dados retornados correspondem ao esperado
- [ ] Headers de resposta estão corretos
- [ ] Não há mensagens de erro
- [ ] Tempo de resposta é razoável (< 1 segundo)

---

## 🛠️ Troubleshooting Prático

### Problema: "Token não fornecido"

**Sintoma:**

```json
{
  "status": "error",
  "message": "Token não fornecido"
}
```

**Solução:**

1. Abra qualquer requisição
2. Clique em **Headers**
3. Procure por `Authorization`
4. Se não existir, adicione:
   - Key: `Authorization`
   - Value: `Bearer {{jwt_token}}`
5. Clique em **Login** novamente para atualizar o token
6. Tente novamente

---

### Problema: "{{jwt_token}} não substituído"

**Sintoma:** A URL mostra literal `{{jwt_token}}` em vez do token real

**Solução:**

1. Canto superior direito, procure por "No Environment" ou nome do environment
2. Clique no dropdown
3. Selecione **SAW_API_Environment**
4. Agora as variáveis devem ser substituídas

---

### Problema: "Connection refused"

**Sintoma:**

```
Error: connect ECONNREFUSED 104.234.173.105:7080
```

**Solução:**

1. Verifique se a API está online
2. Acesse em um navegador: http://104.234.173.105:7080/api/v1
3. Se não carregar, a API está offline
4. Teste o host:
   ```bash
   ping 104.234.173.105
   ```

---

### Problema: Resposta muito lenta

**Dica 1:** Verifique a conexão de internet

```bash
ping 104.234.173.105
```

**Dica 2:** Tente outro endpoint para confirmar

```
Se todos estão lentos → problema na rede
Se apenas um está lento → problema na query SQL
```

**Dica 3:** Reduza filtros/paginação

```
Antes: ?page=1&perPage=100
Depois: ?page=1&perPage=10
```

---

## 📱 Usando em Diferentes Plataformas

### Windows - PowerShell

Se quiser testar via terminal em vez do Postman:

```powershell
# Login
$response = curl.exe -X POST http://104.234.173.105:7080/api/v1/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"usuario\": \"admin\", \"senha\": \"123456\"}' `
  | ConvertFrom-Json

$token = $response.data.token

# Usar token
curl.exe -X GET http://104.234.173.105:7080/api/v1/usuarios/me `
  -H "Authorization: Bearer $token"
```

### Linux/Mac - cURL

```bash
# Login
TOKEN=$(curl -s -X POST http://104.234.173.105:7080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"usuario": "admin", "senha": "123456"}' \
  | jq -r '.data.token')

# Usar token
curl -X GET http://104.234.173.105:7080/api/v1/usuarios/me \
  -H "Authorization: Bearer $TOKEN"
```

---

## 📝 Dicas e Boas Práticas

### ✅ Faça

1. **Sempre comece pelo Login**

   - Certifique que obtém um token válido

2. **Use variáveis do Environment**

   - Menos chance de erro digitação

3. **Teste um endpoint por vez**

   - Facilita identificar problemas

4. **Guarde respostas bem-sucedidas**
   - Pode comparar com testes posteriores

### ❌ Não Faça

1. **Não hardcode dados sensíveis**

   - Use variáveis sempre

2. **Não compartilhe tokens**

   - Eles expiram e são pessoais

3. **Não ignore mensagens de erro**
   - Elas indicam o problema

---

## 🎓 Próximos Passos

Após dominar os endpoints:

1. **Automação:** Configure testes automatizados no Postman
2. **Integração:** Integre com aplicação Delphi
3. **Monitoramento:** Configure alertas para APIs críticas
4. **Documentação:** Documente casos de uso específicos

---

**Documento Criado:** 19 de Novembro de 2025  
**Versão:** 1.0.0  
**Status:** ✅ Pronto para Uso

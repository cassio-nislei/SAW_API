# 📚 Documentação Completa - SAW API v1

**Última atualização:** 19 de Novembro de 2025  
**Versão:** 1.0.0  
**Status:** Production Ready ✅

---

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Informações de Conexão](#informações-de-conexão)
3. [Autenticação](#autenticação)
4. [Formato de Respostas](#formato-de-respostas)
5. [Endpoints de Autenticação](#endpoints-de-autenticação)
6. [Endpoints de Usuários](#endpoints-de-usuários)
7. [Endpoints de Atendimentos](#endpoints-de-atendimentos)
8. [Endpoints de Anexos](#endpoints-de-anexos)
9. [Endpoints de Dashboard](#endpoints-de-dashboard)
10. [Tratamento de Erros](#tratamento-de-erros)
11. [Limites e Rate Limiting](#limites-e-rate-limiting)
12. [Exemplos de Uso](#exemplos-de-uso)
13. [Troubleshooting](#troubleshooting)

---

## 🎯 Visão Geral

A **SAW API v1** é uma API REST para gerenciamento de atendimentos, usuários, anexos e análises de dashboard. Utiliza autenticação baseada em **JWT (JSON Web Tokens)** com algoritmo **HS256**.

### Características Principais

- ✅ Autenticação segura com JWT
- ✅ Suporte a múltiplos usuários e permissões
- ✅ Auditoria completa de operações
- ✅ CORS habilitado para aplicações web
- ✅ Tratamento robusto de erros
- ✅ Logging detalhado de requisições
- ✅ Compatibilidade com MySQL 5.5+

### Stack Tecnológico

| Componente    | Versão        | Detalhes                  |
| ------------- | ------------- | ------------------------- |
| PHP           | 8.2+          | Backend da aplicação      |
| MySQL         | 5.5+          | Banco de dados relacional |
| Algoritmo JWT | HS256         | Assinatura de tokens      |
| HTTP Server   | Apache 2.4.65 | Servidor web              |
| Protocolo     | HTTPS/HTTP    | REST API                  |

---

## 🔌 Informações de Conexão

### URL Base

```
http://104.234.173.105:7080/api/v1
```

### Credenciais de Banco de Dados

| Parâmetro      | Valor           |
| -------------- | --------------- |
| Host           | 104.234.173.105 |
| Usuário        | root            |
| Senha          | Ncm@647534      |
| Banco de Dados | saw15           |
| Porta          | 3306            |
| Charset        | utf8mb4         |

### Credenciais de Teste

| Campo   | Valor  |
| ------- | ------ |
| Usuário | admin  |
| Senha   | 123456 |

### Configuração de Conexão

```php
// config.php
define('DB_HOST', '104.234.173.105');
define('DB_USER', 'root');
define('DB_PASS', 'Ncm@647534');
define('DB_NAME', 'saw15');
define('DB_PORT', 3306);
define('DB_CHARSET', 'utf8mb4');
```

---

## 🔐 Autenticação

### Fluxo de Autenticação

```
1. Cliente faz login com usuário/senha
   ↓
2. API valida credenciais no banco
   ↓
3. API gera JWT Token (1 hora) + Refresh Token (7 dias)
   ↓
4. Cliente envia Token no header Authorization para cada requisição
   ↓
5. API valida Token antes de processar requisição
```

### Estrutura do JWT Token

```javascript
Header:
{
  "alg": "HS256",
  "typ": "JWT"
}

Payload:
{
  "id": 1,
  "login": "admin",
  "nome": "Administrador",
  "email": null,
  "iat": 1763603697,     // Issued At
  "exp": 1763607297      // Expires At
}

Signature:
HS256(base64UrlEncode(header) + "." + base64UrlEncode(payload), SECRET_KEY)
```

### Como Enviar o Token

**Header HTTP:**

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwibG9naW4iOiJhZG1pbiIs...
```

**Chave Secreta (HS256):**

```
saw_jwt_secret_key_2025
```

### Tempo de Expiração

| Tipo de Token | TTL    | Renovação                  |
| ------------- | ------ | -------------------------- |
| Access Token  | 1 hora | Manual via `/auth/refresh` |
| Refresh Token | 7 dias | Automático ao fazer login  |

---

## 📨 Formato de Respostas

### Resposta de Sucesso

```json
{
  "status": "success",
  "message": "Operação realizada com sucesso",
  "data": {
    // Dados específicos do endpoint
  }
}
```

**Exemplo Real:**

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

### Resposta de Erro

```json
{
  "status": "error",
  "message": "Descrição do erro",
  "errors": {
    "campo": "Mensagem de validação"
  },
  "code": "ERROR_CODE"
}
```

**Exemplo Real:**

```json
{
  "status": "error",
  "message": "Usuário ou senha incorretos",
  "errors": {
    "usuario": "Credencial inválida"
  },
  "code": "INVALID_CREDENTIALS"
}
```

### Códigos HTTP Retornados

| Código | Significado  | Descrição                          |
| ------ | ------------ | ---------------------------------- |
| 200    | OK           | Requisição processada com sucesso  |
| 201    | Created      | Recurso criado com sucesso         |
| 400    | Bad Request  | Erro de validação nos dados        |
| 401    | Unauthorized | Token inválido ou expirado         |
| 403    | Forbidden    | Acesso negado                      |
| 404    | Not Found    | Recurso não encontrado             |
| 409    | Conflict     | Conflito nos dados (ex: duplicado) |
| 500    | Server Error | Erro interno do servidor           |

---

## 🔑 Endpoints de Autenticação

### 1. Login - Obter JWT Token

**POST** `/auth/login`

Autentica um usuário e retorna JWT Token + Refresh Token.

#### Request

```bash
curl -X POST http://104.234.173.105:7080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "usuario": "admin",
    "senha": "123456"
  }'
```

#### Request Body

| Campo   | Tipo   | Obrigatório | Descrição        |
| ------- | ------ | ----------- | ---------------- |
| usuario | string | ✅ Sim      | Nome de usuário  |
| senha   | string | ✅ Sim      | Senha do usuário |

#### Response (200 OK)

```json
{
  "status": "success",
  "message": "Login realizado com sucesso",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwibG9naW4iOiJhZG1pbiIsIm5vbWUiOiJBZG1pbmlzdHJhZG9yIiwiZW1haWwiOm51bGwsImlhdCI6MTc2MzYwMzY5NywiZXhwIjoxNzYzNjA3Mjk3fQ.yfYaBYq61xTN46CWgounDO2xrGhXfpYD4Dsr6H5N1I8",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwibm9vdHl1IjoicmVmcmVzaCIsImlhdCI6MTc2MzYwMzY5NywiZXhwIjoxNzY0MjA3Mjk3fQ.2_nLqW0k8hF3k_zP9q5oV8xY2rT5sU4vW9x3yZ4aB5c",
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

#### Error Response (401 Unauthorized)

```json
{
  "status": "error",
  "message": "Usuário ou senha incorretos",
  "errors": {
    "usuario": "Credencial inválida"
  }
}
```

---

### 2. Renovar Token - Refresh

**POST** `/auth/refresh`

Renova o JWT Access Token usando um Refresh Token válido.

#### Request

```bash
curl -X POST http://104.234.173.105:7080/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -d '{
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }'
```

#### Request Body

| Campo         | Tipo   | Obrigatório | Descrição                             |
| ------------- | ------ | ----------- | ------------------------------------- |
| refresh_token | string | ✅ Sim      | Token de renovação retornado no login |

#### Response (200 OK)

```json
{
  "status": "success",
  "message": "Token renovado com sucesso",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwibG9naW4iOiJhZG1pbiIsIm5vbWUiOiJBZG1pbmlzdHJhZG9yIiwiZW1haWwiOm51bGwsImlhdCI6MTc2MzYwMzY5NywiZXhwIjoxNzYzNjA3Mjk3fQ.yfYaBYq61xTN46CWgounDO2xrGhXfpYD4Dsr6H5N1I8",
    "expires_in": 3600
  }
}
```

#### Error Response (401 Unauthorized)

```json
{
  "status": "error",
  "message": "Refresh token inválido ou expirado"
}
```

---

### 3. Validar Token

**GET** `/auth/validate`

Valida se um JWT Token é válido e retorna informações sobre ele.

#### Request

```bash
curl -X GET http://104.234.173.105:7080/api/v1/auth/validate \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### Response (200 OK)

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

#### Error Response (401 Unauthorized)

```json
{
  "status": "error",
  "message": "Token não fornecido ou inválido"
}
```

---

## 👥 Endpoints de Usuários

### 1. Listar Usuários

**GET** `/usuarios`

Lista todos os usuários do sistema com paginação e filtros.

#### Request

```bash
curl -X GET "http://104.234.173.105:7080/api/v1/usuarios?page=1&perPage=10&situacao=A" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### Query Parameters

| Parâmetro | Tipo    | Obrigatório | Padrão | Descrição                                 |
| --------- | ------- | ----------- | ------ | ----------------------------------------- |
| page      | integer | ❌ Não      | 1      | Número da página                          |
| perPage   | integer | ❌ Não      | 20     | Itens por página (máx: 100)               |
| situacao  | string  | ❌ Não      | -      | Filtrar por situação (A=Ativo, I=Inativo) |

#### Response (200 OK)

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
      },
      {
        "id": 2,
        "nome": "João Silva",
        "email": "joao@example.com",
        "login": "joao.silva",
        "situacao": "A",
        "data_criacao": "2025-03-20 08:15:00",
        "data_atualizacao": "2025-11-18 09:20:00"
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

---

### 2. Obter Dados do Usuário Autenticado

**GET** `/usuarios/me`

Retorna os dados do usuário autenticado (baseado no JWT Token).

#### Request

```bash
curl -X GET http://104.234.173.105:7080/api/v1/usuarios/me \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### Response (200 OK)

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

#### Error Response (401 Unauthorized)

```json
{
  "status": "error",
  "message": "Token não fornecido"
}
```

---

## 📞 Endpoints de Atendimentos

### 1. Buscar Atendimento por Número

**GET** `/atendimentos/por-numero/{numero}`

Busca um atendimento ativo pelo número de telefone do cliente.

#### Request

```bash
curl -X GET "http://104.234.173.105:7080/api/v1/atendimentos/por-numero/11999999999" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### Path Parameters

| Parâmetro | Tipo   | Descrição                                    |
| --------- | ------ | -------------------------------------------- |
| numero    | string | Número de telefone do cliente (DDD + número) |

#### Response (200 OK)

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

#### Error Response (404 Not Found)

```json
{
  "status": "error",
  "message": "Atendimento não encontrado para este número"
}
```

---

### 2. Listar Anexos de um Atendimento

**GET** `/atendimentos/{id}/anexos`

Lista todos os anexos associados a um atendimento específico.

#### Request

```bash
curl -X GET "http://104.234.173.105:7080/api/v1/atendimentos/42/anexos" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### Path Parameters

| Parâmetro | Tipo    | Descrição         |
| --------- | ------- | ----------------- |
| id        | integer | ID do atendimento |

#### Query Parameters

| Parâmetro | Tipo    | Obrigatório | Padrão | Descrição        |
| --------- | ------- | ----------- | ------ | ---------------- |
| page      | integer | ❌ Não      | 1      | Número da página |
| perPage   | integer | ❌ Não      | 20     | Itens por página |

#### Response (200 OK)

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
      },
      {
        "id": 157,
        "atendimento_id": 42,
        "nome_arquivo": "captura_tela.png",
        "tipo_mime": "image/png",
        "tamanho_bytes": 512000,
        "tamanho_formatado": "500 KB",
        "data_upload": "2025-11-19 15:38:00",
        "enviado_por": "Administrador",
        "downloads": 0,
        "ultima_visualizacao": null
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

---

## 📎 Endpoints de Anexos

### 1. Fazer Download de Anexo

**GET** `/anexos/{id}/download`

Faz download de um arquivo anexo. Registra o download na auditoria.

#### Request

```bash
curl -X GET "http://104.234.173.105:7080/api/v1/anexos/156/download" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -o comprovante.pdf
```

#### Path Parameters

| Parâmetro | Tipo    | Descrição   |
| --------- | ------- | ----------- |
| id        | integer | ID do anexo |

#### Response (200 OK - Arquivo)

Retorna o arquivo binário com headers apropriados:

```
Content-Type: application/pdf
Content-Disposition: attachment; filename="comprovante_nota_fiscal.pdf"
Content-Length: 245632
```

#### Error Response (404 Not Found)

```json
{
  "status": "error",
  "message": "Anexo não encontrado"
}
```

#### Auditoria

O download é registrado automaticamente em `tb_audit_download`:

```sql
INSERT INTO tb_audit_download (
  anexo_id, usuario_id, data_download, ip_address, user_agent
) VALUES (156, 1, NOW(), '192.168.1.100', 'Mozilla/5.0...')
```

---

## 📊 Endpoints de Dashboard

### 1. Estatísticas do Ano Atual

**GET** `/dashboard/ano-atual`

Retorna estatísticas consolidadas do ano atual (triagem, pendentes, atendendo, finalizados).

#### Request

```bash
curl -X GET http://104.234.173.105:7080/api/v1/dashboard/ano-atual \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### Response (200 OK)

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

---

### 2. Atendimentos Mensais

**GET** `/dashboard/atendimentos-mensais`

Retorna relatório de atendimentos agrupados por mês.

#### Request

```bash
curl -X GET "http://104.234.173.105:7080/api/v1/dashboard/atendimentos-mensais?ano=2025" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### Query Parameters

| Parâmetro | Tipo    | Obrigatório | Padrão    | Descrição        |
| --------- | ------- | ----------- | --------- | ---------------- |
| ano       | integer | ❌ Não      | Ano atual | Ano para filtrar |

#### Response (200 OK)

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
      },
      {
        "mes": 11,
        "mes_nome": "Novembro",
        "total": 52,
        "em_triagem": 5,
        "pendentes": 8,
        "em_atendimento": 2,
        "finalizados": 37
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

---

## ⚠️ Tratamento de Erros

### Validação de Dados

Quando há erros de validação, a API retorna com status 400:

```json
{
  "status": "error",
  "message": "Erro de validação",
  "errors": {
    "usuario": "Campo obrigatório",
    "senha": "Mínimo 6 caracteres",
    "email": "Email inválido"
  }
}
```

### Autenticação Falha

```json
{
  "status": "error",
  "message": "Não autorizado",
  "code": "UNAUTHORIZED",
  "statusCode": 401
}
```

### Recurso Não Encontrado

```json
{
  "status": "error",
  "message": "Recurso não encontrado",
  "code": "NOT_FOUND",
  "statusCode": 404
}
```

### Erro Interno do Servidor

```json
{
  "status": "error",
  "message": "Erro ao processar requisição",
  "code": "INTERNAL_ERROR",
  "statusCode": 500
}
```

### Códigos de Erro Específicos

| Código              | Significado              | HTTP | Ação Recomendada        |
| ------------------- | ------------------------ | ---- | ----------------------- |
| INVALID_CREDENTIALS | Usuário/senha incorretos | 401  | Verificar credenciais   |
| TOKEN_EXPIRED       | Token expirado           | 401  | Fazer refresh do token  |
| TOKEN_INVALID       | Token inválido           | 401  | Fazer novo login        |
| VALIDATION_ERROR    | Dados inválidos          | 400  | Corrigir dados enviados |
| NOT_FOUND           | Recurso não encontrado   | 404  | Verificar ID do recurso |
| FORBIDDEN           | Acesso negado            | 403  | Verificar permissões    |
| CONFLICT            | Conflito (ex: duplicado) | 409  | Dados já existem        |
| INTERNAL_ERROR      | Erro no servidor         | 500  | Contatar suporte        |

---

## 🚦 Limites e Rate Limiting

### Limite de Requisições

| Tipo                     | Limite                | Janela     |
| ------------------------ | --------------------- | ---------- |
| Autenticação             | 5 tentativas          | 15 minutos |
| Requisições Autenticadas | 100 requisições       | 1 minuto   |
| Upload de Arquivo        | 50 MB por arquivo     | -          |
| Listagens                | 1000 registros máximo | -          |

### Headers de Limit

Respostas incluem headers com informações de limite:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 87
X-RateLimit-Reset: 1763607300
```

---

## 💡 Exemplos de Uso

### Exemplo Completo: Fluxo de Autenticação

**1. Login e Obter Token**

```bash
#!/bin/bash

# Fazer login
RESPONSE=$(curl -s -X POST http://104.234.173.105:7080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "usuario": "admin",
    "senha": "123456"
  }')

# Extrair token
TOKEN=$(echo $RESPONSE | jq -r '.data.token')
REFRESH=$(echo $RESPONSE | jq -r '.data.refresh_token')

echo "Access Token: $TOKEN"
echo "Refresh Token: $REFRESH"
```

**2. Usar Token em Requisições Autenticadas**

```bash
# Obter dados do usuário
curl -s -X GET http://104.234.173.105:7080/api/v1/usuarios/me \
  -H "Authorization: Bearer $TOKEN"

# Listar atendimentos
curl -s -X GET "http://104.234.173.105:7080/api/v1/atendimentos/por-numero/11999999999" \
  -H "Authorization: Bearer $TOKEN"
```

**3. Renovar Token Expirado**

```bash
# Se o token estiver perto de expirar
curl -s -X POST http://104.234.173.105:7080/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"refresh_token\": \"$REFRESH\"
  }"
```

### Exemplo em PowerShell

```powershell
# Login
$loginResponse = curl.exe -s -X POST http://104.234.173.105:7080/api/v1/auth/login `
  -H "Content-Type: application/json" `
  -d '{
    "usuario": "admin",
    "senha": "123456"
  }' | ConvertFrom-Json

$token = $loginResponse.data.token

# Fazer requisição autenticada
$auth = "Authorization: Bearer $token"
curl.exe -s -X GET http://104.234.173.105:7080/api/v1/usuarios/me `
  -H $auth
```

### Exemplo em JavaScript/Fetch

```javascript
// Login
async function login() {
  const response = await fetch(
    "http://104.234.173.105:7080/api/v1/auth/login",
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        usuario: "admin",
        senha: "123456",
      }),
    }
  );

  const data = await response.json();
  return data.data.token;
}

// Usar token
async function getMe() {
  const token = await login();

  const response = await fetch(
    "http://104.234.173.105:7080/api/v1/usuarios/me",
    {
      method: "GET",
      headers: {
        Authorization: `Bearer ${token}`,
      },
    }
  );

  return await response.json();
}

// Chamar
getMe().then(console.log);
```

### Exemplo em Python

```python
import requests
import json

BASE_URL = 'http://104.234.173.105:7080/api/v1'

# Login
login_response = requests.post(
    f'{BASE_URL}/auth/login',
    json={
        'usuario': 'admin',
        'senha': '123456'
    }
)

token = login_response.json()['data']['token']

# Fazer requisição autenticada
headers = {
    'Authorization': f'Bearer {token}'
}

me_response = requests.get(
    f'{BASE_URL}/usuarios/me',
    headers=headers
)

print(json.dumps(me_response.json(), indent=2))
```

---

## 🔧 Troubleshooting

### Problema: "Token não fornecido"

**Possíveis Causas:**

- Authorization header não está sendo enviado
- Header está mal formatado
- Token está vazio

**Solução:**

```bash
# ✅ Correto
curl -H "Authorization: Bearer eyJhbGciOi..." http://...

# ❌ Incorreto - Falta "Bearer"
curl -H "Authorization: eyJhbGciOi..." http://...

# ❌ Incorreto - Espaçamento
curl -H "Authorization:Bearer eyJhbGciOi..." http://...
```

---

### Problema: "Token inválido ou expirado"

**Possíveis Causas:**

- Token expirou (TTL de 1 hora)
- Token foi alterado
- Chave secreta diferente

**Solução:**

```bash
# Validar token antes de usar
curl -H "Authorization: Bearer $TOKEN" http://104.234.173.105:7080/api/v1/auth/validate

# Se expirado, renovar
curl -X POST http://104.234.173.105:7080/api/v1/auth/refresh \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"refresh_token\": \"$REFRESH_TOKEN\"}"
```

---

### Problema: "Endpoint não encontrado" (404)

**Possíveis Causas:**

- URL digitada incorretamente
- Método HTTP errado (GET vs POST)
- Path da API incorreta

**Solução:**

```bash
# ✅ Correto
GET http://104.234.173.105:7080/api/v1/usuarios/me

# ❌ Incorreto - Falta /api/v1
GET http://104.234.173.105:7080/usuarios/me

# ❌ Incorreto - Endpoint não existe
GET http://104.234.173.105:7080/api/v1/usuario  (singular)

# ✅ Correto - Use plural
GET http://104.234.173.105:7080/api/v1/usuarios (plural)
```

---

### Problema: Erro 500 - "Erro interno do servidor"

**Possíveis Causas:**

- Erro na query SQL
- Conexão com banco de dados falhou
- Erro não tratado na aplicação

**Verificar Logs:**

```bash
# Logs estão em /var/log/apache2/error.log (em produção)
# ou no mesmo diretório da aplicação (desenvolvimento)

tail -f /path/to/api/logs/api_errors.log
```

---

### Problema: CORS - "Access to XMLHttpRequest blocked"

**Possíveis Causas:**

- CORS não está configurado corretamente
- Origem (Origin) não autorizada

**Solução:**
CORS já está habilitado para todas as origens:

```php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS, PATCH, HEAD');
header('Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept, Authorization');
```

Se precisar restringir, altere em `index.php`:

```php
header('Access-Control-Allow-Origin: https://seu-dominio.com');
```

---

### Problema: Código 400 "Erro de validação"

**Possíveis Causas:**

- JSON malformado
- Campos obrigatórios faltando
- Tipo de dados errado

**Verificar Resposta:**

```bash
curl -X POST http://104.234.173.105:7080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"usuario": "admin"}' \
  -v  # Modo verbose para ver resposta completa
```

**Resposta esperada:**

```json
{
  "status": "error",
  "message": "Erro de validação",
  "errors": {
    "senha": "Campo obrigatório"
  }
}
```

---

### Problema: PowerShell - JSON com escape characters

**Problema:**

```powershell
# ❌ Erro com aspas duplas
curl.exe -X POST ... -d '{"usuario": "admin", "senha": "123"}'
```

**Solução:**

```powershell
# ✅ Use aspas simples externas
curl.exe -X POST ... -d '{\"usuario\": \"admin\", \"senha\": \"123\"}'

# ✅ Ou use @"..."@
curl.exe -X POST ... -d @"
{
  "usuario": "admin",
  "senha": "123"
}
"@
```

---

## 📞 Suporte e Contato

Para dúvidas, bugs ou sugestões:

- **Email:** suporte@saw.com.br
- **Telefone:** (11) 3000-0000
- **Chat:** https://saw.com.br/chat

---

## 📅 Versões e Changelog

### v1.0.0 - 19 de Novembro de 2025

✅ **Novo**

- 10 endpoints implementados
- Autenticação com JWT (HS256)
- Suporte a renovação de tokens
- Endpoints de dashboard com estatísticas
- Auditoria de downloads

✅ **Corrigido**

- Nome correto das tabelas (tbusuario)
- Compatibilidade com MySQL 5.5+
- Header de autorização (getallheaders)
- Cache de php://input

✅ **Melhorado**

- Tratamento de erros robusto
- Validação completa de dados
- Logging detalhado
- Documentação abrangente

---

## 📋 Licença e Termos

Todos os direitos reservados © 2025 SAW. Esta API é fornecida "tal qual" para uso autorizado apenas.

**Proibido:**

- Modificar sem autorização
- Distribuir sem permissão
- Usar em produção sem contrato
- Divulgar dados sensíveis

---

## Apêndice - Estrutura de Banco de Dados

### Tabela: tbusuario

```sql
CREATE TABLE tbusuario (
  id INT PRIMARY KEY AUTO_INCREMENT,
  login VARCHAR(100) UNIQUE NOT NULL,
  nome VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  senha VARCHAR(255) NOT NULL,
  situacao ENUM('A', 'I') DEFAULT 'A',
  data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Tabela: tb_audit_login

```sql
CREATE TABLE tb_audit_login (
  id INT PRIMARY KEY AUTO_INCREMENT,
  usuario_id INT,
  ip_address VARCHAR(45),
  resultado VARCHAR(50),
  data_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES tbusuario(id)
);
```

### Tabela: tb_audit_download

```sql
CREATE TABLE tb_audit_download (
  id INT PRIMARY KEY AUTO_INCREMENT,
  anexo_id INT,
  usuario_id INT,
  ip_address VARCHAR(45),
  user_agent VARCHAR(500),
  data_download TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES tbusuario(id)
);
```

### Tabela: tb_api_log

```sql
CREATE TABLE tb_api_log (
  id INT PRIMARY KEY AUTO_INCREMENT,
  method VARCHAR(10),
  endpoint VARCHAR(255),
  usuario_id INT,
  status_code INT,
  response_time_ms INT,
  data_requisicao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES tbusuario(id)
);
```

---

**Documento Gerado:** 19 de Novembro de 2025  
**Versão:** 1.0.0  
**Status:** ✅ Production Ready

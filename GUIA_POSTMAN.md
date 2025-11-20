# 📚 Guia de Uso - Coleção Postman SAW API v1

## ✅ Pré-requisitos

- Postman (versão 9.0 ou superior)
- Acesso à API: `http://104.234.173.105:7080/api/v1`
- Credenciais: `admin` / `123456`

## 🚀 Como Importar a Coleção

### Opção 1: Via Arquivo JSON

1. Abra o Postman
2. Clique em **Import** (canto superior esquerdo)
3. Selecione **Upload Files**
4. Escolha o arquivo `SAW_API_Postman.postman_collection.json`
5. Clique em **Import**

### Opção 2: Via Link

1. Abra o Postman
2. Clique em **Import**
3. Cole a URL do arquivo (se hospedado)
4. Clique em **Import**

## 🔧 Como Configurar o Environment

1. Clique no ícone de engrenagem ⚙️ (canto superior direito)
2. Selecione **Import**
3. Escolha `SAW_API_Environment.postman_environment.json`
4. Clique em **Import**
5. Na barra superior, selecione **SAW API Environment** no dropdown de environments

## 📋 Estrutura da Coleção

```
SAW API v1
├── 🔐 Autenticação
│   ├── Login (POST)
│   ├── Validar Token (GET)
│   └── Renovar Token (POST)
├── 👥 Usuários
│   ├── Listar Usuários (GET)
│   └── Dados do Usuário Autenticado (GET)
├── 📞 Atendimentos
│   ├── Buscar por Número (GET)
│   └── Listar Anexos (GET)
├── 📎 Anexos
│   └── Download (GET)
└── 📊 Dashboard
    ├── Estatísticas Ano Atual (GET)
    └── Atendimentos Mensais (GET)
```

## 🔐 Como Autenticar

### Primeiro: Fazer Login

1. Abra a pasta **🔐 Autenticação**
2. Clique em **Login**
3. O body já contém as credenciais padrão (`admin` / `123456`)
4. Clique em **Send**
5. O Postman automaticamente salva `jwt_token` e `refresh_token` no environment

### Exemplo de Resposta:

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

## 📝 Endpoints e Parâmetros

### 1️⃣ LOGIN

- **Método:** POST
- **URL:** `/auth/login`
- **Body (JSON):**
  ```json
  {
    "usuario": "admin",
    "senha": "123456"
  }
  ```
- **Resposta:** JWT token + Refresh token (válido por 1 hora + 7 dias respectivamente)

### 2️⃣ VALIDAR TOKEN

- **Método:** GET
- **URL:** `/auth/validate`
- **Header:** `Authorization: Bearer {jwt_token}`
- **Resposta:** Status de validade do token + tempo restante

### 3️⃣ RENOVAR TOKEN

- **Método:** POST
- **URL:** `/auth/refresh`
- **Header:** `Authorization: Bearer {refresh_token}`
- **Resposta:** Novo JWT token

### 4️⃣ LISTAR USUÁRIOS

- **Método:** GET
- **URL:** `/usuarios?page=1&perPage=20&situacao=A`
- **Parâmetros Query:**
  - `page`: Número da página (padrão: 1)
  - `perPage`: Itens por página (padrão: 20, máximo: 100)
  - `situacao`: Filtro por situação ('A' = Ativo)
- **Header:** `Authorization: Bearer {jwt_token}`
- **Resposta:** Lista paginada de usuários

### 5️⃣ DADOS DO USUÁRIO AUTENTICADO

- **Método:** GET
- **URL:** `/usuarios/me`
- **Header:** `Authorization: Bearer {jwt_token}`
- **Resposta:** Dados do usuário logado + info do token

### 6️⃣ BUSCAR ATENDIMENTO POR NÚMERO

- **Método:** GET
- **URL:** `/atendimentos/por-numero/{numero}`
- **Parâmetro:** `{numero}` - Número de telefone (ex: 11999999999)
- **Header:** `Authorization: Bearer {jwt_token}`
- **Resposta:** Atendimento ativo para esse número

### 7️⃣ LISTAR ANEXOS DO ATENDIMENTO

- **Método:** GET
- **URL:** `/atendimentos/{id}/anexos`
- **Parâmetro:** `{id}` - ID do atendimento
- **Header:** `Authorization: Bearer {jwt_token}`
- **Resposta:** Lista de anexos do atendimento

### 8️⃣ DOWNLOAD DE ANEXO

- **Método:** GET
- **URL:** `/anexos/{id}/download`
- **Parâmetro:** `{id}` - ID do anexo
- **Header:** `Authorization: Bearer {jwt_token}`
- **Resposta:** Arquivo com auditoria de acesso

### 9️⃣ ESTATÍSTICAS DO ANO ATUAL

- **Método:** GET
- **URL:** `/dashboard/ano-atual`
- **Header:** `Authorization: Bearer {jwt_token}`
- **Resposta:**
  - Total de atendimentos em triagem
  - Total de pendentes
  - Total atendendo
  - Total finalizados
  - Taxa de finalização (%)
  - Tempo médio (minutos)
  - Canais mais populares

### 🔟 ATENDIMENTOS MENSAIS

- **Método:** GET
- **URL:** `/dashboard/atendimentos-mensais`
- **Header:** `Authorization: Bearer {jwt_token}`
- **Resposta:** Relatório de atendimentos por mês

## 🔄 Workflow Recomendado

### Para Teste Completo:

1. **Login** → Obter token
2. **Validar Token** → Confirmar que está válido
3. **Dados do Usuário** → Ver informações do logado
4. **Listar Usuários** → Ver lista com paginação
5. **Dashboard - Ano Atual** → Ver estatísticas
6. **Buscar Atendimento** → Testar busca por número
7. **Listar Anexos** → Ver anexos do atendimento
8. **Download** → Baixar um anexo (auditado)

## 🛠️ Troubleshooting

### ❌ "Endpoint não encontrado"

- Verifique se a URL está correta
- Confirme que a API está rodando em `104.234.173.105:7080`
- Teste o health check: `GET /api/v1/`

### ❌ "Token não fornecido"

- Verifique se o header `Authorization` foi adicionado
- Certifique-se de que está no formato: `Bearer {token}`
- Execute o Login novamente para gerar novo token

### ❌ "Token inválido ou expirado"

- Use o endpoint **Renovar Token** com o refresh_token
- Ou faça login novamente

### ❌ "Usuário ou senha incorretos"

- Verifique as credenciais no environment
- Padrão: `admin` / `123456`
- Se alterado, update no environment

## 📊 Variáveis do Environment

| Variável         | Valor Padrão                       | Descrição                             |
| ---------------- | ---------------------------------- | ------------------------------------- |
| `base_url`       | http://104.234.173.105:7080/api/v1 | URL base da API                       |
| `username`       | admin                              | Usuário para login                    |
| `password`       | 123456                             | Senha para login                      |
| `jwt_token`      | (auto)                             | Token JWT (preenchido após login)     |
| `refresh_token`  | (auto)                             | Refresh token (preenchido após login) |
| `atendimento_id` | 1                                  | ID do atendimento para testes         |
| `anexo_id`       | 1                                  | ID do anexo para download             |
| `numero_cliente` | 11999999999                        | Número de telefone para busca         |

## 📌 Dicas Importantes

✅ **Variáveis automáticas:** Após login, tokens são salvos automaticamente  
✅ **Reutilizar token:** Use `{{jwt_token}}` em qualquer requisição autenticada  
✅ **Renovar token:** Faça isso antes de expirar (a cada 1 hora)  
✅ **Teste local:** Adapte IP/porta conforme necessário  
✅ **Headers automáticos:** Collection já contém headers corretos

## 🚀 Próximos Passos

1. Importe a coleção no Postman
2. Configure o environment
3. Execute Login
4. Teste todos os 10 endpoints
5. Integre com sua aplicação Delphi ou Postman Runner

---

**Versão:** 1.0  
**Data:** 19/11/2025  
**API Version:** 1.0  
**Status:** ✅ Produção

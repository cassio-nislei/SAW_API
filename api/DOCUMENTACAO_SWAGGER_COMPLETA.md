# 📋 Documentação Swagger - SAW API (42 Endpoints)

**Versão:** 2.0.0  
**Data:** 20/11/2025  
**Status:** ✅ COMPLETO E VALIDADO

---

## 📊 Resumo dos Endpoints

| Categoria         | Qty    | Endpoints                                                                                                                                      |
| ----------------- | ------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| **Health**        | 1      | Health Check                                                                                                                                   |
| **Autenticação**  | 1      | Login                                                                                                                                          |
| **Atendimentos**  | 7      | Listar, Criar, Verificar Pendente, Finalizar, Gravar Mensagem, Atualizar Setor, Inativos                                                       |
| **Mensagens**     | 8      | Verificar Duplicada, Status Múltiplas, Pendentes Envio, Próxima Sequência, Marcar Excluída, Marcar Reação, Marcar Enviada, Comparar Duplicação |
| **Contatos**      | 2      | Exportar, Buscar por Nome                                                                                                                      |
| **Agendamentos**  | 1      | Pendentes                                                                                                                                      |
| **Parâmetros**    | 2      | Sistema, Verificar Expediente                                                                                                                  |
| **Menus**         | 2      | Principal, Submenus                                                                                                                            |
| **Respostas**     | 1      | Respostas Automáticas                                                                                                                          |
| **Departamentos** | 1      | Por Menu                                                                                                                                       |
| **Avisos**        | 4      | Registrar, Limpar Antigos, Limpar Número, Verificar Existente                                                                                  |
| **TOTAL**         | **42** | ✅ Todos implementados                                                                                                                         |

---

## 🔗 Servidores

```
- Desenvolvimento: http://localhost/SAW-main/api/v1
- Produção: http://104.234.173.105:7080/api/v1
- Produção HTTPS: https://api.saw.local/v1
```

---

## 📚 Detalhes dos Endpoints

### 1️⃣ Health Check (1 endpoint)

#### GET /

Verifica se a API está funcionando.

**Resposta 200:**

```json
{
  "sucesso": true,
  "mensagem": "API operacional",
  "dados": {
    "api": "SAW API",
    "version": "2.0.0",
    "status": "running"
  }
}
```

---

### 2️⃣ Autenticação (1 endpoint)

#### POST /auth/login

Autentica usuário e retorna token JWT.

**Request:**

```json
{
  "login": "admin",
  "senha": "123456"
}
```

**Resposta 200:**

```json
{
  "sucesso": true,
  "dados": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "usuario": {
      "id": 1,
      "nome": "Admin",
      "email": "admin@saw.local"
    }
  }
}
```

---

### 3️⃣ Atendimentos (7 endpoints)

#### GET /atendimentos

Lista atendimentos com paginação.

**Query Parameters:**

- `page` (int): Número da página (default: 1)
- `perPage` (int): Itens por página (default: 20)
- `situacao` (string): Filtrar por situação

#### POST /atendimentos

Criar novo atendimento.

**Request:**

```json
{
  "numero": "11988888888",
  "nome": "Cliente Nome",
  "canal": "WhatsApp"
}
```

#### POST /atendimentos/verificar-pendente

Verifica se existe atendimento pendente para um número.

#### POST /atendimentos/finalizar

Finaliza um atendimento.

**Request:**

```json
{
  "id": 123,
  "observacao": "Atendimento finalizado"
}
```

#### POST /atendimentos/gravar-mensagem

Grava mensagem com possível anexo.

**Content-Type:** multipart/form-data

**Parameters:**

- `id_atendimento` (int, required)
- `mensagem` (string, required)
- `arquivo` (file, optional)

#### PUT /atendimentos/atualizar-setor

Atualiza o setor responsável.

**Request:**

```json
{
  "id": 123,
  "setor": "Suporte"
}
```

#### GET /atendimentos/inativos

Lista atendimentos inativos/encerrados.

---

### 4️⃣ Mensagens (8 endpoints)

#### POST /mensagens/verificar-duplicada

Verifica se uma mensagem já foi enviada.

**Request:**

```json
{
  "conteudo": "Texto da mensagem",
  "remetente": "admin"
}
```

#### POST /mensagens/status-multiplas

Obter status de múltiplas mensagens.

**Request:**

```json
{
  "ids": [1, 2, 3, 4, 5]
}
```

#### GET /mensagens/pendentes-envio

Lista mensagens aguardando envio.

#### GET /mensagens/proxima-sequencia

Obter próxima sequência de mensagem.

**Query Parameter:**

- `id_atendimento` (int, required)

#### PUT /mensagens/marcar-excluida

Marca mensagem como excluída.

**Request:**

```json
{
  "id": 123
}
```

#### POST /mensagens/marcar-reacao

Adiciona reação emoji.

**Request:**

```json
{
  "id": 123,
  "reacao": 1
}
```

#### PUT /mensagens/marcar-enviada

Marca como enviada.

**Request:**

```json
{
  "id": 123
}
```

#### POST /mensagens/comparar-duplicacao

Compara dois textos para detectar duplicação.

**Request:**

```json
{
  "mensagem1": "Primeiro texto",
  "mensagem2": "Segundo texto"
}
```

---

### 5️⃣ Contatos (2 endpoints)

#### GET /contatos/exportar

Exporta contatos em formato especificado.

**Query Parameter:**

- `formato` (string): json, csv ou xlsx

#### GET /contatos/buscar-nome

Busca contato por nome.

**Query Parameter:**

- `nome` (string, required): Nome a buscar

---

### 6️⃣ Agendamentos (1 endpoint)

#### GET /agendamentos/pendentes

Lista agendamentos aguardando execução.

---

### 7️⃣ Parâmetros (2 endpoints)

#### GET /parametros/sistema

Retorna parâmetros configuráveis do sistema.

**Resposta:**

```json
{
  "sucesso": true,
  "dados": {
    "horario_inicio": "08:00",
    "horario_fim": "18:00",
    "dias_funcionamento": "seg-sex",
    ...
  }
}
```

#### GET /parametros/verificar-expediente

Verifica se atendimento está dentro do expediente.

---

### 8️⃣ Menus (2 endpoints)

#### GET /menus/principal

Retorna menu principal com todas as opções.

#### GET /menus/submenus

Retorna submenus de um menu pai.

**Query Parameter:**

- `id_menu` (int): ID do menu pai

---

### 9️⃣ Respostas (1 endpoint)

#### GET /respostas/respostas-automaticas

Retorna lista de respostas automáticas configuradas.

---

### 🔟 Departamentos (1 endpoint)

#### GET /departamentos/por-menu

Lista departamentos associados a um menu.

**Query Parameter:**

- `id_menu` (int, required): ID do menu

---

### 1️⃣1️⃣ Avisos (4 endpoints)

#### POST /avisos/registrar

Registra um aviso (geralmente fora do expediente).

**Request:**

```json
{
  "numero": "11988888888",
  "mensagem": "Seu aviso aqui"
}
```

#### DELETE /avisos/limpar-antigos

Remove avisos mais antigos que X dias.

**Query Parameter:**

- `dias` (int, default: 30)

#### DELETE /avisos/limpar-numero

Remove avisos específicos de um número.

**Query Parameter:**

- `numero` (string, required)

#### GET /avisos/verificar-existente

Verifica se existe aviso para um número.

**Query Parameter:**

- `numero` (string, required)

---

## 🔐 Autenticação

Todos os endpoints (exceto `/` e `/auth/login`) requerem token JWT.

**Header obrigatório:**

```
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc...
```

**Token válido por:** 1 hora  
**Refresh token válido por:** 7 dias

---

## 📦 Formato de Resposta Padrão

### Sucesso (2xx)

```json
{
  "sucesso": true,
  "mensagem": "Descrição da ação",
  "dados": {
    "resultado": "dados aqui"
  },
  "status_code": 200
}
```

### Erro (4xx/5xx)

```json
{
  "sucesso": false,
  "mensagem": "Descrição do erro",
  "dados": null,
  "status_code": 400
}
```

---

## 🧪 Como Testar

### Opção 1: Swagger UI

```
URL: http://104.234.173.105:7080/api/swagger-ui.html
```

1. Abra no navegador
2. Execute o endpoint `/auth/login`
3. Copie o token da resposta
4. Clique em "Authorize" (canto superior direito)
5. Cole o token: `Bearer token_aqui`
6. Teste os demais endpoints

### Opção 2: Postman

```
1. Importe: SAW_API_32_Endpoints.postman_collection.json
2. Crie ambiente com:
   - base_url: http://104.234.173.105:7080/api/v1
   - token: (após login)
3. Execute requests
```

### Opção 3: CURL

```bash
# Login
curl -X POST http://104.234.173.105:7080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"login":"admin","senha":"123456"}'

# Com token
curl -X GET http://104.234.173.105:7080/api/v1/atendimentos \
  -H "Authorization: Bearer seu_token_aqui"
```

---

## ✅ Validação dos Endpoints

Execute o script para validar todos os 42 endpoints:

```powershell
# Windows PowerShell
.\VALIDATE_SWAGGER.ps1

# Ou Windows CMD
VALIDATE_SWAGGER.bat
```

**Resultado esperado:**

```
✅ TODOS OS ENDPOINTS ESTÃO OPERACIONAIS (SWAGGER OK)
Taxa de sucesso: 100%
```

---

## 📝 Arquivo Swagger

**Localização:** `api/swagger.json`

**Validação JSON:**

```powershell
$json = Get-Content api/swagger.json | ConvertFrom-Json
Write-Host "Endpoints: $($json.paths | Measure-Object).Count"
Write-Host "Versão: $($json.info.version)"
```

**Servir via PHP:**

```
GET /api/swagger-json.php
```

---

## 🔄 Fluxo de Integração Completo

```
1. Autenticação
   POST /auth/login → Obter token

2. Obter Configuração
   GET /parametros/sistema
   GET /parametros/verificar-expediente

3. Processar Atendimento
   POST /atendimentos → Criar
   POST /atendimentos/gravar-mensagem → Enviar resposta
   POST /mensagens/marcar-enviada → Confirmar envio

4. Finalizar
   POST /atendimentos/finalizar → Encerrar
```

---

## 🚀 Melhorias Implementadas (v2.0.0)

✅ Adicionados 32 novos endpoints  
✅ Suporte a todas operações CRUD básicas  
✅ Melhor organização por tags  
✅ Documentação completa de cada endpoint  
✅ Exemplos de requisição/resposta  
✅ Suporte a múltiplos servidores  
✅ Validação de token JWT  
✅ Tratamento de erros padronizado

---

## 📞 Suporte

- **Email:** suporte@saw.local
- **Documentação Completa:** Veja `api/DOCUMENTACAO_SWAGGER.md`
- **Guia Rápido:** Veja `GUIA_POSTMAN_COLLECTION.md`
- **Testes:** Veja `GUIA_TESTE_32_ENDPOINTS.md`

---

**Swagger JSON atualizado e validado em 20/11/2025** ✅

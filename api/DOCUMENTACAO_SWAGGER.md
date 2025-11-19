# 📚 Documentação Swagger - SAW API

## Visão Geral

A documentação Swagger/OpenAPI 3.0 da SAW API fornece uma interface interativa completa para explorar, testar e integrar todos os endpoints da API.

---

## 🚀 Como Acessar

### Via Browser

**URL de Desenvolvimento:**

```
http://localhost/SAW-main/api/swagger-ui.html
```

**Ou através do servidor Swagger PHP:**

```
http://localhost/SAW-main/api/swagger/
```

### Via CLI

```bash
# Ver o arquivo JSON bruto
curl http://localhost/SAW-main/api/swagger.json

# Usar jq para formatar
curl http://localhost/SAW-main/api/swagger.json | jq .

# Salvar localmente
curl http://localhost/SAW-main/api/swagger.json -o swagger-local.json
```

---

## 📁 Arquivos Swagger

### `swagger.json` ⭐

- **Formato:** OpenAPI 3.0.0
- **Tamanho:** ~50KB
- **Conteúdo:**
  - 24 endpoints documentados
  - 30+ schemas de requisição/resposta
  - Exemplos de uso
  - Descrições completas
  - Códigos de erro

**Localização:**

```
api/swagger.json
```

### `swagger-ui.html` 🖥️

- **Formato:** HTML + JavaScript
- **CDN:** Swagger UI oficial
- **Recursos:**
  - Interface interativa
  - Testes de endpoints
  - Visualização de modelos
  - Suporte offline (com CDN)

**Localização:**

```
api/swagger-ui.html
```

### `swagger/index.php` 🔗

- **Função:** Servidor dinâmico
- **Rotas:**
  - `/swagger/` → UI HTML
  - `/swagger/swagger.json` → JSON spec

**Localização:**

```
api/swagger/index.php
```

---

## 🎯 Endpoints Documentados

### Categoria: Health Check

```
GET / - Verifica se a API está rodando
```

### Categoria: Atendimentos (7 endpoints)

```
GET    /atendimentos                    - Lista com paginação
POST   /atendimentos                    - Criar novo
GET    /atendimentos/ativos             - Apenas ativos
GET    /atendimentos/{id}               - Detalhes
PUT    /atendimentos/{id}/situacao      - Alterar situação
PUT    /atendimentos/{id}/setor         - Transferir setor
POST   /atendimentos/{id}/finalizar     - Encerrar
```

### Categoria: Mensagens (7 endpoints)

```
GET    /atendimentos/{id}/mensagens     - Listar
POST   /atendimentos/{id}/mensagens     - Criar
GET    /atendimentos/{id}/mensagens/pendentes - Não visualizadas
PUT    /mensagens/{id}/situacao         - Alterar situação
PUT    /mensagens/{id}/visualizar       - Marcar como lida
POST   /mensagens/{id}/reacao           - Adicionar emoji
DELETE /mensagens/{id}                  - Remover
```

### Categoria: Anexos (1 endpoint)

```
POST   /atendimentos/{id}/anexos        - Upload de arquivo
```

### Categoria: Parâmetros (2 endpoints)

```
GET    /parametros                      - Listar
PUT    /parametros/{id}                 - Atualizar
```

### Categoria: Menus (4 endpoints)

```
GET    /menus                           - Listar
GET    /menus/{id}                      - Detalhes
GET    /menus/{id}/resposta-automatica  - Resposta automática
GET    /menus/submenus/{idPai}          - Submenus
```

### Categoria: Horários (2 endpoints)

```
GET    /horarios/funcionamento          - Horários
GET    /horarios/aberto                 - Verificar se aberto
```

---

## 💡 Como Usar o Swagger UI

### 1️⃣ Explorar Endpoints

1. Abra a URL do Swagger UI no navegador
2. Veja a lista de endpoints agrupados por categoria (tags)
3. Clique em um endpoint para expandir
4. Leia a descrição, parâmetros e esquemas

### 2️⃣ Testar um Endpoint

1. Clique no botão "Try it out"
2. Preencha os parâmetros obrigatórios
3. Configure o corpo da requisição (se POST/PUT)
4. Clique em "Execute"
5. Veja a resposta na aba "Response"

### 3️⃣ Exemplo: Listar Atendimentos

```
1. Procure por "GET /atendimentos"
2. Clique para expandir
3. Clique em "Try it out"
4. Defina: page=1, perPage=20
5. Clique "Execute"
6. Veja o resultado em JSON
```

### 4️⃣ Exemplo: Criar Atendimento

```
1. Procure por "POST /atendimentos"
2. Clique para expandir
3. Clique em "Try it out"
4. Preencha o JSON:
   {
     "numero": "ATD-001",
     "solicitante": "João",
     "solicitacao": "Problema com sistema"
   }
5. Clique "Execute"
6. Veja o ID do novo atendimento
```

---

## 📊 Esquemas (Schemas)

### Atendimento

```json
{
  "id": 1,
  "numero": "ATD-001",
  "solicitante": "string",
  "solicitacao": "string",
  "situacao": "aberto|em_andamento|finalizado|cancelado",
  "setor": "string",
  "responsavel": "string",
  "data_criacao": "2024-11-19T10:30:00",
  "data_atualizacao": "2024-11-19T10:30:00"
}
```

### Mensagem

```json
{
  "id": 1,
  "id_atendimento": 1,
  "seqm": 1,
  "conteudo": "string",
  "remetente": "string",
  "tipo": "entrada|saida",
  "visualizada": 0,
  "data_criacao": "2024-11-19T10:30:00"
}
```

### Resposta Padrão

```json
{
  "status": "success|error",
  "message": "string",
  "data": {},
  "pagination": {
    "page": 1,
    "perPage": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

---

## 🔐 Segurança

### Headers Padrão

```
Content-Type: application/json
Access-Control-Allow-Origin: *
```

### Códigos de Status HTTP

```
200 OK                  - Sucesso
201 Created             - Recurso criado
204 No Content          - Sem conteúdo
400 Bad Request         - Erro de validação
404 Not Found           - Recurso não existe
409 Conflict            - Conflito (ex: já existe)
500 Internal Error      - Erro no servidor
```

---

## 🛠️ Integração com Ferramentas

### Postman

```
1. Abra Postman
2. File → Import
3. Cole a URL: http://localhost/SAW-main/api/swagger.json
4. Clique Import
5. Todos os endpoints estarão disponíveis
```

### Insomnia

```
1. Abra Insomnia
2. Design → Import
3. Cole a URL: http://localhost/SAW-main/api/swagger.json
4. Clique Import
5. Crie requisições baseadas nos endpoints
```

### cURL

```bash
# Listar atendimentos
curl -X GET "http://localhost/SAW-main/api/v1/atendimentos?page=1&perPage=20"

# Criar atendimento
curl -X POST "http://localhost/SAW-main/api/v1/atendimentos" \
  -H "Content-Type: application/json" \
  -d '{
    "numero": "ATD-001",
    "solicitante": "João",
    "solicitacao": "Teste"
  }'
```

### JavaScript/Fetch

```javascript
// Listar atendimentos
fetch("http://localhost/SAW-main/api/v1/atendimentos")
  .then((r) => r.json())
  .then((data) => console.log(data));

// Criar atendimento
fetch("http://localhost/SAW-main/api/v1/atendimentos", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    numero: "ATD-001",
    solicitante: "João",
    solicitacao: "Teste",
  }),
})
  .then((r) => r.json())
  .then((data) => console.log(data));
```

---

## 📞 Suporte Swagger

### URLs de Referência

- **Swagger UI:** https://swagger.io/tools/swagger-ui/
- **OpenAPI 3.0:** https://spec.openapis.org/oas/v3.0.3
- **Swagger Editor:** https://editor.swagger.io/

### Atualizar Swagger

Se adicionar novos endpoints, atualize `swagger.json`:

```bash
# Validar Swagger
curl -X POST "https://api.swagger.io/validate" \
  -H "Content-Type: application/json" \
  -d @api/swagger.json

# Ou use o Swagger Editor online
# https://editor.swagger.io/
```

---

## ✅ Checklist de Documentação

- ✅ OpenAPI 3.0.0 spec completo
- ✅ 24 endpoints documentados
- ✅ 30+ schemas definidos
- ✅ Exemplos de requisição/resposta
- ✅ Descrições de erro
- ✅ Parâmetros obrigatórios marcados
- ✅ Interface Swagger UI
- ✅ Compatível com Postman
- ✅ Compatível com Insomnia
- ✅ CORS habilitado

---

## 🎓 Próximos Passos

1. **Testar Endpoints:** Use o Swagger UI para testar todos os endpoints
2. **Integrar:** Use APIClient.php ou importe no Postman
3. **Monitorar:** Acompanhe logs em real-time
4. **Evoluir:** Adicione novos endpoints conforme necessário

---

**Documentação criada:** 19/11/2025  
**Versão Swagger:** 1.0.0  
**Versão API:** 1.0.0  
**Status:** ✅ **Completo**

# 🔌 SAW API - Swagger/OpenAPI 3.0 Documentation

Documentação completa em Swagger/OpenAPI 3.0 da SAW API com interface interativa para testes.

---

## 🚀 Quick Start

### 1. Abra a Interface Swagger UI

```
http://localhost/SAW-main/api/swagger-ui.html
```

### 2. Explore os Endpoints

Clique em um endpoint para expandir e ver detalhes, parâmetros e exemplos.

### 3. Teste um Endpoint

- Clique em "Try it out"
- Preencha os campos
- Clique "Execute"
- Veja a resposta

---

## 📁 Arquivos Swagger

| Arquivo                     | Descrição                                 |
| --------------------------- | ----------------------------------------- |
| **swagger.json**            | Especificação OpenAPI 3.0 completa (50KB) |
| **swagger-ui.html**         | Interface interativa (HTML + Swagger UI)  |
| **swagger/index.php**       | Servidor dinâmico PHP para servir Swagger |
| **DOCUMENTACAO_SWAGGER.md** | Guia completo de uso                      |
| **swagger-setup.sh**        | Script setup para Linux/Mac               |
| **swagger-setup.bat**       | Script setup para Windows                 |
| **apache-swagger.conf**     | Configuração Apache                       |

---

## 🎯 Endpoints Documentados

### 24 Endpoints em 6 Categorias

**Atendimentos** (7)

- Lista, criar, consultar, atualizar situação, atualizar setor, finalizar

**Mensagens** (7)

- Listar, criar, listar pendentes, atualizar situação, visualizar, reação, deletar

**Anexos** (1)

- Upload de arquivos

**Parâmetros** (2)

- Obter, atualizar

**Menus** (4)

- Listar, consultar, resposta automática, submenus

**Horários** (2)

- Horários de funcionamento, verificar se aberto

---

## 💡 Como Usar

### Via Swagger UI (Recomendado)

1. **Abra no navegador:** `http://localhost/SAW-main/api/swagger-ui.html`
2. **Procure um endpoint:** Use o campo "Filter" para buscar
3. **Clique para expandir:** Veja descrição e parâmetros
4. **Teste:** Clique em "Try it out" e execute

### Via Postman

1. Abra Postman
2. File → Import
3. Cole: `http://localhost/SAW-main/api/swagger.json`
4. Clique Import
5. Todos os endpoints estarão disponíveis

### Via cURL

```bash
# Listar atendimentos
curl http://localhost/SAW-main/api/v1/atendimentos

# Criar atendimento
curl -X POST http://localhost/SAW-main/api/v1/atendimentos \
  -H "Content-Type: application/json" \
  -d '{
    "numero": "ATD-001",
    "solicitante": "João",
    "solicitacao": "Teste"
  }'
```

### Via JavaScript

```javascript
// Listar
fetch("http://localhost/SAW-main/api/v1/atendimentos")
  .then((r) => r.json())
  .then(console.log);

// Criar
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
  .then(console.log);
```

---

## 📊 Estrutura de Resposta

### Sucesso (200)

```json
{
  "status": "success",
  "message": "Operação realizada com sucesso",
  "data": {
    "id": 1,
    "numero": "ATD-001",
    ...
  }
}
```

### Com Paginação

```json
{
  "status": "success",
  "data": [...],
  "pagination": {
    "page": 1,
    "perPage": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

### Erro (400/404/500)

```json
{
  "status": "error",
  "message": "Descrição do erro",
  "errors": {
    "campo": "Mensagem específica"
  }
}
```

---

## 🔐 Esquemas Principais

### Atendimento

- `id` (integer)
- `numero` (string) - Identificador único
- `solicitante` (string) - Quem solicitou
- `solicitacao` (string) - Descrição
- `situacao` (enum) - aberto, em_andamento, finalizado, cancelado
- `setor` (string)
- `responsavel` (string)
- `data_criacao` (datetime)
- `data_atualizacao` (datetime)

### Mensagem

- `id` (integer)
- `id_atendimento` (integer)
- `seqm` (integer) - Sequência
- `conteudo` (string)
- `remetente` (string)
- `tipo` (enum) - entrada, saida
- `visualizada` (integer) - 0 ou 1
- `data_criacao` (datetime)

### Parâmetro

- Campo de configuração dinâmica
- Suporta qualquer propriedade JSON

---

## 🛠️ Ferramentas Compatíveis

### ✅ Testadas e Funcionando

- **Swagger UI** - Interface padrão
- **Postman** - Importação de spec
- **Insomnia** - Importação de spec
- **cURL** - Linha de comando
- **Fetch API** - JavaScript nativo
- **Axios** - JavaScript biblioteca
- **RestClient** - VS Code extension
- **Thunder Client** - VS Code extension

### 📱 Versões de Navegador

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

---

## ⚙️ Configuração

### Pré-requisitos

- Apache 2.4+ com mod_rewrite
- PHP 7.0+
- MySQL 5.7+
- CDN Swagger UI (ou offline)

### Permissões

```bash
# Linux/Mac
chmod 755 api/swagger/
chmod 644 api/swagger.json
chmod 644 api/swagger-ui.html

# Windows
# Use GUI ou ajuste via Properties
```

### Variáveis de Ambiente

```bash
# .env
SWAGGER_URL=http://localhost/SAW-main/api/swagger.json
SWAGGER_TITLE=SAW API v1.0
API_BASE_URL=http://localhost/SAW-main/api/v1
```

---

## 🔄 Manutenção

### Atualizar Swagger

Se adicionar novos endpoints:

1. Edite `api/v1/index.php`
2. Atualize `swagger.json` com novo endpoint
3. Atualize `api/DOCUMENTACAO_SWAGGER.md`
4. Valide com editor online: https://editor.swagger.io/

### Validar JSON

```bash
# Node.js
npm install -g swagger-cli
swagger-cli validate api/swagger.json

# Python
pip install swagger-spec-validator
swagger-spec-validator api/swagger.json

# Online
# https://editor.swagger.io/
```

---

## 🐛 Troubleshooting

### "Swagger UI não carrega"

- ✓ Verifique URL: `http://localhost/SAW-main/api/swagger-ui.html`
- ✓ Verifique CDN Swagger UI
- ✓ Verifique console do navegador (F12)

### "JSON não é servido"

- ✓ Verifique arquivo `swagger.json`
- ✓ Verifique permissões (644)
- ✓ Verifique CORS headers

### "Endpoints não aparecem"

- ✓ Verifique `swagger.json` está válido
- ✓ Verifique parser JSON
- ✓ Use https://editor.swagger.io/ para validar

### "Teste retorna erro 404"

- ✓ Verifique Apache mod_rewrite ativo
- ✓ Verifique `.htaccess` em `api/v1/`
- ✓ Verifique URL base correta

---

## 📚 Recursos Adicionais

### Documentação Oficial

- **Swagger UI:** https://swagger.io/tools/swagger-ui/
- **OpenAPI 3.0:** https://spec.openapis.org/oas/v3.0.3
- **OpenAPI Spec:** https://www.openapis.org/

### Ferramentas Úteis

- **Swagger Editor:** https://editor.swagger.io/
- **JSON Schema:** https://json-schema.org/
- **API Blueprint:** https://apiblueprint.org/

### Tutoriais

- **Getting Started:** https://swagger.io/tutorial/getting-started/
- **OpenAPI Guide:** https://swagger.io/resources/articles/best-practices-in-api-design/

---

## ✅ Checklist

- ✅ OpenAPI 3.0.0 specification
- ✅ 24 endpoints documentados
- ✅ 30+ schemas definidos
- ✅ Exemplos de requisição/resposta
- ✅ Códigos de erro documentados
- ✅ Interface Swagger UI
- ✅ Servidor dinâmico PHP
- ✅ CORS headers habilitado
- ✅ Compatível com Postman/Insomnia
- ✅ Scripts de setup automatizados
- ✅ Configuração Apache incluída
- ✅ Documentação completa

---

## 📞 Suporte

Para problemas ou dúvidas:

1. Leia `DOCUMENTACAO_SWAGGER.md`
2. Consulte `README.md` da API
3. Verifique `swagger.json` (válido?)
4. Use Swagger Editor: https://editor.swagger.io/
5. Valide com: `swagger-cli validate swagger.json`

---

## 🎓 Próximos Passos

1. **Familiarize-se:** Explore endpoints no Swagger UI
2. **Teste:** Execute alguns GET e POST
3. **Importe:** Adicione em Postman/Insomnia
4. **Integre:** Use APIClient.php ou cURL
5. **Monitore:** Acompanhe logs

---

**Documentação Criada:** 19/11/2025  
**Especificação:** OpenAPI 3.0.0  
**Versão API:** 1.0.0  
**Status:** ✅ Completo

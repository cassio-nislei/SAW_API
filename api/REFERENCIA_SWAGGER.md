# 🔗 REFERÊNCIA RÁPIDA - SWAGGER SAW API

## 🚀 URLs de Acesso

```
🖥️  Interface Swagger UI (Recomendado):
    http://localhost/SAW-main/api/swagger-ui.html

📋 Arquivo JSON (OpenAPI 3.0):
    http://localhost/SAW-main/api/swagger.json

🔗 Servidor Dinâmico (PHP):
    http://localhost/SAW-main/api/swagger/

📚 API Base (Requisições):
    http://localhost/SAW-main/api/v1/
```

---

## 📚 Documentação Localizada

```
Local:
├── SWAGGER_CRIADO.txt ..................... Resumo visual ⭐ LEIA PRIMEIRO
├── SWAGGER_README.md ..................... Quick start (5-10 min)
├── DOCUMENTACAO_SWAGGER.md .............. Documentação completa (30 min)
├── SWAGGER_COMPLETO.txt ................. Resumo executivo
├── SWAGGER_RESUMO_FINAL.md .............. Resumo final
├── swagger.json ......................... Especificação OpenAPI 3.0
├── swagger-ui.html ....................... Interface (HTML + JS)
├── swagger/index.php ..................... Servidor dinâmico
├── swagger-setup.bat ..................... Setup Windows
└── swagger-setup.sh ...................... Setup Linux/Mac
```

---

## 🎯 Quick Start (5 minutos)

```bash
1. Abra browser: http://localhost/SAW-main/api/swagger-ui.html
2. Explore endpoints (clique para expandir)
3. Clique "Try it out"
4. Preencha parâmetros
5. Clique "Execute"
6. Veja resposta em JSON
```

---

## 📊 24 Endpoints Documentados

```
ATENDIMENTOS (7):
  GET    /atendimentos              Lista com paginação
  POST   /atendimentos              Criar novo
  GET    /atendimentos/ativos       Apenas ativos
  GET    /atendimentos/{id}         Detalhes
  PUT    /atendimentos/{id}/situacao    Alterar situação
  PUT    /atendimentos/{id}/setor       Transferir setor
  POST   /atendimentos/{id}/finalizar   Encerrar

MENSAGENS (7):
  GET    /atendimentos/{id}/mensagens          Listar
  POST   /atendimentos/{id}/mensagens          Criar
  GET    /atendimentos/{id}/mensagens/pendentes Pendentes
  PUT    /mensagens/{id}/situacao              Alterar
  PUT    /mensagens/{id}/visualizar            Marcar lida
  POST   /mensagens/{id}/reacao                Adicionar reação
  DELETE /mensagens/{id}                       Remover

ANEXOS (1):
  POST   /atendimentos/{id}/anexos    Upload

PARÂMETROS (2):
  GET    /parametros                 Obter
  PUT    /parametros/{id}            Atualizar

MENUS (4):
  GET    /menus                      Listar
  GET    /menus/{id}                 Detalhes
  GET    /menus/{id}/resposta-automatica  Resposta
  GET    /menus/submenus/{idPai}     Submenus

HORÁRIOS (2):
  GET    /horarios/funcionamento    Horários
  GET    /horarios/aberto           Verificar se aberto

HEALTH (1):
  GET    /                           Status da API
```

---

## 💻 Exemplos de Uso

### cURL

```bash
# Listar atendimentos
curl http://localhost/SAW-main/api/v1/atendimentos

# Criar atendimento
curl -X POST http://localhost/SAW-main/api/v1/atendimentos \
  -H "Content-Type: application/json" \
  -d '{
    "numero":"ATD-001",
    "solicitante":"João",
    "solicitacao":"Teste"
  }'
```

### JavaScript/Fetch

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

### PHP

```php
require_once("api/APIClient.php");
$api = new APIClient();

// Listar
$atendimentos = $api->listAtendimentos();

// Criar
$novo = $api->createAtendimento([
  'numero' => 'ATD-001',
  'solicitante' => 'João',
  'solicitacao' => 'Teste'
]);
```

---

## 📱 Postman

```bash
1. File → Import
2. URL: http://localhost/SAW-main/api/swagger.json
3. Import
4. Endpoints aparecem automaticamente
5. Selecione e clique "Send"
```

---

## 🌐 Insomnia

```bash
1. Design → Import
2. URL: http://localhost/SAW-main/api/swagger.json
3. Import
4. Use os endpoints criados
```

---

## ⚙️ Validar OpenAPI 3.0

```bash
Online (Recomendado):
1. Abra: https://editor.swagger.io/
2. Copie conteúdo de: swagger.json
3. Cole na aba "Spec"
4. Valida automaticamente

Linha de Comando:
# Node.js
npm install -g swagger-cli
swagger-cli validate api/swagger.json

# Python
pip install swagger-spec-validator
swagger-spec-validator api/swagger.json
```

---

## 🔧 Troubleshooting

| Problema           | Causa                    | Solução                     |
| ------------------ | ------------------------ | --------------------------- |
| 404 Not Found      | mod_rewrite desabilitado | Verifique Apache config     |
| CORS Error         | Headers não configurados | Verifique .htaccess         |
| JSON invalido      | Sintaxe incorreta        | Valide em editor.swagger.io |
| Endpoints ausentes | Cache do navegador       | Limpe Ctrl+Shift+Del        |

---

## 📞 Recursos Úteis

```
Swagger UI: https://swagger.io/tools/swagger-ui/
OpenAPI 3.0: https://spec.openapis.org/oas/v3.0.3
Editor Online: https://editor.swagger.io/
JSON Schema: https://json-schema.org/
```

---

## ✅ Checklist Setup

- [ ] Abra: http://localhost/SAW-main/api/swagger-ui.html
- [ ] Explore endpoints
- [ ] Teste um GET (sem parâmetros)
- [ ] Teste um POST (com dados)
- [ ] Importe em Postman
- [ ] Compartilhe URL com time

---

**Criado:** 19/11/2025  
**Versão:** 1.0.0  
**Especificação:** OpenAPI 3.0.0  
**Status:** ✅ Pronto para Usar

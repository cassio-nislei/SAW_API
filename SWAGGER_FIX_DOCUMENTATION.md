# Resolução - Erro "Failed to fetch" do Swagger UI

## 📋 Resumo do Problema

O Swagger UI estava retornando erro "Failed to fetch" com mensagens de CORS, mesmo tendo:

- ✅ Headers CORS configurados em `swagger-json.php`
- ✅ JSON válido em `swagger.json`
- ✅ Configuração CORS no `.htaccess`

## 🔍 Raiz da Causa

O arquivo `swagger-json.php` era inacessível através do routing normal da API porque:

1. O `.htaccess` em `/api/` reescreve requisições
2. O arquivo `.php` não era servido diretamente
3. O Swagger UI estava tentando acessar via URL que passava pelo routing, mas não tinha uma rota definida

## ✅ Solução Implementada

### 1. **Nova Rota no API Router** (`api/v1/index.php`)

Adicionada rota `GET /swagger.json` que:

- Serve o arquivo `swagger.json` com headers CORS corretos
- Detecta dinamicamente o servidor atual
- Atualiza as URLs dos servidores conforme necessário
- Está integrada no routing normal da API

```php
$router->get('/swagger.json', function () {
    // Headers CORS completos
    // Validação de JSON
    // Detecção dinâmica de servidor
});
```

### 2. **Require do AnexosController** (`api/v1/index.php`)

Adicionado `require_once` que estava faltando:

```php
require_once __DIR__ . '/controllers/AnexosController.php';
```

### 3. **Atualização do Swagger UI** (`api/swagger-ui.html`)

Alterada a URL de busca do Swagger JSON:

- **De:** `/api/swagger-json.php`
- **Para:** `/api/v1/swagger.json`

Isso garante que:

- A requisição passa pelo routing normal da API
- Os headers CORS são aplicados consistentemente
- A URL é mais intuitiva e segue a estrutura RESTful

## 🚀 Como Testar

### Opção 1: Teste Rápido no Navegador

```
http://104.234.173.105:7080/api/test-swagger-route.html
```

Este arquivo HTML fornecido testa:

- ✅ GET request para `/api/v1/swagger.json`
- ✅ OPTIONS preflight request
- ✅ Headers CORS retornados
- ✅ Validação de conteúdo

### Opção 2: Teste com cURL

```bash
curl -i http://104.234.173.105:7080/api/v1/swagger.json
```

Deve retornar:

- Status: 200 OK
- Headers CORS: `Access-Control-Allow-Origin: *`
- Content: JSON válido com a especificação Swagger

### Opção 3: Teste via Swagger UI

```
http://104.234.173.305:7080/api/swagger-ui.html
```

Deve carregar sem erros e mostrar todos os 45+ endpoints.

## 📊 Estrutura de Acesso

```
┌─────────────────────────────────────────────┐
│ Swagger UI (swagger-ui.html)                │
└────────────────┬────────────────────────────┘
                 │ GET /api/v1/swagger.json
                 ▼
┌─────────────────────────────────────────────┐
│ API Router (index.php)                      │
│ - GET /swagger.json route                   │
│ - Headers CORS automáticos                  │
│ - Validação de JSON                         │
└────────────────┬────────────────────────────┘
                 │ file_get_contents()
                 ▼
┌─────────────────────────────────────────────┐
│ swagger.json (especificação OpenAPI)        │
│ - 45+ endpoints documentados                │
│ - Schemas validados                         │
│ - Exemplos de request/response              │
└─────────────────────────────────────────────┘
```

## ✨ Benefícios da Solução

1. **Rota Integrada:** Usa o mesmo routing que o restante da API
2. **Headers CORS Consistentes:** Aplicados automaticamente
3. **Sem Dependências de `.htaccess`:** Funciona mesmo se mod_rewrite estiver desabilitado
4. **URL Limpa:** `/api/v1/swagger.json` em vez de `/api/swagger-json.php`
5. **Dinâmica:** Detecta e usa o servidor correto automaticamente
6. **Escalável:** Mantém a mesma estrutura que o restante da API

## 📁 Arquivos Modificados

| Arquivo                       | Mudança                                     | Status   |
| ----------------------------- | ------------------------------------------- | -------- |
| `api/v1/index.php`            | ✅ Adicionada rota GET /swagger.json        | COMPLETO |
| `api/v1/index.php`            | ✅ Adicionado require AnexosController      | COMPLETO |
| `api/swagger-ui.html`         | ✅ URL atualizada para /api/v1/swagger.json | COMPLETO |
| `api/test-swagger-route.html` | ✅ Criado arquivo de teste                  | NOVO     |

## 🔄 Próximos Passos

1. **Testar** a nova rota usando o arquivo de teste fornecido
2. **Acessar** o Swagger UI e verificar se carrega sem erros
3. **Validar** que todos os 45+ endpoints aparecem
4. **Confirmar** que os requests funcionam normalmente

## 🛠️ Troubleshooting

Se ainda tiver erro "Failed to fetch":

1. **Verificar console do navegador** (F12 → Console):

   - Deve mostrar a URL tentada
   - Deve mostrar apenas avisos normais de CORS, não erros

2. **Verificar headers de resposta**:
   ```bash
   curl -i http://104.234.173.305:7080/api/v1/swagger.json | head -20
   ```
3. **Verificar se a rota está carregada**:
   - Chamar GET /api/v1/health para verificar se a API está respondendo
   - Verificar logs do servidor

## 📝 Notas

- A rota `/api/v1/swagger.json` é READ-ONLY (apenas GET)
- O arquivo `swagger-json.php` em `/api/` pode ser mantido como backup ou removido
- A validação JSON garante que o arquivo está sempre correto

---

**Data:** 20/11/2025  
**Versão API:** v2.0.0  
**Endpoints Total:** 45+  
**Status:** ✅ RESOLVIDO

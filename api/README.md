# SAW API v1 - Documentação

## Base URL

```
http://seu-dominio/SAW-main/api/v1/
```

## Autenticação

Todas as rotas atualmente são públicas. Para adicionar autenticação JWT:

1. Criar middleware de autenticação em `middlewares/Auth.php`
2. Validar token no início de cada rota

## Endpoints

### ATENDIMENTOS

#### GET /atendimentos

Lista todos os atendimentos com filtros opcionais

**Parâmetros de Query:**

- `page` (int) - Página (default: 1)
- `perPage` (int) - Itens por página (default: 20, máx: 100)
- `situacao` (string) - Filtrar por situação (P, A, T, F)
- `canal` (int) - Filtrar por canal
- `numero` (string) - Filtrar por número
- `setor` (int) - Filtrar por setor

**Resposta:**

```json
{
  "status": "success",
  "message": "Atendimentos listados com sucesso",
  "data": [
    {
      "id": 1,
      "situacao": "A",
      "nome": "Cliente",
      "numero": "5521999999999",
      "dt_atend": "2025-11-19",
      "hr_atend": "10:30:00",
      "protocolo": "20251119103000"
    }
  ],
  "pagination": {
    "total": 100,
    "page": 1,
    "perPage": 20,
    "totalPages": 5
  },
  "timestamp": "2025-11-19 10:30:00"
}
```

#### POST /atendimentos

Cria novo atendimento

**Corpo da Requisição:**

```json
{
  "numero": "5521999999999",
  "nome": "Cliente Silva",
  "idAtende": 1,
  "nomeAtende": "João Atendente",
  "situacao": "P",
  "canal": 1,
  "setor": 1
}
```

**Resposta:**

```json
{
  "status": "success",
  "message": "Atendimento criado com sucesso",
  "data": {
    "id": 1,
    "situacao": "P",
    "nome": "Cliente Silva",
    "numero": "5521999999999",
    ...
  },
  "timestamp": "2025-11-19 10:30:00"
}
```

#### GET /atendimentos/ativos

Lista apenas atendimentos ativos (não finalizados)

**Parâmetros de Query:**

- `canal` (int) - Filtrar por canal
- `numero` (string) - Filtrar por número

#### GET /atendimentos/{id}?numero=...

Obtém um atendimento específico

**Parâmetros:**

- `id` (int) - ID do atendimento
- `numero` (string, query) - Número do cliente

#### PUT /atendimentos/{id}/situacao?numero=...

Atualiza a situação do atendimento

**Corpo:**

```json
{
  "situacao": "A"
}
```

#### PUT /atendimentos/{id}/setor?numero=...

Atualiza o setor do atendimento

**Corpo:**

```json
{
  "setor": 2
}
```

#### POST /atendimentos/{id}/finalizar?numero=...

Finaliza um atendimento

### MENSAGENS

#### GET /atendimentos/{id}/mensagens?numero=...&tipo=current

Lista mensagens de um atendimento

**Parâmetros:**

- `id` (int) - ID do atendimento
- `numero` (string, query) - Número do cliente
- `tipo` (string, query) - Tipo: 'current', 'all', 'att' (default: 'current')

#### POST /atendimentos/{id}/mensagens?numero=...

Cria nova mensagem

**Corpo:**

```json
{
  "numero": "5521999999999",
  "msg": "Olá, como posso ajudar?",
  "resp_msg": "",
  "id_atend": 1,
  "nome_chat": "João",
  "situacao": "E",
  "canal": 1,
  "chatid_resposta": null
}
```

#### GET /atendimentos/{id}/mensagens/pendentes

Lista mensagens pendentes (situação 'E')

**Parâmetros de Query:**

- `canal` (int) - Filtrar por canal

#### PUT /mensagens/{id}/situacao

Atualiza situação da mensagem

**Corpo:**

```json
{
  "situacao": "E"
}
```

#### PUT /mensagens/{id}/visualizar?numero=...

Marca mensagens como visualizadas

#### POST /mensagens/{id}/reacao

Adiciona reação a mensagem

**Corpo:**

```json
{
  "reacao": 0
}
```

**Reações disponíveis:**

- 0 = 👍
- 1 = ❤️
- 2 = 😂
- 3 = 😮
- 4 = 👏🏻
- 5 = 😁
- etc...

#### DELETE /mensagens/{id}

Deleta uma mensagem

### ANEXOS

#### POST /atendimentos/{id}/anexos

Cria novo anexo

**Corpo:**

```json
{
  "numero": "5521999999999",
  "seq": 1,
  "nomeArquivo": "documento.pdf",
  "nomeOriginal": "documento.pdf",
  "tipoArquivo": "DOCUMENT",
  "arquivo": "base64_encoded_content",
  "canal": 1,
  "enviado": 1
}
```

### PARÂMETROS

#### GET /parametros

Obtém todos os parâmetros do sistema

#### PUT /parametros/{id}

Atualiza parâmetros

**Corpo:**

```json
{
  "usar_protocolo": 1,
  "nome_atendente": 1,
  "departamento_atendente": 1
}
```

### MENUS

#### GET /menus

Lista menus principais

#### GET /menus/{id}

Obtém menu específico com seus submenus

#### GET /menus/{id}/resposta-automatica

Obtém resposta automática configurada para o menu

#### GET /menus/submenus/{idPai}

Lista submenus de um menu pai

### HORÁRIOS

#### GET /horarios/funcionamento

Obtém horários de funcionamento

**Parâmetros de Query:**

- `dia` (int) - Dia da semana (0-6, onde 0=domingo)

#### GET /horarios/aberto

Verifica se o atendimento está aberto

**Resposta:**

```json
{
  "status": "success",
  "message": "Status verificado com sucesso",
  "data": {
    "aberto": true
  },
  "timestamp": "2025-11-19 10:30:00"
}
```

## Códigos de Erro

- `200` - Sucesso
- `201` - Criado com sucesso
- `400` - Erro de validação
- `401` - Não autorizado
- `403` - Acesso proibido
- `404` - Não encontrado
- `409` - Conflito (ex: atendimento já existe)
- `500` - Erro interno do servidor

## Exemplo de Requisição (cURL)

```bash
# Criar atendimento
curl -X POST http://localhost/SAW-main/api/v1/atendimentos \
  -H "Content-Type: application/json" \
  -d '{
    "numero": "5521999999999",
    "nome": "Cliente",
    "idAtende": 1,
    "nomeAtende": "João"
  }'

# Listar atendimentos
curl -X GET "http://localhost/SAW-main/api/v1/atendimentos?page=1&perPage=10"

# Criar mensagem
curl -X POST http://localhost/SAW-main/api/v1/atendimentos/1/mensagens \
  -H "Content-Type: application/json" \
  -d '{
    "numero": "5521999999999",
    "msg": "Olá!"
  }'
```

## Próximas Implementações

1. **Autenticação JWT** - Adicionar segurança aos endpoints
2. **Rate Limiting** - Limitar requisições por IP
3. **Cache** - Implementar cache para queries frequentes
4. **Logging** - Log detalhado de todas as operações
5. **Validações** - Validações mais rigorosas
6. **Testes Automatizados** - Suite de testes
7. **Documentação Swagger** - OpenAPI/Swagger
8. **WebSocket** - Notificações em tempo real

## Testando a API

Abra no navegador ou use Postman:

```
GET http://localhost/SAW-main/api/v1/
```

Deve retornar:

```json
{
  "status": "success",
  "message": "API funcionando corretamente",
  "data": {
    "api": "SAW API",
    "version": "1.0",
    "status": "running",
    "timestamp": "2025-11-19 10:30:00"
  },
  "timestamp": "2025-11-19 10:30:00"
}
```

---

**Data:** 19/11/2025  
**Versão:** 1.0  
**Status:** ✅ Funcionando

# Guia de Teste - 32 Novos Endpoints

**Data:** 19/11/2025
**Total de Endpoints:** 32
**Controllers:** 9

---

## 🔐 Autenticação (Requisito Básico)

Antes de testar qualquer endpoint, obtenha um token JWT:

### 1. Login

```
POST /api/v1/auth/login
Content-Type: application/json

{
  "login": "usuario",
  "senha": "senha"
}

Resposta:
{
  "sucesso": true,
  "dados": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "usuario": {
      "id": 1,
      "login": "usuario",
      "nome": "Nome do Usuário"
    }
  }
}
```

Copie o `token` para usar nos testes.

---

## 📊 Testes por Categoria

### CONTATOS (2 Endpoints)

#### Q1: Exportar Contatos

```
POST /api/v1/contatos/exportar
Content-Type: application/json
Authorization: Bearer [seu_token]

{
  "pagina": 1,
  "limite": 20,
  "filtro": ""
}

Resposta Esperada:
{
  "sucesso": true,
  "mensagem": "Contatos exportados",
  "dados": {
    "total": 150,
    "pagina": 1,
    "limite": 20,
    "contatos": [
      {
        "id": 1,
        "nome": "João Silva",
        "telefone": "11999999999",
        "email": "joao@email.com"
      }
    ]
  }
}
```

#### Q7: Buscar Nome por Telefone

```
GET /api/v1/contatos/buscar-nome?numero=11999999999
Authorization: Bearer [seu_token]

Resposta Esperada:
{
  "sucesso": true,
  "dados": {
    "nome": "João Silva",
    "numero": "11999999999"
  }
}
```

---

### AGENDAMENTOS (1 Endpoint)

#### Q2: Mensagens Pendentes

```
GET /api/v1/agendamentos/pendentes?canal=1
Authorization: Bearer [seu_token]

Resposta Esperada:
{
  "sucesso": true,
  "mensagem": "Agendamentos pendentes",
  "dados": {
    "agendamentos": [
      {
        "id": 1,
        "login": "11999999999",
        "nome": "João",
        "situacao": "P",
        "data_criacao": "2025-11-19 10:30:00"
      }
    ]
  }
}
```

---

### ATENDIMENTOS (6 Endpoints)

#### Q3: Verificar Pendente

```
GET /api/v1/atendimentos/verificar-pendente?numero=11999999999&canal=WhatsApp
Authorization: Bearer [seu_token]

Resposta Esperada:
{
  "sucesso": true,
  "dados": {
    "existe": true,
    "atendimento": {
      "id": 456,
      "login": "11999999999",
      "nome": "João Silva",
      "situacao": "A"
    }
  }
}
```

#### P2: Criar Atendimento

```
POST /api/v1/atendimentos/criar
Content-Type: application/json
Authorization: Bearer [seu_token]

{
  "numero": "11988888888",
  "nome": "Maria Silva",
  "situacao": "P",
  "canal": "WhatsApp"
}

Resposta Esperada:
{
  "sucesso": true,
  "mensagem": "Atendimento criado",
  "dados": {
    "id": 457
  },
  "status_code": 201
}
```

#### P1: Finalizar Atendimento

```
PUT /api/v1/atendimentos/finalizar
Content-Type: application/json
Authorization: Bearer [seu_token]

{
  "id_atendimento": 457,
  "numero": "11988888888",
  "canal": "WhatsApp"
}

Resposta Esperada:
{
  "sucesso": true,
  "mensagem": "Atendimento finalizado"
}
```

#### P3: Gravar Mensagem

```
POST /api/v1/atendimentos/gravar-mensagem
Content-Type: multipart/form-data
Authorization: Bearer [seu_token]

Form Data:
- id_atendimento: 457
- mensagem: "Olá, como posso ajudar?"
- tipo_arquivo: audio/mp3
- arquivo: [selecionar arquivo]

Resposta Esperada:
{
  "sucesso": true,
  "mensagem": "Mensagem registrada",
  "status_code": 201
}
```

#### P8: Atualizar Setor

```
PUT /api/v1/atendimentos/atualizar-setor
Content-Type: application/json
Authorization: Bearer [seu_token]

{
  "id_atendimento": 457,
  "setor": "Suporte"
}

Resposta Esperada:
{
  "sucesso": true,
  "mensagem": "Setor atualizado"
}
```

#### Q16: Atendimentos Inativos

```
GET /api/v1/atendimentos/inativos?tempo_minutos=5
Authorization: Bearer [seu_token]

Resposta Esperada:
{
  "sucesso": true,
  "dados": {
    "inativos": [
      {
        "id": 450,
        "login": "11977777777",
        "nome": "Pedro",
        "situacao": "A"
      }
    ]
  }
}
```

---

### MENSAGENS (8 Endpoints)

#### Q6: Verificar Duplicada

```
GET /api/v1/mensagens/verificar-duplicada?chatid=msg_123456
Authorization: Bearer [seu_token]

Resposta Esperada:
{
  "sucesso": true,
  "dados": {
    "existe": false,
    "chatid": "msg_123456"
  }
}
```

#### Q8: Status Múltiplas

```
GET /api/v1/mensagens/status-multiplas?canal=WhatsApp
Authorization: Bearer [seu_token]

Resposta Esperada:
{
  "sucesso": true,
  "dados": {
    "mensagens": [
      {
        "id": 1,
        "mensagem": "Texto aqui",
        "situacao": "N",
        "data_msg": "2025-11-19 10:30:00"
      }
    ]
  }
}
```

#### Q13: Pendentes de Envio

```
GET /api/v1/mensagens/pendentes-envio?canal=WhatsApp
Authorization: Bearer [seu_token]

Resposta Esperada:
{
  "sucesso": true,
  "dados": {
    "mensagens": [
      {
        "id": 2,
        "mensagem": "Pendente de envio",
        "situacao": "E"
      }
    ]
  }
}
```

#### Q17: Próxima Sequência

```
GET /api/v1/mensagens/proxima-sequencia?id_atendimento=457&numero=11988888888
Authorization: Bearer [seu_token]

Resposta Esperada:
{
  "sucesso": true,
  "dados": {
    "seq": 5,
    "proxima": 6
  }
}
```

#### P5: Marcar Excluída

```
PUT /api/v1/mensagens/marcar-excluida
Content-Type: application/json
Authorization: Bearer [seu_token]

{
  "chatid": "msg_123456"
}

Resposta Esperada:
{
  "sucesso": true,
  "mensagem": "Mensagem marcada como excluída"
}
```

#### P6: Marcar Reação

```
PUT /api/v1/mensagens/marcar-reacao
Content-Type: application/json
Authorization: Bearer [seu_token]

{
  "chatid": "msg_123456",
  "reacao": "👍"
}

Resposta Esperada:
{
  "sucesso": true,
  "mensagem": "Reação marcada"
}
```

#### P4: Marcar Enviada

```
PUT /api/v1/mensagens/marcar-enviada
Content-Type: application/json
Authorization: Bearer [seu_token]

{
  "id_agendamento": 5,
  "enviado": true,
  "tempo_envio": 120
}

Resposta Esperada:
{
  "sucesso": true,
  "mensagem": "Mensagem marcada como enviada"
}
```

#### Q14: Comparar Duplicação

```
POST /api/v1/mensagens/comparar-duplicacao
Content-Type: application/json
Authorization: Bearer [seu_token]

{
  "id": 457,
  "seq_anterior": 4,
  "numero": "11988888888",
  "msg_atual": "Olá, como posso ajudar?"
}

Resposta Esperada:
{
  "sucesso": true,
  "dados": {
    "eh_duplicada": false,
    "msg_anterior": "Anterior"
  }
}
```

---

### PARÂMETROS (2 Endpoints)

#### Q10: Sistema

```
GET /api/v1/parametros/sistema
Authorization: Bearer [seu_token]

Resposta Esperada:
{
  "sucesso": true,
  "mensagem": "Parâmetros do sistema",
  "dados": {
    "id": 1,
    "parametro1": "valor1",
    "parametro2": "valor2"
  }
}
```

#### P9: Verificar Expediente

```
GET /api/v1/parametros/verificar-expediente
Authorization: Bearer [seu_token]

Resposta Esperada:
{
  "sucesso": true,
  "dados": {
    "esta_aberto": true,
    "hora_atual": "10:30:00",
    "dia_semana": 3
  }
}
```

---

### MENUS (2 Endpoints)

#### Q11: Principal

```
GET /api/v1/menus/principal
Authorization: Bearer [seu_token]

Resposta Esperada:
{
  "sucesso": true,
  "dados": {
    "menus": [
      {
        "id": 1,
        "nome": "Menu Principal",
        "descricao": "Primeiro menu",
        "pai": null
      }
    ]
  }
}
```

#### Q12: Submenus

```
GET /api/v1/menus/submenus
Authorization: Bearer [seu_token]

Resposta Esperada:
{
  "sucesso": true,
  "dados": {
    "submenus": [
      {
        "id": 2,
        "nome": "Submenu",
        "descricao": "Submenu do principal",
        "pai": 1
      }
    ]
  }
}
```

---

### RESPOSTAS AUTOMÁTICAS (1 Endpoint)

#### Q4: Buscar

```
GET /api/v1/respostas-automaticas?id_menu=1
Authorization: Bearer [seu_token]

Resposta Esperada:
{
  "sucesso": true,
  "mensagem": "Resposta encontrada",
  "dados": {
    "id": 1,
    "titulo": "Resposta Automática",
    "conteudo": "Texto da resposta"
  }
}
```

---

### DEPARTAMENTOS (1 Endpoint)

#### Q5: Por Menu

```
GET /api/v1/departamentos/por-menu?id_menu=1
Authorization: Bearer [seu_token]

Resposta Esperada:
{
  "sucesso": true,
  "mensagem": "Departamento encontrado",
  "dados": {
    "id": 1,
    "nome": "Departamento",
    "descricao": "Descrição"
  }
}
```

---

### AVISOS (4 Endpoints)

#### P7: Registrar

```
POST /api/v1/avisos/registrar-sem-expediente
Content-Type: application/json
Authorization: Bearer [seu_token]

{
  "numero": "11988888888",
  "mensagem": "Fora do horário de funcionamento"
}

Resposta Esperada:
{
  "sucesso": true,
  "mensagem": "Aviso registrado",
  "dados": {
    "id": 100
  },
  "status_code": 201
}
```

#### P11: Limpar Antigos

```
DELETE /api/v1/avisos/limpar-antigos
Authorization: Bearer [seu_token]

Resposta Esperada:
{
  "sucesso": true,
  "dados": {
    "rows_deleted": 5
  }
}
```

#### P14: Limpar Número

```
DELETE /api/v1/avisos/limpar-numero?numero=11988888888
Authorization: Bearer [seu_token]

Resposta Esperada:
{
  "sucesso": true,
  "dados": {
    "rows_deleted": 2
  }
}
```

#### P15: Verificar Existente

```
GET /api/v1/avisos/verificar-existente?numero=11988888888
Authorization: Bearer [seu_token]

Resposta Esperada:
{
  "sucesso": true,
  "dados": {
    "existe": true,
    "resultado": "1"
  }
}
```

---

## 🧪 Teste Rápido (Curl)

```bash
# Teste de Login
curl -X POST http://104.234.173.105:7080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"login":"usuario","senha":"senha"}'

# Teste de Parametros/Sistema
curl -X GET http://104.234.173.105:7080/api/v1/parametros/sistema \
  -H "Authorization: Bearer SEU_TOKEN"

# Teste de Criar Atendimento
curl -X POST http://104.234.173.105:7080/api/v1/atendimentos/criar \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN" \
  -d '{"numero":"11988888888","nome":"Maria","situacao":"P"}'
```

---

## ✅ Checklist de Validação

Para cada endpoint testado, verifique:

- [ ] Status HTTP correto (200, 201, 400, 500)
- [ ] Campo `sucesso` presente (true/false)
- [ ] Campo `mensagem` descritiva
- [ ] Campo `dados` com informações corretas
- [ ] Tratamento de erros funcional
- [ ] Validação de entrada funcionando
- [ ] Token JWT validado
- [ ] Resposta em formato JSON válido

---

## 🐛 Troubleshooting

| Problema            | Solução                                                                            |
| ------------------- | ---------------------------------------------------------------------------------- |
| 401 Unauthorized    | Verifique se o token JWT é válido e está no header `Authorization: Bearer [token]` |
| 404 Not Found       | Verifique o caminho da rota e o método HTTP (GET/POST/PUT/DELETE)                  |
| 400 Bad Request     | Verifique se os parâmetros obrigatórios estão presentes                            |
| 500 Internal Server | Verifique os logs da API e confirme se as tabelas existem no banco                 |
| Resposta vazia      | Verifique se há dados no banco para a consulta                                     |

---

## 📝 Notas Importantes

1. **Substitua [seu_token]** pelo token JWT obtido no login
2. **Substitua [seu_usuario]** pelo usuário real
3. **Substitua valores de exemplo** por dados reais do seu banco
4. **Teste em desenvolvimento primeiro** antes de usar em produção
5. **Ative logging** para rastrear problemas

---

**Testes Prontos! ✅**

# 📮 Guia - Coleção Postman SAW API (32 Endpoints)

**Data:** 20/11/2025  
**Status:** ✅ COMPLETO  
**Total de Requests:** 33 (1 login + 32 endpoints)

---

## 🚀 Importar a Coleção no Postman

### 1. Abra o Postman

- Clique em **Collections** (lado esquerdo)
- Clique em **Import**

### 2. Importar o Arquivo

- Selecione **SAW_API_32_Endpoints.postman_collection.json**
- Clique em **Import**

### 3. A coleção estará pronta para usar!

---

## 🔐 Configurar Variáveis

### Variáveis Automáticas na Coleção

A coleção inclui 2 variáveis:

```
base_url: http://104.234.173.105:7080/api/v1
token: SEU_TOKEN_JWT_AQUI
```

### Como Configurar

**Opção 1: No Postman (Collection Variables)**

1. Clique na coleção **SAW API - 32 Novos Endpoints**
2. Abra a aba **Variables**
3. Configure:
   - `base_url`: http://104.234.173.105:7080/api/v1
   - `token`: Deixe vazio (será preenchido após login)

**Opção 2: Environment**

1. Clique em **Environments** (lado esquerdo)
2. Clique em **Create New Environment**
3. Nome: **SAW API**
4. Adicione:
   ```
   base_url: http://104.234.173.105:7080/api/v1
   token:
   usuario: admin
   senha: 123456
   ```

---

## 🔑 Fazer Login Primeiro

### Passo 1: Login

1. Expanda a coleção
2. Vá para **1. Autenticação** → **Login**
3. Ajuste o username/password se necessário:
   ```json
   {
     "login": "seu_usuario",
     "senha": "sua_senha"
   }
   ```
4. Clique em **Send**

### Passo 2: Copiar o Token

Na resposta, você receberá:

```json
{
  "sucesso": true,
  "dados": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "refresh_token": "...",
    "usuario": {...}
  }
}
```

### Passo 3: Salvar o Token

1. Copie o valor de `token`
2. Vá para **Collection Variables** (ou Environment)
3. Paste em `token`
4. Clique em **Save**

---

## 📋 Estrutura da Coleção

A coleção está organizada em 10 pastas:

```
SAW API - 32 Novos Endpoints
├── 1. Autenticação (1)
├── 2. Contatos (2)
├── 3. Agendamentos (1)
├── 4. Atendimentos (6)
├── 5. Mensagens (8)
├── 6. Parâmetros (2)
├── 7. Menus (2)
├── 8. Respostas Automáticas (1)
├── 9. Departamentos (1)
└── 10. Avisos (4)

Total: 32 Endpoints
```

---

## 🧪 Testar os Endpoints

### Exemplo 1: Testar Contatos

1. Abra **2. Contatos** → **Exportar Contatos**
2. Clique em **Send**
3. Verá a resposta:

```json
{
  "sucesso": true,
  "mensagem": "Contatos exportados",
  "dados": {
    "contatos": [...]
  }
}
```

### Exemplo 2: Criar Atendimento

1. Abra **4. Atendimentos** → **Criar Atendimento**
2. Na aba **Body**, edite o JSON:

```json
{
  "numero": "11988888888",
  "nome": "Seu Nome",
  "situacao": "P",
  "canal": "WhatsApp"
}
```

3. Clique em **Send**

### Exemplo 3: Upload de Arquivo

1. Abra **4. Atendimentos** → **Gravar Mensagem Atendimento**
2. Vá para aba **Body**
3. Selecione **form-data**
4. Preencha:
   - `id_atendimento`: 123
   - `mensagem`: Seu texto
   - `arquivo`: Clique em **Select Files** (lado direito)
5. Clique em **Send**

---

## 🔄 Fluxo de Teste Recomendado

### Teste Básico (5 min)

1. ✅ Login
2. ✅ Parametros do Sistema
3. ✅ Menu Principal
4. ✅ Exportar Contatos
5. ✅ Listar Agendamentos

### Teste de Atendimento (10 min)

1. ✅ Verificar Atendimento Pendente
2. ✅ Criar Atendimento
3. ✅ Gravar Mensagem
4. ✅ Atualizar Setor
5. ✅ Finalizar Atendimento

### Teste de Mensagens (10 min)

1. ✅ Verificar Duplicada
2. ✅ Próxima Sequência
3. ✅ Status Múltiplas
4. ✅ Pendentes Envio
5. ✅ Marcar Enviada

### Teste de Avisos (5 min)

1. ✅ Registrar Aviso
2. ✅ Verificar Existente
3. ✅ Limpar Avisos

---

## 🐛 Troubleshooting

| Erro                    | Solução                                    |
| ----------------------- | ------------------------------------------ |
| **401 Unauthorized**    | Token expirado. Faça login novamente       |
| **400 Bad Request**     | Verifique parâmetros obrigatórios no Body  |
| **404 Not Found**       | Verifique se a URL está correta            |
| **500 Internal Server** | Erro no servidor. Verifique banco de dados |

---

## 💡 Dicas Úteis

### 1. Pre-request Script (Opcional)

Para renovar automaticamente o token:

```javascript
// Pre-request Script
if (pm.variables.get("token_expiry") < new Date()) {
  pm.sendRequest(
    {
      url: pm.variables.get("base_url") + "/auth/refresh",
      method: "POST",
      header: {
        Authorization: "Bearer " + pm.variables.get("token"),
      },
    },
    (err, response) => {
      pm.variables.set("token", response.json().data.token);
    }
  );
}
```

### 2. Tests (Validação Automática)

Adicione scripts para validar respostas:

```javascript
// Tests
pm.test("Status é 200", function () {
  pm.response.to.have.status(200);
});

pm.test("Resposta tem sucesso", function () {
  var jsonData = pm.response.json();
  pm.expect(jsonData.sucesso).to.equal(true);
});
```

### 3. Collection Runner

Para testar múltiplos requests:

1. Clique em **Collection** → **Run**
2. Selecione os requests
3. Clique em **Run SAW API**

---

## 📊 Exemplo de Resposta

### Login

```json
{
  "sucesso": true,
  "dados": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "usuario": {
      "id": 1,
      "nome": "Admin",
      "email": "admin@example.com",
      "login": "admin"
    }
  }
}
```

### Criar Atendimento

```json
{
  "sucesso": true,
  "mensagem": "Atendimento criado",
  "dados": {
    "id": 456
  },
  "status_code": 201
}
```

### Erro

```json
{
  "sucesso": false,
  "mensagem": "Token inválido",
  "dados": null,
  "status_code": 401
}
```

---

## 🔗 Links Úteis

- **Documentação Completa:** DOCUMENTACAO_API_COMPLETA.md
- **Guia de Teste:** GUIA_TESTE_32_ENDPOINTS.md
- **Implementação:** IMPLEMENTACAO_COMPLETA_32_ENDPOINTS.md

---

## 📝 Checklist de Setup

- [ ] Importou a coleção no Postman
- [ ] Configurou base_url
- [ ] Fez login e copiou token
- [ ] Testou 1-2 endpoints
- [ ] Validou respostas

---

## ✅ Tudo Pronto!

Sua coleção Postman está 100% funcional com todos os 32 endpoints!

**Próximos passos:**

1. Use para testar em QA
2. Documente casos de teste
3. Integre em testes automatizados

---

**Coleção Criada em:** 20/11/2025  
**Formato:** Postman Collection v2.1.0  
**Status:** ✅ PRONTO PARA USO

**Divirta-se testando! 🚀**

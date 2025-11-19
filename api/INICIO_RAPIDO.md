# SAW API v1 - Guia Rápido de Início

## 📋 O que foi criado?

Uma **API RESTful em PHP puro** totalmente funcional para o SAW, baseada no relatório de acessos ao banco de dados. A API segue os padrões da aplicação existente e mantém a compatibilidade com PHP.

## 🗂️ Estrutura de Arquivos

```
api/
├── v1/
│   ├── index.php                    # Ponto de entrada da API
│   ├── config.php                   # Configurações
│   ├── Database.php                 # Classe de conexão
│   ├── Response.php                 # Classe de respostas padronizadas
│   ├── Router.php                   # Classe de roteamento
│   ├── .htaccess                    # Reescrita de URLs
│   ├── models/
│   │   ├── Atendimento.php          # Modelo de Atendimento
│   │   ├── Mensagem.php             # Modelo de Mensagem
│   │   ├── Anexo.php                # Modelo de Anexo
│   │   ├── Parametro.php            # Modelo de Parâmetro
│   │   ├── Menu.php                 # Modelo de Menu
│   │   └── Horario.php              # Modelo de Horário
│   ├── controllers/
│   │   ├── AtendimentoController.php # Controlador de Atendimentos
│   │   ├── MensagemController.php    # Controlador de Mensagens
│   │   ├── ParametroController.php   # Controlador de Parâmetros
│   │   ├── MenuController.php        # Controlador de Menus
│   │   └── HorarioController.php     # Controlador de Horários
│   └── middlewares/                 # (Futuro: autenticação, validação)
├── APIClient.php                    # Cliente PHP para integração
├── exemplos.php                     # Exemplos de uso
├── test.php                         # Testes automatizados
├── MIGRACAO.php                     # Guia de migração
└── README.md                        # Documentação completa
```

## 🚀 Como Usar

### 1. Verificar se a API está funcionando

**Browser:**

```
http://localhost/SAW-main/api/v1/
```

**cURL:**

```bash
curl http://localhost/SAW-main/api/v1/
```

**Resposta esperada:**

```json
{
  "status": "success",
  "message": "API funcionando corretamente",
  "data": {
    "api": "SAW API",
    "version": "1.0",
    "status": "running",
    "timestamp": "2025-11-19 10:30:00"
  }
}
```

### 2. Usar a API no seu código PHP

```php
<?php
// Importar cliente
require_once("api/APIClient.php");
$api = new APIClient();

try {
    // Criar atendimento
    $atendimento = $api->createAtendimento(
        '5521999999999',      // número
        'João Silva',         // nome
        1,                    // idAtende
        'Maria Atendente',    // nomeAtende
        'P',                  // situacao
        1,                    // canal
        1                     // setor
    );

    $idAtendimento = $atendimento['data']['id'];

    // Criar mensagem
    $mensagem = $api->createMensagem(
        $idAtendimento,
        '5521999999999',
        'Olá, como posso ajudar?'
    );

    // Listar mensagens
    $mensagens = $api->listMensagens($idAtendimento, '5521999999999');

} catch (Exception $e) {
    echo "Erro: " . $e->getMessage();
}
?>
```

### 3. Testar a API

```bash
# Executar testes
php api/test.php

# Ver exemplos
php api/exemplos.php
```

## 📊 Endpoints Principais

### Atendimentos

- `GET /atendimentos` - Lista atendimentos
- `POST /atendimentos` - Cria atendimento
- `GET /atendimentos/{id}` - Obtém atendimento
- `PUT /atendimentos/{id}/situacao` - Atualiza situação
- `POST /atendimentos/{id}/finalizar` - Finaliza

### Mensagens

- `GET /atendimentos/{id}/mensagens` - Lista mensagens
- `POST /atendimentos/{id}/mensagens` - Cria mensagem
- `DELETE /mensagens/{id}` - Deleta mensagem
- `POST /mensagens/{id}/reacao` - Adiciona reação

### Parâmetros

- `GET /parametros` - Obtém parâmetros
- `PUT /parametros/{id}` - Atualiza parâmetros

### Menus

- `GET /menus` - Lista menus
- `GET /menus/{id}` - Obtém menu

### Horários

- `GET /horarios/funcionamento` - Horários
- `GET /horarios/aberto` - Verifica se aberto

## 🔄 Como Migrar seu Código

### Antes (Código atual):

```php
$qry = mysqli_query($conexao, "SELECT * FROM tbatendimento WHERE situacao = 'A'");
while($row = mysqli_fetch_object($qry)) {
    echo $row->numero;
}
```

### Depois (Com API):

```php
$api = new APIClient();
$response = $api->listAtendimentosAtivos();
foreach($response['data'] as $atendimento) {
    echo $atendimento['numero'];
}
```

Ver `api/MIGRACAO.php` para mais exemplos.

## 🔐 Segurança

A API usa:

- **Prepared Statements** - Proteção contra SQL Injection
- **JSON Response** - Prevenção de XSS
- **CORS Headers** - Controle de acesso

Para adicionar mais segurança:

1. Implementar JWT em `api/v1/middlewares/Auth.php`
2. Rate limiting
3. Validações mais rigorosas

## 📈 Performance

A API é otimizada para:

- **Queries preparadas** - Reutilização de planos
- **Paginação** - Limita resultados
- **Transações** - Mantém integridade
- **Compressão** - Reduz payload

## 🧪 Testando Endpoints

### Com Postman:

1. Criar nova request
2. Método: GET
3. URL: `http://localhost/SAW-main/api/v1/atendimentos`
4. Send

### Com cURL:

```bash
# GET
curl http://localhost/SAW-main/api/v1/atendimentos

# POST
curl -X POST http://localhost/SAW-main/api/v1/atendimentos \
  -H "Content-Type: application/json" \
  -d '{"numero":"5521999999999","nome":"Cliente","idAtende":1,"nomeAtende":"Maria"}'

# PUT
curl -X PUT http://localhost/SAW-main/api/v1/atendimentos/1/situacao?numero=5521999999999 \
  -H "Content-Type: application/json" \
  -d '{"situacao":"A"}'

# DELETE
curl -X DELETE http://localhost/SAW-main/api/v1/mensagens/123
```

## ⚙️ Configuração

Editar `api/v1/config.php` para alterar:

- Credenciais do banco de dados
- URL base da API
- Encoding padrão

## 📝 Documentação Completa

Veja `api/README.md` para documentação detalhada de todos os endpoints.

## 🐛 Troubleshooting

### Erro 404

- Verificar se o .htaccess está habilitado
- Testar URL sem reescrita: `http://localhost/SAW-main/api/v1/index.php/atendimentos`

### Erro de Conexão

- Verificar credenciais em `api/v1/config.php`
- Verificar se MySQL está rodando
- Verificar firewall/rede

### Erro 500

- Verificar logs em `api/v1/logs/api_errors.log`
- Verificar permissões de pasta

## 🎯 Próximos Passos

1. ✅ **Atual**: API funcionando
2. 📋 **Próximo**: Implementar autenticação JWT
3. 📊 **Depois**: Adicionar endpoints faltantes
4. 🧪 **Então**: Testes de integração completos
5. 🚀 **Final**: Deploy em produção

## 📞 Suporte

Para dúvidas ou problemas:

1. Verificar documentação em `api/README.md`
2. Ver exemplos em `api/exemplos.php`
3. Executar testes com `php api/test.php`

## 📄 Arquivos Importante

| Arquivo             | Função                  |
| ------------------- | ----------------------- |
| `api/v1/index.php`  | Ponto de entrada        |
| `api/APIClient.php` | Cliente para usar a API |
| `api/README.md`     | Documentação completa   |
| `api/MIGRACAO.php`  | Guia de migração        |
| `api/exemplos.php`  | Exemplos de uso         |
| `api/test.php`      | Suite de testes         |

---

**API criada em:** 19/11/2025  
**Versão:** 1.0  
**Status:** ✅ Pronta para usar

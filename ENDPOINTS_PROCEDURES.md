# Endpoints de Procedures - Documentação Completa

## Introdução

Este documento descreve os 7 novos endpoints adicionados à SAW API para gerenciamento de procedures e sincronização de estrutura de banco de dados. Esses endpoints substituem as funções diretas de banco de dados do código Delphi original.

**Objetivo Principal:** Centralizar todas as operações de banco de dados na API REST, eliminando conexões diretas do Delphi ao MySQL.

---

## 📋 Sumário de Endpoints

| Método | Endpoint                         | Descrição                     | Requer Admin |
| ------ | -------------------------------- | ----------------------------- | ------------ |
| GET    | `/procedures/listar`             | Listar todas as procedures    | Não          |
| GET    | `/procedures/existe`             | Verificar se procedure existe | Não          |
| POST   | `/procedures/executar`           | Executar uma procedure        | Não          |
| POST   | `/procedures/criar`              | Criar nova procedure          | **SIM**      |
| POST   | `/procedures/droppar`            | Remover procedure             | **SIM**      |
| POST   | `/sql/executar`                  | Executar SQL arbitrário       | **SIM**      |
| POST   | `/tabelas/sincronizar-estrutura` | Sincronizar tabelas/colunas   | Não          |

---

## 🔍 Detalhes de Cada Endpoint

### 1. GET `/procedures/listar`

**Descrição:** Lista todas as procedures do banco de dados MySQL.

**Substitui:** Loop manual em Delphi verificando procedures.

**Autenticação:** Bearer Token (obrigatório)

**Parâmetros:** Nenhum

**Exemplo de Requisição:**

```bash
curl -X GET "http://104.234.173.105:7080/api/v1/procedures/listar" \
  -H "Authorization: Bearer SEU_TOKEN_JWT"
```

**Exemplo de Resposta (200 OK):**

```json
{
  "success": true,
  "data": [
    {
      "nome": "sprDashBoardAnoAtual",
      "banco": "saw_db"
    },
    {
      "nome": "sprDashBoardAtendimentosMensais",
      "banco": "saw_db"
    },
    {
      "nome": "sprFolhaPagamento",
      "banco": "saw_db"
    }
  ],
  "message": "3 procedures encontradas"
}
```

**Uso em Delphi (SAWAPIClient):**

```pascal
var
  LProcedures: TJSONValue;
begin
  LProcedures := FAPIClient.ListarProcedures;
  // Processar LProcedures...
end;
```

---

### 2. GET `/procedures/existe`

**Descrição:** Verifica se uma procedure existe no banco de dados.

**Substitui:** `ProcedureExists(db, 'sprDashBoardAnoAtual')` do Delphi original

**Autenticação:** Bearer Token (obrigatório)

**Parâmetros:**

- `nome` (query string, obrigatório): Nome da procedure a verificar

**Exemplo de Requisição:**

```bash
curl -X GET "http://104.234.173.105:7080/api/v1/procedures/existe?nome=sprDashBoardAnoAtual" \
  -H "Authorization: Bearer SEU_TOKEN_JWT"
```

**Exemplo de Resposta (200 OK):**

```json
{
  "success": true,
  "data": {
    "existe": true,
    "nome": "sprDashBoardAnoAtual"
  },
  "message": "Procedure encontrada"
}
```

**Exemplo de Resposta quando NÃO existe:**

```json
{
  "success": true,
  "data": {
    "existe": false,
    "nome": "sprProcedureQueNaoExiste"
  },
  "message": "Procedure não encontrada"
}
```

**Uso em Delphi (SAWAPIClient):**

```pascal
var
  LExiste: Boolean;
begin
  LExiste := FAPIClient.ProcedureExists('sprDashBoardAnoAtual');
  if not LExiste then
  begin
    // Criar a procedure
    FAPIClient.CriarProcedure('sprDashBoardAnoAtual', LSQL);
  end;
end;
```

---

### 3. POST `/procedures/executar`

**Descrição:** Executa uma procedure com parâmetros opcionais.

**Autenticação:** Bearer Token (obrigatório)

**Body (JSON):**

```json
{
  "nome": "sprNomeProcedure",
  "parametros": ["valor1", "valor2"]
}
```

**Parâmetros:**

- `nome` (string, obrigatório): Nome da procedure
- `parametros` (array, opcional): Array com valores dos parâmetros

**Exemplo de Requisição (sem parâmetros):**

```bash
curl -X POST "http://104.234.173.105:7080/api/v1/procedures/executar" \
  -H "Authorization: Bearer SEU_TOKEN_JWT" \
  -H "Content-Type: application/json" \
  -d '{"nome":"sprDashBoardAnoAtual"}'
```

**Exemplo de Requisição (com parâmetros):**

```bash
curl -X POST "http://104.234.173.105:7080/api/v1/procedures/executar" \
  -H "Authorization: Bearer SEU_TOKEN_JWT" \
  -H "Content-Type: application/json" \
  -d '{"nome":"sprFolhaPagamento","parametros":["2024","01"]}'
```

**Exemplo de Resposta (200 OK):**

```json
{
  "success": true,
  "data": {
    "resultado": "Dados processados com sucesso",
    "linhas_afetadas": 42
  },
  "message": "Procedure sprDashBoardAnoAtual executada"
}
```

**Uso em Delphi (SAWAPIClient):**

```pascal
var
  LParams: TArray<Variant>;
  LResult: TJSONValue;
begin
  SetLength(LParams, 2);
  LParams[0] := '2024';
  LParams[1] := '01';

  LResult := FAPIClient.ExecutarProcedure('sprFolhaPagamento', LParams);
  // Processar LResult...
end;
```

---

### 4. POST `/procedures/criar`

**Descrição:** Cria uma nova procedure no banco de dados.

**⚠️ Requer Admin:** SIM

**Autenticação:** Bearer Token com permissão admin (obrigatório)

**Body (JSON):**

```json
{
  "nome": "sprNovaProc",
  "sql": "CREATE PROCEDURE sprNovaProc() BEGIN SELECT 1; END"
}
```

**Parâmetros:**

- `nome` (string, obrigatório): Nome da procedure
- `sql` (string, obrigatório): Código SQL completo

**Exemplo de Requisição:**

```bash
curl -X POST "http://104.234.173.105:7080/api/v1/procedures/criar" \
  -H "Authorization: Bearer SEU_TOKEN_ADMIN" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "sprDashBoardAnoAtual",
    "sql": "CREATE PROCEDURE sprDashBoardAnoAtual() BEGIN SELECT COUNT(*) as total FROM tbatendimento WHERE YEAR(dt_criacao) = YEAR(NOW()); END"
  }'
```

**Exemplo de Resposta (200 OK):**

```json
{
  "success": true,
  "data": {
    "nome": "sprDashBoardAnoAtual",
    "mensagem": "Procedure criada com sucesso"
  },
  "message": "Procedure sprDashBoardAnoAtual criada"
}
```

**Exemplo de Resposta quando falha (já existe):**

```json
{
  "success": false,
  "data": null,
  "message": "Procedure já existe ou erro de sintaxe SQL"
}
```

**Uso em Delphi (SAWAPIClient):**

```pascal
var
  LSQL: string;
  LSucesso: Boolean;
begin
  LSQL := 'CREATE PROCEDURE sprDashBoardAnoAtual() BEGIN ' +
          'SELECT COUNT(*) as total FROM tbatendimento ' +
          'WHERE YEAR(dt_criacao) = YEAR(NOW()); END';

  LSucesso := FAPIClient.CriarProcedure('sprDashBoardAnoAtual', LSQL);
  if LSucesso then
    ShowMessage('Procedure criada com sucesso');
end;
```

---

### 5. POST `/procedures/droppar`

**Descrição:** Remove uma procedure do banco de dados.

**⚠️ Requer Admin:** SIM

**Autenticação:** Bearer Token com permissão admin (obrigatório)

**Body (JSON):**

```json
{
  "nome": "sprNomeAPagar"
}
```

**Parâmetros:**

- `nome` (string, obrigatório): Nome da procedure a remover

**Exemplo de Requisição:**

```bash
curl -X POST "http://104.234.173.105:7080/api/v1/procedures/droppar" \
  -H "Authorization: Bearer SEU_TOKEN_ADMIN" \
  -H "Content-Type: application/json" \
  -d '{"nome":"sprProcedureAntiga"}'
```

**Exemplo de Resposta (200 OK):**

```json
{
  "success": true,
  "data": {
    "nome": "sprProcedureAntiga",
    "status": "removida"
  },
  "message": "Procedure sprProcedureAntiga removida com sucesso"
}
```

**Uso em Delphi (SAWAPIClient):**

```pascal
var
  LSucesso: Boolean;
begin
  LSucesso := FAPIClient.RemoverProcedure('sprProcedureAntiga');
  if LSucesso then
    ShowMessage('Procedure removida');
end;
```

---

### 6. POST `/sql/executar`

**Descrição:** Executa código SQL arbitrário no banco de dados.

**⚠️ CUIDADO:** Endpoint poderoso - use com extrema cautela!

**⚠️ Requer Admin:** SIM

**Autenticação:** Bearer Token com permissão admin (obrigatório)

**Body (JSON):**

```json
{
  "sql": "UPDATE tbusuario SET em_almoco = 1 WHERE id = 123"
}
```

**Parâmetros:**

- `sql` (string, obrigatório): Código SQL a executar

**Proteções Integradas:**

- ✅ Bloqueia `DROP TABLE` em tabelas críticas (tbusuario, tbatendimento, etc)
- ✅ Requer autenticação admin
- ✅ Todas as operações são logadas

**Exemplo de Requisição:**

```bash
curl -X POST "http://104.234.173.105:7080/api/v1/sql/executar" \
  -H "Authorization: Bearer SEU_TOKEN_ADMIN" \
  -H "Content-Type: application/json" \
  -d '{"sql":"UPDATE tbusuario SET em_almoco = 1 WHERE id = 123"}'
```

**Exemplo de Resposta (200 OK):**

```json
{
  "success": true,
  "data": {
    "linhas_afetadas": 1,
    "sql_executado": "UPDATE tbusuario SET em_almoco = 1 WHERE id = 123"
  },
  "message": "SQL executado com sucesso"
}
```

**Uso em Delphi (SAWAPIClient):**

```pascal
var
  LSucesso: Boolean;
  LSQL: string;
begin
  LSQL := 'UPDATE tbusuario SET em_almoco = 1 WHERE id = 123';
  LSucesso := FAPIClient.ExecutarSQL(LSQL);
  if LSucesso then
    ShowMessage('SQL executado com sucesso');
end;
```

---

### 7. POST `/tabelas/sincronizar-estrutura`

**Descrição:** Sincroniza a estrutura de tabelas e colunas, criando-as se não existirem.

**Substitui:** Função `VerificaTabelaseColunas` do Delphi original

**Autenticação:** Bearer Token (obrigatório)

**Body (JSON):**

```json
{
  "tabela": "tbusuario",
  "colunas": [
    { "nome": "em_almoco", "tipo": "INT", "permite_null": true },
    { "nome": "msg_almoco", "tipo": "VARCHAR(255)", "permite_null": true }
  ],
  "sql_criacao": "CREATE TABLE IF NOT EXISTS tbusuario (...)",
  "criar_se_nao_existe": true
}
```

**Parâmetros:**

- `tabela` (string, obrigatório): Nome da tabela
- `colunas` (array, obrigatório): Array com definição das colunas
  - `nome` (string): Nome da coluna
  - `tipo` (string): Tipo de dado (INT, VARCHAR, etc)
  - `permite_null` (boolean): Se permite NULL
- `sql_criacao` (string, opcional): SQL para criar a tabela
- `criar_se_nao_existe` (boolean, default: true): Se deve criar tabela se não existir

**Exemplo de Requisição (criar tabela nova):**

```bash
curl -X POST "http://104.234.173.105:7080/api/v1/tabelas/sincronizar-estrutura" \
  -H "Authorization: Bearer SEU_TOKEN_JWT" \
  -H "Content-Type: application/json" \
  -d '{
    "tabela": "tbavisosemexpediente",
    "colunas": [
      {"nome": "id", "tipo": "INT AUTO_INCREMENT PRIMARY KEY", "permite_null": false},
      {"nome": "titulo", "tipo": "VARCHAR(255)", "permite_null": false},
      {"nome": "mensagem", "tipo": "LONGTEXT", "permite_null": false},
      {"nome": "dt_criacao", "tipo": "DATETIME DEFAULT CURRENT_TIMESTAMP", "permite_null": false}
    ],
    "sql_criacao": "CREATE TABLE IF NOT EXISTS tbavisosemexpediente (id INT AUTO_INCREMENT PRIMARY KEY, titulo VARCHAR(255) NOT NULL, mensagem LONGTEXT NOT NULL, dt_criacao DATETIME DEFAULT CURRENT_TIMESTAMP)",
    "criar_se_nao_existe": true
  }'
```

**Exemplo de Requisição (adicionar colunas):**

```bash
curl -X POST "http://104.234.173.105:7080/api/v1/tabelas/sincronizar-estrutura" \
  -H "Authorization: Bearer SEU_TOKEN_JWT" \
  -H "Content-Type: application/json" \
  -d '{
    "tabela": "tbusuario",
    "colunas": [
      {"nome": "em_almoco", "tipo": "INT", "permite_null": true},
      {"nome": "msg_almoco", "tipo": "VARCHAR(500)", "permite_null": true}
    ],
    "criar_se_nao_existe": false
  }'
```

**Exemplo de Resposta (200 OK):**

```json
{
  "success": true,
  "data": {
    "tabela": "tbusuario",
    "tabela_criada": false,
    "colunas_adicionadas": ["em_almoco", "msg_almoco"],
    "total": 2
  },
  "message": "Estrutura sincronizada com sucesso"
}
```

**Uso em Delphi (SAWAPIClient):**

```pascal
var
  LColunas: TJSONArray;
  LColuna1, LColuna2: TJSONObject;
  LResult: TJSONValue;
begin
  LColunas := TJSONArray.Create;

  LColuna1 := TJSONObject.Create;
  LColuna1.AddPair('nome', 'em_almoco');
  LColuna1.AddPair('tipo', 'INT');
  LColuna1.AddPair('permite_null', TJSONBool.Create(True));
  LColunas.Add(LColuna1);

  LColuna2 := TJSONObject.Create;
  LColuna2.AddPair('nome', 'msg_almoco');
  LColuna2.AddPair('tipo', 'VARCHAR(500)');
  LColuna2.AddPair('permite_null', TJSONBool.Create(True));
  LColunas.Add(LColuna2);

  LResult := FAPIClient.SincronizarEstrutura('tbusuario', LColunas);
  // Processar LResult...
end;
```

---

## 🔐 Autenticação

Todos os endpoints requerem um token Bearer JWT válido no header:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Obtenção do token:**

```bash
curl -X POST "http://104.234.173.105:7080/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"login":"seu_usuario","senha":"sua_senha"}'
```

---

## 📊 Casos de Uso

### Caso 1: Sincronização na Inicialização

Quando sua aplicação Delphi inicia, sincronize todas as tabelas necessárias:

```pascal
procedure TSUAApp.InicializarSincronizacao;
var
  LColunas: TJSONArray;
begin
  // Sincronizar tabela de avisos sem expediente
  LColunas := CriarColunasTbavisosemexpediente;
  FAPIClient.SincronizarEstrutura('tbavisosemexpediente', LColunas,
    LSQL_CREATE_TABLE, True);

  // Sincronizar colunas adicionais em tbusuario
  LColunas := CriarColunasUsuario;
  FAPIClient.SincronizarEstrutura('tbusuario', LColunas, '', False);

  // Criar/verificar procedures
  if not FAPIClient.ProcedureExists('sprDashBoardAnoAtual') then
    FAPIClient.CriarProcedure('sprDashBoardAnoAtual', LSQL_PROCEDURE);
end;
```

### Caso 2: Execução Dinâmica de Relatórios

```pascal
procedure TSUAApp.GerarRelatorioDash;
var
  LResult: TJSONValue;
begin
  LResult := FAPIClient.ExecutarProcedure('sprDashBoardAnoAtual', []);
  // Processar e exibir resultados...
end;
```

### Caso 3: Manutenção Administrativa

```pascal
procedure TSUAApp.AdministracaoProcedures;
begin
  // Listar todas as procedures
  var LProcedures := FAPIClient.ListarProcedures;

  // Remover procedure antiga
  if FAPIClient.ProcedureExists('sprProcedureAntiga') then
    FAPIClient.RemoverProcedure('sprProcedureAntiga');

  // Criar nova versão
  FAPIClient.CriarProcedure('sprProcedureAntiga', LSQL_NOVA_VERSAO);
end;
```

---

## ⚠️ Boas Práticas

1. **Sempre verificar autenticação** antes de usar endpoints ADMIN
2. **Sincronizar estrutura na inicialização** para garantir consistência
3. **Usar SincronizarEstrutura** em vez de criar manualmente
4. **Nunca executar SQL arbitrário** diretamente em produção
5. **Fazer backup** antes de operações ADMIN em produção
6. **Logar todas as operações** para auditoria

---

## 🐛 Troubleshooting

| Problema         | Solução                                 |
| ---------------- | --------------------------------------- |
| 401 Unauthorized | Token expirado - refaça login           |
| 403 Forbidden    | Usuário não é admin para operação       |
| 400 Bad Request  | JSON malformado ou parâmetros inválidos |
| 500 Server Error | Verifique logs do servidor PHP          |

---

## 📝 Referências Rápidas

**Classes SAWAPIClient usadas:**

- `ListarProcedures(): TJSONValue`
- `ProcedureExists(ANome: string): Boolean`
- `ExecutarProcedure(ANome: string; AParametros: TArray<Variant>): TJSONValue`
- `CriarProcedure(ANome, ASQL: string): Boolean`
- `RemoverProcedure(ANome: string): Boolean`
- `ExecutarSQL(ASQL: string): Boolean`
- `SincronizarEstrutura(ANomeTabela: string; AColunas: TJSONArray; ...): TJSONValue`

---

Documento gerado automaticamente - Última atualização: 2025

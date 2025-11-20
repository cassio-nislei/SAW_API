# 📋 Endpoints para VerificaStatusMessage_Mult

## Resumo

Criados **4 endpoints** que substituem a funcionalidade de `VerificaStatusMessage_Mult` do Delphi original. O fluxo agora é:

1. **Delphi chama GET `/mensagens/pendentes-status`** → Obtém lista de mensagens
2. **Delphi processa com WPPConnect** → Verifica status via WPPConnect.getMessageById()
3. **Delphi chama POST `/mensagens/status/atualizar` ou POST `/mensagens/status/processar-mult`** → Sincroniza status no banco

---

## Endpoints Criados

### 1️⃣ GET `/api/v1/mensagens/pendentes-status`

**Descrição:** Lista mensagens pendentes de verificação de status

**Parâmetros (Query String):**

- `canal` (obrigatório): Canal de atendimento (ex: `whatsapp`)
- `horas_atras` (opcional, padrão: 24): Quantidade de horas para buscar
- `minutos_futuros` (opcional, padrão: 10): Minutos para frente

**Exemplo de Requisição:**

```bash
GET http://104.234.173.105:7080/api/v1/mensagens/pendentes-status?canal=whatsapp&horas_atras=24&minutos_futuros=10
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": [
    {
      "id_msg": 1,
      "chatid": "5585987654321@c.us",
      "dt_msg": "2025-11-20 15:30:45",
      "id_atend": 123,
      "situacao": "N",
      "status_msg": 1,
      "canal": "whatsapp"
    },
    {
      "id_msg": 2,
      "chatid": "5585987654321@c.us",
      "dt_msg": "2025-11-20 14:25:30",
      "id_atend": 124,
      "situacao": "N",
      "status_msg": 1,
      "canal": "whatsapp"
    }
  ],
  "count": 2,
  "message": "2 mensagens encontradas para verificação"
}
```

---

### 2️⃣ POST `/api/v1/mensagens/status/atualizar`

**Descrição:** Atualiza o status de UMA mensagem após WPPConnect verificar

**Body (JSON):**

```json
{
  "id_msg": 1,
  "chatid": "5585987654321@c.us",
  "novo_status": 2
}
```

**Status Válidos:**

- `0`: Pendente
- `1`: Enviada
- `2`: Entregue
- `3`: Lida
- `4`: Erro

**Exemplo de Requisição:**

```bash
curl -X POST http://104.234.173.105:7080/api/v1/mensagens/status/atualizar \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"id_msg": 1, "chatid": "5585987654321@c.us", "novo_status": 2}'
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "id_msg": 1,
    "status_anterior": 1,
    "status_novo": 2,
    "atualizado_em": "2025-11-20 15:36:00"
  },
  "message": "Status atualizado com sucesso"
}
```

---

### 3️⃣ POST `/api/v1/mensagens/status/processar-mult`

**Descrição:** Atualiza MÚLTIPLAS mensagens de uma vez em lote

**Body (JSON):**

```json
{
  "atualizacoes": [
    {
      "id_msg": 1,
      "chatid": "5585987654321@c.us",
      "novo_status": 2
    },
    {
      "id_msg": 2,
      "chatid": "5585987654321@c.us",
      "novo_status": 3
    },
    {
      "id_msg": 3,
      "chatid": "5585987654322@c.us",
      "novo_status": 2
    }
  ]
}
```

**Exemplo de Requisição:**

```bash
curl -X POST http://104.234.173.105:7080/api/v1/mensagens/status/processar-mult \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d @atualizacoes.json
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "processadas": 3,
    "atualizadas": 3,
    "erros": 0,
    "detalhes": [
      {
        "id_msg": 1,
        "status_novo": 2,
        "sucesso": true
      },
      {
        "id_msg": 2,
        "status_novo": 3,
        "sucesso": true
      },
      {
        "id_msg": 3,
        "status_novo": 2,
        "sucesso": true
      }
    ]
  }
}
```

---

### 4️⃣ GET `/api/v1/mensagens/status/relatorio`

**Descrição:** Gera relatório de mensagens agrupadas por status

**Parâmetros (Query String):**

- `canal` (obrigatório): Canal de atendimento
- `data_ini` (opcional, padrão: 7 dias atrás): Data inicial (formato: YYYY-MM-DD)
- `data_fim` (opcional, padrão: hoje): Data final (formato: YYYY-MM-DD)

**Exemplo de Requisição:**

```bash
GET http://104.234.173.105:7080/api/v1/mensagens/status/relatorio?canal=whatsapp&data_ini=2025-11-13&data_fim=2025-11-20
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "total": 100,
    "por_status": {
      "0": 10,
      "1": 30,
      "2": 45,
      "3": 15
    },
    "pendentes": 10,
    "enviadas": 30,
    "entregues": 45,
    "lidas": 15,
    "periodo": {
      "inicio": "2025-11-13",
      "fim": "2025-11-20"
    }
  }
}
```

---

## 📱 Exemplo de Uso no Delphi

### Substituição de `VerificaStatusMessage_Mult`

**Código Original (Delphi):**

```pascal
procedure TfrmPrincipal.VerificaStatusMessage_Mult;
begin
  // ... conexão ao banco ...
  QRYMSGRETORNO.SQL.Text := ' SELECT * FROM tbmsgatendimento WHERE ...';
  QRYMSGRETORNO.Open;

  while not QRYMSGRETORNO.eof do
  begin
    WPPConnect1.getMessageById(QRYMSGRETORNO.FieldByName('chatid').AsString);
    sleepNoFreeze(2000);
    QRYMSGRETORNO.Next;
  end;
end;
```

**Código Novo (usando API):**

```pascal
procedure TfrmPrincipal.VerificaStatusMessage_Mult;
var
  API: TSAWAPIClient;
  ListaPendentes: TJSONValue;
  JSONArray: TJSONArray;
  JSONObject: TJSONObject;
  I: Integer;
  IdMsg, NovoStatus: Integer;
  ChatID: string;
  Atualizacoes: TJSONArray;
begin
  API := TSAWAPIClient.Create('admin', '123456');
  try
    // 1. Obter lista de mensagens pendentes
    ListaPendentes := API.ListarMensagensStatusPendentes('whatsapp', 24, 10);

    if Assigned(ListaPendentes) then
    begin
      JSONArray := TJSONArray(TJSONObject(ListaPendentes).GetValue('data'));
      Atualizacoes := TJSONArray.Create;

      // 2. Processar cada mensagem com WPPConnect
      for I := 0 to JSONArray.Count - 1 do
      begin
        JSONObject := TJSONObject(JSONArray.Items[I]);

        IdMsg := JSONObject.GetValue('id_msg').GetValue<Integer>;
        ChatID := JSONObject.GetValue('chatid').GetValue<string>;

        // Verificar status via WPPConnect
        NovoStatus := WPPConnect1.getMessageById(ChatID); // Seu código WPPConnect

        // Adicionar à lista de atualizações
        JSONObject := TJSONObject.Create;
        JSONObject.AddPair('id_msg', TJSONNumber.Create(IdMsg));
        JSONObject.AddPair('chatid', ChatID);
        JSONObject.AddPair('novo_status', TJSONNumber.Create(NovoStatus));
        Atualizacoes.Add(JSONObject);

        sleepNoFreeze(2000);
      end;

      // 3. Sincronizar todos os status de uma vez
      API.ProcessarMultiplasAtualizacoesStatus(Atualizacoes);
    end;
  finally
    API.Free;
  end;
end;
```

---

## 📝 Métodos do TSAWAPIClient

Adicionados 4 novos métodos:

### 1. ListarMensagensStatusPendentes

```pascal
function ListarMensagensStatusPendentes(const ACanal: string;
  AHorasAtras: Integer = 24; AMinutosFuturos: Integer = 10): TJSONValue;
```

### 2. AtualizarStatusMensagem

```pascal
function AtualizarStatusMensagem(AIdMsg: Integer;
  const AChatID: string; ANovoStatus: Integer): Boolean;
```

### 3. ProcessarMultiplasAtualizacoesStatus

```pascal
function ProcessarMultiplasAtualizacoesStatus(const AAtualizacoes: TJSONArray): TJSONValue;
```

### 4. ObterRelatorioStatusMensagens

```pascal
function ObterRelatorioStatusMensagens(const ACanal: string;
  ADataIni: TDate = 0; ADataFim: TDate = 0): TJSONValue;
```

---

## 🔄 Fluxo de Sincronização

```
┌─────────────────────────────────────────────────────┐
│ 1. Delphi chama GET /mensagens/pendentes-status    │
│    (Lista mensagens que precisam ser verificadas)   │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│ 2. Loop: Para cada mensagem na lista               │
│    - WPPConnect1.getMessageById(chatid)            │
│    - Aguarda 2 segundos (sleepNoFreeze)            │
│    - Obtém o status real da mensagem               │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│ 3. Monta array com todas as atualizações           │
│    [{id_msg, chatid, novo_status}, ...]            │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│ 4. Delphi chama POST /mensagens/status/            │
│    processar-mult com as atualizações              │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│ 5. API sincroniza todos os status no banco         │
│    em um UPDATE batch para melhor performance      │
└─────────────────────────────────────────────────────┘
```

---

## ✅ Vantagens da Solução

✅ **Separação de Responsabilidades**: API cuida do banco, Delphi cuida do WPPConnect  
✅ **Melhor Performance**: Batch update em vez de múltiplos UPDATE  
✅ **Sincronização Confiável**: Dados sempre sincronizados entre Delphi e API  
✅ **Fácil Manutenção**: Lógica centralizada na API  
✅ **Escalabilidade**: Suporta múltiplas verificações simultâneas  
✅ **Relatórios**: Endpoint extra para análise de status

---

## 🚀 Próximos Passos

1. Testar endpoints com Postman/Insomnia
2. Integrar no código Delphi
3. Monitorar logs em `/api/v1/logs/`
4. Configurar alertas para erros de sincronização

---

**Data:** 20/11/2025  
**Status:** ✅ COMPLETO  
**Endpoints:** 4 (GET + POST)  
**Métodos Delphi:** 4 novos

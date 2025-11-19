# 🔧 Guia Avançado de Troubleshooting - Delphi SAW API

## Problemas Comuns e Soluções

### 1. ERRO: "Cannot read property 'data' of null"

**Sintomas:**

```
Exception: Object reference not assigned to an instance
Mensagem: Cannot read property 'data'
```

**Diagnóstico:**
O servidor não está respondendo com JSON válido.

**Solução:**

1. **Verifique se Apache está rodando:**

```powershell
netstat -an | findstr :80
```

2. **Teste endpoint diretamente:**

```bash
curl http://localhost/SAW-main/api/v1/atendimentos
```

3. **Verifique logs do Apache:**

```
C:\Apache24\logs\error.log
C:\Apache24\logs\access.log
```

4. **Código corrigido:**

```delphi
var Response: TJSONObject;
begin
  Response := FManager.ListarAtendimentos;

  if not Assigned(Response) then
  begin
    Logar('Erro: ' + FManager.FAPI.LastError);
    Exit;
  end;

  try
    if Response.GetValue('status').Value = 'success' then
      Logar('Sucesso!');
  finally
    Response.Free; // IMPORTANTE: Sempre liberar
  end;
end;
```

---

### 2. ERRO: "Timeout na conexão"

**Sintomas:**

```
Operação levou mais de 30 segundos
Request timeout
```

**Diagnóstico:**
Servidor está lento ou não está respondendo.

**Solução:**

1. **Aumentar timeout no APIClient:**

```delphi
procedure TAPIClient.Create;
begin
  inherited Create;
  FHTTPClient := TIdHTTP.Create(nil);
  FHTTPClient.ConnectTimeout := 10000; // 10 segundos
  FHTTPClient.ReadTimeout := 30000;    // 30 segundos
end;
```

2. **Ou faça em thread para não travar UI:**

```delphi
procedure TForm1.CarregarEmThread;
var
  Thread: TThread;
begin
  Thread := TThread.CreateAnonymousThread(
    procedure
    var
      Manager: TManager_Atendimento;
    begin
      Manager := TManager_Atendimento.Create;
      try
        // Sua operação aqui
      finally
        Manager.Free;
      end;

      TThread.Synchronize(nil, procedure
      begin
        Logar('Carregado!');
      end);
    end
  );
  Thread.Start;
end;
```

3. **Verifique desempenho do servidor:**

```
Abra Task Manager → Processes
Procure por Apache (httpd.exe)
Verifique CPU e memória
```

---

### 3. ERRO: "Authentication required" (401)

**Sintomas:**

```
HTTP Status 401 Unauthorized
Acesso negado
```

**Diagnóstico:**
Você não tem permissão para acessar o endpoint.

**Solução:**

1. **Verifique credenciais (se usar autenticação):**

```delphi
var API: TAPIClient;
begin
  API := TAPIClient.Create;
  try
    // Adicionar header de autenticação
    API.FHTTP.Request.CustomHeaders.AddValue('Authorization', 'Bearer TOKEN_AQUI');
    API.Get('/atendimentos');
  finally
    API.Free;
  end;
end;
```

2. **Ou configure em APIClient.pas:**

```delphi
procedure TAPIClient.SetAuthToken(const Token: string);
begin
  FAuthToken := Token;
end;

function TAPIClient.Get(const Path: string): TJSONObject;
begin
  if FAuthToken <> '' then
    FHTTPClient.Request.CustomHeaders.AddValue('Authorization', 'Bearer ' + FAuthToken);
  Result := inherited Get(Path);
end;
```

---

### 4. ERRO: "JSON parsing failed"

**Sintomas:**

```
Erro ao fazer parsing de JSON
TJSONObject.Create falha
```

**Diagnóstico:**
Resposta não é JSON válido.

**Solução:**

1. **Debugar resposta:**

```delphi
procedure DebugResponse(const Response: string);
begin
  Memo1.Lines.Text := Response;

  // Salvar em arquivo para analisar
  var List := TStringList.Create;
  try
    List.Text := Response;
    List.SaveToFile('response.json');
  finally
    List.Free;
  end;
end;

var Manager: TManager_Atendimento;
    Response: string;
begin
  Manager := TManager_Atendimento.Create;
  try
    Response := Manager.FAPI.FHTTP.Get('/atendimentos');
    DebugResponse(Response);
  finally
    Manager.Free;
  end;
end;
```

2. **Validar JSON:**

```delphi
function IsValidJSON(const S: string): Boolean;
var
  JSONValue: TJSONValue;
begin
  try
    JSONValue := TJSONObject.ParseJSONValue(S);
    if Assigned(JSONValue) then
    begin
      JSONValue.Free;
      Result := True;
    end
    else
      Result := False;
  except
    Result := False;
  end;
end;

// Usar:
if IsValidJSON(Response) then
  JSONObj := TJSONObject.ParseJSONValue(Response) as TJSONObject
else
  ShowMessage('JSON inválido');
```

---

### 5. ERRO: "Empty response from server"

**Sintomas:**

```
Response is empty
Sem dados retornados
```

**Diagnóstico:**
O endpoint retorna vazio ou não existe.

**Solução:**

1. **Verificar endpoint:**

```bash
# Teste direto no navegador
http://localhost/SAW-main/api/v1/atendimentos
```

2. **Adicionar debug no APIClient:**

```delphi
function TAPIClient.Get(const Path: string): TJSONObject;
var
  Response: string;
begin
  try
    Response := FHTTPClient.Get(BuildURL(Path));

    // DEBUG
    if Response = '' then
    begin
      FLastError := 'Resposta vazia do servidor';
      Result := nil;
      Exit;
    end;

    Result := TJSONObject.ParseJSONValue(Response) as TJSONObject;
  except
    on E: Exception do
    begin
      FLastError := E.Message;
      Result := nil;
    end;
  end;
end;
```

3. **Verificar se dados existem:**

```delphi
var Manager: TManager_Atendimento;
    Response: TJSONObject;
begin
  Manager := TManager_Atendimento.Create;
  try
    Response := Manager.ListarAtendimentos;

    if Assigned(Response) then
    begin
      if Response.Get('data') <> nil then
        ShowMessage('Dados: ' + (Response.Get('data') as TJSONArray).Count.ToString)
      else
        ShowMessage('Campo "data" não existe na resposta');
    end;
  finally
    Response.Free;
    Manager.Free;
  end;
end;
```

---

### 6. ERRO: "Connection refused" (127.0.0.1:80)

**Sintomas:**

```
Cannot connect to 127.0.0.1:80
Connection refused
```

**Diagnóstico:**
Apache não está rodando.

**Solução:**

1. **Verificar serviço do Apache:**

```powershell
# No PowerShell como Admin:
Get-Service | findstr Apache

# Iniciar Apache
net start Apache2.4

# Parar Apache
net stop Apache2.4

# Verificar status
Get-Service Apache2.4 | Select-Object Status
```

2. **Ou use Apache Monitor:**

```
Iniciar → Apache HTTP Server → Monitor Apache Servers
Clique em botão verde (Start)
```

3. **Verificar se porta 80 está em uso:**

```powershell
netstat -ano | findstr :80

# Se houver outra aplicação:
taskkill /PID <PID> /F
```

---

### 7. ERRO: "Cannot find module 'System.JSON'"

**Sintomas:**

```
Unresolved forward declaration
System.JSON não encontrado
```

**Diagnóstico:**
Você está usando Delphi versão antiga (pré-2009).

**Solução:**

1. **Usar versão compatível:**

```delphi
// Para Delphi 2009+:
uses System.JSON;

// Para Delphi 7 e XE:
uses JSON; // ou use DBXJSON
```

2. **Ou use biblioteca de JSON alternativa:**

```delphi
uses uJSONUtils; // Usar unit custom para parse JSON
```

3. **Download da versão corrigida do APIClient.pas:**

```
Versão Delphi 7: DELPHI_APIClient_D7.pas
Versão Delphi 2009+: DELPHI_APIClient.pas (padrão)
```

---

### 8. ERRO: "TIdHTTP não declarado"

**Sintomas:**

```
Undeclared identifier 'TIdHTTP'
Indy não encontrado
```

**Diagnóstico:**
Indy não está instalado ou não está adicionado ao projeto.

**Solução:**

1. **Instalar Indy (Delphi 2009+):**

```
File → New → Other → Delphi Projects → Default
Procure por "Indy"
Indy Clients deve estar marcado
```

2. **Ou adicione manualmente:**

```delphi
uses
  IdHTTP,
  IdSSLOpenSSL;
```

3. **Se ainda falhar, criar wrapper customizado:**

```delphi
uses
  Windows, WinInet;

function SimpleGet(const URL: string): string;
var
  hSession, hConnect, hRequest: HINTERNET;
  Buffer: array[0..1023] of Char;
  BytesRead: DWORD;
begin
  hSession := InternetOpen(nil, INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  try
    hConnect := InternetOpenURL(hSession, PChar(URL), nil, 0, 0, 0);
    try
      repeat
        InternetReadFile(hConnect, @Buffer, SizeOf(Buffer), BytesRead);
        Result := Result + Copy(Buffer, 1, BytesRead);
      until BytesRead = 0;
    finally
      InternetCloseHandle(hConnect);
    end;
  finally
    InternetCloseHandle(hSession);
  end;
end;
```

---

### 9. ERRO: "Memory leak" / "Objeto não liberado"

**Sintomas:**

```
Object XXX still has xxx instance(s) in memory
FastMM detects memory leak
```

**Diagnóstico:**
Você está criando objetos e não liberando.

**Solução:**

1. **Sempre usar try/finally:**

```delphi
var Manager: TManager_Atendimento;
begin
  Manager := TManager_Atendimento.Create;
  try
    // Seu código
  finally
    Manager.Free; // IMPORTANTE!
  end;
end;
```

2. **Também liberar Response:**

```delphi
var Response: TJSONObject;
begin
  Response := Manager.ListarAtendimentos;
  try
    // Usar Response
  finally
    if Assigned(Response) then
      Response.Free;
  end;
end;
```

3. **Criar Destrutor customizado:**

```delphi
type
  TMyForm = class(TForm)
  private
    FManager: TManager_Atendimento;
  public
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  end;

implementation

procedure TMyForm.FormCreate(Sender: TObject);
begin
  FManager := TManager_Atendimento.Create;
end;

procedure TMyForm.FormDestroy(Sender: TObject);
begin
  FManager.Free;
end;
```

---

### 10. ERRO: "Performance lenta" / "Aplicação travando"

**Sintomas:**

```
UI fica travada ao carregar dados
Operações levam muito tempo
```

**Diagnóstico:**
Operações longas na thread principal.

**Solução:**

1. **Usar threads:**

```delphi
procedure TForm1.CarregarAtendimentosAsync;
begin
  TThread.CreateAnonymousThread(
    procedure
    var
      Manager: TManager_Atendimento;
      Response: TJSONObject;
    begin
      Manager := TManager_Atendimento.Create;
      try
        Response := Manager.ListarAtendimentos;
        try
          TThread.Synchronize(nil, procedure
          begin
            // Atualizar UI aqui
            PreencherGrid(Response);
          end);
        finally
          Response.Free;
        end;
      finally
        Manager.Free;
      end;
    end
  ).Start;
end;
```

2. **Implementar cache local:**

```delphi
type
  TAtendimentoCache = class
  private
    FCache: TDictionary<Integer, TJSONObject>;
    FLastUpdate: TDateTime;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Atualizar;
    function Obter(const ID: Integer): TJSONObject;
    function EstaVencido: Boolean;
  end;

constructor TAtendimentoCache.Create;
begin
  inherited;
  FCache := TDictionary<Integer, TJSONObject>.Create;
  FLastUpdate := 0;
end;

function TAtendimentoCache.EstaVencido: Boolean;
begin
  Result := Now - FLastUpdate > 1/24; // 1 hora
end;

procedure TAtendimentoCache.Atualizar;
var
  Manager: TManager_Atendimento;
  Response: TJSONObject;
begin
  if not EstaVencido then Exit;

  Manager := TManager_Atendimento.Create;
  try
    Response := Manager.ListarAtendimentos;
    // Processar e cachear
    FLastUpdate := Now;
  finally
    Manager.Free;
  end;
end;
```

3. **Usar pagination:**

```delphi
procedure TForm1.CarregarPaginado;
var
  Manager: TManager_Atendimento;
  Page: Integer;
begin
  Page := 1;
  repeat
    Response := Manager.ListarAtendimentos(Page, 50);
    // Processar 50 por vez
    Inc(Page);
  until JSONArray.Count < 50;
end;
```

---

## Checklist de Diagnóstico

```
☐ Apache está rodando?
  Verifique: Services (services.msc) ou Apache Monitor

☐ PHP está funcionando?
  Teste: http://localhost/info.php
  Verifique: phpinfo() na página

☐ Arquivos do SAW existem?
  Verifique: C:\Apache24\htdocs\SAW-main\

☐ Banco de dados está conectado?
  Verifique: includes/conexao.php
  Teste: SELECT COUNT(*) FROM atendimentos;

☐ API retorna JSON válido?
  Teste: http://localhost/SAW-main/api/swagger-ui.html
  Clique em um endpoint e veja a resposta

☐ Delphi tem Indy instalado?
  Verifique: IDE → Tools → Manage Packages
  Procure por Indy

☐ APIClient.pas está no projeto?
  Verifique: Project → View Project Source
  Procure por APIClient.pas

☐ Código usa try/finally?
  Revise: Todas as criações devem ter Free

☐ Resposta JSON não é vazia?
  Debugar: Salve response em arquivo
  Verifique: O conteúdo usando editor de texto
```

---

## Ferramentas de Debug

### 1. Debugar com PostMan/Insomnia

```
1. Download: https://www.postman.com/
2. Crie requisição GET para: http://localhost/SAW-main/api/v1/atendimentos
3. Verifique Status, Headers e Body
```

### 2. Debugar com Swagger UI

```
Abra: http://localhost/SAW-main/api/swagger-ui.html
Clique em endpoint
Clique em "Try it out"
Veja requisição e resposta
```

### 3. Debugar com Browser Console

```
F12 → Network → Limpar
Recarregue página
Verifique requisições para API
Veja erros em Console
```

### 4. Debugar com Fiddler

```
1. Download: https://www.telerik.com/fiddler
2. Capture requisições HTTP
3. Analise Headers e Body
```

---

## Performance - Tips & Tricks

### 1. Use Connection Pool

```delphi
type
  TAPIConnectionPool = class
  private
    FConnections: TList;
  public
    function Get: TAPIClient;
    procedure Return(AClient: TAPIClient);
  end;
```

### 2. Implemente Batch Operations

```delphi
// Em vez de chamar 100x:
for I := 0 to 99 do
  Manager.CriarMensagem(...)

// Use um endpoint batch:
Manager.CriarMulasMensagens(ArrayOfMessages);
```

### 3. Compressão HTTP

```delphi
FHTTPClient.Request.CustomHeaders.AddValue('Accept-Encoding', 'gzip');
```

### 4. Cache Agressivo

```delphi
// Cachear 1 hora
if Now - FLastUpdate < (1/24) then
  Exit;
```

---

## Quando Contactar Suporte

1. **Erro não listado aqui?**

   - Copie a mensagem de erro
   - Abra comando como Admin
   - Copie conteúdo de C:\Apache24\logs\error.log
   - Envie para suporte

2. **Desempenho ruim?**

   - Qual versão do Delphi?
   - Quantos registros você está carregando?
   - Quantas requisições por segundo?

3. **Problema de dados?**
   - Teste em Swagger UI primeiro
   - Copie a resposta JSON
   - Teste mesma operação em APIClient

---

**Última atualização:** 19/11/2025  
**Versão:** 1.0.0  
**Status:** ✅ Completo

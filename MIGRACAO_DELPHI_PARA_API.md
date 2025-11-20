# 🔄 Guia de Migração - Delphi de BD Direto para API REST

**Data:** 20 de Novembro de 2025  
**Versão:** 1.0.0  
**Status:** Production Ready

---

## 📋 Índice

1. [Visão Geral da Migração](#visão-geral-da-migração)
2. [Arquitetura Atual vs Nova](#arquitetura-atual-vs-nova)
3. [Preparação Inicial](#preparação-inicial)
4. [Fase 1: Criar Componentes de API](#fase-1-criar-componentes-de-api)
5. [Fase 2: Substituir Conexões do BD](#fase-2-substituir-conexões-do-bd)
6. [Fase 3: Migrar Operações CRUD](#fase-3-migrar-operações-crud)
7. [Fase 4: Implementar Autenticação JWT](#fase-4-implementar-autenticação-jwt)
8. [Fase 5: Testes e Validação](#fase-5-testes-e-validação)
9. [Troubleshooting](#troubleshooting)

---

## 🎯 Visão Geral da Migração

### O que está mudando?

**ANTES (Atual):**

```
┌─────────────────────┐
│   Aplicação Delphi  │
└──────────┬──────────┘
           │ Conexão direta SQL
           │ (ADO/BDE/FireDAC)
           ▼
┌─────────────────────┐
│   MySQL Database    │
│   (saw15)           │
└─────────────────────┘
```

**DEPOIS (Nova):**

```
┌─────────────────────┐
│   Aplicação Delphi  │
└──────────┬──────────┘
           │ HTTP + JSON
           │ (Indy/REST Components)
           ▼
┌─────────────────────┐
│   API REST (PHP)    │
│   http://...7080    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   MySQL Database    │
│   (saw15)           │
└─────────────────────┘
```

### Benefícios

✅ Segurança: Sem credenciais do banco expostas  
✅ Escalabilidade: Múltiplos clientes com 1 API  
✅ Manutenção: Mudanças apenas na API, não em cada cliente  
✅ Auditoria: Todas as operações registradas  
✅ Flexibilidade: Pode conectar de qualquer lugar

---

## 🏗️ Arquitetura Atual vs Nova

### Componentes Necessários em Delphi

| Componente   | Atual   | Novo           | Descrição                   |
| ------------ | ------- | -------------- | --------------------------- |
| Conexão BD   | ADO/BDE | ❌ Removido    | Conexão direta ao MySQL     |
| HTTP Client  | -       | ✅ TRESTClient | Para comunicação com API    |
| JSON         | -       | ✅ JSON (REST) | Parse de respostas          |
| Autenticação | Windows | ✅ JWT Token   | Token da API                |
| Thread Pool  | -       | ✅ Async       | Requisições não-bloqueantes |

---

## 🚀 Preparação Inicial

### Passo 1: Fazer Backup do Projeto

```bash
# Em PowerShell
$projectPath = "C:\Sua\Pasta\ProjetoDelphi"
$backupPath = "C:\Backups\ProjetoDelphi_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss')"

Copy-Item -Path $projectPath -Destination $backupPath -Recurse
Write-Host "✅ Backup criado em: $backupPath"
```

### Passo 2: Verificar Versão do Delphi

A migração funciona em:

- ✅ Delphi 10.3+
- ✅ Delphi 10.4+
- ✅ Delphi 11
- ✅ Delphi 12

Se usar versão anterior, consulte o suporte.

### Passo 3: Organizar Estrutura de Pastas

```
ProjetoDelphi/
├── src/
│   ├── View/           (Forms)
│   ├── Model/          (Modelos de dados)
│   ├── API/            (🆕 Componentes de API)
│   │   ├── APIClient.pas
│   │   ├── AuthManager.pas
│   │   └── RequestHandler.pas
│   ├── Dao/            (Data Access Objects)
│   │   ├── BaseDAO.pas
│   │   ├── UsuarioDAO.pas
│   │   └── AtendimentoDAO.pas
│   └── Utils/          (Utilitários)
├── Resources/
└── Config/
    └── APIConfig.ini   (🆕 Configurações da API)
```

---

## 📦 Fase 1: Criar Componentes de API

### 1.1 Criar arquivo de configuração: `APIConfig.ini`

```ini
[API]
Host=104.234.173.105
Port=7080
BasePath=/api/v1
Protocol=http
Timeout=30000

[Auth]
Username=admin
Password=123456
TokenExpiry=3600
RefreshTokenExpiry=604800

[Debug]
LogRequests=1
LogResponses=1
LogFile=C:\Logs\API_Log.txt
```

### 1.2 Criar classe: `APIConfig.pas`

```pascal
unit APIConfig;

interface

type
  TAPIConfig = class
  private
    FHost: string;
    FPort: Integer;
    FBasePath: string;
    FProtocol: string;
    FTimeout: Integer;
    FUsername: string;
    FPassword: string;
    function GetBaseURL: string;
    procedure LoadFromIni;
  public
    constructor Create;
    property Host: string read FHost write FHost;
    property Port: Integer read FPort write FPort;
    property BasePath: string read FBasePath write FBasePath;
    property Protocol: string read FProtocol write FProtocol;
    property Timeout: Integer read FTimeout write FTimeout;
    property Username: string read FUsername write FUsername;
    property Password: string read FPassword write FPassword;
    property BaseURL: string read GetBaseURL;
  end;

implementation

uses
  IniFiles, SysUtils;

constructor TAPIConfig.Create;
begin
  inherited;
  LoadFromIni;
end;

function TAPIConfig.GetBaseURL: string;
begin
  Result := Format('%s://%s:%d%s', [FProtocol, FHost, FPort, FBasePath]);
end;

procedure TAPIConfig.LoadFromIni;
var
  LIniFile: TIniFile;
  LConfigPath: string;
begin
  // Construir caminho do arquivo de configuração
  LConfigPath := ExtractFilePath(ParamStr(0)) + 'APIConfig.ini';

  if FileExists(LConfigPath) then
  begin
    LIniFile := TIniFile.Create(LConfigPath);
    try
      FHost := LIniFile.ReadString('API', 'Host', '104.234.173.105');
      FPort := LIniFile.ReadInteger('API', 'Port', 7080);
      FBasePath := LIniFile.ReadString('API', 'BasePath', '/api/v1');
      FProtocol := LIniFile.ReadString('API', 'Protocol', 'http');
      FTimeout := LIniFile.ReadInteger('API', 'Timeout', 30000);
      FUsername := LIniFile.ReadString('Auth', 'Username', 'admin');
      FPassword := LIniFile.ReadString('Auth', 'Password', '123456');
    finally
      LIniFile.Free;
    end;
  end
  else
  begin
    // Valores padrão
    FHost := '104.234.173.105';
    FPort := 7080;
    FBasePath := '/api/v1';
    FProtocol := 'http';
    FTimeout := 30000;
    FUsername := 'admin';
    FPassword := '123456';
  end;
end;

end.
```

### 1.3 Criar classe de autenticação: `AuthManager.pas`

```pascal
unit AuthManager;

interface

uses
  System.JSON, System.Classes, REST.Client, REST.Types;

type
  TAuthManager = class
  private
    FAccessToken: string;
    FRefreshToken: string;
    FTokenExpiry: TDateTime;
    FAPIConfig: TAPIConfig;
    FRESTClient: TRESTClient;
    function PerformLogin: Boolean;
  public
    constructor Create(AAPIConfig: TAPIConfig);
    destructor Destroy; override;
    function Login: Boolean;
    function IsTokenValid: Boolean;
    function RefreshAccessToken: Boolean;
    property AccessToken: string read FAccessToken;
    property RefreshToken: string read FRefreshToken;
  end;

implementation

uses
  SysUtils, DateUtils;

constructor TAuthManager.Create(AAPIConfig: TAPIConfig);
begin
  inherited Create;
  FAPIConfig := AAPIConfig;
  FRESTClient := TRESTClient.Create(FAPIConfig.BaseURL);
  FRESTClient.ConnectTimeout := FAPIConfig.Timeout;
  FRESTClient.ReadTimeout := FAPIConfig.Timeout;
end;

destructor TAuthManager.Destroy;
begin
  if Assigned(FRESTClient) then
    FRESTClient.Free;
  inherited;
end;

function TAuthManager.Login: Boolean;
begin
  Result := PerformLogin;
end;

function TAuthManager.PerformLogin: Boolean;
var
  LRequest: TRESTRequest;
  LResponse: IRESTResponse;
  LJSONValue: TJSONValue;
  LJSONObject: TJSONObject;
begin
  Result := False;

  try
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/auth/login';
      LRequest.Method := rmPOST;

      // Preparar dados de login
      LRequest.AddParameter('usuario', FAPIConfig.Username, pkJSONBODY);
      LRequest.AddParameter('senha', FAPIConfig.Password, pkJSONBODY);

      // Enviar requisição
      LRequest.Execute;

      // Verificar resposta
      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          if LJSONValue is TJSONObject then
          begin
            LJSONObject := TJSONObject(LJSONValue);

            // Extrair token
            FAccessToken := LJSONObject.GetValue('data').GetValue<string>('token');
            FRefreshToken := LJSONObject.GetValue('data').GetValue<string>('refresh_token');

            // Calcular expiração
            FTokenExpiry := IncSecond(Now, 3600); // 1 hora

            Result := True;
          end;
        finally
          LJSONValue.Free;
        end;
      end
      else
      begin
        raise Exception.Create('Falha no login: ' + LRequest.Response.StatusText);
      end;
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
    begin
      WriteLn('Erro ao fazer login: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TAuthManager.IsTokenValid: Boolean;
begin
  // Verificar se token existe e ainda não expirou
  Result := (FAccessToken <> '') and (Now < FTokenExpiry);
end;

function TAuthManager.RefreshAccessToken: Boolean;
var
  LRequest: TRESTRequest;
  LResponse: IRESTResponse;
  LJSONValue: TJSONValue;
  LJSONObject: TJSONObject;
begin
  Result := False;

  try
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/auth/refresh';
      LRequest.Method := rmPOST;

      // Adicionar autorização atual
      LRequest.AddHeader('Authorization', 'Bearer ' + FAccessToken);

      // Preparar dados de refresh
      LRequest.AddParameter('refresh_token', FRefreshToken, pkJSONBODY);

      // Enviar requisição
      LRequest.Execute;

      // Verificar resposta
      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          if LJSONValue is TJSONObject then
          begin
            LJSONObject := TJSONObject(LJSONValue);

            // Atualizar token
            FAccessToken := LJSONObject.GetValue('data').GetValue<string>('token');
            FTokenExpiry := IncSecond(Now, 3600);

            Result := True;
          end;
        finally
          LJSONValue.Free;
        end;
      end;
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
    begin
      WriteLn('Erro ao renovar token: ' + E.Message);
      Result := False;
    end;
  end;
end;

end.
```

### 1.4 Criar gerenciador de requisições: `APIClient.pas`

```pascal
unit APIClient;

interface

uses
  System.JSON, System.Classes, REST.Client, REST.Types, APIConfig, AuthManager;

type
  TAPIClient = class
  private
    FConfig: TAPIConfig;
    FAuthManager: TAuthManager;
    FRESTClient: TRESTClient;
  public
    constructor Create;
    destructor Destroy; override;

    // Métodos de requisição
    function GET(const AResource: string): TJSONValue;
    function POST(const AResource: string; AData: TJSONObject): TJSONValue;
    function PUT(const AResource: string; AData: TJSONObject): TJSONValue;
    function DELETE(const AResource: string): TJSONValue;

    // Propriedades
    property Config: TAPIConfig read FConfig;
    property AuthManager: TAuthManager read FAuthManager;
  end;

implementation

uses
  SysUtils, DateUtils;

constructor TAPIClient.Create;
begin
  inherited Create;
  FConfig := TAPIConfig.Create;
  FRESTClient := TRESTClient.Create(FConfig.BaseURL);
  FRESTClient.ConnectTimeout := FConfig.Timeout;
  FRESTClient.ReadTimeout := FConfig.Timeout;
  FAuthManager := TAuthManager.Create(FConfig);

  // Fazer login automaticamente
  if not FAuthManager.Login then
    raise Exception.Create('Falha ao conectar à API');
end;

destructor TAPIClient.Destroy;
begin
  if Assigned(FAuthManager) then
    FAuthManager.Free;
  if Assigned(FRESTClient) then
    FRESTClient.Free;
  if Assigned(FConfig) then
    FConfig.Free;
  inherited;
end;

function TAPIClient.GET(const AResource: string): TJSONValue;
var
  LRequest: TRESTRequest;
begin
  Result := nil;

  // Renovar token se expirado
  if not FAuthManager.IsTokenValid then
    FAuthManager.RefreshAccessToken;

  LRequest := TRESTRequest.Create(nil);
  try
    LRequest.Client := FRESTClient;
    LRequest.Resource := AResource;
    LRequest.Method := rmGET;

    // Adicionar autorização
    LRequest.AddHeader('Authorization', 'Bearer ' + FAuthManager.AccessToken);

    // Executar
    LRequest.Execute;

    if LRequest.Response.StatusCode = 200 then
      Result := TJSONObject.ParseJSONValue(LRequest.Response.Content)
    else
      raise Exception.Create('Erro na requisição GET: ' + LRequest.Response.StatusText);
  finally
    LRequest.Free;
  end;
end;

function TAPIClient.POST(const AResource: string; AData: TJSONObject): TJSONValue;
var
  LRequest: TRESTRequest;
begin
  Result := nil;

  if not FAuthManager.IsTokenValid then
    FAuthManager.RefreshAccessToken;

  LRequest := TRESTRequest.Create(nil);
  try
    LRequest.Client := FRESTClient;
    LRequest.Resource := AResource;
    LRequest.Method := rmPOST;

    // Adicionar autorização
    LRequest.AddHeader('Authorization', 'Bearer ' + FAuthManager.AccessToken);

    // Adicionar dados
    LRequest.Body.Add(AData.ToString);

    // Executar
    LRequest.Execute;

    if LRequest.Response.StatusCode in [200, 201] then
      Result := TJSONObject.ParseJSONValue(LRequest.Response.Content)
    else
      raise Exception.Create('Erro na requisição POST: ' + LRequest.Response.StatusText);
  finally
    LRequest.Free;
  end;
end;

function TAPIClient.PUT(const AResource: string; AData: TJSONObject): TJSONValue;
var
  LRequest: TRESTRequest;
begin
  Result := nil;

  if not FAuthManager.IsTokenValid then
    FAuthManager.RefreshAccessToken;

  LRequest := TRESTRequest.Create(nil);
  try
    LRequest.Client := FRESTClient;
    LRequest.Resource := AResource;
    LRequest.Method := rmPUT;

    LRequest.AddHeader('Authorization', 'Bearer ' + FAuthManager.AccessToken);
    LRequest.Body.Add(AData.ToString);

    LRequest.Execute;

    if LRequest.Response.StatusCode in [200, 201] then
      Result := TJSONObject.ParseJSONValue(LRequest.Response.Content)
    else
      raise Exception.Create('Erro na requisição PUT: ' + LRequest.Response.StatusText);
  finally
    LRequest.Free;
  end;
end;

function TAPIClient.DELETE(const AResource: string): TJSONValue;
var
  LRequest: TRESTRequest;
begin
  Result := nil;

  if not FAuthManager.IsTokenValid then
    FAuthManager.RefreshAccessToken;

  LRequest := TRESTRequest.Create(nil);
  try
    LRequest.Client := FRESTClient;
    LRequest.Resource := AResource;
    LRequest.Method := rmDELETE;

    LRequest.AddHeader('Authorization', 'Bearer ' + FAuthManager.AccessToken);

    LRequest.Execute;

    if LRequest.Response.StatusCode in [200, 204] then
      Result := TJSONObject.ParseJSONValue(LRequest.Response.Content)
    else
      raise Exception.Create('Erro na requisição DELETE: ' + LRequest.Response.StatusText);
  finally
    LRequest.Free;
  end;
end;

end.
```

---

## 🔄 Fase 2: Substituir Conexões do BD

### 2.1 Remover conexão direta

**ANTES (código antigo):**

```pascal
unit DataModule;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MySQL,
  FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TDataModule1 = class(TDataModule)
    FDConnection1: TFDConnection;
    qryUsuarios: TFDQuery;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataModule1: TDataModule1;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
```

**DEPOIS (novo):**

```pascal
unit DataModule;

interface

uses
  System.SysUtils, System.Classes, APIClient;

type
  TDataModule1 = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    FAPIClient: TAPIClient;
  public
    property APIClient: TAPIClient read FAPIClient;
  end;

var
  DataModule1: TDataModule1;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDataModule1.DataModuleCreate(Sender: TObject);
begin
  // Criar cliente API
  try
    FAPIClient := TAPIClient.Create;
  except
    on E: Exception do
      ShowMessage('Erro ao conectar à API: ' + E.Message);
  end;
end;

end.
```

### 2.2 Remover componentes FireDAC do DFM

No arquivo `.dfm`, remova:

```
object FDConnection1: TFDConnection
  Params.Strings = (
    'DriverID=MySQL'
    'Server=104.234.173.105'
    'Port=3306'
    'Database=saw15'
    'User_Name=root'
    'Password=Ncm@647534'
    'CharacterSet=utf8mb4')
end
object qryUsuarios: TFDQuery
end
```

Deixando apenas o necessário para a API.

---

## 📊 Fase 3: Migrar Operações CRUD

### 3.1 Criar classes DAO com API

**Padrão Antigo (com BD direto):**

```pascal
// ❌ ANTIGO
type
  TUsuarioDAO = class
  private
    FConnection: TFDConnection;
  public
    constructor Create(AConnection: TFDConnection);
    function GetAll: TDataSet;
    function GetByID(AID: Integer): TDataSet;
    function Insert(AUser: TUsuario): Integer;
    function Update(AUser: TUsuario): Boolean;
    function Delete(AID: Integer): Boolean;
  end;

implementation

function TUsuarioDAO.GetAll: TDataSet;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  LQuery.Connection := FConnection;
  LQuery.SQL.Text := 'SELECT * FROM tbusuario';
  LQuery.Open;
  Result := LQuery;
end;
```

**Padrão Novo (com API):**

```pascal
// ✅ NOVO
unit UsuarioDAO;

interface

uses
  System.JSON, System.Classes, APIClient, System.Generics.Collections;

type
  TUsuario = record
    ID: Integer;
    Nome: string;
    Email: string;
    Login: string;
    Situacao: string;
  end;

  TUsuarioDAO = class
  private
    FAPIClient: TAPIClient;
  public
    constructor Create(AAPIClient: TAPIClient);

    // Leitura
    function GetAll: TList<TUsuario>;
    function GetByID(AID: Integer): TUsuario;

    // Escrita
    function Insert(AUser: TUsuario): Integer;
    function Update(AID: Integer; AUser: TUsuario): Boolean;
    function Delete(AID: Integer): Boolean;
  end;

implementation

uses
  SysUtils;

constructor TUsuarioDAO.Create(AAPIClient: TAPIClient);
begin
  inherited Create;
  FAPIClient := AAPIClient;
end;

function TUsuarioDAO.GetAll: TList<TUsuario>;
var
  LResponse: TJSONValue;
  LData: TJSONArray;
  LItem: TJSONValue;
  LUsuario: TUsuario;
begin
  Result := TList<TUsuario>.Create;

  try
    // Requisição GET para /usuarios
    LResponse := FAPIClient.GET('/usuarios?page=1&perPage=100');

    try
      // Parse do JSON
      if LResponse is TJSONObject then
      begin
        LData := TJSONObject(LResponse).GetValue('data')
          .FindValue('usuarios') as TJSONArray;

        for LItem in LData do
        begin
          LUsuario.ID := TJSONObject(LItem).GetValue<Integer>('id');
          LUsuario.Nome := TJSONObject(LItem).GetValue<string>('nome');
          LUsuario.Email := TJSONObject(LItem).GetValue<string>('email');
          LUsuario.Login := TJSONObject(LItem).GetValue<string>('login');
          LUsuario.Situacao := TJSONObject(LItem).GetValue<string>('situacao');

          Result.Add(LUsuario);
        end;
      end;
    finally
      LResponse.Free;
    end;
  except
    on E: Exception do
    begin
      WriteLn('Erro ao buscar usuários: ' + E.Message);
      Result.Clear;
    end;
  end;
end;

function TUsuarioDAO.GetByID(AID: Integer): TUsuario;
var
  LResponse: TJSONValue;
  LJSONObject: TJSONObject;
begin
  FillChar(Result, SizeOf(TUsuario), 0);

  try
    // Requisição GET para /usuarios/me
    LResponse := FAPIClient.GET('/usuarios/me');

    try
      if LResponse is TJSONObject then
      begin
        LJSONObject := TJSONObject(LResponse).GetValue('data') as TJSONObject;

        Result.ID := LJSONObject.GetValue<Integer>('id');
        Result.Nome := LJSONObject.GetValue<string>('nome');
        Result.Email := LJSONObject.GetValue<string>('email');
        Result.Login := LJSONObject.GetValue<string>('login');
        Result.Situacao := LJSONObject.GetValue<string>('situacao');
      end;
    finally
      LResponse.Free;
    end;
  except
    on E: Exception do
      WriteLn('Erro ao buscar usuário: ' + E.Message);
  end;
end;

function TUsuarioDAO.Insert(AUser: TUsuario): Integer;
var
  LData: TJSONObject;
  LResponse: TJSONValue;
begin
  Result := 0;

  // Criar objeto JSON com dados
  LData := TJSONObject.Create;
  try
    LData.AddPair('nome', TJSONString.Create(AUser.Nome));
    LData.AddPair('email', TJSONString.Create(AUser.Email));
    LData.AddPair('login', TJSONString.Create(AUser.Login));
    LData.AddPair('situacao', TJSONString.Create(AUser.Situacao));

    // POST para /usuarios
    LResponse := FAPIClient.POST('/usuarios', LData);

    try
      if LResponse is TJSONObject then
      begin
        Result := TJSONObject(LResponse)
          .GetValue('data')
          .GetValue<Integer>('id');
      end;
    finally
      LResponse.Free;
    end;
  finally
    LData.Free;
  end;
end;

function TUsuarioDAO.Update(AID: Integer; AUser: TUsuario): Boolean;
var
  LData: TJSONObject;
  LResponse: TJSONValue;
  LResource: string;
begin
  Result := False;

  LData := TJSONObject.Create;
  try
    LData.AddPair('nome', TJSONString.Create(AUser.Nome));
    LData.AddPair('email', TJSONString.Create(AUser.Email));
    LData.AddPair('situacao', TJSONString.Create(AUser.Situacao));

    LResource := Format('/usuarios/%d', [AID]);
    LResponse := FAPIClient.PUT(LResource, LData);

    try
      if LResponse is TJSONObject then
        Result := TJSONObject(LResponse).GetValue<string>('status') = 'success';
    finally
      LResponse.Free;
    end;
  finally
    LData.Free;
  end;
end;

function TUsuarioDAO.Delete(AID: Integer): Boolean;
var
  LResponse: TJSONValue;
  LResource: string;
begin
  Result := False;

  LResource := Format('/usuarios/%d', [AID]);
  LResponse := FAPIClient.DELETE(LResource);

  try
    if LResponse is TJSONObject then
      Result := TJSONObject(LResponse).GetValue<string>('status') = 'success';
  finally
    LResponse.Free;
  end;
end;

end.
```

---

## 🔐 Fase 4: Implementar Autenticação JWT

### 4.1 Criar gerenciador de sessão

```pascal
unit SessionManager;

interface

uses
  APIClient, System.DateUtils;

type
  TSessionManager = class
  private
    FAPIClient: TAPIClient;
    FCurrentUserID: Integer;
    FCurrentUsername: string;
    FLoginTime: TDateTime;
    FIsAuthenticated: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    function Login(AUsername, APassword: string): Boolean;
    function Logout: Boolean;
    procedure CheckTokenExpiry;

    property APIClient: TAPIClient read FAPIClient;
    property CurrentUserID: Integer read FCurrentUserID;
    property CurrentUsername: string read FCurrentUsername;
    property IsAuthenticated: Boolean read FIsAuthenticated;
  end;

var
  GSessionManager: TSessionManager;

implementation

uses
  SysUtils, System.JSON;

constructor TSessionManager.Create;
begin
  inherited Create;
  FIsAuthenticated := False;
  try
    FAPIClient := TAPIClient.Create;
  except
    on E: Exception do
    begin
      WriteLn('Erro ao inicializar API: ' + E.Message);
      FAPIClient := nil;
    end;
  end;
end;

destructor TSessionManager.Destroy;
begin
  if Assigned(FAPIClient) then
    FAPIClient.Free;
  inherited;
end;

function TSessionManager.Login(AUsername, APassword: string): Boolean;
var
  LData: TJSONObject;
  LResponse: TJSONValue;
  LAuthConfig: TAPIConfig;
begin
  Result := False;

  try
    // Atualizar credenciais na configuração
    LAuthConfig := FAPIClient.Config;
    LAuthConfig.Username := AUsername;
    LAuthConfig.Password := APassword;

    // Fazer novo login
    Result := FAPIClient.AuthManager.Login;

    if Result then
    begin
      FCurrentUsername := AUsername;
      FIsAuthenticated := True;
      FLoginTime := Now;

      // Buscar dados do usuário
      LResponse := FAPIClient.GET('/usuarios/me');
      try
        if LResponse is TJSONObject then
        begin
          FCurrentUserID := TJSONObject(LResponse)
            .GetValue('data')
            .GetValue<Integer>('id');
        end;
      finally
        LResponse.Free;
      end;
    end;
  except
    on E: Exception do
    begin
      WriteLn('Erro no login: ' + E.Message);
      FIsAuthenticated := False;
    end;
  end;
end;

function TSessionManager.Logout: Boolean;
begin
  Result := True;
  FIsAuthenticated := False;
  FCurrentUserID := 0;
  FCurrentUsername := '';
end;

procedure TSessionManager.CheckTokenExpiry;
begin
  if FIsAuthenticated then
  begin
    if not FAPIClient.AuthManager.IsTokenValid then
    begin
      if not FAPIClient.AuthManager.RefreshAccessToken then
      begin
        FIsAuthenticated := False;
        raise Exception.Create('Token expirou e não pode ser renovado');
      end;
    end;
  end;
end;

end.
```

### 4.2 Integrar SessionManager na aplicação

```pascal
unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, SessionManager;

type
  TMainForm = class(TForm)
    btnLogin: TButton;
    edtUsername: TEdit;
    edtPassword: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
  private
    procedure CheckSession;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Inicializar Session Manager
  if not Assigned(GSessionManager) then
    GSessionManager := TSessionManager.Create;
end;

procedure TMainForm.btnLoginClick(Sender: TObject);
begin
  if GSessionManager.Login(edtUsername.Text, edtPassword.Text) then
  begin
    ShowMessage('Login realizado com sucesso!');
    // Abrir próxima tela
  end
  else
  begin
    ShowMessage('Falha no login. Verifique as credenciais.');
  end;
end;

procedure TMainForm.CheckSession;
begin
  try
    GSessionManager.CheckTokenExpiry;
  except
    on E: Exception do
    begin
      ShowMessage('Sessão expirada: ' + E.Message);
      // Redirecionar para login
    end;
  end;
end;

end.
```

---

## ✅ Fase 5: Testes e Validação

### 5.1 Teste de Conexão

```pascal
// Em um formulário de teste
procedure TTestForm.TestAPIConnection;
var
  LClient: TAPIClient;
  LResponse: TJSONValue;
begin
  try
    // Criar cliente
    LClient := TAPIClient.Create;
    try
      // Testar Login
      ShowMessage('✅ Login OK');

      // Testar GET
      LResponse := LClient.GET('/usuarios/me');
      try
        ShowMessage('✅ GET OK: ' + LResponse.ToString);
      finally
        LResponse.Free;
      end;

      ShowMessage('✅ Todas as conexões OK!');
    finally
      LClient.Free;
    end;
  except
    on E: Exception do
      ShowMessage('❌ Erro: ' + E.Message);
  end;
end;
```

### 5.2 Teste de CRUD

```pascal
procedure TTestForm.TestCRUDOperations;
var
  LUsuarioDAO: TUsuarioDAO;
  LUsuario: TUsuario;
  LUsers: TList<TUsuario>;
begin
  LUsuarioDAO := TUsuarioDAO.Create(GSessionManager.APIClient);
  try
    // READ
    LUsers := LUsuarioDAO.GetAll;
    try
      ShowMessage('✅ Leitura: ' + IntToStr(LUsers.Count) + ' usuários');
    finally
      LUsers.Free;
    end;

    // CREATE
    LUsuario.Nome := 'Novo Usuário';
    LUsuario.Email := 'novo@example.com';
    LUsuario.Login := 'novousuario';
    LUsuario.Situacao := 'A';

    LUsuario.ID := LUsuarioDAO.Insert(LUsuario);
    ShowMessage('✅ Criação: ID = ' + IntToStr(LUsuario.ID));

    // UPDATE
    LUsuario.Nome := 'Usuário Atualizado';
    if LUsuarioDAO.Update(LUsuario.ID, LUsuario) then
      ShowMessage('✅ Atualização OK')
    else
      ShowMessage('❌ Atualização falhou');

    // DELETE
    if LUsuarioDAO.Delete(LUsuario.ID) then
      ShowMessage('✅ Exclusão OK')
    else
      ShowMessage('❌ Exclusão falhou');

  finally
    LUsuarioDAO.Free;
  end;
end;
```

### 5.3 Checklist de Validação

- [ ] Conexão com API estabelecida
- [ ] Login retorna JWT token válido
- [ ] Token renovação funciona
- [ ] GET /usuarios/me retorna dados corretos
- [ ] GET /usuarios lista todos os usuários
- [ ] POST cria novo registro
- [ ] PUT atualiza registro existente
- [ ] DELETE remove registro
- [ ] Headers de autenticação corretos
- [ ] Tratamento de erros adequado
- [ ] Timeout configurado
- [ ] Reconexão automática em caso de falha

---

## 🔧 Troubleshooting

### Problema 1: "Connection refused"

**Causa:** API offline ou URL incorreta

**Solução:**

```pascal
procedure TTestForm.VerifyAPIConnection;
begin
  if not Assigned(GSessionManager.APIClient) then
    ShowMessage('❌ API Client não inicializado')
  else
    ShowMessage('✅ API URL: ' + GSessionManager.APIClient.Config.BaseURL);
end;
```

---

### Problema 2: "Token inválido"

**Causa:** Token expirado ou corrompido

**Solução:**

```pascal
procedure TTestForm.RefreshTokenIfNeeded;
begin
  GSessionManager.CheckTokenExpiry;
  ShowMessage('✅ Token renovado');
end;
```

---

### Problema 3: "JSON Parse Error"

**Causa:** Resposta da API em formato inesperado

**Solução:**

```pascal
procedure TTestForm.DebugResponse(AResponse: TJSONValue);
begin
  Memo1.Lines.Add('Resposta Bruta:');
  Memo1.Lines.Add(AResponse.ToString);
end;
```

---

### Problema 4: "Timeout"

**Causa:** Requisição demorando muito

**Solução:**

```pascal
// Em APIConfig.ini
[API]
Timeout=60000  // Aumentar para 60 segundos
```

---

## 📋 Cronograma Sugerido

| Fase      | Duração        | Tarefas                              |
| --------- | -------------- | ------------------------------------ |
| **1**     | 2-3 dias       | Criar componentes API e autenticação |
| **2**     | 1-2 dias       | Remover conexões diretas do BD       |
| **3**     | 3-5 dias       | Migrar todos os DAOs para API        |
| **4**     | 1 dia          | Implementar JWT                      |
| **5**     | 2-3 dias       | Testes completos e validação         |
| **6**     | 1 dia          | Correções e fine-tuning              |
| **Total** | **10-15 dias** | Migração completa                    |

---

## 📚 Referências Rápidas

### URLs de Testes

```
Base URL: http://104.234.173.105:7080/api/v1

Endpoints:
POST   /auth/login                          (Login)
GET    /auth/validate                       (Validar Token)
POST   /auth/refresh                        (Renovar Token)
GET    /usuarios                            (Listar)
GET    /usuarios/me                         (Dados Atuais)
GET    /usuarios/{id}                       (Detalhes)
POST   /usuarios                            (Criar)
PUT    /usuarios/{id}                       (Atualizar)
DELETE /usuarios/{id}                       (Deletar)
```

### Credenciais Padrão

```
Username: admin
Password: 123456
```

### Headers Necessários

```
Content-Type: application/json
Authorization: Bearer {token}
```

---

## ✨ Dicas de Migração

✅ **DO:**

- Manter backup do código antigo
- Migrar funcionalidade por funcionalidade
- Testar cada componente isoladamente
- Documentar mudanças feitas
- Usar variáveis de ambiente para URLs

❌ **DON'T:**

- Deletar código antigo antes de validar novo
- Fazer migração de tudo de uma vez
- Hardcode credenciais
- Ignorar erros de validação
- Usar versão velha da API sem atualizar

---

## 🎓 Próximas Lições

1. **Caching:** Implementar cache local de dados
2. **Sincronização:** Sincronizar offline e online
3. **Logs:** Sistema de logging completo
4. **Testes:** Testes automatizados
5. **Performance:** Otimização de requisições

---

**Documento Criado:** 20 de Novembro de 2025  
**Versão:** 1.0.0  
**Status:** ✅ Pronto para Uso

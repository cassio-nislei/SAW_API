{ ============================================================================
  APIClient.pas - Cliente Delphi para SAW API
  
  Use este arquivo em seu projeto Delphi para se conectar à API
  
  Instalação:
  1. Copie este arquivo para sua pasta do projeto
  2. Adicione em sua uses: APIClient
  3. Crie instâncias de TAPIClient ou TManager_Atendimento
  
  Exemplo:
  
    var
      API: TAPIClient;
      Response: TJSONObject;
    begin
      API := TAPIClient.Create;
      try
        Response := API.Get('/atendimentos');
        // Processar response
      finally
        API.Free;
      end;
    end;
  
  ============================================================================ }

unit APIClient;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.NetEncoding,
  IdHTTP,
  IdSSLOpenSSL;

type
  // =========================================================================
  // Cliente HTTP para API REST
  // =========================================================================
  TAPIClient = class
  private
    FHTTP: TIdHTTP;
    FBaseURL: string;
    FTimeout: Integer;
    FLastError: string;
    FLastStatusCode: Integer;
  protected
    function BuildURL(const Endpoint: string): string;
    procedure HandleError(const Operation: string; E: Exception);
  public
    constructor Create(const ABaseURL: string = 'http://localhost/SAW-main/api/v1');
    destructor Destroy; override;
    
    // HTTP Methods
    function Get(const Endpoint: string): TJSONObject;
    function Post(const Endpoint: string; AData: TJSONObject): TJSONObject;
    function Put(const Endpoint: string; AData: TJSONObject): TJSONObject;
    function Delete(const Endpoint: string): TJSONObject;
    
    // Configuração
    procedure SetTimeout(AMilliseconds: Integer);
    procedure SetBaseURL(const URL: string);
    
    // Propriedades
    property LastError: string read FLastError;
    property LastStatusCode: Integer read FLastStatusCode;
  end;

  // =========================================================================
  // Manager de Atendimentos (Business Logic)
  // =========================================================================
  TManager_Atendimento = class
  private
    FAPI: TAPIClient;
  public
    constructor Create(const ABaseURL: string = 'http://localhost/SAW-main/api/v1');
    destructor Destroy; override;
    
    function ListarAtendimentos(Page: Integer = 1; PerPage: Integer = 20): TJSONObject;
    function ListarAtendimentosAtivos: TJSONObject;
    function ObterAtendimento(const ID: Integer): TJSONObject;
    function CriarAtendimento(const Numero, Solicitante, Solicitacao: string; Setor: string = ''): Integer;
    function AlterarSituacao(const ID: Integer; const Situacao: string): Boolean;
    function AlterarSetor(const ID: Integer; const Setor: string): Boolean;
    function FinalizarAtendimento(const ID: Integer; Observacao: string = ''): Boolean;
  end;

  // =========================================================================
  // Manager de Mensagens
  // =========================================================================
  TManager_Mensagem = class
  private
    FAPI: TAPIClient;
  public
    constructor Create(const ABaseURL: string = 'http://localhost/SAW-main/api/v1');
    destructor Destroy; override;
    
    function ListarMensagens(const IDAtendimento: Integer; Tipo: string = ''): TJSONObject;
    function ListarMensagensPendentes(const IDAtendimento: Integer): TJSONObject;
    function CriarMensagem(const IDAtendimento: Integer; const Conteudo, Remetente: string; Tipo: string = 'saida'): Integer;
    function AlterarSituacao(const ID: Integer; const Situacao: string): Boolean;
    function MarcarVisualizada(const ID: Integer): Boolean;
    function AdicionarReacao(const ID: Integer; Reacao: Integer): Boolean;
    function DeletarMensagem(const ID: Integer): Boolean;
  end;

  // =========================================================================
  // Manager de Menus
  // =========================================================================
  TManager_Menu = class
  private
    FAPI: TAPIClient;
  public
    constructor Create(const ABaseURL: string = 'http://localhost/SAW-main/api/v1');
    destructor Destroy; override;
    
    function ListarMenus: TJSONObject;
    function ObterMenu(const ID: Integer): TJSONObject;
    function ObterRespostaAutomatica(const ID: Integer): TJSONObject;
    function ListarSubmenus(const IDPai: Integer): TJSONObject;
  end;

  // =========================================================================
  // Manager de Horários
  // =========================================================================
  TManager_Horario = class
  private
    FAPI: TAPIClient;
  public
    constructor Create(const ABaseURL: string = 'http://localhost/SAW-main/api/v1');
    destructor Destroy; override;
    
    function ObterFuncionamento: TJSONObject;
    function EstaAberto: Boolean;
  end;

implementation

{ ============================================================================
  TAPIClient
  ============================================================================ }

constructor TAPIClient.Create(const ABaseURL: string);
begin
  inherited Create;
  FBaseURL := ABaseURL;
  FTimeout := 30000; // 30 segundos
  FLastStatusCode := 0;
  FLastError := '';
  
  FHTTP := TIdHTTP.Create(nil);
  FHTTP.ConnectTimeout := FTimeout;
  FHTTP.ReadTimeout := FTimeout;
end;

destructor TAPIClient.Destroy;
begin
  FHTTP.Free;
  inherited;
end;

function TAPIClient.BuildURL(const Endpoint: string): string;
begin
  if Endpoint.StartsWith('/') then
    Result := FBaseURL + Endpoint
  else
    Result := FBaseURL + '/' + Endpoint;
end;

procedure TAPIClient.HandleError(const Operation: string; E: Exception);
begin
  FLastError := Format('%s error: %s', [Operation, E.Message]);
end;

procedure TAPIClient.SetTimeout(AMilliseconds: Integer);
begin
  FTimeout := AMilliseconds;
  FHTTP.ConnectTimeout := FTimeout;
  FHTTP.ReadTimeout := FTimeout;
end;

procedure TAPIClient.SetBaseURL(const URL: string);
begin
  FBaseURL := URL;
end;

function TAPIClient.Get(const Endpoint: string): TJSONObject;
var
  Response: string;
  URL: string;
begin
  Result := nil;
  FLastError := '';
  
  try
    URL := BuildURL(Endpoint);
    Response := FHTTP.Get(URL);
    FLastStatusCode := FHTTP.ResponseCode;
    
    if Response <> '' then
      Result := TJSONObject.ParseJSONValue(Response) as TJSONObject
    else
      FLastError := 'Empty response';
  except
    on E: Exception do
      HandleError('GET', E);
  end;
end;

function TAPIClient.Post(const Endpoint: string; AData: TJSONObject): TJSONObject;
var
  Response: string;
  Stream: TStringStream;
  URL: string;
begin
  Result := nil;
  FLastError := '';
  
  if not Assigned(AData) then
  begin
    FLastError := 'AData cannot be nil';
    Exit;
  end;
  
  Stream := TStringStream.Create;
  try
    try
      Stream.WriteString(AData.ToJSON);
      Stream.Position := 0;
      
      URL := BuildURL(Endpoint);
      FHTTP.Request.ContentType := 'application/json';
      Response := FHTTP.Post(URL, Stream);
      FLastStatusCode := FHTTP.ResponseCode;
      
      if Response <> '' then
        Result := TJSONObject.ParseJSONValue(Response) as TJSONObject
      else
        FLastError := 'Empty response';
    except
      on E: Exception do
        HandleError('POST', E);
    end;
  finally
    Stream.Free;
  end;
end;

function TAPIClient.Put(const Endpoint: string; AData: TJSONObject): TJSONObject;
var
  Response: string;
  Stream: TStringStream;
  URL: string;
begin
  Result := nil;
  FLastError := '';
  
  if not Assigned(AData) then
  begin
    FLastError := 'AData cannot be nil';
    Exit;
  end;
  
  Stream := TStringStream.Create;
  try
    try
      Stream.WriteString(AData.ToJSON);
      Stream.Position := 0;
      
      URL := BuildURL(Endpoint);
      FHTTP.Request.ContentType := 'application/json';
      Response := FHTTP.Put(URL, Stream);
      FLastStatusCode := FHTTP.ResponseCode;
      
      if Response <> '' then
        Result := TJSONObject.ParseJSONValue(Response) as TJSONObject
      else
        FLastError := 'Empty response';
    except
      on E: Exception do
        HandleError('PUT', E);
    end;
  finally
    Stream.Free;
  end;
end;

function TAPIClient.Delete(const Endpoint: string): TJSONObject;
var
  Response: string;
  URL: string;
begin
  Result := nil;
  FLastError := '';
  
  try
    URL := BuildURL(Endpoint);
    Response := FHTTP.Delete(URL);
    FLastStatusCode := FHTTP.ResponseCode;
    
    if Response <> '' then
      Result := TJSONObject.ParseJSONValue(Response) as TJSONObject
    else
      FLastError := 'Empty response';
  except
    on E: Exception do
      HandleError('DELETE', E);
  end;
end;

{ ============================================================================
  TManager_Atendimento
  ============================================================================ }

constructor TManager_Atendimento.Create(const ABaseURL: string);
begin
  inherited Create;
  FAPI := TAPIClient.Create(ABaseURL);
end;

destructor TManager_Atendimento.Destroy;
begin
  FAPI.Free;
  inherited;
end;

function TManager_Atendimento.ListarAtendimentos(Page: Integer; PerPage: Integer): TJSONObject;
var
  Endpoint: string;
begin
  Endpoint := Format('/atendimentos?page=%d&perPage=%d', [Page, PerPage]);
  Result := FAPI.Get(Endpoint);
end;

function TManager_Atendimento.ListarAtendimentosAtivos: TJSONObject;
begin
  Result := FAPI.Get('/atendimentos/ativos');
end;

function TManager_Atendimento.ObterAtendimento(const ID: Integer): TJSONObject;
begin
  Result := FAPI.Get('/atendimentos/' + IntToStr(ID));
end;

function TManager_Atendimento.CriarAtendimento(const Numero, Solicitante, Solicitacao, Setor: string): Integer;
var
  Data: TJSONObject;
  Response: TJSONObject;
  DataObj: TJSONObject;
begin
  Result := 0;
  Data := TJSONObject.Create;
  try
    Data.AddPair('numero', Numero);
    Data.AddPair('solicitante', Solicitante);
    Data.AddPair('solicitacao', Solicitacao);
    if Setor <> '' then
      Data.AddPair('setor', Setor);
    
    Response := FAPI.Post('/atendimentos', Data);
    try
      if Assigned(Response) and (Response.GetValue('status').Value = 'success') then
      begin
        DataObj := Response.GetValue('data') as TJSONObject;
        if Assigned(DataObj) and (DataObj.GetValue('id') <> nil) then
          Result := StrToInt(DataObj.GetValue('id').Value);
      end;
    finally
      Response.Free;
    end;
  finally
    Data.Free;
  end;
end;

function TManager_Atendimento.AlterarSituacao(const ID: Integer; const Situacao: string): Boolean;
var
  Data: TJSONObject;
  Response: TJSONObject;
begin
  Result := False;
  Data := TJSONObject.Create;
  try
    Data.AddPair('situacao', Situacao);
    
    Response := FAPI.Put('/atendimentos/' + IntToStr(ID) + '/situacao', Data);
    try
      if Assigned(Response) then
        Result := Response.GetValue('status').Value = 'success';
    finally
      Response.Free;
    end;
  finally
    Data.Free;
  end;
end;

function TManager_Atendimento.AlterarSetor(const ID: Integer; const Setor: string): Boolean;
var
  Data: TJSONObject;
  Response: TJSONObject;
begin
  Result := False;
  Data := TJSONObject.Create;
  try
    Data.AddPair('setor', Setor);
    
    Response := FAPI.Put('/atendimentos/' + IntToStr(ID) + '/setor', Data);
    try
      if Assigned(Response) then
        Result := Response.GetValue('status').Value = 'success';
    finally
      Response.Free;
    end;
  finally
    Data.Free;
  end;
end;

function TManager_Atendimento.FinalizarAtendimento(const ID: Integer; Observacao: string): Boolean;
var
  Data: TJSONObject;
  Response: TJSONObject;
begin
  Result := False;
  Data := TJSONObject.Create;
  try
    if Observacao <> '' then
      Data.AddPair('observacao', Observacao);
    
    Response := FAPI.Post('/atendimentos/' + IntToStr(ID) + '/finalizar', Data);
    try
      if Assigned(Response) then
        Result := Response.GetValue('status').Value = 'success';
    finally
      Response.Free;
    end;
  finally
    Data.Free;
  end;
end;

{ ============================================================================
  TManager_Mensagem
  ============================================================================ }

constructor TManager_Mensagem.Create(const ABaseURL: string);
begin
  inherited Create;
  FAPI := TAPIClient.Create(ABaseURL);
end;

destructor TManager_Mensagem.Destroy;
begin
  FAPI.Free;
  inherited;
end;

function TManager_Mensagem.ListarMensagens(const IDAtendimento: Integer; Tipo: string): TJSONObject;
var
  Endpoint: string;
begin
  Endpoint := '/atendimentos/' + IntToStr(IDAtendimento) + '/mensagens';
  if Tipo <> '' then
    Endpoint := Endpoint + '?tipo=' + Tipo;
  Result := FAPI.Get(Endpoint);
end;

function TManager_Mensagem.ListarMensagensPendentes(const IDAtendimento: Integer): TJSONObject;
begin
  Result := FAPI.Get('/atendimentos/' + IntToStr(IDAtendimento) + '/mensagens/pendentes');
end;

function TManager_Mensagem.CriarMensagem(const IDAtendimento: Integer; const Conteudo, Remetente: string; Tipo: string): Integer;
var
  Data: TJSONObject;
  Response: TJSONObject;
  DataObj: TJSONObject;
begin
  Result := 0;
  Data := TJSONObject.Create;
  try
    Data.AddPair('conteudo', Conteudo);
    Data.AddPair('remetente', Remetente);
    Data.AddPair('tipo', Tipo);
    
    Response := FAPI.Post('/atendimentos/' + IntToStr(IDAtendimento) + '/mensagens', Data);
    try
      if Assigned(Response) and (Response.GetValue('status').Value = 'success') then
      begin
        DataObj := Response.GetValue('data') as TJSONObject;
        if Assigned(DataObj) and (DataObj.GetValue('id') <> nil) then
          Result := StrToInt(DataObj.GetValue('id').Value);
      end;
    finally
      Response.Free;
    end;
  finally
    Data.Free;
  end;
end;

function TManager_Mensagem.AlterarSituacao(const ID: Integer; const Situacao: string): Boolean;
var
  Data: TJSONObject;
  Response: TJSONObject;
begin
  Result := False;
  Data := TJSONObject.Create;
  try
    Data.AddPair('situacao', Situacao);
    
    Response := FAPI.Put('/mensagens/' + IntToStr(ID) + '/situacao', Data);
    try
      if Assigned(Response) then
        Result := Response.GetValue('status').Value = 'success';
    finally
      Response.Free;
    end;
  finally
    Data.Free;
  end;
end;

function TManager_Mensagem.MarcarVisualizada(const ID: Integer): Boolean;
var
  Response: TJSONObject;
begin
  Result := False;
  Response := FAPI.Put('/mensagens/' + IntToStr(ID) + '/visualizar', TJSONObject.Create);
  try
    if Assigned(Response) then
      Result := Response.GetValue('status').Value = 'success';
  finally
    Response.Free;
  end;
end;

function TManager_Mensagem.AdicionarReacao(const ID: Integer; Reacao: Integer): Boolean;
var
  Data: TJSONObject;
  Response: TJSONObject;
begin
  Result := False;
  Data := TJSONObject.Create;
  try
    Data.AddPair('reacao', TJSONNumber.Create(Reacao));
    
    Response := FAPI.Post('/mensagens/' + IntToStr(ID) + '/reacao', Data);
    try
      if Assigned(Response) then
        Result := Response.GetValue('status').Value = 'success';
    finally
      Response.Free;
    end;
  finally
    Data.Free;
  end;
end;

function TManager_Mensagem.DeletarMensagem(const ID: Integer): Boolean;
var
  Response: TJSONObject;
begin
  Result := False;
  Response := FAPI.Delete('/mensagens/' + IntToStr(ID));
  try
    if Assigned(Response) then
      Result := Response.GetValue('status').Value = 'success';
  finally
    Response.Free;
  end;
end;

{ ============================================================================
  TManager_Menu
  ============================================================================ }

constructor TManager_Menu.Create(const ABaseURL: string);
begin
  inherited Create;
  FAPI := TAPIClient.Create(ABaseURL);
end;

destructor TManager_Menu.Destroy;
begin
  FAPI.Free;
  inherited;
end;

function TManager_Menu.ListarMenus: TJSONObject;
begin
  Result := FAPI.Get('/menus');
end;

function TManager_Menu.ObterMenu(const ID: Integer): TJSONObject;
begin
  Result := FAPI.Get('/menus/' + IntToStr(ID));
end;

function TManager_Menu.ObterRespostaAutomatica(const ID: Integer): TJSONObject;
begin
  Result := FAPI.Get('/menus/' + IntToStr(ID) + '/resposta-automatica');
end;

function TManager_Menu.ListarSubmenus(const IDPai: Integer): TJSONObject;
begin
  Result := FAPI.Get('/menus/submenus/' + IntToStr(IDPai));
end;

{ ============================================================================
  TManager_Horario
  ============================================================================ }

constructor TManager_Horario.Create(const ABaseURL: string);
begin
  inherited Create;
  FAPI := TAPIClient.Create(ABaseURL);
end;

destructor TManager_Horario.Destroy;
begin
  FAPI.Free;
  inherited;
end;

function TManager_Horario.ObterFuncionamento: TJSONObject;
begin
  Result := FAPI.Get('/horarios/funcionamento');
end;

function TManager_Horario.EstaAberto: Boolean;
var
  Response: TJSONObject;
begin
  Result := False;
  Response := FAPI.Get('/horarios/aberto');
  try
    if Assigned(Response) and (Response.GetValue('data') <> nil) then
      Result := StrToBool(Response.GetValue('data').Value);
  finally
    Response.Free;
  end;
end;

end.

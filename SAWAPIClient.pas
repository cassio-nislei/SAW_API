unit SAWAPIClient;

{
  SAW API Client - Unit simplificada para integração rápida
  Desenvolvido para Delphi 10.3+

  Uso básico:

    var
      API: TSAW API;
    begin
      // Inicializar
      API := TSAWAPIClient.Create('admin', '123456');

      // Usar
      ShowMessage(API.GetUsuario(1).Nome);

      // Liberar
      API.Free;
    end;
}

interface

uses
  System.SysUtils, System.JSON, System.Classes, System.Generics.Collections,
  REST.Client, REST.Types, System.DateUtils,REST.Authenticator.Basic,
  REST.Utils, System.Net.HttpClient, System.IOUtils, System.StrUtils,
  System.Net.HttpClientComponent,
  System.Net.Mime;

type
  // ============================================
  // Tipos de Dados
  // ============================================

  TUsuario = record
    ID: Integer;
    Nome: string;
    Email: string;
    Login: string;
    Situacao: string;
    DataCriacao: TDateTime;
  end;

  TAtendimento = record
    ID: Integer;
    Cliente: string;
    Setor: string;
    Assunto: string;
    Status: string;
    OperadorID: Integer;
    OperadorNome: string;
    DataInicio: TDateTime;
  end;

  TAnexo = record
    ID: Integer;
    AtendimentoID: Integer;
    NomeArquivo: string;
    TamanhoBytes: Integer;
    DataUpload: TDateTime;
    Downloads: Integer;
  end;

  TDashboard = record
    Ano: Integer;
    TotalAtendimentos: Integer;
    EmTriagem: Integer;
    Pendentes: Integer;
    EmAtendimento: Integer;
    Finalizados: Integer;
    TaxaConclusao: Double;
    TempoMedioAtendimento: Double;
  end;

  TContato = record
    ID: Integer;
    Nome: string;
    Telefone: string;
    Email: string;
  end;

  TMensagem = record
    ID: Integer;
    Conteudo: string;
    Situacao: string;
    DataCriacao: TDateTime;
  end;

  TParametro = record
    ID: Integer;
    Chave: string;
    Valor: string;
  end;

  TMenu = record
    ID: Integer;
    Nome: string;
    Descricao: string;
    Pai: Integer;
  end;

  TAviso = record
    ID: Integer;
    Numero: string;
    Mensagem: string;
    DataCriacao: TDateTime;
  end;

  // ============================================
  // Eventos
  // ============================================

  TOnTokenRefresh = procedure(Sender: TObject; const ANewToken: string) of object;
  TOnError = procedure(Sender: TObject; const AError: string) of object;
  TOnRequestLog = procedure(Sender: TObject; const AMethod, AResource, AResponse: string) of object;

  // ============================================
  // Classe Principal
  // ============================================

  TSAWAPIClient = class
  private
    FHost: string;
    FPort: Integer;
    FProtocol: string;
    FAccessToken: string;
    FRefreshToken: string;
    FTokenExpiry: TDateTime;
    FRESTClient: TRESTClient;
    FUsername: string;
    FPassword: string;
    FTimeout: Integer;
    FDebugMode: Boolean;
    FOnTokenRefresh: TOnTokenRefresh;
    FOnError: TOnError;
    FOnRequestLog: TOnRequestLog;
    FBaseURL: string;

    // Métodos privados
    function GetBaseURL: string;
    function GetAuthHeader: string;
    function IsTokenValid: Boolean;
    procedure RefreshToken;
    procedure CheckTokenExpiry;
    procedure LogRequest(const AMethod, AResource, AResponse: string);
    procedure RaiseError(const AError: string);
    function AtualizarStatusMensagem(AIdMsg: Integer; const AChatID: string;
      ANovoStatus: Integer): Boolean;
    function ListarMensagensStatusPendentes(const ACanal: string;
  AHorasAtras: Integer = 24; AMinutosFuturos: Integer = 10): TJSONValue;
    function ObterRelatorioStatusMensagens(const ACanal: string;
  ADataIni: TDate = 0; ADataFim: TDate = 0): TJSONValue;



  public
    // Construtor e destrutor
    constructor Create(const AUsername, APassword: string;
      const AHost: string = '104.234.173.105'; APort: Integer = 7080);
    destructor Destroy; override;

    // ============================================
    // Autenticação
    // ============================================

    procedure Login(const AUsername, APassword: string);
    procedure Logout;
    function ValidateToken: Boolean;
    function GetTokenExpiration: TDateTime;
    function GetTimeRemaining: Integer;

    // ============================================
    // Usuários
    // ============================================

    function GetAllUsuarios(APage: Integer = 1; APerPage: Integer = 20): TList<TUsuario>;
    function GetUsuario(AID: Integer): TUsuario;
    function GetCurrentUsuario: TUsuario;
    function CreateUsuario(AUsuario: TUsuario): Integer;
    function UpdateUsuario(AUsuario: TUsuario): Boolean;
    function DeleteUsuario(AID: Integer): Boolean;

    // ============================================
    // Atendimentos
    // ============================================

    function GetAtendimentoByPhone(const APhone: string): TAtendimento;
    function GetAtendimentoAnexos(AAtendimentoID: Integer): TList<TAnexo>;
    function VerificarAtendimentoPendente(const ANumero: string): Boolean;
    function CriarAtendimento(const ANumero, ANome: string; AIDAtendente: Integer = 0;
      const ANomeAtendente: string = ''; const ASituacao: string = 'P';
      const ACanal: string = ''; const ASetor: string = ''): Integer;
   function FinalizarAtendimento(AID: Integer): Boolean;

    function GravarMensagemAtendimento(AAtendimentoID: Integer; const AMensagem: string): Boolean;
    function AtualizarSetorAtendimento(AAtendimentoID: Integer; const ASetor: string): Boolean;
    function ListarAtendimentosInativos(ATempoMinutos: Integer = 5): TList<TAtendimento>;

    // ============================================
    // Mensagens
    // ============================================

    function VerificarMensagemDuplicada(const AChatID: string): Boolean;
    function GetStatusMultiplasMensagens: TJSONValue;
    function ListarMensagensParaEnviar: TList<TMensagem>;
    function ProximaSequenciaMensagem(AAtendimentoID: Integer): Integer;
    function MarcarMensagemExcluida(const AChatID: string): Boolean;
    function MarcarMensagemReacao(const AChatID, AReacao: string): Boolean;
    function MarcarMensagemEnviada(AID: Integer): Boolean;
    function CompararDuplicacaoMensagem(AID: Integer; const AMensagem: string): Boolean;
    function AtualizarEnvioMensagem(AIDAgendamento: Integer; AEnviado: Integer; ATempoEnvio: Integer): Boolean;
    function EnviarArquivo(
  AAtendimentoID: Integer;
  const ACaminhoArquivo, ANomeArquivo, ATipoArquivo: string
): Boolean;

    function ProcessarMultiplasAtualizacoesStatus(
  const AAtualizacoes: TJSONArray
    ): TJSONValue;


    // ============================================
    // Contatos
    // ============================================

    function ExportarContatos(APagina: Integer = 1; ALimite: Integer = 20): TList<TContato>;
    function BuscarNomeContato(const ANumero: string): string;

    // ============================================
    // Agendamentos
    // ============================================

    function ListarAgendamentosPendentes: TJSONValue;

    // ============================================
    // Parâmetros
    // ============================================

    function GetParametrosSistema: TJSONValue;
    function VerificarExpediente: TJSONValue;

    // ============================================
    // Menus
    // ============================================

    function GetMenuPrincipal: TList<TMenu>;
    function GetSubmenus: TList<TMenu>;

    // ============================================
    // Respostas Automáticas
    // ============================================

    function GetRespostasAutomaticas(AIDMenu: Integer): TJSONValue;

    // ============================================
    // Departamentos
    // ============================================

    function GetDepartamentoPorMenu(AIDMenu: Integer): TJSONValue;

    // ============================================
    // Avisos
    // ============================================

    function RegistrarAvisoSemExpediente(const ANumero, AMensagem: string): Integer;
    function LimparAvisoAntigos: Integer;
    function LimparAvisoNumero(const ANumero: string): Integer;
        function VerificarAvisoExistente(const ANumero: string): Boolean;
    function BuscarAvisosPorNumero(const ANumero: string): TJSONValue;


    // ============================================
    // Anexos
    // ============================================


    function ListarAnexosPendentes(const ACanal: string = 'WhatsApp'): TJSONValue;
    function BuscarAnexoPorPK(const APK: string): TJSONValue;
    function MarcarAnexoEnviado(const APK: string; AEnviado: Integer = 0): TJSONValue;

    // ============================================
    // Dashboard
    // ============================================

    function GetDashboardYearStats: TDashboard;
    function GetDashboardMonthlyStats(AAno: Integer = 0): TJSONValue;

    procedure DownloadAnexo(const AAtendimentoID, ASeq: Integer;
      const ADestinationPath: string);

    // ============================================
    // Configuração
    // ============================================

    procedure SetTimeout(AMilliseconds: Integer);
    procedure SetDebugMode(AEnabled: Boolean);

    property BaseURL: string read GetBaseURL;
    property IsAuthenticated: Boolean read IsTokenValid;
    property CurrentToken: string read FAccessToken;
    property DebugMode: Boolean read FDebugMode write SetDebugMode;

    // Eventos
    property OnTokenRefresh: TOnTokenRefresh read FOnTokenRefresh write FOnTokenRefresh;
    property OnError: TOnError read FOnError write FOnError;
    property OnRequestLog: TOnRequestLog read FOnRequestLog write FOnRequestLog;
  end;

implementation

// ============================================
// Implementação
// ============================================

constructor TSAWAPIClient.Create(const AUsername, APassword: string;
  const AHost: string = '104.234.173.105'; APort: Integer = 7080);
begin
  inherited Create;

  FHost := AHost;
  FPort := APort;
  FProtocol := 'http';
  FUsername := AUsername;
  FPassword := APassword;
  FTimeout := 30000;
  FDebugMode := False;

  // Criar cliente REST
  FRESTClient := TRESTClient.Create(GetBaseURL);
  FRESTClient.ConnectTimeout := FTimeout;
  FRESTClient.ReadTimeout := FTimeout;

  // Fazer login
  try
    Login(AUsername, APassword);
  except
    on E: Exception do
    begin
      RaiseError('Erro ao inicializar API: ' + E.Message);
      raise;
    end;
  end;
end;

destructor TSAWAPIClient.Destroy;
begin
  if Assigned(FRESTClient) then
    FRESTClient.Free;
  inherited;
end;

// ============================================
// Métodos Privados
// ============================================

function TSAWAPIClient.GetBaseURL: string;
begin
  Result := Format('%s://%s:%d/api/v1', [FProtocol, FHost, FPort]);
end;

function TSAWAPIClient.GetAuthHeader: string;
begin
  Result := 'Bearer ' + FAccessToken;
end;

function TSAWAPIClient.IsTokenValid: Boolean;
begin
  Result := (FAccessToken <> '') and (Now < FTokenExpiry);
end;

procedure TSAWAPIClient.CheckTokenExpiry;
begin
  if not IsTokenValid then
  begin
    if (FRefreshToken <> '') then
      RefreshToken
    else
      raise Exception.Create('Token expirado. Faça login novamente.');
  end;
end;

function TSAWAPIClient.MarcarMensagemExcluida(const AChatID: string): Boolean;
var
  LRequest: TRESTRequest;
  LData: TJSONObject;
  LJSONValue: TJSONValue;
begin
  Result := False;
  try
    CheckTokenExpiry;
    LData := TJSONObject.Create;
    try
      LData.AddPair('chatid', TJSONString.Create(AChatID));
      LRequest := TRESTRequest.Create(nil);
      try
        LRequest.Client := FRESTClient;
        LRequest.Resource := '/mensagens/marcar-excluida';
        LRequest.Method := rmPUT;
        LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
        LRequest.Body.Add(LData.ToString);
        LRequest.Execute;

        if LRequest.Response.StatusCode = 200 then
        begin
          LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
          try
            Result := TJSONObject(LJSONValue).GetValue<Boolean>('sucesso');
          finally
            LJSONValue.Free;
          end;
        end;
      finally
        LRequest.Free;
      end;
    finally
      LData.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('MarcarMensagemExcluida: ' + E.Message);
      Result := False;
    end;
  end;
end;


procedure TSAWAPIClient.RefreshToken;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
  LJSONObject: TJSONObject;
  LBody: TJSONObject;
  LNewToken: string;
begin
  try
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/auth/refresh';
      LRequest.Method := rmPOST;

      // ---------- HEADERS ----------
      LRequest.AddParameter('Content-Type', 'application/json', pkHTTPHEADER);
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);

      // ---------- JSON BODY ----------
      LBody := TJSONObject.Create;
      LBody.AddPair('refresh_token', FRefreshToken);

      LRequest.Body.ClearBody;
      LRequest.Body.Add(LBody.ToString, TRESTContentType.ctAPPLICATION_JSON);

      // ---------- EXECUTA ----------
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          if LJSONValue is TJSONObject then
          begin
            LJSONObject := TJSONObject(LJSONValue);

            LNewToken := LJSONObject
              .GetValue('data')
              .GetValue<string>('token');

            FAccessToken := LNewToken;
            FTokenExpiry := IncSecond(Now, 3600);

            LogRequest('POST', '/auth/refresh', 'Token renovado com sucesso');

            if Assigned(FOnTokenRefresh) then
              FOnTokenRefresh(Self, LNewToken);
          end;
        finally
          LJSONValue.Free;
        end;
      end
      else
        raise Exception.Create('Erro ao renovar token: ' +
                               LRequest.Response.StatusText);
    finally
      LRequest.Free;
    end;

  except
    on E: Exception do
    begin
      RaiseError('Erro ao renovar token: ' + E.Message);
      raise;
    end;
  end;
end;

procedure TSAWAPIClient.LogRequest(const AMethod, AResource, AResponse: string);
begin
  if FDebugMode and Assigned(FOnRequestLog) then
    FOnRequestLog(Self, AMethod, AResource, AResponse);
end;

procedure TSAWAPIClient.RaiseError(const AError: string);
begin
  if Assigned(FOnError) then
    FOnError(Self, AError);
end;

// ============================================
// Autenticação
// ============================================

procedure TSAWAPIClient.Login(const AUsername, APassword: string);
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
  LJSONObject: TJSONObject;
  LBody: TJSONObject;
begin
  try
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/auth/login';
      LRequest.Method := rmPOST;

      // Headers obrigatórios
      LRequest.AddParameter('Content-Type', 'application/json', pkHTTPHEADER);

      // Corpo JSON
      LBody := TJSONObject.Create;
      LBody.AddPair('usuario', AUsername);
      LBody.AddPair('senha', APassword);

      LRequest.Body.ClearBody;
      LRequest.Body.Add(LBody.ToString, TRESTContentType.ctAPPLICATION_JSON);

      // Executa
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          if LJSONValue is TJSONObject then
          begin
            LJSONObject := TJSONObject(LJSONValue);

            FAccessToken := LJSONObject.GetValue('data').GetValue<string>('token');
            FRefreshToken := LJSONObject.GetValue('data').GetValue<string>('refresh_token');
            FTokenExpiry := IncSecond(Now, 3600);

            LogRequest('POST', '/auth/login', 'Login realizado com sucesso');
          end;
        finally
          LJSONValue.Free;
        end;
      end
      else
        raise Exception.Create('Login falhou: ' + LRequest.Response.StatusText);

    finally
      LRequest.Free;
    end;

  except
    on E: Exception do
    begin
      RaiseError('Erro no login: ' + E.Message);
      raise;
    end;
  end;
end;


procedure TSAWAPIClient.Logout;
begin
  FAccessToken := '';
  FRefreshToken := '';
  FTokenExpiry := 0;
end;

function TSAWAPIClient.ValidateToken: Boolean;
var
  LRequest: TRESTRequest;
begin
  Result := False;

  try
    CheckTokenExpiry;

    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/auth/validate';
      LRequest.Method := rmGET;

      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);

      LRequest.Execute;

      Result := LRequest.Response.StatusCode = 200;
      LogRequest('GET', '/auth/validate', 'Token validado: ' + BoolToStr(Result));
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('Erro ao validar token: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TSAWAPIClient.GetTokenExpiration: TDateTime;
begin
  Result := FTokenExpiry;
end;

function TSAWAPIClient.GetTimeRemaining: Integer;
begin
  CheckTokenExpiry;
  Result := SecondsBetween(Now, FTokenExpiry);
  if Result < 0 then
    Result := 0;
end;

// ============================================
// Usuários
// ============================================

function TSAWAPIClient.GetAllUsuarios(APage: Integer = 1; APerPage: Integer = 20): TList<TUsuario>;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
  LArray: TJSONArray;
  LItem: TJSONValue;
  LUsuario: TUsuario;
begin
  Result := TList<TUsuario>.Create;

  try
    CheckTokenExpiry;

    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := Format('/usuarios?page=%d&perPage=%d', [APage, APerPage]);
      LRequest.Method := rmGET;

      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);

      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          if LJSONValue is TJSONObject then
          begin
            LArray := TJSONObject(LJSONValue).GetValue('data')
              .FindValue('usuarios') as TJSONArray;

            for LItem in LArray do
            begin
              if LItem is TJSONObject then
              begin
                LUsuario.ID := TJSONObject(LItem).GetValue<Integer>('id');
                LUsuario.Nome := TJSONObject(LItem).GetValue<string>('nome');
                LUsuario.Email := TJSONObject(LItem).GetValue<string>('email');
                LUsuario.Login := TJSONObject(LItem).GetValue<string>('login');
                LUsuario.Situacao := TJSONObject(LItem).GetValue<string>('situacao');

                Result.Add(LUsuario);
              end;
            end;

            LogRequest('GET', '/usuarios', Format('Retornados %d usuários', [Result.Count]));
          end;
        finally
          LJSONValue.Free;
        end;
      end
      else
        raise Exception.Create('Erro ao buscar usuários: ' + LRequest.Response.StatusText);
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('Erro ao buscar usuários: ' + E.Message);
      Result.Clear;
    end;
  end;
end;

function TSAWAPIClient.GetUsuario(AID: Integer): TUsuario;
begin
  FillChar(Result, SizeOf(TUsuario), 0);
  Result.ID := AID;
  // Implementar conforme necessário
end;

function TSAWAPIClient.GetCurrentUsuario: TUsuario;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
  LJSONObject: TJSONObject;
begin
  FillChar(Result, SizeOf(TUsuario), 0);

  try
    CheckTokenExpiry;

    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/usuarios/me';
      LRequest.Method := rmGET;

      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);

      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          if LJSONValue is TJSONObject then
          begin
            LJSONObject := TJSONObject(LJSONValue).GetValue('data') as TJSONObject;

            Result.ID := LJSONObject.GetValue<Integer>('id');
            Result.Nome := LJSONObject.GetValue<string>('nome');
            Result.Email := LJSONObject.GetValue<string>('email');
            Result.Login := LJSONObject.GetValue<string>('login');
            Result.Situacao := LJSONObject.GetValue<string>('situacao');

            LogRequest('GET', '/usuarios/me', 'Usuário: ' + Result.Nome);
          end;
        finally
          LJSONValue.Free;
        end;
      end
      else
        raise Exception.Create('Erro ao buscar usuário: ' + LRequest.Response.StatusText);
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
      RaiseError('Erro ao buscar usuário: ' + E.Message);
  end;
end;

function TSAWAPIClient.CreateUsuario(AUsuario: TUsuario): Integer;
var
  LRequest: TRESTRequest;
  LData: TJSONObject;
  LJSONValue: TJSONValue;
begin
  Result := 0;

  try
    CheckTokenExpiry;

    LData := TJSONObject.Create;
    try
      LData.AddPair('nome', TJSONString.Create(AUsuario.Nome));
      LData.AddPair('email', TJSONString.Create(AUsuario.Email));
      LData.AddPair('login', TJSONString.Create(AUsuario.Login));
      LData.AddPair('situacao', TJSONString.Create(AUsuario.Situacao));

      LRequest := TRESTRequest.Create(nil);
      try
        LRequest.Client := FRESTClient;
        LRequest.Resource := '/usuarios';
        LRequest.Method := rmPOST;

        LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
        LRequest.Body.Add(LData.ToString);

        LRequest.Execute;

        if LRequest.Response.StatusCode in [200, 201] then
        begin
          LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
          try
            Result := TJSONObject(LJSONValue).GetValue('data').GetValue<Integer>('id');
            LogRequest('POST', '/usuarios', 'Usuário criado: ID ' + IntToStr(Result));
          finally
            LJSONValue.Free;
          end;
        end
        else
          raise Exception.Create('Erro ao criar usuário: ' + LRequest.Response.StatusText);
      finally
        LRequest.Free;
      end;
    finally
      LData.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('Erro ao criar usuário: ' + E.Message);
      Result := 0;
    end;
  end;
end;

function TSAWAPIClient.UpdateUsuario(AUsuario: TUsuario): Boolean;
var
  LRequest: TRESTRequest;
  LData: TJSONObject;
  LJSONValue: TJSONValue;
begin
  Result := False;

  try
    CheckTokenExpiry;

    LData := TJSONObject.Create;
    try
      LData.AddPair('nome', TJSONString.Create(AUsuario.Nome));
      LData.AddPair('email', TJSONString.Create(AUsuario.Email));
      LData.AddPair('situacao', TJSONString.Create(AUsuario.Situacao));

      LRequest := TRESTRequest.Create(nil);
      try
        LRequest.Client := FRESTClient;
        LRequest.Resource := Format('/usuarios/%d', [AUsuario.ID]);
        LRequest.Method := rmPUT;

        LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
        LRequest.Body.Add(LData.ToString);

        LRequest.Execute;

        if LRequest.Response.StatusCode = 200 then
        begin
          LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
          try
            Result := TJSONObject(LJSONValue).GetValue<string>('status') = 'success';
            LogRequest('PUT', Format('/usuarios/%d', [AUsuario.ID]), 'Usuário atualizado');
          finally
            LJSONValue.Free;
          end;
        end
        else
          raise Exception.Create('Erro ao atualizar usuário: ' + LRequest.Response.StatusText);
      finally
        LRequest.Free;
      end;
    finally
      LData.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('Erro ao atualizar usuário: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TSAWAPIClient.DeleteUsuario(AID: Integer): Boolean;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
begin
  Result := False;

  try
    CheckTokenExpiry;

    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := Format('/usuarios/%d', [AID]);
      LRequest.Method := rmDELETE;

      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);

      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          Result := TJSONObject(LJSONValue).GetValue<string>('status') = 'success';
          LogRequest('DELETE', Format('/usuarios/%d', [AID]), 'Usuário deletado');
        finally
          LJSONValue.Free;
        end;
      end
      else
        raise Exception.Create('Erro ao deletar usuário: ' + LRequest.Response.StatusText);
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('Erro ao deletar usuário: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TSAWAPIClient.EnviarArquivo(
  AAtendimentoID: Integer;
  const ACaminhoArquivo, ANomeArquivo, ATipoArquivo: string
): Boolean;
var
  HTTP: THTTPClient;
  Resp: IHTTPResponse;
  Form: TMultipartFormData;
begin
  Result := False;

  HTTP := THTTPClient.Create;
  Form := TMultipartFormData.Create;
  try
    // adiciona o arquivo corretamente
    Form.AddFile('arquivo', ACaminhoArquivo);

    // executa o POST multipart
    Resp := HTTP.Post(
      FBaseURL + Format('/atendimentos/%d/anexos', [AAtendimentoID]),
      Form
    );

    // confirma sucesso HTTP 2xx
    Result := (Resp.StatusCode >= 200) and (Resp.StatusCode < 300);

  finally
    Form.Free;
    HTTP.Free;
  end;
end;

// ============================================
// Atendimentos
// ============================================

//function TSAWAPIClient.FinalizarAtendimento(AID: Integer; const AObservacao: string): Boolean;
//var
//  LRequest: TRESTRequest;
//  LBody: TJSONObject;
//begin
//  Result := False;
//
//  try
//    CheckTokenExpiry;
//
//    LBody := TJSONObject.Create;
//    try
//      if AObservacao <> '' then
//        LBody.AddPair('observacao', AObservacao);
//
//      LRequest := TRESTRequest.Create(nil);
//      try
//        LRequest.Client := FRESTClient;
//        LRequest.Resource := Format('/atendimentos/%d/finalizar', [AID]);
//        LRequest.Method := rmPOST;
//        LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
//        LRequest.Body.Add(LBody.ToString);
//
//        LRequest.Execute;
//
//        Result := LRequest.Response.StatusCode in [200, 201];
//
//      finally
//        LRequest.Free;
//      end;
//    finally
//      LBody.Free;
//    end;
//
//  except
//    on E: Exception do
//      RaiseError('FinalizarAtendimento: ' + E.Message);
//  end;
//end;


function TSAWAPIClient.GetAtendimentoByPhone(const APhone: string): TAtendimento;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
  LJSONObject: TJSONObject;
begin
  FillChar(Result, SizeOf(TAtendimento), 0);

  try
    CheckTokenExpiry;

    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := Format('/atendimentos/por-numero/%s', [APhone]);
      LRequest.Method := rmGET;

      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);

      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          if LJSONValue is TJSONObject then
          begin
            LJSONObject := TJSONObject(LJSONValue).GetValue('data') as TJSONObject;

            Result.ID := LJSONObject.GetValue<Integer>('id');
            Result.Cliente := LJSONObject.GetValue<string>('cliente');
            Result.Setor := LJSONObject.GetValue<string>('setor');
            Result.Assunto := LJSONObject.GetValue<string>('assunto');
            Result.Status := LJSONObject.GetValue<string>('status');

            LogRequest('GET', Format('/atendimentos/por-numero/%s', [APhone]), 'Atendimento encontrado');
          end;
        finally
          LJSONValue.Free;
        end;
      end
      else
        raise Exception.Create('Atendimento não encontrado');
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
      RaiseError('Erro ao buscar atendimento: ' + E.Message);
  end;
end;

function TSAWAPIClient.GetAtendimentoAnexos(AAtendimentoID: Integer): TList<TAnexo>;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
  LArray: TJSONArray;
  LItem: TJSONValue;
  LAnexo: TAnexo;
begin
  Result := TList<TAnexo>.Create;

  try
    CheckTokenExpiry;

    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := Format('/atendimentos/%d/anexos', [AAtendimentoID]);
      LRequest.Method := rmGET;

      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);

      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          if LJSONValue is TJSONObject then
          begin
            LArray := TJSONObject(LJSONValue).GetValue('data')
              .FindValue('anexos') as TJSONArray;

            for LItem in LArray do
            begin
              if LItem is TJSONObject then
              begin
                LAnexo.ID := TJSONObject(LItem).GetValue<Integer>('id');
                LAnexo.AtendimentoID := TJSONObject(LItem).GetValue<Integer>('atendimento_id');
                LAnexo.NomeArquivo := TJSONObject(LItem).GetValue<string>('nome_arquivo');
                LAnexo.TamanhoBytes := TJSONObject(LItem).GetValue<Integer>('tamanho_bytes');
                LAnexo.Downloads := TJSONObject(LItem).GetValue<Integer>('downloads');

                Result.Add(LAnexo);
              end;
            end;

            LogRequest('GET', Format('/atendimentos/%d/anexos', [AAtendimentoID]),
              Format('Retornados %d anexos', [Result.Count]));
          end;
        finally
          LJSONValue.Free;
        end;
      end
      else
        raise Exception.Create('Erro ao buscar anexos: ' + LRequest.Response.StatusText);
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('Erro ao buscar anexos: ' + E.Message);
      Result.Clear;
    end;
  end;
end;

// ============================================
// Anexos
// ============================================

procedure TSAWAPIClient.DownloadAnexo(
  const AAtendimentoID: Integer;
  const ASeq: Integer;
  const ADestinationPath: string);
var
  LRequest: TRESTRequest;
begin
  LRequest := TRESTRequest.Create(nil);
  try
    LRequest.Client := FRESTClient;
    LRequest.Resource := Format('/atendimentos/%d/anexos/%d', [AAtendimentoID, ASeq]);
    LRequest.Method := rmGET;

    LRequest.Execute;

    if LRequest.Response.StatusCode = 200 then
    begin
      // RAWBYTES → salvar arquivo
      TFile.WriteAllBytes(ADestinationPath, LRequest.Response.RawBytes);
    end
    else
      raise Exception.Create('Erro ao baixar anexo: ' + LRequest.Response.StatusText);

  finally
    LRequest.Free;
  end;
end;

function TSAWAPIClient.ListarAnexosPendentes(const ACanal: string = 'WhatsApp'): TJSONValue;
var
  LRequest: TRESTRequest;
begin
  Result := nil;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := Format('/anexos/pendentes?canal=%s', [ACanal]);
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        Result := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        LogRequest('GET', Format('/anexos/pendentes?canal=%s', [ACanal]),
          'Anexos pendentes listados');
      end
      else
        raise Exception.Create('Erro ao listar anexos: ' + LRequest.Response.StatusText);
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('ListarAnexosPendentes: ' + E.Message);
      Result := nil;
    end;
  end;
end;

function TSAWAPIClient.BuscarAnexoPorPK(const APK: string): TJSONValue;
var
  LRequest: TRESTRequest;
begin
  Result := nil;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := Format('/anexos/%s', [APK]);
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        Result := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        LogRequest('GET', Format('/anexos/%s', [APK]), 'Anexo encontrado');
      end
      else if LRequest.Response.StatusCode = 404 then
        raise Exception.Create('Anexo não encontrado')
      else
        raise Exception.Create('Erro ao buscar anexo: ' + LRequest.Response.StatusText);
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('BuscarAnexoPorPK: ' + E.Message);
      Result := nil;
    end;
  end;
end;

function TSAWAPIClient.MarcarAnexoEnviado(const APK: string; AEnviado: Integer = 0): TJSONValue;
var
  LRequest: TRESTRequest;
  LData: TJSONObject;
begin
  Result := nil;
  try
    CheckTokenExpiry;
    LData := TJSONObject.Create;
    try
      LData.AddPair('pk', TJSONString.Create(APK));
      LData.AddPair('enviado', TJSONNumber.Create(AEnviado));

      LRequest := TRESTRequest.Create(nil);
      try
        LRequest.Client := FRESTClient;
        LRequest.Resource := Format('/anexos/%s/marcar-enviado', [APK]);
        LRequest.Method := rmPUT;
        LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
        LRequest.Body.Add(LData.ToString);
        LRequest.Execute;

        if LRequest.Response.StatusCode = 200 then
        begin
          Result := TJSONObject.ParseJSONValue(LRequest.Response.Content);
          LogRequest('PUT', Format('/anexos/%s/marcar-enviado', [APK]),
            'Anexo marcado como ' + IfThen(AEnviado = 0, 'enviado', 'pendente'));
        end
        else
          raise Exception.Create('Erro ao marcar anexo: ' + LRequest.Response.StatusText);
      finally
        LRequest.Free;
      end;
    finally
      LData.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('MarcarAnexoEnviado: ' + E.Message);
      Result := nil;
    end;
  end;
end;

// ============================================
// Dashboard
// ============================================

function TSAWAPIClient.GetDashboardYearStats: TDashboard;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
  LJSONObject: TJSONObject;
begin
  FillChar(Result, SizeOf(TDashboard), 0);

  try
    CheckTokenExpiry;

    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/dashboard/ano-atual';
      LRequest.Method := rmGET;

      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);

      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          if LJSONValue is TJSONObject then
          begin
            LJSONObject := TJSONObject(LJSONValue).GetValue('data') as TJSONObject;

            Result.Ano := LJSONObject.GetValue<Integer>('ano');
            Result.TotalAtendimentos := LJSONObject.GetValue<Integer>('total_atendimentos');
            Result.EmTriagem := LJSONObject.GetValue<Integer>('em_triagem');
            Result.Pendentes := LJSONObject.GetValue<Integer>('pendentes');
            Result.EmAtendimento := LJSONObject.GetValue<Integer>('em_atendimento');
            Result.Finalizados := LJSONObject.GetValue<Integer>('finalizados');
            Result.TaxaConclusao := LJSONObject.GetValue<Double>('taxa_conclusao_percentual');
            Result.TempoMedioAtendimento := LJSONObject.GetValue<Double>('tempo_medio_atendimento_minutos');

            LogRequest('GET', '/dashboard/ano-atual', 'Estatísticas obtidas');
          end;
        finally
          LJSONValue.Free;
        end;
      end
      else
        raise Exception.Create('Erro ao buscar estatísticas: ' + LRequest.Response.StatusText);
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
      RaiseError('Erro ao buscar estatísticas: ' + E.Message);
  end;
end;

function TSAWAPIClient.GetDashboardMonthlyStats(AAno: Integer = 0): TJSONValue;
var
  LRequest: TRESTRequest;
  LResource: string;
begin
  Result := nil;

  try
    CheckTokenExpiry;

    LResource := '/dashboard/atendimentos-mensais';

    if AAno > 0 then
      LResource := LResource + Format('?ano=%d', [AAno]);

    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := LResource;
      LRequest.Method := rmGET;

      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);

      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        Result := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        LogRequest('GET', LResource, 'Estatísticas mensais obtidas');
      end
      else
        raise Exception.Create('Erro ao buscar estatísticas mensais: ' + LRequest.Response.StatusText);
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('Erro ao buscar estatísticas mensais: ' + E.Message);
      Result := nil;
    end;
  end;
end;

// ============================================
// Configuração
// ============================================

procedure TSAWAPIClient.SetTimeout(AMilliseconds: Integer);
begin
  FTimeout := AMilliseconds;
  if Assigned(FRESTClient) then
  begin
    FRESTClient.ConnectTimeout := FTimeout;
    FRESTClient.ReadTimeout := FTimeout;
  end;
end;

procedure TSAWAPIClient.SetDebugMode(AEnabled: Boolean);
begin
  FDebugMode := AEnabled;
end;

// ============================================
// Novos Endpoints - Atendimentos
// ============================================

function TSAWAPIClient.VerificarAtendimentoPendente(const ANumero: string): Boolean;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
begin
  Result := False;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := Format('/atendimentos/verificar-pendente?numero=%s', [ANumero]);
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          Result := TJSONObject(LJSONValue).GetValue('data').GetValue<Boolean>('existe');
        finally
          LJSONValue.Free;
        end;
      end;
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
      RaiseError('VerificarAtendimentoPendente: ' + E.Message);
  end;
end;

function TSAWAPIClient.CriarAtendimento(const ANumero, ANome: string; AIDAtendente: Integer = 0;
  const ANomeAtendente: string = ''; const ASituacao: string = 'P';
  const ACanal: string = ''; const ASetor: string = ''): Integer;
var
  LRequest: TRESTRequest;
  LData: TJSONObject;
  LJSONValue: TJSONValue;
begin
  Result := 0;
  try
    CheckTokenExpiry;
    LData := TJSONObject.Create;
    try
      LData.AddPair('numero', TJSONString.Create(ANumero));
      LData.AddPair('nome', TJSONString.Create(ANome));

      if AIDAtendente > 0 then
        LData.AddPair('id_atendente', TJSONNumber.Create(AIDAtendente));

      if ANomeAtendente <> '' then
        LData.AddPair('nome_atendente', TJSONString.Create(ANomeAtendente));

      if ASituacao <> 'P' then
        LData.AddPair('situacao', TJSONString.Create(ASituacao));

      if ACanal <> '' then
        LData.AddPair('canal', TJSONString.Create(ACanal));

      if ASetor <> '' then
        LData.AddPair('setor', TJSONString.Create(ASetor));

      LRequest := TRESTRequest.Create(nil);
      try
        LRequest.Client := FRESTClient;
        LRequest.Resource := '/atendimentos';
        LRequest.Method := rmPOST;
        LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
        LRequest.Body.Add(LData.ToString);
        LRequest.Execute;

        if LRequest.Response.StatusCode in [200, 201] then
        begin
          LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
          try
            Result := TJSONObject(LJSONValue).GetValue('data').GetValue<Integer>('id');
            LogRequest('POST', '/atendimentos', 'Atendimento ID: ' + IntToStr(Result));
          finally
            LJSONValue.Free;
          end;
        end;
      finally
        LRequest.Free;
      end;
    finally
      LData.Free;
    end;
  except
    on E: Exception do
      RaiseError('CriarAtendimento: ' + E.Message);
  end;
end;

function TSAWAPIClient.FinalizarAtendimento(AID: Integer): Boolean;
var
  LRequest: TRESTRequest;
  LData: TJSONObject;
begin
  Result := False;
  try
    CheckTokenExpiry;
    LData := TJSONObject.Create;
    try
      LData.AddPair('id_atendimento', TJSONNumber.Create(AID));

      LRequest := TRESTRequest.Create(nil);
      try
        LRequest.Client := FRESTClient;
        LRequest.Resource := '/atendimentos/finalizar';
        LRequest.Method := rmPUT;
        LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
        LRequest.Body.Add(LData.ToString);
        LRequest.Execute;

        Result := LRequest.Response.StatusCode = 200;
        LogRequest('PUT', '/atendimentos/finalizar', 'Status: ' + IntToStr(LRequest.Response.StatusCode));
      finally
        LRequest.Free;
      end;
    finally
      LData.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('FinalizarAtendimento: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TSAWAPIClient.GravarMensagemAtendimento(AAtendimentoID: Integer; const AMensagem: string): Boolean;
var
  LRequest: TRESTRequest;
  LData: TJSONObject;
begin
  Result := False;
  try
    CheckTokenExpiry;
    LData := TJSONObject.Create;
    try
      LData.AddPair('id_atendimento', TJSONNumber.Create(AAtendimentoID));
      LData.AddPair('mensagem', TJSONString.Create(AMensagem));

      LRequest := TRESTRequest.Create(nil);
      try
        LRequest.Client := FRESTClient;
        LRequest.Resource := '/atendimentos/gravar-mensagem';
        LRequest.Method := rmPOST;
        LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
        LRequest.Body.Add(LData.ToString);
        LRequest.Execute;

        Result := LRequest.Response.StatusCode in [200, 201];
      finally
        LRequest.Free;
      end;
    finally
      LData.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('GravarMensagemAtendimento: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TSAWAPIClient.AtualizarSetorAtendimento(AAtendimentoID: Integer; const ASetor: string): Boolean;
var
  LRequest: TRESTRequest;
  LData: TJSONObject;
begin
  Result := False;
  try
    CheckTokenExpiry;
    LData := TJSONObject.Create;
    try
      LData.AddPair('id_atendimento', TJSONNumber.Create(AAtendimentoID));
      LData.AddPair('setor', TJSONString.Create(ASetor));

      LRequest := TRESTRequest.Create(nil);
      try
        LRequest.Client := FRESTClient;
        LRequest.Resource := '/atendimentos/atualizar-setor';
        LRequest.Method := rmPUT;
        LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
        LRequest.Body.Add(LData.ToString);
        LRequest.Execute;

        Result := LRequest.Response.StatusCode = 200;
      finally
        LRequest.Free;
      end;
    finally
      LData.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('AtualizarSetorAtendimento: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TSAWAPIClient.ListarAtendimentosInativos(ATempoMinutos: Integer = 5): TList<TAtendimento>;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
  LArray: TJSONArray;
  LItem: TJSONValue;
  LAtendimento: TAtendimento;
begin
  Result := TList<TAtendimento>.Create;
  try
    CheckTokenExpiry;

    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := Format('/atendimentos/inativos?tempo_minutos=%d', [ATempoMinutos]);
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          LArray := TJSONObject(LJSONValue).GetValue('data').FindValue('inativos') as TJSONArray;
          for LItem in LArray do
          begin
            if LItem is TJSONObject then
            begin
              FillChar(LAtendimento, SizeOf(LAtendimento), 0);
              LAtendimento.ID := TJSONObject(LItem).GetValue<Integer>('id');
              Result.Add(LAtendimento);
            end;
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
      RaiseError('ListarAtendimentosInativos: ' + E.Message);
      Result.Clear;
    end;
  end;
end;

// ============================================
// Novos Endpoints - Mensagens
// ============================================

function TSAWAPIClient.VerificarMensagemDuplicada(const AChatID: string): Boolean;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
begin
  Result := False;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := Format('/mensagens/verificar-duplicada?chatid=%s', [AChatID]);
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          Result := TJSONObject(LJSONValue).GetValue('data').GetValue<Boolean>('existe');
        finally
          LJSONValue.Free;
        end;
      end;
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
      RaiseError('VerificarMensagemDuplicada: ' + E.Message);
  end;
end;

function TSAWAPIClient.GetStatusMultiplasMensagens: TJSONValue;
var
  LRequest: TRESTRequest;
begin
  Result := nil;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/mensagens/status-multiplas';
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
        Result := TJSONObject.ParseJSONValue(LRequest.Response.Content);
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
      RaiseError('GetStatusMultiplasMensagens: ' + E.Message);
  end;
end;

function TSAWAPIClient.ListarMensagensParaEnviar: TList<TMensagem>;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
  LArray: TJSONArray;
  LItem: TJSONValue;
  LMensagem: TMensagem;
begin
  Result := TList<TMensagem>.Create;
  try
    CheckTokenExpiry;

    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/mensagens/pendentes-envio';
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          LArray := TJSONObject(LJSONValue).GetValue('data').FindValue('mensagens') as TJSONArray;
          for LItem in LArray do
          begin
            if LItem is TJSONObject then
            begin
              FillChar(LMensagem, SizeOf(LMensagem), 0);
              LMensagem.ID := TJSONObject(LItem).GetValue<Integer>('id');
              LMensagem.Conteudo := TJSONObject(LItem).GetValue<string>('mensagem');
              LMensagem.Situacao := TJSONObject(LItem).GetValue<string>('situacao');
              Result.Add(LMensagem);
            end;
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
      RaiseError('ListarMensagensParaEnviar: ' + E.Message);
      Result.Clear;
    end;
  end;
end;

function TSAWAPIClient.ProximaSequenciaMensagem(AAtendimentoID: Integer): Integer;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
begin
  Result := 0;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := Format('/mensagens/proxima-sequencia?id_atendimento=%d', [AAtendimentoID]);
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          Result := TJSONObject(LJSONValue).GetValue('data').GetValue<Integer>('seq');
        finally
          LJSONValue.Free;
        end;
      end;
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
      RaiseError('ProximaSequenciaMensagem: ' + E.Message);
  end;
end;

//function TSAWAPIClient.MarcarMensagemExcluida(const AChatID: string): Boolean;
//var
//  LRequest: TRESTRequest;
//  LData: TJSONObject;
//begin
//  Result := False;
//  try
//    CheckTokenExpiry;
//    LData := TJSONObject.Create;
//    try
//      LData.AddPair('chatid', TJSONString.Create(AChatID));
//      LRequest := TRESTRequest.Create(nil);
//      try
//        LRequest.Client := FRESTClient;
//        LRequest.Resource := '/mensagens/marcar-excluida';
//        LRequest.Method := rmPUT;
//        LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
//        LRequest.Body.Add(LData.ToString);
//        LRequest.Execute;
//        Result := LRequest.Response.StatusCode = 200;
//      finally
//        LRequest.Free;
//      end;
//    finally
//      LData.Free;
//    end;
//  except
//    on E: Exception do
//    begin
//      RaiseError('MarcarMensagemExcluida: ' + E.Message);
//      Result := False;
//    end;
//  end;
//end;

function TSAWAPIClient.MarcarMensagemReacao(const AChatID, AReacao: string): Boolean;
var
  LRequest: TRESTRequest;
  LData: TJSONObject;
begin
  Result := False;
  try
    CheckTokenExpiry;
    LData := TJSONObject.Create;
    try
      LData.AddPair('chatid', TJSONString.Create(AChatID));
      LData.AddPair('reacao', TJSONString.Create(AReacao));
      LRequest := TRESTRequest.Create(nil);
      try
        LRequest.Client := FRESTClient;
        LRequest.Resource := '/mensagens/marcar-reacao';
        LRequest.Method := rmPUT;
        LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
        LRequest.Body.Add(LData.ToString);
        LRequest.Execute;
        Result := LRequest.Response.StatusCode = 200;
      finally
        LRequest.Free;
      end;
    finally
      LData.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('MarcarMensagemReacao: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TSAWAPIClient.MarcarMensagemEnviada(AID: Integer): Boolean;
var
  LRequest: TRESTRequest;
  LData: TJSONObject;
begin
  Result := False;
  try
    CheckTokenExpiry;
    LData := TJSONObject.Create;
    try
      LData.AddPair('id_agendamento', TJSONNumber.Create(AID));
      LRequest := TRESTRequest.Create(nil);
      try
        LRequest.Client := FRESTClient;
        LRequest.Resource := '/mensagens/marcar-enviada';
        LRequest.Method := rmPUT;
        LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
        LRequest.Body.Add(LData.ToString);
        LRequest.Execute;
        Result := LRequest.Response.StatusCode = 200;
      finally
        LRequest.Free;
      end;
    finally
      LData.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('MarcarMensagemEnviada: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TSAWAPIClient.CompararDuplicacaoMensagem(AID: Integer; const AMensagem: string): Boolean;
var
  LRequest: TRESTRequest;
  LData: TJSONObject;
  LJSONValue: TJSONValue;
begin
  Result := False;
  try
    CheckTokenExpiry;
    LData := TJSONObject.Create;
    try
      LData.AddPair('id', TJSONNumber.Create(AID));
      LData.AddPair('msg_atual', TJSONString.Create(AMensagem));
      LRequest := TRESTRequest.Create(nil);
      try
        LRequest.Client := FRESTClient;
        LRequest.Resource := '/mensagens/comparar-duplicacao';
        LRequest.Method := rmPOST;
        LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
        LRequest.Body.Add(LData.ToString);
        LRequest.Execute;

        if LRequest.Response.StatusCode = 200 then
        begin
          LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
          try
            Result := TJSONObject(LJSONValue).GetValue('data').GetValue<Boolean>('eh_duplicada');
          finally
            LJSONValue.Free;
          end;
        end;
      finally
        LRequest.Free;
      end;
    finally
      LData.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('CompararDuplicacaoMensagem: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TSAWAPIClient.AtualizarEnvioMensagem(AIDAgendamento: Integer; AEnviado: Integer; ATempoEnvio: Integer): Boolean;
var
  LRequest: TRESTRequest;
  LData: TJSONObject;
  LJSONValue: TJSONValue;
begin
  Result := False;
  try
    CheckTokenExpiry;
    LData := TJSONObject.Create;
    try
      LData.AddPair('id_agendamento', TJSONNumber.Create(AIDAgendamento));
      LData.AddPair('enviado', TJSONNumber.Create(AEnviado));
      LData.AddPair('tempo_envio', TJSONNumber.Create(ATempoEnvio));
      LRequest := TRESTRequest.Create(nil);
      try
        LRequest.Client := FRESTClient;
        LRequest.Resource := '/mensagens/atualizar-envio';
        LRequest.Method := rmPUT;
        LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
        LRequest.Body.Add(LData.ToString);
        LRequest.Execute;

        if LRequest.Response.StatusCode = 200 then
        begin
          LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
          try
            Result := TJSONObject(LJSONValue).GetValue<Boolean>('sucesso');
          finally
            LJSONValue.Free;
          end;
        end;
      finally
        LRequest.Free;
      end;
    finally
      LData.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('AtualizarEnvioMensagem: ' + E.Message);
      Result := False;
    end;
  end;
end;

// ============================================
// Novos Endpoints - Contatos
// ============================================

function TSAWAPIClient.ExportarContatos(APagina: Integer = 1; ALimite: Integer = 20): TList<TContato>;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
  LArray: TJSONArray;
  LItem: TJSONValue;
  LContato: TContato;
begin
  Result := TList<TContato>.Create;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := Format('/contatos/exportar?pagina=%d&limite=%d', [APagina, ALimite]);
      LRequest.Method := rmPOST;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          LArray := TJSONObject(LJSONValue).GetValue('data').FindValue('contatos') as TJSONArray;
          for LItem in LArray do
          begin
            if LItem is TJSONObject then
            begin
              FillChar(LContato, SizeOf(LContato), 0);
              LContato.ID := TJSONObject(LItem).GetValue<Integer>('id');
              LContato.Nome := TJSONObject(LItem).GetValue<string>('nome');
              LContato.Telefone := TJSONObject(LItem).GetValue<string>('telefone');
              Result.Add(LContato);
            end;
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
      RaiseError('ExportarContatos: ' + E.Message);
      Result.Clear;
    end;
  end;
end;

function TSAWAPIClient.BuscarNomeContato(const ANumero: string): string;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
begin
  Result := '';
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := Format('/contatos/buscar-nome?numero=%s', [ANumero]);
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          Result := TJSONObject(LJSONValue).GetValue('data').GetValue<string>('nome');
        finally
          LJSONValue.Free;
        end;
      end;
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
      RaiseError('BuscarNomeContato: ' + E.Message);
  end;
end;

// ============================================
// Novos Endpoints - Agendamentos
// ============================================

function TSAWAPIClient.ListarAgendamentosPendentes: TJSONValue;
var
  LRequest: TRESTRequest;
begin
  Result := nil;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/agendamentos/pendentes';
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
        Result := TJSONObject.ParseJSONValue(LRequest.Response.Content);
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
      RaiseError('ListarAgendamentosPendentes: ' + E.Message);
  end;
end;

// ============================================
// Novos Endpoints - Parâmetros
// ============================================

function TSAWAPIClient.GetParametrosSistema: TJSONValue;
var
  LRequest: TRESTRequest;
begin
  Result := nil;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/parametros/sistema';
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
        Result := TJSONObject.ParseJSONValue(LRequest.Response.Content);
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
      RaiseError('GetParametrosSistema: ' + E.Message);
  end;
end;

function TSAWAPIClient.VerificarExpediente: TJSONValue;
var
  LRequest: TRESTRequest;
begin
  Result := nil;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/parametros/verificar-expediente';
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
        Result := TJSONObject.ParseJSONValue(LRequest.Response.Content);
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
      RaiseError('VerificarExpediente: ' + E.Message);
  end;
end;

// ============================================
// Novos Endpoints - Menus
// ============================================

function TSAWAPIClient.GetMenuPrincipal: TList<TMenu>;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
  LArray: TJSONArray;
  LItem: TJSONValue;
  LMenu: TMenu;
begin
  Result := TList<TMenu>.Create;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/menus/principal';
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          LArray := TJSONObject(LJSONValue).GetValue('data').FindValue('menus') as TJSONArray;
          for LItem in LArray do
          begin
            if LItem is TJSONObject then
            begin
              FillChar(LMenu, SizeOf(LMenu), 0);
              LMenu.ID := TJSONObject(LItem).GetValue<Integer>('id');
              LMenu.Nome := TJSONObject(LItem).GetValue<string>('nome');
              Result.Add(LMenu);
            end;
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
      RaiseError('GetMenuPrincipal: ' + E.Message);
      Result.Clear;
    end;
  end;
end;

function TSAWAPIClient.GetSubmenus: TList<TMenu>;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
  LArray: TJSONArray;
  LItem: TJSONValue;
  LMenu: TMenu;
begin
  Result := TList<TMenu>.Create;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/menus/submenus';
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          LArray := TJSONObject(LJSONValue).GetValue('data').FindValue('submenus') as TJSONArray;
          for LItem in LArray do
          begin
            if LItem is TJSONObject then
            begin
              FillChar(LMenu, SizeOf(LMenu), 0);
              LMenu.ID := TJSONObject(LItem).GetValue<Integer>('id');
              LMenu.Nome := TJSONObject(LItem).GetValue<string>('nome');
              Result.Add(LMenu);
            end;
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
      RaiseError('GetSubmenus: ' + E.Message);
      Result.Clear;
    end;
  end;
end;

// ============================================
// Novos Endpoints - Respostas
// ============================================

function TSAWAPIClient.GetRespostasAutomaticas(AIDMenu: Integer): TJSONValue;
var
  LRequest: TRESTRequest;
begin
  Result := nil;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := Format('/respostas-automaticas?id_menu=%d', [AIDMenu]);
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
        Result := TJSONObject.ParseJSONValue(LRequest.Response.Content);
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
      RaiseError('GetRespostasAutomaticas: ' + E.Message);
  end;
end;

// ============================================
// Novos Endpoints - Departamentos
// ============================================

function TSAWAPIClient.GetDepartamentoPorMenu(AIDMenu: Integer): TJSONValue;
var
  LRequest: TRESTRequest;
begin
  Result := nil;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := Format('/departamentos/por-menu?id_menu=%d', [AIDMenu]);
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
        Result := TJSONObject.ParseJSONValue(LRequest.Response.Content);
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
      RaiseError('GetDepartamentoPorMenu: ' + E.Message);
  end;
end;

// ============================================
// Novos Endpoints - Avisos
// ============================================

function TSAWAPIClient.RegistrarAvisoSemExpediente(const ANumero, AMensagem: string): Integer;
var
  LRequest: TRESTRequest;
  LData: TJSONObject;
  LJSONValue: TJSONValue;
begin
  Result := 0;
  try
    CheckTokenExpiry;
    LData := TJSONObject.Create;
    try
      LData.AddPair('numero', TJSONString.Create(ANumero));
      LData.AddPair('mensagem', TJSONString.Create(AMensagem));
      LRequest := TRESTRequest.Create(nil);
      try
        LRequest.Client := FRESTClient;
        LRequest.Resource := '/avisos/registrar-sem-expediente';
        LRequest.Method := rmPOST;
        LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
        LRequest.Body.Add(LData.ToString);
        LRequest.Execute;

        if LRequest.Response.StatusCode in [200, 201] then
        begin
          LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
          try
            Result := TJSONObject(LJSONValue).GetValue('data').GetValue<Integer>('id');
          finally
            LJSONValue.Free;
          end;
        end;
      finally
        LRequest.Free;
      end;
    finally
      LData.Free;
    end;
  except
    on E: Exception do
      RaiseError('RegistrarAvisoSemExpediente: ' + E.Message);
  end;
end;

function TSAWAPIClient.LimparAvisoAntigos: Integer;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
begin
  Result := 0;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/avisos/limpar-antigos';
      LRequest.Method := rmDELETE;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          Result := TJSONObject(LJSONValue).GetValue('data').GetValue<Integer>('rows_deleted');
        finally
          LJSONValue.Free;
        end;
      end;
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
      RaiseError('LimparAvisoAntigos: ' + E.Message);
  end;
end;

function TSAWAPIClient.LimparAvisoNumero(const ANumero: string): Integer;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
begin
  Result := 0;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := Format('/avisos/limpar-numero?numero=%s', [ANumero]);
      LRequest.Method := rmDELETE;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          Result := TJSONObject(LJSONValue).GetValue('data').GetValue<Integer>('rows_deleted');
        finally
          LJSONValue.Free;
        end;
      end;
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
      RaiseError('LimparAvisoNumero: ' + E.Message);
  end;
end;

function TSAWAPIClient.VerificarAvisoExistente(const ANumero: string): Boolean;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
begin
  Result := False;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := Format('/avisos/verificar-existente?numero=%s', [ANumero]);
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          Result := TJSONObject(LJSONValue).GetValue('data').GetValue<Boolean>('existe');
        finally
          LJSONValue.Free;
        end;
      end;
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
      RaiseError('VerificarAvisoExistente: ' + E.Message);
  end;
end;

function TSAWAPIClient.BuscarAvisosPorNumero(const ANumero: string): TJSONValue;
var
  LRequest: TRESTRequest;
begin
  Result := nil;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := Format('/avisos/buscar-por-numero?numero=%s', [ANumero]);
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        Result := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        LogRequest('GET', Format('/avisos/buscar-por-numero?numero=%s', [ANumero]),
          'Avisos retornados');
      end
      else
        raise Exception.Create('Erro ao buscar avisos: ' + LRequest.Response.StatusText);
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('BuscarAvisosPorNumero: ' + E.Message);
      Result := nil;
    end;
  end;
end;

// ============================================
// MÉTODOS - MENSAGENS STATUS (SINCRONIZAÇÃO)
// ============================================

{ Listar mensagens pendentes de verificação de status
  O Delphi chama WPPConnect.getMessageById() para cada mensagem e recebe os status reais

  Parâmetros:
  - ACanal: Canal de atendimento (ex: 'whatsapp')
  - AHorasAtras: Horas retroativas (padrão: 24)
  - AMinutosFuturos: Minutos para frente (padrão: 10)
}
function TSAWAPIClient.ListarMensagensStatusPendentes(const ACanal: string;
  AHorasAtras: Integer = 24; AMinutosFuturos: Integer = 10): TJSONValue;
var
  LRequest: TRESTRequest;
  LResource: string;
begin
  Result := nil;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LResource := Format('/mensagens/pendentes-status?canal=%s&horas_atras=%d&minutos_futuros=%d',
        [ACanal, AHorasAtras, AMinutosFuturos]);
      LRequest.Resource := LResource;
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
        Result := TJSONObject.ParseJSONValue(LRequest.Response.Content)
      else
        RaiseError(Format('Erro ao listar mensagens pendentes: %d', [LRequest.Response.StatusCode]));
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('ListarMensagensStatusPendentes: ' + E.Message);
      Result := nil;
    end;
  end;
end;

{ Atualizar status de uma mensagem após WPPConnect verificar

  Parâmetros:
  - AIdMsg: ID da mensagem
  - AChatID: ID da conversa
  - ANovoStatus: Novo status obtido do WPPConnect (0=Pendente, 1=Enviada, 2=Entregue, 3=Lida, 4=Erro)
}
function TSAWAPIClient.AtualizarStatusMensagem(AIdMsg: Integer;
  const AChatID: string; ANovoStatus: Integer): Boolean;
var
  LRequest: TRESTRequest;
  LJSONBody: TJSONObject;
begin
  Result := False;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/mensagens/status/atualizar';
      LRequest.Method := rmPOST;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);

      LJSONBody := TJSONObject.Create;
      try
        LJSONBody.AddPair('id_msg', TJSONNumber.Create(AIdMsg));
        LJSONBody.AddPair('chatid', AChatID);
        LJSONBody.AddPair('novo_status', TJSONNumber.Create(ANovoStatus));

        LRequest.Body.Add(LJSONBody.ToString);
        LRequest.Execute;

        Result := LRequest.Response.StatusCode = 200;
        if not Result then
          RaiseError(Format('Erro ao atualizar status: %d', [LRequest.Response.StatusCode]));
      finally
        LJSONBody.Free;
      end;
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('AtualizarStatusMensagem: ' + E.Message);
      Result := False;
    end;
  end;
end;

{ Processar múltiplas atualizações de status em lote
  Útil quando o Delphi verifica várias mensagens via WPPConnect e precisa atualizar múltiplas de uma vez

  Parâmetros:
  - AAtualizacoes: Array de objects com {id_msg, chatid, novo_status}

 { Exemplo:
  var
    Atualizacoes: TJSONArray;
    Item: TJSONObject;
  begin
    Atualizacoes := TJSONArray.Create;
    Item := TJSONObject.Create;
    Item.AddPair('id_msg', TJSONNumber.Create(1));
    Item.AddPair('chatid', '5585987654321@c.us');
    Item.AddPair('novo_status', TJSONNumber.Create(2));
    Atualizacoes.Add(Item);

    Result := API.ProcessarMultiplasAtualizacoesStatus(Atualizacoes);
  end;
}
function TSAWAPIClient.ProcessarMultiplasAtualizacoesStatus(
  const AAtualizacoes: TJSONArray
): TJSONValue;
var
  LRequest: TRESTRequest;
begin
  Result := nil;

  try
    CheckTokenExpiry;

    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/mensagens/status/processar-mult';
      LRequest.Method := rmPOST;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.AddParameter('Content-Type', 'application/json', pkHTTPHEADER);


      LRequest.Body.Add(AAtualizacoes.ToString, TRESTContentType.ctAPPLICATION_JSON);

      LRequest.Execute;

      if LRequest.Response.StatusCode in [200, 201] then
        Result := TJSONObject.ParseJSONValue(LRequest.Response.Content);

    finally
      LRequest.Free;
    end;

  except
    on E: Exception do
      RaiseError('ProcessarMultiplasAtualizacoesStatus: ' + E.Message);
  end;
end;

{ Obter relatório de mensagens por status

  Parâmetros:
  - ACanal: Canal de atendimento
  - ADataIni: Data inicial (formato: YYYY-MM-DD)
  - ADataFim: Data final (formato: YYYY-MM-DD)
}
function TSAWAPIClient.ObterRelatorioStatusMensagens(const ACanal: string;
  ADataIni: TDate = 0; ADataFim: TDate = 0): TJSONValue;
var
  LRequest: TRESTRequest;
  LResource: string;
  LDataIniStr, LDataFimStr: string;
begin
  Result := nil;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      // Usar datas padrão se não informadas
      if ADataIni = 0 then
        ADataIni := IncDay(Now, -7);
      if ADataFim = 0 then
        ADataFim := Now;

      LDataIniStr := FormatDateTime('YYYY-MM-DD', ADataIni);
      LDataFimStr := FormatDateTime('YYYY-MM-DD', ADataFim);

      LRequest.Client := FRESTClient;
      LResource := Format('/mensagens/status/relatorio?canal=%s&data_ini=%s&data_fim=%s',
        [ACanal, LDataIniStr, LDataFimStr]);
      LRequest.Resource := LResource;
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
        Result := TJSONObject.ParseJSONValue(LRequest.Response.Content)
      else
        RaiseError(Format('Erro ao obter relatório: %d', [LRequest.Response.StatusCode]));
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('ObterRelatorioStatusMensagens: ' + E.Message);
      Result := nil;
    end;
  end;
end;

// ============================================
// MÉTODOS - BANCO DE DADOS
// ============================================

{ Listar todas as tabelas do banco de dados
}
function TSAWAPIClient.ListarTabelas: TJSONValue;
var
  LRequest: TRESTRequest;
begin
  Result := nil;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/banco-dados/tabelas';
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
        Result := TJSONObject.ParseJSONValue(LRequest.Response.Content)
      else
        RaiseError(Format('Erro ao listar tabelas: %d', [LRequest.Response.StatusCode]));
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('ListarTabelas: ' + E.Message);
      Result := nil;
    end;
  end;
end;

{ Verificar se uma tabela existe no banco de dados
  Equivalente a: TabelaExistenoMYSQL(NomeTabela, BancoDados)
  
  Parâmetros:
  - ANomeTabela: Nome da tabela a verificar
}
function TSAWAPIClient.TabelaExiste(const ANomeTabela: string): Boolean;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
  LResource: string;
begin
  Result := False;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LResource := Format('/banco-dados/tabela/existe?tabela=%s', [ANomeTabela]);
      LRequest.Resource := LResource;
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          Result := TJSONObject(LJSONValue).GetValue('data').GetValue<Boolean>('existe');
        finally
          LJSONValue.Free;
        end;
      end
      else
        RaiseError(Format('Erro ao verificar tabela: %d', [LRequest.Response.StatusCode]));
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('TabelaExiste: ' + E.Message);
      Result := False;
    end;
  end;
end;

{ Verificar se um campo existe em uma tabela
  Equivalente a: CampoExiste(NomeTabela, NomeCampo, Conexao)
  
  Parâmetros:
  - ANomeTabela: Nome da tabela
  - ANomeCampo: Nome do campo
}
function TSAWAPIClient.CampoExiste(const ANomeTabela, ANomeCampo: string): Boolean;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
  LResource: string;
begin
  Result := False;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LResource := Format('/banco-dados/campo/existe?tabela=%s&campo=%s', 
        [ANomeTabela, ANomeCampo]);
      LRequest.Resource := LResource;
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          Result := TJSONObject(LJSONValue).GetValue('data').GetValue<Boolean>('existe');
        finally
          LJSONValue.Free;
        end;
      end
      else
        RaiseError(Format('Erro ao verificar campo: %d', [LRequest.Response.StatusCode]));
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('CampoExiste: ' + E.Message);
      Result := False;
    end;
  end;
end;

{ Obter estrutura completa de uma tabela
  
  Parâmetros:
  - ANomeTabela: Nome da tabela
}
function TSAWAPIClient.ObterEstruturatTabela(const ANomeTabela: string): TJSONValue;
var
  LRequest: TRESTRequest;
  LResource: string;
begin
  Result := nil;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LResource := Format('/banco-dados/tabela/estrutura?tabela=%s', [ANomeTabela]);
      LRequest.Resource := LResource;
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
        Result := TJSONObject.ParseJSONValue(LRequest.Response.Content)
      else
        RaiseError(Format('Erro ao obter estrutura: %d', [LRequest.Response.StatusCode]));
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('ObterEstruturatTabela: ' + E.Message);
      Result := nil;
    end;
  end;
end;

{ Obter informações detalhadas de um campo
  
  Parâmetros:
  - ANomeTabela: Nome da tabela
  - ANomeCampo: Nome do campo
}
function TSAWAPIClient.ObterInfoCampo(const ANomeTabela, ANomeCampo: string): TJSONValue;
var
  LRequest: TRESTRequest;
  LResource: string;
begin
  Result := nil;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LResource := Format('/banco-dados/campo/info?tabela=%s&campo=%s', 
        [ANomeTabela, ANomeCampo]);
      LRequest.Resource := LResource;
      LRequest.Method := rmGET;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);
      LRequest.Execute;

      if LRequest.Response.StatusCode = 200 then
        Result := TJSONObject.ParseJSONValue(LRequest.Response.Content)
      else
        RaiseError(Format('Erro ao obter info do campo: %d', [LRequest.Response.StatusCode]));
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('ObterInfoCampo: ' + E.Message);
      Result := nil;
    end;
  end;
end;

{ Criar nova tabela (ADMIN ONLY)
  
  Parâmetros:
  - ANome: Nome da tabela
  - ACampos: TJSONArray com definição dos campos
}
function TSAWAPIClient.CriarTabela(const ANome: string; const ACampos: TJSONArray): Boolean;
var
  LRequest: TRESTRequest;
  LJSONBody: TJSONObject;
begin
  Result := False;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/banco-dados/tabela/criar';
      LRequest.Method := rmPOST;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);

      LJSONBody := TJSONObject.Create;
      try
        LJSONBody.AddPair('nome', ANome);
        LJSONBody.AddPair('campos', ACampos);

        LRequest.Body.Add(LJSONBody.ToString);
        LRequest.Execute;

        Result := LRequest.Response.StatusCode = 200;
        if not Result then
          RaiseError(Format('Erro ao criar tabela: %d', [LRequest.Response.StatusCode]));
      finally
        LJSONBody.Free;
      end;
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('CriarTabela: ' + E.Message);
      Result := False;
    end;
  end;
end;

{ Adicionar campo a uma tabela (ADMIN ONLY)
  
  Parâmetros:
  - ATabela: Nome da tabela
  - ANomeCampo: Nome do novo campo
  - ATipo: Tipo do campo (ex: 'VARCHAR(255)', 'INT', etc)
  - APermiteNull: Se permite NULL
}
function TSAWAPIClient.AdicionarCampo(const ATabela, ANomeCampo, ATipo: string; 
  APermiteNull: Boolean = True): Boolean;
var
  LRequest: TRESTRequest;
  LJSONBody: TJSONObject;
begin
  Result := False;
  try
    CheckTokenExpiry;
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/banco-dados/campo/adicionar';
      LRequest.Method := rmPOST;
      LRequest.AddParameter('Authorization', GetAuthHeader, pkHTTPHEADER);

      LJSONBody := TJSONObject.Create;
      try
        LJSONBody.AddPair('tabela', ATabela);
        LJSONBody.AddPair('nome', ANomeCampo);
        LJSONBody.AddPair('tipo', ATipo);
        LJSONBody.AddPair('permite_null', TJSONBool.Create(APermiteNull));

        LRequest.Body.Add(LJSONBody.ToString);
        LRequest.Execute;

        Result := LRequest.Response.StatusCode = 200;
        if not Result then
          RaiseError(Format('Erro ao adicionar campo: %d', [LRequest.Response.StatusCode]));
      finally
        LJSONBody.Free;
      end;
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('AdicionarCampo: ' + E.Message);
      Result := False;
    end;
  end;
end;

end.
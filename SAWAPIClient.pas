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
  REST.Client, REST.Types, System.DateUtils;

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
    
    // Métodos privados
    function GetBaseURL: string;
    function GetAuthHeader: string;
    function IsTokenValid: Boolean;
    procedure RefreshToken;
    procedure CheckTokenExpiry;
    procedure LogRequest(const AMethod, AResource, AResponse: string);
    procedure RaiseError(const AError: string);
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

    // ============================================
    // Anexos
    // ============================================

    function DownloadAnexo(AAnexoID: Integer; const ADestinationPath: string): Boolean;

    // ============================================
    // Dashboard
    // ============================================

    function GetDashboardYearStats: TDashboard;
    function GetDashboardMonthlyStats(AAno: Integer = 0): TJSONValue;

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

procedure TSAWAPIClient.RefreshToken;
var
  LRequest: TRESTRequest;
  LJSONValue: TJSONValue;
  LJSONObject: TJSONObject;
  LNewToken: string;
begin
  try
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/auth/refresh';
      LRequest.Method := rmPOST;
      
      LRequest.AddHeader('Authorization', GetAuthHeader);
      LRequest.AddParameter('refresh_token', FRefreshToken, pkJSONBODY);
      
      LRequest.Execute;
      
      if LRequest.Response.StatusCode = 200 then
      begin
        LJSONValue := TJSONObject.ParseJSONValue(LRequest.Response.Content);
        try
          if LJSONValue is TJSONObject then
          begin
            LJSONObject := TJSONObject(LJSONValue);
            LNewToken := LJSONObject.GetValue('data').GetValue<string>('token');
            
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
        raise Exception.Create('Erro ao renovar token: ' + LRequest.Response.StatusText);
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
begin
  try
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := '/auth/login';
      LRequest.Method := rmPOST;
      
      LRequest.AddParameter('usuario', AUsername, pkJSONBODY);
      LRequest.AddParameter('senha', APassword, pkJSONBODY);
      
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
      
      LRequest.AddHeader('Authorization', GetAuthHeader);
      
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
      
      LRequest.AddHeader('Authorization', GetAuthHeader);
      
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
      
      LRequest.AddHeader('Authorization', GetAuthHeader);
      
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
        
        LRequest.AddHeader('Authorization', GetAuthHeader);
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
        
        LRequest.AddHeader('Authorization', GetAuthHeader);
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
      
      LRequest.AddHeader('Authorization', GetAuthHeader);
      
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

// ============================================
// Atendimentos
// ============================================

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
      
      LRequest.AddHeader('Authorization', GetAuthHeader);
      
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
      
      LRequest.AddHeader('Authorization', GetAuthHeader);
      
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

function TSAWAPIClient.DownloadAnexo(AAnexoID: Integer; 
  const ADestinationPath: string): Boolean;
var
  LRequest: TRESTRequest;
begin
  Result := False;
  
  try
    CheckTokenExpiry;
    
    LRequest := TRESTRequest.Create(nil);
    try
      LRequest.Client := FRESTClient;
      LRequest.Resource := Format('/anexos/%d/download', [AAnexoID]);
      LRequest.Method := rmGET;
      
      LRequest.AddHeader('Authorization', GetAuthHeader);
      
      LRequest.Execute;
      
      if LRequest.Response.StatusCode = 200 then
      begin
        LRequest.Response.RawBytes.SaveToFile(ADestinationPath);
        Result := True;
        LogRequest('GET', Format('/anexos/%d/download', [AAnexoID]), 
          'Arquivo baixado: ' + ADestinationPath);
      end
      else
        raise Exception.Create('Erro ao baixar anexo: ' + LRequest.Response.StatusText);
    finally
      LRequest.Free;
    end;
  except
    on E: Exception do
    begin
      RaiseError('Erro ao baixar anexo: ' + E.Message);
      Result := False;
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
      
      LRequest.AddHeader('Authorization', GetAuthHeader);
      
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
      
      LRequest.AddHeader('Authorization', GetAuthHeader);
      
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

end.

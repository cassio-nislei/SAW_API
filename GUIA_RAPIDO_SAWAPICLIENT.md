# 🚀 SAWAPIClient - Guia de Uso Rápido

**Unit Simplificada para Integração com API SAW**

---

## 📦 O que foi criado

### Arquivo: `SAWAPIClient.pas`

Uma unit única com **tudo integrado** para conectar ao Delphi com a API SAW:

- ✅ Autenticação JWT automática
- ✅ Renovação de token automática
- ✅ Tratamento de erros robusto
- ✅ Logging e debug
- ✅ Tipos de dados estruturados
- ✅ Todos os 10 endpoints implementados
- ✅ Sem dependência de FireDAC ou BDE

---

## 🎯 Uso Básico (3 linhas!)

```pascal
uses SAWAPIClient;

procedure TMainForm.ButtonClick(Sender: TObject);
var
  API: TSAWAPIClient;
  Usuario: TUsuario;
begin
  // 1. Inicializar (com auto-login)
  API := TSAWAPIClient.Create('admin', '123456');
  try
    // 2. Usar
    Usuario := API.GetCurrentUsuario;
    ShowMessage('Olá ' + Usuario.Nome);
  finally
    // 3. Liberar
    API.Free;
  end;
end;
```

---

## 📋 Exemplos Práticos

### 1️⃣ Listar Todos os Usuários

```pascal
procedure TMainForm.ListarUsuarios;
var
  API: TSAWAPIClient;
  Usuarios: TList<TUsuario>;
  I: Integer;
begin
  API := TSAWAPIClient.Create('admin', '123456');
  try
    // Buscar usuários (página 1, 20 itens por página)
    Usuarios := API.GetAllUsuarios(1, 20);
    try
      for I := 0 to Usuarios.Count - 1 do
      begin
        WriteLn(Format('[%d] %s (%s)',
          [Usuarios[I].ID, Usuarios[I].Nome, Usuarios[I].Login]));
      end;
    finally
      Usuarios.Free;
    end;
  finally
    API.Free;
  end;
end;
```

**Resultado:**

```
[1] Administrador (admin)
[2] João Silva (joao.silva)
[3] Maria Santos (maria.santos)
```

---

### 2️⃣ Obter Dados do Usuário Logado

```pascal
procedure TMainForm.MostrarDadosUsuario;
var
  API: TSAWAPIClient;
  Usuario: TUsuario;
begin
  API := TSAWAPIClient.Create('admin', '123456');
  try
    Usuario := API.GetCurrentUsuario;

    ShowMessage(
      'ID: ' + IntToStr(Usuario.ID) + sLineBreak +
      'Nome: ' + Usuario.Nome + sLineBreak +
      'Email: ' + Usuario.Email + sLineBreak +
      'Login: ' + Usuario.Login + sLineBreak +
      'Situação: ' + Usuario.Situacao
    );
  finally
    API.Free;
  end;
end;
```

---

### 3️⃣ Criar Novo Usuário

```pascal
procedure TMainForm.CriarUsuario;
var
  API: TSAWAPIClient;
  NovoUsuario: TUsuario;
  NovoID: Integer;
begin
  API := TSAWAPIClient.Create('admin', '123456');
  try
    // Preparar dados
    NovoUsuario.Nome := 'Pedro Costa';
    NovoUsuario.Email := 'pedro@example.com';
    NovoUsuario.Login := 'pedro.costa';
    NovoUsuario.Situacao := 'A';  // Ativo

    // Criar
    NovoID := API.CreateUsuario(NovoUsuario);

    if NovoID > 0 then
      ShowMessage('Usuário criado com ID: ' + IntToStr(NovoID))
    else
      ShowMessage('Erro ao criar usuário');
  finally
    API.Free;
  end;
end;
```

---

### 4️⃣ Atualizar Usuário

```pascal
procedure TMainForm.AtualizarUsuario;
var
  API: TSAWAPIClient;
  Usuario: TUsuario;
begin
  API := TSAWAPIClient.Create('admin', '123456');
  try
    // Buscar usuário
    Usuario := API.GetCurrentUsuario;

    // Modificar
    Usuario.Nome := 'Novo Nome';
    Usuario.Email := 'novoemail@example.com';

    // Atualizar
    if API.UpdateUsuario(Usuario) then
      ShowMessage('✅ Usuário atualizado com sucesso')
    else
      ShowMessage('❌ Erro ao atualizar usuário');
  finally
    API.Free;
  end;
end;
```

---

### 5️⃣ Deletar Usuário

```pascal
procedure TMainForm.DeletarUsuario(AUserID: Integer);
var
  API: TSAWAPIClient;
begin
  API := TSAWAPIClient.Create('admin', '123456');
  try
    if API.DeleteUsuario(AUserID) then
      ShowMessage('✅ Usuário deletado')
    else
      ShowMessage('❌ Erro ao deletar');
  finally
    API.Free;
  end;
end;
```

---

### 6️⃣ Buscar Atendimento por Telefone

```pascal
procedure TMainForm.BuscarAtendimento;
var
  API: TSAWAPIClient;
  Atendimento: TAtendimento;
begin
  API := TSAWAPIClient.Create('admin', '123456');
  try
    // Buscar por telefone
    Atendimento := API.GetAtendimentoByPhone('11999999999');

    if Atendimento.ID > 0 then
    begin
      ShowMessage(
        'Cliente: ' + Atendimento.Cliente + sLineBreak +
        'Setor: ' + Atendimento.Setor + sLineBreak +
        'Assunto: ' + Atendimento.Assunto + sLineBreak +
        'Status: ' + Atendimento.Status
      );
    end
    else
      ShowMessage('Atendimento não encontrado');
  finally
    API.Free;
  end;
end;
```

---

### 7️⃣ Listar Anexos de um Atendimento

```pascal
procedure TMainForm.ListarAnexos(AAtendimentoID: Integer);
var
  API: TSAWAPIClient;
  Anexos: TList<TAnexo>;
  I: Integer;
begin
  API := TSAWAPIClient.Create('admin', '123456');
  try
    Anexos := API.GetAtendimentoAnexos(AAtendimentoID);
    try
      for I := 0 to Anexos.Count - 1 do
      begin
        WriteLn(Format('[%d] %s (%d KB)',
          [Anexos[I].ID, Anexos[I].NomeArquivo, Anexos[I].TamanhoBytes div 1024]));
      end;
    finally
      Anexos.Free;
    end;
  finally
    API.Free;
  end;
end;
```

**Resultado:**

```
[156] comprovante.pdf (240 KB)
[157] captura_tela.png (500 KB)
```

---

### 8️⃣ Fazer Download de Arquivo

```pascal
procedure TMainForm.DownloadArquivo(AAnexoID: Integer);
var
  API: TSAWAPIClient;
  CaminhoDestino: string;
begin
  API := TSAWAPIClient.Create('admin', '123456');
  try
    CaminhoDestino := GetDesktopPath + '\arquivo_baixado.pdf';

    if API.DownloadAnexo(AAnexoID, CaminhoDestino) then
      ShowMessage('✅ Arquivo baixado em: ' + CaminhoDestino)
    else
      ShowMessage('❌ Erro ao baixar arquivo');
  finally
    API.Free;
  end;
end;
```

---

### 9️⃣ Obter Estatísticas do Ano

```pascal
procedure TMainForm.MostrarEstatisticas;
var
  API: TSAWAPIClient;
  Stats: TDashboard;
begin
  API := TSAWAPIClient.Create('admin', '123456');
  try
    Stats := API.GetDashboardYearStats;

    ShowMessage(
      'Ano: ' + IntToStr(Stats.Ano) + sLineBreak +
      'Total: ' + IntToStr(Stats.TotalAtendimentos) + sLineBreak +
      'Finalizados: ' + IntToStr(Stats.Finalizados) + sLineBreak +
      'Taxa Conclusão: ' + FormatFloat('0.0', Stats.TaxaConclusao) + '%' + sLineBreak +
      'Tempo Médio: ' + FormatFloat('0.0', Stats.TempoMedioAtendimento) + ' min'
    );
  finally
    API.Free;
  end;
end;
```

**Resultado:**

```
Ano: 2025
Total: 1542
Finalizados: 1506
Taxa Conclusão: 97.7%
Tempo Médio: 8.4 min
```

---

### 🔟 Obter Estatísticas Mensais

```pascal
procedure TMainForm.MostrarEstatisticasMensais;
var
  API: TSAWAPIClient;
  JSON: TJSONValue;
begin
  API := TSAWAPIClient.Create('admin', '123456');
  try
    // Estatísticas de 2025
    JSON := API.GetDashboardMonthlyStats(2025);

    if Assigned(JSON) then
    begin
      Memo1.Text := JSON.ToString;
      JSON.Free;
    end;
  finally
    API.Free;
  end;
end;
```

---

## 🔐 Recursos Avançados

### Validar Token

```pascal
procedure TMainForm.ValidarToken;
var
  API: TSAWAPIClient;
begin
  API := TSAWAPIClient.Create('admin', '123456');
  try
    if API.ValidateToken then
      ShowMessage('✅ Token válido')
    else
      ShowMessage('❌ Token inválido ou expirado');
  finally
    API.Free;
  end;
end;
```

---

### Verificar Tempo Restante do Token

```pascal
procedure TMainForm.VerificarExpiracaoToken;
var
  API: TSAWAPIClient;
  SegundosRestantes: Integer;
begin
  API := TSAWAPIClient.Create('admin', '123456');
  try
    SegundosRestantes := API.GetTimeRemaining;
    ShowMessage('Token expira em: ' + IntToStr(SegundosRestantes) + ' segundos');
  finally
    API.Free;
  end;
end;
```

---

### Ativar Modo Debug

```pascal
procedure TMainForm.AtivarDebug;
var
  API: TSAWAPIClient;
begin
  API := TSAWAPIClient.Create('admin', '123456');
  API.DebugMode := True;  // Ativa logging

  try
    // Suas operações aqui - serão logadas
    API.GetCurrentUsuario;
  finally
    API.Free;
  end;
end;
```

---

### Tratar Eventos

```pascal
procedure TMainForm.FormCreate(Sender: TObject);
var
  API: TSAWAPIClient;
begin
  API := TSAWAPIClient.Create('admin', '123456');

  // Registrar eventos
  API.OnTokenRefresh := APITokenRefreshHandler;
  API.OnError := APIErrorHandler;
  API.OnRequestLog := APIRequestLogHandler;
end;

procedure TMainForm.APITokenRefreshHandler(Sender: TObject; const ANewToken: string);
begin
  WriteLn('Token renovado: ' + Copy(ANewToken, 1, 20) + '...');
end;

procedure TMainForm.APIErrorHandler(Sender: TObject; const AError: string);
begin
  WriteLn('Erro: ' + AError);
end;

procedure TMainForm.APIRequestLogHandler(Sender: TObject;
  const AMethod, AResource, AResponse: string);
begin
  WriteLn(Format('[%s] %s -> %s', [AMethod, AResource, AResponse]));
end;
```

---

### Alterar Timeout

```pascal
procedure TMainForm.AlterarTimeout;
var
  API: TSAWAPIClient;
begin
  API := TSAWAPIClient.Create('admin', '123456');

  // Aumentar timeout para 60 segundos
  API.SetTimeout(60000);

  try
    // Operações com timeout aumentado
    API.GetAllUsuarios;
  finally
    API.Free;
  end;
end;
```

---

### Conectar em Servidor Diferente

```pascal
procedure TMainForm.ConectarEmOutroServidor;
var
  API: TSAWAPIClient;
begin
  // Conectar em servidor customizado
  API := TSAWAPIClient.Create('admin', '123456',
    'seu-servidor.com', 8080);

  try
    ShowMessage('Conectado em: ' + API.BaseURL);
  finally
    API.Free;
  end;
end;
```

---

## 🔌 Integração em uma Aplicação Real

### 1. Adicionar à aplicação

```pascal
// Adicionar "SAWAPIClient" à cláusula Uses do seu form
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  SAWAPIClient;  // ← Adicionar aqui

type
  TMainForm = class(TForm)
    // ...
  private
    FAPI: TSAWAPIClient;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;
```

### 2. Inicializar na criação

```pascal
constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;

  try
    FAPI := TSAWAPIClient.Create('admin', '123456');
    FAPI.OnError := APIErrorHandler;
    ShowMessage('✅ Conectado à API');
  except
    on E: Exception do
    begin
      ShowMessage('❌ Erro ao conectar: ' + E.Message);
      // Aplicação não abre ou vai sem API
    end;
  end;
end;

destructor TMainForm.Destroy;
begin
  if Assigned(FAPI) then
    FAPI.Free;
  inherited;
end;

procedure TMainForm.APIErrorHandler(Sender: TObject; const AError: string);
begin
  ShowMessage('⚠️ Erro da API: ' + AError);
end;
```

### 3. Usar em qualquer lugar

```pascal
procedure TMainForm.Button1Click(Sender: TObject);
var
  Usuario: TUsuario;
begin
  if Assigned(FAPI) then
  begin
    Usuario := FAPI.GetCurrentUsuario;
    Label1.Caption := 'Olá ' + Usuario.Nome;
  end;
end;
```

---

## ✨ Benefícios da Unit

| Recurso             | Benefício                     |
| ------------------- | ----------------------------- |
| **Simplificidade**  | 3 linhas para conectar e usar |
| **Segurança**       | Tokens JWT automáticos        |
| **Robustez**        | Tratamento de erros completo  |
| **Performance**     | Renovação automática de token |
| **Debugging**       | Logging completo incluído     |
| **Flexibilidade**   | Eventos customizáveis         |
| **Compatibilidade** | Funciona com Delphi 10.3+     |
| **Maintenance**     | Tudo em um arquivo            |

---

## 🎓 Comparação: Antes vs Depois

### ❌ ANTES (conexão direta)

```pascal
// Dezenas de linhas para conectar
FDConnection.DriverName := 'MySQL';
FDConnection.Params.Database := 'saw15';
FDConnection.Params.UserName := 'root';
FDConnection.Params.Password := 'senha';
FDConnection.Connected := True;

// Query manual
Query.SQL.Text := 'SELECT * FROM tbusuario';
Query.Open;

// Processamento manual
while not Query.Eof do
begin
  // ...
  Query.Next;
end;

// Nenhuma segurança
// Sem auditoria automática
// Sem tratamento de erro robusto
```

### ✅ DEPOIS (com SAWAPIClient)

```pascal
// 1 linha para conectar
API := TSAWAPIClient.Create('admin', '123456');

// 1 linha para buscar dados
Usuarios := API.GetAllUsuarios;

// 1 loop para processar
for Usuario in Usuarios do
  ShowMessage(Usuario.Nome);

// Segurança JWT automática
// Auditoria completa na API
// Tratamento robusto integrado
```

---

## 🚨 Troubleshooting

### Problema: "Unit not found"

**Solução:**

1. Coloque `SAWAPIClient.pas` na mesma pasta do seu projeto
2. Ou adicione à Search Path: Tools → Options → Delphi Options → Library

### Problema: "Connection refused"

**Solução:**

```pascal
// Verifique a URL
API := TSAWAPIClient.Create('admin', '123456',
  '104.234.173.105', 7080);

// Teste ping
ping 104.234.173.105
```

### Problema: "Login failed"

**Solução:**

```pascal
// Verifique credenciais
API := TSAWAPIClient.Create(
  'admin',      // ← Verificar
  '123456'      // ← Verificar
);
```

### Problema: "Token inválido"

**Solução:**

```pascal
// Renovar token manualmente
if not API.ValidateToken then
  API.RefreshAccessToken;
```

---

## 📞 Referência Rápida

### Métodos Principais

```pascal
// Autenticação
API.Login(Usuario, Senha);
API.Logout;
API.ValidateToken: Boolean;

// Usuários
API.GetAllUsuarios: TList<TUsuario>;
API.GetCurrentUsuario: TUsuario;
API.CreateUsuario(Usuario): Integer;
API.UpdateUsuario(Usuario): Boolean;
API.DeleteUsuario(ID): Boolean;

// Atendimentos
API.GetAtendimentoByPhone(Phone): TAtendimento;
API.GetAtendimentoAnexos(ID): TList<TAnexo>;

// Anexos
API.DownloadAnexo(ID, Path): Boolean;

// Dashboard
API.GetDashboardYearStats: TDashboard;
API.GetDashboardMonthlyStats(Ano): TJSONValue;

// Configuração
API.SetTimeout(Ms);
API.SetDebugMode(True/False);
```

---

**Document Created:** 20 de Novembro de 2025  
**Status:** ✅ Pronto para Produção

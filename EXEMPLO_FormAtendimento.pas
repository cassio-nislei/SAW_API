unit FormAtendimento;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Buttons, ExtCtrls, DateUtils,
  System.JSON,
  APIClient;

type
  TFormAtendimento = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    EditBusca: TEdit;
    BtnBuscar: TButton;
    BtnNovo: TButton;
    BtnAtualizar: TButton;
    StringGrid1: TStringGrid;
    Label2: TLabel;
    EditID: TEdit;
    Label3: TLabel;
    EditSituacao: TComboBox;
    Label4: TLabel;
    EditSetor: TEdit;
    BtnSalvar: TButton;
    BtnAbrir: TButton;
    Memo1: TMemo;
    StatusBar1: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure BtnBuscarClick(Sender: TObject);
    procedure BtnNovoClick(Sender: TObject);
    procedure BtnSalvarClick(Sender: TObject);
    procedure BtnAbrirClick(Sender: TObject);
    procedure BtnAtualizarClick(Sender: TObject);
    procedure StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
  private
    FManager: TManager_Atendimento;
    FCurrentID: Integer;
    procedure CarregarGrid(Page: Integer = 1);
    procedure ExibirDetalhes(const ID: Integer);
    procedure Logar(const Msg: string);
  public
    { Public declarations }
  end;

var
  FormAtendimento: TFormAtendimento;

implementation

{$R *.dfm}

procedure TFormAtendimento.FormCreate(Sender: TObject);
begin
  FManager := TManager_Atendimento.Create;
  
  // Configurar Grid
  StringGrid1.ColCount := 5;
  StringGrid1.RowCount := 1;
  StringGrid1.Cols[0].Caption := 'ID';
  StringGrid1.Cols[1].Caption := 'Número';
  StringGrid1.Cols[2].Caption := 'Solicitante';
  StringGrid1.Cols[3].Caption := 'Situação';
  StringGrid1.Cols[4].Caption := 'Data';
  
  // Configurar ComboBox
  EditSituacao.Items.Add('aberto');
  EditSituacao.Items.Add('em_andamento');
  EditSituacao.Items.Add('concluido');
  EditSituacao.Items.Add('cancelado');
  
  Logar('Formulário carregado');
  CarregarGrid;
end;

procedure TFormAtendimento.CarregarGrid(Page: Integer);
var
  Response: TJSONObject;
  JSONArray: TJSONArray;
  I: Integer;
  JSONObj: TJSONObject;
begin
  try
    Logar('Carregando atendimentos...');
    Response := FManager.ListarAtendimentos(Page, 50);
    
    if not Assigned(Response) then
    begin
      Logar('Erro ao carregar: ' + FManager.FAPI.LastError);
      Exit;
    end;
    
    try
      StringGrid1.RowCount := 1;
      JSONArray := Response.GetValue('data') as TJSONArray;
      
      if not Assigned(JSONArray) then
      begin
        Logar('Nenhum resultado');
        Exit;
      end;
      
      StringGrid1.RowCount := JSONArray.Count + 1;
      
      for I := 0 to JSONArray.Count - 1 do
      begin
        JSONObj := JSONArray.Items[I] as TJSONObject;
        StringGrid1.Cells[0, I + 1] := JSONObj.GetValue('id').Value;
        StringGrid1.Cells[1, I + 1] := JSONObj.GetValue('numero').Value;
        StringGrid1.Cells[2, I + 1] := JSONObj.GetValue('solicitante').Value;
        StringGrid1.Cells[3, I + 1] := JSONObj.GetValue('situacao').Value;
        StringGrid1.Cells[4, I + 1] := JSONObj.GetValue('data_criacao').Value;
      end;
      
      Logar('Carregados ' + IntToStr(JSONArray.Count) + ' registros');
    finally
      Response.Free;
    end;
  except
    on E: Exception do
      Logar('Exceção: ' + E.Message);
  end;
end;

procedure TFormAtendimento.BtnBuscarClick(Sender: TObject);
begin
  if EditBusca.Text <> '' then
    Logar('Buscar por: ' + EditBusca.Text)
  else
    CarregarGrid;
end;

procedure TFormAtendimento.BtnNovoClick(Sender: TObject);
var
  Numero: string;
  Solicitante: string;
  Solicitacao: string;
  NovoID: Integer;
begin
  Numero := InputBox('Novo', 'Número:', '');
  if Numero = '' then Exit;
  
  Solicitante := InputBox('Novo', 'Solicitante:', '');
  if Solicitante = '' then Exit;
  
  Solicitacao := InputBox('Novo', 'Solicitação:', '');
  if Solicitacao = '' then Exit;
  
  try
    Logar('Criando novo atendimento...');
    NovoID := FManager.CriarAtendimento(Numero, Solicitante, Solicitacao, '');
    
    if NovoID > 0 then
    begin
      Logar('Atendimento criado! ID: ' + IntToStr(NovoID));
      CarregarGrid;
    end
    else
      Logar('Erro ao criar atendimento');
  except
    on E: Exception do
      Logar('Erro: ' + E.Message);
  end;
end;

procedure TFormAtendimento.StringGrid1SelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  if ARow > 0 then
  begin
    FCurrentID := StrToInt(StringGrid1.Cells[0, ARow]);
    EditID.Text := IntToStr(FCurrentID);
    ExibirDetalhes(FCurrentID);
  end;
end;

procedure TFormAtendimento.ExibirDetalhes(const ID: Integer);
var
  Response: TJSONObject;
  JSONObj: TJSONObject;
begin
  try
    Response := FManager.ObterAtendimento(ID);
    
    if Assigned(Response) then
    begin
      try
        JSONObj := Response.GetValue('data') as TJSONObject;
        EditSituacao.ItemIndex := EditSituacao.Items.IndexOf(JSONObj.GetValue('situacao').Value);
        EditSetor.Text := JSONObj.GetValue('setor').Value;
        Memo1.Text := JSONObj.GetValue('solicitacao').Value;
        Logar('Detalhes carregados');
      finally
        Response.Free;
      end;
    end;
  except
    on E: Exception do
      Logar('Erro ao carregar detalhes: ' + E.Message);
  end;
end;

procedure TFormAtendimento.BtnSalvarClick(Sender: TObject);
begin
  if FCurrentID = 0 then
  begin
    Logar('Selecione um atendimento');
    Exit;
  end;
  
  try
    Logar('Alterando situação...');
    if FManager.AlterarSituacao(FCurrentID, EditSituacao.Items[EditSituacao.ItemIndex]) then
      Logar('Situação alterada com sucesso')
    else
      Logar('Erro ao alterar situação');
  except
    on E: Exception do
      Logar('Erro: ' + E.Message);
  end;
end;

procedure TFormAtendimento.BtnAbrirClick(Sender: TObject);
begin
  if FCurrentID = 0 then
  begin
    Logar('Selecione um atendimento');
    Exit;
  end;
  
  try
    Logar('Abrindo atendimento ' + IntToStr(FCurrentID) + '...');
    if FManager.AlterarSituacao(FCurrentID, 'em_andamento') then
    begin
      EditSituacao.ItemIndex := 1; // em_andamento
      Logar('Atendimento aberto');
    end
    else
      Logar('Erro ao abrir');
  except
    on E: Exception do
      Logar('Erro: ' + E.Message);
  end;
end;

procedure TFormAtendimento.BtnAtualizarClick(Sender: TObject);
begin
  CarregarGrid;
end;

procedure TFormAtendimento.Logar(const Msg: string);
begin
  StatusBar1.SimpleText := FormatDateTime('hh:mm:ss', Now) + ' - ' + Msg;
  Memo1.Lines.Insert(0, Msg);
end;

end.

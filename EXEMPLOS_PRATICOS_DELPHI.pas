// ============================================================================
// EXEMPLOS PRONTOS PARA COPIAR/COLAR - SAWAPIClient.pas
// Implementação de chamadas aos novos endpoints de Procedures
// ============================================================================

{
  Este arquivo contém exemplos prontos para usar no seu código Delphi.
  Copie e adapte conforme necessário para seu projeto.
}

// ============================================================================
// EXEMPLO 1: Inicialização com Sincronização de Estrutura
// ============================================================================

procedure TFormPrincipal.InicializarAplicacao;
var
  LColunas: TJSONArray;
  LColuna: TJSONObject;
  LSQL: string;
begin
  try
    // Sincronizar tabela de avisos sem expediente
    LColunas := TJSONArray.Create;
    
    LColuna := TJSONObject.Create;
    LColuna.AddPair('nome', 'id');
    LColuna.AddPair('tipo', 'INT AUTO_INCREMENT PRIMARY KEY');
    LColuna.AddPair('permite_null', TJSONBool.Create(False));
    LColunas.Add(LColuna);
    
    LColuna := TJSONObject.Create;
    LColuna.AddPair('nome', 'titulo');
    LColuna.AddPair('tipo', 'VARCHAR(255)');
    LColuna.AddPair('permite_null', TJSONBool.Create(False));
    LColunas.Add(LColuna);
    
    LSQL := 'CREATE TABLE IF NOT EXISTS tbavisosemexpediente (' +
            'id INT AUTO_INCREMENT PRIMARY KEY, ' +
            'titulo VARCHAR(255) NOT NULL, ' +
            'mensagem LONGTEXT NOT NULL, ' +
            'dt_criacao DATETIME DEFAULT CURRENT_TIMESTAMP)';
    
    FAPIClient.SincronizarEstrutura('tbavisosemexpediente', LColunas, LSQL, True);
    
    ShowMessage('Estrutura sincronizada com sucesso');
  except
    on E: Exception do
      ShowMessage('Erro ao sincronizar: ' + E.Message);
  end;
end;

// ============================================================================
// EXEMPLO 2: Criar Procedure se não existir
// ============================================================================

procedure TFormPrincipal.CriarProcedureSeNecessario;
var
  LSQL: string;
  LSucesso: Boolean;
begin
  try
    // Verificar se procedure existe
    if FAPIClient.ProcedureExists('sprDashBoardAnoAtual') then
    begin
      ShowMessage('Procedure sprDashBoardAnoAtual já existe');
      Exit;
    end;
    
    // Criar procedure
    LSQL := 'CREATE PROCEDURE sprDashBoardAnoAtual() ' +
            'BEGIN ' +
            '  SELECT COUNT(*) as total_atendimentos FROM tbatendimento ' +
            '  WHERE YEAR(dt_criacao) = YEAR(NOW()); ' +
            'END';
    
    LSucesso := FAPIClient.CriarProcedure('sprDashBoardAnoAtual', LSQL);
    
    if LSucesso then
      ShowMessage('Procedure criada com sucesso!')
    else
      ShowMessage('Erro ao criar procedure');
  except
    on E: Exception do
      ShowMessage('Erro: ' + E.Message);
  end;
end;

// ============================================================================
// EXEMPLO 3: Executar Procedure e processar resultado
// ============================================================================

procedure TFormPrincipal.ExecutarRelatorio;
var
  LResult: TJSONValue;
  LResultObj: TJSONObject;
  LTotal: Integer;
begin
  try
    // Executar procedure sem parâmetros
    LResult := FAPIClient.ExecutarProcedure('sprDashBoardAnoAtual', []);
    
    if LResult is TJSONObject then
    begin
      LResultObj := TJSONObject(LResult);
      
      // Processar resultado
      if LResultObj.GetValue('success').AsType<Boolean> then
      begin
        // Extrair dados
        LTotal := StrToIntDef(
          LResultObj.GetValue('data').GetValue('total_atendimentos').ToString, 0);
        
        ShowMessage(Format('Total de atendimentos: %d', [LTotal]));
      end;
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao executar procedure: ' + E.Message);
  end;
end;

// ============================================================================
// EXEMPLO 4: Executar Procedure com parâmetros
// ============================================================================

procedure TFormPrincipal.ExecutarRelatorioMensais(AAno, AMes: Integer);
var
  LParams: TArray<Variant>;
  LResult: TJSONValue;
begin
  try
    // Preparar parâmetros
    SetLength(LParams, 2);
    LParams[0] := AAno;
    LParams[1] := AMes;
    
    // Executar procedure
    LResult := FAPIClient.ExecutarProcedure('sprDashBoardAtendimentosMensais', LParams);
    
    // Processar resultado...
    ShowMessage('Relatório gerado: ' + LResult.ToString);
  except
    on E: Exception do
      ShowMessage('Erro: ' + E.Message);
  end;
end;

// ============================================================================
// EXEMPLO 5: Sincronizar múltiplas colunas em tabela existente
// ============================================================================

procedure TFormPrincipal.SincronizarColunasUsuario;
var
  LColunas: TJSONArray;
  LColuna: TJSONObject;
  LResult: TJSONValue;
begin
  try
    LColunas := TJSONArray.Create;
    
    // Coluna 1: em_almoco
    LColuna := TJSONObject.Create;
    LColuna.AddPair('nome', 'em_almoco');
    LColuna.AddPair('tipo', 'INT');
    LColuna.AddPair('permite_null', TJSONBool.Create(True));
    LColunas.Add(LColuna);
    
    // Coluna 2: msg_almoco
    LColuna := TJSONObject.Create;
    LColuna.AddPair('nome', 'msg_almoco');
    LColuna.AddPair('tipo', 'VARCHAR(500)');
    LColuna.AddPair('permite_null', TJSONBool.Create(True));
    LColunas.Add(LColuna);
    
    // Coluna 3: dt_almoco_inicio
    LColuna := TJSONObject.Create;
    LColuna.AddPair('nome', 'dt_almoco_inicio');
    LColuna.AddPair('tipo', 'DATETIME');
    LColuna.AddPair('permite_null', TJSONBool.Create(True));
    LColunas.Add(LColuna);
    
    // Sincronizar sem criar a tabela (já existe)
    LResult := FAPIClient.SincronizarEstrutura('tbusuario', LColunas, '', False);
    
    ShowMessage('Colunas sincronizadas: ' + LResult.ToString);
  except
    on E: Exception do
      ShowMessage('Erro: ' + E.Message);
  end;
end;

// ============================================================================
// EXEMPLO 6: Listar todas as procedures do banco
// ============================================================================

procedure TFormPrincipal.ListarTodasProcedures;
var
  LProcedures: TJSONValue;
  LArray: TJSONArray;
  i: Integer;
  LProcedure: TJSONObject;
begin
  try
    LProcedures := FAPIClient.ListarProcedures;
    
    if LProcedures is TJSONObject then
    begin
      LArray := TJSONArray(TJSONObject(LProcedures).GetValue('data'));
      
      for i := 0 to LArray.Count - 1 do
      begin
        LProcedure := TJSONObject(LArray.Items[i]);
        ShowMessage(Format('Procedure: %s (BD: %s)', 
          [LProcedure.GetValue('nome').ToString,
           LProcedure.GetValue('banco').ToString]));
      end;
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao listar: ' + E.Message);
  end;
end;

// ============================================================================
// EXEMPLO 7: Verificação completa de estrutura e procedures
// ============================================================================

procedure TFormPrincipal.VerificacaoCompleta;
var
  LColunas: TJSONArray;
  i: Integer;
begin
  try
    // Array de procedures necessárias
    var LProceduresNecessarias: array[0..2] of string = (
      'sprDashBoardAnoAtual',
      'sprDashBoardAtendimentosMensais',
      'sprFolhaPagamento'
    );
    
    // Verificar cada procedure
    for i := Low(LProceduresNecessarias) to High(LProceduresNecessarias) do
    begin
      if not FAPIClient.ProcedureExists(LProceduresNecessarias[i]) then
      begin
        ShowMessage(Format('Procedure %s não existe. Criar? Sim/Não', 
          [LProceduresNecessarias[i]]));
        // Criar procedure aqui...
      end;
    end;
    
    // Sincronizar estrutura de tabelas
    LColunas := CriarColunasParaSincronizar;
    FAPIClient.SincronizarEstrutura('tbusuario', LColunas, '', False);
    
    ShowMessage('Verificação completa realizada com sucesso');
  except
    on E: Exception do
      ShowMessage('Erro na verificação: ' + E.Message);
  end;
end;

// ============================================================================
// FUNÇÃO AUXILIAR: Criar array de colunas
// ============================================================================

function TFormPrincipal.CriarColunasParaSincronizar: TJSONArray;
var
  LColuna: TJSONObject;
begin
  Result := TJSONArray.Create;
  
  LColuna := TJSONObject.Create;
  LColuna.AddPair('nome', 'em_almoco');
  LColuna.AddPair('tipo', 'INT');
  LColuna.AddPair('permite_null', TJSONBool.Create(True));
  Result.Add(LColuna);
  
  LColuna := TJSONObject.Create;
  LColuna.AddPair('nome', 'msg_almoco');
  LColuna.AddPair('tipo', 'VARCHAR(500)');
  LColuna.AddPair('permite_null', TJSONBool.Create(True));
  Result.Add(LColuna);
end;

// ============================================================================
// EXEMPLO 8: Tratamento de erros robusto
// ============================================================================

procedure TFormPrincipal.ExecutarComErroTratamento;
var
  LResult: TJSONValue;
  LResultObj: TJSONObject;
begin
  try
    try
      LResult := FAPIClient.ExecutarProcedure('sprDashBoardAnoAtual', []);
      
      if not Assigned(LResult) then
      begin
        ShowMessage('Resposta vazia do servidor');
        Exit;
      end;
      
      LResultObj := TJSONObject(LResult);
      
      // Verificar se sucesso
      if not LResultObj.GetValue('success').AsType<Boolean> then
      begin
        ShowMessage('Erro: ' + LResultObj.GetValue('message').ToString);
        Exit;
      end;
      
      // Processar dados
      ShowMessage('Sucesso: ' + LResultObj.GetValue('message').ToString);
      
    except
      on EJSONException do
        ShowMessage('Erro ao processar JSON da resposta');
      on ENetException do
        ShowMessage('Erro de rede ao chamar API');
    end;
  except
    on E: Exception do
      ShowMessage('Erro geral: ' + E.Message);
  end;
end;

// ============================================================================
// EXEMPLO 9: Loop para criar múltiplas procedures
// ============================================================================

type
  TProcedureInfo = record
    Nome: string;
    SQL: string;
  end;

procedure TFormPrincipal.CriarMultiplasProcedures;
var
  LProcedures: array[0..2] of TProcedureInfo;
  i: Integer;
  LSucesso: Boolean;
begin
  // Definir procedures
  LProcedures[0].Nome := 'sprDashBoardAnoAtual';
  LProcedures[0].SQL := 'CREATE PROCEDURE sprDashBoardAnoAtual() BEGIN ' +
    'SELECT COUNT(*) as total FROM tbatendimento WHERE YEAR(dt_criacao) = YEAR(NOW()); END';
  
  LProcedures[1].Nome := 'sprDashBoardAtendimentosMensais';
  LProcedures[1].SQL := 'CREATE PROCEDURE sprDashBoardAtendimentosMensais(IN pAno INT, IN pMes INT) BEGIN ' +
    'SELECT COUNT(*) as total FROM tbatendimento WHERE YEAR(dt_criacao) = pAno AND MONTH(dt_criacao) = pMes; END';
  
  LProcedures[2].Nome := 'sprFolhaPagamento';
  LProcedures[2].SQL := 'CREATE PROCEDURE sprFolhaPagamento() BEGIN ' +
    'SELECT * FROM tbfolhapagamento WHERE mes = MONTH(NOW()) AND ano = YEAR(NOW()); END';
  
  // Criar cada uma
  for i := Low(LProcedures) to High(LProcedures) do
  begin
    if not FAPIClient.ProcedureExists(LProcedures[i].Nome) then
    begin
      LSucesso := FAPIClient.CriarProcedure(LProcedures[i].Nome, LProcedures[i].SQL);
      if LSucesso then
        ShowMessage(Format('✓ %s criada', [LProcedures[i].Nome]))
      else
        ShowMessage(Format('✗ Erro ao criar %s', [LProcedures[i].Nome]));
    end;
  end;
end;

// ============================================================================
// EXEMPLO 10: Integração com progresso visual
// ============================================================================

procedure TFormPrincipal.SincronizarComProgresso;
var
  LColunas: TJSONArray;
  LColuna: TJSONObject;
  i: Integer;
  LColunasNecessarias: array[0..2] of string = (
    'em_almoco',
    'msg_almoco',
    'dt_almoco_inicio'
  );
begin
  try
    ProgressBar1.Max := Length(LColunasNecessarias);
    ProgressBar1.Position := 0;
    
    LColunas := TJSONArray.Create;
    
    for i := Low(LColunasNecessarias) to High(LColunasNecessarias) do
    begin
      LColuna := TJSONObject.Create;
      LColuna.AddPair('nome', LColunasNecessarias[i]);
      LColuna.AddPair('tipo', 'INT');
      LColuna.AddPair('permite_null', TJSONBool.Create(True));
      LColunas.Add(LColuna);
      
      ProgressBar1.Position := i + 1;
      Application.ProcessMessages;
    end;
    
    FAPIClient.SincronizarEstrutura('tbusuario', LColunas, '', False);
    ShowMessage('Sincronização concluída!');
  except
    on E: Exception do
      ShowMessage('Erro: ' + E.Message);
  end;
end;

// ============================================================================
// FIM DOS EXEMPLOS
// ============================================================================

{
  RESUMO DOS EXEMPLOS:
  
  1. InicializarAplicacao
     └─ Sincronizar tabelas na inicialização
     
  2. CriarProcedureSeNecessario
     └─ Verificar existência e criar se precisar
     
  3. ExecutarRelatorio
     └─ Executar procedure e processar resultado
     
  4. ExecutarRelatorioMensais
     └─ Executar com parâmetros
     
  5. SincronizarColunasUsuario
     └─ Adicionar múltiplas colunas
     
  6. ListarTodasProcedures
     └─ Listar e iterar procedures
     
  7. VerificacaoCompleta
     └─ Verificação completa de estrutura
     
  8. ExecutarComErroTratamento
     └─ Tratamento robusto de erros
     
  9. CriarMultiplasProcedures
     └─ Loop para criar várias procedures
     
  10. SincronizarComProgresso
      └─ Com barra de progresso visual
}

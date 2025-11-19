# 🎯 Guia Rápido - Migrar Delphi para SAW API

## 5 Minutos para Começar

### Passo 1: Copiar o Arquivo APIClient.pas

1. Localize o arquivo: `DELPHI_APIClient.pas`
2. Copie para sua pasta de projeto Delphi
3. Renomeie para: `APIClient.pas`
4. Adicione em seu projeto: `Project → Add to Project`

### Passo 2: Testar Conexão

No seu Delphi, em um botão ou formulário:

```delphi
procedure TForm1.BtnTestarClick(Sender: TObject);
var
  API: TAPIClient;
  Response: TJSONObject;
begin
  API := TAPIClient.Create;
  try
    Response := API.Get('/');
    try
      if Assigned(Response) then
        ShowMessage('Sucesso! API respondendo')
      else
        ShowMessage('Erro: ' + API.LastError);
    finally
      Response.Free;
    end;
  finally
    API.Free;
  end;
end;
```

### Passo 3: Listar Atendimentos

```delphi
procedure TForm1.CarregarAtendimentos;
var
  Manager: TManager_Atendimento;
  Response: TJSONObject;
  JSONArray: TJSONArray;
  I: Integer;
begin
  Manager := TManager_Atendimento.Create;
  try
    Response := Manager.ListarAtendimentos(1, 20); // Page 1, 20 por página
    try
      if Assigned(Response) then
      begin
        JSONArray := Response.GetValue('data') as TJSONArray;
        StringGrid1.RowCount := JSONArray.Count + 1;

        for I := 0 to JSONArray.Count - 1 do
        begin
          // Preencher grid com dados
        end;
      end;
    finally
      Response.Free;
    end;
  finally
    Manager.Free;
  end;
end;
```

### Passo 4: Criar Novo Atendimento

```delphi
procedure TForm1.CriarNovoClick(Sender: TObject);
var
  Manager: TManager_Atendimento;
  NovoID: Integer;
begin
  Manager := TManager_Atendimento.Create;
  try
    NovoID := Manager.CriarAtendimento(
      EditNumero.Text,
      EditSolicitante.Text,
      MemoSolicitacao.Text,
      'Setor1' // opcional
    );

    if NovoID > 0 then
      ShowMessage('Criado com sucesso! ID: ' + IntToStr(NovoID))
    else
      ShowMessage('Erro ao criar');
  finally
    Manager.Free;
  end;
end;
```

### Passo 5: Testar no Navegador

Abra no navegador para confirmar que a API está funcionando:

```
http://localhost/SAW-main/api/swagger-ui.html
```

Clique em um endpoint e teste com "Try it out".

---

## 📚 Classes Disponíveis

### TAPIClient - Cliente HTTP Básico

```delphi
var API: TAPIClient;
begin
  API := TAPIClient.Create('http://localhost/SAW-main/api/v1');
  try
    API.Get('/atendimentos');
    API.Post('/atendimentos', JSONData);
    API.Put('/atendimentos/1/situacao', JSONData);
    API.Delete('/mensagens/1');
  finally
    API.Free;
  end;
end;
```

### TManager_Atendimento - Gerenciar Atendimentos

```delphi
var Manager: TManager_Atendimento;
begin
  Manager := TManager_Atendimento.Create;
  try
    Manager.ListarAtendimentos(1, 20);
    Manager.ListarAtendimentosAtivos;
    Manager.ObterAtendimento(123);
    Manager.CriarAtendimento('ATD-001', 'João', 'Teste');
    Manager.AlterarSituacao(123, 'em_andamento');
    Manager.FinalizarAtendimento(123, 'Resolvido');
  finally
    Manager.Free;
  end;
end;
```

### TManager_Mensagem - Gerenciar Mensagens

```delphi
var Manager: TManager_Mensagem;
begin
  Manager := TManager_Mensagem.Create;
  try
    Manager.ListarMensagens(123);
    Manager.ListarMensagensPendentes(123);
    Manager.CriarMensagem(123, 'Conteúdo', 'Sistema');
    Manager.MarcarVisualizada(456);
    Manager.AdicionarReacao(456, 5); // 0-20
    Manager.DeletarMensagem(456);
  finally
    Manager.Free;
  end;
end;
```

### TManager_Menu - Gerenciar Menus

```delphi
var Manager: TManager_Menu;
begin
  Manager := TManager_Menu.Create;
  try
    Manager.ListarMenus;
    Manager.ObterMenu(1);
    Manager.ObterRespostaAutomatica(1);
    Manager.ListarSubmenus(1);
  finally
    Manager.Free;
  end;
end;
```

### TManager_Horario - Verificar Horários

```delphi
var Manager: TManager_Horario;
begin
  Manager := TManager_Horario.Create;
  try
    Manager.ObterFuncionamento;
    if Manager.EstaAberto then
      ShowMessage('Atendimento aberto')
    else
      ShowMessage('Atendimento fechado');
  finally
    Manager.Free;
  end;
end;
```

---

## 🔧 Tratamento de Erros Básico

```delphi
procedure ExecutarComErro;
var
  Manager: TManager_Atendimento;
  Response: TJSONObject;
begin
  Manager := TManager_Atendimento.Create;
  try
    try
      Response := Manager.ListarAtendimentos;
      try
        if Assigned(Response) then
        begin
          if Response.GetValue('status').Value = 'success' then
            ShowMessage('Sucesso!')
          else
            ShowMessage('Erro: ' + Response.GetValue('message').Value);
        end
        else
          ShowMessage('Sem resposta. Erro: ' + Manager.FAPI.LastError);
      finally
        Response.Free;
      end;
    except
      on E: Exception do
        ShowMessage('Exceção: ' + E.Message);
    end;
  finally
    Manager.Free;
  end;
end;
```

---

## 🎯 Exemplos Comuns

### Exemplo 1: Filtrar Atendimentos Abertos

```delphi
procedure TForm1.MostrarAbertos;
var
  Manager: TManager_Atendimento;
  Response: TJSONObject;
begin
  Manager := TManager_Atendimento.Create;
  try
    Response := Manager.ListarAtendimentos; // Todos
    try
      // Filtrar localmente por situação = 'aberto'
      // Ou use endpoint: /atendimentos?situacao=aberto
    finally
      Response.Free;
    end;
  finally
    Manager.Free;
  end;
end;
```

### Exemplo 2: Mostrar Mensagens em TMemo

```delphi
procedure TForm1.MostrarMensagens(const IDAtendimento: Integer);
var
  Manager: TManager_Mensagem;
  Response: TJSONObject;
  JSONArray: TJSONArray;
  I: Integer;
  Msg: string;
begin
  Manager := TManager_Mensagem.Create;
  try
    Response := Manager.ListarMensagens(IDAtendimento);
    try
      if Assigned(Response) then
      begin
        JSONArray := Response.GetValue('data') as TJSONArray;
        MemoMensagens.Clear;

        for I := 0 to JSONArray.Count - 1 do
        begin
          Msg := Format('[%s] %s: %s',
            [
              (JSONArray.Items[I] as TJSONObject).GetValue('data_criacao').Value,
              (JSONArray.Items[I] as TJSONObject).GetValue('remetente').Value,
              (JSONArray.Items[I] as TJSONObject).GetValue('conteudo').Value
            ]
          );
          MemoMensagens.Lines.Add(Msg);
        end;
      end;
    finally
      Response.Free;
    end;
  finally
    Manager.Free;
  end;
end;
```

### Exemplo 3: Atualizar Múltiplos Campos

```delphi
procedure TForm1.AtualizarAtendimento(const ID: Integer);
var
  Manager: TManager_Atendimento;
begin
  Manager := TManager_Atendimento.Create;
  try
    // Alterar situação
    if Manager.AlterarSituacao(ID, 'em_andamento') then
      ShowMessage('Situação alterada');

    // Alterar setor
    if Manager.AlterarSetor(ID, 'Setor2') then
      ShowMessage('Setor alterado');
  finally
    Manager.Free;
  end;
end;
```

---

## 🚀 Próximos Passos

1. **Hoje:**

   - Copie APIClient.pas para seu projeto
   - Teste conexão básica

2. **Amanhã:**

   - Implemente formulário de atendimentos
   - Liste atendimentos do servidor

3. **Semana:**
   - Migre todas as operações CRUD
   - Teste com dados reais
   - Otimize performance

---

## 📞 Troubleshooting Rápido

| Problema             | Solução                          |
| -------------------- | -------------------------------- |
| "Connection refused" | Verifique se Apache está rodando |
| "Cannot reach host"  | Verifique URL e porta 80         |
| "Invalid JSON"       | Teste endpoint em Swagger UI     |
| "Empty response"     | Verifique logs do Apache         |

---

## 📖 Documentação Completa

Para mais detalhes, consulte:

- `MIGRACAO_DELPHI.txt` - Guia completo
- `DOCUMENTACAO_SWAGGER.md` - API completa
- `http://localhost/SAW-main/api/swagger-ui.html` - Teste interativo

---

**Criado:** 19/11/2025  
**Versão:** 1.0.0  
**Status:** ✅ Pronto para Usar

Boa migração! 🎊

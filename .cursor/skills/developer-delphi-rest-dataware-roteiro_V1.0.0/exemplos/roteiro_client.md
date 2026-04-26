---
description: "Exemplos de cliente REST — TRESTDWClientSQL e TRESTDWTable"
alwaysApply: false
---

# Roteiro — Cliente REST (REST DataWare)

> Fonte canônica: `app/modules/REST-DataWare/Documentation/Analise/Basic/RESTDWClientSQL.md`

## 1. TRESTDWClientSQL — consulta SQL com parâmetros

```pascal
uses uRESTDWClientSQL;

procedure TClientForm.ConsultarPorID(AID: Integer);
begin
  RESTDWClientSQL1.Close;
  RESTDWClientSQL1.SQL.Clear;
  RESTDWClientSQL1.SQL.Add('SELECT id, nome, email, cpf');
  RESTDWClientSQL1.SQL.Add('FROM clientes');
  RESTDWClientSQL1.SQL.Add('WHERE id = :pid_cliente');

  RESTDWClientSQL1.Params.ParamByName('pid_cliente').AsInteger := AID;

  RESTDWClientSQL1.Open;

  if not RESTDWClientSQL1.IsEmpty then
  begin
    ShowMessage(
      'Nome: ' + RESTDWClientSQL1.FieldByName('nome').AsString + #13 +
      'Email: ' + RESTDWClientSQL1.FieldByName('email').AsString
    );
  end;
end;
```

## 2. TRESTDWClientSQL — iteração de resultado

```pascal
procedure TClientForm.ListarClientes;
var
  LNomes: TStringList;
begin
  RESTDWClientSQL1.Close;
  RESTDWClientSQL1.SQL.Text := 'SELECT nome, cidade FROM clientes ORDER BY nome';
  RESTDWClientSQL1.Open;

  LNomes := TStringList.Create;
  try
    RESTDWClientSQL1.First;
    while not RESTDWClientSQL1.EOF do
    begin
      LNomes.Add(
        RESTDWClientSQL1.FieldByName('nome').AsString + ' — ' +
        RESTDWClientSQL1.FieldByName('cidade').AsString
      );
      RESTDWClientSQL1.Next;
    end;
    ShowMessage(LNomes.Text);
  finally
    LNomes.Free;
  end;
end;
```

## 3. TRESTDWClientSQL — ExecSQL (INSERT/UPDATE/DELETE)

```pascal
procedure TClientForm.InserirCliente(const ANome, AEmail: string);
begin
  RESTDWClientSQL1.Close;
  RESTDWClientSQL1.SQL.Text :=
    'INSERT INTO clientes (nome, email) VALUES (:pnome, :pemail)';

  RESTDWClientSQL1.Params.ParamByName('pnome').AsString  := ANome;
  RESTDWClientSQL1.Params.ParamByName('pemail').AsString := AEmail;

  RESTDWClientSQL1.ExecSQL;
  ShowMessage('Cliente inserido com sucesso');
end;
```

## 4. TRESTDWTable — acesso a tabela sem SQL

```pascal
uses uRESTDWClientTable;

procedure TClientForm.CarregarTabela;
begin
  RESTDWTable1.Close;
  RESTDWTable1.TableName := 'clientes';
  RESTDWTable1.Open;
  // RESTDWTable1 está populada — pode ligar a DBGrid/DataSource
end;

procedure TClientForm.InserirRegistro;
begin
  RESTDWTable1.Insert;
  RESTDWTable1.FieldByName('nome').AsString  := 'Ana Costa';
  RESTDWTable1.FieldByName('email').AsString := 'ana@empresa.com';
  RESTDWTable1.Post;
end;

procedure TClientForm.EditarRegistro;
begin
  // Localizar registro antes de editar
  if RESTDWTable1.Locate('id', 42, []) then
  begin
    RESTDWTable1.Edit;
    RESTDWTable1.FieldByName('email').AsString := 'ana.nova@empresa.com';
    RESTDWTable1.Post;
  end;
end;

procedure TClientForm.ExcluirRegistro;
begin
  if RESTDWTable1.Locate('id', 42, []) then
    RESTDWTable1.Delete;
end;
```

## 5. ApplyUpdates — enviar alterações ao servidor

```pascal
procedure TClientForm.SalvarAlteracoes;
var
  LErros: Integer;
begin
  // ApplyUpdates(MaxErrors): envia as alterações pendentes
  // Retorna o número de erros encontrados
  LErros := RESTDWClientSQL1.ApplyUpdates(0);  // 0 = sem tolerância a erros

  if LErros = 0 then
    ShowMessage('Alterações salvas com sucesso')
  else
    ShowMessage('Ocorreram ' + IntToStr(LErros) + ' erro(s) ao salvar');
end;
```

## 6. Tratamento de exceções no cliente

```pascal
uses uRESTDWException;

procedure TClientForm.ExecutarComTratamento;
begin
  try
    RESTDWClientSQL1.Open;
  except
    on E: eRESTDWTimeoutException do
      ShowMessage('Timeout ao conectar: ' + E.Message);
    on E: eRESTDWAuthException do
      ShowMessage('Falha de autenticação: ' + E.Message);
    on E: eRESTDWQueryException do
      ShowMessage('Erro na query: ' + E.Message);
    on E: eRESTDWException do
      ShowMessage('Erro RDW: ' + E.Message);
  end;
end;
```

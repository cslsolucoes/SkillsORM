---
name: developer-delphi-firedac-queries
description: >
  TFDQuery, TFDTable, execução de SQL, parâmetros nomeados, navegação de datasets,
  edição de dados, campos calculados, filtros, localização de registros, fetching,
  CachedUpdates, Array DML, execução assíncrona, stored procedures.
  Ativar quando o usuário mencionar: TFDQuery, TFDTable, executar SQL Delphi,
  parâmetros FireDAC, SELECT FireDAC, INSERT FireDAC, UPDATE FireDAC, DELETE FireDAC,
  Open FireDAC, ExecSQL, campos FireDAC, FieldByName, ParamByName, TFDStoredProc,
  filtrar dataset, navegar dataset, TFDMemTable, AsString AsInteger AsFloat.
model: sonnet
thinking: none
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-firedac-queries

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Criado** | 2026-04-24 |
| **Família** | FireDAC — Data Access |

## Responsabilidade única

Executar consultas e comandos SQL via FireDAC: SELECT, DML, parâmetros, navegação
de datasets, edição, filtros, campos calculados e stored procedures.

## When to use

- Executar SELECT e navegar pelos registros (`Open`, `First`, `Next`, `EOF`)
- Executar INSERT, UPDATE, DELETE (`ExecSQL`)
- Usar parâmetros nomeados (`ParamByName`, `:param`)
- Ler e modificar valores de campos (`FieldByName`, `.AsString`, `.AsInteger`)
- Filtrar e localizar registros sem nova query (`Filter`, `Locate`)
- Editar dados via dataset (`Append`, `Edit`, `Post`, `Cancel`, `Delete`)
- Chamar stored procedures (`TFDStoredProc`)
- Dataset em memória (`TFDMemTable`)

## When NOT to use

- Configurar conexão e drivers → `developer-delphi-firedac-connection`
- Transações e CachedUpdates → `developer-delphi-firedac-transactions`
- Visão geral FireDAC → `developer-delphi-firedac-orchestrator`

---

## §1 — SELECT e navegação básica

```pascal
uses FireDAC.Comp.Client, FireDAC.Stan.Param;

// Abrir query e navegar
procedure TdmPrincipal.ListarClientes;
begin
  qryClientes.Close;
  qryClientes.SQL.Text := 'SELECT ID, NOME, CIDADE FROM CLIENTES WHERE ATIVO = :ATIVO';
  qryClientes.ParamByName('ATIVO').AsInteger := 1;
  qryClientes.Open;

  while not qryClientes.EOF do
  begin
    Writeln(qryClientes.FieldByName('NOME').AsString);
    qryClientes.Next;
  end;
end;

// Leitura de campos com tipos
procedure TdmPrincipal.LerCampos;
begin
  var LId    := qryClientes.FieldByName('ID').AsInteger;
  var LNome  := qryClientes.FieldByName('NOME').AsString;
  var LSaldo := qryClientes.FieldByName('SALDO').AsCurrency;
  var LData  := qryClientes.FieldByName('DT_NASC').AsDateTime;
  var LAtivo := qryClientes.FieldByName('ATIVO').AsBoolean;

  // Verificar nulo antes de ler
  if not qryClientes.FieldByName('TELEFONE').IsNull then
    LNome := qryClientes.FieldByName('TELEFONE').AsString;
end;
```

---

## §2 — DML: INSERT, UPDATE, DELETE

```pascal
// INSERT via ExecSQL
procedure TdmPrincipal.InserirCliente(const ANome, ACidade: string; AAtivo: Boolean);
begin
  qryClientes.Close;
  qryClientes.SQL.Text :=
    'INSERT INTO CLIENTES (NOME, CIDADE, ATIVO, DT_CADASTRO) ' +
    'VALUES (:NOME, :CIDADE, :ATIVO, :DT)';
  qryClientes.ParamByName('NOME').AsString   := ANome;
  qryClientes.ParamByName('CIDADE').AsString := ACidade;
  qryClientes.ParamByName('ATIVO').AsBoolean := AAtivo;
  qryClientes.ParamByName('DT').AsDateTime   := Now;
  qryClientes.ExecSQL;
end;

// UPDATE via ExecSQL
procedure TdmPrincipal.AtualizarCidade(AId: Integer; const ACidade: string);
begin
  qryClientes.Close;
  qryClientes.SQL.Text := 'UPDATE CLIENTES SET CIDADE = :CIDADE WHERE ID = :ID';
  qryClientes.ParamByName('CIDADE').AsString := ACidade;
  qryClientes.ParamByName('ID').AsInteger    := AId;
  qryClientes.ExecSQL;
  // Linhas afetadas:
  // ShowMessage('Afetadas: ' + qryClientes.RowsAffected.ToString);
end;

// DELETE
procedure TdmPrincipal.ExcluirCliente(AId: Integer);
begin
  with TFDQuery.Create(nil) do
  try
    Connection := FDConnection1;
    SQL.Text   := 'DELETE FROM CLIENTES WHERE ID = :ID';
    ParamByName('ID').AsInteger := AId;
    ExecSQL;
  finally
    Free;
  end;
end;
```

---

## §3 — Edição via dataset (data-aware)

```pascal
// Modo de edição direto no dataset (usado com TDBGrid, TDBEdit)
procedure TdmPrincipal.InserirViaDataset(const ANome, ACidade: string);
begin
  qryClientes.Append;     // novo registro
  try
    qryClientes.FieldByName('NOME').AsString   := ANome;
    qryClientes.FieldByName('CIDADE').AsString := ACidade;
    qryClientes.FieldByName('ATIVO').AsBoolean := True;
    qryClientes.Post;    // confirma
  except
    qryClientes.Cancel;  // descarta em caso de erro
    raise;
  end;
end;

procedure TdmPrincipal.EditarAtual(const ANomeNovo: string);
begin
  qryClientes.Edit;
  try
    qryClientes.FieldByName('NOME').AsString := ANomeNovo;
    qryClientes.Post;
  except
    qryClientes.Cancel;
    raise;
  end;
end;

procedure TdmPrincipal.ExcluirAtual;
begin
  if MessageDlg('Confirmar exclusão?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    qryClientes.Delete;
end;
```

---

## §4 — Filtros e localização

```pascal
// Filter — aplica filtro em memória sem nova query
procedure TdmPrincipal.FiltrarPorCidade(const ACidade: string);
begin
  if ACidade = '' then
    qryClientes.Filter := ''
  else
    qryClientes.Filter := Format('CIDADE = ''%s''', [ACidade]);
  qryClientes.Filtered := ACidade <> '';
end;

// Locate — posicionar no primeiro registro que atende
function TdmPrincipal.LocalizarCliente(AId: Integer): Boolean;
begin
  Result := qryClientes.Locate('ID', AId, []);
  // loOptions: loCaseInsensitive, loPartialKey
end;

// Lookup — retornar valor de um campo sem mover o cursor
function TdmPrincipal.ObterNomeCliente(AId: Integer): string;
var LValor: Variant;
begin
  LValor := qryClientes.Lookup('ID', AId, 'NOME');
  if VarIsNull(LValor) then
    Result := ''
  else
    Result := LValor;
end;
```

---

## §5 — Campos calculados

```pascal
// Definir campo calculado no OnCalcFields
type
  TdmPrincipal = class(TDataModule)
    qryItens: TFDQuery;
    procedure qryItensCalcFields(DataSet: TDataSet);
  end;

procedure TdmPrincipal.qryItensCalcFields(DataSet: TDataSet);
begin
  // Campo TOTAL calculado: QTD * VALOR_UNIT
  DataSet.FieldByName('TOTAL').AsCurrency :=
    DataSet.FieldByName('QTD').AsInteger *
    DataSet.FieldByName('VALOR_UNIT').AsCurrency;
end;

// Criar campo calculado programaticamente
procedure TdmPrincipal.CriarCampoCalculado;
var LCampo: TFloatField;
begin
  LCampo          := TFloatField.Create(qryItens);
  LCampo.FieldName := 'TOTAL';
  LCampo.FieldKind := fkCalculated;
  LCampo.DataSet   := qryItens;
  LCampo.DisplayFormat := '#,##0.00';
  qryItens.OnCalcFields := qryItensCalcFields;
end;
```

---

## §6 — Stored Procedures

```pascal
uses FireDAC.Comp.Client;

procedure TdmPrincipal.ExecutarStoredProc(AClienteId: Integer);
begin
  spProc.Close;
  spProc.StoredProcName := 'SP_PROCESSAR_CLIENTE';
  spProc.Params.Clear;
  spProc.Prepare;  // carrega parâmetros do banco

  spProc.ParamByName('ID_CLIENTE').AsInteger := AClienteId;
  spProc.ExecProc;

  // Ler parâmetro de saída
  var LResultado := spProc.ParamByName('RESULTADO').AsString;
  ShowMessage('Resultado: ' + LResultado);
end;
```

---

## §7 — TFDMemTable — dataset em memória

```pascal
uses FireDAC.Comp.Client;

procedure TdmPrincipal.CriarMemTable;
begin
  // Criar campos manualmente
  FDMemTable1.FieldDefs.Add('ID',   ftInteger,  0);
  FDMemTable1.FieldDefs.Add('NOME', ftString,   100);
  FDMemTable1.FieldDefs.Add('VALOR',ftCurrency, 0);
  FDMemTable1.CreateDataSet;

  // Adicionar dados
  FDMemTable1.Append;
  FDMemTable1.FieldByName('ID').AsInteger    := 1;
  FDMemTable1.FieldByName('NOME').AsString   := 'Produto A';
  FDMemTable1.FieldByName('VALOR').AsCurrency := 99.90;
  FDMemTable1.Post;
end;

// Copiar estrutura de uma query para memória
procedure TdmPrincipal.CopiarParaMemoria;
begin
  FDMemTable1.Close;
  FDMemTable1.CloneCursor(qryClientes, False, True);
  // ou usar TFDDataSet.CopyDataSet
end;
```

---

## §8 — Fetching e performance

```pascal
// Fetch em blocos (não carregar tudo de uma vez)
procedure TdmPrincipal.ConfigurarFetch;
begin
  qryClientes.FetchOptions.Mode       := fmOnDemand;  // fetch sob demanda
  qryClientes.FetchOptions.RowsetSize := 50;          // 50 linhas por vez
  qryClientes.FetchOptions.Unidirectional := True;    // só para frente (melhor performance)
end;

// Fetch all quando o total é necessário
procedure TdmPrincipal.FetchTodos;
begin
  qryClientes.FetchOptions.Mode := fmAll;  // carrega tudo no Open
  qryClientes.Open;
end;

// RecordCount confiável só com fmAll ou após FetchAll
procedure TdmPrincipal.ContarRegistros;
begin
  qryClientes.FetchAll;  // força carregamento completo
  ShowMessage('Total: ' + qryClientes.RecordCount.ToString);
end;
```

---

## §9 — Checklist de qualidade — Queries

- [ ] Sempre usar parâmetros nomeados (`:param`) — nunca concatenar strings SQL
- [ ] `Close` antes de alterar `SQL.Text` ou `Params`
- [ ] `try/finally` com `Free` para queries criadas dinamicamente
- [ ] `Cancel` no `except` de operações de edição via dataset
- [ ] `FetchOptions.Mode` configurado conforme volume esperado
- [ ] Campos calculados declarados como `fkCalculated` no `FieldDefs`
- [ ] `ExecSQL` (sem retorno) vs `Open` (com retorno) usados corretamente

## Referências cruzadas

- `developer-delphi-firedac-connection` — TFDConnection, drivers
- `developer-delphi-firedac-transactions` — controle de transações
- `developer-delphi-firedac-orchestrator` — visão geral FireDAC
- `developer-delphi-vcl-components` — TDBGrid, TDBEdit, TDataSource

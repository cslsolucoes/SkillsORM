---
name: developer-delphi-firedac-transactions
description: >
  Controle de transações FireDAC: StartTransaction, Commit, Rollback, savepoints,
  CachedUpdates, ApplyUpdates, Array DML, execução assíncrona, transações aninhadas,
  isolation level. Ativar quando o usuário mencionar: transação Delphi, BEGIN TRANSACTION,
  Commit FireDAC, Rollback FireDAC, StartTransaction, savepoint FireDAC, CachedUpdates,
  ApplyUpdates, Array DML FireDAC, batch insert FireDAC, transação aninhada, isolation level.
model: sonnet
thinking: none
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-firedac-transactions

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Criado** | 2026-04-24 |
| **Família** | FireDAC — Data Access |

## Responsabilidade única

Controlar transações no FireDAC: transações explícitas e implícitas, savepoints,
CachedUpdates para edição em memória, Array DML para bulk insert/update, e
execução assíncrona de comandos.

## When to use

- Agrupar várias operações em uma transação atômica
- Implementar savepoints para rollback parcial
- Usar CachedUpdates para edição offline (usuário edita, depois aplica)
- Bulk insert/update com Array DML (alta performance)
- Executar queries longas de forma assíncrona sem travar a UI

## When NOT to use

- Apenas executar queries simples → `developer-delphi-firedac-queries`
- Configurar conexão → `developer-delphi-firedac-connection`

---

## §1 — Transação explícita (TFDTransaction)

```pascal
uses FireDAC.Comp.Client, FireDAC.Stan.Error;

// Padrão: usar TFDTransaction ligado ao TFDConnection
procedure TdmPrincipal.SalvarPedido(APedido: TPedidoDTO);
begin
  FDTransaction1.StartTransaction;
  try
    // 1. Inserir cabeçalho
    InserirCabecalhoPedido(APedido);
    // 2. Inserir itens
    for var LItem in APedido.Itens do
      InserirItemPedido(LItem);
    // 3. Atualizar estoque
    BaixarEstoque(APedido.Itens);

    FDTransaction1.Commit;
  except
    FDTransaction1.Rollback;
    raise;  // re-raise para o handler do form
  end;
end;
```

### Configurar TFDTransaction no DFM / código

```pascal
// No DataModule
FDTransaction1.Connection := FDConnection1;
FDTransaction1.Options.AutoCommit     := False;
FDTransaction1.Options.AutoStop       := True;   // fecha ao Commit/Rollback
FDTransaction1.Options.Isolation      := xiReadCommitted;
// xiReadUncommitted / xiReadCommitted / xiRepeatableRead / xiSerializable

// Associar queries à transação explícita
qryClientes.Transaction  := FDTransaction1;
qryItens.Transaction     := FDTransaction1;
```

---

## §2 — Transação via TFDConnection (atalho)

```pascal
// Alternativa mais simples quando só há uma transação ativa
procedure TdmPrincipal.TransacaoSimples;
begin
  FDConnection1.StartTransaction;
  try
    qryClientes.ExecSQL;
    qryItens.ExecSQL;
    FDConnection1.Commit;
  except
    FDConnection1.Rollback;
    raise;
  end;
end;

// Verificar se transação está ativa
if FDConnection1.InTransaction then
  FDConnection1.Commit;
```

---

## §3 — Savepoints (rollback parcial)

```pascal
procedure TdmPrincipal.ProcessarComSavepoint;
begin
  FDConnection1.StartTransaction;
  try
    InserirCabecalho;

    FDConnection1.Savepoint('sp_itens');   // savepoint nomeado
    try
      InserirItens;
    except
      FDConnection1.RollbackToSavepoint('sp_itens');  // desfaz só os itens
      // cabeçalho preservado
    end;

    FDConnection1.Commit;
  except
    FDConnection1.Rollback;
    raise;
  end;
end;
```

---

## §4 — CachedUpdates — edição offline

```pascal
// Ideal para grade editável: usuário edita vários registros, salva tudo de uma vez
procedure TdmPrincipal.AtivarCachedUpdates;
begin
  qryItens.CachedUpdates := True;
  qryItens.Open;
  // Edições via dataset vão para cache local (não ao banco ainda)
end;

procedure TdmPrincipal.AplicarAlteracoes;
begin
  FDConnection1.StartTransaction;
  try
    qryItens.ApplyUpdates(-1);   // -1 = não tolerar erros
    FDConnection1.Commit;
    qryItens.CommitUpdates;      // confirma o cache local
  except
    FDConnection1.Rollback;
    qryItens.CancelUpdates;      // descarta o cache
    raise;
  end;
end;

// Eventos de atualização
procedure TdmPrincipal.qryItensBeforeApplyUpdates(DataSet: TDataSet; var Applied: Boolean);
begin
  // Validar antes de aplicar
end;

procedure TdmPrincipal.qryItensOnApplyRecord(DataSet: TFDDataSet;
  AError: EFDDBEngineException; var AAction: TFDErrorAction);
begin
  if Assigned(AError) then
  begin
    TLogger.Instance.Error('Erro ao aplicar registro: ' + AError.Message);
    AAction := eaFail;   // ou eaSkip para pular o registro com erro
  end;
end;
```

---

## §5 — Array DML — bulk insert de alta performance

```pascal
// Inserir milhares de registros de uma vez (muito mais rápido que ExecSQL em loop)
procedure TdmPrincipal.BulkInsert(AItens: TArray<TItemDTO>);
const LOTE = 1000;
var
  LCount, LIdx: Integer;
begin
  qryBulk.SQL.Text :=
    'INSERT INTO ITENS (COD, NOME, VALOR) VALUES (:COD, :NOME, :VALOR)';

  qryBulk.Params.ArraySize := LOTE;
  FDConnection1.StartTransaction;
  try
    LIdx := 0;
    LCount := 0;
    for var LItem in AItens do
    begin
      qryBulk.Params[0].AsIntegers[LIdx] := LItem.Codigo;
      qryBulk.Params[1].AsStrings[LIdx]  := LItem.Nome;
      qryBulk.Params[2].AsCurrencys[LIdx]:= LItem.Valor;
      Inc(LIdx);
      Inc(LCount);

      if LIdx = LOTE then
      begin
        qryBulk.Params.ArraySize := LIdx;
        qryBulk.Execute(LIdx);
        LIdx := 0;
        qryBulk.Params.ArraySize := LOTE;
      end;
    end;

    // Último lote
    if LIdx > 0 then
    begin
      qryBulk.Params.ArraySize := LIdx;
      qryBulk.Execute(LIdx);
    end;

    FDConnection1.Commit;
  except
    FDConnection1.Rollback;
    raise;
  end;
end;
```

---

## §6 — Execução assíncrona

```pascal
uses FireDAC.Stan.Async;

// Executar query longa sem travar a UI
procedure TdmPrincipal.ExecutarRelatorioAsync;
begin
  qryRelatorio.SQL.Text := 'SELECT ... FROM VENDAS WHERE ...';  // query pesada

  // Executar em background
  qryRelatorio.Execute(0, 0, [eoAsyncExecute]);

  // Opção: usar callback ao terminar
  qryRelatorio.OnAsyncProgress := procedure(ADataSet: TFDDataSet)
  begin
    // Atualizar barra de progresso na UI (via TThread.Queue)
    TThread.Queue(nil, procedure
    begin
      frmPrincipal.ProgressBar1.Position := ADataSet.RecordCount;
    end);
  end;
end;

// Cancelar execução assíncrona
procedure TdmPrincipal.CancelarAsync;
begin
  if qryRelatorio.Options.StmtOptions.AsyncExecute then
    qryRelatorio.AbortJob;
end;
```

---

## §7 — Checklist de qualidade — Transações

- [ ] `try/except` com `Rollback` no `except` para toda transação explícita
- [ ] Re-raise após `Rollback` — não silenciar exceções
- [ ] `CommitUpdates` / `CancelUpdates` sincronizados com `Commit` / `Rollback`
- [ ] `ArraySize` configurado antes de popular parâmetros do Array DML
- [ ] Lotes de no máximo 1000 registros no Array DML para evitar estouro de memória
- [ ] Isolation level definido explicitamente conforme regras de negócio
- [ ] `AbortJob` disponível para o usuário cancelar queries assíncronas longas

## Referências cruzadas

- `developer-delphi-firedac-queries` — execução de SQL e datasets
- `developer-delphi-firedac-connection` — TFDConnection, drivers
- `developer-delphi-firedac-orchestrator` — visão geral FireDAC

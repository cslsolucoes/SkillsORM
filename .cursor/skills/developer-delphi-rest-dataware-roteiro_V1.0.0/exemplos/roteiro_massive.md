---
description: "Exemplos de operações em lote — TRESTDWMassiveCache"
alwaysApply: false
---

# Roteiro — MassiveCache (REST DataWare)

> Fonte canônica: `app/modules/REST-DataWare/Documentation/Analise/Basic/RESTDWMassiveCache.md`

> **ADR RDW-04:** Usar MassiveCache para toda operação de batch > 10 registros.
> Nunca fazer loop de ApplyUpdates linha a linha — causa degradação severa de performance.

## 1. MassiveCache — INSERT em lote

```pascal
uses uRESTDWMassiveCache;

procedure TClientForm.InserirLote(AClientes: TList);
var
  LMassive: TRESTDWMassiveCache;
  I: Integer;
  LCliente: TClienteRecord;
begin
  LMassive := TRESTDWMassiveCache.Create(nil);
  try
    LMassive.TableName := 'clientes';

    // Acumular todos os INSERTs em memória
    for I := 0 to AClientes.Count - 1 do
    begin
      LCliente := TClienteRecord(AClientes[I]);

      LMassive.Append;
      LMassive.FieldByName('nome').AsString    := LCliente.Nome;
      LMassive.FieldByName('email').AsString   := LCliente.Email;
      LMassive.FieldByName('cpf').AsString     := LCliente.CPF;
      LMassive.FieldByName('ativo').AsBoolean  := True;
      LMassive.Post;
    end;

    // Enviar TUDO em um único request HTTP
    LMassive.RESTDWClientSQL := RESTDWClientSQL1;
    LMassive.ApplyUpdates;

    ShowMessage(IntToStr(AClientes.Count) + ' clientes inseridos com sucesso');
  finally
    LMassive.Free;
  end;
end;
```

## 2. MassiveCache — UPDATE em lote

```pascal
procedure TClientForm.AtualizarCidadeLote(const ACidade: string; AIds: array of Integer);
var
  LMassive: TRESTDWMassiveCache;
  LID: Integer;
begin
  LMassive := TRESTDWMassiveCache.Create(nil);
  try
    LMassive.TableName := 'clientes';

    for LID in AIds do
    begin
      // KeyField: campo de chave para identificar o registro
      LMassive.KeyField := 'id';
      LMassive.Edit;
      LMassive.FieldByName('id').AsInteger      := LID;
      LMassive.FieldByName('cidade').AsString   := ACidade;
      LMassive.FieldByName('atualizado').AsDate := Date;
      LMassive.Post;
    end;

    LMassive.RESTDWClientSQL := RESTDWClientSQL1;
    LMassive.ApplyUpdates;
  finally
    LMassive.Free;
  end;
end;
```

## 3. MassiveCache — DELETE em lote

```pascal
procedure TClientForm.ExcluirInativos(AIds: array of Integer);
var
  LMassive: TRESTDWMassiveCache;
  LID: Integer;
begin
  LMassive := TRESTDWMassiveCache.Create(nil);
  try
    LMassive.TableName := 'clientes';
    LMassive.KeyField  := 'id';

    for LID in AIds do
    begin
      LMassive.Delete;
      LMassive.FieldByName('id').AsInteger := LID;
      LMassive.Post;
    end;

    LMassive.RESTDWClientSQL := RESTDWClientSQL1;
    LMassive.ApplyUpdates;
  finally
    LMassive.Free;
  end;
end;
```

## 4. MassiveCache — operações mistas (INSERT + UPDATE + DELETE)

```pascal
procedure TClientForm.SincronizarRegistros(
  AInserir, AAtualizar, AExcluir: TList);
var
  LMassive: TRESTDWMassiveCache;
  I: Integer;
begin
  LMassive := TRESTDWMassiveCache.Create(nil);
  try
    LMassive.TableName := 'clientes';
    LMassive.KeyField  := 'id';

    // Fase INSERT
    for I := 0 to AInserir.Count - 1 do
    begin
      LMassive.Append;
      // ... preencher campos ...
      LMassive.Post;
    end;

    // Fase UPDATE
    for I := 0 to AAtualizar.Count - 1 do
    begin
      LMassive.Edit;
      // ... preencher campos incluindo chave ...
      LMassive.Post;
    end;

    // Fase DELETE
    for I := 0 to AExcluir.Count - 1 do
    begin
      LMassive.Delete;
      LMassive.FieldByName('id').AsInteger := Integer(AExcluir[I]);
      LMassive.Post;
    end;

    // Envio único — todas as operações em um request
    LMassive.RESTDWClientSQL := RESTDWClientSQL1;
    LMassive.ApplyUpdates;

    ShowMessage(
      'Inseridos: ' + IntToStr(AInserir.Count) + #13 +
      'Atualizados: ' + IntToStr(AAtualizar.Count) + #13 +
      'Excluídos: ' + IntToStr(AExcluir.Count)
    );
  finally
    LMassive.Free;
  end;
end;
```

## 5. Comparação: loop individual vs. MassiveCache

```pascal
// ERRADO — loop de ApplyUpdates linha a linha (anti-padrão RDW-04)
// Causa N round-trips HTTP para N registros
procedure TClientForm.InserirLoteErrado(AClientes: TList);
var
  I: Integer;
begin
  for I := 0 to AClientes.Count - 1 do
  begin
    RESTDWClientSQL1.Insert;
    // ... preencher campos ...
    RESTDWClientSQL1.Post;
    RESTDWClientSQL1.ApplyUpdates(0);  // 1 request por registro — LENTO
  end;
end;

// CORRETO — MassiveCache (1 round-trip para N registros)
// Ver exemplos 1–4 acima
```

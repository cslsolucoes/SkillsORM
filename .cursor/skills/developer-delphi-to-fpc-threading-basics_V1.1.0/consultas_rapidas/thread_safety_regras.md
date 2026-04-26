# Thread Safety — Regras Obrigatórias

## Regra 1: UI só na main thread

**NUNCA** acessar componentes VCL ou FMX de uma thread secundária:

```pascal
// ERRADO — causa Access Violation ou flickering imprevisível
procedure TWorker.Execute;
begin
  Label1.Caption := 'Pronto';       // ERRADO
  ProgressBar1.Position := 50;      // ERRADO
  ListBox1.Items.Add('item');        // ERRADO
  Form1.Close;                       // ERRADO
end;

// CORRETO — sempre via Queue (preferido) ou Synchronize
procedure TWorker.Execute;
begin
  Queue(procedure
  begin
    Label1.Caption := 'Pronto';
    ProgressBar1.Position := 50;
  end);
end;
```

**Por que:** O VCL/FMX message loop e o GDI/DirectX operam na main thread. Acesso concorrente corrompe estado interno dos controles.

---

## Regra 2: Sincronizar SEMPRE com try/finally

```pascal
// ERRADO — exceção em ProcessarItem deixa o lock preso para sempre
FLock.Enter;
ProcessarItem;       // se lançar exceção → Leave nunca chamado → deadlock
FLock.Leave;

// CORRETO
FLock.Enter;
try
  ProcessarItem;
finally
  FLock.Leave;       // executado mesmo em caso de exceção
end;
```

---

## Regra 3: Verificar Terminated dentro de Execute

```pascal
// ERRADO — thread ignora pedido de cancelamento
procedure TWorker.Execute;
var I: Integer;
begin
  for I := 1 to 1_000_000 do
    ProcessarItem(I);        // nunca cancela
end;

// CORRETO — verificar Terminated periodicamente
procedure TWorker.Execute;
var I: Integer;
begin
  for I := 1 to 1_000_000 do
  begin
    if Terminated then Exit;  // saída limpa
    ProcessarItem(I);
  end;
end;
```

---

## Regra 4: Não acessar TThread após FreeOnTerminate = True

```pascal
// ERRADO — objeto pode já ter sido destruído
var W: TWorker;
W := TWorker.Create;  // FreeOnTerminate = True por padrão
W.Start;
W.Priority := tpLow;  // CRASH POTENCIAL: W já destruído se terminou

// CORRETO: configurar antes de liberar o controle
W := TWorker.Create;
W.FreeOnTerminate := True;
W.Priority := tpLow;   // configurar ANTES de Start
W.Start;
// Não tocar em W após Start com FreeOnTerminate = True
```

---

## Regra 5: Ordem de destruição dos locks

```pascal
// CORRETO: threads terminam antes de liberar o lock
var Lock: TCriticalSection;
var W: TWorker;
Lock := TCriticalSection.Create;
try
  W := TWorker.Create(..., Lock);
  try
    W.Start;
    W.WaitFor;          // threads terminaram
  finally
    W.Free;
  end;
finally
  Lock.Free;            // liberar DEPOIS das threads
end;
```

---

## Regra 6: TMonitor.Wait sempre em loop while

```pascal
// ERRADO — spurious wakeups existem em todos os sistemas operacionais
TMonitor.Wait(FQueue, INFINITE);
var Item := FQueue.Dequeue;   // fila pode estar vazia!

// CORRETO — verificar condição após acordar
while FQueue.Count = 0 do
  TMonitor.Wait(FQueue, INFINITE);
var Item := FQueue.Dequeue;
```

---

## Regra 7: Evitar Synchronize quando main thread pode estar bloqueada

```pascal
// PERIGO — se chamar WaitFor na main thread enquanto worker usa Synchronize
procedure TForm1.BtnProcessarClick(Sender: TObject);
var W: TWorker;
begin
  W := TWorker.Create;
  W.WaitFor;  // main thread bloqueia → Synchronize nunca executa → deadlock
  W.Free;
end;

// SOLUÇÃO A: usar Queue em vez de Synchronize na thread
// SOLUÇÃO B: WaitFor em thread auxiliar
// SOLUÇÃO C: usar TTask com continuação (ver threading-advanced)
```

---

## Regra 8: Variáveis locais em closures de threads

```pascal
// PERIGO — captura de variável de loop por referência
for I := 0 to N - 1 do
  TThread.CreateAnonymousThread(procedure
  begin
    // I pode ser N ao executar (loop já terminou)
    ProcessarIndice(I);  // todos processam o mesmo I final!
  end).Start;

// CORRETO — capturar por valor com variável local
for I := 0 to N - 1 do
begin
  var Idx := I;  // copia imutável por thread
  TThread.CreateAnonymousThread(procedure
  begin
    ProcessarIndice(Idx);  // cada thread tem seu próprio Idx
  end).Start;
end;
```

---

## Regra 9: Exceções em threads secundárias

```pascal
// Exceções em Execute que não são tratadas TERMINAM a thread silenciosamente
// Em Delphi: a exceção fica guardada em FatalException
procedure TWorker.Execute;
begin
  try
    FazTrabalho;
  except
    on E: Exception do
    begin
      // Registrar erro e notificar main thread
      FErro := E.Message;
      Queue(procedure
      begin
        ShowMessage('Erro na thread: ' + FErro);
      end);
    end;
  end;
end;

// Verificar exceção após WaitFor (se FreeOnTerminate = False):
W.WaitFor;
if Assigned(W.FatalException) then
  raise W.FatalException;  // re-lança na main thread
```

---

## Regra 10: Dados imutáveis não precisam de lock

```pascal
// Dados criados antes das threads e nunca modificados:
// NÃO precisam de lock — read-only é sempre thread-safe
const
  TABELA: array[0..9] of Integer = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

// Qualquer thread pode ler TABELA sem lock — é imutável
procedure TWorker.Execute;
var I: Integer;
begin
  for I := Low(TABELA) to High(TABELA) do
    Processar(TABELA[I]);  // seguro: TABELA não muda
end;
```

---

## Checklist de revisão de código thread-safe

- [ ] Toda atualização de UI usa `Queue` ou `Synchronize`
- [ ] Todo `Enter`/`BeginRead`/`BeginWrite` tem `finally` correspondente
- [ ] `Execute` verifica `Terminated` em loops longos
- [ ] `FreeOnTerminate = True` — não usar a referência após `Start`
- [ ] Locks destruídos apenas APÓS todas as threads pararem
- [ ] `TMonitor.Wait` está dentro de loop `while`
- [ ] Closures de thread capturam por variável local (não variável de loop)
- [ ] Exceções em `Execute` são tratadas internamente ou verificadas via `FatalException`

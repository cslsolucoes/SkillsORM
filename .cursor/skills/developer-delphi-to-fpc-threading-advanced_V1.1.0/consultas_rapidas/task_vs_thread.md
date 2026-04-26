# TTask vs TThread — Quando usar cada um

## Resumo executivo

| Critério | `TTask` (PPL) | `TThread` |
|---|---|---|
| Gestão de thread | Automática (thread pool) | Manual |
| Overhead de criação | Muito baixo (reusa threads) | Alto (cria thread de SO) |
| Cancelamento | `TCancellationToken` | `Terminate` + `Terminated` |
| Valor de retorno | `ITask<T>.Value` | Variável compartilhada + lock |
| Composição | `WaitForAll`, `WaitForAny`, encadeamento | Manual com `WaitFor` |
| Exceções | Capturadas em `T.Exception` | `T.FatalException` |
| Ciclo de vida | Gerenciado pela interface `ITask` | Manual (`Free` ou `FreeOnTerminate`) |
| Comunicação com UI | `TThread.Queue(nil, proc)` | `Queue(proc)` ou `Synchronize(proc)` |
| Melhor para | Tarefas pontuais, computação paralela, futures | Threads longevas com estado próprio, workers com fila |

---

## Quando usar TTask

```pascal
uses System.Threading;

// 1. Tarefa assíncrona única e curta
var T := TTask.Run(procedure begin FazTrabalho; end);
T.Wait;

// 2. Valor de retorno (Future)
var TF := TTask<Integer>.Run(function: Integer begin Result := Calcular; end);
var V  := TF.Value;   // bloqueia até ter resultado

// 3. Múltiplas tarefas paralelas
TTask.WaitForAll([
  TTask.Run(procedure begin FazA; end),
  TTask.Run(procedure begin FazB; end),
  TTask.Run(procedure begin FazC; end)
]);

// 4. Cancelamento simples
var Cancel := TCancellationTokenSource.Create;
var T := TTask.Run(procedure
begin
  if Cancel.Token.IsCancellationRequested then Exit;
  FazTrabalho;
end, Cancel.Token);
Cancel.Cancel;
T.Wait;
Cancel.Free;
```

**Use TTask quando:**
- A tarefa tem duração limitada e não precisa de gerenciamento de estado complexo
- Precisa compor múltiplas operações assíncronas
- Precisa de Future pattern (valor de retorno assíncrono)
- Quer aproveitar o thread pool do sistema

---

## Quando usar TThread

```pascal
uses System.Classes;

// Thread longeva com fila de trabalho — continua viva esperando trabalho
type
  TWorkerLongevo = class(TThread)
  private
    FFila: TQueue<TItem>;
    FLock: TCriticalSection;
  protected
    procedure Execute; override;
  end;

procedure TWorkerLongevo.Execute;
begin
  // Fica viva indefinidamente processando itens
  while not Terminated do
  begin
    FLock.Enter;
    try
      if FFila.Count > 0 then ProcessarItem(FFila.Dequeue);
    finally
      FLock.Leave;
    end;
    if FFila.Count = 0 then Sleep(1);
  end;
end;
```

**Use TThread quando:**
- A thread precisa viver longa (ex.: loop de evento, servidor de socket)
- Precisa de prioridade específica (`Priority := tpHigh`)
- Precisa de afinidade de CPU (`SetThreadAffinityMask`)
- A lógica de ciclo de vida é complexa demais para closure
- Legado: código já usa herança de TThread

---

## Comparação de padrões equivalentes

### Criar e aguardar

```pascal
// TTask
var T := TTask.Run(procedure begin FazTrabalho; end);
T.Wait;

// TThread
var W := TThread.CreateAnonymousThread(procedure begin FazTrabalho; end);
W.FreeOnTerminate := False;
W.Start;
W.WaitFor;
W.Free;
```

### Valor de retorno

```pascal
// TTask<T> — limpo e sem lock
var TF := TTask<Integer>.Run(function: Integer begin Result := 42; end);
var V  := TF.Value;

// TThread — verboso, requer campo compartilhado
var Resultado: Integer;
var T := TThread.CreateAnonymousThread(procedure begin Resultado := 42; end);
T.FreeOnTerminate := False;
T.Start;
T.WaitFor;
T.Free;
// V := Resultado;
```

### Múltiplas em paralelo

```pascal
// TTask — conciso
TTask.WaitForAll([TTask.Run(A), TTask.Run(B), TTask.Run(C)]);

// TThread — verboso
var W1 := TThread.CreateAnonymousThread(A); W1.FreeOnTerminate := False; W1.Start;
var W2 := TThread.CreateAnonymousThread(B); W2.FreeOnTerminate := False; W2.Start;
var W3 := TThread.CreateAnonymousThread(C); W3.FreeOnTerminate := False; W3.Start;
W1.WaitFor; W2.WaitFor; W3.WaitFor;
W1.Free; W2.Free; W3.Free;
```

---

## Thread Pool do TTask

O `TTask` usa um pool de threads global gerenciado pelo Delphi:
- Número de threads: `TThreadPool.Default.MaxWorkerThreads` (padrão: número de CPUs × 25)
- Evita criar/destruir threads para cada tarefa (overhead de ~1-2 ms por criação de thread)
- Adequado para tarefas curtas e numerosas
- **Não adequado** para tarefas que bloqueiam por muito tempo (esgota o pool)

```pascal
// Ver/ajustar pool
WriteLn(TThreadPool.Default.MinWorkerThreads);
WriteLn(TThreadPool.Default.MaxWorkerThreads);
// TThreadPool.Default.MaxWorkerThreads := 32;  // aumentar se necessário
```

---

## Referências cruzadas

- `exemplos/ttask_ppl.pas` — TTask completo com futures e cancelamento
- `developer-delphi-to-fpc-threading-basics_V1.1.0` — TThread em detalhe
- `parallel_pitfalls.md` — armadilhas de paralelismo

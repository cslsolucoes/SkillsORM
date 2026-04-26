---
name: developer-delphi-to-fpc-threading-advanced
description: Concorrência avançada em Delphi — PPL, TTask, TParallel.For, IFuture e padrões producer-consumer.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-threading-advanced_V1.1.0

**Versão:** 1.1.0
**Área:** Concorrência Avançada — PPL (Parallel Programming Library)
**Compatibilidade:** Delphi 10.4+ (Win32/Win64) · dcc32/dcc64
**Locale:** pt-BR

---

## O que é

Esta skill cobre a Parallel Programming Library (PPL) do Delphi e técnicas
avançadas de threading: `TTask`, `TParallel.For`, `TThreadedQueue<T>`,
`TInterlocked` (operações lock-free), padrões de pipeline e prevenção de
deadlock.

Para primitivas básicas (`TThread`, `TCriticalSection`, `TMonitor`, `TEvent`),
consulte `developer-delphi-to-fpc-threading-basics_V1.1.0`.

---

## Casos de uso

| Situação | API recomendada |
|---|---|
| Tarefa assíncrona única sem gerenciar thread | `TTask.Run` |
| Aguardar múltiplas tarefas paralelas | `TTask.WaitForAll` |
| Valor calculado em background (Future) | `TTask<T>.Run` + `.Value` |
| Iterar coleção em paralelo | `TParallel.For` |
| Fila thread-safe de alta produção | `TThreadedQueue<T>` |
| Contador/flag atômico sem lock | `TInterlocked.Increment/Exchange` |
| CAS (Compare-And-Swap) lock-free | `TInterlocked.CompareExchange` |
| Pipeline de stages assíncronos | `TTask` + continuações |

---

## API principal

### TTask — Parallel Programming Library

```pascal
uses System.Threading;

// ---- Criar e iniciar task imediatamente ----
var T: ITask := TTask.Run(procedure
begin
  // código assíncrono — executa no thread pool gerenciado
  FazTrabalho;
end);

// ---- Aguardar conclusão ----
T.Wait;               // bloqueia o chamador até T terminar
T.Wait(5000);         // com timeout de 5000 ms — lança EOperationCancelled se expirar

// ---- Aguardar múltiplas tasks ----
var T1, T2, T3: ITask;
T1 := TTask.Run(procedure begin FazA; end);
T2 := TTask.Run(procedure begin FazB; end);
T3 := TTask.Run(procedure begin FazC; end);
TTask.WaitForAll([T1, T2, T3]);       // bloqueia até todas terminarem
TTask.WaitForAny([T1, T2, T3]);       // bloqueia até qualquer uma terminar

// ---- Task com valor de retorno (Future pattern) ----
var TF: ITask<Integer> := TTask<Integer>.Run(function: Integer
begin
  Result := CalcularValor;
end);
var Resultado: Integer := TF.Value;   // bloqueia até concluir, retorna resultado

// ---- Verificar estado ----
case T.Status of
  TTaskStatus.Created   : { criada, não iniciada };
  TTaskStatus.Running   : { executando };
  TTaskStatus.Completed : { concluída com sucesso };
  TTaskStatus.Exception : { falhou — acessar T.Exception };
  TTaskStatus.Canceled  : { cancelada };
end;

// ---- Task com cancelamento ----
var Cancel := TCancellationTokenSource.Create;
var Token  := Cancel.Token;
var TC: ITask := TTask.Run(procedure
begin
  while not Token.IsCancellationRequested do
    FazIteracao;
end, Token);
Cancel.Cancel;   // solicita cancelamento
TC.Wait;
Cancel.Free;
```

**Estados de TTask:**

| Status | Significado |
|---|---|
| `Created` | Criada, não iniciada (Use `TTask.Create` + `.Start`) |
| `WaitingToRun` | Na fila do pool, aguardando thread |
| `Running` | Executando |
| `Completed` | Concluída com sucesso |
| `Exception` | Falhou — verificar `.Exception` |
| `Canceled` | Cancelada via `TCancellationToken` |

---

### TParallel.For — iteração paralela

```pascal
uses System.Threading;

// ---- Forma básica ----
TParallel.For(0, Dados.Count - 1, procedure(I: Integer)
begin
  ProcessarItem(Dados[I]);   // executa em threads do pool simultaneamente
end);
// Bloqueante: retorna apenas após TODAS as iterações concluírem

// ---- Com controle de parada ----
TParallel.For(0, N - 1, procedure(I: Integer; LoopState: TParallelLoopState)
begin
  if EncontrarAlvo(Dados[I]) then
    LoopState.Break;   // interrompe iterações futuras (em andamento continuam)
    // LoopState.Stop — interrupção mais agressiva
end);

// ---- Retorno com informações do loop ----
var Info := TParallel.For(0, N - 1, procedure(I: Integer)
begin
  ProcessarItem(I);
end);

if Info.IsExceptional then
  raise Info.Exception;
if Info.Completed then
  WriteLn('Todas as iterações concluíram');

// ---- Com stride (passo > 1) — Delphi 11+ ----
TParallel.For(0, N - 1, 4, procedure(I: Integer)
begin
  ProcessarBloco(I, 4);  // processa bloco de 4 elementos a partir de I
end);
```

**Regras críticas do TParallel.For:**
- A função de iteração deve ser **reentrantável** (não compartilhar estado mutável sem lock)
- Se precisar acumular resultado: usar `TInterlocked` ou lock por thread
- `LoopState.Break` marca iterações acima de I para não iniciar; as já em execução continuam

---

### TThreadedQueue\<T\> — fila thread-safe de alta performance

```pascal
uses System.Generics.Collections;

// Construtor: (AQueueDepth, APushTimeout, APopTimeout)
//   AQueueDepth  = capacidade máxima (0 = ilimitada)
//   APushTimeout = ms de espera se fila cheia (INFINITE = esperar sempre)
//   APopTimeout  = ms de espera se fila vazia (INFINITE = esperar sempre)
var Q: TThreadedQueue<string>;
Q := TThreadedQueue<string>.Create(1000, INFINITE, INFINITE);
try
  // ---- Produtor (qualquer thread) ----
  var R := Q.PushItem('mensagem');
  case R of
    wrSignaled : { ok };
    wrTimeout  : { fila cheia e timeout expirou };
    wrAbandoned: { fila foi encerrada/destruída };
  end;

  // Alternativa: PushItem sem retorno (lança exceção em timeout)
  Q.PushItem('msg');

  // ---- Consumidor (outra thread) ----
  var Item: string;
  var Res := Q.PopItem(Item);     // bloqueia até ter item ou timeout
  if Res = wrSignaled then
    Processar(Item);

  // PopItem com timeout explícito:
  var Res2 := Q.PopItem(Item, 2000);  // 2000 ms

  // ---- Encerramento ----
  Q.DoShutDown;  // sinaliza encerramento — PopItem retorna wrAbandoned

finally
  Q.Free;
end;

// ---- Inspecionar estado ----
WriteLn(Q.QueueSize);    // itens na fila agora
WriteLn(Q.TotalItemsPushed);
WriteLn(Q.TotalItemsPopped);
```

---

### TInterlocked — operações atômicas lock-free

```pascal
uses System.SyncObjs;

var FContador: Integer;
var FValor   : Integer;
var FEstado  : Integer;

// ---- Increment / Decrement ----
TInterlocked.Increment(FContador);     // FContador++ atômico
TInterlocked.Decrement(FContador);     // FContador-- atômico
var Novo := TInterlocked.Increment(FContador);  // retorna NOVO valor

// ---- Exchange — troca e retorna o valor anterior ----
var Anterior := TInterlocked.Exchange(FValor, 42);

// ---- CompareExchange — CAS (Compare-And-Swap) ----
// Troca FEstado para NOVO somente se FEstado atual = ESPERADO
// Retorna o valor LIDO (pode ser diferente de ESPERADO se outra thread mudou)
const LIVRE = 0; OCUPADO = 1;
var Lido := TInterlocked.CompareExchange(FEstado, {novoValor=}OCUPADO, {esperado=}LIVRE);
if Lido = LIVRE then
begin
  // adquiriu "lock" via CAS — processar
  try
    FazTrabalho;
  finally
    TInterlocked.Exchange(FEstado, LIVRE);  // liberar
  end;
end
else
  // outra thread já estava OCUPADO — tratar contenção

// ---- Add ----
TInterlocked.Add(FContador, 5);   // FContador += 5 atômico

// ---- CompareExchange para ponteiros/objetos ----
var Anterior: TObject;
TInterlocked.CompareExchange(FObj, NovoObj, nil);  // inicializar uma vez (lazy init)
```

**Quando usar TInterlocked vs TCriticalSection:**

| Cenário | Usar |
|---|---|
| Incrementar/decrementar contador | `TInterlocked` |
| Inicializar singleton (lazy) | `TInterlocked.CompareExchange` |
| Flag booleano de estado | `TInterlocked.Exchange` |
| Seção crítica com múltiplas operações | `TCriticalSection` |
| Operações condicionais complexas | `TCriticalSection` |

---

### Padrão Pipeline com TTask

```pascal
uses System.Threading;

// Pipeline: Estágio1 → Estágio2 → Estágio3
// Cada estágio processa em paralelo com os outros

var Fila12 := TThreadedQueue<string>.Create(50, INFINITE, 500);
var Fila23 := TThreadedQueue<string>.Create(50, INFINITE, 500);
try
  var Estagio1 := TTask.Run(procedure
  begin
    // Produz dados e empurra para próxima etapa
    var I: Integer;
    for I := 1 to 100 do
      Fila12.PushItem(Format('Dado-%d', [I]));
    Fila12.PushItem('FIM');  // sentinela
  end);

  var Estagio2 := TTask.Run(procedure
  var Item: string;
  begin
    while True do
    begin
      if Fila12.PopItem(Item) = wrSignaled then
      begin
        if Item = 'FIM' then Break;
        Fila23.PushItem('Transformado-' + Item);
      end;
    end;
    Fila23.PushItem('FIM');
  end);

  var Estagio3 := TTask.Run(procedure
  var Item: string;
  begin
    while True do
    begin
      if Fila23.PopItem(Item) = wrSignaled then
      begin
        if Item = 'FIM' then Break;
        // Processar item final
        SalvarResultado(Item);
      end;
    end;
  end);

  TTask.WaitForAll([Estagio1, Estagio2, Estagio3]);
finally
  Fila12.Free;
  Fila23.Free;
end;
```

---

## Exemplos incluídos

| Arquivo | Conteúdo |
|---|---|
| `exemplos/ttask_ppl.pas` | TTask.Run, ITask, WaitForAll, TTask<T> (Future) |
| `exemplos/tparallel.pas` | TParallel.For com LoopState.Break e acumuladores |
| `exemplos/tthreadedqueue.pas` | TThreadedQueue<T>: produtor-consumidor N:M |
| `exemplos/async_await_pattern.pas` | TTask como async/await com continuação na UI |
| `exemplos/lock_free.pas` | TInterlocked: Increment, CompareExchange, CAS |
| `exemplos/parallel_aggregate.pas` | TParallel.For com acumulação thread-safe |

---

## Armadilhas comuns

### 1. Race condition em TParallel.For

```pascal
// ERRADO — múltiplas threads escrevem em Total simultaneamente
var Total: Integer := 0;
TParallel.For(0, N - 1, procedure(I: Integer)
begin
  Inc(Total);   // race condition!
end);

// CORRETO — operação atômica
var Total: Integer := 0;
TParallel.For(0, N - 1, procedure(I: Integer)
begin
  TInterlocked.Increment(Total);
end);
```

### 2. Captura de variável em TTask.Run

```pascal
// PERIGO — variável de loop capturada por referência
for I := 0 to N - 1 do
  TTask.Run(procedure begin ProcessarIndice(I); end);  // todos veem I = N

// CORRETO
for I := 0 to N - 1 do
begin
  var Idx := I;
  TTask.Run(procedure begin ProcessarIndice(Idx); end);
end;
```

### 3. Exceções em TTask não propagadas automaticamente

```pascal
var T: ITask := TTask.Run(procedure begin raise EInvalidOperation.Create('Erro'); end);
T.Wait;   // NÃO lança a exceção aqui!

// Verificar explicitamente:
if T.Status = TTaskStatus.Exception then
  raise T.Exception;  // ou T.Exception.RaiseOuterException

// Ou: Wait com reraise automático usando WaitForAll
TTask.WaitForAll([T]);  // lança AggregateException se alguma task falhou
```

### 4. Deadlock com TTask.Wait na main thread + Synchronize

```pascal
// PERIGO — mesmo deadlock que com TThread.WaitFor
var T := TTask.Run(procedure
begin
  TThread.Synchronize(nil, procedure begin AtualizarUI; end);
end);
T.Wait;   // main thread bloqueada → Synchronize não processa → deadlock

// SOLUÇÃO: usar Queue em vez de Synchronize dentro de TTask
TThread.Queue(nil, procedure begin AtualizarUI; end);
```

### 5. TParallel.For não é ideal para I/O

```pascal
// MAL USO — TParallel.For com operações de I/O bloqueantes
// Esgota threads do pool; outros tasks ficam sem thread
TParallel.For(0, N - 1, procedure(I: Integer)
begin
  DownloadArquivo(URLs[I]);  // I/O bloqueante → pool esgotado
end);

// CORRETO para I/O: usar múltiplos TTask.Run com async I/O
// ou TParallel.For apenas para trabalho CPU-bound
```

### 6. False sharing em loops paralelos

```pascal
// PROBLEMA: elementos adjacentes no array compartilham cache line → contenção
var Contadores: array[0..3] of Integer;
TParallel.For(0, 3, procedure(I: Integer)
begin
  for var J := 0 to 10000 do
    Inc(Contadores[I]);  // false sharing: todos na mesma cache line
end);

// SOLUÇÃO: padding ou acumular localmente e combinar depois
TParallel.For(0, 3, procedure(I: Integer)
var Local: Integer;
begin
  Local := 0;
  for var J := 0 to 10000 do Inc(Local);
  TInterlocked.Add(Total, Local);   // uma única operação atômica ao final
end);
```

### 7. Deadlock clássico entre dois locks

```pascal
// Thread A: Lock1 → Lock2
// Thread B: Lock2 → Lock1 → DEADLOCK

// PREVENÇÃO: ordem canônica de aquisição de locks
// Definir ordem global: Lock1 sempre antes de Lock2
// Toda thread deve adquirir na mesma ordem
Lock1.Enter; try Lock2.Enter; try ... finally Lock2.Leave; end; finally Lock1.Leave; end;
```

---

## Referências cruzadas

- `developer-delphi-to-fpc-threading-basics_V1.1.0` — TThread, TCriticalSection, TMonitor, TEvent
- `developer-delphi-to-fpc-performance-and-memory_V1.0.0` — cache locality, false sharing
- Documentação Delphi: `System.Threading` (TTask, TParallel), `System.SyncObjs` (TInterlocked)
- `System.Generics.Collections` — TThreadedQueue<T>

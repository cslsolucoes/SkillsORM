---
name: developer-delphi-to-fpc-threading-basics
description: Concorrência básica em Delphi — TThread, sincronização (TCriticalSection, TMonitor, TEvent) e Synchronize.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-threading-basics_V1.1.0

**Versão:** 1.1.0
**Área:** Concorrência e Sincronização
**Compatibilidade:** Delphi 10.4+ (Win32/Win64) · dcc32/dcc64
**Locale:** pt-BR

---

## O que é

Esta skill cobre as primitivas fundamentais de threading em Delphi:
`TThread`, `TCriticalSection`, `TMonitor`, `TEvent`, `TMREWSync` e
os mecanismos de atualização segura de UI (`Synchronize` / `Queue`).

Não envolve a PPL (TTask/TParallel) — consulte
`developer-delphi-to-fpc-threading-advanced_V1.1.0` para esses tópicos.

---

## Casos de uso

| Situação | Primitiva recomendada |
|---|---|
| Executar trabalho em background com progresso na UI | `TThread` + `Queue` |
| Proteger acesso a recurso compartilhado (seção crítica) | `TCriticalSection` |
| Bloquear objeto inteiro (sem alocar lock separado) | `TMonitor` |
| Sinalizar evento entre threads (produtor/consumidor simples) | `TEvent` |
| Múltiplos leitores simultâneos, 1 escritor exclusivo | `TMREWSync` |
| Variável isolada por thread (sem lock) | `threadvar` |
| Thread anônima rápida (fire-and-forget) | `TThread.CreateAnonymousThread` |

---

## API principal

### TThread

```pascal
unit System.Classes;  // já incluso em uses padrão

type
  TWorker = class(TThread)
  protected
    procedure Execute; override;  // OBRIGATÓRIO — lógica de background
  public
    constructor Create;
  end;

constructor TWorker.Create;
begin
  inherited Create(False);  // False = inicia imediatamente; True = suspenso
  FreeOnTerminate := True;  // libera a instância ao terminar (não usar após Start)
end;

procedure TWorker.Execute;
begin
  // Código de background — NUNCA acesse componentes VCL/FMX aqui diretamente

  // Bloqueante: espera a proc terminar na main thread antes de continuar
  Synchronize(procedure
  begin
    Label1.Caption := 'Em progresso...';
  end);

  // Não-bloqueante: enfileira a proc para rodar na main thread e continua
  Queue(procedure
  begin
    ProgressBar1.Position := 50;
  end);

  // Verificar cancelamento (chamado por TThread.Terminate de fora)
  if Terminated then
    Exit;
end;

// Criação e uso
var W: TWorker;
W := TWorker.Create;
// Se FreeOnTerminate = False, liberar manualmente: W.Free;
// Para cancelar: W.Terminate; (Terminated passa a True na Execute)
// Para aguardar: W.WaitFor;
```

**Propriedades e métodos chave:**

| Membro | Tipo | Descrição |
|---|---|---|
| `Execute` | procedure virtual abstract | Corpo da thread — implementar em descendentes |
| `Synchronize(AProc)` | procedure | Executa AProc na main thread — bloqueante |
| `Queue(AProc)` | procedure | Enfileira AProc na main thread — não bloqueante |
| `Terminate` | procedure | Sinaliza `Terminated := True` (não força parada) |
| `Terminated` | Boolean | Verificar dentro de Execute para sair graciosamente |
| `FreeOnTerminate` | Boolean | Se True, thread se autodesaloca após Execute retornar |
| `WaitFor` | LongWord | Bloqueia o chamador até a thread terminar |
| `Priority` | TThreadPriority | tpIdle .. tpTimeCritical |
| `CreateAnonymousThread(proc)` | class function | Cria TThread sem herança |

---

### TCriticalSection

```pascal
uses System.SyncObjs;

// Criação — normalmente campo de objeto ou variável global
var FLock: TCriticalSection;
FLock := TCriticalSection.Create;
try
  // ---- Padrão obrigatório: Enter + try/finally + Leave ----
  FLock.Enter;
  try
    FDados.Add(NovoItem);   // apenas 1 thread executa isso por vez
    FContador := FContador + 1;
  finally
    FLock.Leave;            // SEMPRE no finally — libera mesmo em exceção
  end;
finally
  FLock.Free;
end;

// TryEnter — não bloqueante (retorna False se outra thread segura o lock)
if FLock.TryEnter then
begin
  try
    // seção crítica
  finally
    FLock.Leave;
  end;
end;
```

**Regras:**
- `Enter` é **reentrante** na mesma thread (não causa deadlock consigo mesmo)
- **Sempre** usar `try/finally` para garantir `Leave` mesmo em exceção
- Não chamar `Free` enquanto outra thread está em `Enter` (comportamento indefinido)

---

### TMonitor (object-level locking)

```pascal
// TMonitor usa o próprio objeto como mutex — sem alocar TCriticalSection
// Disponível desde Delphi 2009 · unit System

var FDados: TList<string>;
FDados := TList<string>.Create;

// Bloquear/desbloquear
TMonitor.Enter(FDados);
try
  FDados.Add(Item);
finally
  TMonitor.Exit(FDados);
end;

// Wait/Pulse — produtor-consumidor com um único objeto de fila
// Consumidor:
TMonitor.Enter(FQueue);
try
  while FQueue.Count = 0 do
    TMonitor.Wait(FQueue, INFINITE);  // libera o lock e dorme; acorda com Pulse
  var Item := FQueue.Dequeue;
finally
  TMonitor.Exit(FQueue);
end;

// Produtor:
TMonitor.Enter(FQueue);
try
  FQueue.Enqueue(NovoItem);
  TMonitor.Pulse(FQueue);   // acorda UMA thread em Wait
  // TMonitor.PulseAll(FQueue) — acorda TODAS
finally
  TMonitor.Exit(FQueue);
end;
```

**Métodos:**

| Método | Descrição |
|---|---|
| `TMonitor.Enter(Obj)` | Adquire o lock do objeto (bloqueante) |
| `TMonitor.Exit(Obj)` | Libera o lock do objeto |
| `TMonitor.TryEnter(Obj)` | Tenta adquirir; retorna Boolean |
| `TMonitor.TryEnter(Obj, Timeout)` | Com timeout em ms |
| `TMonitor.Wait(Obj, Timeout)` | Libera lock e dorme até Pulse ou timeout |
| `TMonitor.Pulse(Obj)` | Acorda uma thread em Wait |
| `TMonitor.PulseAll(Obj)` | Acorda todas as threads em Wait |

---

### TEvent — sinalização entre threads

```pascal
uses System.SyncObjs;

// Criar evento:
// AManualReset = True  → precisa chamar ResetEvent manualmente após disparar
// AManualReset = False → auto-reset após primeira thread ser liberada
// AInitialState = False → começa não sinalizado
var FEvento: TEvent;
FEvento := TEvent.Create(nil, {ManualReset=}False, {InitialState=}False, '');

// Thread produtora — sinalizar evento:
FEvento.SetEvent;    // libera threads em WaitFor

// Thread consumidora — aguardar evento:
case FEvento.WaitFor(5000) of   // timeout em ms (INFINITE = sem limite)
  wrSignaled:  // evento foi sinalizado → prosseguir
    ProcessarDados;
  wrTimeout:   // tempo esgotado → tratar ausência de sinal
    raise ETimeout.Create('Timeout aguardando evento');
  wrAbandoned, wrError: // erro
    raise EInvalidOperation.Create('Erro no evento');
end;

// Resetar (necessário em ManualReset=True):
FEvento.ResetEvent;

// Liberar:
FEvento.Free;
```

---

### TMREWSync — Multiple Readers / Exclusive Writer

```pascal
uses System.SyncObjs;

var FRWLock: TMREWSync;
FRWLock := TMREWSync.Create;

// Leitura: múltiplas threads simultâneas
FRWLock.BeginRead;
try
  Resultado := FDados[Indice];  // leitura concorrente OK
finally
  FRWLock.EndRead;
end;

// Escrita: exclusiva (bloqueia todos leitores e escritores)
FRWLock.BeginWrite;
try
  FDados[Indice] := NovoValor;  // apenas 1 thread por vez
finally
  FRWLock.EndWrite;
end;

FRWLock.Free;
```

**Quando usar TMREWSync:**
- Dados lidos com frequência mas escritos raramente (ex.: cache, configurações)
- `TCriticalSection` seria desnecessariamente restritiva para leituras concorrentes

---

### threadvar — Thread-Local Storage (TLS)

```pascal
// threadvar: cada thread tem sua própria cópia da variável
threadvar
  FContextoAtual: string;
  FContadorLocal: Integer;

// Thread A define seu próprio FContextoAtual — não afeta Thread B
FContextoAtual := 'Thread-A';
FContadorLocal := 0;
```

---

### TThread.CreateAnonymousThread

```pascal
// Thread rápida sem herança — ideal para tarefas pontuais
var T: TThread;
T := TThread.CreateAnonymousThread(procedure
begin
  // lógica em background
  TThread.Queue(nil, procedure
  begin
    ShowMessage('Concluído');
  end);
end);
T.FreeOnTerminate := True;
T.Start;
```

---

## Exemplos incluídos

| Arquivo | Conteúdo |
|---|---|
| `exemplos/tthread_basico.pas` | TThread com Execute, Synchronize, Queue, Terminate |
| `exemplos/tcriticalsection.pas` | TCriticalSection com Enter/Leave e TryEnter |
| `exemplos/tmonitor.pas` | TMonitor com Wait/Pulse para produtor-consumidor |
| `exemplos/thread_local_storage.pas` | threadvar e TLS por thread |
| `exemplos/tthread_anonymous.pas` | CreateAnonymousThread fire-and-forget |
| `exemplos/sync_events.pas` | TEvent e TMREWSync em cenário real |

---

## Armadilhas comuns

### 1. Acessar UI fora da main thread
```pascal
// ERRADO — causa Access Violation ou comportamento imprevisível
procedure TWorker.Execute;
begin
  Label1.Caption := 'Pronto'; // NUNCA FAZER ISSO
end;

// CORRETO
procedure TWorker.Execute;
begin
  Queue(procedure begin Label1.Caption := 'Pronto'; end);
end;
```

### 2. Esquecer Leave em TCriticalSection
```pascal
// ERRADO — deixa o lock para sempre se houver exceção
FLock.Enter;
FDados.Add(Item);  // se explodir, Leave nunca é chamado → deadlock
FLock.Leave;

// CORRETO
FLock.Enter;
try
  FDados.Add(Item);
finally
  FLock.Leave;
end;
```

### 3. Synchronize causando deadlock
```pascal
// Deadlock: main thread aguarda WaitFor; worker chama Synchronize
// → main thread nunca processa a fila de Synchronize
var W: TWorker;
W := TWorker.Create;
W.WaitFor;         // main thread fica bloqueada aqui
// worker chama Synchronize → espera main thread → deadlock!

// SOLUÇÃO: usar Queue em vez de Synchronize, ou WaitFor em thread separada
```

### 4. FreeOnTerminate = True + uso após Start
```pascal
// ERRADO — W pode já ter sido destruído antes de acessar Priority
W := TWorker.Create;  // FreeOnTerminate = True
W.Priority := tpLow;  // CRASH: W já foi destruído se a thread terminou rápido
W.Start;

// CORRETO: configurar antes de liberar o controle ou usar FreeOnTerminate = False
```

### 5. TMonitor.Wait sem loop de verificação
```pascal
// ERRADO — spurious wakeups podem ocorrer
TMonitor.Enter(FQueue);
TMonitor.Wait(FQueue, INFINITE);   // pode acordar sem Pulse
var Item := FQueue.Dequeue;        // fila pode estar vazia!

// CORRETO
TMonitor.Enter(FQueue);
while FQueue.Count = 0 do
  TMonitor.Wait(FQueue, INFINITE);
var Item := FQueue.Dequeue;
```

---

## Referências cruzadas

- `developer-delphi-to-fpc-threading-advanced_V1.1.0` — TTask, TParallel, TThreadedQueue, TInterlocked
- `developer-delphi-to-fpc-performance-and-memory_V1.0.0` — otimização de memória em threads
- `developer-delphi-to-fpc-error-handling-and-diagnostics_V1.0.0` — tratamento de exceções em threads
- Documentação Delphi: `System.Classes` (TThread), `System.SyncObjs` (TCriticalSection, TEvent, TMREWSync)

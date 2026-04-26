# Primitivas de Lock — Tabela de Decisão

## Quando usar cada primitiva

| Primitiva | Unit | Overhead | Reentrante | Wait/Signal | Melhor para |
|---|---|---|---|---|---|
| `TCriticalSection` | System.SyncObjs | Baixo | Sim | Não | Seção crítica simples; caso geral |
| `TMonitor` | System (built-in) | Médio | Sim | Sim (Wait/Pulse) | Lock + sinalização no mesmo objeto |
| `TSpinLock` | System.SyncObjs | Muito baixo | Não | Não | Seções ultra-curtas, sem contenção alta |
| `TMREWSync` | System.SyncObjs | Médio | Parcial | Não | Cache/config: muitos leitores, poucos escritores |
| `TEvent` | System.SyncObjs | Baixo | N/A | Sim (SetEvent/WaitFor) | Sinalização entre threads (evento único) |
| `TSemaphore` | System.SyncObjs | Baixo | N/A | Sim (Release/WaitFor) | Limitar N threads simultâneas a um recurso |

---

## TCriticalSection — padrão canônico

```pascal
uses System.SyncObjs;

var FLock: TCriticalSection;
// Criar: FLock := TCriticalSection.Create;
// Destruir APÓS todas as threads pararem: FLock.Free;

FLock.Enter;            // bloqueia se outra thread segura o lock
try
  // seção crítica
finally
  FLock.Leave;          // SEMPRE no finally
end;

// Variante não bloqueante:
if FLock.TryEnter then
begin
  try
    // seção crítica (adquiriu)
  finally
    FLock.Leave;
  end;
end
else
begin
  // não adquiriu — tratar alternativa
end;
```

**Regras:**
- Criar antes das threads; liberar após todas terminarem
- Nunca chamar `Free` com outra thread em `Enter`
- `Enter` é reentrante (mesma thread pode entrar N vezes; precisa de N `Leave`)

---

## TMonitor — lock + variável de condição

```pascal
// Sem alocação extra: qualquer objeto serve de mutex
var FObj: TObject;
FObj := TObject.Create;

// Lock básico:
TMonitor.Enter(FObj);
try
  // seção crítica
finally
  TMonitor.Exit(FObj);
end;

// Wait/Pulse — produtor-consumidor:
// Produtor:
TMonitor.Enter(FQueue);
try
  FQueue.Enqueue(Item);
  TMonitor.Pulse(FQueue);      // acorda 1 consumidor
  // TMonitor.PulseAll(FQueue) // acorda todos
finally
  TMonitor.Exit(FQueue);
end;

// Consumidor (SEMPRE while, nunca if):
TMonitor.Enter(FQueue);
try
  while FQueue.Count = 0 do
    TMonitor.Wait(FQueue, INFINITE);  // libera lock; dorme; acorda com Pulse
  Item := FQueue.Dequeue;
finally
  TMonitor.Exit(FQueue);
end;
```

---

## TSpinLock — lock sem context switch

```pascal
uses System.SyncObjs;

var FSpinLock: TSpinLock;
// TSpinLock é record — inicialização automática; não precisa de Create/Free

FSpinLock.Enter;     // gira em busy-wait (não dorme)
try
  // seção ultra-curta (< 10 instruções)
finally
  FSpinLock.Exit;
end;

// CUIDADO: SpinLock NÃO é reentrante — deadlock se a mesma thread chamar Enter duas vezes
// Usar apenas para seções brevíssimas com baixa contenção
```

---

## TMREWSync — múltiplos leitores, 1 escritor

```pascal
uses System.SyncObjs;

var FRW: TMREWSync;
FRW := TMREWSync.Create;

// Leitura (compartilhada — N threads simultâneas):
FRW.BeginRead;
try
  Resultado := FCache[Chave];
finally
  FRW.EndRead;
end;

// Escrita (exclusiva — bloqueia leitores e outros escritores):
FRW.BeginWrite;
try
  FCache[Chave] := NovoValor;
finally
  FRW.EndWrite;
end;

FRW.Free;
```

**Quando usar:** dados lidos frequentemente, escritos raramente (cache, configurações, índices).

---

## TEvent — sinalização pontual

```pascal
uses System.SyncObjs;

// Auto-reset: liberado após 1 WaitFor; precisa SetEvent novamente
var FEvt: TEvent := TEvent.Create(nil, False, False, '');

// Sinalizar (de qualquer thread):
FEvt.SetEvent;

// Aguardar (bloqueante com timeout):
case FEvt.WaitFor(5000) of  // ms; INFINITE = sem limite
  wrSignaled : { ok };
  wrTimeout  : { timeout };
  wrAbandoned: { thread dona do evento terminou };
  wrError    : { erro de SO };
end;

// Manual-reset: permanece sinalizado; libera TODAS as threads em WaitFor
var FEvtBroadcast: TEvent := TEvent.Create(nil, True, False, '');
FEvtBroadcast.SetEvent;    // libera todos
FEvtBroadcast.ResetEvent;  // reiniciar manualmente
```

---

## Fluxograma de seleção

```
Preciso proteger acesso a dados compartilhados?
│
├─ Seção muito curta (< 10 instruções, sem chamadas externas)?
│   → TSpinLock
│
├─ Seção moderada, sem necessidade de Wait/Signal?
│   → TCriticalSection  ← PADRÃO para maioria dos casos
│
├─ Preciso de Wait/Pulse (produtor-consumidor) no mesmo objeto?
│   → TMonitor
│
├─ Dados lidos com muito mais frequência do que escritos?
│   → TMREWSync
│
└─ Preciso apenas sinalizar "evento ocorreu" entre threads?
    → TEvent (auto-reset) ou TEvent (manual-reset para broadcast)
```

---

## Referências cruzadas

- `exemplos/tcriticalsection.pas` — TCriticalSection em detalhe
- `exemplos/tmonitor.pas` — TMonitor Wait/Pulse
- `exemplos/sync_events.pas` — TEvent e TMREWSync
- `developer-delphi-to-fpc-threading-advanced_V1.1.0` — TInterlocked (lock-free)

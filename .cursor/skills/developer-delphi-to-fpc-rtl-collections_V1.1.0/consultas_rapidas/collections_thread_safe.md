# Coleções Thread-Safe — TThreadList\<T\>, TMonitor, Padrões de Locking

## Por que as coleções padrão não são thread-safe

`TList<T>`, `TDictionary<K,V>`, `TQueue<T>` e `TStack<T>` **não são thread-safe**. Acesso concorrente sem sincronização causa:
- Corrupção de memória (lista redimensiona enquanto outro thread itera)
- AV / range check errors
- Dados perdidos silenciosamente

---

## TThreadList\<T\> — solução nativa simples

```pascal
uses System.Classes, System.Generics.Collections;

var TL: TThreadList<string>;
TL := TThreadList<string>.Create;
try
  // Adicionar (thread-safe)
  TL.Add('item1');

  // Bloquear para operações múltiplas
  var L := TL.LockList;
  try
    L.Add('item2');
    L.Add('item3');
    Writeln('Count: ', L.Count);
    // Iterar com lock mantido
    for var S in L do Writeln(S);
  finally
    TL.UnlockList;  // SEMPRE liberar após LockList
  end;
finally
  TL.Free;
end;
```

**LockList retorna `TList<T>`** — use apenas dentro do bloco Lock/Unlock.  
**DuplicatesMode:** `TThreadList` tem propriedade `Duplicates` (dupIgnore, dupAccept, dupError).

---

## TCriticalSection — proteção de TDictionary ou TQueue

```pascal
uses System.SyncObjs, System.Generics.Collections;

type
  TThreadSafeDict<K,V> = class
  private
    FLock: TCriticalSection;
    FDict: TDictionary<K,V>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetValue(const K: K; const V: V);
    function TryGet(const K: K; out V: V): Boolean;
    procedure Remove(const K: K);
  end;

constructor TThreadSafeDict<K,V>.Create;
begin
  inherited;
  FLock := TCriticalSection.Create;
  FDict := TDictionary<K,V>.Create;
end;

destructor TThreadSafeDict<K,V>.Destroy;
begin FDict.Free; FLock.Free; inherited; end;

procedure TThreadSafeDict<K,V>.SetValue(const K: K; const V: V);
begin
  FLock.Enter;
  try FDict.AddOrSetValue(K, V);
  finally FLock.Leave; end;
end;

function TThreadSafeDict<K,V>.TryGet(const K: K; out V: V): Boolean;
begin
  FLock.Enter;
  try Result := FDict.TryGetValue(K, V);
  finally FLock.Leave; end;
end;
```

---

## TMonitor — lock leve (sem objeto externo)

```pascal
var FQueue: TQueue<string>;

// Produtor
TMonitor.Enter(FQueue);
try
  FQueue.Enqueue('msg');
  TMonitor.Pulse(FQueue);  // sinaliza consumidor
finally
  TMonitor.Exit(FQueue);
end;

// Consumidor
TMonitor.Enter(FQueue);
try
  while FQueue.Count = 0 do
    TMonitor.Wait(FQueue, 5000);  // aguarda sinal (timeout 5s)
  var Msg := FQueue.Dequeue;
finally
  TMonitor.Exit(FQueue);
end;
```

**TMonitor.Wait** libera o lock temporariamente e aguarda `Pulse`. Preferível a `Sleep` + polling.

---

## Padrão Copy-Before-Notify (Observer thread-safe)

Coleção de observers protegida por lock, mas notificação fora do lock:

```pascal
procedure TSubjectBase.Notificar(const AEvento: string);
var Copia: TArray<IObserver>;
    Obs:   IObserver;
begin
  // 1. Captura snapshot com lock
  FLock.Enter;
  try
    Copia := FObservers.ToArray;
  finally
    FLock.Leave;
  end;
  // 2. Notifica fora do lock — evita deadlock se observer chama Inscrever
  for Obs in Copia do
    Obs.Atualizar(AEvento);
end;
```

---

## Padrão Read-Write Lock (leitura concorrente, escrita exclusiva)

```pascal
uses System.SyncObjs;

type
  TRWCache<K,V> = class
  private
    FLock:  TMultiReadExclusiveWriteSynchronizer;
    FCache: TDictionary<K,V>;
  public
    function Get(const K: K; out V: V): Boolean;
    procedure Put(const K: K; const V: V);
  end;

function TRWCache<K,V>.Get(const K: K; out V: V): Boolean;
begin
  FLock.BeginRead;
  try Result := FCache.TryGetValue(K, V);
  finally FLock.EndRead; end;
end;

procedure TRWCache<K,V>.Put(const K: K; const V: V);
begin
  FLock.BeginWrite;
  try FCache.AddOrSetValue(K, V);
  finally FLock.EndWrite; end;
end;
```

`TMultiReadExclusiveWriteSynchronizer` permite múltiplos leitores simultâneos mas bloqueia para escrita.

---

## Comparativo de mecanismos

| Mecanismo | Uso ideal | Overhead | Espera |
|-----------|-----------|----------|--------|
| `TThreadList<T>` | Lista simples protegida | Baixo | Spinlock/Mutex |
| `TCriticalSection` | Seção crítica genérica | Baixo | Kernel wait |
| `TMonitor` | Produtor/consumidor com sinalização | Médio | Wait/Pulse |
| `TMultiReadExclusiveWriteSynchronizer` | Cache read-heavy | Médio | Reader sem bloqueio mútuo |

---

## Regras de ouro

1. **Lock pelo menor tempo possível** — nunca segure lock durante I/O ou operação longa
2. **Ordem consistente de locks** — para evitar deadlock, adquira sempre na mesma ordem
3. **Nunca chamar código externo dentro de lock** — o callback pode tentar adquirir outro lock
4. **TThreadList.LockList sempre com try/finally** — vazamento de lock trava toda a aplicação
5. **Prefer TMonitor.Wait a Sleep+polling** — CPU-friendly e reage imediatamente ao Pulse

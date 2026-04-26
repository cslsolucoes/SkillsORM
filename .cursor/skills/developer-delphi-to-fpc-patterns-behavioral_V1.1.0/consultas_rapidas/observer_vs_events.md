# Observer vs. TNotifyEvent vs. Anonymous Method

## Comparação

| Aspecto | TNotifyEvent | Observer Pattern | Anonymous Method |
|---------|-------------|-----------------|-----------------|
| Assinantes | 1 (um único handler) | N (lista de observers) | N (lista de procs) |
| Tipagem dos dados | Sender: TObject | TValue (genérico) | Tipo específico no closure |
| Desacopla subject? | Não — Sender é TObject | Sim — IObserver | Sim — closure |
| Thread-safe | Não por padrão | Com lock na lista | Com lock na lista |
| Delphi VCL padrão | Sim (OnClick, OnChange…) | Não — implementar | Não — implementar |
| Testável | Difícil | Fácil — mock IObserver | Fácil — lambda inline |

---

## TNotifyEvent — uso VCL padrão

```pascal
// Limitado a um handler, Sender é TObject — informação mínima
type TButton = class
  property OnClick: TNotifyEvent;  // procedure(Sender: TObject)
end;

// Problema: só um handler; dado relevante exige cast de Sender
```

---

## Observer Pattern — para N assinantes

```pascal
type IObserver = interface
  procedure Update(const AEvento: string; const ADados: TValue);
end;

type TSubjectBase = class
  FObservadores: TList<IObserver>;
  procedure Notificar(const AEvento: string; const ADados: TValue);
end;

// Vantagem: qualquer número de observers; dados fortemente tipados via TValue
Conta.Inscrever(TLogObserver.Create('auditoria'));
Conta.Inscrever(TAlertaObserver.Create(200));
Conta.Inscrever(TEmailObserver.Create('gerente@'));
// Todos notificados automaticamente — sujeito não os conhece diretamente
```

---

## Anonymous Method — multicast sem classes extras

```pascal
type TEventoHandler<T> = reference to procedure(const ADados: T);

type TMulticastEvent<T> = class
private
  FHandlers: TList<TEventoHandler<T>>;
public
  procedure Subscribe(AHandler: TEventoHandler<T>);
  procedure Fire(const ADados: T);
end;

// Uso:
var OnSaldoMudou := TMulticastEvent<Currency>.Create;
OnSaldoMudou.Subscribe(procedure(V: Currency) begin Writeln('Label: ', V); end);
OnSaldoMudou.Subscribe(procedure(V: Currency) begin Writeln('Gráfico: ', V); end);
OnSaldoMudou.Fire(1500);
```

---

## Quando usar cada abordagem

```
Evento simples VCL (OnClick, OnChange):
  → TNotifyEvent — convenção do framework

Múltiplos observadores com lógica de negócio:
  → Observer Pattern (IObserver + TSubjectBase)
  → Testável: mock IObserver em DUnitX

Callbacks curtos e inline:
  → Anonymous Method / TMulticastEvent<T>
  → Mais conciso, sem criar classe de observer

Thread-safe + N assinantes:
  → Observer Pattern + TCriticalSection na lista
  → Ou TMulticastEvent<T> com lock
```

---

## Thread safety no Observer

```pascal
// Copiar a lista ANTES de notificar — evita deadlock se observer chamar Inscrever
procedure TSubjectBase.Notificar(const AEvento: string; const ADados: TValue);
var Copia: TArray<IObserver>;
begin
  FLock.Enter;
  try Copia := FObservadores.ToArray;
  finally FLock.Leave; end;
  // Notificar fora do lock
  for var Obs in Copia do Obs.Update(AEvento, ADados);
end;
```

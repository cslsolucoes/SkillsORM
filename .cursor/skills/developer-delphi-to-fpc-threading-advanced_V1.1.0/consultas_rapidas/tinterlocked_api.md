# TInterlocked — Referência Rápida de API

**Unit:** `System.SyncObjs`
**Classe:** `TInterlocked` (métodos de classe estáticos)

---

## Tabela de métodos

| Método | Assinatura | Descrição | Retorno |
|---|---|---|---|
| `Increment` | `(var Target: Integer): Integer` | Target++ atômico | Novo valor |
| `Increment` | `(var Target: Int64): Int64` | Target++ atômico (64-bit) | Novo valor |
| `Decrement` | `(var Target: Integer): Integer` | Target-- atômico | Novo valor |
| `Decrement` | `(var Target: Int64): Int64` | Target-- atômico (64-bit) | Novo valor |
| `Add` | `(var Target: Integer; Value: Integer): Integer` | Target += Value atômico | Novo valor |
| `Add` | `(var Target: Int64; Value: Int64): Int64` | Target += Value (64-bit) | Novo valor |
| `Exchange` | `(var Target: Integer; Value: Integer): Integer` | Troca Target por Value | Valor anterior |
| `Exchange` | `(var Target: Int64; Value: Int64): Int64` | Troca (64-bit) | Valor anterior |
| `Exchange` | `(var Target: TObject; Value: TObject): TObject` | Troca objeto | Objeto anterior |
| `Exchange` | `(var Target: Pointer; Value: Pointer): Pointer` | Troca ponteiro | Ponteiro anterior |
| `CompareExchange` | `(var Target, Value, Comparand: Integer): Integer` | CAS 32-bit | Valor lido |
| `CompareExchange` | `(var Target, Value, Comparand: Int64): Int64` | CAS 64-bit | Valor lido |
| `CompareExchange` | `(var Target: Pointer; Value, Comparand: Pointer): Pointer` | CAS de ponteiro | Ponteiro lido |
| `CompareExchange` | `(var Target: TObject; Value, Comparand: TObject): TObject` | CAS de objeto | Objeto lido |

---

## Snippets prontos

### Contador simples

```pascal
var FContador: Integer := 0;

TInterlocked.Increment(FContador);   // ++
TInterlocked.Decrement(FContador);   // --
var Novo := TInterlocked.Increment(FContador);  // ++ e retorna novo valor

// Em TParallel.For:
TParallel.For(0, N - 1, procedure(I: Integer)
begin
  TInterlocked.Increment(FContador);
end);
```

### Soma acumulada

```pascal
var FTotal: Integer := 0;
TInterlocked.Add(FTotal, ValorParcial);   // FTotal += ValorParcial

// Int64:
var FTotal64: Int64 := 0;
TInterlocked.Add(FTotal64, Int64(ValorParcial));
```

### Flag de estado (boolean como Integer)

```pascal
var FAtivo: Integer := 0;  // 0 = inativo, 1 = ativo

// Ativar:
TInterlocked.Exchange(FAtivo, 1);

// Desativar:
TInterlocked.Exchange(FAtivo, 0);

// Ler (sem lock — leitura de 32-bit alinhada já é atômica em x86/x64):
if FAtivo = 1 then ...
```

### Inicialização única (lazy singleton)

```pascal
var GInstancia: TServico = nil;

function ObterInstancia: TServico;
var Novo: TServico;
begin
  if GInstancia = nil then
  begin
    Novo := TServico.Create;
    // CAS: troca GInstancia para Novo apenas se GInstancia = nil
    if TInterlocked.CompareExchange(Pointer(GInstancia), Pointer(Novo), nil) <> nil then
      Novo.Free;   // outra thread ganhou — descartar
  end;
  Result := GInstancia;
end;
```

### Atualizar máximo/mínimo atômico

```pascal
// Atualizar máximo com CAS loop
procedure AtualizarMaximo(var AMax: Integer; AValor: Integer);
var Lido: Integer;
begin
  while True do
  begin
    Lido := AMax;
    if AValor <= Lido then Break;  // AValor não é maior — nada a fazer
    if TInterlocked.CompareExchange(AMax, AValor, Lido) = Lido then Break;
    // Falhou: outra thread mudou AMax — tentar novamente
  end;
end;
```

### Troca e uso do valor anterior

```pascal
var FEstado: Integer := LIVRE;

// Adquirir "lock" simples:
var Anterior := TInterlocked.Exchange(FEstado, OCUPADO);
if Anterior = LIVRE then
begin
  try
    // processar
  finally
    TInterlocked.Exchange(FEstado, LIVRE);
  end;
end;
// else: já estava OCUPADO — outra thread segura o "lock"
```

---

## Limites e restrições

| Aspecto | Detalhe |
|---|---|
| Tipos suportados | `Integer` (32-bit), `Int64` (64-bit), `Pointer`, `TObject` |
| Tipos NÃO suportados | `Double`, `string`, records complexos |
| Para `Double` | Usar `TCriticalSection` ou recodificar como `Int64` bits |
| Para `string` | Usar `TCriticalSection` |
| Alinhamento | Variáveis devem ser alinhadas (automático em variáveis Delphi) |
| Plataformas | Win32, Win64, macOS, iOS, Android (instruções LOCK do CPU) |

---

## TInterlocked vs TCriticalSection

```
Use TInterlocked quando:
  ✓ Operação é um único Increment/Decrement/Exchange/CAS
  ✓ Contadores, flags, ponteiros únicos
  ✓ Performance crítica (evitar context switch)
  ✓ Implementar estruturas lock-free simples

Use TCriticalSection quando:
  ✓ Múltiplas operações devem ser atômicas em conjunto
  ✓ Condição + ação ("se X < 10 então X++")
  ✓ Operações em tipos não suportados por TInterlocked
  ✓ Seção de código com chamadas externas
```

---

## Referências cruzadas

- `exemplos/lock_free.pas` — todos os métodos em cenários reais
- `parallel_pitfalls.md` — ABA problem e outros cuidados com CAS
- `developer-delphi-to-fpc-threading-basics_V1.1.0/consultas_rapidas/lock_primitives.md`

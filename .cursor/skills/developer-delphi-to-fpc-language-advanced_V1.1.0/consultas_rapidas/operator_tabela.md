# Operators Overloadáveis em Delphi

## Tabela completa

| Operador | Sintaxe | Retorno | Uso |
|----------|---------|---------|-----|
| `Add` | `A + B` | T | Soma, concatenação |
| `Subtract` | `A - B` | T | Subtração |
| `Multiply` | `A * B` | T | Multiplicação (A pode ser outro tipo) |
| `Divide` | `A / B` | T | Divisão |
| `IntDivide` | `A div B` | T | Divisão inteira |
| `Modulus` | `A mod B` | T | Módulo/resto |
| `Negative` | `-A` | T | Negação unária |
| `Positive` | `+A` | T | Positivo unário |
| `Equal` | `A = B` | Boolean | Igualdade |
| `NotEqual` | `A <> B` | Boolean | Diferença |
| `LessThan` | `A < B` | Boolean | Menor que |
| `GreaterThan` | `A > B` | Boolean | Maior que |
| `LessThanOrEqual` | `A <= B` | Boolean | Menor ou igual |
| `GreaterThanOrEqual` | `A >= B` | Boolean | Maior ou igual |
| `LogicalAnd` | `A and B` | T | AND lógico |
| `LogicalOr` | `A or B` | T | OR lógico |
| `LogicalXor` | `A xor B` | T | XOR lógico |
| `LogicalNot` | `not A` | T | NOT lógico |
| `BitwiseAnd` | `A and B` | T | AND bit a bit (inteiro) |
| `BitwiseOr` | `A or B` | T | OR bit a bit |
| `BitwiseXor` | `A xor B` | T | XOR bit a bit |
| `ShiftLeft` | `A shl B` | T | Deslocamento esquerda |
| `ShiftRight` | `A shr B` | T | Deslocamento direita |
| `Implicit` | Automático | T | Conversão implícita (sem cast) |
| `Explicit` | `T(expr)` | T | Conversão explícita (com cast) |
| `Inc` | `Inc(A)` | T | Incremento |
| `Dec` | `Dec(A)` | T | Decremento |
| `Trunc` | `Trunc(A)` | Integer | Truncamento |
| `Round` | `Round(A)` | Integer | Arredondamento |

## Declaração padrão (em record)

```pascal
type TValor = record
  FN: Integer;

  // Operador com dois operandos: class operator Nome(A, B: T): Ret
  class operator Add(const A, B: TValor): TValor;

  // Operador unário: class operator Nome(A: T): Ret
  class operator Negative(const A: TValor): TValor;

  // Operador comparação: retorna Boolean
  class operator Equal(const A, B: TValor): Boolean;

  // Conversão Implicit: sem sintaxe de cast
  class operator Implicit(AValor: Integer): TValor;    // Integer → TValor
  class operator Implicit(const A: TValor): Integer;   // TValor → Integer

  // Conversão Explicit: requer TValor(expr) ou Integer(expr)
  class operator Explicit(const A: TValor): string;
end;
```

## Regras

- Todos os operadores de record são `class operator` — implicitamente estáticos
- Podem ser definidos em `class` e em `record`
- `Implicit`: conversão silenciosa — usar com cautela para evitar ambiguidade
- `Explicit`: requer cast explícito — mais seguro
- `Multiply` pode ter tipos mistos: `TVector * Single` e `Single * TVector` → dois operadores
- Comparação (`Equal`, `LessThan`, etc.) deve retornar `Boolean`
- `Inc`/`Dec` devem retornar o mesmo tipo T

## Exemplo: operador com tipos mistos

```pascal
// Vetor * escalar (e escalar * vetor — dois overloads)
class operator Multiply(const A: TVector2; B: Single): TVector2;
class operator Multiply(B: Single; const A: TVector2): TVector2;

// Preço * quantidade
class operator Multiply(const A: TMoney; B: Integer): TMoney;
class operator Multiply(B: Integer; const A: TMoney): TMoney;
```

## Operadores NÃO overloadáveis

- `:=` (atribuição) — em records é cópia automática
- `@` (endereço)
- `^` (dereferência)
- `is`, `as` (type checking)
- `in` (set membership)
- `.` (acesso a membro)
- `[]` (índice de array) — **não** disponível em Delphi (diferente de C++)

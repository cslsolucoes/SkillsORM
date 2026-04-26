# Tipos Numéricos em Delphi — Referência Rápida

## Inteiros

| Tipo | Bytes | Signed | Range |
|------|-------|--------|-------|
| `ShortInt` | 1 | Sim | -128 .. 127 |
| `Byte` | 1 | Não | 0 .. 255 |
| `SmallInt` | 2 | Sim | -32.768 .. 32.767 |
| `Word` | 2 | Não | 0 .. 65.535 |
| `Integer` | 4 | Sim | -2.147.483.648 .. 2.147.483.647 |
| `Cardinal` | 4 | Não | 0 .. 4.294.967.295 |
| `LongInt` | 4 | Sim | = Integer |
| `LongWord` | 4 | Não | = Cardinal |
| `Int64` | 8 | Sim | -9.223.372.036.854.775.808 .. 9.223.372.036.854.775.807 |
| `UInt64` | 8 | Não | 0 .. 18.446.744.073.709.551.615 |
| `NativeInt` | 4/8 | Sim | plataforma (Win32=4, Win64=8) |
| `NativeUInt` | 4/8 | Não | plataforma |

## Float

| Tipo | Bytes | Precisão | Uso |
|------|-------|---------|-----|
| `Single` | 4 | ~7 dígitos | gráficos, cálculos simples |
| `Double` | 8 | ~15 dígitos | cálculos científicos, padrão |
| `Extended` | 10 (x86) / 8 (x64) | ~18-19 dígitos | alta precisão, só x87 |
| `Currency` | 8 | 4 casas fixas | valores monetários — sem erro de arredondamento |
| `Comp` | 8 | inteiro de 64 bits | obsoleto — use Int64 |

## Quando usar cada tipo

```
Contagem genérica, IDs de banco    → Integer
Endereços de memória, offsets      → NativeInt / NativeUInt  
Bytes, buffers                     → Byte, PByte
Flags bit a bit (≤8 bits)         → Byte + constantes
Valores grandes (> 2^31)           → Int64 / UInt64
Preços, saldos, percentuais        → Currency
Coordenadas 2D/3D, física          → Single (FMX usa Single)
Cálculo científico                 → Double
```

## High/Low/MinInt/MaxInt

```pascal
High(Byte)     = 255
Low(Byte)      = 0
High(Integer)  = 2147483647    = MaxInt
Low(Integer)   = -2147483648   = MinInt
High(Int64)    = 9223372036854775807
```

## Conversões seguras

```pascal
// Widening: sempre seguro (menor → maior)
var I: Integer := 42;
var I64: Int64 := I;  // OK, automático

// Narrowing: requer verificação + cast explícito
if I64 <= MaxInt then
  I := Integer(I64);  // seguro após verificação

// StrToInt pode lançar EConvertError — usar StrToIntDef
var N := StrToIntDef('abc', 0); // retorna 0 se falhar
```

## Overflow

```pascal
{$OVERFLOWCHECKS ON}   // ativa verificação de overflow → EIntOverflow
{$OVERFLOWCHECKS OFF}  // desativa (padrão em Release) → wrap silencioso
```

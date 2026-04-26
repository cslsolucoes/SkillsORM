# TValue — Container de Valor RTTI

## O que é TValue

`TValue` (em `System.Rtti`) é um record que pode armazenar qualquer valor com informação de tipo em runtime. Usado internamente pelo RTTI para ler/escrever propriedades e invocar métodos.

## Criar TValue

```pascal
uses System.Rtti;

// Tipos primitivos
var VI := TValue.From<Integer>(42);
var VD := TValue.From<Double>(3.14);
var VS := TValue.From<string>('Olá');
var VB := TValue.From<Boolean>(True);

// Enum
type TDia = (diaSeg, diaTer);
var VE := TValue.From<TDia>(diaSeg);

// Object
var Obj := TStringList.Create;
var VO := TValue.From<TStringList>(Obj);
// ou
var VO2 := TValue.FromObject(Obj);  // conveniência

// Ordinal genérico
var VOrd := TValue.FromOrdinal(TypeInfo(TDia), Ord(diaTer));
```

## Ler TValue

```pascal
var V := TValue.From<Integer>(42);

// Método AsType<T> — levanta exceção se tipo errado
var N: Integer := V.AsType<Integer>;
var S: string  := V.AsType<string>;   // EInvalidCast se V não for string

// Métodos tipados (mais rápidos para primitivos)
var N2  := V.AsInteger;
var D   := V.AsExtended;
var Str := V.AsString;
var B   := V.AsBoolean;
var Obj := V.AsObject;
var I64 := V.AsInt64;
var Ord := V.AsOrdinal;  // qualquer enum/ordinal
```

## Verificar tipo antes de ler

```pascal
var V: TValue := ...;

// TTypeKind: tkInteger, tkFloat, tkUString, tkClass, tkEnumeration...
case V.Kind of
  tkInteger  : Writeln('Int: ', V.AsInteger);
  tkFloat    : Writeln('Float: ', V.AsExtended:0:4);
  tkUString,
  tkString   : Writeln('Str: ', V.AsString);
  tkClass    : Writeln('Obj: ', V.AsObject.ClassName);
  tkEnumeration:
    if V.TypeInfo = TypeInfo(Boolean) then
      Writeln('Bool: ', V.AsBoolean)
    else
      Writeln('Enum: ', V.AsOrdinal);
end;

// IsEmpty — TValue não inicializado
if V.IsEmpty then ...;

// IsObject
if V.IsObject then
  Writeln(V.AsObject.ClassName);

// TypeInfo
if V.TypeInfo = TypeInfo(Integer) then ...;
```

## TValue.ToString

```pascal
var V := TValue.From<Integer>(42);
Writeln(V.ToString);   // '42'
// Para Boolean → 'True' / 'False'
// Para enum   → nome do valor (se RTTI disponível) ou ordinal como string
// Para object → ClassName
```

## TValue em invocação de método

```pascal
// Invocar método que recebe (AId: Integer; ANome: string): string
var Resultado := Metodo.Invoke(Instancia,
  [TValue.From<Integer>(1), TValue.From<string>('teste')]);
var RetStr := Resultado.AsString;
```

## Tabela de conversões TValue

| Tipo Delphi | `From<T>` | Leitura recomendada |
|-------------|-----------|-------------------|
| `Integer` | `TValue.From<Integer>(N)` | `V.AsInteger` |
| `Int64` | `TValue.From<Int64>(N)` | `V.AsInt64` |
| `Double` | `TValue.From<Double>(N)` | `V.AsExtended` |
| `string` | `TValue.From<string>(S)` | `V.AsString` |
| `Boolean` | `TValue.From<Boolean>(B)` | `V.AsBoolean` |
| `TObject` | `TValue.FromObject(O)` | `V.AsObject` |
| `Enum` | `TValue.From<TEnum>(E)` | `V.AsOrdinal` / `V.AsType<TEnum>` |
| vazio | `TValue.Empty` | `V.IsEmpty = True` |

## Armadilhas comuns

```pascal
// CUIDADO: AsType<T> lança exceção se tipo incompatível
var V := TValue.From<Integer>(42);
var S := V.AsType<string>;  // EInvalidCast!

// CORRETO: verificar Kind antes
if V.Kind = tkInteger then
  var N := V.AsInteger;

// CUIDADO: ToString de Double pode variar por locale
var VD := TValue.From<Double>(1.5);
Writeln(VD.ToString);  // pode ser '1,5' em pt-BR!

// MELHOR para double display:
Writeln(Format('%.4f', [VD.AsExtended]));
```

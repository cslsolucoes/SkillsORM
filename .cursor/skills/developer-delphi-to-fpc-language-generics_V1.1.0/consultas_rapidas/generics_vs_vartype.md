# Generics vs Variant vs TObject vs Any

## Quando usar cada abordagem

| Abordagem | Tipagem | Performance | Uso ideal |
|-----------|---------|-------------|-----------|
| **Generics `<T>`** | Forte (compile-time) | Máxima (sem boxing) | Coleções, algoritmos reutilizáveis |
| **`Variant`** | Fraca (runtime) | Baixa (boxing, COM) | Interop COM, scripts, dados desconhecidos |
| **`TObject`** | Fraca (requer cast) | Média (heap, cast) | Legacy VCL, listas heterogêneas antigas |
| **`TValue` (RTTI)** | Média (runtime safe) | Média | Reflexão, mappers, serialização |

## Generics — prós e contras

**Prós:**
- Type-safe em tempo de compilação
- Zero overhead de boxing em tipos primitivos
- IntelliSense funciona completamente
- Erros detectados antes de rodar

**Contras:**
- Binário maior (code inflation — cópia para cada T)
- Requer constraints para operações específicas
- Não funciona com tipos `Variant` ou `array of const`

```pascal
// SEGURO: erro de tipo em compilação
var L: TList<Integer>;
L.Add('texto');  // ERRO de compilação → tipo incompatível
```

## Variant — quando ainda faz sentido

```pascal
uses System.Variants;

var V: Variant;
V := 42;
V := 'texto';   // aceita qualquer coisa
V := Now;

// Bom para:
// - Interop COM / OLE Automation
// - Dados de planilhas Excel
// - Scripts Delphi Script / JScript
// - Campos de banco de dados via TDataSet.FieldValues[]
```

**Nunca usar Variant quando generics resolvem** — o custo de boxing + checagem runtime é 5–20x maior.

## TObject nas coleções — legacy

```pascal
// Delphi 5-2007: antes dos generics
var Lista: TList;       // lista de TObject/Pointer
Lista.Add(TStringList.Create);
var SL := Lista[0] as TStringList;  // cast manual obrigatório
```

Hoje: usar sempre `TObjectList<T>` ou `TList<T>`.

## Regra de escolha rápida

```
Preciso de coleção type-safe?         → TList<T>, TDictionary<K,V>
Algoritmo que funcione com N tipos?   → generic method <T>
Dados de banco/Excel/COM?             → Variant ou TValue
Reflexão/mapper/serialização?         → TValue + RTTI
Código legado pré-generics?           → TObject + cast (e migrar)
```

## Comparação de performance (estimada, Win64)

```pascal
// Generics — sem boxing para Integer
var L := TList<Integer>.Create;
L.Add(42);        // direto, sem alocação extra
var N := L[0];    // Integer nativo, sem cast

// Variant — boxing (alocação de TVarData)
var V: Variant := 42;  // ~10ns de alocação
var N2: Integer := V;   // ~15ns de conversão

// TObject — cast manual
var Obj: TObject := TObject.Create;
var N3 := Integer(NativeInt(Obj));  // ERRADO — apenas exemplo de overhead
```

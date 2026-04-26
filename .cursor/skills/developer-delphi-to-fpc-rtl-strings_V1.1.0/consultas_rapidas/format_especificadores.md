# Format — Especificadores Completos

## Sintaxe geral

```
% [índice:] ["-"] [largura] ["." precisão] tipo
```

- `índice:` — argumento a usar (0-based); ex.: `%1:s` usa o segundo arg
- `"-"` — alinhamento à esquerda (padrão: direita)
- `largura` — largura mínima do campo
- `.precisão` — casas decimais (float) ou dígitos mínimos (inteiro)
- `tipo` — caractere de formato

---

## Tipos de formato

| Tipo | Descrição | Exemplo | Resultado |
|------|-----------|---------|-----------|
| `s` | String | `%s` | `'Alice'` |
| `d` | Decimal inteiro | `%d` | `42` |
| `u` | Unsigned decimal | `%u` | `42` |
| `f` | Float (ponto fixo) | `%f` | `3.140000` |
| `e` | Notação científica | `%e` | `3.14e+0` |
| `g` | Mais compacto (f ou e) | `%g` | `3.14` |
| `n` | Float com separador milhar | `%n` | `1.234,56` |
| `m` | Moeda (locale) | `%m` | `R$ 1.234,56` |
| `x` | Hexadecimal | `%x` | `FF` |
| `p` | Ponteiro (hex) | `%p` | `00A3F2C8` |
| `%` | Literal % | `%%` | `%` |

---

## Largura e alinhamento

```pascal
Format('[%8d]',    [42])   // '[      42]'  — alinha direita, 8 chars
Format('[%-8d]',   [42])   // '[42      ]'  — alinha esquerda
Format('[%08d]',   [42])   // '[00000042]'  — zero padding
Format('[%8s]',    ['Hi']) // '[      Hi]'  — string alinhada direita
Format('[%-8s]',   ['Hi']) // '[Hi      ]'  — string alinhada esquerda
```

---

## Precisão em floats

```pascal
Format('%.0f', [3.7])     // '4'       — sem decimal (arredonda)
Format('%.2f', [3.14])    // '3.14'
Format('%.4f', [3.14])    // '3.1400'
Format('%.2e', [12345.0]) // '1.23e+4'
Format('%.3g', [0.00123]) // '1.23e-3'
Format('%.3g', [123.456]) // '123'     — compacto sem zeros
```

---

## Precisão em inteiros

```pascal
Format('%.4d', [42])    // '0042'  — mínimo 4 dígitos
Format('%8.4d', [42])   // '    0042'  — largura 8, mín 4 dígitos
```

---

## Índice explícito de argumento

```pascal
Format('%1:s tem %0:d anos', [30, 'Carol'])
// 'Carol tem 30 anos'

Format('%0:s, %0:s, %1:d vezes', ['eco', 3])
// 'eco, eco, 3 vezes'  — arg[0] usado duas vezes
```

---

## Hexadecimal

```pascal
Format('%x',   [255])     // 'FF'
Format('%X',   [255])     // 'FF'  (Delphi não diferencia case)
Format('%08x', [255])     // '000000FF'
Format('%.4x', [255])     // '00FF'   — mín 4 dígitos
Format('0x%x', [255])     // '0xFF'   — prefixo manual
```

---

## Tabela de formatação de números

| Objetivo | Formato | Resultado (para 1234.56) |
|----------|---------|--------------------------|
| 2 casas decimais | `%.2f` | `1234,56` (locale) |
| 2 casas, separador milhar | `%.2n` | `1.234,56` (pt-BR) |
| Moeda | `%.2m` | `R$ 1.234,56` |
| Científico | `%.2e` | `1,23e+3` |
| Sem decimal | `%.0f` | `1235` |
| Zero-padded 10 chars | `%010.2f` | `0001234,56` |

---

## Locale e TFormatSettings

`Format` usa `DefaultFormatSettings` do processo (locale do SO). Para saída locale-invariante:

```pascal
// FormatFloat com TFormatSettings
var FS := TFormatSettings.Invariant;
Writeln(Format('%f', [1234.56]));              // locale-dependente
Writeln(FloatToStrF(1234.56, ffFixed, 10, 2, FS));  // '1234.56' sempre
```

---

## Armadilhas

| Problema | Causa | Solução |
|----------|-------|---------|
| `EConvertError` | Menos args que especificadores | Verificar contagem de args |
| `%d` com Float | Tipo errado | Usar `%f` ou converter com `Round` |
| Float impreciso | Acumulação de ponto flutuante | Usar `Currency` para dinheiro |
| `%m`/`%n` locale | Saída varia por SO | Usar `FloatToStrF` com `TFormatSettings` explícito |
| Aspas em %s | Não escapa automaticamente | Fazer escape manual antes de Format |

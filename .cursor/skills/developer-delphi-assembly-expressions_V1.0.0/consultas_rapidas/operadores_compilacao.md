# Operadores em Expressoes Assembly Delphi — Consulta Rapida

## Operadores suportados em expressoes asm

Todos calculados pelo compilador em TEMPO DE COMPILACAO (nao em runtime):

| Operador   | Tipo       | Exemplo                                   | Resultado      |
| ---------- | ---------- | ----------------------------------------- | -------------- |
| `+`        | Soma       | `OFFSET GVar + 4`                         | Endereco + 4   |
| `-`        | Subtracao  | `TYPE Integer - 1`                        | 3              |
| `*`        | Mult.      | `TYPE Integer * 10`                       | 40             |
| `SHR N`    | Shift dir  | `SIZE GArray SHR 2`                       | count elem.    |
| `SHL N`    | Shift esq  | `TYPE Integer SHL 3`                      | 32             |
| `AND`      | Bitwise AND| `VMTOFFSET T.M AND $FF`                   | low byte       |
| `OR`       | Bitwise OR | `$00FF OR $FF00`                          | $FFFF          |
| `XOR`      | Bitwise XOR| `$FFFF XOR $00FF`                         | $FF00          |
| `NOT`      | Complemento| `NOT 0`                                   | $FFFFFFFF      |
| `MOD`      | Modulo     | `17 MOD 4`                                | 1              |

## Exemplos praticos

### Calcular numero de elementos de array:
```pascal
var Arr: array[0..7] of Integer;
asm
  // SIZE / TYPE = numero de elementos
  MOV ECX, SIZE Arr      // ECX = 32 (8 * 4)
  SHR ECX, 2             // ECX = 8 (numero de Integer no array)
  // Alternativa em uma expressao:
  MOV ECX, SIZE Arr / TYPE Integer  // NASM aceita; Delphi: usar SHR
end;
```

### Offset de segundo elemento de array:
```pascal
var Arr: array[0..9] of Double;
asm
  MOV EAX, OFFSET Arr + TYPE Double  // EAX = endereco do segundo elemento (Arr[1])
  MOV EAX, OFFSET Arr + TYPE Double * 3 // Arr[3]
end;
```

### Mascaras de bits:
```pascal
asm
  MOV EAX, NOT $FF       // EAX = $FFFFFF00 (mask out low byte)
  AND EAX, NOT $FF       // limpar byte baixo de EAX
  MOV EAX, $FF AND EAX  // equivalente (calculo na expressao)
end;
```

## Limitacoes

- Operadores trabalham apenas com **constantes e simbolos conhecidos em compilacao**
- NAO funcionam com variaveis em tempo de runtime dentro da expressao
- Divisao `/` em expressoes asm pode nao ser suportada em todos os compiladores — preferir SHR para divisao por potencia de 2

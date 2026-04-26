# Retorno de Valores em Assembly — Tipos Delphi

## Tabela de retorno por tipo

| Tipo Pascal      | Win32 (dcc32)         | Win64 (dcc64)         |
| ---------------- | --------------------- | --------------------- |
| `Boolean`        | AL (parte de EAX)     | AL (parte de RAX)     |
| `Byte`           | AL                    | AL                    |
| `Word`           | AX                    | AX                    |
| `Integer`        | EAX                   | EAX (parte de RAX)    |
| `Cardinal`       | EAX                   | EAX (parte de RAX)    |
| `Int64`          | EDX:EAX               | RAX                   |
| `UInt64`         | EDX:EAX               | RAX                   |
| `Pointer`        | EAX                   | RAX                   |
| `PChar`          | EAX                   | RAX                   |
| `Single`         | ST(0) [x87]           | XMM0 (32-bit low)     |
| `Double`         | ST(0) [x87]           | XMM0 (64-bit)         |
| `Extended`       | ST(0) [x87 80-bit]    | Ponteiro em RAX*      |
| `Currency`       | ST(0) ou EDX:EAX      | RAX                   |
| Record <=8 bytes | EDX:EAX               | RAX                   |
| Record >8 bytes  | Ponteiro oculto EAX   | Ponteiro oculto RCX** |
| `string`         | Gerenciado — evitar   | Gerenciado — evitar   |
| `interface`      | Gerenciado — evitar   | Gerenciado — evitar   |

*Extended em x64: comportamento plataforma-especifico — evitar em codigo portavel.
**Record grande em x64: caller aloca e passa ponteiro como primeiro argumento oculto.

## Exemplos de retorno correto

### Boolean:
```asm
function IsPositivo(N: Integer): Boolean; assembler;
asm
  // N = EAX (Win32 register) ou ECX (Win64)
  TEST EAX, EAX    // ou TEST ECX, ECX em Win64
  SETG AL          // AL = 1 se N > 0, 0 caso contrario
  // Boolean retornado em AL (byte baixo de EAX)
end;
```

### Int64 em Win32:
```asm
function Dobrar(N: Int64): Int64; assembler;
asm
  // N esta em EDX:EAX (high:low)
  // Retorno tambem em EDX:EAX
  ADD  EAX, EAX    // low * 2 (com carry)
  ADC  EDX, EDX    // high * 2 + carry
end;
```

### Double em Win64:
```asm
function MetadeFloat(X: Double): Double; assembler;
asm
  // X em XMM0
  // Retorno em XMM0
  MOVSD XMM1, [RIP + cMeio]  // XMM1 = 0.5
  MULSD XMM0, XMM1            // XMM0 = X * 0.5
  // XMM0 ja contem o resultado
  RET
cMeio: dq 0x3FE0000000000000  // IEEE 754 double: 0.5
end;
```

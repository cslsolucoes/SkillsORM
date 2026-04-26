# Retorno de Valores em Funcoes Assembly Delphi — Referencia

## Tabela rapida

| Tipo Pascal  | Win32 dcc32    | Win64 dcc64    | Como escrever no asm              |
| ------------ | -------------- | -------------- | --------------------------------- |
| Boolean      | AL             | AL             | `SETZ AL` / `MOV AL, 1`          |
| Byte         | AL             | AL             | `MOV AL, valor`                   |
| Word/SmallInt| AX             | AX             | `MOV AX, valor`                   |
| Integer      | EAX            | EAX            | `MOV EAX, valor`                  |
| Cardinal     | EAX            | EAX            | `MOV EAX, valor`                  |
| Int64        | EDX:EAX        | RAX            | Win32: `MOV EAX,low; MOV EDX,high`|
| UInt64       | EDX:EAX        | RAX            | idem Int64                        |
| Pointer      | EAX            | RAX            | `MOV EAX, ptr32` / `MOV RAX, ptr`|
| PChar        | EAX            | RAX            | idem Pointer                      |
| Single       | ST(0) [x87]    | XMM0 (low 32)  | `FLD [mem]` / `MOVSS XMM0, src`  |
| Double       | ST(0) [x87]    | XMM0 (64-bit)  | `FLD [mem]` / `MOVSD XMM0, src`  |
| Extended     | ST(0) [x87]    | Espec. plataforma | `FLD TBYTE PTR [mem]`         |

## Exemplos praticos

### Integer em Win32:
```pascal
function SomarInt(A, B: Integer): Integer; assembler;
asm
  ADD EAX, EDX    // resultado automaticamente em EAX
end;
```

### Boolean:
```pascal
function EhPositivo(N: Integer): Boolean; assembler;
asm
  TEST EAX, EAX   // Win32: N=EAX
  SETG AL         // AL = 1 se N > 0
end;
```

### Int64 em Win32 (EDX:EAX):
```pascal
function MultiplicarInt64(A, B: Integer): Int64; assembler;
asm
  // A=EAX, B=EDX
  IMUL EDX    // EDX:EAX = EAX * EDX (signed 64-bit result)
  // Resultado em EDX:EAX automaticamente (Int64 em Win32)
end;
```

### Double em Win32 (FPU ST(0)):
```pascal
function ReciprocoPi: Double; assembler;
asm
  FLDPI           // ST(0) = Pi
  FLD1            // ST(0) = 1.0, ST(1) = Pi
  FDIVP           // ST(0) = 1.0 / Pi
  // Delphi busca Double de ST(0) automaticamente
end;
```

### Double em Win64 (XMM0):
```pascal
function DobrarFloat(X: Double): Double; assembler;
asm
  // X em XMM0 (Win64)
  ADDSD XMM0, XMM0   // XMM0 = X + X = 2*X
  // Resultado em XMM0 automaticamente
end;
```

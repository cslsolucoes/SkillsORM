# Registradores Caller/Callee-Saved — Tabela de Referencia

## Win32 (dcc32)

| Registrador | Tipo         | Obrigacao                              |
| ----------- | ------------ | -------------------------------------- |
| EAX         | caller-saved | Pode ser destruido pela funcao chamada |
| ECX         | caller-saved | Pode ser destruido pela funcao chamada |
| EDX         | caller-saved | Pode ser destruido pela funcao chamada |
| EBX         | callee-saved | DEVE ser preservado (PUSH/POP)         |
| ESI         | callee-saved | DEVE ser preservado (PUSH/POP)         |
| EDI         | callee-saved | DEVE ser preservado (PUSH/POP)         |
| EBP         | callee-saved | DEVE ser preservado (frame pointer)    |
| ESP         | especial     | Sempre balancear antes de RET          |
| ST(0)-ST(7) | caller-saved | FPU stack — limpar antes de retornar  |

## Win64 (dcc64)

### Volatile (caller-saved — podem ser destruidos):
```
RAX, RCX, RDX, R8, R9, R10, R11
XMM0, XMM1, XMM2, XMM3, XMM4, XMM5
```

### Non-volatile (callee-saved — DEVEM ser preservados):
```
RBX, RBP, RDI, RSI, RSP, R12, R13, R14, R15
XMM6, XMM7, XMM8, XMM9, XMM10, XMM11
XMM12, XMM13, XMM14, XMM15
```

## Padrao de preservacao em asm

### Win32:
```asm
; Salvar no inicio:
PUSH EBX
PUSH ESI
PUSH EDI

; ... codigo ...

; Restaurar antes de RET (ordem inversa!):
POP EDI
POP ESI
POP EBX
RET
```

### Win64 (com pseudo-op Delphi):
```pascal
function MinhaFunc(...): Integer; assembler;
asm
  .PUSHNV R12    // salva R12 automaticamente no prologo/epilogo
  .PUSHNV R13    // salva R13
  .SAVENV XMM6   // salva XMM6 (non-volatile XMM)
  // ... codigo usando R12, R13, XMM6 livremente ...
  // Delphi restaura automaticamente no epilogo
end;
```

## Regra de ouro

> Se voce USAR um registrador callee-saved sem salva-lo,
> voce esta corrompendo o estado do caller — o bug aparece
> em codigo completamente diferente e e muito dificil de rastrear.

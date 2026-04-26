# Preservação de registradores — Regras por plataforma

## Win32 — Delphi 32-bit

### Devem ser preservados (callee-saved)
```
EBX  ESI  EDI  EBP  ESP
```

### Podem ser destruídos (caller-saved / voláteis)
```
EAX  EDX  ECX
(+ ST1-ST7 da FPU — ST0 é retorno de float)
```

### Padrão de preservação no asm..end

```pascal
procedure MinhaFuncao;
asm
  PUSH EBX          // salvar EBX
  PUSH ESI          // salvar ESI
  PUSH EDI          // salvar EDI

  // ... usa EBX, ESI, EDI livremente ...

  POP  EDI          // restaurar na ordem INVERSA!
  POP  ESI
  POP  EBX
end;
```

## Win64 — Delphi 64-bit (Windows x64 ABI)

### Devem ser preservados (callee-saved)
```
Inteiros:  RBX  RSI  RDI  RBP  RSP  R12  R13  R14  R15
SIMD:      XMM4  XMM5  XMM6  XMM7  XMM8  XMM9  XMM10  XMM11
           XMM12  XMM13  XMM14  XMM15
```

### Podem ser destruídos (caller-saved / voláteis)
```
Inteiros:  RAX  RCX  RDX  R8  R9  R10  R11
SIMD:      XMM0  XMM1  XMM2  XMM3  (XMM4 e XMM5 são NÃO-voláteis!)
```

### Padrão com .PUSHNV (built-in assembler Delphi 64-bit)

```pascal
function MinhaFuncao64: Int64;
asm
  .PUSHNV RBX       // equivale a PUSH RBX + gera unwind information
  .PUSHNV R12       // equivale a PUSH R12 + gera unwind information
  .PUSHNV R13

  // ... usa RBX, R12, R13 livremente ...

  // Epilogue gerado automaticamente: POP R13, POP R12, POP RBX, RET
end;
```

### Padrão com PUSH/POP manual (64-bit)

```pascal
function MinhaFuncao64Manual: Int64;
asm
  PUSH RBX
  PUSH R12
  PUSH R13
  // Atenção: número ímpar de PUSH pode desalinhar RSP (16-byte alignment)
  // Adicionar push extra ou sub rsp, 8 para alinhar se necessário

  // ... implementação ...

  POP R13
  POP R12
  POP RBX
end;
```

## Tabela comparativa rápida

| Registrador | Win32 | Win64 |
|-------------|-------|-------|
| EAX / RAX | Volátil (retorno) | Volátil (retorno) |
| EBX / RBX | **Preservar** | **Preservar** |
| ECX / RCX | Volátil (3° param) | Volátil (1° param) |
| EDX / RDX | Volátil (2° param) | Volátil (2° param) |
| ESI / RSI | **Preservar** | **Preservar** |
| EDI / RDI | **Preservar** | **Preservar** |
| EBP / RBP | **Preservar** | **Preservar** |
| ESP / RSP | **Preservar** | **Preservar** |
| R8 | — | Volátil (3° param) |
| R9 | — | Volátil (4° param) |
| R10, R11 | — | Volátil |
| R12-R15 | — | **Preservar** |
| XMM0-XMM3 | Volátil | Volátil |
| XMM4-XMM5 | Volátil | **Preservar** |
| XMM6-XMM15 | — | **Preservar** |

## Consequências de não preservar

- Corrupção silenciosa: o chamador pode ler valores errados em EBX/RSI/RDI etc.
- Crashes intermitentes: difíceis de reproduzir e depurar
- Loop infinito: se RBP é corrompido, o epilogue do caller fica com frame pointer errado
- Stack corruption: se ESP/RSP é corrompido, o RET vai para endereço aleatório

## Mnemônico Win32

**"Eu Sei Dar Bons Exemplos Periódicos"** → ESI, EDI, EBX, EBP (+ ESP implícito)

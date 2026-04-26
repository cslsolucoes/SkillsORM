# Registradores — Referência rápida Delphi 32/64

## Tabela: Registrador | Tamanho | Uso no Delphi 32 | Uso no Delphi 64

| Registrador | Bits | Delphi 32 (register) | Delphi 64 (Win64 ABI) | Preservar? |
|-------------|------|----------------------|-----------------------|------------|
| EAX / RAX | 32/64 | 1° param / retorno int | retorno int/ptr | Não (volátil) |
| EDX / RDX | 32/64 | 2° param / retorno hi | 2° param | Não (volátil) |
| ECX / RCX | 32/64 | 3° param | 1° param (ou Self) | Não (volátil) |
| EBX / RBX | 32/64 | uso geral | uso geral | **Sim** |
| ESI / RSI | 32/64 | string source | uso geral | **Sim** |
| EDI / RDI | 32/64 | string dest | uso geral | **Sim** |
| ESP / RSP | 32/64 | stack pointer | stack pointer | **Sim** (nunca perder) |
| EBP / RBP | 32/64 | frame pointer | frame pointer | **Sim** |
| R8 | 64 | — | 3° param | Não (volátil) |
| R9 | 64 | — | 4° param | Não (volátil) |
| R10 | 64 | — | uso geral | Não (volátil) |
| R11 | 64 | — | uso geral | Não (volátil) |
| R12-R15 | 64 | — | uso geral | **Sim** |
| XMM0 | 128 | retorno float (SSE) | retorno float/double | Não (volátil) |
| XMM4-XMM15 | 128 | — | uso SIMD | **Sim** |
| ST(0) | 80 | retorno Extended/Double | — (usar XMM0) | Não |

## Convenção de retorno

| Tipo | Delphi 32 | Delphi 64 |
|------|-----------|-----------|
| Integer, Cardinal, Pointer | EAX | RAX |
| Int64 | EDX:EAX | RAX |
| Single, Double | ST(0) | XMM0 |
| Extended | ST(0) | — (evitar em 64-bit) |
| Boolean | EAX (0 ou 1) | RAX |
| Record pequeno (≤8 bytes) | EAX:EDX | RAX |
| Record grande (>8 bytes) | ponteiro em EAX | ponteiro em RAX |

## Mnemônico de preservação (Win32)

```
Devo Preservar? → EBX ESI EDI EBP ESP   (= "Devemos Salvar Endereços E Ponteiros")
Posso destruir? → EAX EDX ECX           (= parâmetros e retorno)
```

## Mnemônico de preservação (Win64)

```
Devo Preservar? → RBX RSI RDI RBP RSP R12 R13 R14 R15 XMM4-XMM15
Posso destruir? → RAX RCX RDX R8 R9 R10 R11 XMM0-XMM5
```

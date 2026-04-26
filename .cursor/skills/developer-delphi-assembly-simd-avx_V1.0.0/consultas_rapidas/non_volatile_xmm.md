# XMM Non-Volatile no Win64 — Consulta Rapida

## Regra fundamental Win64

| Registrador | Tipo          | Obrigacao                                      |
| ----------- | ------------- | ---------------------------------------------- |
| XMM0-XMM5  | Volatile      | Pode ser destruido — nao precisa preservar     |
| XMM6-XMM15 | NON-VOLATILE  | DEVE ser preservado antes de usar              |

**Win32:** Todos XMM sao caller-saved — sem non-volatile.

## Como preservar com pseudo-op Delphi

```pascal
function MinhaFuncao: Single; assembler;
asm
  .PARAMS 0
  .SAVENV XMM6     // Delphi salva XMM6 no prologo, restaura no epilogo
  .SAVENV XMM7     // idem XMM7
  .SAVENV XMM8     // idem XMM8

  // Agora posso usar XMM6, XMM7, XMM8 livremente
  XORPS  XMM6, XMM6   // XMM6 = 0
  // ... operacoes com XMM6-XMM8 ...

  // Restauracao automatica antes do RET
end;
```

## Como preservar manualmente (sem pseudo-op)

```pascal
function ManualPreservation: Single; assembler;
asm
  // Salvar manualmente na pilha (alinhada a 16 bytes):
  SUB RSP, 32
  MOVAPS [RSP], XMM6      // salvar XMM6 (16 bytes alinhados)
  MOVAPS [RSP+16], XMM7   // salvar XMM7

  // ... usar XMM6 e XMM7 ...

  // Restaurar:
  MOVAPS XMM7, [RSP+16]
  MOVAPS XMM6, [RSP]
  ADD RSP, 32
  RET
end;
```

## VZEROUPPER — obrigatorio ao transicionar AVX → SSE

Ao usar instrucoes AVX (V-prefix, YMM), os bits 128-255 de YMM ficam "sujos".
Transicionar para SSE sem VZEROUPPER causa penalidade de 50-100 ciclos:

```pascal
procedure UsarAVX;
asm
  VMOVUPS YMM0, [RCX]     // instrucao AVX
  VADDPS  YMM0, YMM0, YMM1
  VMOVUPS [RDX], YMM0
  VZEROUPPER              // OBRIGATORIO antes de voltar para SSE/FPU!
  // Agora safe usar MOVAPS, ADDPS etc.
end;
```

## Quando usar XMM0-XMM5 vs XMM6-XMM15

| Cenario                           | Usar              |
| --------------------------------- | ----------------- |
| Variaveis temporarias de curta vida| XMM0-XMM5 (volatile) |
| Acumuladores ao longo de um loop  | XMM6-XMM15 (com .SAVENV) |
| Retorno de funcao float           | XMM0 (volatile — ja correto) |
| Parametro float de entrada        | XMM0-XMM3 (volatile — nao precisa salvar) |

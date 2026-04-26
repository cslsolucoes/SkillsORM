# EFLAGS / RFLAGS — Resumo dos bits principais

## Mapa dos bits relevantes

| Bit | Sigla | Nome completo | Setado (=1) quando | Usado por |
|-----|-------|---------------|--------------------|-----------|
| 0 | CF | Carry Flag | Resultado unsigned gerou carry/borrow; MUL overflow | JC, JNC, JB, JAE, ADC, SBB |
| 2 | PF | Parity Flag | Byte baixo tem número PAR de bits 1 | JP, JNP |
| 4 | AF | Auxiliary Carry | Carry do nibble baixo para nibble alto (BCD) | DAA, DAS |
| 6 | ZF | Zero Flag | Resultado é zero | JE, JZ, JNE, JNZ, LOOP |
| 7 | SF | Sign Flag | Resultado é negativo (bit mais alto = 1) | JS, JNS, JG, JL... |
| 8 | TF | Trap Flag | Single-step debug mode habilitado | Debugger |
| 9 | IF | Interrupt Enable | Interrupções de hardware habilitadas | CLI, STI |
| 10 | DF | Direction Flag | String ops decrementam RSI/RDI (padrão = 0 = incrementar) | STD, CLD, MOVS, STOS... |
| 11 | OF | Overflow Flag | Resultado signed causou overflow | JO, JNO, JG, JL, JGE, JLE |

## O que cada instrução afeta

```
ADD/SUB:    AF, CF, OF, PF, SF, ZF  (todas)
CMP:        AF, CF, OF, PF, SF, ZF  (como SUB sem resultado)
TEST:       CF=0, OF=0, PF, SF, ZF  (como AND sem resultado)
INC/DEC:    AF, OF, PF, SF, ZF      (CF NÃO é afetado!)
AND/OR/XOR: CF=0, OF=0, PF, SF, ZF
SHL/SHR:    CF (último bit), OF, PF, SF, ZF
MUL:        CF e OF = 0 se resultado cabe no tamanho menor; PF/SF/ZF = undefined
IMUL:       CF e OF = 0 se resultado cabe no tamanho menor
```

## Lendo flags no Delphi com SETcc

```pascal
procedure LerZeroFlag;
var
  ZeroFlagSetado: Byte;
begin
  asm
    MOV EAX, 5
    CMP EAX, 5      // ZF = 1 (são iguais)
    SETZ ZeroFlagSetado   // ZeroFlagSetado = 1 se ZF=1
  end;
  if ZeroFlagSetado <> 0 then
    WriteLn('Valores iguais (ZF=1)');
end;
```

## Flags e saltos condicionais — resumo rápido

| Condição | Signed | Unsigned |
|----------|--------|----------|
| Igual (=) | JE / JZ | JE / JZ |
| Diferente (≠) | JNE / JNZ | JNE / JNZ |
| Maior (>) | JG (ZF=0 e SF=OF) | JA (CF=0 e ZF=0) |
| Menor (<) | JL (SF≠OF) | JB (CF=1) |
| Maior ou igual (≥) | JGE (SF=OF) | JAE (CF=0) |
| Menor ou igual (≤) | JLE (ZF=1 ou SF≠OF) | JBE (CF=1 ou ZF=1) |

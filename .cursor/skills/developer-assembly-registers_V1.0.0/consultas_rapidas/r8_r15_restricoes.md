# R8-R15 — Restrições e disponibilidade

## Disponibilidade

R8-R15 existem **somente em modo 64-bit (Long Mode)**. Em 32-bit (Protected Mode) estes
registradores não existem e o uso de qualquer instrução que os referencie gera erro de compilação.

## No Delphi

```pascal
// ✓ Válido apenas com dcc64:
{$IFDEF CPUX64}
asm
  MOV R8,  1
  MOV R9,  2
  MOV R10, 3
  MOV R11, 4
  MOV R12, 5    // callee-saved — deve ser preservado!
  MOV R13, 6    // callee-saved
  MOV R14, 7    // callee-saved
  MOV R15, 8    // callee-saved
end;
{$ENDIF}

// ✗ ERRO de compilação com dcc32:
// asm
//   MOV R8, 1   // "R8: Unknown register name"
// end;
```

## Subdivisões de R8-R15

| 64-bit | 32-bit | 16-bit | 8-bit |
|--------|--------|--------|-------|
| R8 | R8D | R8W | R8B |
| R9 | R9D | R9W | R9B |
| R10 | R10D | R10W | R10B |
| R11 | R11D | R11W | R11B |
| R12 | R12D | R12W | R12B |
| R13 | R13D | R13W | R13B |
| R14 | R14D | R14W | R14B |
| R15 | R15D | R15W | R15B |

**Nota:** R8B-R15B (byte low) **não** têm equivalente "high" como AH/BH/CH/DH.
MOV R8D, valor → zero-extension para R8 (mesmo comportamento que EAX → RAX).

## Uso no Windows x64 ABI

| Registrador | Papel | Preservar? |
|-------------|-------|------------|
| R8 | 3° parâmetro de função | Não (volátil) |
| R9 | 4° parâmetro de função | Não (volátil) |
| R10 | uso geral temporário | Não (volátil) |
| R11 | uso geral temporário | Não (volátil) |
| R12 | uso geral | **Sim** (callee-saved) |
| R13 | uso geral | **Sim** (callee-saved) |
| R14 | uso geral | **Sim** (callee-saved) |
| R15 | uso geral | **Sim** (callee-saved) |

## Codificação de instrução (REX prefix)

Os registradores R8-R15 requerem o prefixo **REX** (0x40-0x4F) na codificação da instrução:
- REX.R = extensão do campo reg do ModRM
- REX.X = extensão do campo index do SIB
- REX.B = extensão do campo base do ModRM ou campo rm do ModRM

```
REX.W (bit 3) = operação de 64-bit
REX.R (bit 2) = estende campo reg para R8-R15
REX.X (bit 1) = estende índice SIB para R8-R15
REX.B (bit 0) = estende base/rm para R8-R15
```

Consequência: instruções com R8-R15 têm 1 byte a mais (REX prefix), ligeiramente mais lentas
em código muito comprimido, mas geralmente irrelevante para performance.

## Code guards — padrão recomendado

```pascal
// Padrão para código compatível com 32 e 64-bit:
procedure MinhaFuncao(A, B: NativeInt);
asm
  {$IFDEF CPUX64}
    // Código 64-bit — pode usar R8-R15
    MOV  RAX, RCX
    ADD  RAX, RDX
    MOV  R10, RAX   // R10 é volátil, OK
  {$ELSE}
    // Código 32-bit — apenas EAX-EDI
    ADD  EAX, EDX
  {$ENDIF}
end;
```

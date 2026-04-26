---
name: developer-delphi-assembly-simd-avx
description: SIMD em Delphi — SSE2, SSE4.1, AVX (YMM 256-bit) e AVX-512 (ZMM 512-bit). Registradores XMM/YMM/ZMM, instrucoes vetorizadas, sintaxe angle brackets do Delphi para masking AVX-512, preservacao de XMM, CPUID check e alinhamento de dados.
model: sonnet
thinking: extended
category: developer-delphi-assembly
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-assembly-simd-avx

## Versao interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |

## Responsabilidade unica

Esta skill cobre o uso de instrucoes SIMD (Single Instruction, Multiple Data) em Delphi — desde SSE2 (XMM 128-bit), SSE4.1, AVX/AVX2 (YMM 256-bit) ate AVX-512 (ZMM 512-bit) com opmask. Documenta a sintaxe especifica do Delphi para masking AVX-512 (angle brackets `<>` em vez de chaves `{}` que sao comentarios Pascal), como preservar registradores XMM non-volatile no Win64, verificar suporte com CPUID e alinhar dados corretamente. NAO cobre convencoes de chamada em geral — essas pertencem a `developer-delphi-assembly-calling-conventions`.

## When to use

- Processar arrays de float/double em paralelo (4x SSE, 8x AVX, 16x AVX-512).
- Implementar operacoes de algebra linear (dot product, matrix multiply) otimizadas.
- Processamento de imagens, audio ou dados numericos de alta throughput.
- Verificar suporte a extensoes de CPU em runtime (CPUID).
- Operacoes de string/memoria otimizadas com PCMPESTRI/PCMPISTRI (SSE4.2).

## When NOT to use

- Logica de negocios simples — overhead de SIMD nao justifica a complexidade.
- Codigo portavel iOS/Android — LLVM sem suporte a `asm..end`.
- Operacoes em dados nao-contiguos na memoria — SIMD requer acesso sequencial ou alinhado.

## Registradores SIMD

| Registrador  | Tamanho  | Capacidade                                    | Disponivel desde |
| ------------ | -------- | --------------------------------------------- | ---------------- |
| XMM0-XMM15  | 128-bit  | 4x Single, 2x Double, 16x Byte, 4x Int32     | SSE (1999)       |
| YMM0-YMM15  | 256-bit  | 8x Single, 4x Double, 32x Byte, 8x Int32     | AVX (2011)       |
| ZMM0-ZMM31  | 512-bit  | 16x Single, 8x Double, 64x Byte, 16x Int32   | AVX-512 (2017)   |
| K0-K7       | 64-bit   | Opmask registers para AVX-512                 | AVX-512          |

**Relacao:** YMM0 = XMM0 + 128 bits altos. ZMM0 = YMM0 + 256 bits altos.
Usar instrucao AVX (V-prefix) zera automaticamente os bits altos de YMM/ZMM.

## Preservacao de XMM no Win64

- **XMM0-XMM5:** Volateis (caller-saved) — podem ser destruidos
- **XMM6-XMM15:** NON-VOLATILE — devem ser preservados!

```pascal
function ComSIMD: Single; assembler;
asm
  .PARAMS 0
  .SAVENV XMM6    // salva XMM6 automaticamente
  .SAVENV XMM7    // salva XMM7
  // Pode usar XMM6 e XMM7 livremente — restaurados no epilogo
end;
```

## Sintaxe AVX-512 no Delphi (ANGLE BRACKETS!)

```pascal
// IMPORTANTE: chaves {} = comentarios no Pascal/Delphi!
// AVX-512 masking usa angle brackets < > no built-in assembler Delphi

asm
  // Masking com zeroing (elementos onde k1=0 viram zero):
  VADDPS ZMM0 <k1><z>, ZMM1, ZMM2   // Delphi syntax (< > em vez de { })

  // Masking sem zeroing (elementos onde k1=0 ficam inalterados):
  VADDPS ZMM0 <k1>, ZMM1, ZMM2

  // Broadcast: replicar scalar para todos os elementos:
  VBROADCASTSS ZMM0, [RBX] <1to16>  // Delphi syntax

  // Rounding control embutido:
  VADDPS ZMM0, ZMM1, ZMM2 <rd>      // round-down
end;
```

## Verificar suporte SIMD em runtime (CPUID)

```pascal
function SuportaSSE2: Boolean; assembler;
asm
{$IF DEFINED(WIN32)}
  PUSH EBX
  MOV  EAX, 1        // CPUID leaf 1: feature flags
  CPUID              // EDX bit 26 = SSE2
  BT   EDX, 26       // testar bit 26 de EDX
  SETC AL            // AL = 1 se SSE2 suportado
  POP  EBX
{$ENDIF}
{$IF DEFINED(WIN64)}
  PUSH RBX
  MOV  EAX, 1
  CPUID
  BT   EDX, 26
  SETC AL
  POP  RBX
{$ENDIF}
end;

function SuportaAVX2: Boolean; assembler;
asm
{$IF DEFINED(WIN32)}
  PUSH EBX
  MOV  EAX, 7        // CPUID leaf 7 = extended features
  XOR  ECX, ECX
  CPUID              // EBX bit 5 = AVX2
  BT   EBX, 5
  SETC AL
  POP  EBX
{$ENDIF}
end;
```

## Instrucoes SSE2 fundamentais

```nasm
; Floats (Single = 32-bit):
MOVAPS  XMM0, [EAX]        ; carregar 4 floats ALINHADOS (16 bytes)
MOVUPS  XMM0, [EAX]        ; carregar 4 floats NAO-ALINHADOS
ADDPS   XMM0, XMM1         ; XMM0[0..3] += XMM1[0..3] (4 somas)
MULPS   XMM0, XMM1         ; XMM0[0..3] *= XMM1[0..3] (4 multiplicacoes)
SUBPS   XMM0, XMM1         ; 4 subtracoes
DIVPS   XMM0, XMM1         ; 4 divisoes
SQRTPS  XMM0, XMM1         ; 4 raizes quadradas

; Inteiros (PADDQ, PSUBQ, PCMPEQD, PMULLD):
MOVDQU  XMM0, [EAX]        ; 128-bit nao-alinhado
PADDQ   XMM0, XMM1         ; 2x Int64 soma
PSUBQ   XMM0, XMM1         ; 2x Int64 subtracao
PCMPEQD XMM0, XMM1         ; 4x Int32 igualdade (mascara)
PMULLD  XMM0, XMM1         ; 4x Int32 multiplicacao (SSE4.1!)
```

## Instrucoes AVX2 fundamentais (YMM 256-bit)

```nasm
; Floats (8 floats por operacao):
VMOVDQU YMM0, [EAX]             ; carregar 8 floats nao-alinhados
VADDPS  YMM0, YMM1, YMM2        ; YMM0 = YMM1 + YMM2 (3 operandos, nao-destrutivo!)
VMULPS  YMM0, YMM1, YMM2        ; YMM0 = YMM1 * YMM2
VHADDPS YMM0, YMM1, YMM2        ; horizontal add
VFMADD132PS YMM0, YMM1, YMM2   ; fused multiply-add: YMM0 = YMM0 * YMM2 + YMM1
VZEROUPPER                       ; OBRIGATORIO: limpar bits altos YMM antes de SSE
```

## Alinhamento de dados

```pascal
// Alinhamento 16 bytes para SSE:
type
  TFloat4 = array[0..3] of Single;

var
  Data: TFloat4;  // Delphi nao garante alinhamento automatico!

// Para garantir alinhamento, usar:
// 1. Campo de record com {$ALIGN 16}
// 2. GetMemory + alinhamento manual
// 3. Usar MOVUPS (nao-alinhado) se nao ha garantia

// Diretiva de alinhamento em record:
type
  {$ALIGN 16}
  TAlinhado = record
    Floats: array[0..3] of Single;
  end;
  {$ALIGN OFF}
```

## Inputs

- Tipo de dados a processar (Single, Double, Integer, Byte).
- Tamanho do array e restricoes de alinhamento.
- Nivel de SIMD disponivel (SSE2, AVX, AVX-512).

## Workflow executavel

1. Verificar suporte de CPU em runtime com CPUID.
2. Garantir alinhamento dos dados (MOVAPS requer 16 bytes, VMOVAPS requer 32).
3. Implementar loop principal com instrucoes vetorizadas.
4. Tratar elementos residuais (Count mod N) com loop escalar.
5. Chamar VZEROUPPER antes de transicao AVX → SSE.
6. Testar com arrays de tamanho variado (0, 1, 3, 4, 8, 17...).

## Anti-padroes

| Anti-padrao                           | Por que e errado                              | Como corrigir                            |
| ------------------------------------- | --------------------------------------------- | ---------------------------------------- |
| `{k1}{z}` para masking AVX-512        | Chaves = comentarios Pascal — ignoradas!      | Usar `<k1><z>` no Delphi               |
| Usar MOVAPS com dados nao-alinhados   | General Protection Fault em runtime           | Usar MOVUPS ou garantir alinhamento      |
| Esquecer VZEROUPPER apos AVX          | Penalidade de transicao AVX→SSE (50-100 ciclos)| Chamar VZEROUPPER antes de SSE          |
| Modificar XMM6-XMM15 sem .SAVENV     | Corrompe estado do caller em Win64            | Adicionar .SAVENV XMMreg                 |
| SIMD sem CPUID check                  | Crash em CPUs antigas (ex: pre-2011)          | Verificar em runtime com CPUID           |

## Referencias

- Consulta rapida: `consultas_rapidas/registradores_simd.md`
- Consulta rapida: `consultas_rapidas/avx512_sintaxe_delphi.md`
- Exemplos: `exemplos/pas/sse_soma_floats.pas`, `avx2_soma_8floats.pas`
- Templates: `templates/TEMPLATE_sse_dot_product.pas`, `TEMPLATE_avx2_loop.pas`
- Skill orquestradora: `developer-delphi-assembly-orchestrator_V1.1.0`

---

## Changelog (este arquivo)

- 1.0.0 (11/04/2026): Criacao inicial — XMM/YMM/ZMM, SSE2/AVX2/AVX-512, angle brackets Delphi, CPUID, alinhamento e exemplos.

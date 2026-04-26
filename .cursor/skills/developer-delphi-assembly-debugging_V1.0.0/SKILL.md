---
name: developer-delphi-assembly-debugging
description: Depuração de assembly em Delphi — CPU View do IDE (disassembly, registradores, stack, FPU/SSE), INT 3 como breakpoint manual, RDTSC/RDTSCP para benchmarking de ciclos, OutputDebugString de dentro de asm, analise com x64dbg e estrategias de diagnostico.
model: sonnet
thinking: extended
category: developer-delphi-assembly
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-assembly-debugging

## Versao interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |

## Responsabilidade unica

Esta skill cobre tecnicas especificas de depuracao de codigo assembly em Delphi: uso do CPU View do IDE, breakpoints condicionais via INT 3, medicao de performance com RDTSC, inspecao de registradores e pilha, e uso de ferramentas externas como x64dbg. NAO cobre debugging Pascal geral (FastMM4, EurekaLog) — essas pertencem a `developer-delphi-debugging-techniques`.

## When to use

- Depurar corrupcao de registradores ou pilha em rotinas asm.
- Medir exatamente quantos ciclos de CPU uma rotina consome.
- Verificar que registradores non-volatile foram preservados corretamente.
- Inspecionar o estado da pilha antes/depois de um CALL.
- Depurar codigo asm externamente com x64dbg quando o IDE nao e suficiente.

## When NOT to use

- Debugging Pascal geral (memory leaks, stack traces) → `developer-delphi-debugging-techniques`.
- Depuracao de codigo iOS/Android → asm inline nao existe nessas plataformas.
- Profiling de alto nivel (DLL calls, SQL) → ferramentas de profiling especializadas.

## CPU View — Atalhos e Paneis

**Abrir:** View → Debug Windows → CPU (ou Ctrl+Alt+C no Delphi)

| Painel        | Conteudo                                              |
| ------------- | ----------------------------------------------------- |
| Disassembly   | Codigo assembly gerado pelo compilador; breakpoints   |
| Registers     | EAX/RAX, EBX/RBX, ECX/RCX, EDX/RDX, ESP/RSP, EIP/RIP|
| Stack         | Conteudo da pilha em hex (ESP/RSP para baixo)         |
| Memory        | Inspecionar qualquer regiao de memoria em hex/texto   |
| FPU/MMX/SSE   | ST(0)-ST(7), XMM0-XMM15, flags de status FPU         |

**Teclas de passo no CPU View:**
- F8: Step Over (executa 1 instrucao, nao entra em CALL)
- F7: Trace Into (entra na funcao CALL)
- F4: Run to Cursor (executar ate instrucao apontada pelo cursor)
- F9: Run (continuar ate proximo breakpoint)

## Watch de registradores no IDE

No Watch Window (Ctrl+Alt+W), adicionar os nomes:
- `EAX`, `EBX`, `ECX`, `EDX`, `ESI`, `EDI`, `ESP`, `EBP`
- `RAX`, `RBX`, `RCX`, `RDX`, `RSI`, `RDI`, `RSP`, `RBP` (x64)
- `XMM0`, `XMM1`, etc. — funcionam como variaveis Pascal!

## INT 3 — Breakpoint manual em asm

```pascal
// INT 3 = opcode 0xCC = software breakpoint
// O debugger captura o trap e para a execucao
procedure DebugPointCondicional(Condicao: Boolean);
asm
  TEST AL, AL     // Boolean em AL
  JZ   @fim       // pular se Condicao = False
  INT  3          // parar no debugger se Condicao = True
@fim:
end;

// Uso em producao — condicional em compilacao:
procedure MinhaRotina;
asm
  // ... codigo ...
  {$IFDEF DEBUG}
  INT 3           // somente em builds DEBUG
  {$ENDIF}
  // ... mais codigo ...
end;
```

## RDTSC — Benchmarking de ciclos de CPU

```pascal
function LerTSC: Int64; assembler;
// Retorna o contador de ciclos de CPU desde o boot
// Diferenca entre dois LerTSC = ciclos gastos
asm
  RDTSC           // EDX:EAX = timestamp counter (64-bit)
  // Int64 em Win32: retorno automatico em EDX:EAX
  // Int64 em Win64: RAX = RAX (RDTSC preenche automaticamente RAX)
end;

// Uso:
// var T1, T2: Int64;
// T1 := LerTSC;
// MinhaRotina;
// T2 := LerTSC;
// CiclosGastos := T2 - T1;
```

## Inputs

- Rotina assembly com bug (corrupcao de registrador, stack imbalance, valor errado).
- Hipotese do bug (registrador incorreto, salto errado, acesso a memoria invalida).
- Plataforma (Win32/Win64) e ferramenta disponivel (IDE Delphi, x64dbg, WinDbg).

## Workflow executavel

1. Compilar em modo DEBUG (Project → Options → Compiler → Debug Information ON).
2. Abrir CPU View (View → Debug Windows → CPU).
3. Colocar breakpoint na primeira instrucao asm suspeita (F8 ou F5 no codigo).
4. Anotar valores de EAX/RAX, ESP/RSP antes da secao suspeita.
5. Executar instrucao a instrucao (F8), verificando registradores.
6. Comparar ESP antes e depois de cada PUSH/POP para detectar imbalance.
7. Verificar que callee-saved (EBX, ESI, EDI) tem os mesmos valores apos a funcao.
8. Se necessario, adicionar INT 3 condicional para parar em condicao especifica.
9. Para performance: usar RDTSC para medir ciclos com e sem a otimizacao.

## Anti-padroes

| Anti-padrao                        | Por que e errado                                    | Como corrigir                              |
| ---------------------------------- | --------------------------------------------------- | ------------------------------------------ |
| INT 3 em builds de producao        | Crash para o usuario se nao houver debugger         | Sempre proteger com {$IFDEF DEBUG}          |
| RDTSC sem CPUID/LFENCE antes       | CPU pode reordenar instrucoes, medida imprecisa     | Adicionar LFENCE antes/depois de RDTSC     |
| Nao verificar ESP antes e apos     | Stack imbalance silencioso — crash distante         | Comparar ESP no CPU View antes/depois CALL |
| Watch de XMM sem CPU View aberto   | Watch Window mostra XMM como escalar, nao vetor     | Usar painel FPU/SSE do CPU View            |
| Nao usar DEBUG info no .dproj      | Disassembly sem simbolos — impossivel de rastrear   | Project → Options: Debug Info = True       |

## Referencias

- Consulta rapida: `consultas_rapidas/cpu_view_atalhos.md`
- Consulta rapida: `consultas_rapidas/x64dbg_guia.md`
- Exemplos: `exemplos/pas/rdtsc_profiling.pas`, `breakpoint_asm.pas`
- Templates: `templates/TEMPLATE_debug_benchmark.pas`, `TEMPLATE_int3_break.pas`
- Skill orquestradora: `developer-delphi-assembly-orchestrator_V1.1.0`

---

## Changelog (este arquivo)

- 1.0.0 (11/04/2026): Criacao inicial — CPU View, INT 3, RDTSC, x64dbg, workflow de debug e anti-padroes.

# Mapa de Skills Assembly Delphi — Consulta Rapida

## Qual skill usar para cada tarefa?

| Tarefa                                                    | Skill                                           |
| --------------------------------------------------------- | ----------------------------------------------- |
| Entender como Delphi passa parametros em asm              | `calling-conventions` (J1)                      |
| Saber quais registradores devo preservar                  | `calling-conventions` (J1)                      |
| Escrever bloco asm dentro de funcao Pascal existente      | `delphi-inline` (J2)                            |
| Usar OFFSET, TYPE, SIZE, @Result no bloco asm             | `delphi-inline` (J2) + `expressions` (J5)       |
| Criar funcao inteiramente em assembly (`assembler;`)      | `delphi-functions` (J3)                         |
| Linkar arquivo .obj NASM ao projeto Delphi                | `delphi-functions` (J3)                         |
| Usar pseudo-ops x64 (.PARAMS, .PUSHNV, .SAVENV)          | `delphi-functions` (J3)                         |
| Processar arrays de float com SSE/AVX                     | `simd-avx` (J4)                                 |
| Verificar suporte de CPU com CPUID                        | `simd-avx` (J4)                                 |
| Usar AVX-512 com masking no Delphi (angle brackets)       | `simd-avx` (J4)                                 |
| Usar VMTOFFSET para chamar metodo virtual em asm          | `expressions` (J5)                              |
| Calcular tamanho de tipo com TYPE/SIZE                    | `expressions` (J5)                              |
| Otimizar multiplicacao com LEA                            | `expressions` (J5)                              |
| Escrever macros NASM (%macro, %rep)                       | `expressions` (J5)                              |
| Depurar codigo asm com CPU View do IDE                    | `debugging` (J6)                                |
| Adicionar breakpoint manual INT 3                         | `debugging` (J6)                                |
| Medir ciclos de CPU com RDTSC                             | `debugging` (J6)                                |
| Inspecionar stack frame no x64dbg                         | `debugging` (J6)                                |
| Decidir se devo usar asm ou Pascal puro                   | `orchestrator` (esta skill)                     |

## Arvore de decisao rapida

```
Preciso de assembly?
  ├── Nao sei → ler consultas_rapidas/quando_usar_asm.md
  ├── Sim — otimizacao de loop/array de dados
  │     └── Dados sao float/int em paralelo? → simd-avx (J4)
  │     └── Sem SIMD, apenas logica otimizada → delphi-inline (J2)
  ├── Sim — preciso de instrucao especifica (CPUID, RDTSC, POPCNT)
  │     └── Dentro de funcao existente → delphi-inline (J2)
  │     └── Funcao separada → delphi-functions (J3)
  ├── Sim — integrar .obj NASM externo
  │     └── delphi-functions (J3)
  └── Sim — chamar metodo virtual por offset
        └── expressions (J5) — VMTOFFSET
```

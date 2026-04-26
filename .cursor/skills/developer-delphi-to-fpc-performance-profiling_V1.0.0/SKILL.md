---
name: developer-delphi-to-fpc-performance-profiling
description: Profiling e benchmarking em Delphi — TStopwatch, FastMM5, AQTime/Sampling Profiler, QueryPerformanceCounter, hotspots em producao e analise de leaks de memoria.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-performance-profiling

## Versao interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Data** | 11/04/2026 |

## Responsabilidade unica

Esta skill cobre medição precisa de desempenho e diagnóstico de memória em Delphi: micro-benchmarks com `TStopwatch`, profiling de hotspots com AQTime e Sampling Profiler do RAD Studio, counters de alta resolução via `QueryPerformanceCounter`, relatórios de leak com FastMM5 e técnicas de benchmark estatisticamente correto (aquecimento de cache + média de N execuções). Ela NÃO cobre otimizações arquiteturais de alto impacto (→ `developer-delphi-to-fpc-performance-and-architecture`) e NÃO diagnostica exceções de runtime (→ `developer-delphi-to-fpc-error-handling-and-diagnostics`).

## When to use

- Medir tempo de execução de trechos específicos de código com TStopwatch.
- Identificar hotspots com AQTime ou Sampling Profiler integrado ao RAD Studio.
- Configurar FastMM5 para relatório de leaks em build de diagnóstico.
- Comparar implementações alternativas por benchmark estatístico (N execuções, min/avg/max).
- Usar QueryPerformanceCounter/GetTickCount64 para medições em contexto Windows.

## When NOT to use

- Não usar para decisões arquiteturais de pool de objetos ou threading → use `developer-delphi-to-fpc-performance-and-architecture`.
- Não usar para diagnóstico de exceções em runtime → use `developer-delphi-to-fpc-error-handling-and-diagnostics`.
- Não usar para testes unitários que verificam ausência de leaks em pipeline → use `developer-delphi-testing-and-quality`.
- Não usar para otimização de queries SQL → referenciar documentação do módulo de banco.

## Inputs

- Trecho de código a medir (função, loop, operação de I/O).
- Critério de comparação: implementação A vs. B, ou baseline vs. otimizado.
- Contexto de execução: build Debug vs. Release, plataforma Win32 vs. Win64.

## Workflow executavel

1. **Definir baseline** — identificar o trecho a medir; garantir build Release (sem otimizações do debugger).
2. **Aquecer o cache** — executar a operação 1–3 vezes antes de iniciar a medição real (evita cold-start).
3. **Medir N vezes** — executar 10–100 iterações; registrar min, avg e max.
4. **Comparar** — se comparando implementações, medir ambas sob as mesmas condições de sistema.
5. **Interpretar hotspots** — usar AQTime ou Sampling Profiler para confirmar que o ponto medido é responsável por ≥ 20 % do custo total.
6. **Validar leaks** — rodar com FastMM5 configurado; zero leaks antes de declarar otimização concluída.
7. **Documentar** — registrar baseline vs. resultado e custo de complexidade adicionado.

## Tecnicas cobertas

| Tecnica | Quando usar | Precisao |
|---------|-------------|----------|
| `TStopwatch` (System.Diagnostics) | Micro-benchmarks em código Delphi puro | ~100 ns |
| `QueryPerformanceCounter` (Windows API) | Medições de alta resolução fora de System.Diagnostics | ~100 ns |
| `GetTickCount64` | Medições de baixa resolução; timeouts grosseiros | ~15 ms |
| AQTime (RAD Studio Add-on) | Profiling completo com call graph e alocações | - |
| Sampling Profiler (IDE) | Hotspot CPU rápido sem instrumentação | - |
| FastMM5 heap snapshot | Diagnóstico de leaks e crescimento de heap | - |

## Dependencias (skills previas)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-to-fpc-build` | Build Release limpo e sem hints/warnings é pré-requisito |
| `developer-delphi-to-fpc-performance-and-memory` | Confirmar diagnóstico de leak antes de interpretar snapshots FastMM5 |

## Checklist Delphi

- [ ] Build em modo Release (não Debug) para medições representativas
- [ ] Aquecimento de cache executado antes das medições reais
- [ ] Mínimo de 10 iterações; calcular min/avg/max
- [ ] FastMM5 habilitado (LogToFile + OutputDebugString) em build de diagnóstico
- [ ] AQTime ou Sampling Profiler confirma que hotspot corresponde ao trecho medido
- [ ] Comparação A vs. B executada nas mesmas condições de sistema (sem outros processos pesados)
- [ ] Resultado documentado: baseline, resultado pós-otimização, trade-off de complexidade

## Exemplo minimo compilavel

### TStopwatch basico — Delphi (dcc32 / dcc64)

```pascal
program SampleStopwatchDelphi;
{$APPTYPE CONSOLE}
uses
  System.Diagnostics, System.SysUtils;
var
  SW: TStopwatch;
  I: Integer;
  S: string;
begin
  SW := TStopwatch.StartNew;
  for I := 1 to 1000 do
    S := S + 'x';
  SW.Stop;
  WriteLn('Elapsed ms: ' + IntToStr(SW.ElapsedMilliseconds));
  WriteLn('Elapsed ticks: ' + IntToStr(SW.ElapsedTicks));
  WriteLn('Frequency (ticks/s): ' + IntToStr(TStopwatch.Frequency));
  Halt(0);
end.
```

## Anti-padroes

| Anti-padrao | Por que e errado | Como corrigir |
|-------------|-----------------|---------------|
| Medir com build Debug | JIT, assertions e checks extras distorcem o tempo | Sempre medir em build Release |
| Uma única iteração como baseline | Ruído de sistema domina o resultado | Executar ≥ 10 iterações; usar média |
| Sem aquecimento de cache | Primeira execução inclui cold-start de CPU e memória | Executar a operação 1–3 vezes antes de iniciar medição |
| FastMM5 habilitado em produção com MessageBoxes | Travamento em servidores sem UI | `FastMM_MessageBoxes := False`; usar apenas LogToFile |
| Comparar Debug vs. Release como "antes/depois" | Variável de controle diferente; resultado inválido | Comparar mesma configuração de build |

## Metricas de sucesso

- Benchmark executa sem errors; min/avg/max registrados.
- FastMM5 reporta zero leaks após execução do benchmark.
- Hotspot confirmado por AQTime ou Sampling Profiler.
- Comparação A vs. B com diferença estatisticamente significativa (> 5 % de delta avg).

## Responsavel principal

| Papel | Quem |
|-------|------|
| Responsavel pelo benchmark | Desenvolvedor do modulo |
| Validador de leaks | CI/pipeline com FastMM5 habilitado |

## Avaliacao de risco e confirmacao

- Benchmarks com FastMM5 em FullDebugMode são ~3-5x mais lentos que produção; não usar esses números como baseline de performance.
- Se a otimização alterar contrato público de interface, confirmar antes e executar `governance-refactoring-compatibility-policy`.

## Referencias

- `exemplos/stopwatch.pas` — TStopwatch micro-benchmarks
- `exemplos/fastmm5_config.pas` — FastMM5 configuração e leitura de relatório
- `exemplos/memory_leak_patterns.pas` — padrões de leak e como evitar
- `exemplos/string_concat_perf.pas` — benchmark: + vs TStringBuilder vs TArray.Join
- `consultas_rapidas/fastmm_opcoes.md` — FullDebugMode vs Production; opções
- `consultas_rapidas/profiling_tools.md` — AQTime, Sampling Profiler IDE
- `consultas_rapidas/hotspot_identificacao.md` — como ler CPU profile
- `templates/TEMPLATE_benchmark.pas` — micro-benchmark com min/max/avg
- `templates/TEMPLATE_leak_test.pas` — test case que verifica ausência de leaks
- RAD Studio docs — AQTime, Sampling Profiler, TStopwatch
- `.cursor/skills/developer-delphi-to-fpc-performance-and-memory_V1.0.0/SKILL.md`

## Changelog (este arquivo)

- 1.0.0 (11/04/2026): Skill nova — SP-E2 do plano master; cobre TStopwatch, FastMM5, AQTime/Sampling Profiler, QueryPerformanceCounter, benchmark estatístico e padrões de leak.

---
name: developer-delphi-debugging-techniques
description: Técnicas avançadas de depuração em Delphi — breakpoints condicionais, watches, CPU View, FastMM4, EurekaLog/MadExcept, OutputDebugString e estratégias de diagnóstico.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-debugging-techniques

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## Responsabilidade única

Esta skill cobre técnicas avançadas de depuração de aplicações Delphi: uso do debugger integrado do IDE (breakpoints condicionais, watches, call stack, CPU View), rastreamento de memory leaks com FastMM4, geração de crash reports com EurekaLog/MadExcept, diagnóstico não-intrusivo com `OutputDebugString` e estratégias sistémicas como binary search debugging e logging estratégico. Ela NÃO modela hierarquias de exceções nem define políticas de tratamento de erro — essas responsabilidades pertencem a `developer-delphi-to-fpc-error-handling-and-diagnostics`.

## When to use

- Localizar causa raiz de bugs em runtime: crashes, comportamentos inesperados, loops infinitos.
- Rastrear memory leaks e uso indevido de memória.
- Inspecionar estado interno de objetos, listas e strings durante execução.
- Diagnosticar problemas de concorrência ou threading.
- Integrar crash reporters (EurekaLog/MadExcept) em builds de produção/staging.
- Adicionar instrumentação de debug sem alterar fluxo principal (`OutputDebugString`, `{$IFDEF DEBUG}`).

## When NOT to use

- Não usar para modelar hierarquia de exceções → use `developer-delphi-to-fpc-error-handling-and-diagnostics`.
- Não usar para otimização de performance ou profiling → use `developer-delphi-to-fpc-performance-and-memory`.
- Não usar para configurar build pipelines ou compilação → use `developer-delphi-to-fpc-build`.
- Não usar para escrever testes automatizados → use `developer-delphi-testing-and-quality`.

## Inputs

- Código-fonte Pascal com bug a investigar.
- Stack trace / crash report de produção.
- Descrição do comportamento esperado vs. observado.

## Workflow executável

1. Reproduzir o problema com o mínimo de código possível (minimal reproduce).
2. Isolar a área suspeita com binary search debugging (comentar metades do código).
3. Posicionar breakpoints condicionais na entrada da área suspeita.
4. Inspecionar estado via Watch Window e Call Stack.
5. Se memory leak: habilitar FastMM4 `ReportMemoryLeaksOnShutdown` e analisar relatório.
6. Se crash em produção: analisar call stack do crash report (EurekaLog/MadExcept).
7. Adicionar `OutputDebugString` onde breakpoints não são viáveis (código de inicialização, threads).
8. Corrigir e validar: remover instrumentação de debug antes do commit.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-to-fpc-error-handling-and-diagnostics` | Antes de interpretar stack traces e exceções capturadas |
| `developer-delphi-to-fpc-performance-and-memory` | Quando o problema envolver consumo de memória além de leaks simples |

## Checklist Delphi+FPC

- [ ] Compilação sem hints/warnings em Delphi (dcc32 + dcc64)
- [ ] Compilação sem hints/warnings em FPC (fpc32 + fpc64)
- [ ] FastMM4 habilitado em debug builds com `ReportMemoryLeaksOnShutdown := True`
- [ ] `OutputDebugString` protegido por `{$IFDEF DEBUG}` — não vazar para produção
- [ ] Breakpoints condicionais removidos/desativados antes do commit
- [ ] Crash reporter (EurekaLog/MadExcept) configurado apenas em builds release destinados a diagnóstico
- [ ] Nenhum `DebugBreak` ou `Int3` manual deixado no código de produção
- [ ] Call stack analisada a partir do frame mais interno (topo da pilha)
- [ ] Nomenclatura: prefixos T/I/E/F/A conforme documentation-project-expert

## Atalhos do Debugger IDE (tabela rápida)

| Tecla | Ação |
|-------|------|
| F5 | Run / Continue (retomar execução) |
| F8 | Step Over (próxima linha, sem entrar em funções) |
| F7 | Trace Into (entrar na função chamada) |
| F4 | Run to Cursor (executar até o cursor) |
| F9 | Toggle Breakpoint na linha atual |
| Ctrl+F2 | Reset / Stop (parar processo) |
| Ctrl+Alt+B | Breakpoints list (gerenciar todos os breakpoints) |
| Ctrl+Alt+W | Watch list (gerenciar watches) |
| Ctrl+Alt+S | Call Stack window |
| Ctrl+Alt+C | CPU View (disassembly + registradores + memória) |

## Exemplo mínimo compilável

**Delphi (dcc32 / dcc64):**

```pascal
program SampleDebuggingDelphi;
{$APPTYPE CONSOLE}
uses
  SysUtils, Windows;
begin
  {$IFDEF DEBUG}
  OutputDebugString('SampleDebuggingDelphi: iniciando');
  {$ENDIF}
  try
    WriteLn('OK -- developer-delphi-debugging-techniques');
  except
    on E: Exception do
      WriteLn(E.ClassName + ': ' + E.Message);
  end;
end.
```

**Free Pascal (fpc32 / fpc64):**

```pascal
program SampleDebuggingFPC;
{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}
{$APPTYPE CONSOLE}
uses
  SysUtils;
begin
  try
    WriteLn('OK -- developer-delphi-debugging-techniques');
  except
    on E: Exception do
      WriteLn(E.ClassName + ': ' + E.Message);
  end;
end.
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|------------------|---------------|
| `except` vazio para "suprimir" bugs | Esconde o problema; bug reaparece em condições diferentes | Tratar ou re-lançar com contexto; nunca suprimir silenciosamente |
| Deixar `OutputDebugString` sem `{$IFDEF DEBUG}` | Vaza informação interna em builds de produção; impacto de performance | Envolver sempre com `{$IFDEF DEBUG}` ou `{$IFDEF VERBOSE_LOG}` |
| Depender apenas de `ShowMessage` para diagnóstico | Para threads secundárias; bloqueia UI; não capturado em logs | Usar `OutputDebugString` + DebugView ou logging estruturado |
| Breakpoint na linha errada (loop externo em vez do interno) | Para na iteração errada; desperdiça tempo | Usar breakpoint condicional: `I = ValorSuspeito` |
| Analisar call stack de baixo para cima | Confusão sobre a origem real do erro | Sempre ler de cima para baixo: o frame do topo é o ponto exato do erro |
| FastMM4 em builds de produção sem configuração | Overhead de performance; relatório em janela modal em produção | Habilitar apenas em debug: `{$IFDEF DEBUG}ReportMemoryLeaksOnShutdown := True;{$ENDIF}` |

## Métricas de sucesso

- Tempo médio de localização de bug reduzido com uso de breakpoints condicionais.
- Zero memory leaks reportados pelo FastMM4 no shutdown de testes de integração.
- Crash reports de produção com call stack legível e identificação de frame de origem.
- Nenhum `OutputDebugString` ou `DebugBreak` presente em builds release.

## Responsável principal

| Papel | Quem |
|-------|------|
| Desenvolvedor debugger | Desenvolvedor responsável pelo módulo com bug |
| Revisor de crash reports | Líder técnico do projeto |

## Avaliacao de risco e confirmacao

- Habilitar FastMM4 em modo verbose pode impactar performance em testes de carga — confirmar com usuário antes de ativar em ambiente de staging compartilhado.

## Referencias

- FastMM4: https://github.com/pleriche/FastMM4
- EurekaLog: https://www.eurekalog.com
- MadExcept: http://madshi.net/madExceptDesc.htm
- Sysinternals DebugView: https://learn.microsoft.com/en-us/sysinternals/downloads/debugview
- Object Pascal Handbook (capítulo de debugging)

## Changelog (este arquivo)

- 1.0.0 (11/04/2026): Criação inicial — SP-H1. Cobre breakpoints condicionais, watches, call stack, CPU View, FastMM4, EurekaLog/MadExcept, OutputDebugString, binary search debugging, defines `{$IFDEF DEBUG}`.

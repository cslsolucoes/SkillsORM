---
name: developer-delphi-to-fpc-performance-and-memory
description: Otimização de desempenho e gestão de memória cross-compiler (FastMM, HeapTrc/CMem, padrões preventivos).
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-performance-and-memory

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## Responsabilidade única

Esta skill cobre investigação e correção de problemas de desempenho e gestão de memória em projetos Delphi/FPC: ciclo de vida de objetos com `try..finally`, diagnósticos de leak com FastMM (Delphi) e HeapTrc/CMem (FPC), profiling antes de otimizar e revalidação após correção. Ela NÃO define domínio funcional, NÃO modifica contratos de interface e NÃO altera semântica de negócio — apenas corrige ciclo de vida de recursos e identifica gargalos de performance.

## When to use

- Investigação de lentidão, leaks, uso excessivo de recursos e tuning de performance.
- Habilitação de diagnósticos de memória por compilador (FastMM/HeapTrc).
- Revisão de ciclo de vida de objetos em módulos críticos.

## When NOT to use

- Não usar para definir domínio funcional ou contratos de interface → use `developer-delphi-to-fpc-architecture-and-design`.
- Não usar para diagnóstico de exceções em runtime → use `developer-delphi-to-fpc-error-handling-and-diagnostics`.
- Não usar para otimização de queries SQL (pertence ao domínio do banco) → referenciar documentação do módulo de banco.
- Não usar para configurar build/compilação → use `developer-delphi-to-fpc-build`.

## Inputs

- Métricas de performance, relatório de leak, contexto de execução.

## Workflow executável

1. Medir antes de otimizar.
2. Aplicar correções de ciclo de vida.
3. Habilitar diagnósticos por compilador.
4. Revalidar performance e leaks.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-to-fpc-build` | Build limpo é pré-requisito antes de habilitar diagnósticos de memória |
| `developer-delphi-testing-and-quality` | Gates de teste devem estar definidos para validar ausência de leaks no pipeline |

## Checklist Delphi+FPC

- [ ] Compilação sem hints/warnings em Delphi (dcc32 + dcc64)
- [ ] Compilação sem hints/warnings em FPC (fpc32 + fpc64)
- [ ] Memory management: Create/Free em try..finally; sem leaks (ReportMemoryLeaksOnShutdown)
- [ ] Tratamento de exceções: hierarquia do projeto (EProviderError ou equivalente)
- [ ] Nomenclatura: prefixos T/I/E/F/A conforme documentation-project-expert
- [ ] Diretivas {$IFDEF} conforme developer-delphi-programming-conditional-defines; sem mistura com paths
- [ ] Separação UI/lógica: zero SQL ou regras de negócio em event handlers
- [ ] Plano inclui validação cross-compiler
- [ ] Referências a compile.md e diretivas_compilacao.md verificadas quando aplicável
- [ ] `try..finally` para todos os objetos não gerenciados por interface.
- [ ] Estratégia FastMM (Delphi) e HeapTrc/CMem (FPC) documentada.
- [ ] Gate de detecção de leak no pipeline de CI.

## Exemplo mínimo compilável

**Delphi (dcc32 / dcc64):**

```pascal
program SampleMemoryDelphi;
{$APPTYPE CONSOLE}
uses Classes;
var
  S: TStringList;
begin
  S := TStringList.Create;
  try
    S.Add('OK -- developer-delphi-to-fpc-performance-and-memory');
    WriteLn(S[0]);
  finally
    S.Free;
  end;
end.
```

**Free Pascal (fpc32 / fpc64):**

```pascal
program SampleMemoryFPC;
{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}
uses Classes;
var
  S: TStringList;
begin
  S := TStringList.Create;
  try
    S.Add('OK -- developer-delphi-to-fpc-performance-and-memory');
    WriteLn(S[0]);
  finally
    S.Free;
  end;
end.
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|------------------|---------------|
| Criar objeto sem `try..finally` | Qualquer exceção antes do `Free` gera leak | Sempre usar `obj := T.Create; try ... finally obj.Free; end` |
| Otimizar sem medir antes | Otimização prematura; melhora o lugar errado | Usar profiler (AQTime, Sampling Profiler, HeapTrc) para identificar hot spots reais antes de alterar código |
| Desabilitar FastMM/HeapTrc em build de teste | Leaks passam despercebidos até produção | Habilitar `ReportMemoryLeaksOnShutdown := True` em todos os builds de teste |
| Reescrever algoritmo sem validar semântica | Otimização muda comportamento de negócio silenciosamente | Confirmar com usuário se a otimização pode alterar semântica; cobrir com testes antes |
| Usar interfaces só para memory management sem DI | Mistura responsabilidades; dificulta testes | Usar interfaces por contrato (DI); `TInterfacedObject` provê ref-count como efeito colateral, não como objetivo |

## Métricas de sucesso

- Zero leaks reportados pelo FastMM/HeapTrc após cada ciclo de correção.
- Todo objeto alocado manualmente tem `try..finally` com `Free` no bloco `finally`.
- Métrica de baseline de performance registrada antes e depois de qualquer otimização.
- Gate de leak integrado ao pipeline de CI (build falha se leak detectado).

## Responsável principal

| Papel | Quem |
|-------|------|
| Investigador de performance | Desenvolvedor responsável pelo módulo |
| Validador de leaks | CI/pipeline local com FastMM/HeapTrc habilitado |

## Avaliacao de risco e confirmacao

- Se a otimização alterar semântica de negócio ou contrato público, confirmar antes.

## Referencias

- RAD Studio docs (FastMM/leak detection)
- FPC docs (HeapTrc/CMem)
- `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md`

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `developer-delphi-performance-and-memory`; novo prefixo canônico `developer-delphi`. Conteúdo idêntico ao V1.1.0 de origem; cross-references atualizadas para prefixo `developer-delphi-*`.

---
name: developer-delphi-testing-and-quality
description: Estratégia de testes e qualidade para Delphi/FPC, incluindo gates de compilação e exemplos mínimos compiláveis.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-testing-and-quality

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## Responsabilidade única

Esta skill cobre a definição e execução de estratégias de teste (unitários, integração) e quality gates para projetos Delphi/FPC: matriz de testes por módulo, execução de build cross-compiler no pipeline, gates de falha versionados e critérios de aceite de qualidade. Ela NÃO faz troubleshooting profundo de exceções em runtime e NÃO define estratégia de performance — apenas garante que o código está coberto, validado e que os gates de qualidade estão definidos e funcionando.

## When to use

- Definir ou revisar testes unitários/integração e gates de qualidade.
- Configurar pipeline de CI com validação Delphi e FPC.
- Definir critérios de aceite para novos módulos ou features.

## When NOT to use

- Não usar para troubleshooting profundo de exceções em runtime → use `developer-delphi-to-fpc-error-handling-and-diagnostics`.
- Não usar para otimização de performance ou gestão de leaks → use `developer-delphi-to-fpc-performance-and-memory`.
- Não usar para execução de build isolada sem contexto de testes → use `developer-delphi-to-fpc-build`.
- Não usar para validar dados de produção ou ambientes críticos sem confirmação prévia.

## Inputs

- Escopo funcional, módulos e riscos.

## Workflow executável

1. Definir matriz de testes por módulo.
2. Executar build Delphi/FPC no pipeline.
3. Rodar testes unitários e integração.
4. Aplicar gates (build, testes críticos, leaks quando aplicável).

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-to-fpc-build` | Build limpo é pré-requisito antes de executar qualquer suite de testes |
| `developer-delphi-to-fpc-error-handling-and-diagnostics` | Exceções esperadas devem estar modeladas antes de escrever testes que as verificam |

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
- [ ] Testes executam em ambos compiladores ou possuem justificativa explícita.
- [ ] Gates de falha definidos e versionados.

## Exemplo mínimo compilável

**Delphi (dcc32 / dcc64):**

```pascal
program SampleTestDelphi;
{$APPTYPE CONSOLE}
begin
  if 1 + 1 <> 2 then
  begin
    WriteLn('FAIL -- developer-delphi-testing-and-quality');
    Halt(1);
  end;
  WriteLn('OK -- developer-delphi-testing-and-quality');
  Halt(0);
end.
```

**Free Pascal (fpc32 / fpc64):**

```pascal
program SampleTestFPC;
{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}
begin
  if 1 + 1 <> 2 then
  begin
    WriteLn('FAIL -- developer-delphi-testing-and-quality');
    Halt(1);
  end;
  WriteLn('OK -- developer-delphi-testing-and-quality');
  Halt(0);
end.
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|------------------|---------------|
| Testes apenas em Delphi, sem validação FPC | Divergências cross-compiler passam despercebidas até produção | Executar a mesma suite em fpc32 e fpc64; documentar exclusões com justificativa |
| Gates sem definição de critério de falha | Pipeline passa mesmo com testes quebrados | Definir explicitamente quais testes são bloqueantes (build não avança se falhar) |
| Testar com dados de produção sem isolamento | Risco de corrupção de dados; testes não reproduzíveis | Usar banco de teste isolado (`Data/test_*.db`) ou mocks de interface |
| Testes que dependem de ordem de execução | Falhas intermitentes difíceis de diagnosticar | Cada teste deve ser independente; setUp/tearDown por teste |
| Nenhum teste para caminho de erro | Apenas happy path coberto; exceções explodem em produção | Adicionar casos de teste para cada exceção documentada na hierarquia do projeto |

## Métricas de sucesso

- Suite de testes executa com exit code 0 em dcc32, dcc64, fpc32, fpc64.
- Gates de falha definidos e versionados no repositório.
- Cobertura de caminho de erro para todos os tipos de exceção documentados.
- Nenhum teste depende de ordem de execução ou de dados de produção.

## Responsável principal

| Papel | Quem |
|-------|------|
| Definidor de estratégia de testes | Desenvolvedor responsável pelo módulo |
| Executor do pipeline | CI/pipeline local (scripts de build + testes) |

## Avaliacao de risco e confirmacao

- Se a execução de testes demandar dados de produção/ambiente crítico, parar e confirmar antes.

## Referencias

- `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md`
- `.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md`
- RAD Studio docs (testing/build)
- FPC docs (compiler/test flags)

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `developer-delphi-testing-and-quality`; novo prefixo canônico `developer-delphi`. Conteúdo idêntico ao V1.1.0 de origem; cross-references atualizadas para prefixo `developer-delphi-*`.

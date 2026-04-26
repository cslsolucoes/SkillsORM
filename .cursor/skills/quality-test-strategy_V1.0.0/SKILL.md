---
name: quality-test-strategy
description: Define qual tipo de teste usar em qual camada — unitário, integração, aceite — para Delphi/FPC (DUnit, FPCUnit, TestInsight) e Web (Vitest, Jest, Playwright). Triggers - "estratégia de testes", "plano de testes", "cobertura de testes", "qual framework de teste", "como testar este módulo", "matriz de testes", "planejamento de testes".
model: sonnet
thinking: extended
category: quality
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# quality-test-strategy

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## Responsabilidade única

Esta skill define a estratégia de testes para o projeto — qual tipo de teste usar em qual camada (unitário, integração, aceite) e qual framework por tecnologia: DUnit/FPCUnit/TestInsight para Delphi/FPC; Vitest/Jest/Playwright para Web. Ela NÃO escreve os testes em si (use `developer-delphi-testing-and-quality` para testes Delphi ou `developer-web-testing-debugging` para testes Web); apenas define o plano e a matriz de cobertura.

## When to use

- Ao iniciar um módulo novo — definir o plano de testes antes de implementar.
- Ao revisar cobertura insuficiente em módulo existente.
- Ao onboarding de novo membro que precisa entender a estratégia do projeto.

## When NOT to use

- Para escrever testes Delphi/FPC → use `developer-delphi-testing-and-quality`.
- Para escrever testes Web (Vitest/Jest/Playwright) → use `developer-web-testing-debugging`.
- Para testes de aceite baseados em acceptance_criteria da SPEC → use `quality-acceptance-testing`.
- Para análise de regressão → use `quality-regression-guard`.

## Inputs

- SPEC do módulo ou feature (acceptance_criteria obrigatório).
- Inventário de camadas do módulo (interface pública, lógica interna, integração com DB/rede).

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `governance-spec-technical-writer` | A SPEC deve existir antes de definir o plano — ela contém os critérios de aceite que determinam o que testar |

## Workflow executável

1. **Ler a SPEC** — identificar módulo, camadas envolvidas, acceptance_criteria e riscos listados.
2. **Mapear camadas testáveis** — separar: lógica pura (unitário), integração com dependências externas (integração), comportamento do sistema do ponto de vista do usuário (aceite).
3. **Escolher framework por camada** — aplicar a matriz abaixo para selecionar o framework adequado a cada camada e tecnologia.
4. **Gerar plano de testes** — produzir tabela com: camada, tipo de teste, framework, caso de teste mínimo, critério de falha, responsável.

## Matriz de frameworks por camada

| Camada | Tipo | Delphi/FPC | Web |
|--------|------|------------|-----|
| Lógica pura / funções | Unitário | DUnit / FPCUnit | Vitest |
| Integração com DB | Integração | DUnit com banco de teste real | Jest + repositório mock |
| Pipeline cross-compiler | Build gate | TestInsight + dcc32/dcc64/fpc | N/A |
| Comportamento do usuário | Aceite | DUnit (script) | Playwright / Cypress |
| Performance crítica | Benchmark | Custom (Timer + assert) | Vitest bench |

## Regras de escolha de framework

- **DUnit** — padrão para testes Delphi; compatível com RAD Studio + CLI.
- **FPCUnit** — alternativa quando o target é exclusivamente FPC/Lazarus.
- **TestInsight** — para execução visual no IDE Delphi; não usar em CI (usar DUnit no CI).
- **Vitest** — padrão para unitários Web; mais rápido que Jest para projetos Vite.
- **Jest** — quando o projeto Web não usa Vite ou quando a suite existente já é Jest.
- **Playwright** — para testes E2E e aceite Web; preferir sobre Cypress para projetos novos.

## Checklist do plano de testes

- [ ] Cada acceptance_criterion da SPEC tem ao menos um caso de teste mapeado.
- [ ] Caminhada de erro (edge cases e exceções esperadas) está coberta.
- [ ] Banco de teste real e isolado definido para testes de integração (não mock de banco).
- [ ] Cada teste é independente — sem dependência de ordem de execução.
- [ ] Framework escolhido por camada documentado com justificativa.
- [ ] Cobertura mínima de 70% por módulo definida como gate de CI.
- [ ] Responsável por executar e manter cada suite definido.

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|------------------|---------------|
| Testar só happy path | Exceções e edge cases explodem em produção | Mapear explicitamente caminhos de erro na etapa 2 do workflow |
| Mock de banco de dados em testes de integração | Mock esconde comportamentos reais de transação, constraint e tipo | Usar banco real de teste isolado (`Data/test_*.db` ou schema de teste) |
| Testes frágeis dependentes de ordem | Falhas intermitentes; difíceis de diagnosticar em CI | Cada teste com setUp/tearDown independente; sem estado compartilhado entre testes |
| Definir estratégia sem ler a SPEC | Plano desalinhado com critérios de aceite reais | Sempre partir da SPEC; sem SPEC, criá-la primeiro com `governance-spec-technical-writer` |

## Métricas de sucesso

- Cobertura mínima de **70%** por módulo (medida por linhas/branches executados).
- Zero flaky tests — cada teste produz o mesmo resultado em execuções consecutivas sem alteração de código.
- 100% dos acceptance_criteria da SPEC com ao menos um caso de teste mapeado no plano.
- Plano documentado e revisado antes do início da implementação.

## Responsável principal

| Papel | Quem |
|-------|------|
| Definidor de estratégia | `dev-agent-backend` |
| Revisor do plano | Tech Lead / Arquiteto |

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Skill nova V2 — criada para lacuna quality no plano de migração V2.6.

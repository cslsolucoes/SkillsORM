---
name: quality-acceptance-testing
description: Transforma acceptance_criteria da SPEC em casos de teste executáveis — verifica que a implementação satisfaz os critérios de aceite do ponto de vista do usuário final. Triggers - "testes de aceite", "acceptance testing", "verificar critérios de aceite", "validar implementação contra SPEC", "casos de teste de aceite", "end of sprint testing".
model: sonnet
thinking: normal
category: quality
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# quality-acceptance-testing

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## Responsabilidade única

Esta skill transforma os `acceptance_criteria` da SPEC em casos de teste executáveis — scripts ou cenários que verificam o comportamento do sistema do ponto de vista do usuário final. Ela NÃO escreve testes unitários de função (use `developer-delphi-testing-and-quality`); NÃO define a estratégia geral de testes (use `quality-test-strategy`). Foca exclusivamente em confirmar que a implementação entregue satisfaz cada critério de aceite declarado na SPEC.

## When to use

- Ao final de sprint, antes da validação via `governance-spec-validator`.
- Ao entregar uma feature para revisão do usuário ou cliente.
- Para confirmar que um bugfix resolve o critério de aceite quebrado.

## When NOT to use

- Para testes unitários de funções e métodos → use `developer-delphi-testing-and-quality`.
- Para definir a estratégia e matriz de testes → use `quality-test-strategy`.
- Para análise de regressão em código existente → use `quality-regression-guard`.

## Inputs

- SPEC da feature com seção `acceptance_criteria` preenchida.
- Implementação a ser validada (branch ou release candidate).

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `governance-spec-technical-writer` | SPEC com acceptance_criteria deve existir e estar aprovada antes de escrever os casos de teste |
| `governance-spec-reviewer` | SPEC deve ter passado por revisão; critérios ambíguos devem estar resolvidos antes do teste |

## Workflow executável

1. **Ler acceptance_criteria da SPEC** — listar cada critério numerado; identificar pré-condições, ação e resultado esperado para cada um.
2. **Transformar em caso de teste** — para cada critério, criar: ID do caso (`AC-001`), descrição, pré-condições, passos de execução, resultado esperado e critério de aprovação (pass/fail).
3. **Executar os casos** — rodar cada caso de teste na implementação; registrar resultado real e comparar com resultado esperado.
4. **Reportar conformidade** — produzir relatório de conformidade: tabela `AC-ID | critério | resultado | status`; marcar como CONFORME (100% AC passando) ou NÃO CONFORME (listar ACs falhando).

## Checklist de aceite

- [ ] Cada `acceptance_criterion` da SPEC tem exatamente um caso de teste correspondente (AC-ID).
- [ ] Pré-condições de cada caso de teste estão documentadas e reproduzíveis.
- [ ] Casos cobrem tanto fluxo principal (happy path) quanto fluxos de erro declarados na SPEC.
- [ ] Testes foram executados na implementação real (não em mock ou ambiente simulado não equivalente).
- [ ] Resultado de cada caso registrado com evidência (log, screenshot ou saída de terminal).
- [ ] Relatório de conformidade gerado com status final CONFORME ou NÃO CONFORME.

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|------------------|---------------|
| Testar sem referência aos acceptance_criteria da SPEC | Teste valida o que foi implementado, não o que foi especificado — divergência silenciosa | Todo caso de teste deve ter ID de AC correspondente; sem AC, não há caso |
| Aceitar teste manual sem automação | Não reproduzível; próximo sprint pode regredir silenciosamente | Ao menos cenários críticos devem ter script executável; registrar pendências em TechDebt |
| Testar apenas happy path | Critérios de erro e edge cases da SPEC ficam sem cobertura | Mapear explicitamente cada AC; incluir ACs de comportamento em caso de erro |
| Rodar testes de aceite antes da SPEC ser revisada | Critérios ambíguos geram falsos positivos ou falsos negativos | Executar `governance-spec-reviewer` antes; resolver ambiguidades antes dos testes |

## Métricas de sucesso

- **100%** dos `acceptance_criteria` da SPEC com caso de teste correspondente.
- **100%** dos casos de teste executados com resultado registrado.
- Status final **CONFORME** para aprovação da entrega.
- Zero ACs validados apenas manualmente sem registro de evidência.

## Responsável principal

| Papel | Quem |
|-------|------|
| Executor de testes de aceite backend | `dev-agent-backend` |
| Executor de testes de aceite frontend | `dev-agent-vuejs-core-expert` |
| Aprovador da conformidade | Tech Lead / Product Owner |

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Skill nova V2 — criada para lacuna quality no plano de migração V2.6.

---
name: quality-refactoring-safe
description: Define e executa refatorações de código com segurança: avalia risco, escolhe estratégia (inline / strangler fig / branch-by-abstraction), garante cobertura de testes antes de alterar comportamento.
model: sonnet
thinking: extended
category: quality
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

## Responsabilidade única

Garantir que refatorações preservem comportamento externo enquanto melhoram estrutura interna — não tomar decisões de compatibilidade (use `governance-refactoring-compatibility-policy` primeiro).

## When to use

- Antes de iniciar qualquer refatoração não trivial (> 1 arquivo ou > 50 linhas).
- Quando o código está dificultando manutenção ou extensão.
- Quando há dívida técnica identificada pelo `quality-tech-debt-tracker`.

## When NOT to use

- Para decisões de backward compat / deprecação → use `governance-refactoring-compatibility-policy`.
- Para adicionar features durante refatoração → separe os commits.
- Para hotfix → use `quality-hotfix-workflow` (velocidade > estrutura nesse caso).

## Inputs obrigatórios

1. Escopo da refatoração (arquivos/módulos afetados).
2. Motivação clara (o que melhora e por quê).
3. Cobertura de testes atual (% ou "ausente").

## Dependências (skills prévias)

- `governance-refactoring-compatibility-policy` — decisão de estratégia A/B/C obrigatória antes.
- `quality-test-strategy` — se cobertura de testes for insuficiente.
- `quality-regression-guard` — configurar guardrails antes de alterar código crítico.

## Workflow executável

1. **Verificar cobertura:** se cobertura < 80% do escopo → criar testes primeiro (não refatorar sem rede de segurança).
2. **Escolher padrão de refatoração:**
   - *Inline* — para funções simples, sem callers externos.
   - *Strangler Fig* — para módulos grandes; criar novo ao lado, migrar gradualmente, remover antigo.
   - *Branch by Abstraction* — para dependências que precisam de interface temporária.
3. **Commits atômicos:** 1 commit por transformação semântica (rename, extract, move).
4. **Rodar testes após cada commit** — não agrupar múltiplas transformações sem validação.
5. **Code review** com foco em: comportamento preservado, sem feature creep.
6. **Registrar dívida resolvida** em `quality-tech-debt-tracker`.

## Outputs obrigatórios

- Código refatorado com testes passando.
- Commits atômicos com mensagens descritivas de cada transformação.
- Confirmação de que nenhuma interface pública foi alterada (ou que a política de compatibilidade foi aplicada).

## Checklist de validação

- [ ] Cobertura de testes >= 80% antes de iniciar.
- [ ] Estratégia de refatoração escolhida e documentada.
- [ ] Zero alterações de comportamento externo.
- [ ] Commits atômicos (uma transformação por commit).
- [ ] Testes passam após cada commit.
- [ ] Sem features ou correções misturadas na refatoração.
- [ ] `governance-refactoring-compatibility-policy` aplicada se interface pública foi tocada.

## Anti-padrões

- Refatorar e adicionar feature no mesmo PR — mistura responsabilidades, dificulta review.
- Começar refatoração sem testes — qualquer bug pré-existente passa a ser "culpa" da refatoração.
- Grandes commits de refatoração — impossível fazer bisect ou rollback parcial.
- Usar refatoração como desculpa para reescrever tudo do zero.

## Avaliação de risco

| Cenário | Risco | Mitigação |
|---------|-------|-----------|
| Ausência de testes | Alto | Criar testes antes de qualquer mudança |
| Interface pública alterada | Alto | Aplicar `governance-refactoring-compatibility-policy` |
| Refatoração em código crítico | Médio | Usar `quality-regression-guard` como guardrail |

## Métricas de sucesso

- Zero regressões introduzidas pela refatoração.
- Cobertura de testes igual ou maior que antes.
- Complexidade ciclomática reduzida nos arquivos refatorados.

## Responsável principal

`dev-agent-orchestrator` — seleciona o agente técnico da área para executar as transformações.

## Referências

- `governance-refactoring-compatibility-policy_V1.0.0/SKILL.md`
- `quality-test-strategy_V1.0.0/SKILL.md`
- `quality-regression-guard_V1.0.0/SKILL.md`
- `quality-tech-debt-tracker_V1.0.0/SKILL.md`

## Versão interna (ficheiro)

| Campo       | Valor |
|-------------|-------|
| FileVersion | 1.0.0 |

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Criação direta em V2 — Onda F.

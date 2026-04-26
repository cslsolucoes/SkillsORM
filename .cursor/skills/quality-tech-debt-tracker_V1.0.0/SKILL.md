---
name: quality-tech-debt-tracker
description: Registra, classifica e prioriza dívida técnica no backlog, vinculando cada item a seu custo de manutenção e ao caminho de resolução, para que dívida seja tratada explicitamente em vez de acumular silenciosamente.
model: haiku
thinking: normal
category: quality
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

## Responsabilidade única

Manter um inventário atualizado e priorizado de dívida técnica — não executar as refatorações (use `quality-refactoring-safe`) nem tomar decisões de compatibilidade (use `governance-refactoring-compatibility-policy`).

## When to use

- Quando um workaround ou solução temporária é implementada intencionalmente.
- Quando código existente é identificado como problemático mas não pode ser resolvido agora.
- Durante code review, quando problemas são encontrados fora do escopo do PR atual.
- Ao planejar sprints: priorizar itens de dívida para inclusão.

## When NOT to use

- Para bugs ativos → use `quality-bug-triage`.
- Para executar refatoração → use `quality-refactoring-safe`.
- Para decidir backward compat → use `governance-refactoring-compatibility-policy`.

## Inputs obrigatórios

1. Descrição do problema técnico.
2. Localização (arquivo/módulo/linha).
3. Impacto atual (manutenção, performance, segurança, escalabilidade).

## Dependências (skills prévias)

- Nenhuma — esta skill é ponto de entrada para registro de dívida.

## Workflow executável

1. **Registrar item:** descrição, localização, data de identificação, autor.
2. **Classificar tipo:**
   - *Arquitetural* — estrutura incorreta, acoplamento excessivo.
   - *Código* — duplicação, complexidade ciclomática alta, magic numbers.
   - *Testes* — cobertura insuficiente, testes frágeis.
   - *Documentação* — ausente ou desatualizada.
   - *Dependências* — bibliotecas desatualizadas, vulneráveis.
3. **Avaliar custo de carregamento** (quanto tempo por sprint essa dívida consome indiretamente).
4. **Priorizar:** Alto (bloqueia evolução) / Médio (aumenta custo) / Baixo (cosmético).
5. **Definir caminho de resolução:** skill/agente responsável, estimativa de esforço.
6. **Revisar backlog mensalmente** — remover itens resolvidos, re-priorizar restantes.

## Outputs obrigatórios

- Item registrado no backlog de dívida técnica com: tipo, prioridade, localização, custo de carregamento, caminho de resolução.
- Tag `// TODO(tech-debt):` ou equivalente no código (opcional mas recomendado).

## Checklist de validação

- [ ] Tipo de dívida classificado.
- [ ] Localização exata documentada.
- [ ] Prioridade (Alto/Médio/Baixo) atribuída com justificativa.
- [ ] Caminho de resolução definido (skill/agente + esforço estimado).
- [ ] Item adicionado ao backlog e visível ao time.

## Anti-padrões

- Registrar dívida sem localização — impossível resolver depois.
- Nunca revisar o backlog — itens ficam obsoletos ou são esquecidos.
- Tratar toda dívida como baixa prioridade — priorização sem critério.
- Usar tracker como desculpa para não resolver dívidas críticas.

## Avaliação de risco

| Cenário | Risco | Mitigação |
|---------|-------|-----------|
| Dívida arquitetural não rastreada | Alto | Revisões mensais do backlog |
| Acumulação ilimitada | Médio | Regra: cada sprint reserva X% para dívida técnica |

## Métricas de sucesso

- Backlog de dívida visível e revisado mensalmente.
- Ratio dívida/features novas estável ou decrescente por sprint.
- Itens Alto resolvidos em <= 2 sprints após registro.

## Responsável principal

`dev-agent-orchestrator` — coordena com agentes técnicos para resolução dos itens de maior prioridade.

## Referências

- `quality-refactoring-safe_V1.0.0/SKILL.md`
- `governance-refactoring-compatibility-policy_V1.0.0/SKILL.md`
- `quality-code-review-checklist_V1.0.0/SKILL.md`

## Versão interna (ficheiro)

| Campo       | Valor |
|-------------|-------|
| FileVersion | 1.0.0 |

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Criação direta em V2 — Onda F.

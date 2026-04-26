---
name: quality-bug-triage
description: Classifica, prioriza e encaminha bugs reportados segundo severidade, impacto e área, produzindo um ticket estruturado com contexto suficiente para resolução imediata.
model: sonnet
thinking: normal
category: quality
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

## Responsabilidade única

Transformar um reporte de bug bruto em um ticket estruturado com severidade, impacto, passos de reprodução e área responsável — não corrigir o bug (use o agente da área técnica).

## When to use

- Ao receber um bug report informal (chat, e-mail, log de erro).
- Antes de atribuir um bug a um desenvolvedor.
- Quando há acumulação de bugs sem priorização clara.

## When NOT to use

- Para corrigir bugs → use o agente técnico da área (`dev-agent-*`).
- Para regressão após fix → use `quality-regression-guard`.
- Para rastrear dívida técnica → use `quality-tech-debt-tracker`.

## Inputs obrigatórios

1. Descrição do comportamento observado vs. esperado.
2. Passos para reproduzir (ou logs disponíveis).
3. Versão/ambiente afetado.

## Dependências (skills prévias)

- Nenhuma obrigatória — esta skill é ponto de entrada.

## Workflow executável

1. **Coletar contexto:** título, descrição, ambiente, frequência.
2. **Classificar severidade:**
   - S1 — Bloqueante (sistema inoperante, perda de dados).
   - S2 — Crítico (funcionalidade principal quebrada, sem workaround).
   - S3 — Moderado (funcionalidade parcialmente afetada, workaround existe).
   - S4 — Menor (cosmético, edge case).
3. **Identificar área:** módulo, camada, componente responsável.
4. **Estimar impacto:** % de usuários afetados, frequência de ocorrência.
5. **Gerar ticket estruturado** com todos os campos acima.
6. **Encaminhar** ao responsável da área ou enfileirar conforme prioridade.

## Outputs obrigatórios

- Ticket de bug com: título, severidade (S1–S4), passos de reprodução, ambiente, área responsável, impacto estimado.
- Prioridade sugerida: imediata / próximo sprint / backlog.

## Checklist de validação

- [ ] Severidade classificada (S1–S4) com justificativa.
- [ ] Passos de reprodução claros e verificáveis.
- [ ] Área responsável identificada.
- [ ] Impacto estimado documentado.
- [ ] Ticket encaminhado ou enfileirado.

## Anti-padrões

- Atribuir todos os bugs como S1 — dilui a priorização.
- Tickets sem passos de reprodução — bloqueiam a resolução.
- Triage sem identificar área — cria ping-pong entre times.

## Avaliação de risco

| Cenário | Risco | Mitigação |
|---------|-------|-----------|
| Bug S1 não priorizado | Alto | Alerta imediato ao responsável técnico |
| Ticket duplicado | Baixo | Verificar backlog antes de criar novo ticket |

## Métricas de sucesso

- 100% dos bugs recebem classificação de severidade.
- Tickets com passos de reprodução verificáveis ≥ 90%.
- Tempo médio de triage < 15 minutos.

## Responsável principal

`dev-agent-orchestrator` — escala ao agente técnico da área conforme área identificada.

## Referências

- `quality-regression-guard_V1.0.0/SKILL.md`
- `quality-hotfix-workflow_V1.0.0/SKILL.md`
- `quality-tech-debt-tracker_V1.0.0/SKILL.md`

## Versão interna (ficheiro)

| Campo       | Valor |
|-------------|-------|
| FileVersion | 1.0.0 |

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Criação direta em V2 — Onda F.

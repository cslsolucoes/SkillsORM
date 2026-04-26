---
name: governance-incident-response
description: Resposta a incidente em produção — processo estruturado para classificar severidade (P0-P3), isolar impacto, identificar root cause, aplicar fix ou rollback, comunicar status e escrever post-mortem com lições aprendidas.
model: sonnet
thinking: extended
category: governance-process
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Governance Process — Incident Response

## Responsabilidade única

Conduzir o processo de resposta a incidentes em produção de forma estruturada e rastreável:
classificar a severidade (P0/P1/P2/P3), isolar o impacto, identificar a root cause, aplicar
fix ou rollback, comunicar status à equipe e escrever post-mortem com lições aprendidas e medidas
preventivas. Esta skill **não** trata bugs em desenvolvimento (→ `quality-bug-triage`) nem hotfix
planejado fora de incidente ativo (→ `quality-hotfix-workflow`).

## When to use

- Ao detectar comportamento inesperado em produção que afeta usuários ou sistemas dependentes.
- Ao receber reporte de usuário crítico sobre falha na biblioteca.
- Quando o sistema de monitoramento emitir alerta de comportamento anômalo em produção.

## When NOT to use

- Para bug encontrado em desenvolvimento ou ambiente de teste → usar `quality-bug-triage`.
- Para hotfix planejado que não é incidente ativo → usar `quality-hotfix-workflow`.
- Para mudança preventiva baseada em análise de risco → usar `governance-change-request`.

## Inputs obrigatórios

| Input | Tipo | Descrição |
|-------|------|-----------|
| Descrição do sintoma | Texto livre | O que está acontecendo e como foi detectado |
| Ambiente afetado | Texto | Versão do Providers.2.1.0, engine de banco, plataforma |
| Momento de detecção | Data/hora | Quando o incidente foi detectado |
| Impacto observado | Texto | Quais funcionalidades, quantos usuários, operações afetadas |

## Dependências (skills prévias)

| Skill | Motivo |
|-------|--------|
| `quality-bug-triage_V1.0.0` | Triagem técnica do bug identificado como root cause |
| `quality-hotfix-workflow_V1.0.0` | Implementar e publicar o fix após diagnóstico |

## Workflow executável

1. **Detectar e registrar** — criar registro de incidente com ID (INC-YYYY-NNN), data/hora de
   detecção, quem detectou, descrição do sintoma, ambiente afetado e impacto observado inicial.
   Notificar imediatamente o Tech Lead.

2. **Classificar severidade** — determinar prioridade com critério objetivo:
   - *P0 (crítico)*: sistema completamente inoperante para todos os usuários; perda de dados
   - *P1 (alto)*: funcionalidade crítica indisponível para maioria dos usuários; workaround inexistente
   - *P2 (médio)*: funcionalidade degradada; workaround existe mas é custoso
   - *P3 (baixo)*: comportamento incorreto em caso de uso não crítico; workaround simples disponível
   - P0 e P1 requerem escalação humana imediata.

3. **Isolar o impacto** — determinar o perímetro exato: quais módulos, engines, plataformas e
   versões são afetados; quais não são afetados (isso delimita o escopo do fix e do workaround).

4. **Investigar root cause** — analisar logs, stack traces, condições de reprodução; formular
   hipóteses e validar com evidências; invocar `quality-bug-triage` para triagem técnica aprofundada;
   não fechar a investigação com hipótese — exigir evidência confirmada.

5. **Corrigir ou executar rollback** — com root cause confirmado:
   - Se fix rápido for viável: implementar via `quality-hotfix-workflow`, testar em ambiente isolado,
     publicar com aprovação humana.
   - Se fix não for seguro: executar rollback para última versão estável conforme plano documentado
     em `governance-release-management`.
   Comunicar status a cada etapa.

6. **Escrever post-mortem** — documentar em até 24h: linha do tempo do incidente, root cause
   confirmado, impacto quantificado, ações de mitigação tomadas, lições aprendidas e medidas
   preventivas com responsável e prazo. Post-mortem não é atribuição de culpa — é aprendizado.

## Outputs obrigatórios

| Output | Localização | Formato |
|--------|-------------|---------|
| Registro de incidente | `Documentation/Incidents/INC-YYYY-NNN.md` | Markdown estruturado |
| Post-mortem | `Documentation/Incidents/INC-YYYY-NNN-postmortem.md` | Markdown estruturado |

### Estrutura obrigatória do post-mortem

```markdown
# Post-Mortem — INC-YYYY-NNN

## Resumo
<2-3 linhas descrevendo o incidente e o impacto total>

## Linha do tempo
| Hora | Evento |
|------|--------|
| ...  | ...    |

## Root cause
<Explicação técnica da causa raiz confirmada com evidências>

## Impacto quantificado
- Duração: <X horas/minutos>
- Funcionalidades afetadas: <lista>
- Usuários/sistemas impactados: <estimativa>

## Ações tomadas
- Fix/rollback aplicado: <descrição>
- Validação pós-fix: <como foi verificado>

## Lições aprendidas
- <Lição 1>
- <Lição N>

## Medidas preventivas
| Medida | Responsável | Prazo |
|--------|-------------|-------|
| ...    | ...         | ...   |
```

## Checklist de validação

- [ ] ID de incidente atribuído (INC-YYYY-NNN)
- [ ] Severidade classificada com critério objetivo (P0/P1/P2/P3)
- [ ] Tech Lead notificado (obrigatório para P0/P1)
- [ ] Perímetro de impacto isolado
- [ ] Root cause investigado com evidência confirmada (não hipótese)
- [ ] Fix ou rollback aplicado com aprovação humana
- [ ] Post-mortem escrito em até 24h após resolução
- [ ] Medidas preventivas com responsável e prazo registradas

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Corrigir sem identificar root cause | O incidente volta a ocorrer; falsa sensação de segurança | Executar passo 4 completo antes de qualquer fix |
| Não escrever post-mortem | Lições perdidas; mesmos erros se repetem | Post-mortem em até 24h é obrigatório para todo incidente |
| Classificar P0 sem critério objetivo | Prioridade inflada gera fadiga e desconfiança | Usar tabela de critérios do passo 2 sem exceção |
| Post-mortem como atribuição de culpa | Inibe reporte honesto de problemas futuros | Focar em processo e prevenção, nunca em pessoas |
| Fechar incidente sem medida preventiva | Root cause pode se repetir | Toda lição deve ter medida preventiva com responsável e prazo |

## Avaliação de risco

- **Parar e confirmar quando:** classificar como P0 ou P1 — escalação humana imediata antes de
  qualquer ação técnica.
- **Parar e confirmar quando:** rollback for necessário — aprovação humana obrigatória antes de
  executar rollback em produção.
- **Risco baixo (P3):** agent pode conduzir investigação e propor fix sem escalação imediata,
  mas aprovação humana é necessária antes de publicar.

## Métricas de sucesso

- Post-mortem documentado em até 24h após resolução do incidente.
- Root cause identificado e confirmado com evidência em 100% dos incidentes.
- Medida preventiva registrada com responsável e prazo para todo incidente P0/P1/P2.
- Zero incidentes com a mesma root cause repetida (medidas preventivas efetivas).

## Responsável principal

| Papel | Quem |
|-------|------|
| Agent executor | `dev-agent-orchestrator` |
| Escalação obrigatória | Humano (Tech Lead) para P0/P1 |
| Aprovação para fix/rollback | Humano (Tech Lead) |

## Referências

- Triagem de bug: `quality-bug-triage_V1.0.0`
- Hotfix: `quality-hotfix-workflow_V1.0.0`
- Rollback: `governance-release-management_V1.0.0`
- Pasta de saída: `Documentation/Incidents/`
- Política de documentação: `.cursor/skills/documentation-general_rules_V2.0.0/SKILL.md`

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.0.0 (09/04/2026): Skill nova V2 — criada para lacuna governance no plano de migração V2.6.

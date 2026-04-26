---
name: governance-change-request
description: Gestão de solicitação de mudança com análise de impacto — processa qualquer pedido de alteração em módulo existente do Providers.2.1.0 de forma estruturada, classificando, avaliando impacto e obtendo aprovação antes de implementar.
model: sonnet
thinking: extended
category: governance-process
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Governance Process — Change Request

## Responsabilidade única

Processar solicitação de mudança de forma estruturada: registrar quem pediu, o quê e por quê;
classificar o tipo (correção, preventiva, corretiva ou evolução); avaliar impacto em escopo, prazo,
qualidade e riscos; verificar breaking change; obter aprovação humana; implementar; atualizar SPEC.
Esta skill **não** trata bugs urgentes em produção (→ `quality-hotfix-workflow`) nem features novas
sem código existente (→ `governance-spec-prd-generator`).

## When to use

- Ao receber qualquer pedido de mudança em módulo existente do Providers.2.1.0.
- Quando um requisito aprovado precisar ser alterado após o início da implementação.
- Quando a mudança puder impactar API pública, interfaces ou comportamento observável.
- Antes de refatorar código existente com alteração de contrato.

## When NOT to use

- Para bug urgente em produção → usar `quality-hotfix-workflow`.
- Para feature nova sem código existente → usar `governance-spec-prd-generator`.
- Para atualizar SPEC como documento vivo sem solicitação formal → usar `governance-spec-evolution`.
- Para revisar SPEC já existente → usar `governance-spec-reviewer`.

## Inputs obrigatórios

| Input | Tipo | Descrição |
|-------|------|-----------|
| Solicitante | Texto | Nome ou papel de quem solicita a mudança |
| Descrição da mudança | Texto livre | O que deve mudar e por quê |
| Módulo/arquivo afetado | Texto | Identificador do artefato alvo da mudança |

## Dependências (skills prévias)

| Skill | Motivo |
|-------|--------|
| `governance-spec-evolution_V1.0.0` | Atualizar SPEC após aprovação e implementação |

## Workflow executável

1. **Registrar a solicitação** — documentar: solicitante, data, descrição da mudança, módulo afetado,
   motivação (por que a mudança é necessária). Atribuir um ID sequencial (CR-YYYY-NNN).

2. **Classificar o tipo** — determinar a categoria da mudança:
   - *Correção*: elimina comportamento incorreto sem alterar especificação
   - *Preventiva*: melhora qualidade/manutenibilidade sem alterar comportamento externo
   - *Corretiva*: ajusta especificação para refletir realidade do negócio
   - *Evolução*: adiciona novo comportamento a módulo existente

3. **Avaliar impacto** — analisar dimensões:
   - Escopo: quais outros módulos, interfaces ou documentos são afetados
   - Prazo: estimativa de esforço e risco de atraso no plano vigente
   - Qualidade: risco de regressão, necessidade de novos testes
   - Riscos: dependências externas, possibilidade de breaking change

4. **Verificar breaking change** — inspecionar se a mudança altera API pública, contratos de
   interface (`I*`), assinaturas de métodos públicos ou comportamento documentado. Se sim, invocar
   `version-breaking-change-guard` antes de prosseguir.

5. **Obter aprovação humana** — apresentar resumo de impacto e aguardar confirmação explícita do
   responsável humano (Tech Lead ou Product Owner). Não implementar sem aprovação registrada.

6. **Implementar a mudança** — executar a alteração no código seguindo os padrões do projeto
   (interfaces `I*`, implementações `T*`, factory `New`, estilo fluente). Registrar o ID da
   solicitação no commit.

7. **Atualizar SPEC** — invocar `governance-spec-evolution` para refletir a mudança no documento
   de especificação técnica correspondente. Registrar referência cruzada entre CR e SPEC.

## Outputs obrigatórios

| Output | Localização | Formato |
|--------|-------------|---------|
| Registro de change request | `Documentation/ChangeRequests/CR-YYYY-NNN.md` | Markdown estruturado |
| SPEC atualizada | `Documentation/SPEC/<módulo>.SPEC.md` | Via `governance-spec-evolution` |

## Checklist de validação

- [ ] ID de change request atribuído (CR-YYYY-NNN)
- [ ] Solicitante, data e motivação registrados
- [ ] Tipo de mudança classificado (correção/preventiva/corretiva/evolução)
- [ ] Impacto avaliado nas 4 dimensões (escopo, prazo, qualidade, riscos)
- [ ] Breaking change verificado — se sim, `version-breaking-change-guard` invocado
- [ ] Aprovação humana obtida e registrada antes de implementar
- [ ] Implementação com referência ao ID da CR no commit
- [ ] SPEC atualizada via `governance-spec-evolution`

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Implementar mudança sem análise de impacto | Provoca regressões silenciosas em módulos dependentes | Executar passo 3 antes de qualquer código |
| Aprovar sem verificar breaking change | Quebra clientes que dependem da API pública | Executar passo 4 sempre, mesmo para mudanças "pequenas" |
| Não atualizar SPEC após implementação | SPEC diverge do código real, documentação fica desatualizada | Invocar `governance-spec-evolution` como último passo obrigatório |
| Múltiplas mudanças no mesmo CR | Dificulta rastreabilidade e rollback seletivo | Um CR por mudança lógica independente |
| Registrar aprovação sem identificar o aprovador | Impossível rastrear responsabilidade da decisão | Incluir nome e papel do aprovador no registro |

## Avaliação de risco

- **Parar e confirmar quando:** a mudança alterar interface pública ou comportamento documentado —
  apresentar análise de impacto completa antes de qualquer implementação.
- **Risco baixo:** mudança interna sem alteração de API — aprovação pode ser obtida na mesma sessão.
- **Risco médio:** mudança que afeta módulo compartilhado (Commons, Main) — verificar todos os
  consumidores antes de implementar.
- **Risco alto:** mudança que introduz breaking change — obrigatoriamente invocar
  `version-breaking-change-guard` e planejar período de deprecação.

## Métricas de sucesso

- Toda mudança com análise de impacto documentada nas 4 dimensões.
- Aprovação humana registrada antes de implementar — zero exceções.
- 100% das CRs implementadas com SPEC atualizada via `governance-spec-evolution`.
- Zero breaking changes não sinalizados.

## Responsável principal

| Papel | Quem |
|-------|------|
| Agent executor | `dev-agent-orchestrator` |
| Aprovação obrigatória | Humano (Tech Lead / Product Owner) |

## Referências

- Skill de breaking change: `version-breaking-change-guard_V1.0.0`
- Atualização de SPEC: `governance-spec-evolution_V1.0.0`
- Hotfix urgente: `quality-hotfix-workflow_V1.0.0`
- Nova feature: `governance-spec-prd-generator_V1.0.0`
- Política de documentação: `.cursor/skills/documentation-general_rules_V2.0.0/SKILL.md`

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.0.0 (09/04/2026): Skill nova V2 — criada para lacuna governance no plano de migração V2.6.

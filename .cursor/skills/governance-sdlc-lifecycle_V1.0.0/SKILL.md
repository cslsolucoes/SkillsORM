---
name: governance-sdlc-lifecycle
description: >-
  Padroniza artefatos de documentacao ao longo do ciclo de vida de software
  (SDLC): tabela de fase x artefato (Planejamento→Operacao), estrategia de
  testes e matriz RN→teste, runbooks de deploy/rollback, seguranca e compliance
  (LGPD, classificacao de docs), e checklists consolidados de release/SDLC/RN.
model: sonnet
thinking: extended
category: governance-process
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Governance — SDLC lifecycle (fase × artefato, testes, operacao, seguranca)

## Responsabilidade única

Esta skill padroniza os artefatos de documentação ao longo de todo o ciclo de vida de software — desde Planejamento até Operação. Ela define quais artefatos devem existir em cada fase (tabela fase×artefato), como estruturar estratégia de testes, runbooks de deploy/rollback e controles de segurança/compliance. Existe separada das demais skills documentais porque foca no **ciclo de vida completo como um todo**, não em artefatos individuais.

## When to use

- Ao planejar ou revisar releases: garantir que todos os artefatos do ciclo estejam presentes.
- Ao escrever runbooks de deploy/rollback para ambientes de produção.
- Ao montar matriz de rastreabilidade RN → caso de teste.
- Ao revisar completude documental frente ao SDLC (auditoria de qualidade).
- Ao incorporar requisitos de segurança/compliance (LGPD, classificação de dados) na documentação.

## When NOT to use

- Para criar/editar regras de negócio específicas → usar `documentation-business-rules`
- Para scaffold de pasta `Analise/` ou `{ClassName}.md` → usar `documentation-paste_analysis_unit_class_method`
- Para escanear lacunas de documentação por feature → usar `documentation-project-feature`
- Para gerar portal HTML estático → usar `documentation-portal-html`
- Para decisões de arquitetura (ADRs) → usar `documentation-architecture`

## Inputs obrigatórios

| Input | Tipo | Descrição |
|-------|------|-----------|
| Contexto do projeto | texto | Fase atual do ciclo, stack, módulos envolvidos |
| Documentação existente | path | `Documentation/`, `Analise/` — lidos como evidência |
| Requisito de compliance | texto (opcional) | LGPD, classificação de dados, requisitos de auditoria |

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `documentation-project-scan` | Recomendado para ter inventário base antes de auditar o ciclo |

---

## 1. Mapa: fases do ciclo de vida × artefatos

| Fase | Objetivo | Artefatos tipicos (Markdown preferencial) |
|------|----------|-------------------------------------------|
| **Planejamento** | Alinhar escopo, riscos, cronograma | Visao do produto, roadmap, restricoes, stakeholders |
| **Requisitos** | O que o sistema deve fazer | Epicos, RF/RNF, criterios de aceite, glossario, **RNs** |
| **Analise** | Entender dominio e impactos | Modelo de dominio, casos de uso, mapa de integracoes |
| **Arquitetura** | Decisoes estruturais estaveis | Documento de arquitetura, diagramas (C4, sequencia), **ADRs** |
| **Design** | Detalhar interfaces e persistencia | Contratos de API (OpenAPI), modelo logico/fisico |
| **Implementacao** | Codificar com rastreio | Padroes em `CONTRIBUTING`/guia do time |
| **Testes** | Verificar e validar | Plano/estrategia de testes, matriz **RN → caso de teste** |
| **Implantacao** | Entregar em producao | Runbook de deploy, checklist de release |
| **Operacao** | Manter e evoluir | Monitoramento, SLO/SLA, procedimentos de incidente |

**Principio:** se um artefato nao existe, registar **explicitamente** no README hub como «nao aplicavel» ou «pendente».

---

## 2. Estrategia de testes e qualidade

- **Piramide:** unitario, integracao, E2E; indicar o que e manual.
- **Matriz RN/RF → ID de teste** (ou tag no framework de testes).
- **Definicao de «pronto»:** testes passando + documentacao do hub atualizada.

---

## 3. Implantacao e operacao

- **Runbook:** pre-requisitos, passos, rollback, verificacao pos-deploy.
- **Configuracao:** variaveis por ambiente; **nunca** commitar segredos.
- **DR/backup:** o que e copiado, frequencia, retencao, teste de restauracao.

---

## 4. Seguranca, privacidade e compliance

- **Classificacao** do documento (interno, confidencial).
- **Dados pessoais:** base legal, retencao, titular — quando aplicavel.
- **Integracoes e legado:** modo **somente leitura** ou escopo explicito de escrita.
- **Dependencias e vulnerabilidades:** processo de atualizacao.

---

## 5. Checklists consolidados

**Qualquer alteracao em documentacao (antes de dar como concluida)**

- [ ] Analise de impacto: **todos** os ficheiros afetados identificados
- [ ] Links, hub, indices e stubs atualizados quando aplicavel
- [ ] Versao no nome/cabecalho coerentes se houve delta normativo

**Release**

- [ ] Versao documentada no hub
- [ ] Runbook revisado
- [ ] Riscos e rollback descritos
- [ ] Matriz de testes criticos atualizada

**Conformidade SDLC (revisao rapida)**

- [ ] Existe visao de planejamento ou justificativa de MVP
- [ ] Requisitos/RNs com IDs estaveis
- [ ] Arquitetura + ADRs para decisoes nao obvias
- [ ] Rastreio ate testes
- [ ] Operacao (deploy, monitoramento, backup) descrita ou marcada N/A

---

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Usar esta skill para criar artefatos individuais (RNs, ADRs) | Fora do escopo — duplica domínio de outras skills | Redirecionar para `documentation-business-rules` ou `documentation-architecture` |
| Pular a fase de Requisitos no mapa SDLC | Gera artefatos sem rastreabilidade para negócio | Registrar explicitamente "não aplicável" no README hub |
| Commitar segredos no runbook de deploy | Viola compliance e cria vetor de ataque | Referenciar cofre/secret manager por nome, nunca o valor real |

## Avaliação de risco

- **Parar e confirmar quando:** o runbook de deploy envolver banco de dados de produção sem rollback descrito.
- **Risco alto:** omitir fase inteira do SDLC sem registro explícito de "N/A".
- **Risco baixo:** revisar checklists em projeto com documentação já estruturada.

## Métricas de sucesso

- Todas as fases do ciclo (Planejamento → Operação) têm pelo menos 1 artefato listado ou marcado como "N/A"
- Matriz RN → caso de teste preenchida com IDs rastreáveis

## Responsável principal

| Papel | Quem |
|-------|------|
| Agent executor | `doc-agent-orchestrator` |
| Revisão humana | Tech Lead / Arquiteto de Software |
| Aprovação final | Product Owner (para critérios de aceite) |

## Referências

- Skill de artefatos documental: `documentation-general_rules`
- Skill de regras de negócio: `documentation-business-rules`
- Skill de arquitetura: `documentation-architecture`

## Versao interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Politica** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `documentation-sdlc-lifecycle`; novo prefixo canônico `governance`. Conteúdo V2 preservado (FileVersion 1.1.0 da origem).

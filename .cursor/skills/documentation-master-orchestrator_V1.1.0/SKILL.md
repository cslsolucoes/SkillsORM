---
name: documentation-master-orchestrator
description: Ponto de entrada para todos os workflows de documentação — bootstrap, design OOP inicial, análise de código, conteúdo canónico, portais, manutenção e migração. Complementa o documentation-agent-orchestrator na camada de skills (25 skills da família documentation-*).
model: sonnet
thinking: minimal
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation Master Orchestrator

## Responsabilidade única

Ponto de entrada único para qualquer tarefa de documentação do projeto: inicializar a estrutura `Documentation/`, definir design OOP antes de documentar, analisar e documentar classes/unidades, gerar conteúdo canónico (RN, arquitetura, feature), criar portais e índices, e manter a documentação atualizada. Esta skill não executa diretamente — seleciona a skill especialista correta da família `documentation-*` e define a sequência de execução.

**Distinção importante:** Esta skill-orquestradora é a referência de sequência para humanos e agentes. O `documentation-agent-orchestrator` é o agente que executa e delega com memória de contexto — são camadas distintas e complementares.

## When to use

- "documentar", "documentação", "doc", "analisar classe", "RN", "regra de negócio", "arquitetura", "portal", "hub", "migrar docs", "CHANGELOG", "wireframe", "OpenAPI", "README"
- Ao iniciar um projeto sem estrutura `Documentation/` e sem código-fonte existente
- Ao adicionar nova feature que precisa ser documentada
- Ao analisar código existente para gerar documentação

## When NOT to use

- Para governança de processo → `governance-master-orchestrator`
- Para versionamento SemVer → `version-master-orchestrator`
- Para QA e code review → `quality-master-orchestrator`
- Para implementação técnica de código → `developer-delphi-master-orchestrator`

## Skills coordenadas (25)

### NÍVEL 0 — Bootstrap

| Skill | Responsabilidade | Quando invocar |
|-------|-----------------|----------------|
| `documentation-oop-first` | Design OOP antes de qualquer doc em projeto sem código | Ao iniciar inception documental de projeto novo sem código-fonte |
| `documentation-project-bootstrap` | Inicializar estrutura `Documentation/` | Ao criar projeto ou ao bootstrapar docs |
| `documentation-general_rules` | Normas transversais de documentação | Como referência normativa |

### NÍVEL 1 — Estrutura

| Skill | Responsabilidade | Quando invocar |
|-------|-----------------|----------------|
| `documentation-project-fundamentals-template` | Template de fundamentos do projeto | Ao criar seção de fundamentos |
| `documentation-project-structure-template` | Template de estrutura do repositório | Ao documentar estrutura de pastas/arquivos |
| `documentation-project-roadmap-template` | Template de roadmap do projeto | Ao criar ou atualizar roadmap |
| `documentation-project-examples-template` | Template de exemplos de uso | Ao documentar exemplos práticos |

### NÍVEL 2 — Análise de Código

| Skill | Responsabilidade | Quando invocar |
|-------|-----------------|----------------|
| `documentation-paste_analysis_unit_class_method` | Scaffold `Analise/{ClassName}.md` a partir de código colado | Ao analisar unidades/classes específicas |
| `documentation-class-analysis-generator` | Preencher `{ClassName}.md` completo | Após scaffold de análise |

### NÍVEL 3 — Conteúdo Canónico

| Skill | Responsabilidade | Quando invocar |
|-------|-----------------|----------------|
| `documentation-project-feature` | Documentar feature: gaps, RN, semântica | Ao fechar nova feature |
| `documentation-business-rules` | Documentar regras de negócio (formato padrão) | Ao identificar ou formalizar RN |
| `documentation-architecture` | Criar/atualizar `Documentation/Arquitetura/` | Ao documentar arquitetura do sistema |
| `documentation-overview-architecture` | Modelo de qualidade Overview de arquitetura | Como referência de qualidade de docs |
| `documentation-project-scan` | Inventariar docs existentes + identificar gaps | Ao auditar documentação |

### NÍVEL 4 — Portais e Índices

| Skill | Responsabilidade | Quando invocar |
|-------|-----------------|----------------|
| `documentation-readme-hub` | Gerar hub `README.md` de documentação | Ao criar ou atualizar o hub de docs |
| `documentation-analysis-index` | Gerar índice `Analise/` | Ao indexar análises de classes |
| `documentation-roadmap-from-docs` | Gerar roadmap a partir da árvore `Documentation/` | Ao extrair roadmap do estado atual |
| `documentation-portal-html` | Gerar portal HTML estático | Ao criar portal navegável de docs |
| `documentation-screen-sketches` | Gerar wireframes/sketches de telas | Ao documentar UI/UX |

### NÍVEL 5 — Manutenção

| Skill | Responsabilidade | Quando invocar |
|-------|-----------------|----------------|
| `documentation-migration-backup` | Migrar docs com backup | Ao reorganizar estrutura de docs |
| `documentation-migration-plan` | Planejar migração de docs | Antes de migração significativa |
| `documentation-rules_creator` | Gerar `.cursor/rules/` a partir de docs | Ao codificar normas como rules |
| `documentation-versioning-changelog` | Gerenciar changelog de documentação | Ao versionar mudanças de docs |
| `documentation-api-openapi` | Gerar/atualizar spec OpenAPI | Ao documentar APIs REST |
| `documentation-project-update` | Atualização incremental de docs existentes | Ao atualizar docs após mudança de código |

## Sequências canônicas

```
NOVO PROJETO SEM CÓDIGO:
  documentation-oop-first → documentation-project-bootstrap →
  documentation-project-fundamentals-template → documentation-readme-hub

NOVO PROJETO (com código existente):
  documentation-project-bootstrap → documentation-project-fundamentals-template →
  documentation-project-structure-template → documentation-readme-hub

ANÁLISE DE CÓDIGO:
  documentation-paste_analysis_unit_class_method → documentation-class-analysis-generator →
  documentation-analysis-index

NOVA FEATURE:
  documentation-project-feature → documentation-business-rules (se houver RN) →
  documentation-project-update

AUDITORIA DE DOCS:
  documentation-project-scan → documentation-migration-plan → documentation-migration-backup

PORTAL COMPLETO:
  documentation-readme-hub → documentation-portal-html → documentation-roadmap-from-docs
```

## Matriz de decisão

| Cenário | Skill |
|---------|-------|
| Projeto novo sem código-fonte — por onde começar? | `documentation-oop-first` |
| Projeto sem estrutura `Documentation/` (com código) | `documentation-project-bootstrap` |
| Quais docs existem e quais faltam? | `documentation-project-scan` |
| Documentar uma classe ou unit específica | `documentation-paste_analysis_unit_class_method` |
| Feature concluída — documentar para o produto | `documentation-project-feature` |
| Formalizar regras de negócio | `documentation-business-rules` |
| Criar ou atualizar arquitetura técnica | `documentation-architecture` |
| Gerar hub README de navegação | `documentation-readme-hub` |
| Criar portal HTML navegável | `documentation-portal-html` |
| Migrar docs para nova estrutura | `documentation-migration-plan` → `documentation-migration-backup` |
| Criar rules `.cursor/` a partir de normas | `documentation-rules_creator` |
| Gerar spec OpenAPI | `documentation-api-openapi` |
| Atualizar docs após mudança de código | `documentation-project-update` |

## Anti-padrões

| Anti-padrão | Como corrigir |
|-------------|---------------|
| Documentar features/RN sem definir classes primeiro (projeto novo) | Usar `documentation-oop-first` antes de qualquer doc de conteúdo |
| Documentar diretamente em `.claude/` ou `.vscode/` | Toda documentação vai em `Documentation/` (SSOT) ou `Analise/` — nunca em espelhos |
| Migrar sem backup | `documentation-migration-backup` é obrigatório antes de qualquer reorganização |
| Criar `{ClassName}.md` manualmente sem scaffold | Usar `documentation-paste_analysis_unit_class_method` para garantir template correto |
| Gerar portal sem atualizar README hub | Sempre `documentation-readme-hub` antes de `documentation-portal-html` |

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.1.0 (13/04/2026): Adicionada `documentation-oop-first` em NÍVEL 0 — Bootstrap (24 → 25 skills); nova sequência canônica "NOVO PROJETO SEM CÓDIGO"; nova entrada na matriz de decisão; novo anti-padrão "documentar sem design OOP".
- 1.0.0 (11/04/2026): Criação — skill orquestradora da família `documentation-*` (24 skills, 5 níveis).
- 1.2.0 (24/04/2026): Rename E5a — `documentation-master-orchestrator` -> `documentation-master-orchestrator`. Motivo: diferenciar master-orchestrator de sub-orchestrators (regra N3 do plano de refactor).
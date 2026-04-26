---
name: documentation-migration-plan
description: Planeia migrações de documentação — analisa o estado atual de Documentation/, identifica artefatos que precisam ser movidos, renomeados ou arquivados, e gera um plano de migração com backup antes de qualquer ação. Triggers - "plano de migração", "migration plan", "migrar documentação", "reorganizar Documentation", "mover artefatos", "reestruturar docs", "planejar migração".
model: sonnet
thinking: extended
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

## Responsabilidade única

Esta skill planeia migrações de documentação — ela analisa o estado atual de `Documentation/`, identifica artefatos que precisam ser movidos, renomeados ou arquivados, e gera um plano de migração com backup antes de qualquer ação. Existe separada de `documentation-migration-backup` porque foca no planeamento (o que mover / para onde / quando), não na execução (cópia física e arquivamento).

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |
| **Política** | `.cursor/VERSION.md` |

## When to use

- Quando o usuário pedir para reorganizar, reestruturar ou migrar a pasta `Documentation/`.
- Quando houver lacunas documentais identificadas por `documentation-project-scan` e for necessário planejar o preenchimento.
- Quando módulos forem adicionados/removidos de `src/` e a documentação precisar ser alinhada.
- Quando o usuário pedir "plano de migração", "migration plan" ou `/migration-plan`.
- Antes de executar qualquer movimentação em massa de artefatos documentais.

## When NOT to use

- Quando o usuário quer mover apenas 1-2 arquivos sem planeamento formal → usar `documentation-migration-backup` para executar diretamente com backup.
- Quando quer apenas escanear lacunas sem propor migração → usar `documentation-project-scan`, que entrega o inventário sem gerar plano de ação.
- Quando a migração já foi planeada e aprovada e o usuário quer apenas executar → usar `documentation-migration-backup` para realizar a cópia física e o arquivamento.

## Dependências (skills prévias)

| Skill | Papel | Obrigatória? |
| --- | --- | --- |
| `documentation-project-scan` | Fornece o inventário atual de `Documentation/` e a lista de lacunas — entrada obrigatória para a análise de gaps desta skill | Sim (executar antes) |
| `documentation-migration-backup` | Executa o backup físico antes da migração — deve ser acionada como primeiro passo da execução após aprovação do plano | Não (mas recomendada antes da execução) |

## Workflow obrigatório

**REGRA OBRIGATÓRIA:** Esta skill opera em **plan mode** — gera o plano completo e aguarda aprovação explícita do usuário antes de qualquer ação de escrita/movimentação.

### Fase 1 — Pré-requisitos

1. Verificar que `{SRC_PATH}` existe e contém código-fonte.
2. Verificar existência do entrypoint de build (`*.dpr` ou `*.lpr`).
3. Confirmar acesso aos templates em `.cursor/Templates/`.
4. Registrar estado inicial: hash/contagem de arquivos em `Documentation/`.

### Fase 2 — Descoberta (scan)

1. Executar scan recursivo de `{SRC_PATH}` — inventário de módulos reais.
2. Executar scan recursivo de `Documentation/` — inventário de artefatos existentes.
3. Extrair lista de `uses` do entrypoint de build; cruzar com arquivos físicos.
4. Identificar units órfãs (em `{SRC_PATH}` mas fora do `uses`) e documentos órfãos (em `Documentation/` sem módulo correspondente).

### Fase 3 — Análise de lacunas (gap analysis)

1. Para cada módulo em `{SRC_PATH}`, verificar cobertura em: `Analise/`, `Regras de Negocio/`, `Arquitetura/`.
2. Classificar status: Completo / Parcial / Ausente.
3. Listar lacunas críticas com prioridade.
4. Listar documentos órfãos com ação recomendada (Arquivar / Eliminar / Manter).

### Fase 4 — Geração do plano

Gerar documento de plano usando o template `.cursor/plans/documentation-migration-plan_V1.0.md` como base, preenchendo todos os placeholders com dados reais coletados nas fases anteriores.

### Fase 5 — Aprovação e execução

1. Apresentar plano completo ao usuário.
2. **Aguardar aprovação explícita** antes de qualquer escrita/movimentação.
3. Após aprovação: acionar `documentation-migration-backup` para backup físico.
4. Executar migração módulo a módulo conforme o plano aprovado.
5. Emitir relatório de conclusão.

## As 13 subpastas obrigatórias de Documentation/

| # | Subpasta | Finalidade |
|---|----------|-----------|
| 01 | `Analise/` | Análises, scans, lacunas |
| 02 | `Analise/{Domain}/` | Uma subpasta por domínio/módulo |
| 03 | `Arquitetura/` | Documentação de arquitetura e camadas |
| 04 | `Regras de Negocio/` | Hub de regras de negócio |
| 05 | `Regras de Negocio/RN-M{xx}/` | Uma subpasta por módulo com RNs |
| 06 | `Esboco_Telas/` | Esboços e documentação de telas |
| 07 | `Roadmap/` | Roadmap por fases e entregas |
| 08 | `Versionamento/` | Changelog e histórico de versões |
| 09 | `Backup/` | Backups documentais de ciclos anteriores |
| 10 | `html/` | Portal estático (index.html, docs-data.js) |
| 11 | `Overview/` | Visão geral do projeto |
| 12 | `Diagramas/` | Diagramas técnicos (UML, ER, fluxos) |
| 13 | `Glossario/` | Glossário de termos do domínio |

## Anti-padrões

| Anti-padrão | Por que errado | Como corrigir |
| --- | --- | --- |
| Executar movimentação de artefatos sem gerar plano primeiro | Impossibilita revisão humana; cria risco de perda de documentos sem trilha de auditoria | Sempre gerar e aprovar o plano completo antes de qualquer ação de escrita |
| Pular `documentation-project-scan` e iniciar o plano com dados incompletos | O plano fica baseado em suposições; lacunas reais não são mapeadas | Executar `documentation-project-scan` e usar seu output como entrada desta skill |
| Mover documentos sem backup prévio | Em caso de erro, não há como recuperar o estado anterior | Acionar `documentation-migration-backup` como primeiro passo da execução |
| Gerar plano e executar na mesma sessão sem aprovação explícita | Viola o plan mode obrigatório; o usuário perde controle sobre o que será alterado | Apresentar o plano, aguardar "aprovado" ou equivalente explícito, só então executar |

## Métricas de sucesso

- Zero documentos perdidos após migração — verificável comparando contagem e hashes antes/depois com o backup gerado por `documentation-migration-backup`.
- 100% dos módulos de `{SRC_PATH}` com cobertura documental em `Analise/`, `Regras de Negocio/` e `Arquitetura/` ao final do ciclo — verificável rodando novamente `documentation-project-scan` e confirmando status "Completo" para todos os módulos.

## Responsável principal

| Papel | Quem |
| --- | --- |
| Agent executor | `doc-agent-orchestrator` |
| Aprovador humano | Tech Lead |
| Revisor de conteúdo | Desenvolvedor responsável por cada módulo |

## Relação com outras skills

| Skill | Relação |
| --- | --- |
| `documentation-project-scan` | Pré-condição — fornece inventário e gap analysis como entrada |
| `documentation-migration-backup` | Complementar — executa backup físico antes da migração e realiza a cópia após aprovação |
| `documentation-project-bootstrap` | Complementar — cria a estrutura de 13 subpastas caso não exista |
| `documentation-rules_creator` | Posterior — cria rules específicas do projeto após a estrutura estar migrada |

## Template de referência

O template completo do plano de migração está em:
`.cursor/plans/documentation-migration-plan_V1.0.md`

Usar como base para gerar o plano preenchido com dados reais do projeto.

## Regras operacionais

1. **SEMPRE entrar em plan mode** antes de executar qualquer etapa deste plano.
2. **Nunca eliminar** documentos sem backup prévio e confirmação do utilizador.
3. **Nunca executar** modo `full` de scaffolding sem confirmação explícita.
4. **Manter precedência:** `src/` (código) > `.cursor/` (canônicos) > `Documentation/`.
5. **Um módulo por vez:** completar todas as etapas de um módulo antes de avançar.
6. **Templates são obrigatórios:** não criar documentos de raiz; usar `.cursor/Templates/`.

## Changelog (este arquivo)

- 1.1.0 (08/04/2026): Migração V2 — adicionadas seções Responsabilidade única, When NOT to use, Dependências, Anti-padrões, Métricas de sucesso, Responsável principal; frontmatter com thinking e category. Skill criada em `.cursor/skills/` a partir do template `.cursor/plans/documentation-migration-plan_V1.0.md`.
- 1.0.0 (04/04/2026): Versão inicial — plano genérico de migração documental com placeholders; seções: pré-requisitos, descoberta, análise de lacunas, checklist por módulo (Analise/RN/Arquitetura), bootstrap de 13 subpastas, validação, pós-migração, propagação.

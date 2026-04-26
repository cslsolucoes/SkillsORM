# sub_domains — governance-master-orchestrator

## Mapa de sub-domínios

```
governance-* (20 skills)
├── ARTIFACTS (3)
│   ├── governance-artifact-inventory         → inventário
│   ├── governance-artifact-dependency-map    → mapa dependências
│   └── governance-artifact-traceability      → req→código→doc
│
├── SPECS (5)
│   ├── governance-spec-prd-generator         → PRD
│   ├── governance-spec-technical-writer      → spec técnica
│   ├── governance-spec-reviewer              → revisão de spec
│   ├── governance-spec-validator             → validação vs código
│   └── governance-spec-evolution             → mudanças de requisito
│
├── POLICIES (5)
│   ├── governance-constitution-policies      → políticas normativas
│   ├── governance-refactoring-compatibility-policy → refactor seguro
│   ├── governance-pack-versioning-policy     → versionar pack
│   ├── governance-pack-checklist-validation  → validar pack
│   └── governance-pack-sync                  → sync entre projetos
│
├── RELEASE / SDLC (4)
│   ├── governance-sdlc-lifecycle             → ciclo de vida
│   ├── governance-release-management         → gerenciar releases
│   ├── governance-change-request             → change request formal
│   └── governance-incident-response          → resposta a incidente
│
└── TEAM (3)
    ├── governance-team-onboarding            → novo membro
    ├── governance-team-raci-matrix           → responsabilidades
    └── governance-team-ai-human-workflow     → workflow IA+humano
```

## Sequências rápidas

| Objetivo | Sequência |
|----------|-----------|
| Nova feature do zero | `spec-prd-generator` → `spec-technical-writer` → `spec-reviewer` |
| Release formal | `release-management` → `change-request` → `sdlc-lifecycle` |
| Mudança em produção | `change-request` → `release-management` |
| Auditoria do pack | `pack-checklist-validation` → `pack-versioning-policy` → `pack-sync` |
| Novo membro | `team-onboarding` → `team-raci-matrix` |
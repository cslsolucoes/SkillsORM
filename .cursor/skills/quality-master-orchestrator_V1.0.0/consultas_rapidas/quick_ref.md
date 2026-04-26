# quick_ref — quality-master-orchestrator

| Skill | Quando usar |
|-------|-------------|
| `quality-test-strategy` | definir estratégia de testes para nova feature ou projeto |
| `quality-acceptance-testing` | validar critérios de aceite antes de marcar feature como pronta |
| `quality-regression-guard` | garantir que mudanças não quebram funcionalidade existente |
| `quality-code-review-checklist` | estruturar code review em PRs com checklist padronizado |
| `quality-bug-triage` | classificar, priorizar e atribuir bugs reportados |
| `quality-hotfix-workflow` | executar hotfix em produção com segurança e rastreabilidade |
| `quality-refactoring-safe` | refatorar código preservando comportamento e sem regressões |
| `quality-tech-debt-tracker` | catalogar, priorizar e planejar redução de tech debt |

**Sequências típicas:**
- Pré-release: `test-strategy` → `acceptance-testing` → `regression-guard`
- Incidente: `bug-triage` → `hotfix-workflow`
- Evolução: `refactoring-safe` → `tech-debt-tracker`
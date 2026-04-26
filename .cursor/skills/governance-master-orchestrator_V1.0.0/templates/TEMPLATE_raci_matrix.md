# TEMPLATE — RACI Matrix

**Skill:** `governance-team-raci-matrix_V1.0.0`
**Projeto / Módulo:** {nome}
**Data:** {YYYY-MM-DD}
**Versão:** {vX.Y}

---

## Legenda

| Letra | Papel | Descrição |
|-------|-------|-----------|
| **R** | Responsible | Executa a tarefa |
| **A** | Accountable | Responde pelo resultado (apenas 1 por tarefa) |
| **C** | Consulted | Consultado antes/durante (comunicação bidirecional) |
| **I** | Informed | Informado do resultado (comunicação unidirecional) |

---

## Membros da Equipe

| Sigla | Nome | Papel |
|-------|------|-------|
| {P1} | {nome} | {Tech Lead / Dev / QA / PO / etc.} |
| {P2} | {nome} | |
| {P3} | {nome} | |
| {IA} | Claude / IA | Assistente de desenvolvimento |

---

## Matriz de Responsabilidades

### Desenvolvimento

| Atividade | {P1} | {P2} | {P3} | {IA} |
|-----------|:---:|:---:|:---:|:---:|
| Arquitetura e design técnico | A | C | I | C |
| Implementação de features | R | R | I | C |
| Code review | A | R | C | C |
| Testes unitários | R | R | I | C |
| Testes de integração | R | C | I | C |
| Merge para main | A | R | I | I |

### Qualidade e Release

| Atividade | {P1} | {P2} | {P3} | {IA} |
|-----------|:---:|:---:|:---:|:---:|
| Definição de critérios de aceite | C | I | A | C |
| Triage de bugs | R | C | A | C |
| Aprovação de release | A | C | R | I |
| Deploy em produção | R | I | A | I |
| Post-mortem de incidentes | A | R | C | C |

### Documentação e Governança

| Atividade | {P1} | {P2} | {P3} | {IA} |
|-----------|:---:|:---:|:---:|:---:|
| Atualização de specs técnicas | R | C | A | C |
| Documentação de API | R | I | A | C |
| Atualização do `.cursor/` pack | A | R | C | R |
| Onboarding de novos membros | A | C | R | C |

---

## Notas

- {Observação sobre casos especiais, conflitos ou gap identificado}

---

**FileVersion:** 1.0.0 · **Skill:** `governance-team-raci-matrix_V1.0.0`

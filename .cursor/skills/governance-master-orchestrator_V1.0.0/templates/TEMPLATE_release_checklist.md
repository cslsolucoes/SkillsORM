# TEMPLATE — Release Checklist

**Skill:** `governance-release-management_V1.0.0`
**Versão:** {vX.Y.Z}
**Data planejada:** {YYYY-MM-DD}
**Release Manager:** {nome}

---

## PRÉ-RELEASE

### Código e Qualidade

- [ ] Todos os PRs da versão merged em `main`
- [ ] Build limpo sem erros (Delphi dcc32/dcc64 e/ou FPC)
- [ ] Testes unitários passando (0 falhas)
- [ ] Code review realizado em todos os PRs desta versão
- [ ] Breaking changes identificados: `version-breaking-change-guard` executado
- [ ] Versão calculada: `version-semver-product` executado → {vX.Y.Z}

### Documentação

- [ ] CHANGELOG.md atualizado com as mudanças desta versão
- [ ] Release notes redigidas: `version-release-notes` executado
- [ ] Guia de migração criado (se breaking changes): `version-migration-assistant` executado
- [ ] Deprecações formalizadas (se houver): `version-deprecation-policy` executado
- [ ] Documentação técnica atualizada em `Documentation/`

### Segurança e Compliance

- [ ] Dependências externas auditadas (sem vulnerabilidades conhecidas)
- [ ] Credenciais e segredos verificados — nenhum hardcoded
- [ ] Change request aprovado: {CR-YYYY-NNN}

---

## RELEASE

### Deploy

- [ ] Tag `vX.Y.Z` criada em `main`
- [ ] Build de release compilado para todas as plataformas alvo
- [ ] Deploy executado no ambiente de staging
- [ ] Smoke tests passando em staging
- [ ] Aprovação para produção obtida de: {nome}
- [ ] Deploy executado em produção
- [ ] Plano de rollback definido: {CR-YYYY-NNN}

---

## PÓS-RELEASE

### Validação

- [ ] Smoke tests passando em produção
- [ ] Logs sem erros novos após 30 min
- [ ] Métricas normalizadas (sem pico de erros / latência)
- [ ] Funcionalidades críticas validadas manualmente

### Comunicação

- [ ] Stakeholders notificados sobre release
- [ ] Release notes publicadas em: {local}
- [ ] Equipe de suporte informada das mudanças

### Rastreabilidade

- [ ] Issues/tasks da versão fechadas
- [ ] Próxima versão planejada: {vX.Y.(Z+1)} — milestone criado

---

**Resultado:**

| Campo | Valor |
|-------|-------|
| **Release status** | {SUCESSO / FALHA / ROLLBACK} |
| **Data real de release** | {YYYY-MM-DD HH:MM} |
| **Observações** | {notas relevantes} |

---

**FileVersion:** 1.0.0 · **Skill:** `governance-release-management_V1.0.0`

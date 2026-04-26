# TEMPLATE — Code Review Checklist

**Skill:** `quality-code-review-checklist_V1.0.0`
**PR / Branch:** {nome do PR ou branch}
**Revisor:** {nome}
**Data:** {YYYY-MM-DD}
**Autor do código:** {nome}

---

## Classificação

| Campo | Valor |
|-------|-------|
| **Tipo** | {feature / bugfix / hotfix / refactor / docs} |
| **Risco** | {BAIXO / MÉDIO / ALTO} |
| **Módulo afetado** | {módulo(s)} |

---

## 1. Correção Funcional

- [ ] O código faz o que a issue/spec descreve
- [ ] Casos de borda identificados e tratados
- [ ] Sem regressão visível em funcionalidades adjacentes
- [ ] Lógica de negócio está no módulo correto (não no form/view)

**Notas:**

---

## 2. Qualidade do Código

- [ ] Naming claro e consistente com o projeto (I*/T*, F/A prefix onde aplicável)
- [ ] Sem código morto, comentários obsoletos ou `TODO` não rastreados
- [ ] Ausência de duplicação — reutilização de código existente onde possível
- [ ] Complexidade ciclomática aceitável (funções/métodos curtos e focados)
- [ ] Memory management correto (`try...finally`, `.Free`, sem leaks visíveis)

**Notas:**

---

## 3. Tratamento de Erros

- [ ] Exceções tratadas no nível adequado (não silenciadas)
- [ ] Mensagens de erro informativas e rastreáveis
- [ ] Fluxo de erro não deixa estado inconsistente
- [ ] Log de erros presente onde relevante

**Notas:**

---

## 4. Testes

- [ ] Testes unitários presentes para lógica nova ou alterada
- [ ] Testes de integração para fluxos críticos (se aplicável)
- [ ] Cobertura dos casos de erro
- [ ] Testes passando localmente (confirmado pelo autor)

**Notas:**

---

## 5. Performance e Segurança

- [ ] Sem N+1 queries ou loops desnecessários sobre coleções grandes
- [ ] Sem SQL gerado dinamicamente sem parametrização
- [ ] Sem credenciais ou segredos hardcoded
- [ ] Sem operações bloqueantes na thread principal da UI

**Notas:**

---

## 6. Documentação e Rastreabilidade

- [ ] Issue/task referenciada no commit ou PR
- [ ] Mudanças de API pública documentadas ou rastreadas
- [ ] `CHANGELOG.md` atualizado se necessário
- [ ] Breaking changes identificados e comunicados

**Notas:**

---

## Resultado

| Campo | Valor |
|-------|-------|
| **Decisão** | {APROVADO / APROVADO COM RESSALVAS / REPROVADO} |
| **Ressalvas obrigatórias** | {lista de itens que devem ser corrigidos antes do merge} |
| **Sugestões (opcionais)** | {melhorias não-bloqueantes} |

---

**FileVersion:** 1.0.0 · **Skill:** `quality-code-review-checklist_V1.0.0`

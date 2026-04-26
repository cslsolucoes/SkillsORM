---
name: governance-artifact-traceability
description: Rastreabilidade bidirecional no Providers.2.1.0 — mapeia requisito ↔ SPEC ↔ código ↔ teste ↔ documentação, detectando requisitos sem implementação e código sem requisito correspondente.
model: sonnet
thinking: normal
category: governance-artifact
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Governance Artifact — Artifact Traceability

## Responsabilidade única

Manter a matriz de rastreabilidade bidirecional do Providers.2.1.0: para cada requisito do PRD,
rastrear qual feature da SPEC o cobre, qual arquivo de código o implementa, qual teste o verifica
e qual documento o descreve. Permite detectar lacunas (requisito sem implementação, código sem
requisito) e avaliar o impacto real de uma mudança antes de implementá-la. Esta skill **não** faz
inventário simples de artefatos (→ `governance-artifact-inventory`) nem valida implementação
contra SPEC diretamente (→ `governance-spec-validator`).

## When to use

- Ao auditar cobertura de requisitos antes de release.
- Ao avaliar impacto de uma mudança proposta em `governance-change-request`.
- Ao validar se a SPEC está coberta por testes.
- Ao detectar código órfão (sem requisito correspondente).

## When NOT to use

- Para inventário simples de artefatos → usar `governance-artifact-inventory`.
- Para validar implementação vs. SPEC → usar `governance-spec-validator`.
- Para atualizar SPEC após mudança → usar `governance-spec-evolution`.

## Inputs obrigatórios

| Input | Tipo | Descrição |
|-------|------|-----------|
| PRD de referência | Caminho | `Documentation/PRD/<feature>.PRD.md` |
| SPEC de referência | Caminho | `Documentation/SPEC/<módulo>.SPEC.md` |
| Escopo de rastreabilidade | Texto | Módulo ou feature a rastrear |

## Dependências (skills prévias)

| Skill | Motivo |
|-------|--------|
| `governance-spec-technical-writer_V1.0.0` | Garantir que a SPEC existe e está estruturada |
| `governance-artifact-inventory_V1.0.0` | Inventário base dos artefatos a rastrear |

## Workflow executável

1. **Ler PRD + SPEC** — extrair de cada documento:
   - PRD: lista de features com IDs e critérios de aceite
   - SPEC: lista de steps/componentes técnicos que implementam cada feature do PRD
   Verificar consistência: toda feature do PRD deve ter ao menos um item na SPEC.

2. **Mapear código** — para cada item da SPEC, identificar:
   - Arquivo `.pas`/`.pp` que o implementa (interface `I*` e implementação `T*`)
   - Método ou procedimento específico responsável pelo comportamento
   Registrar casos não mapeados como lacunas de implementação.

3. **Mapear testes** — para cada item de código identificado, localizar:
   - Arquivo de teste que cobre aquele comportamento
   - Nome do caso de teste e tipo (unitário/integração/aceitação)
   Registrar comportamentos sem teste como lacunas de cobertura.

4. **Gerar matriz** — consolidar os 3 mapeamentos em `Documentation/Traceability.md`:
   cada linha representa um requisito; as colunas avançam de PRD → SPEC → código → teste → doc.
   Marcar lacunas com `[FALTANDO]` para visibilidade imediata.

## Outputs obrigatórios

| Output | Localização | Formato |
|--------|-------------|---------|
| Matriz de rastreabilidade | `Documentation/Traceability.md` | Tabela Markdown |

### Estrutura obrigatória da matriz

```markdown
# Matriz de Rastreabilidade — Providers.2.1.0

**Módulo/Feature:** <nome> · **Gerado em:** YYYY-MM-DD

| Requisito (PRD) | Feature (SPEC) | Arquivo de Código | Método/Unit | Teste | Documento |
|-----------------|----------------|-------------------|-------------|-------|-----------|
| REQ-001: ...    | SPEC-F01: ...  | src/.../Unit.pas  | TClass.Met  | test_... | SPEC.md |
| REQ-002: ...    | [FALTANDO]     | —                 | —           | —     | —         |
| —               | SPEC-F05: ...  | src/.../Other.pas | TClass.Met  | —     | [FALTANDO] |
```

**Legenda:**
- `[FALTANDO]` = lacuna identificada — requer ação
- `—` = não aplicável para este nível

## Checklist de validação

- [ ] PRD e SPEC de referência identificados e lidos
- [ ] Toda feature do PRD mapeada para ao menos um item da SPEC
- [ ] Todo item da SPEC mapeado para ao menos um arquivo de código
- [ ] Lacunas de implementação identificadas e marcadas como `[FALTANDO]`
- [ ] Lacunas de cobertura de teste identificadas e marcadas como `[FALTANDO]`
- [ ] `Documentation/Traceability.md` criado/atualizado
- [ ] Matriz revisada pelo Tech Lead antes de release

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Rastreabilidade parcial (só PRD→SPEC) | Não detecta código sem teste nem código sem requisito | Executar todos os 4 passos — PRD, SPEC, código, teste |
| Não atualizar após mudança | Matriz desatualizada dá falsa sensação de cobertura | Invocar esta skill após toda mudança aprovada via `governance-change-request` |
| Requisitos órfãos sem implementação não sinalizados | Lacunas invisíveis; release com cobertura parcial | Marcar `[FALTANDO]` explicitamente para toda lacuna |
| Código sem requisito correspondente não sinalizado | Código "fantasma" sem rastreabilidade; risco de ser removido por engano | Rastrear na direção reversa (código → requisito) também |
| Matriz em formato não estruturado | Difícil de processar e auditar | Usar estrutura de tabela obrigatória com colunas definidas |

## Avaliação de risco

- **Parar e confirmar quando:** requisito sem nenhum item de código mapeado — não prosseguir para
  release sem resolver lacuna ou documentar decisão explícita de excluir o requisito.
- **Risco baixo:** auditoria de módulo pequeno e isolado.
- **Risco médio:** rastreabilidade de módulo com múltiplas engines (FireDAC, UniDAC, Zeos, SQLdb)
  — verificar que todas as implementações estão cobertas.
- **Risco alto:** rastreabilidade pré-release — verificar cobertura total antes de publicar.

## Métricas de sucesso

- 100% dos requisitos do PRD com pelo menos um item de código rastreado.
- Zero itens de código sem requisito correspondente no módulo rastreado.
- Matriz atualizada a cada mudança aprovada e a cada release.
- Lacunas identificadas com ação registrada (implementar ou documentar exclusão).

## Responsável principal

| Papel | Quem |
|-------|------|
| Agent executor | `dev-agent-orchestrator` |
| Revisão e aprovação | Humano (Tech Lead) |

## Referências

- SPEC técnica: `governance-spec-technical-writer_V1.0.0`
- Inventário de artefatos: `governance-artifact-inventory_V1.0.0`
- Validação SPEC: `governance-spec-validator_V1.0.0`
- Gestão de mudança: `governance-change-request_V1.0.0`
- Pasta de saída: `Documentation/`
- Política de documentação: `.cursor/skills/documentation-general_rules_V2.0.0/SKILL.md`

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.0.0 (09/04/2026): Skill nova V2 — criada para lacuna governance no plano de migração V2.6.

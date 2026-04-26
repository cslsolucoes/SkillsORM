---
name: governance-spec-technical-writer
description: Converte PRD aprovado em SPEC técnica estruturada (SPEC.json + SPEC.md) decomposta em sprints, features, steps, edge_cases e acceptance_criteria — com campos técnicos api_endpoint, build, database, auth, frontend, delphi_component, fpc_component prontos para execução por agents.
model: sonnet
thinking: extended
category: governance-spec
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Governance Spec — Technical Writer

## Responsabilidade única

Converter um PRD aprovado em uma especificação técnica acionável (SPEC) que agents possam executar
diretamente, decompondo features em sprints, steps e edge_cases, preenchendo campos técnicos
categoria por categoria, e marcando explicitamente os gaps que exigem pergunta ao usuário antes de
prosseguir. Esta skill **não** cria o PRD (responsabilidade de `governance-spec-prd-generator`) nem
revisa a SPEC gerada (responsabilidade de `governance-spec-reviewer`).

## When to use

- Após o PRD estar aprovado pelo stakeholder.
- Para transformar requisitos de negócio em tarefas técnicas executáveis por agents.
- Antes de invocar `governance-spec-reviewer` para auditoria independente.

## When NOT to use

- Sem PRD aprovado — invocar `governance-spec-prd-generator` primeiro.
- Para revisar ou auditar a SPEC após gerada → usar `governance-spec-reviewer`.
- Para evoluir SPEC já existente com novas mudanças → usar `governance-spec-evolution`.
- Para validar implementação contra a SPEC → usar `governance-spec-validator`.

## Inputs obrigatórios

| Input | Tipo | Descrição |
|-------|------|-----------|
| PRD aprovado | Arquivo Markdown | `Documentation/PRD/<nome-feature>.PRD.md` com aprovação registrada |
| Nome da feature/módulo | Texto | Identificador que será usado no nome dos arquivos de saída |

## Dependências (skills prévias)

| Skill | Motivo |
|-------|--------|
| `governance-spec-prd-generator` | PRD.md aprovado é o input obrigatório desta skill |

## Workflow executável

1. **Ler o PRD** — carregar `Documentation/PRD/<nome-feature>.PRD.md`; verificar que possui
   aprovação registrada; se não tiver, interromper e solicitar aprovação antes de prosseguir.

2. **Decompor em sprints e features** — mapear cada feature do PRD para um sprint numerado;
   decompor cada feature em steps atômicos (passos de implementação independentes); identificar
   edge_cases por feature (pelo menos 1 por feature de negócio relevante).

3. **Preencher campos técnicos** — para cada feature/step, preencher os campos aplicáveis
   conforme as Regras de auto-fill (seção abaixo); campos não aplicáveis recebem `null`;
   nunca inferir campos de negócio (ex.: regras de auth, schemas de banco) — registrar como
   `"PENDING_INPUT"` e formular pergunta explícita ao usuário.

4. **Marcar gaps** — listar ao final da SPEC todos os campos `"PENDING_INPUT"` com a pergunta
   exata que precisa de resposta; não avançar para geração do arquivo final sem resolver os gaps
   críticos (segurança, banco de dados, autenticação).

5. **Gerar SPEC.json e SPEC.md** — serializar a SPEC no JSON Schema obrigatório (seção abaixo)
   e também exportar versão Markdown alternativa; salvar ambos em `Documentation/SPEC/`.

## Outputs obrigatórios

| Output | Localização | Formato |
|--------|-------------|---------|
| SPEC estruturada | `Documentation/SPEC/<nome-feature>.SPEC.json` | JSON (schema obrigatório) |
| SPEC alternativa | `Documentation/SPEC/<nome-feature>.SPEC.md` | Markdown legível |

## Formato de saída

### JSON Schema obrigatório

```json
{
  "feature": "<nome-feature>",
  "version": "1.0.0",
  "prd_ref": "Documentation/PRD/<nome-feature>.PRD.md",
  "pre_requisito": "<dependências de outras features ou módulos>",
  "sprints": [
    {
      "sprint": 1,
      "features": [
        {
          "id": "F1",
          "nome": "<nome da feature>",
          "steps": [
            {
              "id": "F1-S1",
              "descricao": "<o que fazer>",
              "api_endpoint": null,
              "build": null,
              "database": null,
              "auth": null,
              "frontend": null,
              "delphi_component": null,
              "fpc_component": null
            }
          ],
          "edge_cases": ["<caso de borda 1>"],
          "acceptance_criteria": ["<critério de aceite 1>"]
        }
      ]
    }
  ],
  "gaps": [
    {
      "campo": "PENDING_INPUT",
      "feature_id": "F1",
      "pergunta": "<pergunta exata para o usuário>"
    }
  ]
}
```

### Markdown alternativa (SPEC.md)

```markdown
# SPEC — <Nome da Feature>

**Versão:** 1.0.0
**PRD de origem:** `Documentation/PRD/<nome-feature>.PRD.md`
**Pré-requisito:** <dependências>

## Sprint 1

### F1 — <Nome>
**Steps:**
- F1-S1: <descrição>

**Edge cases:**
- <caso>

**Acceptance criteria:**
- <critério>

## Gaps pendentes
| Campo | Feature | Pergunta |
|-------|---------|----------|
| ...   | ...     | ...      |
```

## Regras de auto-fill

| Categoria | Quando preencher | Fonte do valor |
|-----------|-----------------|----------------|
| `api_endpoint` | Feature que expõe ou consome endpoint HTTP/REST | Inferir método + path do PRD; marcar `PENDING_INPUT` se ambíguo |
| `build` | Step que altera configuração de compilação ou dependências | Inferir do contexto do projeto; marcar `PENDING_INPUT` se não identificado |
| `database` | Step que cria/altera tabelas, queries ou migrations | Marcar sempre como `PENDING_INPUT` — nunca inferir schema de negócio |
| `auth` | Feature com controle de acesso, tokens ou sessões | Marcar sempre como `PENDING_INPUT` — regras de auth são de negócio |
| `frontend` | Step que altera tela, componente visual ou fluxo de navegação | Inferir do PRD; marcar `PENDING_INPUT` se não descrito |
| `delphi_component` | Step que cria/altera unit, form ou classe Delphi | Inferir prefixo `T`/`I`/`ufrm` do contexto; nunca inventar nome de classe |
| `fpc_component` | Step que cria/altera unit FPC/Lazarus | Mesma regra do `delphi_component` |

**Regra geral:** se não houver evidência suficiente no PRD para preencher um campo com segurança,
registrar `"PENDING_INPUT"` e formular pergunta explícita na seção `gaps`.

## Checklist de validação

- [ ] PRD de origem referenciado em `prd_ref` e com aprovação registrada
- [ ] Campo `pre_requisito` preenchido (pode ser `"nenhum"`, nunca vazio)
- [ ] Cada feature possui ao menos 1 `edge_case` e 1 `acceptance_criteria`
- [ ] Campos de negócio sensíveis (`auth`, `database`) marcados como `PENDING_INPUT` se não confirmados
- [ ] Seção `gaps` lista todas as perguntas pendentes antes de finalizar
- [ ] SPEC.json e SPEC.md gerados em `Documentation/SPEC/`
- [ ] SPEC validável por `governance-spec-validator` (zero campos obrigatórios vazios)

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Preencher `auth` ou `database` sem perguntar ao usuário | Regras de negócio sensíveis não podem ser inferidas | Marcar como `PENDING_INPUT` e formular pergunta na seção `gaps` |
| SPEC sem campo `pre_requisito` | Gera dependências ocultas entre módulos | Sempre preencher, mesmo que seja `"nenhum"` |
| Ignorar `edge_cases` | Features sem edge cases geram bugs em produção | Identificar ao menos 1 edge case por feature relevante |
| Gerar SPEC sem PRD aprovado | SPEC desconectada do requisito de negócio | Retornar para `governance-spec-prd-generator` |
| Features sem `acceptance_criteria` | Impossível validar com `governance-spec-validator` | Mapear cada critério de aceite do PRD para a feature correspondente |

## Avaliação de risco

- **Parar e confirmar quando:** existirem gaps críticos em `auth` ou `database` — não gerar SPEC
  final sem resolver esses gaps; apresentar as perguntas ao usuário antes de continuar.
- **Risco baixo:** steps de `build` e `delphi_component`/`fpc_component` com naming claro no PRD.
- **Risco médio:** features com `api_endpoint` — confirmar método HTTP e path antes de registrar.
- **Risco alto:** qualquer campo de `auth` ou `database` — obrigatório perguntar ao usuário.

## Métricas de sucesso

- SPEC validável por `governance-spec-validator` sem erros estruturais.
- Zero campos obrigatórios (`pre_requisito`, `edge_cases`, `acceptance_criteria`) vazios.
- Todos os campos de negócio sensíveis resolvidos (saíram de `PENDING_INPUT`) antes da entrega.
- SPEC aprovada por `governance-spec-reviewer` sem gaps críticos remanescentes.

## Responsável principal

| Papel | Quem |
|-------|------|
| Agent executor | `dev-agent-orchestrator` |
| Revisão humana | Tech Lead / Arquiteto |

## Referências

- Skill anterior na cadeia: `governance-spec-prd-generator_V1.0.0`
- Próxima skill na cadeia: `governance-spec-reviewer_V1.0.0`
- Validação de implementação: `governance-spec-validator_V1.0.0`
- Evolução de SPEC aprovada: `governance-spec-evolution_V1.0.0`
- Pasta de saída canônica: `Documentation/SPEC/`

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.0.0 (09/04/2026): Skill nova V2 — criada para lacuna governance-spec no plano de migração V2.6.

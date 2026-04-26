---
name: version-deprecation-policy
description: Processo para deprecar APIs do projeto sem quebrar usuários — adiciona marcador deprecated com mensagem e prazo, documenta alternativa, gera warning de compilação e agenda remoção na próxima MAJOR. Garante que nenhuma API é removida sem ciclo de deprecação explícito.
model: sonnet
thinking: normal
category: version
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Version Deprecation Policy

## Responsabilidade única

Esta skill gerencia o **ciclo completo de deprecação** de APIs públicas do projeto — desde a marcação com `deprecated` (incluindo mensagem de alternativa e prazo de remoção) até o agendamento formal da remoção na próxima MAJOR. Garante que nenhum consumidor seja surpreendido por remoção silenciosa: toda API removida deve ter passado por ciclo de deprecação com warning de compilação visível, alternativa documentada e prazo explícito.

## When to use

- Ao substituir uma API pública por uma nova implementação mais adequada.
- Ao consolidar interfaces duplicadas em uma única canónica.
- Ao preparar a codebase para uma futura MAJOR onde APIs legadas serão removidas.

## When NOT to use

- Para breaking change imediato sem ciclo gradual → usar `version-breaking-change-guard` (análise obrigatória primeiro) e depois decidir com o Tech Lead.
- Para remoção sem aviso prévio → exige aprovação explícita; esta skill bloqueia remoção sem ciclo deprecated.
- Para mudança interna não-pública → usar `quality-refactoring-safe`.

## Dependências (skills prévias)

| Skill | Quando executar antes |
| --- | --- |
| `version-breaking-change-guard` | Obrigatório — avaliar impacto da futura remoção antes de iniciar ciclo |
| `version-semver-product` | Referência para identificar qual será a próxima MAJOR (prazo de remoção) |

## Inputs obrigatórios

| Input | Descrição |
| --- | --- |
| API a deprecar | Identificador completo — ex.: `IConnection.OpenLegacy` |
| API substituta | O que usar no lugar — ex.: `IConnection.Open` |
| Versão de remoção | Próxima MAJOR planejada — ex.: `V3.0.0` |

## Marcador deprecated

**Delphi:**
```pascal
procedure OldMethod; deprecated 'Use NewMethod instead. Removed in V3.0.0';
```

**FPC:**
```pascal
procedure OldMethod; deprecated;
{ Alternativa: NewMethod. Remoção planejada: V3.0.0 }
```

O marcador deve estar na declaração da interface (`I*`) e na implementação (`T*`).

## Workflow executável

1. **Marcar como deprecated** — adicionar `deprecated 'mensagem'` na declaração da API na interface e na implementação; a mensagem deve incluir alternativa e versão de remoção.
2. **Documentar alternativa** — atualizar a documentação da API (XMLDoc/comentários) com exemplo de uso da alternativa.
3. **Adicionar ao changelog** — registrar em `CHANGELOG.md` sob seção `### Deprecated` com versão atual e prazo de remoção.
4. **Agendar remoção** — criar item de backlog/issue apontando para a próxima MAJOR como data de remoção; referenciar no changelog.

## Outputs obrigatórios

| Output | Descrição |
| --- | --- |
| Marcador `deprecated` aplicado | Na interface `I*` e implementação `T*` |
| Mensagem com alternativa e prazo | Texto completo visível no warning de compilação |
| Entrada no `CHANGELOG.md` | Seção `### Deprecated` com prazo explícito |
| Item de remoção agendado | Backlog/issue com versão de remoção referenciada |

## Checklist de validação

- [ ] `deprecated` aplicado na declaração da interface `I*`.
- [ ] `deprecated` aplicado na implementação `T*` correspondente.
- [ ] Mensagem inclui nome da alternativa e versão de remoção (ex.: `V3.0.0`).
- [ ] Compilação gera warning visível (testado em Delphi e FPC).
- [ ] Entrada adicionada em `CHANGELOG.md` na seção `### Deprecated`.
- [ ] Item de remoção criado no backlog com referência à versão MAJOR.
- [ ] `version-breaking-change-guard` foi executado previamente.

## Anti-padrões

| Anti-padrão | Por que errado | Como corrigir |
| --- | --- | --- |
| Remover API sem ciclo deprecated | Consumidores têm compilação quebrada sem aviso | Sempre iniciar com marcador deprecated; remoção somente na MAJOR seguinte |
| Deprecated sem prazo de remoção | Consumidor não sabe quando precisa migrar; API acumula como dead code | Sempre incluir versão de remoção na mensagem |
| Deprecated sem alternativa documentada | Consumidor sabe que a API vai sumir mas não sabe para onde migrar | Mensagem obrigatoriamente inclui nome da API substituta |
| Aplicar deprecated sem passar por `version-breaking-change-guard` | Impacto da futura remoção não foi avaliado | Executar análise de impacto antes de iniciar ciclo de deprecação |

## Avaliação de risco

| Risco | Probabilidade | Impacto | Mitigação |
| --- | --- | --- | --- |
| Warning ignorado pelo consumidor | Média | Médio — compilação quebra na MAJOR | Warning é obrigatório; documentar prazo em changelog público |
| Versão MAJOR planejada muda e prazo fica errado | Baixa | Baixo — mensagem com versão desatualizada | Atualizar mensagem deprecated se prazo de MAJOR mudar |
| Ciclo deprecated pulado em refactoring rápido | Média | Alto — regressão não anunciada para consumidores | `governance-refactoring-compatibility-policy` bloqueia este cenário |

## Métricas de sucesso

- 100% das APIs removidas precedidas por ao menos um release com marcador deprecated.
- 0 remoções de API sem entrada correspondente em `CHANGELOG.md` na seção `### Deprecated`.
- Todos os marcadores deprecated incluem alternativa e versão de remoção na mensagem.

## Responsável principal

| Papel | Quem |
| --- | --- |
| Agent executor | `dev-agent-providers-orm-expert` |
| Revisão e aprovação | Tech Lead (humano) |

---

## Versão interna (arquivo)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Skill nova V2 — criada para lacuna version no plano de migração V2.6.

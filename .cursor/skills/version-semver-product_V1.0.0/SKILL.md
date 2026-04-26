---
name: version-semver-product
description: Aplica versionamento semântico ao produto — decide quando bumpar MAJOR/MINOR/PATCH, define o que é breaking change no contexto da biblioteca e gera a tag de versão correspondente. Distinto do versionamento interno do pack .cursor/ (gerido por pack-versioning-policy).
model: haiku
thinking: minimal
category: version
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Version SemVer Product

## Responsabilidade única

Esta skill aplica versionamento semântico (SemVer) ao **produto público** — decide quando bumpar MAJOR, MINOR ou PATCH com base nas mudanças do release, atualiza `VERSION.md`, gera a tag de versão e registra a entrada no changelog. É a referência canónica para qualquer decisão de versão de produto. Não versiona artefatos internos do pack `.cursor/` (responsabilidade de `pack-versioning-policy`).

## When to use

- Ao finalizar sprint com novas features prontas para release.
- Ao corrigir bug público documentado em issue/changelog.
- Ao realizar breaking change em API pública da biblioteca.
- Quando qualquer colaborador perguntar "qual versão devo usar para este release?".

## When NOT to use

- Para versionar artefatos do pack `.cursor/` (rules, skills, agentes, templates) → usar `pack-versioning-policy`.
- Para análise de impacto de breaking change antes de aplicar → usar `version-breaking-change-guard`.
- Para iniciar o ciclo de deprecação de uma API → usar `version-deprecation-policy`.
- Para gerar release notes a partir do changelog → usar `version-release-notes`.

## Dependências (skills prévias)

| Skill | Quando executar antes |
| --- | --- |
| `pack-versioning-policy` | Referência de base — compreender distinção entre versão de produto e versão de pack |

## Inputs obrigatórios

| Input | Descrição |
| --- | --- |
| Tipo de mudança | MAJOR / MINOR / PATCH conforme regras desta skill |
| Versão atual | SemVer atual do produto (ex.: `2.1.0`) |
| Descrição do release | Resumo das mudanças incluídas no release |

## Regras de decisão SemVer

| Tipo | Quando aplicar | Exemplo |
| --- | --- | --- |
| **MAJOR** | API pública quebrada — qualquer mudança que exige adaptação de código do consumidor | Remover método de interface `I*`; mudar assinatura de método público |
| **MINOR** | Feature nova retrocompatível — consumidor pode ignorar e continuar funcionando | Novo método em interface; novo parâmetro opcional; novo engine suportado |
| **PATCH** | Bugfix sem mudança de contrato — corrige comportamento incorreto sem alterar API | Correção de leak de memória; fix de query incorreta; correção de exception handling |

## Workflow executável

1. Identificar o tipo de mudança dominante no release (MAJOR sobrepõe MINOR, MINOR sobrepõe PATCH).
2. Calcular a nova versão SemVer a partir da versão atual.
3. Atualizar `VERSION.md` na raiz do projeto com a nova versão e data.
4. Adicionar entrada no `CHANGELOG.md` com a nova versão, data e lista de mudanças categorizada.
5. Criar tag Git com formato `v{MAJOR}.{MINOR}.{PATCH}` — ex.: `v2.2.0`.
6. Confirmar ao usuário: versão anterior → nova versão, tipo de bump aplicado.

## Outputs obrigatórios

| Output | Descrição |
| --- | --- |
| `VERSION.md` atualizado | Versão e data do release registradas |
| Entrada no `CHANGELOG.md` | Categoria + itens do release adicionados |
| Tag Git criada | `v{X.Y.Z}` apontando para o commit de release |

## Checklist de validação

- [ ] Tipo de bump correto conforme regras MAJOR/MINOR/PATCH.
- [ ] `VERSION.md` reflete a nova versão.
- [ ] `CHANGELOG.md` tem entrada com data e itens categorizados.
- [ ] Tag `v{X.Y.Z}` criada no repositório.
- [ ] Para MAJOR: `version-breaking-change-guard` foi executado previamente.
- [ ] Para MAJOR: `version-migration-assistant` foi executado previamente.

## Anti-padrões

| Anti-padrão | Por que errado | Como corrigir |
| --- | --- | --- |
| Bumpar MAJOR por mudança interna não-pública | MAJOR sinaliza quebra para consumidores — não para mudanças internas | Verificar se a mudança afeta API pública; se não, usar MINOR ou PATCH |
| Não documentar o que quebrou no MAJOR | Consumidores não sabem o que precisam adaptar | Registrar cada breaking change com antes/depois no CHANGELOG.md |
| Criar tag sem entrada de changelog | Impossível saber o que mudou na versão | Sempre criar entrada no CHANGELOG antes de criar a tag |
| Bumpar sem consolidar todos os commits do release | Versão pode ficar incompleta ou imprecisa | Revisar todos os commits desde o release anterior antes de classificar |

## Avaliação de risco

| Risco | Probabilidade | Impacto | Mitigação |
| --- | --- | --- | --- |
| Classificar MAJOR como MINOR por engano | Média | Alto — consumidores quebram silenciosamente | Executar `version-breaking-change-guard` antes de todo release |
| Tag criada antes do CHANGELOG | Média | Médio — rastreabilidade comprometida | Workflow obriga CHANGELOG antes da tag |
| Versão desalinhada entre `VERSION.md` e tag Git | Baixa | Alto — inconsistência de referência | Checklist inclui verificação de coerência |

## Métricas de sucesso

- `VERSION.md` sempre reflete a versão ativa do produto.
- Cada tag Git tem exatamente uma entrada correspondente no `CHANGELOG.md`.
- 0 releases com MAJOR sem documentação de breaking changes.

## Responsável principal

| Papel | Quem |
| --- | --- |
| Decisão de bump | Tech Lead (humano) |
| Execução | Tech Lead ou `dev-agent-providers-orm-expert` |

---

## Versão interna (arquivo)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Skill nova V2 — criada para lacuna version no plano de migração V2.6.

---
name: version-breaking-change-guard
description: Avalia impacto de breaking change ANTES de aplicar — mapeia todos os consumidores da API a ser quebrada na codebase do projeto, quantifica o impacto e gera relatório com lista de arquivos afetados e plano de migração. Opera obrigatoriamente antes de qualquer mudança que quebre interface pública.
model: opus
thinking: extended
category: version
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Version Breaking Change Guard

## Responsabilidade única

Esta skill realiza **análise profunda de impacto** de mudança breaking antes de qualquer alteração ser aplicada — escaneia toda a codebase em busca de usos da API que vai mudar, quantifica o número de arquivos e chamadas afetadas, gera relatório detalhado com lista de arquivos afetados e plano de migração concreto. A aprovação humana é obrigatória antes de prosseguir. Não aplica a mudança — apenas avalia e documenta o impacto.

## When to use

- Antes de renomear ou remover qualquer método público de interface `I*`.
- Antes de mudar a assinatura de método público (parâmetros, tipo de retorno).
- Antes de qualquer bump MAJOR de versão do produto.
- Quando houver dúvida se uma mudança é MINOR ou MAJOR.

## When NOT to use

- Para mudança interna não-pública (métodos privados, unidades internas de `src/Modulos/`) → usar `quality-refactoring-safe`.
- Para iniciar ciclo gradual de deprecação com prazo → usar `version-deprecation-policy`.
- Para aplicar a mudança já aprovada → prosseguir diretamente após aprovação humana obtida por esta skill.

## Dependências (skills prévias)

| Skill | Quando executar antes |
| --- | --- |
| `governance-refactoring-compatibility-policy` | Obrigatório — define política de compatibilidade e decisão entre backward compat / deprecated / quebrar agora |
| `version-semver-product` | Referência para classificação MAJOR do release resultante |

## Inputs obrigatórios

| Input | Descrição |
| --- | --- |
| API a quebrar | Identificador completo — ex.: `IConnection.Connect(AHost: string)` |
| Motivo da mudança | Por que a API precisa ser alterada (nova funcionalidade, consolidação, simplificação) |
| Proposta de nova API | Como a API ficará após a mudança (assinatura, comportamento) |

## Workflow executável

1. **Identificar API a quebrar** — nome completo da interface/método/propriedade com unit de origem.
2. **Escanear consumidores** — buscar em toda a codebase (`src/`, `Views/`, testes) todos os arquivos que referenciam a API identificada; listar com path e número de linha.
3. **Quantificar impacto** — contar total de arquivos afetados, total de ocorrências, classificar por severidade (direto vs. indireto).
4. **Gerar plano de migração** — para cada ponto de uso, descrever o que precisa mudar (busca/substituição, adaptação lógica, novo parâmetro).
5. **Obter aprovação humana** — apresentar relatório completo e aguardar aprovação explícita antes de qualquer alteração de código.

## Outputs obrigatórios

| Output | Descrição |
| --- | --- |
| Relatório de impacto | Lista de todos os arquivos afetados com paths e linhas |
| Contagem de ocorrências | Total de arquivos e chamadas impactadas |
| Plano de migração | Passos concretos por arquivo/uso para adaptar ao novo contrato |
| Decisão registrada | Aprovação humana documentada antes de proceder |

## Checklist de validação

- [ ] 100% dos arquivos de `src/` escaneados por usos da API.
- [ ] `Views/` e testes também escaneados.
- [ ] Relatório de impacto gerado com paths e linhas.
- [ ] Plano de migração tem passo concreto para cada ocorrência.
- [ ] Aprovação humana registrada explicitamente antes de qualquer alteração.
- [ ] `governance-refactoring-compatibility-policy` foi consultada previamente.

## Anti-padrões

| Anti-padrão | Por que errado | Como corrigir |
| --- | --- | --- |
| Quebrar API sem mapear consumidores | Gera falhas de compilação inesperadas em arquivos não considerados | Executar esta skill antes de qualquer breaking change |
| Classificar mudança como MINOR quando quebra contrato | Subestima o impacto — consumidores não esperam quebra em MINOR | Usar tabela de regras de `version-semver-product` para classificar corretamente |
| Não gerar plano de migração | Consumidores sabem que há quebra mas não como se adaptar | Plano de migração é output obrigatório desta skill |
| Prosseguir sem aprovação humana | Breaking change sem revisão pode causar regressões críticas | Aprovação humana explícita é bloqueante — não pular |

## Avaliação de risco

| Risco | Probabilidade | Impacto | Mitigação |
| --- | --- | --- | --- |
| Consumidor não detectado no scan | Baixa | Alto — compilação falha em ponto não mapeado | Scan deve cobrir 100% de `src/` incluindo subpastas |
| Aprovação obtida sem revisão real do relatório | Média | Alto — mudança mal compreendida aplicada | Relatório deve ser explícito e legível; humano assina conscientemente |
| Plano de migração incompleto | Média | Médio — adaptação parcial gera bugs sutis | Cada ocorrência no relatório deve ter passo correspondente no plano |

## Métricas de sucesso

- 100% dos consumidores mapeados antes de qualquer breaking change aplicada.
- Plano de migração com passo concreto para cada ocorrência identificada.
- 0 breaking changes aplicadas sem aprovação humana registrada.

## Responsável principal

| Papel | Quem |
| --- | --- |
| Agent executor | `dev-agent-providers-orm-expert` |
| Aprovação obrigatória | Humano (Tech Lead) |

---

## Versão interna (arquivo)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Skill nova V2 — criada para lacuna version no plano de migração V2.6.

---
name: quality-regression-guard
description: Guarda de regressão — captura snapshot do comportamento atual antes de qualquer alteração e verifica preservação após a mudança. Trabalha com governance-refactoring-compatibility-policy. Triggers - "guarda de regressão", "baseline antes de refatorar", "verificar regressão", "comparar comportamento antes e depois", "snapshot de testes", "regressão".
model: sonnet
thinking: extended
category: quality
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# quality-regression-guard

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## Responsabilidade única

Esta skill captura o baseline comportamental antes de qualquer refatoração ou bugfix — quais testes passam, quais APIs são chamadas, quais dados são gerados — e compara sistematicamente após a mudança para garantir zero regressões. Ela NÃO define a estratégia de testes (use `quality-test-strategy`); NÃO decide a estratégia de compatibilidade da API (use `governance-refactoring-compatibility-policy`). Atua como instrumento de verificação complementar a ambas.

## When to use

- Antes de qualquer refatoração de código existente.
- Antes de bump de versão com potencial breaking change.
- Ao aplicar bugfix em código com múltiplos consumidores.
- Como gate antes de merge de branch de refatoração.

## When NOT to use

- Para testar features completamente novas (sem comportamento anterior a proteger) → use `quality-acceptance-testing`.
- Para definir qual tipo de teste usar em qual camada → use `quality-test-strategy`.
- Para decidir entre backward compat / deprecated / quebrar → use `governance-refactoring-compatibility-policy`.

## Inputs

- Escopo da mudança (módulo, classe, método ou conjunto de units).
- Suite de testes existente ou conjunto de cenários de comportamento observável.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `governance-refactoring-compatibility-policy` | A decisão de estratégia (A/B/C) deve preceder a captura de baseline — o escopo da proteção depende da estratégia escolhida |
| `quality-test-strategy` | A suite de testes a ser usada como baseline deve estar definida antes |

## Workflow executável

1. **Rodar a suite atual** — executar todos os testes do módulo/escopo afetado; registrar resultado (passou/falhou) para cada teste com identificador único.
2. **Documentar o baseline** — salvar snapshot: lista de testes com resultado, APIs públicas chamadas (se observável via log/trace), saídas de dados relevantes (formatos, valores esperados). Formato: tabela `teste | resultado | saída observável`.
3. **Aplicar a mudança** — executar a refatoração ou bugfix planejado; não alterar testes durante esta etapa.
4. **Rodar a suite novamente** — repetir exatamente a mesma execução da etapa 1.
5. **Comparar diff** — contrastar resultado atual com baseline; classificar cada diferença como: (a) regressão (passou → falhou), (b) correção esperada (falhou → passou por ser o bugfix alvo), (c) novo comportamento não coberto antes.

## Checklist de regressão

- [ ] Baseline documentado antes do início da mudança (tabela com todos os testes + resultado).
- [ ] Suite rodada em ambiente limpo (sem estado residual de execução anterior).
- [ ] Diff produzido após a mudança com categorização de cada diferença.
- [ ] Zero regressões (categoria a) na comparação.
- [ ] Comportamento externo observável (APIs, formatos de dados, contratos) idêntico ao baseline.
- [ ] Baseline arquivado em documento ou comentário de commit para rastreabilidade.

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|------------------|---------------|
| Refatorar sem capturar baseline primeiro | Não há como distinguir regressão de correção acidental após a mudança | Sempre executar etapa 1 e 2 antes de qualquer edit |
| Considerar "passa os testes" como suficiente sem verificar comportamento externo | Testes podem passar mas contrato de API mudar silenciosamente | Incluir no baseline o comportamento observável externo: formatos de retorno, exceções lançadas, efeitos colaterais |
| Alterar testes durante a refatoração | Mascara regressões — testes "passam" porque foram ajustados para a nova realidade incorreta | Testes só podem ser alterados após confirmar zero regressões; mudanças em testes são commit separado |
| Baseline apenas verbal ("estava funcionando antes") | Não reproduzível; impossível de comparar objetivamente | Baseline deve ser sempre documento escrito com resultados concretos |

## Métricas de sucesso

- Diff de comportamento = **zero regressões** (categoria a vazia).
- Baseline documentado e arquivado antes de cada mudança significativa.
- Tempo de detecção de regressão: durante o ciclo de desenvolvimento (não em produção).

## Responsável principal

| Papel | Quem |
|-------|------|
| Executor do guard | `dev-agent-backend` |
| Revisor do diff | Tech Lead / Arquiteto |

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Skill nova V2 — criada para lacuna quality no plano de migração V2.6.

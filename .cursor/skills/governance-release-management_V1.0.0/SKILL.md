---
name: governance-release-management
description: Fluxo completo de release do Providers.2.1.0 — coordena freeze, compilação Delphi+FPC para todas as plataformas, execução de testes, verificação de quality gates, publicação e plano de rollback.
model: sonnet
thinking: normal
category: governance-process
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Governance Process — Release Management

## Responsabilidade única

Coordenar o processo de publicação de versão do Providers.2.1.0 do início ao fim: anunciar freeze,
executar compilação Delphi+FPC para Win32 e Win64, rodar suíte de testes de regressão, verificar
quality gates, publicar a release e documentar o plano de rollback. Esta skill **não** trata hotfix
urgente (→ `quality-hotfix-workflow`) nem geração isolada de release notes (→ `version-release-notes`).

## When to use

- Ao iniciar processo de release de qualquer versão (major, minor ou patch planejado).
- Após aprovação do código candidato a release.
- Quando o ciclo de desenvolvimento do sprint/milestone estiver concluído.

## When NOT to use

- Para hotfix urgente que não pode aguardar o ciclo completo → usar `quality-hotfix-workflow`.
- Para gerar release notes sem publicar → usar `version-release-notes`.
- Para definir versão SemVer do produto → usar `version-semver-product`.

## Inputs obrigatórios

| Input | Tipo | Descrição |
|-------|------|-----------|
| Versão alvo | Texto (SemVer) | Ex.: 2.1.0 — versão a ser publicada |
| Branch/commit candidato | Texto | Referência do código base da release |
| Release notes rascunho | Texto | Resumo das mudanças para validação |

## Dependências (skills prévias)

| Skill | Motivo |
|-------|--------|
| `version-semver-product_V1.0.0` | Confirmar versão SemVer correta antes do freeze |
| `quality-regression-guard_V1.0.0` | Executar suíte de testes de regressão |
| `version-release-notes_V1.0.0` | Gerar/finalizar release notes antes da publicação |

## Workflow executável

1. **Freeze** — anunciar congelamento do branch candidato: nenhum commit não aprovado pode entrar
   após o freeze; comunicar data/hora do freeze para a equipe; verificar que não há PR aberto
   pendente para o milestone; confirmar versão SemVer com `version-semver-product`.

2. **Build Delphi + FPC** — compilar para todas as plataformas suportadas:
   - Delphi Win32: `dcc32 ProvidersORM.dpr`
   - Delphi Win64: `dcc64 ProvidersORM.dpr`
   - FPC Win32: `D:\fpc\fpc\bin\i386-win32\fpc.exe @fpc32.opts ProvidersORM.lpr`
   - FPC Win64: `D:\fpc\fpc\bin\x86_64-win64\fpc.exe @fpc64.opts ProvidersORM.lpr`
   - Tratar qualquer erro de compilação como bloqueador de release.

3. **Testes** — executar suíte completa via `quality-regression-guard`; confirmar cobertura dos
   cenários críticos (conexões multi-engine, ORM, pool, parâmetros, exceções); registrar resultado
   da suíte (pass/fail por módulo).

4. **Quality gates** — verificar critérios mínimos antes de autorizar publicação:
   - Zero falhas de compilação em todas as plataformas
   - Zero regressões na suíte de testes
   - Release notes finalizadas e revisadas
   - CHANGELOG.md atualizado
   - Versão no código-fonte consistente com SemVer alvo

5. **Publicar** — criar tag de versão, gerar artefatos de distribuição, publicar release notes,
   atualizar referências de versão na documentação. Aprovação humana obrigatória para este passo.

6. **Plano de rollback** — documentar antes de publicar: qual versão anterior restaurar, quais
   artefatos substituir, critério objetivo para acionar o rollback (ex.: falha em produção nas
   primeiras 24h), responsável humano pela decisão de rollback.

## Outputs obrigatórios

| Output | Localização | Formato |
|--------|-------------|---------|
| Tag de versão | Repositório git | Tag SemVer anotada |
| Release notes publicadas | `Documentation/Releases/v<versao>.md` | Markdown |
| Plano de rollback | `Documentation/Releases/v<versao>-rollback.md` | Markdown |
| Resultado dos testes | `Documentation/Releases/v<versao>-test-report.md` | Markdown |

## Checklist de validação

- [ ] Versão SemVer confirmada via `version-semver-product`
- [ ] Freeze anunciado e data registrada
- [ ] Compilação Delphi Win32/Win64 sem erros
- [ ] Compilação FPC Win32/Win64 sem erros
- [ ] Suíte de regressão executada — zero falhas
- [ ] Todos os quality gates verificados
- [ ] Release notes revisadas e aprovadas
- [ ] Plano de rollback documentado antes de publicar
- [ ] Aprovação humana registrada para o passo de publicação

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Release sem freeze period | Commits de última hora introduzem regressões não testadas | Anunciar freeze com antecedência e bloquear merges não aprovados |
| Publicar sem testes de regressão | Risco de comportamento incorreto chegar ao usuário | `quality-regression-guard` é pré-requisito obrigatório do passo 5 |
| Sem plano de rollback documentado | Impossível recuperar rapidamente em caso de falha pós-release | Documentar plano de rollback no passo 6 antes de publicar |
| Quality gates ignorados por pressão de prazo | Acumula dívida técnica e regressões silenciosas | Quality gates são bloqueadores — não há exceção por prazo |
| Release notes geradas após publicação | Usuários sem informação sobre mudanças; rastreabilidade comprometida | Finalizar release notes no passo 4, antes do passo 5 |

## Avaliação de risco

- **Parar e confirmar quando:** qualquer compilação falhar ou qualquer teste de regressão falhar —
  não publicar em hipótese alguma sem resolver o bloqueador.
- **Risco baixo:** patch com mudança isolada em módulo sem dependências externas.
- **Risco médio:** minor com novas APIs — verificar breaking change e atualizar documentação.
- **Risco alto:** major com mudanças de contrato — obrigatório período de freeze mais longo,
  testes de integração ampliados e aprovação explícita do Tech Lead.

## Métricas de sucesso

- Zero regressões no release publicado.
- Plano de rollback documentado antes de cada publicação.
- 100% das plataformas compiladas sem erro antes da publicação.
- Release notes disponíveis simultaneamente à publicação.

## Responsável principal

| Papel | Quem |
|-------|------|
| Agent executor | `dev-agent-orchestrator` |
| Aprovação para deploy | Humano (Tech Lead) |

## Referências

- Versão SemVer: `version-semver-product_V1.0.0`
- Regressão: `quality-regression-guard_V1.0.0`
- Release notes: `version-release-notes_V1.0.0`
- Hotfix: `quality-hotfix-workflow_V1.0.0`
- Guia de compilação: `.claude/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md`
- Política de documentação: `.cursor/skills/documentation-general_rules_V2.0.0/SKILL.md`

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.0.0 (09/04/2026): Skill nova V2 — criada para lacuna governance no plano de migração V2.6.

---
name: documentation-project-update
description: Propaga o pack `.cursor/` entre projectos — copia scripts, skills, Templates, agents; limpa orfaos; verifica coerencia. Usar quando precisar sincronizar o pack `.cursor/` de um projecto fonte para um ou mais projectos destino.
model: haiku
thinking: minimal
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation Project Update

## Responsabilidade única

Esta skill sincroniza o pack `.cursor/` para outros repositórios — ela copia ou atualiza skills/agents/rules/templates para um projeto destino sem sobrescrever configurações locais. Existe separada de `sync-cursor-pack.ps1` porque adiciona lógica de validação de conflitos e log de alterações antes e depois de cada operação de cópia.

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |
| **Politica** | `.cursor/VERSION.md` |

## When to use

- Quando o pack `.cursor/` do projecto fonte foi actualizado e os projectos destino precisam receber as alteracoes.
- Quando o utilizador pedir para "sincronizar .cursor", "propagar pack", "actualizar skills noutro projecto" ou `/sync-cursor-pack`.
- Quando um novo projecto for criado e precisar receber o pack `.cursor/` completo.
- Apos migracoes ou actualizacoes significativas do pack (ex.: novas skills, agents renomeados, templates actualizados).

## When NOT to use

- Quando quer criar skills novas do zero → usar o template em `.cursor/Templates/` e a skill `skill-creator` para scaffolding estruturado.
- Quando quer validar integridade do pack sem propagar → usar `pack-checklist-validation`, que inspeciona sem realizar cópias.
- Quando quer apenas atualizar documentação de um único projeto sem propagar o pack → usar `documentation-project-bootstrap` ou editar diretamente.

## Dependências (skills prévias)

| Skill | Papel | Obrigatória? |
| --- | --- | --- |
| `pack-checklist-validation` | Valida integridade do pack fonte antes da propagação — recomendado executar primeiro para garantir que não há arquivos corrompidos ou ausentes | Não (mas recomendada) |
| `pack-versioning-policy` | Define as regras de versionamento do `VERSION.md` — necessária para comparar versões entre fonte e destino corretamente | Não (referência de política) |

## Inputs

1. `<projecto_fonte>` (opcional): caminho do projecto fonte (padrao: projecto actual).
2. `<projectos_destino>`: lista de caminhos dos projectos destino (obrigatorio, pelo menos 1).
3. `<modo>` (opcional): `full` (copia tudo) | `incremental` (apenas alterados desde ultima sync) | `validate` (apenas verificar, sem copiar). Padrao: `full`.
4. `<excluir>` (opcional): lista de pastas/ficheiros a excluir da propagacao (ex.: `plans/`, ficheiros especificos do projecto).

## O que e propagado

| Area | Conteudo | Notas |
| --- | --- | --- |
| `scripts/` | Todos os scripts PowerShell de automacao | Inclui `bootstrap-mirror-symlinks.ps1`, `bootstrap-build-config.ps1`, etc. |
| `skills/` | Todas as pastas `*_Vx.y.z/` com `SKILL.md` | Remover skills obsoletas no destino |
| `Templates/` | Ficheiros-modelo `TEMPLATE_*` e subpastas | Inclui templates de build-config, rules-modelo, etc. |
| `agents/` | Todos os `doc-agent-*` e `dev-agent-*` | Manter versao mais recente |
| `Constitution/` | Politicas meta-documentais | SSOT: nunca editar no destino |
| `rules/` | Templates genericos `project-*.mdc` | Regras especificas do projecto NAO sao propagadas |
| `commands/` | Comandos slash `.md` | Novos comandos disponibilizados |
| Ficheiros raiz | `compile.md`, `database.md`, `diretivas_compilacao.md`, `VERSION.md`, `README.md`, `MIRRORS_VALIDATION.md` | Sobrescrever no destino |

## O que NAO e propagado

- `plans/` — planos sao especificos de cada projecto.
- `settings.json` / `settings.local.json` — configuracoes locais de cada IDE.
- Ficheiros `.cursor/rules/` com conteudo especifico do projecto destino (gerados por `documentation-rules_creator`).
- Espelhos (`.claude/`, `.vscode/`, `.continue/`, `.opencode/`) — recriados pelo bootstrap de espelhos no destino.

## Passos

1. **Validar fonte**: verificar que `<projecto_fonte>/.cursor/` existe e contem `VERSION.md`.
2. **Validar destinos**: para cada projecto destino, verificar que o caminho existe.
3. **Inventariar diferengas**: comparar `VERSION.md` da fonte e do destino; listar ficheiros novos, alterados e removidos.
4. **Copiar areas propagaveis**: copiar scripts, skills, Templates, agents, Constitution, commands e ficheiros raiz.
5. **Limpar orfaos no destino**: remover skills, agents ou templates que ja nao existem na fonte (com confirmacao).
6. **Executar bootstrap de espelhos no destino**: invocar `bootstrap-mirror-symlinks.ps1 -Repair` em cada projecto destino para recriar symlinks.
7. **Verificar coerencia**: validar que `VERSION.md` do destino corresponde a fonte; listar eventuais conflitos.
8. **Relatorio**: emitir lista de ficheiros copiados, removidos, ignorados e conflitos.

**Referencia de script:** `sync-cursor-pack.ps1` (a criar em `.cursor/scripts/`) automatiza os passos 3 a 7.

## Criterios de aceite

- [ ] Todas as areas propagaveis estao sincronizadas nos projectos destino.
- [ ] Skills e agents obsoletos foram removidos do destino (ou sinalizados).
- [ ] Espelhos recriados nos projectos destino (`bootstrap-mirror-symlinks.ps1 -Repair`).
- [ ] `VERSION.md` do destino corresponde a versao da fonte.
- [ ] Relatorio de sync emitido com lista completa de accoes.
- [ ] Nenhum ficheiro especifico do projecto destino foi sobrescrito (plans, rules especificas, settings).

## Anti-padrões

| Anti-padrão | Por que errado | Como corrigir |
| --- | --- | --- |
| Propagar o pack sem verificar `VERSION.md` da fonte primeiro | Pode distribuir uma versão desatualizada ou corrompida do pack para todos os destinos | Sempre validar `VERSION.md` e integridade do pack fonte com `pack-checklist-validation` antes de iniciar a propagação |
| Sobrescrever `plans/` ou `settings.json` nos destinos | Destrói configurações locais e planos específicos de cada projeto irreversivelmente | Manter esses caminhos na lista de exclusão e nunca incluí-los na propagação |
| Remover skills "obsoletas" no destino sem confirmação do usuário | Um projeto destino pode depender de uma skill antiga que não foi atualizada na fonte por engano | Listar as skills a remover e exigir confirmação explícita antes de deletar |

## Métricas de sucesso

- `VERSION.md` idêntico entre fonte e todos os destinos após a sync — verificável comparando o hash do arquivo em cada projeto destino com o da fonte.
- Relatório de sync emitido com zero conflitos não resolvidos — cada arquivo copiado, ignorado ou removido deve estar listado e justificado no relatório final.

## Responsável principal

| Papel | Quem |
| --- | --- |
| Agent executor | `doc-agent-orchestrator` |
| Aprovador humano | Desenvolvedor |
| Revisor de conflitos | Tech Lead (quando houver divergências entre fonte e destino) |

## Relacao com outras skills

| Skill | Relacao |
| --- | --- |
| `documentation-project-bootstrap` | Complementar — bootstrap cria `Documentation/`; esta skill propaga `.cursor/` |
| `documentation-rules_creator` | Rules especificas do projecto NAO sao propagadas; apenas templates genericos |
| `pack-versioning-policy` | `VERSION.md` e a referencia para comparar versoes entre fonte e destino |
| `pack-checklist-validation` | Valida integridade do pack antes e depois da propagacao |

## Changelog (este arquivo)

- 1.1.0 (08/04/2026): Migração V2 — adicionadas seções Responsabilidade única, When NOT to use, Dependências, Anti-padrões, Métricas de sucesso, Responsável principal; frontmatter com thinking e category.
- 1.0.0 (04/04/2026): Versao inicial — propagacao do pack `.cursor/` entre projectos; inventario, copia, limpeza de orfaos, bootstrap de espelhos, relatorio.

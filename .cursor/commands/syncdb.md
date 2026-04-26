---
name: syncdb
description: Sincroniza os índices SQLite (FTS5) do pack .cursor/, do workspace .workspace/ e dos docs técnicos locais em E:\.docs\ com o estado actual dos ficheiros. Usa hash SHA-256 para upsert incremental — só re-indexa o que mudou. Inclui validação post-scan. Se E:\.docs\ não existir, o scope project é silenciosamente saltado.
---

# /syncdb

Sincroniza os índices SQLite + FTS5 do pack, do workspace e dos docs técnicos.

## Escopo

Força o rebuild incremental das três bases de índice:

- **`.cursor/index.db`** — pack genérico (skills + agents + rules), propagado via `sync-cursor-pack`.
- **`.workspace/index.db`** — artefactos específicos do clone actual (prefixo `<projectId>-*` em `.workspace/`, ex.: `activedirectoryorm-*`), não propagado.
- **`E:\.docs\index.db`** — documentação técnica offline local (Assembly, Delphi, LDAP em `E:\.docs\`), fora do repo. **Opcional** — se `E:\.docs\` não existir, o scope `project` é saltado com `[skip]` sem erro.

**Objetivo:** manter a base de dados pesquisável consistente com o filesystem, permitindo que a IA use `pack_index_db.py --query` como primeira fonte de informação (offline-first).

**NÃO invocar** se estiver a fazer várias edições seguidas — aguardar o fim da sessão de edição antes de correr.

## Quando usar

- Após criar/editar/eliminar skills, agents, rules ou ficheiros em `E:\.docs\` / `.workspace/`.
- Após `sync-cursor-pack` no destino (força rebuild com paths locais).
- Se `pack_index_db.py --query` devolver resultados desactualizados.
- Como passo de validação no fim de cada onda do refactor.
- Ao fim de qualquer session que criou documentação nova em `.docs/<tech>/` (scope `project`).

## Uso

```text
/syncdb                   # scan de ambos (cursor + workspace)
/syncdb --cursor          # só .cursor/
/syncdb --workspace       # só .workspace/
/syncdb --full            # drop + recreate (ignora cache; após mudança de schema)
/syncdb --stats           # apenas mostra estatísticas, sem re-indexar
/syncdb --dry-run         # simula; não escreve
```

## Skills invocadas

| Ordem | Skill / script | Papel |
|:-:|---|---|
| 1 | `pack_index_db.py --scan <alvo>` | Varre filesystem + upsert incremental |
| 2 | `pack_index_db.py --stats` | Exibe contadores pós-scan |
| 3 | `validate_pack.py --indexes-fresh` | Gate de validação final |

## Parâmetros implícitos

Lê automaticamente:

- `.cursor/config.json._pack_versions` — para registar versão de cada manifest.
- `.cursor/config.json._frameworks` — para validar paths convencionais.
- `.workspace/context.json.projectId` — para popular coluna `scope` nas entries.

## O que faz internamente

1. Invoca `python .cursor/scripts/pack_index_db.py --scan all`.
2. Mostra estatísticas antes/depois (`N entries, X added, Y modified, Z deleted`).
3. Executa `validate_pack.py --indexes-fresh` (se existir) para confirmar sincronia.
4. Exit codes: `0` sucesso · `1` erro de parse/scan · `2` validação falhou.

## Exemplos de uso

### Após criar skill nova

```text
/syncdb
```

Saída esperada:

```text
[scan cursor] db=index.db +1 ~0 -0 =224
[scan workspace] db=index.db +0 ~0 -0 =0
[scan project] db=E:\.docs\index.db +0 ~0 -0 =N   (ou [skip] E:\.docs\ ausente)
[stats] cursor: 225 total (skills: 181, agents: 33, rules: 10)
[validate] indexes-fresh: PASS
```

### Após rename em massa

```text
/syncdb --full
```

### Só consultar stats

```text
/syncdb --stats
```

## Fluxo pós-execução

Depois de `/syncdb` reportar sucesso, a IA pode usar:

```bash
python .cursor/scripts/pack_index_db.py --query "keywords" --type skill --scope cursor
```

para busca rápida sem carregar SKILL.md completo.

## Integração com outros commands

- **`/sync-cursor-pack`** — após sync para projeto destino, rodar `/syncdb --full` no destino para rebuild com paths locais.
- **`/validate-docs`** — complementa; `/syncdb` foca índice, `/validate-docs` foca qualidade textual da Documentation/.
- **`/consolidar`** — invoca `/syncdb --stats` como parte do relatório.

## Changelog

- 1.1.0 (18/04/2026): Adicionado scope `project` (`E:\.docs\index.db`) para docs técnicos locais em `E:\.docs\`. Skip silencioso se `E:\.docs\` ausente.
- 1.0.0 (17/04/2026): Comando criado na Onda 1 do refactor — gestor do pack_index_db.py.

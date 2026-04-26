---
name: commands-pack-manifest
description: Manifesto da pasta .cursor/commands/ — inventário de commands activos com FileVersion e descrição
type: manifest
FileVersion: 1.8.0
FolderVersion: 1.8.0
---

# Versão interna — `.cursor/commands/`

**FolderVersion:** 1.8.0 · **Data:** 25/04/2026
**Política:** [../VERSION.md](../VERSION.md)

Commands activos:

| Arquivo | FileVersion | Descrição |
| ------- | :---------: | --------- |
| `migration-plan.md` | 1.1.0 | Gera plano de migração documental — analisa gaps, propõe fases com matriz origem/destino |
| `sync-cursor-pack.md` | 1.1.0 | Propaga o pack `.cursor/` para projectos destino via `sync_cursor_pack.py` |
| `validate-docs.md` | 1.1.0 | Valida integridade da documentação e conformidade de artefactos |
| `consolidar.md` | 1.0.0 | Auditoria consolidada (cursor, docs, source ou all) — rota para a família `project-consolidate-*` |
| `iniciar.md` | 1.0.0 | Bootstrap do projecto via `/iniciar` quando nao existe `.dpr`/`.lpr` — fluxo interativo e geracao de build config |
| `autostart.md` | 1.0.0 | Executa o protocolo de auto-start (espelhos + deteccao + criacao interativa) conforme a rule `project-autostart-bootstrap` |
| `syncdb.md` | 1.0.0 | Sincroniza as bases SQLite de indexação (pack/docs/project) via `pack_index_db.py` |
| `audit.md` | 1.1.0 | Gera laudo técnico profissional Delphi — Quest (tipo/escopo/finalidade/contexto) antes de executar |
| `spec.md` | 1.1.0 | Gera SPEC por engenharia reversa — Quest (escopo/nível/destino/finalidade) antes de executar |
| `write.md` | 1.0.0 | Inicia sessão de escrita de código Delphi com todos os padrões aplicados |
| `tdd.md` | 1.0.0 | Gera suite DUnitX para o projeto ou classe específica |
| `review.md` | 1.0.0 | Revisão rápida de código Delphi — detecta violações de padrão |
| `new-project.md` | 1.0.0 | Bootstrap interativo de projeto novo Delphi/FPC via scripts PS1 |
| `doc.md` | 1.0.0 | Documenta classes/interfaces/métodos via pipeline scanner→writer→indexer com Quest de clarificação |

Todos os commands seguem o padrão V2: seções **Escopo**, **Skills invocadas** (tabela), **Parâmetros**, **Comportamento**, **Exemplos de uso**, **Versão interna**, **Changelog**.

## Changelog (este arquivo)

- 1.8.0 (25/04/2026): **FolderVersion** 1.8.0; `spec.md` → V1.1.0: Quest de clarificação com 4 perguntas (escopo, nível, destino, finalidade) + 3 níveis de SPEC (técnica completa/executiva/módulo); linguagem adaptada à finalidade; próximo passo sugerido `/audit`.
- 1.7.0 (25/04/2026): **FolderVersion** 1.7.0; `audit.md` → V1.1.0: Quest de clarificação com 4 perguntas (tipo, escopo, finalidade, contexto técnico) + 3 modos de execução (executivo/completo/direcionado); linguagem adaptada à finalidade; próximo passo sugerido `/spec`.
- 1.6.0 (25/04/2026): **FolderVersion** 1.6.0; inventário completo — adicionados 7 commands do workflow Delphi (audit, spec, write, tdd, review, new-project) que estavam ativos mas ausentes da tabela; novo command `doc.md` (1.0.0) — pipeline de documentação completa de classes com Quest de clarificação (4 perguntas: escopo, detalhe, destino, exclusões). Total: 14 commands ativos.
- 1.5.0 (24/04/2026): **FolderVersion** 1.5.0; reconciliação pós-refactor E7 — renomeado ficheiro V1.4.0 → V1.5.0 (sufixo estava desalinhado com FileVersion interno); tabela corrigida: `autostart-bootstrap.md` → `autostart.md` (nome real do ficheiro) e adicionado `syncdb.md` (1.0.0) que estava ausente do inventário.
- 1.4.0 (24/04/2026): **FolderVersion** 1.4.0; novo command `autostart-bootstrap.md` (1.0.0) — comando manual para executar o protocolo completo de auto-start conforme a rule.
- 1.3.0 (24/04/2026): **FolderVersion** 1.3.0; novo command `iniciar.md` (1.0.0) — slash command `/iniciar` para bootstrap e criacao interativa quando nao existe `.dpr`/`.lpr`.
- 1.2.0 (16/04/2026): **FolderVersion** 1.2.0; novo command `consolidar.md` (1.0.0) — slash command `/consolidar <alvo>` que invoca a família `project-consolidate-*` (orchestrator + 3 especializadas). 4 commands no total.
- 1.1.0 (09/04/2026): Manifesto inicial da pasta `commands/` — 3 commands em FileVersion 1.1.0; padrão V2 completo.

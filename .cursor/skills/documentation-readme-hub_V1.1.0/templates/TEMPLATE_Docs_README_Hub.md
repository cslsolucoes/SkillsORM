# {NomeProjeto} — Documentação (hub)

**Versao:** `Vx.y`
**Data:** DD/MM/AAAA

Hub central da pasta `Docs/`. Ponto de entrada para toda documentação canônica do projeto.

---

## Estrutura

| Pasta | Conteúdo |
|-------|----------|
| [Analise/](Analise/) | Análises, scans e lacunas do projeto. |
| [Arquitetura/](Arquitetura/) | Documentação de arquitetura e camadas. |
| [Regras de Negocio/](Regras%20de%20Negocio/) | Regras de negócio e invariantes. |
| [Esboco_Telas/](Esboco_Telas/) | Esboços e documentação de telas/formulários. |
| [Roadmap/](Roadmap/) | Roadmap por fases e entregas. |
| [Versionamento/](Versionamento/) | Changelog e histórico de versões. |
| [Backup/](Backup/) | Backups documentais de ciclos anteriores. |
| [html/](html/) | Portal estático (`index.html`, `docs-data.js`); política em skill `documentation-portal-html`. |

---

## Documentos canônicos atuais

| Categoria | Documento | Versão |
|-----------|-----------|--------|
| Hub | [README_Vx.y.md](README_Vx.y.md) | Vx.y |
| Analise | [Analise_Projeto_Vx.y.md](Analise/Analise_Projeto_Vx.y.md) | Vx.y |
| Arquitetura | [Arquitetura_{Projeto}_Vx.y.md](Arquitetura/Arquitetura_{Projeto}_Vx.y.md) | Vx.y |
| Regras de Negócio | [RN_{Projeto}_Vx.y.md](Regras%20de%20Negocio/RN_{Projeto}_Vx.y.md) | Vx.y |
| Telas | [Telas_{Projeto}_Vx.y.md](Esboco_Telas/Telas_{Projeto}_Vx.y.md) | Vx.y |
| Roadmap | [Roadmap_FaseX_Vx.y.md](Roadmap/Roadmap_FaseX_Vx.y.md) | Vx.y |
| Changelog | [CHANGELOG.md](Versionamento/CHANGELOG.md) | — |
| Roteiros consolidados | [ROTEIROS_CONSOLIDADO.md](../ROTEIROS_CONSOLIDADO.md) | Bootstrap, modos de uso, checklist (template: `TEMPLATE_Docs_ROTEIROS_CONSOLIDADO.md`) |
| Lógica de camada (dados) | [LOGICA_DATABASE.md](../LOGICA_DATABASE.md) | Recriação de semântica da camada; opcional por projeto (`TEMPLATE_Docs_LOGICA_DATABASE.md`) |

> **Nota:** Os caminhos relativos assumem `ROTEIROS_CONSOLIDADO.md` e `LOGICA_DATABASE.md` na **mesma raiz** que `README_Vx.y.md` (pasta documental canónica **`Documentation/`**).

---

## Backlog documental

| # | Item | Prioridade | Status |
|---|------|------------|--------|
| 1 | {Item pendente} | Alta/Média/Baixa | [ ] |

---

## Convenções de versionamento

- Documentos versionados: `{Tipo}_{Projeto}_Vx.y.md` (ex.: `Arquitetura_ProvidersORM_V1.0.md`).
- Hub: `README_Vx.y.md` — re-sincronizar após qualquer alteração estrutural.
- Versão semântica: `Vx.y` (major.minor); patch via changelog.

---

**Changelog (este arquivo):**

- Vx.y (DD/MM/AAAA): {descrição da versão}.
- V1.2 (27/03/2026): Linha **html/** na árvore — portal + remissão a skill `documentation-portal-html`.
- V1.1 (27/03/2026): Linhas para **ROTEIROS_CONSOLIDADO.md** e **LOGICA_DATABASE.md** na raiz documental (templates genéricos).
- V1.0 (DD/MM/AAAA): Criação do hub `Docs/`.
---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).

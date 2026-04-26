# Portal HTML — pasta `{DocsRaiz}/html/`

**Propósito:** documentação **estática** navegável no browser (visão geral do produto, módulos, engines, bancos, exemplos), **sem** backend. Os dados vivem em JavaScript; o layout e estilos ficam no HTML.

**Genérico:** substituir `{DocsRaiz}` pela pasta documental do projeto. **Canónica neste ecossistema:** `Documentation` (se na raiz existir apenas `Docs/` ou `docs/`, renomear para `Documentation/` antes de publicar artefactos).

---

## Conformidade e referência

Checklist para considerar o portal **100% conforme** ao padrão do ecossistema:

- **Path:** `{DocsRaiz}/html/` com os três ficheiros (`index.html`, `docs-data.js`, `README.md`) presentes e com caminhos relativos correctos entre si.
- **Comentários e cabeçalhos:** `docs-data.js` deve referir `{DocsRaiz}/html/index.html` (não paths legados como `Docs/html/` se a raiz documental for `Documentation/`).
- **Contrato JS:** variáveis globais esperadas por `index.html` (`MODULES`, `DATABASE_TYPES`, `ENGINES`, `EXAMPLES`, `PROJECT_*` ou equivalente do template) definidas e coerentes com o script de renderização.
- **Manutenção:** alterações relevantes em `Documentation/Versionamento/CHANGELOG.md` (ou equivalente); após editar `docs-data.js`, hard refresh no browser.
- **Hub:** quando o portal for parte do conjunto canónico, o ficheiro `Documentation/README_Vx.y.md` deve mencionar `html/` ou `html/README.md` para o portal não ficar órfão do índice.

**Referência de exemplo completo (Providers ORM):** pasta `Documentation/html/` no repositório ProvidersORM — README local, `docs-data.js` e `index.html` já alinhados a esta política.

---

## Conteúdo esperado da pasta

| Ficheiro | Origem (template) | Função |
|----------|-------------------|--------|
| `index.html` | `TEMPLATE_Docs_html_index.html` | Página única: header, sidebar, secções geradas a partir de `docs-data.js`. |
| `docs-data.js` | `TEMPLATE_Docs_html_docs-data.js` | Constantes `PROJECT_*`, arrays `MODULES`, `DATABASE_TYPES`, `ENGINES`, `EXAMPLES`. |
| `README.md` | **este ficheiro** (copiado e preenchido) | Política da pasta, como editar, como abrir localmente. |

**Opcional (por projeto):** subpasta `assets/` (`logo.svg`, `favicon.ico`, CSS extra); manter caminhos relativos a `index.html`.

---

## Como criar a partir dos templates

1. Criar `{DocsRaiz}/html/` na raiz da pasta documental.
2. Copiar `TEMPLATE_Docs_html_index.html` → `{DocsRaiz}/html/index.html`.
3. Copiar `TEMPLATE_Docs_html_docs-data.js` → `{DocsRaiz}/html/docs-data.js`.
4. Copiar **este** modelo → `{DocsRaiz}/html/README.md` e substituir `{…}`.
5. Preencher `docs-data.js` (módulos, engines, bancos, exemplos) sem alterar os nomes das variáveis que `index.html` espera — se renomear, actualizar o script no HTML.
6. Ajustar `<title>` e meta no `index.html` se não dependerem só de JS.

---

## Abrir no browser

- **Recomendado:** servidor HTTP local na raiz de `{DocsRaiz}/html/` (evita restrições de `file://` a módulos ou fetch em alguns browsers).
  - Exemplo: `npx serve .` ou extensão "Live Server" apontando para `index.html`.
- **`file://`:** pode funcionar se `index.html` apenas incluir `<script src="docs-data.js">` sem imports ES module; testar no browser alvo.

---

## Manutenção

- **Fonte de verdade** dos textos longos: preferir **`{DocsRaiz}/`** em Markdown (Arquitetura, Analise, etc.); o portal HTML resume e aponta links relativos ou absolutos para o repositório, se desejado.
- Após alterar `docs-data.js`, fazer **hard refresh** (Ctrl+F5) para evitar cache.
- Registar mudanças relevantes no **changelog documental** do projeto (`{DocsRaiz}/Versionamento/CHANGELOG.md` ou equivalente).

---

## Contrato mínimo `docs-data.js` ↔ `index.html`

O template HTML assume a existência global (no `window`) das variáveis definidas no ficheiro modelo JS. Se o projecto alterar nomes ou estrutura, **sincronizar** o código de renderização em `index.html`.

Campos típicos por módulo em `MODULES[]`: `id`, `name`, `icon`, `desc`, `path`; opcionais: `interfaces`, `classes`, `files`, `features`, `example`, `note`, `analise`.

---

## `{Nome do projeto}` — notas locais

- **Repositório / build:** {onde clonar; entrypoint de build, se aplicável}
- **Responsável pela pasta html:** {equipa ou "documentação"}
- **Última revisão visual / acessibilidade:** {data ou pendente}

---

**Changelog (este arquivo):**

- 1.1.0 (27/03/2026): Secção **Conformidade e referência** (checklist 100%, hub, exemplo `Documentation/html/`); raiz documental canónica `Documentation/`.
- 1.0.0 (27/03/2026): Template genérico da pasta **`Docs/html`** / **`docs/html`** em `.cursor/Templates/`; complementa `TEMPLATE_Docs_html_index.html` e `TEMPLATE_Docs_html_docs-data.js`.
---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).

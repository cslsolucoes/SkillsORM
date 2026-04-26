# E7 — Lint de Consistência do Pack .cursor/

**Data:** 24/04/2026
**Script:** `.cursor/scripts/validate-skills-consistency.py`
**Comando:** `python .cursor/scripts/validate-skills-consistency.py --format text`
**Ficheiros inspecionados:** 587
**Totais:** **20 CRITICAL** | **111 WARN**
**Exit code:** 1 (há criticals)

---

## Interpretação por categoria

### R1-BOM — 19 CRITICAL

Ficheiros `.md` / `.mdc` iniciados com a sequência UTF-8 BOM (`EF BB BF`). Como o parser YAML do Claude/Cursor espera `---` exactamente no byte 0, a BOM transforma a primeira linha em `﻿---`, o que corrompe o frontmatter e faz a skill perder descoberta.

**Origem provável:** editores Windows (Notepad, VS Code sem configuração UTF-8) ou export do PowerShell com encoding padrão (UTF-16/UTF-8-BOM).

**Correção recomendada:** remover BOM em lote com um script utilitário (`content.lstrip('﻿')` após leitura com `utf-8-sig`). Afecta 4 agents, 1 rule, 5 SKILL.md/subficheiros, 3 READMEs de Templates e 1 template de mirror.

### R3-name-match — 1 CRITICAL

Única skill com `name:` do frontmatter divergente da pasta:

- `developer-delphi-active-directory-orchestrator_V1.0.0/SKILL.md` tem `name: developer-delphi-active-directory` (falta sufixo `-orchestrator`).

**Correção recomendada:** alterar frontmatter para `name: developer-delphi-active-directory-orchestrator`.

### R4-ifdef-pascal — 20 WARN

Blocos ` ```pascal ` com `{$IFDEF FPC}` / `{$IFDEF MSWINDOWS}` sem marcador explícito de anti-padrão nas 3 linhas acima. Maioria legítima (exemplos cross-compile em `developer-delphi-shared-libraries`, `developer-delphi-linux-servers`, `developer-delphi-packaging-delivery`), mas viola a política consolidada de banir IFDEFs dentro de código Pascal *canónico* do pack.

**Correção recomendada (caso a caso):**
1. Se o IFDEF é legítimo (skill cross-platform), adicionar comentário `// exemplo cross-compiler` ou bloco `> ⚠️ exemplo — IFDEFs permitidos em cross-compile` acima.
2. Se é puramente ilustrativo de anti-padrão, antepor marker `❌ anti-padrão:`.

Distribuição: `developer-delphi-shared-libraries` (11), `developer-delphi-linux-servers` (7), 1 em cada de L09 audit/mobile-orchestrator/packaging-delivery/project-expert.

### R5-ref-quebrada — 83 WARN

Maioria em `.cursor/plans/audit/*.md` (documentos da própria onda de refactor) e em `.cursor/agents/*_V1.3.0.md`. Dois subpadrões:

- **`delphi-fpc-*`** (≈ 65 ocorrências): nomenclatura legada herdada do kit antigo. Os agents `developer-delphi-agent-*_V1.3.0.md` continuam a referenciá-la.
- **`developer-delphi-orchestrator` / `project-orchestrator` sem `master-`** (≈ 18 ocorrências): refs antigas antes do rename para `*-master-orchestrator`. Principal concentração em `L01-architecture.md`, `L02-assembly.md`, `L05-mobile-errors.md`, `L18-project-quality-version.md`, `L22-commands-and-summary.md`, `governance-master-orchestrator/SKILL.md:27`, `project-master-orchestrator/SKILL.md:101`, `developer-delphi-master-orchestrator/SKILL.md:265`.

**Correção recomendada:** nova onda de find-replace global:
- `developer-delphi-orchestrator` → `developer-delphi-master-orchestrator`
- `project-orchestrator` → `project-master-orchestrator`
- `delphi-fpc-XXX` → skill-alvo actual (requer triagem item a item)

### R6-acentos — 8 WARN

Descriptions com palavras sem acentuação (provável resíduo de migração PowerShell):

- `convencoes` → `convenções` (developer-delphi-assembly-calling-conventions)
- `depuracao` → `depuração` (developer-delphi-assembly-debugging)
- `expressoes` → `expressões` (developer-delphi-assembly-expressions)
- `publicacao` → `publicação` (developer-delphi-ios-publishing)
- `testes unitarios` → `testes unitários` (developer-delphi-testing-dunitx)
- `integracao` → `integração` (developer-delphi-testing-integration)
- `documentacao` → `documentação` (documentation-class-analysis-generator, documentation-overview-architecture)

**Correção recomendada:** edição directa das descriptions no frontmatter das 8 skills.

---

## Output bruto

Ver `.cursor/plans/audit/_raw-output.txt` (145 linhas) para lista completa.

## Próximos passos sugeridos (fora do escopo E7)

- **E8 (proposto)**: script `fix-bom.py` para remover BOM em lote + correção do mismatch `active-directory-orchestrator`.
- **E9 (proposto)**: varredura global das refs legadas (`delphi-fpc-*`, `*-orchestrator` sem `master-`) com mapa de substituição.
- **E10 (proposto)**: correção das descriptions sem acento nas 8 skills listadas em R6.

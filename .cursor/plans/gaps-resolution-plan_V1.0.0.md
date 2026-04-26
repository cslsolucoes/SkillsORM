# Plano de Resolução de Lacunas — Onda E9

**Versão:** 1.0.0 · **Data:** 24/04/2026
**Ref. HTML:** `skillsorm_analise_e_projecao.html` — aba "Lacunas" + aba "Projeção"
**Objetivo:** Eliminar todas as lacunas P1 e P2 do HTML, cobrir P3 selecionadas, atualizar HTML para 100%
**Aprovado por:** _(aguardando aprovação explícita)_

---

## 0. Resumo executivo

O HTML identifica 11 lacunas distribuídas em 4 criticidades. Este plano cobre **todas as P1 e P2** e
**2 P3 prioritárias**, totalizando **14 skills novas**. As P3 restantes (interop-dll, interop-com,
providers-orm-impl) e as P4 ficam para onda futura.

| Prioridade | Skills | Famílias | Fonte |
|---|---|---|---|
| P1 CRÍTICO | 6 | VCL, FireDAC | `E:\.docs\Delphi\12\topics\` (150 FireDAC, 105 VCL) |
| P2 HIGH | 6 | JSON, Crypto, Indy, Reporting | `E:\.docs\Delphi\12\topics\` (15 JSON, 6 FastReport, 2 Indy, 8 Crypt) |
| P3 selecionadas | 2 | CI/CD, Quality | Conhecimento interno + docs online |
| **Total** | **14** | — | — |

---

## 1. Inventário de skills a criar

### P1 — Críticas (6 skills)

| # | Skill (pasta) | Categoria | Linhas estimadas |
|---|---|---|---|
| P1.1 | `developer-delphi-vcl-orchestrator_V1.0.0` | `developer-delphi` | ~120L |
| P1.2 | `developer-delphi-vcl-forms_V1.0.0` | `developer-delphi` | ~280L |
| P1.3 | `developer-delphi-vcl-components_V1.0.0` | `developer-delphi` | ~300L |
| P1.4 | `developer-delphi-firedac-orchestrator_V1.0.0` | `developer-delphi` | ~130L |
| P1.5 | `developer-delphi-firedac-connection_V1.0.0` | `developer-delphi` | ~320L |
| P1.6 | `developer-delphi-firedac-queries_V1.0.0` | `developer-delphi` | ~340L |

### P2 — High (6 skills)

| # | Skill (pasta) | Categoria | Linhas estimadas |
|---|---|---|---|
| P2.1 | `developer-delphi-json-serialization_V1.0.0` | `developer-delphi` | ~260L |
| P2.2 | `developer-delphi-firedac-transactions_V1.0.0` | `developer-delphi` | ~240L |
| P2.3 | `developer-delphi-reporting-fastreport_V1.0.0` | `developer-delphi` | ~280L |
| P2.4 | `developer-delphi-crypto-security_V1.0.0` | `developer-delphi` | ~260L |
| P2.5 | `developer-delphi-indy-http_V1.0.0` | `developer-delphi` | ~240L |
| P2.6 | `developer-delphi-indy-email_V1.0.0` | `developer-delphi` | ~220L |

### P3 selecionadas (2 skills)

| # | Skill (pasta) | Categoria | Linhas estimadas |
|---|---|---|---|
| P3.1 | `quality-security-audit_V1.0.0` | `quality` | ~200L |
| P3.2 | `developer-delphi-ci-cd-github_V1.0.0` | `developer-delphi` | ~220L |

---

## 2. Fontes de documentação por skill

### VCL (P1.1–P1.3)

Pasta: `E:\.docs\Delphi\12\topics\` (105 tópicos VCL) + `E:\.docs\Delphi\12\vcl\` (31.096 arquivos)

Tópicos chave:
- `VCL_Overview.htm` — visão geral
- `VCL_Form.htm` — TForm, lifecycle, show/hide
- `Introducing_the_Visual_Component_Library_(VCL).htm`
- `Building_a_Windows_VCL_Application.htm`
- `Building_a_Windows_VCL_MDI_Application_Without_Using_a_Wizard.htm`
- `Building_a_Windows_VCL_SDI_Application.htm`
- `Dynamically_Creating_a_VCL_Modal_Form.htm`
- `Dynamically_Creating_a_VCL_Modeless_Form.htm`
- `Creating_a_VCL_Form_Instance_Using_a_Local_Variable.htm`
- `VCL_Styles_Overview.htm`, `Working_with_VCL_Styles.htm`
- `VCL_Actions.htm`, `Creating_Actions_in_a_Windows_VCL_Application.htm`
- `VCL_Components_Categories_Index.htm`
- `Design_Guidelines_(VCL_Only).htm`
- `Tutorial'3A_Connecting_to_a_SQLite_Database_from_a_VCL_Application.htm`
- `Tutorial'3A_Using_LiveBinding_in_VCL_Applications.htm`
- `Default_Exception_Handling_in_VCL.htm`
- `Printing_in_VCL_Applications.htm`
- `Using_the_Main_VCL_Thread.htm`

### FireDAC (P1.4–P1.6 + P2.2)

Pasta: `E:\.docs\Delphi\12\topics\` (150 tópicos FireDAC) + `E:\.docs\Delphi\12\data\` (14.531 arquivos)

Tópicos chave:
- `Architecture_(FireDAC).htm`, `Components_(FireDAC).htm`
- `Establishing_Connection_(FireDAC).htm`, `Defining_Connection_(FireDAC).htm`
- `Common_Connection_Parameters_(FireDAC).htm`, `Configuring_Drivers_(FireDAC).htm`
- `Connect_to_Microsoft_SQL_Server_(FireDAC).htm`, `Connect_to_MySQL_Server_(FireDAC).htm`
- `Connect_to_PostgreSQL_(FireDAC).htm`, `Connect_to_SQLite_database_(FireDAC).htm`
- `Connect_to_Firebird_(FireDAC).htm`, `Connect_to_InterBase_(FireDAC).htm`
- `Executing_Commands_(FireDAC).htm`, `Executing_SQL_Scripts_(FireDAC).htm`
- `Executing_Stored_Procedures_(FireDAC).htm`
- `Fetching_Rows_(FireDAC).htm`, `Browsing_Tables_(FireDAC).htm`
- `Editing_Data_(FireDAC).htm`, `Changing_DataSet_Data_(FireDAC).htm`
- `Filtering_Records_(FireDAC).htm`, `Finding_a_Record_(FireDAC).htm`
- `Caching_Updates_(FireDAC).htm`
- `Array_DML_(FireDAC).htm`, `Asynchronous_Execution_(FireDAC).htm`
- `Calculated_and_Aggregated_Fields_(FireDAC).htm`
- `Data_Type_Mapping_(FireDAC).htm`
- `Auto-Incremental_Fields_(FireDAC).htm`
- `Deploying_(FireDAC).htm`, `Deploying_on_Windows_(FireDAC).htm`
- `FAQ_(FireDAC).htm`, `Debugging_and_Support_(FireDAC).htm`
- `Transactions_(FireDAC).htm` _(se existir)_

### JSON (P2.1)

- `JSON_Objects_Framework.htm`
- `System.JSON.htm`
- `JSON.htm`
- `Readers_and_Writers_JSON_Framework.htm`
- `ParseJSONValue.htm`
- `The_JSON_Data_Binding_Wizard.htm`
- `TFDJSONDataSets.htm`

### FastReport (P2.3)

- `FastReport.htm`
- `Category'3AFastReport.htm`
- `Creating_Reports_with_FastReport_(FireDAC).htm`

### Criptografia (P2.4)

- `Encrypt.htm`
- `InterBase_Database_Encryption.htm`
- Documentação interna de `System.Hash`, `System.NetEncoding`, `IdSSLOpenSSL` (RTL)

### Indy HTTP + Email (P2.5, P2.6)

**Fonte primária (nova):** `E:\.docs\Indy\extracted\` — Indy 10.1.5.0 docs completos, **13.416 arquivos** extraídos de `Indy10.chm` em 24/04/2026.

Cobertura confirmada:
- `TIdHTTP.html` + 184 arquivos relacionados — GET, POST, PUT, DELETE, cookies, redirects, proxies
- `TIdSSLIOHandlerSocketOpenSSL.html` + 132 arquivos — TLS/SSL, certificados, `SSLVersions`, `OnVerifyPeer`
- `TIdSMTP.html` + 149 arquivos — autenticação PLAIN/LOGIN/NTLM, `TIdMessage`, STARTTLS
- `TIdIMAP4.html` + 270 arquivos — folders, fetch, flags, UID, SEARCH, IDLE
- `TIdPOP3.html` + 83 arquivos — list, retrieve, delete, UIDL
- `TIdMessage.html` + 359 arquivos — headers, encoding, multipart, `TIdAttachment`
- `TIdTCPClient.html` / `TIdTCPServer.html` — raw TCP (complementar)
- `!!CLASSES.html` — índice completo de todas as classes Indy

**Fonte secundária:** `E:\.docs\Delphi\12\topics\Indy.htm`, `Securing_Indy_Network_Connections.htm`

### Quality Security Audit (P3.1)

Fonte: conhecimento interno do pack (horse-security, JWT, SQL injection patterns existentes em skills horse)

### CI/CD GitHub (P3.2)

Fonte: conhecimento interno (dcc32/dcc64 CLI, FPC CLI, GitHub Actions YAML patterns)

---

## 3. Antes / Depois

### Antes (estado atual — Onda E8)

```
.cursor/skills/  →  189 pastas físicas
                     186 ativas
                     3 DEPRECATED
```

Lacunas críticas no HTML:
- 🚨 VCL Forms — AUSENTE
- 🚨 FireDAC — AUSENTE
- 🚨 Relatórios — AUSENTE
- ⚠️ JSON / Serialização — PARCIAL
- ⚠️ Criptografia — FRAGMENTADO
- ⚠️ Networking / Indy — AUSENTE

### Depois (pós Onda E9)

```
.cursor/skills/  →  203 pastas físicas
                     200 ativas (+14)
                     3 DEPRECATED (inalterado)
```

Lacunas resolvidas no HTML (P1+P2+2xP3):
- ✅ VCL → 3 skills novas (orchestrator + forms + components)
- ✅ FireDAC → 4 skills novas (orchestrator + connection + queries + transactions)
- ✅ FastReport → 1 skill nova
- ✅ JSON → 1 skill nova
- ✅ Crypto → 1 skill nova
- ✅ Indy HTTP + Email → 2 skills novas
- ✅ CI/CD GitHub → 1 skill nova
- ✅ Quality Security Audit → 1 skill nova

Lacunas que permanecem (para ondas futuras):
- 🔵 Interop DLL / COM (P3)
- 🔵 ProvidersORM implementação (P3)
- 🟢 DevExpress / TMS / ACBr (P4)
- 🟢 Fortes Reports (P4)

---

## 4. Dependências e ordem de execução

```
Bloco A (VCL) — paralelo:
  P1.1 vcl-orchestrator
  P1.2 vcl-forms
  P1.3 vcl-components

Bloco B (FireDAC) — paralelo:
  P1.4 firedac-orchestrator
  P1.5 firedac-connection
  P1.6 firedac-queries
  P2.2 firedac-transactions

Bloco C (complementares) — paralelo:
  P2.1 json-serialization
  P2.3 reporting-fastreport
  P2.4 crypto-security
  P2.5 indy-http
  P2.6 indy-email
  P3.1 quality-security-audit
  P3.2 ci-cd-github

Pós-criação:
  → skills-pack-manifest V1.19.0 → V1.21.0
  → validate_pack.py (0 CRITICAL)
  → validate-skills-consistency.py (0 CRITICAL)
  → Update skillsorm_analise_e_projecao.html
```

---

## 5. Template SKILL.md (frontmatter padrão)

Cada skill segue o template V2.0:

```markdown
---
name: developer-delphi-<nome>
description: >
  <trigger: 1-3 frases descrevendo quando ativar, palavras-chave de ativação>
model: sonnet
thinking: none
category: developer-delphi
---

# <Título completo>

**Versão:** 1.0.0 · **Categoria:** developer-delphi · **Modelo:** claude-sonnet
**Scope:** `.cursor/skills/`
```

---

## 6. Estratégia de backup

- Operação é **apenas criação** — nenhum arquivo existente é modificado
- Rollback = `rm -rf` das 14 pastas novas
- Backup não necessário pois não há modificação de skills existentes
- Validators rodados antes de atualizar o manifest

---

## 7. Atualização do manifest pós-execução

- `skills-pack-manifest_V1.20.0.md` → renomear para `skills-pack-manifest_V1.21.0.md`
- FolderVersion: 1.20.0 → 1.21.0
- Adicionar seção "Onda E9" com as 14 novas skills
- Atualizar total: 189 físicas → 203 físicas; 186 ativas → 200 ativas

---

## 8. Atualização do HTML

Após criação de todas as 14 skills e validação:

- Aba "Lacunas": remover cards P1+P2 resolvidos, manter P3 restantes + P4 como backlog
- Aba "Projeção": marcar P1+P2+2xP3 como ✅ CRIADO
- Stats: 186 → 200 skills ativas
- Subtitle: adicionar "Onda E9 aplicada · manifest V1.21.0"
- Família `developer-delphi-*`: 95 ativas → 108 ativas (+VCL 3, +FireDAC 4, +JSON 1, +FastReport 1, +Crypto 1, +Indy 2, +CI-CD 1)
- Cards VCL e FireDAC: adicionar na aba Famílias

---

## 9. Checklist de execução

| Item | Status |
|---|---|
| P1.1 `vcl-orchestrator` criada | ⬜ |
| P1.2 `vcl-forms` criada | ⬜ |
| P1.3 `vcl-components` criada | ⬜ |
| P1.4 `firedac-orchestrator` criada | ⬜ |
| P1.5 `firedac-connection` criada | ⬜ |
| P1.6 `firedac-queries` criada | ⬜ |
| P2.1 `json-serialization` criada | ⬜ |
| P2.2 `firedac-transactions` criada | ⬜ |
| P2.3 `reporting-fastreport` criada | ⬜ |
| P2.4 `crypto-security` criada | ⬜ |
| P2.5 `indy-http` criada | ⬜ |
| P2.6 `indy-email` criada | ⬜ |
| P3.1 `quality-security-audit` criada | ⬜ |
| P3.2 `ci-cd-github` criada | ⬜ |
| `validate_pack.py` 0 CRITICAL | ⬜ |
| `validate-skills-consistency.py` 0 CRITICAL | ⬜ |
| `skills-pack-manifest` → V1.21.0 | ⬜ |
| `skillsorm_analise_e_projecao.html` atualizado | ⬜ |

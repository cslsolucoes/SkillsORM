# Skills Pack — Manifesto Canônico

**FolderVersion:** 1.25.0 · **Data:** 26/04/2026
**Política de versionamento:** [../VERSION.md](../VERSION.md)

## Contagens

| Métrica | Valor |
|---------|-------|
| **Skills ativas** | **213** |
| **Skills físicas** | **221** |
| **Agents** | 36 |
| **Commands** | 13 |

---

## Delta E13 — Documentation Quality Gates (26/04/2026)

### Bump in-place de 5 skills (rename de pasta + edição do SKILL.md)

| Skill | Versão antes | Versão depois | Mudanças principais |
|-------|--------------|----------------|---------------------|
| `documentation-master-orchestrator` | V1.1.0 | **V1.2.0** | Workflow obrigatório de 5 fases (scan → bootstrap → coverage-plan → geração → coverage-final); 7 arquivos canônicos em `Documentation/Decisions/`; 3 novos anti-padrões; nova entrada na matriz |
| `documentation-project-bootstrap` | V2.1.0 | **V2.2.0** | Parâmetros `<output_path>`, `<structure_mode>`, `<portal_html>`; novo passo 5 cria `Documentation/Decisions/`; 4 novos anti-padrões; 4 novos critérios de aceite |
| `documentation-project-scan` | V1.1.0 | **V1.2.0** | Novo passo 4: cruzamento dependências vs imports (Python/Node/Pascal/Rust/Go/Java); inventário de unidades de código; gera `DEPENDENCY_GAPS.md`; 2 novos anti-padrões |
| `documentation-general_rules` | V2.0.0 | **V2.1.0** | Formaliza os 7 arquivos canônicos em `Documentation/Decisions/` com origem por skill; 2 novos anti-padrões |
| `documentation-class-analysis-generator` | V1.1.0 | **V1.2.0** | Threshold de agregação dura: ≥5 unidades = doc individual obrigatória; 2–4 exigem `AGGREGATION_RATIONALE.md`; 2 novos anti-padrões |

**Net E13:** 0 ativas / 0 físicas (5 bumps in-place, sem nova pasta).
**Trigger:** lacunas detectadas durante documentação Fase 1 do GDoc — agente fez agregação indevida e pulou gates.
**Backup:** `.cursor/Backup/skills/<timestamp>/` antes da edição.

---

## Delta E12 — Indy Completion (25/04/2026)

### Enriquecimento in-place (2 skills existentes)

| Skill | Seções adicionadas |
|-------|-------------------|
| `developer-delphi-indy-http_V1.0.0` | §9 PATCH/HEAD · §10 progress events (OnWork) · §11 response headers + cookies (TIdCookieManager) · §12 download assíncrono com TTask · §13 TIdHTTPServer (servidor local/webhook/OAuth callback) · §14 checklist atualizado |
| `developer-delphi-indy-email_V1.0.0` | §8 decodificar mensagem recebida (partes MIME) · §9 extrair e salvar anexos · §10 Reply/Forward com headers de threading (InReplyTo, References) · §11 envio em lote com reconexão · §12 checklist atualizado |

### 2 novas skills criadas

| Skill | Responsabilidade |
|-------|-----------------|
| `developer-delphi-indy-ftp_V1.0.0` | TIdFTP: autenticação FTP/FTPS (explícito + implícito), upload/download, listagem, operações em diretórios, renomear, sincronização incremental, progress events |
| `developer-delphi-indy-tcp_V1.0.0` | TIdTCPClient, TIdTCPServer multi-thread, TIdCmdTCPServer, framing length-prefix, heartbeat com TTask, SSL/TLS sobre TCP, broadcast para clientes conectados |

**Net E12:** +2 ativas / +2 físicas (2 enriquecimentos in-place, sem nova pasta)

---

## Delta E11 — Vue.js Skills Improvement (anterior)

+6 ativas / +10 físicas. Pack antes: 205 ativas / 209 físicas.

---

## Delta E10 — Plugin Absorption (anterior)

+5 skills · +1 enriquecida · +4 agents · +6 commands.

---

## Delta E9 — Gaps Resolution (anterior)

+14 skills novas.

---

## Validação

```
Checks: 1548  |  Passed: 1548  |  Issues: 3
[MODERATE] (2): .claude/VERSION.md SYMLINK ausente · .vscode/VERSION.md SYMLINK ausente
[LOW]      (1): .continue/ não existe
CRITICAL: 0
```

---

## Changelog deste arquivo

- 1.25.0 (26/04/2026): **E13 — Documentation Quality Gates**: 5 bumps in-place — `documentation-master-orchestrator` V1.1→V1.2 (workflow obrigatório de 5 fases), `documentation-project-bootstrap` V2.1→V2.2 (`<output_path>`, `<structure_mode>`, `<portal_html>`, `Decisions/`), `documentation-project-scan` V1.1→V1.2 (cruzamento deps↔imports, `DEPENDENCY_GAPS.md`), `documentation-general_rules` V2.0→V2.1 (7 arquivos canônicos em `Decisions/`), `documentation-class-analysis-generator` V1.1→V1.2 (threshold ≥5 = doc individual). Net: 0 ativas / 0 físicas. Pack: **213 ativas / 221 físicas** (inalterado).
- 1.24.0 (25/04/2026): **E12 — Indy Completion**: HTTP enriquecido (§9-§14: PATCH/HEAD, progress, cookies, TTask, TIdHTTPServer); Email enriquecido (§8-§12: decode MIME, anexos, reply/forward, lote); +2 skills novas (indy-ftp, indy-tcp). Net: +2 ativas / +2 físicas. Pack: **213 ativas / 221 físicas**.
- 1.23.0 (24/04/2026): E11 Vue.js: +6 ativas / +10 físicas. Pack: 211 ativas / 219 físicas.
- 1.22.0 (24/04/2026): E10 Plugin absorption: +5 skills, +1 enriquecida, +4 agents, +6 commands. Pack: 205 ativas / 209 físicas.
- 1.21.0 (24/04/2026): E9 Gaps Resolution: +14 skills. Pack: 200 ativas / 204 físicas.
- 1.20.0 (17/04/2026): Pós-split D3: 186 ativas / 190 físicas.

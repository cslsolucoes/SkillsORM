# Skills Pack — Manifesto Canônico

**FolderVersion:** 1.24.0 · **Data:** 25/04/2026
**Política de versionamento:** [../VERSION.md](../VERSION.md)

## Contagens

| Métrica | Valor |
|---------|-------|
| **Skills ativas** | **213** |
| **Skills físicas** | **221** |
| **Agents** | 36 |
| **Commands** | 13 |

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

- 1.24.0 (25/04/2026): **E12 — Indy Completion**: HTTP enriquecido (§9-§14: PATCH/HEAD, progress, cookies, TTask, TIdHTTPServer); Email enriquecido (§8-§12: decode MIME, anexos, reply/forward, lote); +2 skills novas (indy-ftp, indy-tcp). Net: +2 ativas / +2 físicas. Pack: **213 ativas / 221 físicas**.
- 1.23.0 (24/04/2026): E11 Vue.js: +6 ativas / +10 físicas. Pack: 211 ativas / 219 físicas.
- 1.22.0 (24/04/2026): E10 Plugin absorption: +5 skills, +1 enriquecida, +4 agents, +6 commands. Pack: 205 ativas / 209 físicas.
- 1.21.0 (24/04/2026): E9 Gaps Resolution: +14 skills. Pack: 200 ativas / 204 físicas.
- 1.20.0 (17/04/2026): Pós-split D3: 186 ativas / 190 físicas.

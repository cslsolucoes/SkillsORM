# Lógica da camada {NOME_CAMADA_OU_MODULO}

**Propósito (genérico):** descrever **arquitectura e comportamento** de uma camada de acesso a dados (ou equivalente) para que outra equipa ou IA possa **reimplementar a mesma semântica** sem copiar código.

**Destino sugerido:** `{DocsRaiz}/LOGICA_DATABASE.md` — ou `{DocsRaiz}/LOGICA_{MODULO}.md` se o nome `LOGICA_DATABASE` for demasiado específico para o vosso domínio.

**Como usar:** substituir `{…}`; alinhar secções ao vosso stack (linguagem, drivers, ORM, message bus, etc.); manter **Changelog (este arquivo)**.

**Documento complementar:** roteiros de arranque e uso do ecossistema — `{DocsRaiz}/ROTEIROS_CONSOLIDADO.md` (se existir).

---

## 1. Visão geral e ficheiros

- **`{UnitOuPacotePrincipal}`** — {responsabilidade: interface pública, estado, ciclo de vida}
- **`{Auxiliar1}`** — {leitura / escrita / transformação}
- **`{IncludeOuConfig}`** — {constantes, feature flags}

---

## 2. Compilação / feature flags / variantes

- **`{FLAG_OU_PROFILE_A}`** — {efeito}
- **`{FLAG_OU_PROFILE_B}`** — {efeito}
- **Regra:** {ex.: uma variante activa por build; sem misturar drivers}

---

## 3. Modelo de dados e convenções

- **Tabelas / esquemas:** {nomes, prefixos, multi-tenant}
- **Tipos e mapeamentos:** {datas, booleanos, blobs}
- **Thread-safety / concorrência:** {locks, transacções}

---

## 4. Fluxos principais

### 4.1 Conexão e configuração

1. {passo}
2. {passo}

### 4.2 CRUD ou operações de domínio

- {operação} — {pré / pós-condições, erros}

---

## 5. Tratamento de erros

- **Excepções ou códigos:** {hierarquia, mensagens mínimas}
- **Retry / idempotência:** {se aplicável}

---

## 6. Checklist para recriação

- [ ] {item verificável}
- [ ] {item verificável}
- [ ] {item verificável}

---

**Changelog (este arquivo):**

- 1.0.0 (DD/MM/AAAA): Template genérico criado em `.cursor/Templates/` para qualquer projeto.
---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).

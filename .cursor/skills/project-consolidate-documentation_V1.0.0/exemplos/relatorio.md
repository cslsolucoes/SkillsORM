# Consolidação — documentação — 2026-04-16 18:30

## Resumo

| Dimensão | Status | Itens | Falhas |
|----------|:------:|------:|-------:|
| 1. Versionamento | FAIL | 87 | 12 |
| 2. Links quebrados | FAIL | 412 | 5 |
| 3. Estruturação | PASS | 10/10 | 0 |
| 4. Nomenclatura | FAIL | 87 | 3 |
| 5. Hub e Changelog | PASS | 2/2 | 0 |
| 6. Portal HTML | WARNING | 0/2 | — |
| 7. Formato padrão | PASS | 24 | 0 |

**Total:** 3 PASS, 3 FAIL, 1 WARNING.

## Detalhes por dimensão

### 1. Versionamento — FAIL (12)

Arquivos sem seção "Versão interna":

- `Documentation/Analise/Users.md`
- `Documentation/Arquitetura/overview.md`
- `Documentation/BancoDados/tabela-users.md`
- ... (9 outros)

### 2. Links Markdown — FAIL (5)

- `Documentation/README.md:15` → `Arquitetura/OLD_overview.md` (não existe)
- `Documentation/RegrasNegocio/RN-M01-001.md:28` → `../Analise/TUsers.md` (arquivo renomeado)
- ... (3 outros)

### 3. Estruturação — PASS (10/10)

Todas as 10 subpastas obrigatórias presentes.

### 4. Nomenclatura — FAIL (3)

- `Documentation/Analise/TUsers.md` — prefixo `T` não deveria existir → renomear para `Users.md`.
- `Documentation/Analise/IConnection.md` — prefixo `I` não deveria existir → renomear para `Connection.md`.
- `Documentation/RegrasNegocio/RN01-001.md` — formato incorreto → `RN-M01-001.md`.

### 5. Hub e Changelog — PASS

- `Documentation/README.md` presente.
- `Documentation/Versionamento/CHANGELOG.md` presente.

### 6. Portal HTML — WARNING

- `Documentation/html/index.html` ausente.
- `Documentation/html/docs-data.js` ausente.
- Opcional — só gerar via `documentation-portal-html` se desejado.

### 7. Formato padrão — PASS (24)

Todos os 24 RNs em `Documentation/RegrasNegocio/` têm as 12 seções obrigatórias.

## Recomendações acionáveis

1. **Adicionar "Versão interna"** a 12 arquivos listados — seguir template em `documentation-general_rules_V2.0.0`.
2. **Corrigir 5 links quebrados** — validar cada arquivo e atualizar path.
3. **Renomear 3 arquivos** conforme nomenclatura canónica.
4. (Opcional) Gerar portal HTML via `documentation-portal-html_V1.2.0`.

## Próximos passos

- [ ] Aplicar correções em Analise/, RegrasNegocio/ e links.
- [ ] Re-executar `/consolidar docs` para confirmar PASS.

# Continue — Configuracao

**Fonte:** `.cursor/Templates/mirror-config/continue-stub.template.md`

O Continue (continue.dev) nao possui actualmente ficheiros de configuracao especificos neste projecto. A pasta `.continue/` e utilizada como espelho de `.cursor/` via symlinks (skills, rules, agents, etc.).

## Futura configuracao

Quando o Continue adoptar ficheiros de config proprios (ex.: `config.json`), criar um template `continue-config.template.json` nesta pasta (`mirror-config/`) e integrar no script `bootstrap-mirror-symlinks.ps1`.

## Ficheiro exclusivo Continue

O ficheiro `.continue/rules/projeto-fonte-cursor.md` (se existir) e exclusivo do Continue e **nao** provem de `.cursor/rules/`. O script de bootstrap nao o remove nem substitui.

---

**Changelog (este arquivo):**

- 1.0.0 (30/03/2026): Stub inicial para futura configuracao Continue.

---

## Versão interna (ficheiro)

| Campo           | Valor                |
| --------------- | -------------------- |
| **FileVersion** | 1.0.0                |
| **Política**    | `.cursor/VERSION.md` |

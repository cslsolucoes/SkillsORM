# Analise — {NomeModulo}

Base de conhecimento do **módulo {NomeModulo}**: {descrição breve do propósito}.

**Uso:** {quem consome este módulo e como}.

**Localização do código:** `src/Modulos/{NomeModulo}/` — {lista de units principais}.

---

## Status (realidade atual)

| Item | Status | Observação |
|------|--------|------------|
| {Item 1} | [X] / [ ] | {obs} |
| {Item 2} | [X] / [ ] | {obs} |

---

## O que está implementado

- **{Unit principal}:** {descrição resumida}.

---

## O que falta

1. **{Pendência 1}** — {descrição do que precisa ser feito}.
2. **{Pendência 2}** — {descrição}.

---

## Convenção

- Um arquivo por classe/interface principal no padrão canônico: **{ClassName}.md** (nome base sem `T`/`I`).
- Conteúdo: apenas **descrição e responsabilidade** (métodos, variáveis, papel) — sem implementação.

## Índice por unit / tipo

| Unit | Classe / Interface | Arquivo |
|------|--------------------|---------|
| {Unit} | {TClassName} / {IClassName} | [{ClassName}.md]({ClassName}.md) |

## Estrutura do módulo (src/Modulos/{NomeModulo})

- **Interfaces:** {Unit}.Interfaces.pas ({IClassName}).
- **Implementação:** {Unit}.pas ({TClassName}).
- **Exceções:** {onde ficam as exceções do módulo}.

---

**Changelog (este arquivo):**

- 1.0.0 (DD/MM/AAAA): Criação do README do módulo {NomeModulo}.
---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).
# Roteiros consolidados — {TITULO_CURTO}

**Propósito (genérico):** modelo para um único documento que concentra **ordem de arranque** de módulos ou serviços, **roteiros de uso** (ex.: modo mínimo vs. modo avançado) e **checklist de validação** (ex.: variantes de build, ambientes ou integrações).

**Destino sugerido:** `{DocsRaiz}/ROTEIROS_CONSOLIDADO.md` — onde `{DocsRaiz}` é a pasta documental canónica do projeto (ex.: `Docs/`, `docs/`).

**Como usar:** substituir todos os `{…}`; remover secções que não se aplicam; manter o bloco **Changelog (este arquivo)** ao editar.

---

## 1) Escopo e audiência

- **Ferramentas / pastas relevantes:** {ex.: `.cursor/`, CI, monorepo — listar}
- **Leitores:** {ex.: agentes de IA, equipa de plataforma, onboarding}
- **Fora de âmbito:** {ex.: detalhe de uma única API — apontar para outro doc}

---

## 2) Bootstrap ou ordem de inicialização

1. **{ModuloA}** — {accão resumida}
2. **{ModuloB}** — {accão resumida}
3. **{ModuloC}** — {accão resumida}

**Notas de composição / injeção:** {regras que evitem dependências circulares ou acoplamento indevido}

---

## 3) Roteiro de uso — {MODO_1_NOME}

- **Pré-requisitos:** {build flags, config, secrets}
- **Passos:** {lista numerada ou bullets}
- **Erros comuns:** {como diagnosticar}

---

## 4) Roteiro de uso — {MODO_2_NOME} (opcional)

- **Pré-requisitos:** {…}
- **Passos:** {…}

---

## 5) Checklist de validação

- **Variante ou alvo 1:** {critério testável}
- **Variante ou alvo 2:** {critério testável}
- **Registo de resultados:** {onde documentar}

---

## 6) Referências canónicas no repositório

- Este documento: `{DocsRaiz}/ROTEIROS_CONSOLIDADO.md`
- {Documento relacionado}: `{DocsRaiz}/{OUTRO}.md`
- Regras / config: {paths relativos à raiz do repo}

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

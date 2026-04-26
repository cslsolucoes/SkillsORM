# Checklist de implementação — Módulo {NomeModulo}

Ordem de implementação com dependências e links para as especificações ({ClassName}.md). **Regra:** componentes que usam conexão recebem apenas **IConnection**; a origem (pool ou Connection direta) é decidida por quem chama.

## Ordem e dependências

| # | Fase | Descrição | Especificações (Analise) |
|---|------|-----------|--------------------------|
| 1 | 1.1 | {Componente 1} | [{ClassName}.md]({ClassName}.md) |
| 2 | 1.2 | {Componente 2} | [{ClassName}.md]({ClassName}.md) |
| 3 | 1.3 | {Componente 3} | [{ClassName}.md]({ClassName}.md) |

## Regras de arquitetura

- **{Componente A}** recebe e usa apenas a interface **{IClassName}**.
- O módulo **não** chama {operação proibida}.
- {Outra regra relevante}.

## Status por item

| # | Item | Status | Observação |
|---|------|--------|------------|
| 1 | {Componente 1} | [X] / [ ] | {obs} |
| 2 | {Componente 2} | [X] / [ ] | {obs} |

## Referências

- [roadmap_V1.0.mdc](../../.cursor/rules/roadmap_V1.0.mdc)
- [Documentacao_V1.0.mdc](../../.cursor/rules/Documentacao_V1.0.mdc)
- [ESPECIFICACAO_{MODULO}.md](../ESPECIFICACAO_{MODULO}.md)

---

**Changelog (este arquivo):**

- 1.0.0 (DD/MM/AAAA): Criação do checklist de implementação do módulo {NomeModulo}.
---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).
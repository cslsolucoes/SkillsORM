# Docs/Backup — Política de superseded/conflito

Nesta pasta ficam documentos que foram classificados como:

- **superseded**: substituídos por uma versão mais recente do mesmo artefato (mesmo alvo funcional);
- **conflito**: excedentes em colisões de destino canônico (mesmo path pretendido).

---

## Regras

1. Todo arquivo em `Docs/Backup/` deve manter rastreabilidade:
   - nome com evidência de origem (quando possível: `{tipo}_{origem}_{AAAA-MM-DD}.md`);
   - registro no hub `Docs/README_Vx.y.md` após a migração.
2. Sempre que um arquivo for movido para Backup:
   - atualizar hub (sem links órfãos);
   - resolver duplicação residual no índice canônico.
3. Nenhum arquivo em `Docs/Backup/` é excluído sem:
   - confirmação explícita;
   - período de quarentena mínimo de {N} dias ou {N} versões.

---

## Índice de arquivos em Backup

| Arquivo | Origem | Motivo | Data de entrada |
|---------|--------|--------|-----------------|
| `{arquivo}.md` | `{caminho de origem}` | superseded / conflito | DD/MM/AAAA |

---

## Referências de decisão

- skill `documentation-constitution-policies` (superseded-definition)
- skill `documentation-constitution-policies` (migration-conflict-resolution)
- skill `documentation-readme-hub` (hub resync rules)
- [Analise/ANALISE_DIAGNOSTICO_ORGANIZACAO.md](../../Analise/ANALISE_DIAGNOSTICO_ORGANIZACAO.md#cap6) (Cap. 6 — matriz histórica)

---

**Changelog (este arquivo):**

- 1.0.0 (DD/MM/AAAA): Criação da política de Backup de {Projeto}.
---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).

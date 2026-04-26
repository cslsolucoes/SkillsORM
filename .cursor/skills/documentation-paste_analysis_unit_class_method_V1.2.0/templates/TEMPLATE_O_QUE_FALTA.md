# O que falta para 100% — {Projeto} v{X.Y}

**Data:** DD/MM/AAAA | **Versão:** {X.Y.Z}

**Plano de execução das pendências:** {link para plano em `.cursor/plans/` se existir}. Não duplicar escopo de outros planos aqui.

**Atualização DD/MM/AAAA:** {Breve descrição de ciclo concluído ou atualização relevante — ex.: ciclo de reestruturação documental concluído}.

---

## Resumo executivo

{Parágrafo curto: o que está completo e o que falta. Ex.: "O projeto está funcionalmente completo para uso em produção. O que resta são polimentos, validações multi-engine e documentação."}

**Alinhamento com o plano unificado:** {link para seção do roadmap_V1.0.mdc com o checklist detalhado}. Ao atualizar pendências, manter este arquivo e a tabela referenciada em sincronia.

### Plano de execução das pendências

O que está **pendente** neste documento é executado pelo plano em `.cursor/plans/`. Ordem sugerida:
- **Bloco A** — {categoria de itens, ex.: limpeza e CHANGELOGs}.
- **Bloco B** — {categoria, ex.: funcionalidades assimiladas}.
- **Bloco C** — {categoria, ex.: validação multi-engine}.

Ao concluir cada item, atualizar status `[X]`/`[ ]` neste arquivo e no roadmap.

---

## Mapa completo — `.cursor` e `src/`

### `.cursor` — Estrutura e cobertura

| Onde | Arquivo / pasta | Status | Observação |
|------|-----------------|--------|------------|
| **rules** | {arquivo}.mdc | [X] / [ ] | {observação} |
| **plans** | {plano}.plan.md | [X] / [ ] | {observação} |
| **skills** | {skill} | [X] / [ ] | {observação} |
| **raiz `.cursor`** | {doc}.md | [X] / [ ] | {observação} |

**Lacunas `.cursor`:** {resumo — ex.: "Nenhuma regra essencial faltando."}.

### `src/` — Módulos e arquivos

| Módulo / pasta | Cobertura | Falta (para 100%) |
|----------------|-----------|-------------------|
| **{Módulo}** | [X] {o que está OK} | {o que falta ou "—"} |
| **{Módulo}** | [X] {o que está OK} | {o que falta} |

### Data e Docs

| Item | Status | Observação |
|------|--------|------------|
| {item} | [X] / [ ] | {obs} |

---

## Checklist detalhado de pendências

### 1. {Categoria — ex.: Funcionalidades núcleo}

- [X] {Item concluído}.
- [ ] {Item pendente — descrição clara do que precisa ser feito}.

### 2. {Categoria — ex.: Validação multi-engine}

- [ ] {Item pendente}.
- [ ] {Item pendente}.

### 3. {Categoria — ex.: Documentação e roteiros}

- [X] {Item concluído}.
- [ ] {Item pendente}.

---

## Sprint / backlog imediato

| ID | Item | Prioridade | Status |
|----|------|------------|--------|
| SP-01 | {item} | Alta/Média/Baixa | [ ] |
| SP-02 | {item} | Alta/Média/Baixa | [ ] |

---

**Referências:** [{Projeto}.dpr](../{Projeto}.dpr) | [roadmap_V1.0.mdc](../.cursor/rules/roadmap_V1.0.mdc) | [ANALISE_DIAGNOSTICO_ORGANIZACAO.md](../ANALISE_DIAGNOSTICO_ORGANIZACAO.md#cap4) (Cap. 4 — inventário DPR)

---

**Changelog (este arquivo):**

- {X.Y.Z} (DD/MM/AAAA): {descrição da atualização}.
- 1.0.0 (DD/MM/AAAA): Criação do documento de pendências.
---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).
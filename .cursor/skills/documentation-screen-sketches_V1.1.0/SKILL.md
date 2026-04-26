---
name: documentation-screen-sketches
description: Gera rascunhos/documentação de telas e fluxos em `Documentation/Esboco_Telas/` com conteúdo claro, rastreável e operacional.
model: haiku
thinking: normal
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation Screen Sketches

## Responsabilidade única

Esta skill é a responsável exclusiva pela geração de esboços e documentação de telas, wireframes e fluxos de UI em `Documentation/Esboco_Telas/`. Resolve o problema de fluxos de interface sem registo formal, tornando cada tela rastreável com objetivos, entradas/saídas e tratamento de erros testáveis. Existe separada de `documentation-business-rules` porque esboços de tela descrevem **interação e fluxo de utilizador** enquanto RNs descrevem **invariantes de negócio**; os dois artefactos se complementam mas não se substituem. A skill produz documentação suficientemente detalhada para orientar implementação de UI sem substituir um protótipo de alta fidelidade.

## When NOT to use

- Quando o objetivo for documentar regras de negócio ou invariantes de comportamento do sistema — usar `documentation-business-rules`.
- Quando o objetivo for gerar documentação de classes e interfaces do código-fonte — usar `documentation-class-analysis-generator`.
- Quando o objetivo for criar um roadmap documental — usar `documentation-roadmap-from-docs`.
- Quando o objetivo for documentar arquitetura geral (módulos, ADRs, decisões) — usar `documentation-architecture`.
- Quando o objetivo for auditar lacunas documentais sem gerar conteúdo novo — usar `documentation-project-scan`.

## When to use

- Quando o usuário pedir para documentar telas, wireframes, fluxos de UI ou protótipos.
- Quando o scan identificar lacunas em `Documentation/Esboco_Telas/`.

## Inputs

1. `<modulo>`: área/feature para a qual as telas serão documentadas.
2. `<versao_docs>`: `Vx.y`.
3. `<telas>`: lista de telas e fluxos (ou descrição textual do fluxo).
4. `<contexto>`: público-alvo e restrições de UX.

## Outputs

- `Documentation/Esboco_Telas/Telas_<modulo>_Vx.y.md`
- Atualização do hub se aplicável (orquestrador/livre).

**Base (ficheiro-modelo):** copiar **`templates/TEMPLATE_Docs_EsbocTelas.md`** (dentro desta skill) para o path canónico (ajustar nome/versão), depois preencher.

## Dependências (skills prévias)

| Skill | Quando executar antes |
| --- | --- |
| `documentation-general_rules` | Sempre — verificar convenções de nomenclatura e versionamento antes de criar arquivos. |
| `documentation-project-bootstrap` | Quando `Documentation/Esboco_Telas/` ainda não existir no projeto. |

## Passos executáveis

1. Mapear fluxo principal (passos e decisões).
2. Para cada tela/estado:
   - objetivo da tela
   - componentes/ações principais (sem detalhar UI final se não for necessário)
   - entradas e saídas (o que o usuário fornece e o que o sistema retorna)
   - estados de erro/validação
3. Inserir diagrama (opcional) com Mermaid quando ajudar a compreensão.
4. Checklist de aceite testável (ex.: todos os passos do fluxo estão representados).

## Critérios de aceite

- Documentação descreve tela/estado e fluxo de forma não genérica.
- Contém entradas/saídas e tratamento de erros/validações.
- Nome/versionamento conforme template.

## Template de saída (arquivo)

1. Cabeçalho: versão/data + escopo
2. Visão geral do fluxo (1 diagrama ou passos numerados)
3. Seção por tela:
   - Tela: `<nome>`
   - Objetivo
   - Ações/Componentes principais
   - Entradas
   - Saídas
   - Erros/validações
4. Checklist final

## Exemplo de referência canônica

- **`templates/TEMPLATE_Docs_EsbocTelas.md`** (dentro desta skill)
- `EXEMPLO DE DOCUMENTAÇÃO/Docs/Esboco_Telas/` (quando existir)

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| --- | --- | --- |
| Documentar telas de forma genérica (apenas nome e descrição de uma linha) | Não satisfaz o critério de aceite; não é testável nem implementável | Incluir sempre objetivo, ações/componentes principais, entradas, saídas e estados de erro para cada tela |
| Misturar esboço de telas com regras de negócio no mesmo arquivo | Viola a separação de responsabilidades; complica rastreabilidade e aprovação | Criar arquivo separado em `Documentation/Esboco_Telas/` para UI e arquivo em `Documentation/Regras de Negocio/` para RNs |
| Criar um único arquivo para todas as telas de um módulo grande | Arquivo gigante dificulta revisão incremental e manutenção | Separar por feature/fluxo: `Telas_<modulo>_Vx.y.md` por escopo gerenciável |

## Métricas de sucesso

- Cada tela/estado documentado tem objetivo, ações principais, entradas, saídas e pelo menos um estado de erro (critério de completude por tela = 100%).
- Checklist final do arquivo preenchido e verificável por revisor humano sem necessitar ler o código.
- Arquivo nomeado e versionado conforme `templates/TEMPLATE_Docs_EsbocTelas.md` (sem desvios de nomenclatura).

## Responsável principal

| Papel | Quem |
| --- | --- |
| Agent executor | `doc-agent-orchestrator` |
| Revisão humana | Designer / analista de UX responsável pela feature |
| Aprovação final | Product owner / tech lead |

---

**Changelog (este arquivo):**

- 1.0.1 (27/03/2026): Base física **`./templates/TEMPLATE_Docs_EsbocTelas.md`** (dentro da skill).
- 1.0.0 (27/03/2026): Versão inicial publicada neste repositório.
---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.1.0 (09/04/2026): Migração V2 — adicionadas seções Responsabilidade única, When NOT to use, Dependências (skills prévias), Anti-padrões, Métricas de sucesso, Responsável principal; frontmatter expandido com thinking e category.
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).
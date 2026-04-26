---
name: documentation-readme-hub
description: Atualiza o hub de documentação `Documentation/README_Vx.y.md` como índice curto, coerente e sincronizado com o mapa final de artefatos dentro de `Documentation/` e `Documentation/Backup/`. Raiz canónica `Documentation/`; renomear `Docs/` ou `docs/` na raiz para `Documentation/` se necessário.
model: sonnet
thinking: normal
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation README Hub

## Responsabilidade única

Esta skill é responsável exclusivamente por criar e manter o hub `Documentation/README_Vx.y.md` como índice curto, coerente e sem links órfãos de todos os artefatos documentais canônicos do projeto. Ela sincroniza o hub com o mapa real de arquivos em `Documentation/` e `Documentation/Backup/` após qualquer alteração estrutural, garantindo que cada subpasta e documento relevante esteja referenciado. Não move nem renomeia arquivos — apenas reflete o estado atual do sistema documental e deve ser executada como etapa obrigatória após migrações, criações e atualizações de documentos.

## When NOT to use

- Quando o objetivo for mover ou arquivar documentos — usar `documentation-migration-backup` primeiro, depois re-sincronizar o hub.
- Quando for necessário criar conteúdo novo de arquitetura, RN ou análise — usar a skill específica do tipo de documento.
- Quando o hub já está sincronizado e nenhum arquivo foi alterado — não há re-sincronização a fazer.
- Quando o objetivo for registrar o histórico de alterações — usar `documentation-versioning-changelog`.
- Quando a tarefa for apenas analisar lacunas documentais sem atualizar o hub — usar `documentation-analysis-index`.

## When to use

- Quando o hub `Documentation/README_Vx.y.md` estiver ausente, incompleto ou inconsistente com os arquivos reais.
- Após qualquer criação/atualização/movimentação de documentos.
- Como parte obrigatória de roadmap, migração e bootstrap.

## Dependências (skills prévias)

| Skill | Quando executar antes |
| --- | --- |
| `documentation-migration-backup` | Quando houve remanejamento de arquivos — o hub deve refletir o estado pós-migração |
| `documentation-general_rules` | Consultar antes para garantir naming conventions corretos nos links |

## Inputs

1. `<versao_docs>`: `Vx.y` do hub/stack documental.
2. `<mapa_final>`: lista dos caminhos canônicos (e seus títulos/descrições curtas).
3. `<backups>`: lista de documentos movidos para `Documentation/Backup/` (superseded/conflito) quando aplicável.
4. `<status_por_subpasta>` (opcional): se o usuário já tem status/aceitabilidade.

## Outputs obrigatorios

**Base (ficheiro-modelo):** criar ou alinhar o hub a partir de **`templates/TEMPLATE_Docs_README_Hub.md`** (e `templates/TEMPLATE_Docs_README_Simples.md` para `Documentation/README.md` quando aplicável).

1. Hub atualizado: `Documentation/README_Vx.y.md` com:
   - versão/data coerentes
   - visão geral curta
   - árvore indexada por subpastas (Arquitetura/RN/Telas/Analise/Versionamento/Roadmap/Backup/**html**)
   - lista de backlog/“próximas ações” se existirem lacunas
   - quando existir **portal estático:** incluir no mapa/`README_Vx.y.md` a pasta **`html/`** e, se útil, link ou menção a **`html/README.md`** (evitar o portal órfão do índice)
2. Sem links órfãos:
   - nenhum path apontando para arquivo inexistente
3. Registros de histórico:
   - seção mínima para `Documentation/Backup/` com o que foi movido e por quê (quando houver migração)

## Passos executáveis

1. Ler o hub atual (se existir) e comparar com `<mapa_final>`.
2. Atualizar árvore do hub:
   - consolidar links por categoria
   - manter o hub curto (menos é mais): links e descrições curtas, conteúdo detalhado fica nas docs.
3. Sincronizar versionamento:
   - garantir coerência entre `_Vx.y` do nome do arquivo e a versão informada no hub
4. Atualizar seção Backup quando houver:
   - listar superseded/conflito com evidência (origem/data/motivo resumido)
5. Checklist pós-edição:
   - confirmar ausência de duplicação residual (duas entradas canônicas apontando para o mesmo path)
   - se `Documentation/html/` existir: confirmar que o hub ou tabela de documentos canónicos a referencia quando for parte do conjunto publicado

## Critérios de aceite

- Hub reflete exatamente o mapa final de documentos canônicos.
- Backup está consistente com a classificação superseded/conflito.
- Não há links órfãos.

## Regras transversais

- Obedecer skill `documentation-general_rules` (naming conventions) e skill `documentation-general_rules` (language policy).
- Aplicar a regra obrigatória de re-sincronização do hub (skill `documentation-readme-hub` (hub resync rules)).

## Template de saída (estrutura do hub)

- Cabeçalho: versão/data
- Visão geral curta + objetivo do hub
- Status por subpasta (placeholder ok)
- Lista indexada de docs canônicas por subpasta
- Seção de histórico (Documentation/Backup) quando houver
- Backlog/Próximas ações (se houver lacunas)

## Exemplo de referência canônica

- **`./templates/TEMPLATE_Docs_README_Hub.md`** (e **`./templates/TEMPLATE_Docs_README_Simples.md`**) — dentro da skill
- `EXEMPLO DE DOCUMENTAÇÃO/Docs/README_V1.5.md` (quando existir)

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| --- | --- | --- |
| Hub com links para arquivos inexistentes | Gera links órfãos que enganam quem navega na documentação | Verificar existência de cada path antes de incluir no hub |
| Duas entradas canônicas apontando para o mesmo arquivo | Duplicação no índice confunde sobre qual é a referência oficial | Manter apenas uma entrada por artefato canônico; a segunda vai para histórico |
| Hub muito extenso com conteúdo detalhado duplicado | O hub deve ser curto (índice); conteúdo detalhado fica nos documentos filhos | Substituir parágrafos longos por links concisos com descrição de 1 linha |
| Não incluir `Documentation/html/` quando o portal existe | Portal estático fica órfão do índice, invisível para navegadores | Sempre referenciar `html/` no hub quando a pasta existir |
| Não re-sincronizar após migração | Hub reflete estado anterior, enganando auditorias e buscas | Executar esta skill como etapa obrigatória após toda migração ou atualização |

## Métricas de sucesso

- Zero links órfãos no hub após execução — todos os paths referenciados existem fisicamente.
- Nenhuma duplicação de entradas canônicas apontando para o mesmo artefato.
- Hub atualizado reflete exatamente a estrutura real de `Documentation/` incluindo `Backup/` e `html/` quando aplicável.

## Responsável principal

| Papel | Quem |
| --- | --- |
| Agent executor | `doc-agent-orchestrator` |
| Revisão humana | Responsável pela documentação do projeto |
| Aprovação final | Usuário / tech lead |

---

## Política de re-sincronização do hub (absorvida de Constitution)

Conteúdo anteriormente em `.cursor/Constitution/constitution-hub-resync-rules_V1.0.md` (SSOT). Absorvido para esta skill em 04/04/2026.

### Quando re-sincronizar

- Criar, mover, renomear ou arquivar um documento sob `Documentation/`.
- Alterar a estrutura de pastas (`Arquitetura/`, `Analise/`, `Versionamento/`, etc.).
- Fechar uma revisão que mude o mapa de artefactos referenciados pelo hub.

### Checklist mínimo de re-sincronização

1. Abrir `Documentation/README_Vx.y.md` (versão activa do hub).
2. Actualizar tabelas de **estado**, **documentos canónicos** e **backlog** conforme a realidade da árvore.
3. Garantir que **todas** as referências internas apontam para ficheiros existentes ou para destinos explicitamente marcados como *pendente*.
4. Registar alteração no changelog documental (`Documentation/Versionamento/CHANGELOG.md` ou equivalente), se aplicável.

---

**Changelog (este arquivo):**

- 1.0.3 (04/04/2026): Absorvido conteúdo de `constitution-hub-resync-rules_V1.0.md` (política de re-sincronização do hub).
- 1.0.2 (27/03/2026): Hub e checklist — pasta **`html/`** e **`html/README.md`** no mapa quando o portal existir.
- 1.0.1 (27/03/2026): Base física **`.cursor/Templates/TEMPLATE_Docs_README_*.md`**.
- 1.0.0 (27/03/2026): Versão inicial publicada neste repositório.
---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)
- 1.1.0 (09/04/2026): Migração V2 — adicionadas seções Responsabilidade única, When NOT to use, Dependências, Anti-padrões, Métricas de sucesso, Responsável principal; frontmatter expandido com thinking e category.
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).

---
name: documentation-architecture
description: Cria ou atualiza documentos de arquitetura dentro de `Documentation/Arquitetura/` no template canônico.
model: sonnet
thinking: extended
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation Architecture

## Responsabilidade única

Esta skill é responsável exclusivamente por criar e atualizar documentos de arquitetura em `Documentation/Arquitetura/`, seguindo o template canônico e garantindo que cada documento tenha escopo delimitado, responsabilidades claras, fluxos operacionais e critérios de aceite testáveis. Ela opera sobre um módulo ou tema por execução, evitando duplicação com documentos de RN, análise ou roadmap. A atualização do hub e o registro no changelog são responsabilidade do orquestrador após a conclusão desta skill.

## When to use

- Quando o usuário pedir para documentar a arquitetura (componentes, módulos, camadas, fluxo).
- Quando o scan identificar lacunas em `Documentation/Arquitetura/`.
- Como parte de bootstrap, roadmap ou migração.

## When NOT to use

- Quando o objetivo for documentar regras de negócio — usar `documentation-business-rules`.
- Quando for necessário documentar análise de lacunas ou inventário — usar `documentation-analysis-index`.
- Quando for uma visão de alto nível multi-módulo — usar `documentation-overview-architecture`.
- Quando o pedido for migrar ou reorganizar documentos existentes — usar `documentation-migration-backup`.
- Quando o foco for o roadmap do produto — usar `documentation-roadmap-from-docs`.

## Inputs

1. `<modulo>`: nome funcional do módulo/tema (ex.: `Auth`, `Data`, `Connections`).
2. `<versao_docs>`: `Vx.y`.
3. `<contexto>`: o que a arquitetura deve cobrir (público, escopo, restrições).
4. `<insumos>` (opcional): documentos existentes, análises, roadmap atual.

## Dependências (skills prévias)

| Skill | Quando executar antes |
| --- | --- |
| `documentation-general_rules` | Sempre — confirmar naming conventions, versioning e idioma canônicos |
| `documentation-project-scan` | Quando não se sabe o estado atual da pasta `Arquitetura/` — para evitar duplicação |
| `documentation-analysis-index` | Quando houver análise de gaps prévia que deva orientar o escopo do documento |

## Passos executáveis

1. Determinar o escopo do `<modulo>` com base no pedido e nos insumos.
2. Definir fronteiras:
   - o que entra no documento
   - o que fica fora (para evitar duplicação)
3. Incluir:
   - visão geral (1 seção curta)
   - responsabilidades e limites (boundaries)
   - fluxo/contratos de interação (passo a passo)
   - dependências (docs relacionadas)
4. Inserir checklist de "pronto" e critérios de aceite operacional.
5. Garantir naming/versioning conforme skill `documentation-general_rules` (naming conventions).

## Outputs

- Arquivo canônico: `Documentation/Arquitetura/Arquitetura_<modulo>_Vx.y.md`
- Atualização do hub se aplicável (via `documentation-readme-hub` ou orquestrador).

**Base (ficheiro-modelo):** copiar **`templates/TEMPLATE_Docs_Arquitetura.md`** para o path canónico (ajustar nome/versão), depois executar os passos acima.

## Checklist de aceite

- O arquivo possui seções e conteúdo operacional (não genérico).
- O escopo está delimitado para evitar duplicação com RN/Analise/roadmap.
- O documento é consistente com o hub (quando atualizado).

## Template de saída (arquivo)

O arquivo `Arquitetura_<modulo>_Vx.y.md` deve conter:
1. Cabeçalho: versão/data + escopo
2. Visão geral curta
3. Responsabilidades (bullet list)
4. Fluxos e contratos (passos numerados)
5. Dependências e referências cruzadas (links)
6. Checklist de aceite (itens testáveis)

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| --- | --- | --- |
| Documentar múltiplos módulos em um único arquivo | Viola escopo único; dificulta rastreabilidade e manutenção | Criar um arquivo por módulo com naming `Arquitetura_<modulo>_Vx.y.md` |
| Incluir regras de negócio no documento de arquitetura | Mistura de preocupações; duplica conteúdo com `Documentation/Regras de Negocio/` | Extrair RN para documento próprio via `documentation-business-rules` |
| Documentar arquitetura sem definir fronteiras explícitas | Documento cresce sem controle e se sobrepõe a outros | Incluir seção de limites (o que entra / o que fica fora) antes de escrever |
| Criar documento sem consultar scan prévio | Risco de duplicação com arquivos existentes em `Arquitetura/` | Executar `documentation-project-scan` antes quando o estado atual é incerto |
| Conteúdo genérico sem fluxos ou contratos reais | Documento inútil para quem precisa implementar ou revisar | Substituir texto genérico por passos numerados e contratos concretos |

## Avaliação de risco

- **Baixo:** Atualização de documento existente com insumos e escopo claros.
- **Médio:** Criação de novo documento sem scan prévio — risco de duplicação.
- **Alto:** Documentar módulo com dependências não mapeadas — pode induzir decisões arquiteturais incorretas.

## Métricas de sucesso

- O documento gerado não duplica conteúdo já existente em `Arquitetura/`, `Regras de Negocio/` ou `Analise/`.
- Cada seção possui conteúdo operacional concreto (não texto genérico ou placeholder).
- O naming e versioning estão conforme as convenções de `documentation-general_rules`.
- O hub é atualizado ou sinalizado para atualização pelo orquestrador.

## Responsável principal

| Papel | Quem |
| --- | --- |
| Executor da skill | Agente de documentação (Claude Code) |
| Aprovador do escopo | Usuário / arquiteto responsável pelo módulo |
| Mantenedor do template base | Responsável pelo pack `.cursor/Templates/` |

## Rules to consult

- skill `documentation-general_rules` (naming conventions)
- skill `documentation-general_rules` (language policy)
- skill `documentation-readme-hub` (hub resync rules)
- skill `documentation-constitution-policies` (rules-integration)

## Exemplo de referência canônica

- **`templates/TEMPLATE_Docs_Arquitetura.md`**
- `EXEMPLO DE DOCUMENTAÇÃO/Docs/Arquitetura/` (quando existir)

---

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.1.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.1.0 (09/04/2026): Migração V2 — `thinking` elevado de `normal` para `extended`; adicionadas seções `Dependências (skills prévias)`, `Anti-padrões`, `Avaliação de risco`, `Métricas de sucesso`, `Responsável principal`; tabelas convertidas para estilo `| --- |`; reordenação canônica de seções; FileVersion 1.0.1 → 1.1.0.
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).

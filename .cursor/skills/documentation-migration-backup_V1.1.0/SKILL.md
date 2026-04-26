---
name: documentation-migration-backup
description: Migra documentação existente para a estrutura canônica de `Documentation/` movendo artefatos para destinos finais corretos e arquivando documentos superseded em `Documentation/Backup/`. Use quando o usuário pedir "migrar docs para o novo padrão", "padronizar estrutura Documentation" ou "organizar documentação legada com backup". Raiz canónica `Documentation/`; renomear `Docs/` ou `docs/` na raiz quando aplicável. Também serve como etapa obrigatória do ecossistema de documentação.
model: sonnet
thinking: normal
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation Migration & Backup

## Responsabilidade única

Esta skill é responsável exclusivamente por migrar acervos documentais existentes — dispersos, legados ou inconsistentes — para a estrutura canônica `Documentation/`, garantindo que cada artefato chegue ao seu destino final correto ou seja arquivado em `Documentation/Backup/`. Ela opera em fases ordenadas (inventário → normalização → remanejamento → validação) para assegurar rastreabilidade completa e ausência de perda de conteúdo. Não cria documentos novos de conteúdo — sua responsabilidade é mover, renomear, arquivar e resolver colisões. A atualização do hub (`documentation-readme-hub`) e do changelog (`documentation-versioning-changelog`) são etapas pós-migração e responsabilidade do orquestrador ou do usuário.

## When NOT to use

- Quando o objetivo for **criar** um documento novo de conteúdo — usar `documentation-architecture`, `documentation-business-rules`, etc.
- Quando o acervo já estiver na estrutura canônica correta e sem colisões — não há migração a fazer.
- Quando o usuário pedir apenas atualizar o hub sem mover arquivos — usar `documentation-readme-hub`.
- Quando a tarefa for registrar changelog documental sem remanejamento — usar `documentation-versioning-changelog`.
- Quando a análise de lacunas for o objetivo principal — usar `documentation-analysis-index`.

## When to use

- Quando o usuário pedir para **migrar documentação existente** para o novo padrão `Documentation/`.
- Quando houver acervo em `Analise/`, `Arquitetura/`, `Regras de Negocio/` (fora do destino final), `docs/` antigos ou nomes/versões inconsistentes.
- Quando o usuário disser que existe duplicação, versões antigas ou “documentos espalhados” e precisa padronizar.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|---|---|
| `documentation-project-scan` | Executar antes para mapear o acervo existente e identificar pastas dispersas |
| `documentation-constitution-policies` | Consultar para obter definição de superseded e regras de resolução de colisão |
| `documentation-migration-plan` | Quando a migração for complexa e exigir plano aprovado antes do remanejamento |

## Inputs

1. Estrutura atual do repositório (pelo menos):
   - `Documentation/` (se existir parcialmente)
   - `Analise/` (se existir)
   - pastas/arquivos que contenham documentos a migrar
2. Template esperado do novo padrão (contrato estrutural):
   - `Documentation/README_Vx.y.md`
   - `Documentation/Arquitetura/`
   - `Documentation/Regras de Negocio/`
   - `Documentation/Esboco_Telas/`
   - `Documentation/Analise/`
   - `Documentation/Versionamento/`
   - `Documentation/Roadmap/`
   - `Documentation/Backup/`
3. **Ficheiros-modelo físicos** (estrutura e secções mínimas): **`.cursor/Templates/`** — índice `README.md`; usar `TEMPLATE_Docs_*` ao criar destinos novos durante a migração.

## Regra de ouro (obrigatória)

- **Nenhum documento canônico pode permanecer “fora do destino final”.**
- Migrar significa: **remanejar efetivamente** para o path correto dentro de `Documentation/`.
- **Superseded deve ir para `Documentation/Backup/`.**
- Se dois arquivos disputarem o mesmo destino, aplicar resolução canônica e mandar o excedente para `Documentation/Backup/` (com sufixo de conflito).

## Princípios operacionais (extraídos das referências)

1. **Documentos que valem a pena manter**: o resultado precisa ser simples de manter (paths claros, regra de destino final e checklist de validação).
2. **Sem “conteúdo perdido”**: todo canônico deve estar no lugar correto; superseded deve existir como evidência no Backup.
3. **Hub como índice curto e coerente**: depois da migração, o `Documentation/README_Vx.y.md` precisa refletir o mapa final (sem duplicação residual).

## Definições

Norma detalhada por ficheiro: **skill `documentation-constitution-policies` (superseded-definition)** e **skill `documentation-constitution-policies` (migration-conflict-resolution)** (alinhado a este SKILL).

- Destino final correto = path alvo dentro de `Documentation/` que corresponde:
  - tipo de documento (Arquitetura/RN/Esboço/Telas/Analise/Roadmap/Changelog)
  - versão (sufixo `_Vx.y` ou regra do hub)
  - nomenclatura do template.

### Definição de documento superseded (critérios)

- Um documento é **superseded** quando:
  - existe uma versão mais recente do mesmo artefato (mesmo alvo funcional);
  - foi explicitamente substituído por outro documento com escopo equivalente;
  - possui data de conteúdo anterior à versão canônica vigente (quando houver evidência).
- Se não houver evidência clara de “escopo equivalente”, tratar como duplicado/conflito e resolver pela política de colisão (e não como superseded automático).

## Fases obrigatórias

### Fase 0 — Inventário do estado atual (pré-requisito)
Gerar um relatório de inventário contendo:
- lista de documentos encontrados por pasta
- classificação por:
  - tipo (Arquitetura/RN/Esboço/Analise/Roadmap/Changelog/etc.)
  - versão identificada (quando existir)
  - status (canônico / desatualizado / duplicado / órfão / legado/transitório)

Saída: `docs-migration_inventory.md` (pode ser um resumo no corpo da resposta).

Estrutura mínima do arquivo de inventário:
1. Objetivo e escopo da Fase 0
2. Tabela de metadados por documento (origem/tipo/versão/pasta/status/destino esperado/conflito/evidência)
3. Resumo executivo (totais + lista de conflitos destino → origens)
4. Próxima etapa (Fase A/B/C)

### Fase A — Inventário formal
- repetir classificação com critérios mais rígidos (para reduzir erro em remanejamento).
- identificar conflitos: mais de um documento mapeando para o mesmo destino.

### Fase B — Normalização (preparação)
- renomear por funcionalidade e versão conforme padrão do template.
- consolidar duplicatas apenas quando o conteúdo for realmente equivalente (senão, reservar como superseded).

### Fase C — Remanejamento obrigatório (destino final)
Para cada documento do inventário:
- determinar o path alvo dentro de `Documentation/`
- mover o arquivo para o destino final
- atualizar o hub:
  - adicionar/atualizar links no `Documentation/README_Vx.y.md`
  - se moveu para `Documentation/Backup/`, registrar em seção de histórico.

Regras de colisão:
- destino já existe:
  - selecionar o mais canônico usando a política:
    - equivalência de escopo
    - completude
    - evidência de atualização de conteúdo
    - consistência de versão/nome
  - mover o excedente para `Documentation/Backup/` com sufixo `_CONFLITO` e registrar evidência no hub.

### Fase D — Migração controlada
- validar consistência de índices e links cruzados
- garantir que o hub reflita o novo mapa de arquivos.

### Fase E — Validação final (não negociável)
- checagem de links quebrados no hub
- checagem de versão nome × conteúdo (nome `_Vx.y` e campo de versão equivalente no corpo)
- checagem de aderência ao template (estrutura e seções mínimas por tipo)
- checagem de duplicação residual (operacional):
  - ler o hub `Documentation/README_Vx.y.md` e extrair a lista de caminhos canônicos referenciados
  - para cada caminho canônico referenciado:
    - verificar que existe exatamente 1 arquivo no path canônico
    - verificar que não existem mais de uma “entrada canônica” apontando para o mesmo path (duplicação no índice)
  - se houver conflitos remanescentes:
    - mover o excedente para `Documentation/Backup/` como superseded ou `_CONFLITO` (conforme evidência no conteúdo)
    - atualizar o hub para refletir o canônico final

### Fase F — Rollback (procedimento)
Se migração falhar:
- usar `Documentation/Backup/` como fonte de restauração
- restaurar significa mover de volta para as pastas de origem identificadas no inventário
- remover referências do hub para os destinos incorretos
- registrar no changelog/versão documental o ocorrido.

## Extensão — `Analise/` na raiz do repositório (anti-perda)

Projetos com pasta **`Analise/`** fora de `Documentation/` (ex.: análise por classe ao lado de `src/`) aplicam os **mesmos princípios** operacionais:

1. **Inventário prévio** com colunas: `ficheiro_origem`, `ficheiro_destino`, `accao` (copiar, fundir, renomear, arquivar), `notas`.
2. **Backup integral datado** antes de qualquer move/delete destrutivo (ex.: `backup/Analise_reestruturacao_YYYY-MM-DD/`).
3. **Nenhum conteúdo útil perdido:** fundir ou arquivar em backup; DELETE só com critério explícito (entidade ausente no código, sem valor histórico, confirmação).
4. A **criação** de ficheiros **`{ClassName}.md`** (`T…` / `I…`) e subpastas por domínio permanece na skill **`documentation-paste_analysis_unit_class_method`**; esta skill trata **migração, fusão e arquivo** após decisão e matriz.

## Output esperado (formato de resposta)

A resposta deve incluir:

1. **Mapa de remanejamento** (tabela):
   - `Origem → Destino → Classificação (canônico/superseded/conflito) → Ação (mover/renomear) → evidência`
2. **Lista de superseded movidos**:
   - path de origem
   - path final em `Documentation/Backup/`
3. **Conflitos resolvidos**:
   - quais documentos foram consolidados
   - qual ficou canônico e por quê
4. **Checklist de validação final**

## Exemplo de referência canônica

- Usar como padrão de estrutura o diretório `EXEMPLO DE DOCUMENTAÇÃO/Docs/` (especialmente `Docs/README_V1.5.md` e as pastas `Docs/Arquitetura`, `Docs/Regras de Negocio`, `Docs/Esboco_Telas`, `Docs/Analise`, `Docs/Backup`).
- Quando o usuário estiver em outro repositório e não houver arquivos idênticos, aplicar o mesmo layout conceitual e convenções de nomenclatura/versionamento do template.

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| --- | --- | --- |
| Mover arquivos sem inventário prévio | Perde rastreabilidade e pode criar colisões silenciosas | Sempre executar Fase 0 antes de qualquer move |
| Deletar documento sem critério explícito | Risco de perda de conteúdo histórico valioso | Arquivar em `Documentation/Backup/` com sufixo e evidência |
| Migrar sem atualizar o hub | Hub fica desincronizado com a realidade do repositório | Sempre invocar `documentation-readme-hub` após Fase C |
| Tratar todo documento duplicado como superseded | Documentos com escopos distintos não são superseded | Aplicar política de colisão da `documentation-constitution-policies` |
| Executar Fase C sem backup datado | Sem possibilidade de rollback seguro | Criar backup integral antes de qualquer remanejamento destrutivo |

## Métricas de sucesso

- 100% dos documentos do inventário foram classificados e chegaram a um destino final (canônico ou Backup) — nenhum órfão remanescente.
- Zero links quebrados no hub `Documentation/README_Vx.y.md` após Fase D/E.
- Todos os conflitos de colisão foram documentados com evidência (origem, critério de decisão, destino final).

## Responsável principal

| Papel | Quem |
| --- | --- |
| Agent executor | `doc-agent-orchestrator` |
| Revisão humana | Responsável pela documentação do projeto |
| Aprovação final | Usuário / tech lead |

## Checklist de qualidade (antes de concluir)

- [ ] Nenhum documento canônico permanece fora de `Documentation/`
- [ ] Remanejamento completo do acervo existente: todos os documentos classificados como canônicos passaram pela Fase C para o destino final dentro de `Documentation/`
- [ ] Todo documento superseded foi movido para `Documentation/Backup/`
- [ ] Hub resync: confirmação explícita de que `Documentation/README_Vx.y.md` foi atualizado para refletir o mapa final (sem links órfãos).
- [ ] `Documentation/README_Vx.y.md` foi sincronizado com o novo mapa de arquivos
- [ ] Não há duplicação residual em destinos canônicos
- [ ] Colisões foram resolvidas e excedentes foram enviados ao Backup

---

**Changelog (este arquivo):**

- 1.1.2 (27/03/2026): SSOT das políticas superseded/colisão em **`.cursor/Constitution/`** (`constitution-*_V1.0.md`).
- 1.1.1 (27/03/2026): Secção **Definições** — remete a **`.cursor/Constitution/constitution-superseded-definition_V1.0.md`** e **`.cursor/Constitution/constitution-migration-conflict-resolution_V1.0.md`**.
- 1.1.0 (27/03/2026): Pasta canónica **`Documentation/`** (antes `Docs/`) em todo o texto operacional; descrição e exemplo EXEMPLO corrigidos.
- 1.0.3 (27/03/2026): Inputs — **`.cursor/Templates/`** como fonte de `TEMPLATE_Docs_*` na migração.
- 1.0.2 (27/03/2026): Referência a ficheiros **`{ClassName}.md`** (`T…` / `I…`) na extensão Analise/ (paste_analysis 1.2.0).
- 1.0.1 (27/03/2026): Secção **Extensão — Analise/ na raiz** (matriz, backup, anti-perda; separação face a paste_analysis).
- 1.0.0: Versão base da skill (migração Documentation/ + fases).
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

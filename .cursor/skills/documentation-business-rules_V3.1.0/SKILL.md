---
name: documentation-business-rules
description: Cria ou atualiza documentos de Regras de Negócio em `Documentation/Regras de Negocio/` — um arquivo por regra, subpasta por módulo, padrão ERP modular.
model: sonnet
thinking: extended
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation Business Rules

## Responsabilidade única

Esta skill é a responsável exclusiva pela criação e atualização de documentos de Regras de Negócio no formato padrão — um arquivo por regra, subpasta por módulo, em `Documentation/Regras de Negocio/`. Resolve o problema de regras de negócio dispersas em código-fonte, comentários ou documentos genéricos, centralizando-as em artefactos rastreáveis com fluxo principal, exceções, validações, impactos e assinaturas. Existe separada de `documentation-class-analysis-generator` porque RNs descrevem **comportamento de negócio** (invariantes, pré/pós-condições, políticas) enquanto a análise de classes descreve **estrutura técnica** (API, campos, herança). O formato padrão com 12 secções obrigatórias garante que cada RN seja aprovável e implementável sem ambiguidade.

## When NOT to use

- Quando o objetivo for documentar a estrutura técnica de classes/interfaces — usar `documentation-class-analysis-generator`.
- Quando o objetivo for documentar fluxos de arquitetura (diagramas, ADRs, decisões de design) — usar `documentation-architecture`.
- Quando o objetivo for criar esboços de telas ou wireframes — usar `documentation-screen-sketches`.
- Quando o objetivo for apenas identificar lacunas documentais sem criar novos documentos — usar `documentation-project-scan`.
- Quando as RNs ainda não tiverem análise de classe de suporte — executar `documentation-class-analysis-generator` primeiro para ler `Documentation/Analise/` antes de redigir.

## When to use

- Quando o usuário pedir para documentar regras de negócio, políticas, contratos de comportamento e invariantes.
- Quando o scan identificar lacunas em `Documentation/Regras de Negocio/`.

## Estrutura física obrigatória

```
Documentation/Regras de Negocio/
├── README.md                            ← hub com índice de todos os módulos
├── RN-M01 - Commons/
│   ├── README.md                        ← lista todas as RNs do módulo com links
│   ├── ProvidersORM_RN-M01-001_M01_V1_0.md
│   ├── ProvidersORM_RN-M01-002_M01_V1_0.md
│   └── ...
├── RN-M02 - Connections/
│   ├── README.md
│   └── ProvidersORM_RN-M02-001_M02_V1_0.md
└── ... (um subdiretório por módulo)
```

**Regra fundamental:** cada regra de negócio é **um arquivo separado**. Nunca agrupar múltiplas regras em um único arquivo.

## Nomenclatura de arquivo individual

```
{Projeto}_RN-M{xx}-{nnn}_{xx}_V{X}_{Y}.md
```

| Parte | Descrição | Exemplo |
|---|---|---|
| `{Projeto}_` | Prefixo canônico do projeto | `ProvidersORM_` |
| `RN-M{xx}` | Código do módulo (2 dígitos) | `RN-M01` |
| `-{nnn}` | Número da regra (3 dígitos, pode ter gaps) | `-001`, `-003`, `-007` |
| `_{xx}` | Repetição do número do módulo | `_M01` |
| `_V{X}_{Y}` | Versão com underscores | `_V1_0` |

**Exemplos:**
- `ProvidersORM_RN-M01-001_M01_V1_0.md`
- `ProvidersORM_RN-M04-003_M04_V1_0.md`
- `ProvidersORM_RN-M06-012_M06_V1_0.md`

**Gaps na numeração são propositais** — permitem inserir novas RNs sem renumerar.

## Mapeamento de módulos do projecto

Os módulos de cada projecto são **derivados da análise do código-fonte** (`src/`) ou de pedido explícito do utilizador — **nunca impostos** por esta skill. A quantidade e granularidade dependem da natureza do projecto:

- Um **ORM** como ProvidersORM tem 9 módulos funcionais porque a sua arquitectura é modular por domínio técnico.
- Um **ERP** como GestorERP tem 26 módulos porque cobre muitos domínios de negócio.
- Um projecto pequeno pode ter 3-4 módulos; um monolito pode ter apenas 1-2.

A tabela de mapeamento `Mxx → Módulo` é criada durante o bootstrap documental ou na primeira invocação desta skill, com base na estrutura real do projecto.

### Exemplo: ProvidersORM (9 módulos funcionais)

| Mxx | Módulo | Pasta em Analise/ | Prefixo legado |
|---|---|---|---|
| M01 | Commons | `Commons/` | RN-CO |
| M02 | Connections | `Connections/` | RN-CN |
| M03 | PoolConnections | `PoolConnections/` | RN-PC |
| M04 | Database | `Database/` | RN-DB |
| M05 | Exceptions | `Exceptions/` | RN-EX |
| M06 | Loggers | `Loggers/` | RN-LG |
| M07 | Parameters | `Parameters/` | RN-PA |
| M15 | Attributers | `Attributers/` | RN-AT |
| M16 | Main | `Main/` | RN-MA |
| M17 | Providers.v161 | `Providers.v161/` | RN-V1 |
| M00 | ProvidersORM (geral) | — | RN-GE |
| M00-C | Compilação | — | RN-C |

### Exemplo: GestorERP (26 módulos de negócio)

| Mxx | Módulo | Descrição |
|---|---|---|
| M01 | Segurança | Autenticação, autorização, perfis, tokens |
| M02 | Cadastros | Cadastros gerais (cidades, estados, tabelas auxiliares) |
| M03 | Clientes | Gestão de clientes, contactos, histórico |
| M04 | Empresas | Multi-empresa, filiais, configurações por empresa |
| M05 | Financeiro | Contas a pagar/receber, fluxo de caixa, conciliação |
| M06 | Fiscal | NF-e, NFS-e, CF-e, SPED, obrigações fiscais |
| M07 | Documentos | Gestão documental, anexos, assinaturas |
| M15 | LGPD | Consentimento, anonimização, relatórios de impacto |
| M16 | Estoque | Movimentação, inventário, lotes, rastreabilidade |
| M17 | OS | Ordens de serviço, apontamentos, SLA |
| M18 | Orçamentos | Orçamentos comerciais, aprovações, conversão |
| M19 | Veículos | Cadastro de veículos, manutenção, custos |
| M20 | Vendas | Pedidos de venda, faturamento, comissões |
| M21 | Proposta | Propostas comerciais, follow-up, pipeline |
| M22 | Comissões | Cálculo, rateio, pagamento de comissões |
| M23 | Execução Serviços | Agendamento, execução, encerramento de serviços |
| M24 | Frota | Gestão de frota, abastecimento, rastreamento |
| M25 | Roteiros | Rotas, sequenciamento, otimização de percursos |
| M26 | Caixa | Abertura/fechamento, sangria, suprimento |
| M27 | Bancos | Integração bancária, CNAB, conciliação |
| M28 | Boletos | Emissão, registro, baixa de boletos |
| M29 | Compras | Pedidos de compra, cotação, recebimento |
| M30 | PDV | Ponto de venda, TEF, cupom fiscal |
| M31 | RH | Recursos humanos, folha, benefícios |
| M32 | Marketing | Campanhas, leads, CRM básico |
| M33 | Aluguéis | Contratos de locação, reajustes, cobranças |

## Cada RN = uma regra de negócio

Princípio fundamental da organização:

- Cada **ARQUIVO** descreve **UMA** regra de negócio específica e atómica.
- Cada **PASTA** (`RN-Mxx - Nome/`) agrupa as regras de **UM** módulo.
- **Gaps na numeração são propositais** — permitem inserir novas RNs sem renumerar as existentes (ex.: M01-001, M01-003, M01-007 sem 002, 004-006).
- Nunca agrupar múltiplas regras num único arquivo; nunca misturar regras de módulos diferentes na mesma pasta.

## Inputs

1. `<modulo>`: módulo ao qual as regras pertencem (ex.: `Commons`, `Database`).
2. `<regras>`: lista de regras ou descrição do comportamento esperado.
3. `<contexto>`: objetivo e termos do domínio.
4. `<analise_path>`: caminho de `Documentation/Analise/<Modulo>/` — ler antes de redigir.

## Exemplo de referência (gold standard)

A pasta `exemplos/` dentro desta skill contém ficheiros de referência no formato padrão completo:

- `Padrao_RN-M01-001_exemplo.md` — exemplo de RN do módulo Segurança
- `Padrao_RN-M05-001_exemplo.md` — exemplo de RN do módulo SERPRO/APIs Governamentais

Estes ficheiros servem como **modelo de qualidade** para qualquer nova RN gerada. Ao criar RNs, consultar estes exemplos para garantir que todas as 12 secções obrigatórias estão preenchidas com o nível de detalhe esperado.

## Dependências (skills prévias)

| Skill | Quando executar antes |
| --- | --- |
| `documentation-class-analysis-generator` | Quando `Documentation/Analise/<Modulo>/` ainda não existir ou estiver com placeholders — as RNs são derivadas dos invariantes documentados ali. |
| `documentation-general_rules` | Sempre — verificar convenções de nomenclatura, versionamento e idioma antes de criar arquivos. |
| `documentation-project-bootstrap` | Quando a pasta `Documentation/Regras de Negocio/` ainda não existir no projeto. |

## Fonte primária: Documentation/Analise/

Antes de redigir qualquer RN, **ler** os documentos de análise do módulo em `Documentation/Analise/<Modulo>/`. Cada `{ClassName}.md` contém invariantes, contratos e restrições.

**Workflow:**
1. Listar `Documentation/Analise/<Modulo>/*.md`
2. Para cada arquivo, extrair: pré-condições, pós-condições, invariantes de estado, restrições de uso
3. Cada invariante/contrato coeso = uma RN separada (um arquivo)
4. Criar arquivo `{Projeto}_RN-M{xx}-{nnn}_{xx}_V1_0.md` para cada RN
5. Criar/atualizar `RN-M{xx} - Nome/README.md` com link para a nova RN
6. Atualizar hub `Documentation/Regras de Negocio/README.md`

## Estrutura interna de cada arquivo RN — Formato padrão (MANDATÓRIO)

Usar `templates/TEMPLATE_Docs_RN.md` (dentro desta skill) como base. **Todas as seções abaixo são MANDATÓRIAS** — nenhuma pode ser omitida. Referência local: `exemplos/` (dentro desta skill).

Cada arquivo RN **deve** seguir esta estrutura exata:

~~~markdown
{Projeto} · RN-M{xx}-{nnn} — Título descritivo | V1.0
====================================================================

{Projeto} · Regra de Negócio

**ID da Regra**: RN-M{xx}-{nnn}
**Módulo**: M{xx} — Nome do Módulo
**Fase**: Fase {n} ({Descrição})
**Prioridade**: Alta / Média / Baixa
**Status**: Proposto / Em detalhamento / Aprovado / Implementado / Testado
**Título**: Título descritivo da regra
**Ref. Arquitetura**: {Documento} · Cap. {n} §{seção}

## PRÉ-CONDIÇÕES — O que deve ser verdadeiro antes desta regra ser aplicada

1. [Condição 1]
2. [Condição 2]

## FLUXO PRINCIPAL — Sequência feliz (passo a passo quando tudo funciona)

1. [Passo 1 — descrição detalhada]
2. [Passo 2 — dados, chamadas, transformações]

## FLUXOS DE EXCEÇÃO — O que acontece quando algo dá errado

- **E1. [Título]**
  - `HTTP {código} { "error": "{erro}" }`
  - [Ação do sistema]

- **E2. [Título]**
  - [Descrição]

## VALIDAÇÕES

| Campo / Dado | Condição / Regra | Mensagem de Erro | HTTP |
|---|---|---|---|
| [campo] | [condição] | [mensagem] | [código] |

## TABELAS / CAMPOS DO BANCO DE DADOS

| Tabela | Op. | Campos Relevantes |
|---|---|---|
| `{schema}.{tabela}` | R/W | `campo1`, `campo2` |

## IMPACTO EM OUTRAS RNs

- **RN-M{xx}-{yyy}** — [descrição do impacto]

## LGPD — Dados pessoais envolvidos, base legal e prazo de retenção

- **Dados tratados**: [lista]
- **Base legal**: [artigo LGPD]
- **Retenção**: [prazo e política]

## ESBOÇO DE IMPLEMENTAÇÃO — {Stack}

```pascal
// Código demonstrativo do fluxo principal
```

## NOTAS / OBSERVAÇÕES

- [Decisões de design, justificativas]

## Assinaturas

- **Elaborado por**: Equipe {Projeto} — ___/___/______
- **Revisado por**: ___________________ — ___/___/______
- **Aprovado por**: ___________________ — ___/___/______
~~~

**IMPORTANTE — seções que NÃO fazem parte do formato padrão (não usar):**
- ~~`## Descrição`~~ → substituída pelo cabeçalho de identificação
- ~~`## Regras` / subrules~~ → substituída por FLUXO PRINCIPAL + VALIDAÇÕES
- ~~`## Critérios de aceite`~~ → substituída por VALIDAÇÕES
- ~~`## Rastreabilidade`~~ → não faz parte do formato padrão
- ~~`## Changelog`~~ → substituída por NOTAS / OBSERVAÇÕES

## README.md por pasta de módulo

Cada `RN-M{xx} - Nome/README.md` deve conter:

```markdown
# RN-M{xx} — Nome do Módulo

> Breve descrição do escopo do módulo.

## Regras de Negócio

| RN | Título | Status |
|---|---|---|
| [RN-M{xx}-001]({Projeto}_RN-M{xx}-001_M{xx}_V1_0.md) | Título | [P] |
| [RN-M{xx}-002]({Projeto}_RN-M{xx}-002_M{xx}_V1_0.md) | Título | [ ] |

## Changelog (este arquivo)

| Versão | Data | Descrição |
|---|---|---|
| 1.0.0 | DD/MM/YYYY | Criação do módulo |
```

## Skills de domínio a consultar

- `documentation-project-expert` — hierarquia ORM, engines, diretivas, faixas de exceção, padrões Factory/Fluent
- `developer-delphi-programming-conditional-defines` — diretivas USE_* e blocos condicionais

## Matriz de cobertura (estado atual)

| Módulo | Mxx | RNs existentes | Status |
|---|---|---|---|
| Commons | M01 | RN_Commons_V1.0.md (formato antigo) | [ ] Migrar |
| Connections | M02 | RN_Connections_V1.0.md (formato antigo) | [ ] Migrar |
| PoolConnections | M03 | RN_PoolConnections_V1.0.md (formato antigo) | [ ] Migrar |
| Database | M04 | RN_Database_V1.0.md (formato antigo) | [ ] Migrar |
| Exceptions | M05 | RN_Exceptions_V1.0.md (formato antigo) | [ ] Migrar |
| Loggers | M06 | RN_Loggers_V1.0.md (formato antigo) | [ ] Migrar |
| Parameters | M07 | RN_Parameters_V1.0.md (formato antigo) | [ ] Migrar |
| Attributers | M15 | RN_Attributers_V1.0.md (formato antigo) | [ ] Migrar |
| Main | M16 | RN_Main_V1.0.md (formato antigo) | [ ] Migrar |

> **Nota:** Os arquivos no formato antigo (`RN_Modulo_Vx.y.md`) devem ser migrados para o novo padrão (subpastas + um arquivo por RN). Usar skill `documentation-migration-backup` para mover os antigos para Backup/ antes de criar os novos.

## Critérios de aceite da skill

- Cada RN é um arquivo separado com nomenclatura `{Projeto}_RN-M{xx}-{nnn}_{xx}_V{X}_{Y}.md`.
- Cada arquivo segue o **formato padrão MANDATÓRIO** com todas as seções: Cabeçalho de identificação (ID, Módulo, Fase, Prioridade, Status, Título, Ref. Arquitetura), PRÉ-CONDIÇÕES, FLUXO PRINCIPAL, FLUXOS DE EXCEÇÃO, VALIDAÇÕES, TABELAS/CAMPOS BD, IMPACTO EM OUTRAS RNs, LGPD, ESBOÇO DE IMPLEMENTAÇÃO, NOTAS/OBSERVAÇÕES, Assinaturas.
- Nenhum arquivo pode usar o formato antigo (Descrição, Regras/subrules, Critérios de aceite, Rastreabilidade, Changelog).
- Cada pasta de módulo tem `README.md` com tabela de links para as RNs.
- Hub `Documentation/Regras de Negocio/README.md` lista todos os módulos.
- Não há duplicação com `Documentation/Arquitetura/` (arquitetura = fluxos; RN = invariantes).
- Naming/versioning conforme skill `documentation-general_rules` (naming conventions).

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| --- | --- | --- |
| Agrupar múltiplas regras em um único arquivo | Viola o princípio fundamental (uma RN = um arquivo); impede rastreabilidade individual e aprovação atômica | Separar cada invariante/contrato num arquivo `{Projeto}_RN-M{xx}-{nnn}_{xx}_V1_0.md` distinto |
| Usar o formato antigo (seções Descrição, Regras, Critérios de aceite, Changelog) | Formato incompatível com o formato padrão; impede comparação e migração automática | Reescrever usando as 12 secções obrigatórias do formato padrão com `templates/TEMPLATE_Docs_RN.md` |
| Criar RNs sem ler `Documentation/Analise/<Modulo>/` antes | RNs baseadas em suposições, não em invariantes reais do código; geram inconsistências | Seguir o workflow: listar e ler todos os `{ClassName}.md` do módulo antes de redigir |
| Misturar regras de módulos diferentes na mesma pasta | Quebra a organização por módulo; dificulta manutenção e busca | Criar subpasta `RN-M{xx} - Nome/` por módulo e mover/criar arquivos no local correto |

## Métricas de sucesso

- Cada RN gerada possui arquivo próprio com nomenclatura `{Projeto}_RN-M{xx}-{nnn}_{xx}_V{X}_{Y}.md` e todas as 12 secções obrigatórias preenchidas (zero secções ausentes ou com placeholder vazio).
- Hub `Documentation/Regras de Negocio/README.md` atualizado com link para cada nova RN (zero links quebrados após execução).
- Cada pasta de módulo tem `README.md` com tabela de links para todas as RNs do módulo (cobertura de índice = 100%).

## Responsável principal

| Papel | Quem |
| --- | --- |
| Agent executor | `doc-agent-orchestrator` |
| Revisão humana | Analista de negócio ou tech lead do módulo |
| Aprovação final | Product owner / dono do requisito |

---

**Changelog (este arquivo):**

- 3.0.0 (04/04/2026): Mapeamento de módulos genérico (derivado de `src/`, nunca imposto); tabela ProvidersORM marcada como exemplo; exemplo GestorERP (26 módulos) adicionado; secção "Cada RN = uma regra de negócio"; secção "Exemplo de referência" com remissão a `exemplos/`.
- 2.0.0 (04/04/2026): Reescrita completa — padrão GestorERP: um arquivo por RN, subpastas por módulo, nomenclatura `{Projeto}_RN-M{xx}-{nnn}_{xx}_V{X}_{Y}.md`, subrules numeradas, README por módulo.
- 1.0.2 (03/04/2026): Fonte primária Analise/, mapeamento módulo→prefixo, matriz de cobertura.
- 1.0.1 (27/03/2026): Base física `./templates/TEMPLATE_Docs_RN.md` (dentro da skill).
- 1.0.0 (27/03/2026): Versão inicial.

---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 3.1.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 3.1.0 (09/04/2026): Migração V2 — adicionadas seções Responsabilidade única, When NOT to use, Dependências (skills prévias), Anti-padrões, Métricas de sucesso, Responsável principal; frontmatter expandido com thinking e category.
- 3.0.0 (04/04/2026): Mapeamento genérico de módulos; exemplos ProvidersORM (9) e GestorERP (26); secção "Cada RN = uma regra de negócio"; referência a `exemplos/`.
- 2.2.0 (04/04/2026): Template inline completo no formato padrão (cabeçalho com ID/Módulo/Fase/Prioridade/Status/Título/Ref.Arquitetura + PRÉ-CONDIÇÕES + FLUXO PRINCIPAL + FLUXOS DE EXCEÇÃO + VALIDAÇÕES + TABELAS BD + IMPACTO + LGPD + ESBOÇO + NOTAS + Assinaturas); lista explícita de seções do formato antigo proibidas.
- 2.1.0 (04/04/2026): Formato padrão com 12 seções MANDATÓRIAS; removidas seções opcionais; template alinhado ao exemplo de referência.
- 2.0.0 (04/04/2026): Reescrita completa para padrão GestorERP (um arquivo por RN, subpastas).
- 1.0.2 (03/04/2026): Fonte primária Analise/, mapeamento módulo→prefixo, matriz de cobertura.
- 1.0.1 (30/03/2026): Rubrica de versionamento interno.
- 1.0.0 (30/03/2026): Versionamento interno inicial.

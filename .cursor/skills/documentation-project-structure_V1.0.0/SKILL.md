---
name: documentation-project-structure
description: >-
  Mapeia o repositório Projeto v2 (Delphi / Free Pascal): raiz do repositório (workspace),
  ORM.Defines.inc, src/Commons, src/Modulos (Database, Connections, PoolConnections,
  Exceptions, Parameters, Loggers, Attributers), Views FMX/VCL, Analise/, Exemplos/,
  Data/. Usar ao editar o Projeto a partir da raiz do clone ou ao localizar
  units, diretivas USE_*, regras e skills canônicas do próprio repositório.
model: sonnet
thinking: extended
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# documentation-project-structure
## Versão interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |
| **Política**    | `.cursor/VERSION.md` |

## Responsabilidade única

Esta skill mapeia a estrutura física e organizacional do repositório Providers ORM v2 — localiza pastas, units, diretivas `USE_*`, regras e skills canônicas a partir da raiz do clone. Serve como mapa de navegação antes de editar código: indica onde está cada camada (Commons, Modulos, Views) e onde buscar convenções detalhadas (skills, rules, Templates). Não executa build, não define padrões de implementação e não documenta APIs — essas responsabilidades pertencem a skills dedicadas.

## When to use

- Ao editar código e precisar localizar uma unit, pasta ou convenção de path.
- Ao onboarding de novo desenvolvedor no repositório.
- Ao criar nova unit e precisar confirmar a pasta correta.
- Ao verificar onde ficam diretivas `USE_*` e quais engines estão disponíveis.

## When NOT to use

- Arquitetura de domínio, padrões de implementação → usar `documentation-project-expert`.
- Compilação e diretivas de build → usar `developer-delphi-programming-conditional-defines` + `developer-delphi-build-toolchain`.
- Uso prático do ORM (modo Slim, Attributes, EntityManager) → usar `developer-delphi-providers-orm-usage`.
- Documentação de produto (RNs, ADRs, hubs) → usar família `documentation-*`.

## Dependências (skills prévias)

| Skill                       | Quando executar antes                              |
| --------------------------- | -------------------------------------------------- |
| *(nenhuma)*                 | Esta skill é ponto de partida — sem pré-requisitos |

## Onde está a documentação e as skills "oficiais"

Toda convenção detalhada, regras do agente e skills completas ficam **dentro do repositório**:

| Local | Conteúdo |
| ----- | -------- |
| `.cursor/rules/` | **Inicial_V1.0.mdc**, **roadmap_V1.0.mdc**, **local_arquivos_V1.0.mdc**, **Documentacao_V1.0.mdc**, **Exemplos_ORM_V1.0.mdc** |
| `.cursor/skills/` | **documentation-project-expert**, **developer-delphi-programming-conditional-defines**, **developer-delphi-providers-orm-usage**, **developer-delphi-build-toolchain** |
| `.cursor/` | **diretivas_compilacao.md**, **compile.md**, **database.md**, **README.md** (índice), **Templates/** (ficheiros-modelo `Analise/` + `Documentation/`) |
| `.cursor/agents/` | Agentes por domínio (ex.: agente especialista do Projeto) |
| `.claude/` | **CLAUDE.md** e **settings.local.json** (diretrizes operacionais) — na raiz do repositório, se existir |

**Regra de trabalho:** ao implementar ou revisar código, **abrir o workspace na raiz do repositório**, **ler primeiro** o skill **documentation-project-expert** e as regras em **`.cursor/rules/`** (caminhos relativos à raiz).

## Raiz do repositório

| Item | Conteúdo |
| ---- | -------- |
| `ProvidersORM.dpr` / `ProvidersORM.dproj` | Programa principal e projeto Delphi |
| `ORM.Defines.inc` | **Diretivas** `USE_*` — módulos opcionais, engine DB, UI (FMX/VCL), email/HTTP/WebSocket; base dos `{$IFDEF}` |
| `CHANGELOG.md` | Histórico de mudanças |
| `Data/` | Configuração de exemplo (`config.ini`, etc.) |
| `Analise/` | Análise, especificações, roteiros (`README`, tabelas, O_QUE_FALTA…) |
| `Documentation/` | Documentação canónica estruturada — subpastas: `Analise/` (análises de classe), `Arquitetura/` (ADRs, fluxos), `Regras de Negocio/` (RNs), `Roadmap/`, `Versionamento/`, `Esboco_Telas/` |
| `Exemplos/` | Projetos de exemplo (Dashboard, Exceptions, …) |
| `MySQL/` | Artefatos locais de ambiente (ex.: libs Python) — **não** é o núcleo do ORM |
| `backup/` | Cópias / histórico de exemplos |

## `src/` — código fonte

| Pasta | Descrição |
| ----- | --------- |
| `src/Commons/` | **Fonte única** de tipos, constantes, mensagens e utilitários compartilhados (`Commons.Base`, `Commons.Consts`, `Commons.Types`, `Commons.Exceptions`, SQL Parameters/Loggers, etc.) |
| `src/Main/` | Facades/interfaces de entrada quando aplicável (`Exceptions.Interfaces`, …) |
| `src/Modulos/Connections/` | `Providers.Connection` — conexão Slim (`IConnection` / `TConnection`) |
| `src/Modulos/PoolConnections/` | Pool de conexões |
| `src/Modulos/Database/` | Núcleo ORM: **Field**, **Fields**, **Table**, **Tables**, **Schema**, **Schemas**, **EntityManager**, **QueryBuilder**, **IdentityMap**, **UnitOfWork**, **TypeDatabase** |
| `src/Modulos/Exceptions/` | Exceções de banco e módulos; alinhadas a **Commons** |
| `src/Modulos/Parameters/` | Parâmetros (INI, JSON, atributos, Database) |
| `src/Modulos/Loggers/` | Loggers (arquivo, CSV, XML, HTTP, e-mail, WebSocket, eventos, …) |
| `src/Attributers/` | Atributos RTTI `[Table]` / `[Field]` quando `USE_ATTRIBUTES` (units `Providers.Attributers.*` no DPR) |
| `src/Views/` | Formulários de teste / demonstração (**FMX** `.fmx` ou **VCL** `.dfm` conforme `ORM.Defines.inc`) |

**Hierarquia resumida (roadmap):** Field → Fields → Table → Tables → Schema → Schemas → camada Database / `TDatabaseSchema` → `TypeDatabase` → Connection. **Modo Connection.Lite removido**; usar apenas fluxo **Slim** documentado no repositório.

## Compilação e engines

- **Um engine por build:** definir em `ORM.Defines.inc` (`USE_FIREDAC`, `USE_UNIDAC`, `USE_ZEOS` ou `USE_SQLDB`). FireDAC não aplica ao FPC.
- **UI:** `USE_FMX` **ou** VCL (`VCL` / `FRAMEWORK_VCL` conforme o `.inc`); formulários em `src/Views` usam blocos condicionais.
- Detalhes tabulados: skill **developer-delphi-programming-conditional-defines** + `.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md`.

## Convenções rápidas para navegação

- Sempre conferir `ProvidersORM.dpr` antes de alterar units.
- Sempre conferir `ORM.Defines.inc` + `.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md` antes de mexer em `{$IFDEF}`.
- Para arquitetura e implementação, usar `documentation-project-expert`.
- Para padrão documental, usar `documentation-portal-html` (ecossistema `documentation-*`).

## Documentação de produto (opcional)

Para artefatos longos (RNs, ADRs, hubs em `Analise/` / `Documentation/`), usar o skill **`documentation-portal-html`** (e os skills específicos: `documentation-project-bootstrap`, `documentation-roadmap-from-docs`, `documentation-migration-backup`), trocando o prefixo e o nome do produto para **Projeto**.

## Quando reler ou atualizar este skill

Atualizar se mudarem: layout de `src/Modulos`, nomes no `ProvidersORM.dpr`, localização de Attributers/Views, ou convenções de paths no repositório.

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| ----------- | ---------------- | ------------- |
| Colocar tipos/constantes compartilhadas fora de `src/Commons/` | Duplicação inevitável; quebra a fonte única de verdade | Mover para `src/Commons/` e importar de lá em todos os módulos |
| Criar unit nova em pasta errada (ex.: lógica de negócio em `src/Views/`) | Viola separação de responsabilidades; torna testes impossíveis | Verificar hierarquia de pastas neste skill antes de criar qualquer unit |
| Referenciar paths absolutos (`E:\...\ProvidersORM`) em código ou docs | Quebra portabilidade entre máquinas e clones | Usar sempre caminhos relativos à raiz do workspace |
| Ignorar `ORM.Defines.inc` e hardcodar engine diretamente | Impede multi-engine e build cross-platform | Sempre usar diretivas `USE_*` do arquivo de defines |

## Métricas de sucesso

- Desenvolvedor consegue localizar qualquer unit ou convenção em menos de 30 segundos usando este skill.
- Nenhuma unit criada em pasta errada (verificado em code review com este skill como referência).
- Paths absolutos ausentes em todo o código e documentação do projeto.

## Responsável principal

| Papel    | Quem                              |
| -------- | --------------------------------- |
| Executor | Desenvolvedor Delphi/FPC do projeto |
| Revisor  | `documentation-project-expert`                  |

---

## Changelog (este arquivo)

- 1.0.0 (17/04/2026): Onda 3 do refactor — skill renomeada de `project-estrutura_V*` para `documentation-project-structure_V1.0.0`. Conteúdo generificado (remoção de referências literais a 'Projeto v2.0 deste clone', paths absolutos, MXX concreto). Versão anterior arquivada em `.cursor/Backup/renamed-skills-20260417/skills/`.

- 1.2.0 (11/04/2026): Corrigido path `developer-delphi-programming-conditional-defines` → V1.2.0; expandida descrição de `Documentation/` com subpastas canônicas; adicionado `consultas_rapidas/quick_ref.md`.
- 1.1.0 (09/04/2026): Migração V2 — `thinking: extended`, `category: project`, Responsabilidade única, When NOT to use, Dependências, Anti-padrões, Métricas de sucesso, Responsável principal adicionados.
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.4 (27/03/2026): Caminhos dentro do projeto em formato relativo à raiz; tabelas e descrição actualizadas.
- 1.0.4 (27/03/2026): Pasta documental canónica `Documentation/` (antes `Docs/`).
- 1.0.3 (27/03/2026): Tabela `.cursor/` — pasta Templates/ (modelos Analise/ + Docs/).
- 1.0.2 (26/03/2026): Nome do produto em texto genérico «Projeto»; caminhos físicos absolutos ao workspace (época).
- 1.0.1 (23/03/2026): Ajustadas referências de workspace para ProvidersORM após renomeação de pasta.
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote .cursor).

## Backend Pascal Naming Convention (MXX)

When mapping or creating backend units in `projects/backend/MXX-*`, apply the canonical naming:

```text
<ModuleConcept>.<Feature>[.<SubFeature>].pas
```

**ModuleConcept** = English translation of the domain concept from the module folder (not the folder name, not the `MXX` code). Compound modules decompose: `M01-Seguranca_Acesso` → `Security.*` (OBAC/admin) and `Access.*` (Auth/JWT/LDAP).

Use English names, avoid layer prefixes as the first segment (`Core`, `Commons`, `Modulos`).
`X.Interfaces.pas` requires `X.pas` to exist as its base (ProvidersORM pairing rule).
Authority rule: `.cursor/rules/backend-pascal-unit-naming_V1.1.0.mdc`.


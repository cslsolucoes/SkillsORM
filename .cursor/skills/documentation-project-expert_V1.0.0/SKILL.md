---
name: documentation-project-expert
description: Expert in Projeto v2.0 for Delphi/Free Pascal. Use when working on ORM architecture, Connection/Pool, Fields/Tables hierarchy, FireDAC/UniDAC/Zeos/SQLdb engines, conventions (Fluent, Factory, I/T naming), EDatabaseException hierarchy, or when the user asks for ORM implementation help.
model: opus
thinking: extended
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Projeto Expert

## Responsabilidade única

Esta skill é a **fonte única de verdade (SSOT) das convenções do Projeto v2.0** em Delphi/Free Pascal.
Ela define os padrões obrigatórios de nomenclatura (`I*`/`T*`, Factory, Fluent), a hierarquia de
módulos (Connection, PoolConnections, Database, Exceptions, Parameters, Loggers), as regras de
encapsulamento e a organização da base de conhecimento em `Analise/`. Existe separada das demais
skills porque acumula o contexto acumulado do projeto — convenções, engines, diretivas e estado atual
das units — necessário para que qualquer implementação siga o mesmo padrão.

## When to use

- Ao implementar ou revisar código nos módulos Connection, PoolConnections, Database, Exceptions, Parameters ou Loggers
- Ao definir ou verificar convenções de nomenclatura (`I*`, `T*`, Factory, Fluent) no projeto
- Ao trabalhar com engines FireDAC, UniDAC, Zeos ou SQLdb
- Ao criar ou atualizar `Analise/<módulo>/<ClassName>.md`
- Quando o usuário pedir "ORM implementation help", "implement connection", "add pool feature" ou similar

## When NOT to use

- Para gerar documentação Overview/Architecture → usar `documentation-overview-architecture`
- Para compilar e validar builds → usar `developer-delphi-build-toolchain`
- Para definir diretivas `{$IFDEF}` → usar `developer-delphi-programming-conditional-defines`
- Para refatoração com análise de compatibilidade → usar `governance-refactoring-compatibility-policy`
- Para questões exclusivamente de UI/formulários → usar `dev-agent-frontend` ou `dev-agent-views-expert`

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-programming-conditional-defines` | Ao adicionar nova diretiva `USE_*` ao projeto |
| `governance-refactoring-compatibility-policy` | Ao renomear classes, methods ou units existentes |

Expert in Projeto v2.0 — Delphi/Free Pascal. When invoked, follow project conventions and consult rules for details.

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

---

## Sempre atualizar o skill (regra obrigatória)

- **Ao implementar** novos comportamentos, APIs, eventos ou convenções em módulos cobertos pelo skill (Connection, PoolConnections, hierarquia ORM, exceções, etc.), **sempre atualizar este SKILL.md** na mesma sessão.
- **Incluir no skill:** planejamento ou descrição do que foi acrescentado (ex.: nova seção "Eventos", nova diretiva, novo método público), para que o documento permaneça a **fonte única de verdade** e futuras implementações sigam o mesmo padrão.
- **Ordem recomendada:** primeiro documentar/planejar no skill (tabelas, tipos, momento de disparo), depois implementar no código.
- Aplicar em **todas** as interações que alterem Connection, PoolConnections, convenções ou estrutura documentada aqui.

---

## Escopo de alteração — apenas dentro do projeto (regra obrigatória)

- **Arquivos fora da pasta do projeto não podem ser alterados sem autorização explícita do usuário.**
- Considera-se **dentro do projeto** apenas o conteúdo da **raiz do workspace** (pasta de `ProvidersORM.dpr`). Qualquer caminho que aponte para fora dessa raiz (outros drives, outras pastas como **E:\CSL\ExceptionORM**, **E:\CSL\ParamentersORM**, **E:\Pacote**, etc.) **não deve ser editado, criado ou removido** pelo agente, a menos que o usuário autorize expressamente.
- Ao propor mudanças que envolvam arquivos externos ao workspace (leitura para referência é permitida quando o usuário indicar), **solicitar autorização** antes de aplicar qualquer alteração.
- Aplicar em **todas** as interações (código, regras, planos, documentação).

---

## Units editáveis (regra obrigatória)

- **Só alterar units que estejam listadas no arquivo de projeto (ProvidersORM.dpr).**
- Se for necessário alterar alguma unit **fora do DPR**, **solicitar ao usuário** antes de modificar.
- Prioridade de trabalho: iniciar pelos **módulos Connection e Exceptions** (units desses módulos no DPR).

**Estado do projeto (após backup restaurado):** Modo **Connection.Lite (IConnectionLite/TConnectionLite) foi removido**; apenas modo Slim (TConnection + TTables separados). O DPR **não** referencia Connection.Lite; Parameters/Loggers podem não estar no uses do ProvidersORM.dpr quando o projeto é mínimo (Views); incluir quando USE_PARAMENTERS/USE_LOGGERS.

**Units atualmente no DPR (referência — ProvidersORM.dpr):**

| Módulo | Units |
|--------|--------|
| **Exceptions** | Exceptions.Database.Interfaces, Exceptions.Database, Exceptions.Interfaces, Exceptions (src/Modulos/Exceptions) |
| **Commons** | Commons.Base, Commons.Consts, Commons.Types, Commons.Exceptions, Commons.IOUtils, Commons.StrUtils, Commons.Messages, Commons.Exceptions.SQL, Commons.Parameters.SQL, Commons.Loggers.SQL |
| **Connection** | Providers.Connection.Interfaces, Providers.Connection (sem Connection.Lite; exceções em Commons.Exceptions) |
| **PoolConnections** | Providers.PoolConnections.Interfaces, Providers.PoolConnections |
| **Database** | Field, Fields, Table, Tables, Schema, Schemas, EntityManager, QueryBuilder, IdentityMap, UnitOfWork, TypeDatabase (src/Modulos/Database) |
| **Attributers** | Providers.Attributers.Types, Consts, Exceptions, Interfaces, Attributers; Providers.Attributers.Parameters (USE_PARAMENTERS), Providers.Attributers.Loggers (USE_LOGGERS); TestEntities (e Views condicionais) |
| **Views** | ufrmConnectionTeste, ufrmPoolConnectionsTeste, ufrmDatabaseTeste, ufrmDatabaseAttributersTeste (src/Views) |

- **Exceções:** Centralizadas em src/Modulos/Exceptions + Commons; Main (Exceptions.Interfaces, Exceptions) opcional como facade.
- **Parameters/Loggers:** IParametersDatabase e ILoggerDatabase com overload **Connection(IConnection)**; quando atribuído usam IConnection.ExecuteQuery/ExecuteCommand. API em Main; Connection(TObject) mantido.
- Loggers e Parameters: ativados por USE_LOGGERS e USE_PARAMENTERS; quando ativos, o DPR inclui as units dos módulos. **Para alterar units que não estejam no DPR**, solicitar ao usuário.

---

## Quick Start

1. Read **Inicial_V1.0.mdc** for fundamentals and naming
2. **Antes de criar constante/tipo/record/função:** consultar **src/Commons** (Commons.Consts, Commons.Types, Commons.Exceptions, etc.) para evitar redundância — ver seção **Evitar redundância** e **src/Commons — Papel e estrutura**
3. Read **roadmap_V1.0.mdc** for phases, Connection/Pool, encapsulation, hierarquia ORM
4. Read **local_arquivos_V1.0.mdc** for paths and packages
5. Para diretivas USE_*: **.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md** ou skill **developer-delphi-programming-conditional-defines**
6. Read **Documentacao_V1.0.mdc** for Analise folder e convenção **`ClassName.md`** (tipos **`T…`** / **`I…`** — ver skill **documentation-paste_analysis_unit_class_method**)
7. Para CRUD e geração de SQL: **roadmap_V1.0.mdc** (seção 2.3.4)
8. Para hierarquia de exceções e classes: **Inicial_V1.0.mdc** (Classes de exceção, faixas); **Documentacao_V1.0.mdc** (Exceções centralizadas); **local_arquivos_V1.0.mdc** (EXCEPTIONORM); repositório **E:\CSL\ExceptionORM**.
9. Para fases e entregas: **roadmap_V1.0.mdc** (seções 0 e 7)
10. Para planejamento unificado (unificação dos cinco projetos, assimilação DatabaseORM, exemplos, validação multi-engine): **.cursor/plans/plano_unificado_ecossistema_orm.plan.md**

---

## Project Context

| Aspect | Details |
|--------|---------|
| **ORM** | Abstraction layer for database access |
| **Engines** | FireDAC, UniDAC, Zeos, SQLdb — one per compilation via `ORM.Defines.inc` |
| **Databases** | PostgreSQL, MySQL, SQL Server, FireBird, SQLite, Access |
| **Hierarchy** | Field → Fields → Table → Tables → Schema → Schemas → Database / TDatabaseSchema → TypeDatabase → Parameters → Connection. Containers: TFields, TTables, TSchemas, TPrimaryKeys, TForeignKeys, TIndexes. |
| **Structure** | `src/`, `src/Views`, `src/Commons`, `src/Modulos/`, `Exemplos/` — Views = formulários de teste; Exemplos = exemplos por módulo/projeto (conforme pasta). |

### SDLC posture (merged from v2)

- **Repository identity:** raiz do repositório (workspace) — ficheiro âncora **`ProvidersORM.dpr`**.
- **Core mode:** strictly **Slim Mode** (`TConnection` + `TTables`); `Connection.Lite` deprecated/removed.
- **Documentation-first:** before implementing, consult `Analise/<módulo>/<ClassName>.md` (ex.: **`Connection.md`** — nome base sem `T`/`I`; `T…`/`I…` no conteúdo; fonte de responsabilidades) e `roadmap_V1.0.mdc` (fase/fluxo).
- **ORM chain (mandatory):** `Field -> Fields -> Table -> Tables -> Schema -> Schemas -> Database -> DatabaseSchema`.
- **Validation path:** use `TfrmEcossistemaTeste` (quando disponível no projeto) e scripts em `Data/sql/` para validar DDL/DML.
- **Interaction protocol:** antes de codificar, explicitar qual documento de `Analise/` está guiando a mudança e checar impacto em compatibilidade multi-engine (Delphi/FPC).

### SDLC execution flow (merged from SDLC-Expert-Flow)

- **Context awareness (analysis/design):** sempre validar requisitos e arquitetura antes de codar; pedir esclarecimento quando o escopo estiver ambíguo; sinalizar melhorias de modelagem (UI/UX, schema, integrações) quando houver falha lógica.
- **Coding standards:** priorizar código limpo, legível e modular; aplicar SOLID e padrões compatíveis com o stack Delphi/FPC e convenções do projeto.
- **Quality assurance:** para nova feature/bugfix, propor testes (unitários e/ou de integração), validar critérios de aceite e mapear edge cases.
- **Deployment/DevOps:** considerar diretivas de build, segurança de segredos/configurações e compatibilidade com pipelines/CI.
- **Agile delivery:** quebrar tarefas grandes em entregas menores e verificáveis, mantendo equilíbrio entre velocidade e consistência estrutural.
- **Maintenance note:** quando houver dívida técnica, migração pendente ou pré-requisito de operação, registrar uma nota explícita de manutenção.

### Fase 1 — DML e DDL em ITable (concluída)

- **DML:** ITable expõe ExecuteInsert(IConnection), ExecuteUpdate(IConnection), ExecuteDelete(IConnection); retornam linhas afetadas (Integer). Usam GenerateInsertSQLOptimized, GenerateUpdateSQLOptimized e GenerateDeleteSQL; execução via AConnection.ExecuteCommand(SQL).
- **DDL:** ITable expõe GetSQLCreateTable, GetSQLDropTable (por DatabaseTypes); CreateTable(IConnection), DropTable(IConnection) executam o SQL no banco. AlterTable/AddColumn/DropColumn ficam como extensão futura.

---

## ORM.Defines.inc — ativação/desativação de módulos

Arquivo na **raiz do projeto** (`ORM.Defines.inc`). Controla quais módulos e qual engine entram na compilação.

**Regra:** para **habilitar** → descomente a linha (`{$DEFINE USE_XXX}`). Para **desabilitar** → comente a linha (`//{$DEFINE USE_XXX}`).

### Módulos opcionais

| Diretiva | Efeito quando habilitado | Efeito quando desabilitado |
|----------|---------------------------|----------------------------|
| **USE_PARAMENTERS** | Conexão usa Parameters (INI, JSON, Database); FromIniFile/FromParameters disponíveis. | Conexão apenas manual (Host, Port, Database, etc.). |
| **USE_LOGGERS** | Sistema de logging (Database.Loggers.*) ativo. | Sem logging interno. |
| **USE_POOLCONNECTIONS** | Pool de conexões ativo; reutilização de conexões. | Uma nova conexão por instância. |
| **USE_ATTRIBUTES** | Suporte a [Table], [Field], [Parameter]; RTTI para mapeamento declarativo. | Sistema manual (Fields/Table/Tables); units que usam Attributes exigem esta diretiva. |
| **USE_ENTITY_MANAGER** | TDatabase.NewEntityManager&lt;T&gt; para persistência direta. (Requer USE_ATTRIBUTES.) | Persistência via SQL/Tables manual. |
| **USE_QUERY_BUILDER** | Query Builder fluente para construção de SQL. | SQL manual ou Tables. |

### Engines (um por compilação)

Descomente **apenas um** dos seguintes. O engine define qual camada de acesso a dados (FireDAC, UniDAC, Zeos ou SQLdb) será usada por Connection, Database e módulos.

| Diretiva | Engine | Requisitos / observação |
|----------|--------|-------------------------|
| **USE_UNIDAC** | UniDAC (Universal Data Access Components) | Requer: Uni, UniProvider, PostgreSQLUniProvider, SQLServerUniProvider, etc. Componentes de terceiros (Devart). |
| **USE_FIREDAC** | FireDAC (Embarcadero) | Incluído no Delphi desde XE7. FireDAC.* (FDConnection, FDQuery, etc.). |
| **USE_ZEOS** | Zeos (open-source) | Requer: ZAbstractConnection, ZConnection. Biblioteca open-source; funciona em Delphi e FPC. |
| **USE_SQLDB** | SQLdb (FPC nativo) | Requer: sqldb, pqconnection, mysql51conn, mssqlconn, sqlite3conn, ibconnection (conforme tipo de banco). **Recomendado para FPC/Lazarus** quando não usar Zeos ou UniDAC. |

- Se **mais de um** engine estiver definido, o compilador emite **erro**. Comente todos exceto o desejado.
- **Detecção automática (opcional):** `{$DEFINE AUTO_DETECT_ENGINES}` no `ORM.Defines.inc`; o sistema pode escolher o engine conforme pacotes disponíveis (ordem: UniDAC &gt; FireDAC &gt; Zeos).

---

## Evitar redundância (regra obrigatória)

- **Consultar src/Commons antes de qualquer criação:** antes de criar **constante**, **tipo**, **record**, **função**, **array** ou **unit** nova, **sempre consultar** a pasta **src/Commons** e as units listadas abaixo. Se já existir equivalente em Commons, **usar o existente** e **não duplicar** em outro módulo.
- **Units a consultar (src/Commons), nesta ordem:** Commons.Consts, Commons.Types, Commons.Exceptions, Commons.Base, Commons.Exceptions.SQL, Commons.Messages, Commons.IOUtils, Commons.StrUtils, Commons.Parameters.SQL, Commons.Loggers.SQL, Commons.pas. Ver a tabela em **src/Commons — Papel e estrutura** (abaixo) para o que cada unit concentra.
- **Se já existir no projeto algo que produza o mesmo resultado** (constante, tipo, função, array, unit), **adaptar o módulo/projeto para usar o que já existe** e **não duplicar**.
- Ao adicionar constantes, tipos ou funções: verificar primeiro em **Commons** e nas units já usadas pelo módulo; se houver equivalente, usar o existente e remover ou refatorar a cópia.
- **Nome do engine:** definido **apenas por diretiva de compilação** (USE_FIREDAC, USE_UNIDAC, USE_ZEOS, USE_SQLDB); **não há como mudar em runtime**. Usar a constante **`DEFAULT_DATABASE_ENGINE_NAME`** (e **`DEFAULT_DATABASE_ENGINE`** para o enum) em Commons.Consts; **não criar função** que retorne o nome do engine — seria redundante com a constante.
- Aplicar em **todo o projeto e em todos os módulos** (Parameters, Loggers, Connections, Database, Views, etc.).

---

## Não usar alias (regra obrigatória)

- **Não usar alias de tipo** em módulos/projeto (ex.: `type TMeuTipo = Commons.Types.TDatabaseEngine`). Usar **diretamente** o tipo da unit de origem e incluir a unit no `uses`.
- **Não usar alias de unit** nem reexportar tipos com outro nome para “facilitar uso”. Quem consome deve referenciar **Commons.Types**, **Commons.Consts**, etc., e usar **TDatabaseEngine**, **TDatabaseTypes**, **TConnectionData**, e demais tipos pelo nome original.
- **Exceção:** apenas quando uma unit existente for **compatibilidade explícita** com outro nome de unit (ex.: `Loggers.json` aponta para `Loggers.JsonObject`) e documentada como tal; mesmo assim, preferir migrar referências para a unit canônica e evitar novos alias.
- Aplicar em **todo o projeto e em todos os módulos**.

---

## src/Commons — Papel e estrutura

**src/Commons** concentra todos os **Types**, **Consts** e **métodos utilitários** usados pelo projeto e pelos módulos. **Estas units devem ser consultadas antes de qualquer criação** (constante, tipo, record, função, array) para evitar redundância; nada disso deve ser duplicado em outros módulos.

| Unit | Responsabilidade |
|------|------------------|
| **Commons.Consts** | Constantes necessárias para todo o projeto e todos os módulos (engine, banco, paths, DLLs, seções, filenames, etc.). |
| **Commons.Types** | Tipos necessários para todo o projeto e todos os módulos (enums, records, classes de tipo, TConnectionData, TDatabaseTypeClass, etc.). |
| **Commons.Exceptions** | Exceções base (EExceptionBase, EConnectionException, etc.) e constantes/records de mensagens (TMessageColumns, MESSAGES_COL, ExceptionsColumns). |
| **Commons.Base** | Métodos utilitários gerais (helpers, funções de uso comum). |
| **Commons.Exceptions.SQL** | SQL e constantes para o banco de mensagens (exception.db; criação de tabela, etc.). |
| **Commons.Messages** | Mensagens e recursos centralizados do projeto. |
| **Commons.IOUtils**, **Commons.StrUtils** | **Compatibilidade com FPC:** expõem apenas o que existe no Delphi e não no FPC (padrão Commons.XXXX). |
| **Commons.Parameters.SQL**, **Commons.Loggers.SQL** | SQL e constantes específicas dos módulos Parameters e Loggers quando centralizados em Commons. |
| **Commons.pas** | Variáveis e classes **comuns ao projeto**, integração entre os módulos; pode ter initialization. |

---

## src/Views — Formulários de teste

**src/Views** concentra os **formulários de teste** para cada projeto/módulo. Cada aplicação ou módulo que tenha interface de teste (Connection, Parameters, Loggers, Providers, etc.) deve colocar aqui as forms (.pas/.fmx ou .lfm) usadas apenas para testes e demonstração.

- Um formulário de teste por projeto/módulo (ex.: ufrmProviderTeste, ufrmParameters, ufrmParametersAttributers).
- Não colocar lógica de negócio ou SQL direto nas forms; usar camada de serviço ou módulos (regra Inicial_V1.0.mdc).

---

## Exemplos — Exemplos por módulo/projeto

Na pasta **Exemplos** serão gerados os **exemplos** para cada módulo/projeto, organizados **conforme sua pasta** (uma subpasta ou conjunto de arquivos por módulo/projeto).

- Exemplos de uso de Connection, Parameters, Loggers, Database, etc., cada um na pasta ou estrutura correspondente ao módulo/projeto.
- Servem como referência de consumo da API e de boas práticas; podem incluir snippets, projetos de demonstração ou documentação executável.

---

## Changelog (por unit .pas e por documento .md/.mdc) — regra obrigatória

- 1.0.0 (17/04/2026): Onda 3 do refactor — skill renomeada de `project-expert_V*` para `documentation-project-expert_V1.0.0`. Conteúdo generificado (remoção de referências literais a 'Projeto v2.0 deste clone', paths absolutos, MXX concreto). Versão anterior arquivada em `.cursor/Backup/renamed-skills-20260417/skills/`.

- **CHANGELOG.md (raiz):** Toda mudança notável do **projeto** deve ser registrada em uma entrada de versão (Adicionado, Corrigido, Alterado, Documentação; opcional "Alterações unit a unit"). Formato: [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/) e [Semantic Versioning](https://semver.org/lang/pt-BR/).
- **Units .pas:** No **cabeçalho** de cada unit (antes de `interface`), manter os campos abaixo no formato canônico com delimitadores `{ ===...=== }`:

  ```pascal
  { =============================================================================
    UnitName - Descrição breve em uma linha

    Project:        NomeProjeto
    ProjectVersion: X.Y.Z
    FileVersion:    X.Y.Z
    Company:        CSL Tech Solutions
    Author:         Claiton de Souza Linhares
    Date:           DD/MM/AAAA

    Changelog (file):
    - X.Y.Z (DD/MM/AAAA): descrição
    ============================================================================= }
  ```

  Ao alterar a unit, atualizar **FileVersion**, **Date** e adicionar entrada em **Changelog (file)**. Ver **Inicial_V1.0.mdc** (Changelog por unit).
- **Documentos .md e .mdc:** Ao **final do arquivo**, incluir bloco **"Changelog (este arquivo):"** com entradas `- X.Y.Z (DD/MM/AAAA): descrição`. Ao alterar o documento, atualizar esse bloco. Aplica-se a regras (.mdc), Analise (*.md), planos (.plan.md), skills (SKILL.md), README e demais .md/.mdc do projeto. Ver **Inicial_V1.0.mdc** (Changelog por documento .md e .mdc).
- **Ordem ao editar:** Ao concluir alterações em uma sessão, atualizar (1) CHANGELOG.md se houver mudança notável no projeto; (2) cabeçalho da unit .pas ou bloco "Changelog (este arquivo)" do .md/.mdc correspondente.

---

## Mandatory Conventions

### Naming
- **Interfaces:** `I` + Name (e.g. `IField`, `ITable`, `IConnection`)
- **Implementations:** `T` + Name (e.g. `TField`, `TTable`, `TConnection`)
- **Private fields:** `F` prefix (e.g. `FTableName`, `FConnection`)
- **Parameters:** `A` prefix (e.g. `AField`, `ATableName`)
- **Local variables:** descriptive; `L` optional (e.g. `LTable`, `LConn`)

### Fluent (obrigatório em todo o projeto e em todos os módulos)
- **Todo o projeto e todos os módulos** devem adotar **fluência** (Fluent API): métodos de configuração e de mutação retornam a própria interface (ou Self) para permitir encadeamento.
- Setters e mutadores (Add, Remove, Clear, etc.) retornam a interface; não retornam void/procedure quando o encadeamento fizer sentido.
- Exemplo: `Table.TableName('usuarios').DatabaseTypes(dtPostgreSQL).AuditFields(True)`  
  Exemplo Connection: `Connection.Host('localhost').Port(5432).Database('mydb').Connect`

### Factory
- Main classes expose `New`: `TField.New`, `TTable.New`, `TConnection.New`, `TPoolConnections.New`

### Exceptions
- All inherit from `EDatabaseException`
- Codes by module: 10XXX Commons, 20XXX Fields, 30XXX Tables, 40XXX Connections, 50XXX Parameters, etc.

### Memory Management (Delphi)
- Objects created locally **MUST** be freed in `try...finally`
- Use `.Free` for objects not reused; `FreeAndNil` only when pointer will be checked later

### Conexão e uso do banco (padronizado)
- **A conexão e o uso do banco têm de ser padronizados** em todo o projeto e em todos os módulos.
- Usar **IConnection** / **Connection** (ou Pool quando USE_POOLCONNECTIONS) como ponto único de acesso ao banco; configuração via Host, Port, Database, FromConfig/FromParameters quando USE_PARAMENTERS.
- Módulos que precisem de dados (Exceptions, Loggers, Parameters) utilizam Connection/Database/Parameters de forma consistente; não criar canais ou padrões alternativos de conexão ou execução de SQL.

---

## Eventos (TConnection e TPoolConnections)

Eventos são **propriedades da classe** (TConnection, TPoolConnections), **não da interface** (IConnection, IPoolConnections). Uso opcional; para atribuir, usar a referência à classe (ex.: `(FConnection as TConnection).OnAfterConnect := MeuHandler`).

### TConnection — planejamento e convenção

| Evento | Tipo | Momento de disparo |
|--------|------|--------------------|
| **OnBeforeConnect** | TNotifyEvent | Imediatamente antes de abrir a conexão (após validação de DLL e criação do objeto nativo). |
| **OnAfterConnect** | TNotifyEvent | Imediatamente após a conexão ser aberta com sucesso. |
| **OnBeforeDisconnect** | TNotifyEvent | Imediatamente antes de fechar a conexão (após Rollback se InTransaction). |
| **OnAfterDisconnect** | TNotifyEvent | Imediatamente após a conexão ser fechada. |
| **OnConnectionError** | TConnectionErrorEvent (Sender; E: Exception) | Quando uma exceção ocorre durante Connect; disparado antes de re-raise. |

- **TConnectionErrorEvent** = `procedure(Sender: TObject; E: Exception) of object`.
- Disparar apenas se `Assigned(FOn...)` antes de chamar o handler.

### TPoolConnections — planejamento e convenção

| Evento | Tipo | Momento de disparo |
|--------|------|--------------------|
| **OnBeforeAdd** | TPoolConnectionEvent | Antes de incluir a conexão na lista. |
| **OnAfterAdd** | TPoolConnectionEvent | Depois de incluir a conexão na lista. |
| **OnBeforeRemove** | TPoolConnectionEvent | Antes de remover a conexão da lista. |
| **OnAfterRemove** | TPoolConnectionEvent | Depois de remover a conexão da lista. |
| **OnBeforeGetFromPool** | TNotifyEvent | Antes de retirar uma conexão do pool. |
| **OnAfterGetFromPool** | TPoolConnectionEvent | Depois de retirar a conexão (recebe a IConnection retirada). |
| **OnBeforeReturnToPool** | TPoolConnectionEvent | Antes de devolver a conexão ao pool. |
| **OnAfterReturnToPool** | TPoolConnectionEvent | Depois de devolver a conexão ao pool. |
| **OnClear** | TNotifyEvent | Antes de limpar a lista do pool. |

- **TPoolConnectionEvent** = `procedure(Sender: TObject; const AConnection: IConnection) of object`.
- Disparar apenas se `Assigned(FOn...)`; em GetFromPool, OnAfterGetFromPool só dispara quando há conexão retornada (Count > 0).

---

## Container de objetos (PoolConnections e sustentação do projeto)

- **Padrão comum:** Um **container de objetos** (ex.: pool de conexões com **TPools** / **FPoolList**) é usado para manter instâncias (ex.: IConnection) que serão **consumidas por outros módulos** do projeto. O container é **fundamental para a sustentação** do projeto: centraliza e reutiliza os objetos em vez de cada módulo criar os seus.
- **Funcionalidade esperada do container:**
  - **Listagem identificada:** cada item com identificador (ex.: Id + Name em **TPool**) para exibição em UI (combo, lista).
  - **Seleção e recuperação:** ao selecionar um item (por índice ou nome), a aplicação deve poder **recuperar o objeto** (ex.: GetByIndex, GetByName) e **recuperar o status e os dados** desse objeto (ex.: conexão conectada ou não, Host, Port, Database, etc.).
  - **Preenchimento da UI:** com o objeto selecionado, preencher o painel/formulário com os **dados e o status** (ex.: conectado/desconectado, parâmetros da conexão), para que o usuário veja o estado atual e outros módulos possam usar a mesma referência.
- **Uso por outros módulos:** Os objetos do container (ex.: IConnection obtida do pool) são a **fonte única** para operações que precisam de conexão; Loggers, Parameters, Exceptions, Database, etc. devem receber ou obter a conexão do container (ou da conexão única, conforme arquitetura) em vez de criar novas instâncias soltas.
- **Ao implementar novos containers** no projeto (ou estender PoolConnections), considerar: lista nomeada/indexada, GetByIndex/GetByName (ou equivalente), e na UI associada — ao mudar a seleção, atualizar painel com status e dados do objeto selecionado.

---

## LEGENDA (status)

| Symbol | Meaning |
|--------|---------|
| `[ ]` | Pending |
| `[X]` | Done |
| `[P]` | Paused |
| `[A]` | High priority |
| `[M]` | Medium priority |
| `[B]` | Low priority |

---

## Exceptions: exception.sql → exception.db e fundamento Exception ORM

- O **módulo Exceptions** é **utilizado por todos os módulos e pelo projeto** para mensagens de exceção centralizadas (consulta por código ou constante em Data/exception.db).
- **Exception ORM (referência):** Projeto **E:\CSL\ExceptionORM** (standalone): API IExceptions, IExceptionsDatabase, TMessageRecord, tabela messages, idiomas, FromDefault/FromConfig/FromConfigJson, GetMessage. Síntese em **Documentacao_V1.0.mdc** (Exceções centralizadas) e estrutura em **local_arquivos_V1.0.mdc** (EXCEPTIONORM). No Projeto, **src/Modulos/Exceptions** segue o mesmo contrato; base em Commons (fonte única).
- **Data/exception.sql** (e exception_en.sql, exception_es.sql) é o arquivo fonte para **inserir os tipos de exceções** (INSERT na tabela `messages` ou estrutura equivalente).
- Esse script será **importado** pelo **SQLite** (`sqlite3.exe`) no banco **Data/exception.db**.
- **Vale para todo o projeto e para todos os módulos:** qualquer módulo (ORM, Loggers, Parameters, Connection, etc.) que use mensagens de exceção localizadas deve usar **Exceptions** (src/Modulos/Exceptions ou Main: Exceptions.Interfaces, Exceptions) e seguir o fluxo: editar/gerar `Data/exception.sql` e importar para `Data/exception.db` via sqlite3.

### Exceções do Connection (centralizadas)

- **Commons.Exceptions** (src/Commons): define EExceptionBase e EConnectionException (e derivadas), códigos 40001–40019. **Providers.Connection.Exceptions** foi migrada para Commons; Connection e Exceptions usam **Commons.Exceptions**.

### Verificação futura — demais módulos (integração Commons / Exceptions)

- **PoolConnections:** Providers.PoolConnections.Consts e Providers.PoolConnections.Exceptions estão vazios; Providers.PoolConnections.Types define apenas TPoolConnectionsList (array of IConnection), específico do módulo. Nenhuma redundância com Commons; nenhuma duplicação com módulo Exceptions. Manter como está.
- **Parameters:** Parameters.Consts usa Commons.Consts/Commons.Types. Constantes como DEFAULT_PARAMETERS_CONFIG_RELATIVE_PATH (= 'Data' + PathDelim) e DEFAULT_PARAMETERS_INI_FILENAME (= 'config.ini') têm o mesmo valor que Commons DEFAULT_DATABASE_PATH e DEFAULT_INI_FILENAME — em revisão futura, considerar referenciar Commons onde o valor for idêntico. Parameters.Exceptions usa faixa 1001–1999; Inicial_V1.0.mdc (Classes de exceção) prevê **50XXX** para Parameters — em revisão futura, alinhar códigos e avaliar unificação com hierarquia do módulo Exceptions (EExceptionBase).
- **Loggers:** Loggers.Consts tem constantes deprecated (uso de Loggers.Database.Consts); valores de path/arquivo config podem coincidir com Commons — em revisão futura, usar Commons onde aplicável. Loggers.Exceptions usa faixa 1001–1999; regras preveem **93XXX** para Loggers — em revisão futura, alinhar códigos e avaliar unificação com módulo Exceptions.
- **Attributers:** Providers.Attributers.Consts, Types e Exceptions estão como stubs; quando implementados, evitar duplicar tipos/constantes já existentes em Commons e exceções já cobertas por Exceptions.Commons.Errors (60XXX em Inicial_V1.0.mdc).

---

## Módulos: papéis e acesso a dados

**Exceptions** é utilizado por **todos os módulos e pelo projeto**: centraliza mensagens de exceção (Data/exception.db). Qualquer módulo (Loggers, Parameters, Connection, Database, etc.) e a aplicação principal devem consumir **Exceptions** (src/Exceptions.Interfaces, src/Exceptions) para obter mensagens por código ou constante; não duplicar lógica de mensagens.

| Módulo | Papel | Acesso a dados / uso |
|--------|--------|------------------------|
| **Exceptions** | Exceções do projeto/módulos (Data/exception.db); **consumido por todos os módulos e pelo projeto** | Utiliza **Connection**, **Database** e **Parameters** para acesso a dados. |
| **Loggers** | Logs do projeto/módulos | Utiliza **Connection**, **Database** e **Parameters** para acesso a dados. |
| **Parameters** | Configuração (INI, JSON, Database) | Utiliza **Connection** e **Database** para acesso a dados; uso interno de **IniFile** e **JsonObjects**. |
| **Attributers** | Atributos do **projeto ORM somente** | **src/Attributers**: atributos do núcleo ORM ([Table], [Field], etc.). Cada módulo tem seu **sub-módulo Attributers** com atributos específicos. |
| **Connections** | Conexão multi-engine e multi-banco | Contém o necessário para conexão em **multi-engine** e **multi-banco**; **fornece** para todos os módulos e para o Projeto. |
| **PoolConnections** | Pool de conexões | Contém o necessário para organizar **multi-conexões** (MultEngine/MultBanco); **fornece** para todos os módulos e para o Projeto as conexões necessárias. |
| **Providers.v161** | Versão anterior | Contém a versão anterior do Projeto (form + units). |
| **Aplicação principal** | Programa e Views | Utiliza **todos** os módulos. |

- **Attributers:** **src/Attributers** é exclusivo do **projeto ORM** (atributos do núcleo). **Cada módulo** possui seu **sub-módulo Attributers** (ex.: Modulos/Exceptions/…/Attributes, Modulos/Loggers/…/Attributes, Modulos/Parameters/…/Attributes). Esses sub-módulos são **somente units de junção** ao módulo específico: fazem a ligação com o módulo e **customizam métodos específicos** para aquele módulo, sem duplicar o núcleo.

---

## Encapsulamento para usuários externos vs uso interno

**Todos os módulos** devem estar **encapsulados** nas units abaixo para **uso por usuários externos** ao projeto (consumo apenas via essas APIs em **src/**):

| Módulo | Interfaces | Implementação |
|--------|-------------|---------------|
| **Exceptions** | `src/Modulos/Exceptions/Exceptions.Interfaces.pas` | `src/Modulos/Exceptions/Exceptions.pas` (+ Exceptions.Database.*) |
| **Loggers** | `src/Loggers.Interfaces.pas` | `src/Loggers.pas` (API em src/; demais em src/Modulos/Loggers) |
| **Parameters** | `src/Parameters.Interfaces.pas` | `src/Parameters.pas` (API em src/; demais em src/Modulos/Parameters) |
| **Database** | Interfaces/impl em `src/Modulos/Database/` | Field, Fields, Table, Tables, Schema, Schemas, EntityManager, QueryBuilder, IdentityMap, UnitOfWork, TypeDatabase |

- **Usuários externos:** usam **somente** essas units (ex.: `Exceptions.Interfaces`, `Exceptions`); não referenciam units internas dos módulos (`Modulos/...`).
- **Projeto internamente:** pode utilizar **acesso direto** às units dos módulos (pastas `Modulos/...`, Connections, Database, etc.) **sem necessidade** de passar pela API encapsulada. Ou seja, o código do próprio Projeto pode fazer `uses` direto em units internas quando fizer sentido (ex.: testes, integração entre módulos, performance).

---

## Modules: Parameters and Loggers (encapsulation)

- **Encapsulation é somente para uso externo.** Parameters e Loggers **internamente** (dentro do Projeto) **não precisam** ser encapsulados: o projeto pode acessar direto as units em `src/Modulos/Loggers/` e `src/Modulos/Parameters/`. As 4 units em **src/** existem para **usuários externos** consumirem os módulos sem depender da estrutura interna.
- **Para externos:** apenas 4 units — `Loggers.Interfaces.pas`, `Loggers.pas`, `Parameters.Interfaces.pas`, `Parameters.pas` (em `src/`). Uso: `uses Loggers.Interfaces, Loggers;` e `uses Parameters.Interfaces, Parameters;`
- **Não modificar** nem adicionar arquivos em `src/Modulos/Loggers/` e `src/Modulos/Parameters/` por parte de código externo ao módulo; internamente o projeto pode referenciar essas units.
- Ativar via `USE_LOGGERS` e `USE_PARAMENTERS` em `ORM.Defines.inc`

---

## Reference Blueprint (Few-Shot)

Follow this style for Fluent, Factory, try...finally and naming:

```delphi
function TUsuarioService.AtualizarSaldo(const AUsuarioId: Integer; const AValor: Currency): Boolean;
var
  LQuery: TFDQuery;
begin
  Result := False;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConnection;
    LQuery.SQL.Text := 'UPDATE USUARIOS SET SALDO = SALDO + :VALOR WHERE ID = :ID';
    LQuery.ParamByName('VALOR').AsCurrency := AValor;
    LQuery.ParamByName('ID').AsInteger := AUsuarioId;
    LQuery.ExecSQL;
    Result := LQuery.RowsAffected > 0;
  finally
    LQuery.Free;
  end;
end;
```

---

## Base de conhecimento — pasta Analise

A pasta **Analise/** contém a **base de conhecimento** do projeto, organizada **por pasta** (como em Exemplos): uma **subpasta por módulo/projeto**, com ficheiros **`{ClassName}.md`** em que **`ClassName`** é o **nome base** (sem prefixo **`T`** ou **`I`** no nome do ficheiro; ex.: **`Connection.md`** para `TConnection` / `IConnection`).

- **Estrutura:** `Analise/<modulo_ou_projeto>/` — ex.: `Analise/Parameters/`, `Analise/Loggers/`, `Analise/Connections/`, **`Analise/Database/`** (`Providers.Databases.*` / `Providers.Database.*`), **`Analise/Attributers/`** (`Providers.Attributers.*` em `src/Attributers`). Não recriar em `Analise/` pastas paralelas `Providers.Databases/` ou `Providers.Database/` (redirects removidos após fusão em `Database/`); não recriar `Analise/Providers.Attributers/` (renomeado para **`Attributers/`**). Dentro de cada pasta ficam os .md daquele módulo (**`Connection.md`**, **`Field.md`**, etc.), Views_Formularios.md quando aplicável, README ou índices locais.
- **Backup:** As pastas **Analise/Exceptions/** e **Analise/Reconstrucao/** e cópias/obsoletos foram movidos para **backup/Analise/**; planos concluídos ou fora do escopo em **backup/cursor_plans/**. Ver **backup/README.md** (raiz do projeto) para conteúdo e nomenclatura.
- **Assimilações e plano unificado:** Características dos projetos DatabaseORMLite, DatabaseORMSlim, DatabaseORM (e unificação com LoggersORM, ParamentersORM, ExceptionORM, VersionORM) estão no **plano único** **`.cursor/plans/plano_unificado_ecossistema_orm.plan.md`**; **roadmap_V1.0.mdc** seção **1.5** e **Documentacao_V1.0.mdc** (seção Assimilações).
- **Conteúdo dos .md:** Apenas **descrição e responsabilidade** — sem implementação. Ao criar ou alterar um `Analise/.../<ClassName>.md`, o corpo deve referir explicitamente os identificadores completos **`T…`** / **`I…`** e a **unit**; manter só descrição/responsabilidade.
- **Ao implementar código:** Seguir a responsabilidade descrita no .md correspondente como especificação.
- **Classes [A implementar]:** EntityManager, UnitOfWork, QueryBuilder e TypeDatabase têm units com implementation vazio (stubs); os .md descrevem o comportamento planejado até a implementação real.
- **Índice geral:** `Analise/README.md` (no projeto-alvo) — índice por módulo e convenção **`ClassName.md`** (nome base sem `T`/`I` no ficheiro; skill **documentation-paste_analysis_unit_class_method**).
- **Após scaffold, migração ou fusão de pastas em `Analise/`:** executar o passo **Pós-conclusão** dessa skill (auditoria de links no repositório, remoção de redundantes/órfãos conforme política e backup, uma fonte canónica por classe; registo no relatório ou CHANGELOG quando aplicável). Não deixar links quebrados nem rascunhos só necessários durante o trabalho.
- **Views e formulários:** em `Analise/<modulo>/Views_Formularios.md` ou `Analise/Views_Formularios.md` conforme convenção do módulo.
- **CRUD e SQL:** Consultar **roadmap_V1.0.mdc** (seção 2.3.4) para geração de SQL (Select/Insert/Update/Delete) e execução via Connection.
- **Exceções:** Consultar **Inicial_V1.0.mdc** (Classes de exceção, faixas) para hierarquia e responsabilidade das classes de exceção.

### Documentos por classe (por pasta, conforme módulo/projeto)

| Módulo / área | Pasta em Analise/ | Exemplos de arquivos |
|---------------|-------------------|----------------------|
| **Loggers** | `Analise/Loggers/` | LoggerAttributeMapper.md, LoggerAttributeParser.md, LoggersDatabase.md, Logger.md, LoggerFactory.md, Loggers.md |
| **Parameters** | `Analise/Parameters/` | AttributeMapper.md, AttributeParser.md, ParametersDatabase.md, ParametersInifiles.md, ParametersJsonObject.md, Parameters.md, ParametersImpl.md, Parameter.md, ParameterList.md |
| **Connections** | `Analise/Connections/` | **`Connection.md`** (`TConnection` / `IConnection` no conteúdo; conforme units) |
| **PoolConnections** | `Analise/PoolConnections/` | PoolConnections.md |
| **Database (ORM + avançado: Field…Indexes + EntityManager, QueryBuilder, …)** | **`Analise/Database/`** | Todos os `{ClassName}.md` de `Providers.Databases.*` e `Providers.Database.*` (ver `Analise/Database/README.md`) |
| **Attributers (RTTI, [Table]/[Field])** | **`Analise/Attributers/`** | `Providers.Attributers.*` — AttributeParser, AttributeMapper, Types (ver `Analise/Attributers/README.md`) |

Ao implementar ou revisar código de uma classe ou interface, consulte o **Analise/<pasta_do_modulo>/<ClassName>.md** (ex.: **`Connections/Connection.md`**, **`Database/Field.md`**, **`Database/EntityManager.md`**) correspondente como base de conhecimento.

---

## TypeDatabase — abstração de dialeto SQL

`TTypeDatabase` em `src/Modulos/Database/` fornece a abstração de **dialeto SQL por banco** para paginação e geração de identity (auto-incremento).

| Banco | Paginação | Identity (auto-geração de PK) |
|-------|-----------|-------------------------------|
| **PostgreSQL** | `LIMIT n OFFSET m` | `SERIAL` / `BIGSERIAL` |
| **MySQL / MariaDB** | `LIMIT n OFFSET m` | `AUTO_INCREMENT` |
| **SQL Server** | `OFFSET m ROWS FETCH NEXT n ROWS ONLY` | `IDENTITY(1,1)` |
| **SQLite** | `LIMIT n OFFSET m` | `AUTOINCREMENT` |
| **Firebird** | `FIRST n SKIP m` | `GEN_ID(gerador, 1)` |

- O engine define a variante correta em tempo de compilação via `USE_*`.
- Não usar paginação ou identity SQL inline — sempre delegar a `TTypeDatabase`.
- Para adicionar suporte a novo banco: estender `TTypeDatabase` em `src/Modulos/Database/TypeDatabase.pas`.

---

## EntityManager lifecycle

O `EntityManager` (`src/Modulos/Database/EntityManager.pas`) gerencia o ciclo de vida de entidades mapeadas com `[Table]`/`[Field]` (requer `USE_ENTITY_MANAGER` + `USE_ATTRIBUTES`).

```
Transient → Managed → Persisted/Clean → Detached → Removed
```

| Estado | Descrição |
|--------|-----------|
| **Transient** | Objeto criado, mas **nunca** passado ao EntityManager; não rastreado. |
| **Managed** | Registrado via `EntityManager.Save<T>` ou `EntityManager.Find<T>`; rastreado. |
| **Persisted/Clean** | Persistido no banco (INSERT/UPDATE executado); sem mudanças pendentes. |
| **Detached** | Desregistrado do EntityManager (`Detach`); alterações não rastreadas. |
| **Removed** | Marcado para deleção (`Delete`); será excluído no próximo `Flush`. |

- `USE_ENTITY_MANAGER` **requer** `USE_ATTRIBUTES` ativo em `ORM.Defines.inc`.
- Sem `USE_ENTITY_MANAGER`, usar fluxo manual: `TTables` + `ITable.ExecuteInsert/ExecuteUpdate/ExecuteDelete`.
- `IdentityMap` (`src/Modulos/Database/IdentityMap.pas`) e `UnitOfWork` evitam leituras duplicadas e agrupam operações pendentes.

---

## Exception code ranges (por módulo)

| Módulo | Faixa |
|--------|-------|
| Commons | 10XXX |
| Fields | 20XXX |
| Tables | 30XXX |
| Connections | 40XXX |
| Parameters | 50XXX |
| Loggers | 60XXX |
| PoolConnections | 70XXX |
| Database | 80XXX |
| Exceptions | 90XXX |

---

**Changelog (este arquivo):**
- 1.3.0 (11/04/2026): Adicionadas seções TypeDatabase (dialeto SQL por banco: paginação + identity), EntityManager lifecycle (Transient → Managed → Persisted → Detached → Removed) e tabela de faixas de código por módulo.
- 1.2.0 (09/04/2026): Migração V2 — adicionadas seções Responsabilidade única, When to use, When NOT to use, Dependências, Checklist Delphi+FPC, Anti-padrões, Métricas de sucesso, Responsável principal; model atualizado para opus; thinking: extended; category: project.
- 1.1.12 (30/03/2026): Rubrica de versionamento interno do pack `.cursor/` (política: `.cursor/VERSION.md`); tabela **Versão interna (ficheiro)** com **FileVersion 1.1.12** (nome da pasta = versão do SKILL.md).
- 1.1.11 (28/03/2026): **`Analise/Attributers/`** — renomeação de **`Providers.Attributers/`**; tabela e bullet de estrutura.
- 1.1.10 (28/03/2026): **Analise/** — removidas pastas redirect **`Providers.Databases/`** e **`Providers.Database/`**; só **`Database/`** como domínio físico.
- 1.1.9 (28/03/2026): **Analise/** — bullet **Pós-conclusão**: alinhar à skill **documentation-paste_analysis_unit_class_method** (links, limpeza, estado final).
- 1.1.8 (28/03/2026): **Analise/Database/** — pasta canónica única para ORM + EntityManager/QB; tabela de pastas Analise; redirects `Providers.Databases` / `Providers.Database`.
- 1.1.7 (27/03/2026): **Repository identity** e escopo do workspace — paths relativos à raiz do repositório (sem drive absoluto para o clone ProvidersORM).
- 1.1.6 (27/03/2026): Analise — **`ClassName.md`** = nome base **sem** `T`/`I` no ficheiro (ex.: **`Connection.md`**); tabela de exemplos e SDLC actualizados; skill paste 1.3.0.
- 1.1.5 (27/03/2026): Analise — convenção **`ClassName.md`** (`T…` / `I…`) alinhada à skill **documentation-paste_analysis_unit_class_method**; remoção de referências a `Unit.ClassName.md`; tabela Connections.
- 1.1.4 (27/03/2026): Exceptions — rule **Exceptions_Unificado.mdc** removida; Quick Start e secção Exception ORM → **Documentacao_V1.0.mdc**, **local_arquivos_V1.0.mdc**, **E:\CSL\ExceptionORM**.
- 1.1.3 (26/03/2026): Nome do produto em texto genérico «Projeto»; caminhos físicos e `ProvidersORM.dpr` inalterados.
- 1.1.2 (12/03/2026): Nova seção "Escopo de alteração — apenas dentro do projeto" (regra obrigatória): arquivos fora da pasta do projeto não podem ser alterados sem autorização explícita do usuário; workspace = raiz do projeto; solicitar autorização para caminhos externos.
- 1.1.1 (12/03/2026): Exceptions — referência histórica a rule dedicada (substituída em 1.1.4 por Documentacao + local_arquivos).
- 1.1.0 (12/03/2026): Seção "Changelog (por unit .pas e por documento .md/.mdc)" — regra obrigatória para CHANGELOG.md, cabeçalho .pas e bloco "Changelog (este arquivo)" em .md/.mdc.
- 1.0.0 (anterior): Estrutura inicial do skill; convenções, encapsulamento, eventos, exceções, Analise.

---

## Checklist Delphi+FPC

- [ ] Compilação sem hints/warnings em Delphi (dcc32 + dcc64)
- [ ] Compilação sem hints/warnings em FPC (fpc32 + fpc64)
- [ ] Memory management: Create/Free em try..finally; sem leaks (`ReportMemoryLeaksOnShutdown`)
- [ ] Tratamento de exceções: hierarquia do projeto (`EProviderError` ou equivalente em Commons.Exceptions)
- [ ] Nomenclatura: prefixos `T`/`I`/`E`/`F`/`A`; Factory via `New`; API Fluente com `.Method()` vertical
- [ ] Diretivas `{$IFDEF}` conforme `developer-delphi-programming-conditional-defines`; sem mistura com paths
- [ ] Separação UI/lógica: zero SQL ou regras de negócio em event handlers de formulários (Views)

→ Ver [exemplos completos](./exemplos/README.md)

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Usar `TObject` como parâmetro em vez de interface `I*` | Quebra encapsulamento; dificulta substituição de engine | Sempre declarar parâmetros com a interface correspondente |
| SQL inline em event handlers ou forms (Views) | Viola separação UI/lógica; impossível testar sem UI | Mover SQL para módulo de serviço ou usar QueryBuilder |
| Criar constante/tipo/record sem verificar `src/Commons` antes | Gera redundância e duplicação | Consultar Commons.Consts, Commons.Types antes de criar |
| Alterar unit fora do DPR sem autorização | Viola escopo de alteração; pode quebrar projetos externos | Solicitar autorização ao usuário antes de editar qualquer arquivo fora da raiz |
| Nomear classe sem prefixo `T` ou interface sem prefixo `I` | Viola convenção do projeto; gera inconsistência | Usar exatamente `TNome` para classes e `INome` para interfaces |

## Métricas de sucesso

- Código gerado compila sem hints/warnings em dcc32/dcc64 e fpc32/fpc64
- Nenhuma classe ou interface gerada viola as convenções de nomenclatura (`T*`/`I*`, Factory, Fluent)
- `Analise/<módulo>/<ClassName>.md` atualizado na mesma sessão em que o código é alterado

## Responsável principal

| Papel | Quem |
|-------|------|
| Agent executor | `dev-agent-*` (especialista do módulo) |
| Revisão humana | Desenvolvedor / Tech Lead |
| Aprovação final | Desenvolvedor responsável pelo módulo |

## Output Guidelines

- Propose code that follows project conventions
- Reference existing rules instead of duplicating
- Use LEGENDA in any status/planning text
- Prefer progressive disclosure — point to `.cursor/rules/` for details
- For class/API details, consult **Analise/** (`ClassName.md` for `T…` / `I…` types) as the knowledge base

---
description: "Diretivas de Compilação — habilitar/desabilitar módulos e engines; base para blocos {$IFDEF}"
alwaysApply: false
globs: ["**/*.pas", "**/*.inc", "**/*.dpr", "**/*.dproj"]
---

# Diretivas de Compilação

**Versão:** V1.1.0  
**Arquivo fonte:** `ORM.Defines.inc`  
**Responsabilidade deste documento:** **Diretivas de compilação** — habilitar/desabilitar módulos, engines e funcionalidades; base para blocos `{$IFDEF}`. Use esta regra para saber **quais diretivas existem** e **como habilitar/desabilitar**; para nomenclaturas, locais e processos, consulte as regras correspondentes.

---

## Consolidação por responsabilidade

As informações do projeto estão divididas por responsabilidade. **Siga sempre** a regra correta conforme a necessidade:

| Responsabilidade | Regra | Conteúdo principal |
|------------------|-------|--------------------|
| **Regras para criação** | **Inicial.mdc** | Changelog (projeto e por unit), **nomenclaturas** (classes I/T, métodos, variáveis, records), localização e centralização de criação, exceções por módulo, subagent, encapsulamento. |
| **Locais de arquivos e pacotes** | **local_arquivos.mdc** | **Onde estão** os arquivos: diretórios (src/, Data/, Analise/, dll/) e **pacotes de terceiros** do ambiente local (UniDAC, Zeos etc.), paths Parameters/Loggers, acesso CLI, compilação, FPC. |
| **Processos de execução** | **roadmap.mdc** | **Fases detalhadas** para criação do projeto, hierarquia ORM (Field → Fields → Table → Tables → Connection), Connection/Pool, parâmetros de conexão, Fluent, DDL/DML, CRUD, checklist, ordem de implementação. |
| **Diretivas de compilação** | **Este documento** (.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md) + skill **developer-delphi-programming-conditional-defines** | **Diretivas** (USE_*, habilitar/desabilitar), base para blocos `{$IFDEF}`; arquivo fonte `ORM.Defines.inc`. |

**Regra:** Ao criar ou alterar código, usar a regra adequada à responsabilidade — não duplicar aqui o que pertence a Inicial, local_arquivos ou roadmap.

---

## Como Habilitar e Desabilitar

| Ação | O que fazer |
|------|-------------|
| **Habilitar** | Descomentar a linha (remover `//` no início de `{$DEFINE ...}`) |
| **Desabilitar** | Comentar a linha (adicionar `//` antes de `{$DEFINE ...}`) |
| **Referência** | Sempre consultar `ORM.Defines.inc` antes de escrever código condicional |

---

## Módulos Opcionais (Configuração de Módulos)

| Diretiva | Descrição | Habilitado | Desabilitado |
|----------|-----------|------------|--------------|
| `USE_PARAMENTERS` | Integração com Parameters (INI, JSON, DB) | Conexão usa FromConfig, FromParameters | Apenas configuração manual (Host, Port, etc.) |
| `USE_LOGGERS` | Sistema de logging | Logs via Database.Loggers.* | Sem logging interno |
| `USE_POOLCONNECTIONS` | Pool de conexões | Reutilização de conexões | Uma nova conexão por instância |

---

## Funcionalidades Opcionais (ORM Core)

| Diretiva | Descrição | Requisitos | Habilitado | Desabilitado |
|----------|-----------|------------|------------|--------------|
| `USE_ATTRIBUTES` | Attributes (RTTI) — mapeamento [Table]/[Field]; [Parameter]/[Logger] em src/Attributers | Delphi XE7+ ou FPC 3.3.1+; RTTI nas classes | Uso de [Table], [Field]; [Parameter]/[Logger] via Providers.Attributers.* | Uso manual (Fields/Table/Tables) |
| `USE_ENTITY_MANAGER` | Entity Manager (persistência direta) | **Requer** USE_ATTRIBUTES | TDatabase.NewEntityManager\<T\> | SQL/Tables manual |
| `USE_QUERY_BUILDER` | Query Builder (API fluente) | Nenhum; com USE_ATTRIBUTES permite .FromClass() | TDatabase.NewQueryBuilder | SQL manual ou Tables |

---

## Engines de Banco de Dados (um por compilação)

| Diretiva | Descrição | Plataforma |
|----------|-----------|------------|
| `USE_UNIDAC` | UniDAC — Universal Data Access Components | Delphi + FPC |
| `USE_FIREDAC` | FireDAC — Framework Embarcadero | **Apenas Delphi** (não disponível no FPC) |
| `USE_ZEOS` | Zeos — Biblioteca open-source | Delphi + FPC; recomendado para FPC |
| `USE_SQLDB` | SQLdb — Nativo FPC/Lazarus | **Apenas FPC** |

**Regra:** Descomentar **apenas um** engine. No FPC, FireDAC é desativado automaticamente.

---

## Engines de Serviços

| Diretiva | Descrição |
|----------|-----------|
| `USE_LDAP` | LDAP (Synapse) — opcional; LDAP sempre incluído por padrão |

---

## Engines relacionados a Email / HTTP / WebSocket

A **ordem** da tabela abaixo é a **prioridade** recomendada. Descomente em **ORM.Defines.inc** no máximo um engine (ou a combinação desejada, conforme o código). **Para que serve:** **Email** = SMTP/envio de mensagens; **HTTP** = requisições REST/API; **WebSocket** = conexão bidirecional em tempo real.

| Diretiva | Descrição | Uso |
|----------|-----------|-----|
| `USE_INDY` | Email/HTTP/WebSocket via Indy | Email, HTTP, WebSocket |
| `USE_ICS` | Email/HTTP/WebSocket via ICS (Internet Component Suite) | Email, HTTP, WebSocket |
| `USE_IPWORKS` | Email/HTTP/WebSocket via IPWorks 2024 (nSoftware, comercial) | Email, HTTP, WebSocket |
| `USE_SYNAPSE` | Email/HTTP via Synapse | Email, HTTP |
| `USE_TMS_WEBSOCKET` | WebSocket via TMS FNC WebSocket (comercial) | WebSocket |
| `USE_SYNAPSE_WS` | WebSocket via Synapse WebSocket | WebSocket |
| `USE_HORSE` | WebSocket via Horse SocketIO | WebSocket |
| `USE_BIRD_SOCKET` | WebSocket via Bird Socket Server | WebSocket |

---

## Frameworks de Controles (VCL / FMX)

Escolha **um** framework de UI por compilação. As Views (ufrmLoggers, ufrmParameters, ufrmParametersAttributers) compilam com **compilação condicional** conforme a diretiva ativa; o recurso de formulário (.dfm ou .fmx) é vinculado no .dpr conforme o framework.

| Diretiva | Descrição | Quando usar |
|----------|-----------|-------------|
| `USE_FMX` | FireMonkey — formulários .fmx, units FMX.* (FMX.Forms, TTabControl, TTabItem, TListViewItem, etc.) | Projeto Windows/multiplataforma FireMonkey; aplicação principal usa FMX.Forms |
| `VCL` | Visual Component Library — formulários .dfm, units Vcl.* (Vcl.Forms, TPageControl, TTabSheet, TListItem, TDateTimePicker, etc.) | Projeto Windows VCL; aplicação principal usa Vcl.Forms |
| `USE_DEVEXPRESS` | DevExpress VCL (requer VCL) | Componentes DevExpress (cxTextEdit, cxGrid, etc.) |
| `USE_KONOPKA` | Konopka Signature VCL (requer VCL) | Componentes Konopka (TRzEdit, TRzComboBox, etc.) |
| `USE_VERSIONINFO` | InfoEmbed / VersionInfo embutido | Versionamento do executável |

**Regra:** Descomentar **apenas uma** das diretivas de framework de UI em `ORM.Defines.inc`: `USE_FMX` **ou** `VCL`. Se nenhuma estiver definida, o padrão é **VCL** (compatível com FPC/Lazarus).

### Formulários com suporte VCL e FMX

As units `ufrmLoggers`, `ufrmParameters` e `ufrmParametersAttributers` usam `{$IF DEFINED(USE_FMX)}` / `{$ELSE}` para:

- **Uses:** FMX.Types, FMX.Forms, FMX.StdCtrls, … (USE_FMX) **ou** Vcl.* / LCL (VCL);
- **Tipos de controles:** TTabControl/TTabItem (FMX) **ou** TPageControl/TTabSheet (VCL); TListViewItem (FMX) **ou** TListItem (VCL); TDateTimePicker (VCL) **ou** TEdit para datas (FMX quando não houver equivalente);
- **Recurso de formulário no .dpr:** vincular `.fmx` quando `USE_FMX` estiver definido e `.dfm` quando `VCL` estiver definido.

**Exemplo no .dpr (recurso de formulário):**

```pascal
{$IF DEFINED(USE_FMX)}
  ufrmLoggers in 'src\Views\ufrmLoggers.pas' {frmLoggers.fmx},
{$ELSE}
  ufrmLoggers in 'src\Views\ufrmLoggers.pas' {frmLoggers.dfm},
{$ENDIF}
```

**Exemplo em unit de form (uses condicional):**

```pascal
{$IF DEFINED(USE_FMX)}
uses
  System.SysUtils, System.Classes, FMX.Forms, FMX.StdCtrls, FMX.Controls, ...
{$ELSE}
uses
  Winapi.Windows, Vcl.Forms, Vcl.StdCtrls, Vcl.Controls, ...  // ou LCL no FPC
{$ENDIF}
```

---

## Construção de Código — Regras

**Unit de referência para engines (UniDAC, FireDAC, Zeos, SQLdb):** `src/Modulos/Parameters/Database/Parameters.Database.pas`. Seguir o mesmo padrão reduz a quantidade de linhas e mantém consistência.

### Ordem fixa dos engines nas condicionais

Sempre usar esta ordem para **um engine por compilação** (evitar múltiplos blocos separados):

1. `USE_UNIDAC`
2. `USE_FIREDAC`
3. `USE_ZEOS`
4. `USE_SQLDB`
5. fallback (`TObject`, `nil`, `teNone`, `TDataSet`, etc.)

### Padrão compacto: tipo de campo (declaração)

Encadear `{$IF DEFINED(...)}` / `{$ELSE}` na mesma declaração; fallback no último `{$ELSE}`. Um único ponto e vírgula no final.

```pascal
FConnection: {$IF DEFINED(USE_UNIDAC)}            TUniConnection
             {$ELSE}
               {$IF DEFINED(USE_FIREDAC)}  TFDConnection
               {$ELSE}
                 {$IF DEFINED(USE_ZEOS)}     TZConnection
                 {$ELSE} {$IF DEFINED(USE_SQLDB)} TSQLConnection
                 {$ELSE}                         TObject
                 {$ENDIF}
                 {$ENDIF}
               {$ENDIF}
             {$ENDIF};
FQuery: {$IF DEFINED(USE_UNIDAC)}            TUniQuery
        {$ELSE}
          {$IF DEFINED(USE_FIREDAC)} TFDQuery
          {$ELSE}
            {$IF DEFINED(USE_ZEOS)}    TZQuery
            {$ELSE} {$IF DEFINED(USE_SQLDB)} TSQLQuery
            {$ELSE}                         TDataSet
            {$ENDIF}
            {$ENDIF}
          {$ENDIF}
        {$ENDIF};
```

Campos específicos de um único engine ficam em bloco separado e curto:

```pascal
{$IF DEFINED(USE_SQLDB)}
FTransaction: TSQLTransaction;
FOwnTransaction: Boolean;
{$ENDIF}
```

### Padrão compacto: criação de instância (Create)

Mesma árvore de diretivas; fallback `nil` quando nenhum engine definido.

```pascal
FConnection := {$IF DEFINED(USE_UNIDAC)}
                  TUniConnection.Create(nil)
               {$ELSE} {$IF DEFINED(USE_FIREDAC)}
                         TFDConnection.Create(nil)
                       {$ELSE} {$IF DEFINED(USE_ZEOS)}
                                 TZConnection.Create(nil)
                               {$ELSE}
                                 nil
                               {$ENDIF}
                       {$ENDIF}
               {$ENDIF};
```

Para SQLdb, usar bloco à parte (ex.: `case` por tipo de banco) e depois a mesma regra para FQuery/FExecQuery.

### Padrão compacto: resultado de função (enum ou valor)

Encadear na mesma ordem (UNIDAC → FIREDAC → ZEOS → SQLDB → else).

```pascal
begin
  {$IF DEFINED(USE_UNIDAC)}
    Result := teUnidac;
  {$ELSE}
    {$IF DEFINED(USE_FIREDAC)}
      Result := teFireDAC;
    {$ELSE}
      {$IF DEFINED(USE_ZEOS)}
        Result := teZeos;
      {$ELSE}
        {$IF DEFINED(USE_SQLDB)}
          Result := teSQLdb;
        {$ELSE}
          Result := teNone;
        {$ENDIF}
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
end;
```

### Padrão: cast/atribuição por engine (constructor ou SetConnection)

Repetir a mesma ordem: verificar `AConnection is TUniConnection`, depois `TFDConnection`, depois `TZConnection`, depois `TSQLConnection`, else genérico. Idem para AQuery / AExecQuery.

```pascal
if Assigned(AConnection) then
begin
  {$IF DEFINED(USE_UNIDAC)}
  if AConnection is TUniConnection then
    FConnection := TUniConnection(AConnection);
  {$ELSE}
    {$IF DEFINED(USE_FIREDAC)}
      if AConnection is TFDConnection then
        FConnection := TFDConnection(AConnection);
    {$ELSE}
      {$IF DEFINED(USE_ZEOS)}
        if AConnection is TZConnection then
          FConnection := TZConnection(AConnection);
      {$ELSE} {$IF DEFINED(USE_SQLDB)}
        if AConnection is TSQLConnection then
          // ... atribuir FConnection e FTransaction
      {$ELSE}
        FConnection := AConnection;
      {$ENDIF}
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
end;
```

### Regras gerais

1. **Consultar ORM.Defines.inc** — Verificar qual diretiva controla a funcionalidade.
2. **Usar `{$IF DEFINED(...)}`** — Preferir `DEFINED()` para evitar símbolo não definido quando a diretiva não existe.
3. **Encadear com `{$ELSE} {$IF DEFINED(...)}`** — Reduz linhas em relação a vários `{$IF} ... {$ENDIF}` seguidos.
4. **Fallback no último `{$ELSE}`** — Sempre tratar o caso “nenhum engine” (TObject, nil, teNone, etc.).
5. **Campos/units só de um engine** — Bloco único e curto: `{$IF DEFINED(USE_SQLDB)} ... {$ENDIF}`.
6. **Dependências** — Entity Manager requer USE_ATTRIBUTES. Atributos em **src/Attributers**; Parameters/Loggers reexportam conforme USE_PARAMENTERS/USE_LOGGERS.

### Exemplo de uses condicional (módulos / engine)

```pascal
{$IF DEFINED(USE_PARAMENTERS)}  uses Parameters;  {$ENDIF}
{$IF DEFINED(USE_LOGGERS)}      uses Loggers;      {$ENDIF}
{$IF DEFINED(USE_FIREDAC)}
  uses FireDAC.Comp.Client;
{$ELSE}{$IF DEFINED(USE_ZEOS)}
  uses ZConnection, ZDataset;
{$ENDIF}{$ENDIF}
```

### Projetos que não incluem o .inc

Se o projeto **não incluir** `ORM.Defines.inc` (ex.: Services.Cliente), definir `USE_ATTRIBUTES` e/ou `USE_PARAMENTERS` nas **opções do projeto** (dproj/cfg). Caso contrário: "identificador não declarado" (TableAttribute, TParameterSource, etc.).

---

## Referência cruzada (consolidação por responsabilidade)

- **Arquivo fonte:** `ORM.Defines.inc`
- **Inicial.mdc** → Nomenclaturas (classes, métodos, variáveis, records), Changelog, localização, encapsulamento
- **local_arquivos.mdc** → Paths de units, pacotes (UniDAC, Zeos, etc.), diretórios src/Modulos
- **roadmap.mdc** → Fases de implementação, hierarquia ORM, Connection, CRUD, Fluent, ordem de execução
- **Plano unificado do ecossistema:** `.cursor/plans/plano_unificado_ecossistema_orm.plan.md` — visão de unificação dos cinco projetos, diretivas (módulos, engines DB, WebSocket/Email/HTTP, UI, VCL/FMX, USE_VERSIONINFO), API externa, integração e validação multi-engine

---

## Exemplos ORM Core — USE_ATTRIBUTES / USE_ENTITY_MANAGER / USE_QUERY_BUILDER

### USE_ATTRIBUTES — declaração de entidade

```pascal
// ORM.Defines.inc deve ter {$DEFINE USE_ATTRIBUTES}
uses Providers.Attributers.Interfaces, Providers.Attributers;

type
  [Table('usuarios')]
  TUsuario = class
  private
    FId: Integer;
    FNome: string;
  public
    [Field('id')] [PrimaryKey] [AutoIncrement]
    property Id: Integer read FId write FId;
    [Field('nome')]
    property Nome: string read FNome write FNome;
  end;
```

### USE_ENTITY_MANAGER — CRUD declarativo

> **Requer:** `USE_ENTITY_MANAGER` **e** `USE_ATTRIBUTES` ativos em `ORM.Defines.inc`.

```pascal
// ORM.Defines.inc deve ter:
//   {$DEFINE USE_ATTRIBUTES}
//   {$DEFINE USE_ENTITY_MANAGER}
uses Database, EntityManager;

var
  LEM: IEntityManager;
  LUser: TUsuario;
begin
  LEM := TDatabase.New(LConn).NewEntityManager;
  // Save (INSERT ou UPDATE)
  LUser := TUsuario.Create;
  try
    LUser.Nome := 'Alice';
    LEM.Save<TUsuario>(LUser);
    // Find por PK
    LUser := LEM.Find<TUsuario>(1);
    // FindAll
    for LUser in LEM.FindAll<TUsuario> do
      Writeln(LUser.Nome);
    // Delete
    LEM.Delete<TUsuario>(LUser);
  finally
    LUser.Free;
  end;
end;
```

### USE_QUERY_BUILDER — SQL fluente

```pascal
// USE_QUERY_BUILDER não exige USE_ATTRIBUTES, mas com USE_ATTRIBUTES
// permite .FromClass<T>() para mapear campos automaticamente.
uses Database, QueryBuilder;

var
  LQBL: IQueryBuilder;
  LDS: TDataSet;
begin
  LQBL := TDatabase.New(LConn).NewQueryBuilder;
  LDS := LQBL
    .Select(['id', 'nome', 'email'])
    .From('usuarios')
    .Where('ativo = :ativo')
    .Param('ativo', True)
    .OrderBy('nome')
    .Build
    .Execute;
  try
    while not LDS.Eof do
    begin
      Writeln(LDS.FieldByName('nome').AsString);
      LDS.Next;
    end;
  finally
    LDS.Free;
  end;
end;
```

### Dependência USE_ENTITY_MANAGER → USE_ATTRIBUTES

```pascal
// ORM.Defines.inc — CORRETO
{$DEFINE USE_ATTRIBUTES}      // requerido
{$DEFINE USE_ENTITY_MANAGER}  // depende de USE_ATTRIBUTES

// ORM.Defines.inc — ERRADO: USE_ENTITY_MANAGER sem USE_ATTRIBUTES
// gera erro de compilação "identificador não declarado: TableAttribute"
//{$DEFINE USE_ATTRIBUTES}
{$DEFINE USE_ENTITY_MANAGER}  // <-- NÃO FAZER
```

---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.1.0 (11/04/2026): Adicionada seção "Exemplos ORM Core" com USE_ATTRIBUTES (declaração de entidade), USE_ENTITY_MANAGER (CRUD declarativo), USE_QUERY_BUILDER (SQL fluente) e bloco de dependência USE_ENTITY_MANAGER → USE_ATTRIBUTES.
- 1.0.2 (30/03/2026): Rodapé único (um bloco Changelog + tabela **Versão interna**).
- 1.0.1 (14/03/2026): Frameworks de Controles — seção expandida com USE_FMX/VCL; tabela e regra (um por compilação); formulários com suporte VCL e FMX; exemplo .dpr e uses condicional. ORM.Defines.inc: USE_FMX para Delphi (não FPC), fallback VCL.

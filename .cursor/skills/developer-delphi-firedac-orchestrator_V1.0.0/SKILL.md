---
name: developer-delphi-firedac-orchestrator
description: >
  Orquestrador da família FireDAC — ponto de entrada para conexão, queries, datasets
  e transações. Ativar quando o usuário mencionar: FireDAC, TFDConnection, TFDQuery,
  TFDTable, TFDDataSet, acesso a banco Delphi, FireDAC driver, FireDAC connection,
  banco de dados Delphi, SQL Server FireDAC, MySQL FireDAC, PostgreSQL FireDAC,
  SQLite FireDAC, Firebird FireDAC, InterBase FireDAC, DataModule FireDAC.
model: sonnet
thinking: none
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-firedac-orchestrator

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Criado** | 2026-04-24 |
| **Família** | FireDAC — Data Access |

## Responsabilidade única

Ponto de entrada da família FireDAC. Identifica o contexto do usuário e roteia para
a skill especializada correta. Fornece visão geral da arquitetura, componentes
principais e padrões de organização em DataModules.

## Mapa da família FireDAC

| Skill | Escopo |
|-------|--------|
| `developer-delphi-firedac-connection` | TFDConnection, drivers, pooling, multi-banco |
| `developer-delphi-firedac-queries` | TFDQuery, TFDTable, parâmetros, datasets, campos calculados |
| `developer-delphi-firedac-transactions` | Transações, savepoints, CachedUpdates, Array DML |

## Quando ativar cada skill

```
Usuário quer → conectar ao banco, configurar driver, pool, .ini de conexão
  → developer-delphi-firedac-connection

Usuário quer → executar SQL, SELECT, INSERT, UPDATE, parâmetros, navegação de datasets
  → developer-delphi-firedac-queries

Usuário quer → transações, BEGIN/COMMIT/ROLLBACK, savepoints, CachedUpdates
  → developer-delphi-firedac-transactions

Usuário quer → relacionar FireDAC com TDBGrid, TDBEdit (data-aware)
  → developer-delphi-vcl-components
```

---

## Arquitetura FireDAC — visão geral

```
TFDManager (singleton global)
  └─ TFDConnection  — conexão ao banco (1 por DataModule ou pool)
       ├─ TFDQuery        — SELECT / DML com parâmetros e cursores
       ├─ TFDTable        — acesso direto a tabela (CRUD simples)
       ├─ TFDStoredProc   — stored procedures
       ├─ TFDCommand      — DDL e comandos sem resultado
       └─ TFDTransaction  — controle explícito de transação
```

### Componentes principais

| Componente | Função |
|-----------|--------|
| `TFDConnection` | Abre/fecha conexão, gerencia pool |
| `TFDQuery` | SELECT com cursor bidirecional, parâmetros nomeados |
| `TFDTable` | CRUD em tabela única sem SQL explícito |
| `TFDCommand` | Executa DDL/DML sem retorno de linhas |
| `TFDStoredProc` | Chama stored procedures |
| `TFDTransaction` | Transação explícita (multi-statement) |
| `TFDMemTable` | Dataset em memória, sem banco |
| `TDataSource` | Ponte VCL data-aware ↔ FireDAC dataset |

### Namespaces principais FireDAC

| Unit | Conteúdo |
|------|----------|
| `FireDAC.Comp.Client` | TFDConnection, TFDQuery, TFDTable, TFDCommand |
| `FireDAC.Comp.DataSet` | TFDDataSet base class |
| `FireDAC.Stan.Async` | Execução assíncrona |
| `FireDAC.Stan.Param` | TFDParam, parâmetros nomeados |
| `FireDAC.Stan.Option` | TFDOptions (fetch, format, resource) |
| `FireDAC.Stan.Def` | TFDDefinition, connection def |
| `FireDAC.UI.Intf` | Interface UI (wait cursor) |
| `FireDAC.Phys.*` | Drivers físicos (MSSQL, MySQL, PG, SQLite, FB) |
| `FireDAC.DApt.*` | Adaptadores de dados |
| `FireDAC.Moni.*` | Monitor de eventos (tracing) |

---

## Organização em DataModule

```pascal
unit udm.Principal;

interface

uses
  System.SysUtils, System.Classes,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  FireDAC.Phys.MSSQLDef, FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL,
  Data.DB;

type
  TdmPrincipal = class(TDataModule)
    FDConnection1: TFDConnection;
    // queries organizadas por domínio:
    qryClientes: TFDQuery;
    qryProdutos: TFDQuery;
    dsClientes: TDataSource;
    dsProdutos: TDataSource;
  public
    class function Instance: TdmPrincipal;
    procedure Conectar(const AServidor, ABanco, AUsuario, ASenha: string);
  end;

var
  dmPrincipal: TdmPrincipal;

implementation
{$R *.dfm}

// Padrão Singleton para DataModule global
var _Instance: TdmPrincipal;

class function TdmPrincipal.Instance: TdmPrincipal;
begin
  if not Assigned(_Instance) then
    _Instance := TdmPrincipal.Create(Application);
  Result := _Instance;
end;
```

---

## Padrões arquiteturais recomendados

### 1 — Separar DataModule por domínio (projetos médios/grandes)

```
DataModules/
  udm.Conexao.pas      ← só TFDConnection + TFDManager
  udm.Clientes.pas     ← queries de clientes
  udm.Produtos.pas     ← queries de produtos
  udm.Financeiro.pas   ← queries financeiras
```

### 2 — Encapsular queries em services

```pascal
// Evitar: TFDQuery acessado diretamente do form
// Preferir: service que encapsula queries e retorna DTOs

type
  IClienteRepository = interface
    function ListarAtivos: TArray<TClienteDTO>;
    procedure Salvar(const ACliente: TClienteDTO);
  end;
```

### 3 — Não expor TDataSet fora do DataModule para lógica de negócio

```
Form         → Service/Repository (DTOs)
DataModule   → FireDAC queries internas
TDBGrid      → TDataSource → TFDQuery (data-aware direto — único caso aceitável)
```

---

## Checklist de início — FireDAC

- [ ] Criar DataModule separado (`TDataModule`) para componentes de dados
- [ ] `TFDConnection` configurado com `LoginPrompt := False` para conexão automática
- [ ] Drivers físicos incluídos nas `uses` (`FireDAC.Phys.MSSQL`, etc.)
- [ ] `FDManager` configurado se usar connection definitions de arquivo `.ini`
- [ ] Transações explícitas (`TFDTransaction`) para operações multi-statement
- [ ] `Disconnect` chamado no `OnDestroy` do DataModule

## Referências cruzadas

- `developer-delphi-firedac-connection` — configuração de conexão e drivers
- `developer-delphi-firedac-queries` — queries, parâmetros, datasets
- `developer-delphi-firedac-transactions` — transações e CachedUpdates
- `developer-delphi-vcl-components` — componentes data-aware (TDBGrid, TDBEdit)

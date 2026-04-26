---
description: "Exemplos de seleção e configuração de drivers de banco — REST DataWare"
alwaysApply: false
---

# Roteiro — Drivers de Banco (REST DataWare)

> Fonte canônica: `app/modules/REST-DataWare/Documentation/Analise/Database_Drivers/RESTDWDriverBase.md`

## 1. Selecionar driver — tabela de decisão

| Critério | Driver recomendado | Diretiva |
| --- | --- | --- |
| Delphi + Windows + múltiplos bancos | FireDAC | `{$DEFINE RESTDWFIREDAC}` |
| Lazarus / FPC (multiplataforma) | Zeos | `{$DEFINE RESTDWZEOS}` |
| Lazarus / FPC (gratuito, simples) | SQLdb | `{$DEFINE RESTDWSQLDB}` |
| Máxima cobertura de bancos | UniDAC | `{$DEFINE RESTDWUNIDAC}` |
| Firebird / InterBase otimizado | IBDAC | `{$DEFINE RESTDWIBDAC}` |
| MySQL / MariaDB otimizado | MyDAC | `{$DEFINE RESTDWMYDAC}` |

## 2. Configurar diretiva em uRESTDW.inc

```pascal
// Arquivo: CORE/Source/uRESTDW.inc
// Habilitar exatamente UM driver por projeto

// Opção A — FireDAC (Delphi)
{$DEFINE RESTDWFIREDAC}
// {$DEFINE RESTDWZEOS}    // descomentado apenas um
// {$DEFINE RESTDWUNIDAC}

// Opção B — Zeos (Lazarus/FPC)
// {$DEFINE RESTDWFIREDAC}
{$DEFINE RESTDWZEOS}
// {$DEFINE RESTDWUNIDAC}
```

> Nunca ativar mais de um driver simultaneamente — causa conflito de compilação.

## 3. FireDAC — configurar TRESTDWPoolerDB no servidor

```pascal
uses uRESTDWPoolerDB;

// No servidor — configurar pooler com FireDAC + PostgreSQL
procedure TServerForm.ConfigurarFireDAC;
begin
  // Certificar: {$DEFINE RESTDWFIREDAC} ativo em uRESTDW.inc

  RESTDWPoolerDB1.DataBase    := 'empresa';
  RESTDWPoolerDB1.UserName    := 'postgres';
  RESTDWPoolerDB1.Password    := 'senha-bd';
  RESTDWPoolerDB1.ServerName  := 'db.empresa.com';
  RESTDWPoolerDB1.Port        := 5432;
  RESTDWPoolerDB1.DriverID    := 'PG';            // FireDAC DriverID para PostgreSQL
  RESTDWPoolerDB1.Active      := True;
end;

// FireDAC DriverIDs comuns:
// 'PG'       → PostgreSQL
// 'MSSQL'    → SQL Server
// 'MySQL'    → MySQL / MariaDB
// 'FB'       → Firebird
// 'SQLite'   → SQLite
// 'Oracle'   → Oracle
```

## 4. Zeos — configurar TRESTDWPoolerDB no servidor (Lazarus/FPC)

```pascal
// Certificar: {$DEFINE RESTDWZEOS} ativo em uRESTDW.inc

procedure TServerForm.ConfigurarZeos;
begin
  RESTDWPoolerDB1.DataBase   := 'empresa';
  RESTDWPoolerDB1.UserName   := 'postgres';
  RESTDWPoolerDB1.Password   := 'senha-bd';
  RESTDWPoolerDB1.ServerName := 'db.empresa.com';
  RESTDWPoolerDB1.Port       := 5432;
  RESTDWPoolerDB1.Protocol   := 'postgresql';   // Zeos protocol string
  RESTDWPoolerDB1.Active     := True;
end;

// Zeos Protocols comuns:
// 'postgresql'  → PostgreSQL
// 'mysql'       → MySQL
// 'sqlite-3'    → SQLite 3
// 'firebird'    → Firebird
// 'mssql'       → SQL Server
```

## 5. Lazarus SQLdb — configurar TRESTDWPoolerDB no servidor (FPC gratuito)

```pascal
// Certificar: {$DEFINE RESTDWSQLDB} ativo em uRESTDW.inc

procedure TServerForm.ConfigurarSQLdb;
begin
  RESTDWPoolerDB1.DataBase        := 'empresa';
  RESTDWPoolerDB1.UserName        := 'postgres';
  RESTDWPoolerDB1.Password        := 'senha-bd';
  RESTDWPoolerDB1.ServerName      := 'localhost';
  RESTDWPoolerDB1.Port            := 5432;
  RESTDWPoolerDB1.ConnectorType   := 'PostgreSQL';  // SQLdb connector
  RESTDWPoolerDB1.Active          := True;
end;

// SQLdb ConnectorTypes comuns:
// 'PostgreSQL'  → PostgreSQL (via libpq)
// 'MySQL 4.0'   → MySQL
// 'SQLite3'     → SQLite 3
// 'ODBC'        → Qualquer banco via ODBC
```

## 6. Trocar driver sem alterar código de negócio

```pascal
// O código de negócio usa APENAS TRESTDWClientSQL
// (nunca TRESTDWFireDACQuery, TRESTDWZeosQuery diretamente)

procedure TClientForm.ConsultarClientes;
begin
  // ESTE CÓDIGO NÃO MUDA ao trocar o driver no servidor
  RESTDWClientSQL1.SQL.Text := 'SELECT id, nome FROM clientes WHERE ativo = 1';
  RESTDWClientSQL1.Open;
  // ...
end;

// Para trocar de FireDAC para Zeos:
// 1. No servidor: editar uRESTDW.inc (trocar diretiva)
// 2. Recompilar o servidor
// 3. O cliente NÃO precisa de alterações
```

# Referência rápida — Firebird (`isql`)

## Executável

Sistema: `C:\Program Files\Firebird\Firebird_2_5\bin\isql.exe` (ou 3.0+).

## Parâmetros essenciais

| Parâmetro | Descrição |
|-----------|-----------|
| `-u <user>` | Usuário (default: `SYSDBA`) |
| `-p <senha>` | Senha (default: `masterkey`) |
| `-d <conn>` | Connection string (`host/porta:caminho.fdb`) |
| `-i arquivo.sql` | Script de entrada |
| `-o arquivo` | Saída em arquivo |
| `-b` | Bail out no primeiro erro (automação) |
| `-q` | Quiet mode (sem prompts) |
| `-e` | Echo dos comandos |

## Comandos interativos

| Comando | Descrição |
|---------|-----------|
| `SHOW TABLES;` | Lista tabelas |
| `SHOW COLUMNS <TABELA>;` | Colunas da tabela |
| `SHOW INDEXES [<TABELA>];` | Índices |
| `SHOW DATABASE;` | Info do banco atual |
| `CONNECT 'host/porta:caminho.fdb' USER 'u' PASSWORD 'p';` | Conectar |
| `SET LIST ON;` | Formato uma-coluna-por-linha |
| `SET HEADING OFF;` | Sem cabeçalho |
| `OUTPUT arquivo.txt;` | Redireciona output |
| `OUTPUT;` | Volta para stdout |
| `EXIT;` / `QUIT;` | Sai |

## Queries prontas

### Versão

```sql
SELECT RDB$GET_CONTEXT('SYSTEM','ENGINE_VERSION') FROM RDB$DATABASE;
```

### Listar tabelas

Fonte: `GetSQLTablesFireBird` em `Providers.Common.SQLBuilder.pas`.

```sql
SELECT
  '' as table_catalog,
  '' as table_schema,
  RDB$RELATION_NAME as table_name,
  'BASE TABLE' as table_type
FROM RDB$RELATIONS
WHERE RDB$SYSTEM_FLAG = 0
  AND RDB$RELATION_TYPE = 0
ORDER BY RDB$RELATION_NAME;
```

### Colunas com PK

Fonte: `GetSQLFieldsFireBird` em `Providers.Common.SQLBuilder.pas`. Parâmetro: `<TABELA>` (nome maiúsculo no Firebird).

```sql
SELECT
  '' as table_catalog,
  '' as table_schema,
  rf.RDB$RELATION_NAME as table_name,
  rf.RDB$FIELD_POSITION + 1 as position,
  rf.RDB$FIELD_NAME as column_name,
  upper(CASE f.RDB$FIELD_TYPE
    WHEN 7  THEN 'SMALLINT'
    WHEN 8  THEN 'INTEGER'
    WHEN 10 THEN 'FLOAT'
    WHEN 12 THEN 'DATE'
    WHEN 13 THEN 'TIME'
    WHEN 14 THEN 'CHAR'
    WHEN 16 THEN 'BIGINT'
    WHEN 27 THEN 'DOUBLE PRECISION'
    WHEN 35 THEN 'TIMESTAMP'
    WHEN 37 THEN 'VARCHAR'
    WHEN 261 THEN 'BLOB'
    ELSE 'UNKNOWN'
  END) as data_type,
  f.RDB$FIELD_LENGTH as character_maximum_length,
  CASE WHEN rf.RDB$NULL_FLAG = 1 THEN 'NO' ELSE 'YES' END as is_nullable,
  rf.RDB$DEFAULT_SOURCE as column_default,
  (SELECT 1
    FROM RDB$RELATION_CONSTRAINTS rc1
    JOIN RDB$INDEX_SEGMENTS ise ON rc1.RDB$INDEX_NAME = ise.RDB$INDEX_NAME
    WHERE rc1.RDB$CONSTRAINT_TYPE = 'PRIMARY KEY'
      AND rc1.RDB$RELATION_NAME = '<TABELA>'
      AND ise.RDB$FIELD_NAME = rf.RDB$FIELD_NAME) as pkey
FROM RDB$RELATION_FIELDS rf
JOIN RDB$FIELDS f ON rf.RDB$FIELD_SOURCE = f.RDB$FIELD_NAME
WHERE rf.RDB$RELATION_NAME = '<TABELA>'
ORDER BY rf.RDB$FIELD_POSITION;
```

### Contar / Top N

```sql
SELECT COUNT(*) FROM <TABELA>;
SELECT FIRST 10 * FROM <TABELA>;
```

## Padrão de uso

```bash
# Conexão remota TCP/IP
& "C:\Program Files\Firebird\Firebird_2_5\bin\isql.exe" \
  -u SYSDBA -p masterkey \
  -d "<HOST>/<PORTA>:<CAMINHO_FDB>" \
  -q

# Conexão local
& "C:\Program Files\Firebird\Firebird_2_5\bin\isql.exe" \
  -u SYSDBA -p masterkey \
  -d "C:\dados\base.fdb"
```

## Script `.sql`

```bash
isql.exe -u SYSDBA -p masterkey \
  -d "<HOST>/<PORTA>:<CAMINHO_FDB>" \
  -i Data/script.sql \
  -o Data/output.txt \
  -b
```

## Exportação CSV (via OUTPUT + SET)

```sql
SET HEADING OFF;
SET LIST OFF;
OUTPUT Data/<TABELA>.csv;
SELECT col1 || ',' || col2 || ',' || col3 FROM <TABELA>;
OUTPUT;
```

## Backup / Restore

Com `gbak.exe` (mesma pasta do isql):

```bash
# Backup
& "C:\Program Files\Firebird\Firebird_2_5\bin\gbak.exe" \
  -backup -user SYSDBA -password masterkey \
  "<HOST>/<PORTA>:<CAMINHO_FDB>" "Data/backup.fbk"

# Restore
& "C:\Program Files\Firebird\Firebird_2_5\bin\gbak.exe" \
  -create -user SYSDBA -password masterkey \
  "Data/backup.fbk" "<HOST>/<PORTA>:<NOVO_FDB>"
```

## Automação

```bat
@echo off
isql.exe -u SYSDBA -p masterkey -d "..." -i script.sql -b -o output.txt
if errorlevel 1 (echo Erro & exit /b 1)
```

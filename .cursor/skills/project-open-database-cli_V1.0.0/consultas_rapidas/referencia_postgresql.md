# Referência rápida — PostgreSQL (`psql`)

## Executável

Sistema: `C:\Program Files\PostgreSQL\18\bin\psql.exe` (ou versão 13).

## Parâmetros essenciais

| Parâmetro | Descrição |
|-----------|-----------|
| `-h <host>` | Host |
| `-p <porta>` | Porta (default 5432) |
| `-U <user>` | Usuário |
| `-d <database>` | Database |
| `-c "query"` | Executa query e encerra |
| `-f arquivo.sql` | Script de entrada |
| `-o arquivo` | Saída em arquivo |
| `-A` | Output não-alinhado |
| `-t` | Sem headers nem rodapé |
| `-F "|"` | Separador de colunas |
| `-v ON_ERROR_STOP=1` | Sai no primeiro erro (automação) |

Senha via env `PGPASSWORD=<senha>` ou arquivo `~/.pgpass`.

## Meta-comandos (`\`)

| Comando | Descrição |
|---------|-----------|
| `\l` | Lista databases |
| `\c <db>` | Conectar a outro database |
| `\dt` | Lista tabelas |
| `\dn` | Lista schemas |
| `\d <tabela>` | Describe tabela |
| `\di` | Lista índices |
| `\df` | Lista funções |
| `\du` | Lista users/roles |
| `\q` | Sai |
| `\i arquivo.sql` | Executa arquivo |
| `\o arquivo` | Redireciona saída |
| `\timing` | Mostra tempo de execução |
| `\copy <tabela> TO 'arquivo' CSV HEADER` | Exporta CSV |

## Queries prontas

### Versão

```sql
SELECT version();
```

### Listar databases

```sql
SELECT datname FROM pg_database
WHERE datname NOT IN ('template0','template1','postgres')
ORDER BY datname;
```

### Listar tabelas de um schema

Fonte: `GetSQLTablesPostgreSQL` em `Providers.Common.SQLBuilder.pas`.

```sql
SELECT
  table_catalog,
  table_schema,
  table_name,
  table_type
FROM information_schema.tables
WHERE table_type = 'BASE TABLE'
  AND table_catalog = '<DATABASE>'
  AND table_schema  = '<SCHEMA>'
ORDER BY table_name;
```

### Colunas com PK

Fonte: `GetSQLFieldsPostgreSQL` em `Providers.Common.SQLBuilder.pas`.

```sql
WITH CKey AS (
  SELECT
    kcu.TABLE_CATALOG AS "database",
    kcu.TABLE_SCHEMA AS "schema",
    kcu.TABLE_NAME AS "table",
    tco.CONSTRAINT_NAME,
    kcu.ORDINAL_POSITION AS "position",
    kcu.COLUMN_NAME
  FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tco
  JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
    ON kcu.CONSTRAINT_NAME = tco.CONSTRAINT_NAME
   AND kcu.TABLE_SCHEMA    = tco.TABLE_SCHEMA
  WHERE tco.CONSTRAINT_TYPE = 'PRIMARY KEY'
    AND kcu.TABLE_SCHEMA    = '<SCHEMA>'
    AND kcu.TABLE_NAME      = '<TABELA>'
)
SELECT
  Col.TABLE_CATALOG            AS table_catalog,
  Col.TABLE_SCHEMA             AS table_schema,
  Col.TABLE_NAME               AS table_name,
  Col.ORDINAL_POSITION         AS position,
  Col.COLUMN_NAME              AS column_name,
  upper(Col.DATA_TYPE)         AS data_type,
  Col.CHARACTER_MAXIMUM_LENGTH AS character_maximum_length,
  Col.IS_NULLABLE              AS is_nullable,
  Col.COLUMN_DEFAULT           AS column_default,
  (SELECT 1               FROM CKey WHERE CKey.COLUMN_NAME = Col.COLUMN_NAME) AS PKey,
  (SELECT CONSTRAINT_NAME FROM CKey WHERE CKey.COLUMN_NAME = Col.COLUMN_NAME) AS constraint_name
FROM INFORMATION_SCHEMA.COLUMNS Col
WHERE Col.TABLE_SCHEMA = '<SCHEMA>'
  AND Col.TABLE_NAME   = '<TABELA>'
ORDER BY Col.ORDINAL_POSITION;
```

### Contar / Top N

```sql
SELECT COUNT(*) FROM <SCHEMA>.<TABELA>;
SELECT * FROM <SCHEMA>.<TABELA> LIMIT 10;
```

## Padrão de uso

```bash
# PowerShell
$env:PGPASSWORD="<SENHA>"
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h <HOST> -p <PORTA> -U <USUARIO> -d <DATABASE> -c "SELECT version();"

# bash / gitbash
PGPASSWORD="<SENHA>" "/c/Program Files/PostgreSQL/18/bin/psql.exe" -h <HOST> -p <PORTA> -U <USUARIO> -d <DATABASE> -c "..."
```

## Exportação CSV

```sql
\copy (SELECT * FROM <TABELA>) TO 'Data/<TABELA>.csv' WITH CSV HEADER;
```

Ou via linha de comando:

```bash
psql ... -c "\copy (SELECT * FROM <TABELA>) TO STDOUT WITH CSV HEADER" > Data/<TABELA>.csv
```

## Script `.sql`

```bash
psql -h <HOST> -U <USUARIO> -d <DATABASE> -v ON_ERROR_STOP=1 -f Data/script.sql -o Data/output.txt
```

## Backup / Restore

```bash
# Backup
& "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe" -h <HOST> -U <USUARIO> -d <DATABASE> -F c -f Data/backup.dump

# Restore
& "C:\Program Files\PostgreSQL\18\bin\pg_restore.exe" -h <HOST> -U <USUARIO> -d <DATABASE> Data/backup.dump
```

## Automação

```bash
psql -v ON_ERROR_STOP=1 -h <HOST> -U <USUARIO> -d <DATABASE> -f Data/script.sql
if [ $? -ne 0 ]; then echo "Erro"; exit 1; fi
```

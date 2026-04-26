# Referência rápida — MySQL / MariaDB (`mysql`, `mysqlsh`)

## Executáveis

Workspace: `./MySQL/bin/mysql.exe`, `./MySQL/bin/mysqlsh.exe`
Sistema: `C:\Program Files\MySQL\MySQL Server 8.x\bin\mysql.exe`

## Parâmetros essenciais

| Parâmetro | Descrição |
|-----------|-----------|
| `-h <host>` | Host |
| `-P <porta>` | Porta (default 3306) |
| `-u <user>` | Usuário |
| `-p[senha]` | Senha (sem espaço para inline, ou prompt) |
| `-e "query"` | Executa query e encerra |
| `-D <banco>` | Banco inicial (ou último arg) |
| `--batch` | Saída tabular pipe-delimited |
| `--raw` | Sem escape de caracteres |

## Queries prontas

### Versão

```sql
SELECT VERSION(), @@hostname;
```

### Listar bancos (aplicação)

```sql
SHOW DATABASES;
```

Filtrar sistema manualmente: `mysql`, `performance_schema`, `information_schema`, `sys`.

### Listar tabelas de um banco

Fonte: `GetSQLTablesMySQL` em `Providers.Common.SQLBuilder.pas`.

```sql
SELECT
  TABLE_CATALOG as table_catalog,
  TABLE_SCHEMA  as table_schema,
  TABLE_NAME    as table_name,
  TABLE_TYPE    as table_type
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
  AND TABLE_SCHEMA = '<DATABASE>'
ORDER BY TABLE_NAME;
```

Alternativa interativa: `SHOW TABLES;` (dentro de `USE <banco>`).

### Colunas com PK

Fonte: `GetSQLFieldsMySQL` em `Providers.Common.SQLBuilder.pas`.

```sql
SELECT
  TABLE_CATALOG            AS table_catalog,
  TABLE_SCHEMA             AS table_schema,
  TABLE_NAME               AS table_name,
  ORDINAL_POSITION         AS position,
  COLUMN_NAME              AS column_name,
  DATA_TYPE                AS data_type,
  CHARACTER_MAXIMUM_LENGTH AS character_maximum_length,
  IS_NULLABLE              AS is_nullable,
  COLUMN_DEFAULT           AS column_default,
  CASE WHEN COLUMN_KEY = 'PRI' THEN 1 ELSE 0 END AS PKey
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = '<DATABASE>'
  AND TABLE_NAME   = '<TABELA>'
ORDER BY ORDINAL_POSITION;
```

### Contar / Top N

```sql
SELECT COUNT(*) FROM <TABELA>;
SELECT * FROM <TABELA> LIMIT 10;
```

## Comandos interativos (mysql)

| Comando | Descrição |
|---------|-----------|
| `\?` / `help` | Ajuda |
| `\q` / `quit` | Sai |
| `\G` | Resultado em formato vertical |
| `\s` / `status` | Status da conexão |
| `source arquivo.sql` | Executa script |
| `\u <banco>` | Equivalente a `USE` |
| `\T arquivo` | Log do output em arquivo |
| `\t` | Desliga log |

## Padrão de uso

```bash
./MySQL/bin/mysql.exe -h <HOST> -P <PORTA> -u <USUARIO> -p<SENHA> <DATABASE> -e "..."
```

## Exportação

### CSV

```bash
./MySQL/bin/mysql.exe -h <HOST> -u <USUARIO> -p<SENHA> <DATABASE> \
  --batch --raw -e "SELECT * FROM <TABELA>;" > Data/<TABELA>.csv
```

### Script `.sql`

```bash
./MySQL/bin/mysql.exe -h <HOST> -u <USUARIO> -p<SENHA> <DATABASE> < Data/script.sql
```

## Backup / Restore

```bash
./MySQL/bin/mysqldump.exe -h <HOST> -u <USUARIO> -p<SENHA> <DATABASE> > Data/backup.sql
./MySQL/bin/mysql.exe     -h <HOST> -u <USUARIO> -p<SENHA> <DATABASE> < Data/backup.sql
```

## Automação

```bat
@echo off
./MySQL/bin/mysql.exe -h <HOST> -u <USUARIO> -p<SENHA> <DATABASE> < Data/script.sql
if errorlevel 1 (echo Erro & exit /b 1)
```

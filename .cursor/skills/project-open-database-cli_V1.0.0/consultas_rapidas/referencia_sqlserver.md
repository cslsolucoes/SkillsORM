# Referência rápida — SQL Server (`sqlcmd`)

## Executável

Workspace: `./MSSqlcmd/sqlcmd.exe`

## Parâmetros essenciais

| Parâmetro | Descrição |
|-----------|-----------|
| `-S <host>[,<porta>]` | Servidor / host (porta opcional com vírgula) |
| `-U <user>` | Usuário SQL |
| `-P <senha>` | Senha SQL |
| `-E` | Autenticação Windows (substitui -U/-P) |
| `-d <banco>` | Banco de dados inicial |
| `-Q "query"` | Executa query e encerra |
| `-i arquivo` | Script de entrada `.sql` |
| `-o arquivo` | Arquivo de saída |
| `-s ","` | Separador de colunas (CSV) |
| `-W` | Remove espaços em branco finais |
| `-h -1` | Remove cabeçalho |
| `-b` | Retorna erro ao shell em falha (automação) |
| `-N -C` | Conexão criptografada + confia no certificado |

## Queries prontas

### Versão / servidor

```sql
SELECT @@SERVERNAME, @@VERSION;
```

### Listar bancos (aplicação, exclui sistema)

```sql
SET NOCOUNT ON;
SELECT name FROM sys.databases
WHERE name NOT IN ('master','tempdb','model','msdb')
ORDER BY name;
```

### Listar tabelas de um banco

Fonte: `GetSQLTablesSQLServer` em `Providers.Common.SQLBuilder.pas`.

```sql
SET NOCOUNT ON;
SELECT
  TABLE_CATALOG as table_catalog,
  TABLE_SCHEMA  as table_schema,
  TABLE_NAME    as table_name,
  TABLE_TYPE    as table_type
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
  AND TABLE_CATALOG = '<DATABASE>'
  AND TABLE_SCHEMA  = '<SCHEMA>'
ORDER BY TABLE_NAME;
```

### Colunas com PK

Fonte: `GetSQLFieldsSQLServer` em `Providers.Common.SQLBuilder.pas`. Parâmetros: `<SCHEMA>` (ex.: `dbo`), `<TABELA>`.

```sql
With CKey as (
  Select
    kcu.TABLE_CATALOG as "database",
    kcu.TABLE_SCHEMA  as "schema",
    kcu.TABLE_NAME    as "table",
    tco.CONSTRAINT_NAME,
    kcu.ORDINAL_POSITION as "position",
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
  TABLE_CATALOG            as table_catalog,
  TABLE_SCHEMA             as table_schema,
  TABLE_NAME               as table_name,
  ORDINAL_POSITION         as position,
  COLUMN_NAME              as column_name,
  UPPER(DATA_TYPE)         as data_type,
  CHARACTER_MAXIMUM_LENGTH as character_maximum_length,
  IS_NULLABLE              as is_nullable,
  COLUMN_DEFAULT           as column_default,
  (Select 1               From CKey Where COLUMN_NAME = Col.COLUMN_NAME) as PKey,
  (Select CONSTRAINT_NAME From CKey Where COLUMN_NAME = Col.COLUMN_NAME) as constraint_name
FROM INFORMATION_SCHEMA.COLUMNS Col
WHERE TABLE_SCHEMA = '<SCHEMA>'
  AND TABLE_NAME   = '<TABELA>'
ORDER BY ORDINAL_POSITION;
```

### Contar registros

```sql
SELECT COUNT(*) AS Total FROM <TABELA>;
```

### Top N

```sql
SELECT TOP 10 * FROM <TABELA>;
```

## Comandos interativos

| Comando | Descrição |
|---------|-----------|
| `GO` | Envia batch atual para execução |
| `EXIT` | Sai do sqlcmd |
| `:RESET` | Limpa buffer atual |
| `:r arquivo.sql` | Inclui e executa arquivo SQL |
| `:setvar VAR valor` | Define variável |

## Padrão de uso

```bash
./MSSqlcmd/sqlcmd.exe -S <HOST> -U <USUARIO> -P "<SENHA>" -d <BANCO> -Q "..."
```

## Exportação

### CSV

```bash
./MSSqlcmd/sqlcmd.exe -S <HOST> -U <USUARIO> -P "<SENHA>" -d <BANCO> \
  -Q "SET NOCOUNT ON; SELECT * FROM <TABELA>;" \
  -s "," -W -h -1 \
  -o "Data/<TABELA>.csv"
```

### Script `.sql`

```bash
./MSSqlcmd/sqlcmd.exe -S <HOST> -U <USUARIO> -P "<SENHA>" -d <BANCO> \
  -i "Data/script.sql" -b \
  -o "Data/script_output.txt"
```

## Automação

```bat
@echo off
./MSSqlcmd/sqlcmd.exe -S <HOST> -U <USUARIO> -P "<SENHA>" -d <BANCO> ^
  -i Data\script.sql -b -o Data\script_output.txt
if errorlevel 1 (echo Erro & exit /b 1)
```

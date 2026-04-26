# Referência rápida — SQLite (`sqlite3`)

## Executável

Workspace: `./SQLite/sqlite3.exe`

## Parâmetros essenciais (linha de comando)

| Parâmetro | Descrição |
|-----------|-----------|
| `<arquivo.db>` | Banco a abrir (cria se não existir) |
| `-header` / `-noheader` | Liga/desliga cabeçalhos |
| `-csv` | Modo CSV |
| `-column` | Modo coluna (alinhado) |
| `-separator "STR"` | Separador |
| `-cmd "DOT_CMD"` | Executa dot command antes |
| `-bail` | Sai do shell no primeiro erro (automação) |

## Dot commands (interativos)

| Comando | Descrição |
|---------|-----------|
| `.tables` | Lista tabelas |
| `.schema [TABELA]` | Mostra CREATE |
| `.databases` | Bancos anexados |
| `.indexes [TABELA]` | Lista índices |
| `.headers on/off` | Cabeçalhos |
| `.mode csv/column/line/insert` | Formato de saída |
| `.output arquivo` | Redireciona saída |
| `.read arquivo.sql` | Executa arquivo |
| `.dump [TABELA]` | Gera SQL de backup |
| `.backup arquivo` | Cópia binária |
| `.restore arquivo` | Restaura de binário |
| `.import arquivo TABELA` | Importa CSV |
| `.quit` | Sai |

## Queries prontas

### Versão

```sql
SELECT sqlite_version();
```

### Listar tabelas (aplicação)

Fonte: `GetSQLTablesSQLite` em `Providers.Common.SQLBuilder.pas`.

```sql
SELECT
  '' as table_catalog,
  '' as table_schema,
  name as table_name,
  'BASE TABLE' as table_type
FROM sqlite_master
WHERE type = 'table'
  AND name NOT LIKE 'sqlite_%'
ORDER BY name;
```

### Colunas com PK

Fonte: `GetSQLFieldsSQLite` em `Providers.Common.SQLBuilder.pas`.

```sql
SELECT
  '' as table_catalog,
  '' as table_schema,
  '<TABELA>' as table_name,
  cid + 1 as position,
  name as column_name,
  type as data_type,
  0 as character_maximum_length,
  CASE WHEN "notnull" = 0 THEN 'YES' ELSE 'NO' END as is_nullable,
  dflt_value as column_default,
  pk as PKey
FROM pragma_table_info('<TABELA>')
ORDER BY cid;
```

### Contar / Top N

```sql
SELECT COUNT(*) FROM <TABELA>;
SELECT * FROM <TABELA> LIMIT 10;
```

## Padrão de uso

```bash
./SQLite/sqlite3.exe <ARQUIVO_DB> "SELECT name FROM sqlite_master WHERE type='table';"
```

## Modo interativo

```bash
./SQLite/sqlite3.exe <ARQUIVO_DB>
# prompt sqlite>
.headers on
.mode column
SELECT * FROM <TABELA> LIMIT 10;
.quit
```

## Exportação CSV

```bash
./SQLite/sqlite3.exe -header -csv <ARQUIVO_DB> "SELECT * FROM <TABELA>;" > Data/<TABELA>.csv
```

Ou via dot commands:

```sql
.headers on
.mode csv
.output Data/export.csv
SELECT * FROM <TABELA>;
.output stdout
```

## Backup

```bash
# Texto (portátil)
./SQLite/sqlite3.exe <ARQUIVO_DB> .dump > Data/backup.sql

# Binário (rápido)
./SQLite/sqlite3.exe <ARQUIVO_DB> ".backup Data/backup.db"
```

## Automação

```bash
./SQLite/sqlite3.exe -bail <ARQUIVO_DB> < Data/script.sql
# exit code != 0 em falha
```

# Exemplo: Explorar banco via CLI (6 passos)

Cenário completo de exploração de um banco, cobrindo os 5 SGBDs suportados. Substitua os placeholders `<HOST>`, `<PORTA>`, `<USUARIO>`, `<SENHA>`, `<DATABASE>`, `<SCHEMA>`, `<TABELA>`, `<ARQUIVO_DB>`, `<ARQUIVO_FDB>` pelos dados da sessão.

## 1. Validar conexão

### SQL Server

```bash
./MSSqlcmd/sqlcmd.exe -S <HOST>,<PORTA> -U <USUARIO> -P "<SENHA>" \
  -Q "SELECT @@SERVERNAME, GETDATE();"
```

### MySQL

```bash
./MySQL/bin/mysql.exe -h <HOST> -P <PORTA> -u <USUARIO> -p<SENHA> -e "SELECT VERSION(), NOW();"
```

### SQLite

```bash
./SQLite/sqlite3.exe <ARQUIVO_DB> "SELECT sqlite_version(), datetime('now');"
```

### PostgreSQL

```bash
$env:PGPASSWORD="<SENHA>"
psql -h <HOST> -p <PORTA> -U <USUARIO> -d postgres -c "SELECT version(), NOW();"
```

### Firebird

```bash
isql -u <USUARIO> -p <SENHA> -d "<HOST>/<PORTA>:<ARQUIVO_FDB>" \
  -q <<SQL
SELECT RDB\$GET_CONTEXT('SYSTEM','ENGINE_VERSION') FROM RDB\$DATABASE;
EXIT;
SQL
```

## 2. Listar bancos / databases

### SQL Server

```bash
./MSSqlcmd/sqlcmd.exe -S <HOST> -U <USUARIO> -P "<SENHA>" \
  -Q "SET NOCOUNT ON; SELECT name FROM sys.databases WHERE name NOT IN ('master','tempdb','model','msdb') ORDER BY name;"
```

### MySQL

```bash
./MySQL/bin/mysql.exe -h <HOST> -u <USUARIO> -p<SENHA> -e "SHOW DATABASES;"
```

### SQLite

SQLite tem um único database por arquivo. O nome é derivado do arquivo `.db`.

### PostgreSQL

```bash
psql -h <HOST> -U <USUARIO> -d postgres -c "\l"
```

### Firebird

Firebird tem um único database por arquivo `.fdb`. O nome é derivado do arquivo.

## 3. Listar tabelas

### SQL Server

```bash
./MSSqlcmd/sqlcmd.exe -S <HOST> -U <USUARIO> -P "<SENHA>" -d <DATABASE> \
  -Q "SET NOCOUNT ON; SELECT TABLE_SCHEMA + '.' + TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_SCHEMA, TABLE_NAME;"
```

### MySQL

```bash
./MySQL/bin/mysql.exe -h <HOST> -u <USUARIO> -p<SENHA> <DATABASE> -e "SHOW TABLES;"
```

### SQLite

```bash
./SQLite/sqlite3.exe <ARQUIVO_DB> "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name;"
```

### PostgreSQL

```bash
psql -h <HOST> -U <USUARIO> -d <DATABASE> -c "\dt <SCHEMA>.*"
```

### Firebird

```sql
SELECT RDB$RELATION_NAME FROM RDB$RELATIONS
WHERE RDB$SYSTEM_FLAG = 0 AND RDB$RELATION_TYPE = 0
ORDER BY RDB$RELATION_NAME;
```

## 4. Ver colunas de uma tabela

Queries completas em [../consultas_rapidas/](../consultas_rapidas/) por SGBD.

Básico por SGBD:

- **SQL Server:** `SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='<TABELA>';`
- **MySQL:** `DESCRIBE <TABELA>;` ou `SHOW COLUMNS FROM <TABELA>;`
- **SQLite:** `PRAGMA table_info(<TABELA>);`
- **PostgreSQL:** `\d <TABELA>`
- **Firebird:** `SHOW COLUMNS <TABELA>;`

Para colunas com PK identificada: usar as queries completas em `consultas_rapidas/referencia_<sgbd>.md#colunas-com-pk`.

## 5. Contar registros

```sql
SELECT COUNT(*) FROM <TABELA>;
```

Funciona em todos os 5 SGBDs.

## 6. Exportar para CSV

### SQL Server

```bash
./MSSqlcmd/sqlcmd.exe -S <HOST> -U <USUARIO> -P "<SENHA>" -d <DATABASE> \
  -Q "SET NOCOUNT ON; SELECT * FROM <TABELA>;" \
  -s "," -W -h -1 -o Data/<TABELA>.csv
```

### MySQL

```bash
./MySQL/bin/mysql.exe -h <HOST> -u <USUARIO> -p<SENHA> <DATABASE> \
  --batch --raw -e "SELECT * FROM <TABELA>;" > Data/<TABELA>.csv
```

### SQLite

```bash
./SQLite/sqlite3.exe -header -csv <ARQUIVO_DB> "SELECT * FROM <TABELA>;" > Data/<TABELA>.csv
```

### PostgreSQL

```bash
psql -h <HOST> -U <USUARIO> -d <DATABASE> -c "\copy (SELECT * FROM <TABELA>) TO STDOUT WITH CSV HEADER" > Data/<TABELA>.csv
```

### Firebird

```sql
SET HEADING OFF;
OUTPUT Data/<TABELA>.csv;
SELECT col1 || ',' || col2 FROM <TABELA>;
OUTPUT;
```

---

## Automação — exemplo com tratamento de erro

### Script universal (.bat)

```bat
@echo off
setlocal

rem Escolher SGBD e executar script com flag de erro apropriada
if "%1"=="sqlserver" (
  ./MSSqlcmd/sqlcmd.exe -S %HOST% -U %USER% -P %PASS% -d %DB% -i %2 -b -o %3
) else if "%1"=="mysql" (
  ./MySQL/bin/mysql.exe -h %HOST% -u %USER% -p%PASS% %DB% < %2 > %3
) else if "%1"=="sqlite" (
  ./SQLite/sqlite3.exe -bail %DB% < %2 > %3
) else if "%1"=="postgresql" (
  psql -v ON_ERROR_STOP=1 -h %HOST% -U %USER% -d %DB% -f %2 -o %3
) else if "%1"=="firebird" (
  isql -u %USER% -p %PASS% -d "%CONN%" -i %2 -b -o %3
) else (
  echo Uso: %0 ^<sgbd^> ^<script.sql^> ^<output.txt^>
  exit /b 1
)

if errorlevel 1 (echo Erro na execucao & exit /b 1)
echo Concluido.
```

## Script Python auxiliar

Usar [`.cursor/scripts/database_session_manager.py`](../../../scripts/database_session_manager.py) para automatizar o fluxo interativo:

```bash
python .cursor/scripts/database_session_manager.py
# ou especificar SGBD:
python .cursor/scripts/database_session_manager.py --sgbd postgresql
```

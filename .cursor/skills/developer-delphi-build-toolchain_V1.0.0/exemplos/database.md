# Acesso aos bancos de dados — CLI (workspace)

Documento de referência para **acesso por linha de comando (CLI)** aos bancos de dados configurados no **repositório aberto no workspace**. Inclui paths das ferramentas CLI, ficheiros de configuração (parâmetros de conexão) e como usar cada cliente para testes, scripts e inspeção de dados. Alinhado ao módulo Parameters e a **FromConfig** (`config.ini`, `config.json`, `Config.db` sob `Data\` na raiz do workspace).

---

## 1. Configuração de conexão (fonte única)

Os parâmetros de conexão são lidos pelos módulos **Parameters** e **Connection** a partir de:

| Arquivo / fonte | Local | Uso |
|-----------------|--------|-----|
| **config.ini** | `Data\config.ini` | Seções `[database]`, `[database_sqlite]`, etc. Chaves: host, port, username, password, database, schema, database_type. |
| **config.json** | `Data\config.json` | Objeto `database`; cada parâmetro pode ter estrutura `{ "valor": "...", "descricao": "", "ativo": true, "ordem": N }`. Para CLI, usar o campo **valor** (ou equivalente) de host, port, username, password, database, schema, database_type. |
| **config1.ini** / **config1.json** | `Data\config1.ini`, `Data\config1.json` | Variantes alternativas de configuração (mesma convenção de chaves). |
| **Config.db** (SQLite) | `Data\Config.db` | Banco usado pelo Parameters para armazenar configuração; pode conter tabela de parâmetros de conexão. |

**Chaves de conexão (INI/JSON):** `host`, `port`, `username`, `password`, `database`, `schema`, `database_type`. Mesma convenção dos módulos Parameters e Connection (FromConfig, FromIniFile, FromJSONObject).

**Raiz do workspace:** `.`. Paths de config relativos: `Data\config.ini`, `Data\config.json`, etc. Em **VS Code / Cursor** (`tasks.json`, argumentos de ferramentas), preferir **`${workspaceFolder}/Data/...`** em vez de caminho absoluto do clone.

### 1.1 Paths das ferramentas CLI (MSSqlcmd, MySQL, SQLite)

Paths típicos para acesso por linha de comando. Ajustar conforme a instalação em cada máquina.

| Ferramenta | Path completo |
|-------------|----------------|
| **sqlcmd (MSSqlcmd)** | `sqlcmd` (PATH) ou `<sqlcmd_install>\sqlcmd.exe` |
| **mysql (MySQL)** | `mysql` (PATH) ou `<mysql_install>\bin\mysql.exe` |
| **sqlite3 (SQLite)** | `sqlite3` (PATH) ou `<sqlite_install>\sqlite3.exe` |

- **MSSqlcmd:** path acima corresponde ao "Microsoft Command Line Utilities" / ODBC 170. Outras versões podem estar em `...\ODBC\130\Tools\Binn\` ou sob `Microsoft SQL Server\<versão>\Tools\Binn\`.
- **MySQL:** se o MySQL estiver em outro disco ou versão, usar o executável da instalação local (`<mysql_install>\bin\mysql.exe`).
- **SQLite:** baixar em [sqlite.org/download](https://www.sqlite.org/download.html) (sqlite-tools-win-*.zip) e incluir o diretório no PATH.

---

## 2. MySQL

### 2.1 Ferramenta CLI (path)

| Ferramenta | Uso | Path típico (Windows) |
|------------|-----|------------------------|
| **mysql.exe** | Cliente de linha de comando MySQL | **Path:** `mysql` (PATH) ou `<mysql_install>\bin\mysql.exe`. |

**PATH:** Incluir o diretório `bin` da instalação MySQL (ex.: `<mysql_install>\bin`) para usar `mysql` no terminal.

### 2.2 Arquivos de configuração (parâmetros de conexão)

| Arquivo | Descrição |
|---------|-----------|
| **Data/config.ini** | Seção `[database]` com database_type=MySQL (ou seção dedicada). Chaves: host, port, username, password, database, schema (opcional). |
| **Data/config.json** | Objeto `database` com host, port, username, password, database, schema; valores em `.valor` quando for estrutura completa. |

### 2.3 Parâmetros da ferramenta (resumo)

| Parâmetro | Significado | Exemplo |
|-----------|-------------|---------|
| **-h** | Host | `-h 127.0.0.1` ou `-h 192.168.1.100` |
| **-P** | Porta (P maiúsculo) | `-P 3306` |
| **-u** | Usuário | `-u root` |
| **-p** | Senha (prompt se não informado) | `-p` ou `-pMinhaSenha` (sem espaço) |
| **database** | Nome do banco (argumento posicional) | No final: `mysql ... nome_do_banco` |

### 2.4 Como usar (CLI)

Executar a partir da **raiz do projeto** ou de qualquer pasta, informando host, porta, usuário e banco conforme **Data/config.ini** ou **Data/config.json**:

```bat
mysql -h 192.168.1.100 -P 3306 -u root -p nome_do_banco
```

Executar script SQL:

```bat
mysql -h 192.168.1.100 -P 3306 -u root -p nome_do_banco < Data\script.sql
```

Com path completo da ferramenta (ajustar versão do Server):

```bat
mysql -h 127.0.0.1 -P 3306 -u root -p meubanco
```

---

## 3. SQLite

### 3.1 Ferramenta CLI (path)

| Ferramenta | Uso | Path típico (Windows) |
|------------|-----|------------------------|
| **sqlite3.exe** | Cliente de linha de comando SQLite | **Path:** `sqlite3` (PATH) ou `<sqlite_install>\sqlite3.exe`. |

**Download:** [sqlite.org/download](https://www.sqlite.org/download.html) — "Precompiled Binaries for Windows" (sqlite-tools).

### 3.2 Arquivos de configuração (parâmetros de conexão)

| Arquivo | Descrição |
|---------|-----------|
| **Data/config.ini** | Seção `[database_sqlite]` ou `[database]` com database_type=SQLite. Chave **database** = caminho do arquivo .db (ex.: `Data\test.db`, `Data\Config.db`). |
| **Data/config.json** | Objeto com chave database contendo caminho do .db. |

Não há host/port/username/password para SQLite; apenas o **caminho do arquivo** do banco.

### 3.3 Parâmetros da ferramenta (resumo)

| Parâmetro | Significado | Exemplo |
|-----------|-------------|---------|
| **arquivo.db** | Caminho do banco SQLite (argumento posicional) | `sqlite3 Data\Config.db` |
| **.read arquivo.sql** | Executar script (dentro do shell sqlite3) | `.read Data\script.sql` |
| **.quit** / **.exit** | Sair do shell | — |

### 3.4 Como usar (CLI)

A partir da **raiz do projeto** (`.`):

```bat
sqlite3 Data\Config.db
```

Abrir e executar script:

```bat
sqlite3 Data\Config.db < Data\script.sql
```

Com path completo (exemplo):

```bat
sqlite3 Data\test.db
```

Dentro do shell sqlite3: `.tables`, `.schema`, `SELECT ...`, etc.

---

## 4. Firebird

### 4.1 Ferramenta CLI (path)

| Ferramenta | Uso | Path típico (Windows) |
|------------|-----|------------------------|
| **isql.exe** | Interativo SQL (Firebird) | `isql` (PATH) ou `<firebird_install>\isql.exe`. |
| **gsec.exe** | Gerenciamento de usuários (opcional) | `gsec` (PATH) ou `<firebird_install>\gsec.exe`. |

**Porta padrão Firebird:** 3050.

### 4.2 Arquivos de configuração (parâmetros de conexão)

| Arquivo | Descrição |
|---------|-----------|
| **Data/config.ini** | Seção `[database]` com database_type=Firebird. Chaves: host, port (ex.: 3050), username (ex.: SYSDBA), password, database (caminho completo do arquivo .fdb). |
| **Data/config.json** | Objeto database com host, port, username, password, database (path do .fdb). |

### 4.3 Parâmetros da ferramenta (resumo)

| Parâmetro | Significado | Exemplo |
|-----------|-------------|---------|
| **-user** | Usuário | `-user SYSDBA` |
| **-pas** / **-password** | Senha | `-pas masterkey` |
| **conexão** | host:path ou path local do .fdb | `localhost:Data\arquivo.fdb` ou `127.0.0.1/3050:Data\arquivo.fdb` |

Sintaxe de conexão: `host:path_absoluto` ou `host/porta:path`. Para local: `path_absoluto` ou `localhost:path`.

### 4.4 Como usar (CLI)

Conexão local (arquivo .fdb):

```bat
isql -user SYSDBA -pas masterkey "Data\meubanco.fdb"
```

Conexão remota (host + porta + path no servidor):

```bat
isql -user SYSDBA -pas masterkey 127.0.0.1/3050:Data\meubanco.fdb
```

Executar script:

```bat
isql -user SYSDBA -pas masterkey "Data\meubanco.fdb" -i Data\script.sql
```

Incluir a pasta do Firebird no PATH para usar apenas `isql`:

```bat
set PATH=%PATH%;<firebird_install>
isql -user SYSDBA -pas masterkey localhost:Data\arquivo.fdb
```

---

## 5. PostgreSQL

### 5.1 Ferramenta CLI (path)

| Ferramenta | Uso | Path típico (Windows) |
|------------|-----|------------------------|
| **psql.exe** | Cliente de linha de comando PostgreSQL | `psql` (PATH) ou `<postgres_install>\bin\psql.exe`. |

**PATH:** Incluir `<postgres_install>\bin` para usar `psql` no terminal.

### 5.2 Arquivos de configuração (parâmetros de conexão)

| Arquivo | Descrição |
|---------|-----------|
| **Data/config.ini** | Seção `[database]` com database_type=PostgreSQL. Chaves: host, port (5432), username, password, database, schema (ex.: public). |
| **Data/config.json** | Objeto database com host, port, username, password, database, schema. |

### 5.3 Parâmetros da ferramenta (resumo)

| Parâmetro | Significado | Exemplo |
|-----------|-------------|---------|
| **-h** | Host | `-h 127.0.0.1` |
| **-p** | Porta (p minúsculo) | `-p 5432` |
| **-U** | Usuário (U maiúsculo) | `-U postgres` |
| **-d** | Nome do banco | `-d meubanco` |
| **-W** | Solicitar senha (prompt) | `-W` |
| **-f arquivo** | Executar script | `-f Data\script.sql` |

Variável de ambiente **PGPASSWORD** (evitar prompt): `set PGPASSWORD=MinhaSenha` (uso inseguro em ambiente compartilhado).

### 5.4 Como usar (CLI)

Interativo:

```bat
psql -h 127.0.0.1 -p 5432 -U postgres -d meubanco -W
```

Executar script:

```bat
psql -h 127.0.0.1 -p 5432 -U postgres -d meubanco -f Data\script.sql
```

Com path completo:

```bat
psql -h 192.168.1.100 -p 5432 -U postgres -d Habil -W
```

---

## 6. SQL Server

### 6.1 Ferramenta CLI (path)

| Ferramenta | Uso | Path típico (Windows) |
|------------|-----|------------------------|
| **sqlcmd.exe** | Cliente de linha de comando SQL Server (MSSqlcmd) | **Path:** `sqlcmd` (PATH) ou `<sqlcmd_install>\sqlcmd.exe`. |
| **bcp.exe** | Bulk copy (opcional) | Mesma árvore de instalação. |

**PATH:** Pode ser necessário adicionar o diretório Tools\Binn da instalação do SQL Server ou do "Microsoft Command Line Utilities".

### 6.2 Arquivos de configuração (parâmetros de conexão)

| Arquivo | Descrição |
|---------|-----------|
| **Data/config.ini** | Seção `[database]` com database_type=SQL Server. Chaves: host (ou server), port (1433), username, password, database, schema (ex.: dbo). |
| **Data/config.json** | Objeto database com host, port, username, password, database, schema. |

### 6.3 Parâmetros da ferramenta (resumo)

| Parâmetro | Significado | Exemplo |
|-----------|-------------|---------|
| **-S** | Servidor (host ou host,porta) | `-S 192.168.1.100` ou `-S 192.168.1.100,1433` |
| **-U** | Usuário (autenticação SQL) | `-U sa` |
| **-P** | Senha | `-P MinhaSenha` |
| **-d** | Nome do banco | `-d Habil` |
| **-i** | Arquivo de entrada (script) | `-i Data\script.sql` |
| **-Q** | Query (executar e sair) | `-Q "SELECT 1"` |

Autenticação Windows: use **-E** em vez de -U -P.

### 6.4 Como usar (CLI)

Conexão com usuário/senha (conforme config.ini do projeto):

```bat
sqlcmd -S 192.168.1.100,1433 -U sa -P changeme -d Habil
```

Executar script:

```bat
sqlcmd -S 192.168.1.100,1433 -U sa -P changeme -d Habil -i Data\script.sql
```

Com path completo (ajustar versão/caminho):

```bat
sqlcmd -S 192.168.1.100 -U sa -P changeme -d Habil
```

---

## 7. Como usar cada cliente CLI — resumo

Descritivo de uso: ferramenta, arquivo(s) de configuração e parâmetros necessários para conectar por CLI.

### 7.1 MySQL (mysql)

| Item | Descrição |
|------|------------|
| **Ferramenta** | `mysql.exe`. Path: `mysql` (PATH) ou `<mysql_install>\bin\mysql.exe`. |
| **Arquivo de config** | **Data/config.ini** (seção database) ou **Data/config.json** (objeto database). Chaves: host, port (3306), username, password, database, schema. |
| **Parâmetros CLI** | **-h** host, **-P** porta, **-u** usuário, **-p** senha, nome do banco no final. |
| **Comando exemplo** | `mysql -h 192.168.1.100 -P 3306 -u root -p nome_do_banco` |

### 7.2 SQLite (sqlite3)

| Item | Descrição |
|------|------------|
| **Ferramenta** | `sqlite3.exe`. Path: `sqlite3` (PATH) ou `<sqlite_install>\sqlite3.exe`. |
| **Arquivo de config** | **Data/config.ini** (database = caminho do .db) ou **Data/config.json**. Sem host/port; apenas path do arquivo. |
| **Parâmetros CLI** | Caminho do .db como argumento posicional. Dentro do shell: `.read script.sql`. |
| **Comando exemplo** | `sqlite3 Data\Config.db` ou `sqlite3 Data\test.db < Data\script.sql` |

### 7.3 Firebird (isql)

| Item | Descrição |
|------|------------|
| **Ferramenta** | `isql.exe`. Path: `isql` (PATH) ou `<firebird_install>\isql.exe`. |
| **Arquivo de config** | **Data/config.ini** ou **Data/config.json**. Chaves: host, port (3050), username, password, database (path .fdb). |
| **Parâmetros CLI** | **-user**, **-pas**; conexão = host:path ou path local. |
| **Comando exemplo** | `isql -user SYSDBA -pas masterkey localhost:Data\arquivo.fdb` |

### 7.4 PostgreSQL (psql)

| Item | Descrição |
|------|------------|
| **Ferramenta** | `psql.exe`. Path: `psql` (PATH) ou `<postgres_install>\bin\psql.exe`. |
| **Arquivo de config** | **Data/config.ini** ou **Data/config.json**. Chaves: host, port (5432), username, password, database, schema. |
| **Parâmetros CLI** | **-h** host, **-p** porta, **-U** usuário, **-d** banco, **-W** (senha), **-f** script. |
| **Comando exemplo** | `psql -h 127.0.0.1 -p 5432 -U postgres -d meubanco -W` |

### 7.5 SQL Server (sqlcmd)

| Item | Descrição |
|------|------------|
| **Ferramenta** | `sqlcmd.exe` (MSSqlcmd). Path: `sqlcmd` (PATH) ou `<sqlcmd_install>\sqlcmd.exe`. |
| **Arquivo de config** | **Data/config.ini** ou **Data/config.json**. Chaves: host, port (1433), username, password, database, schema. |
| **Parâmetros CLI** | **-S** servidor,porta, **-U** usuário, **-P** senha, **-d** banco, **-i** script. |
| **Comando exemplo** | `sqlcmd -S 192.168.1.100,1433 -U sa -P changeme -d Habil` |

### 7.6 Tabela comparativa

| Banco | Cliente CLI | Path típico (ferramenta) | Porta padrão | Config (conexão) |
|-------|-------------|----------------------------|--------------|-------------------|
| **MySQL** | mysql | `<mysql_install>\bin\mysql.exe` ou PATH | 3306 | Data/config.ini, config.json |
| **SQLite** | sqlite3 | `<sqlite_install>\sqlite3.exe` ou PATH | — | database = path .db |
| **Firebird** | isql | `<firebird_install>\isql.exe` ou PATH | 3050 | Data/config.ini, config.json |
| **PostgreSQL** | psql | `<postgres_install>\bin\psql.exe` ou PATH | 5432 | Data/config.ini, config.json |
| **SQL Server** | sqlcmd (MSSqlcmd) | `<sqlcmd_install>\sqlcmd.exe` ou PATH | 1433 | Data/config.ini, config.json |

---

## 8. Tabela resumo — paths das ferramentas CLI

| Banco | Ferramenta | Path completo |
|-------|-------------|----------------|
| **MySQL** | mysql.exe | `mysql` (PATH) ou `<mysql_install>\bin\mysql.exe` |
| **SQLite** | sqlite3.exe | `sqlite3` (PATH) ou `<sqlite_install>\sqlite3.exe` |
| **Firebird** | isql.exe | `isql` (PATH) ou `<firebird_install>\isql.exe` |
| **PostgreSQL** | psql.exe | `psql` (PATH) ou `<postgres_install>\bin\psql.exe` |
| **SQL Server (MSSqlcmd)** | sqlcmd.exe | `sqlcmd` (PATH) ou `<sqlcmd_install>\sqlcmd.exe` |

---

## 9. Scripts SQL no projeto

| Pasta / arquivo | Descrição |
|-----------------|------------|
| **Data/script.sql** | Script SQL genérico. |
| **Data/config.sql** | Script de criação/configuração. |
| **Data/exception.sql**, **exception_en.sql**, **exception_es.sql** | Scripts de exceções por idioma. |
| **Data/pessoa.sql**, **Data/contrato.sql**, **Data/messages.sql** | Scripts de exemplo. |
| **Data/sql/** (se existir) | Scripts por banco: postgresql.sql, mysql.sql, sqlite.sql (tabelas orm_test_ddl, orm_test_dml, etc.). |

Executar via CLI conforme a seção do banco (ex.: `mysql ... < Data\script.sql`, `sqlite3 Data\Config.db < Data\script.sql`, `psql ... -f Data\script.sql`, `sqlcmd ... -i Data\script.sql`, `isql ... -i Data\script.sql`).

---

## 10. Referências no repositório

- **Locais e pacotes (incl. CLI):** `.cursor/rules/local_arquivos_V1.0.mdc` — secções de ferramentas e Data/, quando existir no pack.
- **Parâmetros de conexão e FromConfig:** documentação do projeto em `.cursor/rules/` (ex.: roadmap / inicial), se existir.
- **Estrutura Data/ e config:** ficheiros sob **`${workspaceFolder}/Data/`** (config.ini, config.json, Config.db).
---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.2 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)
- 1.0.2 (12/04/2026): Título e texto genéricos ao workspace; `${workspaceFolder}` para paths sob o repo; §10 com caminho canónico `local_arquivos` em Templates; remoção de referências fixas a rules inexistentes.
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).
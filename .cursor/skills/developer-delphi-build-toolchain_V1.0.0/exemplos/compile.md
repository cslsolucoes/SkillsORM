# Compilação no workspace (Delphi, FPC, Go e Python)

Documento de referência para compilar o **repositório aberto no workspace** (VS Code / Cursor) por linha de comando em **Delphi**, **Free Pascal (FPC)**, **Go** e **Python**. Inclui paths das ferramentas, arquivos de configuração e dependências — **sem** nome de produto ou clone fixo; adaptar `<nome>.dpr` / `<nome>.lpr` ao projeto local.

Este arquivo é o **guia canônico de compilação em prompt do sistema operacional** (Windows CMD/PowerShell e equivalentes), devendo ser usado como referência primária para comandos de build fora da IDE.

---

## 1. Diretivas e include obrigatório

- **ORM.Defines.inc** (raiz do projeto) define engines (USE_FIREDAC, USE_UNIDAC, USE_ZEOS, USE_SQLDB) e módulos (USE_LOGGERS, USE_PARAMENTERS, etc.). Um único engine por compilação.
- O compilador precisa encontrar esse arquivo: **-I"."** ou **-I"raiz"** (já previsto nos cfg/opts).
- Referência completa: **`.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md`** (skill: **developer-delphi-programming-conditional-defines**) e **`ORM.Defines.inc`** na raiz.

### 1.1 VS Code — `.vscode/tasks.json`

Política única: **tudo o que estiver dentro da pasta do workspace** deve usar **`${workspaceFolder}`** (nunca uma letra de unidade nem caminho absoluto do clone).

- **`command` / `args`:** `${workspaceFolder}/<ficheiro-relativo-à-raiz>` — por exemplo `${workspaceFolder}/MeuProjeto.dpr`, `${workspaceFolder}/fpc64.opts`, `${workspaceFolder}/SQLite/sqlite3.exe`.
- **`options.cwd`:** `${workspaceFolder}` quando o compilador precisar de resolver `*.cfg` / `*.opts` na raiz.
- **`label`:** no template canónico usar placeholders **`{PROJECT_NAME}`** / **`{PROJECT_DPR}`**; após o bootstrap, o nome reflete o projeto local — não fixar um nome de repositório na skill.
- **Fora do workspace** (toolchains instalados no SO): manter caminho absoluto ou placeholder substituído na geração — exemplo: executável **`fpc.exe`** com **`{FPC_ROOT}`** em **`.cursor/Templates/mirror-config/vscode-tasks.template.json`**.
- O template canónico e o fluxo de cópia (`bootstrap-autostart-mirrors` / `bootstrap_autostart_mirrors.py`) seguem esta política.

---

## 2. Delphi (Win32 e Win64)

### 2.1 Ferramentas de compilação (paths)

| Ferramenta   | Uso        | Path típico (ajustar versão do Studio) |
|-------------|------------|----------------------------------------|
| **dcc32.exe** | Compilador Win32 | `dcc32` (PATH) ou `<rad_studio>\bin\dcc32.exe` |
| **dcc64.exe** | Compilador Win64 | `dcc64` (PATH) ou `<rad_studio>\bin\dcc64.exe` |

Versões comuns: **22.0**, **23.0** (substituir no path). O **RAD Studio** adiciona esse diretório ao PATH quando se usa o "Command Line" do menu Iniciar.

**BPL (packages):**

- Win32: `<bpl>\Win32`
- Win64: `<bpl>\Win64`

**Headers (C++):** `<rad_studio>\hpp` (Win32) e `<rad_studio>\hpp\Win64` (Win64).

### 2.2 Arquivos de configuração

| Arquivo     | Descrição |
|------------|-----------|
| **dcc32.cfg** | Opções e paths para compilação Win32 (units, include, saída, aliases, definições). |
| **dcc64.cfg** | Idem para Win64. |

Local: **raiz do projeto** (`.`).

### 2.3 Conteúdo relevante dos cfg (resumo)

- **Units (-U):** `src`, `src\Commons`, `src\Connections`, `src\Database`, `src\Database\Messages`, `src\Services`; dependências externas devem ser referenciadas por paths do ambiente local (preferencialmente via PATH/variáveis). UniDAC comentado; FireDAC não precisa -U (RTL).
- **Include (-I):** `"."`, `"src"`; Zeos (paths acima).
- **Saída:** `-E` EXE, `-N`/`-NO` DCU, `-LN`/`-NB` DCP em `Compiled\EXE\Debug\Win32` (ou Win64), `Compiled\DCU\Debug\Win32`, etc.
- **Opções:** `-$O-`, `-$W+`, `-$C+`, `-$D+`, `-$L+`, `-$Y+`, `-Q`, `-TX.exe`, `-VN`.
- **Defines:** `DEBUG`, `FRAMEWORK_VCL`.

No **repositório atual**, use o ficheiro principal `*.dpr` (ou `*.lpr` para Lazarus/FPC). Se a estrutura de pastas for diferente (ex.: `src\Modulos\Database`, `src\Modulos\Connections`), ajustar as linhas **-U** no `dcc32.cfg`/`dcc64.cfg` para coincidir com o `*.dproj` ou com os paths do **fpc32.opts**/ **fpc64.opts**.

### 2.4 Comandos de compilação (CLI)

Executar na **raiz do projeto** (`.`):

```bat
dcc32 -B "<arquivo-principal>.dpr"
dcc64 -B "<arquivo-principal>.dpr"
```

O compilador Delphi carrega automaticamente `dcc32.cfg` ou `dcc64.cfg` quando estão no diretório atual. Para forçar um cfg específico:

```bat
dcc32 -B -@dcc32.cfg "<arquivo-principal>.dpr"
dcc64 -B -@dcc64.cfg "<arquivo-principal>.dpr"
```

- **-B** = build (recompila o necessário).

---

## 3. Free Pascal (FPC) — Win32 e Win64

### 3.1 Ferramentas de compilação (paths)

| Ferramenta   | Uso        | Path |
|-------------|------------|------|
| **fpc.exe (Win32)** | Compilador i386-win32 | `fpc` (via PATH) ou `<fpc>\bin\i386-win32\fpc.exe` |
| **fpc.exe (Win64)** | Compilador x86_64-win64 | `fpc` (via PATH) ou `<fpc>\bin\x86_64-win64\fpc.exe` |

**Base FPC:** diretório local da instalação (`<fpc>` e `<lazarus>`). FPC 3.3.1+ recomendado (Attributers e Generics).

**Units FCL (SQLdb):**

- Win32: `<fpc>\units\i386-win32\fcl-db`
- Win64: `<fpc>\units\x86_64-win64\fcl-db`

**Zeos (OPM):** `<lazarus_opm>\zeosdbo\src\` (component, core, dbc, parsesql, plain).

**DataSet.Serialize:** `<dataset_serialize>\src` (obrigatório quando Parameters.Database usa).

### 3.2 Arquivos de configuração

| Arquivo      | Descrição |
|-------------|-----------|
| **fpc32.opts** | Opções e paths para FPC Win32 (include, units, saída, modo Delphi, target). |
| **fpc64.opts** | Idem para FPC Win64. |

Local: **raiz do projeto** (`.`).

### 3.3 Conteúdo relevante dos opts (resumo)

- **Modo/target:** `-Mdelphi`, `-Twin32` / `-Twin64`, `-Pi386` / `-Px86_64`.
- **Include:** `-Fi.`, `-Fisrc`.
- **Units do projeto:** `-Fusrc`, `-Fusrc\Commons`, `-Fusrc\Attributers`, `-Fusrc\Connections`, `-Fusrc\Database` e subpastas (Fields, Tables, Schemas, EntityManager, IdentityMap, UnitOfWork, QueryBuilder, TypeDatabase), `-Fusrc\Modulos\Parameters` (e subpastas), `-Fusrc\Modulos\Loggers` (e subpastas).
- **DataSet.Serialize:** `-Fu<dataset_serialize>\src`.
- **SQLdb (USE_SQLDB):** `-Fu<fpc>\units\<target>\fcl-db`.
- **Zeos (USE_ZEOS):** `-Fu<lazarus_opm>\zeosdbo\src\component`, `core`, `dbc`, `parsesql`, `plain`.
- **LCL (GUI):** paths em `<lazarus>\...` (lcl, lazutils, packager, codetools, freetype, lazcontrols, buildintf, ideintf) para o target correspondente.
- **Saída:** `-FECompiled\EXE\Default\win32` ou `win64`, `-FUCompiled\DCU\Default\win32` ou `win64`.
- **Opções:** `-V0`, `-WB`, `-l`.

### 3.4 Comandos de compilação (CLI)

Executar na **raiz do projeto** (`.`). Se existir `*.lpr`, use-o; caso contrário use o `*.dpr` (FPC aceita com `-Mdelphi`):

```bat
fpc @fpc32.opts "<arquivo-principal>.dpr"
fpc @fpc64.opts "<arquivo-principal>.dpr"
```

Se o PATH já incluir o bin do FPC:

```bat
fpc @fpc32.opts "<arquivo-principal>.dpr"
fpc @fpc64.opts "<arquivo-principal>.dpr"
```

(Garanta que o `fpc` no PATH seja o do target desejado, ou use o path completo.)

---

## 4. Go (Golang)

### 4.1 Ferramentas de compilação (paths)

| Ferramenta | Uso | Path típico (Windows) |
|------------|-----|------------------------|
| **go.exe** | Compilador e CLI Go | `go` (PATH) ou `<go_root>\bin\go.exe` |

**GOROOT** (instalação do Go): `<go_root>`. O binário fica em `%GOROOT%\bin`.

**GOPATH** (opcional com módulos): ex. `<go_workspace>` ou `%USERPROFILE%\go`. Com **Go modules** (recomendado), o projeto não precisa estar em GOPATH.

**PATH:** Incluir `%GOROOT%\bin` para usar `go` no terminal.

### 4.2 Estrutura recomendada (quando houver código Go)

Na raiz do repositório ou em subpasta (ex.: `go/` ou `cmd/`):

```
<projeto>/
  go.mod              # módulo Go (criar com: go mod init <module>)
  go.sum              # checksums de dependências (gerado)
  go/                 # opcional: código Go em subpasta
    main.go
    cmd/
      app/
        main.go
  Compiled/
    EXE/
      Go/              # saída Go (ex.: go build -o Compiled/EXE/Go/...)
        windows_amd64/
        linux_amd64/
```

Para alinhar saída ao resto do projeto: `-o Compiled\EXE\Go\windows_amd64\app.exe` (ou pasta equivalente).

### 4.3 Arquivos de configuração

| Arquivo | Descrição |
|---------|-----------|
| **go.mod** | Módulo e dependências (criar com `go mod init <module>`). |
| **go.sum** | Soma de verificação dos módulos (gerado por `go mod tidy` / `go build`). |
| **.env** ou **Makefile** | Opcional: variáveis (CGO_ENABLED, GOOS, GOARCH) ou alvos de build. |

**Variáveis de ambiente úteis:**

- **GO111MODULE=on** — usar sempre Go modules (padrão a partir do Go 1.17).
- **GOROOT** — instalação do Go (geralmente já definido).
- **GOPATH** — workspace legado; com módulos, usado para cache (`%GOPATH%\pkg\mod`).
- **CGO_ENABLED=0** — build estático sem CGO (útil para cross-compile ou quando não há C).
- **GOOS**, **GOARCH** — cross-compile (ex.: `GOOS=linux GOARCH=amd64 go build`).

### 4.4 Comandos de compilação (CLI)

Executar na **raiz do módulo Go** (onde está o `go.mod`) ou na raiz do projeto:

```bat
go build -o Compiled\EXE\Go\app.exe .
```

Build para múltiplos alvos (exemplo, na raiz do módulo):

```bat
set CGO_ENABLED=0
go build -o Compiled\EXE\Go\windows_amd64\app.exe .
set GOOS=linux
set GOARCH=amd64
go build -o Compiled\EXE\Go\linux_amd64\app .
set GOOS=darwin
set GOARCH=amd64
go build -o Compiled\EXE\Go\darwin_amd64\app .
```

Outros comandos úteis:

```bat
go mod init <module>     # criar go.mod (ex.: go mod init github.com/org/projeto)
go mod tidy              # baixar deps e atualizar go.sum
go mod download          # baixar dependências
go test ./...            # rodar testes
go vet ./...             # análise estática
go fmt ./...             # formatação
```

### 4.5 Versão mínima e requisitos

- **Go 1.18+** recomendado (generics); 1.16+ para módulos estável.
- Se o **repositório** tiver apenas código Delphi/FPC por enquanto, a seção Go serve de **preparação**: ao adicionar código Go, criar `go.mod` na raiz ou em `go/` e usar os paths de saída acima.

---

## 5. Python

### 5.1 Ferramentas de compilação / interpretação (paths)

| Ferramenta | Uso | Path típico (Windows) |
|------------|-----|------------------------|
| **python.exe** | Interpretador Python | `python` (PATH) ou `<python>\python.exe` |
| **py.exe** | Launcher (múltiplas versões) | `py` (PATH) |
| **pip** | Gerenciador de pacotes | `python -m pip` (junto ao interpretador) |
| **venv** | Ambiente virtual | `python -m venv` (módulo da stdlib) |

**Instalações comuns:**

- **Python.org:** `<python_install_dir>`.
- **Anaconda/Miniconda:** `<conda_install_dir>`; usar `conda` para ambientes.
- **PATH:** Incluir o diretório que contém `python.exe` (e opcionalmente `Scripts\`) para usar `python` e `pip` no terminal.

### 5.1.1 Pasta `<python_root>` — múltiplas versões

Quando o Python é instalado em uma pasta base (ex.: `<python_root>`), cada versão fica em uma subpasta. Estrutura típica e uso:

**Base:** `<python_root>`

**Subpastas por versão (convenção):**

| Pasta em `<python_root>` | Interpretador | pip | Observação |
|--------------------|---------------|-----|------------|
| **Python313** | `<python_root>\Python313\python.exe` | `<python_root>\Python313\Scripts\pip.exe` ou `python -m pip` | Python 3.13 (64-bit, se for instalação padrão) |
| **Python38** | `<python_root>\Python38\python.exe` | `<python_root>\Python38\Scripts\pip.exe` | Python 3.8 |
| **Python37** | `<python_root>\Python37\python.exe` | `<python_root>\Python37\Scripts\pip.exe` | Python 3.7 (32-bit, se não houver sufixo) |
| **Python37_64** | `<python_root>\Python37_64\python.exe` | `<python_root>\Python37_64\Scripts\pip.exe` | Python 3.7 64-bit (sufixo _64) |

**Uso por versão (CLI):**

```bat
<python_root>\Python313\python.exe -m venv .venv313
<python_root>\Python38\python.exe script.py
<python_root>\Python37_64\Scripts\pip.exe install -r requirements.txt
```

**Launcher py.exe (selecionar versão):**

```bat
py -3.13 -m venv .venv
py -3.8 script.py
py -3.7-64 -c "import sys; print(sys.executable)"
```

**Variável PATH:** Para usar uma versão como `python` padrão, incluir no PATH apenas **uma** pasta, por exemplo: `<python_root>\Python313` e `<python_root>\Python313\Scripts`. Não colocar várias versões no PATH ao mesmo tempo para evitar ambiguidade; preferir path completo ou `py -X.Y`.

**Resumo da análise da pasta `<python_root>` (referência de exemplo):**

- **Python313** — versão mais recente listada.
- **Python38** — 3.8.
- **Python37** — 3.7 (provavelmente 32-bit).
- **Python37_64** — 3.7 64-bit.

Ao adicionar novas instalações (ex.: Python312, Python311), seguir o mesmo padrão: `<python_root>\Python3XX` ou `<python_root>\Python3XX_64` para 64-bit quando coexistir com 32-bit.

### 5.2 Estrutura recomendada (quando houver código Python)

Na raiz do repositório ou em subpasta (ex.: `python/` ou `py/`):

```
<projeto>/
  python/                 # opcional: código Python em subpasta
    pyproject.toml         # projeto e dependências (PEP 518)
    requirements.txt       # dependências para pip (alternativo)
    requirements-dev.txt   # dependências de desenvolvimento (opcional)
    .venv/                 # ambiente virtual (não versionar)
    src/
      app/
        __init__.py
        ...
    tests/
      ...
  Compiled/
    EXE/
      Python/              # saída/artefatos Python (scripts, wheels, etc.)
        dist/              # ex.: python -m build → dist/*.whl
        scripts/           # scripts de entrada opcionais
```

Para alinhar ao resto do projeto: usar `Compiled\EXE\Python\` para builds, wheels ou scripts empacotados.

### 5.3 Arquivos de configuração

| Arquivo | Descrição |
|---------|------------|
| **pyproject.toml** | Metadados do projeto, dependências e ferramentas (build, pytest, black, etc.) — PEP 517/518. |
| **requirements.txt** | Lista de dependências para `pip install -r requirements.txt`. |
| **requirements-dev.txt** | Dependências de desenvolvimento (testes, lint, formatação). |
| **.env** | Variáveis de ambiente (opcional; usar `python-dotenv` se necessário). |
| **setup.py** / **setup.cfg** | Legado; preferir **pyproject.toml** para projetos novos. |

**Variáveis de ambiente úteis:**

- **VIRTUAL_ENV** — path do ambiente virtual ativo (definido ao ativar o venv).
- **PYTHONPATH** — diretórios adicionais para import (ex.: raiz do pacote ou `src/`).
- **PIP_INDEX_URL** — repositório de pacotes (ex.: PyPI privado).

### 5.4 Comandos (CLI)

Executar na **raiz do projeto** ou na pasta do módulo Python (onde está `pyproject.toml` ou `requirements.txt`).

**Ambiente virtual (recomendado):**

```bat
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

**Instalação em modo editável (desenvolvimento):**

```bat
pip install -e .
```

**Executar módulo ou script:**

```bat
python -m <modulo>
python script.py
```

**Testes e qualidade:**

```bat
python -m pytest tests\
python -m pytest --cov=src
python -m pylint src
python -m black src
python -m ruff check src
```

**Empacotamento (wheel/sdist):**

```bat
pip install build
python -m build
```

Saída em `dist/`; pode ser copiada para `Compiled\EXE\Python\dist\` se desejar centralizar artefatos.

### 5.5 Versão mínima e requisitos

- **Python 3.10+** recomendado; 3.8+ como mínimo para a maioria dos projetos atuais.
- Se o **repositório** tiver apenas código Delphi/FPC/Go por enquanto, a seção Python serve de **preparação**: ao adicionar código Python, criar `pyproject.toml` (ou `requirements.txt`) na raiz ou em `python/` e usar os paths de saída acima.

---

## 6. Como usar cada compilador — parâmetros e arquivos de configuração

Descritivo de uso: ferramenta, arquivo(s) de configuração e parâmetros necessários para compilar/executar com cada ambiente.

### 6.1 Delphi (dcc32 / dcc64)

| Item | Descrição |
|------|------------|
| **Ferramenta** | `dcc32.exe` (Win32) ou `dcc64.exe` (Win64). Path via PATH ou `<rad_studio>\bin\`. |
| **Arquivo de configuração** | **dcc32.cfg** (Win32) ou **dcc64.cfg** (Win64), na raiz do projeto. O compilador carrega automaticamente o `.cfg` correspondente ao executável quando o arquivo está no diretório atual. |
| **Como o cfg é usado** | Linhas do cfg equivalem a opções na linha de comando. Não é necessário passar o cfg explicitamente, a menos que queira outro arquivo: use `-@arquivo.cfg`. |
| **Parâmetros principais (no cfg)** | **-U** = diretórios de units; **-I** = diretórios de include; **-E** = pasta do EXE; **-N** / **-NO** = pasta dos DCU; **-LN** / **-NB** = pasta dos DCP; **-D** = definições (ex.: DEBUG, FRAMEWORK_VCL). |
| **Parâmetros na linha de comando** | **-B** = build (recompilar o necessário); **-@dcc32.cfg** = carregar cfg específico; no final = nome do .dpr. |
| **Comando completo (exemplo)** | `dcc32 -B "<arquivo-principal>.dpr"` (usa dcc32.cfg do diretório atual). Ou: `dcc32 -B -@dcc32.cfg "<arquivo-principal>.dpr"`. |
| **Pré-requisito** | Estar na raiz do projeto (`.`). Incluir no PATH o bin do Studio ou usar path completo do dcc32/dcc64. |

### 6.2 Free Pascal (fpc)

| Item | Descrição |
|------|------------|
| **Ferramenta** | `fpc.exe` via PATH (ou path local da instalação). |
| **Arquivo de configuração** | **fpc32.opts** (Win32) ou **fpc64.opts** (Win64), na raiz do projeto. O FPC **não** carrega opts sozinho: é obrigatório passar com **@fpc32.opts** ou **@fpc64.opts**. |
| **Como o opts é usado** | Cada linha do arquivo .opts é uma opção (ou comentário com #). O compilador lê o arquivo como se as linhas fossem argumentos. |
| **Parâmetros principais (no opts)** | **-Mdelphi** = modo Delphi; **-Twin32** / **-Twin64** = target; **-Pi386** / **-Px86_64** = processador; **-Fi** = include; **-Fu** = units; **-FE** = pasta do executável; **-FU** = pasta das units compiladas; **-V0**, **-WB**, **-l** = verbosidade e warnings. |
| **Parâmetros na linha de comando** | **@fpc32.opts** ou **@fpc64.opts** (obrigatório); em seguida o arquivo principal (.dpr ou .lpr). |
| **Comando completo (exemplo)** | `fpc @fpc32.opts "<arquivo-principal>.dpr"` (Win32). `fpc @fpc64.opts "<arquivo-principal>.dpr"` (Win64). |
| **Pré-requisito** | Estar na raiz do projeto. O opts deve apontar `-Fu` para dependências do ambiente local (Zeos/SQLdb/LCL). |

### 6.3 Go (go)

| Item | Descrição |
|------|------------|
| **Ferramenta** | `go.exe`. Path via PATH ou `<go_root>\bin\go.exe`. |
| **Arquivo de configuração** | **go.mod** (e **go.sum**, gerado). Não há arquivo de opções de compilação separado como no Delphi/FPC; o módulo e as flags são passados na linha de comando ou via variáveis de ambiente. |
| **Como o go.mod é usado** | Define o nome do módulo e as dependências. O comando `go build` usa o go.mod do diretório atual (ou do diretório do pacote indicado). |
| **Parâmetros principais** | **go build** = compilar; **-o** = caminho do executável de saída; **.** = pacote no diretório atual. Para cross-compile: **GOOS**, **GOARCH** (ex.: `set GOOS=linux`, `set GOARCH=amd64`); **CGO_ENABLED=0** = desabilitar CGO (build estático). |
| **Comando completo (exemplo)** | `go build -o Compiled\EXE\Go\app.exe .` (na pasta onde está o go.mod). Cross-compile: `set CGO_ENABLED=0` e depois `set GOOS=linux` e `set GOARCH=amd64`, então `go build -o Compiled\EXE\Go\linux_amd64\app .`. |
| **Pré-requisito** | Ter **go.mod** (criar com `go mod init <módulo>`). Executar na raiz do módulo. PATH deve incluir o bin do Go. |

### 6.4 Python (python / pip)

| Item | Descrição |
|------|------------|
| **Ferramenta** | `python.exe` (interpretador) e `pip` (pacotes). Path via PATH ou `<python>\python.exe` e `<python>\Scripts\pip.exe`. |
| **Arquivo de configuração** | **pyproject.toml** (projeto e dependências) e/ou **requirements.txt** (lista de pacotes para pip). Não há “compilação” no sentido Delphi/FPC; o uso é instalar dependências e executar scripts ou módulos. |
| **Como os arquivos são usados** | **pyproject.toml**: ferramentas de build e metadados (PEP 517/518); **requirements.txt**: `pip install -r requirements.txt` instala as dependências listadas. |
| **Parâmetros principais** | **python -m venv .venv** = criar ambiente virtual; **pip install -r requirements.txt** = instalar deps; **python -m &lt;módulo&gt;** = executar módulo; **python script.py** = executar script; **pip install -e .** = instalar projeto em modo editável. |
| **Comando completo (exemplo)** | Criar venv e compilar/rodar: `python -m venv .venv`, depois `.venv\Scripts\activate`, `pip install -r requirements.txt`, `python -m <modulo>` ou `python script.py`. |
| **Pré-requisito** | Ter **requirements.txt** ou **pyproject.toml** na pasta do projeto Python. Recomendado usar ambiente virtual (.venv) e ativá-lo antes de instalar ou rodar. |

### 6.5 Resumo comparativo

| Compilador | Arquivo de config | Carregamento do config | Parâmetro típico de build |
|------------|-------------------|------------------------|----------------------------|
| **Delphi** | dcc32.cfg / dcc64.cfg | Automático (mesmo dir.) ou `-@arquivo.cfg` | `-B` + nome do .dpr |
| **FPC** | fpc32.opts / fpc64.opts | Obrigatório `@fpc32.opts` / `@fpc64.opts` | `@fpc32.opts` + nome do .dpr |
| **Go** | go.mod (go.sum) | Implícito (diretório atual) | `go build -o &lt;saída&gt; .` |
| **Python** | pyproject.toml / requirements.txt | Explícito: `pip install -r requirements.txt`; pyproject.toml usado por ferramentas | `python -m &lt;módulo&gt;` ou `python script.py` |

---

## 7. Tabela resumo — paths das ferramentas

| Ambiente | Ferramenta   | Path completo (exemplo) |
|----------|-------------|--------------------------|
| Delphi Win32 | dcc32.exe | `dcc32` (PATH) ou `<rad_studio>\bin\dcc32.exe` |
| Delphi Win64 | dcc64.exe | `dcc64` (PATH) ou `<rad_studio>\bin\dcc64.exe` |
| FPC Win32    | fpc.exe   | `fpc` (PATH) ou `<fpc>\bin\i386-win32\fpc.exe` |
| FPC Win64    | fpc.exe   | `fpc` (PATH) ou `<fpc>\bin\x86_64-win64\fpc.exe` |
| Go           | go.exe   | `go` (PATH) ou `<go_root>\bin\go.exe` |
| Python       | python.exe | `python` (PATH) ou `<python>\python.exe` |

---

## 8. Dependências externas (paths)

| Dependência | Path | Uso |
|-------------|------|-----|
| **Zeos** | `<zeos>\src\` | USE_ZEOS |
| **UniDAC** | `<unidac>\Source` | USE_UNIDAC (Delphi) |
| **DataSet.Serialize** | `<dataset_serialize>\src` | Parameters.Database (FPC opts) |
| **FireDAC** | RTL Delphi (sem path extra) | USE_FIREDAC (apenas Delphi) |
| **SQLdb** | `<fpc>\units\<target>\fcl-db` | USE_SQLDB (FPC) |

---

## 9. Diretórios de saída

| Config / Platform | EXE | DCU | DCP |
|-------------------|-----|-----|-----|
| Delphi Debug Win32 | `Compiled\EXE\Debug\Win32` | `Compiled\DCU\Debug\Win32` | `Compiled\DCP\Debug\Win32` |
| Delphi Debug Win64 | `Compiled\EXE\Debug\Win64` | `Compiled\DCU\Debug\Win64` | `Compiled\DCP\Debug\Win64` |
| FPC Default Win32  | `Compiled\EXE\Default\win32` | `Compiled\DCU\Default\win32` | — |
| FPC Default Win64  | `Compiled\EXE\Default\win64` | `Compiled\DCU\Default\win64` | — |
| Go (exemplo)       | `Compiled\EXE\Go\windows_amd64\` (ou `linux_amd64\`, `darwin_amd64\`) | — | — |
| Python (exemplo)   | `Compiled\EXE\Python\dist\` (wheels/sdist) ou `scripts\` | — | — |

---

## 10. Referências no repositório

- **Diretivas:** `.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md`, **ORM.Defines.inc** (raiz do workspace).
- **Locais e pacotes:** `.cursor/rules/local_arquivos_V1.0.mdc` (referências do ambiente local: Zeos, UniDAC, FPC/Lazarus, BPL etc.), quando existir no pack.
- **Processos e CRUD:** `.cursor/rules/roadmap.mdc`, se existir.
- **Entrada de compilação:** `*.dpr` / `*.dproj` (e opcionalmente `*.lpr`) na raiz — caminhos em tasks VS Code sempre como **`${workspaceFolder}/...`**.
- **Uso por Skills e Agents:** qualquer skill/agente que trate de build, CI/CD ou validação cross-compiler deve referenciar explicitamente este arquivo antes de propor comandos de compilação.

---

---

## 10b. GestorERP — backend MXX (M01 exemplo)

Arquivos de build do GestorERP ficam em `projects/` (raiz dos projetos). O código-fonte fica em `projects/backend/MXX-<Nome>/`. Executar os compiladores a partir da raiz do workspace (`e:\GestorERP`):

### Delphi

```bat
dcc32 projects\Seguranca.Backend.dpr
dcc64 projects\Seguranca.Backend.dpr
```

Os arquivos `dcc32.cfg` / `dcc64.cfg` em `projects\` são carregados automaticamente pelo compilador.

### FPC/Lazarus

```bat
D:\fpc\fpc\bin\i386-win32\fpc.exe @projects\fpc32.opts projects\Seguranca.Backend.lpr
D:\fpc\fpc\bin\x86_64-win64\fpc.exe @projects\fpc64.opts projects\Seguranca.Backend.lpr
```

**Convenção obrigatória:** nunca prefixar o nome com código de módulo — `Seguranca.Backend.dpr`, não `M01.Seguranca.Backend.dpr`.

Referência de scaffold e paths: skill `developer-delphi-modular-backend-scaffold_V1.0.0`.

---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.4 |
| **Política** | `.cursor/VERSION.md` |

## 11. Changelog (este arquivo)

- 1.0.4 (15/04/2026): Adicionada seção §10b com comandos de compilação específicos para GestorERP backend MXX (`dcc32 projects\Seguranca.Backend.dpr`); referência à skill `developer-delphi-modular-backend-scaffold_V1.0.0`.
- 1.0.3 (12/04/2026): Título e texto genéricos ao workspace; secção 1.1 com regra explícita **`${workspaceFolder}`** para todo o conteúdo sob o repo; remoção de formulações “Projeto” como nome fixo; referências §10 alinhadas ao pack (local_arquivos em Templates).
- 1.0.2 (30/03/2026): Bloco **Versão interna** (tabela FileVersion; política `.cursor/VERSION.md`); consolidação das duas alterações de 1.0.1 (30/03/2026) num único registo.
- 1.0.1 (30/03/2026): Rubrica de versionamento interno; reforço do papel canônico deste documento para compilação por CLI; referência explícita para Skills/Agents de build.

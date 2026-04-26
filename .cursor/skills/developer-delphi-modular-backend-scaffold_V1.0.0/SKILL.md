---
name: developer-delphi-modular-backend-scaffold
description: >
  Scaffold completo de módulo backend MXX Delphi/FPC: geração de arquivos de build
  (.dpr/.dproj/.lpr/.lpi/.lps/cfg/opts), estrutura de pastas (Core/Commons/Modulos),
  paths obrigatórios para ProvidersORM/ParamentersORM/ActiveDirectoryORM/REST-DataWare/ZeosDBO,
  e regra de encapsulamento Core/ como única fachada pública.
model: sonnet
thinking: normal
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Backend Pascal Module Scaffold (MXX)

## Responsabilidade única

Guiar a criação de um novo módulo backend Pascal (Delphi/FPC) seguindo a convenção `<ModulePattern>` (ex.: MXX-like `M01-<Domain>`): gerar os arquivos de build, criar a estrutura de pastas e aplicar as convenções de encapsulamento `Core/`. Este skill é o ponto de entrada para qualquer novo módulo backend Delphi/FPC em projetos que adoptem modularização por domínio.

**Exemplo concreto do GestorERP:** ver [`.workspace/skills/gestorerp-mxx-scaffold_V1.0.0/SKILL.md`](../../../.workspace/skills/gestorerp-mxx-scaffold_V1.0.0/SKILL.md).

**Escopo:** `projects/` (arquivos de build) e `projects/backend/MXX-<Nome>/` (código-fonte).

---

## Regra de encapsulamento — Core/ é a única fachada pública

```
Core/       ← ÚNICO ponto de saída pública do módulo
Commons/    ← interno — tipos de domínio, utilitários, serviços cross-cutting
Modulos/    ← interno — repositórios, controllers HTTP
```

- O `.dpr` / `.lpr` referencia **somente** units em `Core/`.
- `Core/MainService.pas` (TBootstrap) instancia todos os repositórios, serviços e registra os controllers — nenhum consumidor externo importa `Commons/` ou `Modulos/` diretamente.
- Outros módulos (M02, M03…) consomem este módulo **exclusivamente via HTTP REST** — nunca via units Pascal compartilhadas.

---

## Estrutura de pastas obrigatória

```
projects/backend/MXX-<Nome>/
├── config/
│   └── database.ini          ← template sem credenciais reais
├── Core/
│   ├── MainService.pas              ← TBootstrap: DI wiring, server init, RegisterAllControllers
│   ├── MainService.Interfaces.pas   ← apenas IBootstrap
│   ├── MainService.Connection.pas         ← TConnection via ProvidersORM
│   └── MainService.Connection.Interfaces.pas  ← apenas IConnection
├── Commons/
│   ├── Commons.<Concept>.Domain.Entities.pas  ← entidades do domínio (sem companion)
│   ├── Commons.<Concept>.Domain.Types.pas     ← tipos, records, enums (sem companion)
│   ├── Commons.<Concept>.Service.Xxx.pas      ← serviços cross-cutting
│   ├── Commons.<Concept>.Service.Xxx.Interfaces.pas
│   └── Commons.Message.Response.pas           ← TResponse<T>, TResponsePaged<T> (sem companion)
└── Modulos/
    ├── <Concept>/
    │   ├── <Concept>.Repository.Xxx.pas
    │   └── <Concept>.Repository.Xxx.Interfaces.pas
    └── Access/
        ├── Access.Controller.Xxx.pas
        ├── Access.Controller.Xxx.Interfaces.pas
        └── Access.Controller.ServerMain.pas    ← TRESTDWIdServicePooler + RegisterAllControllers
```

**Regra Commons. (obrigatória):** todo arquivo em `Commons/` usa `Commons.` como primeiro segmento:
```
Commons.Security.Domain.Entities.pas     ✓
Commons.Access.Auth.Jwt.pas              ✓
Security.Domain.Entities.pas             ✗  ← falta prefixo Commons.
```

**Regra Controllers:** sempre `Access.Controller.*` — nunca `Access.EntryPoint.*` nem `Access.Entry.*`.

---

## Camadas e fluxo de dependência

```
Access.Controller.Xxx          ← recebe request HTTP, delega ao serviço
  ↓ usa interface de
Commons.<Concept>.Service.Xxx  ← orquestra regra de negócio
  ↓ usa interface de
<Concept>.Repository.Xxx       ← persistência via ProvidersORM
  ↓ lê
Commons.<Concept>.Domain.*     ← entidades e tipos de domínio (sem deps externas)
```

Zero SQL em `Commons/` e `Core/` — toda persistência fica em `Modulos/<Concept>/`.

---

## Comando bootstrap

Execute a partir de `{WORKSPACE_ROOT}/{BACKEND_ROOT}/` (os arquivos de build são gerados nessa pasta raiz — valores de `.workspace/context.json`):

### Somente Delphi

```powershell
powershell -ExecutionPolicy Bypass -File "../.cursor/scripts/bootstrap-build-config.ps1" `
  -ProjectName "Seguranca.Backend" `
  -ConditionalDefines "USE_ZEOS;USE_PARAMENTERS;USE_LOGGERS;USE_POOLCONNECTIONS;USE_ATTRIBUTES;USE_ENTITY_MANAGER;USE_QUERY_BUILDER" `
  -StudioVersion "23.0" `
  -SkipLazarusFiles
```

### Somente FPC/Lazarus

```powershell
powershell -ExecutionPolicy Bypass -File "../.cursor/scripts/bootstrap-build-config.ps1" `
  -ProjectName "Seguranca.Backend" `
  -ConditionalDefines "USE_ZEOS;USE_PARAMENTERS;USE_LOGGERS;USE_POOLCONNECTIONS;USE_ATTRIBUTES;USE_ENTITY_MANAGER;USE_QUERY_BUILDER" `
  -FpcRoot "D:\fpc\fpc" `
  -LazarusRoot "D:\fpc\lazarus" `
  -FpcOpmRoot "D:\fpc\config_lazarus\onlinepackagemanager\packages" `
  -SkipProjectFiles
```

### Delphi + FPC/Lazarus (ambos)

```powershell
powershell -ExecutionPolicy Bypass -File "../.cursor/scripts/bootstrap-build-config.ps1" `
  -ProjectName "Seguranca.Backend" `
  -ConditionalDefines "USE_ZEOS;USE_PARAMENTERS;USE_LOGGERS;USE_POOLCONNECTIONS;USE_ATTRIBUTES;USE_ENTITY_MANAGER;USE_QUERY_BUILDER" `
  -StudioVersion "23.0" `
  -FpcRoot "D:\fpc\fpc" `
  -LazarusRoot "D:\fpc\lazarus" `
  -FpcOpmRoot "D:\fpc\config_lazarus\onlinepackagemanager\packages"
```

**Regra de nomenclatura:** `-ProjectName` nunca usa prefixo de módulo — `"Seguranca.Backend"`, não `"M01.Seguranca.Backend"`.

---

## Arquivos gerados pelo bootstrap

| Arquivo | Tipo | Descrição |
|---|---|---|
| `Seguranca.Backend.dpr` | Delphi | Program principal |
| `Seguranca.Backend.dproj` | Delphi | Projeto RAD Studio |
| `Seguranca.Backend.lpr` | FPC | Program principal Lazarus |
| `Seguranca.Backend.lpi` | FPC | Projeto Lazarus |
| `Seguranca.Backend.lps` | FPC | Sessão Lazarus |
| `dcc32.cfg` | Delphi | Compiler config Win32 |
| `dcc64.cfg` | Delphi | Compiler config Win64 |
| `fpc32.opts` | FPC | Compiler opts Win32 |
| `fpc64.opts` | FPC | Compiler opts Win64 |

Todos os arquivos de build ficam em `projects/` (raiz de projetos) — não há subpasta por módulo para arquivos de build.

---

## Paths obrigatórios — adicionar a cfg/opts

Após o bootstrap, acrescentar os caminhos `-U` (Delphi) ou `-Fu` (FPC) nos arquivos `dcc32.cfg`, `dcc64.cfg`, `fpc32.opts`, `fpc64.opts`:

### Backend source (módulo corrente)

Padrão genérico (substituir `<Domain>` pelo nome do módulo):

```
-U{BACKEND_ROOT}\<ModulePattern>-<Domain>\Core
-U{BACKEND_ROOT}\<ModulePattern>-<Domain>\Commons
-U{BACKEND_ROOT}\<ModulePattern>-<Domain>\Modulos\<SubDomain1>
-U{BACKEND_ROOT}\<ModulePattern>-<Domain>\Modulos\<SubDomain2>
-U{BACKEND_ROOT}\<ModulePattern>-<Domain>\config
```

Exemplo concreto do GestorERP (M01 Segurança): ver [`gestorerp-mxx-scaffold`](../../../.workspace/skills/gestorerp-mxx-scaffold_V1.0.0/SKILL.md).

### ProvidersORM

```
-Uprojects\modules\ProvidersORM\src\Modulos\Connections
-Uprojects\modules\ProvidersORM\src\Modulos\Database
-Uprojects\modules\ProvidersORM\src\Modulos\Exceptions
-Uprojects\modules\ProvidersORM\src\Modulos\Loggers
-Uprojects\modules\ProvidersORM\src\Modulos\Parameters
-Uprojects\modules\ProvidersORM\src\Modulos\PoolConnections
-Uprojects\modules\ProvidersORM\src\Main
```

*(Ver `projects/modules/ProvidersORM/dcc32.cfg` para a lista exata de subpastas)*

### ParamentersORM

```
-Uprojects\modules\ParamentersORM\src
```

### ActiveDirectoryORM

```
-Uprojects\modules\ActiveDirectoryORM\src
```

### REST-DataWare

```
-Uprojects\package\REST-DataWare\CORE\Source
```

### ZeosDBO

```
-Uprojects\package\zeosdbo\src\component
-Uprojects\package\zeosdbo\src\core
-Uprojects\package\zeosdbo\src\dbc
-Uprojects\package\zeosdbo\src\parsesql
-Uprojects\package\zeosdbo\src\plain
```

---

## database.ini — template

Criar `projects/backend/MXX-<Nome>/config/database.ini` com este template:

```ini
[database]
driver=SQLSERVER
server=localhost
port=1433
database=GestorERP_Dev
username=sa
password=

[auth]
auth_mode=local

[jwt]
secret=change-me-in-production
access_ttl_minutes=15
refresh_ttl_days=7

[server]
port=9000
max_connections=10
```

**Nunca comitar credenciais reais.** Adicionar `config/database.ini` ao `.gitignore`.

---

## Defines condicionais — referência M01

| Define | Módulo ativado |
|---|---|
| `USE_ZEOS` | ZeosDBO engine no ProvidersORM |
| `USE_PARAMENTERS` | ParamentersORM (lê database.ini) |
| `USE_LOGGERS` | Loggers module do ProvidersORM |
| `USE_POOLCONNECTIONS` | Pool de conexões do ProvidersORM |
| `USE_ATTRIBUTES` | Mapeamento ORM via atributos `[Table]`/`[Column]` |
| `USE_ENTITY_MANAGER` | Entity Manager do ProvidersORM |
| `USE_QUERY_BUILDER` | Query Builder do ProvidersORM |

---

## Compilação CLI

```powershell
# Delphi Win32
dcc32 projects\Seguranca.Backend.dpr

# Delphi Win64
dcc64 projects\Seguranca.Backend.dpr

# FPC Win32
D:\fpc\fpc\bin\i386-win32\fpc.exe @projects\fpc32.opts projects\Seguranca.Backend.lpr

# FPC Win64
D:\fpc\fpc\bin\x86_64-win64\fpc.exe @projects\fpc64.opts projects\Seguranca.Backend.lpr
```

---

## Checklist de validação pós-scaffold

- [ ] Arquivos de build em `projects/` (raiz) — sem prefixo M01 no nome
- [ ] Pastas `Core/`, `Commons/`, `Modulos/<Concept>/`, `Modulos/Access/` criadas
- [ ] `config/database.ini` template criado (sem credenciais)
- [ ] `dcc32.cfg` / `dcc64.cfg` / `fpc*.opts` contêm todos os `-U` paths
- [ ] `.dpr` / `.lpr` referenciam somente units de `Core/`
- [ ] Nenhum arquivo em `Commons/` sem prefixo `Commons.`
- [ ] Controllers nomeados `Access.Controller.*` (não `EntryPoint`)
- [ ] `config/database.ini` adicionado ao `.gitignore`

---

## When to use

- Ao iniciar um novo módulo backend MXX (M01, M02, …)
- Ao verificar se um módulo existente segue a estrutura canônica
- Como referência para adicionar paths a cfg/opts de módulos existentes

## When NOT to use

- Módulos Vue.js / frontend
- Scripts utilitários sem estrutura de módulo
- Código de infra fora de `projects/backend/`

## Dependências

- `developer-delphi-programming-oop-fluent_V1.0.0` — fluência total em todas as classes geradas
- `developer-delphi-programming-oop-naming_V1.0.0` — nomenclatura das interfaces/classes
- `backend-pascal-unit-naming_V1.2.0` — naming canônico de units (rule)

## Skills relacionadas

- `developer-delphi-programming-oop-fluent_V1.0.0` — padrão OOP + fluência
- `developer-delphi-programming-oop-naming_V1.0.0` — naming de classes/interfaces
- `developer-delphi-agent-orm-architect` — arquitetura e geração ORM

---

## Versão interna (arquivo)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.0.0 (17/04/2026): Onda 3 do refactor — skill renomeada de `backend-pascal-module-scaffold_V*` para `developer-delphi-modular-backend-scaffold_V1.0.0`. Conteúdo generificado (remoção de referências literais a 'Projeto v2.0 deste clone', paths absolutos, MXX concreto). Versão anterior arquivada em `.cursor/Backup/renamed-skills-20260417/skills/`.

- 1.0.0 (15/04/2026): Criação — scaffold de módulo MXX backend: bootstrap command, paths obrigatórios (ProvidersORM/ParamentersORM/ActiveDirectoryORM/REST-DataWare/ZeosDBO), estrutura Core/Commons/Modulos, encapsulamento Core/, database.ini template, checklist pós-scaffold.

---
name: developer-delphi-servers-libraries-orchestrator
description: Orquestradora da Família M — Serviços e Bibliotecas Delphi. Mapeia Horse, REST-DataWare, JWT, OpenSSL e afins.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-servers-libraries-orchestrator_V1.1.0

**Família:** M — Serviços e Bibliotecas  
**Versão:** 1.1.0  
**Data:** 2026-04-11  
**Tipo:** Orquestrador (ponto de entrada único)

---

## 1. Função desta skill

Esta skill é o **ponto de entrada único** para qualquer tarefa relacionada com:

- **Serviços Windows** — processos geridos pelo SCM (Service Control Manager), instalados via `sc.exe`, que arrancam com o sistema e correm sem sessão de utilizador
- **Servidores e Daemons Linux** — processos de fundo com `fork`/`setsid`, unidades `systemd`, aplicações console compiladas com `dcclinux64` ou FPC para Linux64
- **Bibliotecas Partilhadas** — `.dll` (Windows) e `.so` (Linux), BPL (Delphi package), sistemas de plugin baseados em interfaces, carregamento dinâmico com `LoadLibrary`/`dlopen`

O orquestrador **não resolve problemas directamente** — analisa o contexto e **roteia para a skill especializada** adequada, fornecendo o caminho exacto para o documento ou template mais relevante.

---

## 2. Tabela de roteamento principal

| Contexto / Pergunta | Skill invocada | Recurso directo |
|---------------------|---------------|-----------------|
| REST API / servidor HTTP com Horse (THorse, rotas, middleware) | `developer-delphi-horse-orchestrator_V1.0.0` | `SKILL.md` matriz de roteamento |
| Middleware Delphi (CORS, JWT, log, compressão, ETag…) | `developer-delphi-horse-orchestrator_V1.0.0` | `SKILL.md` diagrama de decisão |
| Criar Windows Service (TService, SCM, OnStart/OnStop) | `developer-delphi-windows-services_V1.0.0` | `SKILL.md` secção "Criar TService" |
| Instalar/desinstalar serviço Windows (`sc.exe`) | `developer-delphi-windows-services_V1.0.0` | `consultas_rapidas/sc_commands_reference.md` |
| Session 0 isolation, sem UI em serviço | `developer-delphi-windows-services_V1.0.0` | `consultas_rapidas/session0_isolation.md` |
| IPC entre serviço e app desktop (named pipes) | `developer-delphi-windows-services_V1.0.0` | `consultas_rapidas/service_ipc_patterns.md` |
| Tipos de conta de serviço (LocalSystem, NetworkService, conta custom) | `developer-delphi-windows-services_V1.0.0` | `consultas_rapidas/service_account_types.md` |
| Eventos do TService (OnStart, OnStop, OnPause, OnContinue) | `developer-delphi-windows-services_V1.0.0` | `consultas_rapidas/tservice_events_reference.md` |
| Deploy de app Delphi em Linux | `developer-delphi-to-fpc-linux-servers_V1.0.0` | `SKILL.md` secção "Deploy Linux" |
| `dcclinux64`, compilar para Linux no Windows | `developer-delphi-to-fpc-linux-servers_V1.0.0` | `exemplos/dcclinux64_build_guide.md` |
| PAServer setup e configuração | `developer-delphi-to-fpc-linux-servers_V1.0.0` | `exemplos/paserver_linux_setup.md` |
| Daemon Linux (`fork`, `setsid`, `systemd`) | `developer-delphi-to-fpc-linux-servers_V1.0.0` | `templates/TEMPLATE_linux_console_daemon.pas` |
| Diferenças FPC vs Delphi no Linux (Posix vs BaseUnix) | `developer-delphi-to-fpc-linux-servers_V1.0.0` | `consultas_rapidas/posix_vs_fpc_linux.md` |
| Opções do compilador `dcclinux64` | `developer-delphi-to-fpc-linux-servers_V1.0.0` | `consultas_rapidas/dcclinux64_options.md` |
| Criar DLL / `.so` (projecto library) | `developer-delphi-to-fpc-shared-libraries_V1.0.0` | `exemplos/library_basic_exports.pas` |
| Problema de memory manager entre DLLs | `developer-delphi-to-fpc-shared-libraries_V1.0.0` | `exemplos/dll_memory_manager_guide.md` |
| Plugin system com interfaces (`IPlugin`) | `developer-delphi-to-fpc-shared-libraries_V1.0.0` | `exemplos/interface_plugin_host.pas` |
| `LoadLibrary` / `dlopen` (carregamento dinâmico) | `developer-delphi-to-fpc-shared-libraries_V1.0.0` | `exemplos/loadlibrary_consumer_win.pas` + `exemplos/dlopen_consumer_linux.pas` |
| Calling conventions (`stdcall` vs `cdecl`) | `developer-delphi-to-fpc-shared-libraries_V1.0.0` | `consultas_rapidas/calling_conventions_win_linux.md` |
| BPL vs DLL — quando usar cada um | `developer-delphi-to-fpc-shared-libraries_V1.0.0` | `consultas_rapidas/bpl_vs_dll_comparison.md` |
| `.dproj` multi-plataforma para library | `developer-delphi-to-fpc-shared-libraries_V1.0.0` | `consultas_rapidas/dproj_library_multiplatform.md` |
| Armadilhas de memory manager em DLLs | `developer-delphi-to-fpc-shared-libraries_V1.0.0` | `consultas_rapidas/memory_manager_pitfalls.md` |
| Empacotar e distribuir DLL (Inno Setup, MSIX) | `developer-delphi-packaging-delivery_V1.0.0` | `SKILL.md` secção "DLL deployment" |
| Build cross-platform (Win+Linux no mesmo pipeline) | `developer-delphi-to-fpc-build_V1.0.0` | `SKILL.md` |

---

## 3. Diagrama de decisão — qual skill usar?

```
Preciso de componente de servidor/biblioteca?
│
├─► Windows? ──────────────────────────────────────────────────────────────────┐
│   │                                                                           │
│   ├─► Processo que corre como serviço SCM (start/stop via services.msc)?     │
│   │   └─► developer-delphi-windows-services_V1.0.0                           │
│   │       ├── TService + OnStart/OnStop                                       │
│   │       ├── Worker thread (TEMPLATE_service_worker_thread.pas)              │
│   │       ├── Session 0 isolation                                             │
│   │       └── IPC via named pipes                                             │
│   │                                                                           │
│   ├─► Biblioteca partilhada (.dll) carregada por outro processo?             │
│   │   └─► developer-delphi-to-fpc-shared-libraries_V1.0.0                           │
│   │       ├── Exports explícitos (stdcall)                                    │
│   │       ├── ShareMem / interfaces / POD                                     │
│   │       └── Plugin system (IPlugin + LoadLibrary)                           │
│   │                                                                           │
│   ├─► App que precisa de correr em background mas não como serviço?          │
│   │   └─► Consultar consultas_rapidas/family_m_decision_guide.md             │
│   │       (Task Scheduler vs NSSM wrapper vs console minimizado)             │
│   │                                                                           │
│   └─► Empacotar/distribuir executável + DLLs?                                │
│       └─► developer-delphi-packaging-delivery_V1.0.0                         │
│           (MSIX: developer-delphi-windows-msix_V1.0.0)                       │
│                                                                               │
└─► Linux? ─────────────────────────────────────────────────────────────────┐  │
    │                                                                        │  │
    ├─► Processo de fundo / daemon?                                         │  │
    │   └─► developer-delphi-to-fpc-linux-servers_V1.0.0                          │  │
    │       ├── fork + setsid (daemonização POSIX)                          │  │
    │       ├── systemd unit (TEMPLATE_daemon.service)                      │  │
    │       ├── Signal handling (SIGTERM, SIGHUP)                           │  │
    │       └── PAServer para deploy remoto                                 │  │
    │                                                                       │  │
    ├─► Biblioteca partilhada (.so)?                                        │  │
    │   └─► developer-delphi-to-fpc-shared-libraries_V1.0.0                       │  │
    │       ├── Exports com cdecl (Linux convención)                        │  │
    │       └─► dcclinux64 / FPC para Linux64                              │  │
    │           (developer-delphi-to-fpc-linux-servers_V1.0.0)                    │  │
    │                                                                       │  │
    ├─► Tarefa periódica no Linux?                                          │  │
    │   └─► Consultar consultas_rapidas/family_m_decision_guide.md         │  │
    │       (daemon loop vs cron vs systemd timer)                          │  │
    │                                                                       │  │
    └─► Deploy de executável para Linux?                                    │  │
        └─► developer-delphi-to-fpc-linux-servers_V1.0.0                          │  │
            (PAServer + dcclinux64 + runtime deps .so)                     │  │
```

---

## 4. Cenários comuns e stack de skills

### Cenário A — Windows Service que expõe API via named pipe

**Problema:** Criar um serviço Windows que corre em segundo plano e comunica com uma aplicação desktop através de named pipes.

**Stack de skills:**

1. `developer-delphi-windows-services_V1.0.0` — criar estrutura `TService` base
   - Template: `templates/TEMPLATE_tservice.pas`
   - Adicionar worker thread: `templates/TEMPLATE_service_worker_thread.pas`
2. `developer-delphi-windows-services_V1.0.0` → `consultas_rapidas/service_ipc_patterns.md`
   - Padrão de named pipe servidor (no serviço) + cliente (na app desktop)
   - Session 0 vs Session 1 considerations
3. `developer-delphi-windows-services_V1.0.0` → `consultas_rapidas/session0_isolation.md`
   - UI proibida em Session 0; usar WTSSendMessage apenas em emergência
4. `developer-delphi-packaging-delivery_V1.0.0` — Inno Setup com install/uninstall do serviço
   - `[Run]` entry com `sc.exe create` ou `RunOnce` para `InstallService`

**Resultado esperado:** Serviço instalável/desinstalável, arranca automaticamente, worker thread em loop, pipe server aceita ligações de apps desktop na mesma máquina.

---

### Cenário B — Daemon Linux com API REST

**Problema:** Deploy de servidor Delphi/FPC no Linux que serve requests HTTP como daemon systemd.

**Stack de skills:**

1. `developer-delphi-to-fpc-linux-servers_V1.0.0` — setup PAServer + compilação dcclinux64
   - Guia: `exemplos/paserver_linux_setup.md`
   - Guia de build: `exemplos/dcclinux64_build_guide.md`
2. `developer-delphi-to-fpc-linux-servers_V1.0.0` — estrutura daemon com daemonização POSIX
   - Template: `templates/TEMPLATE_linux_console_daemon.pas`
   - Signals: SIGTERM para shutdown graceful, SIGHUP para reload config
3. `developer-delphi-to-fpc-linux-servers_V1.0.0` → `templates/TEMPLATE_daemon.service`
   - Instalar como unidade systemd com `Restart=on-failure`
   - `EnvironmentFile` para configuração externa
4. `developer-delphi-to-fpc-linux-servers_V1.0.0` → `consultas_rapidas/linux_runtime_deps.md`
   - Lista de `.so` necessários para deploy; verificar com `ldd`

**Resultado esperado:** Binário Linux64, unidade systemd, arranca com o sistema, shutdown graceful ao receber SIGTERM, logs no journald.

---

### Cenário C — Plugin system (.dll/.so) multi-plataforma

**Problema:** Criar uma aplicação host que carrega plugins em runtime via `LoadLibrary`/`dlopen`, onde os plugins implementam uma interface comum.

**Stack de skills:**

1. `developer-delphi-to-fpc-shared-libraries_V1.0.0` — definir interface `IPlugin` partilhada
   - Template: `exemplos/interface_plugin_host.pas` (host que carrega plugins)
   - Implementação: `exemplos/interface_plugin_impl.pas` (DLL que exporta plugin)
2. `developer-delphi-to-fpc-shared-libraries_V1.0.0` — configurar projecto library multi-plataforma
   - Referência: `consultas_rapidas/dproj_library_multiplatform.md`
   - Calling convention: `consultas_rapidas/calling_conventions_win_linux.md`
3. `developer-delphi-to-fpc-shared-libraries_V1.0.0` — gerir memory manager
   - Guia: `exemplos/dll_memory_manager_guide.md`
   - Usar interfaces como boundary (sem ShareMem necessário)
4. `developer-delphi-to-fpc-linux-servers_V1.0.0` — compilar `.so` para Linux64
   - Usar `dcclinux64` com opção `-fPIC`
   - PAServer para deploy e teste

**Resultado esperado:** `.dll` (Windows) e `.so` (Linux) com factory function exportada; host carrega em runtime; memory manager gerido via interfaces; sem dependência de ShareMem.

---

### Cenário D — Windows Service + DLL de extensibilidade

**Problema:** Serviço Windows que carrega DLLs de extensão (plugins) em runtime, permitindo adicionar funcionalidades sem reinstalar o serviço.

**Stack de skills:**

1. `developer-delphi-windows-services_V1.0.0` — TService base com worker thread
   - Template: `templates/TEMPLATE_tservice.pas`
   - Adicionar `TPluginManager` no worker thread
2. `developer-delphi-to-fpc-shared-libraries_V1.0.0` — plugin system via interfaces
   - `IPlugin` interface definida em unit partilhada (sem `uses` cruzados)
   - Factory: `function CreatePlugin: IPlugin; stdcall;` exportada pela DLL
3. `developer-delphi-windows-services_V1.0.0` → `consultas_rapidas/service_ipc_patterns.md`
   - Notificar apps desktop sobre plugins carregados/descarregados
4. `developer-delphi-packaging-delivery_V1.0.0` — deploy conjunto
   - Inno Setup: serviço principal + directório `plugins\` com DLLs de extensão
   - DLLs de plugin podem ser actualizadas sem reinstalar o serviço

**Resultado esperado:** Serviço Windows extensível, carrega plugins de `plugins\*.dll` ao arrancar, worker thread chama métodos `IPlugin`, IPC para notificar UI sobre estado dos plugins.

---

## 5. Tabela de dependências entre Famílias

| Skill da Família M | Complementa (outra família) | Motivo |
|--------------------|-----------------------------|--------|
| `windows-services_V1.0.0` | SP-G1 `packaging-delivery_V1.0.0` | Inno Setup precisa registar/desregistar o serviço via `sc.exe` |
| `linux-servers_V1.0.0` | SP-G1 `build-cross-compiler_V1.0.0` | `dcclinux64` e MSBuild cross-platform para Linux64 |
| `shared-libraries_V1.0.0` | SP-G1 `packaging-delivery_V1.0.0` | BPL vs DLL decision; distribuir DLLs com Inno/MSIX |
| `shared-libraries_V1.0.0` | SP-I1 `architecture-modules_V1.0.0` | Módulos BPL no contexto de arquitectura de aplicação |
| Família M completa | SP-J `assembly-simd-avx_V1.0.0` | Optimização de DLLs de processamento com instruções SSE/AVX |
| Família M completa | SP-E `threading-basics_V1.1.0` | Serviços Windows e daemons Linux são inerentemente multi-threaded |
| Família M completa | SP-E `threading-advanced_V1.1.0` | Lock-free queues, thread pools em serviços de alta carga |

---

## 6. Referências cruzadas completas

### Skills da Família M (especializadas)

| Skill | Âmbito |
|-------|--------|
| `developer-delphi-windows-services_V1.0.0` | TService, SCM, Session 0, IPC, named pipes, worker threads |
| `developer-delphi-to-fpc-linux-servers_V1.0.0` | PAServer, dcclinux64, daemon POSIX, systemd, FPC Linux |
| `developer-delphi-to-fpc-shared-libraries_V1.0.0` | DLL/.so, exports, LoadLibrary/dlopen, plugin system, memory manager |

### Skills complementares (outras famílias)

| Skill | Âmbito | Quando usar |
|-------|--------|-------------|
| `developer-delphi-to-fpc-build_V1.0.0` | Build Win+Linux no mesmo pipeline | CI/CD multi-plataforma |
| `developer-delphi-packaging-delivery_V1.0.0` | Inno Setup, MSIX, deploy | Distribuição do serviço/DLL |
| `developer-delphi-windows-msix_V1.0.0` | MSIX / Windows Store | Distribuição via Store |
| `developer-delphi-to-fpc-threading-basics_V1.1.0` | Threads, TThread, synchronização | Worker threads em serviços |
| `developer-delphi-to-fpc-threading-advanced_V1.1.0` | Thread pools, lock-free, ICS | Serviços de alta carga |
| `developer-delphi-to-fpc-architecture-modules_V1.0.0` | BPL, plugin architecture | Decisão BPL vs DLL |
| `developer-delphi-assembly-simd-avx_V1.0.0` | SSE/AVX em DLLs | Optimização de bibliotecas numéricas |

### Documentos de consulta rápida desta skill (Família M Orquestrador)

| Documento | Conteúdo |
|-----------|---------|
| `consultas_rapidas/family_m_decision_guide.md` | Guia de decisão completo: service vs daemon vs DLL vs BPL |
| `templates/TEMPLATE_server_library_project_setup.md` | Checklist de setup para projecto novo |

# Guia de Decisão — Família M (Serviços e Bibliotecas)

**Skill:** `developer-delphi-servers-libraries-orchestrator_V1.1.0`  
**Actualizado:** 2026-04-11

---

## 1. Windows Service vs App Console vs Task Scheduler

### Quando escolher Windows Service

**Escolha Windows Service quando:**

- O processo deve **correr sem sessão de utilizador** (arranca com o sistema, mesmo sem ninguém logado)
- Precisa de integração com o **SCM** (start/stop/pause/continue via `services.msc` ou `sc.exe`)
- Precisa de **dependências de serviço** (Ex: iniciar após SQL Server)
- Requer uma **conta de serviço específica** (LocalSystem, NetworkService, conta de domínio)
- O processo deve ser **monitorizado e reiniciado automaticamente** em caso de falha (Recovery Actions do SCM)
- Tem requisitos de **auditoria** (eventos no Windows Event Log)

**Skill:** `developer-delphi-windows-services_V1.0.0`  
**Template:** `templates/TEMPLATE_tservice.pas`

---

### Quando escolher App Console em Background

**Escolha app console quando:**

- É um processo de **desenvolvimento/teste** que ainda não está pronto para ser serviço
- Precisa de **interacção ocasional** com o terminal (debugging, configuração inicial)
- O requisito é temporário ou para um ambiente controlado
- Usar **NSSM** (Non-Sucking Service Manager) como wrapper se necessitar de comportamento de serviço sem modificar o código

**Nota:** NSSM pode converter qualquer executável console num serviço Windows sem modificações. Útil para aplicações legadas ou de terceiros.

---

### Quando escolher Task Scheduler

**Escolha Task Scheduler quando:**

- A tarefa deve correr **periodicamente** (diário, semanal, em horários específicos)
- Não precisa de estar em execução contínua — apenas por um período limitado
- Precisa de correr **como resposta a um evento** (login, idle, evento do sistema)
- O overhead de um serviço permanente não se justifica para uma tarefa de curta duração
- Quer evitar a complexidade de `OnStart`/`OnStop`/`OnPause` para uma tarefa simples

**Comparação rápida:**

| Critério | Windows Service | Task Scheduler | Console + NSSM |
|----------|----------------|----------------|----------------|
| Arranca com o sistema | Sim (automático) | Sim (trigger) | Sim (via NSSM) |
| Corre continuamente | Sim | Não (por defeito) | Sim |
| Sem sessão de utilizador | Sim (Session 0) | Sim (opção) | Sim |
| Reinício automático em falha | Sim (Recovery Actions) | Sim (restart on failure) | Sim (via NSSM) |
| UI permitida | Não (Session 0) | Depende da conta | Depende |
| Complexidade de implementação | Média (TService) | Baixa | Baixa |
| Integração SCM | Sim | Não | Sim (via NSSM) |
| Logs de sistema | Event Log nativo | Task Scheduler log | Event Log via NSSM |

---

## 2. Linux Daemon vs Cron Job vs systemd Timer

### Quando escolher Linux Daemon (processo de fundo permanente)

**Escolha daemon quando:**

- O processo deve estar **sempre em execução** (servidor HTTP, socket server, monitor de ficheiros)
- Precisa de **manter estado** em memória entre requests/eventos
- Tem **latência baixa** como requisito (não pode ter overhead de inicialização a cada invocação)
- Precisa de **gerir conexões persistentes** (TCP, WebSocket, named pipes Unix)
- Responde a **signals POSIX** (SIGTERM para shutdown graceful, SIGHUP para reload de config)

**Skill:** `developer-delphi-to-fpc-linux-servers_V1.0.0`  
**Templates:** `templates/TEMPLATE_linux_console_daemon.pas`, `templates/TEMPLATE_daemon.service`

---

### Quando escolher Cron Job

**Escolha cron quando:**

- A tarefa deve correr **em horários fixos** (backup diário às 02:00, relatório semanal)
- A tarefa é **de curta duração** e termina sozinha
- Não precisa de comunicação entre execuções (stateless)
- Simplicidade é prioritária — `crontab -e` é suficiente para casos básicos
- Não precisa de logs sofisticados (stdout/stderr redireccionado para ficheiro)

```cron
# Exemplo: backup às 02:30 todos os dias
30 2 * * * /opt/myapp/backup_db >> /var/log/myapp/backup.log 2>&1
```

---

### Quando escolher systemd Timer

**Escolha systemd timer quando:**

- Precisa do **rigor do cron** mas com gestão via `systemctl` (enable/disable/status)
- Quer **calendário flexível** (`OnCalendar=weekly`, `OnBootSec=5min`)
- Precisa de **logging integrado no journald** (sem redireccionar stdout)
- Quer **dependências entre timers e serviços** (o timer só corre se outro serviço estiver activo)
- Precisa de **OnFailure** (acção quando o timer/serviço falha)

```ini
# Exemplo: myapp-backup.timer
[Timer]
OnCalendar=*-*-* 02:30:00
Persistent=true

[Install]
WantedBy=timers.target
```

**Comparação rápida:**

| Critério | Daemon | Cron | systemd Timer |
|----------|--------|------|---------------|
| Execução contínua | Sim | Não | Não |
| Execução periódica | Não (loop interno) | Sim | Sim |
| Gestão via systemctl | Sim | Não | Sim |
| Logs no journald | Sim | Não (ficheiro) | Sim |
| Dependências de serviço | Sim | Não | Sim |
| Estado persistente | Sim | Não | Não |
| Latência de arranque | Zero (já em execução) | Alta (process fork) | Alta (process fork) |
| Complexidade | Alta | Baixa | Média |

---

## 3. DLL vs BPL vs COM vs Interface approach

### DLL (Dynamic Link Library / Shared Object)

**Use DLL/.so quando:**

- Precisa de partilhar código entre **aplicações de linguagens diferentes** (C, Python, C++, Delphi)
- A biblioteca deve ser carregada por aplicações que **não têm o Delphi runtime**
- Precisa de exportar funções com **calling conventions standard** (stdcall/cdecl)
- O deployment é **independente** — a DLL pode ser actualizada sem reinstalar a app principal
- Quer **isolamento de memória** rigoroso entre módulos (cada DLL tem o seu heap se não usar ShareMem)

**Skill:** `developer-delphi-to-fpc-shared-libraries_V1.0.0`

---

### BPL (Borland Package Library)

**Use BPL quando:**

- **Todos** os módulos são Delphi e partilham o mesmo runtime
- Quer partilhar **componentes VCL/FMX** em design time (instalação no IDE)
- Precisa de aceder a tipos Delphi complexos (classes, strings AnsiString/UnicodeString, interfaces)
- O objectivo é **reduzir o tamanho** do executável principal distribuindo código em packages
- O deployment é **controlado** — os BPLs são instalados numa localização conhecida

**Limitações de BPL:**
- Não pode ser carregado por aplicações não-Delphi
- Requer o Delphi runtime instalado
- Versões do Delphi devem coincidir exactamente

---

### COM (Component Object Model)

**Use COM quando:**

- Precisa de integração com **tecnologias Windows legacy** (Office, shell extensions, ActiveX)
- Precisa de **registo no Windows Registry** e activação por ProgID/CLSID
- O cliente pode ser **qualquer linguagem COM-compatible** (VBScript, Python win32com, C++)
- Precisa de **marshalling automático** entre processos (COM out-of-proc servers)
- Compatibilidade com sistemas antigos é obrigatória

**Nota:** COM é a escolha certa para shell extensions, add-ins do Office, e integração com sistemas Windows legacy. Para novos desenvolvimentos, prefira interfaces Delphi ou DLL com C API.

---

### Interface approach (Delphi interfaces como boundary)

**Use interfaces Delphi quando:**

- **Todos** os módulos são Delphi (mesmo compilador/versão)
- Quer **gestão automática de lifetime** via reference counting
- Precisa de **plugin system** sem overhead de COM
- Quer evitar problemas de memory manager (interfaces não passam strings/classes — apenas tipos POD e outras interfaces)
- Quer **type safety** sem marshalling manual

**Padrão recomendado:**

```delphi
// Unit partilhada (sem implementação)
unit IPlugin;
interface
type
  IPlugin = interface
    ['{GUID-AQUI}']
    function GetName: string;
    procedure Execute(const AParam: string);
  end;
  
  // Factory function exportada pela DLL
  TCreatePlugin = function: IPlugin; stdcall;
end.
```

**Skill:** `developer-delphi-to-fpc-shared-libraries_V1.0.0` → `exemplos/interface_plugin_host.pas`

---

**Tabela de trade-offs — DLL vs BPL vs COM vs Interfaces:**

| Critério | DLL (C API) | BPL | COM | Interfaces Delphi |
|----------|-------------|-----|-----|-------------------|
| Interop multi-linguagem | Sim | Não | Sim | Não |
| Type safety | Baixa | Alta | Média | Alta |
| Gestão de memória | Manual | Automática | Automática (IUnknown) | Automática (ref count) |
| Registo no sistema | Não | Não | Sim (registry) | Não |
| Versioning | Manual | Delphi version lock | Interface versioning | GUID-based |
| Complexity | Baixa | Baixa | Alta | Média |
| Performance | Alta | Alta | Média (marshalling) | Alta |
| Debugging | Difícil cross-DLL | Fácil | Médio | Fácil |
| Deploy independente | Sim | Sim | Sim | Sim (DLL host) |
| Compatível com não-Delphi | Sim | Não | Sim | Não |

---

## 4. LoadLibrary dinâmico vs Link estático vs Pacotes

### LoadLibrary / dlopen (carregamento dinâmico)

**Use carregamento dinâmico quando:**

- Os plugins são **opcionais** — a aplicação deve funcionar mesmo sem eles
- Os plugins são **desenvolvidos por terceiros** e desconhecidos em compile time
- Precisa de **hot-reload** — carregar/descarregar plugins sem reiniciar a aplicação
- Quer **isolamento de falhas** — um plugin que crasha pode ser descarregado sem afectar o host
- A **lista de plugins não é fixa** — o utilizador instala/remove plugins em runtime

**Skill:** `developer-delphi-to-fpc-shared-libraries_V1.0.0`  
**Exemplos:** `exemplos/loadlibrary_consumer_win.pas`, `exemplos/dlopen_consumer_linux.pas`

---

### Link estático (uses na secção interface/implementation)

**Use link estático quando:**

- Os módulos são **sempre necessários** — não há cenário de funcionamento sem eles
- Quer o **executável único** (sem DLLs externas para distribuir)
- Performance é crítica e quer evitar o overhead de chamadas inter-DLL
- Quer **simplificar o deployment** — um único `.exe` sem dependências

**Nota:** Link estático em Delphi é o comportamento padrão via `uses`. Não há mecanismo de link estático para bibliotecas C externas no estilo `static library` — usa-se em vez disso importação de DLL com declarações `external`.

---

### BPL (Pacotes Delphi)

**Use BPL quando:**

- Quer reutilização de código entre **múltiplas aplicações Delphi** sem duplicar código
- Os componentes precisam de ser instalados no **IDE Delphi** (design time)
- Quer reduzir o tamanho dos executáveis distribuindo código partilhado em BPLs
- O ambiente de deployment é **controlado** (instalação do BPL garantida)

**Comparação rápida:**

| Critério | LoadLibrary/dlopen | Link estático | BPL |
|----------|-------------------|---------------|-----|
| Carregamento em runtime | Sim | Não | Sim (mas fixo) |
| Plugins de terceiros | Sim | Não | Não |
| Hot-reload | Sim | Não | Não |
| Executável único | Não | Sim | Não |
| Isolamento de falhas | Sim | Não | Não |
| Performance | Média | Alta | Alta |
| Complexity deploy | Média | Baixa | Média |
| Compatível com não-Delphi | Sim (C API) | N/A | Não |

---

## 5. Referências para aprofundamento

| Tópico | Recurso |
|--------|---------|
| Windows Service completo | `developer-delphi-windows-services_V1.0.0/SKILL.md` |
| Session 0 isolation (sem UI) | `developer-delphi-windows-services_V1.0.0/consultas_rapidas/session0_isolation.md` |
| Daemon Linux + systemd | `developer-delphi-to-fpc-linux-servers_V1.0.0/SKILL.md` |
| DLL exports + memory manager | `developer-delphi-to-fpc-shared-libraries_V1.0.0/SKILL.md` |
| BPL vs DLL análise completa | `developer-delphi-to-fpc-shared-libraries_V1.0.0/consultas_rapidas/bpl_vs_dll_comparison.md` |
| Plugin system via interfaces | `developer-delphi-to-fpc-shared-libraries_V1.0.0/exemplos/interface_plugin_host.pas` |
| Calling conventions Win/Linux | `developer-delphi-to-fpc-shared-libraries_V1.0.0/consultas_rapidas/calling_conventions_win_linux.md` |

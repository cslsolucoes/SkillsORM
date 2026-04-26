---
name: developer-delphi-to-fpc-linux-daemon
description: Implementar daemons UNIX em Linux com Delphi e FPC — fork/setsid, signal handling (SIGTERM/SIGHUP/SIGPIPE) em Delphi (Posix.*) e FPC (BaseUnix), systemd unit files, tabela de equivalência Posix vs FPC, TDaemon FPC, DataSnap/Web Server em Linux e checklist pré-deploy.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-linux-daemon

## Versão interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |
| **Criado**      | 2026-04-24 |
| **Família**     | M — Serviços e Bibliotecas |

## Responsabilidade única

Implementar processos de fundo (daemons) Linux com Delphi e FPC. Cobre: projecto consola como base de daemon, daemon UNIX clássico (`fork`+`setsid`), signal handlers (`SIGTERM`, `SIGHUP`, `SIGPIPE`) em Delphi (`Posix.Signal`) e FPC (`BaseUnix`+`sigaction`), systemd unit files (Type=simple vs forking), tabela de equivalência Posix.* vs FPC BaseUnix, `TDaemon` no FPC/Lazarus, e DataSnap/Web Server em Linux.

## When to use

- Criar um daemon UNIX com fork/setsid em Delphi ou FPC.
- Implementar signal handlers (`SIGTERM`, `SIGHUP`) para saída limpa.
- Criar um unit file systemd para o daemon.
- Compreender as diferenças Posix.* (Delphi) vs BaseUnix (FPC).
- Usar `TDaemon` do Lazarus como alternativa ao fork manual.
- Desenvolver DataSnap Server ou Web Server Application para Linux.

## When NOT to use

- Configurar o PAServer ou compilar para Linux → usar `developer-delphi-to-fpc-linux-setup`.
- Windows Services → usar `developer-delphi-windows-services-setup`.
- Android/iOS → usar as skills de mobile específicas.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-to-fpc-linux-setup` | Antes — compilador, PAServer e runtime deps configurados |

## Referências cruzadas

- `developer-delphi-to-fpc-linux-setup` — PAServer, dcclinux64, runtime dependencies, deploy SCP

---

## 4. Projecto Consola como Base de Daemon

O tipo de projecto correcto para um daemon Linux é **Console Application** — não GUI, não VCL.

### 4.1 Criar no RAD Studio

```
File > New > Other > Delphi Projects > Console Application
```

Seleccionar **Linux 64-bit** como plataforma alvo antes de criar.

### 4.2 Estrutura mínima do `.dpr`

```pascal
program MeuDaemon;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  Posix.Unistd,    // getpid, fork, setsid, close, STDIN_FILENO, etc.
  Posix.Signal,    // signal, SIGTERM, SIGHUP, SIG_IGN
  Posix.Stdlib;    // exit (não confundir com System.exit)

var
  GTerminating: Boolean;

begin
  GTerminating := False;

  // Configurar signal handlers antes de qualquer trabalho
  // (ver Secção 6)

  // Daemonizar se solicitado
  // (ver Secção 5)

  // Loop principal
  while not GTerminating do
  begin
    // Trabalho do daemon
    Sleep(1000);
  end;

  // Cleanup garantido
  ExitCode := 0;
end.
```

---

## 5. Daemon UNIX Clássico (fork + setsid)

A daemonização separa o processo do terminal de controlo, cria uma nova sessão e garante que o processo sobrevive ao logout do utilizador.

### 5.1 Implementação em Delphi (Posix.*)

```pascal
uses Posix.Unistd, Posix.Stdlib, Posix.Fcntl;

procedure DaemonizeProcess;
var
  LPID: pid_t;
  LFd: Integer;
begin
  // Passo 1: Fork — processo pai termina
  LPID := fork();
  if LPID < 0 then
    raise Exception.CreateFmt('fork() falhou: errno=%d', [errno]);
  if LPID > 0 then
    Halt(0); // processo pai termina normalmente

  // Passo 2: Criar nova sessão (desligar do terminal de controlo)
  if setsid() < 0 then
    raise Exception.CreateFmt('setsid() falhou: errno=%d', [errno]);

  // Passo 3: Segundo fork (opcional mas recomendado)
  // Garante que o processo não pode readquirir um terminal de controlo
  LPID := fork();
  if LPID < 0 then
    raise Exception.CreateFmt('fork() #2 falhou: errno=%d', [errno]);
  if LPID > 0 then
    Halt(0); // segundo pai termina

  // Passo 4: Mudar directório de trabalho para /
  chdir('/');

  // Passo 5: Redirigir stdin/stdout/stderr para /dev/null
  LFd := __open('/dev/null', O_RDWR);
  if LFd >= 0 then
  begin
    __dup2(LFd, STDIN_FILENO);
    __dup2(LFd, STDOUT_FILENO);
    __dup2(LFd, STDERR_FILENO);
    if LFd > STDERR_FILENO then
      __close(LFd);
  end;
end;
```

### 5.2 Implementação em FPC (BaseUnix)

```pascal
uses BaseUnix, Unix;

procedure DaemonizeProcess;
var
  LPID: TPid;
begin
  // Fork #1
  LPID := fpFork();
  if LPID < 0 then
    raise Exception.CreateFmt('fpFork() falhou: %d', [fpgeterrno()]);
  if LPID > 0 then
    Halt(0);

  // Nova sessão
  if fpSetsid() < 0 then
    raise Exception.CreateFmt('fpSetsid() falhou: %d', [fpgeterrno()]);

  // Fork #2
  LPID := fpFork();
  if LPID < 0 then
    raise Exception.CreateFmt('fpFork() #2 falhou: %d', [fpgeterrno()]);
  if LPID > 0 then
    Halt(0);

  // Mudar para /
  fpChDir('/');

  // Redirigir stdio para /dev/null
  fpClose(0); fpOpen('/dev/null', O_RDWR);
  fpDup2(0, 1);
  fpDup2(0, 2);
end;
```

**Nota crítica:** Em Delphi para Linux usar `Posix.Unistd`. Em FPC usar `BaseUnix` (`fpFork`, `fpSetsid`). As funções Posix do Delphi são wrappers inline para as syscalls — não existe `TDaemon` no Delphi Linux (esse componente existe apenas no FPC/Lazarus via `daemonapp`).

---

## 6. Signal Handling (SIGTERM, SIGHUP, SIGPIPE)

### 6.1 Handlers em Delphi (Posix.Signal)

```pascal
uses Posix.Signal;

var
  GTerminating: Boolean = False;
  GReloadConfig: Boolean = False;

// Handler para SIGTERM e SIGINT (terminação limpa)
procedure HandleSIGTERM(ASig: Integer); cdecl;
begin
  GTerminating := True;
end;

// Handler para SIGHUP (reload de configuração)
procedure HandleSIGHUP(ASig: Integer); cdecl;
begin
  GReloadConfig := True;
end;

// Instalação dos handlers (chamar no início do programa, ANTES do fork)
procedure InstallSignalHandlers;
begin
  signal(SIGTERM, HandleSIGTERM);  // kill PID (terminação normal)
  signal(SIGINT,  HandleSIGTERM);  // Ctrl+C (para debugging)
  signal(SIGHUP,  HandleSIGHUP);   // kill -HUP PID (reload config)
  signal(SIGPIPE, SIG_IGN);        // Ignorar SIGPIPE (conexões quebradas)
end;

// Loop principal com verificação
while not GTerminating do
begin
  if GReloadConfig then
  begin
    GReloadConfig := False;
    // Recarregar configuração aqui
  end;
  // Trabalho...
  Sleep(100);
end;
```

### 6.2 Handlers em FPC (BaseUnix + sigaction)

```pascal
uses BaseUnix, Unix;

var
  GTerminating: Boolean = False;

procedure HandleSIGTERM(ASig: cint); cdecl;
begin
  GTerminating := True;
end;

procedure InstallSignalHandlers;
var
  LSA: SigActionRec;
begin
  FillChar(LSA, SizeOf(LSA), 0);
  LSA.sa_Handler := @HandleSIGTERM;
  fpSigEmptySet(LSA.sa_mask);
  LSA.sa_flags := 0;

  fpSigAction(SIGTERM, @LSA, nil);
  fpSigAction(SIGINT,  @LSA, nil);

  // Ignorar SIGPIPE
  LSA.sa_Handler := SIG_IGN;
  fpSigAction(SIGPIPE, @LSA, nil);

  // SIGHUP: ignorar ou usar handler próprio
  LSA.sa_Handler := SIG_IGN;
  fpSigAction(SIGHUP, @LSA, nil);
end;
```

### 6.3 Tabela de sinais relevantes para daemons

| Sinal | Valor | Uso típico | Acção recomendada |
|-------|-------|-----------|-------------------|
| `SIGTERM` | 15 | `kill PID` / `systemctl stop` | Terminar limpo (`GTerminating := True`) |
| `SIGINT` | 2 | Ctrl+C (debugging) | Igual a SIGTERM |
| `SIGHUP` | 1 | `kill -HUP PID` | Reload de configuração |
| `SIGPIPE` | 13 | Pipe/socket quebrado | `SIG_IGN` (ignorar) |
| `SIGCHLD` | 17 | Filho terminou | `SIG_IGN` para evitar zombies |
| `SIGUSR1` | 10 | Sinal personalizado | Dump de estado / diagnóstico |
| `SIGUSR2` | 12 | Sinal personalizado | Toggle de verbosidade de log |

---

## 7. systemd Unit File

### 7.1 Unit file mínimo funcional

```ini
[Unit]
Description=Meu Daemon Delphi
Documentation=https://exemplo.com/docs
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=meuservico
Group=meuservico
WorkingDirectory=/opt/meudaemon
ExecStart=/opt/meudaemon/MeuDaemon --config /etc/meudaemon/config.ini
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=meudaemon

[Install]
WantedBy=multi-user.target
```

### 7.2 Comandos systemd essenciais

```bash
# Instalar o unit
sudo cp meudaemon.service /etc/systemd/system/
sudo systemctl daemon-reload

# Habilitar para iniciar no boot
sudo systemctl enable meudaemon

# Controlo
sudo systemctl start   meudaemon
sudo systemctl stop    meudaemon
sudo systemctl restart meudaemon
sudo systemctl reload  meudaemon   # envia SIGHUP

# Status e logs
sudo systemctl status  meudaemon
journalctl -u meudaemon -f          # follow ao vivo
journalctl -u meudaemon --since "1 hour ago"
journalctl -u meudaemon -n 100      # últimas 100 linhas
```

### 7.3 Type=simple vs Type=forking

| Tipo | Quando usar | Notas |
|------|------------|-------|
| `Type=simple` | Daemon sem fork (loop directo no processo principal) | Recomendado para Delphi/FPC modernos |
| `Type=forking` | Daemon clássico UNIX com double-fork | Requer `PIDFile=` para tracking correcto |
| `Type=notify` | Daemon que notifica o systemd via `sd_notify` | Máximo controlo; requer lib `libsystemd` |
| `Type=oneshot` | Processo que termina após a tarefa | Para scripts de inicialização |

**Recomendação:** Para daemons Delphi/FPC novos, usar `Type=simple` e **não** implementar fork — deixar o systemd gerir o ciclo de vida. Usar `fork` apenas se necessário por razões de compatibilidade legada.

---


## 9. FPC/Lazarus para Linux — Diferenças vs Delphi

### 9.1 Tabela de equivalência de units

| Unidade Delphi | Unidade FPC | Notas |
|---------------|------------|-------|
| `Posix.Unistd` | `BaseUnix` | fork, setsid, getpid, chdir, close |
| `Posix.Signal` | `BaseUnix` | fpSignal, fpSigAction |
| `Posix.Dlfcn` | `dynlibs` | LoadLibrary, GetProcAddress |
| `Posix.Stdlib` | `BaseUnix` | exit, malloc |
| `Posix.Fcntl` | `BaseUnix` | fpOpen, O_RDWR, O_CREAT |
| `Posix.SysTypes` | `Unix` | pid_t = TPid, etc. |
| `System.IOUtils` | `SysUtils` + `FileUtil` | TPath, TFile, TDirectory |
| `System.Threading` | `Classes` + `SyncObjs` | TThread funciona em ambos |

### 9.2 Tabela de funções

| Função | Delphi (Posix.*) | FPC (BaseUnix/Unix) |
|--------|-----------------|---------------------|
| fork | `Posix.Unistd.fork()` | `BaseUnix.fpFork()` |
| setsid | `Posix.Unistd.setsid()` | `BaseUnix.fpSetsid()` |
| getpid | `Posix.Unistd.getpid()` | `BaseUnix.fpGetPID()` |
| signal | `Posix.Signal.signal()` | `BaseUnix.fpSignal()` |
| sigaction | `Posix.Signal.sigaction()` | `BaseUnix.fpSigAction()` |
| open | `Posix.Fcntl.__open()` | `BaseUnix.fpOpen()` |
| close | `Posix.Unistd.__close()` | `BaseUnix.fpClose()` |
| dup2 | `Posix.Unistd.__dup2()` | `BaseUnix.fpDup2()` |
| chdir | `Posix.Unistd.chdir()` | `BaseUnix.fpChDir()` |
| dlopen | `Posix.Dlfcn.dlopen()` | `dynlibs.LoadLibrary()` |
| errno | `Posix.Errno.errno` | `BaseUnix.fpgeterrno()` |
| sleep | `Posix.Unistd.sleep()` ou `System.SysUtils.Sleep()` | `Unix.sleep()` ou `SysUtils.Sleep()` |

### 9.3 Directivas de compilação condicional

```pascal
{$IFDEF FPC}
  // Código FPC/Lazarus
  uses BaseUnix, Unix;
  var LPid: TPid;
  LPid := fpFork();
{$ELSE}
  // Código Delphi
  uses Posix.Unistd;
  var LPid: pid_t;
  LPid := fork();
{$ENDIF}
```

### 9.4 Compilar para Linux com FPC

```bash
# FPC cross-compile para Linux 64-bit (a partir do Windows)
# Requer FPC com cross-compiler instalado

# Linux 64-bit
fpc -Tlinux -Px86_64 -O2 MeuPrograma.lpr

# No próprio Linux (compilação nativa)
/usr/bin/fpc -O2 MeuPrograma.lpr

# Via fpc32.opts / fpc64.opts (padrão do projeto)
fpc @fpc64.opts MeuPrograma.lpr
```

### 9.5 TDaemon (FPC/Lazarus — componente dedicado)

O FPC oferece o componente `TDaemon` (unit `daemonapp`) que encapsula toda a lógica de daemonização:

```pascal
uses daemonapp;

type
  TMeuDaemon = class(TDaemon)
  public
    function Start: Boolean; override;
    function Stop: Boolean; override;
    function Execute: Boolean; override;
    function Install: Boolean; override;
    function UnInstall: Boolean; override;
  end;
```

**Nota:** `TDaemon` é exclusivo do FPC — não existe equivalente em Delphi para Linux. Em Delphi, implementar manualmente via fork/setsid ou usar `Type=simple` no systemd sem daemonização.

---

## 10. DataSnap/Web Server em Linux (Escopo Fechado)

### 10.1 Web Server Application Wizard

```
File > New > Other > Delphi Projects > WebBroker > Web Server Application
```

1. Seleccionar **CGI Stand-alone executable** ou **Stand-alone executable (isapi not supported)**
2. Alterar plataforma alvo para **Linux 64-bit**
3. O wizard cria um `TWebModule` com actions HTTP
4. Deploy via PAServer para o servidor Linux

**Nota:** Não existe ISAPI no Linux — usar stand-alone executable com socket próprio ou colocar atrás de nginx/Apache como reverse proxy.

### 10.2 DataSnap Server para Linux

```
File > New > Other > Delphi Projects > DataSnap Server
```

1. Seleccionar **DataSnap REST Application** ou **DataSnap Server Application**
2. Definir plataforma como **Linux 64-bit**
3. Servidor TCP DataSnap funciona nativamente no Linux

### 10.3 RAD Server (alternativa recomendada para produção)

Para serviços HTTP REST em produção no Linux, considerar **RAD Server (EMS)** como alternativa ao WebBroker manual:

```
File > New > Other > RAD Server > RAD Server Package
```

- O RAD Server Engine (EMSDevServer) pode ser instalado no Linux
- Ver CHM: `Configuring_Your_RAD_Server_Engine_or_RAD_Server_Console_on_Linux.htm`
- Gestão via console web (EMSConsole)

---

## 11. Checklist Pré-Deploy Linux

```
[ ] PAServer em execução no servidor Linux (ou configurado como serviço systemd)
[ ] Connection Profile configurado e testado no RAD Studio (Tools > Options > Connection Profile Manager)
[ ] Plataforma Linux 64-bit adicionada ao projeto (Project Manager > Target Platforms)
[ ] Licença RAD Studio verificada: Enterprise ou Architect (necessária para Linux 64-bit)
[ ] ldd ./MeuDaemon sem linhas "not found" — todas as dependências resolvidas
[ ] SIGTERM handler implementado — saída limpa sem perda de dados
[ ] Log via ficheiro ou systemd journal — NUNCA stdout/stderr em daemon de produção
[ ] Conta de utilizador dedicada (não root) para executar o daemon
[ ] systemd unit com Restart=on-failure e RestartSec=5 (ou superior)
[ ] Firewall configurado: porta do daemon acessível, PAServer (64211) restrita à rede interna
[ ] Permissões do binário: chmod 750, owner=root, group=meuservico
[ ] /opt/meudaemon/ criado com owner correcto: chown -R meuservico:meuservico /opt/meudaemon/
[ ] Teste de reinício: sudo systemctl restart meudaemon && sleep 3 && systemctl is-active meudaemon
[ ] Teste de logs: journalctl -u meudaemon -n 50 sem erros críticos
[ ] Teste de terminação: sudo systemctl stop meudaemon — verificar saída limpa nos logs
```


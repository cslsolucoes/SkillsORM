---
name: developer-delphi-to-fpc-linux-servers
description: Guia completo para desenvolver, compilar e implantar servidores e daemons Linux com Delphi (RAD Studio 12+) e FPC/Lazarus: PAServer, dcclinux64, fork/setsid, signal handling, systemd e compatibilidade FPC.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

> **⚠️ DEPRECATED — 24/04/2026**
> Esta skill foi subdividida em 2 skills filhas:
> - `developer-delphi-to-fpc-linux-setup_V1.0.0` — PAServer, dcclinux64, cross-compile, runtime dependencies
> - `developer-delphi-to-fpc-linux-daemon_V1.0.0` — fork/setsid, signal handling, systemd, FPC/Delphi diferenças, DataSnap, checklist
>
> **Use as skills filhas.** Este arquivo é mantido apenas como referência histórica.


# developer-delphi-to-fpc-linux-servers

## Versão interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |
| **Criado**      | 2026-04-11 |
| **Família**     | M — Serviços e Bibliotecas |

## Responsabilidade única

Esta skill cobre o ciclo completo de desenvolvimento de servidores e processos de fundo (daemons) Linux com Delphi e FPC: configuração do PAServer, compilação via `dcclinux64`, estrutura de daemon UNIX com `fork`/`setsid`, signal handling (`SIGTERM`, `SIGHUP`), integração com systemd, gestão de dependências de runtime (`.so`), e tabela de equivalência Posix.* (Delphi) vs BaseUnix (FPC).

## When to use

- Compilar um projeto Delphi para Linux 64-bit com `dcclinux64` ou MSBuild.
- Configurar o PAServer no servidor Linux (manual ou como serviço systemd).
- Criar um daemon UNIX com fork/setsid em Delphi ou FPC.
- Implementar signal handlers (`SIGTERM`, `SIGHUP`) para saída limpa.
- Criar unit files systemd para daemons Delphi/FPC.
- Fazer cross-compile no Windows e deploy para Linux via SCP ou Deployment Manager.
- Desenvolver Web Server ou DataSnap Server para plataforma Linux 64-bit.

## When NOT to use

- Windows Services — usar `developer-delphi-windows-services`.
- Android/iOS — usar `developer-delphi-android-setup` ou `developer-delphi-ios-publishing`.
- Aplicações GUI Linux (GTK/Qt) — fora do escopo desta skill.
- Compilação para macOS — usar perfil Mac 64-bit separado no RAD Studio.

---

## 1. Pré-requisitos para Linux

### 1.1 Lado Windows (máquina de desenvolvimento)

- **RAD Studio 12 Athens** (ou superior) com licença **Enterprise** ou **Architect**
  - A licença Professional **não inclui** a plataforma Linux 64-bit
  - Verificar: Help > About > Licensed Features → "Linux 64-bit"
- SDK e compilador Linux incluídos na instalação padrão Enterprise/Architect
- MSBuild disponível no PATH (incluso no RAD Studio)

### 1.2 Lado Linux (servidor alvo)

- **Ubuntu 20.04 LTS** ou **22.04 LTS** (certificados pela Embarcadero)
- **RHEL 8** / **Rocky Linux 8** / **AlmaLinux 8** (também suportados)
- Arquitectura: **x86_64** (Linux 64-bit)
- Pacotes de runtime obrigatórios:
  ```bash
  sudo apt install libcurl4 libssl-dev libpthread-stubs0-dev
  # ou em RHEL/Rocky:
  sudo dnf install libcurl openssl-libs
  ```
- PAServer instalado e em execução (ver Secção 2)
- Porta **64211** aberta no firewall (TCP)

### 1.3 Versões do compilador

| Compilador | Plataforma alvo | Notas |
|-----------|----------------|-------|
| `dcc32.exe` | Windows 32-bit | Não gera Linux |
| `dcc64.exe` | Windows 64-bit | Não gera Linux |
| `dcclinux64.exe` | Linux 64-bit (ELF64) | Requer instalação Enterprise/Architect |
| `fpc` (i386-linux) | Linux 32-bit | FPC open-source |
| `fpc` (x86_64-linux) | Linux 64-bit | FPC open-source |

---

## 2. PAServer (Platform Assistant) — Instalação e Configuração

O PAServer é o agente que o RAD Studio usa para comunicar com o servidor Linux: compilação remota, deploy e debugging.

### 2.1 Instalar o PAServer no Linux

```bash
# 1. Copiar o binário do Windows para o Linux via SCP
#    (localização padrão no Windows)
scp "C:\Program Files (x86)\Embarcadero\Studio\23.0\PAServer\paserver" \
    user@linuxhost:~/paserver

# 2. Tornar executável
chmod +x ~/paserver

# 3. Verificar que executa
./paserver --version
```

**Nota:** O binário `paserver` é nativo Linux ELF64 — a Embarcadero distribui-o junto com o RAD Studio Windows. Extrair de `C:\Program Files (x86)\Embarcadero\Studio\23.0\PAServer\`.

### 2.2 Iniciar o PAServer

```bash
# Porta padrão: 64211
./paserver -p 64211

# Com senha (recomendado em ambientes não-isolados)
./paserver -p 64211 -password=MinhaSenha123

# Em background (para testes — preferir systemd para produção)
nohup ./paserver -p 64211 -password=MinhaSenha123 &> ~/paserver.log &
```

### 2.3 Configurar Connection Profile no RAD Studio

1. **Tools > Options > IDE > Connection Profile Manager**
2. Clicar **Add**
3. Preencher:
   - **Name:** `LinuxDev` (nome livre)
   - **Platform:** `Linux 64-bit`
   - **Host:** IP ou hostname do servidor Linux
   - **Port:** `64211`
   - **Password:** (a mesma usada no `-password=` acima)
4. Clicar **Test Connection** — deve mostrar "Connection Successful"

### 2.4 Seleccionar a plataforma no projeto

```
Project Manager → Target Platforms → botão direito → Add Platform → Linux 64-bit
```

Depois seleccionar o **Connection Profile** criado.

### 2.5 PAServer como daemon systemd

Ver `templates/TEMPLATE_paserver.service` para o unit file completo.

```bash
# Instalação rápida
sudo cp TEMPLATE_paserver.service /etc/systemd/system/paserver.service
# Editar /etc/systemd/system/paserver.service com caminho e password
sudo systemctl daemon-reload
sudo systemctl enable paserver
sudo systemctl start paserver
sudo systemctl status paserver
```

---

## 3. Compilar com dcclinux64

### 3.1 Cross-compile via IDE (recomendado)

1. No **Project Manager**, seleccionar **Linux 64-bit** como plataforma activa
2. Seleccionar o **Connection Profile** do servidor Linux
3. **Run > Run** (F9) ou **Project > Build**
4. O IDE transfere o binário para o servidor via PAServer e pode fazer debugging remoto

### 3.2 Cross-compile via MSBuild (CLI — Windows)

```bash
# Release build para Linux 64-bit
msbuild MeuPrograma.dproj /p:Platform=Linux64 /p:Config=Release

# Debug build
msbuild MeuPrograma.dproj /p:Platform=Linux64 /p:Config=Debug

# Especificar Connection Profile
msbuild MeuPrograma.dproj /p:Platform=Linux64 /p:Config=Release \
  /p:ConnectionProfile=LinuxDev
```

Output: ficheiro ELF64 **sem extensão** na pasta de output do projeto.

### 3.3 Compilação directa via dcclinux64 (avançado)

```bash
# No Windows, via linha de comandos
# (assumindo RAD Studio no PATH ou caminho completo)
dcclinux64.exe -B -O2 \
  -NSSystem;System.SysUtils;System.Classes;Posix.Unistd;Posix.Signal \
  -U"C:\Program Files (x86)\Embarcadero\Studio\23.0\lib\Linux64\release" \
  -I"C:\Program Files (x86)\Embarcadero\Studio\23.0\include" \
  MeuPrograma.dpr

# Output: MeuPrograma (ELF64, sem extensão)
```

Ver `consultas_rapidas/dcclinux64_options.md` para referência completa de flags.

### 3.4 Deploy manual via SCP

```bash
# Copiar o binário para o servidor
scp MeuPrograma user@linuxhost:/opt/meuprograma/

# Tornar executável
ssh user@linuxhost "chmod +x /opt/meuprograma/MeuPrograma"

# Verificar dependências
ssh user@linuxhost "ldd /opt/meuprograma/MeuPrograma"
```

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

## 8. Runtime Dependencies no Linux

### 8.1 Verificar dependências do binário

```bash
# Listar todas as bibliotecas necessárias
ldd /opt/meudaemon/MeuDaemon

# Output típico (Delphi):
#   linux-vdso.so.1 => (0x00007ffea...)
#   libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0
#   libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6
#   librtl.so => not found   ← precisa de deploy!
#   libssl.so.1.1 => /usr/lib/x86_64-linux-gnu/libssl.so.1.1

# Verificar se alguma lib está em falta
ldd /opt/meudaemon/MeuDaemon | grep "not found"
```

### 8.2 RTL Delphi para Linux 64-bit

Os seguintes ficheiros `.so` fazem parte da RTL Delphi e **devem ser incluídos no deploy** via Deployment Manager:

| Ficheiro | Obrigatório | Descrição |
|---------|------------|-----------|
| `librtl.so` | Sim | RTL Delphi base (System.SysUtils, etc.) |
| `libpthread.so.0` | Sim (do OS) | Threading POSIX — instalado no sistema |
| `libc.so.6` | Sim (do OS) | libc — instalado no sistema |
| `libssl.so` / `libssl.so.1.1` | Condicional | SSL/TLS (se usar Indy, TLS, HTTPS) |
| `libcurl.so` | Condicional | HTTP client (TNetHTTPClient, REST) |
| `libz.so.1` | Condicional | Compressão (ZLib) |
| `libdbtg.so` | Debug only | DataBase Table Grid (apenas debug) |

### 8.3 Configurar Deployment Manager no RAD Studio

```
Project > Deployment
```

1. Seleccionar plataforma **Linux 64-bit**
2. Clicar **Add Used Unit** para incluir automaticamente os `.so` da RTL
3. Verificar que todos os ficheiros em `Required` estão marcados para deploy
4. Configurar **Remote Path** (ex.: `/opt/meudaemon/`)

### 8.4 Instalar libs no servidor

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install libcurl4 libssl-dev libz-dev

# RHEL/Rocky/AlmaLinux
sudo dnf install libcurl openssl-libs zlib

# Verificar após instalação
ldconfig -p | grep libcurl
ldconfig -p | grep libssl
```

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

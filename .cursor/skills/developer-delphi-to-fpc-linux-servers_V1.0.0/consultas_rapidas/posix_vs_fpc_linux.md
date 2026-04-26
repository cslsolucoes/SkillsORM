# Delphi Posix.* vs FPC BaseUnix/Unix — Tabela de Equivalência

Referência completa das chamadas relevantes para daemons e servidores Linux,
comparando as APIs Delphi (Posix.*) com as APIs FPC (BaseUnix, Unix, dynlibs).

---

## Units necessárias

| Área | Delphi | FPC |
|------|--------|-----|
| Processo / Fork / PID | `Posix.Unistd` | `BaseUnix` |
| Sinais | `Posix.Signal` | `BaseUnix` |
| File descriptors / IO | `Posix.Fcntl`, `Posix.Unistd` | `BaseUnix` |
| Dynamic linking | `Posix.Dlfcn` | `dynlibs` |
| Tipos POSIX (pid_t, etc.) | `Posix.SysTypes` | `Unix` / `BaseUnix` |
| Erros (errno) | `Posix.Errno` | `BaseUnix` (fpgeterrno) |
| stdlib (exit, abort) | `Posix.Stdlib` | `BaseUnix` / `SysUtils` |
| Diretórios / FS | `Posix.Unistd`, `Posix.Fcntl` | `BaseUnix`, `Unix` |
| Memória | `Posix.Stdlib` | `BaseUnix` |
| Sockets | `Posix.SysSocket`, `Posix.NetinetIn` | `Sockets` |
| Time / Clock | `Posix.Time` | `Unix`, `BaseUnix` |
| Daemon (component) | *(não existe)* | `daemonapp` |

---

## 1. Gestão de Processos

| Operação | Delphi | FPC | Notas |
|----------|--------|-----|-------|
| Fork | `fork(): pid_t` | `fpFork(): TPid` | Tipos equivalentes |
| Criar nova sessão | `setsid(): pid_t` | `fpSetsid(): TPid` | Para daemonização |
| Obter PID | `getpid(): pid_t` | `fpGetPID(): TPid` | PID do processo actual |
| Obter PPID | `getppid(): pid_t` | `fpGetPPID(): TPid` | PID do processo pai |
| Mudar directório | `chdir(path): Integer` | `fpChDir(path): cint` | |
| Obter directório actual | `getcwd(buf, size): MarshaledAString` | `fpGetCWD(buf, size): pchar` | |
| Terminar processo | `Posix.Stdlib.exit(code)` ou `Halt(code)` | `Halt(code)` | |
| Exec | `execve(path, argv, envp)` | `fpExecve(path, argv, envp)` | Substituir processo |
| Wait filho | `waitpid(pid, stat, opts)` | `fpWaitPid(pid, stat, opts)` | |

```pascal
// Delphi
uses Posix.Unistd;
var LPid: pid_t;
LPid := fork();
if LPid > 0 then Halt(0);

// FPC
uses BaseUnix;
var LPid: TPid;
LPid := fpFork();
if LPid > 0 then Halt(0);
```

---

## 2. Sinais

| Operação | Delphi | FPC | Notas |
|----------|--------|-----|-------|
| Instalar handler simples | `signal(sig, handler)` | `fpSignal(sig, handler)` | Compatível ANSI C |
| Instalar handler completo | `sigaction(sig, @sa, nil)` | `fpSigAction(sig, @sa, nil)` | Preferível |
| Mascarar sinais | `sigprocmask(how, @new, @old)` | `fpSigProcMask(how, @new, @old)` | |
| Inicializar máscara vazia | `sigemptyset(@mask)` | `fpSigEmptySet(@mask)` | |
| Inicializar máscara cheia | `sigfillset(@mask)` | `fpSigFillSet(@mask)` | |
| Adicionar sinal à máscara | `sigaddset(@mask, sig)` | `fpSigAddSet(@mask, sig)` | |
| Remover da máscara | `sigdelset(@mask, sig)` | `fpSigDelSet(@mask, sig)` | |
| Verificar na máscara | `sigismember(@mask, sig)` | `fpSigIsMember(@mask, sig)` | |
| Enviar sinal | `kill(pid, sig)` | `fpKill(pid, sig)` | |
| Ignorar sinal | `SIG_IGN` | `SIG_IGN` | Igual em ambos |
| Default do sinal | `SIG_DFL` | `SIG_DFL` | Igual em ambos |

### Tipos de struct sigaction

```pascal
// Delphi: Posix.Signal
type
  sigaction_t = record
    sa_handler : Pointer;  // ou sa_sigaction
    sa_mask    : sigset_t;
    sa_flags   : Integer;
  end;

// FPC: BaseUnix
type
  SigActionRec = record
    sa_Handler : SignalHandler;  // ou SigActionHandler
    sa_mask    : TSigSet;
    sa_flags   : cint;
    sa_restorer: Pointer;
  end;
```

### Constantes de sinais (iguais em Delphi e FPC)

| Sinal | Valor | Descrição |
|-------|-------|-----------|
| `SIGTERM` | 15 | Terminação normal (kill PID) |
| `SIGINT` | 2 | Interrupção (Ctrl+C) |
| `SIGHUP` | 1 | Hangup / reload config |
| `SIGKILL` | 9 | Kill forçado (não pode ser interceptado) |
| `SIGPIPE` | 13 | Escrita em pipe/socket fechado |
| `SIGCHLD` | 17 | Processo filho terminou |
| `SIGUSR1` | 10 | Sinal de utilizador 1 |
| `SIGUSR2` | 12 | Sinal de utilizador 2 |
| `SIGALRM` | 14 | Timer alarm |
| `SIGABRT` | 6 | Abort (assert falhou, etc.) |
| `SIGSEGV` | 11 | Segmentation fault |

---

## 3. File Descriptors e I/O

| Operação | Delphi | FPC | Notas |
|----------|--------|-----|-------|
| Abrir ficheiro | `__open(path, flags): Integer` | `fpOpen(path, flags): cint` | |
| Abrir com modo | `__open(path, flags, mode)` | `fpOpen(path, flags, mode)` | |
| Fechar | `__close(fd): Integer` | `fpClose(fd): cint` | |
| Ler | `read(fd, buf, count)` | `fpRead(fd, buf, count)` | |
| Escrever | `write(fd, buf, count)` | `fpWrite(fd, buf, count)` | |
| Duplicar fd | `dup(fd)` | `fpDup(fd)` | |
| Duplicar fd para fd2 | `__dup2(fd, fd2)` | `fpDup2(fd, fd2)` | |
| Controlo de fd | `fcntl(fd, cmd, ...)` | `fpFcntl(fd, cmd, ...)` | |
| Stdin/Stdout/Stderr | `STDIN_FILENO` (0), `STDOUT_FILENO` (1), `STDERR_FILENO` (2) | 0, 1, 2 | |

### Flags de abertura (O_*)

| Flag | Valor | Descrição |
|------|-------|-----------|
| `O_RDONLY` | 0 | Somente leitura |
| `O_WRONLY` | 1 | Somente escrita |
| `O_RDWR` | 2 | Leitura e escrita |
| `O_CREAT` | 64 (0x40) | Criar se não existir |
| `O_TRUNC` | 512 (0x200) | Truncar ao abrir |
| `O_APPEND` | 1024 (0x400) | Acrescentar ao fim |
| `O_NONBLOCK` | 2048 (0x800) | Não bloqueante |
| `O_CLOEXEC` | 524288 | Fechar em exec() |

---

## 4. Dynamic Linking (dlopen)

| Operação | Delphi | FPC |
|----------|--------|-----|
| Carregar biblioteca | `dlopen(path, flags): Pointer` | `LoadLibrary(path): TLibHandle` |
| Obter símbolo | `dlsym(handle, name): Pointer` | `GetProcAddress(handle, name): Pointer` |
| Descarregar | `dlclose(handle): Integer` | `FreeLibrary(handle): Boolean` |
| Último erro | `dlerror(): MarshaledAString` | `GetLoadErrorStr(): string` |

```pascal
// Delphi
uses Posix.Dlfcn;
var
  LHandle: Pointer;
  LFunc: procedure; cdecl;
begin
  LHandle := dlopen('/usr/lib/libminhab.so', RTLD_LAZY);
  if LHandle <> nil then
  begin
    @LFunc := dlsym(LHandle, 'minha_funcao');
    if Assigned(LFunc) then LFunc();
    dlclose(LHandle);
  end;
end;

// FPC
uses dynlibs;
var
  LHandle: TLibHandle;
  LFunc: procedure; cdecl;
begin
  LHandle := LoadLibrary('/usr/lib/libminhab.so');
  if LHandle <> NilHandle then
  begin
    @LFunc := GetProcAddress(LHandle, 'minha_funcao');
    if Assigned(LFunc) then LFunc();
    FreeLibrary(LHandle);
  end;
end;
```

---

## 5. Tipos de Dados POSIX

| Tipo C | Delphi | FPC |
|--------|--------|-----|
| `pid_t` | `pid_t` (Posix.SysTypes) | `TPid` (BaseUnix) |
| `uid_t` | `uid_t` | `TUid` |
| `gid_t` | `gid_t` | `TGid` |
| `off_t` | `off_t` | `TOff` |
| `size_t` | `size_t` | `SizeT` / `csize_t` |
| `ssize_t` | `ssize_t` | `cssize_t` |
| `int` | `Integer` | `cint` |
| `char*` | `MarshaledAString` | `pchar` / `PChar` |
| `void*` | `Pointer` | `Pointer` |
| `mode_t` | `mode_t` | `TMode` |

---

## 6. Errno (Códigos de Erro)

| Operação | Delphi | FPC |
|----------|--------|-----|
| Obter errno | `errno` (Posix.Errno) | `fpgeterrno()` (BaseUnix) |
| Definir errno | `errno := value` | `fpseterrno(value)` |
| Mensagem de erro | `strerror(errno)` | `SysErrorMessage(fpgeterrno())` |

Constantes de erro comuns (iguais em Delphi e FPC):

| Constante | Valor | Descrição |
|-----------|-------|-----------|
| `EPERM` | 1 | Operação não permitida |
| `ENOENT` | 2 | Ficheiro ou directório não existe |
| `EACCES` | 13 | Permissão negada |
| `EEXIST` | 17 | Ficheiro já existe |
| `EINVAL` | 22 | Argumento inválido |
| `EAGAIN` | 11 | Tentar novamente (recurso temporariamente indisponível) |
| `EINTR` | 4 | Chamada de sistema interrompida por sinal |
| `ENOTSUP` | 95 | Operação não suportada |
| `ECONNREFUSED` | 111 | Conexão recusada |
| `ETIMEDOUT` | 110 | Timeout de conexão |

---

## 7. Directiva de Compilação Condicional Completa

```pascal
{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

uses
{$IFDEF FPC}
  BaseUnix,
  Unix,
  dynlibs
{$ELSE}
  Posix.Unistd,
  Posix.Signal,
  Posix.Fcntl,
  Posix.Stdlib,
  Posix.Dlfcn,
  Posix.Errno
{$ENDIF}
  ;

function GetProcessID: Integer;
begin
  {$IFDEF FPC}
  Result := Integer(fpGetPID());
  {$ELSE}
  Result := getpid();
  {$ENDIF}
end;

function ForkProcess: Integer;
begin
  {$IFDEF FPC}
  Result := Integer(fpFork());
  {$ELSE}
  Result := fork();
  {$ENDIF}
end;

function GetLastOSError: Integer;
begin
  {$IFDEF FPC}
  Result := fpgeterrno();
  {$ELSE}
  Result := errno;
  {$ENDIF}
end;
```

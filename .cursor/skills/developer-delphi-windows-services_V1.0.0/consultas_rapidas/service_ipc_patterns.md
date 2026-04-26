# IPC — Padrões de Comunicação Serviço ↔ App Desktop

> Todos os mecanismos funcionam cross-session (Sessão 0 ↔ Sessão 1+) com a configuração correcta.

---

## Comparação rápida

| Mecanismo | Direcção | Complexidade | Fiabilidade | Performance | Quando usar |
|-----------|---------|-------------|------------|------------|------------|
| Named Pipes | Bidirecional | Média | Alta | Alta | Caso geral — comunicação fiável e tipada |
| TCP/IP local | Bidirecional | Baixa | Alta | Alta | Compatibilidade máxima, debug fácil, Telnet |
| Mailslots | Serviço → Desktop | Baixa | Baixa (UDP-like) | Média | Notificações broadcast sem confirmação |
| Shared Memory | Bidirecional | Alta | Alta (com sync) | Muito Alta | Alto volume de dados sem latência |
| Windows Messages | Bidirecional | Baixa | Baixa | Baixa | **EVITAR** em cross-session |
| COM Local Server | Bidirecional | Alta | Alta | Média | Integração COM/DCOM existente |
| WCF Named Pipe | Bidirecional | Alta (.NET) | Alta | Alta | Interop com serviços .NET |

---

## Named Pipes (recomendado para maioria dos casos)

**Pros:**
- Nativo Win32 — sem dependências externas
- Bidirecional — cliente e servidor podem enviar/receber
- Modo message — mensagens delimitadas automaticamente
- Segurança integrada — ACLs no pipe
- Cross-session transparente
- Suporta impersonation do cliente no servidor

**Contras:**
- Complexidade moderada de implementação
- Single-client por padrão (múltiplas instâncias para multi-client)
- Não funciona cross-machine sem `\\NomeMaquina\pipe\Nome`

**Exemplo mínimo — Serviço (servidor):**

```pascal
const PIPE = '\\.\pipe\GestorERPPipe';

// Criar pipe (no OnStart):
FPipeHandle := CreateNamedPipe(PIPE,
  PIPE_ACCESS_DUPLEX,
  PIPE_TYPE_MESSAGE or PIPE_READMODE_MESSAGE or PIPE_WAIT,
  PIPE_UNLIMITED_INSTANCES, 4096, 4096, 0, nil);

// Thread de escuta:
while not Terminated do
begin
  if ConnectNamedPipe(FPipeHandle, nil) then
  begin
    ReadFile(FPipeHandle, LBuf, SizeOf(LBuf), LRead, nil);
    // processar...
    WriteFile(FPipeHandle, LResp, LRespLen, LWritten, nil);
    DisconnectNamedPipe(FPipeHandle);
  end;
end;
```

**Exemplo mínimo — App Desktop (cliente):**

```pascal
LHandle := CreateFile(PIPE, GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, 0, 0);
WriteFile(LHandle, LCmd, LCmdLen, LWritten, nil);
ReadFile(LHandle, LBuf, SizeOf(LBuf), LRead, nil);
CloseHandle(LHandle);
```

---

## TCP/IP local (localhost)

**Pros:**
- Máxima compatibilidade (qualquer linguagem pode conectar)
- Debug fácil com Telnet, Netcat, Postman
- Pode escalar para rede se necessário
- Bibliotecas maduras no Delphi (Indy, ICS, SynCrtSock)

**Contras:**
- Requer binding a porta — conflito possível com outros processos
- Firewall pode bloquear (mesmo localhost em alguns configs)
- Ligeiramente mais overhead que named pipes

**Portas recomendadas:** Usar portas acima de 1024, preferencialmente registadas (IANA). Para uso interno, range 49152–65535 (ephemeral).

**Exemplo com Indy:**

```pascal
// No serviço (TIdTCPServer):
FServer := TIdTCPServer.Create(nil);
FServer.DefaultPort := 19876;
FServer.OnExecute := HandleClientRequest;
FServer.Active := True;

procedure HandleClientRequest(AContext: TIdContext);
var LCmd: string;
begin
  LCmd := AContext.Connection.IOHandler.ReadLn;
  // processar...
  AContext.Connection.IOHandler.WriteLn('PONG');
end;

// Na app desktop (TIdTCPClient):
FClient := TIdTCPClient.Create(nil);
FClient.Host := '127.0.0.1';
FClient.Port := 19876;
FClient.Connect;
FClient.IOHandler.WriteLn('PING');
LResp := FClient.IOHandler.ReadLn;
```

---

## Mailslots

**Pros:**
- Broadcast automático — um envio chega a todos os clientes
- Simples de implementar
- Cross-machine possível (`\\*\mailslot\Nome`)

**Contras:**
- Unidirecional (serviço → desktop) — sem resposta
- Sem garantia de entrega (UDP-like)
- Tamanho limitado de mensagem (~424 bytes via rede, maior localmente)
- Descontinuado em alguns contextos modernos

**Exemplo:**

```pascal
// No cliente (app desktop) — criar o mailslot receptor:
FMailslot := CreateMailslot('\\.\mailslot\GestorERPNotify',
  0, MAILSLOT_WAIT_FOREVER, nil);

// Thread de leitura:
while not Terminated do
begin
  ReadFile(FMailslot, LBuf, SizeOf(LBuf), LRead, nil);
  // processar notificação...
end;

// No serviço — enviar notificação:
LHandle := CreateFile('\\.\mailslot\GestorERPNotify',
  GENERIC_WRITE, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
WriteFile(LHandle, LMsg, LMsgLen, LWritten, nil);
CloseHandle(LHandle);

// Broadcast para TODAS as máquinas da rede:
LHandle := CreateFile('\\*\mailslot\GestorERPNotify', ...);
```

---

## Shared Memory (Memory-Mapped Files)

**Pros:**
- Performance máxima — zero-copy entre processos
- Ideal para grandes volumes de dados estruturados
- Acesso simultâneo de múltiplos processos
- Named sections funcionam cross-session

**Contras:**
- Requer sincronização explícita (Mutex, Event, Semaphore)
- Complexidade alta — bugs de concorrência difíceis de detectar
- Tamanho definido em criação (não cresce dinamicamente)

**Exemplo:**

```pascal
type
  PSharedStatus = ^TSharedStatus;
  TSharedStatus = record
    Version     : Cardinal;
    Estado      : Integer;   // 0=parado, 1=running, 2=paused
    CiclosTotal : Int64;
    UltimaExec  : TDateTime;
    MsgErro     : array[0..255] of Char;
  end;

const
  SHARED_MEM_NAME  = 'GestorERPSharedStatus';
  SHARED_MUTEX_NAME = 'GestorERPSharedMutex';

// No serviço (criar e escrever):
FMapHandle := CreateFileMapping(INVALID_HANDLE_VALUE, nil,
  PAGE_READWRITE, 0, SizeOf(TSharedStatus), SHARED_MEM_NAME);
FShared := MapViewOfFile(FMapHandle, FILE_MAP_ALL_ACCESS, 0, 0, 0);
FMutex := CreateMutex(nil, False, SHARED_MUTEX_NAME);

// Escrever com sincronização:
WaitForSingleObject(FMutex, INFINITE);
try
  FShared^.Estado := 1;
  FShared^.CiclosTotal := Inc(FCiclos);
  FShared^.UltimaExec := Now;
finally
  ReleaseMutex(FMutex);
end;

// Na app desktop (abrir e ler):
FMapHandle := OpenFileMapping(FILE_MAP_READ, False, SHARED_MEM_NAME);
FShared := MapViewOfFile(FMapHandle, FILE_MAP_READ, 0, 0, 0);
FMutex := OpenMutex(MUTEX_ALL_ACCESS, False, SHARED_MUTEX_NAME);

WaitForSingleObject(FMutex, 5000);
try
  LEstado := FShared^.Estado;
  LCiclos := FShared^.CiclosTotal;
finally
  ReleaseMutex(FMutex);
end;
```

---

## Windows Messages (EVITAR em cross-session)

**Por que evitar:**
- A partir do Vista, `PostMessage(HWND_BROADCAST, ...)` NÃO atravessa fronteiras de sessão
- `FindWindow` de sessão 0 para sessão 1 é bloqueado pelo UIPI (User Interface Privilege Isolation)
- Apenas funciona dentro da mesma sessão

**Se absolutamente necessário (mesma sessão, app desktop para outra app):**
```pascal
// Registar mensagem customizada:
const WM_GESTORERP_NOTIFY = WM_USER + 100;

// Enviar (dentro da mesma sessão):
PostMessage(LHWnd, WM_GESTORERP_NOTIFY, LWParam, LLParam);

// Alternativa com ChangeWindowMessageFilter (Vista+) para UIPI:
ChangeWindowMessageFilter(WM_GESTORERP_NOTIFY, MSGFLT_ADD);
```

---

## Matriz de decisão por requisito

| Requisito | Mecanismo recomendado |
|-----------|----------------------|
| Comandos request/response simples | Named Pipes |
| Compatibilidade com múltiplas linguagens | TCP/IP local |
| Notificações sem confirmação | Mailslots |
| Dados em tempo real com alta frequência | Shared Memory |
| Status polling frequente | Shared Memory (read-only na app) |
| Debug/diagnóstico via terminal | TCP/IP local |
| Multi-cliente simultâneo | TCP/IP local ou Named Pipes (multi-instance) |
| Segurança por identidade Windows | Named Pipes (com impersonation) |
| Interop com serviços .NET | Named Pipes via WCF |

# Session 0 Isolation — Guia Completo

## Por que existe

A partir do **Windows Vista (2007)**, a Microsoft introduziu o isolamento de sessão (Session Isolation) como medida de segurança contra os chamados **"shatter attacks"** — ataques onde código malicioso enviava mensagens de janela (WM_*) para processos privilegiados (como serviços a correr como SYSTEM) para forçar execução de código arbitrário.

**Antes do Vista:** Serviços e o desktop do utilizador corriam na mesma sessão (Sessão 0).

**Após o Vista:** Serviços são isolados na **Sessão 0**, enquanto cada utilizador interactivo recebe a sua própria sessão numerada (Sessão 1, 2, etc.).

```
Vista+:
  Sessão 0 ← Serviços Windows (LocalSystem, LocalService, NetworkService)
  Sessão 1 ← Utilizador interactivo 1 (Desktop, apps, etc.)
  Sessão 2 ← Utilizador interactivo 2 (em servidores TS/RDP)
```

---

## O que NÃO fazer num serviço

### UI e janelas (NUNCA)

```pascal
// PROIBIDO — a janela é criada mas invisível na sessão 0
// A função BLOQUEIA indefinidamente aguardando input do utilizador
ShowMessage('Erro crítico!');
// → Serviço congela. SCM detecta timeout. Serviço é marcado como falho.

MessageDlg('Confirmar operação?', mtConfirmation, [mbYes, mbNo], 0);
// → Idem — bloqueio infinito.

Application.MessageBox('OK', 'Título', MB_OK);
// → Idem.

TOpenDialog.Execute;
TOpenDialog.FileName; // se diálogo anterior bloqueou
// → Bloqueio.

// Windows API directa — também bloqueada:
MessageBox(0, 'Erro', 'Título', MB_OK);
// → Com MB_SERVICE_NOTIFICATION pode mostrar na sessão 0 mas é depreciado
```

### Console I/O (sem efeito ou erro)

```pascal
// Sem console alocado num serviço — output é descartado silenciosamente:
Writeln('Processando...');         // descartado
Write('Valor: ', LValor, #13#10); // descartado
readln;                            // bloqueia (sem stdin)
```

### Forms e VCL/FMX (NUNCA inicializar)

```pascal
// Não criar forms nem Application.Initialize para UI em serviços:
Application.CreateForm(TfrmMain, frmMain);  // form invisível + leak de recursos
frmMain.Show;                               // invisível na sessão 0
```

---

## Padrões correctos de logging

### TEventLogger (recomendado — integrado ao Windows)

```pascal
uses Vcl.SvcMgr;

// Dentro de TService — método disponível directamente:
procedure TGestorERPService.LogInfo(const AMsg: string);
begin
  LogMessage(AMsg, EVENTLOG_INFORMATION_TYPE, 0, 0);
end;

procedure TGestorERPService.LogError(const AMsg: string);
begin
  LogMessage(AMsg, EVENTLOG_ERROR_TYPE, 0, 0);
end;

// Fora do contexto do serviço (ex.: thread worker):
uses Vcl.SvcMgr;

procedure TWorkerThread.LogaErro(const AMsg: string);
begin
  // Aceder via variável global gerada pelo wizard:
  GestorERPService.LogMessage(AMsg, EVENTLOG_ERROR_TYPE, 0, 0);
end;
```

### Ficheiro de log (alternativa — mais controlo)

```pascal
uses System.SysUtils, System.Classes, System.SyncObjs;

type
  TFileLogger = class
  private
    class var FLock: TCriticalSection;
    class var FLogFile: string;
  public
    class procedure Initialize(const ALogPath: string);
    class procedure Log(const ALevel, AMessage: string);
    class procedure Finalize;
  end;

class procedure TFileLogger.Log(const ALevel, AMessage: string);
var
  LFile: TStreamWriter;
  LLine: string;
begin
  FLock.Enter;
  try
    LLine := Format('[%s] [%s] %s',
      [FormatDateTime('yyyy-mm-dd hh:nn:ss', Now), ALevel, AMessage]);

    LFile := TStreamWriter.Create(FLogFile, True, TEncoding.UTF8);
    try
      LFile.WriteLine(LLine);
    finally
      LFile.Free;
    end;
  finally
    FLock.Leave;
  end;
end;
```

### OutputDebugString (para debugging, nunca para produção)

```pascal
uses Winapi.Windows;

// Visível no DebugView (Sysinternals) — zero impacto em Release se não usado:
OutputDebugString(PChar('[GestorERP] Ciclo #' + IntToStr(FCiclo) + ' concluído.'));
```

---

## IPC — Comunicação Serviço ↔ App Desktop

### Named Pipes (recomendado)

**Características:**
- Bidirecional
- Tipado (mensagens delimitadas ou stream)
- Funciona cross-session (sessão 0 → sessão 1)
- Handle de pipe atravessa fronteiras de sessão

```pascal
// Nome do pipe (funciona cross-session automaticamente):
const PIPE_NAME = '\\.\pipe\GestorERPServicePipe';

// Servidor (no serviço, sessão 0):
FPipeHandle := CreateNamedPipe(PIPE_NAME, PIPE_ACCESS_DUPLEX, ...);

// Cliente (na app desktop, sessão 1):
FClientHandle := CreateFile(PIPE_NAME, GENERIC_READ or GENERIC_WRITE, ...);
```

### TCP/IP local (localhost)

```pascal
// Serviço escuta em porta local:
FTcpServer := TTCPServer.Create;
FTcpServer.Port := 19876; // porta proprietária
FTcpServer.Active := True;

// App desktop conecta:
FTcpClient := TTCPClient.Create;
FTcpClient.Host := '127.0.0.1';
FTcpClient.Port := 19876;
FTcpClient.Connect;
```

### Mailslots (apenas serviço → desktop, broadcast)

```pascal
// Criar mailslot no cliente (app desktop, sessão 1):
FMailslot := CreateMailslot('\\.\mailslot\GestorERPNotify', 0, MAILSLOT_WAIT_FOREVER, nil);

// Enviar do serviço (sessão 0):
FHandle := CreateFile('\\*\mailslot\GestorERPNotify', ...);
WriteFile(FHandle, LMsg, LLen, LWritten, nil);
// Broadcast automático para todos os clientes com este mailslot name
```

### Shared Memory (alto volume de dados)

```pascal
// Criar mapeamento de ficheiro (qualquer sessão):
FMapHandle := CreateFileMapping(INVALID_HANDLE_VALUE, nil,
  PAGE_READWRITE, 0, SizeOf(TSharedData), 'GestorERPSharedMem');

FSharedData := MapViewOfFile(FMapHandle, FILE_MAP_ALL_ACCESS, 0, 0, 0);

// Sincronizar acesso com Mutex ou Event:
FMutex := CreateMutex(nil, False, 'GestorERPSharedMemMutex');
WaitForSingleObject(FMutex, INFINITE);
try
  // acesso ao shared data
finally
  ReleaseMutex(FMutex);
end;
```

---

## Detecção de ambiente de serviço no código

```pascal
uses Winapi.Windows, Vcl.SvcMgr;

// Método 1 — via Application.IsService (mais confiável):
function IsRunningAsService: Boolean;
begin
  Result := Application.IsService;
end;

// Método 2 — via GetConsoleWindow (heurística):
function IsRunningAsService: Boolean;
begin
  // Sem console = muito provavelmente um serviço
  Result := (GetConsoleWindow = 0);
end;

// Método 3 — via parâmetros de linha de comando (deploy-specific):
function IsRunningAsService: Boolean;
begin
  // SCM passa /service ou -service em algumas implementações customizadas
  Result := FindCmdLineSwitch('service');
end;

// Uso:
procedure TGestorERPService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  if IsRunningAsService then
    LogMessage('Ambiente: serviço Windows', EVENTLOG_INFORMATION_TYPE, 0, 0)
  else
    Writeln('[DEBUG] Ambiente: console/debug');
end;
```

---

## Checklist Session 0

- [ ] Nenhum `ShowMessage`, `MessageDlg`, `MessageBox` no código do serviço
- [ ] Nenhum `TOpenDialog`, `TSaveDialog`, `TColorDialog` etc.
- [ ] Nenhum `Application.CreateForm` para forms de UI
- [ ] Nenhum `Writeln` ou `Readln` para interação com utilizador
- [ ] Log via `LogMessage` (TEventLogger) ou ficheiro de log
- [ ] IPC com app desktop via Named Pipe, TCP local ou Mailslot
- [ ] Testado como serviço real (não apenas como executável directo)
- [ ] Sem janelas de splash, progressos visuais ou confirmações

---

## Referências Microsoft

- [Interactive Services](https://docs.microsoft.com/windows/win32/services/interactive-services)
- [Session 0 Isolation](https://docs.microsoft.com/windows/win32/services/services-and-the-interactive-desktop)
- [Impact of Session 0 Isolation on Services and Drivers](https://docs.microsoft.com/windows-hardware/drivers/install/impact-of-session-0-isolation)

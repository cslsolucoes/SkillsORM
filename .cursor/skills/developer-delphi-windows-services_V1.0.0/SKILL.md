---
name: developer-delphi-windows-services
description: Guia completo para criar, instalar, depurar e manter Windows Services com Delphi usando TService, TEventLogger, Named Pipes e boas práticas de Session 0 Isolation.
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
> - `developer-delphi-windows-services-setup_V1.0.0` — TService, eventos, thread, Session 0 Isolation, TEventLogger, instalação sc.exe
> - `developer-delphi-windows-services-advanced_V1.0.0` — contas de serviço, recovery actions, debugging (4 métodos), Named Pipes IPC, checklist
>
> **Use as skills filhas.** Este arquivo é mantido apenas como referência histórica.


# developer-delphi-windows-services

## Versão interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |
| **Criado**      | 2026-04-11 |
| **Família**     | M — Serviços e Bibliotecas |

## Responsabilidade única

Esta skill cobre o ciclo completo de desenvolvimento de Windows Services com Delphi: criação com o wizard do RAD Studio, implementação correcta dos eventos `TService`, padrão de thread worker, Session 0 Isolation, logging com `TEventLogger`, instalação/desinstalação via `sc.exe`, contas de serviço, recovery actions e debugging. Inclui padrões de IPC (Named Pipes) para comunicação entre o serviço e aplicações desktop.

## When to use

- Criar um novo Windows Service com Delphi.
- Implementar threads worker dentro de um serviço.
- Configurar logging, instalação, recovery e contas de serviço.
- Depurar um serviço Windows em desenvolvimento.
- Implementar comunicação IPC entre serviço (sessão 0) e app desktop (sessão do utilizador).

## When NOT to use

- Serviços Android — usar `developer-delphi-android-setup`.
- Tarefas agendadas simples sem necessidade de serviço contínuo — usar Windows Task Scheduler.
- Daemons cross-platform (Linux/macOS) — usar FPC com `TDaemon` ou soluções específicas.
- Web services (SOAP/REST) — usar `developer-delphi-to-fpc-rtl-and-units` ou WebBroker.

---

## 1. Criar um Windows Service com Delphi (TService)

### 1.1 Wizard — File > New > Other

```
File > New > Other > Delphi Projects > Service Application
```

O wizard gera:
1. Um `.dpr` com a aplicação de serviço.
2. Uma unit de serviço (`.pas` + `.dfm`) herdando de `TService`.
3. A referência a `Vcl.SvcMgr` nas `uses`.

### 1.2 Estrutura do `.dpr` gerado

```pascal
program MeuServico;

uses
  Vcl.SvcMgr,
  uMeuServico in 'uMeuServico.pas' {MeuServico: TService};

{$R *.res}

begin
  // Obrigatório para suporte a Unicode no Windows Vista+
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.Title := 'Meu Serviço Windows';
  Application.CreateForm(TMeuServico, MeuServico);
  Application.Run;
end.
```

**Pontos obrigatórios no `.dpr`:**
- `Application.Title` — nome exibido no SCM (Services Management Console).
- `Application.DelayInitialize` — necessário para comportamento correcto em Vista+.
- `Application.Installing` — activo quando chamado com `-install`/`-uninstall`.

### 1.3 Unit de serviço — herda de TService

```pascal
unit uMeuServico;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
  Vcl.SvcMgr;

type
  TMeuServico = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService);
  private
    FThread: TThread;   // worker thread principal
  public
    function GetServiceController: TServiceController; override;
    class procedure ServiceController(CtrlCode: DWord); static; stdcall;
  end;

var
  MeuServico: TMeuServico;

implementation

{$R *.DFM}

class procedure TMeuServico.ServiceController(CtrlCode: DWord); stdcall;
begin
  MeuServico.Controller(CtrlCode);
end;

function TMeuServico.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

// ... implementação dos eventos
end.
```

---

## 2. Eventos TService — Tabela Completa

| Evento | Assinatura | Propósito |
|--------|-----------|-----------|
| `OnStart` | `procedure(Sender: TService; var Started: Boolean)` | Inicializar threads, abrir recursos; `Started := False` aborta a inicialização |
| `OnStop` | `procedure(Sender: TService)` | Sinalizar `Terminated`, aguardar threads, fechar recursos; chamado por SCM STOP |
| `OnExecute` | `procedure(Sender: TService)` | Loop principal alternativo (bloqueia até serviço parar); raro — preferir OnStart+thread |
| `OnPause` | `procedure(Sender: TService)` | SCM PAUSE — pausar operação temporariamente; thread pode fazer `SuspendThread` |
| `OnContinue` | `procedure(Sender: TService)` | SCM CONTINUE — retomar após pausa; `ResumeThread` na thread worker |
| `OnShutdown` | `procedure(Sender: TService)` | Sistema a desligar; tempo limitado (~20s) para limpeza; similar ao OnStop |
| `OnInterrogate` | `procedure(Sender: TService)` | SCM pede estado actual; normalmente não requer implementação manual |
| `OnCustomControl` | `procedure(Sender: TService; Control: DWORD)` | Comandos personalizados enviados via `ControlService` (128–255) |

**Observações críticas:**
- `OnExecute` retorna controlo ao SCM apenas quando o método retorna — usar com cuidado.
- `OnShutdown` tem prioridade sobre `OnStop` quando o sistema é reiniciado.
- Nunca bloquear `OnStop` indefinidamente — o SCM tem timeout (default: 30s).

---

## 3. Padrão correcto de Thread em OnStart/OnStop

```pascal
procedure TMeuServico.ServiceStart(Sender: TService; var Started: Boolean);
begin
  try
    FWorkerThread := TWorkerThread.Create(False); // False = iniciar imediatamente
    Started := True;
    LogMessage('Serviço iniciado com sucesso.', EVENTLOG_INFORMATION_TYPE, 0, 0);
  except
    on E: Exception do
    begin
      LogMessage('Falha ao iniciar serviço: ' + E.Message, EVENTLOG_ERROR_TYPE, 0, 0);
      Started := False;
    end;
  end;
end;

procedure TMeuServico.ServiceStop(Sender: TService);
begin
  if Assigned(FWorkerThread) then
  begin
    FWorkerThread.Terminate;       // sinaliza Terminated := True
    FWorkerThread.WaitFor;         // aguarda finalização limpa
    FreeAndNil(FWorkerThread);     // liberta memória
  end;
  LogMessage('Serviço parado.', EVENTLOG_INFORMATION_TYPE, 0, 0);
end;
```

**Regras do padrão:**
1. Criar a thread com `Create(False)` — inicia imediatamente sem necessidade de `Resume`.
2. `Terminate` apenas sinaliza `Terminated := True` — a thread deve verificar este flag no seu loop.
3. `WaitFor` aguarda a thread terminar — garantir que o worker verifica `Terminated` frequentemente.
4. `FreeAndNil` em vez de `Free` — previne double-free e ponteiros dangling.
5. Todo o bloco em `try..except` — uma excepção no `OnStart` deve colocar `Started := False`.

---

## 4. Session 0 Isolation (Vista+) — SECÇÃO OBRIGATÓRIA

### Por que existe

A partir do Windows Vista, o SCM executa todos os serviços na **Sessão 0** — uma sessão isolada sem acesso ao desktop interactivo dos utilizadores. Esta separação é uma medida de segurança para prevenir ataques "shatter attacks" e escalonamento de privilégios via mensagens de janela.

### O que NUNCA fazer num serviço

```pascal
// PROIBIDO — causam erro silencioso ou bloqueio em sessão 0:
ShowMessage('Erro: ' + E.Message);           // janela invisível — bloqueia indefinidamente
MessageDlg('Confirmar?', mtConfirmation, []); // idem
raise Exception.Create('Erro crítico');       // sem handler = crash silencioso
TOpenDialog.Execute;                          // diálogo de ficheiro = bloqueio total
Application.MessageBox('OK', 'Título', 0);   // invisível em sessão 0
```

### Logging correcto (em vez de UI)

```pascal
// CORRECTO — usar TEventLogger ou ficheiro de log:
LogMessage('Operação concluída.', EVENTLOG_INFORMATION_TYPE, 0, 0);
LogMessage('Aviso: recurso indisponível.', EVENTLOG_WARNING_TYPE, 0, 0);
LogMessage('Erro crítico: ' + E.Message, EVENTLOG_ERROR_TYPE, 0, 0);
```

### Comunicação com app desktop (sessão do utilizador)

| Mecanismo | Direcção | Complexidade | Quando usar |
|-----------|---------|-------------|-------------|
| Named Pipes | Bidirecional | Média | Comunicação fiável e tipada |
| TCP/IP local (localhost) | Bidirecional | Baixa | Compatibilidade máxima |
| Mailslots | Serviço → Desktop (broadcast) | Baixa | Notificações simples sem resposta |
| Shared Memory | Bidirecional (sem bloqueio) | Alta | Alto volume de dados |
| COM Local Server | Bidirecional | Alta | Integração COM existente |

### Detecção de ambiente de serviço no código

```pascal
function RunningAsService: Boolean;
begin
  // GetConsoleWindow = 0 indica que não há console — fortemente indica serviço
  Result := (GetConsoleWindow = 0);
end;

// Alternativa via IsService property (Vcl.SvcMgr):
if Application.IsService then
  // estamos a correr como serviço
```

---

## 5. TEventLogger — Windows Event Log

```pascal
uses
  Vcl.SvcMgr;  // TService já expõe LogMessage directamente

// Dentro da classe TService:
procedure TMeuServico.LogInfo(const AMsg: string);
begin
  LogMessage(AMsg, EVENTLOG_INFORMATION_TYPE, 0, 0);
end;

procedure TMeuServico.LogWarning(const AMsg: string);
begin
  LogMessage(AMsg, EVENTLOG_WARNING_TYPE, 0, 0);
end;

procedure TMeuServico.LogError(const AMsg: string);
begin
  LogMessage(AMsg, EVENTLOG_ERROR_TYPE, 0, 0);
end;
```

**Fora do contexto de TService (thread worker):**

```pascal
uses
  Vcl.SvcMgr;

// Aceder ao serviço global pela variável gerada pelo wizard:
procedure TWorkerThread.LogThreadError(const AMsg: string);
begin
  // MeuServico é a variável global do tipo TMeuServico
  MeuServico.LogMessage(AMsg, EVENTLOG_ERROR_TYPE, 0, 0);
end;
```

**Ver logs no Event Viewer:**
- `Win + R` → `eventvwr.msc`
- Windows Logs > Application — logs do serviço aparecem aqui
- Filtrar por Source = nome do serviço

---

## 6. Instalação e Desinstalação

### Via sc.exe (recomendado para produção)

```batch
:: Instalar o serviço
sc create "MeuServico" ^
  binPath= "C:\Caminho\MeuServico.exe" ^
  DisplayName= "Meu Serviço GestorERP" ^
  start= auto ^
  obj= "LocalSystem"

:: Adicionar descrição (opcional)
sc description "MeuServico" "Serviço de processamento em background do GestorERP"

:: Iniciar imediatamente após instalação
sc start "MeuServico"

:: Verificar estado
sc query "MeuServico"

:: Parar o serviço
sc stop "MeuServico"

:: Desinstalar (serviço deve estar parado)
sc delete "MeuServico"
```

**Nota:** O espaço após `=` nos parâmetros de `sc` é obrigatório e intencional.

### Via Delphi (auto-instalação no executável)

```pascal
// No OnCreate do serviço ou no dpr:
// Executar o .exe com parâmetro -install ou -uninstall
// O próprio SvcMgr trata dos parâmetros automaticamente
begin
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TMeuServico, MeuServico);
  Application.Run;
end.
```

```batch
:: Instalar via auto-registro
MeuServico.exe -install

:: Desinstalar via auto-registro
MeuServico.exe -uninstall
```

---

## 7. Contas de Serviço — Tabela de Decisão

| Conta | SID / Identidade | Privilégio | Acesso à Rede | Quando usar |
|-------|-----------------|-----------|---------------|-------------|
| `LocalSystem` | `NT AUTHORITY\SYSTEM` | Máximo (admin completo) | Sim (como computador) | Evitar — usar apenas se absolutamente necessário (acesso a hardware, drivers) |
| `LocalService` | `NT AUTHORITY\LOCAL SERVICE` | Mínimo | Não (anónimo) | Serviços sem acesso a rede ou recursos de sistema privilegiados |
| `NetworkService` | `NT AUTHORITY\NETWORK SERVICE` | Reduzido | Sim (como computador) | Serviços que acedem recursos de rede com identidade do computador |
| Conta personalizada | Utilizador de domínio ou local | Configurável | Conforme permissões | Ambientes corporativos — princípio do mínimo privilégio |

**Regra de ouro:** usar sempre a conta com o mínimo de privilégio necessário para a funcionalidade do serviço.

**Configurar conta personalizada via sc:**

```batch
sc config "MeuServico" obj= "DOMINIO\ContaServico" password= "SenhaSegura"
```

---

## 8. Recovery Actions (Watchdog via SCM)

O SCM pode reiniciar automaticamente um serviço em caso de falha:

```batch
:: Configurar recovery: reiniciar após 60s nas 3 primeiras falhas
:: reset= 86400 → resetar contagem de falhas após 24h
sc failure "MeuServico" ^
  reset= 86400 ^
  actions= restart/60000/restart/60000/restart/60000
```

**Parâmetros de `sc failure`:**

| Parâmetro | Descrição |
|-----------|-----------|
| `reset=` | Segundos após os quais o contador de falhas é resetado |
| `actions=` | Lista `acção/delay` separada por `/` (restart, run, reboot) |
| `command=` | Comando a executar na acção `run` |

**Via GUI:** `services.msc` → clique direito no serviço → Properties → Recovery tab.

---

## 9. Debugging de Serviços

### Método 1 — RunAs Console (desenvolvimento)

```pascal
// No .dpr, condicionalmente compilar como aplicação console:
{$IFDEF DEBUG}
  if not Application.IsService then
  begin
    // Correr como aplicação normal para facilitar debugging
    // Útil com breakpoints normais da IDE
  end;
{$ENDIF}
```

Ou directamente:

```pascal
// Antes de Application.Run:
Application.ConsoleApplication := not Application.IsService;
```

### Método 2 — Attach to Process (mais comum)

1. Iniciar o serviço normalmente: `sc start "MeuServico"`.
2. Na IDE: **Run > Attach to Process** (Shift+F9 ou menu Run).
3. Seleccionar `MeuServico.exe` na lista de processos.
4. Colocar breakpoints — serão activados normalmente.

### Método 3 — OutputDebugString + DebugView

```pascal
uses Winapi.Windows;

// Em qualquer parte do serviço:
OutputDebugString(PChar('TMeuServico: estado = ' + IntToStr(FEstado)));
```

- Descarregar **DebugView** (Sysinternals / Microsoft).
- Executar como Administrador.
- Enable: Capture > Capture Win32 e Capture > Capture Global Win32.

### Método 4 — Sleep no OnStart (para attach rápido)

```pascal
procedure TMeuServico.ServiceStart(Sender: TService; var Started: Boolean);
begin
  {$IFDEF DEBUG}
  // Dar 15 segundos para attach do debugger antes de continuar
  OutputDebugString('MeuServico: aguardando attach do debugger...');
  Sleep(15000);
  {$ENDIF}
  // código normal...
end;
```

---

## 10. Named Pipes para IPC (Serviço ↔ App Desktop)

### No serviço (servidor de pipe)

```pascal
uses Winapi.Windows;

// Criar o pipe no OnStart:
procedure TMeuServico.CriarPipe;
begin
  FPipeHandle := CreateNamedPipe(
    '\\.\pipe\GestorERPServicePipe',    // nome do pipe
    PIPE_ACCESS_DUPLEX,                  // leitura e escrita
    PIPE_TYPE_MESSAGE or                 // mensagens delimitadas
    PIPE_READMODE_MESSAGE or
    PIPE_WAIT,                           // bloqueante (usar em thread separada)
    1,        // máximo de instâncias simultâneas
    4096,     // buffer de saída (bytes)
    4096,     // buffer de entrada (bytes)
    0,        // timeout de cliente em ms (0 = default 50ms)
    nil       // atributos de segurança (nil = herdar)
  );

  if FPipeHandle = INVALID_HANDLE_VALUE then
    raise Exception.Create('Falha ao criar named pipe: ' + SysErrorMessage(GetLastError));
end;

// Thread de escuta (loop de accept):
procedure TPipeListenThread.Execute;
var
  LBuffer: array[0..4095] of Byte;
  LBytesRead: DWORD;
begin
  while not Terminated do
  begin
    if ConnectNamedPipe(FPipeHandle, nil) or (GetLastError = ERROR_PIPE_CONNECTED) then
    begin
      // Cliente conectado — ler comando
      if ReadFile(FPipeHandle, LBuffer, SizeOf(LBuffer), LBytesRead, nil) then
      begin
        // Processar comando...
        // Enviar resposta:
        // WriteFile(FPipeHandle, LResposta, LRespostaLen, LBytesWritten, nil);
      end;
      DisconnectNamedPipe(FPipeHandle);
    end;
  end;
end;
```

### Na app desktop (cliente de pipe)

```pascal
function ConectarServicoEEnviar(const AComando: string): string;
var
  LPipeHandle: THandle;
  LBuffer: array[0..4095] of Byte;
  LBytesWritten, LBytesRead: DWORD;
  LComandoBytes: TBytes;
begin
  Result := '';

  // Aguardar pipe disponível (timeout 5s)
  if not WaitNamedPipe('\\.\pipe\GestorERPServicePipe', 5000) then
    raise Exception.Create('Serviço não disponível');

  LPipeHandle := CreateFile(
    '\\.\pipe\GestorERPServicePipe',
    GENERIC_READ or GENERIC_WRITE,
    0,                    // sem partilha
    nil,                  // atributos de segurança padrão
    OPEN_EXISTING,        // pipe deve existir
    0,                    // flags normais
    0                     // sem template
  );

  if LPipeHandle = INVALID_HANDLE_VALUE then
    raise Exception.Create('Falha ao conectar ao serviço: ' + SysErrorMessage(GetLastError));

  try
    // Mudar para modo mensagem
    var LMode: DWORD := PIPE_READMODE_MESSAGE;
    SetNamedPipeHandleState(LPipeHandle, LMode, nil, nil);

    // Enviar comando
    LComandoBytes := TEncoding.UTF8.GetBytes(AComando);
    WriteFile(LPipeHandle, LComandoBytes[0], Length(LComandoBytes), LBytesWritten, nil);

    // Ler resposta
    if ReadFile(LPipeHandle, LBuffer, SizeOf(LBuffer), LBytesRead, nil) then
      Result := TEncoding.UTF8.GetString(LBuffer, 0, LBytesRead);
  finally
    CloseHandle(LPipeHandle);
  end;
end;
```

---

## 11. Checklist Pré-deploy

- [ ] Sem chamadas de UI (`ShowMessage`, `MessageBox`, `TOpenDialog`) em qualquer código executado pelo serviço
- [ ] Thread worker com verificação de `Terminated` no loop principal
- [ ] `OnStop` aguarda thread com `WaitFor` (e timeout razoável via `TEvent` se necessário)
- [ ] Log via `TEventLogger` (`LogMessage`) ou ficheiro de log estruturado
- [ ] Conta de serviço configurada com mínimo privilégio necessário
- [ ] Recovery Actions configuradas para ambiente de produção
- [ ] Testado com Attach to Process na IDE antes do deploy
- [ ] `sc failure` configurado no script de instalação
- [ ] Executável compilado em **Release** (Win64 recomendado)
- [ ] `.exe` assinado digitalmente (se distribuído fora da organização)

---

## Fontes de referência (CHM Delphi 12)

| Arquivo | Conteúdo |
|---------|----------|
| `Doc-Delphi/delphi12-topics_chm_decompiled/Service_Applications.htm` | Visão geral de Service Applications |
| `Doc-Delphi/delphi12-topics_chm_decompiled/TService.htm` | Referência completa da classe TService |
| `Doc-Delphi/delphi12-topics_chm_decompiled/Implementing_Services.htm` | Implementação e eventos |
| `Doc-Delphi/delphi12-topics_chm_decompiled/Service_Threads.htm` | Threads em serviços |
| `Doc-Delphi/delphi12-topics_chm_decompiled/Debugging_Service_Applications.htm` | Técnicas de debugging |
| `Doc-Delphi/delphi12-topics_chm_decompiled/TEventLogger.htm` | Referência do TEventLogger |

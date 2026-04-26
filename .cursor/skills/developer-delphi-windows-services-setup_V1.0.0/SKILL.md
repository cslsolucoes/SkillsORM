---
name: developer-delphi-windows-services-setup
description: Criar, configurar e implantar Windows Services em Delphi com TService — wizard, estrutura .dpr, tabela de eventos, padrão de thread em OnStart/OnStop, Session 0 Isolation (Vista+), TEventLogger e instalação/desinstalação via sc.exe.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-windows-services-setup

## Versão interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |
| **Criado**      | 2026-04-24 |
| **Família**     | L — Windows Platform |

## Responsabilidade única

Criar, configurar e implantar Windows Services em Delphi usando `TService`. Cobre: wizard (File > New > Other), estrutura do `.dpr` gerado, tabela completa de eventos `TService`, padrão correcto de thread em `OnStart`/`OnStop`, Session 0 Isolation (Vista+) — secção crítica de segurança, `TEventLogger` para Windows Event Log, e instalação/desinstalação via `sc.exe` e auto-instalação no executável.

## When to use

- Criar um novo Windows Service com Delphi.
- Configurar eventos TService (OnStart, OnStop, OnPause, OnResume, etc.).
- Implementar thread de trabalho correcta dentro de um serviço.
- Resolver problemas de Session 0 Isolation (UI não aparece no serviço).
- Instalar ou desinstalar um serviço via `sc.exe`.

## When NOT to use

- Contas de serviço, recovery actions ou debugging → usar `developer-delphi-windows-services-advanced`.
- IPC entre serviço e app desktop (Named Pipes) → usar `developer-delphi-windows-services-advanced`.
- Linux daemons → usar `developer-delphi-to-fpc-linux-daemon`.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-to-fpc-build` | Confirmar toolchain Delphi configurada |

## Referências cruzadas

- `developer-delphi-windows-services-advanced` — contas de serviço, recovery, debugging, Named Pipes IPC

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



## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Chamar `Application.MessageBox` ou criar janelas no OnStart | Session 0 Isolation — janela não aparece para o utilizador | Usar TEventLogger para logs; comunicar via Named Pipes |
| Bloqueio no OnStart sem thread | SCM timeout de 30s — serviço marcado como com falha | Sempre delegar trabalho pesado a TThread; retornar OnStart rapidamente |
| Não encerrar thread em OnStop | Processo fica vivo após `sc stop` | Sinalizar FStopEvent.SetEvent() e aguardar TThread.WaitFor |

## Métricas de sucesso

- Serviço instala, inicia e para sem erros no Event Viewer.
- `sc query MeuServico` mostra `STATE: RUNNING`.
- Nenhum timeout de SCM (30s) durante OnStart.
- Session 0 Isolation verificada (sem chamadas UI directas).

## Changelog (este arquivo)

- 1.0.0 (24/04/2026): Extraído de `developer-delphi-windows-services_V1.0.0` (557L) — seções §1-6 (criação, eventos, thread, Session 0, EventLogger, instalação). Skill original deprecada em favor das 2 skills filhas: `-setup` e `-advanced`.

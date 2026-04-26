# TService — Referência Completa de Eventos

## Tabela de Eventos

| Evento | Assinatura completa | Propósito | Observações críticas |
|--------|--------------------| --------- | -------------------- |
| `OnStart` | `procedure(Sender: TService; var Started: Boolean)` | Inicializar recursos, criar threads. `Started := False` aborta o startup e mantém serviço em estado Stopped. | Chamado pelo SCM quando recebe comando START. Tempo limite: `ServicesPipeTimeout` (default 30s). |
| `OnStop` | `procedure(Sender: TService)` | Terminar threads, fechar conexões, libertar recursos. | Chamado pelo SCM (comando STOP). Timeout default: 30s. Nunca bloquear indefinidamente. |
| `OnExecute` | `procedure(Sender: TService)` | Loop principal alternativo. Bloqueia até o serviço parar. Retorno do método = serviço parado. | Raramente usado. Preferir padrão OnStart + thread worker. Deve chamar `ServiceThread.ProcessRequests` periodicamente. |
| `OnPause` | `procedure(Sender: TService)` | Pausar operação temporariamente (SCM PAUSE). | Serviço deve declarar `CanPause := True` no DFM para SCM aceitar PAUSE. |
| `OnContinue` | `procedure(Sender: TService)` | Retomar após pausa (SCM CONTINUE). | Par obrigatório de OnPause. |
| `OnShutdown` | `procedure(Sender: TService)` | Sistema a desligar (Windows shutdown). Tempo muito limitado. | SCM dá menos tempo que OnStop. Usar para limpeza mínima essencial. |
| `OnInterrogate` | `procedure(Sender: TService)` | SCM consulta estado actual do serviço. | Normalmente não requer implementação — TService responde automaticamente. |
| `OnCustomControl` | `procedure(Sender: TService; Control: DWORD)` | Comandos personalizados (128–255) enviados via `ControlService` Win32 API. | Registar controles suportados em `Controls` property do serviço. |
| `OnBeforeInstall` | `procedure(Sender: TService)` | Executado antes de registar o serviço no SCM. | Útil para validar pré-condições de instalação. |
| `OnAfterInstall` | `procedure(Sender: TService)` | Executado após registar o serviço no SCM. | Bom momento para configurar recovery actions via `ChangeServiceConfig2`. |
| `OnBeforeUninstall` | `procedure(Sender: TService)` | Executado antes de remover o serviço do SCM. | Útil para parar o serviço se ainda em execução. |
| `OnAfterUninstall` | `procedure(Sender: TService)` | Executado após remoção do SCM. | Limpeza de ficheiros, logs, chaves de registo. |

---

## Ordem de chamada dos eventos

### Startup normal
```
OnBeforeInstall (se -install)
  → OnAfterInstall (se -install)

OnStart
  → [Serviço em execução]
  → OnExecute (se implementado — bloqueia)
```

### Paragem normal
```
[Serviço em execução]
  → OnStop
  → [Serviço parado]
```

### Ciclo completo de vida
```
Install     → OnBeforeInstall → OnAfterInstall
Start       → OnStart → (OnExecute) → [RUNNING]
Pause       → OnPause → [PAUSED]
Continue    → OnContinue → [RUNNING]
Stop        → OnStop → [STOPPED]
Shutdown    → OnShutdown → [STOPPED]
Custom      → OnCustomControl(Control: DWORD)
Uninstall   → OnBeforeUninstall → OnAfterUninstall
```

---

## Propriedades importantes de TService

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `Name` | `string` | Nome interno do serviço (sem espaços) |
| `DisplayName` | `string` | Nome exibido no services.msc |
| `ServiceType` | `TServiceType` | `stWin32OwnProcess` (padrão) ou `stWin32ShareProcess` |
| `StartType` | `TStartType` | `stAutomatic`, `stManual`, `stDisabled` |
| `ErrorSeverity` | `TErrorSeverity` | `esIgnore`, `esNormal`, `esSevere`, `esCritical` |
| `CanPause` | `Boolean` | Habilitar suporte a PAUSE/CONTINUE |
| `CanShutdown` | `Boolean` | Receber notificação de shutdown do sistema |
| `CanStop` | `Boolean` | Habilitar suporte a STOP (padrão: True) |
| `Interactive` | `Boolean` | **Depreciado no Vista+** — não usar |
| `Controls` | `set` | Conjunto de controles aceites (`CONTROL_STOP`, etc.) |
| `Terminated` | `Boolean` | True quando SCM enviou STOP — verificar no loop |

---

## Métodos importantes de TService

| Método | Descrição |
|--------|-----------|
| `LogMessage(Msg; EventType; Category; ID)` | Escrever no Windows Event Log |
| `Controller(CtrlCode)` | Processar código de controle do SCM (chamado pelo ServiceController) |
| `ReportStatus` | Reportar estado actual ao SCM (chamado automaticamente) |
| `SetStatus(AStatus)` | Forçar estado manual no SCM |

---

## Assinaturas completas para declaração na classe

```pascal
type
  TGestorERPService = class(TService)
    // Eventos principais
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService);
    procedure ServiceExecute(Sender: TService);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceInterrogate(Sender: TService);
    procedure ServiceCustomControl(Sender: TService; Control: DWORD);
    // Eventos de instalação
    procedure ServiceBeforeInstall(Sender: TService);
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceBeforeUninstall(Sender: TService);
    procedure ServiceAfterUninstall(Sender: TService);
  end;
```

---

## Flags de EventType para LogMessage

| Constante | Valor | Tipo de log | Ícone no Event Viewer |
|-----------|-------|------------|----------------------|
| `EVENTLOG_SUCCESS` | 0 | Sucesso | Verde |
| `EVENTLOG_ERROR_TYPE` | 1 | Erro | Vermelho |
| `EVENTLOG_WARNING_TYPE` | 2 | Aviso | Amarelo |
| `EVENTLOG_INFORMATION_TYPE` | 4 | Informação | Azul |
| `EVENTLOG_AUDIT_SUCCESS` | 8 | Auditoria de sucesso | — |
| `EVENTLOG_AUDIT_FAILURE` | 16 | Auditoria de falha | — |

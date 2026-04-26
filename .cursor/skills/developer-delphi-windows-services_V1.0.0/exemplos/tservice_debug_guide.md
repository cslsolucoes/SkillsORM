# Guia de Debugging — Windows Service Delphi

## Métodos disponíveis

| Método | Complexidade | Permite breakpoints | Produção |
|--------|-------------|--------------------| ---------|
| 1. RunAs Console | Baixa | Sim | Não |
| 2. Attach to Process | Média | Sim | Cuidado |
| 3. OutputDebugString + DebugView | Baixa | Não | Sim |
| 4. Sleep trick no OnStart | Baixa | Sim (com delay) | Não |

---

## Método 1 — RunAs Console (mais simples, apenas desenvolvimento)

Compilar o executável com uma flag condicional que o faz correr como aplicação normal quando não há SCM:

### No `.dpr`:

```pascal
program GestorERPService;

uses
  Vcl.SvcMgr,
  uGestorERPService in 'uGestorERPService.pas' {GestorERPService: TService};

{$R *.res}

begin
  {$IFDEF DEBUG}
  // Em modo Debug sem SCM: correr como console para facilitar debugging
  if not Application.IsService then
  begin
    AllocConsole; // abrir janela de console
    ReportMemoryLeaksOnShutdown := True;
  end;
  {$ENDIF}

  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.Title := 'GestorERP Service';
  Application.CreateForm(TGestorERPService, GestorERPService);
  Application.Run;
end.
```

### Na unit do serviço:

```pascal
procedure TGestorERPService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  {$IFDEF DEBUG}
  if not Application.IsService then
    Writeln('[DEBUG] ServiceStart chamado manualmente');
  {$ENDIF}
  // código normal...
end;
```

### Executar em modo debug:

```batch
:: Compilar com define DEBUG (dcc32/dcc64 inclui DEBUG automaticamente em Debug config)
dcc32 -DDEBUG GestorERPService.dpr

:: Executar directamente (sem SCM)
Win32\Debug\GestorERPService.exe
```

**Vantagens:**
- Breakpoints normais da IDE funcionam.
- `Writeln` para console.
- `ReportMemoryLeaksOnShutdown` detecta leaks.

**Limitações:**
- Não simula perfeitamente o ambiente de serviço (sessão 0, conta LocalService, etc.).

---

## Método 2 — Attach to Process (recomendado para testar o serviço real)

### Passo a passo:

1. **Compilar em Debug:**
   ```
   Project > Options > Build Configuration > Debug
   Run > Build (Ctrl+F9)
   ```

2. **Instalar e iniciar o serviço com o executável Debug:**
   ```batch
   :: Actualizar binPath para apontar para Debug build
   sc config "GestorERPService" binPath= "C:\GestorERP\Win32\Debug\GestorERPService.exe"
   sc start "GestorERPService"
   ```

3. **Attach na IDE:**
   ```
   Run > Attach to Process... (Shift+F9 ou menu Run)
   ```
   - Seleccionar `GestorERPService.exe` na lista.
   - Clicar **Attach**.

4. **Colocar breakpoints** no código — serão activados normalmente quando o código for executado.

5. **Triggerar o código** via SCM, pipe, ou outro mecanismo.

### Problemas comuns:

| Problema | Solução |
|---------|---------|
| Processo não aparece na lista | Correr IDE como Administrador |
| Breakpoints não param | Verificar que o `.exe` em execução é a build Debug (com símbolos) |
| "Cannot attach" | Serviço pode já ter `SeDebugPrivilege` bloqueado pela conta; usar LocalSystem para debug |

---

## Método 3 — OutputDebugString + DebugView

### No código Delphi:

```pascal
uses Winapi.Windows;

// Logar mensagens que o DebugView captura:
OutputDebugString('GestorERPService: iniciando ciclo de processamento');
OutputDebugString(PChar('GestorERPService: registos processados = ' + IntToStr(LCount)));
OutputDebugString(PChar('GestorERPService: ERRO — ' + E.Message));
```

### Configurar DebugView:

1. Descarregar **DebugView** de [Sysinternals / Microsoft](https://docs.microsoft.com/sysinternals/downloads/debugview).
2. Executar como **Administrador** (obrigatório para capturar output de serviços).
3. Activar:
   - **Capture > Capture Win32** (output de processos normais)
   - **Capture > Capture Global Win32** (output de serviços em sessão 0)
4. Iniciar o serviço: `sc start GestorERPService`.
5. Ver mensagens em tempo real no DebugView.

### Filtrar output:

- **Edit > Filter/Highlight** → adicionar filtro `GestorERPService*` para ver apenas mensagens do serviço.

**Vantagens:**
- Funciona em produção sem interrupção.
- Sem necessidade de attach de debugger.
- Captura output de threads em tempo real.

**Limitações:**
- Não permite breakpoints.
- Strings muito longas são truncadas.

---

## Método 4 — Sleep no OnStart (dar tempo ao attach)

Colocar um `Sleep` no início do `OnStart` para ter tempo de fazer attach antes do código principal executar:

```pascal
procedure TGestorERPService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  {$IFDEF DEBUG}
  // Aguardar 20 segundos para attach do debugger
  // Após compilar e iniciar o serviço, attach via Run > Attach to Process
  OutputDebugString('GestorERPService: aguardando attach do debugger (20s)...');
  Sleep(20000);
  OutputDebugString('GestorERPService: continuando inicialização...');
  {$ENDIF}

  // código normal de inicialização...
  FWorkerThread := TWorkerThread.Create(False);
  Started := True;
end;
```

### Workflow:

```batch
:: 1. Compilar em Debug e iniciar o serviço
sc start GestorERPService

:: 2. Imediatamente na IDE: Run > Attach to Process
::    Seleccionar GestorERPService.exe
::    Clicar Attach
::    Colocar breakpoints antes dos 20s acabarem

:: 3. O código principal inicia após o Sleep
::    Breakpoints serão activados normalmente
```

**Vantagens:**
- Simples de implementar.
- Permite debug do próprio `OnStart` e código de inicialização.

**Limitações:**
- Serviço demora a iniciar (timeout do SCM pode ser problema — default 30s).
- Só útil para debugging da inicialização.

**Ajustar timeout do SCM se necessário:**

```batch
:: Aumentar timeout de inicialização do SCM para 120s
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v ServicesPipeTimeout /t REG_DWORD /d 120000 /f
:: Reiniciar o Windows para aplicar
```

---

## Dicas gerais de debugging de serviços

### Verificar logs no Event Viewer

```batch
:: Abrir Event Viewer
eventvwr.msc
```

- Windows Logs > **Application** — logs do serviço (via LogMessage/TEventLogger)
- Windows Logs > **System** — eventos do SCM (falhas de startup, timeouts)

### Verificar estado detalhado do serviço

```batch
:: Estado actual
sc query GestorERPService

:: Configuração completa
sc qc GestorERPService

:: Recovery actions configuradas
sc qfailure GestorERPService
```

### Simular paragem inesperada (para testar recovery)

```batch
:: Matar o processo abruptamente (simula crash)
taskkill /f /im GestorERPService.exe
:: O SCM deve detectar e aplicar recovery actions configuradas
```

### Verificar permissões de conta de serviço

```batch
:: Ver conta actual
sc qc GestorERPService | findstr "SERVICE_START_NAME"

:: Alterar conta para debug mais fácil (LocalSystem tem acesso completo)
sc config GestorERPService obj= LocalSystem
```

> **Atenção:** Não usar `LocalSystem` em produção. Usar apenas para debugging.

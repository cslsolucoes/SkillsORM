---
name: developer-delphi-windows-services-advanced
description: Operação avançada de Windows Services em Delphi — contas de serviço (tabela de decisão), recovery actions (watchdog SCM), debugging por 4 métodos (RunAs Console, Attach, OutputDebugString, Sleep), IPC via Named Pipes entre serviço e app desktop, checklist pré-deploy e fontes CHM Delphi 12.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-windows-services-advanced

## Versão interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |
| **Criado**      | 2026-04-24 |
| **Família**     | L — Windows Platform |

## Responsabilidade única

Operação avançada de Windows Services: selecção de conta de serviço (LocalSystem vs NetworkService vs conta dedicada), configuração de recovery actions via SCM (watchdog automático), debugging por 4 métodos distintos, comunicação IPC entre o serviço (Session 0) e a app desktop do utilizador via Named Pipes, checklist pré-deploy e fontes de referência.

## When to use

- Escolher a conta de serviço correcta (LocalSystem vs NetworkService vs conta AD).
- Configurar recovery actions automáticos (reiniciar serviço após falha).
- Fazer debug de um Windows Service em desenvolvimento.
- Implementar comunicação entre o serviço e uma app desktop via Named Pipes.

## When NOT to use

- Criar o serviço do zero → usar `developer-delphi-windows-services-setup`.
- Linux daemons → usar `developer-delphi-to-fpc-linux-daemon`.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-windows-services-setup` | Serviço deve estar criado e funcional antes de avançar |

## Referências cruzadas

- `developer-delphi-windows-services-setup` — criação TService, eventos, thread, Session 0, instalação
- `developer-delphi-to-fpc-linux-daemon` — equivalente em Linux (fork, signal, systemd)

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


## Métricas de sucesso

- Conta de serviço com privilégios mínimos necessários (princípio do least-privilege).
- Recovery action configurado: reinício automático após falha em < 60s.
- Debugging via Attach to Process funcional sem modificar o executável de produção.
- Named Pipe responde ao cliente desktop em < 100ms.

## Changelog (este arquivo)

- 1.0.0 (24/04/2026): Extraído de `developer-delphi-windows-services_V1.0.0` (557L) — seções §7-11 (contas, recovery, debugging, Named Pipes, checklist) e Fontes de referência. Skill original deprecada em favor das 2 skills filhas: `-setup` e `-advanced`.

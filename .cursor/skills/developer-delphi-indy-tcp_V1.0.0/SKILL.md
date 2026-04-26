---
name: developer-delphi-indy-tcp
description: >
  TCP raw com Indy no Delphi: TIdTCPClient, TIdTCPServer, TIdCmdTCPServer,
  leitura e escrita de bytes/strings/streams, framing de mensagens, heartbeat,
  servidor multi-thread com TIdContext, protocolo texto personalizado e SSL/TLS.
  Ativar quando o usuário mencionar: TIdTCPClient, TIdTCPServer, TCP Delphi,
  socket Delphi, servidor TCP, cliente TCP, protocolo próprio TCP, telnet Delphi,
  conexão socket, TIdContext, TIdCmdTCPServer.
model: sonnet
thinking: none
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-indy-tcp

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Criado** | 2026-04-25 |
| **Família** | Networking / Indy |

## Responsabilidade única

Comunicação TCP de baixo nível com Indy: `TIdTCPClient` para conexão a servidores
TCP arbitrários, `TIdTCPServer` para servidor multi-thread, `TIdCmdTCPServer` para
protocolo baseado em comandos de texto, framing de mensagens, heartbeat e SSL/TLS
sobre TCP.

## When to use

- Conectar a serviços TCP proprietários (equipamentos, PLCs, legados)
- Criar servidor TCP custom multi-thread
- Implementar protocolo de texto linha-a-linha (similar a Telnet/SMTP/FTP)
- Comunicação bidirecional em tempo real com framing de mensagens
- Substituir Named Pipes ou COM por socket local

## When NOT to use

- HTTP/HTTPS → `developer-delphi-indy-http`
- FTP/FTPS → `developer-delphi-indy-ftp`
- E-mail → `developer-delphi-indy-email`
- WebSocket de alto nível → bibliotecas dedicadas (sgcWebSocket, etc.)

---

## §1 — TIdTCPClient — cliente TCP básico

```pascal
uses IdTCPClient, IdGlobal;

// Conectar, enviar string, receber resposta e desconectar
function TClienteTCP.EnviarComando(const AComando: string): string;
var
  LClient: TIdTCPClient;
begin
  LClient := TIdTCPClient.Create(nil);
  try
    LClient.Host            := FHost;
    LClient.Port            := FPorta;
    LClient.ConnectTimeout  := 10000;  // 10 s
    LClient.ReadTimeout     := 30000;  // 30 s

    LClient.Connect;
    try
      // Enviar linha (adiciona CRLF automaticamente)
      LClient.IOHandler.WriteLn(AComando);

      // Ler linha de resposta (bloqueia até CRLF ou ReadTimeout)
      Result := LClient.IOHandler.ReadLn;
    finally
      LClient.Disconnect;
    end;
  finally
    LClient.Free;
  end;
end;

// Ler múltiplas linhas até marcador de fim
function TClienteTCP.EnviarMultiResposta(const AComando: string): TStringList;
var
  LClient: TIdTCPClient;
  LLinha: string;
begin
  Result  := TStringList.Create;
  LClient := TIdTCPClient.Create(nil);
  try
    LClient.Host           := FHost;
    LClient.Port           := FPorta;
    LClient.ConnectTimeout := 10000;
    LClient.ReadTimeout    := 5000;

    LClient.Connect;
    try
      LClient.IOHandler.WriteLn(AComando);

      // Ler até linha "." (convenção de fim, como SMTP)
      repeat
        LLinha := LClient.IOHandler.ReadLn;
        if LLinha <> '.' then
          Result.Add(LLinha);
      until LLinha = '.';
    finally
      LClient.Disconnect;
    end;
  except
    Result.Free;
    raise;
  end;
  LClient.Free;
end;
```

---

## §2 — Envio e recebimento de bytes e streams

```pascal
uses IdTCPClient, IdGlobal, System.Classes;

// Enviar bytes raw
procedure TClienteTCP.EnviarBytes(LClient: TIdTCPClient;
  ABytes: TIdBytes);
begin
  LClient.IOHandler.Write(ABytes);
end;

// Ler N bytes exatos (bloqueia até receber todos)
function TClienteTCP.LerBytes(LClient: TIdTCPClient;
  AQuantidade: Integer): TIdBytes;
begin
  LClient.IOHandler.ReadBytes(Result, AQuantidade, False);
  // False = não append; True = acumular em buffer
end;

// Enviar stream completo
procedure TClienteTCP.EnviarStream(LClient: TIdTCPClient;
  AStream: TStream; AEnviarTamanho: Boolean = True);
begin
  AStream.Position := 0;
  if AEnviarTamanho then
  begin
    // Protocolo: enviar tamanho como Int32 big-endian antes do payload
    var LTamanho := Int32(AStream.Size);
    LClient.IOHandler.Write(LTamanho);
  end;
  LClient.IOHandler.Write(AStream, 0);  // 0 = tamanho completo
end;

// Receber stream (prefixado com tamanho Int32)
procedure TClienteTCP.ReceberStream(LClient: TIdTCPClient;
  AStream: TStream);
var
  LTamanho: Int32;
begin
  // Ler tamanho do payload
  LTamanho := LClient.IOHandler.ReadInt32;

  // Ler payload
  AStream.Size     := 0;
  AStream.Position := 0;
  LClient.IOHandler.ReadStream(AStream, LTamanho, False);
end;

// Enviar objeto JSON serializado
procedure TClienteTCP.EnviarJSON(LClient: TIdTCPClient;
  const AJson: string);
var
  LBytes: TBytes;
begin
  LBytes := TEncoding.UTF8.GetBytes(AJson);
  // Protocolo: tamanho (4 bytes) + payload
  LClient.IOHandler.Write(Int32(Length(LBytes)));
  LClient.IOHandler.Write(TIdBytes(LBytes));
end;
```

---

## §3 — Framing de mensagens (protocolo length-prefix)

```pascal
uses IdTCPClient, IdGlobal;

// Protocolo simples: [2 bytes tamanho][N bytes payload]
// Garante leitura de mensagens completas independente de fragmentação TCP

const
  TAMANHO_HEADER = 2;  // UInt16 = máx 65535 bytes por mensagem

// Enviar mensagem com framing
procedure TClienteTCP.EnviarMensagem(LClient: TIdTCPClient;
  const AMensagem: string);
var
  LPayload: TBytes;
  LHeader: TIdBytes;
begin
  LPayload := TEncoding.UTF8.GetBytes(AMensagem);

  if Length(LPayload) > $FFFF then
    raise EProtocoloException.Create('Mensagem excede 65535 bytes');

  // Header: 2 bytes big-endian com tamanho do payload
  SetLength(LHeader, TAMANHO_HEADER);
  LHeader[0] := (Length(LPayload) shr 8) and $FF;
  LHeader[1] :=  Length(LPayload) and $FF;

  LClient.IOHandler.Write(LHeader);
  LClient.IOHandler.Write(TIdBytes(LPayload));
end;

// Receber mensagem com framing
function TClienteTCP.ReceberMensagem(LClient: TIdTCPClient): string;
var
  LHeader: TIdBytes;
  LPayload: TIdBytes;
  LTamanho: Integer;
begin
  // Ler header
  LClient.IOHandler.ReadBytes(LHeader, TAMANHO_HEADER, False);
  LTamanho := (Integer(LHeader[0]) shl 8) or Integer(LHeader[1]);

  if LTamanho = 0 then
    Exit('');

  // Ler payload completo
  LClient.IOHandler.ReadBytes(LPayload, LTamanho, False);
  Result := TEncoding.UTF8.GetString(TBytes(LPayload));
end;
```

---

## §4 — TIdTCPServer — servidor multi-thread

```pascal
uses IdTCPServer, IdContext, IdCustomTCPServer;

// Servidor TCP que processa cada cliente em thread separada
type
  TServidorTCP = class
  private
    FServer: TIdTCPServer;
    procedure OnExecute(AContext: TIdContext);
    procedure OnConnect(AContext: TIdContext);
    procedure OnDisconnect(AContext: TIdContext);
    procedure OnException(AContext: TIdContext; AException: Exception);
  public
    constructor Create(APorta: Integer);
    destructor Destroy; override;
    function ClientesConectados: Integer;
  end;

constructor TServidorTCP.Create(APorta: Integer);
begin
  FServer := TIdTCPServer.Create(nil);
  FServer.DefaultPort    := APorta;
  FServer.OnExecute      := OnExecute;
  FServer.OnConnect      := OnConnect;
  FServer.OnDisconnect   := OnDisconnect;
  FServer.OnException    := OnException;

  // Thread pool — cada cliente em sua própria thread
  FServer.Active := True;
  Writeln('Servidor TCP ativo na porta ', APorta);
end;

destructor TServidorTCP.Destroy;
begin
  FServer.Active := False;
  FServer.Free;
  inherited;
end;

// Executado em thread dedicada para cada cliente
procedure TServidorTCP.OnExecute(AContext: TIdContext);
var
  LLinha: string;
  LResposta: string;
begin
  // Loop: processar comandos enquanto cliente estiver conectado
  while AContext.Connection.Connected do
  begin
    try
      // Ler linha do cliente (bloqueia até CRLF ou timeout)
      LLinha := AContext.Connection.IOHandler.ReadLn('', 30000);

      if LLinha = '' then Continue;
      if LLinha = 'QUIT' then Break;

      // Processar comando e responder
      LResposta := ProcessarComando(AContext, LLinha);
      AContext.Connection.IOHandler.WriteLn(LResposta);

    except
      on E: EIdConnClosedGracefully do Break;
      on E: EIdReadTimeout do Break;      // cliente silencioso por 30s
      on E: Exception do
      begin
        Writeln('Erro em cliente: ', E.Message);
        Break;
      end;
    end;
  end;
end;

procedure TServidorTCP.OnConnect(AContext: TIdContext);
begin
  var LIP := AContext.Binding.PeerIP;
  Writeln('Cliente conectado: ', LIP);
  AContext.Connection.IOHandler.WriteLn('220 Servidor pronto');
end;

procedure TServidorTCP.OnDisconnect(AContext: TIdContext);
begin
  Writeln('Cliente desconectado: ', AContext.Binding.PeerIP);
end;

procedure TServidorTCP.OnException(AContext: TIdContext;
  AException: Exception);
begin
  if not (AException is EIdConnClosedGracefully) then
    Writeln('Exceção: ', AException.Message);
end;

function TServidorTCP.ClientesConectados: Integer;
begin
  Result := FServer.Contexts.LockList.Count;
  FServer.Contexts.UnlockList;
end;
```

---

## §5 — TIdCmdTCPServer — protocolo baseado em comandos

```pascal
uses IdCmdTCPServer, IdContext, IdCommandHandlers;

// Servidor com dispatch automático de comandos (como SMTP/FTP/POP3)
type
  TServidorComandos = class
  private
    FServer: TIdCmdTCPServer;
    procedure OnGreeting(AContext: TIdContext);
    procedure CmdHelo(ASender: TIdCommand);
    procedure CmdPing(ASender: TIdCommand);
    procedure CmdEcho(ASender: TIdCommand);
    procedure CmdQuit(ASender: TIdCommand);
    procedure CmdDesconhecido(ASender: TIdCommand);
  public
    constructor Create(APorta: Integer);
    destructor Destroy; override;
  end;

constructor TServidorComandos.Create(APorta: Integer);
var
  LCmd: TIdCommandHandler;
begin
  FServer := TIdCmdTCPServer.Create(nil);
  FServer.DefaultPort := APorta;
  FServer.OnConnect   := OnGreeting;

  // Registrar handlers para cada comando
  LCmd := FServer.CommandHandlers.Add;
  LCmd.Command := 'HELO';
  LCmd.OnCommand := CmdHelo;

  LCmd := FServer.CommandHandlers.Add;
  LCmd.Command := 'PING';
  LCmd.OnCommand := CmdPing;

  LCmd := FServer.CommandHandlers.Add;
  LCmd.Command := 'ECHO';
  LCmd.OnCommand := CmdEcho;

  LCmd := FServer.CommandHandlers.Add;
  LCmd.Command := 'QUIT';
  LCmd.OnCommand := CmdQuit;

  // Handler padrão para comandos desconhecidos
  FServer.CommandHandlers.Add.OnCommand := CmdDesconhecido;

  FServer.Active := True;
end;

procedure TServidorComandos.OnGreeting(AContext: TIdContext);
begin
  AContext.Connection.IOHandler.WriteLn(
    '220 ServidorORM v1.0 pronto');
end;

procedure TServidorComandos.CmdHelo(ASender: TIdCommand);
begin
  // Params contém o texto após o comando
  ASender.Reply.SetReply(250,
    'Olá ' + ASender.Params + ', bem-vindo!');
end;

procedure TServidorComandos.CmdPing(ASender: TIdCommand);
begin
  ASender.Reply.SetReply(200, 'PONG');
end;

procedure TServidorComandos.CmdEcho(ASender: TIdCommand);
begin
  ASender.Reply.SetReply(200, ASender.Params);
end;

procedure TServidorComandos.CmdQuit(ASender: TIdCommand);
begin
  ASender.Reply.SetReply(221, 'Até mais!');
  ASender.Context.Connection.Disconnect;
end;

procedure TServidorComandos.CmdDesconhecido(ASender: TIdCommand);
begin
  ASender.Reply.SetReply(500,
    'Comando desconhecido: ' + ASender.CommandHandler.Command);
end;
```

---

## §6 — Heartbeat (keepalive de aplicação)

```pascal
uses IdTCPClient, System.Threading;

// Cliente com heartbeat automático em thread separada
type
  TClienteComHeartbeat = class
  private
    FClient: TIdTCPClient;
    FHeartbeatTask: ITask;
    FAtivo: Boolean;
    FCritica: TCriticalSection;
    procedure EnviarHeartbeat;
  public
    constructor Create(const AHost: string; APorta: Integer);
    destructor Destroy; override;
    procedure Conectar;
    procedure Desconectar;
    function EnviarComando(const ACmd: string): string;
  end;

procedure TClienteComHeartbeat.Conectar;
begin
  FClient.Connect;
  FAtivo := True;

  // Heartbeat a cada 30 segundos
  FHeartbeatTask := TTask.Run(procedure
  begin
    while FAtivo do
    begin
      Sleep(30000);
      if FAtivo then
        EnviarHeartbeat;
    end;
  end);
end;

procedure TClienteComHeartbeat.EnviarHeartbeat;
begin
  FCritica.Enter;
  try
    if FClient.Connected then
    begin
      FClient.IOHandler.WriteLn('PING');
      FClient.IOHandler.ReadLn;  // espera PONG
    end;
  except
    // Conexão perdida — tentar reconectar
    try
      FClient.Disconnect;
      FClient.Connect;
    except
      // Ignorar falha de reconexão — será tentado no próximo ciclo
    end;
  finally
    FCritica.Leave;
  end;
end;

function TClienteComHeartbeat.EnviarComando(const ACmd: string): string;
begin
  FCritica.Enter;
  try
    FClient.IOHandler.WriteLn(ACmd);
    Result := FClient.IOHandler.ReadLn;
  finally
    FCritica.Leave;
  end;
end;
```

---

## §7 — TCP sobre SSL/TLS

```pascal
uses IdTCPClient, IdTCPServer, IdContext, IdSSLOpenSSL;

// Cliente TCP com SSL
procedure TClienteTCP.ConectarSSL;
var
  LClient: TIdTCPClient;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
begin
  LClient := TIdTCPClient.Create(nil);
  LSSL    := TIdSSLIOHandlerSocketOpenSSL.Create(LClient);
  try
    LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
    LSSL.SSLOptions.Mode        := sslmClient;

    LClient.IOHandler      := LSSL;
    LClient.Host           := FHost;
    LClient.Port           := FPorta;  // ex.: 8443
    LClient.ConnectTimeout := 10000;

    LClient.Connect;
    try
      LClient.IOHandler.WriteLn('HELO cliente-seguro');
      Writeln(LClient.IOHandler.ReadLn);
    finally
      LClient.Disconnect;
    end;
  finally
    LClient.Free;
  end;
end;

// Servidor TCP com SSL (TLS server-side)
procedure TServidorTCP.ConfigurarSSL;
var
  LSSL: TIdServerIOHandlerSSLOpenSSL;
begin
  LSSL := TIdServerIOHandlerSSLOpenSSL.Create(FServer);
  LSSL.SSLOptions.CertFile    := 'servidor.crt';
  LSSL.SSLOptions.KeyFile     := 'servidor.key';
  LSSL.SSLOptions.RootCertFile := 'ca.crt';
  LSSL.SSLOptions.SSLVersions  := [sslvTLSv1_2, sslvTLSv1_3];
  LSSL.SSLOptions.Mode         := sslmServer;

  FServer.IOHandler := LSSL;
end;
```

---

## §8 — Broadcast para todos os clientes conectados

```pascal
uses IdTCPServer, IdContext;

// Enviar mensagem para todos os clientes conectados simultaneamente
procedure TServidorTCP.Broadcast(const AMensagem: string);
var
  LLista: TList;
  LContext: TIdContext;
  I: Integer;
begin
  LLista := FServer.Contexts.LockList;
  try
    for I := 0 to LLista.Count - 1 do
    begin
      LContext := TIdContext(LLista[I]);
      try
        if LContext.Connection.Connected then
          LContext.Connection.IOHandler.WriteLn(AMensagem);
      except
        // Ignorar clientes que desconectaram durante o broadcast
      end;
    end;
  finally
    FServer.Contexts.UnlockList;
  end;
end;

// Enviar para cliente específico por IP
procedure TServidorTCP.EnviarParaCliente(const AIP, AMensagem: string);
var
  LLista: TList;
  LContext: TIdContext;
  I: Integer;
begin
  LLista := FServer.Contexts.LockList;
  try
    for I := 0 to LLista.Count - 1 do
    begin
      LContext := TIdContext(LLista[I]);
      if LContext.Binding.PeerIP = AIP then
      begin
        LContext.Connection.IOHandler.WriteLn(AMensagem);
        Break;
      end;
    end;
  finally
    FServer.Contexts.UnlockList;
  end;
end;
```

---

## §9 — Checklist de qualidade — TIdTCPClient / TIdTCPServer

- [ ] `ConnectTimeout` e `ReadTimeout` definidos no cliente (nunca 0)
- [ ] `try/finally` com `Disconnect` separado do `Free`
- [ ] `OnExecute` no servidor com loop protegido por `try/except`
- [ ] Tratar `EIdConnClosedGracefully` separadamente — não é erro
- [ ] `TCriticalSection` ao compartilhar `TIdTCPClient` entre threads
- [ ] Framing de mensagens (length-prefix) para evitar mensagens fragmentadas
- [ ] Heartbeat implementado para detectar conexões mortas
- [ ] `FServer.Contexts.LockList` / `UnlockList` para iterar clientes com segurança
- [ ] DLLs OpenSSL presentes para conexões SSL/TLS
- [ ] Protocolo documentado (formato de frame, comandos, códigos de resposta)

## Referências cruzadas

- `developer-delphi-indy-http` — HTTP sobre TCP (nível mais alto)
- `developer-delphi-indy-ftp` — FTP sobre TCP
- `developer-delphi-indy-email` — SMTP/IMAP/POP3 sobre TCP
- `developer-delphi-crypto-security` — SSL/TLS, certificados

## Changelog (este arquivo)

- 1.0.0 (25/04/2026): E12 — skill criada. Cobre TIdTCPClient, TIdTCPServer multi-thread, TIdCmdTCPServer, framing length-prefix, heartbeat com TTask, SSL/TLS sobre TCP, broadcast para clientes conectados.

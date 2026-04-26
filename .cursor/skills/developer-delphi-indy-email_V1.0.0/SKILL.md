---
name: developer-delphi-indy-email
description: >
  E-mail com Indy no Delphi: TIdSMTP, TIdMessage, TIdAttachment, STARTTLS, SSL/TLS,
  autenticação PLAIN/LOGIN/NTLM, TIdIMAP4, TIdPOP3, anexos, HTML, encodings,
  envio com Gmail/Office365/Hotmail, recebimento e busca de mensagens IMAP.
  Ativar quando o usuário mencionar: enviar e-mail Delphi, TIdSMTP, TIdMessage,
  SMTP Delphi, e-mail Indy, TIdIMAP4, TIdPOP3, anexo e-mail Delphi, STARTTLS Delphi,
  autenticação SMTP, Gmail SMTP Delphi, Office365 SMTP, HTML e-mail Delphi,
  receber e-mail Delphi, IMAP Delphi.
model: sonnet
thinking: none
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-indy-email

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Criado** | 2026-04-24 |
| **Família** | Networking / Indy |

## Responsabilidade única

Enviar e receber e-mails com Indy: SMTP (com STARTTLS), IMAP4 e POP3. Cobre
mensagens HTML, anexos, autenticação e provedores modernos (Gmail, Office365).

## When to use

- Enviar e-mail via SMTP com autenticação e TLS
- Enviar e-mail com corpo HTML e anexos
- Integrar com Gmail, Office365, Hotmail via SMTP
- Verificar e baixar mensagens via IMAP4 ou POP3
- Construir `TIdMessage` com cabeçalhos customizados

## When NOT to use

- Requisições HTTP/REST → `developer-delphi-indy-http`
- Notificações push → APIs externas (Firebase, etc.)

---

## §1 — Envio básico via SMTP

```pascal
uses
  IdSMTP, IdMessage, IdSSLOpenSSL,
  IdText, IdAttachment, IdAttachmentFile,
  IdExplicitTLSClientServerBase;

procedure TEmailServico.Enviar(const APara, AAssunto, ACorpo: string);
var
  LSMTP: TIdSMTP;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
  LMsg: TIdMessage;
begin
  LSMTP := TIdSMTP.Create(nil);
  LSSL  := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  LMsg  := TIdMessage.Create(nil);
  try
    // SSL/TLS
    LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
    LSMTP.IOHandler  := LSSL;
    LSMTP.UseTLS     := utUseExplicitTLS;   // STARTTLS

    // Servidor SMTP
    LSMTP.Host     := FHost;    // ex.: 'smtp.gmail.com'
    LSMTP.Port     := FPorta;   // 587 (STARTTLS) ou 465 (SSL implícito)
    LSMTP.Username := FUsuario;
    LSMTP.Password := FSenha;

    // Mensagem
    LMsg.From.Address := FUsuario;
    LMsg.From.Name    := FNomeRemetente;
    LMsg.Recipients.EMailAddresses := APara;
    LMsg.Subject  := AAssunto;
    LMsg.Body.Text := ACorpo;
    LMsg.Encoding := meMIME;
    LMsg.CharSet  := 'utf-8';

    LSMTP.Connect;
    try
      LSMTP.Authenticate;
      LSMTP.Send(LMsg);
    finally
      LSMTP.Disconnect;
    end;
  finally
    LMsg.Free;
    LSSL.Free;
    LSMTP.Free;
  end;
end;
```

---

## §2 — Configurações por provedor

### Gmail

```pascal
LSMTP.Host   := 'smtp.gmail.com';
LSMTP.Port   := 587;
LSMTP.UseTLS := utUseExplicitTLS;  // STARTTLS
// Obs.: Usar App Password (não a senha normal) — Ativar em conta Google
```

### Office 365 / Microsoft

```pascal
LSMTP.Host   := 'smtp.office365.com';
LSMTP.Port   := 587;
LSMTP.UseTLS := utUseExplicitTLS;
```

### Hotmail / Outlook.com

```pascal
LSMTP.Host   := 'smtp-mail.outlook.com';
LSMTP.Port   := 587;
LSMTP.UseTLS := utUseExplicitTLS;
```

### SSL implícito (porta 465)

```pascal
LSMTP.Port   := 465;
LSMTP.UseTLS := utUseImplicitTLS;
LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
```

---

## §3 — E-mail HTML com anexos

```pascal
uses IdText, IdAttachmentFile, IdMessageParts;

procedure TEmailServico.EnviarComAnexo(
  const APara, AAssunto, ACorpoHTML: string;
  AAnexos: TArray<string>);
var
  LSMTP: TIdSMTP;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
  LMsg: TIdMessage;
  LTexto: TIdText;
  LAnexo: TIdAttachmentFile;
begin
  LSMTP := TIdSMTP.Create(nil);
  LSSL  := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  LMsg  := TIdMessage.Create(nil);
  try
    // SSL
    LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
    LSMTP.IOHandler := LSSL;
    LSMTP.UseTLS    := utUseExplicitTLS;
    LSMTP.Host      := FHost;
    LSMTP.Port      := FPorta;
    LSMTP.Username  := FUsuario;
    LSMTP.Password  := FSenha;

    // Cabeçalho
    LMsg.From.Address := FUsuario;
    LMsg.Recipients.EMailAddresses := APara;
    LMsg.Subject  := AAssunto;
    LMsg.Encoding := meMIME;
    LMsg.CharSet  := 'utf-8';
    LMsg.ContentType := 'multipart/mixed';

    // Parte HTML
    LTexto := TIdText.Create(LMsg.MessageParts, nil);
    LTexto.ContentType := 'text/html';
    LTexto.CharSet     := 'utf-8';
    LTexto.Body.Text   := ACorpoHTML;

    // Anexos
    for var LArquivo in AAnexos do
    begin
      LAnexo := TIdAttachmentFile.Create(LMsg.MessageParts, LArquivo);
      LAnexo.FileName := ExtractFileName(LArquivo);
    end;

    LSMTP.Connect;
    try
      LSMTP.Authenticate;
      LSMTP.Send(LMsg);
    finally
      LSMTP.Disconnect;
    end;
  finally
    LMsg.Free;
    LSSL.Free;
    LSMTP.Free;
  end;
end;
```

---

## §4 — Múltiplos destinatários e CC/BCC

```pascal
procedure TEmailServico.ConfigurarDestinatarios(
  LMsg: TIdMessage;
  APara, ACC, ABCC: TArray<string>);
begin
  // Para (To)
  for var LEmail in APara do
    with LMsg.Recipients.Add do Address := LEmail;

  // Cópia (CC)
  for var LEmail in ACC do
    with LMsg.CCList.Add do Address := LEmail;

  // Cópia oculta (BCC)
  for var LEmail in ABCC do
    with LMsg.BccList.Add do Address := LEmail;
end;
```

---

## §5 — Recebimento via IMAP4

```pascal
uses IdIMAP4, IdSSLOpenSSL;

procedure TEmailServico.VerificarIMAP;
var
  LIMAP: TIdIMAP4;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
  LMsg: TIdMessage;
  LCount, I: Integer;
begin
  LIMAP := TIdIMAP4.Create(nil);
  LSSL  := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
    LIMAP.IOHandler    := LSSL;
    LIMAP.UseTLS       := utUseExplicitTLS;
    LIMAP.Host         := 'imap.gmail.com';
    LIMAP.Port         := 993;
    LIMAP.Username     := FUsuario;
    LIMAP.Password     := FSenha;

    LIMAP.Connect;
    try
      // Selecionar mailbox
      LIMAP.SelectMailBox('INBOX');
      LCount := LIMAP.MailBox.TotalMsgs;

      // Ler últimas 5 mensagens
      for I := Max(1, LCount - 4) to LCount do
      begin
        LMsg := TIdMessage.Create(nil);
        try
          LIMAP.Retrieve(I, LMsg);
          Memo1.Lines.Add(Format('[%d] %s — %s',
            [I, LMsg.Subject, LMsg.From.Address]));
        finally
          LMsg.Free;
        end;
      end;
    finally
      LIMAP.Disconnect;
    end;
  finally
    LSSL.Free;
    LIMAP.Free;
  end;
end;

// Buscar mensagens não lidas
procedure TEmailServico.BuscarNaoLidos;
var
  LIMAP: TIdIMAP4;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
  LMsgNums: TIdMessageNums;
begin
  // ... configurar conexão ...
  LMsgNums := TIdMessageNums.Create;
  try
    LIMAP.SearchMailBox('UNSEEN', LMsgNums);
    Memo1.Lines.Add(Format('%d mensagens não lidas', [LMsgNums.Count]));
  finally
    LMsgNums.Free;
  end;
end;
```

---

## §6 — Recebimento via POP3

```pascal
uses IdPOP3, IdSSLOpenSSL;

procedure TEmailServico.BaixarPOP3;
var
  LPOP3: TIdPOP3;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
  LMsg: TIdMessage;
  LCount, I: Integer;
begin
  LPOP3 := TIdPOP3.Create(nil);
  LSSL  := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
    LPOP3.IOHandler := LSSL;
    LPOP3.UseTLS    := utUseExplicitTLS;
    LPOP3.Host      := 'pop.gmail.com';
    LPOP3.Port      := 995;
    LPOP3.Username  := FUsuario;
    LPOP3.Password  := FSenha;

    LPOP3.Connect;
    try
      LCount := LPOP3.CheckMessages;
      for I := 1 to LCount do
      begin
        LMsg := TIdMessage.Create(nil);
        try
          LPOP3.Retrieve(I, LMsg);
          ProcessarMensagem(LMsg);
          LPOP3.Delete(I);  // marcar para exclusão
        finally
          LMsg.Free;
        end;
      end;
    finally
      LPOP3.Disconnect;  // Delete é efetivado no Disconnect
    end;
  finally
    LSSL.Free;
    LPOP3.Free;
  end;
end;
```

---

## §7 — Checklist de qualidade — E-mail Indy

- [ ] `TIdSSLIOHandlerSocketOpenSSL` com `SSLVersions := [sslvTLSv1_2, sslvTLSv1_3]`
- [ ] `UseTLS := utUseExplicitTLS` (STARTTLS porta 587) ou `utUseImplicitTLS` (SSL porta 465)
- [ ] `LSMTP.Authenticate` chamado explicitamente após `Connect`
- [ ] `LSMTP.Disconnect` no `finally` interno (separado do `Free`)
- [ ] `LMsg.CharSet := 'utf-8'` para caracteres acentuados
- [ ] App Password para Gmail (não senha de conta regular)
- [ ] DLLs OpenSSL no diretório do executável
- [ ] `TIdAttachmentFile` para anexos físicos; `TIdAttachment` para stream em memória

## Referências cruzadas

- `developer-delphi-indy-http` — TIdHTTP, SSL/TLS, DLLs OpenSSL
- `developer-delphi-crypto-security` — Base64, autenticação
- `developer-delphi-reporting-fastreport` — gerar PDF para enviar como anexo

---

## §8 — Decodificar mensagem recebida (subject, body, remetente)

```pascal
uses IdMessage, IdText, IdMessagePart, IdGlobal;

// Extrair informações de TIdMessage já recuperado via IMAP/POP3
procedure TEmailServico.ProcessarMensagem(LMsg: TIdMessage);
var
  LAssunto   : string;
  LRemetente : string;
  LData      : TDateTime;
  LCorpoTexto: string;
  LCorpoHTML : string;
begin
  // Cabeçalho
  LAssunto   := LMsg.Subject;
  LRemetente := LMsg.From.Address;
  LData      := LMsg.Date;

  // Decodificar assunto com encoding (ex.: =?UTF-8?B?...?=)
  // Indy decodifica automaticamente em LMsg.Subject

  // Corpo — verificar partes MIME
  if LMsg.MessageParts.Count = 0 then
  begin
    // Mensagem simples (plain text)
    LCorpoTexto := LMsg.Body.Text;
  end
  else
  begin
    // Mensagem multipart — iterar pelas partes
    for var I := 0 to LMsg.MessageParts.Count - 1 do
    begin
      var LParte := LMsg.MessageParts.Items[I];

      if LParte is TIdText then
      begin
        var LTexto := TIdText(LParte);
        if Pos('text/plain', LTexto.ContentType) > 0 then
          LCorpoTexto := LTexto.Body.Text
        else if Pos('text/html', LTexto.ContentType) > 0 then
          LCorpoHTML := LTexto.Body.Text;
      end;
    end;
  end;

  // Usar HTML se disponível, fallback para texto
  if LCorpoHTML <> '' then
    ExibirHTML(LCorpoHTML)
  else
    ExibirTexto(LCorpoTexto);
end;
```

---

## §9 — Extrair e salvar anexos de mensagem recebida

```pascal
uses IdMessage, IdAttachment, IdAttachmentFile, IdMessagePart;

procedure TEmailServico.ExtrairAnexos(LMsg: TIdMessage;
  const APastaDestino: string);
var
  LParte   : TIdMessagePart;
  LAnexo   : TIdAttachment;
  LCaminho : string;
  I        : Integer;
begin
  for I := 0 to LMsg.MessageParts.Count - 1 do
  begin
    LParte := LMsg.MessageParts.Items[I];

    // Verificar se é anexo (tem ContentDisposition = attachment ou FileName)
    if (LParte is TIdAttachment) then
    begin
      LAnexo := TIdAttachment(LParte);

      if LAnexo.FileName <> '' then
      begin
        LCaminho := IncludeTrailingPathDelimiter(APastaDestino)
                  + ExtractFileName(LAnexo.FileName);

        // Salvar no disco
        LAnexo.SaveToFile(LCaminho);

        // Log
        Writeln('Anexo salvo: ', LCaminho,
                ' (', LAnexo.Size, ' bytes)');
      end;
    end;
  end;
end;

// Versão alternativa — verificar ContentDisposition explicitamente
procedure TEmailServico.ExtrairAnexosCompleto(LMsg: TIdMessage;
  const APastaDestino: string);
var
  LParte: TIdMessagePart;
  I: Integer;
begin
  for I := 0 to LMsg.MessageParts.Count - 1 do
  begin
    LParte := LMsg.MessageParts.Items[I];

    // Anexo inline (imagem embutida no HTML) ou attachment
    if (Pos('attachment', LowerCase(LParte.ContentDisposition)) > 0)
    or (Pos('inline', LowerCase(LParte.ContentDisposition)) > 0) then
    begin
      if (LParte is TIdAttachment) and (LParte.FileName <> '') then
      begin
        var LDestino := IncludeTrailingPathDelimiter(APastaDestino)
                      + ExtractFileName(LParte.FileName);
        TIdAttachment(LParte).SaveToFile(LDestino);
      end;
    end;
  end;
end;
```

---

## §10 — Reply e Forward

```pascal
uses IdMessage, IdMessagePart, IdText, IdReplies;

// Responder a uma mensagem (Reply)
function TEmailServico.CriarReply(LMsgOriginal: TIdMessage;
  const ACorpoResposta: string): TIdMessage;
var
  LReply: TIdMessage;
begin
  LReply := TIdMessage.Create(nil);

  // Cabeçalho do reply
  LReply.From.Address := FUsuario;
  LReply.From.Name    := FNomeRemetente;

  // Responder ao remetente original
  LReply.Recipients.EMailAddresses := LMsgOriginal.From.Address;

  // Subject com Re: (evitar duplicar "Re: Re:")
  if StartsText('Re:', LMsgOriginal.Subject) then
    LReply.Subject := LMsgOriginal.Subject
  else
    LReply.Subject := 'Re: ' + LMsgOriginal.Subject;

  // Headers de threading
  LReply.InReplyTo  := LMsgOriginal.MsgId;
  if LMsgOriginal.References <> '' then
    LReply.References := LMsgOriginal.References + ' ' + LMsgOriginal.MsgId
  else
    LReply.References := LMsgOriginal.MsgId;

  // Corpo: resposta + citação do original
  var LCitacao := '';
  LCitacao := sLineBreak
    + '-----Mensagem original-----' + sLineBreak
    + 'De: '      + LMsgOriginal.From.Address + sLineBreak
    + 'Data: '    + DateTimeToStr(LMsgOriginal.Date) + sLineBreak
    + 'Assunto: ' + LMsgOriginal.Subject + sLineBreak
    + sLineBreak
    + LMsgOriginal.Body.Text;

  LReply.Body.Text := ACorpoResposta + LCitacao;
  LReply.Encoding  := meMIME;
  LReply.CharSet   := 'utf-8';

  Result := LReply;  // caller deve liberar
end;

// Encaminhar uma mensagem (Forward)
function TEmailServico.CriarForward(LMsgOriginal: TIdMessage;
  const APara, AComentario: string): TIdMessage;
var
  LFwd: TIdMessage;
  LTexto: TIdText;
  I: Integer;
begin
  LFwd := TIdMessage.Create(nil);

  LFwd.From.Address := FUsuario;
  LFwd.From.Name    := FNomeRemetente;
  LFwd.Recipients.EMailAddresses := APara;

  // Subject com Fwd:
  if StartsText('Fwd:', LMsgOriginal.Subject) then
    LFwd.Subject := LMsgOriginal.Subject
  else
    LFwd.Subject := 'Fwd: ' + LMsgOriginal.Subject;

  LFwd.Encoding    := meMIME;
  LFwd.CharSet     := 'utf-8';
  LFwd.ContentType := 'multipart/mixed';

  // Parte texto — comentário + cabeçalho da original
  LTexto := TIdText.Create(LFwd.MessageParts, nil);
  LTexto.ContentType := 'text/plain';
  LTexto.CharSet     := 'utf-8';
  LTexto.Body.Text   :=
    AComentario + sLineBreak + sLineBreak
    + '-----Mensagem encaminhada-----' + sLineBreak
    + 'De: '      + LMsgOriginal.From.Address + sLineBreak
    + 'Data: '    + DateTimeToStr(LMsgOriginal.Date) + sLineBreak
    + 'Assunto: ' + LMsgOriginal.Subject + sLineBreak
    + sLineBreak
    + LMsgOriginal.Body.Text;

  // Re-anexar os anexos da mensagem original
  for I := 0 to LMsgOriginal.MessageParts.Count - 1 do
  begin
    if LMsgOriginal.MessageParts.Items[I] is TIdAttachment then
    begin
      var LSrc := TIdAttachment(LMsgOriginal.MessageParts.Items[I]);
      if LSrc.FileName <> '' then
      begin
        // Salvar temporariamente e re-anexar
        var LTmp := TPath.GetTempFileName;
        LSrc.SaveToFile(LTmp);
        var LAnexo := TIdAttachmentFile.Create(LFwd.MessageParts, LTmp);
        LAnexo.FileName := LSrc.FileName;
      end;
    end;
  end;

  Result := LFwd;  // caller deve liberar
end;
```

---

## §11 — Envio em lote com reconexão

```pascal
// Enviar múltiplos e-mails reutilizando conexão SMTP
procedure TEmailServico.EnviarEmLote(AMensagens: TArray<TIdMessage>);
var
  LSMTP: TIdSMTP;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
  LMsg: TIdMessage;
  LErros: TStringList;
begin
  LSMTP  := TIdSMTP.Create(nil);
  LSSL   := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  LErros := TStringList.Create;
  try
    LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
    LSMTP.IOHandler  := LSSL;
    LSMTP.UseTLS     := utUseExplicitTLS;
    LSMTP.Host       := FHost;
    LSMTP.Port       := FPorta;
    LSMTP.Username   := FUsuario;
    LSMTP.Password   := FSenha;

    LSMTP.Connect;
    try
      LSMTP.Authenticate;

      for LMsg in AMensagens do
      begin
        try
          LSMTP.Send(LMsg);
          Sleep(500);  // pausa entre envios — evitar rate limit
        except
          on E: Exception do
          begin
            LErros.Add(Format('Falha [%s]: %s',
              [LMsg.Recipients.EMailAddresses, E.Message]));

            // Tentar reconectar se conexão caiu
            if not LSMTP.Connected then
            begin
              LSMTP.Connect;
              LSMTP.Authenticate;
            end;
          end;
        end;
      end;
    finally
      LSMTP.Disconnect;
    end;

    if LErros.Count > 0 then
      raise EEmailException.CreateFmt(
        '%d envio(s) falharam:%s%s',
        [LErros.Count, sLineBreak, LErros.Text]);
  finally
    LErros.Free;
    LSSL.Free;
    LSMTP.Free;
  end;
end;
```

---

## §12 — Checklist atualizado

- [ ] `TIdSSLIOHandlerSocketOpenSSL` com `SSLVersions := [sslvTLSv1_2, sslvTLSv1_3]`
- [ ] `LSMTP.Authenticate` chamado após `Connect`
- [ ] `LSMTP.Disconnect` no `finally` interno
- [ ] `LMsg.CharSet := 'utf-8'` para acentos
- [ ] App Password para Gmail/Office365
- [ ] DLLs OpenSSL no diretório do executável
- [ ] Partes MIME iteradas para extrair texto + HTML + anexos em mensagens recebidas
- [ ] `InReplyTo` e `References` preenchidos em replies para threading correto
- [ ] Pausa entre envios em lote (`Sleep(500)`) para evitar rate limit
- [ ] Arquivos temporários limpos após forward com re-anexação

## Changelog (este arquivo)

- 1.1.0 (25/04/2026): Adicionados §8 (decodificar mensagem recebida), §9 (extrair e salvar anexos), §10 (reply/forward com threading headers), §11 (envio em lote com reconexão), §12 (checklist atualizado).
- 1.0.0 (24/04/2026): E9 P2 — versão inicial. §1 SMTP, §2 provedores, §3 HTML+anexos, §4 CC/BCC, §5 IMAP4, §6 POP3, §7 checklist.

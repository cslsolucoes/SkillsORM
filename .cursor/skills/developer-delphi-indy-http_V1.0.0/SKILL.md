---
name: developer-delphi-indy-http
description: >
  HTTP/HTTPS com Indy no Delphi: TIdHTTP, GET, POST, PUT, DELETE, headers,
  cookies, redirects, proxies, TLS/SSL com TIdSSLIOHandlerSocketOpenSSL,
  upload de arquivos, autenticação Basic/Bearer, timeout, multipart/form-data.
  Ativar quando o usuário mencionar: TIdHTTP, Indy HTTP, GET Delphi, POST Delphi,
  requisição HTTP Delphi, HTTPS Delphi, TIdSSL, SSL Indy, REST client Indy,
  upload arquivo HTTP, autenticação HTTP, Basic Auth Delphi, Bearer token Delphi,
  timeout HTTP, cookies Indy, proxy HTTP Delphi.
model: sonnet
thinking: none
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-indy-http

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Criado** | 2026-04-24 |
| **Família** | Networking / Indy |

## Responsabilidade única

Executar requisições HTTP e HTTPS com Indy: TIdHTTP, métodos REST (GET/POST/PUT/DELETE),
headers, autenticação, SSL/TLS, upload de arquivos e tratamento de erros.

## When to use

- Fazer GET, POST, PUT, DELETE a APIs REST ou serviços HTTP
- Configurar HTTPS com certificado via TIdSSLIOHandlerSocketOpenSSL
- Enviar formulários multipart e fazer upload de arquivos
- Configurar autenticação Basic ou Bearer token
- Gerenciar cookies, redirects e proxies
- Tratar erros HTTP (4xx, 5xx)

## When NOT to use

- Enviar e-mail → `developer-delphi-indy-email`
- TCP raw → `TIdTCPClient` (documentação Indy)
- REST com TRESTClient (RAD) → skill própria

---

## §1 — GET básico

```pascal
uses IdHTTP, IdSSL, IdSSLOpenSSL;

// GET simples — retorna string da resposta
function THttpServico.Get(const AURL: string): string;
var
  LHttp: TIdHTTP;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
begin
  LHttp := TIdHTTP.Create(nil);
  LSSL  := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
    LHttp.IOHandler    := LSSL;
    LHttp.HandleRedirects := True;
    LHttp.ConnectTimeout  := 10000;  // 10 segundos
    LHttp.ReadTimeout     := 30000;  // 30 segundos

    Result := LHttp.Get(AURL);
  finally
    LSSL.Free;
    LHttp.Free;
  end;
end;

// GET retornando stream (download de arquivo)
procedure THttpServico.Download(const AURL, ADestino: string);
var
  LHttp: TIdHTTP;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
  LStream: TFileStream;
begin
  LHttp   := TIdHTTP.Create(nil);
  LSSL    := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  LStream := TFileStream.Create(ADestino, fmCreate);
  try
    LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
    LHttp.IOHandler := LSSL;
    LHttp.Get(AURL, LStream);
  finally
    LStream.Free;
    LSSL.Free;
    LHttp.Free;
  end;
end;
```

---

## §2 — POST (JSON / form)

```pascal
uses IdHTTP, IdSSLOpenSSL, System.Classes;

// POST com corpo JSON
function THttpServico.PostJSON(const AURL, AJson: string): string;
var
  LHttp: TIdHTTP;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
  LBody: TStringStream;
begin
  LHttp := TIdHTTP.Create(nil);
  LSSL  := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  LBody := TStringStream.Create(AJson, TEncoding.UTF8);
  try
    LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
    LHttp.IOHandler := LSSL;
    LHttp.Request.ContentType := 'application/json';
    LHttp.Request.Accept      := 'application/json';
    LHttp.Request.CharSet     := 'utf-8';

    Result := LHttp.Post(AURL, LBody);
  finally
    LBody.Free;
    LSSL.Free;
    LHttp.Free;
  end;
end;

// POST form-urlencoded
function THttpServico.PostForm(const AURL: string;
  AParams: TStringList): string;
var
  LHttp: TIdHTTP;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
begin
  LHttp := TIdHTTP.Create(nil);
  LSSL  := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
    LHttp.IOHandler := LSSL;
    Result := LHttp.Post(AURL, AParams);
    // AParams: TStringList com 'chave=valor' (Indy faz URL encoding)
  finally
    LSSL.Free;
    LHttp.Free;
  end;
end;
```

---

## §3 — PUT e DELETE

```pascal
// PUT — atualizar recurso
function THttpServico.Put(const AURL, AJson: string): string;
var
  LHttp: TIdHTTP;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
  LBody: TStringStream;
begin
  LHttp := TIdHTTP.Create(nil);
  LSSL  := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  LBody := TStringStream.Create(AJson, TEncoding.UTF8);
  try
    LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
    LHttp.IOHandler := LSSL;
    LHttp.Request.ContentType := 'application/json';
    Result := LHttp.Put(AURL, LBody);
  finally
    LBody.Free;
    LSSL.Free;
    LHttp.Free;
  end;
end;

// DELETE — remover recurso
procedure THttpServico.Delete(const AURL: string);
var
  LHttp: TIdHTTP;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
begin
  LHttp := TIdHTTP.Create(nil);
  LSSL  := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
    LHttp.IOHandler := LSSL;
    LHttp.Delete(AURL);
  finally
    LSSL.Free;
    LHttp.Free;
  end;
end;
```

---

## §4 — Headers customizados e autenticação

```pascal
uses IdHTTP, IdSSLOpenSSL, IdAuthentication;

// Adicionar headers customizados
procedure THttpServico.ConfigurarHeaders(LHttp: TIdHTTP;
  const AToken: string);
begin
  LHttp.Request.CustomHeaders.Clear;
  LHttp.Request.CustomHeaders.Add('Authorization: Bearer ' + AToken);
  LHttp.Request.CustomHeaders.Add('X-API-Key: ' + FApiKey);
  LHttp.Request.CustomHeaders.Add('X-App-Version: 1.0.0');
  LHttp.Request.Accept      := 'application/json';
  LHttp.Request.ContentType := 'application/json';
end;

// Autenticação Basic (username:password em Base64)
procedure THttpServico.ConfigurarBasicAuth(LHttp: TIdHTTP;
  const AUsuario, ASenha: string);
begin
  LHttp.Request.BasicAuthentication := True;
  LHttp.Request.Username := AUsuario;
  LHttp.Request.Password := ASenha;
end;

// Verificar status HTTP da resposta
procedure THttpServico.VerificarResposta(LHttp: TIdHTTP;
  const AContexto: string);
begin
  case LHttp.ResponseCode of
    200, 201, 204: ;  // sucesso
    400: raise EHttpException.CreateFmt('[%s] Bad Request: %s',
           [AContexto, LHttp.ResponseText]);
    401: raise EHttpException.CreateFmt('[%s] Não autorizado', [AContexto]);
    403: raise EHttpException.CreateFmt('[%s] Acesso negado', [AContexto]);
    404: raise EHttpException.CreateFmt('[%s] Recurso não encontrado', [AContexto]);
    500: raise EHttpException.CreateFmt('[%s] Erro interno do servidor', [AContexto]);
  else
    raise EHttpException.CreateFmt('[%s] HTTP %d: %s',
      [AContexto, LHttp.ResponseCode, LHttp.ResponseText]);
  end;
end;
```

---

## §5 — Upload de arquivo (multipart/form-data)

```pascal
uses IdHTTP, IdSSLOpenSSL, IdMultipartFormData;

procedure THttpServico.UploadArquivo(const AURL, ACaminhoArquivo: string);
var
  LHttp: TIdHTTP;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
  LForm: TIdMultiPartFormDataStream;
begin
  LHttp := TIdHTTP.Create(nil);
  LSSL  := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  LForm := TIdMultiPartFormDataStream.Create;
  try
    LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
    LHttp.IOHandler := LSSL;

    // Adicionar campo texto
    LForm.AddFormField('descricao', 'Arquivo de importacao');
    // Adicionar arquivo
    LForm.AddFile('arquivo', ACaminhoArquivo, 'application/octet-stream');

    LHttp.Post(AURL, LForm);
  finally
    LForm.Free;
    LSSL.Free;
    LHttp.Free;
  end;
end;
```

---

## §6 — Proxy e tratamento de erros

```pascal
uses IdHTTP, IdSSLOpenSSL, IdException;

// Configurar proxy
procedure THttpServico.ConfigurarProxy(LHttp: TIdHTTP;
  const AHost: string; APorta: Integer;
  const AUsuario, ASenha: string);
begin
  LHttp.ProxyParams.ProxyServer   := AHost;
  LHttp.ProxyParams.ProxyPort     := APorta;
  LHttp.ProxyParams.ProxyUsername := AUsuario;
  LHttp.ProxyParams.ProxyPassword := ASenha;
end;

// Tratamento completo de erros Indy
function THttpServico.GetSeguro(const AURL: string): string;
var
  LHttp: TIdHTTP;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
begin
  LHttp := TIdHTTP.Create(nil);
  LSSL  := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
    LHttp.IOHandler      := LSSL;
    LHttp.ConnectTimeout := 10000;
    LHttp.ReadTimeout    := 30000;

    try
      Result := LHttp.Get(AURL);
    except
      on E: EIdHTTPProtocolException do
        raise EHttpException.CreateFmt('HTTP %d: %s',
          [E.ErrorCode, E.ErrorMessage]);
      on E: EIdConnectTimeout do
        raise EHttpException.Create('Timeout de conexão');
      on E: EIdReadTimeout do
        raise EHttpException.Create('Timeout de leitura');
      on E: EIdSocketError do
        raise EHttpException.CreateFmt('Erro de socket: %s', [E.Message]);
    end;
  finally
    LSSL.Free;
    LHttp.Free;
  end;
end;
```

---

## §7 — Deployment — DLLs OpenSSL necessárias

```
Para HTTPS com TIdSSLIOHandlerSocketOpenSSL, copiar para a pasta do executável:

Win32:
  libssl-3.dll    (ou libeay32.dll + ssleay32.dll para OpenSSL 1.x)
  libcrypto-3.dll

Win64:
  libssl-3-x64.dll
  libcrypto-3-x64.dll

Fonte: https://wiki.overbyte.eu/wiki/index.php/ICS_Download#Download_OpenSSL_Binaries
       ou do pacote Indy incluído no RAD Studio
```

---

## §8 — Checklist de qualidade — TIdHTTP

- [ ] `TIdSSLIOHandlerSocketOpenSSL` configurado para HTTPS com `sslvTLSv1_2` ou `sslvTLSv1_3`
- [ ] `ConnectTimeout` e `ReadTimeout` definidos (nunca deixar em 0)
- [ ] `try/finally` para liberar `TIdHTTP`, `LSSL` e streams
- [ ] Status HTTP verificado após cada requisição
- [ ] DLLs OpenSSL incluídas no instalador
- [ ] Credenciais não hardcoded — ler de configuração externa
- [ ] `HandleRedirects := True` para APIs com redirect 301/302

## Referências cruzadas

- `developer-delphi-indy-email` — SMTP via Indy
- `developer-delphi-json-serialization` — parsear resposta JSON
- `developer-delphi-crypto-security` — HMAC, Base64 para auth

---

## §9 — PATCH e HEAD

```pascal
// PATCH — atualização parcial de recurso
function THttpServico.Patch(const AURL, AJson: string): string;
var
  LHttp: TIdHTTP;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
  LBody: TStringStream;
begin
  LHttp := TIdHTTP.Create(nil);
  LSSL  := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  LBody := TStringStream.Create(AJson, TEncoding.UTF8);
  try
    LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
    LHttp.IOHandler := LSSL;
    LHttp.Request.ContentType := 'application/json';
    // Indy não tem método Patch nativo — usar Request
    LHttp.Request.Method := 'PATCH';
    Result := LHttp.Post(AURL, LBody);
  finally
    LBody.Free;
    LSSL.Free;
    LHttp.Free;
  end;
end;

// HEAD — verificar existência/metadata sem baixar corpo
procedure THttpServico.Head(const AURL: string;
  out AStatusCode: Integer; out AContentLength: Int64);
var
  LHttp: TIdHTTP;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
begin
  LHttp := TIdHTTP.Create(nil);
  LSSL  := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
    LHttp.IOHandler := LSSL;
    LHttp.Head(AURL);
    AStatusCode    := LHttp.ResponseCode;
    AContentLength := LHttp.Response.ContentLength;
  finally
    LSSL.Free;
    LHttp.Free;
  end;
end;
```

---

## §10 — Progress events (barra de progresso)

```pascal
uses IdHTTP, IdSSLOpenSSL, IdComponent;

// Evento OnWork — chamado durante transferência
procedure TFormDownload.Download(const AURL, ADestino: string);
var
  LHttp: TIdHTTP;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
  LStream: TFileStream;
begin
  LHttp   := TIdHTTP.Create(nil);
  LSSL    := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  LStream := TFileStream.Create(ADestino, fmCreate);
  try
    LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
    LHttp.IOHandler := LSSL;

    // Registrar eventos de progresso
    LHttp.OnWorkBegin := OnDownloadBegin;
    LHttp.OnWork      := OnDownloadWork;
    LHttp.OnWorkEnd   := OnDownloadEnd;

    LHttp.Get(AURL, LStream);
  finally
    LStream.Free;
    LSSL.Free;
    LHttp.Free;
  end;
end;

procedure TFormDownload.OnDownloadBegin(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  TThread.Synchronize(nil, procedure
  begin
    ProgressBar.Max      := AWorkCountMax;
    ProgressBar.Position := 0;
    LabelStatus.Caption  := 'Iniciando download...';
  end);
end;

procedure TFormDownload.OnDownloadWork(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  TThread.Synchronize(nil, procedure
  begin
    if ProgressBar.Max > 0 then
      ProgressBar.Position := AWorkCount;
    LabelStatus.Caption := Format('%.1f KB baixados',
      [AWorkCount / 1024]);
  end);
end;

procedure TFormDownload.OnDownloadEnd(ASender: TObject;
  AWorkMode: TWorkMode);
begin
  TThread.Synchronize(nil, procedure
  begin
    ProgressBar.Position := ProgressBar.Max;
    LabelStatus.Caption  := 'Download concluído!';
  end);
end;
```

---

## §11 — Leitura de response headers e cookies

```pascal
// Ler headers da resposta após requisição
function THttpServico.GetComHeaders(const AURL: string;
  out AHeaders: TStringList): string;
var
  LHttp: TIdHTTP;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
  I: Integer;
begin
  LHttp := TIdHTTP.Create(nil);
  LSSL  := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  AHeaders := TStringList.Create;
  try
    LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
    LHttp.IOHandler := LSSL;
    Result := LHttp.Get(AURL);

    // Headers da resposta
    for I := 0 to LHttp.Response.RawHeaders.Count - 1 do
      AHeaders.Add(LHttp.Response.RawHeaders[I]);

    // Headers específicos
    var LContentType  := LHttp.Response.ContentType;
    var LServer       := LHttp.Response.Server;
    var LLocation     := LHttp.Response.Location;  // para redirects
    var LETAG         := LHttp.Response.ETag;
    var LLastModified := LHttp.Response.LastModified;
  except
    AHeaders.Free;
    raise;
  end;
end;

// Gerenciar cookies entre requisições (mesma instância TIdHTTP)
function THttpServico.GetComCookies(const AURL1, AURL2: string): string;
var
  LHttp: TIdHTTP;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
  LCookies: TIdCookieManager;
begin
  LHttp    := TIdHTTP.Create(nil);
  LSSL     := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  LCookies := TIdCookieManager.Create(LHttp);
  try
    LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
    LHttp.IOHandler      := LSSL;
    LHttp.CookieManager  := LCookies;  // mantém cookies entre chamadas
    LHttp.HandleRedirects := True;

    LHttp.Get(AURL1);  // login — recebe Set-Cookie
    Result := LHttp.Get(AURL2);  // dashboard — envia Cookie automaticamente

    // Inspecionar cookies
    for var LCookie in LCookies.CookieCollection do
      Writeln(LCookie.CookieName, '=', LCookie.Value,
              ' domain=', LCookie.Domain);
  finally
    LSSL.Free;
    LHttp.Free;
  end;
end;

// Adicionar cookie manual no request
procedure THttpServico.AddCookieManual(LHttp: TIdHTTP;
  const ANome, AValor, ADominio: string);
var
  LCookie: TIdCookie;
begin
  LCookie        := LHttp.CookieManager.CookieCollection.Add;
  LCookie.CookieName := ANome;
  LCookie.Value  := AValor;
  LCookie.Domain := ADominio;
  LCookie.Path   := '/';
end;
```

---

## §12 — Download assíncrono com TThread

```pascal
uses IdHTTP, IdSSLOpenSSL, System.Threading;

// Download em thread separada — não bloqueia a UI
procedure TFormPrincipal.BtnDownloadClick(Sender: TObject);
begin
  BtnDownload.Enabled := False;

  TTask.Run(procedure
  var
    LHttp: TIdHTTP;
    LSSL: TIdSSLIOHandlerSocketOpenSSL;
    LStream: TMemoryStream;
    LConteudo: string;
  begin
    LHttp   := TIdHTTP.Create(nil);
    LSSL    := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    LStream := TMemoryStream.Create;
    try
      LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
      LHttp.IOHandler := LSSL;

      LHttp.Get('https://api.exemplo.com/dados', LStream);
      LStream.Position := 0;
      LConteudo := TEncoding.UTF8.GetString(
        LStream.Memory, 0, LStream.Size);

      // Atualizar UI na thread principal
      TThread.Synchronize(nil, procedure
      begin
        MemoResultado.Text  := LConteudo;
        BtnDownload.Enabled := True;
        LabelStatus.Caption := 'Concluído!';
      end);
    except
      on E: Exception do
        TThread.Synchronize(nil, procedure
        begin
          ShowMessage('Erro: ' + E.Message);
          BtnDownload.Enabled := True;
        end);
    end;
    LStream.Free;
    LSSL.Free;
    LHttp.Free;
  end);
end;
```

---

## §13 — TIdHTTPServer — servidor HTTP local

```pascal
uses IdHTTPServer, IdContext, IdCustomHTTPServer, IdSSLOpenSSL;

// Servidor HTTP local — útil para callbacks OAuth, webhooks locais
type
  TServidorLocal = class
  private
    FServer: TIdHTTPServer;
    procedure OnRequest(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
  public
    constructor Create(APorta: Integer);
    destructor Destroy; override;
  end;

constructor TServidorLocal.Create(APorta: Integer);
begin
  FServer := TIdHTTPServer.Create(nil);
  FServer.DefaultPort := APorta;
  FServer.OnCommandGet  := OnRequest;
  FServer.OnCommandPost := OnRequest;
  FServer.Active := True;
end;

destructor TServidorLocal.Destroy;
begin
  FServer.Active := False;
  FServer.Free;
  inherited;
end;

procedure TServidorLocal.OnRequest(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo;
  AResponseInfo: TIdHTTPResponseInfo);
var
  LPath: string;
  LCorpo: string;
begin
  LPath := ARequestInfo.Document;

  // Roteamento básico
  if LPath = '/health' then
  begin
    AResponseInfo.ContentType := 'application/json';
    AResponseInfo.ContentText := '{"status":"ok"}';
    AResponseInfo.ResponseNo  := 200;
  end
  else if LPath = '/callback' then
  begin
    // Ex.: OAuth callback — ler parâmetros da query string
    var LCode := ARequestInfo.Params.Values['code'];
    var LState := ARequestInfo.Params.Values['state'];
    ProcessarOAuthCallback(LCode, LState);

    AResponseInfo.ContentType := 'text/html';
    AResponseInfo.ContentText :=
      '<html><body>Autenticado! Pode fechar esta aba.</body></html>';
    AResponseInfo.ResponseNo  := 200;
  end
  else if (ARequestInfo.CommandType = hcPOST) and (LPath = '/webhook') then
  begin
    // Ler body do POST
    LCorpo := ARequestInfo.PostStream.ReadString(
      ARequestInfo.PostStream.Size);
    ProcessarWebhook(LCorpo);
    AResponseInfo.ResponseNo := 204;  // No Content
  end
  else
  begin
    AResponseInfo.ResponseNo  := 404;
    AResponseInfo.ContentText := 'Not Found';
  end;
end;
```

---

## §14 — Checklist atualizado

- [ ] `TIdSSLIOHandlerSocketOpenSSL` com `SSLVersions := [sslvTLSv1_2, sslvTLSv1_3]`
- [ ] `ConnectTimeout` e `ReadTimeout` definidos (nunca 0)
- [ ] `try/finally` para liberar `TIdHTTP`, `LSSL` e streams
- [ ] Status HTTP verificado após cada requisição
- [ ] PATCH implementado via `LHttp.Request.Method := 'PATCH'` + Post
- [ ] Progress events em downloads pesados (OnWork/OnWorkBegin/OnWorkEnd)
- [ ] `TIdCookieManager` reutilizado na mesma instância para sessão
- [ ] Downloads pesados em `TTask.Run` ou `TThread` — nunca na VCL thread
- [ ] DLLs OpenSSL incluídas no instalador
- [ ] Credenciais em configuração externa, nunca hardcoded

## Changelog (este arquivo)

- 1.1.0 (24/04/2026): Adicionados §9 (PATCH/HEAD), §10 (progress events), §11 (response headers e cookies), §12 (download assíncrono TTask), §13 (TIdHTTPServer — servidor local), §14 (checklist atualizado).
- 1.0.0 (24/04/2026): E9 P2 — versão inicial. §1 GET, §2 POST, §3 PUT/DELETE, §4 headers/auth, §5 upload multipart, §6 proxy/erros, §7 DLLs OpenSSL.

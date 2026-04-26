---
name: developer-delphi-indy-ftp
description: >
  FTP e FTPS com Indy no Delphi: TIdFTP, upload, download, listagem de diretório,
  criação e remoção de pastas, renomeação, transferência binária e ASCII, modo passivo,
  FTPS (FTP over SSL/TLS explícito e implícito), autenticação, barra de progresso.
  Ativar quando o usuário mencionar: TIdFTP, FTP Delphi, upload FTP, download FTP,
  FTPS Delphi, listagem FTP, diretório FTP, transferência FTP, modo passivo FTP.
model: sonnet
thinking: none
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-indy-ftp

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Criado** | 2026-04-25 |
| **Família** | Networking / Indy |

## Responsabilidade única

Upload, download e gerenciamento de arquivos/diretórios via FTP e FTPS usando
`TIdFTP`. Cobre modo passivo, transferência binária/ASCII, progresso de transferência,
FTPS explícito (porta 21 + STARTTLS) e implícito (porta 990 + SSL direto).

## When to use

- Upload de arquivos para servidor FTP/FTPS
- Download de arquivos remotos via FTP
- Listar, criar, remover e renomear arquivos/diretórios no servidor
- Integrar com sistemas legados que expõem FTP
- Transferir arquivos com barra de progresso

## When NOT to use

- HTTP/HTTPS → `developer-delphi-indy-http`
- SFTP (SSH File Transfer Protocol) — não é FTP — usar componentes específicos (SecureBlackBox, MidaSocket)
- E-mail → `developer-delphi-indy-email`

---

## §1 — Conexão e autenticação básica

```pascal
uses IdFTP, IdSSLOpenSSL;

// Conexão FTP simples (sem SSL)
procedure TFtpServico.Conectar;
begin
  FFTP := TIdFTP.Create(nil);
  FFTP.Host     := FHost;      // ex.: 'ftp.empresa.com.br'
  FFTP.Port     := 21;
  FFTP.Username := FUsuario;
  FFTP.Password := FSenha;
  FFTP.Passive  := True;       // modo passivo — necessário atrás de NAT/firewall
  FFTP.TransferType := ftBinary;  // binário por padrão; ftASCII para texto

  FFTP.Connect;
  // Após Connect: FTP já está autenticado
end;

procedure TFtpServico.Desconectar;
begin
  if Assigned(FFTP) and FFTP.Connected then
    FFTP.Disconnect;
  FreeAndNil(FFTP);
end;

// Uso completo com try/finally
procedure TFtpServico.ExecutarOperacao;
var
  LFTP: TIdFTP;
begin
  LFTP := TIdFTP.Create(nil);
  try
    LFTP.Host          := FHost;
    LFTP.Port          := 21;
    LFTP.Username      := FUsuario;
    LFTP.Password      := FSenha;
    LFTP.Passive       := True;
    LFTP.TransferType  := ftBinary;
    LFTP.ConnectTimeout := 15000;

    LFTP.Connect;
    try
      // operações aqui
    finally
      LFTP.Disconnect;
    end;
  finally
    LFTP.Free;
  end;
end;
```

---

## §2 — FTPS (FTP sobre SSL/TLS)

```pascal
uses IdFTP, IdSSLOpenSSL, IdExplicitTLSClientServerBase;

// FTPS Explícito — porta 21, STARTTLS (AUTH TLS)
procedure TFtpServico.ConectarFTPSExplicito;
var
  LFTP: TIdFTP;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
begin
  LFTP := TIdFTP.Create(nil);
  LSSL := TIdSSLIOHandlerSocketOpenSSL.Create(LFTP);
  try
    LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];
    LSSL.SSLOptions.Mode        := sslmClient;

    LFTP.IOHandler  := LSSL;
    LFTP.UseTLS     := utUseExplicitTLS;   // AUTH TLS após conexão
    LFTP.Host       := FHost;
    LFTP.Port       := 21;
    LFTP.Username   := FUsuario;
    LFTP.Password   := FSenha;
    LFTP.Passive    := True;
    LFTP.TransferType := ftBinary;

    LFTP.Connect;
    try
      // operações
    finally
      LFTP.Disconnect;
    end;
  finally
    LFTP.Free;
  end;
end;

// FTPS Implícito — porta 990, SSL desde o início
procedure TFtpServico.ConectarFTPSImplicito;
var
  LFTP: TIdFTP;
  LSSL: TIdSSLIOHandlerSocketOpenSSL;
begin
  LFTP := TIdFTP.Create(nil);
  LSSL := TIdSSLIOHandlerSocketOpenSSL.Create(LFTP);
  try
    LSSL.SSLOptions.SSLVersions := [sslvTLSv1_2, sslvTLSv1_3];

    LFTP.IOHandler  := LSSL;
    LFTP.UseTLS     := utUseImplicitTLS;   // SSL imediato
    LFTP.Host       := FHost;
    LFTP.Port       := 990;                // porta padrão FTPS implícito
    LFTP.Username   := FUsuario;
    LFTP.Password   := FSenha;
    LFTP.Passive    := True;

    LFTP.Connect;
    try
      // operações
    finally
      LFTP.Disconnect;
    end;
  finally
    LFTP.Free;
  end;
end;
```

---

## §3 — Upload de arquivos

```pascal
// Upload de arquivo local para servidor FTP
procedure TFtpServico.Upload(LFTP: TIdFTP;
  const AArquivoLocal, ACaminhoRemoto: string);
begin
  // Navegar para diretório remoto
  var LDir  := ExtractFilePath(ACaminhoRemoto);
  var LNome := ExtractFileName(ACaminhoRemoto);

  if LDir <> '' then
    LFTP.ChangeDir(LDir);

  // Fazer upload
  LFTP.Put(AArquivoLocal, LNome, False);
  // 3º parâmetro False = sobrescrever se existir
end;

// Upload com stream (conteúdo em memória)
procedure TFtpServico.UploadStream(LFTP: TIdFTP;
  AStream: TStream; const ANomeRemoto: string);
begin
  AStream.Position := 0;
  LFTP.Put(AStream, ANomeRemoto, False);
end;

// Upload de múltiplos arquivos de uma pasta
procedure TFtpServico.UploadPasta(LFTP: TIdFTP;
  const APastaLocal, ADiretorioRemoto: string;
  const AFiltro: string = '*.*');
var
  LArquivos: TStringDynArray;
  LArquivo: string;
begin
  LFTP.ChangeDir(ADiretorioRemoto);
  LArquivos := TDirectory.GetFiles(APastaLocal, AFiltro);

  for LArquivo in LArquivos do
  begin
    Writeln('Enviando: ', ExtractFileName(LArquivo));
    LFTP.Put(LArquivo, ExtractFileName(LArquivo), False);
  end;
end;
```

---

## §4 — Download de arquivos

```pascal
// Download de arquivo remoto para local
procedure TFtpServico.Download(LFTP: TIdFTP;
  const ACaminhoRemoto, ADestinoLocal: string);
begin
  LFTP.Get(ACaminhoRemoto, ADestinoLocal, False, False);
  // 3º parâmetro: False = não retomar (resume); 4º: False = sobrescrever
end;

// Download para stream (em memória — não toca o disco)
procedure TFtpServico.DownloadStream(LFTP: TIdFTP;
  const ACaminhoRemoto: string; AStream: TStream);
begin
  AStream.Size     := 0;
  AStream.Position := 0;
  LFTP.Get(ACaminhoRemoto, AStream);
end;

// Download com retomada (resume) — arquivo parcialmente baixado
procedure TFtpServico.DownloadComResume(LFTP: TIdFTP;
  const ACaminhoRemoto, ADestinoLocal: string);
var
  LResume: Boolean;
begin
  // True = retomar de onde parou se o arquivo parcial existir
  LResume := TFile.Exists(ADestinoLocal);
  LFTP.Get(ACaminhoRemoto, ADestinoLocal, True, LResume);
end;
```

---

## §5 — Listagem de diretório

```pascal
uses IdFTP, IdFTPList;

// Listar arquivos e subdiretórios
procedure TFtpServico.Listar(LFTP: TIdFTP;
  const ADiretorio: string; ALista: TStrings);
var
  LFTPList: TIdFTPListItems;
  I: Integer;
begin
  if ADiretorio <> '' then
    LFTP.ChangeDir(ADiretorio);

  LFTPList := TIdFTPListItems.Create;
  try
    LFTP.List(LFTPList);

    for I := 0 to LFTPList.Count - 1 do
    begin
      var LItem := LFTPList[I];
      if LItem.ItemType = ditDirectory then
        ALista.Add('[DIR] ' + LItem.FileName)
      else
        ALista.Add(Format('%-40s %12d bytes  %s',
          [LItem.FileName,
           LItem.Size,
           DateTimeToStr(LItem.ModifiedDate)]));
    end;
  finally
    LFTPList.Free;
  end;
end;

// Obter lista filtrada de arquivos (sem subdiretórios)
function TFtpServico.ListarArquivos(LFTP: TIdFTP;
  const ADiretorio, AFiltro: string): TArray<string>;
var
  LFTPList: TIdFTPListItems;
  LNomes: TStringList;
  I: Integer;
begin
  LFTP.ChangeDir(ADiretorio);
  LFTPList := TIdFTPListItems.Create;
  LNomes   := TStringList.Create;
  try
    LFTP.List(LFTPList, AFiltro);  // ex.: AFiltro = '*.xml'

    for I := 0 to LFTPList.Count - 1 do
      if LFTPList[I].ItemType = ditFile then
        LNomes.Add(LFTPList[I].FileName);

    Result := LNomes.ToStringArray;
  finally
    LFTPList.Free;
    LNomes.Free;
  end;
end;
```

---

## §6 — Operações em diretórios e arquivos

```pascal
// Criar diretório remoto (com verificação de existência)
procedure TFtpServico.CriarDiretorio(LFTP: TIdFTP;
  const ADiretorio: string);
begin
  try
    LFTP.MakeDir(ADiretorio);
  except
    on E: EIdFTPReplyError do
    begin
      // Código 550 = diretório já existe — ignorar
      if E.ReplyCode <> 550 then
        raise;
    end;
  end;
end;

// Criar estrutura de diretórios recursivamente
procedure TFtpServico.CriarDiretorioRecursivo(LFTP: TIdFTP;
  const ACaminho: string);
var
  LPartes: TArray<string>;
  LAtual: string;
  I: Integer;
begin
  LPartes := ACaminho.Split(['/']);
  LAtual  := '';

  for I := 0 to High(LPartes) do
  begin
    if LPartes[I] = '' then Continue;
    LAtual := LAtual + '/' + LPartes[I];
    CriarDiretorio(LFTP, LAtual);
  end;
end;

// Remover arquivo remoto
procedure TFtpServico.RemoverArquivo(LFTP: TIdFTP;
  const ACaminhoRemoto: string);
begin
  LFTP.Delete(ACaminhoRemoto);
end;

// Remover diretório remoto (deve estar vazio)
procedure TFtpServico.RemoverDiretorio(LFTP: TIdFTP;
  const ADiretorio: string);
begin
  LFTP.RemoveDir(ADiretorio);
end;

// Renomear / mover arquivo remoto
procedure TFtpServico.Renomear(LFTP: TIdFTP;
  const ANomeAtual, NomeNovo: string);
begin
  LFTP.Rename(ANomeAtual, NomeNovo);
end;

// Verificar existência de arquivo remoto
function TFtpServico.ArquivoExiste(LFTP: TIdFTP;
  const ACaminhoRemoto: string): Boolean;
begin
  try
    LFTP.Size(ACaminhoRemoto);  // gera exceção se não existir
    Result := True;
  except
    Result := False;
  end;
end;

// Obter tamanho e data de modificação
procedure TFtpServico.InfoArquivo(LFTP: TIdFTP;
  const ACaminhoRemoto: string;
  out ATamanho: Int64; out ADataModificacao: TDateTime);
begin
  ATamanho := LFTP.Size(ACaminhoRemoto);
  ADataModificacao := LFTP.GetFileDate(ACaminhoRemoto);
end;
```

---

## §7 — Progress events (barra de progresso)

```pascal
uses IdFTP, IdComponent;

// Configurar eventos antes de Connect
procedure TFormFTP.ConfigurarEventos(LFTP: TIdFTP);
begin
  LFTP.OnWorkBegin := OnTransferenciaInicio;
  LFTP.OnWork      := OnTransferenciaProgresso;
  LFTP.OnWorkEnd   := OnTransferenciaFim;
end;

procedure TFormFTP.OnTransferenciaInicio(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  TThread.Synchronize(nil, procedure
  begin
    ProgressBar.Max      := AWorkCountMax;
    ProgressBar.Position := 0;
    LabelStatus.Caption  := 'Transferindo...';
  end);
end;

procedure TFormFTP.OnTransferenciaProgresso(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  TThread.Synchronize(nil, procedure
  begin
    if ProgressBar.Max > 0 then
      ProgressBar.Position := AWorkCount;
    LabelStatus.Caption := Format('%.1f / %.1f KB',
      [AWorkCount / 1024, ProgressBar.Max / 1024]);
  end);
end;

procedure TFormFTP.OnTransferenciaFim(ASender: TObject;
  AWorkMode: TWorkMode);
begin
  TThread.Synchronize(nil, procedure
  begin
    ProgressBar.Position := ProgressBar.Max;
    LabelStatus.Caption  := 'Concluído!';
  end);
end;
```

---

## §8 — Sincronização de pasta local → remota

```pascal
// Sincronizar pasta local com diretório FTP (upload incremental)
procedure TFtpServico.Sincronizar(LFTP: TIdFTP;
  const APastaLocal, ADiretorioRemoto: string);
var
  LArquivosLocais: TStringDynArray;
  LArquivoLocal: string;
  LNomeRemoto: string;
  LTamanhoLocal: Int64;
  LTamanhoRemoto: Int64;
begin
  LFTP.ChangeDir(ADiretorioRemoto);
  LArquivosLocais := TDirectory.GetFiles(APastaLocal, '*.*',
    TSearchOption.soTopDirectoryOnly);

  for LArquivoLocal in LArquivosLocais do
  begin
    LNomeRemoto   := ExtractFileName(LArquivoLocal);
    LTamanhoLocal := TFile.GetSize(LArquivoLocal);

    try
      LTamanhoRemoto := LFTP.Size(LNomeRemoto);
    except
      LTamanhoRemoto := -1;  // arquivo não existe no servidor
    end;

    // Enviar se não existe ou se tamanho diferente
    if LTamanhoRemoto <> LTamanhoLocal then
    begin
      Writeln('Enviando: ', LNomeRemoto);
      LFTP.Put(LArquivoLocal, LNomeRemoto, False);
    end
    else
      Writeln('Já sincronizado: ', LNomeRemoto);
  end;
end;
```

---

## §9 — Checklist de qualidade — TIdFTP

- [ ] `Passive := True` — obrigatório atrás de NAT/firewall
- [ ] `TransferType := ftBinary` — padrão seguro; ftASCII só para arquivos de texto puro
- [ ] `ConnectTimeout` definido (evitar bloqueio indefinido)
- [ ] `try/finally` com `Disconnect` e `Free` separados
- [ ] FTPS: `TIdSSLIOHandlerSocketOpenSSL` com `sslvTLSv1_2` ou `sslvTLSv1_3`
- [ ] DLLs OpenSSL presentes para FTPS
- [ ] Credenciais em configuração externa (não hardcoded)
- [ ] Progress events em threads — atualizar UI com `TThread.Synchronize`
- [ ] Tratar `EIdFTPReplyError` separadamente de exceções gerais
- [ ] Verificar existência antes de deletar ou renomear

## Referências cruzadas

- `developer-delphi-indy-http` — TIdHTTP, SSL/TLS, DLLs OpenSSL
- `developer-delphi-indy-tcp` — TCP raw client/server
- `developer-delphi-crypto-security` — hash de arquivos para verificação de integridade

## Changelog (este arquivo)

- 1.0.0 (25/04/2026): E12 — skill criada. Cobre TIdFTP: autenticação, FTPS explícito/implícito, upload/download, listagem, operações em diretórios, renomear, sincronização incremental, progress events.

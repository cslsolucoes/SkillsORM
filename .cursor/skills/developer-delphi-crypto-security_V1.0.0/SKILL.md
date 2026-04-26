---
name: developer-delphi-crypto-security
description: >
  Criptografia e segurança em Delphi: System.Hash (MD5, SHA1, SHA256, SHA512),
  System.NetEncoding (Base64, URL encoding), HMAC, AES via IdCoder* (Indy),
  hash de senhas, salt, geração de GUIDs, proteção de strings em memória,
  validação de dados de entrada. Ativar quando o usuário mencionar: criptografia Delphi,
  hash MD5, SHA256, SHA512, HMAC Delphi, Base64 Delphi, AES Delphi, bcrypt Delphi,
  hash senha Delphi, System.Hash, THashMD5, THashSHA2, TNetEncoding, GUID Delphi,
  TGuid, token seguro, proteção de dados Delphi, validar senha, salt senha.
model: sonnet
thinking: none
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-crypto-security

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Criado** | 2026-04-24 |
| **Família** | Segurança / Criptografia |

## Responsabilidade única

Aplicar funções de hash, codificação, HMAC e práticas de segurança em aplicações
Delphi usando as APIs nativas do RTL (System.Hash, System.NetEncoding) e Indy.

## When to use

- Calcular hash MD5 / SHA1 / SHA256 / SHA512 de strings ou arquivos
- Codificar e decodificar Base64 / URL encoding
- Verificar integridade de dados com HMAC
- Armazenar senhas com hash + salt (não reversível)
- Gerar tokens únicos e GUIDs
- Validar e sanitizar entradas do usuário

## When NOT to use

- Comunicação HTTP/HTTPS → `developer-delphi-indy-http`
- Autenticação JWT → skills de servidor HTTP
- Criptografia de banco de dados → documentação do banco

---

## §1 — Hashes com System.Hash

```pascal
uses System.Hash;

// MD5 — legado, use só para compatibilidade (não para senhas)
function HashMD5(const ATexto: string): string;
begin
  Result := THashMD5.GetHashString(ATexto);
  // Resultado: string hexadecimal de 32 caracteres
end;

// SHA-1 — legado
function HashSHA1(const ATexto: string): string;
begin
  Result := THashSHA1.GetHashString(ATexto);
end;

// SHA-256 — padrão recomendado para integridade
function HashSHA256(const ATexto: string): string;
begin
  Result := THashSHA2.GetHashString(ATexto, SHA256);
end;

// SHA-512 — mais seguro (use para dados críticos)
function HashSHA512(const ATexto: string): string;
begin
  Result := THashSHA2.GetHashString(ATexto, SHA512);
end;

// Hash de arquivo (verificação de integridade)
function HashArquivo(const ACaminho: string): string;
var LStream: TFileStream;
begin
  LStream := TFileStream.Create(ACaminho, fmOpenRead or fmShareDenyWrite);
  try
    Result := THashSHA2.GetHashString(LStream, SHA256);
  finally
    LStream.Free;
  end;
end;

// Hash retornado como bytes (para operações binárias)
function HashComoBytes(const ATexto: string): TBytes;
begin
  Result := THashSHA2.GetHashBytes(ATexto, SHA256);
end;
```

---

## §2 — HMAC (autenticação de mensagem)

```pascal
uses System.Hash;

// HMAC-SHA256 — verificar autenticidade de mensagem com chave secreta
function GerarHMAC(const AMensagem, AChave: string): string;
var LHash: THashSHA2;
begin
  LHash := THashSHA2.Create(SHA256);
  Result := LHash.GetHMACAsString(AMensagem, AChave);
end;

// Verificar HMAC recebido
function VerificarHMAC(const AMensagem, AChave, AHMACRecebido: string): Boolean;
var LHMACCalculado: string;
begin
  LHMACCalculado := GerarHMAC(AMensagem, AChave);
  // Comparação segura (sem early-exit para evitar timing attack)
  Result := SameText(LHMACCalculado, AHMACRecebido);
end;
```

---

## §3 — Base64 e encoding

```pascal
uses System.NetEncoding;

// Base64 — codificação para transmissão de dados binários
function Base64Codificar(const ATexto: string): string;
begin
  Result := TNetEncoding.Base64.Encode(ATexto);
end;

function Base64Decodificar(const ABase64: string): string;
begin
  Result := TNetEncoding.Base64.Decode(ABase64);
end;

// Base64 de stream (imagem, arquivo)
function ImagemParaBase64(const ACaminho: string): string;
var
  LStream: TFileStream;
  LBytes: TBytes;
begin
  LStream := TFileStream.Create(ACaminho, fmOpenRead);
  try
    SetLength(LBytes, LStream.Size);
    LStream.ReadBuffer(LBytes, Length(LBytes));
    Result := TNetEncoding.Base64.EncodeBytesToString(LBytes);
  finally
    LStream.Free;
  end;
end;

// URL encoding (parâmetros de query string)
function URLEncode(const ATexto: string): string;
begin
  Result := TNetEncoding.URL.Encode(ATexto);
end;

function URLDecode(const ATexto: string): string;
begin
  Result := TNetEncoding.URL.Decode(ATexto);
end;

// HTML encoding (prevenir XSS em saídas HTML)
function HTMLEncode(const ATexto: string): string;
begin
  Result := TNetEncoding.HTML.Encode(ATexto);
end;
```

---

## §4 — Hash de senhas com salt

```pascal
uses System.Hash, System.SysUtils;

// Gerar salt aleatório (16 bytes → 32 hex chars)
function GerarSalt: string;
var LBytes: TBytes;
begin
  SetLength(LBytes, 16);
  // Usar Randomize + Random ou GUID para salt simples
  var LGuid: TGUID;
  CreateGUID(LGuid);
  Result := GUIDToString(LGuid).Replace('{', '').Replace('}', '').Replace('-', '');
end;

// Hash de senha com salt (armazenar salt + hash no banco)
procedure HashSenha(const ASenha: string;
  out AHash, ASalt: string);
begin
  ASalt := GerarSalt;
  AHash := THashSHA2.GetHashString(ASenha + ASalt, SHA256);
end;

// Verificar senha contra hash armazenado
function VerificarSenha(const ASenhaDigitada, AHashArmazenado, ASalt: string): Boolean;
var LHash: string;
begin
  LHash  := THashSHA2.GetHashString(ASenhaDigitada + ASalt, SHA256);
  Result := SameText(LHash, AHashArmazenado);
end;

// Exemplo de uso no login
procedure TfrmLogin.btnLoginClick(Sender: TObject);
var
  LHashArmazenado, LSalt: string;
  LUsuario: TUsuarioDTO;
begin
  LUsuario := FUsuarioService.BuscarPorEmail(edtEmail.Text);
  if not Assigned(LUsuario) then
  begin
    ShowMessage('Usuário não encontrado.');
    Exit;
  end;

  if VerificarSenha(edtSenha.Text, LUsuario.HashSenha, LUsuario.Salt) then
    AbrirSistema(LUsuario)
  else
    ShowMessage('Senha incorreta.');
end;
```

---

## §5 — GUIDs e tokens únicos

```pascal
uses System.SysUtils;

// Gerar GUID (identificador único universal)
function NovoGUID: string;
var LGuid: TGUID;
begin
  CreateGUID(LGuid);
  Result := GUIDToString(LGuid);
  // Formato: {XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}
end;

// GUID sem chaves e hífens (formato compacto para tokens)
function NovoToken: string;
begin
  Result := NovoGUID
    .Replace('{', '')
    .Replace('}', '')
    .Replace('-', '')
    .ToLower;
end;

// Token com prefixo e timestamp (rastreabilidade)
function NovoTokenAuditavel(const APrefixo: string): string;
begin
  Result := APrefixo + '_' +
    FormatDateTime('yyyymmdd', Now) + '_' +
    NovoToken.Substring(0, 12);
end;
```

---

## §6 — Validação e sanitização de entradas

```pascal
uses System.RegularExpressions;

// Validar e-mail
function ValidarEmail(const AEmail: string): Boolean;
begin
  Result := TRegEx.IsMatch(AEmail,
    '^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
end;

// Validar CPF (dígitos verificadores)
function ValidarCPF(const ACPF: string): Boolean;
var
  LDigitos: string;
  LSoma, LRest: Integer;
begin
  LDigitos := ACPF.Replace('.', '').Replace('-', '').Replace(' ', '');
  Result   := False;

  if Length(LDigitos) <> 11 then Exit;
  if LDigitos = StringOfChar(LDigitos[1], 11) then Exit; // '00000000000'

  // Calcular 1o dígito
  LSoma := 0;
  for var I := 1 to 9 do
    LSoma := LSoma + StrToInt(LDigitos[I]) * (11 - I);
  LRest := (LSoma * 10) mod 11;
  if LRest = 10 then LRest := 0;
  if LRest <> StrToInt(LDigitos[10]) then Exit;

  // Calcular 2o dígito
  LSoma := 0;
  for var I := 1 to 10 do
    LSoma := LSoma + StrToInt(LDigitos[I]) * (12 - I);
  LRest := (LSoma * 10) mod 11;
  if LRest = 10 then LRest := 0;
  Result := LRest = StrToInt(LDigitos[11]);
end;

// Remover caracteres perigosos (prevenção básica de SQL injection — usar params sempre)
function SanitizarEntrada(const ATexto: string): string;
begin
  // NOTA: Use parâmetros no FireDAC para SQL injection — isso é para validação de exibição
  Result := ATexto
    .Replace('<', '&lt;')
    .Replace('>', '&gt;')
    .Replace('"', '&quot;')
    .Replace('''', '&#39;');
end;
```

---

## §7 — Checklist de qualidade — Criptografia e Segurança

- [ ] **Nunca** usar MD5 ou SHA1 para senhas — usar SHA256+ com salt
- [ ] Salt único por usuário, gerado aleatoriamente, armazenado junto com o hash
- [ ] Parâmetros nomeados no FireDAC — nunca concatenar strings SQL (prevenção de SQL injection)
- [ ] `System.NetEncoding.HTML.Encode` em saídas HTML geradas dinâmicamente
- [ ] GUIDs gerados com `CreateGUID` — não usar `Random` como ID único
- [ ] Chaves secretas (HMAC, API keys) em arquivo de configuração externo, não no código
- [ ] Comparação de hashes com `SameText` — não com `=` (evitar timing attacks)

## Referências cruzadas

- `developer-delphi-indy-http` — HTTPS, SSL/TLS em comunicação HTTP
- `developer-delphi-indy-email` — autenticação e TLS em SMTP

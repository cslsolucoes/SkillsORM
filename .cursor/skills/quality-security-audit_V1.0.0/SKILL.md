---
name: quality-security-audit
description: >
  Auditoria de segurança de código: identificar SQL injection, XSS, senhas hardcoded,
  dados sensíveis em log, autenticação fraca, validação ausente, OWASP Top 10 aplicado
  a Delphi/Pascal, Horse HTTP security headers, JWT validation, rate limiting.
  Ativar quando o usuário mencionar: auditoria de segurança, security audit, SQL injection,
  XSS, OWASP, senha hardcoded, dados sensíveis log, JWT segurança, autenticação fraca,
  validação de entrada, security review código, Horse segurança, headers segurança HTTP.
model: sonnet
thinking: none
category: quality
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# quality-security-audit

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Criado** | 2026-04-24 |
| **Família** | Quality |

## Responsabilidade única

Identificar e corrigir vulnerabilidades de segurança em código Delphi/Pascal:
SQL injection, XSS, credenciais expostas, validação ausente, headers HTTP e JWT.

## When to use

- Revisar código para vulnerabilidades de segurança antes de deploy
- Identificar SQL injection, XSS, CSRF em aplicações Delphi
- Verificar se credenciais estão hardcoded ou expostas em logs
- Auditar implementação de autenticação (JWT, hash de senhas)
- Verificar headers de segurança em APIs Horse/HTTP

## When NOT to use

- Auditoria técnica completa do projeto → `developer-delphi-project-audit` (E10)
- Hash e criptografia em si → `developer-delphi-crypto-security`
- Testes de unidade → `developer-delphi-testing-dunitx`

---

## §1 — OWASP Top 10 aplicado a Delphi

| OWASP | Risco | Verificar em Delphi |
|-------|-------|---------------------|
| A01 Broken Access Control | Crítico | Verificar se rotas Horse têm middleware de autenticação |
| A02 Cryptographic Failures | Alto | Senhas com MD5/SHA1 sem salt; dados em texto claro |
| A03 Injection | Crítico | SQL concatenado com input do usuário |
| A04 Insecure Design | Alto | Ausência de validação de entrada em forms/APIs |
| A05 Security Misconfiguration | Alto | Headers HTTP ausentes; LoginPrompt desabilitado sem SSL |
| A06 Vulnerable Components | Médio | Indy/OpenSSL desatualizados; componentes sem suporte |
| A07 Auth Failures | Crítico | JWT sem validação de assinatura; senhas fracas |
| A08 Data Integrity | Alto | Deserialização JSON sem validação de schema |
| A09 Logging Failures | Médio | Dados sensíveis (CPF, senha) em arquivos de log |
| A10 SSRF | Médio | URL de requisição HTTP montada com input do usuário |

---

## §2 — SQL Injection — detectar e corrigir

```pascal
// ❌ VULNERÁVEL — concatenação direta com input do usuário
procedure TServico.BuscarClienteVulneravel(const ANome: string);
begin
  FQuery.SQL.Text := 'SELECT * FROM CLIENTES WHERE NOME = ''' + ANome + '''';
  // Se ANome = "'; DROP TABLE CLIENTES; --" → desastre
  FQuery.Open;
end;

// ✅ SEGURO — parâmetros nomeados
procedure TServico.BuscarClienteSeguro(const ANome: string);
begin
  FQuery.SQL.Text := 'SELECT * FROM CLIENTES WHERE NOME = :NOME';
  FQuery.ParamByName('NOME').AsString := ANome;
  FQuery.Open;
end;

// ❌ VULNERÁVEL — LIKE com concatenação
procedure TServico.PesquisarVulneravel(const ATermo: string);
begin
  FQuery.SQL.Text := 'SELECT * FROM PRODUTOS WHERE DESC LIKE ''%' + ATermo + '%''';
end;

// ✅ SEGURO — LIKE com parâmetro
procedure TServico.PesquisarSeguro(const ATermo: string);
begin
  FQuery.SQL.Text := 'SELECT * FROM PRODUTOS WHERE DESC LIKE :TERMO';
  FQuery.ParamByName('TERMO').AsString := '%' + ATermo + '%';
end;
```

---

## §3 — Credenciais hardcoded — detectar e extrair

```pascal
// ❌ VULNERÁVEL — senha no código-fonte
procedure TdmConexao.ConectarVulneravel;
begin
  FDConnection1.Params.Add('Password=Admin123!');  // exposta no binário
end;

// ✅ SEGURO — ler de arquivo de configuração externo
procedure TdmConexao.ConectarSeguro;
var LConfig: TIniFile;
begin
  LConfig := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'config.ini');
  try
    FDConnection1.Params.Add('Password=' +
      LConfig.ReadString('Database', 'Password', ''));
  finally
    LConfig.Free;
  end;
end;

// ❌ VULNERÁVEL — API key hardcoded
const
  API_KEY = 'sk-1234567890abcdef';  // visível no binário e no código-fonte

// ✅ SEGURO — ler de variável de ambiente ou arquivo externo
function ObterAPIKey: string;
begin
  Result := GetEnvironmentVariable('MINHA_API_KEY');
  if Result.IsEmpty then
    raise ESeguranca.Create('Variável de ambiente MINHA_API_KEY não configurada.');
end;
```

---

## §4 — Dados sensíveis em logs

```pascal
// ❌ VULNERÁVEL — logar dados sensíveis
procedure TLoginServico.Autenticar(const AEmail, ASenha: string);
begin
  TLogger.Instance.Info(Format('Login: %s / %s', [AEmail, ASenha]));  // senha no log!
  // ...
end;

// ✅ SEGURO — logar apenas o necessário
procedure TLoginServico.Autenticar(const AEmail, ASenha: string);
begin
  TLogger.Instance.Info(Format('Tentativa de login: %s', [AEmail]));
  // Nunca logar ASenha, tokens JWT, números de cartão, CPF completo
end;

// Mascarar CPF para log
function MascararCPF(const ACPF: string): string;
begin
  if Length(ACPF) >= 11 then
    Result := '***.' + ACPF.Substring(3, 3) + '.***-**'
  else
    Result := '***';
end;
```

---

## §5 — Validação de entrada em APIs (Horse)

```pascal
uses Horse;

// ❌ VULNERÁVEL — aceitar qualquer entrada sem validação
THorse.Post('/api/clientes',
  procedure(Req: THorseRequest; Res: THorseResponse)
  begin
    var LJson := Req.Body<TJSONObject>;
    var LNome := LJson.GetValue<string>('nome');  // pode ser '' ou ter 10.000 chars
    FClienteService.Salvar(LNome);  // sem validação
  end);

// ✅ SEGURO — validar entrada antes de processar
THorse.Post('/api/clientes',
  procedure(Req: THorseRequest; Res: THorseResponse)
  var LJson: TJSONObject;
  begin
    LJson := Req.Body<TJSONObject>;

    // Validar campo obrigatório
    if not Assigned(LJson.FindValue('nome')) then
    begin
      Res.Status(THTTPStatus.BadRequest);
      Res.Send('{"erro":"campo nome obrigatorio"}');
      Exit;
    end;

    var LNome := LJson.GetValue<string>('nome').Trim;

    // Validar tamanho
    if (LNome.Length < 2) or (LNome.Length > 100) then
    begin
      Res.Status(THTTPStatus.BadRequest);
      Res.Send('{"erro":"nome deve ter entre 2 e 100 caracteres"}');
      Exit;
    end;

    FClienteService.Salvar(LNome);
    Res.Status(THTTPStatus.Created).Send('{}');
  end);
```

---

## §6 — Security headers HTTP (Horse)

```pascal
uses Horse;

// Middleware de security headers
THorse.Use(
  procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  begin
    // Prevenir MIME sniffing
    Res.RawWebResponse.CustomHeaders.Values['X-Content-Type-Options']  := 'nosniff';
    // Prevenir clickjacking
    Res.RawWebResponse.CustomHeaders.Values['X-Frame-Options']         := 'DENY';
    // XSS Protection (legacy browsers)
    Res.RawWebResponse.CustomHeaders.Values['X-XSS-Protection']        := '1; mode=block';
    // HSTS (só para HTTPS)
    Res.RawWebResponse.CustomHeaders.Values['Strict-Transport-Security']:= 'max-age=31536000';
    // Remover header de versão do servidor
    Res.RawWebResponse.CustomHeaders.Values['Server']                   := '';
    Next;
  end);
```

---

## §7 — Checklist de auditoria de segurança

### Crítico (bloquear release)
- [ ] Nenhum SQL concatenado com input do usuário — **apenas parâmetros**
- [ ] Nenhuma senha/token/API key no código-fonte ou em constantes
- [ ] Todas as rotas HTTP autenticadas têm middleware de verificação de JWT
- [ ] Senhas armazenadas com SHA256+ e salt único por usuário

### Alto (corrigir antes do próximo release)
- [ ] Dados sensíveis (CPF, senha, cartão) não aparecem em logs
- [ ] Todos os inputs de API têm validação de tamanho e tipo
- [ ] Headers de segurança configurados no servidor HTTP
- [ ] OpenSSL e Indy atualizados para versões sem CVEs críticos

### Médio (backlog)
- [ ] Rate limiting em endpoints de login/registro
- [ ] Tokens JWT com expiração (`exp` claim) validada
- [ ] Entradas HTML codificadas antes de renderizar (prevenir XSS)
- [ ] Logs de auditoria para ações sensíveis (login, exclusão, admin)

## Referências cruzadas

- `developer-delphi-crypto-security` — hash de senhas, Base64, HMAC
- `developer-delphi-indy-http` — HTTPS, SSL/TLS
- `developer-delphi-firedac-queries` — parâmetros nomeados (prevenção SQL injection)

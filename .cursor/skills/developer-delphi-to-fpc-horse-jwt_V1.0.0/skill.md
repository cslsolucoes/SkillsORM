---
name: developer-delphi-to-fpc-horse-jwt
description: Middleware JWT Bearer para Horse. Cobre HorseJWT (global e por rota), THorseJWTConfig (SkipRoutes, Header, IsRequiredSubject, IsRequiredExpirationTime, ExpectedAudience, SessionClass), leitura de claims via Req.Session<TJWT> e dependência delphi-jose-jwt. Fonte: app/package/docs/pacotes/horse-jwt.md.
model: sonnet
thinking: minimal
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-horse-jwt

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Middleware que valida tokens JWT Bearer no cabeçalho `Authorization` antes de executar o handler da rota.

## When to use

- Proteger rotas com validação JWT Bearer
- Configurar rotas públicas (SkipRoutes)
- Ler claims JWT no handler (`Req.Session<TJWT>`)
- Configurar validação de claims obrigatórios (exp, sub, aud)

## When NOT to use

- Gerar tokens JWT → `developer-delphi-to-fpc-horse-security`
- Autenticação Basic → `developer-delphi-to-fpc-horse-basic-auth`
- Core do servidor → `developer-delphi-to-fpc-horse-core`

## Documento canônico

`app/package/docs/pacotes/horse-jwt.md`

---

## HorseJWT — sobrecargas

| Sobrecarga | Descrição |
| --- | --- |
| `HorseJWT(secret)` | Middleware global com segredo HMAC |
| `HorseJWT(secret, config)` | Com configuração avançada |

---

## THorseJWTConfig — configuração

| Método | Descrição |
| --- | --- |
| `New` | Cria instância |
| `SkipRoutes([...])` | Rotas que ignoram validação JWT |
| `Header(value)` | Cabeçalho do token (padrão: `Authorization`) |
| `IsRequiredSubject(bool)` | Exige claim `sub` |
| `IsRequiredIssuedAt(bool)` | Exige claim `iat` |
| `IsRequiredNotBefore(bool)` | Exige claim `nbf` |
| `IsRequiredExpirationTime(bool)` | Exige claim `exp` |
| `IsRequireAudience(bool)` | Exige claim `aud` |
| `ExpectedAudience([...])` | Audiências válidas |
| `SessionClass(class)` | Classe da sessão injectada no Request |

---

## Exemplos

### Todas as rotas protegidas

```delphi
uses Horse, Horse.JWT;

begin
  THorse.Use(HorseJWT('MY-PASSWORD'));

  THorse.Post('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  THorse.Listen(9000);
end.
```

### Com configuração avançada

```delphi
THorse.Use(
  HorseJWT('meu-segredo',
    THorseJWTConfig.New
      .SkipRoutes(['/auth/login', '/health', '/swagger/doc/html'])
      .IsRequiredExpirationTime(True)
      .IsRequiredSubject(True)
  )
);
```

### Apenas rotas específicas

```delphi
// Rota pública
THorse.Get('/ping',
  procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  begin
    Res.Send('pong');
  end);

// Rota privada — JWT aplicado via AddCallback
THorse
  .AddCallback(HorseJWT('MY-PASSWORD'))
  .Get('/private',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('route private');
    end);
```

### SkipRoutes — rotas públicas

```delphi
THorse.Use(HorseJWT('MY-PASSWORD',
  THorseJWTConfig.New.SkipRoutes(['/public', '/auth/login', '/health'])));
```

### Ler claims da sessão no handler

```delphi
THorse.Get('/me',
  procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  var LJWT: TJWT;
  begin
    LJWT := Req.Session<TJWT>;
    Res.Send('Subject: ' + LJWT.Claims.Subject);
  end);
```

### Validação de audiência

```delphi
THorse.Use(
  HorseJWT('meu-segredo',
    THorseJWTConfig.New
      .IsRequireAudience(True)
      .ExpectedAudience(['gestorerp-api'])
  )
);
```

### Cabeçalho customizado

```delphi
// Token em X-Auth-Token em vez de Authorization
THorse.Use(HorseJWT('meu-segredo',
  THorseJWTConfig.New.Header('X-Auth-Token')));
```

### SessionClass — classe de sessão custom

```delphi
type
  TAppSession = class(TJWT)
    // claims adicionais via RTTI
  end;

THorse.Use(HorseJWT('meu-segredo',
  THorseJWTConfig.New.SessionClass(TAppSession)));
// No handler: Req.Session<TAppSession>
```

### Gerar token (para endpoint de login)

```delphi
uses JOSE.Core.JWT, JOSE.Core.Builder;

function GerarToken(const ASecretKey, ASubject: string): string;
var LJWT: TJWT;
begin
  LJWT := TJWT.Create;
  try
    LJWT.Claims.Subject    := ASubject;
    LJWT.Claims.IssuedAt   := Now;
    LJWT.Claims.Expiration := Now + 1; // +1 dia
    Result := TJOSE.SerializeCompact(
      LJWT, TJOSEAlgorithmId.HS256,
      TEncoding.UTF8.GetBytes(ASecretKey)
    );
  finally
    LJWT.Free;
  end;
end;
```

---

## Dependências

- **Delphi:** `delphi-jose-jwt` (JOSE.Core.JWT, JOSE.Consumer…)
- **Lazarus:** `hashlib4pascal` / `fpjwt` — ver pasta `samples/` do clone

---

## Notas GestorERP

- Segredo HMAC em variável de ambiente (`GESTORERP_JWT_SECRET`) — nunca hardcoded
- Rotas públicas padrão: `/auth/login`, `/health`, `/swagger/doc/html`
- Validade do token: 8 h (ambiente corporativo)
- Usar HTTPS em produção
- `unit` a usar: `Horse.JWT`

---

## Changelog (este arquivo)

- 1.0.0 (12/04/2026): Criação — skill middleware JWT.

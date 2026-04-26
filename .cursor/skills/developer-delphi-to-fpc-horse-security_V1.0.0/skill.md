---
name: developer-delphi-to-fpc-horse-security
description: Segurança JWT/JOSE para APIs Horse em Delphi. Cobre delphi-jose-jwt (TJWT, TJOSE, TJWTClaims, TJOSEConsumerBuilder) e gbSwagger (HorseSwagger, Swagger.Info, Swagger.Path, SchemaOnError, OpenAPI 2.x via RTTI). Fontes canônicas: app/package/docs/pacotes/delphi-jose-jwt.md e gbSwagger.md.
model: opus
thinking: extended
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-horse-security

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Referência completa de segurança JWT/JOSE e documentação Swagger/OpenAPI para APIs Horse. Cobre a geração e validação de tokens JWT (biblioteca base `delphi-jose-jwt`) e a documentação automática de API (`gbSwagger`).

## When to use

- Criar tokens JWT (HS256/RS256) com TJOSE
- Validar tokens e claims (exp, sub, iss, aud) com TJOSEConsumerBuilder
- Claims personalizados em subclasse de TJWTClaims
- Configurar e expor Swagger UI via HorseSwagger
- Registar paths, modelos e schemas de erro no Swagger
- Entender a dependência entre delphi-jose-jwt e horse-jwt

## When NOT to use

- Middleware de validação JWT por rota Horse → `developer-delphi-to-fpc-horse-jwt`
- Middleware de autenticação Basic → `developer-delphi-to-fpc-horse-basic-auth`
- Core do servidor Horse → `developer-delphi-to-fpc-horse-core`

## Documentos canônicos

- `app/package/docs/pacotes/delphi-jose-jwt.md`
- `app/package/docs/pacotes/gbSwagger.md`

---

## delphi-jose-jwt — Biblioteca JWT/JOSE

### TJOSE — operações de alto nível

| Método | Descrição |
| --- | --- |
| `TJOSE.SerializeCompact(jwt, alg, key)` | Serializa JWT em formato compact (header.payload.signature) |
| `TJOSE.DeserializeCompact(token, key, jwt, alg)` | Desserializa e verifica assinatura |
| `TJOSE.Sign(jwt, alg, key)` | Assina JWT |
| `TJOSE.Verify(token, key)` | Verifica assinatura |

### TJWTClaims — claims padrão

| Propriedade | Claim JWT | Descrição |
| --- | --- | --- |
| `Subject` | `sub` | Identificador do sujeito |
| `Issuer` | `iss` | Emissor |
| `Audience` | `aud` | Audiência |
| `IssuedAt` | `iat` | Data de emissão |
| `Expiration` | `exp` | Data de expiração |
| `NotBefore` | `nbf` | Válido a partir de |
| `JWTID` | `jti` | ID único do token |

### TJOSEConsumerBuilder — validação avançada

| Método | Descrição |
| --- | --- |
| `NewConsumer` | Inicia builder |
| `SetClaimsClass(class)` | Classe de claims a usar |
| `SetVerificationKey(bytes)` | Chave de verificação |
| `SetRequireExpirationTime` | Obriga `exp` |
| `SetRequireIssuedAt` | Obriga `iat` |
| `SetRequireSubject` | Obriga `sub` |
| `SetExpectedIssuer(str)` | Valida emissor |
| `SetExpectedAudience(str)` | Valida audiência |
| `Build` | Devolve IJOSEConsumer |

### TJWTHeader

| Propriedade | Descrição |
| --- | --- |
| `Algorithm` | Algoritmo (HS256, RS256…) |
| `HeaderType` | Tipo (normalmente JWT) |
| `KeyID` | ID da chave (`kid`) |

---

## Exemplos delphi-jose-jwt

### Criar token HS256

```delphi
uses JOSE.Core.JWT, JOSE.Core.Builder, System.SysUtils;

function CriarToken(const ASecretKey, ASubject: string): string;
var LJWT: TJWT;
begin
  LJWT := TJWT.Create;
  try
    LJWT.Claims.Subject    := ASubject;
    LJWT.Claims.IssuedAt   := Now;
    LJWT.Claims.Expiration := IncHour(Now, 8);
    LJWT.Claims.Issuer     := 'GestorERP';
    LJWT.Claims.Audience   := TJSONArray.Create.Add('gestorerp-api') as TJSONArray;
    Result := TJOSE.SerializeCompact(
      LJWT,
      TJOSEAlgorithmId.HS256,
      TEncoding.UTF8.GetBytes(ASecretKey)
    );
  finally
    LJWT.Free;
  end;
end;
```

### Validar token com builder

```delphi
uses JOSE.Consumer, JOSE.Consumer.Validators;

var
  LConsumer: IJOSEConsumer;
  LCtx: TJOSEConsumerContext;
begin
  LConsumer := TJOSEConsumerBuilder.NewConsumer
    .SetClaimsClass(TJWTClaims)
    .SetVerificationKey(TEncoding.UTF8.GetBytes('meu-segredo'))
    .SetRequireExpirationTime
    .SetRequireSubject
    .SetExpectedIssuer('GestorERP')
    .SetExpectedAudience('gestorerp-api')
    .Build;

  LCtx := LConsumer.Process(AToken);
  if LCtx.IsValid then
    WriteLn('OK — sub: ' + LCtx.JWT.Claims.Subject)
  else
    raise Exception.Create('JWT inválido: ' + LCtx.ErrorMessage);
end;
```

### Validar token (TJOSE.DeserializeCompact)

```delphi
var LJWT: TJWT; LValid: Boolean;
begin
  LJWT := TJWT.Create;
  try
    LValid := TJOSE.DeserializeCompact(
      AToken,
      TEncoding.UTF8.GetBytes('meu-segredo'),
      LJWT,
      TJOSEAlgorithmId.HS256
    );
    if LValid then
      WriteLn('Sub: ' + LJWT.Claims.Subject)
    else
      WriteLn('Token inválido');
  finally
    LJWT.Free;
  end;
end;
```

### Claims completos

```delphi
LJWT.Claims.Subject    := 'u:42';
LJWT.Claims.Issuer     := 'GestorERP';
LJWT.Claims.IssuedAt   := Now;
LJWT.Claims.Expiration := IncHour(Now, 8);
LJWT.Claims.NotBefore  := Now - (1/1440); // 1 min de tolerância
LJWT.Claims.JWTID      := TGuid.NewGuid.ToString;
```

### Claim personalizado

```delphi
uses JOSE.Core.JWT, JOSE.Core.Builder;

type
  TAppClaims = class(TJWTClaims)
  private
    function GetRole: string;
    procedure SetRole(const Value: string);
  public
    property Role: string read GetRole write SetRole;
  end;

function TAppClaims.GetRole: string;
begin
  Result := TryGetClaimValue('role');
end;

procedure TAppClaims.SetRole(const Value: string);
begin
  SetClaimValue('role', Value);
end;
```

---

## gbSwagger — Documentação OpenAPI 2.x

### API principal

| Elemento | Descrição |
| --- | --- |
| `HorseSwagger` | Middleware que expõe Swagger UI (`/swagger/doc/html`) |
| `Swagger.Info` | Metadados da API (Title, Description, Version, Contact) |
| `Swagger.BasePath(str)` | Prefixo base da API |
| `Swagger.Path(path)` | Registar endpoint documentado |
| `Swagger.SchemaOnError(class)` | Modelo padrão de erro |
| `Swagger.Consumes([...])` | Content-Types aceites |
| `Swagger.Produces([...])` | Content-Types produzidos |

### Registar e configurar

```delphi
uses Horse, Horse.GBSwagger, GBSwagger.Register;

begin
  App := THorse.Create(9000);
  App.Use(HorseSwagger);

  Swagger
    .Info
      .Title('GestorERP API')
      .Description('API REST do sistema GestorERP')
      .Version('1.0.0')
      .Contact
        .Name('Equipa TI')
        .Email('ti@gestorerp.pt')
      .&End
    .&End
    .BasePath('/api/v1')
    .Consumes(['application/json'])
    .Produces(['application/json']);

  Swagger.Path('/users')
    .Tag('Users')
    .GET
      .AddResponse(200, 'Lista de utilizadores', TUser)
      .AddResponse(401, 'Não autenticado')
    .&End;

  App.Start;
end.
```

### Modelo de erro

```delphi
type
  TAPIError = class
  private
    Ferror: string;
  public
    property error: string read Ferror write Ferror;
  end;

// No arranque:
Swagger.SchemaOnError(TAPIError);
```

---

## Fluxo de autenticação JWT completo

```
1. POST /auth/login  →  validar credenciais
2. CriarToken(secret, userId)  →  TJOSE.SerializeCompact
3. Devolver token ao cliente
4. Pedidos seguintes: Authorization: Bearer <token>
5. horse-jwt middleware valida token (usa delphi-jose-jwt internamente)
6. Req.Session<TJWT>  →  claims disponíveis no handler
```

---

## Notas GestorERP

- Segredo HMAC em variável de ambiente (`GESTORERP_JWT_SECRET`) — nunca hardcoded
- Validade: 8 h em ambiente corporativo
- Delphi 10.3+ usa `System.Hash` para HMAC-SHA256 (sem OpenSSL)
- URL Swagger em dev: `http://localhost:9000/swagger/doc/html`
- Registar todos os modelos antes de `App.Start`
- Dependência: `horse-jwt` usa `delphi-jose-jwt` internamente (Delphi)

---

## Changelog (este arquivo)

- 1.0.0 (12/04/2026): Criação — skill de segurança JWT/JOSE e Swagger.

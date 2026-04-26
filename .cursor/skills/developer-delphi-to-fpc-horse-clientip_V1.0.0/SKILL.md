---
name: developer-delphi-to-fpc-horse-clientip
description: Utilitário de extração de IP real do cliente para Horse. Cobre ClientIP(Req) com prioridade de cabeçalhos (CF-Connecting-IP, X-Real-IP, X-Forwarded-For, socket TCP) e padrões de uso em auditoria e rate limiting. Fonte: app/package/docs/pacotes/horse-utils-clientip.md.
model: sonnet
thinking: minimal
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-horse-clientip_V1.0.0

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Função utilitária que extrai o endereço IP real do cliente em ambientes com proxy/load balancer.

## When to use

- Obter IP do cliente para logging ou auditoria
- Rate limiting por IP
- Segurança — rastrear origem de pedidos maliciosos
- Contexto: cliente atrás de Nginx, Cloudflare, load balancer

## When NOT to use

- IP não necessário → usar `Req.RawWebRequest.RemoteIP` diretamente (só para conexão direta)

## Documento canônico

`app/package/docs/pacotes/horse-utils-clientip.md`

---

## ClientIP — função utilitária

| Função | Descrição |
| --- | --- |
| `ClientIP(Req: THorseRequest): string` | Devolve IP real do cliente |

### Prioridade de cabeçalhos

| Ordem | Cabeçalho | Cenário |
| --- | --- | --- |
| 1 | `CF-Connecting-IP` | Cloudflare CDN |
| 2 | `X-Real-IP` | Nginx proxy_pass |
| 3 | `X-Forwarded-For` | Proxy genérico (primeiro IP da cadeia) |
| 4 | IP TCP directo | Sem proxy |

---

## Exemplos

### Uso básico

```delphi
uses Horse, Horse.Utils.ClientIP;

begin
  THorse.Get('ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send(ClientIP(Req));
    end);

  THorse.Listen(9000);
end.
```

### Em middleware de auditoria

```delphi
THorse.Use(
  procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  begin
    TMyAudit.Log(ClientIP(Req), Req.PathInfo, Req.MethodType.ToString);
    Next;
  end);
```

### Rate limiting por IP

```delphi
uses Horse, Horse.Utils.ClientIP;

var GContadorPorIP: TDictionary<string, Integer>;

THorse.Get('/api/query',
  procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  var LIP: string; LCount: Integer;
  begin
    LIP := ClientIP(Req);
    LCount := GContadorPorIP.AddOrSetValue(LIP,
      (GContadorPorIP.GetValueOrDefault(LIP, 0) + 1));
    if LCount > 100 then
    begin
      Res.Status(429).Send('Too Many Requests');
      Exit;
    end;
    Next;
  end);
```

### Em handler de login (auditoria de segurança)

```delphi
THorse.Post('/auth/login',
  procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  var LIP: string;
  begin
    LIP := ClientIP(Req);
    // Registar tentativa de login com IP
    TSecurityLog.LogLoginAttempt(LIP, Req.Body);
    // ... validar credenciais ...
  end);
```

### No middleware global de logging

```delphi
// ClientIP é usado internamente por horse-logger e horse-exception-logger
// via variável ${request_clientip} — não é necessário chamar manualmente
THorse.Use(THorseLoggerManager.HorseCallback);
```

---

## Notas GestorERP

- Proxies confiáveis em produção: load balancer interno
- Verificar cabeçalhos disponíveis no ambiente de deploy
- **Nunca** confiar em `X-Forwarded-For` sem validar origem do proxy (pode ser forjado)
- Dependência interna de `horse-logger` e `horse-exception-logger`
- `unit` a usar: `Horse.Utils.ClientIP`

---

## Changelog (este arquivo)

- 1.0.0 (12/04/2026): Criação — skill utilitário ClientIP.

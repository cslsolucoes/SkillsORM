---
name: developer-delphi-to-fpc-horse-etag
description: Middleware ETag para Horse — caching condicional HTTP. Cobre eTag middleware (cálculo automático de hash, If-None-Match, 304 Not Modified) e cabeçalho Vary. Fonte: app/package/docs/pacotes/Horse-ETag.md.
model: sonnet
thinking: minimal
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-horse-etag

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Middleware ETag para Horse: calcula hash do corpo da resposta, define cabeçalho `ETag` e responde 304 quando o cliente envia `If-None-Match` com o mesmo hash.

## When to use

- Reduzir largura de banda em endpoints de configuração/listas estáticas
- Implementar cache condicional HTTP (304 Not Modified)
- Endpoints GET cujo conteúdo muda raramente (tabelas de referência, config)

## When NOT to use

- Endpoints de escrita (POST/PUT/DELETE) — ETag não aplicável
- Streaming binário → `developer-delphi-to-fpc-horse-octet-stream`

## Documento canônico

`app/package/docs/pacotes/Horse-ETag.md`

---

## eTag — middleware

| Função | Descrição |
| --- | --- |
| `eTag` | Calcula ETag (MD5 do corpo), define header e responde 304 se não mudou |

---

## Ordem no pipeline

ETag deve vir **DEPOIS** de Jhonson (para que o JSON esteja serializado antes do cálculo do hash):

```delphi
THorse
  .Use(Jhonson)  // 1.º — serializa JSON
  .Use(eTag);    // 2.º — calcula hash do corpo
```

---

## Exemplos

### Básico

```delphi
uses Horse, Horse.Etag, Horse.Jhonson, System.JSON;

begin
  THorse
    .Use(Jhonson)
    .Use(eTag);

  THorse.Get('ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send<TJsonObject>(TJsonObject.Create.AddPair('Teste', 'Teste'));
    end);

  THorse.Listen(9000);
end.
```

### Endpoint de configuração (ideal para ETag)

```delphi
THorse.Get('/config',
  procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  var LObj: TJSONObject;
  begin
    LObj := ObterConfiguracaoAtual;
    // ETag calcula MD5 do JSON automaticamente
    Res.Send<TJSONObject>(LObj);
  end);
```

### Comportamento HTTP esperado

```bash
# 1.ª chamada — sem If-None-Match
curl http://localhost:9000/config -v
# < ETag: "d41d8cd98f00b204..."
# < 200 OK

# 2.ª chamada — com ETag recebido
curl http://localhost:9000/config \
     -H 'If-None-Match: "d41d8cd98f00b204..."' -v
# < 304 Not Modified  (sem corpo — economiza bandwidth)
```

### Vary — invalidar por parâmetro

```delphi
// ETag considera Accept-Language na chave de cache
Res.AddHeader('Vary', 'Accept-Language');
```

---

## Notas GestorERP

- ETag reduz largura de banda em tabelas de referência e dados de configuração
- Registar **APÓS** Jhonson para que o corpo JSON esteja serializado
- `unit` a usar: `Horse.Etag`
- Upstream: `bittencourtthulio/Horse-ETag`

---

## Changelog (este arquivo)

- 1.0.0 (12/04/2026): Criação — skill middleware ETag.

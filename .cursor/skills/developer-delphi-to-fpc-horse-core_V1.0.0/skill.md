---
name: developer-delphi-to-fpc-horse-core
description: Framework HTTP Horse para Delphi/Lazarus (FPC). Cobre THorse (routing, Use, Listen, Group), THorseRequest (Params, Query, Body, Headers, Cookie, Session, ContentFields) e THorseResponse (Send, Status, AddHeader, ContentType, SendFile, Download, RedirectTo). Fonte canônica: app/package/docs/pacotes/horse.md.
model: opus
thinking: extended
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-horse-core

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Referência completa do framework **Horse** — servidor HTTP minimalista para Delphi e Lazarus (FPC), inspirado no Express.js. Cobre routing, middleware chain, request e response.

## When to use

- Configurar servidor Horse, registar rotas (Get, Post, Put, Delete, Patch, Head, All)
- Usar middleware global ou por path (`.Use()`)
- Agrupar rotas (`Group`, `AddCallback`)
- Ler parâmetros de rota, query string, corpo, cabeçalhos, cookies
- Enviar resposta (texto, JSON, ficheiro, download, redirect)
- Iniciar o servidor (`Listen`)

## When NOT to use

- CORS → `developer-delphi-to-fpc-horse-cors`
- JWT → `developer-delphi-to-fpc-horse-jwt` ou `developer-delphi-to-fpc-horse-security`
- Compressão → `developer-delphi-to-fpc-horse-compression`
- Logging → `developer-delphi-to-fpc-horse-logger`
- Paginação → `developer-delphi-to-fpc-horse-paginate`
- Exceções → `developer-delphi-to-fpc-horse-handle-exception`

## Documento canônico

`app/package/docs/pacotes/horse.md`

---

## Quickstart

```pascal
uses Horse;

begin
  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      Res.Send('pong');
    end);

  THorse.Listen(9000);
end.
```

---

## THorse — registo de rotas e servidor

### Tabela de métodos

| Método | Descrição |
| --- | --- |
| `Get(path, callback)` | Rota HTTP GET |
| `Post(path, callback)` | Rota HTTP POST |
| `Put(path, callback)` | Rota HTTP PUT |
| `Delete(path, callback)` | Rota HTTP DELETE |
| `Patch(path, callback)` | Rota HTTP PATCH |
| `Head(path, callback)` | Rota HTTP HEAD |
| `All(path, callback)` | Todos os verbos |
| `Use(callback)` | Middleware global |
| `Use(path, callback)` | Middleware por path |
| `AddCallback(callback)` | Encadeia callback inline |
| `Group` | Cria grupo de rotas |
| `Route(path)` | Sub-rota |
| `Listen(porta)` | Inicia o servidor |
| `Version` | Versão do Horse |

### Exemplos

#### Rota com parâmetro
```delphi
THorse.Get('/users/:id',
  procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  begin
    Res.Send('User id: ' + Req.Params['id']);
  end);
```

#### POST com JSON
```delphi
uses Horse, System.JSON;

THorse.Post('/users',
  procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  var LBody: TJSONObject;
  begin
    LBody := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    try
      Res.Status(THTTPStatus.Created)
         .Send('Criado: ' + LBody.GetValue<string>('name'));
    finally
      LBody.Free;
    end;
  end);
```

#### Middleware global
```delphi
THorse.Use(
  procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  begin
    Req.Headers.Add('X-Request-Id', TGuid.NewGuid.ToString);
    Next;
  end);
```

#### Middleware por path (proteger /api/*)
```delphi
THorse.Use('/api',
  procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  begin
    if Req.Headers['X-API-Key'] <> 'secret' then
    begin
      Res.Status(401).Send('Unauthorized');
      Exit;
    end;
    Next;
  end);
```

#### AddCallback — middleware inline por rota
```delphi
THorse
  .AddCallback(HorseJWT('secret'))
  .Get('/private',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('privado');
    end);
```

#### Group — grupo com prefixo
```delphi
var LGroup: IHorseCoreGroup<THorseCore>;
begin
  LGroup := THorse.Group;
  LGroup.Prefix('/api/v1')
    .Get('/ping', PingHandler)
    .Post('/users', CreateUserHandler);
end;
```

#### Listen com callback
```delphi
THorse.Listen(9000,
  procedure
  begin
    WriteLn('Servidor em http://localhost:9000');
  end);
```

---

## THorseRequest — propriedades e métodos

| Propriedade | Descrição |
| --- | --- |
| `Body` | Corpo como string |
| `Body<T>` | Corpo desserializado em T |
| `Params['key']` | Parâmetros de rota (:id) |
| `Query['key']` | Parâmetros de query string |
| `Headers['key']` | Cabeçalhos HTTP |
| `Cookie['key']` | Cookies |
| `ContentFields['key']` | Campos form-data |
| `Session<T>` | Sessão tipada (ex.: TJWT) |
| `MethodType` | Verbo HTTP |
| `ContentType` | Content-Type do pedido |
| `Host` | Host |
| `PathInfo` | Path completo |
| `RawWebRequest` | TWebRequest subjacente |

### Exemplos

```delphi
// Ler query string: GET /search?q=teste&page=2
LQ    := Req.Query['q'];     // 'teste'
LPage := Req.Query['page'];  // '2'

// Ler cabeçalho Authorization
LAuth := Req.Headers['Authorization']; // 'Bearer eyJ...'

// Ler sessão JWT
LJWT := Req.Session<TJWT>;
WriteLn(LJWT.Claims.Subject);

// Form-data
LEmail := Req.ContentFields['email'];
```

---

## THorseResponse — métodos

| Método | Descrição |
| --- | --- |
| `Send(string)` | Envia texto/JSON |
| `Send<T>(obj)` | Envia objeto serializado |
| `Status(code)` | Define código HTTP |
| `AddHeader(name, value)` | Adiciona cabeçalho |
| `RemoveHeader(name)` | Remove cabeçalho |
| `ContentType(value)` | Define Content-Type |
| `SendFile(path)` | Envia ficheiro |
| `Download(path)` | Força download |
| `Render(path)` | Renderiza template |
| `RedirectTo(url)` | Redireciona |
| `RawWebResponse` | TWebResponse subjacente |

### Exemplos

```delphi
// Status + Send encadeado
Res.Status(201).Send('Criado');
Res.Status(THTTPStatus.BadRequest).Send('Pedido inválido');
Res.Status(THTTPStatus.NoContent).Send('');

// Múltiplos cabeçalhos
Res.AddHeader('X-Custom-Header', 'valor')
   .AddHeader('Cache-Control', 'no-cache')
   .Send('ok');

// HTML
Res.ContentType('text/html; charset=utf-8')
   .Send('<h1>HTML direto</h1>');

// Ficheiro / download
Res.SendFile('C:\reports\relatorio.pdf');
Res.Download('C:\exports\dados.xlsx');

// Redirect
Res.RedirectTo('https://novaurl.pt');
Res.RedirectTo('/login', THTTPStatus.Found); // 302

// JSON object
Res.Send<TJSONObject>(TJSONObject.Create.AddPair('id', TJSONNumber.Create(1)));
```

---

## Fluxo de um pedido HTTP

```
Pedido HTTP
    ↓
Motor Web (VCL WebBroker / FPC equivalente)
    ↓
Pipeline middlewares (por ordem de Use())
    ↓
Handler da rota (Req, Res, Next)
    ↓
THorseResponse → Envia corpo + cabeçalhos
```

---

## Notas GestorERP

- Porta padrão: 9000 (dev) / 443 (prod via proxy reverso)
- Middlewares globais registados no DPR: `Compression` → `CORS` → `Jhonson` → `HandleException` → `JWT`
- FPC/Lazarus: usar `{$MODE DELPHI}{$H+}` e callbacks como procedimentos nomeados (não anônimos)

---

## Changelog (este arquivo)

- 1.0.0 (12/04/2026): Criação — skill do framework Horse core.

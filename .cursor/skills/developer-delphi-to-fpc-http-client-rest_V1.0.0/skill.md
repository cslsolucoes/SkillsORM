---
name: developer-delphi-to-fpc-http-client-rest
description: Cliente HTTP REST para Delphi/Lazarus com RESTRequest4Delphi. Cobre TRequest/IRequest (BaseURL, Get, Post, Put, Delete, Patch, AddHeader, AddBody, TokenBearer, Retry, Timeout, Adapters), IResponse, adaptador CSV (TCSVAdapterRESTRequest4D) e adaptador DataSet (TDataSetSerializeAdapter). Fontes: app/package/docs/pacotes/RESTRequest4Delphi.md, csv-adapter-restrequest4delphi.md, dataset-serialize-adapter-restrequest4delphi.md.
model: sonnet
thinking: minimal
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-http-client-rest

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Cliente HTTP REST em Delphi — `RESTRequest4Delphi` com API fluente, adaptadores para CSV e DataSet.

## When to use

- Consumir APIs REST (GET, POST, PUT, DELETE, PATCH)
- Autenticação Bearer (JWT) ou Basic em pedidos HTTP
- Popular DataSets a partir de respostas JSON (via adaptador)
- Exportar respostas JSON para CSV (via adaptador)
- Upload de ficheiros (multipart/form-data)
- Configurar motor HTTP (Synapse, Indy, NetHTTP, ICS)

## When NOT to use

- Servidor HTTP Horse → `developer-delphi-to-fpc-horse-core`
- Serialização JSON ↔ DataSet standalone → `developer-delphi-to-fpc-dataset-serialize`
- JWT geração → `developer-delphi-to-fpc-horse-security`

## Documentos canônicos

- `app/package/docs/pacotes/RESTRequest4Delphi.md`
- `app/package/docs/pacotes/csv-adapter-restrequest4delphi.md`
- `app/package/docs/pacotes/dataset-serialize-adapter-restrequest4delphi.md`

---

## RESTRequest4Delphi

### IRequest — métodos principais

| Método | Descrição |
| --- | --- |
| `TRequest.New` | Cria nova instância |
| `BaseURL(url)` | URL base |
| `Resource(path)` | Recurso (acrescentado ao BaseURL) |
| `Get` | Executa GET → IResponse |
| `Post` | Executa POST → IResponse |
| `Put` | Executa PUT → IResponse |
| `Delete` | Executa DELETE → IResponse |
| `Patch` | Executa PATCH → IResponse |
| `AddHeader(name, value)` | Adiciona cabeçalho |
| `AddParam(name, value)` | Query param |
| `AddParam(name, value, kind)` | Com tipo (query, path, cookie…) |
| `AddBody(string)` | Corpo como string |
| `AddBody(TJSONObject)` | Corpo como TJSONObject |
| `AddBody(TStream)` | Corpo como stream |
| `AddField(name, value)` | Campo form-data |
| `AddFile(field, path)` | Ficheiro em multipart |
| `Token(value)` | Authorization: {value} |
| `TokenBearer(value)` | Authorization: Bearer {value} |
| `BasicAuthentication(user, pass)` | Basic Auth |
| `Accept(mime)` | Accept header |
| `ContentType(mime)` | Content-Type header |
| `Timeout(ms)` | Timeout em ms |
| `Retry(n)` | Número de retentativas |
| `Adapters(adapter)` | Adaptador de resposta |
| `OnBeforeExecute(cb)` | Hook antes do pedido |
| `OnAfterExecute(cb)` | Hook após resposta |
| `FullRequestURL` | URL completa com params |

### IResponse — propriedades

| Propriedade | Descrição |
| --- | --- |
| `StatusCode` | Código HTTP (200, 404…) |
| `StatusText` | Texto do status |
| `Content` | Corpo como string |
| `ContentType` | Content-Type da resposta |
| `Headers` | Cabeçalhos |

---

## Exemplos RESTRequest4Delphi

### GET básico

```pascal
uses RESTRequest4D;

var LResponse: IResponse;
begin
  LResponse := TRequest.New.BaseURL('http://localhost:8888/users')
    .AddHeader('HeaderName', 'HeaderValue')
    .AddParam('status', 'active')
    .Accept('application/json')
    .Get;
  if LResponse.StatusCode = 200 then
    ShowMessage(LResponse.Content);
end;
```

### POST com corpo JSON

```pascal
begin
  TRequest.New.BaseURL('http://localhost:8888/users')
    .ContentType('application/json')
    .AddBody('{"name":"Ana","email":"ana@empresa.pt"}')
    .Post;
end;
```

### PUT e DELETE

```pascal
// PUT
TRequest.New.BaseURL('http://localhost:8888/users/1')
  .ContentType('application/json')
  .AddBody('{"name":"Ana Atualizada"}')
  .Put;

// DELETE
TRequest.New.BaseURL('http://localhost:8888/users/1')
  .Accept('application/json')
  .Delete;
```

### Autenticação JWT Bearer

```delphi
TRequest.New.BaseURL('http://localhost:8888/protected')
  .TokenBearer(LJWTToken)
  .Accept('application/json')
  .Get;
```

### Basic Authentication

```delphi
TRequest.New.BaseURL('http://api.empresa.pt/protected')
  .BasicAuthentication('admin', 'senha')
  .Get;
```

### Tratar erros HTTP

```delphi
var LResponse: IResponse;
begin
  LResponse := TRequest.New.BaseURL('http://localhost:8888/users/999')
    .Accept('application/json')
    .Get;

  case LResponse.StatusCode of
    200: ShowMessage('OK: ' + LResponse.Content);
    404: ShowMessage('Não encontrado');
    401: ShowMessage('Não autorizado — renovar token');
  else
    raise Exception.CreateFmt('Erro HTTP %d: %s',
      [LResponse.StatusCode, LResponse.Content]);
  end;
end;
```

### Upload multipart

```delphi
TRequest.New.BaseURL('http://localhost:8888/upload')
  .ContentType('multipart/form-data')
  .AddFile('file', 'C:\relatorios\relatorio.pdf')
  .AddField('categoria', 'relatorio')
  .Post;
```

### Timeout e Retry

```delphi
TRequest.New.BaseURL('http://api-lenta.pt/dados')
  .Timeout(60000)  // 60 s
  .Retry(3)        // 3 tentativas
  .Get;
```

### Hooks — OnBeforeExecute / OnAfterExecute

```delphi
TRequest.New.BaseURL('http://localhost:8888/users')
  .OnBeforeExecute(
    procedure(ARequest: IRequest)
    begin
      if TokenExpirado then
        ARequest.TokenBearer(RenovarToken);
    end)
  .OnAfterExecute(
    procedure(AResponse: IResponse)
    begin
      TLogger.Log(Format('%d %s', [AResponse.StatusCode, AResponse.StatusText]));
    end)
  .Get;
```

### AddParam com tipo path segment

```delphi
// GET /users/42
TRequest.New.BaseURL('http://localhost:8888/users/{id}')
  .AddParam('id', '42', pkURLSEGMENT)
  .Get;
```

---

## Adaptador CSV — TCSVAdapterRESTRequest4D

### Sobrecargas de New

| Sobrecarga | Descrição |
| --- | --- |
| `New(filename, root)` | JSON → ficheiro CSV |
| `New(strings, root)` | JSON → TStrings |
| `New(filename, root, config)` | Ficheiro com config |
| `New(strings, root, config)` | TStrings com config |

### ICSVAdapterRESTRequest4DConfig

| Método | Descrição |
| --- | --- |
| `New` | Cria instância |
| `Separator(char)` | Separador de campos (padrão: ',') |

### Exemplos

```delphi
uses CSV.Adapter.RESTRequest4D;

// CSV para TStrings (Memo)
TRequest.New.BaseURL('http://localhost:9050/clients')
  .Adapters(TCSVAdapterRESTRequest4D.New(Memo1.Lines, ''))
  .Accept('application/json')
  .Get;

// CSV para ficheiro com separador ';' (Excel PT)
TRequest.New.BaseURL('http://localhost:9050/clients')
  .Adapters(
    TCSVAdapterRESTRequest4D.New(
      'C:\Exportacoes\relatorio.csv',
      '',
      TCSVAdapterRESTRequest4DConfig.New
        .Separator(';')
    )
  )
  .Accept('application/json')
  .Get;

// Com root element: {"items": [...]}
TRequest.New.BaseURL('http://localhost:9050/orders')
  .Adapters(
    TCSVAdapterRESTRequest4D.New(
      'C:\export\orders.csv',
      'items',
      TCSVAdapterRESTRequest4DConfig.New.Separator(';')
    )
  )
  .Get;
```

---

## Adaptador DataSet — TDataSetSerializeAdapter

### Sobrecargas de New

| Sobrecarga | Descrição |
| --- | --- |
| `New(dataset)` | JSON array → DataSet |
| `New(dataset, rootElement)` | JSON com chave raiz → DataSet |

### Exemplos

```delphi
uses RESTRequest4Delphi, DataSet.Serialize.Adapter.RESTRequest4D;

// Array JSON direto: [{"id":1,"name":"Ana"},...]
TRequest.New.BaseURL('http://localhost:8888/users')
  .Adapters(TDataSetSerializeAdapter.New(qryUsers))
  .Accept('application/json')
  .Get;
// qryUsers está populado

// Com root element: {"data": [...], "total": 50}
TRequest.New.BaseURL('http://localhost:8888/users')
  .Adapters(TDataSetSerializeAdapter.New(qryUsers, 'data'))
  .Accept('application/json')
  .Get;

// POST e re-hidratação: receber registo criado no DataSet
var LBody: TJSONObject;
LBody := TJSONObject.Create;
LBody.AddPair('name', 'Carlos').AddPair('email', 'carlos@emp.pt');
TRequest.New.BaseURL('http://localhost:8888/users')
  .ContentType('application/json')
  .AddBody(LBody)
  .Adapters(TDataSetSerializeAdapter.New(qryLastCreated))
  .Post;
```

---

## Motores HTTP (defines de compilação)

| Define | Motor | Padrão |
| --- | --- | --- |
| (nenhum) | RESTClient (Delphi) / fphttpclient (FPC) | Delphi/FPC |
| `RR4D_INDY` | Indy TIdHTTP | — |
| `RR4D_SYNAPSE` | Synapse THTTPSend | — |
| `RR4D_NETHTTP` | TNetHTTPClient | — |
| `RR4D_ICS` | ICS TWSocket | — |

**GestorERP:** motor em produção: `RR4D_SYNAPSE` (com libeay32/ssleay32 para HTTPS).

---

## Notas GestorERP

- Timeout padrão: 30 s
- Separador CSV: `;` para compatibilidade Excel PT
- `mtProducts` deve ter estrutura definida antes do Get (via `LoadStructure`)
- Token JWT renovado automaticamente no `OnBeforeExecute` se expirado

---

## Changelog (este arquivo)

- 1.0.0 (12/04/2026): Criação — skill de cliente HTTP com RESTRequest4Delphi e adaptadores.

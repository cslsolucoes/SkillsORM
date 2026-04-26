---
name: developer-delphi-to-fpc-horse-paginate
description: Middleware de paginação de respostas JSON para Horse. Cobre Paginate (padrão com summary, gpoDoNotIncludeSummary sem wrapper), header X-Paginate, query params limit/page, estrutura de resposta {docs, total, limit, page, pages}. Fonte: app/package/docs/pacotes/horse-paginate.md.
model: sonnet
thinking: minimal
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-horse-paginate_V1.0.0

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Middleware que pagina respostas JSON com base no cabeçalho `X-Paginate: true` e parâmetros `limit` e `page`.

## When to use

- Paginar listas grandes devolvidas como JSON array
- Implementar paginação server-side em endpoints GET
- Controlo client-side via `X-Paginate: true` + `?limit=N&page=N`

## When NOT to use

- Escrita (POST/PUT/DELETE) — paginação não aplicável
- Paginação SQL direta (preferir OFFSET/FETCH no SQL para tabelas muito grandes)

## Documento canônico

`app/package/docs/pacotes/horse-paginate.md`

---

## Paginate — sobrecargas

| Sobrecarga | Descrição |
| --- | --- |
| `Paginate` | Resposta com wrapper `{docs, total, limit, page, pages}` |
| `Paginate(options)` | `[gpoDoNotIncludeSummary]` → apenas array |

## Parâmetros de query

| Parâmetro | Padrão | Descrição |
| --- | --- | --- |
| `limit` | 25 | Itens por página |
| `page` | 1 | Página atual (base 1) |

---

## Estrutura de resposta padrão

```json
{
  "docs": [ {...}, {...} ],
  "total": 100,
  "limit": 10,
  "page": 2,
  "pages": 10
}
```

---

## Exemplos

### Servidor Horse

```delphi
uses System.SysUtils, Horse, Horse.Paginate, Horse.Jhonson,
     System.JSON, DBClient, DataSet.Serialize;

begin
  THorse
    .Use(Paginate)
    .Use(Jhonson);

  THorse.Get('/items',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var LAll: TJSONArray;
    begin
      qryItems.Open;
      LAll := qryItems.ToJSONArray;
      // Paginate corta conforme limit/page
      Res.Send<TJSONArray>(LAll);
    end);

  THorse.Listen(9000);
end.
```

### Sem wrapper (só array)

```delphi
THorse.Use(Paginate([gpoDoNotIncludeSummary]));
// Resposta: [...] (array puro, sem {docs, total, ...})
```

### Pedido do cliente (curl)

```bash
# Pede página 2, 10 itens
curl -H "X-Paginate: true" \
     "http://localhost:9000/items?limit=10&page=2"
```

### X-Total-Count manual

```delphi
THorse.Get('/products',
  procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  var LAll: TJSONArray;
  begin
    LAll := CarregarTodosOsProdutos;
    Res.RawWebResponse.CustomHeaders.Values['X-Total-Count'] :=
      IntToStr(LAll.Count);
    Res.Send<TJSONArray>(LAll);
  end);
```

### Exemplo completo

```delphi
// Servidor
uses Horse, Horse.Paginate, Horse.Jhonson, DataSet.Serialize;

begin
  THorse
    .Use(Paginate)
    .Use(Jhonson);

  THorse.Get('/products',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      qryProducts.Open;
      Res.Send<TJSONArray>(qryProducts.ToJSONArray);
    end);

  THorse.Listen(9000);
end.
```

```bash
# Página 3, 5 itens por página
curl -H "X-Paginate: true" \
     "http://localhost:9000/products?limit=5&page=3"
```

---

## Notas GestorERP

- Usar `X-Paginate` apenas em endpoints GET de listagem
- Para exports grandes: preferir paginação SQL (OFFSET/FETCH) em vez de carregar toda a tabela em memória
- `unit` a usar: `Horse.Paginate`
- Upstream: `bittencourtthulio/Horse-Paginate`

---

## Changelog (este arquivo)

- 1.0.0 (12/04/2026): Criação — skill middleware paginação.

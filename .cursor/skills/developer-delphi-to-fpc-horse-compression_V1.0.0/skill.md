---
name: developer-delphi-to-fpc-horse-compression
description: Middleware de compressão HTTP GZIP/DEFLATE para Horse. Cobre Compression() (padrão, com threshold, com tipos específicos TCompressionType), ordem de registro no pipeline e verificação Accept-Encoding. Fonte: app/package/docs/pacotes/horse-compression.md.
model: sonnet
thinking: minimal
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-horse-compression

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Middleware que comprime respostas HTTP com GZIP ou DEFLATE quando o cliente aceita (`Accept-Encoding`).

## When to use

- Reduzir tamanho de respostas JSON em produção
- Configurar threshold mínimo de compressão
- Selecionar algoritmo específico (GZIP, DEFLATE)

## When NOT to use

- Endpoints de streaming binário → `developer-delphi-to-fpc-horse-octet-stream` (não comprimir streams)
- Core do servidor → `developer-delphi-to-fpc-horse-core`

## Documento canônico

`app/package/docs/pacotes/horse-compression.md`

---

## Compression — sobrecargas

| Sobrecarga | Descrição |
| --- | --- |
| `Compression()` | Threshold padrão (1024 bytes), GZIP ou DEFLATE |
| `Compression(threshold)` | Threshold customizado em bytes |
| `Compression([tipos])` | Tipos específicos (TCompressionType) |

---

## Ordem no pipeline

**Compression deve ser o PRIMEIRO middleware** (antes de Jhonson):

```delphi
THorse
  .Use(Compression())   // 1.º
  .Use(Jhonson);        // 2.º
```

---

## Exemplos

### Compressão padrão

```delphi
uses Horse, Horse.Jhonson, Horse.Compression;

begin
  THorse
    .Use(Compression())
    .Use(Jhonson);

  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var I: Integer; LPong: TJSONArray;
    begin
      LPong := TJSONArray.Create;
      for I := 0 to 1000 do
        LPong.Add(TJSONObject.Create(TJSONPair.Create('ping', 'pong')));
      Res.Send(LPong);
    end);

  THorse.Listen(9000);
end;
```

### Threshold customizado

```delphi
// Comprimir apenas respostas > 512 bytes
THorse.Use(Compression(512));
```

### Tipo específico

```delphi
uses Horse.Compression;

THorse.Use(Compression([TCompressionType.gzip]));    // só GZIP
THorse.Use(Compression([TCompressionType.deflate])); // só DEFLATE
// Ambos (equivalente ao padrão):
THorse.Use(Compression([TCompressionType.gzip, TCompressionType.deflate]));
```

### Lazarus / FPC

```delphi
{$MODE DELPHI}{$H+}
uses Horse, Horse.Jhonson, Horse.Compression, fpjson, SysUtils;

begin
  THorse
    .Use(Compression())
    .Use(Jhonson);
  THorse.Get('/ping', GetPing);
  THorse.Listen(9000);
end.
```

### Verificar no cliente (curl)

```bash
curl -H "Accept-Encoding: gzip" http://localhost:9000/users --compressed -v
# Response: Content-Encoding: gzip
```

---

## Notas GestorERP

- Activo por defeito para respostas > 1 KB
- Não aplicar a endpoints de streaming binário (usar `horse-octet-stream`)
- `unit` a usar: `Horse.Compression`

---

## Changelog (este arquivo)

- 1.0.0 (12/04/2026): Criação — skill middleware compressão.

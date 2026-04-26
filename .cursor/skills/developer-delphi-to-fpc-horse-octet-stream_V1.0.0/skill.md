---
name: developer-delphi-to-fpc-horse-octet-stream
description: Middleware de streaming binário para Horse (application/octet-stream). Cobre OctetStream middleware, Res.Send<TStream>, TFileReturn (Stream, Name, Inline) e upload/download de ficheiros. Fonte: app/package/docs/pacotes/horse-octet-stream.md.
model: sonnet
thinking: minimal
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-horse-octet-stream

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Middleware para servir ou receber conteúdo binário (`application/octet-stream`) via streams em Horse — download/upload de ficheiros sem conversão JSON.

## When to use

- Fazer download de ficheiros (PDF, Excel, ZIP…)
- Upload de ficheiros binários no servidor
- Streaming de blobs sem conversão JSON
- Enviar ficheiro com metadados (nome, inline/attachment)

## When NOT to use

- JSON responses → `developer-delphi-to-fpc-horse-core`
- Compressão → `developer-delphi-to-fpc-horse-compression` (não combinar com streams binários)

## Documento canônico

`app/package/docs/pacotes/horse-octet-stream.md`

---

## OctetStream — middleware

| Função | Descrição |
| --- | --- |
| `OctetStream` | Ativa suporte a streams binários na resposta |

## TFileReturn — envio com metadados

| Propriedade | Descrição |
| --- | --- |
| `Stream` | TStream com o conteúdo |
| `Name` | Nome do ficheiro (Content-Disposition) |
| `Inline` | True = abrir no browser, False = forçar download |

---

## Exemplos

### Download de ficheiro simples

```delphi
uses Horse, Horse.OctetStream, System.Classes, System.SysUtils;

begin
  THorse.Use(OctetStream);

  THorse.Get('/stream',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var LStream: TFileStream;
    begin
      LStream := TFileStream.Create(
        ExtractFilePath(ParamStr(0)) + 'horse.pdf', fmOpenRead);
      Res.Send<TStream>(LStream);
      // OctetStream liberta o stream após envio
    end);

  THorse.Listen(9000);
end;
```

### Download com Content-Type explícito

```delphi
THorse.Get('/files/:name',
  procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  var LPath: string; LStream: TFileStream;
  begin
    LPath := ExtractFilePath(ParamStr(0)) + 'files\' + Req.Params['name'];
    if not FileExists(LPath) then
    begin
      Res.Status(404).Send('Ficheiro não encontrado');
      Exit;
    end;
    LStream := TFileStream.Create(LPath, fmOpenRead or fmShareDenyWrite);
    Res.Send<TStream>(LStream);
  end);
```

### PDF com forçar download

```delphi
THorse.Get('/reports/:id',
  procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  var LStream: TMemoryStream;
  begin
    LStream := GerarRelatorioPDF(Req.Params['id'].ToInteger);
    Res.ContentType('application/pdf')
       .AddHeader('Content-Disposition',
         'attachment; filename="relatorio-' + Req.Params['id'] + '.pdf"')
       .Send<TStream>(LStream);
  end);
```

### TFileReturn — com metadados

```delphi
THorse.Get('/image/:id',
  procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  var LFile: TFileReturn;
  begin
    LFile := TFileReturn.Create;
    LFile.Stream := CarregarImagem(Req.Params['id'].ToInteger);
    LFile.Name   := 'imagem-' + Req.Params['id'] + '.png';
    LFile.Inline := True; // abrir no browser (não forçar download)
    Res.Send<TFileReturn>(LFile);
  end);
```

### Upload de ficheiro binário

```delphi
THorse.Post('/upload',
  procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  var LStream: TMemoryStream; LDestino: string;
  begin
    LStream := TMemoryStream.Create;
    try
      LStream.CopyFrom(Req.Body<TStream>, 0);
      LDestino := ExtractFilePath(ParamStr(0)) + 'uploads\' +
        Req.Params['filename'];
      LStream.SaveToFile(LDestino);
      Res.Status(THTTPStatus.Created).Send('Guardado: ' + LDestino);
    finally
      LStream.Free;
    end;
  end);
```

### Lazarus / FPC

```delphi
{$MODE DELPHI}{$H+}
uses Horse, Horse.OctetStream, SysUtils, Classes;

procedure GetStream(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var LStream: TFileStream;
begin
  LStream := TFileStream.Create(
    ExtractFilePath(ParamStr(0)) + 'horse.pdf', fmOpenRead);
  Res.Send<TStream>(LStream).ContentType('application/pdf');
end;

begin
  THorse.Use(OctetStream);
  THorse.Get('/stream', GetStream);
  THorse.Listen(9000);
end.
```

---

## Notas GestorERP

- Validar extensão e tamanho máximo antes de persistir uploads
- Em produção: guardar ficheiros em pasta fora do webroot com permissões restritas
- Não combinar com `Compression()` em endpoints de stream binário
- `unit` a usar: `Horse.OctetStream`

---

## Changelog (este arquivo)

- 1.0.0 (12/04/2026): Criação — skill middleware octet-stream.

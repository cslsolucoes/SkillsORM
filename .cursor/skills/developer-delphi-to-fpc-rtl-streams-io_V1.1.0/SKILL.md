---
name: developer-delphi-to-fpc-rtl-streams-io
description: I/O com streams no RTL Delphi — TFileStream, TMemoryStream, TIOUtils, encoding, compressão e serialização.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-rtl-streams-io_V1.1.0

## Propósito

Dominar I/O com streams no RTL Delphi: `TStream`, `TFileStream`, `TMemoryStream`, `TStringStream`, `TBytesStream`, encoding/decoding, `TIOUtils`/`TPath`/`TFile`/`TDirectory`, leitura/escrita binária, compressão e serialização.

## Quando usar esta skill

- Leitura/escrita de arquivos binários ou texto (TFileStream, TStreamReader/Writer)
- Buffers em memória sem arquivo (TMemoryStream, TStringStream)
- Conversão e encoding de strings (TEncoding, TStreamReader com BOM)
- Manipulação de caminhos e sistema de arquivos (TPath, TFile, TDirectory)
- Serialização/deserialização binária customizada
- Transferência entre streams (CopyFrom)

## Conteúdo

### exemplos/

| Arquivo | Tema |
|---------|------|
| `tstream_basico.pas` | TStream API: Read/Write/Seek/CopyFrom/Position/Size |
| `file_stream.pas` | TFileStream: modos de abertura, append, leitura linha a linha |
| `stream_encoding.pas` | TStreamReader/Writer, TEncoding (UTF-8/UTF-16/ANSI), BOM |
| `ioutils.pas` | TPath, TFile, TDirectory — sistema de arquivos cross-platform |
| `binary_io.pas` | Leitura/escrita binária tipada: TBinaryWriter/TBinaryReader |

### consultas_rapidas/

| Arquivo | Tema |
|---------|------|
| `stream_modos.md` | Flags fmCreate/fmOpenRead/fmOpenWrite/fmShareXxx |
| `encoding_referencia.md` | TEncoding.UTF8/Unicode/ASCII/GetEncoding; DetectEncoding |
| `ioutils_referencia.md` | TPath/TFile/TDirectory — métodos essenciais e exemplos |

### templates/

| Arquivo | Uso |
|---------|-----|
| `TEMPLATE_file_processor.pas` | Processador de arquivo linha a linha com TStreamReader |
| `TEMPLATE_binary_serializer.pas` | Serialização/deserialização binária de record customizado |

## Fontes

- `Doc-Delphi/delphi12-libraries_chm_decompiled/` — System.Classes (TStream, TFileStream, TMemoryStream)
- `Doc-Delphi/delphi12-libraries_chm_decompiled/` — System.IOUtils

## Changelog

- V1.1.0 (2026-04-11): Criação inicial com 5 exemplos, 3 consultas_rapidas, 2 templates

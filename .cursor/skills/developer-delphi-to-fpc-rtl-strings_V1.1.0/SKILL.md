---
name: developer-delphi-to-fpc-rtl-strings
description: Strings no RTL Delphi — TStringHelper, TStringBuilder, TRegEx, Format, encoding UTF-8 e conversões.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-rtl-strings_V1.1.0

## Propósito

Dominar manipulação de strings no RTL Delphi: `TStringHelper`, `TStringBuilder`, `Format` com especificadores, `TRegEx`, encoding UTF-8/Unicode, e conversões de/para string (números, datas, moeda).

## Quando usar esta skill

- Manipulação e transformação de strings (Contains, Split, Replace, Trim, Pad)
- Concatenação de alta performance (TStringBuilder)
- Formatação com Format / FormatFloat / FormatDateTime
- Validação e extração com expressões regulares (TRegEx)
- Conversão entre tipos e strings (StrToInt, FloatToStrF, DateTimeToStr)
- Encoding UTF-8 e controle de codepage

## Conteúdo

### exemplos/

| Arquivo | Tema |
|---------|------|
| `string_helpers.pas` | TStringHelper: Contains, StartsWith, Split, Trim, IndexOf, Pad |
| `string_builder.pas` | TStringBuilder: Append, Insert, Delete, Replace, performance |
| `format_strings.pas` | Format: %s, %d, %.2f, %x, %e, padding, alinhamento |
| `regex_delphi.pas` | TRegEx: IsMatch, Match, Replace, Split, Groups, flags |
| `string_encoding.pas` | UTF8Encode/Decode, TEncoding, AnsiString vs string |
| `string_conversion.pas` | StrToInt/Float/Date, IntToStr, FloatToStrF, FormatDateTime |

### consultas_rapidas/

| Arquivo | Tema |
|---------|------|
| `string_helper_api.md` | Tabela completa de TStringHelper methods |
| `format_especificadores.md` | %s, %d, %f, %g, %e, %x, padding, alinhamento |
| `regex_flags.md` | roIgnoreCase, roMultiLine, roSingleLine, roExplicitCapture |

### templates/

| Arquivo | Uso |
|---------|-----|
| `TEMPLATE_string_parser.pas` | Parser com TRegEx + TStringBuilder |
| `TEMPLATE_string_format.pas` | Formatação de CPF/CNPJ, moeda, datas |

## Fontes

- `Doc-Delphi/delphi12-libraries_chm_decompiled/` — System.SysUtils (TStringHelper, Format)
- `Doc-Delphi/delphi13-libraries_chm_decompiled/` — updates Delphi 13
- `Doc-Delphi/delphi12-libraries_chm_decompiled/` — System.RegularExpressions (TRegEx)

## Changelog

- V1.1.0 (2026-04-11): Criação inicial com 6 exemplos, 3 consultas_rapidas, 2 templates

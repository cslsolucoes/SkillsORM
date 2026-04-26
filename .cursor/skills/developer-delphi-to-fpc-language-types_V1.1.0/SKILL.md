---
name: developer-delphi-to-fpc-language-types
description: Tipos do Object Pascal/Delphi — primitivos, records, enums, sets, ponteiros e tipos avançados.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-language-types_V1.1.0

## O que é esta skill

Skill especializada em **tipos do Object Pascal/Delphi**: primitivos numéricos,
strings, arrays estáticos e dinâmicos, records (simples e variant), enumerados,
sets e ponteiros.

---

## Quando usar esta skill

- Escolher o tipo numérico correto para um campo (Integer vs Int64 vs Cardinal)
- Trabalhar com strings Unicode, AnsiString, UTF8String ou ShortString
- Criar records como Value Objects (DTOs) com métodos
- Definir enumerações e conjuntos (sets) para flags
- Operar arrays dinâmicos com SetLength, Copy, Insert, TArray<T>
- Usar ponteiros com segurança (New/Dispose, nil check)

---

## Referência rápida de tipos

### Inteiros

| Tipo | Bytes | Range | Plataforma |
|------|-------|-------|-----------|
| `ShortInt` | 1 | -128 .. 127 | qualquer |
| `Byte` | 1 | 0 .. 255 | qualquer |
| `SmallInt` | 2 | -32768 .. 32767 | qualquer |
| `Word` | 2 | 0 .. 65535 | qualquer |
| `Integer` | 4 | -2^31 .. 2^31-1 | qualquer |
| `Cardinal` | 4 | 0 .. 2^32-1 | qualquer |
| `Int64` | 8 | -2^63 .. 2^63-1 | qualquer |
| `UInt64` | 8 | 0 .. 2^64-1 | qualquer |
| `NativeInt` | 4/8 | plataforma | Win32=4, Win64=8 |

### Float

| Tipo | Bytes | Precisão |
|------|-------|---------|
| `Single` | 4 | ~7 dígitos |
| `Double` | 8 | ~15 dígitos |
| `Extended` | 10/8 | ~18-19 dígitos (x87; Win64 usa Double) |
| `Currency` | 8 | fixed 4 casas, sem erro de arredondamento |

### Strings

| Tipo | Encoding | Uso |
|------|---------|-----|
| `string` | UTF-16 (UnicodeString) | padrão Delphi 2009+ |
| `AnsiString` | sistema (CP_ACP) | legacy |
| `UTF8String` | UTF-8 | serialização, JSON, arquivos |
| `ShortString` | ANSI, stack | até 255 chars, legado |
| `RawByteString` | sem conversão | binário |

---

## Arquivos desta skill

| Arquivo | Conteúdo |
|---------|---------|
| `exemplos/tipos_primitivos.pas` | Integer, Int64, Cardinal, Single, Double, Currency |
| `exemplos/strings_unicode.pas` | string, AnsiString, UTF8String, conversões |
| `exemplos/arrays_estaticos.pas` | array[0..N], multidimensional, Low/High |
| `exemplos/arrays_dinamicos.pas` | dynamic array, SetLength, Copy, TArray<T> |
| `exemplos/records_basicos.pas` | record com campos, métodos e class function |
| `exemplos/records_avancados.pas` | variant record, packed record |
| `exemplos/enumerados.pas` | enum, set of enum, operações |
| `exemplos/pointers_basico.pas` | Pointer, ^T, New/Dispose, nil |
| `consultas_rapidas/tipos_numericos.md` | tabela tipos + range + bytes |
| `consultas_rapidas/string_tipos.md` | comparativo de todos os tipos string |
| `consultas_rapidas/array_operations.md` | Low/High, SetLength, Copy, Insert |
| `consultas_rapidas/record_vs_class.md` | valor vs referência; stack vs heap |
| `templates/TEMPLATE_record_dto.pas` | DTO como record com factory e conversão |
| `templates/TEMPLATE_enum_flags.pas` | enum + set para flags |
| `templates/TEMPLATE_array_helpers.pas` | operações comuns em TArray<T> |

---

## Skills relacionadas

| Skill | Uso |
|-------|-----|
| `developer-delphi-to-fpc-language-oop_V1.1.0` | Classes, interfaces, herança, polimorfismo |
| `developer-delphi-to-fpc-language-core_V1.1.0` | Fundamentos: compilador, diretivas, módulos |
| `developer-delphi-to-fpc-rtl-and-units_V1.1.0` | RTL: SysUtils, Classes, Generics |

# Tipos String em Delphi — Comparativo

## Tabela comparativa

| Tipo | Encoding | Bytes/char | Max length | Gerenciado? | Uso |
|------|---------|-----------|-----------|------------|-----|
| `string` (UnicodeString) | UTF-16 | 2 (BMP) / 4 (supl.) | 2GB | Sim (RefCount) | **padrão — use este** |
| `AnsiString` | sistema (CP_ACP) | 1 | 2GB | Sim (RefCount) | APIs legadas ANSI |
| `UTF8String` | UTF-8 | 1-4 | 2GB | Sim (RefCount) | JSON, HTTP, arquivos |
| `RawByteString` | nenhum | 1 | 2GB | Sim (RefCount) | bytes brutos |
| `ShortString` | ANSI | 1 | 255 | Não (stack) | legado, interop C |
| `WideString` | UTF-16 | 2 | 2GB | COM (SysAlloc) | COM/OLE |
| `PChar` / `PWideChar` | UTF-16 | 2 | nenhum | Não | APIs Win32 |
| `PAnsiChar` | ANSI | 1 | nenhum | Não | APIs ANSI Win32 |

## Quando usar cada um

```
string        → padrão para tudo: UI, lógica de negócio, log
UTF8String    → serializar/deserializar JSON, XML, HTTP body, arquivos de texto
AnsiString    → interop com DLL ou API que espera const char* (ANSI)
RawByteString → buffers binários sem conversão de codepage
ShortString   → raramente — só para compatibilidade com código muito antigo
WideString    → só para COM/OLE automation (CreateOleObject, etc.)
PChar         → passar para API Win32 que espera LPWSTR
```

## Conversões seguras

```pascal
// string → UTF8String (para JSON/HTTP)
var U8: UTF8String := UTF8String(S);  // ou UTF8Encode(S)

// UTF8String → string (receber de HTTP)
var S: string := string(U8);          // ou UTF8Decode(U8)

// string → bytes (encoding específico)
var Bytes := TEncoding.UTF8.GetBytes(S);
var Bytes2 := TEncoding.GetEncoding(1252).GetBytes(S); // windows-1252

// bytes → string
var S2 := TEncoding.UTF8.GetString(Bytes);

// string → PChar (para API Win32)
procedure Win32Func(S: string);
begin
  SomeWinAPI(PChar(S)); // PChar(S) = ponteiro para o buffer interno
  // CUIDADO: não armazenar PChar(S) fora do escopo de S
end;
```

## Reference Counting — como funciona

```pascal
var A := 'Hello';  // buffer alocado, RefCount=1
var B := A;         // B compartilha o buffer, RefCount=2
B := B + ' World';  // COW (Copy-on-Write): B ganha novo buffer, A inalterado
// Quando B sai do escopo: RefCount do novo buffer = 0, liberado
// Quando A sai do escopo: RefCount do original = 0, liberado
```

## Operações mais comuns

```pascal
Length(S)              // número de WideChar (não de grafemas Unicode)
S[1]                   // primeiro char (1-based)
S + ' texto'           // concatenação (cria novo buffer)
Trim(S)                // remove espaços/tabs nas extremidades
S.ToUpper / S.ToLower  // maiúsculas / minúsculas
S.Contains('x')        // true se contém
S.StartsWith('pre')    // true se começa com
S.Replace('a','b')     // substitui primeira ocorrência
S.Replace('a','b',[rfReplaceAll]) // substitui todas
S.Split([','])         // divide em TArray<string>
Format('%s=%d',[S,N])  // formatar string
IntToStr(N)            // inteiro para string
StrToIntDef(S, 0)      // string para inteiro, default 0 se falhar
```

## Armadilhas

```pascal
// ERRO: comparar AnsiString com string sem considerar codepage
if AnsiS = UnicodeS then ... // pode dar resultado errado

// CUIDADO: Length conta WideChar, não grafemas
// '🌍'.Length = 2 (par surrogado UTF-16)

// CUIDADO: ShortString[0] = comprimento (byte), não primeiro char
var Short: ShortString := 'Hi';
Writeln(Ord(Short[0]));  // 2 (comprimento)
Writeln(Short[1]);       // 'H' (primeiro char)
```

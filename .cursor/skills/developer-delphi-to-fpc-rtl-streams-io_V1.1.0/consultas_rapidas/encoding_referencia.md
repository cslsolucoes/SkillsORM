# TEncoding — Referência Rápida

## Encodings padrão (singletons — não liberar)

```pascal
TEncoding.UTF8       // UTF-8 sem BOM (mais comum)
TEncoding.Unicode    // UTF-16 LE com BOM
TEncoding.BigEndianUnicode  // UTF-16 BE
TEncoding.ASCII      // US-ASCII (7-bit)
TEncoding.ANSI       // CodePage padrão do SO (ex.: 1252 no Windows)
TEncoding.Default    // Alias para ANSI (legacy)
```

---

## Criar encoding por CodePage (liberar com Free)

```pascal
var Enc := TEncoding.GetEncoding(1252);  // Windows-1252 (Latin-1 West)
try
  ...
finally
  Enc.Free;  // GetEncoding cria nova instância — SEMPRE liberar
end;

// CodePages comuns:
// 1252 — Windows Latin-1 (Europa Ocidental)
// 1250 — Windows Latin-2 (Europa Central)
// 65001 — UTF-8
// 1200 — UTF-16 LE
// 28591 — ISO-8859-1
```

---

## Operações essenciais

```pascal
// String → Bytes
var Bytes := TEncoding.UTF8.GetBytes('Texto com ação');

// Bytes → String
var S := TEncoding.UTF8.GetString(Bytes);

// Bytes com offset/count
var S := TEncoding.UTF8.GetString(Bytes, 3, 10);

// Tamanho sem converter
var N := TEncoding.UTF8.GetByteCount('Texto');

// BOM (Byte Order Mark)
var Preamble := TEncoding.UTF8.GetPreamble;    // EF BB BF (3 bytes)
var Preamble := TEncoding.Unicode.GetPreamble; // FF FE (2 bytes)
// Se não tiver BOM, GetPreamble retorna array vazio
```

---

## DetectEncoding — ler BOM de arquivo/buffer

```pascal
// De arquivo
var Raw := TFile.ReadAllBytes('arquivo.txt');
var Enc: TEncoding;
var BOMLen := TEncoding.GetBufferEncoding(Raw, Enc);
// BOMLen = tamanho do BOM (0 se não detectado → usa default)
// Enc = encoding detectado (ou UTF-8 se não detectado)
try
  var Conteudo := Enc.GetString(Raw, BOMLen, Length(Raw) - BOMLen);
finally
  if not TEncoding.IsStandardEncoding(Enc) then Enc.Free;
end;

// GetBufferEncoding com default explícito:
var BOMLen := TEncoding.GetBufferEncoding(Raw, Enc, TEncoding.UTF8);
// Se não detectar BOM, usa UTF-8 como fallback
```

---

## TStreamReader — detectar encoding ao abrir

```pascal
// True = detectBOM automaticamente
SR := TStreamReader.Create('arquivo.txt', TEncoding.UTF8, True {detectBOM});
try
  Writeln(SR.CurrentEncoding.EncodingName);  // encoding real detectado
  while not SR.EndOfStream do
    Writeln(SR.ReadLine);
finally
  SR.Free;
end;
```

---

## TStreamWriter — controle de BOM

```pascal
// Com BOM (padrão ao usar TEncoding diretamente)
SW := TStreamWriter.Create('arq.txt', False, TEncoding.UTF8);

// Sem BOM — usar TEncoding.UTF8.Clone com preamble vazio (workaround)
// Ou escrever bytes manualmente sem preamble:
var MS := TMemoryStream.Create;
var Bytes := TEncoding.UTF8.GetBytes(Conteudo);  // sem BOM
MS.WriteBuffer(Bytes[0], Length(Bytes));
MS.SaveToFile('sem_bom.txt');
```

---

## Conversão entre encodings

```pascal
// UTF-8 → UTF-16
var BytesUTF8  := TFile.ReadAllBytes('utf8.txt');
var Texto      := TEncoding.UTF8.GetString(BytesUTF8);
var BytesUTF16 := TEncoding.Unicode.GetBytes(Texto);
TFile.WriteAllBytes('utf16.txt', BytesUTF16);

// Ou via streams:
var SR := TStreamReader.Create('utf8.txt',  TEncoding.UTF8,    True);
var SW := TStreamWriter.Create('utf16.txt', False, TEncoding.Unicode);
try
  while not SR.EndOfStream do SW.WriteLine(SR.ReadLine);
finally
  SR.Free; SW.Free;
end;
```

---

## IsStandardEncoding — quando NÃO liberar

```pascal
// Verificar se o encoding é um singleton padrão (não liberar)
if not TEncoding.IsStandardEncoding(Enc) then
  Enc.Free;
// IsStandardEncoding retorna True para: UTF8, Unicode, BigEndianUnicode, ASCII, ANSI, Default
```

---

## Tabela rápida

| Encoding | BOM | Bytes por char ASCII | Uso |
|----------|-----|---------------------|-----|
| UTF-8 | EF BB BF (opcional) | 1 | Web, arquivos texto modernos |
| UTF-16 LE | FF FE | 2 | Windows nativo, strings Delphi |
| UTF-16 BE | FE FF | 2 | Big-endian platforms |
| ASCII | — | 1 | Protocolo simples, 7-bit |
| Windows-1252 | — | 1 | Legacy Europa Ocidental |

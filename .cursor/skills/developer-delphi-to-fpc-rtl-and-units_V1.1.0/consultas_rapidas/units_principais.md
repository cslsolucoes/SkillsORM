# Units RTL Delphi — Tabela de Referência

## Units mais usadas por categoria

### Tipos e utilitários fundamentais

| Unit | Responsabilidade principal | Destaques |
|------|---------------------------|-----------|
| `System` | Tipos primitivos, operadores, Move/FillChar | Implicitamente incluída |
| `System.SysUtils` | String helpers, conversões, exceções, datas | `TStringHelper`, `Format`, `StrToInt`, `TFormatSettings` |
| `System.StrUtils` | Funções de string legadas e algumas modernas | `PosEx`, `IfThen`, `ReverseString`, `DupeString` |
| `System.DateUtils` | Aritmética de datas/horas | `DateAdd`, `DateDiff`, `DayOfWeek`, `WeekOfYear`, `SecondsBetween` |
| `System.Math` | Funções matemáticas | `Max`, `Min`, `Power`, `Log2`, `RoundTo`, `IsNaN`, `IsInfinite` |
| `System.Variants` | Tipo `Variant` e conversões | `VarIsNull`, `VarIsEmpty`, `VarType` |
| `System.Types` | Tipos simples (TPoint, TRect, TSize) | `TArray<T>`, `TStringDynArray` |

### Coleções e generics

| Unit | Responsabilidade |
|------|-----------------|
| `System.Generics.Collections` | `TList<T>`, `TDictionary<K,V>`, `TObjectList<T>`, `TObjectDictionary`, `TQueue<T>`, `TStack<T>`, `TSortedList<K,V>` |
| `System.Generics.Defaults` | `IComparer<T>`, `TComparer<T>`, `IEqualityComparer<T>`, `TEqualityComparer<T>` |
| `System.Classes` | `TStringList`, `TList` (não-genérica), `TStream`, `TStringStream`, `TBinaryWriter/Reader`, `TComponent` |

### I/O e sistema de arquivos

| Unit | Responsabilidade |
|------|-----------------|
| `System.IOUtils` | `TPath`, `TFile`, `TDirectory` — operações de alto nível |
| `System.Classes` | `TFileStream`, `TMemoryStream`, `TBytesStream`, `TStreamReader`, `TStreamWriter` |
| `System.SysUtils` | `DeleteFile`, `RenameFile`, `FileExists`, `DirectoryExists` (legacy) |

### Strings e encoding

| Unit | Responsabilidade |
|------|-----------------|
| `System.SysUtils` | `TStringHelper`, `Format`, `FormatDateTime`, `UTF8Encode/Decode` |
| `System.Classes` | `TEncoding`, `TStringBuilder` |
| `System.RegularExpressions` | `TRegEx`, `TMatch`, `TMatchCollection`, `TRegExOptions` |
| `System.Character` | `TCharacter` — Unicode categories, `IsLetter`, `IsDigit` |

### Threading e sincronização

| Unit | Responsabilidade |
|------|-----------------|
| `System.SyncObjs` | `TCriticalSection`, `TEvent`, `TMutex`, `TSemaphore`, `TMultiReadExclusiveWriteSynchronizer` |
| `System.Classes` | `TThread`, `TThreadList<T>` |
| `System.Threading` | `TTask`, `TParallel`, `TParallel.For` |
| `System.SysUtils` | `TMonitor` |

### RTTI e reflexão

| Unit | Responsabilidade |
|------|-----------------|
| `System.Rtti` | `TRttiContext`, `TRttiType`, `TRttiProperty`, `TRttiMethod` |
| `System.TypInfo` | `GetPropInfo`, `GetPropValue`, `PropInfo` (legacy) |

### Serialização e persistência

| Unit | Responsabilidade |
|------|-----------------|
| `System.JSON` | `TJSONObject`, `TJSONArray`, `TJSONValue` |
| `System.JSONConv` / `REST.Json` | `TJson.ObjectToJsonString`, `TJson.JsonToObject` |
| `Xml.XMLDoc` | `IXMLDocument`, `LoadXMLDocument` |
| `Data.Bind.ObjectScope` | LiveBindings / data binding |

### Rede e protocolos

| Unit | Responsabilidade |
|------|-----------------|
| `System.Net.HttpClient` | `THTTPClient`, `Get`/`Post`/`Put`/`Delete` |
| `System.Net.URLClient` | `TURI`, `TCredentials` |
| `IdHTTP` (Indy) | HTTP client legado |

### Banco de dados (FireDAC)

| Unit | Responsabilidade |
|------|-----------------|
| `FireDAC.Stan.Intf` | `IFDStanObject` |
| `FireDAC.Comp.Client` | `TFDConnection`, `TFDQuery`, `TFDCommand` |
| `FireDAC.Stan.Def` | `TFDConnectionDef` |
| `FireDAC.Phys.SQLite` | Driver SQLite |
| `FireDAC.Phys.PG` | Driver PostgreSQL |

---

## Compatibilidade Delphi vs FPC/Lazarus

| Unit Delphi | Equivalente FPC/Lazarus | Observação |
|-------------|------------------------|------------|
| `System.Generics.Collections` | `fgl` (TFPGList etc.) | API diferente; usar `{$IFDEF FPC}` |
| `System.IOUtils` | `FileUtil` (Lazarus) | `FindAllFiles`, `CopyFile` etc. |
| `System.RegularExpressions` | `RegExpr` | Unidade externa no FPC |
| `System.Threading` | `MTProcs` | `ProcThreadPool.DoParallelLocalProc` |
| `System.JSON` | `fpjson` / `jsonparser` | API diferente |
| `System.Classes` | `Classes` | Compatível (mesmo nome, RTL comum) |
| `System.SysUtils` | `SysUtils` | Compatível (mesmo nome) |

---

## Blocos `uses` mais comuns por cenário

```pascal
// Coleções genéricas
uses System.Generics.Collections, System.Generics.Defaults;

// I/O completo
uses System.Classes, System.IOUtils, System.SysUtils;

// Strings + regex
uses System.SysUtils, System.RegularExpressions;

// Threading
uses System.Classes, System.SyncObjs, System.Threading;

// JSON REST
uses System.JSON, REST.Json, System.Net.HttpClient;

// Tudo RTL usual
uses
  System.SysUtils, System.Classes, System.IOUtils,
  System.Generics.Collections, System.Generics.Defaults,
  System.RegularExpressions, System.DateUtils, System.Math;
```

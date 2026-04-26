---
name: developer-delphi-to-fpc-shared-libraries-windows
description: Criar, exportar e carregar DLLs em Windows com Delphi e FPC — projeto library, cláusula exports, DllProc, LoadLibrary/GetProcAddress, calling conventions Win32/Win64, configuração .dproj multi-plataforma e decisão BPL vs DLL. Inclui aviso crítico sobre fronteira de memória entre DLLs.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-shared-libraries-windows

## Versão interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |
| **Criado**      | 2026-04-24 |
| **Família**     | M — Serviços e Bibliotecas |

## Responsabilidade única

Criar, exportar e carregar DLLs em Windows com Delphi e FPC. Cobre: projecto `library`, cláusula `exports` (alias, índice, resident), `DllProc` para notificações do SO, `LoadLibrary`/`GetProcAddress` com tratamento de erros robusto, calling conventions por plataforma (Win32/Win64/Linux64), configuração `.dproj` multi-plataforma e decisão entre `.dll`, `.bpl` e `.so`. Inclui o aviso crítico sobre fronteira de memória — leitura obrigatória antes de qualquer outro tópico.

## When to use

- Criar uma DLL com Delphi ou FPC para Windows (Win32 ou Win64).
- Consumir uma DLL dinamicamente com `LoadLibrary`/`GetProcAddress`.
- Configurar `.dproj` para saída multi-plataforma (Win32+Win64+Linux64).
- Decidir entre `.dll`, `.bpl` e `.so`.
- Resolver crashes de fronteira de memória entre DLL e host.

## When NOT to use

- Carregar `.so` em Linux → usar `developer-delphi-to-fpc-shared-libraries-linux`.
- Sistema de plugins via interfaces → usar `developer-delphi-to-fpc-shared-libraries-plugins`.
- Serviços Windows → usar `developer-delphi-windows-services-setup`.
- COM/ActiveX clássico — skill separada de COM.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-to-fpc-build` | Confirmar toolchain configurada antes de gerar DLL |

## Referências cruzadas

- `developer-delphi-to-fpc-shared-libraries-linux` — carregamento `.so` em Linux via dlopen/dlsym
- `developer-delphi-to-fpc-shared-libraries-plugins` — sistema de plugins via interfaces COM-compatible

---

## ⚠️ AVISO CRÍTICO: Fronteira de Memória entre DLLs

> **Esta é a causa mais comum de crashes silenciosos e corrupção de heap em DLLs Delphi.**
> Leia esta secção ANTES de qualquer outra.

### O problema

Cada módulo (`.exe`, `.dll`, `.so`) compilado com Delphi tem o **seu próprio memory manager** (FastMM por defeito no Delphi 11+, HeapMM em versões antigas). Quando um objecto é alocado no heap da DLL e libertado pelo host, ou vice-versa, o resultado é **corrupção silenciosa de heap** — às vezes crashando imediatamente, às vezes horas depois.

```pascal
// DLL (memory manager A)
function CreateList: TStringList; stdcall;
begin
  Result := TStringList.Create; // alocado no heap da DLL
end;

// Host (memory manager B)
var L: TStringList;
L := CreateList;
L.Free; // CRASH — libera memória do heap errado
```

O mesmo problema ocorre com:
- `string` / `AnsiString` / `UnicodeString` — reference counting cruzado entre heaps
- `TBytes` / `TArray<T>` — array dinâmico alocado no heap errado
- Qualquer `TObject` alocado na DLL e destruído no host (ou vice-versa)

### Soluções (da mais simples à mais robusta)

#### A. ShareMem (apenas Windows, mesmo compilador, mesmo processo)

```pascal
// PRIMEIRA unit em TODOS os .dpr que partilham objectos (DLL e host)
uses
  ShareMem, // DEVE ser o PRIMEIRO item na cláusula uses do .dpr
  System.SysUtils,
  System.Classes,
  ...;
```

**Prós:** simples, suporta `string` e `TObject` na fronteira.
**Contras:** requer `BORLNDMM.DLL` no directório da aplicação; não funciona entre compiladores diferentes; não funciona em Linux.

#### B. Apenas tipos POD (mais seguro e portável)

```pascal
// Apenas tipos Plain Old Data na interface da DLL
function CreateObject(out AHandle: Pointer): LongBool; stdcall;
procedure DestroyObject(AHandle: Pointer); stdcall;
function GetName(AHandle: Pointer; ABuffer: PChar; ASize: Integer): Integer; stdcall;
function GetCount(AHandle: Pointer): Integer; stdcall;
```

Tipos **SEGUROS** de passar pela fronteira sem ShareMem:
- `Integer`, `Int64`, `Cardinal`, `Int8`/`UInt8`/`Int16`/`UInt16`
- `Single`, `Double`, `Extended` (cuidado: `Extended` é 80-bit em x86, 64-bit em x64)
- `Boolean`, `LongBool`, `WordBool`
- `PChar` / `PWideChar` / `PAnsiChar` (buffer alocado pelo caller, preenchido pelo callee)
- `Pointer` opaco — handle que só a DLL interpreta internamente

Tipos **PERIGOSOS** sem ShareMem:
- `string` / `AnsiString` / `WideString` — excepção: `WideString` é COM-safe (veja abaixo)
- `TObject` e qualquer descendente
- `TList`, `TStringList`, qualquer classe RTL
- `TArray<T>` / `TBytes` — arrays dinâmicos Delphi
- `Variant` — internamente usa `string` e `IInterface`

**Excepção especial:** `WideString` usa o alocador COM (`SysAllocString`/`SysFreeString`) e é **seguro** na fronteira em chamadas `stdcall`/`safecall` — mas é mais lento que `PChar`.

#### C. Interface approach — RECOMENDADO para DLL Delphi ↔ Delphi

```pascal
// A fábrica exportada devolve uma interface (reference counted por COM)
// A interface gere o seu próprio tempo de vida — sem problema de heap
function CreatePlugin: IMyPlugin; stdcall;
```

Interfaces Delphi implementam `IInterface` (equivalente a `IUnknown` COM). O reference counting (`_AddRef`/`_Release`) é definido pela classe, que reside **na DLL** — portanto a memória é sempre gerida pelo mesmo módulo que a alocou. O host simplesmente chama `_Release` quando a interface sai de scope, e a DLL liberta a memória correctamente.

---

## 1. Sintaxe de Projecto Library

```pascal
library MinhaDLL;

{$R *.res}  // recursos (ícone, manifesto, versão)

uses
  // ShareMem AQUI se necessário — ver secção acima
  System.SysUtils,
  System.Classes,
  uMinhaDLLImpl in 'uMinhaDLLImpl.pas';

exports
  MinhaFuncao,
  OutraFuncao name 'OutraFuncaoExportada',  // alias público
  TerceiraFuncao index 1,                   // exportar por índice numérico
  QuartaFuncao index 2 name 'Quarta';       // índice + alias

begin
  // código de inicialização opcional
  // NUNCA chamar LoadLibrary aqui (deadlock no loader lock)
end.
```

**Ficheiro `.dproj`** deve ter:
```xml
<DCC_ProjectType>Library</DCC_ProjectType>
```

**Output produzido:**
- Windows: `MinhaDLL.dll`
- Linux 64-bit (PAServer): `libMinhaDLL.so` (RAD Studio gere o prefixo `lib` automaticamente)

---

## 2. Cláusula `exports` — Referência Completa

```pascal
exports
  // Exportação simples — nome público = nome Pascal
  MinhaFuncao,

  // Alias — nome público diferente do nome Pascal
  MinhaFuncaoInterna name 'MinhaFuncao',

  // Por índice — permite GetProcAddress(h, MAKEINTRESOURCE(1))
  ProcessarDados index 1,

  // Índice + alias
  ProcessarDadosV2 index 2 name 'ProcessarDados2',

  // resident — mantém o nome na memória (obsoleto em Win64, ignorado)
  FuncaoLegado resident;
```

**Verificar exports após compilação:**
```
dumpbin /exports MinhaDLL.dll          (Windows — Visual Studio tools)
objdump -T libMinhaDLL.so             (Linux)
```

---

## 3. DllProc — Notificações do SO

```pascal
library MinhaDLL;

uses
  Winapi.Windows;

var
  GSavedDLLProc: TDLLProc;

procedure DLLHandler(Reason: Integer);
begin
  case Reason of
    DLL_PROCESS_ATTACH:
      begin
        // DLL carregada no processo — inicializar recursos globais
        // ATENÇÃO: não chamar LoadLibrary aqui (deadlock no Loader Lock)
        // ATENÇÃO: não criar janelas ou threads pesadas aqui
      end;

    DLL_PROCESS_DETACH:
      begin
        // DLL prestes a ser descarregada — cleanup obrigatório
        // Libertar handles, fechar ficheiros, destruir singletons
      end;

    DLL_THREAD_ATTACH:
      begin
        // Uma nova thread foi criada no processo host
        // Raramente necessário — maioria das DLLs ignora
      end;

    DLL_THREAD_DETACH:
      begin
        // Uma thread terminou — libertar TLS (Thread Local Storage) se usado
      end;
  end;

  // Encadear com o handler anterior (boa prática)
  if Assigned(GSavedDLLProc) then
    GSavedDLLProc(Reason);
end;

exports
  MinhaFuncao;

initialization
  GSavedDLLProc := DLLProc;
  DLLProc := @DLLHandler;
  DLLHandler(DLL_PROCESS_ATTACH);

finalization
  DLLHandler(DLL_PROCESS_DETACH);
end.
```

**Nota FPC:** FPC usa `DLLProc` da unit `System` (mesmo mecanismo). Em Linux, equivalente ao constructor/destructor de `.so` via `__attribute__((constructor))` — mas o mecanismo Delphi/FPC funciona da mesma forma.

---

## 4. LoadLibrary / GetProcAddress (Windows)

```pascal
uses
  Winapi.Windows,
  System.SysUtils;

type
  // Declarar o tipo da função antes de usar
  TProcessarDados = function(AInput: Integer; AOutput: PChar; ASize: Integer): LongBool; stdcall;
  TGetVersion     = function: Integer; stdcall;

var
  LHandle: HMODULE;
  LProcessar: TProcessarDados;
  LGetVersion: TGetVersion;
  LBuffer: array[0..255] of Char;
begin
  // Carregar a DLL — caminho completo recomendado em produção
  LHandle := LoadLibrary('MinhaDLL.dll');
  if LHandle = 0 then
    raise Exception.CreateFmt(
      'Falha ao carregar DLL: %s (código %d)',
      [SysErrorMessage(GetLastError), GetLastError]);
  try
    // Resolver símbolos — GetProcAddress retorna nil se não encontrar
    @LProcessar := GetProcAddress(LHandle, 'ProcessarDados');
    if not Assigned(LProcessar) then
      raise Exception.CreateFmt(
        'Função ProcessarDados não encontrada na DLL (código %d)',
        [GetLastError]);

    @LGetVersion := GetProcAddress(LHandle, 'GetDLLVersion');
    // Versão pode ser opcional — verificar antes de usar
    if Assigned(LGetVersion) then
      Writeln('Versão DLL: ', LGetVersion);

    // Usar a função
    if LProcessar(42, @LBuffer[0], SizeOf(LBuffer)) then
      Writeln('Resultado: ', LBuffer);

  finally
    // SEMPRE libertar em finally — mesmo se houver excepção
    FreeLibrary(LHandle);
  end;
end;
```

**Carregamento por índice** (quando exportado com `index N`):
```pascal
@LFunc := GetProcAddress(LHandle, MAKEINTRESOURCE(1)); // índice 1
```

---

## 6. Calling Conventions por Plataforma

| Plataforma | Convenção recomendada | Stack cleanup | Registos | Notas |
|-----------|----------------------|---------------|---------|-------|
| Windows 32-bit | `stdcall` | callee | EAX, EDX, ECX (não usados para args) | Padrão Win32 API; compatível com C `__stdcall` |
| Windows 64-bit | `stdcall` ≡ `register` | caller | RCX, RDX, R8, R9 + stack shadow | x64 tem uma única ABI (Microsoft); `stdcall` é ignorado |
| Linux 64-bit | `cdecl` | caller | RDI, RSI, RDX, RCX, R8, R9 | System V AMD64 ABI; `stdcall` não existe |
| macOS/iOS 64-bit | `cdecl` | caller | Mesmo que Linux 64-bit | ARM64: X0-X7 |
| Cross-platform | `cdecl` | caller | — | Funciona em todos; caller limpa stack |

```pascal
// Declaração cross-platform correcta para interface pública
function ProcessarDados(AInput: Integer; AOutput: PChar; ASize: Integer): LongBool;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

// Implementação na DLL
function ProcessarDados(AInput: Integer; AOutput: PChar; ASize: Integer): LongBool;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}
begin
  // ...
end;
```

**Convenções Delphi — resumo completo:**

| Convenção | Passagem | Stack cleanup | Uso |
|-----------|---------|---------------|-----|
| `register` | EAX, EDX, ECX → stack | callee | Padrão Delphi (mais rápido, não portável) |
| `pascal` | Esquerda para direita → stack | callee | Legado Pascal |
| `cdecl` | Direita para esquerda → stack | caller | Compatibilidade C; variadic args |
| `stdcall` | Direita para esquerda → stack | callee | Win32 API |
| `safecall` | Direita para esquerda → stack | callee | COM com tratamento de exceção via HRESULT |
| `winapi` | Alias de `stdcall` em Windows, `cdecl` em outros | — | RTL Win32 wrappers |

---

## 7. Configuração `.dproj` Multi-plataforma (Win32/Win64/Linux64)

```xml
<!-- No ficheiro .dproj, dentro de <Project> -->

<!-- Tipo de projecto — OBRIGATÓRIO para DLL -->
<PropertyGroup>
  <DCC_ProjectType>Library</DCC_ProjectType>
</PropertyGroup>

<!-- Win32 -->
<PropertyGroup Condition="'$(Platform)'=='Win32'">
  <DCC_ExeOutput>.\bin\win32\</DCC_ExeOutput>
  <DCC_DcuOutput>.\dcu\win32\</DCC_DcuOutput>
  <Defines>FRAMEWORK_VCL;WIN32_TARGET</Defines>
</PropertyGroup>

<!-- Win64 -->
<PropertyGroup Condition="'$(Platform)'=='Win64'">
  <DCC_ExeOutput>.\bin\win64\</DCC_ExeOutput>
  <DCC_DcuOutput>.\dcu\win64\</DCC_DcuOutput>
  <Defines>FRAMEWORK_VCL;WIN64_TARGET</Defines>
</PropertyGroup>

<!-- Linux64 (requer PAServer e compilador cross-platform) -->
<PropertyGroup Condition="'$(Platform)'=='Linux64'">
  <DCC_ExeOutput>.\bin\linux64\</DCC_ExeOutput>
  <DCC_DcuOutput>.\dcu\linux64\</DCC_DcuOutput>
  <Defines>LINUX64_TARGET</Defines>
</PropertyGroup>
```

**Extensão do output:**
- RAD Studio gere automaticamente: `.dll` em Windows, `.so` em Linux.
- O nome no `.dproj` **não deve incluir extensão**: `<DCC_ExeOutput>` aponta para a pasta.
- Em Linux, o compilador adiciona o prefixo `lib` automaticamente: `MinhaDLL` → `libMinhaDLL.so`.

**Desactivar runtime packages** (essencial para DLLs standalone):
```xml
<PropertyGroup>
  <DCC_UsePackage></DCC_UsePackage>
  <DCC_RuntimeOnly>false</DCC_RuntimeOnly>
</PropertyGroup>
```

---

## 8. BPL vs DLL vs .so — Quando Usar Cada Um

| Característica | `.dll` / `.so` | `.bpl` (BorlandPackage) |
|----------------|----------------|------------------------|
| Linguagem consumidora | Qualquer (C, Python, Java via JNI, etc.) | Apenas Delphi/C++Builder |
| Memory manager | Problema — requer ShareMem ou POD | Partilhado automaticamente (RTL única) |
| Versioning | Manual (exportar `GetVersion`) | Automático (Package Version no IDE) |
| Deploy | Apenas o `.dll` + `BORLNDMM.DLL` (se ShareMem) | Requer todos os `.bpl` de runtime instalados |
| Plugin system | Sim — qualquer linguagem pode carregar | Sim — mas apenas Delphi |
| Tamanho do binário | Maior (RTL estática) | Menor (RTL partilhada via BPL) |
| Compatibilidade entre versões Delphi | Binária via POD/interfaces | Recompilação necessária (ABI entre versões) |
| Uso recomendado | Bibliotecas para consumo externo, plugins | Packages dentro do mesmo projecto Delphi |

**Recomendação prática:**
- Use `.dll`/`.so` quando o consumidor pode não ser Delphi ou quando distribui a biblioteca externamente.
- Use `.bpl` apenas quando todos os módulos são compilados com a mesma versão do Delphi e fazem parte do mesmo ecossistema de aplicação.

---

## Checklist DLL Windows — Production-Ready

- [ ] Nenhum `string`/`TObject` atravessa a fronteira sem ShareMem ou interface approach
- [ ] `WideString` usado nos pontos de interface quando necessário (COM-safe)
- [ ] `DllProc` / `initialization`+`finalization` para cleanup no `DLL_PROCESS_DETACH`
- [ ] Calling convention explícita e consistente (`stdcall` Win / `cdecl` Linux)
- [ ] `GetDLLVersion` exportado e documentado
- [ ] `.dproj` configurado para Win32+Win64+Linux64 se multi-plataforma
- [ ] Testado com `LoadLibrary` + `FreeLibrary` em loop (verificar leaks com FastMM4 FullDebugMode)
- [ ] NUNCA usar `ShareMem` se DLL será chamada por host não-Delphi
- [ ] Exports verificados com `dumpbin /exports` (Windows) ou `objdump -T` (Linux)

## Métricas de sucesso

- DLL carrega sem erro em `LoadLibrary`; todos os símbolos resolvidos via `GetProcAddress`.
- Zero crashes de corrupção de heap após 1000 ciclos `LoadLibrary`/`FreeLibrary`.
- Calling convention correta verificada via `dumpbin /exports`.

## Changelog (este arquivo)

- 1.0.0 (24/04/2026): Extraído de `developer-delphi-to-fpc-shared-libraries_V1.0.0` (730L) — secções §AVISO CRÍTICO, §1-4, §6-8. Skill original deprecada em favor das 3 skills filhas: `-windows`, `-linux`, `-plugins`.

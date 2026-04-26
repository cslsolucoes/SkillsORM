---
name: developer-delphi-to-fpc-shared-libraries
description: Guia completo para criar, exportar, carregar e consumir bibliotecas dinâmicas (.dll/.so) com Delphi e FPC — cobrindo fronteira de memória, calling conventions, LoadLibrary/dlopen, sistema de plugins via interfaces e configuração multi-plataforma.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

> **⚠️ DEPRECATED — 24/04/2026**
> Esta skill foi subdividida em 3 skills filhas:
> - `developer-delphi-to-fpc-shared-libraries-windows_V1.0.0` — DLL Windows: projecto library, exports, DllProc, LoadLibrary, calling conventions, .dproj multi-plataforma, BPL vs DLL + ⚠️ AVISO CRÍTICO de memória
> - `developer-delphi-to-fpc-shared-libraries-linux_V1.0.0` — dlopen/dlsym em Linux (Delphi Posix.Dlfcn + FPC dynlibs)
> - `developer-delphi-to-fpc-shared-libraries-plugins_V1.0.0` — sistema de plugins via interfaces COM-compatible + versioning + checklist
>
> **Use as skills filhas.** Este arquivo é mantido apenas como referência histórica.


# developer-delphi-to-fpc-shared-libraries

## Versão interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |
| **Criado**      | 2026-04-11 |
| **Família**     | M — Serviços e Bibliotecas |

## Responsabilidade única

Esta skill cobre o ciclo completo de desenvolvimento de bibliotecas dinâmicas com Delphi e FPC: projecto `library`, cláusula `exports`, `DllProc`, carregamento dinâmico (`LoadLibrary`/`dlopen`), fronteira de memória entre módulos, calling conventions por plataforma (Win32/Win64/Linux64), sistema de plugins via interfaces COM-compatible e configuração `.dproj` multi-plataforma.

## When to use

- Criar uma DLL ou `.so` com Delphi ou FPC.
- Consumir uma DLL dinamicamente (`LoadLibrary`/`GetProcAddress`).
- Implementar um sistema de plugins extensível via interfaces.
- Resolver crashes de fronteira de memória entre DLL e host Delphi.
- Configurar um projecto library para Win32 + Win64 + Linux64.
- Decidir entre `.dll`/`.so`, `.bpl` e abordagens alternativas.

## When NOT to use

- Pacotes BPL exclusivos para o IDE — usar o Wizard de Packages.
- Web APIs REST — usar `developer-delphi-to-fpc-rtl-and-units`.
- COM/ActiveX clássico — skill separada de COM.
- Serviços Windows — usar `developer-delphi-windows-services`.

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

## 5. dlopen / dlsym (Linux) — Delphi e FPC

### 5.1 Delphi (Posix.Dlfcn)

```pascal
uses
  Posix.Dlfcn,
  System.SysUtils;

type
  TProcessarDados = function(AInput: Integer): Integer; cdecl;

var
  LHandle: NativeUInt;
  LFunc: TProcessarDados;
begin
  // RTLD_LAZY: resolve símbolos apenas quando chamados
  // RTLD_NOW:  resolve todos os símbolos ao carregar (falha logo se símbolo ausente)
  LHandle := dlopen('/opt/minhapp/libminha.so', RTLD_LAZY);
  if LHandle = 0 then
    raise Exception.CreateFmt(
      'dlopen falhou: %s',
      [string(dlerror)]);
  try
    @LFunc := dlsym(LHandle, 'ProcessarDados');
    if not Assigned(LFunc) then
      raise Exception.CreateFmt(
        'dlsym falhou: %s',
        [string(dlerror)]);

    Writeln('Resultado: ', LFunc(42));
  finally
    dlclose(LHandle);
  end;
end;
```

**Flags `dlopen` relevantes:**
| Flag | Efeito |
|------|--------|
| `RTLD_LAZY` | Resolve referências ao primeiro uso |
| `RTLD_NOW` | Resolve tudo imediatamente (falha rápida) |
| `RTLD_GLOBAL` | Símbolos ficam disponíveis para `.so` carregados depois |
| `RTLD_LOCAL` | Símbolos isolados (padrão) |
| `RTLD_NODELETE` | `.so` não é descarregado mesmo com `dlclose` |

### 5.2 FPC (dynlibs — cross-platform)

```pascal
uses
  dynlibs,  // unit FPC cross-platform para LoadLibrary/dlopen
  SysUtils;

type
  TProcessarDados = function(AInput: Integer): Integer; cdecl;

var
  LHandle: TLibHandle;
  LFunc: TProcessarDados;
begin
  LHandle := LoadLibrary(
    {$IFDEF MSWINDOWS} 'minha.dll'
    {$ELSE}            'libminha.so'
    {$ENDIF});

  if LHandle = NilHandle then
    raise Exception.CreateFmt('LoadLibrary falhou: %s', [GetLoadErrorStr]);
  try
    Pointer(LFunc) := GetProcedureAddress(LHandle, 'ProcessarDados');
    if not Assigned(LFunc) then
      raise Exception.Create('Função não encontrada');

    Writeln(LFunc(42));
  finally
    UnloadLibrary(LHandle);
  end;
end;
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

## 9. Interface Approach — Sistema de Plugins Robusto

### 9.1 Unit de interfaces partilhada (compilada em ambos os lados)

```pascal
unit PluginInterfaces;

interface

const
  PLUGIN_VERSION = 20260411; // YYYYMMDD

type
  // Interface base — GUID obrigatório para Supports() e QueryInterface()
  IPlugin = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    function  GetName: WideString;      // WideString é COM-safe na fronteira
    function  GetVersion: Integer;
    function  GetDescription: WideString;
    procedure Execute(const AContext: WideString);
    function  IsCompatible(AHostVersion: Integer): Boolean;
  end;

  // Interface estendida (v2) — backwards-compatible
  IPlugin2 = interface(IPlugin)
    ['{B2C3D4E5-F6A7-8901-BCDE-F12345678901}']
    function  GetAuthor: WideString;
    procedure Configure(const AJSON: WideString);
  end;

  // Factory type exportado pela DLL
  TPluginFactory = function: IPlugin; stdcall;

implementation
end.
```

### 9.2 Implementação na DLL (plugin)

```pascal
unit uMyPlugin;

interface

uses PluginInterfaces;

type
  TMyPlugin = class(TInterfacedObject, IPlugin, IPlugin2)
  protected
    // IPlugin
    function  GetName: WideString;
    function  GetVersion: Integer;
    function  GetDescription: WideString;
    procedure Execute(const AContext: WideString);
    function  IsCompatible(AHostVersion: Integer): Boolean;
    // IPlugin2
    function  GetAuthor: WideString;
    procedure Configure(const AJSON: WideString);
  end;

implementation

{ TMyPlugin }

function TMyPlugin.GetName: WideString;
begin
  Result := 'MeuPlugin';
end;

function TMyPlugin.GetVersion: Integer;
begin
  Result := PLUGIN_VERSION;
end;

function TMyPlugin.GetDescription: WideString;
begin
  Result := 'Plugin de exemplo — GestorERP';
end;

function TMyPlugin.IsCompatible(AHostVersion: Integer): Boolean;
begin
  // Compatível se a versão do host for >= a nossa versão base
  Result := AHostVersion >= 20260101;
end;

procedure TMyPlugin.Execute(const AContext: WideString);
begin
  // lógica do plugin
end;

function TMyPlugin.GetAuthor: WideString;
begin
  Result := 'Equipa GestorERP';
end;

procedure TMyPlugin.Configure(const AJSON: WideString);
begin
  // parsear configuração JSON
end;

end.

// No ficheiro .dpr da DLL:
// function CreatePlugin: IPlugin; stdcall;
// begin
//   Result := TMyPlugin.Create;
// end;
// exports CreatePlugin;
```

### 9.3 Carregamento no host

```pascal
uses
  PluginInterfaces,
  {$IFDEF MSWINDOWS} Winapi.Windows {$ELSE} Posix.Dlfcn {$ENDIF},
  System.SysUtils,
  System.Generics.Collections;

type
  TPluginManager = class
  private
    FPlugins: TList<IPlugin>;
    FHandles: TList<{$IFDEF MSWINDOWS}HMODULE{$ELSE}NativeUInt{$ENDIF}>;
  public
    constructor Create;
    destructor  Destroy; override;
    function    LoadPlugin(const APath: string): IPlugin;
    procedure   LoadPluginsFromDir(const ADir: string);
    property    Plugins: TList<IPlugin> read FPlugins;
  end;

function TPluginManager.LoadPlugin(const APath: string): IPlugin;
var
  LHandle: {$IFDEF MSWINDOWS}HMODULE{$ELSE}NativeUInt{$ENDIF};
  LFactory: TPluginFactory;
  LPlugin: IPlugin;
  LPlugin2: IPlugin2;
begin
  Result := nil;

  {$IFDEF MSWINDOWS}
  LHandle := LoadLibrary(PChar(APath));
  if LHandle = 0 then
    raise Exception.CreateFmt('Falha ao carregar plugin "%s": %s',
      [APath, SysErrorMessage(GetLastError)]);
  @LFactory := GetProcAddress(LHandle, 'CreatePlugin');
  {$ELSE}
  LHandle := dlopen(PAnsiChar(AnsiString(APath)), RTLD_LAZY);
  if LHandle = 0 then
    raise Exception.CreateFmt('dlopen falhou "%s": %s',
      [APath, string(dlerror)]);
  @LFactory := dlsym(LHandle, 'CreatePlugin');
  {$ENDIF}

  if not Assigned(LFactory) then
  begin
    {$IFDEF MSWINDOWS} FreeLibrary(LHandle); {$ELSE} dlclose(LHandle); {$ENDIF}
    raise Exception.CreateFmt(
      '"%s" não exporta CreatePlugin — não é um plugin válido', [APath]);
  end;

  LPlugin := LFactory; // chama CreatePlugin, retorna IPlugin
  if not LPlugin.IsCompatible(PLUGIN_VERSION) then
  begin
    {$IFDEF MSWINDOWS} FreeLibrary(LHandle); {$ELSE} dlclose(LHandle); {$ENDIF}
    raise Exception.CreateFmt(
      'Plugin "%s" incompatível (versão %d)', [APath, LPlugin.GetVersion]);
  end;

  // Verificar suporte a IPlugin2 (backwards-compatible)
  if Supports(LPlugin, IPlugin2, LPlugin2) then
    Writeln('Plugin suporta IPlugin2 — funcionalidades estendidas disponíveis');

  FPlugins.Add(LPlugin);
  FHandles.Add(LHandle);
  Result := LPlugin;
end;
```

---

## 10. Versioning de DLL — Contrato Mínimo

```pascal
// Sempre exportar função de versão — facilita diagnóstico em produção
function GetDLLVersion: Integer; stdcall;
begin
  // YYYYMMDD ou Major*10000 + Minor*100 + Patch
  // Ex.: versão 2.1.3 → 20103; data 2026-04-11 → 20260411
  Result := 20260411;
end;

function GetDLLVersionString: PWideChar; stdcall;
begin
  // ATENÇÃO: string literal — não chamar Free no resultado
  Result := '2026.04.11';
end;

exports
  GetDLLVersion,
  GetDLLVersionString;
```

**Extensão sem quebrar ABI — Interface versionada:**
```pascal
// V1 — existente
IPlugin = interface ['{GUID1}']
  procedure Execute(const AContext: WideString);
end;

// V2 — adiciona método sem quebrar V1
IPlugin2 = interface(IPlugin) ['{GUID2}']
  procedure ExecuteAsync(const AContext: WideString; ACallback: TProc);
end;

// Host verifica suporte:
var LP2: IPlugin2;
if Supports(LPlugin, IPlugin2, LP2) then
  LP2.ExecuteAsync('dados', procedure begin Writeln('concluído'); end)
else
  LPlugin.Execute('dados'); // fallback para V1
```

**Estratégia de versioning:**
1. **Nunca remover** funções exportadas — deprecar com prefixo `_Deprecated_`.
2. **Nunca alterar** assinatura de função exportada existente — criar nova com sufixo `V2`.
3. **Sempre exportar** `GetDLLVersion` para diagnóstico.
4. **Documentar** no `.h` / ficheiro de interface quais funções foram adicionadas em qual versão.

---

## 11. Checklist de DLL Production-Ready

- [ ] Nenhum `string`/`TObject` atravessa a fronteira sem ShareMem ou interface approach
- [ ] `WideString` usado nos pontos de interface quando necessário (COM-safe)
- [ ] `DllProc` / `initialization`+`finalization` para cleanup no `DLL_PROCESS_DETACH`
- [ ] Calling convention explícita e consistente (`stdcall` Win / `cdecl` Linux)
- [ ] `GetDLLVersion` exportado e documentado
- [ ] `.dproj` configurado para Win32+Win64+Linux64 se multi-plataforma
- [ ] Testado com `LoadLibrary` + `FreeLibrary` em loop (verificar leaks com FastMM4 FullDebugMode)
- [ ] NUNCA usar `ShareMem` se DLL será chamada por host não-Delphi
- [ ] Exports verificados com `dumpbin /exports` (Windows) ou `objdump -T` (Linux)
- [ ] Unit de interface partilhada compilada em ambos os lados (DLL e host) sem linking da DLL
- [ ] Testado com versão incompatível do host (verificar `IsCompatible`)
- [ ] Thread-safety documentada para cada função exportada

---
name: developer-delphi-to-fpc-shared-libraries-plugins
description: Sistema de plugins extensível via interfaces COM-compatible em Delphi/FPC — unit de interfaces partilhada, IPlugin/IPlugin2, TInterfacedObject na DLL, TPluginManager no host, versioning de DLL e checklist production-ready.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-shared-libraries-plugins

## Versão interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |
| **Criado**      | 2026-04-24 |
| **Família**     | M — Serviços e Bibliotecas |

## Responsabilidade única

Arquitectura de sistemas de plugins extensíveis via interfaces COM-compatible em Delphi e FPC. Cobre: unit de interfaces partilhada com GUID, `IPlugin`/`IPlugin2` (backwards-compatible), `TInterfacedObject` na DLL, `TPluginManager` no host, carregamento cross-platform (`LoadLibrary`/`dlopen`), versioning de DLL (contrato mínimo de ABI), e checklist production-ready.

## When to use

- Implementar um sistema de plugins extensível onde a DLL é carregada em runtime.
- Garantir compatibilidade de ABI entre versões de DLL (interface versionada).
- Resolver o problema de fronteira de memória com o interface approach.
- Definir contrato de exportação `GetDLLVersion` para diagnóstico.

## When NOT to use

- Apenas criar/exportar funções simples → usar `developer-delphi-to-fpc-shared-libraries-windows`.
- Apenas carregar `.so` em Linux → usar `developer-delphi-to-fpc-shared-libraries-linux`.
- COM/ActiveX clássico registado no registry — skill separada de COM.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-to-fpc-shared-libraries-windows` | Leitura do ⚠️ AVISO CRÍTICO de fronteira de memória (obrigatório) |

## Referências cruzadas

- `developer-delphi-to-fpc-shared-libraries-windows` — projecto library + exports + DllProc + LoadLibrary
- `developer-delphi-to-fpc-shared-libraries-linux` — dlopen/dlsym em Linux

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
  Result := 'Plugin de exemplo';
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
  Result := 'Equipa Dev';
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

### 9.3 Carregamento no host (TPluginManager cross-platform)

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

## 11. Checklist de Plugin System Production-Ready

- [ ] Unit de interface partilhada compilada em ambos os lados (DLL e host) sem linking da DLL
- [ ] GUID único gerado para cada interface (`Ctrl+Shift+G` no Delphi)
- [ ] `IsCompatible` implementada e verificada antes de usar o plugin
- [ ] `GetDLLVersion` exportado e documentado
- [ ] `Supports(LPlugin, IPlugin2, LP2)` para funcionalidades opcionais
- [ ] Testado com versão incompatível do host (verificar `IsCompatible`)
- [ ] Thread-safety documentada para cada função exportada
- [ ] `WideString` usado (não `string`) nos pontos de interface
- [ ] `TInterfacedObject` como base (reference counting automático)
- [ ] `FreeLibrary`/`dlclose` em `finally` ou no destructor do TPluginManager

## Métricas de sucesso

- Plugin carrega, `IsCompatible` retorna `True`, `Execute` processa sem crash.
- `IPlugin2` detectado correctamente via `Supports()` quando implementado.
- 1000 ciclos de LoadPlugin/Unload sem leaks de memória.

## Changelog (este arquivo)

- 1.0.0 (24/04/2026): Extraído de `developer-delphi-to-fpc-shared-libraries_V1.0.0` (730L) — secções §9 (Interface Approach), §10 (Versioning) e §11 (Checklist). Skill original deprecada em favor das 3 skills filhas: `-windows`, `-linux`, `-plugins`.

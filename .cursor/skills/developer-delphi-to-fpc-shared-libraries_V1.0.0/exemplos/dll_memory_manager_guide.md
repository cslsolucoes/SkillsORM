# Guia: Fronteira de Memória em DLLs Delphi

## O Problema

Cada módulo compilado com Delphi (`.exe`, `.dll`, `.so`) tem o seu **próprio memory manager** (FastMM no Delphi 11+, HeapMM em versões antigas). O SO aloca heaps separados para cada módulo. Quando um objecto é alocado no heap de A e libertado por B, o resultado é **corrupção silenciosa de heap**.

```
┌─────────────────────────────┐    ┌─────────────────────────────┐
│         Host.exe            │    │        MinhaDLL.dll         │
│                             │    │                             │
│  Memory Manager A           │    │  Memory Manager B           │
│  ┌──────────────────┐       │    │  ┌──────────────────┐       │
│  │  Heap A          │       │    │  │  Heap B          │       │
│  │                  │       │    │  │                  │       │
│  │  TStringList ◄───┼───────┼────┼──┼── Create() !!!  │       │
│  │  (alocado em B!) │       │    │  │                  │       │
│  └──────────────────┘       │    │  └──────────────────┘       │
│                             │    │                             │
│  L.Free;  // crash!         │    │                             │
│  // tenta libertar no Heap A│    │                             │
│  // mas o objecto está em B │    │                             │
└─────────────────────────────┘    └─────────────────────────────┘
```

### Porquê acontece com `string` também?

```pascal
// Na DLL:
function GetNome: string; stdcall;
begin
  Result := 'Olá'; // string Delphi alocada no Heap B da DLL
end;

// No Host:
var S: string;
S := GetNome;
// S recebe referência para string em Heap B
// Quando S sai de scope, DecRef → Free → tenta libertar em Heap A
// = corrupção silenciosa (pode não crashar imediatamente!)
```

### Tipos afectados

| Tipo | Afectado? | Motivo |
|------|-----------|--------|
| `string` / `UnicodeString` | SIM | Reference counting cross-heap |
| `AnsiString` | SIM | Idem |
| `ShortString` | NÃO | Alocado na stack |
| `WideString` | NÃO | Usa `SysAllocString` COM (heap COM global) |
| `TObject` e descendentes | SIM | `new`/`dispose` no heap do módulo |
| `TList`, `TStringList` | SIM | São TObjects |
| `TArray<T>` / `TBytes` | SIM | Array dinâmico Delphi usa heap do módulo |
| `Integer`, `Double`, `Boolean` | NÃO | Tipos de valor (stack ou copiados) |
| `PChar` / `PWideChar` | NÃO* | Ponteiro — *depende de quem aloca o buffer |
| `Pointer` opaco | NÃO* | *Se libertado pelo módulo que alocou |
| `IInterface` / `IPlugin` | NÃO | `_Release` está no vtable da DLL |

---

## Solução A: ShareMem

**Quando usar:** DLL Delphi chamada por host Delphi, mesmo processo, mesmo compilador.

**Como funciona:** Substitui o memory manager padrão por `BORLNDMM.DLL` que implementa um heap **partilhado** entre todos os módulos que o usam.

```pascal
// Em TODOS os .dpr (DLL e host) — ShareMem DEVE ser o PRIMEIRO item
uses
  ShareMem,          // ← PRIMEIRO — substitui o MM antes de qualquer uso
  System.SysUtils,
  System.Classes;
```

```
Estrutura de deploy obrigatória:
  MeuApp.exe
  MinhaDLL.dll
  BORLNDMM.DLL    ← obrigatório! Sem ela, LoadLibrary falha.
```

**Prós:**
- Mais simples — não exige mudar a API da DLL
- Suporta `string`, `TObject`, `TList` na fronteira
- Compatível com o modelo Delphi existente

**Contras:**
- Requer `BORLNDMM.DLL` no deploy (redistribuível da Embarcadero)
- Não funciona entre compiladores diferentes (DLL compilada com MSVC, p.ex.)
- Não funciona em Linux (não existe `BORLNDMM.SO`)
- Não funciona com Python, C, ou qualquer host não-Delphi
- Overhead ligeiro de sincronização (heap partilhado)

**Teste de verificação:**
```pascal
// Se ShareMem estiver correcto, este código NÃO deve crashar:
var L: TStringList;
L := DLL.CreateStringList; // alocado na DLL
L.Add('teste');            // modificado no host
L.Free;                    // libertado no host
```

---

## Solução B: Apenas Tipos POD

**Quando usar:** DLL para consumo externo (C, Python, etc.) ou cross-platform.

**Como funciona:** A fronteira da DLL expõe apenas tipos Plain Old Data — o caller e o callee nunca partilham alocações.

```pascal
// ✓ CORRECTO — apenas POD
function CriarObjeto(out AHandle: Pointer): LongBool; stdcall;
procedure DestruirObjeto(AHandle: Pointer); stdcall;
function GetNome(AHandle: Pointer; ABuffer: PChar; ASize: Integer): Integer; stdcall;

// ✗ ERRADO — TStringList atravessa a fronteira
function GetLista: TStringList; stdcall;
```

**Padrão de buffer para strings:**
```pascal
// Caller fornece buffer; DLL preenche:
function GetNome(AHandle: Pointer; ABuffer: PWideChar; ABufferChars: Integer): Integer; stdcall;
// Retorna: nº de chars escritos, ou -(nº necessário) se buffer pequeno

// Uso no host:
var
  LBuffer: array[0..255] of WideChar;
  LNeeded: Integer;
begin
  LNeeded := GetNome(LHandle, @LBuffer[0], 256);
  if LNeeded < 0 then
  begin
    // Buffer insuficiente — alocar e repetir
    SetLength(LBuf2, Abs(LNeeded));
    GetNome(LHandle, PWideChar(LBuf2), Length(LBuf2));
  end;
end;
```

**Prós:**
- Funciona com qualquer linguagem e compilador
- Funciona em Linux e macOS
- Sem dependências extra no deploy
- Mais previsível e auditável

**Contras:**
- API mais verbosa
- Strings requerem buffer pattern
- Objectos complexos ficam "opacos" (handle pattern)

---

## Solução C: Interface Approach (RECOMENDADO para Delphi ↔ Delphi)

**Quando usar:** Plugin system, componentes extensíveis, DLL Delphi para host Delphi.

**Como funciona:** Interfaces Delphi são COM-compatible. `_AddRef`/`_Release` residem no vtable da **classe implementadora** (na DLL), portanto a memória é sempre gerida pelo módulo correcto.

```
┌─────────────────────────────┐    ┌─────────────────────────────┐
│         Host.exe            │    │        Plugin.dll           │
│                             │    │                             │
│  IPlugin (ponteiro)         │    │  TMyPlugin : TInterfacedObj │
│  ┌──────────────────┐       │    │  ┌──────────────────┐       │
│  │ vtable pointer ──┼───────┼────┼─►│ _AddRef          │       │
│  │                  │       │    │  │ _Release ← Free  │       │
│  └──────────────────┘       │    │  │ GetName, Execute │       │
│                             │    │  └──────────────────┘       │
│  LPlugin := nil;            │    │                             │
│  // → _Release na DLL       │    │  // TMyPlugin.Destroy aqui  │
│  // → TMyPlugin.Destroy     │    │  // no heap CORRECTO        │
└─────────────────────────────┘    └─────────────────────────────┘
```

**Regra:** Todos os métodos da interface que retornam strings devem usar `WideString` (COM-safe) — nunca `string` Delphi.

```pascal
// ✓ CORRECTO — WideString é COM-safe
IPlugin = interface
  function GetName: WideString;       // não precisa de ShareMem
  function GetDescription: WideString;
  procedure Execute(const AContext: WideString);
end;

// ✗ ERRADO — string Delphi atravessa a fronteira
IPlugin = interface
  function GetName: string;  // pode crashar sem ShareMem
end;
```

**Prós:**
- Modelo familiar Delphi — interfaces, herança, polimorfismo
- Reference counting automático — sem leaks nem double-free
- Extensível sem quebrar compatibilidade (IPlugin2 extends IPlugin)
- `Supports()` para detecção de versão
- WideString funciona em Linux também

**Contras:**
- Apenas Delphi/C++Builder como host (COM é Windows-centric mas o padrão de interface é cross-platform em Delphi)
- WideString é mais lento que `string` (alocação COM)
- Requer GUID em cada interface

---

## Como Detectar Corrupção com FastMM4

```pascal
// No .dpr do host — ANTES de qualquer uses
{$DEFINE FastMM4}

uses
  FastMM4;  // deve ser o PRIMEIRO item (sobrepõe ShareMem se ambos presentes)

// Configuração FullDebugMode (detecta corrupção imediatamente):
// Adicionar ao .dpr ou às compiler options:
// {$DEFINE FullDebugMode}
// {$DEFINE EnableMemoryLeakReporting}
```

**Sinais de corrupção de heap:**
- Crash aleatório, não reproduzível
- `Access Violation` em código aparentemente correcto
- FastMM4 FullDebugMode reporta "block header has been corrupted"
- O crash ocorre no `finally` ou no destructor, não no código "suspeito"
- Valgrind (Linux): `Invalid read/write of size N`

**Teste de stress para DLLs:**
```pascal
// LoadLibrary/FreeLibrary em loop — detecta leaks e corrupção
for I := 1 to 1000 do
begin
  LHandle := LoadLibrary('MinhaDLL.dll');
  try
    // usar a DLL
  finally
    FreeLibrary(LHandle);
  end;
end;
// Se FastMM4 reportar leaks após o loop → problema de fronteira
```

# Calling Conventions — Delphi (Windows e Linux)

## Tabela Geral

| Convenção | Palavras-chave | Passagem de args | Stack cleanup | Registos usados | Uso típico |
|-----------|---------------|-----------------|---------------|-----------------|------------|
| `register` | `register` | EAX, EDX, ECX → stack (esq→dir) | callee | EAX, EDX, ECX para os 3 primeiros args | Padrão Delphi — mais rápido em x86-32 |
| `pascal` | `pascal` | Stack esq→dir | callee | Nenhum | Legado Pascal/Turbo — evitar em código novo |
| `cdecl` | `cdecl` | Stack dir→esq | **caller** | Nenhum (convenção C) | C libs, variadic, cross-platform |
| `stdcall` | `stdcall` | Stack dir→dir | callee | Nenhum | Win32 API, COM, DLLs Windows |
| `safecall` | `safecall` | Stack dir→esq | callee | Nenhum | COM com wrapping automático de HRESULT |
| `winapi` | `winapi` | Alias: stdcall em Win, cdecl em outros | — | — | RTL wrappers Win32 |

## Comportamento por Plataforma

### Windows 32-bit (x86)

| Convenção | Quem limpa stack | Passagem | Retorno |
|-----------|-----------------|---------|---------|
| `register` | callee | 1º→EAX, 2º→EDX, 3º→ECX, resto→stack | EAX (int), EAX:EDX (int64), FPU ST(0) (float) |
| `cdecl` | **caller** | stack (dir→esq) | EAX |
| `stdcall` | callee | stack (dir→esq) | EAX |
| `pascal` | callee | stack (esq→dir) | EAX |
| `safecall` | callee | stack (dir→esq) | EAX (HRESULT); resultado real como out param |

### Windows 64-bit (x86-64)

> Em x64, **existe uma única ABI** (Microsoft x64 ABI). Todas as convenções Delphi (`stdcall`, `cdecl`, `register`) mapeiam para ela. As palavras-chave são aceites mas ignoradas.

| Parâmetros | Registos |
|-----------|---------|
| 1º a 4º int/ptr | RCX, RDX, R8, R9 |
| 1º a 4º float | XMM0, XMM1, XMM2, XMM3 |
| 5º em diante | Stack (com 32 bytes de shadow space obrigatório) |
| Retorno int | RAX |
| Retorno float | XMM0 |

**Stack cleanup:** sempre o caller (mas o callee deve preservar RBX, RBP, RDI, RSI, R12-R15).

### Linux 64-bit (System V AMD64 ABI)

| Parâmetros | Registos |
|-----------|---------|
| 1º a 6º int/ptr | RDI, RSI, RDX, RCX, R8, R9 |
| 1º a 8º float | XMM0–XMM7 |
| 7º+ int / 9º+ float | Stack |
| Retorno int | RAX (+ RDX para 128-bit) |
| Retorno float | XMM0 |

**Stack cleanup:** sempre o caller.
**Convenção recomendada em Delphi/FPC para Linux:** `cdecl`.

### macOS / iOS 64-bit (ARM64 — Apple Silicon)

| Parâmetros | Registos |
|-----------|---------|
| 1º a 8º int/ptr | X0–X7 |
| 1º a 8º float | V0–V7 |
| 9º+ | Stack |
| Retorno int | X0 |
| Retorno float | V0 |

---

## Declaração Cross-Platform

```pascal
// Convenção correcta para DLL pública — compila em Windows e Linux
function ProcessarDados(AInput: Integer; AOutput: PChar; ASize: Integer): LongBool;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

// Variante explícita para código sempre-cdecl (seguro em todas as plataformas)
// O caller limpa a stack em cdecl — funciona em Windows e Linux
function ProcessarDados(AInput: Integer): Integer; cdecl;
```

## Funções Variádicas (varargs)

Apenas `cdecl` suporta número variável de argumentos (como `printf` em C):

```pascal
// Delphi — variadic com cdecl
function FormatC(AFormat: PChar): Integer; cdecl; varargs;
// Nota: varargs em Delphi só é suportado para IMPORTAÇÃO de funções C
// A exportação de variadics é feita em C; o wrapper Delphi importa.
```

## `safecall` — COM e Excepções Automáticas

```pascal
// Delphi converte automaticamente excepções em HRESULT
function ProcessarDados(AInput: Integer): Integer; safecall;
// Equivalente COM: HRESULT ProcessarDados(int AInput, int* Result);

// Se lançar excepção → Delphi converte para E_FAIL ou código específico
// Host COM verifica HRESULT; se S_OK → usa resultado em out param
```

## Compatibilidade Cruzada (Delphi ↔ C)

| Delphi | C equivalente | Compatível? |
|--------|--------------|-------------|
| `stdcall` | `__stdcall` | SIM (Win32) |
| `cdecl` | `__cdecl` | SIM |
| `register` | (não tem) | NÃO — evitar em interface com C |
| `safecall` | (COM `__stdcall` + HRESULT wrapping) | SIM via COM |
| `pascal` | (não tem) | NÃO |

## Verificar Calling Convention em Binário

```
// Windows — ver decoração do nome:
// stdcall exports: _MinhaFuncao@12 (12 = bytes de args)
// cdecl exports: _MinhaFuncao (sem @N)
// register: MinhaFuncao (sem decoração — Delphi específico)

dumpbin /exports MinhaDLL.dll | findstr MinhaFuncao
```

Em Delphi 32-bit, `stdcall` gera: `MinhaFuncao@N` (N = bytes).
Em Delphi 64-bit, sem decoração (única ABI).

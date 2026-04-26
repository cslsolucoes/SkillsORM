# Restricoes de Plataforma para asm..end — Consulta Rapida

## Suporte por plataforma

| Plataforma              | Compilador  | asm..end | Motivo                              |
| ----------------------- | ----------- | -------- | ----------------------------------- |
| Windows x86 (Win32)     | dcc32       | SIM      | Suporte completo                    |
| Windows x64 (Win64)     | dcc64       | SIM      | Suporte completo (Win64 ABI)        |
| macOS x64               | dcc64       | SIM      | Via LLVM com asm Intel              |
| iOS ARM / ARM64         | dccios      | NAO      | Compilador LLVM — sem asm inline    |
| Android ARM / ARM64     | dccaarm     | NAO      | Compilador LLVM — sem asm inline    |
| Linux x64 (FPC)         | fpc         | SIM      | Sintaxe FPC (diferente do Delphi)  |

## Como proteger codigo asm com diretivas

```pascal
{$IFDEF WIN32}
  asm
    // Codigo x86 32-bit
    ADD EAX, EDX
  end;
{$ENDIF WIN32}

{$IFDEF WIN64}
  asm
    // Codigo x64 64-bit
    ADD EAX, ECX    // Win64: primeiro param em RCX/ECX
  end;
{$ENDIF WIN64}

{$IF DEFINED(IOS) OR DEFINED(ANDROID)}
  // Fallback Pascal puro para plataformas LLVM
  Result := A + B;
{$ENDIF}
```

## Verificar em tempo de compilacao

```pascal
{$IFDEF CPUX86}    // Win32, Linux x86
{$IFDEF CPUX64}    // Win64, macOS x64
{$IFDEF CPU386}    // x86 legado
{$IFDEF CPUARM}    // ARM 32-bit
{$IFDEF CPUAARCH64} // ARM 64-bit (iOS, Android moderno)
```

## Diretivas de plataforma relevantes (Delphi)

```
MSWINDOWS   — Windows (32 ou 64)
WIN32       — Windows 32-bit especificamente
WIN64       — Windows 64-bit especificamente
IOS         — iOS (ARM/ARM64)
ANDROID     — Android
MACOS       — macOS
LINUX       — Linux (via FPC ou Delphi Linux)
```

---
name: developer-delphi-to-fpc-shared-libraries-linux
description: Carregar e consumir shared objects (.so) em Linux com Delphi (Posix.Dlfcn) e FPC (dynlibs) — dlopen, dlsym, dlclose, flags RTLD_*, tratamento de erros e abordagem cross-platform. Complementa a skill de DLL Windows.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-shared-libraries-linux

## Versão interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |
| **Criado**      | 2026-04-24 |
| **Família**     | M — Serviços e Bibliotecas |

## Responsabilidade única

Carregar e consumir shared objects (`.so`) em Linux com Delphi e FPC. Cobre: `dlopen`/`dlsym`/`dlclose` com `Posix.Dlfcn` (Delphi) e `dynlibs` (FPC cross-platform), flags `RTLD_*`, tratamento de erros via `dlerror`, e abordagem cross-platform com `{$IFDEF MSWINDOWS}`. Não cobre criação de `.so` — para isso usar `developer-delphi-to-fpc-shared-libraries-windows` (projecto `library`).

## When to use

- Carregar um `.so` em Linux a partir de Delphi ou FPC.
- Escrever código que carrega DLL em Windows E `.so` em Linux na mesma base de código.
- Usar a unit `dynlibs` do FPC (cross-platform para `LoadLibrary`/`dlopen`).

## When NOT to use

- Criar a DLL/`.so` → usar `developer-delphi-to-fpc-shared-libraries-windows` (configura o projecto library e exports).
- Sistema de plugins via interfaces → usar `developer-delphi-to-fpc-shared-libraries-plugins`.
- Configuração PAServer ou cross-compile para Linux → usar `developer-delphi-to-fpc-linux-setup`.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-to-fpc-linux-setup` | Antes de testar dlopen em Linux (PAServer + cross-compile configurados) |

## Referências cruzadas

- `developer-delphi-to-fpc-shared-libraries-windows` — criação de DLL + LoadLibrary em Windows; ⚠️ AVISO CRÍTICO de fronteira de memória
- `developer-delphi-to-fpc-shared-libraries-plugins` — sistema de plugins via interfaces COM-compatible

> **NOTA:** Antes de chamar `dlopen`, leia o ⚠️ AVISO CRÍTICO em `developer-delphi-to-fpc-shared-libraries-windows` — fronteira de memória entre `.so` e host também se aplica em Linux.

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

**Vantagem de `dynlibs`:** mesmo código funciona em Windows (`LoadLibrary`) e Linux (`dlopen`) — ideal para bibliotecas cross-platform que precisam carregar plugins em ambas as plataformas.

---

## Checklist dlopen Linux

- [ ] Path absoluto ou em `LD_LIBRARY_PATH` passado ao `dlopen`
- [ ] `dlerror()` verificado após `dlopen` E após `dlsym`
- [ ] `dlclose` sempre em `finally`
- [ ] Calling convention `cdecl` em todas as funções importadas de `.so`
- [ ] Dependências do `.so` instaladas no servidor (ver `ldd libminha.so`)
- [ ] Testado com `RTLD_NOW` para detectar símbolos ausentes em tempo de carregamento

## Métricas de sucesso

- `dlopen` retorna handle válido sem `dlerror`.
- Todos os símbolos resolvidos via `dlsym` sem `dlerror`.
- Zero segfaults na chamada cross-heap — ou, se partilha objectos, ShareMem equivalente configurado.

## Changelog (este arquivo)

- 1.0.0 (24/04/2026): Extraído de `developer-delphi-to-fpc-shared-libraries_V1.0.0` (730L) — secção §5 (dlopen/dlsym Delphi + FPC). Skill original deprecada em favor das 3 skills filhas: `-windows`, `-linux`, `-plugins`.

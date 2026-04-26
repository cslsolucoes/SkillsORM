# Referência: Cláusula `exports` em Delphi

## Sintaxe Completa

```pascal
exports
  // 1. Exportação simples — nome público = nome Pascal
  MinhaFuncao,

  // 2. Alias — nome público diferente do nome Pascal
  MinhaFuncaoInterna name 'MinhaFuncao',

  // 3. Por índice — GetProcAddress(h, MAKEINTRESOURCE(N))
  ProcessarDados index 1,

  // 4. Índice + alias
  ProcessarDadosV2 index 2 name 'ProcessarDados2',

  // 5. resident — mantém o nome em memória (obsoleto/ignorado em Win64)
  FuncaoLegado resident,

  // 6. Múltiplas qualificações
  OutraFuncao index 3 name 'Outra' resident;
```

## Regras de Visibilidade

| Visibilidade Pascal | Exportável? | Notas |
|--------------------|-------------|-------|
| `public` (global) | SIM | Padrão para funções/procedimentos no escopo de programa |
| `private` (dentro de `implementation`) | SIM* | *Delphi permite; não recomendado |
| Métodos de classe | NÃO | Não podem ser exportados directamente — usar wrapper |
| Funções locais | NÃO | Funções aninhadas não são exportáveis |
| `inline` | NÃO* | *Sem endereço fixo; o compilador pode recusar |

## Case Sensitivity

- **Windows:** exports são **case-insensitive** por defeito para `LoadLibrary` + `GetProcAddress`.
  Mas `GetProcAddress` com nome exacto faz comparação **case-sensitive**.
- **Linux:** exports são sempre **case-sensitive** (ELF).

```pascal
// Exportar com nome exacto para evitar ambiguidade:
MinhaFuncao name 'MinhaFuncao',  // GetProcAddress('MinhaFuncao') — exacto
MinhaFuncao name 'minhafuncao',  // variante lowercase
```

## Exportar por Índice

```pascal
exports
  ProcessarDados index 1;

// Carregar por índice no host:
@LFunc := GetProcAddress(LHandle, MAKEINTRESOURCE(1));
// Nota: MAKEINTRESOURCE(N) = Pointer(N) — funciona em qualquer Win target
```

**Quando usar índices:**
- DLL com muitas funções onde o carregamento por nome tem overhead
- Interfaces fixas (índice nunca muda; nome pode ser ambíguo)
- Compatibilidade com VB6/COM legado que usa índices

## Verificar Exports

### Windows — dumpbin
```
dumpbin /exports MinhaDLL.dll
```
Saída:
```
  ordinal  hint  RVA       name
        1     0  00001060  CriarHandle
        2     1  000010A0  DestruirHandle
        3     2  00001020  GetLibraryVersion
        4     3  00001040  ProcessarDados
```

### Windows — Dependency Walker / Dependencies (GUI)
Ferramenta gratuita: https://github.com/lucasg/Dependencies

### Windows — PowerShell
```powershell
[System.Reflection.Assembly]::LoadFrom('C:\path\MinhaDLL.dll')
# OU via dumpbin no Visual Studio Developer Command Prompt
```

### Linux — objdump
```bash
objdump -T libMinhaDLL.so
# OU
nm -D libMinhaDLL.so | grep ' T '  # T = text section (código exportado)
```

### Linux — readelf
```bash
readelf -s libMinhaDLL.so | grep GLOBAL
```

## Boas Práticas de Nomeação

```pascal
exports
  // Prefixo com nome da biblioteca — evita colisões em dlopen com RTLD_GLOBAL
  MinhaBib_CriarHandle,
  MinhaBib_DestruirHandle,
  MinhaBib_GetVersion,

  // Convenção Windows API: PascalCase sem underscore
  CreateSession,
  DestroySession,
  GetVersion;
```

## O que Acontece sem `exports`

- A função é compilada e existe no binário.
- Mas **não aparece na export table** — `GetProcAddress` retorna `nil`.
- Para verificar: `dumpbin /exports` não mostra a função.
- Comum em DLLs Delphi: esquecer a cláusula `exports` → tudo compila, nada funciona.

## `resident` Keyword (Windows 16-bit legado)

- Mantém o nome em memória para acesso mais rápido em 16-bit.
- Em Win32/Win64: **ignorado pelo compilador** (documentado na ajuda do Delphi).
- Em código novo: não usar. Pode causar confusão sem benefício.

## Exportar Sobrecargas (Overloads)

```pascal
// Delphi permite overloads, mas a DLL não suporta (sem name mangling tipo C++)
// Solução: usar aliases diferentes para cada variante

function ProcessarInt(AVal: Integer): Integer; stdcall; overload;
function ProcessarFloat(AVal: Double): Double; stdcall; overload;

exports
  ProcessarInt   name 'ProcessarInt',
  ProcessarFloat name 'ProcessarFloat';
// NÃO exportar ambas com o mesmo nome — último ganha, silenciosamente
```

# Armadilhas de Memory Manager em DLLs Delphi

## Porquê o Problema Existe

Delphi e FPC ligam o **memory manager** (FastMM, HeapMM, etc.) estaticamente em cada módulo que o usa. Quando compila `Host.exe` e `MinhaDLL.dll` separadamente, cada um tem:

1. O seu próprio código de `GetMem`/`FreeMem`
2. O seu próprio heap (na prática, chama `HeapCreate` do Windows internamente)
3. O seu próprio registo de blocos alocados

```
Host.exe                          MinhaDLL.dll
┌─────────────────────┐          ┌─────────────────────┐
│ FastMM (cópia A)    │          │ FastMM (cópia B)     │
│ Heap handle: H1     │          │ Heap handle: H2      │
│ Alocações: [...]    │          │ Alocações: [...]     │
└─────────────────────┘          └─────────────────────┘
       ▲                                  ▲
       │ HeapAlloc(H1, ...)               │ HeapAlloc(H2, ...)
       └──────────────────────────────────┘
           Heaps DIFERENTES no SO
```

Quando a DLL aloca e o host liberta: `HeapFree(H1, bloco_em_H2)` → **corrupção silenciosa**.

---

## Tipos SEGUROS de Passar pela Fronteira

Estes tipos **não envolvem heap da DLL** — são copiados por valor ou o caller gere o buffer:

| Tipo | Seguro? | Motivo |
|------|---------|--------|
| `Integer`, `Int64`, `Cardinal` | ✓ SIM | Valor na stack |
| `Byte`, `Word`, `LongWord` | ✓ SIM | Valor na stack |
| `Single`, `Double` | ✓ SIM | Valor na stack/FPU |
| `Boolean`, `LongBool`, `WordBool` | ✓ SIM | Valor na stack |
| `Char`, `WideChar` | ✓ SIM | Valor na stack |
| `PChar` / `PWideChar` / `PAnsiChar` | ✓ SIM* | *Buffer alocado pelo **caller**, preenchido pela DLL |
| `Pointer` opaco | ✓ SIM* | *Se libertado pelo módulo que alocou |
| `WideString` | ✓ SIM | Usa `SysAllocString`/`SysFreeString` (heap COM) |
| `ShortString` | ✓ SIM | Alocado na stack, tamanho fixo |
| `record` (sem managed fields) | ✓ SIM | Copiado por valor se passado por valor |
| `IInterface` / qualquer interface | ✓ SIM | vtable e `_Release` residem no módulo alocador |
| `array[0..N] of T` (estático) | ✓ SIM | Tamanho fixo na stack |

---

## Tipos PERIGOSOS sem ShareMem

| Tipo | Perigoso? | Motivo |
|------|-----------|--------|
| `string` / `UnicodeString` | ✗ SIM | Reference counting cross-heap |
| `AnsiString` | ✗ SIM | Idem |
| `RawByteString` | ✗ SIM | Idem |
| `UTF8String` | ✗ SIM | Alias de AnsiString |
| `TObject` e descendentes | ✗ SIM | `Create` aloca no heap do módulo |
| `TList`, `TStringList`, `TObjectList` | ✗ SIM | São TObjects |
| `TBytes` / `TArray<T>` | ✗ SIM | Array dinâmico gerido pelo heap do módulo |
| `TStream` (mas não `TCustomMemoryStream` com buffer externo) | ✗ SIM | TObject |
| `Variant` | ✗ SIM | Internamente usa `string` e `IDispatch` |
| `OleVariant` | ✓/✗ | COM-safe para tipos simples; perigoso com VT_BSTR se mal usado |
| `record` **com** managed fields | ✗ SIM | Campos `string`, `interface`, `dynamic array` — geridos pelo heap |

---

## Excepção Importante: `WideString`

`WideString` é uma excepção segura porque usa o **alocador COM do SO** (`SysAllocString`/`SysFreeString` no `oleaut32.dll`), que é **global ao processo**:

```pascal
// SEGURO — WideString usa heap COM (não o heap Delphi)
function GetNome: WideString; stdcall;
begin
  Result := 'Olá'; // SysAllocString — heap COM, não FastMM
end;

// No host:
var S: WideString;
S := GetNome;
// S usa SysFreeString quando sai de scope — heap COM correcto
```

**Contras de WideString:**
- Mais lento que `string` (alocação no heap COM)
- UTF-16, 2 bytes por char — pode surpreender se a DLL lida com multibyte
- Em Linux, `WideString` não usa heap COM (não existe oleaut32 em Linux) — **cuidado**

---

## Como Detectar Corrupção

### FastMM4 FullDebugMode (Windows)

```pascal
// No .dpr do host — primeiro item nas uses
uses
  FastMM4;

// Adicionar ao .cfg ou ao código:
// {$DEFINE FullDebugMode}
// {$DEFINE EnableMemoryLeakReporting}
```

Comportamento com FullDebugMode:
- Preenche blocos libertados com `$80808080` — acesso após `Free` causa AV imediata
- Detecta "block header corrupted" → heap corruption de DLL externa
- Reporta leaks no shutdown com stacktrace de quem alocou

### Valgrind (Linux — FPC)

```bash
valgrind --tool=memcheck --leak-check=full \
         --error-exitcode=1 \
         ./minha_app
```

Saída de corrupção:
```
==12345== Invalid write of size 4
==12345==    at 0x... (within /opt/app/libminha.so)
==12345==  Address 0x... is 0 bytes after a block of size 32 free'd
```

### Address Sanitizer (FPC 3.2+ / Clang)

```
fpc -dSANITIZE_ADDRESS -fsanitize=address minha_app.lpr
```

### Teste de Stress

```pascal
// Carregar/descarregar em loop — leak é sinal de problema de fronteira
var I: Integer;
for I := 1 to 10000 do
begin
  var LH := LoadLibrary('MinhaDLL.dll');
  var LF: TMinhaFuncao;
  @LF := GetProcAddress(LH, 'MinhaFuncao');
  if Assigned(LF) then LF(42);
  FreeLibrary(LH);
end;
// FastMM4 deve reportar 0 leaks após o loop
```

---

## Checklist de Diagnóstico Rápido

Se tiver crash ou comportamento estranho ao usar DLL Delphi:

1. **O crash está em `Free`, `Destroy` ou `finalization`?** → Fronteira de memória.
2. **O crash é não-reproduzível (ocorre aleatoriamente)?** → Heap corruption — FastMM4 FullDebugMode.
3. **A DLL passou `string` ou `TObject` pela fronteira sem ShareMem?** → Causa provável.
4. **Host e DLL compilados com versões Delphi diferentes?** → ShareMem não ajuda; use POD.
5. **DLL chamada por Python/C/Java?** → ShareMem não funciona; use POD obrigatoriamente.
6. **Funciona em Debug mas falha em Release?** → Optimizações alteram layout de memória; o bug estava lá antes.

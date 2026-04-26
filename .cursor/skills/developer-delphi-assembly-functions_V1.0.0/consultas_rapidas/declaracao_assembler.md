# Declaracao de Funcao `assembler` — Consulta Rapida

## Formas de declarar

### 1. Funcao puramente assembly (sem begin/end):
```pascal
function NomeFuncao(A, B: Integer): Integer; assembler;
asm
  // Implementacao inteiramente em assembly
  ADD EAX, EDX
end;
```

### 2. Com NOSTACKFRAME (leaf function):
```pascal
function LeafFunc(N: Integer): Integer; assembler; nostackframe;
asm
  NEG EAX    // Win32: N=EAX
end;
```

### 3. Com pseudo-ops x64:
```pascal
function Func64(A, B: Integer): Integer; assembler;
asm
  .PARAMS 2       // frame + shadow space
  .PUSHNV R12     // salvar R12
  MOV EAX, ECX
  ADD EAX, EDX
end;
```

### 4. Linkagem de .obj externo (NASM):
```pascal
// Arquivo .pas:
{$L minha_rotina.obj}           // linkar o objeto
function SomaNasm(A, B: Integer): Integer; external;  // sem nome de DLL = .obj
```

### 5. Declaracao `external` de DLL:
```pascal
function SomaDll(A, B: Integer): Integer; stdcall; external 'minha.dll' name 'SomaDll';
// `name` especifica o nome exato do simbolo exportado na DLL
```

## Diferenca: `assembler` vs. bloco `asm..end`

| Aspecto                  | `assembler` (funcao pura)    | `asm..end` (inline)         |
| ------------------------ | ---------------------------- | --------------------------- |
| Estrutura                | Sem begin/end Pascal         | Dentro de begin..end Pascal |
| Mix Pascal/ASM           | Nao                          | Sim (antes/apos asm)        |
| Performance              | Ligeiramente melhor          | Normal                      |
| Variaveis locais Pascal  | Nao (sem begin..end)         | Sim                         |
| Pseudo-ops x64           | Sim (.PARAMS, .PUSHNV)       | Limitado                    |

## Nomes de simbolos para linkagem .obj

| Plataforma | Convencao    | Nome no NASM               |
| ---------- | ------------ | -------------------------- |
| Win32      | cdecl        | `_NomeFuncao`              |
| Win32      | stdcall      | `_NomeFuncao@N` (N=bytes)  |
| Win32      | register     | `_NomeFuncao`              |
| Win64      | Qualquer     | `NomeFuncao` (sem prefixo) |

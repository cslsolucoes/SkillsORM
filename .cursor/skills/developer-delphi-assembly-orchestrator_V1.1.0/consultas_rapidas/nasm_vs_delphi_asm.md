# NASM vs Delphi Built-in Assembler — Diferencas de Sintaxe

## Tabela comparativa completa

| Aspecto                     | NASM (Intel syntax)                  | Delphi built-in assembler               |
| --------------------------- | ------------------------------------ | --------------------------------------- |
| **Labels locais**           | `.label:` (ponto)                    | `@label:` (arroba)                      |
| **Labels globais**          | `label:` (sem ponto)                 | Evitar sem @ — conflito com Pascal      |
| **Comentarios**             | `; comentario`                       | `// comentario` ou `{ comentario }`     |
| **Comentario invalido**     | N/A                                  | `(* *)` — NAO usar dentro de asm       |
| **Masking AVX-512**         | `VADDPS ZMM0 {k1}{z}, ZMM1, ZMM2`  | `VADDPS ZMM0 <k1><z>, ZMM1, ZMM2`    |
| **Broadcast AVX-512**       | `VMOVSS ZMM0, [RBX] {1to16}`        | `VMOVSS ZMM0, [RBX] <1to16>`          |
| **Tamanho de tipo**         | Constante manual (`dd`, `dq`)        | `TYPE Integer`, `SIZE Arr`             |
| **Endereco de global**      | `[GVar]` ou `GVar`                   | `OFFSET GVar` ou nome direto            |
| **Parametros em funcao**    | Acesso manual por [EBP+8] etc.       | Por nome da variavel Pascal              |
| **Pseudo-ops x64**          | Escrito manualmente (PUSH, SUB RSP) | `.PARAMS`, `.PUSHNV`, `.SAVENV`         |
| **NOSTACKFRAME**            | Default (sem frame se nao colocado)  | `nostackframe` keyword explicito        |
| **Retorno de funcao**       | MOV EAX, valor manualmente          | EAX automatico, ou `MOV Result, EAX`   |
| **VMT dispatch**            | Offset calculado manualmente         | `VMTOFFSET TClasse.Metodo`              |
| **Secoes**                  | `section .text`, `section .data`    | Unica secao (gerenciada pelo compilador)|
| **Macros**                  | `%macro`, `%define`, `%rep`         | Nao ha macros no built-in              |
| **Formato de saida**        | `.obj` via -f win32/win64            | Inline no .dcu/.exe                    |

## Exemplos lado a lado

### Funcao simples soma:

**NASM:**
```nasm
; Win32 cdecl:
global _Somar
_Somar:
    mov eax, [esp+4]   ; A
    add eax, [esp+8]   ; + B
    ret
```

**Delphi (register convention):**
```pascal
function Somar(A, B: Integer): Integer; assembler;
asm
  // A=EAX, B=EDX automaticamente
  ADD EAX, EDX
end;
```

### Label local:

**NASM:**
```nasm
.loop:
    dec ecx
    jnz .loop
```

**Delphi:**
```pascal
asm
@loop:
  DEC ECX
  JNZ @loop
end;
```

### Masking AVX-512:

**NASM:**
```nasm
VADDPS ZMM0 {k1}{z}, ZMM1, ZMM2
```

**Delphi:**
```pascal
asm
  VADDPS ZMM0 <k1><z>, ZMM1, ZMM2
end;
```

## Quando usar cada um

| Use NASM                               | Use Delphi built-in                    |
| -------------------------------------- | -------------------------------------- |
| Algoritmo grande e independente        | Otimizacao dentro de funcao existente  |
| Precisa de macros (%macro)             | Acesso facil a variaveis Pascal        |
| Portabilidade para outros compiladores | Uso de VMTOFFSET/DMTINDEX              |
| Biblioteca assembly reutilizavel       | Prototipagem rapida                    |
| Multiplos .obj vinculados              | Codigo nao sai do projeto Delphi      |

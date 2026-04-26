# Diferenças de sintaxe — Built-in assembler Delphi vs NASM

## Rótulos (Labels)

| NASM | Delphi asm..end |
|------|-----------------|
| `.label:` | `@label:` |
| `label:` (global) | `@label:` (local ao bloco) |
| `jmp .label` | `JMP @label` |

```pascal
// Delphi:
asm
  JMP @fim
@inicio:
  NOP
@fim:
end;

// NASM:
jmp .fim
.inicio:
  nop
.fim:
```

## Tamanho de operando de memória

| NASM | Delphi asm..end |
|------|-----------------|
| `mov byte [var], 0` | `MOV byte ptr [var], 0` |
| `mov dword [var], 42` | `MOV dword ptr [var], 42` |
| `add dword [ptr], 1` | `ADD dword ptr [ptr], 1` |

## Acesso a variáveis Pascal

| NASM | Delphi asm..end |
|------|-----------------|
| Não disponível (usa extern) | `MOV EAX, MinhaVarLocal` |
| — | `MOV MinhaVar, EAX` |
| `lea rax, [rel var]` | `LEA EAX, MinhaVar` |

```pascal
// Delphi: variáveis locais acessíveis pelo nome
procedure Demo;
var
  X, Y: Integer;
begin
  X := 10;
  asm
    MOV EAX, X      // lê X
    ADD EAX, 5
    MOV Y, EAX      // escreve Y
  end;
end;
```

## Acesso a campos de objeto

| NASM | Delphi asm..end |
|------|-----------------|
| `mov eax, [rbx + 8]` (offset manual) | `MOV EAX, [EAX].TClasse.Campo` |

```pascal
// Delphi resolve o offset automaticamente:
MOV EAX, [EAX].TMinhaClasse.FValor
// equivale a:
MOV EAX, [EAX + 4]  // se FValor está no offset 4
```

## Chamada a funções Pascal

| NASM | Delphi asm..end |
|------|-----------------|
| `call _ProcName` | `CALL ProceduraPascal` |
| Precisa de external declaration | Usa o símbolo diretamente |

```pascal
procedure MinhaProc;
begin
  WriteLn('Hello');
end;

procedure Demo;
asm
  CALL MinhaProc    // Delphi resolve o endereço
end;
```

## Comentários

| NASM | Delphi asm..end |
|------|-----------------|
| `;` | `//` ou `{ }` ou `(* *)` |

## Constantes numéricas

| Notação | NASM | Delphi |
|---------|------|--------|
| Hexadecimal | `0x1A2B` ou `1A2Bh` | `$1A2B` |
| Binário | `10110b` | Não suportado diretamente |
| Octal | `17o` ou `17q` | Não suportado |
| Decimal | `42` | `42` |

```pascal
// Delphi usa $ para hex:
asm
  MOV EAX, $DEADBEEF   // hex no Delphi
  // NASM: mov eax, 0xDEADBEEF
end;
```

## Instruções sem equivalente direto no built-in Delphi

| Instrução NASM | Status no Delphi asm..end |
|----------------|--------------------------|
| `%define`, `%macro` | Não suportado (usar {$DEFINE} Pascal) |
| `section .data` | Não aplicável (usa seção do projeto) |
| `bits 32/64` | Determinado pelo compilador (dcc32/dcc64) |
| `global _start` | Não aplicável |
| `extern` | Usar `external` no cabeçalho da função |
| `db`, `dw`, `dd` | Usar variáveis Pascal ou `const` |

## Pseudo-ops Delphi 64-bit (não existem no NASM)

```pascal
// Exclusivos do built-in assembler Delphi 64-bit:
asm
  .PARAMS N          // gera shadow space para N parâmetros
  .PUSHNV RBX        // PUSH RBX + unwind information
  .SAVENV XMM6       // salva XMM6 na stack + unwind info
  .NOFRAME           // indica função leaf sem prologue
end;
```

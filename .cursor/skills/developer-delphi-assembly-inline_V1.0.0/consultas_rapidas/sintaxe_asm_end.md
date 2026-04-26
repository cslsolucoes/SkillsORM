# Sintaxe asm..end — Consulta Rapida

## Estrutura basica

```pascal
function MinhaFuncao(A, B: Integer): Integer;
begin
  // Codigo Pascal normal pode vir antes/depois do bloco asm
  asm
    // Instrucoes assembly aqui
    // Sintaxe Intel (operando destino primeiro)
    MOV EAX, A
    ADD EAX, B
    MOV Result, EAX
  end;
end;
```

## Funcao puramente assembly (sem begin/end Pascal)

```pascal
function SomarPuro(A, B: Integer): Integer;
asm
  ADD EAX, EDX    // Win32: A=EAX, B=EDX, retorno=EAX
end;
// Nota: sem begin/end — o asm vai direto
```

## Labels locais (obrigatorio usar @)

```pascal
function Maximo(A, B: Integer): Integer;
asm
  CMP EAX, EDX
  JGE @retA      // label local com @
  MOV EAX, EDX
@retA:           // definicao do label
  // EAX ja tem o resultado
end;
```

## Comentarios validos dentro de asm

```pascal
asm
  MOV EAX, 1    // comentario estilo C++ — VALIDO
  { comentario Pascal — VALIDO }
  (* comentario Pascal 2 — INVALIDO dentro de asm! *)
end;
```

## @Result vs EAX

```pascal
// Para funcao que retorna Integer:
function F1: Integer;
asm
  MOV EAX, 42      // EAX e o retorno — mais eficiente
end;

function F2: Integer;
begin
  asm
    MOV Result, 42  // Result como variavel Pascal — mais claro
  end;
end;
```

## Variaveis locais e parametros

```pascal
function Calc(X: Integer): Integer;
var
  Temp: Integer;
begin
  asm
    MOV EAX, X       // parametro X por nome
    MOV Temp, EAX    // variavel local por nome
    // Delphi resolve automaticamente os enderecos
  end;
end;
```

## Modificadores de tamanho

```pascal
asm
  MOV BYTE PTR [EAX], 0      // gravar byte
  MOV WORD PTR [EAX], 0      // gravar word (2 bytes)
  MOV DWORD PTR [EAX], 0     // gravar dword (4 bytes)
  MOV QWORD PTR [EAX], 0     // gravar qword (8 bytes, x64)
end;
```

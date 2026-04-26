# Pseudo-ops x64 do Delphi Built-in Assembler — Referencia Completa

## Lista de pseudo-ops

### .PARAMS N
Declara que a funcao tem N parametros. Instrui o compilador a:
- Gerar prologo com PUSH RBP / MOV RBP, RSP
- Reservar shadow space de 32 bytes (obrigatorio Win64)
- Gerar epilogo com MOV RSP, RBP / POP RBP / RET

```pascal
function Func(A, B, C: Integer): Integer; assembler;
asm
  .PARAMS 3       // 3 parametros
  // A=ECX, B=EDX, C=R8D
  MOV EAX, ECX
  ADD EAX, EDX
  ADD EAX, R8D
end;
```

**Quando usar:** Qualquer funcao x64 que chame outras funcoes (nao-leaf).
**Quando omitir:** Funcoes leaf simples sem chamadas a outros simbolos.

### .PUSHNV registrador
Salva registrador inteiro non-volatile no prologo e restaura no epilogo automaticamente.

```pascal
asm
  .PARAMS 2
  .PUSHNV R12    // PUSH R12 no prologo, POP R12 no epilogo
  .PUSHNV R13    // PUSH R13
  // Pode usar R12 e R13 livremente aqui
end;
```

**Registradores non-volatile Win64 que podem precisar salvar:**
`RBX, RBP, RDI, RSI, R12, R13, R14, R15`

### .SAVENV XMMreg
Salva registrador XMM non-volatile na area de home (home space) da pilha.

```pascal
asm
  .PARAMS 2
  .SAVENV XMM6    // salva XMM6 (non-volatile no Win64)
  .SAVENV XMM7    // salva XMM7
  // Pode usar XMM6 e XMM7 livremente
end;
```

**XMM non-volatile Win64:** XMM6 a XMM15 devem ser preservados.
XMM0-XMM5 sao volateis (podem ser destruidos).

### .NOFRAME
Suprime geracao de prologo e epilogo completamente.

```pascal
function LeafFunc(N: Integer): Boolean; assembler; nostackframe;
asm
  // SEM: PUSH RBP / MOV RBP,RSP / ... / POP RBP
  TEST ECX, ECX   // N=ECX (Win64)
  SETNZ AL        // AL = (N != 0)
end;
```

**Restricoes com .NOFRAME:**
- NAO pode chamar outras funcoes (pilha nao alinhada/sem shadow space)
- NAO pode ter variaveis locais
- NAO deve modificar registradores non-volatile sem salvar

## Ordem de uso dos pseudo-ops

```pascal
asm
  .PARAMS N       // DEVE vir primeiro
  .PUSHNV reg1    // depois
  .PUSHNV reg2
  .SAVENV XMMreg
  // Codigo asm aqui
end;
```

## Exemplo completo com todos os pseudo-ops

```pascal
function ProcessarArray(P: PInteger; N: Integer): Int64; assembler;
asm
  .PARAMS 2         // P=RCX, N=EDX; frame + shadow space
  .PUSHNV R12       // salvar R12 (usaremos como ponteiro)
  .PUSHNV R13       // salvar R13 (usaremos como contador)

  MOV  R12, RCX     // R12 = P
  MOV  R13D, EDX    // R13 = N
  XOR  RAX, RAX     // RAX = soma = 0

@loop:
  TEST R13D, R13D
  JZ   @fim
  MOVSXD RCX, DWORD PTR [R12]  // RCX = *P (sign-extended para 64-bit)
  ADD  RAX, RCX                  // soma
  ADD  R12, 4                    // P++
  DEC  R13D
  JMP  @loop

@fim:
  // RAX = resultado (Int64)
  // R12, R13 restaurados automaticamente pelo epilogo
end;
```

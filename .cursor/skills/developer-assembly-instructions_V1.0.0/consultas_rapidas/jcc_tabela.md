# Tabela completa de saltos condicionais (Jcc)

## Todos os Jcc — condição, flags, sinônimos

| Instrução | Sinônimos | Condição (após CMP a,b) | Flags testadas |
|-----------|-----------|------------------------|----------------|
| **JE** | JZ | a == b (igual / zero) | ZF = 1 |
| **JNE** | JNZ | a != b (diferente / não zero) | ZF = 0 |
| **JG** | JNLE | a > b (**signed**) | ZF=0 AND SF=OF |
| **JGE** | JNL | a >= b (**signed**) | SF = OF |
| **JL** | JNGE | a < b (**signed**) | SF ≠ OF |
| **JLE** | JNG | a <= b (**signed**) | ZF=1 OR SF≠OF |
| **JA** | JNBE | a > b (**unsigned**, above) | CF=0 AND ZF=0 |
| **JAE** | JNB, JNC | a >= b (**unsigned**) | CF = 0 |
| **JB** | JNAE, JC | a < b (**unsigned**, below) | CF = 1 |
| **JBE** | JNA | a <= b (**unsigned**) | CF=1 OR ZF=1 |
| **JS** | — | resultado negativo | SF = 1 |
| **JNS** | — | resultado não negativo | SF = 0 |
| **JO** | — | overflow de signed | OF = 1 |
| **JNO** | — | sem overflow | OF = 0 |
| **JP** | JPE | paridade par | PF = 1 |
| **JNP** | JPO | paridade ímpar | PF = 0 |
| **JCXZ** | — | ECX = 0 (32-bit) | CX/ECX = 0 |
| **JECXZ** | — | ECX = 0 | ECX = 0 |
| **JRCXZ** | — | RCX = 0 (64-bit) | RCX = 0 |

## Guia rápido: quando usar signed vs unsigned

| Use signed (JG/JL) quando: | Use unsigned (JA/JB) quando: |
|---------------------------|------------------------------|
| Comparando Integer, Int64 | Comparando Cardinal, DWORD, pointers |
| Valores podem ser negativos | Comparando endereços de memória |
| Índices de array (podem ser -1) | Comparando resultados de operações lógicas |
| Comparando com 0 por sinal | Verificando carry (ADC, SBB) |

## Padrão de uso (Intel syntax / Delphi)

```pascal
// Após CMP EAX, EBX:
asm
  CMP  EAX, EBX
  JE   @igual         // EAX = EBX
  JNE  @diferente     // EAX ≠ EBX
  JG   @maior         // EAX > EBX (signed)
  JL   @menor         // EAX < EBX (signed)
  JGE  @maiorig       // EAX >= EBX (signed)
  JLE  @menorig       // EAX <= EBX (signed)
  JA   @acima         // EAX > EBX (unsigned)
  JB   @abaixo        // EAX < EBX (unsigned)

@igual:
// ...

// Padrão equivalente em Pascal:
if EAX = EBX then ...
```

## Inversão de condição (para otimizar fluxo)

| Original | Inverso |
|----------|---------|
| JE | JNE |
| JG | JLE |
| JGE | JL |
| JA | JBE |
| JAE | JB |
| JS | JNS |
| JO | JNO |

```nasm
; Em vez de:
  cmp eax, ebx
  je  .igual
  jmp .diferente
.igual:
  ; código

; Preferir (elimina o JMP):
  cmp eax, ebx
  jne .diferente   ; inverte a condição!
  ; código do caso "igual"
.diferente:
```

## JMP incondicional — formas

```nasm
jmp  label          ; relativo (curto: ±127, longo: ±2GB)
jmp  rax            ; indireto via registrador (jump table)
jmp  [rax]          ; indireto via memória (ponteiro de função)
jmp  [rax + rcx*8]  ; jump table indexada
```

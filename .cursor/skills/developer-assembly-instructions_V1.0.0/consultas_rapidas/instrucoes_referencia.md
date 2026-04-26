# Instruções x86 — Tabela de referência rápida

## Transferência de dados

| Instrução | Operandos | Flags afetadas | Descrição |
|-----------|-----------|----------------|-----------|
| MOV | dst, src | Nenhuma | Copia src para dst |
| MOVZX | dst, src | Nenhuma | Copia com zero-extension |
| MOVSX | dst, src | Nenhuma | Copia com sign-extension |
| XCHG | a, b | Nenhuma (ou LOCK implícito) | Troca valores |
| LEA | dst, [mem] | Nenhuma | Carrega endereço efetivo |
| PUSH | src | Nenhuma (ESP/RSP) | Empilha: RSP-=8; [RSP]=src |
| POP | dst | Nenhuma | Desempilha: dst=[RSP]; RSP+=8 |

## Aritmética

| Instrução | Operandos | Flags afetadas | Descrição |
|-----------|-----------|----------------|-----------|
| ADD | dst, src | CF,OF,SF,ZF,AF,PF | dst = dst + src |
| SUB | dst, src | CF,OF,SF,ZF,AF,PF | dst = dst - src |
| ADC | dst, src | CF,OF,SF,ZF,AF,PF | dst = dst + src + CF |
| SBB | dst, src | CF,OF,SF,ZF,AF,PF | dst = dst - src - CF |
| INC | dst | OF,SF,ZF,AF,PF (NÃO CF) | dst++ |
| DEC | dst | OF,SF,ZF,AF,PF (NÃO CF) | dst-- |
| NEG | dst | CF,OF,SF,ZF,AF,PF | dst = -dst |
| MUL | src | CF,OF | EDX:EAX = EAX * src (unsigned) |
| IMUL | src | CF,OF | EDX:EAX = EAX * src (signed) |
| IMUL | dst, src | CF,OF | dst = dst * src (2 operandos) |
| IMUL | dst, src, imm | CF,OF | dst = src * imm (3 operandos) |
| DIV | src | Undefined | EAX=quociente, EDX=resto (unsigned) |
| IDIV | src | Undefined | EAX=quociente, EDX=resto (signed) |
| CDQ | — | Nenhuma | Sign-extend EAX → EDX:EAX |
| CQO | — | Nenhuma | Sign-extend RAX → RDX:RAX |

## Lógica

| Instrução | Operandos | Flags | Descrição |
|-----------|-----------|-------|-----------|
| AND | dst, src | CF=0,OF=0,SF,ZF,PF | dst = dst AND src |
| OR | dst, src | CF=0,OF=0,SF,ZF,PF | dst = dst OR src |
| XOR | dst, src | CF=0,OF=0,SF,ZF,PF | dst = dst XOR src |
| NOT | dst | Nenhuma | dst = NOT dst (complemento) |
| TEST | dst, src | CF=0,OF=0,SF,ZF,PF | AND sem salvar (só flags) |

## Deslocamentos e rotações

| Instrução | Operandos | Flags | Descrição |
|-----------|-----------|-------|-----------|
| SHL/SAL | dst, N | CF,OF,SF,ZF,PF | Shift left: dst <<= N |
| SHR | dst, N | CF,OF,SF,ZF,PF | Shift right lógico: dst >>= N (fill 0) |
| SAR | dst, N | CF,OF,SF,ZF,PF | Shift right aritmético (fill sign bit) |
| ROL | dst, N | CF,OF | Rotate left |
| ROR | dst, N | CF,OF | Rotate right |
| RCL | dst, N | CF,OF | Rotate left through carry |
| RCR | dst, N | CF,OF | Rotate right through carry |

Nota: contador variável DEVE estar em CL (`shl eax, cl`).

## Comparação e saltos

| Instrução | Operandos | Flags | Descrição |
|-----------|-----------|-------|-----------|
| CMP | dst, src | CF,OF,SF,ZF,AF,PF | SUB sem salvar (só flags) |
| JMP | label/reg | — | Salto incondicional |
| Jcc | label | — | Salto condicional (ver jcc_tabela.md) |
| LOOP | label | ZF (LOOPE/LOOPNE) | DEC RCX; JNZ label |
| CALL | label/reg | — | PUSH RIP; JMP label |
| RET | — | — | POP RIP; (JMP) |
| RET N | N | — | POP RIP; RSP += N |

## String (com prefixo REP)

| Instrução | Prefixo | Descrição |
|-----------|---------|-----------|
| MOVSB/W/D/Q | REP | Copia [RSI] → [RDI] |
| STOSB/W/D/Q | REP | Armazena AL/AX/EAX/RAX em [RDI] |
| LODSB/W/D/Q | REP | Carrega [RSI] em AL/AX/EAX/RAX |
| SCASB/W/D/Q | REPE/REPNE | Busca AL/AX/EAX em [RDI] |
| CMPSB/W/D/Q | REPE/REPNE | Compara [RSI] com [RDI] |

## Especiais

| Instrução | Descrição |
|-----------|-----------|
| NOP | No operation (1 byte: 0x90) |
| HLT | Halt (ring 0 only) |
| INT 3 | Breakpoint de software (0xCC, 1 byte) |
| CPUID | Query CPU features (destrói EAX,EBX,ECX,EDX) |
| RDTSC | Read Time Stamp Counter → EDX:EAX |
| PAUSE | Hint para spin-wait loops |
| LOCK | Prefixo: garante atomicidade da instrução seguinte |
| XADD | src = dst; dst = dst+src (atômico com LOCK) |
| CMPXCHG | CAS: se dst=EAX, dst=src; EAX=valor anterior |

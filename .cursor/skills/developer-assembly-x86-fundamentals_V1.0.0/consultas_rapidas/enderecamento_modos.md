# Modos de endereçamento x86-64 — Tabela de referência

## Todos os modos (Intel syntax)

| Modo | Notação NASM | Exemplo | Endereço calculado |
|------|-------------|---------|-------------------|
| **Imediato** | literal | `mov eax, 42` | N/A (valor está na instrução) |
| **Registrador** | reg | `mov eax, ebx` | N/A (sem acesso à memória) |
| **Direto** | `[endereço]` | `mov eax, [0x404000]` | Endereço literal |
| **Indireto** | `[reg]` | `mov eax, [rbx]` | RBX |
| **Baseado** | `[reg + disp]` | `mov eax, [rbx + 8]` | RBX + 8 |
| **Indexado** | `[reg + reg]` | `mov eax, [rbx + rcx]` | RBX + RCX |
| **Indexado c/ escala** | `[base + idx*N]` | `mov eax, [rbx + rcx*4]` | RBX + RCX × 4 |
| **Completo** | `[base + idx*N + disp]` | `mov eax, [rbx + rcx*4 + 16]` | RBX + RCX × 4 + 16 |
| **RIP-relative** (x64) | `[rel label]` | `mov rax, [rel var]` | RIP + offset (PC-relativo) |

## Escalas válidas para índice

| Escala | Caso de uso |
|--------|-------------|
| *1 | bytes, qualquer tipo (escala padrão) |
| *2 | words (Int16, Word) |
| *4 | dwords (Int32, Cardinal, Single, ponteiros 32-bit) |
| *8 | qwords (Int64, Double, ponteiros 64-bit) |

## Exemplos práticos no Delphi

```pascal
// Acesso a array Pascal (elemento de 4 bytes) com modo indexado:
// arr[i] onde arr: array of Integer

// 32-bit: EBX = @arr[0], ECX = i
// mov eax, [ebx + ecx*4]   ; EAX = arr[i]

// 64-bit: RBX = @arr[0], RCX = i
// mov eax, [rbx + rcx*4]   ; EAX = arr[i]

// Acesso a campo de record:
// TMyRecord = record A: Integer; B: Integer; C: Integer end;
// Offsets: A @ +0, B @ +4, C @ +8

// mov eax, [rbx + 4]   ; EAX = rec.B (se RBX = @rec)
```

## LEA — calculadora de endereço

LEA computa o endereço **sem acessar a memória**, usando a ULA do processador.
Útil para multiplicações por constantes pequenas sem MUL:

```nasm
lea eax, [eax*2]        ; EAX = EAX * 2
lea eax, [eax + eax*2]  ; EAX = EAX * 3
lea eax, [eax*4]        ; EAX = EAX * 4
lea eax, [eax + eax*4]  ; EAX = EAX * 5
lea eax, [eax*8]        ; EAX = EAX * 8
lea eax, [eax + eax*8]  ; EAX = EAX * 9
```

## Restrições

- Apenas **um registrador índice** (com escala) por endereço
- Escala válida: somente 1, 2, 4, 8
- **RSP** não pode ser usado como registrador índice (apenas como base)
- **RBP/R13** como base sem deslocamento → interpretado como `[RIP+0]` em x64 (use `[RBP+0]` com disp=0 explícito)
- Deslocamento máximo: 32-bit (sign-extended para 64-bit)

# Anatomia do Stack Frame — 32-bit (Win32 / Protected Mode)

## Diagrama do frame

```
Endereço maior
┌────────────────────────────────────┐
│  ... parâmetros 4+ (se houver)    │ [EBP + 20], [EBP + 16], ...
├────────────────────────────────────┤
│  3° parâmetro (stdcall/pascal)    │ [EBP + 16]
├────────────────────────────────────┤
│  2° parâmetro (stdcall/pascal)    │ [EBP + 12]
├────────────────────────────────────┤
│  1° parâmetro (stdcall/pascal)    │ [EBP + 8]
├────────────────────────────────────┤
│  Return Address (CALL empilhou)   │ [EBP + 4]
├────────────────────────────────────┤  ← EBP aponta aqui
│  Saved EBP (PUSH EBP)             │ [EBP + 0]
├────────────────────────────────────┤
│  Variável local 1                 │ [EBP - 4]
├────────────────────────────────────┤
│  Variável local 2                 │ [EBP - 8]
├────────────────────────────────────┤
│  Variável local 3                 │ [EBP - 12]
├────────────────────────────────────┤
│  (padding para alinhamento)       │
├────────────────────────────────────┤  ← ESP durante execução da função
│  (área de trabalho / chamadas)    │
└────────────────────────────────────┘
Endereço menor (stack cresce para baixo)
```

## Prologue 32-bit

```nasm
; Gerado pelo compilador (ou manualmente):
push    ebp         ; salva frame pointer anterior
mov     ebp, esp    ; EBP = novo frame pointer
sub     esp, N      ; reserva N bytes (locais; N múltiplo de 4 normalmente)
```

## Epilogue 32-bit

```nasm
; Convencional:
mov     esp, ebp    ; restaura ESP
pop     ebp         ; restaura frame pointer

; Alternativo (LEAVE é equivalente às 2 linhas acima):
leave

; Return:
ret                 ; convenção register: callee NÃO limpa params
ret N               ; stdcall/pascal: callee limpa N bytes de params
```

## Acesso a parâmetros por convenção

| Convenção | Como chegam os params | Quem limpa a stack |
|-----------|----------------------|-------------------|
| **register** | EAX, EDX, ECX (3 primeiros) | Callee não limpa |
| **stdcall** | todos na stack [EBP+8], [EBP+12]... | Callee (RET N) |
| **cdecl** | todos na stack [EBP+8], [EBP+12]... | Caller (ADD ESP,N) |
| **pascal** | na stack (ordem inversa) | Callee (RET N) |

## Convenção "register" do Delphi (padrão)

```
Para métodos de objeto:
  EAX = Self
  EDX = 1° parâmetro
  ECX = 2° parâmetro
  [EBP+8] = 3° parâmetro (na stack)

Para funções livres:
  EAX = 1° parâmetro
  EDX = 2° parâmetro
  ECX = 3° parâmetro
  [EBP+8] = 4° parâmetro (na stack)
```

## O que CALL e RET fazem ao ESP

```
Antes do CALL:    ESP = X (parâmetros já empilhados se stdcall)
CALL executa:     ESP = X - 4; [ESP] = EIP_next; EIP = função
Dentro da função: ESP = X - 4 (return address no topo)
PUSH EBP:         ESP = X - 8
MOV EBP,ESP:      EBP = X - 8
SUB ESP,N:        ESP = X - 8 - N

RET executa:      EIP = [ESP]; ESP += 4 (+ N se RET N)
Após RET:         ESP volta para X (antes do CALL)
```

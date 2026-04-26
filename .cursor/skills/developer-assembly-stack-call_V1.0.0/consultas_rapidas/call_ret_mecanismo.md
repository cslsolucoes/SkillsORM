# CALL e RET — Mecanismo detalhado

## O que CALL faz (passo a passo)

```
CALL label:
  1. RSP = RSP - 8                         (reserva espaço)
  2. Mem[RSP] = endereço da próxima instrução  (salva return address)
  3. RIP = endereço de label               (salta para a função)

Equivalente em pseudo-código:
  push rip_next    ; (RSP -= 8; [RSP] = endereço após CALL)
  jmp  label
```

## O que RET faz (passo a passo)

```
RET:
  1. RIP = Mem[RSP]    (carrega return address do topo da stack)
  2. RSP = RSP + 8     (remove return address)
  3. Continua em RIP   (volta para o chamador)

RET N (N = número de bytes de parâmetros a limpar):
  1. RIP = Mem[RSP]
  2. RSP = RSP + 8 + N
  (usado em stdcall/pascal onde o callee limpa a stack)
```

## Visualização da stack durante CALL/RET

```
ANTES do CALL (no chamador):
  RSP → [dado_qualquer]

APÓS "PUSH RIP_NEXT" (parte do CALL):
  RSP → [return_address]  ← RSP aponta para o return address
         [dado_qualquer]

DENTRO da função, após PUSH RBP:
  RSP → [saved_rbp]
         [return_address]
         [dado_qualquer]

APÓS RET:
  RSP → [dado_qualquer]  ← RSP restaurado ao estado pré-CALL
  RIP → instrução após o CALL no chamador
```

## CALL indireto

```nasm
; Chamada via registrador (ponteiro de função):
call    rax         ; chama a função cujo endereço está em RAX

; Chamada via memória (tabela de funções):
call    [rax]       ; chama função no endereço armazenado em [RAX]
call    [rax + 8]   ; função no endereço em [RAX+8]

; Em Delphi:
// Chamada via ponteiro de função:
type TFuncao = function(X: Integer): Integer;
var F: TFuncao;
begin
  F := @MinhaFuncao;
  asm
    MOV  EAX, Param
    CALL F            // CALL via variável (Delphi resolve para CALL [&F])
  end;
end;
```

## Retorno múltiplo — não existe em x86

Em x86 existe apenas 1 valor de retorno (RAX ou XMM0). Para retornar múltiplos valores:
- Passar ponteiro para struct como parâmetro extra
- Usar variáveis globais (evitar!)
- Retornar struct pequena em RAX:RDX (até 16 bytes em algumas ABIs)

## CALL e stack em contexto de exceções

```
Quando uma exceção é lançada (SEH/unwind):
1. O runtime percorre a tabela de unwind (.pdata no PE) de dentro para fora
2. Para cada frame: executa cleanup (destruição de objetos, POP de callee-saved)
3. Usa as unwind informações geradas por .PUSHNV / .SAVENV para saber
   quais registradores foram salvos e onde
4. Restaura RSP e registradores de acordo
5. Salta para o handler (except/finally)

Por isso .PUSHNV é obrigatório (não manual PUSH) em 64-bit para código
que pode ter exceções atravessando o frame
```

## Diferença de convenções de chamada

| Convenção | Limpeza da stack | Uso no Delphi |
|-----------|-----------------|---------------|
| register | Caller (automático — params em regs) | Padrão para funções Delphi |
| cdecl | Caller (ADD ESP,N após call) | Interop com C libs (32-bit) |
| stdcall | Callee (RET N) | WinAPI 32-bit |
| fastcall | Callee (RET N) | Variante de register |
| Windows x64 | Caller (32 bytes shadow) | Padrão do dcc64 e WinAPI 64-bit |

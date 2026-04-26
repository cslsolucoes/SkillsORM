# Convencoes de Chamada Delphi — Consulta Rapida

## Padrao por plataforma

| Plataforma | Convencao padrao | Declaracao explicita |
| ---------- | ---------------- | -------------------- |
| Win32      | `register`       | Opcional             |
| Win64      | Win64 ABI        | Automatica           |
| Linux x64  | System V AMD64   | Via FPC              |

## Quem limpa a pilha?

| Convencao  | Quem limpa | Instrucao de retorno |
| ---------- | ---------- | -------------------- |
| `register` | callee     | `RET N` (implicito)  |
| `stdcall`  | callee     | `RET N`              |
| `cdecl`    | caller     | `RET` (sem N)        |
| `pascal`   | callee     | `RET N`              |
| `safecall` | callee     | `RET N`              |
| Win64      | caller     | `RET`                |

## Passagem de parametros inteiros

### Win32 register (padrao Delphi):
```
1o param → EAX
2o param → EDX
3o param → ECX
4o+ param → pilha (direita para esquerda)
```

### Win32 stdcall/cdecl/pascal:
```
Todos na pilha, direita para esquerda
[EBP+8]  = 1o param
[EBP+12] = 2o param
[EBP+16] = 3o param
```

### Windows x64 ABI:
```
1o param → RCX (ou XMM0 se float)
2o param → RDX (ou XMM1 se float)
3o param → R8  (ou XMM2 se float)
4o param → R9  (ou XMM3 se float)
5o+ param → pilha (direita para esquerda, acima do shadow space)
```

## Retorno de valores

| Tipo         | Win32 register/stdcall | Win64         |
| ------------ | ---------------------- | ------------- |
| Integer/Bool | EAX                    | RAX (EAX)     |
| Int64        | EDX:EAX                | RAX           |
| Pointer      | EAX                    | RAX           |
| Single       | ST(0)                  | XMM0          |
| Double       | ST(0)                  | XMM0          |
| Record <=8B  | EDX:EAX                | RAX           |
| Record >8B   | Ponteiro em EAX        | Ponteiro em RAX|

## Declaracao em Pascal

```pascal
procedure Proc1(A: Integer); register;  // padrao — register opcional
procedure Proc2(A: Integer); stdcall;
procedure Proc3(A: Integer); cdecl;
procedure Proc4(A: Integer); pascal;
procedure Proc5(A: Integer); safecall;  // COM only
```

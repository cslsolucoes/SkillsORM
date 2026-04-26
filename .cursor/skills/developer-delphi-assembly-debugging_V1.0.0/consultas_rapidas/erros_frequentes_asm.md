# Erros Frequentes em Assembly Delphi — Diagnostico Rapido

## Erros de compilacao

| Erro       | Mensagem                              | Causa                                  | Solucao                                |
| ---------- | ------------------------------------- | -------------------------------------- | -------------------------------------- |
| E2426      | Cannot inline assembler procedures    | `inline` + `asm` combinados            | Remover `inline;`                      |
| E2089      | Invalid typecast                      | PTR invalido ou tamanho errado         | Verificar BYTE/WORD/DWORD PTR          |
| E2003      | Undeclared identifier                 | Label sem `@` confunde parser          | Adicionar `@` nos labels               |
| E2036      | Variable required                     | OFFSET em variavel local               | OFFSET funciona apenas em globais      |
| E1026      | File not found                        | {$L arquivo.obj} nao encontrado        | Verificar caminho e nome do .obj       |
| E2010      | Incompatible types                    | Tamanho errado em operando             | Verificar registrador vs tipo          |

## Bugs em runtime — diagnostico

### Crash imediato (AV — Access Violation):
- **Sintoma:** EIP aponta para endereco invalido apos RET
- **Causa:** Stack imbalance — mais PUSH que POP, ou RET N errado
- **Debug:** Verificar ESP antes e depois da funcao; verificar N em RET N (stdcall)

### Resultado incorreto mas sem crash:
- **Sintoma:** Valor de retorno errado, mas nao crasha
- **Causa:** Registrador errado (confundiu EAX/EDX/ECX), ou calculo errado
- **Debug:** CPU View, passo a passo, verificar EAX antes do RET

### Bug que aparece em outro lugar (Heisenbug):
- **Sintoma:** Crash ou calculo errado em funcao completamente diferente
- **Causa:** Registrador non-volatile (EBX/ESI/EDI) destruido sem salvar
- **Debug:** Verificar que EBX, ESI, EDI tem os mesmos valores antes e depois da funcao asm

### SIMD crash (sigfault/AV em instrucao SSE):
- **Causa 1:** MOVAPS em dados nao-alinhados em 16 bytes → usar MOVUPS
- **Causa 2:** CPU sem suporte SSE/AVX → verificar CPUID antes
- **Causa 3:** VZEROUPPER nao chamado apos AVX → penalidade ou corrupção de estado

### Corrupcao de heap/objetos Delphi:
- **Causa:** Escrita em offset errado de objeto (campo + 4 bytes de ponteiro VMT)
- **Debug:** FastMM4 com `ReportMemoryLeaksOnShutdown := True`; verificar offsets no CPU View

## Checklist de verificacao pre-commit de codigo asm

- [ ] Todos os registradores callee-saved (EBX, ESI, EDI em Win32) preservados com PUSH/POP
- [ ] ESP/RSP balanceado: mesmo valor antes e depois da funcao
- [ ] RET N correto em stdcall (N = numero de bytes dos parametros)
- [ ] VZEROUPPER chamado apos instrucoes AVX (antes de SSE/FPU)
- [ ] XMM6-XMM15 preservados com .SAVENV em Win64
- [ ] MOVUPS (nao MOVAPS) para dados sem garantia de alinhamento
- [ ] CPUID verificado antes de usar SSE/AVX/AVX-512
- [ ] Labels com @ para evitar conflito com identificadores Pascal
- [ ] INT 3 protegido com {$IFDEF DEBUG}

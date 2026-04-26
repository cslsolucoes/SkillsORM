# Trilha de Aprendizado Assembly Delphi — Consulta Rapida

## Nivel 1: Fundamentos (comecar aqui)

### Etapa 1: Convencoes de Chamada
**Skill:** `developer-delphi-assembly-calling-conventions` (J1)

Objetivos:
- Entender que EAX/EDX/ECX sao os 3 primeiros params em Win32 register
- Memorizar registradores callee-saved: EBX, ESI, EDI (Win32) e R12-R15, XMM6-15 (Win64)
- Entender shadow space Win64 (32 bytes obrigatorios antes de CALL)
- Praticar: escrever funcao stdcall com PUSH/POP de EBX e RET N correto

### Etapa 2: Assembly Inline
**Skill:** `developer-delphi-assembly-inline` (J2)

Objetivos:
- Escrever primeiro bloco `asm..end` dentro de funcao Pascal
- Usar labels com `@` (nunca sem @)
- Acessar variaveis por nome (nao por [EBP-N])
- Verificar restricoes: sem `inline`, sem `(* *)`, Win32/Win64 apenas

## Nivel 2: Intermediario

### Etapa 3: Funcoes Assembly Puras
**Skill:** `developer-delphi-assembly-functions` (J3)

Objetivos:
- Criar funcao com keyword `assembler` (sem begin/end Pascal)
- Usar `.PARAMS`, `.PUSHNV`, `.NOFRAME` corretamente em x64
- Linkar arquivo .obj NASM com `{$L arquivo.obj}`

### Etapa 4: Expressoes em Compilacao
**Skill:** `developer-delphi-assembly-expressions` (J5)

Objetivos:
- Calcular tamanho de tipos com TYPE e SIZE
- Usar VMTOFFSET para chamar metodo virtual em asm
- Otimizar multiplicacao simples com LEA

### Etapa 5: Debugging
**Skill:** `developer-delphi-assembly-debugging` (J6)

Objetivos:
- Abrir CPU View e navegar pelos 5 paineis
- Inspecionar registradores passo-a-passo (F8)
- Medir ciclos com RDTSC antes e depois da otimizacao
- Diagnosticar stack imbalance comparando ESP antes/depois

## Nivel 3: Avancado

### Etapa 6: SIMD/AVX
**Skill:** `developer-delphi-assembly-simd-avx` (J4)

Objetivos:
- Verificar suporte de CPU com CPUID antes de usar SSE/AVX
- Processar 4 floats em paralelo com ADDPS/MULPS (SSE)
- Processar 8 floats em paralelo com VADDPS (AVX, YMM)
- Usar `<k1><z>` para masking AVX-512 (angle brackets Delphi!)
- Preservar XMM6-XMM15 com `.SAVENV` em Win64
- Chamar VZEROUPPER apos instrucoes AVX antes de SSE

## Progresso sugerido por semana

| Semana | Foco                          | Skill        | Exercicio                              |
| ------ | ----------------------------- | ------------ | -------------------------------------- |
| 1      | Convencoes Win32              | J1           | Funcao stdcall com 3 params em NASM   |
| 2      | Inline basico                 | J2           | Funcao soma com asm..end no Delphi    |
| 3      | Funcao assembler + debugging  | J3 + J6      | Funcao pura + debugar no CPU View     |
| 4      | Expressoes + VMTOFFSET        | J5           | Chamar metodo virtual via VMTOFFSET   |
| 5      | SSE basico                    | J4           | Soma de array com ADDPS               |
| 6      | AVX + benchmark               | J4 + J6      | AVX2 soma vs SSE vs Pascal (RDTSC)    |

# CPU View — Guia de uso no RAD Studio

## Abrindo o CPU View

- Menu: **View → Debug Windows → CPU View**
- Atalho: **Ctrl + Alt + C**
- Disponível apenas durante debugging (F9 com breakpoint)

## Painéis do CPU View

### Painel superior — Disassembly
- Mostra o disassembly do código em torno do EIP/RIP atual
- Seta amarela indica a próxima instrução a executar
- F7 = Step Into (entra em CALL)
- F8 = Step Over (executa CALL inteiro)
- F4 = Run to Cursor

### Painel esquerdo — Registers
- Exibe todos os registradores gerais em tempo real
- Valores destacados em vermelho = mudaram na última instrução
- Clique duplo em um registrador para editar seu valor durante debug
- Mostra: EAX/RAX, EBX/RBX, ECX/RCX, EDX/RDX, ESI/RSI, EDI/RDI, ESP/RSP, EBP/RBP
- Em 64-bit: mostra também R8-R15
- EFL / RFLAGS: cada bit de flag é exibido separadamente (ZF, CF, SF, OF, DF, IF...)

### Painel direito — FPU / XMM
- Mostra registradores FPU (ST0-ST7) ou XMM0-XMM15 (alternável)
- Para ver XMM: clique direito → "Show FPU Registers" ou "Show XMM Registers"

### Painel inferior — Stack / Dump
- **Stack**: mostra o conteúdo da stack a partir de ESP/RSP
- **Dump**: mostra memória em formato hexadecimal + ASCII
- Para inspecionar uma variável: selecionar nome → clique direito → "Follow in Dump"

## Workflow para depurar código asm..end

```
1. Colocar breakpoint na primeira instrução do bloco asm
2. Executar com F9
3. Quando parar, observar:
   - Registradores antes da execução de cada instrução
   - Usar F8 para step-over instrução a instrução
   - Observar quais registradores ficam vermelhos (mudaram)
4. Para verificar memória:
   - No painel Dump, inserir endereço (ex: [ESP] ou endereço de variável)
   - Observar bytes antes e depois de MOV/PUSH/POP
```

## Atalhos úteis durante debugging

| Atalho | Ação |
|--------|------|
| F9 | Run / Continue |
| F8 | Step Over (não entra em CALL) |
| F7 | Step Into (entra em CALL) |
| Shift+F8 | Step Out (sai da função atual) |
| F4 | Run to cursor |
| Ctrl+F5 | Add breakpoint |
| F2 | Toggle breakpoint na linha |

## Inspecionando variáveis Pascal em asm

```pascal
procedure Debug;
var
  X: Integer;
begin
  X := 42;
  asm
    MOV EAX, X    // Colocar breakpoint aqui
    // No CPU View: observar EAX = 42 após step
    // No painel Dump: endereço de X = [EBP - offset]
    INC EAX
    MOV X, EAX   // Após step: X = 43 na janela Watch
  end;
  WriteLn(X);    // 43
end;
```

## Dicas avançadas

- **Data Breakpoint**: clique direito no Dump → "Add Data Breakpoint" → para quando o endereço é escrito
- **Conditional Breakpoint**: clique direito no breakpoint → Condition → expressão Pascal ou "EAX = 0"
- **Watch**: View → Debug Windows → Watches → adicionar nome de variável ou endereço `@Var`
- Para calcular offset de campo em record/object: `Integer(@Obj.Campo) - Integer(@Obj)` no Evaluate

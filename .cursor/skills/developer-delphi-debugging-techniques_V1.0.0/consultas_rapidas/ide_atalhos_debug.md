# Atalhos do Debugger IDE — Delphi RAD Studio

**Skill:** `developer-delphi-debugging-techniques_V1.0.0`
**Data:** 2026-04-11

---

## Teclas de controle de execução

| Tecla | Ação | Quando usar |
|-------|------|-------------|
| **F5** | Run / Continue | Iniciar execução ou retomar após breakpoint |
| **F8** | Step Over | Executar próxima linha; NÃO entra em funções chamadas |
| **F7** | Trace Into | Executar próxima linha; ENTRA na função chamada |
| **F4** | Run to Cursor | Executar até a linha onde está o cursor |
| **Shift+F7** | Trace Past | Executa o resto da função atual sem entrar em sub-chamadas |
| **Ctrl+F2** | Reset / Stop | Para o processo em execução |
| **F9** | Toggle Breakpoint | Criar/remover breakpoint na linha atual |

---

## Janelas de debug

| Tecla | Janela | Descrição |
|-------|--------|-----------|
| **Ctrl+Alt+B** | Breakpoints | Lista todos os breakpoints; editar condições e grupos |
| **Ctrl+Alt+W** | Watch List | Expressões para inspecionar valores em tempo real |
| **Ctrl+Alt+S** | Call Stack | Pilha de chamadas; navegar entre frames |
| **Ctrl+Alt+L** | Local Variables | Variáveis locais do frame atual |
| **Ctrl+Alt+E** | Event Log | OutputDebugString e eventos do debugger |
| **Ctrl+Alt+C** | CPU View | Disassembly + Registradores + Memória + FPU |
| **Ctrl+Alt+T** | Threads | Lista de threads; trocar thread ativa |
| **Ctrl+Alt+M** | Modules | Módulos/DLLs carregados no processo |

---

## CPU View — painéis e uso

```
CPU View (Ctrl+Alt+C):
┌─────────────────────────────────────┐
│ Disassembly  │ Registers            │
│ (código asm) │ EAX = 00000001       │
│              │ EBX = 00A3F200       │
│              │ ECX = 00000005       │
│              │ EDX = 00000000       │
│              │ ESP = 0018FF4C       │
│              │ EBP = 0018FF60       │
│              │ EIP = 004015A2       │
├─────────────────────────────────────┤
│ Stack        │ Memory               │
│ 0018FF4C: .. │ (endereço digitável) │
└─────────────────────────────────────┘
```

**Win32:** EAX, EBX, ECX, EDX, ESP, EBP, EIP  
**Win64:** RAX, RBX, RCX, RDX, RSP, RBP, RIP  

| Painel | Para que serve |
|--------|----------------|
| **Disassembly** | Ver código assembly gerado; identificar otimizações do compilador |
| **Registers** | Ver valores dos registradores no frame atual |
| **Stack** | Inspecionar conteúdo bruto da pilha em bytes |
| **Memory** | Digitar qualquer endereço (`@MinhaVar`) para ver bytes |
| **FPU/SSE** | Registradores de ponto flutuante e SIMD |

---

## Breakpoint — configurações avançadas

**Clicar direito no breakpoint → Properties (ou Edit Breakpoint):**

| Campo | Descrição | Exemplo |
|-------|-----------|---------|
| **Condition** | Expressão Pascal booleana | `I = 99` ou `Obj.Saldo < 0` |
| **Pass Count** | Parar apenas na N-ésima passagem | `25` |
| **Group** | Nome do grupo | `GrupoClientes` |
| **Action → Log message** | Escrever no Event Log sem parar | `'Valor=%d'` |
| **Action → Break** | Parar execução (padrão) | — |
| **Action → Enable/Disable group** | Ativar/desativar outro grupo ao atingir | — |

---

## Watch expressions — exemplos práticos

| Expressão | O que inspeciona |
|-----------|-----------------|
| `Objeto.Propriedade` | Valor de propriedade publicada |
| `Length(MeuArray)` | Tamanho de array dinâmico |
| `High(MeuArray)` | Último índice válido |
| `(TCliente(Obj)).Saldo` | Cast de TObject para TCliente |
| `@MinhaVar` | Endereço de memória da variável |
| `EAX` | Registrador (apenas na CPU View) |

---

## Navegar no Call Stack

1. Abrir Call Stack: **Ctrl+Alt+S**
2. Ler de cima para baixo — o frame do topo é onde a execução está pausada.
3. Dar duplo clique em qualquer frame para navegar até aquela linha no editor.
4. A Watch List atualiza com as variáveis locais daquele frame.
5. Frame mais interno = ponto exato do erro; frames abaixo = cadeia de chamadas.

---

## Configurar exceções que param o debugger

**Tools → Options → Debugger → Embarcadero Debuggers → Language Exceptions:**

- Adicionar tipo de exceção específico para parar sempre que lançado.
- Útil para: `EAccessViolation`, `EDivByZero`, exceções customizadas do projeto.
- Desmarcar "Stop on Delphi exceptions" para ignorar exceções tratadas.

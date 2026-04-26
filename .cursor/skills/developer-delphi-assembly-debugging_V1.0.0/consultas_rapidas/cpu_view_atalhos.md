# CPU View — Atalhos e Uso — Consulta Rapida

## Abrir CPU View

- Menu: **View → Debug Windows → CPU**
- Atalho: **Ctrl+Alt+C** (verificar no IDE instalado)
- Disponivel apenas quando em modo de debug com breakpoint ativo

## Paneis do CPU View

### Painel Disassembly (esquerda/superior)
- Mostra codigo assembly gerado pelo compilador para a area atual
- Seta amarela = instrucao atual (EIP/RIP)
- Clicar na margem: adicionar/remover breakpoint
- Clicar com botao direito: opcoes (Go to Address, New Origin...)
- **View → Show Symbol Names**: alternar entre enderecos e nomes de funcoes

### Painel Registers (direita/superior)
- Todos os registradores atuais (EAX-EDI, ESP, EBP, EIP em Win32)
- Valores alterados aparecem em vermelho (destaque de mudanca)
- Duplo-clique no valor: editar registrador manualmente (cuidado!)
- Mostra tambem FLAGS (ZF, SF, CF, OF etc.)

### Painel Stack (inferior)
- Conteudo da pilha a partir de ESP/RSP
- Cada linha = 4 bytes (Win32) ou 8 bytes (Win64)
- Enderecos reconhecidos (ponteiros de funcao, strings) sao rotulados

### Painel Memory (inferior)
- Inspecionar qualquer regiao de memoria
- Digitar endereco no campo: `EAX`, `ESP+8`, `0x00401000`
- Visualizacao: hex, ASCII, Unicode

### Painel FPU / SSE
- ST(0) a ST(7): registradores FPU x87 (usados para float em Win32)
- XMM0-XMM15: registradores SSE (128-bit cada)
- Flags de status FPU: C0, C1, C2, C3, TOP

## Teclas de execucao

| Tecla | Acao                              |
| ----- | --------------------------------- |
| F7    | Step Into (entra em CALL)         |
| F8    | Step Over (nao entra em CALL)     |
| F4    | Run to Cursor                     |
| F9    | Run (continuar)                   |
| Ctrl+F2 | Reset / Stop program            |

## Dicas de uso

### Inspecionar EAX apos CALL:
1. Colocar breakpoint na instrucao imediatamente APOS o CALL
2. Verificar EAX (retorno integer) ou XMM0 (retorno float x64)

### Detectar stack imbalance:
1. Anotar ESP antes da funcao
2. Executar a funcao
3. Verificar ESP apos: deve ser igual ao anotado

### Watch de registrador no Watch Window:
- Adicionar `EAX` no Watch Window (Ctrl+Alt+W)
- Atualiza automaticamente a cada passo

### Ir para endereco especifico:
- No painel Disassembly, Ctrl+G ou clicar direito → Go to Address
- Digitar `EIP+10` (relativo) ou `0x00401234` (absoluto)

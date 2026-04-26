# x64dbg — Guia de Uso para Assembly Delphi — Consulta Rapida

## O que e x64dbg

Debugger open-source para Windows (32-bit: x32dbg, 64-bit: x64dbg).
Ideal para inspecionar binarios Delphi externamente, sem IDE.
Download: https://x64dbg.com

## Abrir um binario Delphi

1. File → Open (ou arrastar o .exe)
2. O x64dbg para no entry point automaticamente
3. View → Symbols: localizar funcoes exportadas/simbolos de debug

## Paneis principais

| Painel     | Acao                                          |
| ---------- | --------------------------------------------- |
| CPU        | Disassembly + registradores + stack + memory  |
| Log        | Output de debug strings (OutputDebugString)   |
| Breakpoints| Lista de todos os breakpoints ativos          |
| Symbols    | Funcoes exportadas, simbolos PDB              |
| Memory Map | Mapa de memoria do processo                   |

## Comandos essenciais

### Execucao:
- F7: Step Into (1 instrucao, entra em CALL)
- F8: Step Over (1 instrucao, nao entra em CALL)
- F9: Run
- F2: Toggle Breakpoint na linha selecionada
- Ctrl+G: Ir para endereco (digitar `NomeFuncao` ou `0x401000`)

### Registradores:
- Painel Registers (direita): todos EAX-EDI, ESP, EBP, EFLAGS
- Duplo-clique no valor: editar

### Memoria:
- Painel Dump (inferior): inspecionar qualquer endereco
- Clicar direito no Dump: Follow in Dump, Goto, etc.
- `dump EAX` no command bar: inspecionar regiao apontada por EAX

### Breakpoints:
- F2 na instrucao desejada (toggle)
- Breakpoint condicional: clicar direito → Breakpoint → Conditional
- Hardware breakpoint: clicar direito → Breakpoint → Hardware → On Write/Read

## Localizar funcoes Delphi no x64dbg

Sem PDB (sem simbolos de debug):
1. View → Call Stack: identifica retornos
2. View → Modules: ver DLLs e seus exports
3. Pesquisar pattern de PUSH EBP/MOV EBP,ESP (prologo Win32)

Com PDB ou MAP file do Delphi:
1. File → Attach PDB (ou renomear .map para .pdb com ferramenta)
2. Simbolos aparecem automaticamente no painel Symbols

## OutputDebugString

Mensagens de `OutputDebugString` do codigo Delphi aparecem no painel **Log** do x64dbg.
Tambem visivel com DebugView (Sysinternals).

```pascal
// No Delphi:
OutputDebugString('Checkpoint: EAX valido');
// Aparece no Log do x64dbg sem parar a execucao
```

## Analisar stack frame no x64dbg

1. F8 ate entrar na funcao alvo
2. No painel Stack (inferior direito): ver conteudo de ESP
3. Colunas: Endereco | Valor Hex | Interpretacao
4. Verificar se parametros esperados estao nas posicoes corretas
   - [ESP+4] = primeiro param stdcall
   - [EBP+8] = primeiro param apos PUSH EBP + MOV EBP,ESP

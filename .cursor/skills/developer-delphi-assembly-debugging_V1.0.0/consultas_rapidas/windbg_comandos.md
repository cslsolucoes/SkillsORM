# WinDbg — Comandos para Assembly Delphi — Consulta Rapida

## O que e WinDbg

Debugger da Microsoft (parte do Windows SDK/WinDDK).
Ideal para: analise de crash dumps, kernel debugging, sessoes remotas.
Para debugging interativo de Delphi, x64dbg e geralmente mais conveniente.

Download: Windows SDK → "Debugging Tools for Windows"
Alternativa moderna: **WinDbg Preview** na Microsoft Store (UI melhorada)

## Abrir processo ou crash dump

```windbg
# Abrir executavel:
# File → Open Executable

# Abrir crash dump (.dmp):
# File → Open Crash Dump

# Anexar a processo rodando:
# File → Attach to Process
```

## Comandos de execucao

| Comando  | Acao                                |
| -------- | ----------------------------------- |
| `g`      | Go (continuar execucao)             |
| `p`      | Step Over (1 instrucao)             |
| `t`      | Step Into (1 instrucao, entra CALL) |
| `pa addr`| Step Over ate endereco              |
| `gu`     | Go Until return (sair da funcao)    |
| `q`      | Quit                                |

## Breakpoints

```windbg
bp 0x00401234         ; breakpoint em endereco
bp MinhaFuncao        ; breakpoint em simbolo (requer .pdb)
bp MinhaFuncao+0x10   ; breakpoint com offset
bl                    ; listar breakpoints
bc 0                  ; deletar breakpoint 0
ba r4 0x00601234      ; hardware breakpoint on READ de 4 bytes no endereco
```

## Inspecionar registradores e memoria

```windbg
r                     ; mostrar todos registradores
r eax                 ; mostrar EAX
r eax=42              ; setar EAX para 42

d 0x00401234          ; dump memoria no endereco (format padrao)
dd 0x00401234         ; dump como DWORDs
dq esp                ; dump QWORDs na pilha (Win64)
db 0x00401234 L20     ; dump 0x20 bytes no endereco

u 0x00401234          ; unassemble (disassembly) no endereco
u eip L10             ; 10 instrucoes a partir de EIP
```

## Analisar call stack

```windbg
k                     ; call stack simples
kb                    ; call stack com parametros
kv                    ; call stack com frame pointer verification
kn                    ; call stack numerado
```

## Crash dump — analise

```windbg
.ecxr                 ; restaurar contexto da excecao
!analyze -v           ; analise automatica do crash (muito util!)
!exchain             ; chain de excecoes
lm                    ; listar modulos carregados
```

## Carregar simbolos Delphi

```windbg
.sympath+ C:\Caminho\Para\PDB  ; adicionar pasta de simbolos
.reload                         ; recarregar simbolos
x MinhaApp!*                    ; listar simbolos do modulo
```

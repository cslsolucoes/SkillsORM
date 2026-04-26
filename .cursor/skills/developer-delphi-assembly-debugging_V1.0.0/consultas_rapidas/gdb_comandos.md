# GDB — Comandos para FPC/Assembly Linux — Consulta Rapida

## Contexto

GDB e o debugger padrao para projetos FPC (Free Pascal Compiler) em Linux.
Para Delphi no Windows, use x64dbg ou WinDbg (ver guias respectivos).

## Compilar FPC com debug info

```bash
fpc -g -O0 MeuPrograma.lpr   # -g = debug info, -O0 = sem otimizacao
# Para informacao de nivel de fonte (melhor):
fpc -gw -O0 MeuPrograma.lpr  # -gw = DWARF debug format
```

## Comandos essenciais GDB

```gdb
# Iniciar:
gdb ./MeuPrograma
(gdb) run [args]

# Breakpoints:
(gdb) break MinhaFuncao
(gdb) break MeuArquivo.pas:42
(gdb) break *0x00401234       # endereco especifico (hex)
(gdb) info breakpoints        # listar
(gdb) delete 1                # deletar breakpoint 1

# Execucao:
(gdb) step       # step into (entra em CALL)
(gdb) next       # step over
(gdb) stepi      # 1 instrucao assembly (step into)
(gdb) nexti      # 1 instrucao assembly (step over)
(gdb) continue   # continuar ate proximo breakpoint
(gdb) finish     # executar ate retorno da funcao atual

# Registradores:
(gdb) info registers              # todos registradores
(gdb) info registers eax ecx edx # registradores especificos
(gdb) print/x $eax               # imprimir EAX em hex
(gdb) print $rsp                  # RSP em decimal
(gdb) set $eax = 42              # setar EAX (com cuidado!)

# Memoria e disassembly:
(gdb) x/4xw $esp        # 4 words (4 bytes) em ESP em hex
(gdb) x/16xb $rip       # 16 bytes em RIP (proximas instrucoes)
(gdb) disassemble        # disassembly da funcao atual
(gdb) disassemble $pc, +40  # 40 bytes a partir do PC atual
(gdb) x/10i $rip        # 10 instrucoes a partir de RIP

# Call stack e frame:
(gdb) backtrace          # call stack completa
(gdb) frame 2            # selecionar frame 2
(gdb) info frame         # detalhe do frame selecionado
(gdb) info locals        # variaveis locais (requer debug info)

# Watchpoints:
(gdb) watch MinhaVar     # parar quando MinhaVar mudar
(gdb) rwatch *$eax       # parar quando regiao apontada por EAX for lida
```

## Dicas para FPC

```gdb
# Nomes de simbolos FPC sao mangled — usar tab-completion:
(gdb) break PROCNAME  # digitar parte do nome + Tab

# Variaveis Pascal:
(gdb) print MinhaVariavel   # imprimir valor
(gdb) print *PtrVar         # deref de ponteiro Pascal

# Acompanhar condicao de loop:
(gdb) watch -l Contador     # watch local no escopo atual
```

#!/bin/bash
# gdb_session.sh — Script GDB comentado para debug de binario Windows via Wine ou Linux FPC
# NOTA: GDB e mais relevante para projetos FPC/Linux
# Para Delphi/Windows, use x64dbg (ver x64dbg_guia.md)
#
# PRE-REQUISITO:
#   - GDB instalado: apt install gdb (Linux) ou gdb via MinGW (Windows)
#   - Binario compilado com info de debug: fpc -g programa.lpr

# Iniciar GDB com o executavel:
# gdb ./MeuPrograma.exe

# --- COMANDOS GDB ESSENCIAIS ---

# Iniciar execucao:
# (gdb) run
# (gdb) run arg1 arg2        # com argumentos

# Breakpoints:
# (gdb) break main           # breakpoint na funcao main/Pascal entry
# (gdb) break *0x00401234    # breakpoint em endereco especifico (hex)
# (gdb) break programa.pas:42 # breakpoint na linha 42 do arquivo

# Executar instrucao a instrucao:
# (gdb) step                 # step in (entra em CALL)
# (gdb) next                 # step over (nao entra em CALL)
# (gdb) stepi                # step 1 instrucao assembly (nao Pascal!)
# (gdb) nexti                # next 1 instrucao assembly

# Inspecionar registradores:
# (gdb) info registers       # todos os registradores
# (gdb) info registers eax   # registrador especifico
# (gdb) print $eax           # imprimir valor de EAX
# (gdb) print/x $eax         # em hexadecimal

# Inspecionar memoria:
# (gdb) x/4xw $esp           # 4 words (4 bytes) na pilha em hex
# (gdb) x/8xb 0x00401234    # 8 bytes no endereco

# Disassembly:
# (gdb) disassemble          # disassemble funcao atual
# (gdb) disassemble/r main   # com bytes raw do opcode
# (gdb) x/20i $eip           # 20 instrucoes a partir de EIP

# Stack frame:
# (gdb) backtrace            # call stack
# (gdb) frame 0              # frame atual
# (gdb) info frame           # detalhe do frame atual
# (gdb) info locals          # variaveis locais (requer debug info)

# Watchpoints (parar quando memoria muda):
# (gdb) watch *0x00601234   # parar quando valor no endereco muda

# Sair:
# (gdb) quit

# --- EXEMPLO DE SESSAO ---
# gdb ./TestPrograma
# (gdb) break MinhaFuncaoAsm
# (gdb) run
# (gdb) stepi               # executar instrucao a instrucao no asm
# (gdb) info registers      # verificar EAX, ESP etc.
# (gdb) x/4xw $esp          # inspecionar 4 words na pilha
# (gdb) continue            # continuar ate proximo breakpoint
echo "Script GDB de referencia — nao executar diretamente"
echo "Use os comandos acima dentro do GDB interativo"

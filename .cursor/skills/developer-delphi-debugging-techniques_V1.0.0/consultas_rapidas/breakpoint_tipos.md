# Tipos de Breakpoint no Delphi

**Skill:** `developer-delphi-debugging-techniques_V1.0.0`
**Data:** 2026-04-11

---

## Visão geral dos tipos

| Tipo | Onde disparar | Como criar |
|------|--------------|------------|
| **Source Breakpoint** | Em uma linha de código Pascal específica | Clicar na margem ou F9 |
| **Address Breakpoint** | Em um endereço de memória (instrução asm) | CPU View → clicar na instrução |
| **Data Breakpoint (Watchpoint)** | Quando uma variável/endereço de memória é escrito ou lido | View → Breakpoints → Add → Data |
| **Module Load Breakpoint** | Quando uma DLL/BPL é carregada | View → Breakpoints → Add → Module Load |

---

## Source Breakpoint

O tipo mais comum. Para na linha especificada do código fonte.

**Fluxo:**
1. Clicar na margem esquerda da linha → círculo vermelho aparece.
2. F9 alterna entre ativo e inativo.
3. Ctrl+Alt+B para gerenciar todos.

**Quando usar:** investigar lógica de negócio, loops, condições.

---

## Address Breakpoint

Para em uma instrução de linguagem de máquina específica, independente do código fonte.

**Quando usar:**
- Código otimizado onde o debugger perde sincronismo com as linhas.
- Investigar comportamento de bibliotecas sem código fonte.
- Depuração de rotinas assembly inline.

**Como criar na CPU View:**
1. Abrir CPU View: Ctrl+Alt+C
2. Navegar até o endereço desejado no painel Disassembly.
3. Clicar na margem esquerda do painel → breakpoint de endereço.

---

## Data Breakpoint (Watchpoint)

Para a execução quando um endereço de memória específico é **modificado** (ou lido, dependendo da configuração).

**Quando usar:**
- Descobrir qual código está corrompendo um campo de objeto.
- Rastrear modificação inesperada de variável global.
- Detectar write-after-free (escrita em memória liberada).

**Como criar:**
1. View → Debug Windows → Breakpoints → botão "+" → "Add Address Breakpoint"
2. Digitar endereço: `@MeuObjeto.FCampo`
3. Selecionar: Write, Read or Write.

**Limitação:** hardware data breakpoints são limitados a 4 pontos simultâneos (registradores DR0-DR3 do x86).

---

## Module Load Breakpoint

Para quando uma DLL ou BPL específica é carregada no processo.

**Quando usar:**
- Depurar plugins carregados dinamicamente.
- Verificar qual código está carregando uma DLL suspeita.
- Parar no momento exato em que um módulo é inicializado.

**Como criar:**
1. Ctrl+Alt+B → Add → Module Load
2. Digitar nome do módulo: `MinhaPlugin.dll`

---

## Breakpoint Groups — usar para organizar

**Cenário típico:**
- Grupo "InicializacaoDB": ativo durante testes de conexão.
- Grupo "ProcessamentoCliente": ativo durante testes de negócio.
- Desativar grupo inativo para não parar em código não relacionado.

**Como usar grupos:**
1. Ctrl+Alt+B → selecionar breakpoint → Properties.
2. Campo "Group": digitar nome do grupo.
3. Na lista: usar botão "Enable/Disable Group" para alternar.
4. Um breakpoint pode acionar Enable/Disable de outro grupo quando atingido.

---

## Comparação rápida

| Necessidade | Tipo recomendado |
|-------------|-----------------|
| "Parar quando a linha X for atingida" | Source Breakpoint |
| "Parar quando a variável Y for alterada" | Data Breakpoint |
| "Parar quando a instrução asm Z for executada" | Address Breakpoint |
| "Parar quando a DLL W for carregada" | Module Load Breakpoint |
| "Parar apenas quando condição for verdadeira" | Source + Condition |
| "Parar apenas na Nth execução" | Source + Pass Count |

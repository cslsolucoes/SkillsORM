---
name: developer-delphi-assembly-inline
description: Assembly inline em Delphi — blocos asm..end dentro de procedures/functions Pascal, acesso a variaveis locais e campos de objeto, labels locais @nome, modificadores OFFSET/PTR, restricoes de plataforma e diretiva NOSTACKFRAME.
model: sonnet
thinking: extended
category: developer-delphi-assembly
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-assembly-inline_V1.0.0

## Versao interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |

## Responsabilidade unica

Esta skill cobre os blocos `asm..end` embutidos dentro de funcoes e procedures Delphi — o "built-in assembler". Documenta a sintaxe especifica do Delphi (labels com `@`, comentarios `{ }` e `//`, modificadores `OFFSET`/`PTR`/`@Result`), como acessar variaveis locais e campos de objeto, restricoes de plataforma (Win32/Win64 apenas — iOS/Android usam LLVM sem suporte asm) e a diretiva `NOSTACKFRAME`. NAO cobre funcoes puramente assembly (`assembler;`) — essas pertencem a `developer-delphi-assembly-functions`.

## When to use

- Otimizar secoes criticas de performance dentro de uma funcao Pascal existente.
- Acessar instrucoes de CPU nao expostas pelo Pascal (CPUID, RDTSC, BSWAP).
- Implementar operacoes atomicas ou de bit manipulation de alta performance.
- Misturar logica Pascal de alto nivel com nucleo assembly otimizado.

## When NOT to use

- Funcoes inteiramente em assembly ’ usar `developer-delphi-assembly-functions` com keyword `assembler`.
- Codigo portavel iOS/Android ’ LLVM nao suporta `asm..end`.
- Combinacao `inline` + `asm` ’ E2426, nao suportado.
- Variaveis gerenciadas (string, interface, array dinamico) dentro do bloco asm ’ evitar acesso direto.

## Regras criticas do built-in assembler Delphi

1. **Comentarios validos:** `{ }` e `//` apenas. NAO usar `(* *)` dentro de blocos asm.
2. **Labels locais:** usar `@NomeLabel:` (com `@`) para evitar conflito com labels Pascal.
3. **`inline` + `asm` = ERRO E2426:** nunca combinar as duas diretivas.
4. **Plataformas:** Win32 e Win64 apenas. iOS e Android = compilador LLVM = sem suporte a `asm..end`.
5. **`@Result`:** referencia ao valor de retorno dentro do bloco asm (invalido fora de funcao com retorno).
6. **`OFFSET`:** endereco absoluto de variavel global em tempo de compilacao.
7. **`PTR`:** especificador de tamanho — `DWORD PTR [EAX]`, `BYTE PTR [EDI]`, `WORD PTR [ESI]`.

## Acesso a variaveis e campos

### Variaveis locais (Win32):
```pascal
var
  X: Integer;
asm
  MOV EAX, [EBP-4]   // primeira variavel local (depende do compilador)
  // OU — mais seguro: usar nome diretamente
  MOV EAX, X         // Delphi resolve o endereco automaticamente
end;
```

### Parametros em convencao `register` (Win32):
```
Funcao livre: A=EAX, B=EDX, C=ECX
Metodo:       Self=EAX, A=EDX, B=ECX
```

### Campos de objeto:
```pascal
// Self em EAX (convencao register/metodo):
MOV ECX, [EAX].TMinhaClasse.MeuCampo
// OU usando deslocamento:
MOV ECX, [EAX + offset_do_campo]
```

## Diretiva NOSTACKFRAME

```pascal
procedure RotinaSemFrame; assembler; nostackframe;
asm
  // Sem PUSH EBP / MOV EBP, ESP
  // Ideal para: funcoes leaf muito curtas, hotpaths
  // PERIGO: variaveis locais nao funcionam sem frame!
  MOV EAX, 42
end;
```

## Inputs

- Funcao Pascal existente com secao a otimizar.
- Especificacao do que deve ser calculado no bloco asm.
- Plataforma alvo (Win32/Win64).

## Workflow executavel

1. Identificar plataforma e convencao da funcao hospedeira.
2. Mapear parametros para registradores (register: EAX/EDX/ECX).
3. Escrever o bloco `asm..end` com labels `@nome`.
4. Verificar que registradores callee-saved sao preservados.
5. Usar `@Result` ou deixar resultado em EAX/XMM0.
6. Compilar com dcc32 e dcc64; checar warnings E2089 etc.

## Anti-padroes

| Anti-padrao                              | Por que e errado                                     | Como corrigir                                 |
| ---------------------------------------- | ---------------------------------------------------- | --------------------------------------------- |
| `{$IFDEF IOS}` com bloco `asm`           | LLVM nao compila asm inline — erro fatal             | Remover asm ou usar {$IFDEF WIN32}/{$IFDEF WIN64} |
| `inline` + `asm` na mesma funcao         | E2426 — incompativel pelo compilador                 | Remover `inline;` da declaracao              |
| Acessar string/interface dentro do asm   | Tipos gerenciados tem ARC/ref counting — corrompe    | Usar apenas tipos primitivos (Integer, Pointer) |
| Label com mesmo nome de variavel Pascal  | Conflito de nome — comportamento indefinido           | Prefixar labels com `@` sempre               |
| Modificar EBX/ESI/EDI sem PUSH/POP       | Corrompe estado do caller                             | PUSH antes de usar; POP antes de sair        |

## Dependencias (skills previas)

| Skill                                           | Quando usar antes                               |
| ----------------------------------------------- | ----------------------------------------------- |
| `developer-delphi-assembly-calling-conventions` | Para entender qual registrador contem cada param |

## Referencias

- Consulta rapida: `consultas_rapidas/sintaxe_asm_end.md`
- Consulta rapida: `consultas_rapidas/restricoes_plataforma.md`
- Exemplos: `exemplos/pas/inline_basico.pas`, `inline_campos_objeto.pas`
- Templates: `templates/TEMPLATE_inline_resultado.pas`, `TEMPLATE_inline_loop.pas`
- Skill orquestradora: `developer-delphi-assembly-orchestrator_V1.1.0`

---

## Changelog (este arquivo)

- 1.0.0 (11/04/2026): Criacao inicial — sintaxe built-in assembler, regras criticas, acesso a variaveis, NOSTACKFRAME, exemplos e anti-padroes.

---
name: audit-L02-assembly
description: Relatório de auditoria do lote L02 — developer-delphi-assembly-* (11 skills) do plano pack-audit-context-isolated-waves v5.0.
plan: D:\Users\claiton.linhares\.claude\plans\quero-que-olhe-arquivo-bright-bear.md
previous: L01-architecture.md
version: 1.0
date: 2026-04-24
scope: 11 skills em .cursor/skills/developer-delphi-assembly-*
---

# Relatório Auditoria — Lote L02 assembly

**Data:** 24/04/2026
**Escopo:** 11 arquivos na família:

1. `developer-delphi-assembly-orchestrator_V1.1.0`
2. `developer-delphi-assembly-x86-fundamentals_V1.0.0`
3. `developer-delphi-assembly-registers_V1.0.0`
4. `developer-delphi-assembly-instructions_V1.0.0`
5. `developer-delphi-assembly-stack-call_V1.0.0`
6. `developer-delphi-assembly-calling-conventions_V1.0.0`
7. `developer-delphi-assembly-delphi-inline_V1.0.0`
8. `developer-delphi-assembly-delphi-functions_V1.0.0`
9. `developer-delphi-assembly-simd-avx_V1.0.0`
10. `developer-delphi-assembly-expressions_V1.0.0`
11. `developer-delphi-assembly-debugging_V1.0.0`

**Contexto budget consumido:** ~42KB

## Tabela-sumário

| # | Arquivo | Q1 | Q2 | Q3 | Q4 | Q5 | Q6 | Q7 | N1 | N2 | N3 | N4 | N5 | Placement atual | Placement correto | Nome proposto | Prioridade |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | assembly-orchestrator_V1.1.0 | ✅ | ⚠ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ⚠ | ❌ | ✅ | ✅ | .cursor | .cursor | developer-delphi-assembly-master-orchestrator | média |
| 2 | assembly-x86-fundamentals_V1.0.0 | ✅ | ⚠ | ⚠ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor | .cursor | manter | baixa |
| 3 | assembly-registers_V1.0.0 | ✅ | ⚠ | ⚠ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor | .cursor | manter | baixa |
| 4 | assembly-instructions_V1.0.0 | ✅ | ⚠ | ⚠ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor | .cursor | manter | baixa |
| 5 | assembly-stack-call_V1.0.0 | ✅ | ⚠ | ⚠ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor | .cursor | manter | baixa |
| 6 | assembly-calling-conventions_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor | .cursor | manter | zero |
| 7 | assembly-delphi-inline_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ❌ | ✅ | ✅ | .cursor | .cursor | developer-delphi-assembly-inline-blocks | baixa |
| 8 | assembly-delphi-functions_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ❌ | ✅ | ✅ | .cursor | .cursor | developer-delphi-assembly-pure-functions | baixa |
| 9 | assembly-simd-avx_V1.0.0 | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor | .cursor | manter | **alta** |
| 10 | assembly-expressions_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor | .cursor | manter | zero |
| 11 | assembly-debugging_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor | .cursor | manter | zero |

**Observação Q1:** `simd-avx` tem Q7 crítico dentro das próprias diretivas `{$IFDEF WIN32}`/`{$IFDEF WIN64}` — anti-padrão condicional.

## Detalhe por arquivo

### Arquivo 1/11: `developer-delphi-assembly-orchestrator_V1.1.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-assembly-orchestrator_V1.1.0\SKILL.md`
**FileVersion:** 1.1.0 (linha 15)
**Tamanho:** 175 linhas
**Model:** sonnet
**Category:** developer-delphi-assembly
**Thinking:** extended

**Frontmatter integral:**

```yaml
---
name: developer-delphi-assembly-orchestrator
description: Orquestradora da Familia Assembly Delphi (J1-J10) — mapa de 10 micro-skills, quando usar asm inline vs. externo, checklist de seguranca, fluxo de aprendizado e criterios para justificar uso de assembly.
model: sonnet
thinking: extended
category: developer-delphi-assembly
---
```

**Responsabilidade declarada** (linha 19):

> "Esta skill e o ponto de entrada da Familia Assembly Delphi. Ela mapeia as 10 micro-skills da familia, orienta sobre quando usar assembly (vs. Pascal puro ou intrinsics), apresenta o checklist de seguranca antes de introduzir asm em producao e define a trilha de aprendizado recomendada. NAO implementa codigo — delega as skills especializadas."

**Achados de qualidade (Q):**

- **Q1:** Não. Sem código de exemplo gerado pela própria skill.
- **Q2:** ⚠ — Linhas 43-46: tabela de 10 micro-skills lista **4 como "futuro"** (x86-fundamentals, assembly-registers, assembly-instructions, assembly-stack-call) — mas essas 4 **JÁ EXISTEM** no pack (confirmado pelo `ls` e pelas leituras dos arquivos 2-5 deste lote). Documentação desatualizada.
- **Q3:** Não — conteúdo específico de orquestrador.
- **Q4:** Não — não tem exemplo mínimo compilável (adequado para orchestrator).
- **Q5:** ⚠ — texto sem acentuação consistente ("Propria" sem acento, "seguranca" sem til, "convencao" sem til) — mas isso é **convenção pt-BR sem diacríticos** aplicada sistematicamente. Consistente internamente → não é achado grave, só leve.
- **Q6:** Não — checklist de segurança (linhas 78-93) é detalhado.
- **Q7:** Não.

**Achados de nomenclatura (N):**

- **N1:** ✅ — prefixo revela família assembly.
- **N2:** ⚠ — Assembly é cross-compile Delphi+FPC em certa medida (pseudo-ops Delphi-only como `.PARAMS` são Delphi-específicos; mas NASM externo funciona em ambos). Baixa urgência de rename `to-fpc-*`.
- **N3:** ❌ — `orchestrator` sozinho (conforme L01 detectado para `developer-delphi-orchestrator`). Esta é a **orquestradora da família Assembly**; nome deveria revelar que orquestra assembly. **Proposta:** `developer-delphi-assembly-master-orchestrator`. Distingue da `developer-delphi-orchestrator` (master do kit inteiro) e deixa explícito ser o hub da família J.
- **N4:** ✅ — única skill que orquestra assembly.
- **N5:** ✅.

**Placement:** `.cursor/` correto.

**Exemplos/templates internos:** `consultas_rapidas/mapa_skills.md`, `quando_usar_asm.md`, `nasm_vs_delphi_asm.md` (conforme linhas 163-165).

**Correção proposta:**

```diff
@@ linhas 33-46 (tabela de 10 micro-skills — atualizar do estado "futuro")
 | # | Skill                                             | Responsabilidade                                   |
 | - | ------------------------------------------------- | -------------------------------------------------- |
 | J1| `developer-delphi-assembly-calling-conventions`   | Convencoes de chamada: register, stdcall, cdecl, Win64 ABI |
 | J2| `developer-delphi-assembly-delphi-inline`         | Blocos `asm..end` dentro de funcoes Pascal         |
 | J3| `developer-delphi-assembly-delphi-functions`      | Funcoes puras `assembler`, pseudo-ops x64, .obj NASM |
 | J4| `developer-delphi-assembly-simd-avx`              | SSE/AVX2/AVX-512, XMM/YMM/ZMM, masking            |
 | J5| `developer-delphi-assembly-expressions`           | OFFSET, TYPE, SIZE, VMTOFFSET, DMTINDEX, LEA       |
 | J6| `developer-delphi-assembly-debugging`             | CPU View, INT 3, RDTSC, x64dbg, erros frequentes  |
-| *(futuro)* | x86-fundamentals                         | Arquitetura x86/x64: registradores, flags, pilha  |
-| *(futuro)* | assembly-registers                        | Uso detalhado de registradores Delphi             |
-| *(futuro)* | assembly-instructions                     | Conjunto de instrucoes x86/x64 por categoria      |
-| *(futuro)* | assembly-stack-call                       | Pilha, frames, CALL/RET, shadow space             |
+| J7| `developer-delphi-assembly-x86-fundamentals`      | Arquitetura x86/x64: modos, memória, ABI x64       |
+| J8| `developer-delphi-assembly-registers`             | Registradores GPR/segmento/RFLAGS/XMM/YMM/ZMM      |
+| J9| `developer-delphi-assembly-instructions`          | Conjunto de instruções x86/x64 por categoria       |
+| J10| `developer-delphi-assembly-stack-call`           | Pilha, frames, CALL/RET, shadow space Windows x64  |
```

**Comentário:** descrição do frontmatter menciona "J1-J10" mas tabela interna lista J1-J6 + 4 "futuros" — skills J7-J10 já existem. Atualização mantém a convenção J# e remove o estado inconsistente.

**Nome proposto:** `developer-delphi-assembly-master-orchestrator` (N3 — explicita que é master da família, não apenas "um orchestrator").

**Dependências cruzadas afetadas por rename:**

- `developer-delphi-orchestrator_V1.1.0/SKILL.md:126, 165` (tabela família J e matriz)
- Todas as 10 skills irmãs assembly-* referenciam como "Skill orquestradora" (linhas equivalentes em cada SKILL.md — confirmado nas leituras: arquivo 6:126, arquivo 7:121, arquivo 8:164, arquivo 9:207, arquivo 10:179, arquivo 11:138).

---

### Arquivo 2/11: `developer-delphi-assembly-x86-fundamentals_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-assembly-x86-fundamentals_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (header linha 9, não há tabela "Versão interna")
**Tamanho:** 321 linhas
**Model:** sonnet
**Category:** developer · delphi · assembly

**Frontmatter integral:**

```yaml
---
name: developer-delphi-assembly-x86-fundamentals
description: Fundamentos x86/x64 para Delphi — modos de endereçamento, segmentos de memória, modo real vs protegido.
model: sonnet
---
```

**Responsabilidade declarada** (linha 14):

> "Referência completa de fundamentos da arquitetura x86/x64 para uso com o built-in assembler do Delphi (blocos `asm..end`) e com NASM (arquivos `.asm` externos). Cobre modos de operação da CPU, modelo de memória, tamanhos de operandos, notação Intel vs AT&T, ABI x64 Windows e as instruções especiais RDTSC e CPUID."

**Achados de qualidade (Q):**

- **Q1:** Não.
- **Q2:** ⚠ — Linha 283 tem erro de sintaxe Pascal. Conforme copiado do código:

  ```pascal
    POP  EBX
  end;
    HasSSE  := (FlagsEDX and (1 shl 25)) <> 0;
    HasSSE2 := (FlagsEDX and (1 shl 26)) <> 0;
    HasAVX  := (FlagsECX and (1 shl 28)) <> 0;
  end;
  ```

  Tem `end;` duplicado na linha 279 e 283 e o bloco `HasSSE := ...` está **fora** de qualquer `begin..end`. Pascal inválido. Isto não é referência quebrada mas é código falho no exemplo — caberia em Q7 (anti-padrão ativo: ensina código que não compila). **Re-classifico:** Q7 ⚠.

- **Q3:** ⚠ — o formato "Propósito / Conteúdo técnico / Estrutura de arquivos / Skills relacionadas" é template repetido nas skills x86-fundamentals, registers, instructions, stack-call (confirmado nas leituras). Padrão diferente do "template V2" das skills governance/documentation. **Não grave** — consistente entre as 4 skills base.
- **Q4:** Não.
- **Q5:** Não. Consistente pt-BR com acentuação.
- **Q6:** Não.
- **Q7:** ⚠ — código Pascal inválido no exemplo CPUID linhas 269-284 (`end;` mal-posicionado; bloco fora de begin..end). Correção abaixo.

**Achados de nomenclatura (N):**

- **N1:** ✅.
- **N2:** ✅ — x86-fundamentals mencionam explicitamente `dcc32`/`dcc64` (linhas 34-35) e NASM externo. Cross-compile implícito. Rename `to-fpc-*` provavelmente **não** agrega porque x86 fundamentals é universal (não específico Delphi+FPC). **Manter.**
- **N3:** ✅ — `x86-fundamentals` preciso.
- **N4:** ✅ — distinto de `registers` (que detalha registradores), `instructions` (opcodes) e `stack-call` (frames).
- **N5:** ✅.

**Placement:** `.cursor/` correto.

**Exemplos/templates internos:** estrutura listada em linhas 290-314: `exemplos/asm/*.asm` + `exemplos/pas/*.pas` + `consultas_rapidas/*.md` + `templates/*.pas`. Não lidos nesta onda.

**Correção proposta:**

```diff
@@ linhas 269-284 (corrigir exemplo CPUID com código Pascal inválido)
 procedure GetCPUFeatures(out HasSSE, HasSSE2, HasAVX: Boolean);
 var
   FlagsECX, FlagsEDX: Cardinal;
-asm
+begin
+  asm
   PUSH EBX           // EBX é callee-saved em 32-bit!
   MOV  EAX, 1
   CPUID
   MOV  FlagsECX, ECX
   MOV  FlagsEDX, EDX
   POP  EBX
-end;
+  end;
   HasSSE  := (FlagsEDX and (1 shl 25)) <> 0;
   HasSSE2 := (FlagsEDX and (1 shl 26)) <> 0;
   HasAVX  := (FlagsECX and (1 shl 28)) <> 0;
 end;
```

**Comentário:** exemplo como estava não compila — o `asm` no topo sem `begin` torna a função "assembler-only" mas depois do `end;` do asm tenta executar `HasSSE := ...` Pascal, o que é erro de sintaxe. A correção adiciona `begin` antes do `asm` e envolve o bloco asm em `asm..end` inline.

**Nome proposto:** manter.

**Dependências cruzadas:** referência à orchestrator (ver arquivo 1) + linha 318-320: Skills relacionadas `assembly-registers`, `assembly-instructions`, `assembly-stack-call`.

---

### Arquivo 3/11: `developer-delphi-assembly-registers_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-assembly-registers_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (header)
**Tamanho:** 266 linhas
**Model:** sonnet
**Category:** developer · delphi · assembly

**Frontmatter integral:**

```yaml
---
name: developer-delphi-assembly-registers
description: Registradores x86/x64 no contexto do assembler Delphi e NASM — GPRs, segmento, flags, SSE/AVX.
model: sonnet
---
```

**Responsabilidade declarada** (linha 14):

> "Referência completa dos registradores x86/x86-64: subdivisões de tamanho, registradores de segmento, RFLAGS bit a bit, RIP, registradores SIMD (XMM/YMM/ZMM) e convenções de preservação (caller-saved vs callee-saved) para Windows x64 ABI. Inclui exemplos concretos de uso no built-in assembler Delphi."

**Achados de qualidade (Q):**

- **Q1:** Não.
- **Q2:** ⚠ — Nenhuma ref quebrada explícita. Linha 263-265 (Skills relacionadas) referencia as 3 irmãs — todas existem. Ok.
- **Q3:** ⚠ — mesmo template base que `x86-fundamentals` (seções Propósito / Conteúdo / Estrutura / Skills). Consistente com grupo, não com pack V2.
- **Q4:** Não — exemplos concretos e úteis (zero-extension, layout RAX, função SomaDois 32-bit e 64-bit).
- **Q5:** Não.
- **Q6:** Não.
- **Q7:** Não — código compila corretamente.

**Achados de nomenclatura (N):**

- **N1:** ✅.
- **N2:** ✅ — abrange Delphi + NASM.
- **N3:** ✅.
- **N4:** ✅.
- **N5:** ✅.

**Placement:** `.cursor/` correto.

**Exemplos/templates internos:** estrutura em linhas 238-259 — `exemplos/asm/registradores_subdivisoes.asm`, `lea_calculos.asm`; `exemplos/pas/parametros_register.pas`, `parametros_x64.pas`, `preservar_obrigatorios.pas`, `self_access.pas`; consultas_rapidas + templates.

**Correção proposta:** nenhuma correção cirúrgica necessária. Sugestão secundária: adicionar tabela "Versão interna (ficheiro)" com FileVersion (padrão do pack) — linhas 11-12 usam formato heading `**Versão:** 1.0.0` em vez da tabela.

**Nome proposto:** manter.

**Dependências cruzadas:** Skills relacionadas linhas 263-265.

---

### Arquivo 4/11: `developer-delphi-assembly-instructions_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-assembly-instructions_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (header)
**Tamanho:** 359 linhas
**Model:** sonnet
**Category:** developer · delphi · assembly

**Frontmatter integral:**

```yaml
---
name: developer-delphi-assembly-instructions
description: Referência do conjunto de instruções x86/x64 para uso com o assembler Delphi e NASM.
model: sonnet
---
```

**Responsabilidade declarada** (linha 14):

> "Referência do conjunto de instruções x86/x64 para uso com o built-in assembler Delphi e NASM. Cobre transferência de dados, aritmética inteira, lógica e deslocamentos, comparação/saltos, operações de string com prefixo REP, instruções especiais e diferenças de sintaxe entre o assembler Delphi e NASM."

**Achados de qualidade (Q):**

- **Q1:** Não.
- **Q2:** ⚠ — Skills relacionadas (linhas 356-358) ok. Sem refs quebradas.
- **Q3:** ⚠ — template consistente com irmãs base.
- **Q4:** Não — exemplos úteis (MOVZX/MOVSX, MUL/IMUL, REP MOVSB) e tabela completa de Jcc.
- **Q5:** Não.
- **Q6:** Não.
- **Q7:** Não.

**Achados de nomenclatura (N):**

- **N1-N5:** todas ✅.

**Placement:** `.cursor/` correto.

**Exemplos/templates internos:** estrutura linhas 325-351.

**Correção proposta:** nenhuma crítica. Sugestão: adicionar tabela Versão interna padronizada.

**Nome proposto:** manter.

---

### Arquivo 5/11: `developer-delphi-assembly-stack-call_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-assembly-stack-call_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (header)
**Tamanho:** 391 linhas
**Model:** sonnet
**Category:** developer · delphi · assembly

**Frontmatter integral:**

```yaml
---
name: developer-delphi-assembly-stack-call
description: Stack e convenções de chamada x86/x64 no assembler Delphi — prologue, epilogue, register vs stack calling conventions.
model: sonnet
---
```

**Responsabilidade declarada** (linha 14):

> "Referência completa de stack frames, mecanismo CALL/RET, shadow space Windows x64, passagem de parâmetros e pseudo-ops do built-in assembler Delphi (.PARAMS, .PUSHNV, .SAVENV, .NOFRAME). Inclui exemplos de funções assembly chamadas do Delphi com 2 parâmetros."

**Achados de qualidade (Q):**

- **Q1:** Não.
- **Q2:** ⚠ — Skills relacionadas (linhas 388-390) ok.
- **Q3:** ⚠ — template consistente irmãs.
- **Q4:** Não.
- **Q5:** Não.
- **Q6:** Não. Cobre shadow space, alinhamento 16 bytes, pseudo-ops com profundidade adequada.
- **Q7:** Não.

**Achados de nomenclatura (N):**

- **N1-N5:** todas ✅.

**Placement:** `.cursor/` correto.

**Correção proposta:** nenhuma. Sugestão: adicionar tabela Versão interna.

**Nome proposto:** manter.

**Observação interessante:** esta skill **sobrepõe tematicamente** com `assembly-calling-conventions` (arquivo 6) em várias seções (parâmetros Win64 RCX/RDX/R8/R9, shadow space, preservação). Candidato a N4 sinônimo se conteúdo for 80%+ igual. Na leitura lado-a-lado:

- `stack-call`: foco em **mecanismo** (CALL/RET, PUSH/POP, shadow space layout, prologue/epilogue).
- `calling-conventions`: foco em **convenções** (register, stdcall, cdecl, safecall, pascal, winapi + tabela comparativa).

São complementares, não redundantes. **N4 ok.**

---

### Arquivo 6/11: `developer-delphi-assembly-calling-conventions_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-assembly-calling-conventions_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (tabela linhas 13-15)
**Tamanho:** 133 linhas
**Model:** sonnet
**Category:** developer-delphi-assembly
**Thinking:** extended

**Frontmatter integral:**

```yaml
---
name: developer-delphi-assembly-calling-conventions
description: Convencoes de chamada em Assembly para Delphi — register, stdcall, cdecl, safecall, pascal, winapi e Windows x64 ABI. Tabelas de registradores caller/callee-saved, passagem de parametros e retorno de valores.
model: sonnet
thinking: extended
category: developer-delphi-assembly
---
```

**Responsabilidade declarada** (linhas 18-19):

> "Esta skill documenta e exemplifica as convencoes de chamada (calling conventions) usadas em Delphi/Free Pascal para codigo assembly: como parametros sao passados (registradores vs. pilha), quem limpa a pilha (callee vs. caller), quais registradores devem ser preservados, e como o Windows x64 ABI difere do modelo Win32 classico. Ela NAO cobre instrucoes SIMD — essas pertencem a `developer-delphi-assembly-simd-avx`."

**Achados de qualidade (Q):**

- **Q1:** Não.
- **Q2:** Não.
- **Q3:** Não — conteúdo específico.
- **Q4:** Não.
- **Q5:** Não — pt-BR sem diacríticos consistente.
- **Q6:** Não.
- **Q7:** Não.

**Achados de nomenclatura (N):**

- **N1-N5:** todas ✅.

**Placement:** `.cursor/` correto.

**Correção proposta:** nenhuma. Skill bem-estruturada em padrão V2 (Responsabilidade única, When to use, When NOT to use, Tabela comparativa, Workflow, Dependencias, Anti-padroes, Metricas, Referencias, Changelog).

**Nome proposto:** manter.

**Observação:** esta é a skill **exemplar** da família — padrão V2 completo. Serve de referência para corrigir as outras skills assembly base (arquivos 2-5) que têm template mais antigo (sem "Responsabilidade única" explícita).

---

### Arquivo 7/11: `developer-delphi-assembly-delphi-inline_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-assembly-delphi-inline_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (tabela linhas 13-15)
**Tamanho:** 128 linhas
**Model:** sonnet
**Category:** developer-delphi-assembly
**Thinking:** extended

**Frontmatter integral:**

```yaml
---
name: developer-delphi-assembly-delphi-inline
description: Assembly inline em Delphi — blocos asm..end dentro de procedures/functions Pascal, acesso a variaveis locais e campos de objeto, labels locais @nome, modificadores OFFSET/PTR, restricoes de plataforma e diretiva NOSTACKFRAME.
model: sonnet
thinking: extended
category: developer-delphi-assembly
---
```

**Responsabilidade declarada** (linhas 18-19):

> "Esta skill cobre os blocos `asm..end` embutidos dentro de funcoes e procedures Delphi — o 'built-in assembler'. Documenta a sintaxe especifica do Delphi (labels com `@`, comentarios `{ }` e `//`, modificadores `OFFSET`/`PTR`/`@Result`), como acessar variaveis locais e campos de objeto, restricoes de plataforma (Win32/Win64 apenas — iOS/Android usam LLVM sem suporte asm) e a diretiva `NOSTACKFRAME`. NAO cobre funcoes puramente assembly (`assembler;`) — essas pertencem a `developer-delphi-assembly-delphi-functions`."

**Achados de qualidade (Q):**

- **Q1:** Não.
- **Q2:** Não.
- **Q3:** Não.
- **Q4:** Não.
- **Q5:** Não.
- **Q6:** Não.
- **Q7:** Não.

**Achados de nomenclatura (N):**

- **N1:** ✅.
- **N2:** ✅ — skill é Delphi-only (LLVM iOS/Android não suporta asm inline) — mas suporta dcc32+dcc64. Cobre também FPC? A descrição não menciona FPC. Asm inline existe em FPC (com `{$ASMMODE INTEL}`) mas conteúdo aqui é Delphi-específico. **Manter como Delphi-only.**
- **N3:** ❌ — `delphi-inline` é ambíguo. Qualquer coisa no Delphi pode ser "inline" (functions, methods, routines). O nome poderia ser `assembly-inline-blocks` ou `inline-asm-blocks`. Mas como está dentro da família assembly-*, contexto ajuda. **Baixa severidade.** Proposta N3: `developer-delphi-assembly-inline-blocks`.
- **N4:** ✅ — distinto de `delphi-functions` (funções puras vs blocos embutidos).
- **N5:** ✅.

**Placement:** `.cursor/` correto.

**Correção proposta:** nenhuma crítica. Sugestão N3 baixa prioridade.

**Nome proposto:** `developer-delphi-assembly-inline-blocks` (N3 baixa).

---

### Arquivo 8/11: `developer-delphi-assembly-delphi-functions_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-assembly-delphi-functions_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (tabela linhas 13-15)
**Tamanho:** 171 linhas
**Model:** sonnet
**Category:** developer-delphi-assembly
**Thinking:** extended

**Frontmatter integral:**

```yaml
---
name: developer-delphi-assembly-delphi-functions
description: Funcoes e procedures puramente assembly em Delphi — keyword `assembler`, pseudo-ops x64 (.PARAMS, .PUSHNV, .SAVENV, .NOFRAME), linkagem de .obj NASM, exportacao de simbolos e retorno de tipos Delphi.
model: sonnet
thinking: extended
category: developer-delphi-assembly
---
```

**Responsabilidade declarada** (linhas 18-19):

> "Esta skill documenta funcoes e procedures que sao INTEIRAMENTE escritas em assembly no Delphi — usando a keyword `assembler` (sem `begin/end` Pascal) ou linkando arquivos `.obj` gerados por NASM externo. ..."

**Achados de qualidade (Q):**

- **Q1:** Não.
- **Q2:** Não.
- **Q3:** Não.
- **Q4:** Não.
- **Q5:** Não.
- **Q6:** Não.
- **Q7:** Não.

**Achados de nomenclatura (N):**

- **N1:** ✅.
- **N2:** ✅ — Delphi `assembler` keyword é Delphi-specific; NASM externo é cross.
- **N3:** ❌ — mesmo problema do arquivo 7: `delphi-functions` é ambíguo. **Proposta:** `developer-delphi-assembly-pure-functions` (remove "delphi" duplicado no nome e torna "pure" explícito — função 100% assembly, sem Pascal).
- **N4:** ✅.
- **N5:** ✅.

**Placement:** `.cursor/` correto.

**Correção proposta:** nenhuma crítica.

**Nome proposto:** `developer-delphi-assembly-pure-functions` (N3 baixa — elimina "delphi" redundante + adiciona "pure" explícito).

---

### Arquivo 9/11: `developer-delphi-assembly-simd-avx_V1.0.0/SKILL.md` — **Q1+Q7 críticos**

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-assembly-simd-avx_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (tabela linhas 13-15)
**Tamanho:** 213 linhas
**Model:** sonnet
**Category:** developer-delphi-assembly
**Thinking:** extended

**Frontmatter integral:**

```yaml
---
name: developer-delphi-assembly-simd-avx
description: SIMD em Delphi — SSE2, SSE4.1, AVX (YMM 256-bit) e AVX-512 (ZMM 512-bit). Registradores XMM/YMM/ZMM, instrucoes vetorizadas, sintaxe angle brackets do Delphi para masking AVX-512, preservacao de XMM, CPUID check e alinhamento de dados.
model: sonnet
thinking: extended
category: developer-delphi-assembly
---
```

**Responsabilidade declarada** (linhas 18-19):

> "Esta skill cobre o uso de instrucoes SIMD (Single Instruction, Multiple Data) em Delphi — desde SSE2 (XMM 128-bit), SSE4.1, AVX/AVX2 (YMM 256-bit) ate AVX-512 (ZMM 512-bit) com opmask. ..."

**Achados de qualidade (Q):**

- **Q1 (auto-contradição):** ❌ **SIM.** Linhas 88-103 têm exemplo com `{$IFDEF WIN32}` e `{$IFDEF WIN64}`:

    ```pascal
    function SuportaSSE2: Boolean; assembler;
    asm
    {$IFDEF WIN32}
      PUSH EBX
      MOV  EAX, 1        // CPUID leaf 1: feature flags
      CPUID              // EDX bit 26 = SSE2
      BT   EDX, 26       // testar bit 26 de EDX
      SETC AL            // AL = 1 se SSE2 suportado
      POP  EBX
    {$ENDIF WIN32}
    {$IFDEF WIN64}
      PUSH RBX
      MOV  EAX, 1
      CPUID
      BT   EDX, 26
      SETC AL
      POP  RBX
    {$ENDIF WIN64}
    end;
    ```

    O pack tem uma **skill canônica** (`developer-delphi-programming-conditional-defines`) que proíbe `{$IFDEF}` e manda usar `{$IF DEFINED(...)}` com encadeamento explícito `{$ELSE} {$IF DEFINED()} ... {$ENDIF}` + fallback nomeado. Este exemplo usa `{$IFDEF}` + sufixo `WIN32`/`WIN64` após `{$ENDIF}` (que é opcional mas pouco usado no resto do pack). **Reproduz o anti-padrão**.

  - Declarada implicitamente via Checklist Delphi+FPC padrão do pack (a skill não tem esse checklist explícito, mas a regra vale transversalmente).
  - Exemplo violador: linhas 88-103 (acima).

- **Q2:** Não.
- **Q3:** Não.
- **Q4:** Não.
- **Q5:** Não.
- **Q6:** Não — cobre CPUID check, preservação, alinhamento, VZEROUPPER.
- **Q7 (anti-padrão ativo):** ❌ **SIM.** Mesmo exemplo acima. Quem copia este bloco para novo código **reproduz** `{$IFDEF WIN32}` em vez do padrão canônico.

**Achados de nomenclatura (N):**

- **N1-N5:** todas ✅.

**Placement:** `.cursor/` correto.

**Correção proposta:**

```diff
@@ linhas 86-117 (corrigir ambos SuportaSSE2 e SuportaAVX2)
 function SuportaSSE2: Boolean; assembler;
 asm
-{$IFDEF WIN32}
+{$IF DEFINED(WIN32)}
   PUSH EBX
   MOV  EAX, 1        // CPUID leaf 1: feature flags
   CPUID              // EDX bit 26 = SSE2
   BT   EDX, 26       // testar bit 26 de EDX
   SETC AL            // AL = 1 se SSE2 suportado
   POP  EBX
-{$ENDIF WIN32}
-{$IFDEF WIN64}
+{$ELSE} {$IF DEFINED(WIN64)}
   PUSH RBX
   MOV  EAX, 1
   CPUID
   BT   EDX, 26
   SETC AL
   POP  RBX
-{$ENDIF WIN64}
+{$ENDIF} {$ENDIF}
 end;

 function SuportaAVX2: Boolean; assembler;
 asm
-{$IFDEF WIN32}
+{$IF DEFINED(WIN32)}
   PUSH EBX
   MOV  EAX, 7        // CPUID leaf 7 = extended features
   XOR  ECX, ECX
   CPUID              // EBX bit 5 = AVX2
   BT   EBX, 5
   SETC AL
   POP  EBX
-{$ENDIF WIN32}
+{$ENDIF}
 end;
```

**Comentário:** a correção aplica a Regra 2 ({$IF DEFINED}) e a Regra 3 (encadeamento com {$ELSE}{$IF}...{$ENDIF}{$ENDIF}) da skill canônica. Também remove o sufixo pouco-usado `{$ENDIF WIN32}` (válido em Delphi, mas não em FPC clássico).

Adicional: seção "Anti-padrões" (linhas 193-199) já tem bullet sobre masking AVX-512 com `{k1}{z}` — adicionar bullet sobre `{$IFDEF}`:

```diff
@@ linha 199 (adicionar linha final à tabela Anti-padrões)
 | Usar MOVAPS com dados nao-alinhados   | General Protection Fault em runtime           | Usar MOVUPS ou garantir alinhamento      |
 | Esquecer VZEROUPPER apos AVX          | Penalidade de transicao AVX→SSE (50-100 ciclos)| Chamar VZEROUPPER antes de SSE          |
 | Modificar XMM6-XMM15 sem .SAVENV     | Corrompe estado do caller em Win64            | Adicionar .SAVENV XMMreg                 |
 | SIMD sem CPUID check                  | Crash em CPUs antigas (ex: pre-2011)          | Verificar em runtime com CPUID           |
+| `{$IFDEF WIN32}` em asm embutido      | Viola regra do projeto (usar `{$IF DEFINED}`) | Seguir `developer-delphi-programming-conditional-defines` |
```

**Nome proposto:** manter.

**Dependências cruzadas afetadas:** nenhuma por rename (não proposto). Após correção Q1/Q7, atualizar Changelog linha 213 com bump para V1.0.1.

---

### Arquivo 10/11: `developer-delphi-assembly-expressions_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-assembly-expressions_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (tabela linhas 13-15)
**Tamanho:** 185 linhas
**Model:** sonnet
**Category:** developer-delphi-assembly
**Thinking:** extended

**Frontmatter integral:**

```yaml
---
name: developer-delphi-assembly-expressions
description: Expressoes assembly Delphi em tempo de compilacao — OFFSET, TYPE, SIZE, VMTOFFSET, DMTINDEX, PTR, LEA com enderecamento indexado, otimizacoes com LEA (multiplicacao sem MUL), macros NASM (%macro, %rep) e operadores aritmeticos em expressoes asm.
model: sonnet
thinking: extended
category: developer-delphi-assembly
---
```

**Responsabilidade declarada** (linhas 18-19):

> "Esta skill cobre as expressoes calculadas em tempo de compilacao disponíveis no assembler Delphi — OFFSET, TYPE, SIZE, VMTOFFSET, DMTINDEX — e endereçamento indexado com LEA, otimizacoes com LEA, macros NASM. ..."

**Achados de qualidade (Q):**

- **Q1-Q7:** todos ✅ — sem achados.

**Achados de nomenclatura (N):**

- **N1-N5:** ✅.

**Placement:** `.cursor/` correto.

**Correção proposta:** nenhuma.

**Nome proposto:** manter.

---

### Arquivo 11/11: `developer-delphi-assembly-debugging_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-assembly-debugging_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (tabela linhas 13-15)
**Tamanho:** 144 linhas
**Model:** sonnet
**Category:** developer-delphi-assembly
**Thinking:** extended

**Frontmatter integral:**

```yaml
---
name: developer-delphi-assembly-debugging
description: Depuracao de assembly em Delphi — CPU View do IDE (disassembly, registradores, stack, FPU/SSE), INT 3 como breakpoint manual, RDTSC/RDTSCP para benchmarking de ciclos, OutputDebugString de dentro de asm, analise com x64dbg e estrategias de diagnostico.
model: sonnet
thinking: extended
category: developer-delphi-assembly
---
```

**Responsabilidade declarada** (linhas 18-19):

> "Esta skill cobre tecnicas especificas de depuracao de codigo assembly em Delphi: uso do CPU View do IDE, breakpoints condicionais via INT 3, medicao de performance com RDTSC, inspecao de registradores e pilha, e uso de ferramentas externas como x64dbg. NAO cobre debugging Pascal geral (FastMM4, EurekaLog) — essas pertencem a `developer-delphi-debugging-techniques`."

**Achados de qualidade (Q):**

- **Q1-Q7:** todos ✅ (linhas 74-81 usam `{$IFDEF DEBUG}` — mas este é um define **global do build** Delphi, não diretiva de engine — seu uso com `{$IFDEF}` é aceitável desde que não seja a skill ensinando o padrão. Verificando: o exemplo demonstra como proteger INT 3 em produção; o `{$IFDEF DEBUG}` é intencional e amplamente usado. Não classifico como Q7. Mas **consistência**: para ficar 100% alinhado à regra canônica, poderia ser `{$IF DEFINED(DEBUG)}`.)

- **Q1:** Não.
- **Q2:** Não.
- **Q3:** Não.
- **Q4:** Não.
- **Q5:** Não.
- **Q6:** Não.
- **Q7:** ⚠ muito leve — `{$IFDEF DEBUG}` em linhas 77-79 e 126 (anti-padrões table). Não é obrigatório corrigir (DEBUG é define de build global, não USE_* de engine), mas para consistência total com regra canônica do pack, poderia padronizar.

**Achados de nomenclatura (N):**

- **N1-N5:** ✅.

**Placement:** `.cursor/` correto.

**Correção proposta (opcional — baixa prioridade):**

```diff
@@ linhas 77-79 (exemplo INT 3 protegido)
 procedure MinhaRotina;
 asm
   // ... codigo ...
-  {$IFDEF DEBUG}
+  {$IF DEFINED(DEBUG)}
   INT 3           // somente em builds DEBUG
   {$ENDIF}
   // ... mais codigo ...
 end;
```

**Nome proposto:** manter.

---

## Ações acumuladas para execução

### E1-candidatas (CLAUDE.md refs quebradas)

Nenhuma neste lote.

### E4-candidatas (Q1/Q7 para fix imediato)

**Prioridade alta:**

1. `developer-delphi-assembly-simd-avx_V1.0.0/SKILL.md` (linhas 88-117) — corrigir 2 funções CPUID (SuportaSSE2, SuportaAVX2) substituindo `{$IFDEF WIN32}`/`{$IFDEF WIN64}` por `{$IF DEFINED(WIN32)}` + encadeamento `{$ELSE} {$IF DEFINED(WIN64)} ... {$ENDIF} {$ENDIF}`. Diff completo acima.
2. `developer-delphi-assembly-simd-avx_V1.0.0/SKILL.md` (linha 199 — tabela Anti-padrões) — adicionar bullet sobre `{$IFDEF}` apontando para skill canônica.

**Prioridade baixa (consistência com regra canônica):**

3. `developer-delphi-assembly-debugging_V1.0.0/SKILL.md` (linhas 77-79, 126) — `{$IFDEF DEBUG}` → `{$IF DEFINED(DEBUG)}` (baixa — DEBUG é global, aceitável).

**Prioridade média (bug Pascal real):**

4. `developer-delphi-assembly-x86-fundamentals_V1.0.0/SKILL.md` (linhas 269-284) — função `GetCPUFeatures` tem `end;` mal-posicionado + código Pascal fora de `begin..end`. Correção: adicionar `begin` + `asm..end` inline. Diff completo acima.

### E5-candidatas (renames propostos)

**Prioridade média:**

1. `developer-delphi-assembly-orchestrator` → `developer-delphi-assembly-master-orchestrator` (N3 — explicita "master da família", distingue de `developer-delphi-orchestrator`). 11 refs cruzadas (todas as 10 skills irmãs citam).

**Prioridade baixa:**

2. `developer-delphi-assembly-delphi-inline` → `developer-delphi-assembly-inline-blocks` (N3 — remove "delphi" redundante).
3. `developer-delphi-assembly-delphi-functions` → `developer-delphi-assembly-pure-functions` (N3 — remove "delphi" redundante + adiciona "pure" explícito).

**Sem rename:** registers, instructions, stack-call, calling-conventions, simd-avx, expressions, debugging, x86-fundamentals (8 skills).

**Observação importante sobre N2:** nenhuma das 11 skills assembly tem rename para `-to-fpc-*` proposto. Assembly é por natureza platform-specific (Delphi built-in assembler tem pseudo-ops diferentes do FPC `{$ASMMODE}`). As skills cobrem ambos mas o foco é Delphi. **Manter prefixo `developer-delphi-*` sem `-to-fpc-*`.**

### E6-candidatas (Q2/Q3/Q4/Q5/Q6 residuais)

1. **Q2 assembly-orchestrator:43-46** — tabela com 4 skills "futuro" que já existem; atualizar para J7-J10. Diff completo acima.
2. **Q3 nas 4 skills base** (x86-fundamentals, registers, instructions, stack-call) — padronizar template V2 completo (adicionar "Versão interna (ficheiro)" tabela + seções "Responsabilidade única" / "When to use" / "When NOT to use" / "Dependências" / "Anti-padrões" / "Métricas" / "Responsável") — conforme padrão da arquivo 6 (`calling-conventions`) que é o exemplar.

### Placement migrations

Nenhuma.

---

## Síntese do lote L02

- **11 skills auditadas** com detalhe completo.
- **1 skill CRÍTICA** (simd-avx) com Q1+Q7 — `{$IFDEF WIN32}`/`{$IFDEF WIN64}` nos exemplos CPUID.
- **1 skill com bug Pascal** (x86-fundamentals) — função GetCPUFeatures com `end;` mal-posicionado.
- **1 skill com Q2** (orchestrator) — tabela desatualizada com 4 skills "futuro" que já existem.
- **3 renames propostos** (orchestrator + 2 skills "delphi-" redundante).
- **Nenhuma proposta `-to-fpc-*`** para a família assembly (platform-specific por natureza).
- **1 skill exemplar** (calling-conventions) — padrão V2 completo; servir de referência para padronizar as 4 skills base (x86/registers/instructions/stack-call).

**Próxima onda sugerida:** L03 (build) — 3 skills (build-cross-compiler, build-toolchain, debugging-techniques).

**Commit sugerido:** `docs(audit): relatório lote L02 assembly — 11 skills, 1 crítica (simd-avx Q1/Q7), 3 renames propostos, bug em x86-fundamentals`

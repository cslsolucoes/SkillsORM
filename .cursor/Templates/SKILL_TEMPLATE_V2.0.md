# Template V2.0 — SKILL.md

> Use este template ao criar ou migrar skills para o padrão V2.
> Caminho da skill: `.cursor/skills/<nome-skill>_V{MAJOR.MINOR.PATCH}/SKILL.md`
> Sufixo da pasta = versão SemVer do SKILL.md (ex.: FileVersion 2.0.0 → pasta `_V2.0.0`).
>
> Seções marcadas com `← NOVO` não existem no template V1 e devem ser adicionadas.
> Remova este bloco de instruções ao criar a skill real.

---

```yaml
---
name: <nome-kebab-case>
description: <uma linha: o que esta skill faz e para quem>
model: <opus|sonnet|haiku>          # ver critérios em 00_indice.plan.md
thinking: <extended|normal|minimal> # extended = raciocínio complexo; minimal = scaffolding
category: <categoria-da-taxonomia>  # ver lista abaixo
---
```

**Categorias válidas:** `documentation` | `project` | `developer-delphi` | `developer-web` |
`governance-spec` | `governance-process` | `governance-people` | `governance-artifact` |
`quality` | `version`

---

# <Nome Legível da Skill>

## Responsabilidade única  ← NOVO

> Um parágrafo (3-5 frases). Descrever **qual problema** esta skill resolve e por que
> ela existe separada das demais. Não repetir o campo `description` do frontmatter.

## When to use

- Gatilho 1: situação objetiva que dispara esta skill
- Gatilho 2: ...
- Gatilho 3: ...

## When NOT to use  ← NOVO

- Situação A → usar `<outra-skill>` em vez desta
- Situação B → usar `<outra-skill>` em vez desta
- Situação C (fora do escopo desta skill)

## Inputs obrigatórios

| Input | Tipo | Descrição |
|-------|------|-----------|
| `<campo>` | `<tipo>` | Descrição e restrições |

## Dependências (skills prévias)  ← NOVO

| Skill | Quando executar antes |
|-------|-----------------------|
| `<nome-skill>` | Razão pela qual deve preceder |

*(Omitir tabela e escrever "Nenhuma dependência obrigatória" se não houver.)*

## Workflow executável

1. Passo 1 — descrição ativa (verbo no imperativo)
2. Passo 2 — ...
3. Passo 3 — ...

> Snippets de código inline ≤ 15 linhas. Blocos maiores → mover para `./exemplos/` e referenciar:
> `→ Ver [exemplo completo](./exemplos/nome.pas)`

## Outputs obrigatórios

| Output | Localização | Formato |
|--------|-------------|---------|
| `<artefato>` | `<path relativo>` | Markdown / Pascal / Vue / JSON |

## Checklist de validação

- [ ] Critério testável 1
- [ ] Critério testável 2
- [ ] Critério testável 3

---
<!-- BLOCO DELPHI/FPC — incluir APENAS em skills project-*, delphi-fpc-*, delphi-ios-* -->
<!-- Remover este bloco em skills de outras famílias -->

## Checklist Delphi+FPC  ← OBRIGATÓRIO (Delphi/FPC)

- [ ] Compilação sem hints/warnings em Delphi (dcc32 + dcc64)
- [ ] Compilação sem hints/warnings em FPC (fpc32 + fpc64)
- [ ] Memory management: Create/Free em try..finally; sem leaks (`ReportMemoryLeaksOnShutdown`)
- [ ] Tratamento de exceções: hierarquia do projeto (`EProviderError` ou equivalente)
- [ ] Nomenclatura: prefixos `T`/`I`/`E`/`F`/`A` conforme `documentation-project-expert`
- [ ] Diretivas `{$IFDEF}` conforme `developer-delphi-programming-conditional-defines`; sem mistura com paths
- [ ] Separação UI/lógica: zero SQL ou regras de negócio em event handlers

## Exemplo mínimo compilável  ← OBRIGATÓRIO (Delphi/FPC)

**Delphi (dcc32/dcc64):**

```pascal
// Snippet ≤ 15 linhas — bloco maior → ./exemplos/exemplo_basico.pas
program ExemploMinimo;
{$APPTYPE CONSOLE}
begin
  // demonstrar o uso correto desta skill
  WriteLn('OK');
end.
```

**Free Pascal (fpc):**

```pascal
program ExemploMinimoFPC;
begin
  // mesmo conceito, sintaxe FPC
  WriteLn('OK');
end.
```

→ Ver [exemplos completos](./exemplos/README.md)
<!-- FIM BLOCO DELPHI/FPC -->

---
<!-- BLOCO WEB/JS VUE.JS — incluir APENAS em skills JS-*, dev-agent-vuejs-*, dev-agent-web-* -->
<!-- Remover este bloco em skills de outras famílias -->

## Stack e versões  ← OBRIGATÓRIO (Web/JS)

| Componente | Versão mínima | Notas |
|------------|:---:|-------|
| Vue.JS | 3.x | Composition API com `<script setup>` obrigatório |
| Node.js | 18.x | LTS mínimo |
| Vite | 5.x | Build tool padrão |
| Pinia | 2.x | State management |
| Vue Router | 4.x | Roteamento |

## Dependências npm  ← OBRIGATÓRIO (Web/JS)

```bash
npm install <pacote>@<versão>
npm run dev      # desenvolvimento
npm run build    # produção
npm run test     # testes
```

**Conflitos conhecidos:** ...

## Checklist Web/Vue.JS  ← OBRIGATÓRIO (Web/JS)

- [ ] Componente SFC válido (`.vue` com `<template>`, `<script setup>`, `<style scoped>`)
- [ ] Sem dependência circular entre componentes
- [ ] Props tipadas (`defineProps<{}>()` com TypeScript ou validação explícita)
- [ ] Loading state, error boundary e empty state tratados
- [ ] Acessibilidade básica: `aria-label`, navegação por teclado, contraste WCAG AA

## Exemplo mínimo funcional  ← OBRIGATÓRIO (Web/JS)

```vue
<!-- Snippet ≤ 15 linhas — bloco maior → ./exemplos/exemplo_componente.vue -->
<script setup lang="ts">
// demonstrar uso correto desta skill
</script>

<template>
  <div><!-- conteúdo mínimo --></div>
</template>
```

→ Ver [exemplos completos](./exemplos/README.md)
<!-- FIM BLOCO WEB/JS -->

---

## Anti-padrões  ← NOVO

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Descrição do erro comum 1 | Consequência | Solução correta |
| Descrição do erro comum 2 | Consequência | Solução correta |

## Avaliação de risco

- **Parar e confirmar quando:** situação que exige confirmação humana antes de prosseguir
- **Risco alto:** cenário de alto impacto que o agent deve reportar
- **Risco baixo:** situação que pode ser resolvida autonomamente

## Métricas de sucesso  ← NOVO

- Indicador 1 mensurável (ex.: "zero hints/warnings na compilação")
- Indicador 2 mensurável (ex.: "checklist 100% marcado")

## Responsável principal  ← NOVO

| Papel | Quem |
|-------|------|
| Agent executor | `<dev-agent-* ou doc-agent-*>` |
| Revisão humana | Desenvolvedor / Tech Lead |
| Aprovação final | `<papel humano>` |

## Referências

- [Documentação oficial relevante](URL)
- Skill relacionada: `<nome-skill>`
- Para Delphi/FPC: `.cursor/skills/project-compile-database-docs_V1.0.1/exemplos/compile.md`
- Para Delphi/FPC: `.cursor/skills/project-diretivas-compilacao_V1.0.1/exemplos/diretivas_compilacao.md`

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 2.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 2.0.0 (DD/MM/AAAA): Migração V2 — adicionadas seções Categoria, Responsabilidade única,
  When NOT to use, Dependências, Anti-padrões, Métricas de sucesso, Responsável principal
  [+ Checklist Delphi+FPC + Exemplo compilável | + Stack/npm/Checklist Web + Exemplo .vue].
- X.Y.Z (DD/MM/AAAA): entrada anterior (preservar histórico).

---

<!-- INSTRUÇÕES DE USO DESTE TEMPLATE (remover ao criar skill real)

FAMÍLIA DA SKILL → BLOCOS A INCLUIR:
  project-*, delphi-fpc-*, delphi-ios-*  → Manter bloco DELPHI/FPC; remover bloco WEB/JS
  JS-*                                   → Manter bloco WEB/JS; remover bloco DELPHI/FPC
  Demais (documentação, governança, etc.) → Remover AMBOS os blocos de stack

POLÍTICA DE SUBPASTAS:
  SKILL.md     → máx ~200 linhas; snippets ≤ 15 linhas inline
  templates/   → templates .md/.html que esta skill gera (exclusivos desta skill)
  exemplos/    → exemplos compiláveis auto-contidos + README.md de índice

BUMP DE VERSÃO:
  Migração (nova seção = retrocompatível) → bump MINOR (ex.: 1.0.5 → 1.1.0 → renomear pasta)
  Skill nova                              → iniciar em 1.0.0
  Correção de bug em seção existente      → bump PATCH

-->

---
name: developer-vuejs-language-core
description: Fundamentos de JavaScript moderno para VueJS, incluindo decisão JS vs TypeScript, nomenclatura e práticas de código.
model: sonnet
thinking: extended
category: developer-web
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---
> **DEPRECATED** — Substituída por `developer-vuejs-language-core_V1.1.0` (E11, 2026-04-24). Não usar.


# developer-vuejs-language-core

## Responsabilidade única

Esta skill cobre os fundamentos de linguagem JavaScript/TypeScript aplicados ao ecossistema VueJS: padrões ES Modules, decisão JS vs TS, nomenclatura obrigatória, async/await e organização de código. Não abrange configuração de build, roteamento, gerenciamento de estado, testes ou deploy — cada um tem sua skill dedicada.

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## When to use
- Definição de padrões de linguagem para projeto VueJS.
- Revisão de sintaxe ES modules, async/await e organização de código.
- Decisão inicial sobre adotar JS puro ou TypeScript no projeto.
- Padronização de nomenclatura em toda a codebase.

## When NOT to use
- Não usar para configuração de Vite ou build → use `developer-web-build-tooling-quality`
- Não usar para criar componentes `.vue` SFC → use `developer-vuejs-components-reactivity`
- Não usar para roteamento ou stores Pinia → use `developer-vuejs-routing-state`
- Não usar para setup de testes unitários → use `developer-web-testing-debugging`
- Não usar para configuração de deploy ou CI/CD → use `developer-web-packaging-deployment`
- Não usar para estratégia multi-skill → use `developer-vuejs-master-orchestrator`

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|----------------------|
| `developer-vuejs-master-orchestrator` | Se a tarefa envolver múltiplas skills JS, acionar o orquestrador primeiro |
| `developer-web-build-tooling-quality` | Para validar que Node/npm/Vue/Vite estão na versão correta antes de aplicar padrões de linguagem |

## Inputs
- Escopo da aplicação/módulo.
- Decisão inicial JS puro ou TypeScript.

## Workflow executável
1. Confirmar baseline Node/npm/Vue/Vite.
2. Definir padrão JS vs TS para o módulo.
3. Aplicar nomenclatura obrigatória.
4. Validar exemplo executável com `npm run dev`.

## Decisão JS vs TypeScript
- JS (default): projetos pequenos/protótipos.
- TS: projetos médios/grandes, equipe maior, necessidade de refatoração segura.
- Impacto TS: `tsconfig.json`, `<script setup lang="ts">`, tipagem de props/retornos.

## Stack e versões

| Componente | Versão mínima | Notas |
|------------|--------------|-------|
| Vue.JS | 3.4.x | Composition API com `<script setup>` obrigatório |
| Node.js | 18.x | LTS mínimo; recomendado 20 LTS |
| Vite | 5.x | Build tool padrão para SPA |
| Pinia | 2.x | State management |
| Vue Router | 4.x | Roteamento declarativo |
| TypeScript | 5.x | Opcional; obrigatório em projetos médios/grandes |
| ESLint | 8.x | Lint de qualidade de código |

## Dependências npm

```bash
# Projeto base Vue + Vite (JS)
npm create vue@latest

# Adicionar TypeScript a projeto existente
npm install --save-dev typescript @vue/tsconfig

# ESLint para Vue
npm install --save-dev eslint eslint-plugin-vue @vue/eslint-config-typescript

# Prettier
npm install --save-dev prettier @vue/eslint-config-prettier
```

## Checklist Web/Vue.JS

- [ ] Componente SFC válido (.vue com template, script setup, style scoped)
- [ ] Sem dependência circular entre componentes
- [ ] Props tipadas (defineProps<{}>() com TypeScript ou validação explícita)
- [ ] Loading state, error boundary e empty state tratados
- [ ] Acessibilidade básica: aria-label, navegação por teclado, contraste WCAG AA
- [ ] Código em ESM (sem `require`, sem `CommonJS` em módulos Vue)
- [ ] Async com `try/catch` em todas as operações de IO
- [ ] Nomenclatura aplicada: `PascalCase` classes, `camelCase` funções, `UPPER_SNAKE_CASE` constantes

## Exemplo mínimo funcional

```vue
<script setup lang="ts">
import { ref, computed } from 'vue'

// Constante com UPPER_SNAKE_CASE
const API_TIMEOUT_MS = 20_000

// Props tipadas com TypeScript
interface Props {
  userName: string
  isLoading?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  isLoading: false
})

// Estado local
const formattedName = computed(() =>
  props.userName?.trim() ?? ''
)

// Função async com tratamento de erro
async function loadData(fetcher: () => Promise<unknown>) {
  try {
    return await fetcher()
  } catch (error) {
    console.error('[loadData] Falha ao carregar dados:', error)
    throw error
  }
}

// camelCase para variáveis e funções
const isVisible = ref(false)

function toggleVisibility() {
  isVisible.value = !isVisible.value
}
</script>

<template>
  <div class="user-info" role="region" aria-label="Informações do usuário">
    <p v-if="props.isLoading" aria-live="polite">Carregando...</p>
    <p v-else>{{ formattedName }}</p>
    <button
      type="button"
      aria-expanded="isVisible"
      @click="toggleVisibility"
    >
      {{ isVisible ? 'Ocultar' : 'Mostrar' }} detalhes
    </button>
  </div>
</template>

<style scoped>
.user-info {
  padding: 1rem;
}
</style>
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| `var` em vez de `const`/`let` | Escopo de função causa bugs difíceis de rastrear | Usar `const` por padrão; `let` apenas quando reassignment é necessário |
| `require()` em módulo Vue | Mistura CommonJS com ESM, quebra tree-shaking | Usar `import`/`export` ES Modules consistentemente |
| `async` sem `try/catch` | Erros assíncronos silenciosos corrompem estado da UI | Sempre envolver `await` em `try/catch` ou propagar com `.catch()` |
| Props sem tipagem | Runtime bugs por valores inesperados | Usar `defineProps<{}>()` com TypeScript ou `validator` explícito |
| `console.log` em produção | Vaza informação e polui console | Usar variável de ambiente `import.meta.env.DEV` para guardar logs de debug |

## Métricas de sucesso

- `npm run build` conclui sem warnings de tipo ou lint
- Zero ocorrências de `var`, `require()` ou `eval` na codebase
- 100% das funções assíncronas com tratamento de erro explícito
- Nomenclatura consistente validada por ESLint rules

## Responsável principal

| Papel | Quem |
|-------|------|
| Definição de padrões de linguagem | Tech Lead / Arquiteto Frontend |
| Revisão de código e nomenclatura | Code Reviewer |
| Execução e aplicação | Desenvolvedor Frontend |

## Avaliação de risco e confirmação
- Se mudança de JS para TS afetar vários módulos e build, confirmar com usuário antes.

## Referências canônicas
- https://vuejs.org/guide/quick-start.html
- https://devdocs.io/javascript/
- https://nodejs.org/docs/latest/api/

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `JS-VueJS-language-core`; novo prefixo canônico `developer-vuejs`. Conteúdo idêntico ao V1.1.0 de origem; cross-references atualizadas para prefixo `developer-*`.
---
name: developer-vuejs-components-reactivity
description: Arquitetura de componentes VueJS com Composition API + script setup, composables e nota de escalabilidade SSR/SSG.
model: sonnet
thinking: extended
category: developer-web
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---
> **DEPRECATED** — Substituída por `developer-vuejs-components-reactivity_V1.1.0` (E11, 2026-04-24). Não usar.


# developer-vuejs-components-reactivity

## Responsabilidade única

Esta skill governa a estruturação de componentes Vue.JS usando exclusivamente Composition API com `<script setup>`, definindo boundaries claros entre views, componentes de UI e composables. Ela garante que lógica reutilizável seja extraída corretamente para composables e que o acoplamento entre componentes permaneça mínimo. Cobre também a decisão estratégica entre SPA (Vite) e SSR/SSG (Nuxt) conforme critérios de SEO e performance de first paint. Não aborda configuração de roteamento, estado global ou build — essas responsabilidades pertencem a skills dedicadas.

## Versão interna (ficheiro)

| Campo | Valor |
|-----------------|-------|
| **FileVersion** | 1.0.0 |

## When to use

- Estruturar componentes, composables e boundaries de UI.
- Definir hierarquia de componentes em features novas.
- Refatorar Options API para Composition API.
- Avaliar necessidade de Nuxt vs SPA puro.

## When NOT to use

- Configuração de rotas ou guards de navegação → usar `developer-vuejs-routing-state`.
- Setup de build, Vite config ou variáveis de ambiente → usar `developer-web-build-tooling-quality`.
- Configuração de testes unitários ou de integração → usar `JS-testing-and-debugging-web`.
- Deploy, Docker ou CI/CD → usar `developer-web-packaging-deployment`.
- Orquestração de múltiplas skills → usar `JS-VueJS-orchestrator`.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|----------------------|
| `JS-VueJS-language-core` | Sempre — define padrão JS vs TS e nomenclatura base |
| `developer-web-build-tooling-quality` | Quando o projeto ainda não tiver Vite configurado |

## Inputs

- Requisitos de UI, estados e interações.

## Workflow executável

1. Modelar componentes por responsabilidade.
2. Usar Composition API + `<script setup>` como padrão.
3. Extrair lógica reutilizável para composables.
4. Validar render e interações locais.

## Padrão arquitetural obrigatório

- Composition API + `<script setup>` por padrão.
- Options API apenas para legado ou exigência explícita.

## Nota SSR/SSG (Nuxt)

- Considerar Nuxt quando SEO, conteúdo indexável e first paint forem críticos.
- Base deste kit é SPA com Vite.

## Checklist de qualidade web

- [ ] Sem lógica de API diretamente em `views`.
- [ ] Sem acoplamento forte entre componentes.
- [ ] `npm run dev`
- [ ] `npm run build`

## Seção de nomenclatura aplicada

- Componentes e tipos: `PascalCase`
- Composables/funções: `camelCase` (prefixo `use` para composables)
- Constantes: `UPPER_SNAKE_CASE`

## Stack e versões

| Componente | Versão mínima | Notas |
| ---------- | :-----------: | ----- |
| Vue.JS | 3.4.x | Composition API com `<script setup>` obrigatório |
| Node.js | 18.x | LTS mínimo |
| Vite | 5.x | Build tool padrão para SPA |
| Pinia | 2.x | State management |
| Vue Router | 4.x | Roteamento declarativo |

## Dependências npm

```bash
npm install vue@^3.4 @vitejs/plugin-vue
npm install -D vite
npm run dev
npm run build
```

**Conflitos conhecidos:** Nenhum identificado.

## Checklist Web/Vue.JS

- [ ] Componente SFC válido (`.vue` com `<template>`, `<script setup>`, `<style scoped>`)
- [ ] Sem dependência circular entre componentes
- [ ] Props tipadas (`defineProps<{}>()` com TypeScript ou validação explícita)
- [ ] Loading state, error boundary e empty state tratados
- [ ] Acessibilidade básica: `aria-label`, navegação por teclado, contraste WCAG AA

## Exemplo mínimo funcional

```vue
<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{ firstName: string }>()

const fullName = computed(() => `${props.firstName} Lovelace`)
</script>

<template>
  <h1>{{ fullName }}</h1>
</template>

<style scoped>
h1 { font-size: 1.5rem; }
</style>
```

## Checklist de segurança web

- [ ] Evitar `v-html` com dados não sanitizados.
- [ ] Evitar exposição de dados sensíveis em props.

## Avaliação de risco e confirmação

- Se refatoração arquitetural envolver múltiplos componentes críticos, confirmar antes.

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|------------------|---------------|
| Lógica de fetch de API em `views` sem composable | Viola SRP, dificulta testes e reuso | Extrair para composable `useXxxData()` |
| Usar Options API em código novo | Mistura de paradigmas, dificulta migração futura | Reescrever com `<script setup>` e Composition API |
| Componente com mais de ~300 linhas sem decomposição | Baixa coesão, difícil de testar isoladamente | Quebrar em componentes menores por responsabilidade |
| Props mutadas diretamente no filho | Viola fluxo unidirecional de dados do Vue | Emitir evento para o pai via `emit` |
| `v-html` com conteúdo externo sem sanitização | Vulnerabilidade XSS | Usar DOMPurify ou remover `v-html` |

## Métricas de sucesso

- Nenhum componente de `views/` contém chamadas HTTP diretas — toda lógica de dados está em composables.
- `npm run build` conclui sem warnings de circular dependency.
- Revisão de código aprova ausência de `v-html` inseguro e props mutadas.

## Responsável principal

| Papel | Quem |
|-------|------|
| Executor | Desenvolvedor Front-end Vue.JS |
| Revisor | Tech Lead / Arquiteto Front-end |

## Referências canônicas

- <https://vuejs.org/guide/quick-start.html>
- <https://vuejs.org/guide/introduction.html>

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `JS-VueJS-component-architecture`; novo prefixo canônico `developer-vuejs`. Conteúdo V2 preservado (FileVersion 1.1.0 da origem). Referências internas atualizadas para nomes canônicos.

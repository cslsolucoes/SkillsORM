---
name: developer-vuejs-routing-state
description: Roteamento e gerenciamento de estado em VueJS com Vue Router e Pinia, incluindo guards e lazy loading.
model: sonnet
thinking: extended
category: developer-web
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---
> **DEPRECATED** — Substituída por `developer-vuejs-routing-state_V1.1.0` (E11, 2026-04-24). Não usar.


# developer-vuejs-routing-state

## Responsabilidade única

Esta skill cobre a configuração de Vue Router (rotas, guards de autenticação, lazy loading, meta) e o gerenciamento de estado global com Pinia (stores por domínio, state, getters, actions, reset). Não trata criação de componentes SFC, configuração de build/Vite, testes ou deploy — cada um tem sua skill dedicada.

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## When to use

- Definir navegação, autorização de rotas e estado global da aplicação.
- Implementar guards de autenticação (`beforeEach`, `beforeEnter`, `onBeforeRouteLeave`).
- Criar ou refatorar stores Pinia por domínio.
- Aplicar lazy loading em views para otimização de bundle.

## When NOT to use

- Não usar para configuração de bundling/build → use `developer-web-build-tooling-quality`
- Não usar para criar componentes `.vue` SFC → use `developer-vuejs-components-reactivity`
- Não usar para fundamentos de linguagem JS/TS → use `JS-VueJS-language-core`
- Não usar para testes de rotas ou stores → use `JS-testing-and-debugging-web`
- Não usar para deploy ou CI/CD → use `developer-web-packaging-deployment`
- Não usar para performance de carregamento de rotas → use `JS-performance-and-accessibility-web`

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|----------------------|
| `developer-web-build-tooling-quality` | Confirmar que Vite/Node estão configurados antes de instalar Vue Router e Pinia |
| `JS-VueJS-language-core` | Estabelecer padrões JS/TS antes de criar stores e rotas |

## Inputs

- Mapa de páginas, requisitos de autenticação e estados globais.

## Workflow executável

1. Definir rotas e metas (`requiresAuth`, `title`).
2. Implementar guards globais e por rota.
3. Criar stores Pinia por domínio.
4. Aplicar lazy loading em views.

## Cobertura obrigatória

- `router.beforeEach`, `beforeEnter`, `onBeforeRouteLeave`.
- Pinia: `state`, `getters`, `actions`, reset de estado.

## Stack e versões

| Componente | Versão mínima | Notas |
|------------|--------------|-------|
| Vue.JS | 3.4.x | Composition API com `<script setup>` obrigatório |
| Node.js | 18.x | LTS mínimo |
| Vite | 5.x | Build tool padrão para SPA |
| Pinia | 2.1.x | State management; `defineStore` com Composition API |
| Vue Router | 4.x | `createRouter` + `createWebHistory` |
| TypeScript | 5.x | Tipagem de rotas e stores recomendada |

## Dependências npm

```bash
npm install vue-router@4
npm install pinia
npm install pinia-plugin-persistedstate
npm install --save-dev unplugin-vue-router
```

## Checklist Web/Vue.JS

- [ ] Componente SFC válido (.vue com template, script setup, style scoped)
- [ ] Sem dependência circular entre componentes
- [ ] Props tipadas (defineProps<{}>() com TypeScript ou validação explícita)
- [ ] Loading state, error boundary e empty state tratados
- [ ] Acessibilidade básica: aria-label, navegação por teclado, contraste WCAG AA
- [ ] Todas as rotas protegidas com guard `requiresAuth` quando aplicável
- [ ] Views carregadas com lazy loading (exceto home/landing inicial)
- [ ] Stores Pinia sem lógica HTTP acoplada (HTTP fica em composables/services)
- [ ] Reset de estado implementado em stores com dados sensíveis (ex: logout)
- [ ] Rotas nomeadas em `camelCase` estável — sem renomeações ad-hoc

## Exemplo mínimo funcional

```ts
// src/router/index.ts
import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes: RouteRecordRaw[] = [
  { path: '/', name: 'homePage', component: () => import('@/views/HomeView.vue') },
  { path: '/dashboard', name: 'dashboardPage', component: () => import('@/views/DashboardView.vue'), meta: { requiresAuth: true } },
]

export const router = createRouter({ history: createWebHistory(import.meta.env.BASE_URL), routes })

router.beforeEach((to, _from, next) => {
  const auth = useAuthStore()
  if (to.meta.requiresAuth && !auth.isAuthenticated) next({ name: 'loginPage' })
  else next()
})
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Lógica HTTP dentro de stores Pinia | Acopla store a detalhes de transporte, dificulta testes | Mover chamadas HTTP para composables/services; store recebe só o resultado |
| Token sensível em `localStorage` sem necessidade | Vulnerável a XSS | Usar `httpOnly cookie` via backend quando possível |
| Rotas sem nome (só `path`) | Links dependem de string de path frágil | Sempre definir `name` em `camelCase` |
| View importada diretamente (sem lazy loading) | Bundle inicial maior, TTI degradado | Usar `() => import('@/views/XxxView.vue')` |
| Store global com estado de UI local | Polui o store global | Estado local vai em `ref`/`reactive` no SFC |

## Métricas de sucesso

- Zero rotas protegidas sem guard `requiresAuth` verificado
- Todas as views (exceto landing) usando lazy loading
- `npm run build` sem warnings de chunks acima do limite configurado
- Stores sem referências diretas a `fetch`/`axios`

## Responsável principal

| Papel | Quem |
|-------|------|
| Design de rotas e stores | Tech Lead / Arquiteto Frontend |
| Implementação de guards | Desenvolvedor Frontend |
| Revisão de segurança de rotas | Code Reviewer / Security Lead |

## Referências canônicas

- https://router.vuejs.org/
- https://pinia.vuejs.org/

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `JS-VueJS-routing-and-state`; novo prefixo canônico `developer-vuejs`. Conteúdo V2 preservado (FileVersion 1.1.0 da origem). Referências internas atualizadas para nomes canônicos.

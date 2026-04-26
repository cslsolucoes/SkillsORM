# Plano de Melhoria — Skills Vue.js · Onda E11

**Versão:** 1.0.0 · **Data:** 2026-04-24
**Referência:** https://v2.vuejs.org/ (Vue 2 Options API) + conhecimento Vue 3
**Aprovado por:** _(aguardando aprovação explícita)_

---

## 0. Resumo executivo

As 11 skills web/Vue.js do pack (4 `developer-vuejs-*` + 7 `developer-web-*`) cobrem
exclusivamente Vue 3 com Composition API. O usuário referenciou `v2.vuejs.org`, sinalizando
necessidade de cobertura Vue 2 (Options API, Vuex, Vue Router 3) e gaps no kit Vue 3 atual.

| Tipo de ação | Qtd | Skills afetadas |
|---|---|---|
| **Fix refs quebradas** | 4 skills | vuejs-language-core, components-reactivity, routing-state, master-orchestrator |
| **Enriquecer conteúdo** | 3 skills | components-reactivity, routing-state, language-core |
| **Criar skills novas Vue 3** | 3 skills | forms-validation, api-integration, testing-vue |
| **Criar skills Vue 2** | 3 skills | vue2-options-api, vue2-state-router, vue2-to-vue3-migration |
| **Total artefatos** | **+6 novas + 4 corrigidas** | |

---

## 1. Inventário e diagnóstico das skills atuais

### 1.1 Skills developer-vuejs-* (4)

| Skill | Versão | Problema detectado |
|---|---|---|
| `developer-vuejs-language-core` | 1.0.0 | Refs quebradas: `JS-VueJS-language-core` (nome antigo); `developer-web-build-tooling-quality` OK |
| `developer-vuejs-components-reactivity` | 1.0.0 | Refs quebradas: `JS-VueJS-orchestrator` (antigo); falta: `defineEmits`, `provide/inject`, `slots`, `Suspense`, `Teleport`, `v-model` em componentes |
| `developer-vuejs-routing-state` | 1.0.0 | Refs quebradas: `JS-VueJS-language-core` (antigo), `JS-testing-and-debugging-web` (antigo); falta: `storeToRefs`, persistência Pinia, composable pattern em stores |
| `developer-vuejs-master-orchestrator` | 1.0.0 | Matriz referencia `developer-web-docs-to-structured-code` (existe ✓); listing menciona `JS-VueJS-language-core` (antigo) |

### 1.2 Skills developer-web-* (7) — estado atual

| Skill | Status |
|---|---|
| `developer-web-build-tooling-quality` | ✅ OK |
| `developer-web-nodejs-api-middleware` | ✅ OK |
| `developer-web-testing-debugging` | ⚠️ Genérico — sem Vue Test Utils / Vitest para Vue |
| `developer-web-performance-accessibility` | ✅ OK |
| `developer-web-packaging-deployment` | ✅ OK |
| `developer-web-documentation-governance` | ✅ OK |
| `developer-web-docs-to-structured-code` | ✅ OK |

### 1.3 Gaps identificados — Vue 3

| Gap | Impacto |
|---|---|
| Formulários e validação (`v-model`, VeeValidate, Zod/Yup) | Alto — toda app tem formulários |
| Integração HTTP com composables (`useAxios`, interceptors, retry) | Alto — toda app consome API |
| Testing Vue-específico (Vitest + Vue Test Utils v2) | Alto — `developer-web-testing-debugging` é genérico |
| Nuxt.js SSR/SSG (mencionado em components mas sem skill dedicada) | Médio |

### 1.4 Gaps identificados — Vue 2

| Gap | Impacto |
|---|---|
| Options API (`data`, `computed`, `methods`, `watch`, lifecycle hooks) | Crítico p/ projetos legado |
| Vuex 3/4 (state management Vue 2) | Crítico p/ projetos legado |
| Vue Router 3 (roteamento Vue 2) | Crítico p/ projetos legado |
| Mixins e event bus (padrões Vue 2) | Médio |
| Guia de migração Vue 2 → Vue 3 | Alto — projetos em transição |

---

## 2. Plano de execução por prioridade

### P1 — Correções (sem aprovação de plano — apenas fixes)

**P1.1 — Fix refs quebradas nas 4 skills vuejs-* (bump V1.0.0 → V1.1.0)**

| Skill | Ref antiga | Ref correta |
|---|---|---|
| `language-core` | `JS-VueJS-language-core` | `developer-vuejs-language-core` |
| `components-reactivity` | `JS-VueJS-orchestrator` | `developer-vuejs-master-orchestrator` |
| `routing-state` | `JS-VueJS-language-core` | `developer-vuejs-language-core` |
| `routing-state` | `JS-testing-and-debugging-web` | `developer-web-testing-debugging` |
| `master-orchestrator` | `JS-VueJS-language-core` (em listing) | `developer-vuejs-language-core` |

---

### P2 — Enriquecimento de skills existentes

**P2.1 — `developer-vuejs-components-reactivity` → V1.1.0**

Adicionar seções:
- `defineEmits<{}>()` + validação de emit
- `provide` / `inject` com typed keys
- `<slot>` nomeados e scoped slots
- `<Teleport to="body">` para modais
- `<Suspense>` + `defineAsyncComponent`
- `v-model` em componentes customizados (`defineModel` Vue 3.4+)
- Expandir: `watchEffect`, `watch` com `{ deep, immediate, once }`

**P2.2 — `developer-vuejs-routing-state` → V1.1.0**

Adicionar seções:
- `storeToRefs(store)` — reatividade fora do setup
- Pinia persistence (`pinia-plugin-persistedstate`)
- Composable pattern dentro de stores (`useXxx` com `storeToRefs`)
- `useRoute()` / `useRouter()` dentro de composables
- `router.push` vs `router.replace` vs `router.go`
- Scroll behavior no createRouter
- Nested routes e `<RouterView>` aninhado

**P2.3 — `developer-vuejs-language-core` → V1.1.0**

Adicionar seções:
- `??=` (Nullish assignment), `?.` (Optional chaining), `Array.at(-1)`
- TypeScript generics em composables: `function useData<T>()`
- `toRef`, `toRefs`, `toValue` (Vue 3.3+)
- `effectScope` para composables com múltiplos watchers
- Type narrowing com `isRef`, `isReactive`, `isProxy`

---

### P3 — Skills novas Vue 3

**P3.1 — `developer-vuejs-forms-validation_V1.0.0`**

Cobertura:
- `v-model` nativo vs. customizado em componentes
- VeeValidate 4 + Zod schema (composição com `useForm`, `useField`)
- Validação reativa sem biblioteca (composable `useValidation`)
- Formulários dinâmicos (`v-for` com campos variáveis)
- `<form @submit.prevent>`, `FormData`, file upload
- Error states e acessibilidade (`aria-invalid`, `aria-describedby`)
- Checklist: campos obrigatórios, mensagens de erro, loading/submit state

**P3.2 — `developer-vuejs-api-integration_V1.0.0`**

Cobertura:
- Composable `useFetch<T>()` com `ref`, `loading`, `error`, `data`
- Axios + interceptors (token injection, refresh, error handling)
- `useAxios` (VueUse) vs. composable manual
- Cancelamento de requests (`AbortController`)
- Paginação e infinite scroll com composable
- Estratégias de cache (SWR pattern em Vue)
- Error boundaries para erros de API
- Checklist: loading state, error state, empty state, retry

**P3.3 — `developer-vuejs-testing_V1.0.0`**

Cobertura:
- Vitest setup (`vitest.config.ts`, `@vue/test-utils`)
- `mount` vs `shallowMount` — quando usar cada um
- `wrapper.find`, `wrapper.get`, `wrapper.findAll`
- Testando props, emits, slots, provide/inject
- Mocking Pinia stores em testes (`createTestingPinia`)
- Mocking Vue Router em testes (`createRouter` com `createMemoryHistory`)
- Testando composables isoladamente
- Snapshot testing com `toMatchSnapshot`
- Checklist: coverage 80%+, testes de happy path + error path

---

### P4 — Skills novas Vue 2 (projetos legado)

**P4.1 — `developer-vuejs-vue2-options-api_V1.0.0`**

Cobertura:
- Options API completa: `data()`, `computed`, `methods`, `watch`, `props`
- Lifecycle hooks Vue 2: `beforeCreate`, `created`, `beforeMount`, `mounted`, `beforeUpdate`, `updated`, `beforeDestroy`, `destroyed`
- `v-model` Vue 2 (`:value` + `@input`)
- `$emit`, `$on`, `$off` — event bus pattern
- Mixins: quando usar, problemas (naming conflicts, origin opaca)
- Filters (`{{ value | currency }}`) — deprecado no Vue 3
- `Vue.set` / `Vue.delete` para reatividade em arrays/objetos
- Slots (padrão, nomeados, scoped com `v-slot`)
- Diretivas customizadas (`Vue.directive`)
- Checklist: sem `this` perdido em arrow functions, lifecycle correto

**P4.2 — `developer-vuejs-vue2-state-router_V1.0.0`**

Cobertura:
- Vuex 3 completo: `state`, `getters`, `mutations`, `actions`, `modules`
- `mapState`, `mapGetters`, `mapMutations`, `mapActions`
- Vuex modules com `namespaced: true`
- Vue Router 3: `createRouter` (Vue 2 = `new Router({})`), routes, meta
- `router.beforeEach`, `router.afterEach`, `router.beforeResolve`
- `$route`, `$router` dentro de componentes Options API
- Route params, query, hash
- Lazy loading: `component: () => import('./View.vue')`
- Checklist: mutations síncronas, actions assíncronas, módulos isolados

**P4.3 — `developer-vuejs-vue2-to-vue3-migration_V1.0.0`**

Cobertura:
- Tabela completa: Vue 2 → Vue 3 equivalências
  - `beforeDestroy` → `onBeforeUnmount`
  - `destroyed` → `onUnmounted`
  - `$listeners` → removido (merge com `$attrs`)
  - `$children` → removido
  - Filters → computed/methods
  - Event bus → `mitt` ou Pinia
  - Vuex → Pinia (mapeamento de conceitos)
  - Vue Router 3 → Vue Router 4 (mudanças de API)
- Estratégia de migração: Vue 2.7 como ponte (Composition API no Vue 2)
- `@vue/compat` — modo de compatibilidade
- Coexistência Vue 2 + Vue 3 em monorepo
- Checklist: warnings de deprecação, `$attrs` behavior, `v-model` breaking change

---

## 3. Antes / Depois

```
ANTES (E10 concluído):
  developer-vuejs-*: 4 skills (Vue 3 apenas, refs quebradas)
  developer-web-*:   7 skills
  Total web/vue:    11 skills

DEPOIS (E11 concluído):
  developer-vuejs-*: 4 skills corrigidas V1.1.0 (P1+P2)
                   + 3 novas Vue 3 (forms, api, testing) → 7 skills Vue 3
                   + 3 novas Vue 2 (options-api, state-router, migration) → 3 skills Vue 2
  developer-web-*:   7 skills (inalterado)
  Total web/vue:    17 skills (+6 novas, +4 enriquecidas)
```

---

## 4. Ordem de execução

```
Bloco P1 (fix imediato, sem aprovação de conteúdo novo):
  P1.1 — Fix refs em 4 skills vuejs-* (bump V1.0.0 → V1.1.0)

Bloco P2 (enriquecimento — 3 skills bump):
  P2.1 — components-reactivity V1.1.0 (defineEmits, provide/inject, slots, Teleport, Suspense)
  P2.2 — routing-state V1.1.0 (storeToRefs, Pinia persistence, useRoute em composables)
  P2.3 — language-core V1.1.0 (??=, generics, toRef/toRefs, effectScope)

Bloco P3 (skills novas Vue 3):
  P3.1 — developer-vuejs-forms-validation_V1.0.0
  P3.2 — developer-vuejs-api-integration_V1.0.0
  P3.3 — developer-vuejs-testing_V1.0.0

Bloco P4 (skills novas Vue 2):
  P4.1 — developer-vuejs-vue2-options-api_V1.0.0
  P4.2 — developer-vuejs-vue2-state-router_V1.0.0
  P4.3 — developer-vuejs-vue2-to-vue3-migration_V1.0.0

Pós-execução:
  → validate_pack.py (0 CRITICAL)
  → skills-pack-manifest → V1.23.0
  → skillsorm_analise_e_projecao.html atualizado
```

---

## 5. Atualização dos manifests

### `skills-pack-manifest` V1.22.0 → V1.23.0

- Seção "Onda E11 — Melhoria kit Vue.js"
- Delta: +6 skills novas (P3+P4), 4 enriquecidas (P1+P2)
- Família `developer-vuejs-*`: 4 → 10 skills
- FolderVersion: 1.22.0 → 1.23.0

---

## 6. Checklist de execução

| Item | Status |
|---|---|
| P1.1 Fix refs 4 skills vuejs-* (V1.1.0) | ⬜ |
| P2.1 components-reactivity V1.1.0 (enriquecer) | ⬜ |
| P2.2 routing-state V1.1.0 (enriquecer) | ⬜ |
| P2.3 language-core V1.1.0 (enriquecer) | ⬜ |
| P3.1 forms-validation criada | ⬜ |
| P3.2 api-integration criada | ⬜ |
| P3.3 testing-vue criada | ⬜ |
| P4.1 vue2-options-api criada | ⬜ |
| P4.2 vue2-state-router criada | ⬜ |
| P4.3 vue2-to-vue3-migration criada | ⬜ |
| validate_pack.py 0 CRITICAL | ⬜ |
| skills-pack-manifest V1.23.0 | ⬜ |
| skillsorm_analise_e_projecao.html atualizado | ⬜ |

---
name: developer-vuejs-vue2-to-vue3-migration
description: Guia prático de migração de Vue 2 para Vue 3. Cobre breaking changes, substituição de Options API por Composition API, migração de Vuex para Pinia, Vue Router 3 para 4, e estratégia incremental com @vue/compat.
model: sonnet
thinking: extended
category: developer-web
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-vuejs-vue2-to-vue3-migration

## Responsabilidade única

Guia de migração incremental de projetos Vue 2 para Vue 3: mapeamento de breaking changes, conversão de Options API para Composition API (`<script setup>`), substituição de Vuex 3 por Pinia, Vue Router 3 por Vue Router 4, remoção de filtros e event bus, e uso do modo de compatibilidade `@vue/compat` para migração gradual.

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## When to use
- Planejar ou executar migração de projeto Vue 2 para Vue 3.
- Converter componentes específicos de Options API para Composition API.
- Substituir Vuex por Pinia em projeto existente.
- Identificar breaking changes antes de bumpar a versão do Vue.

## When NOT to use
- Não usar para desenvolver em Vue 2 sem migrar → use `developer-vuejs-vue2-options-api`
- Não usar para Vue 3 já migrado → use `developer-vuejs-components-reactivity`
- Não usar para testes → use `developer-vuejs-testing`

## Breaking changes — mapeamento rápido

| Vue 2 | Vue 3 | Ação |
|-------|-------|------|
| `new Vue({ ... })` | `createApp({ ... })` | Trocar ponto de entrada |
| `Vue.use(Plugin)` | `app.use(Plugin)` | Mover para `createApp` chain |
| `Vue.set(obj, key, val)` | `obj.key = val` (Proxy) | Remover `Vue.set` |
| `Vue.delete(obj, key)` | `delete obj.key` | Remover `Vue.delete` |
| `$listeners` | Fundido em `$attrs` | Remover usos de `$listeners` |
| `$scopedSlots` | Unificado em `$slots` | Usar só `$slots` |
| `v-model` (`.sync`) | `v-model:prop` | Converter `.sync` |
| Filtros (`filters`) | Computed ou funções utilitárias | Extrair para `utils/` |
| Event bus (`new Vue()`) | `mitt` ou Pinia | Substituir por mitt |
| `beforeDestroy` | `onBeforeUnmount` | Renomear hook |
| `destroyed` | `onUnmounted` | Renomear hook |
| `functional: true` | Componentes funcionais nativo | Remover opção |
| `render(h)` | `render()` com `h` importado | Ajustar assinatura |
| `$children` | Removido | Usar `ref` ou `provide/inject` |
| `propsData` no `new Vue` | Props via `createApp().mount` | Ajustar montagem |

## Conversão de componente — Options API → Composition API

```vue
<!-- ANTES: Vue 2 Options API -->
<script>
import { loadingMixin } from '@/mixins/loadingMixin'

export default {
  name: 'UsuarioLista',
  mixins: [loadingMixin],
  props: {
    filtro: { type: String, default: '' },
  },
  data() {
    return {
      usuarios: [],
      pagina: 1,
    }
  },
  computed: {
    usuariosFiltrados() {
      return this.usuarios.filter(u =>
        u.nome.toLowerCase().includes(this.filtro.toLowerCase())
      )
    },
  },
  watch: {
    filtro() {
      this.pagina = 1
    },
  },
  created() {
    this.buscar()
  },
  methods: {
    async buscar() {
      await this.comLoading(() =>
        api.get('/usuarios').then(r => { this.usuarios = r.data })
      )
    },
  },
}
</script>
```

```vue
<!-- DEPOIS: Vue 3 Composition API -->
<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import type { Usuario } from '@/types/usuario'

const props = withDefaults(defineProps<{
  filtro?: string
}>(), { filtro: '' })

const pagina = ref(1)

const { data: usuarios, loading, execute: buscar } = useApi<Usuario[]>(
  () => api.get('/usuarios').then(r => r.data),
  { immediate: true }
)

const usuariosFiltrados = computed(() =>
  (usuarios.value ?? []).filter(u =>
    u.nome.toLowerCase().includes(props.filtro.toLowerCase())
  )
)

watch(() => props.filtro, () => {
  pagina.value = 1
})
</script>
```

## Migração de filtros Vue 2

```js
// ANTES — filtro global Vue 2
Vue.filter('moeda', (val) => `R$ ${Number(val).toFixed(2)}`)

// No template: {{ preco | moeda }}
```

```ts
// DEPOIS — função utilitária Vue 3
// src/utils/formatters.ts
export function formatarMoeda(val: number): string {
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL',
  }).format(val)
}

// No componente
import { formatarMoeda } from '@/utils/formatters'
// No template: {{ formatarMoeda(preco) }}
```

## Migração de event bus → mitt

```bash
npm install mitt
```

```ts
// src/eventBus.ts — Vue 3 com mitt
import mitt from 'mitt'

type Events = {
  'usuario-atualizado': { id: number; nome: string }
  'modal-abrir': string
}

export const emitter = mitt<Events>()

// Emitir
emitter.emit('usuario-atualizado', { id: 1, nome: 'Ana' })

// Ouvir (em setup)
import { onMounted, onUnmounted } from 'vue'
onMounted(() => emitter.on('usuario-atualizado', handler))
onUnmounted(() => emitter.off('usuario-atualizado', handler))
```

## Migração Vuex 3 → Pinia

```ts
// ANTES — Vuex 3 module auth
// state, getters, mutations, actions separados...

// DEPOIS — Pinia store auth
// src/stores/auth.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string | null>(localStorage.getItem('token'))
  const usuario = ref<Usuario | null>(null)

  const estaLogado = computed(() => !!token.value)
  const nomeUsuario = computed(() => usuario.value?.nome ?? 'Visitante')

  async function login(credenciais: LoginDto) {
    const { data } = await api.post('/auth/login', credenciais)
    token.value = data.token
    usuario.value = data.usuario
    localStorage.setItem('token', data.token)
  }

  function logout() {
    token.value = null
    usuario.value = null
    localStorage.removeItem('token')
  }

  return { token, usuario, estaLogado, nomeUsuario, login, logout }
})
```

## Migração Vue Router 3 → 4

```js
// ANTES — Vue Router 3
import Vue from 'vue'
import VueRouter from 'vue-router'
Vue.use(VueRouter)
const router = new VueRouter({ mode: 'history', routes })

// DEPOIS — Vue Router 4
import { createRouter, createWebHistory } from 'vue-router'
const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
})
```

```js
// ANTES — catch-all Vue Router 3
{ path: '*', component: NaoEncontrado }

// DEPOIS — catch-all Vue Router 4
{ path: '/:pathMatch(.*)*', name: 'NaoEncontrado', component: NaoEncontrado }
```

## Estratégia incremental com @vue/compat

```bash
# 1. Instalar modo de compatibilidade
npm install vue@^3 @vue/compat

# 2. Alias no vite.config.ts
resolve: {
  alias: { vue: '@vue/compat' }
}
```

```js
// 3. Configurar nível de compatibilidade
import { configureCompat } from 'vue'
configureCompat({
  MODE: 2, // Comportamento Vue 2 como padrão
  COMPONENT_V_MODEL: 'suppress-warning',
})
```

Migrar componente por componente, desativando flags de compat conforme convertidos.

## Ordem recomendada de migração

1. **Atualizar dependências** — Vue 2.7 (bridge) → Vue 3 + @vue/compat
2. **Corrigir breaking changes críticos** — `new Vue` → `createApp`, `$listeners`, `v-model` `.sync`
3. **Migrar filtros** → funções utilitárias em `utils/`
4. **Migrar event bus** → `mitt`
5. **Migrar Vue Router 3 → 4** — catch-all, `mode: history`
6. **Migrar Vuex → Pinia** — módulo por módulo
7. **Converter componentes** — Options API → `<script setup>` (começar pelos folha)
8. **Remover @vue/compat** — quando todos os warnings eliminados

## Checklist de migração

- [ ] `@vue/compat` instalado e configurado (se migração gradual)
- [ ] `new Vue` → `createApp` no `main.js`
- [ ] `Vue.set` / `Vue.delete` removidos
- [ ] Filtros (`filters`) convertidos para funções em `utils/`
- [ ] Event bus substituído por `mitt`
- [ ] Vue Router 3 → 4 (catch-all, `createRouter`)
- [ ] Vuex 3 → Pinia (stores convertidas)
- [ ] `beforeDestroy` → `onBeforeUnmount`
- [ ] `destroyed` → `onUnmounted`
- [ ] Zero warnings no console após migração

## Referências canônicas
- https://v3-migration.vuejs.org/
- https://pinia.vuejs.org/cookbook/migration-vuex.html
- https://router.vuejs.org/guide/migration/
- https://github.com/vuejs/vue-compat

## Changelog (este arquivo)

- 1.0.0 (24/04/2026): E11 P4 — skill criada. Cobre breaking changes Vue 2→3, conversão Options API → Composition API, migração filtros/event bus/Vuex/Router, estratégia incremental com @vue/compat.

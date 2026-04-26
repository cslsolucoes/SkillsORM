---
name: developer-vuejs-vue2-state-router
description: Gerenciamento de estado com Vuex 3 e roteamento com Vue Router 3 em projetos Vue 2. Cobre módulos Vuex, getters, actions assíncronas, guards de rota e navegação programática.
model: sonnet
thinking: extended
category: developer-web
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-vuejs-vue2-state-router

## Responsabilidade única

Cobre Vuex 3 (state, getters, mutations, actions, módulos com namespace) e Vue Router 3 (rotas aninhadas, guards de navegação, parâmetros dinâmicos, navegação programática) para projetos Vue 2. Não abrange Options API, mixins, testes ou migração para Vue 3/Pinia.

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## When to use
- Configurar Vuex 3 em projeto Vue 2 com módulos e namespace.
- Implementar actions assíncronas (API calls) no Vuex.
- Configurar Vue Router 3 com rotas aninhadas e guards.
- Proteger rotas com `beforeEach` (autenticação/autorização).

## When NOT to use
- Não usar para Vue 3 / Pinia → use `developer-vuejs-routing-state`
- Não usar para Options API Vue 2 → use `developer-vuejs-vue2-options-api`
- Não usar para planejar migração → use `developer-vuejs-vue2-to-vue3-migration`
- Não usar para testes → use `developer-vuejs-testing`

## Stack

| Componente | Versão | Notas |
|------------|--------|-------|
| Vuex | 3.x | State management para Vue 2 |
| Vue Router | 3.x | Roteamento para Vue 2 |

```bash
npm install vuex@3 vue-router@3
```

## Vuex 3 — Módulo com namespace

```js
// src/store/modules/auth.js
const state = () => ({
  token: localStorage.getItem('token') || null,
  usuario: null,
  carregando: false,
})

const getters = {
  estaLogado: (state) => !!state.token,
  nomeUsuario: (state) => state.usuario?.nome ?? 'Visitante',
  tokenHeader: (state) => state.token ? `Bearer ${state.token}` : null,
}

const mutations = {
  SET_TOKEN(state, token) {
    state.token = token
    if (token) localStorage.setItem('token', token)
    else localStorage.removeItem('token')
  },
  SET_USUARIO(state, usuario) {
    state.usuario = usuario
  },
  SET_CARREGANDO(state, val) {
    state.carregando = val
  },
}

const actions = {
  async login({ commit }, credenciais) {
    commit('SET_CARREGANDO', true)
    try {
      const { data } = await api.post('/auth/login', credenciais)
      commit('SET_TOKEN', data.token)
      commit('SET_USUARIO', data.usuario)
    } finally {
      commit('SET_CARREGANDO', false)
    }
  },
  logout({ commit }) {
    commit('SET_TOKEN', null)
    commit('SET_USUARIO', null)
  },
  async carregarPerfil({ commit, state }) {
    if (!state.token) return
    const { data } = await api.get('/auth/me')
    commit('SET_USUARIO', data)
  },
}

export default {
  namespaced: true,
  state,
  getters,
  mutations,
  actions,
}
```

```js
// src/store/index.js
import Vue from 'vue'
import Vuex from 'vuex'
import auth from './modules/auth'
import usuarios from './modules/usuarios'

Vue.use(Vuex)

export default new Vuex.Store({
  strict: process.env.NODE_ENV !== 'production',
  modules: {
    auth,
    usuarios,
  },
})
```

## Uso do Vuex em componentes

```vue
<script>
import { mapGetters, mapActions, mapState } from 'vuex'

export default {
  computed: {
    // mapGetters com namespace
    ...mapGetters('auth', ['estaLogado', 'nomeUsuario']),
    // mapState com namespace
    ...mapState('auth', ['carregando']),
    // mapState com função (transformação)
    ...mapState('usuarios', {
      lista: (state) => state.lista,
      total: (state) => state.lista.length,
    }),
  },
  methods: {
    ...mapActions('auth', ['login', 'logout']),
    async entrar() {
      await this.login({ email: this.email, senha: this.senha })
      this.$router.push('/dashboard')
    },
  },
}
</script>
```

## Acesso direto à store (fora de componentes)

```js
// Em um serviço ou helper
import store from '@/store'

// Ler estado
const token = store.getters['auth/tokenHeader']

// Disparar action
await store.dispatch('auth/carregarPerfil')

// Commit direto (evitar fora de componentes)
store.commit('auth/SET_USUARIO', usuario)
```

## Vue Router 3 — Configuração

```js
// src/router/index.js
import Vue from 'vue'
import VueRouter from 'vue-router'
import store from '@/store'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    redirect: '/dashboard',
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/LoginView.vue'),
    meta: { publico: true },
  },
  {
    path: '/dashboard',
    component: () => import('@/layouts/AppLayout.vue'),
    meta: { requerAutenticacao: true },
    children: [
      {
        path: '',
        name: 'Dashboard',
        component: () => import('@/views/DashboardView.vue'),
      },
      {
        path: 'usuarios',
        name: 'Usuarios',
        component: () => import('@/views/UsuariosView.vue'),
        meta: { permissao: 'usuarios.listar' },
      },
      {
        path: 'usuarios/:id',
        name: 'UsuarioDetalhe',
        component: () => import('@/views/UsuarioDetalheView.vue'),
        props: true,
      },
    ],
  },
  {
    path: '*',
    name: 'NaoEncontrado',
    component: () => import('@/views/NaoEncontradoView.vue'),
  },
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes,
  scrollBehavior(to, from, savedPosition) {
    return savedPosition ?? { x: 0, y: 0 }
  },
})

// Guard global — autenticação
router.beforeEach((to, from, next) => {
  const estaLogado = store.getters['auth/estaLogado']
  const requerAuth = to.matched.some((r) => r.meta.requerAutenticacao)
  const ehPublico = to.matched.some((r) => r.meta.publico)

  if (requerAuth && !estaLogado) {
    return next({ name: 'Login', query: { redirect: to.fullPath } })
  }

  if (ehPublico && estaLogado) {
    return next({ name: 'Dashboard' })
  }

  next()
})

export default router
```

## Navegação programática

```js
// Navegar para rota nomeada
this.$router.push({ name: 'UsuarioDetalhe', params: { id: 42 } })

// Com query string
this.$router.push({ name: 'Usuarios', query: { page: 2, busca: 'Ana' } })

// Voltar
this.$router.go(-1)

// Substituir (sem histórico)
this.$router.replace({ name: 'Login' })

// Acessar parâmetros da rota atual
const id = this.$route.params.id
const page = this.$route.query.page
const nomeDaRota = this.$route.name
```

## Route guard por componente

```js
export default {
  // Antes de entrar na rota deste componente
  beforeRouteEnter(to, from, next) {
    next((vm) => {
      // vm = instância do componente (única forma de acessar no beforeRouteEnter)
      vm.carregarDados()
    })
  },
  // Antes de sair (ex.: formulário não salvo)
  beforeRouteLeave(to, from, next) {
    if (this.formularioSujo) {
      const confirmou = window.confirm('Deseja sair sem salvar?')
      return confirmou ? next() : next(false)
    }
    next()
  },
}
```

## Checklist Vuex + Router Vue 2

- [ ] Store com `strict: true` em desenvolvimento
- [ ] Módulos com `namespaced: true`
- [ ] Mutations são síncronas; actions assíncronas
- [ ] `state` como função (escopo por instância)
- [ ] Token persistido em `localStorage` via mutation
- [ ] Guard global `beforeEach` protege rotas privadas
- [ ] Rotas lazy-loaded com `() => import(...)`
- [ ] `scrollBehavior` configurado
- [ ] Parâmetros de rota acessados via `this.$route.params`

## Anti-padrões

| Anti-padrão | Correção |
|-------------|----------|
| Mutar state diretamente fora de mutation | Sempre usar commit/mutation |
| Lógica assíncrona em mutation | Mover para action |
| `store.state.auth.token` em template | Usar getter ou mapState |
| Rotas sem lazy loading | `() => import(...)` em todas as views |
| `next()` sem `return` em guards | Sempre `return next(...)` para evitar double-navigation |

## Referências canônicas
- https://v3.vuex.vuejs.org/
- https://v3.router.vuejs.org/
- https://v2.vuejs.org/v2/guide/

## Changelog (este arquivo)

- 1.0.0 (24/04/2026): E11 P4 — skill criada. Cobre Vuex 3 (módulos, namespace, getters, actions async), Vue Router 3 (rotas aninhadas, lazy loading, guards globais e por componente, navegação programática).

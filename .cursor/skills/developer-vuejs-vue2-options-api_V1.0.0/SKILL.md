---
name: developer-vuejs-vue2-options-api
description: Options API em Vue 2 — data, computed, methods, watch, lifecycle hooks, props, eventos e mixins. Para projetos legados que ainda não migraram para Vue 3.
model: sonnet
thinking: extended
category: developer-web
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-vuejs-vue2-options-api

## Responsabilidade única

Cobre o desenvolvimento com Vue 2 usando Options API: `data()`, `computed`, `methods`, `watch`, lifecycle hooks (`created`, `mounted`, `beforeDestroy`), props, eventos `$emit`, mixins e filtros (`filters`). Não abrange Vue Router 3, Vuex 3, testes ou migração para Vue 3.

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## When to use
- Manter ou evoluir projetos Vue 2 com Options API.
- Criar componentes em projetos legados sem Composition API.
- Implementar mixins para lógica compartilhada entre componentes Vue 2.
- Usar filtros de exibição (`filters`) em templates Vue 2.

## When NOT to use
- Não usar para novos projetos — iniciar com Vue 3 e Composition API.
- Não usar para roteamento/estado Vue 2 → use `developer-vuejs-vue2-state-router`
- Não usar para planejar migração → use `developer-vuejs-vue2-to-vue3-migration`
- Não usar para Vue 3 / Composition API → use `developer-vuejs-components-reactivity`

## Stack Vue 2

| Componente | Versão | Notas |
|------------|--------|-------|
| Vue | 2.7.x | Última versão Vue 2 (EOL: Dez 2023) |
| Vue CLI | 5.x | Tooling de projeto Vue 2 |
| vue-class-component | 7.x | Opcional: decorators estilo classe |

## Estrutura de componente Vue 2

```vue
<template>
  <div class="usuario-card">
    <h2>{{ nomeCompleto }}</h2>
    <p>{{ saudacao }}</p>
    <p>Acessos: {{ acessos }}</p>

    <button @click="incrementarAcessos">+ Acesso</button>
    <button @click="$emit('remover', usuario.id)">Remover</button>

    <ul>
      <li v-for="item in itens" :key="item.id">
        {{ item.nome | maiusculas }}
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  name: 'UsuarioCard',

  // Props com validação
  props: {
    usuario: {
      type: Object,
      required: true,
      validator(val) {
        return val.nome && val.email
      },
    },
    itens: {
      type: Array,
      default: () => [],
    },
  },

  // Data como função (escopo por instância)
  data() {
    return {
      acessos: 0,
      mensagem: '',
    }
  },

  // Computed — cacheados, recalculam ao mudar dependência
  computed: {
    nomeCompleto() {
      return `${this.usuario.nome} ${this.usuario.sobrenome ?? ''}`.trim()
    },
    saudacao() {
      const hora = new Date().getHours()
      if (hora < 12) return 'Bom dia'
      if (hora < 18) return 'Boa tarde'
      return 'Boa noite'
    },
  },

  // Watch — reage a mudanças de estado/props
  watch: {
    'usuario.email': {
      handler(novoEmail) {
        this.validarEmail(novoEmail)
      },
      immediate: true,
    },
    acessos(novoVal) {
      if (novoVal >= 100) this.$emit('limite-atingido')
    },
  },

  // Lifecycle hooks
  created() {
    // Dados disponíveis, DOM ainda não montado
    this.carregarDados()
  },
  mounted() {
    // DOM disponível — uso de refs, focus, libs externas
    this.$refs.input?.focus()
  },
  beforeDestroy() {
    // Limpar timers, event listeners externos
    clearInterval(this.timer)
  },

  // Methods
  methods: {
    incrementarAcessos() {
      this.acessos++
    },
    async carregarDados() {
      try {
        const res = await fetch(`/api/usuarios/${this.usuario.id}`)
        this.mensagem = await res.json()
      } catch (err) {
        console.error('[carregarDados]', err)
      }
    },
    validarEmail(email) {
      // lógica de validação
    },
  },

  // Filtros — só Vue 2 (removidos no Vue 3)
  filters: {
    maiusculas(val) {
      return typeof val === 'string' ? val.toUpperCase() : val
    },
  },
}
</script>

<style scoped>
.usuario-card {
  padding: 1rem;
  border: 1px solid #e2e8f0;
}
</style>
```

## Mixins — lógica reutilizável

```js
// src/mixins/loadingMixin.js
export const loadingMixin = {
  data() {
    return {
      loading: false,
      error: null,
    }
  },
  methods: {
    async comLoading(fn) {
      this.loading = true
      this.error = null
      try {
        return await fn()
      } catch (err) {
        this.error = err.message || 'Erro desconhecido'
      } finally {
        this.loading = false
      }
    },
  },
}

// Uso em componente
import { loadingMixin } from '@/mixins/loadingMixin'

export default {
  mixins: [loadingMixin],
  methods: {
    async buscar() {
      await this.comLoading(() => api.get('/dados'))
    },
  },
}
```

## Vue.set — reatividade em objetos/arrays

```js
// ❌ Não reativo — Vue 2 não detecta
this.objeto.novaPropriedade = 'valor'
this.array[0] = 'novo'

// ✅ Reativo com Vue.set
import Vue from 'vue'
Vue.set(this.objeto, 'novaPropriedade', 'valor')
Vue.set(this.array, 0, 'novo')

// Ou via this.$set
this.$set(this.usuario, 'ativo', true)
this.$set(this.itens, index, novoItem)

// Para arrays — métodos reativos nativos
this.itens.push(novoItem)
this.itens.splice(index, 1)
this.itens.sort((a, b) => a.nome.localeCompare(b.nome))
```

## Event bus (padrão Vue 2 para comunicação entre componentes)

```js
// src/eventBus.js
import Vue from 'vue'
export const eventBus = new Vue()

// Emitir em componente A
eventBus.$emit('usuario-atualizado', { id: 1, nome: 'Ana' })

// Ouvir em componente B
export default {
  created() {
    eventBus.$on('usuario-atualizado', this.onUsuarioAtualizado)
  },
  beforeDestroy() {
    // SEMPRE remover listener para evitar memory leak
    eventBus.$off('usuario-atualizado', this.onUsuarioAtualizado)
  },
  methods: {
    onUsuarioAtualizado(usuario) {
      this.usuario = usuario
    },
  },
}
```

## Refs em Vue 2

```vue
<template>
  <input ref="campoNome" type="text" />
</template>

<script>
export default {
  mounted() {
    // Acesso ao elemento DOM
    this.$refs.campoNome.focus()
  },
}
</script>
```

## Checklist Vue 2 Options API

- [ ] `data()` retorna função (não objeto direto)
- [ ] Props com `type`, `required` e/ou `default` definidos
- [ ] `Vue.set` / `this.$set` para propriedades adicionadas dinamicamente
- [ ] Listeners do event bus removidos em `beforeDestroy`
- [ ] Computed sem efeitos colaterais
- [ ] Watch com `immediate: true` quando precisar executar na criação
- [ ] Mixins com responsabilidade única e nome descritivo

## Anti-padrões Vue 2

| Anti-padrão | Correção |
|-------------|----------|
| `data: { ... }` como objeto | Usar `data() { return { ... } }` |
| Mutar prop diretamente | Emitir evento; pai atualiza o dado |
| `this.array[i] = val` | Usar `this.$set(this.array, i, val)` |
| Event bus sem `$off` | Sempre remover em `beforeDestroy` |
| Lógica complexa em template | Mover para `computed` ou `methods` |

## Referências canônicas
- https://v2.vuejs.org/v2/guide/
- https://v2.vuejs.org/v2/api/
- https://v2.vuejs.org/v2/guide/mixins.html

## Changelog (este arquivo)

- 1.0.0 (24/04/2026): E11 P4 — skill criada. Cobre Options API Vue 2: data/computed/methods/watch, lifecycle hooks, props, eventos, mixins, Vue.set, event bus, refs, filtros.

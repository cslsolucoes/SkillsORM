---
name: developer-vuejs-api-integration
description: Integração de APIs REST em Vue 3 com Axios ou Fetch nativo. Cobre composables de requisição, interceptors, tratamento de erros HTTP, loading/error states e cache simples.
model: sonnet
thinking: extended
category: developer-web
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-vuejs-api-integration

## Responsabilidade única

Cobre o padrão de integração com APIs REST em projetos Vue 3: composables de requisição (`useApi`, `useFetch`), configuração de cliente HTTP (Axios ou Fetch), interceptors de autenticação/token, tratamento de erros HTTP por código, estados de loading/error e cache simples com `ref`. Não abrange validação de formulários, gerenciamento de estado global persistido, testes ou build tooling.

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## When to use
- Criar camada de serviço HTTP para chamar APIs REST.
- Implementar composable genérico de requisição com loading/error state.
- Configurar Axios com baseURL, interceptors e refresh de token.
- Tratar erros HTTP (401, 403, 404, 422, 500) de forma centralizada.

## When NOT to use
- Não usar para formulários com validação → use `developer-vuejs-forms-validation`
- Não usar para gerenciamento de estado global → use `developer-vuejs-routing-state`
- Não usar para testes de chamadas HTTP → use `developer-vuejs-testing`
- Não usar para estratégia multi-skill → use `developer-vuejs-master-orchestrator`

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|----------------------|
| `developer-vuejs-language-core` | TypeScript habilitado para tipagem de respostas |
| `developer-vuejs-components-reactivity` | Composables funcionando no projeto |

## Stack HTTP

| Opção | Quando usar |
|-------|-------------|
| **Axios** | Projetos com interceptors, upload, timeout por rota, retry |
| **Fetch nativo** | Projetos minimalistas sem dependências extras |

```bash
# Axios
npm install axios
```

## Composable genérico — useApi

```ts
// src/composables/useApi.ts
import { ref } from 'vue'

interface UseApiOptions<T> {
  immediate?: boolean
  initialData?: T
}

export function useApi<T>(
  fetcher: () => Promise<T>,
  options: UseApiOptions<T> = {}
) {
  const data = ref<T | null>(options.initialData ?? null) as Ref<T | null>
  const loading = ref(false)
  const error = ref<string | null>(null)

  async function execute() {
    loading.value = true
    error.value = null
    try {
      data.value = await fetcher()
    } catch (err) {
      error.value = parseApiError(err)
    } finally {
      loading.value = false
    }
  }

  if (options.immediate) {
    execute()
  }

  return { data, loading, error, execute }
}

function parseApiError(err: unknown): string {
  if (err instanceof AxiosError) {
    const msg = err.response?.data?.message
    if (typeof msg === 'string') return msg
    return `Erro ${err.response?.status ?? 'desconhecido'}`
  }
  if (err instanceof Error) return err.message
  return 'Erro inesperado'
}
```

## Cliente Axios com interceptors

```ts
// src/services/http.ts
import axios, { type AxiosError } from 'axios'
import { useAuthStore } from '@/stores/auth'
import router from '@/router'

export const http = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  timeout: 15_000,
  headers: { 'Content-Type': 'application/json' },
})

// Request interceptor — injeta token
http.interceptors.request.use((config) => {
  const auth = useAuthStore()
  if (auth.token) {
    config.headers.Authorization = `Bearer ${auth.token}`
  }
  return config
})

// Response interceptor — trata 401/403
http.interceptors.response.use(
  (res) => res,
  async (error: AxiosError) => {
    if (error.response?.status === 401) {
      const auth = useAuthStore()
      auth.logout()
      await router.push('/login')
    }
    if (error.response?.status === 403) {
      await router.push('/nao-autorizado')
    }
    return Promise.reject(error)
  }
)
```

## Serviço de domínio

```ts
// src/services/usuarios.service.ts
import { http } from './http'
import type { Usuario, CriarUsuarioDto } from '@/types/usuario'

export const UsuariosService = {
  listar: () =>
    http.get<Usuario[]>('/usuarios').then((r) => r.data),

  buscarPorId: (id: number) =>
    http.get<Usuario>(`/usuarios/${id}`).then((r) => r.data),

  criar: (dto: CriarUsuarioDto) =>
    http.post<Usuario>('/usuarios', dto).then((r) => r.data),

  atualizar: (id: number, dto: Partial<CriarUsuarioDto>) =>
    http.put<Usuario>(`/usuarios/${id}`, dto).then((r) => r.data),

  remover: (id: number) =>
    http.delete(`/usuarios/${id}`),
}
```

## Uso em componente

```vue
<script setup lang="ts">
import { useApi } from '@/composables/useApi'
import { UsuariosService } from '@/services/usuarios.service'
import type { Usuario } from '@/types/usuario'

const { data: usuarios, loading, error, execute: recarregar } = useApi<Usuario[]>(
  () => UsuariosService.listar(),
  { immediate: true }
)
</script>

<template>
  <div>
    <p v-if="loading" aria-live="polite">Carregando usuários...</p>
    <p v-else-if="error" role="alert" class="error">{{ error }}</p>
    <ul v-else>
      <li v-for="u in usuarios" :key="u.id">{{ u.nome }}</li>
    </ul>
    <button @click="recarregar">Recarregar</button>
  </div>
</template>
```

## Cache simples com ref

```ts
// src/composables/useApiCached.ts
import { ref } from 'vue'

const cache = new Map<string, { data: unknown; ts: number }>()
const TTL_MS = 60_000 // 1 minuto

export function useApiCached<T>(key: string, fetcher: () => Promise<T>) {
  const data = ref<T | null>(null) as Ref<T | null>
  const loading = ref(false)

  async function execute() {
    const cached = cache.get(key)
    if (cached && Date.now() - cached.ts < TTL_MS) {
      data.value = cached.data as T
      return
    }
    loading.value = true
    try {
      data.value = await fetcher()
      cache.set(key, { data: data.value, ts: Date.now() })
    } finally {
      loading.value = false
    }
  }

  return { data, loading, execute }
}
```

## Tratamento de erros HTTP por código

| Código | Ação padrão |
|--------|-------------|
| 400 | Exibir mensagem de validação do backend |
| 401 | Redirecionar para login, limpar token |
| 403 | Redirecionar para /nao-autorizado |
| 404 | Exibir "Recurso não encontrado" |
| 422 | Mapear erros por campo (validação servidor) |
| 500 | Exibir "Erro interno. Tente novamente." |
| Network | Exibir "Sem conexão com o servidor" |

## Checklist de integração HTTP

- [ ] `baseURL` em variável de ambiente `VITE_API_URL`
- [ ] Timeout configurado (ex.: 15 s)
- [ ] Interceptor de token no request
- [ ] Interceptor de 401 redireciona para login
- [ ] `parseApiError` trata `AxiosError` e `Error` genérico
- [ ] Loading state visível e acessível (`aria-live`)
- [ ] Erro exibido com `role="alert"`
- [ ] Serviços separados por domínio em `src/services/`

## Referências canônicas
- https://axios-http.com/docs/intro
- https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API
- https://vuejs.org/guide/reusability/composables.html

## Changelog (este arquivo)

- 1.0.0 (24/04/2026): E11 P3 — skill criada. Cobre Axios, composable genérico `useApi<T>`, interceptors de token/401, serviços por domínio, cache simples, tratamento de erros HTTP.

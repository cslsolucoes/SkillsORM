---
name: developer-vuejs-testing
description: Testes unitários e de componente em Vue 3 com Vitest e Vue Test Utils. Cobre setup de ambiente, testes de composables, componentes SFC, mocks de stores Pinia e chamadas HTTP.
model: sonnet
thinking: extended
category: developer-web
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-vuejs-testing

## Responsabilidade única

Cobre setup e escrita de testes em projetos Vue 3: configuração do Vitest, testes unitários de composables, testes de componentes SFC com Vue Test Utils, mocks de stores Pinia e interceptação de chamadas HTTP com `vi.mock`. Não abrange testes E2E (use Playwright/Cypress), build tooling, formulários ou deploy.

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## When to use
- Configurar ambiente de testes com Vitest para projetos Vue 3.
- Escrever testes unitários de composables (`useApi`, `useForm`, etc.).
- Escrever testes de componente SFC (render, interação, emits).
- Mockar stores Pinia e chamadas HTTP em testes isolados.

## When NOT to use
- Não usar para testes E2E — use Playwright ou Cypress.
- Não usar para configuração de build → use `developer-web-build-tooling-quality`
- Não usar para escrita de formulários → use `developer-vuejs-forms-validation`
- Não usar para estratégia multi-skill → use `developer-vuejs-master-orchestrator`

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|----------------------|
| `developer-vuejs-components-reactivity` | Componentes precisam estar escritos antes de testá-los |
| `developer-vuejs-routing-state` | Para testar stores Pinia |
| `developer-vuejs-api-integration` | Para mockar chamadas HTTP |

## Stack de testes

| Ferramenta | Versão | Papel |
|------------|--------|-------|
| Vitest | 1.x | Test runner (integrado ao Vite) |
| @vue/test-utils | 2.x | Utilitários de montagem de componentes |
| @pinia/testing | 0.x | Mock de stores Pinia |
| jsdom | 24.x | Ambiente DOM no Node |
| @testing-library/vue | 8.x | Alternativa centrada no usuário (opcional) |

## Instalação

```bash
npm install --save-dev vitest @vue/test-utils @pinia/testing jsdom
```

## Configuração — vite.config.ts

```ts
// vite.config.ts
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/test/setup.ts'],
  },
})
```

```ts
// src/test/setup.ts
import { config } from '@vue/test-utils'
import { createPinia } from 'pinia'

// Setup global Pinia para todos os testes
config.global.plugins = [createPinia()]
```

## Teste de composable

```ts
// src/composables/__tests__/useCounter.test.ts
import { describe, it, expect } from 'vitest'
import { useCounter } from '../useCounter'

describe('useCounter', () => {
  it('começa em zero', () => {
    const { count } = useCounter()
    expect(count.value).toBe(0)
  })

  it('incrementa em 1', () => {
    const { count, increment } = useCounter()
    increment()
    expect(count.value).toBe(1)
  })

  it('não vai abaixo de zero ao decrementar', () => {
    const { count, decrement } = useCounter()
    decrement()
    expect(count.value).toBe(0)
  })
})
```

## Teste de componente SFC

```ts
// src/components/__tests__/BotaoContador.test.ts
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import BotaoContador from '../BotaoContador.vue'

describe('BotaoContador', () => {
  it('renderiza o valor inicial da prop', () => {
    const wrapper = mount(BotaoContador, {
      props: { valor: 5 },
    })
    expect(wrapper.text()).toContain('5')
  })

  it('emite "incrementar" ao clicar no botão', async () => {
    const wrapper = mount(BotaoContador, {
      props: { valor: 0 },
    })
    await wrapper.find('button').trigger('click')
    expect(wrapper.emitted('incrementar')).toBeTruthy()
    expect(wrapper.emitted('incrementar')?.[0]).toEqual([1])
  })

  it('botão fica desabilitado quando prop disabled=true', () => {
    const wrapper = mount(BotaoContador, {
      props: { valor: 0, disabled: true },
    })
    expect(wrapper.find('button').attributes('disabled')).toBeDefined()
  })
})
```

## Teste com store Pinia mockada

```ts
// src/components/__tests__/PerfilUsuario.test.ts
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { createTestingPinia } from '@pinia/testing'
import PerfilUsuario from '../PerfilUsuario.vue'
import { useAuthStore } from '@/stores/auth'

describe('PerfilUsuario', () => {
  it('exibe o nome do usuário logado', () => {
    const wrapper = mount(PerfilUsuario, {
      global: {
        plugins: [
          createTestingPinia({
            initialState: {
              auth: { user: { nome: 'João Silva', email: 'joao@example.com' } },
            },
          }),
        ],
      },
    })
    expect(wrapper.text()).toContain('João Silva')
  })

  it('chama logout ao clicar em Sair', async () => {
    const wrapper = mount(PerfilUsuario, {
      global: {
        plugins: [createTestingPinia({ createSpy: vi.fn })],
      },
    })
    const auth = useAuthStore()
    await wrapper.find('[data-testid="btn-sair"]').trigger('click')
    expect(auth.logout).toHaveBeenCalledOnce()
  })
})
```

## Teste com mock de chamada HTTP

```ts
// src/composables/__tests__/useApi.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { useApi } from '../useApi'

// Mock do módulo HTTP
vi.mock('@/services/http', () => ({
  http: {
    get: vi.fn(),
  },
}))

import { http } from '@/services/http'

describe('useApi', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('seta loading=true durante a requisição', async () => {
    vi.mocked(http.get).mockResolvedValueOnce({ data: [] })
    const { loading, execute } = useApi(() => http.get('/usuarios').then(r => r.data))

    const promise = execute()
    expect(loading.value).toBe(true)
    await promise
    expect(loading.value).toBe(false)
  })

  it('popula data com o retorno da API', async () => {
    const usuarios = [{ id: 1, nome: 'Ana' }]
    vi.mocked(http.get).mockResolvedValueOnce({ data: usuarios })

    const { data, execute } = useApi(() => http.get('/usuarios').then(r => r.data))
    await execute()

    expect(data.value).toEqual(usuarios)
  })

  it('seta error quando a API falha', async () => {
    vi.mocked(http.get).mockRejectedValueOnce(new Error('Timeout'))

    const { error, execute } = useApi(() => http.get('/usuarios').then(r => r.data))
    await execute()

    expect(error.value).toBe('Timeout')
  })
})
```

## Scripts npm recomendados

```json
{
  "scripts": {
    "test": "vitest",
    "test:run": "vitest run",
    "test:coverage": "vitest run --coverage",
    "test:ui": "vitest --ui"
  }
}
```

## Checklist de testes

- [ ] Vitest configurado com `environment: 'jsdom'`
- [ ] `setupFiles` com Pinia global inicializado
- [ ] Testes de composable: estado inicial, mutações, edge cases
- [ ] Testes de componente: render de props, interação, emits
- [ ] Stores mockadas com `createTestingPinia`
- [ ] HTTP mockado com `vi.mock`
- [ ] `beforeEach(() => vi.clearAllMocks())` em todos os `describe`
- [ ] `data-testid` em elementos interativos nos componentes

## Anti-padrões

| Anti-padrão | Correção |
|-------------|----------|
| Testar implementação interna | Testar comportamento observável (DOM, emits, estado) |
| Mocks globais sem `clearAllMocks` | Sempre limpar mocks entre testes |
| Não usar `await` em `trigger` | `trigger` é assíncrono — sempre `await` |
| Store real nos testes | Usar `createTestingPinia` para isolamento |

## Referências canônicas
- https://vitest.dev/
- https://test-utils.vuejs.org/
- https://pinia.vuejs.org/cookbook/testing.html

## Changelog (este arquivo)

- 1.0.0 (24/04/2026): E11 P3 — skill criada. Cobre Vitest 1.x, Vue Test Utils 2.x, @pinia/testing, mocks de HTTP com vi.mock, testes de composables e componentes SFC.

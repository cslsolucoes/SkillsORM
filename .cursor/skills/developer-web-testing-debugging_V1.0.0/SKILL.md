---
name: developer-web-testing-debugging
description: Estratégia de testes e depuração para aplicações VueJS, incluindo error handling global e observabilidade de falhas.
model: sonnet
thinking: extended
category: developer-web
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-web-testing-debugging

## Responsabilidade única

Esta skill cobre a estratégia de testes (unitários com Vitest, componentes com Vue Test Utils, e2e com Playwright/Cypress), depuração de erros runtime, error handling global Vue (`app.config.errorHandler`, `onErrorCaptured`) e integração com ferramentas de observabilidade (Sentry/Bugsnag). Não trata configuração de build/Vite, criação de componentes SFC, roteamento, deploy ou CI/CD — cada um tem sua skill dedicada.

## Versão interna (ficheiro)

| Campo       | Valor |
|-------------|-------|
| **FileVersion** | 1.0.0 |

## When to use

- Definir ou operar testes unitários, de integração e troubleshooting.
- Configurar captura de erros global e por componente.
- Implementar estratégia de observabilidade (Sentry, logging estruturado).
- Depurar falhas runtime, rejeições de Promise não tratadas e erros de componente.

## When NOT to use

- Não usar para definir estrutura de roteamento → use `developer-vuejs-routing-state`
- Não usar para configuração de build ou Vite → use `developer-web-build-tooling-quality`
- Não usar para criar componentes SFC → use `developer-vuejs-components-reactivity`
- Não usar para deploy ou pipeline de CI/CD → use `developer-web-packaging-deployment`
- Não usar para performance e acessibilidade → use `developer-web-performance-accessibility`

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-web-build-tooling-quality` | Confirmar que Vite/Node estão configurados; Vitest depende do Vite |
| `developer-vuejs-components-reactivity` | Componentes precisam existir antes de serem testados |

## Inputs

- Escopo de teste, componentes críticos e cenários de erro.

## Workflow executável

1. Definir suíte mínima por módulo.
2. Configurar captura de erros global e por componente.
3. Executar testes e registrar falhas.
4. Validar correções sem regressão.

## Error handling obrigatório

- `app.config.errorHandler`
- `onErrorCaptured`
- `window.onerror` e `unhandledrejection`
- Integração com Sentry/Bugsnag quando aplicável

## Stack e versões

| Componente | Versão mínima | Notas |
|------------|--------------|-------|
| Vue.JS | 3.4.x | Composition API com `<script setup>` obrigatório |
| Node.js | 18.x | LTS mínimo |
| Vite | 5.x | Base para Vitest |
| Vitest | 1.x | Test runner nativo do Vite; substitui Jest em projetos Vue |
| Vue Test Utils | 2.x | Montagem e interação com componentes Vue em testes |
| Playwright | 1.40.x | E2E cross-browser; preferido para novos projetos |
| Cypress | 13.x | E2E alternativo; preferir Playwright em projetos novos |
| @sentry/vue | 7.x | Observabilidade de erros em produção |

## Dependências npm

```bash
# Vitest + Vue Test Utils (testes unitários e de componente)
npm install --save-dev vitest @vue/test-utils happy-dom

# Cobertura de código com Vitest
npm install --save-dev @vitest/coverage-v8

# UI do Vitest (opcional, visualização no browser)
npm install --save-dev @vitest/ui

# Playwright (e2e)
npm install --save-dev @playwright/test
npx playwright install

# Sentry (observabilidade em produção)
npm install @sentry/vue
```

## Checklist Web/Vue.JS

- [ ] Componente SFC válido (.vue com template, script setup, style scoped)
- [ ] Sem dependência circular entre componentes
- [ ] Props tipadas (defineProps<{}>() com TypeScript ou validação explícita)
- [ ] Loading state, error boundary e empty state tratados
- [ ] Acessibilidade básica: aria-label, navegação por teclado, contraste WCAG AA
- [ ] `app.config.errorHandler` configurado na entrada da aplicação (`main.ts`)
- [ ] `window.addEventListener('unhandledrejection', ...)` registrado
- [ ] Fluxos críticos com cobertura mínima de teste (happy path + erro principal)
- [ ] Erros assíncronos tratados — sem Promises sem `.catch()` ou `try/catch`
- [ ] Logs de erro sem dados pessoais sensíveis (PII, tokens, senhas)

## Exemplo mínimo funcional

```vue
<!-- src/components/UserCard.vue — componente a ser testado -->
<script setup lang="ts">
import { ref, onErrorCaptured } from 'vue'

interface Props {
  userId: string
}

const props = defineProps<Props>()
const error = ref<string | null>(null)

onErrorCaptured((err) => {
  error.value = 'Falha ao carregar dados do usuário.'
  console.error('[UserCard] Erro capturado:', err)
  return false // impede propagação
})
</script>

<template>
  <div role="region" aria-label="Cartão do usuário">
    <p v-if="error" role="alert">{{ error }}</p>
    <slot v-else />
  </div>
</template>

<style scoped>
[role="alert"] { color: red; }
</style>
```

```ts
// src/main.ts — error handler global
import { createApp } from 'vue'
import App from './App.vue'
import { router } from './router'

const app = createApp(App)
app.use(router)

app.config.errorHandler = (err, instance, info) => {
  console.error('[Vue errorHandler]', { err, info })
  // Enviar para Sentry/Bugsnag em produção
}

window.addEventListener('unhandledrejection', (event) => {
  console.error('[unhandledrejection]', event.reason)
})

app.mount('#app')
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| `console.log` com dados de usuário em produção | Vaza PII (e-mail, CPF, token) em logs do browser e ferramentas de monitoramento | Usar variável `import.meta.env.DEV` para guardar logs de debug; mascarar dados sensíveis |
| Promises sem `.catch()` ou `await` sem `try/catch` | Erros silenciosos; `unhandledrejection` dispara mas sem contexto | Sempre encadear `.catch()` ou envolver `await` em `try/catch` com log estruturado |
| Testes acoplados a implementação interna | Testes quebram em refatorações sem mudança de comportamento | Testar pela interface pública (props, emits, DOM renderizado), não por detalhes internos |
| Sem `app.config.errorHandler` em produção | Erros de componente são silenciados; falhas chegam ao usuário sem diagnóstico | Configurar handler global no `main.ts` com envio para observabilidade |
| Testar com `mount` quando `shallowMount` é suficiente | Dependências de filhos causam falhas por contexto ausente | Usar `shallowMount` para testes unitários de componente; `mount` apenas para testes de integração |

## Métricas de sucesso

- Cobertura de linhas >= 80% nos módulos críticos (verificado via `@vitest/coverage-v8`)
- Zero Promises não tratadas detectadas em `npm run dev` ou `npm run build`
- `app.config.errorHandler` configurado e testado em staging antes de ir para produção
- Testes de e2e cobrindo os 3 fluxos principais da aplicação (happy path)

## Responsável principal

| Papel | Quem |
|-------|------|
| Estratégia de testes e cobertura | Tech Lead / QA Lead |
| Implementação de testes unitários | Desenvolvedor Frontend |
| Configuração de observabilidade | DevOps / SRE |

## Avaliação de risco e confirmação

- Mudança de política global de erro/telemetria em produção exige confirmação.

## Referências canônicas

- https://vuejs.org/guide/introduction.html
- https://vitest.dev/
- https://test-utils.vuejs.org/
- https://playwright.dev/

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `JS-testing-and-debugging-web`; novo prefixo canônico `developer-web`. Conteúdo idêntico ao V1.1.0 de origem; cross-references atualizadas para prefixo `developer-*`.

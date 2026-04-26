---
name: developer-web-nodejs-api-middleware
description: Runtime NodeJS e padrões de integração HTTP/API para aplicações VueJS, incluindo Axios, interceptors e cancellation.
model: sonnet
thinking: normal
category: developer-web
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-web-nodejs-api-middleware

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## Responsabilidade única

Esta skill define os padrões de integração HTTP/API para aplicações VueJS, incluindo configuração de clientes Axios, interceptors de autenticação e erro, e padrões de cancellation com `AbortController`. Ela cobre também o uso de NodeJS como runtime de tooling e scripts de suporte. O escopo é a camada de comunicação entre frontend e backend — não a lógica de componentes visuais nem a arquitetura de estado.

## When to use

- Definir padrões de integração com backend e runtime NodeJS para tooling/scripts.
- Configurar cliente Axios centralizado com interceptors de auth e erro.
- Implementar composable `useApi()` para gerenciamento de loading/error/data.
- Tratar cancellation de requisições ao desmontar componentes.

## When NOT to use

- Arquitetura visual de componentes → usar `developer-vuejs-components-reactivity`.
- Estado global (Pinia stores) → usar `developer-vuejs-routing-state`.
- Empacotamento e deploy → usar `developer-web-packaging-deployment`.
- Testes de integração de API → usar `JS-testing-and-debugging-web`.
- Documentação e governança → usar `documentation-general_rules`.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|----------------------|
| `JS-VueJS-orchestrator` | Sempre — para garantir contexto completo do kit |
| `developer-vuejs-routing-state` | Quando a API alimenta stores Pinia |
| `developer-web-build-tooling-quality` | Para garantir que Vite está configurado antes de instalar pacotes |

## Inputs

- Endpoints de API, estratégia de autenticação e requisitos de timeout/retry.

## Workflow executável

1. Definir `config.js` centralizado.
2. Criar client HTTP (`axios.create`).
3. Configurar interceptors de request/response.
4. Implementar cancellation e retry para GET idempotente.

## Padrões HTTP obrigatórios

- Axios instance em `src/services/api.js`.
- Composable `useApi()` para loading/error/data.
- `AbortController` para cancelamento ao desmontar.

## Stack e versões

| Componente | Versão mínima | Notas |
|------------|:---:|-------|
| Vue.JS | 3.x | Composition API com `<script setup>` obrigatório |
| Node.js | 18.x | LTS mínimo |
| Vite | 5.x | Build tool padrão |
| Pinia | 2.x | State management |
| Vue Router | 4.x | Roteamento |

## Dependências npm

```bash
npm install axios
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
import { ref, onMounted, onUnmounted } from 'vue'
import { apiClient } from '@/services/api'

const props = defineProps<{ endpoint: string }>()
const data = ref(null)
const loading = ref(false)
const error = ref<string | null>(null)
let controller: AbortController | null = null

onMounted(async () => {
  controller = new AbortController()
  loading.value = true
  try {
    const response = await apiClient.get(props.endpoint, { signal: controller.signal })
    data.value = response.data
  } catch (e: any) {
    if (e.name !== 'CanceledError') error.value = e.message
  } finally {
    loading.value = false
  }
})

onUnmounted(() => controller?.abort())
</script>

<template>
  <div>
    <p v-if="loading">Carregando...</p>
    <p v-else-if="error" role="alert">{{ error }}</p>
    <pre v-else>{{ data }}</pre>
  </div>
</template>
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Criar múltiplas instâncias Axios por componente | Duplica configuração e dificulta manutenção | Centralizar em `src/services/api.js` e importar onde necessário |
| Hardcodar baseURL e tokens no código | Expõe segredos e dificulta troca de ambiente | Usar variáveis de ambiente (`import.meta.env.VITE_*`) |
| Ignorar cancellation ao desmontar | Causa setState em componente desmontado e memory leaks | Usar `AbortController` e chamar `.abort()` em `onUnmounted` |
| Logar objeto de erro completo (com headers/tokens) | Expõe informações sensíveis em logs | Logar apenas `error.message` e código HTTP |

## Métricas de sucesso

- Zero instâncias Axios criadas fora de `src/services/api.js` no codebase.
- 100% das requisições com possibilidade de cancellation implementam `AbortController`.
- Interceptors de 401/403/500 presentes e testados com ao menos um caso de uso coberto por teste.

## Responsável principal

| Papel | Quem |
|-------|------|
| Mantenedor da skill | Tech Lead Web |
| Revisor de segurança de API | Arquiteto / Security Lead |

## Referências canônicas

- https://nodejs.org/docs/latest/api/
- https://axios-http.com/

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `JS-NodeJS-runtime-and-apis`; novo prefixo canônico `developer-web`. Conteúdo V2 preservado (FileVersion 1.1.0 da origem). Referências internas atualizadas para nomes canônicos.

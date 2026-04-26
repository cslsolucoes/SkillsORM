---
name: developer-web-performance-accessibility
description: Performance, acessibilidade e prevenção de memory leaks em SPA VueJS.
model: sonnet
thinking: extended
category: developer-web
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-web-performance-accessibility

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## Responsabilidade única

Esta skill otimiza performance de SPAs VueJS (Core Web Vitals: LCP, CLS, INP) e garante conformidade de acessibilidade (WCAG AA). Ela também cobre a prevenção e diagnóstico de memory leaks no ciclo de vida dos componentes, incluindo remoção de listeners, cancelamento de timers e cleanup de watchers. O escopo abrange métricas mensuráveis e correções técnicas — não decisões de design visual ou arquitetura de API.

## When to use
- Melhorar UX, métricas de performance e conformidade de acessibilidade.
- Diagnosticar e corrigir memory leaks em componentes VueJS.
- Aplicar lazy loading, code splitting e otimização de bundle.
- Auditar conformidade WCAG AA em páginas críticas.

## When NOT to use
- Criar contratos de API ou integração HTTP → usar `developer-web-nodejs-api-middleware`.
- Arquitetura de componentes → usar `developer-vuejs-components-reactivity`.
- Deploy e publicação → usar `developer-web-packaging-deployment`.
- Testes automatizados de performance → usar `developer-web-testing-debugging`.
- Governança e changelog → usar `developer-web-documentation-governance`.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|----------------------|
| `developer-vuejs-master-orchestrator` | Sempre — para garantir contexto completo do kit |
| `developer-vuejs-components-reactivity` | Antes de otimizar componentes individuais |
| `developer-web-build-tooling-quality` | Para configurar code splitting e tree-shaking no Vite |

## Inputs
- Páginas críticas, métricas alvo e requisitos WCAG.

## Workflow executável
1. Definir métricas críticas (LCP/CLS/INP).
2. Otimizar carregamento e render.
3. Aplicar checklist de a11y.
4. Verificar memory leaks no ciclo de vida.

## Cobertura de memory leak
- Listeners removidos em `onUnmounted`.
- Timers cancelados.
- Cleanup de watchers/composables.
- Heap snapshots com DevTools.

## Stack e versões

| Componente | Versão mínima | Notas |
|------------|:---:|-------|
| Vue.JS | 3.x | Composition API com `<script setup>` obrigatório |
| Node.js | 18.x | LTS mínimo |
| Vite | 5.x | Build tool padrão — suporta code splitting nativo |
| Pinia | 2.x | State management |
| Vue Router | 4.x | Roteamento com lazy loading de rotas |

## Dependências npm

```bash
npm install vue @vitejs/plugin-vue
npm run dev
npm run build
```

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

const props = defineProps<{ intervalMs?: number }>()
const count = ref(0)
let timerId: ReturnType<typeof setInterval> | null = null

onMounted(() => {
  timerId = setInterval(() => {
    count.value++
  }, props.intervalMs ?? 1000)
})

onUnmounted(() => {
  // Previne memory leak: timer cancelado ao desmontar
  if (timerId !== null) clearInterval(timerId)
})
</script>

<template>
  <div aria-label="Contador de performance" aria-live="polite">
    Ticks: {{ count }}
  </div>
</template>

<style scoped>
div { font-variant-numeric: tabular-nums; }
</style>
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Não remover `addEventListener` em `onUnmounted` | Acumula handlers e causa memory leaks | Sempre parear `addEventListener` com `removeEventListener` em `onUnmounted` |
| Importar biblioteca inteira quando apenas uma função é usada | Aumenta bundle size desnecessariamente | Usar imports nomeados e verificar suporte a tree-shaking |
| `aria-label` ausente em elementos interativos | Inacessível para leitores de tela | Adicionar `aria-label` ou `aria-labelledby` em todos os elementos interativos |
| Renderizar listas longas sem virtualização | Degrada FPS e aumenta tempo de layout | Usar `vue-virtual-scroller` ou paginação para listas > 200 itens |

## Métricas de sucesso

- LCP abaixo de 2,5s e CLS abaixo de 0,1 nas páginas críticas medidas via Lighthouse.
- Zero memory leaks detectados por heap snapshot após 10 ciclos de mount/unmount em componentes críticos.
- 100% dos elementos interativos com `aria-label` ou texto visível associado (auditoria axe-core sem erros críticos).

## Responsável principal

| Papel | Quem |
|-------|------|
| Mantenedor da skill | Tech Lead Web |
| Revisor de acessibilidade | UX Designer / Especialista a11y |

## Avaliação de risco e confirmação
- Otimizações que alterem comportamento funcional visível devem ser confirmadas.

## Referências canônicas
- https://web.dev/
- https://www.w3.org/WAI/WCAG21/quickref/

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `JS-performance-and-accessibility-web`; novo prefixo canônico `developer-web`. Conteúdo idêntico ao V1.1.0 de origem; cross-references atualizadas para prefixo `developer-*`.
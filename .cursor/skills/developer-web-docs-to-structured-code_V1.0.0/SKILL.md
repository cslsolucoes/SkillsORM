---
name: developer-web-docs-to-structured-code
description: Converte documentação funcional/técnica em implementação estruturada VueJS/NodeJS com rastreabilidade completa.
model: sonnet
thinking: extended
category: developer-web
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-web-docs-to-structured-code

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## Responsabilidade única

Esta skill transforma documentação funcional ou técnica existente em implementação estruturada para VueJS/NodeJS, garantindo rastreabilidade bidirecional entre requisito e código. Ela cobre o ciclo completo: inventariar a documentação, extrair requisitos, mapear para artefatos de código e executar com validação de build. Destina-se a cenários onde existe documentação suficiente para derivar uma implementação confiável — nunca para codificação sem base documental.

## When to use
- Implementar feature/módulo a partir de documentação existente.
- Traduzir regras de negócio documentadas em componentes, rotas, stores ou services.
- Gerar plano incremental de implementação a partir de especificação técnica.
- Auditar cobertura: verificar se toda a documentação foi implementada.

## When NOT to use
- Sem documentação mínima válida → solicitar documentação antes de prosseguir.
- Governança e changelog de artefatos → usar `developer-web-documentation-governance`.
- Troubleshooting de runtime ou APIs → usar `developer-web-nodejs-api-middleware`.
- Performance e acessibilidade → usar `developer-web-performance-accessibility`.
- Apenas empacotamento/deploy → usar `developer-web-packaging-deployment`.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|----------------------|
| `developer-vuejs-master-orchestrator` | Sempre — para garantir contexto completo do kit |
| `developer-vuejs-components-reactivity` | Antes de mapear features para componentes |
| `developer-vuejs-routing-state` | Quando feature envolve rotas ou estado global |
| `developer-web-nodejs-api-middleware` | Quando feature requer integração com API/backend |

## Inputs
- Escopo funcional.
- Documentação canônica de arquitetura/regras.
- Restrições técnicas e critérios de aceite.

## Workflow executável
1. Inventariar documentação de entrada.
2. Extrair requisitos técnicos e critérios de aceite.
3. Mapear para componentes, rotas, stores, services e testes.
4. Gerar plano incremental de implementação.
5. Executar com validação (`npm run dev` e `npm run build`).

## Saídas obrigatórias
- Especificação técnica derivada da documentação.
- Mapa de implementação por módulo.
- Plano incremental com checkpoints.
- Relatório de lacunas documentais.

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
npm install vue pinia vue-router @vitejs/plugin-vue
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
// Componente gerado a partir de requisito RQ-001: exibir lista de itens rastreada
import { ref, onMounted } from 'vue'

const props = defineProps<{ sourceRequirement: string }>()
const items = ref<string[]>([])
const loading = ref(false)
const error = ref<string | null>(null)

onMounted(async () => {
  loading.value = true
  try {
    // Implementação derivada de: props.sourceRequirement
    items.value = ['item-1', 'item-2']
  } catch (e) {
    error.value = 'Falha ao carregar itens'
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div aria-label="Lista de itens">
    <p v-if="loading">Carregando...</p>
    <p v-else-if="error" role="alert">{{ error }}</p>
    <ul v-else>
      <li v-for="item in items" :key="item">{{ item }}</li>
    </ul>
  </div>
</template>
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Implementar sem documentação de entrada | Gera código sem rastreabilidade e dificulta manutenção | Exigir ao menos especificação mínima antes de iniciar |
| Mapear um único componente monolítico para toda a feature | Viola separação de responsabilidades e dificulta testes | Decompor em componentes menores por responsabilidade |
| Ignorar lacunas documentais e avançar | Cria implementação parcial ou incorreta | Registrar lacunas no relatório de saída e obter confirmação |
| Rastreabilidade apenas comentada no código | Não auditável sistematicamente | Manter mapa explícito doc→código como artefato de saída |

## Métricas de sucesso

- 100% dos requisitos mapeados têm ao menos um artefato de código correspondente identificado.
- Build `npm run build` executado sem erros ao final de cada checkpoint incremental.
- Relatório de lacunas documentais produzido com zero lacunas críticas não resolvidas antes do merge.

## Responsável principal

| Papel | Quem |
|-------|------|
| Mantenedor da skill | Tech Lead Web |
| Revisor de rastreabilidade | Analista de Requisitos / Arquiteto |

## Avaliação de risco e confirmação
- Se houver lacuna documental crítica ou impacto transversal, parar e pedir confirmação.

## Referências canônicas
- https://vuejs.org/guide/quick-start.html
- https://nodejs.org/docs/latest/api/

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `JS-documentation-to-structured-code-web`; novo prefixo canônico `developer-web`. Conteúdo idêntico ao V1.1.0 de origem; cross-references atualizadas para prefixo `developer-*`.
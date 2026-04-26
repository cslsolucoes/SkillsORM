---
name: developer-vuejs-master-orchestrator
description: Orquestra skills do kit VueJS/NodeJS por cenário, garantindo ordem de execução, risco e evidências de qualidade.
model: sonnet
thinking: extended
category: developer-web
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-vuejs-master-orchestrator

## Responsabilidade única

Esta skill é o ponto de entrada para tarefas multi-etapa no ecossistema VueJS/NodeJS. Ela classifica o cenário, seleciona e ordena as skills `developer-vuejs-*` e `developer-web-*` necessárias, executa a sequência com checkpoints de qualidade e consolida evidências. Não implementa funcionalidades diretamente — delega para as skills especializadas. Não deve ser usada em tarefas simples que envolvam apenas uma skill.

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |

## When to use

- Tarefas multi-etapa no kit VueJS/NodeJS.
- Quando o escopo atravessa duas ou mais skills `developer-vuejs-*`/`developer-web-*`.
- Onboarding de novo projeto Vue (setup completo).
- Refatoração ampla que afeta linguagem, build, testes e deploy simultaneamente.

## When NOT to use

- Não usar para tarefa pequena de uma única skill — chamar a skill diretamente.
- Não usar para decisões de linguagem isoladas → use `developer-vuejs-language-core`
- Não usar para criar um componente específico → use `developer-vuejs-components-reactivity`
- Não usar para configurar somente o Vite → use `developer-web-build-tooling-quality`
- Não usar para escrever testes específicos → use `developer-web-testing-debugging`
- Não usar para documentação apenas → use `developer-web-documentation-governance`

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|----------------------|
| Nenhuma obrigatória | O orquestrador é o ponto de entrada; ele mesmo define a sequência |

## Inputs

- Objetivo, escopo, restrições e critérios de aceite.

## Workflow executável

1. Classificar cenário (linguagem, arquitetura, build, testes, deploy, docs->code).
2. Selecionar skills necessárias.
3. Executar sequência com checkpoints.
4. Consolidar evidências e fechamento.

## Matriz de roteamento

| Cenário | Skills acionadas (ordem) |
|---------|--------------------------|
| Novo projeto Vue do zero | `developer-web-build-tooling-quality` → `developer-vuejs-language-core` → `developer-vuejs-components-reactivity` → `developer-vuejs-routing-state` |
| Feature nova com rota + store + componente | `developer-vuejs-routing-state` → `developer-vuejs-components-reactivity` |
| Cobertura de testes | `developer-web-testing-debugging` |
| CI/CD e deploy | `developer-web-packaging-deployment` |
| Performance e acessibilidade | `developer-web-performance-accessibility` |
| Documentação e governança | `developer-web-documentation-governance` |
| Docs para código estruturado | `developer-web-docs-to-structured-code` |
| Runtime e APIs NodeJS | `developer-web-nodejs-api-middleware` |

Skills disponíveis no kit:

- `developer-vuejs-language-core`
- `developer-vuejs-components-reactivity`
- `developer-vuejs-routing-state`
- `developer-web-nodejs-api-middleware`
- `developer-web-build-tooling-quality`
- `developer-web-testing-debugging`
- `developer-web-performance-accessibility`
- `developer-web-packaging-deployment`
- `developer-web-documentation-governance`
- `developer-web-docs-to-structured-code`

## Stack e versões

| Componente | Versão mínima | Notas |
|------------|--------------|-------|
| Vue.JS | 3.4.x | Composition API com `<script setup>` obrigatório |
| Node.js | 18.x | LTS mínimo; recomendado 20 LTS |
| Vite | 5.x | Build tool padrão para SPA |
| Pinia | 2.x | State management |
| Vue Router | 4.x | Roteamento declarativo |
| npm | 9.x | Gerenciador de pacotes padrão |

## Dependências npm

```bash
# Verificar versões do ambiente antes de orquestrar
node --version   # >= 18.x
npm --version    # >= 9.x
npx vue --version  # >= 3.4.x

# Criar projeto base (usado no cenário de novo projeto)
npm create vue@latest
```

## Checklist Web/Vue.JS

- [ ] Componente SFC válido (.vue com template, script setup, style scoped)
- [ ] Sem dependência circular entre componentes
- [ ] Props tipadas (defineProps<{}>() com TypeScript ou validação explícita)
- [ ] Loading state, error boundary e empty state tratados
- [ ] Acessibilidade básica: aria-label, navegação por teclado, contraste WCAG AA
- [ ] Sequência de skills executada na ordem correta por dependência
- [ ] Evidência de `npm run dev` e `npm run build` coletada ao final
- [ ] Risco avaliado antes de cada ação impactante (ações destrutivas confirmadas)
- [ ] Checkpoints de qualidade registrados entre cada skill executada

## Exemplo mínimo funcional

```vue
<!-- OrquestradorDemo.vue — mostra como o orquestrador expõe estado de execução -->
<script setup lang="ts">
import { ref, computed } from 'vue'

type SkillStatus = 'pending' | 'running' | 'done' | 'error'

interface SkillStep {
  name: string
  status: SkillStatus
}

const steps = ref<SkillStep[]>([
  { name: 'developer-web-build-tooling-quality', status: 'pending' },
  { name: 'developer-vuejs-language-core', status: 'pending' },
  { name: 'developer-vuejs-components-reactivity', status: 'pending' },
  { name: 'developer-vuejs-routing-state', status: 'pending' },
])

const allDone = computed(() => steps.value.every(s => s.status === 'done'))

function markDone(skillName: string) {
  const step = steps.value.find(s => s.name === skillName)
  if (step) step.status = 'done'
}
</script>

<template>
  <section aria-label="Progresso de execução das skills">
    <h2>Orquestrador — Novo Projeto Vue</h2>
    <ol>
      <li
        v-for="step in steps"
        :key="step.name"
        :aria-current="step.status === 'running' ? 'step' : undefined"
      >
        <span :class="`status-${step.status}`">{{ step.name }}</span>
        <span>{{ step.status }}</span>
      </li>
    </ol>
    <p v-if="allDone" role="status">Todas as skills concluídas.</p>
  </section>
</template>

<style scoped>
.status-done { color: green; }
.status-error { color: red; }
.status-running { font-weight: bold; }
</style>
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Invocar o orquestrador para tarefa de uma única skill | Overhead desnecessário, contexto desperdiçado | Chamar a skill específica diretamente |
| Executar skills em paralelo sem verificar dependências | Skill B pode falhar porque Skill A ainda não configurou o ambiente | Seguir a matriz de roteamento em sequência |
| Pular checkpoints entre skills | Erros se propagam para as próximas etapas sem visibilidade | Executar `npm run dev`/`npm run build` após cada skill relevante |
| Ações destrutivas sem confirmação prévia | Perda de trabalho, rollback difícil | Sempre apresentar resumo e aguardar aprovação antes de ações irreversíveis |

## Métricas de sucesso

- Todas as skills do plano executadas sem erro bloqueante
- `npm run dev` e `npm run build` bem-sucedidos ao final de cada cenário
- Zero regressões introduzidas entre etapas (checklist por skill validado)
- Evidências de qualidade registradas e apresentadas ao usuário ao final

## Responsável principal

| Papel | Quem |
|-------|------|
| Definição do cenário e escopo | Tech Lead / Arquiteto Frontend |
| Execução da sequência orquestrada | Desenvolvedor Frontend (com assistência do agente) |
| Validação dos checkpoints | Code Reviewer / QA |

## Avaliação de risco e confirmação

- Qualquer ação destrutiva, irreversível ou de alto impacto exige confirmação prévia.

## Referências canônicas

- https://vuejs.org/guide/quick-start.html
- https://nodejs.org/docs/latest/api/

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `developer-vuejs-master-orchestrator`; novo prefixo canônico `developer-vuejs`. Conteúdo idêntico ao V1.1.0 de origem; cross-references e matriz de roteamento atualizados para prefixo `developer-*`.
- 1.1.0 (24/04/2026): Rename E5a — `developer-vuejs-master-orchestrator` -> `developer-vuejs-master-orchestrator`. Motivo: diferenciar master-orchestrator de sub-orchestrators (regra N3 do plano de refactor).

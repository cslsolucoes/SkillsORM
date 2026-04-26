---
name: developer-web-documentation-governance
description: Governança de documentação para o kit web, com changelog, rastreabilidade de fontes e regras de risco.
model: sonnet
thinking: normal
category: developer-web
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-web-documentation-governance

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## Responsabilidade única

Esta skill governa a criação e atualização de documentação de skills e artefatos do kit web JS/Vue.JS. Ela garante rastreabilidade de fontes, integridade de changelogs e aplicação de regras de risco em cada artefato alterado. O escopo é estritamente documental: registrar o quê foi mudado, por quê e com que impacto. Não substitui skills de implementação, teste ou deploy.

## When to use
- Criar/atualizar documentação de skills e artefatos do kit web.
- Registrar changelog após qualquer alteração em skills do kit web.
- Validar rastreabilidade de fontes em documentos do kit.
- Aplicar regras de risco em decisões documentais cross-skill.

## When NOT to use
- Troubleshooting técnico de runtime → usar `developer-web-nodejs-api-middleware`.
- Implementação de componentes ou features → usar `developer-web-docs-to-structured-code`.
- Performance e acessibilidade → usar `developer-web-performance-accessibility`.
- Deploy e empacotamento → usar `developer-web-packaging-deployment`.
- Criação de testes → usar `developer-web-testing-debugging`.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|----------------------|
| `developer-vuejs-master-orchestrator` | Quando a mudança documental afeta fluxo completo do kit |
| `governance-pack-versioning-policy` | Antes de versionar artefatos do pack |
| `governance-pack-checklist-validation` | Para validar integridade do pack após alterações |

## Inputs
- Arquivos alterados, fontes consultadas e escopo da mudança.

## Workflow executável
1. Atualizar docs afetadas.
2. Registrar changelog por arquivo.
3. Atualizar rastreabilidade de fontes -> conclusão.
4. Validar consistência com hub e template web.

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
npm install vite vue @vitejs/plugin-vue
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
// Demonstrar entrada de changelog documentada
const props = defineProps<{ version: string; description: string }>()
</script>

<template>
  <div class="changelog-entry">
    <span class="version">{{ props.version }}</span>
    <span class="description">{{ props.description }}</span>
  </div>
</template>

<style scoped>
.changelog-entry { display: flex; gap: 1rem; }
.version { font-weight: bold; }
</style>
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Atualizar artefato sem registrar changelog | Perde rastreabilidade de evolução | Sempre adicionar entrada de changelog com data e descrição |
| Documentar numa skill o que é responsabilidade de outra | Viola separação de responsabilidades | Redirecionar para a skill correta e criar referência cruzada |
| Omitir fontes consultadas | Impede auditoria e reprodução | Registrar todas as URLs e documentos consultados em "Referências canônicas" |
| Versionar sem seguir política SemVer do pack | Gera inconsistência no manifest | Consultar `governance-pack-versioning-policy` antes de bump |

## Métricas de sucesso

- 100% dos artefatos alterados possuem entrada de changelog com data e descrição.
- Nenhuma skill do kit web sem seção "Avaliação de risco e confirmação" ao final da revisão.
- Rastreabilidade de fontes auditável: ao menos uma URL canônica por decisão técnica registrada.

## Responsável principal

| Papel | Quem |
|-------|------|
| Mantenedor da skill | Tech Lead Web |
| Revisor de governança | Arquiteto do projeto |

## Avaliação de risco e confirmação
- Se a atualização documental alterar política operacional, confirmar antes.

## Referências canônicas
- https://vuejs.org/guide/quick-start.html
- https://nodejs.org/docs/latest/api/
- https://devdocs.io/javascript/

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `JS-documentation-and-governance-web`; novo prefixo canônico `developer-web`. Conteúdo idêntico ao V1.1.0 de origem; cross-references atualizadas para prefixo `developer-*`.
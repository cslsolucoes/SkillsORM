---
name: developer-web-packaging-deployment
description: Empacotamento e deploy de aplicações VueJS com estratégia de release, CSP e checklist operacional.
model: sonnet
thinking: normal
category: developer-web
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-web-packaging-deployment

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## Responsabilidade única

Esta skill cobre o ciclo de empacotamento e deploy de aplicações VueJS/Vite, desde a validação do build final até a publicação em ambiente produtivo com rollback definido. Ela garante que artefatos sejam versionados corretamente, que políticas de segurança (CSP, CORS) estejam aplicadas e que a estratégia de release seja documentada antes de qualquer publicação. O escopo é operacional: preparar, verificar e publicar — não implementar lógica de componentes ou APIs.

## When to use

- Preparar release, artefatos e publicação.
- Validar build antes de envio para ambiente produtivo.
- Definir ou revisar política de cache, headers e CSP.
- Versionar e taggear releases seguindo SemVer.

## When NOT to use

- Detalhes de lógica interna de componentes → usar `developer-vuejs-components-reactivity`.
- Integração com APIs de backend → usar `developer-web-nodejs-api-middleware`.
- Performance e acessibilidade → usar `JS-performance-and-accessibility-web`.
- Criação de testes automatizados → usar `JS-testing-and-debugging-web`.
- Governança e changelog → usar `documentation-general_rules`.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|----------------------|
| `JS-VueJS-orchestrator` | Sempre — para confirmar que o kit está estável antes do deploy |
| `developer-web-build-tooling-quality` | Para garantir configuração de Vite e linting antes do build final |
| `JS-testing-and-debugging-web` | Para confirmar cobertura de testes antes de publicar |

## Inputs

- Ambiente alvo, artefatos e política de publicação.

## Workflow executável

1. Validar build final.
2. Gerar e versionar artefatos.
3. Aplicar checklist de segurança em deploy.
4. Publicar com rollback definido.

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
npm install vite @vitejs/plugin-vue
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
const props = defineProps<{ version: string; environment: string }>()
</script>

<template>
  <div aria-label="Status do deploy">
    <span>Versão: {{ props.version }}</span>
    <span>Ambiente: {{ props.environment }}</span>
  </div>
</template>

<style scoped>
div { display: flex; gap: 1rem; font-family: monospace; }
</style>
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Deploy direto sem `npm run build` validado | Pode publicar artefatos com erros de compilação | Sempre executar e verificar saída de `npm run build` antes de publicar |
| CSP com `unsafe-inline` ou `*` em produção | Abre vetor para XSS | Definir fontes explícitas e revisar com OWASP CSP Cheat Sheet |
| Publicar sem tag de versão | Impossibilita rollback preciso | Taggear com `vX.Y.Z` antes de publicar e registrar no changelog |
| Variáveis de ambiente hardcodadas no Dockerfile/CI | Expõe segredos e dificulta rotação | Usar secrets manager ou variáveis de ambiente do pipeline |

## Métricas de sucesso

- 100% das releases possuem tag `vX.Y.Z` e entrada de changelog antes da publicação.
- Build `npm run build` executado sem warnings de segurança ao final de cada release.
- Plano de rollback documentado e testado para toda publicação em produção.

## Responsável principal

| Papel | Quem |
|-------|------|
| Mantenedor da skill | Tech Lead Web / DevOps |
| Revisor de segurança de deploy | Security Lead / Arquiteto |

## Referências canônicas

- https://vitejs.dev/
- https://owasp.org/

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `JS-packaging-and-deployment-web`; novo prefixo canônico `developer-web`. Conteúdo V2 preservado (FileVersion 1.1.0 da origem). Referências internas atualizadas para nomes canônicos.

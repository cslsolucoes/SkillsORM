---
name: developer-web-build-tooling-quality
description: Build, qualidade e variáveis de ambiente para VueJS/NodeJS com Vite e comandos npm obrigatórios.
model: haiku
thinking: extended
category: developer-web
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-web-build-tooling-quality

## Responsabilidade única

Esta skill cobre a configuração do ambiente de build com Vite, padronização de scripts npm, gestão de variáveis de ambiente (`.env`), configuração de ESLint/Prettier e validação das versões mínimas de Node/npm/Vue/Vite/Pinia/Router. Não trata criação de componentes, roteamento, testes unitários, deploy para produção ou CI/CD — cada um tem sua skill dedicada.

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## When to use

- Setup de build, lint, qualidade e variáveis de ambiente.
- Validar versões mínimas do ambiente antes de iniciar desenvolvimento.
- Configurar `vite.config.js`/`vite.config.ts` com aliases, plugins e base path.
- Padronizar scripts `dev`, `build`, `preview`, `lint` no `package.json`.

## When NOT to use

- Não usar para modelagem de domínio ou lógica de negócio.
- Não usar para criação de componentes SFC → use `developer-vuejs-components-reactivity`
- Não usar para roteamento ou stores → use `developer-vuejs-routing-state`
- Não usar para testes unitários/e2e → use `JS-testing-and-debugging-web`
- Não usar para deploy/CI/CD → use `developer-web-packaging-deployment`
- Não usar para decisão JS vs TypeScript → use `JS-VueJS-language-core`

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|----------------------|
| Nenhuma obrigatória | Esta skill é normalmente a primeira a ser executada em um projeto novo |
| `JS-VueJS-orchestrator` | Se o contexto envolver múltiplas skills, acionar o orquestrador para sequenciar |

## Inputs

- Baseline de versões e padrões de scripts npm.

## Workflow executável

1. Validar versões mínimas (Node/npm/Vue/Vite/Pinia/Router).
2. Configurar `vite.config.js`.
3. Padronizar `.env`/`.env.local`/`.env.production`.
4. Validar `npm run dev` e `npm run build`.

## Baseline de ferramentas

- NodeJS >= 18 LTS (recomendado 20 LTS)
- npm >= 9
- Vue >= 3.4
- Vite >= 5
- Vue Router >= 4
- Pinia >= 2.1

## Stack e versões

| Componente | Versão mínima | Notas |
|------------|--------------|-------|
| Vue.JS | 3.4.x | Composition API com `<script setup>` obrigatório |
| Node.js | 18.x | LTS mínimo; recomendado 20 LTS |
| Vite | 5.x | Build tool padrão para SPA |
| Pinia | 2.1.x | State management |
| Vue Router | 4.x | Roteamento declarativo |
| npm | 9.x | Gerenciador de pacotes padrão |
| ESLint | 8.x | Lint de qualidade |
| Prettier | 3.x | Formatação de código |
| TypeScript | 5.x | Opcional; obrigatório em projetos médios/grandes |

## Dependências npm

```bash
npm create vue@latest
npm create vite@latest my-app -- --template vue-ts
npm install --save-dev eslint eslint-plugin-vue @vue/eslint-config-typescript
npm install --save-dev prettier @vue/eslint-config-prettier
npm install --save-dev vite-plugin-singlefile
npm install --save-dev rollup-plugin-visualizer
```

## Checklist Web/Vue.JS

- [ ] Componente SFC válido (.vue com template, script setup, style scoped)
- [ ] Sem dependência circular entre componentes
- [ ] Props tipadas (defineProps<{}>() com TypeScript ou validação explícita)
- [ ] Loading state, error boundary e empty state tratados
- [ ] Acessibilidade básica: aria-label, navegação por teclado, contraste WCAG AA
- [ ] Scripts `dev`, `build`, `preview` e `lint` presentes no `package.json`
- [ ] `.env.local` listado no `.gitignore`
- [ ] Sem variáveis sensíveis expostas com prefixo `VITE_`
- [ ] Build de produção bem-sucedido sem erros de tipo ou lint bloqueantes
- [ ] Alias `@` configurado apontando para `src/`

## Exemplo mínimo funcional

```ts
// vite.config.ts
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

export default defineConfig({
  plugins: [vue()],
  resolve: { alias: { '@': path.resolve(__dirname, 'src') } },
  base: './',
  build: { target: 'es2020', sourcemap: false },
})
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Segredos em variáveis `VITE_*` | Prefixo `VITE_` expõe a variável no bundle do cliente | Variáveis sensíveis ficam só no servidor |
| `npm run build` sem `vue-tsc --noEmit` antes | Erros de tipo passam despercebidos | Adicionar `vue-tsc --noEmit &&` antes do `vite build` |
| Sem alias `@` para `src/` | Imports relativos frágeis | Configurar `resolve.alias` no `vite.config` |
| `.env.local` commitado no git | Expõe credenciais | Garantir `.env.local` no `.gitignore` |

## Métricas de sucesso

- `npm run build` conclui sem warnings de segurança (CSP/CORS)
- Bundle de vendor separado de código da aplicação
- Zero variáveis sensíveis detectadas no bundle
- `npm run lint` retorna zero erros bloqueantes

## Responsável principal

| Papel | Quem |
|-------|------|
| Configuração do ambiente de build | Tech Lead / DevOps Frontend |
| Manutenção de scripts npm | Desenvolvedor Frontend |
| Auditoria de segurança do bundle | Security Lead / Code Reviewer |

## Referências canônicas

- https://vuejs.org/guide/quick-start.html
- https://vitejs.dev/

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `JS-build-tooling-and-quality`; novo prefixo canônico `developer-web`. Conteúdo V2 preservado (FileVersion 1.1.0 da origem). Referências internas atualizadas para nomes canônicos.

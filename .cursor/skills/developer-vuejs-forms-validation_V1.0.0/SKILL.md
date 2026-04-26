---
name: developer-vuejs-forms-validation
description: Formulários reativos e validação em Vue 3 com VeeValidate + Zod ou Vuelidate. Cobre criação de campos controlados, esquemas de validação, mensagens de erro e submissão assíncrona.
model: sonnet
thinking: extended
category: developer-web
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-vuejs-forms-validation

## Responsabilidade única

Cobre criação de formulários controlados em Vue 3, validação com VeeValidate + Zod (primário) ou Vuelidate (alternativo), feedback de erro por campo, submissão assíncrona e estados de loading/success/error. Não abrange roteamento pós-submit, gerenciamento de estado global, build tooling ou testes.

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## When to use
- Criar formulários com validação em tempo real.
- Implementar esquemas de validação reutilizáveis com Zod.
- Tratar submissão assíncrona (POST/PUT via API) com feedback visual.
- Padronizar mensagens de erro e acessibilidade em formulários.

## When NOT to use
- Não usar para chamadas HTTP avulsas fora de formulário → use `developer-vuejs-api-integration`
- Não usar para gerenciamento de estado global → use `developer-vuejs-routing-state`
- Não usar para configuração de build → use `developer-web-build-tooling-quality`
- Não usar para testes de formulário → use `developer-vuejs-testing`

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|----------------------|
| `developer-vuejs-components-reactivity` | Garantir que SFC e Composition API estão dominados |
| `developer-vuejs-language-core` | Confirmar TypeScript habilitado para tipagem de esquemas |

## Stack de validação

| Biblioteca | Versão | Papel |
|------------|--------|-------|
| VeeValidate | 4.x | Integração de validação com Vue 3 |
| Zod | 3.x | Esquema de validação TypeScript-first |
| @vee-validate/zod | 4.x | Adaptador VeeValidate ↔ Zod |
| Vuelidate | 2.x | Alternativa para projetos sem Zod |

## Instalação

```bash
# Opção A — VeeValidate + Zod (recomendado)
npm install vee-validate @vee-validate/zod zod

# Opção B — Vuelidate
npm install @vuelidate/core @vuelidate/validators
```

## Exemplo mínimo — VeeValidate + Zod

```vue
<script setup lang="ts">
import { useForm } from 'vee-validate'
import { toTypedSchema } from '@vee-validate/zod'
import { z } from 'zod'

// 1. Definir esquema Zod
const schema = toTypedSchema(
  z.object({
    email: z.string().email('E-mail inválido').min(1, 'E-mail obrigatório'),
    senha: z.string().min(8, 'Mínimo 8 caracteres'),
    nome: z.string().min(2, 'Nome obrigatório').max(100),
  })
)

// 2. Inicializar formulário
const { handleSubmit, isSubmitting, errors, defineField } = useForm({
  validationSchema: schema,
  initialValues: { email: '', senha: '', nome: '' },
})

// 3. Campos controlados
const [emailField, emailAttrs] = defineField('email')
const [senhaField, senhaAttrs] = defineField('senha')
const [nomeField, nomeAttrs] = defineField('nome')

// 4. Submit assíncrono
const onSubmit = handleSubmit(async (values) => {
  await api.post('/auth/register', values)
})
</script>

<template>
  <form @submit.prevent="onSubmit" novalidate>
    <div class="field">
      <label for="nome">Nome</label>
      <input
        id="nome"
        v-model="nomeField"
        v-bind="nomeAttrs"
        type="text"
        :aria-invalid="!!errors.nome"
        :aria-describedby="errors.nome ? 'nome-error' : undefined"
      />
      <span v-if="errors.nome" id="nome-error" role="alert" class="error">
        {{ errors.nome }}
      </span>
    </div>

    <div class="field">
      <label for="email">E-mail</label>
      <input
        id="email"
        v-model="emailField"
        v-bind="emailAttrs"
        type="email"
        :aria-invalid="!!errors.email"
        :aria-describedby="errors.email ? 'email-error' : undefined"
      />
      <span v-if="errors.email" id="email-error" role="alert" class="error">
        {{ errors.email }}
      </span>
    </div>

    <div class="field">
      <label for="senha">Senha</label>
      <input
        id="senha"
        v-model="senhaField"
        v-bind="senhaAttrs"
        type="password"
        :aria-invalid="!!errors.senha"
        :aria-describedby="errors.senha ? 'senha-error' : undefined"
      />
      <span v-if="errors.senha" id="senha-error" role="alert" class="error">
        {{ errors.senha }}
      </span>
    </div>

    <button type="submit" :disabled="isSubmitting">
      {{ isSubmitting ? 'Enviando...' : 'Cadastrar' }}
    </button>
  </form>
</template>
```

## Exemplo — Vuelidate (alternativo)

```vue
<script setup lang="ts">
import { reactive } from 'vue'
import { useVuelidate } from '@vuelidate/core'
import { required, email, minLength } from '@vuelidate/validators'

const state = reactive({ email: '', senha: '' })

const rules = {
  email: { required, email },
  senha: { required, minLength: minLength(8) },
}

const v$ = useVuelidate(rules, state)

async function onSubmit() {
  const valid = await v$.value.$validate()
  if (!valid) return
  await api.post('/auth/login', state)
}
</script>

<template>
  <form @submit.prevent="onSubmit">
    <input v-model="state.email" type="email" />
    <span v-if="v$.email.$error">{{ v$.email.$errors[0].$message }}</span>

    <input v-model="state.senha" type="password" />
    <span v-if="v$.senha.$error">{{ v$.senha.$errors[0].$message }}</span>

    <button type="submit">Entrar</button>
  </form>
</template>
```

## Esquema Zod reutilizável (shared)

```ts
// src/schemas/auth.schema.ts
import { z } from 'zod'

export const loginSchema = z.object({
  email: z.string().email('E-mail inválido'),
  senha: z.string().min(8, 'Mínimo 8 caracteres'),
})

export const registerSchema = loginSchema.extend({
  nome: z.string().min(2).max(100),
  confirmarSenha: z.string(),
}).refine((data) => data.senha === data.confirmarSenha, {
  message: 'Senhas não conferem',
  path: ['confirmarSenha'],
})

export type LoginForm = z.infer<typeof loginSchema>
export type RegisterForm = z.infer<typeof registerSchema>
```

## Checklist de formulários

- [ ] Esquema Zod definido e exportado separadamente de `schemas/`
- [ ] `novalidate` no `<form>` (desabilita validação nativa do browser)
- [ ] `aria-invalid` e `aria-describedby` em campos com erro
- [ ] `role="alert"` em mensagens de erro para leitores de tela
- [ ] `isSubmitting` desabilita botão durante POST
- [ ] Campos required explícitos no esquema Zod
- [ ] Mensagens de erro em português e humanizadas
- [ ] Reset de formulário após submit com sucesso

## Anti-padrões

| Anti-padrão | Correção |
|-------------|----------|
| Validar só no submit | Usar modo `'blur'` ou `'input'` no VeeValidate |
| Mensagens genéricas "Campo inválido" | Escrever mensagens específicas no esquema Zod |
| `disabled` no botão antes de dirty | Desabilitar só durante `isSubmitting` |
| Esquema duplicado por formulário | Extrair para `src/schemas/` compartilhado |

## Referências canônicas
- https://vee-validate.logaretm.com/v4/
- https://zod.dev/
- https://vuelidate-next.netlify.app/

## Changelog (este arquivo)

- 1.0.0 (24/04/2026): E11 P3 — skill criada. Cobre VeeValidate 4 + Zod 3 (primário), Vuelidate 2 (alternativo), esquemas reutilizáveis, acessibilidade em formulários.

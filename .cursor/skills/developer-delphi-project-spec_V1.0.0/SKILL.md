---
name: developer-delphi-project-spec
description: >
  Geração automática de documentos de especificação de software (SPEC) por engenharia reversa
  do código-fonte Delphi: atores, RF, RNF, regras de negócio, casos de uso, modelo de dados,
  integrações, restrições técnicas. Bilíngue pt-BR/en-US com marcadores [INFERIDO]/[INFERRED].
  Ativar quando o usuário mencionar: SPEC, especificação de software, specification document,
  documento de requisitos, "crie uma SPEC", "gere a SPEC", "documente o sistema",
  "especificação do projeto", "especificação do módulo", "quero a SPEC do código",
  "gerar especificação", "analise o código e gere a SPEC".
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-project-spec

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Criado** | 2026-04-24 |
| **Família** | Documentation / Spec |

## Responsabilidade única

Ler código-fonte Delphi e produzir SPEC completa, rastreável e acionável por engenharia
reversa — sem entrevistar o usuário. Cobre projeto inteiro ou módulo de negócio (nunca
uma unit ou classe isolada).

## When to use

- Gerar especificação de software a partir de código-fonte Delphi existente
- Documentar sistema para onboarding de equipe, auditoria ou venda
- Produzir SPEC quando não há documentação formal

## When NOT to use

- Criar SPEC de requisitos futuros → `governance-spec-*`
- Auditar qualidade do código → `developer-delphi-project-audit`
- Documentar apenas uma unit isolada → usar comentários internos

---

## §1 — Idioma e template

Detecte o idioma da primeira mensagem do usuário:
- pt-BR (padrão) → `references/spec-template.md` · marcador: `[INFERIDO]`
- en-US → `references/spec-template.en.md` · marcador: `[INFERRED]`

---

## §2 — Protocolo de geração (5 etapas)

### Etapa 1 — SCAN

```
Glob: **/*.pas, **/*.dfm, **/*.dpr, **/*.dproj
```

Identificar: arquivo principal (`.dpr`), forms (`.dfm` + `.pas`), services, repositories,
entities, datamodules.

### Etapa 2 — READ

Leia os arquivos relevantes em ordem de prioridade:
1. Units de domínio (services, repositories, entities)
2. Forms principais
3. DataModules
4. Arquivo `.dpr`

### Etapa 3 — EXTRACT

| Elemento | Como extrair |
|----------|-------------|
| Atores | Forms + permissões no código |
| RF (Requisitos Funcionais) | Métodos públicos, ações de botões, eventos de forms |
| RNF | Tecnologia usada (versão Delphi, BD, SO alvo) |
| Regras de Negócio (RN) | Validações, guards, `if/raise` no código |
| Casos de Uso (UC) | Fluxos de tela e ações principais dos forms |
| Modelo de Dados | Entidades, records, queries, estruturas de BD |
| Integrações | Chamadas HTTP, COM, DLL, WebService |
| Restrições Técnicas | Versão Delphi, BD, plataforma alvo |

Itens não explícitos no código → marcar com `[INFERIDO]` / `[INFERRED]`.

### Etapa 4 — GENERATE

Preencher **todas as seções** do template. Texto de placeholder:
- pt-BR: `"Não identificado no código-fonte."`
- en-US: `"Not identified in source code."`

### Etapa 5 — SAVE + REPORT

Gravar como `SPEC.md` na raiz do projeto. Informar ao usuário:
- Caminho do arquivo gerado
- Seções preenchidas com dados reais vs. `[INFERIDO]`
- Arquivos não analisados (se houver)
- Seções que merecem revisão manual

---

## §3 — Convenções de numeração

```
RF-001, RF-002 ...   Requisitos Funcionais
RNF-001, RNF-002 ... Requisitos Não Funcionais
RN-001, RN-002 ...   Regras de Negócio
UC-001, UC-002 ...   Casos de Uso
US-001, US-002 ...   User Stories
```

---

## §4 — Checklist de qualidade — SPEC

- [ ] Idioma detectado e template correto carregado
- [ ] SCAN completo (`.pas`, `.dfm`, `.dpr`)
- [ ] Todas as seções do template preenchidas (sem seções em branco)
- [ ] Items inferidos marcados com `[INFERIDO]`/`[INFERRED]`
- [ ] `SPEC.md` gravado na raiz do projeto
- [ ] Relatório de cobertura enviado ao usuário

## Referências cruzadas

- `developer-delphi-project-audit` — laudo técnico + code smells
- `governance-spec-*` — SPEC de requisitos futuros (não engenharia reversa)

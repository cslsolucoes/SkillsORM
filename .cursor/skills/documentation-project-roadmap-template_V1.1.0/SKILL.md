---
name: documentation-project-roadmap-template
description: Template genérico e portátil para roadmap estratégico de projecto — visão, objectivos, fases detalhadas com entregáveis e critérios de aceite, hierarquia de módulos/níveis com interfaces e implementações, DDL/DML quando aplicável, checklist por módulo, backlog priorizado, critérios de qualidade, exemplos de uso e referências a projectos-fonte. Inclui placeholders {PLACEHOLDER} e comentários EXAMPLE (ORM) para orientar o preenchimento. Usar como ponto de partida ao criar o roadmap de qualquer novo projecto.
model: sonnet
thinking: minimal
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation — Project Roadmap Template

## Responsabilidade única

Esta skill fornece o template portátil para criar o roadmap estratégico de qualquer projeto, cobrindo visão, objetivos, hierarquia de módulos, fases com entregáveis e critérios de aceite, backlog priorizado e critérios de qualidade. Ela não planeja o roadmap de forma autônoma — entrega a estrutura com placeholders e exemplos ORM para que o agente ou o Tech Lead preencham com decisões reais do projeto. O escopo termina na geração do documento esqueleto: análise de viabilidade, estimativas de prazo e priorização são decisões humanas a inserir nos placeholders. Cada seção é marcada como `[PORTÁTIL]` ou `[ESPECÍFICO DO PROJETO]` para facilitar a distinção entre estrutura genérica e conteúdo específico.

Template portátil para criação de roadmap estratégico de projecto. Contém a estrutura completa com placeholders e exemplos ORM como referência.

## When to use

- Ao iniciar um projecto novo e precisar de um roadmap estruturado.
- Ao padronizar o roadmap de um projecto existente.
- Como referência para as secções obrigatórias de um roadmap.

## When NOT to use

- Quando o objetivo for documentar fundamentos e nomenclatura — use `documentation-project-fundamentals-template`.
- Quando o objetivo for documentar a estrutura de arquivos — use `documentation-project-structure-template`.
- Quando o projeto já possui roadmap e o objetivo for registrar progresso — use `documentation-project-update`.
- Quando o objetivo for criar o roadmap a partir de documentação existente (reverse engineering) — use `documentation-roadmap-from-docs`.
- Quando o objetivo for documentar exemplos de uso — use `documentation-project-examples-template`.

## Estrutura do template

O template contém 10 secções principais:

1. **Visão e objectivos estratégicos** — visão, objectivos numerados, princípios de design, diagrama de fases (Mermaid)
2. **Visão geral e projectos de referência** — tabela de repositórios-fonte
3. **Hierarquia de módulos / níveis** — dependências, interfaces e implementações
4. **Status de implementação** — checklists por grupo de módulos
5. **DDL e operações de escrita** — criação, DML, restrições (quando aplicável)
6. **Fases detalhadas** — objectivo, entregáveis e critérios de aceite por fase
7. **Backlog e pendências** — alta, média e baixa prioridade
8. **Critérios gerais de qualidade** — cobertura de testes, documentação, exceções, API, recursos
9. **Referência de arquivos** — ficheiros relevantes nos projectos-fonte
10. **Exemplo de uso básico** — snippet e modos de uso

Cada secção está marcada como `[PORTÁTIL]` ou `[ESPECÍFICO DO PROJETO]`.

## Dependências (skills prévias)

| Skill | Quando executar antes |
| --- | --- |
| `documentation-project-fundamentals-template` | Quando o projeto ainda não tem fundamentos documentados — definir identidade e stack antes de criar o roadmap |
| `documentation-project-scan` | Quando o status de implementação real dos módulos não for conhecido — executar scan para obter estado atual |

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| --- | --- | --- |
| Criar roadmap sem definir critérios de aceite por fase | Impossibilita verificar conclusão de fases; backlog acumula sem critério de "pronto" | Cada fase deve ter pelo menos 2 critérios de aceite mensuráveis |
| Preencher estimativas de prazo como parte da geração do template | Prazos requerem contexto de equipe e capacidade — o agente não tem essa informação | Deixar placeholders de prazo explícitos para preenchimento humano |
| Omitir seção de backlog por "não ter pendências ainda" | O template perde utilidade ao longo do ciclo de vida do projeto | Incluir a seção vazia com estrutura pronta; preencher conforme surgem itens |
| Misturar roadmap com exemplos de código no mesmo documento | Aumenta o tamanho do documento sem agregar clareza estratégica | Manter exemplos de código em `documentation-project-examples-template` |

## Métricas de sucesso

- O documento gerado contém as 10 seções do template com seções corretamente marcadas como `[PORTÁTIL]` ou `[ESPECÍFICO DO PROJETO]`.
- Cada fase detalhada possui pelo menos um entregável concreto e um critério de aceite verificável (mesmo que em placeholder).
- Nenhuma estimativa de prazo ou decisão estratégica foi inventada pelo agente — placeholders estão explícitos.

## Responsável principal

| Papel | Quem |
| --- | --- |
| Agent executor | `doc-agent-orchestrator` |
| Revisão humana | Tech Lead / Arquiteto responsável pelo planejamento |
| Aprovação final | Responsável técnico e/ou Product Owner do projeto |

---

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.1.0 |

## Changelog (este arquivo)

- 1.1.0 (09/04/2026): Migração V2 — adicionadas seções Responsabilidade única, When NOT to use, Dependências, Anti-padrões, Métricas de sucesso, Responsável principal; frontmatter expandido com thinking: minimal e category: documentation.
- 1.0.0 (04/04/2026): Versão inicial — conteúdo portátil extraído de `project-roadmap_V1.0.1.mdc` durante migração Fase 1.

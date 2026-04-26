---
name: documentation-project-fundamentals-template
description: Template genérico e portátil para fundamentos do projecto — identidade e stack principal, convenção de changelog (projecto, por arquivo e por documento), nomenclatura completa de tipos/interfaces/métodos/variáveis/records/enums/constantes de erro, hierarquia de exceções com faixas de código por módulo, padrões de design obrigatórios (Fluent, Factory, gestão de recursos, responsabilidade única, separação UI/lógica), diretivas de compilação, subagents e skills de referência, e regras rápidas para o agente. Inclui placeholders {PLACEHOLDER} e comentários EXAMPLE (ORM).
model: haiku
thinking: minimal
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation — Project Fundamentals Template

## Responsabilidade única

Esta skill fornece o template portátil para documentar os fundamentos de qualquer projeto — identidade, stack, nomenclatura, exceções e padrões de design obrigatórios. Ela não preenche o conteúdo final; entrega a estrutura com placeholders e exemplos ORM para orientar o preenchimento pelo agente ou pelo desenvolvedor. O escopo termina na geração do documento esqueleto: validação de conformidade, análise de código-fonte e geração de roadmap são responsabilidades de outras skills. A portabilidade é um princípio central — as seções são agnósticas de framework e podem ser aplicadas a qualquer projeto Delphi/FPC ou outra stack.

Template portátil para documentação dos fundamentos de um projecto (identidade, nomenclatura, padrões).

## When to use

- Ao iniciar um projecto novo e definir as convenções base.
- Ao padronizar a documentação de fundamentos.
- Como referência para os padrões obrigatórios de um projecto.

## When NOT to use

- Quando o projeto já possui documentação de fundamentos e o objetivo for apenas atualizar — use `documentation-project-update` para edições incrementais.
- Quando o objetivo for documentar a estrutura de arquivos e diretórios — use `documentation-project-structure-template`.
- Quando o objetivo for criar o roadmap estratégico do projeto — use `documentation-project-roadmap-template`.
- Quando o objetivo for documentar exemplos de uso — use `documentation-project-examples-template`.
- Quando for necessário primeiro escanear o projeto antes de documentar — execute `documentation-project-scan` antes desta skill.

## Estrutura do template

O template contém as seguintes secções:

1. **Uso do Skill em todas as interações** — skill expert de referência
2. **Agent Skills** — regras como directrizes persistentes
3. **LEGENDA** — status e prioridade (portátil)
4. **Identidade do projecto** — descrição, stack, entry point, API, commons
5. **Changelog** — do projecto, por arquivo de código, por documento .md
6. **Nomenclatura** — tipos/interfaces, métodos, variáveis/campos, records/enums/constantes
7. **Exceções / tratamento de erros** — classe base, hierarquia, faixas de código
8. **Padrões de design obrigatórios** — Fluent, Factory, gestão de recursos, responsabilidade única, separação UI/lógica, comentários
9. **Diretivas de compilação** — engines, módulos opcionais, arquivo de diretivas
10. **Subagents e Skills de referência** — tabela skill/path/quando
11. **Regras rápidas para o agente** — checklist operacional

## Dependências (skills prévias)

Nenhuma dependência obrigatória.

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| --- | --- | --- |
| Preencher placeholders com valores fictícios durante a geração do template | Contamina o documento com dados incorretos que precisarão ser removidos | Entregar o template com placeholders explícitos `{PLACEHOLDER}` e instruções de preenchimento |
| Usar este template para um projeto que já tem fundamentos documentados | Sobrescreve convenções existentes e introduz inconsistências | Usar `documentation-project-update` para edições incrementais em projetos existentes |
| Omitir seções de nomenclatura por "serem óbvias" | Gera inconsistências de naming conforme o projeto cresce | Incluir todas as seções mesmo que inicialmente esparsas; completar incrementalmente |

## Métricas de sucesso

- O documento gerado contém todas as 11 seções da estrutura do template, com placeholders identificáveis para todas as informações específicas do projeto.
- Nenhum valor fictício ou inventado foi inserido nos placeholders durante a geração.
- O arquivo segue o naming convention e está no diretório de documentação canônico do projeto.

## Responsável principal

| Papel | Quem |
| --- | --- |
| Agent executor | `doc-agent-orchestrator` |
| Revisão humana | Tech Lead / Arquiteto responsável pelas convenções do projeto |
| Aprovação final | Responsável técnico do projeto |

---

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.1.0 |

## Changelog (este arquivo)

- 1.1.0 (09/04/2026): Migração V2 — adicionadas seções Responsabilidade única, When NOT to use, Dependências, Anti-padrões, Métricas de sucesso, Responsável principal; frontmatter expandido com thinking: minimal e category: documentation.
- 1.0.0 (04/04/2026): Versão inicial — conteúdo portátil extraído de `project-fundamentos_V1.0.1.mdc` durante migração Fase 1.

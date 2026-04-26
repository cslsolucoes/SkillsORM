---
name: documentation-project-examples-template
description: Template genérico e portátil para exemplos de uso do projecto — padrão central de uso com múltiplas variantes (pool, conexão directa, injecção de dependências), cenários detalhados por componente (configuração, execução, metadados), módulos ou componentes especiais com UI de teste, composição do ecossistema (wiring completo entre módulos), anti-padrões com alternativas correctas, e apêndice com scripts e dados de apoio. Inclui placeholders {PLACEHOLDER} e comentários EXAMPLE (ORM).
model: haiku
thinking: minimal
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation — Project Examples Template

## Responsabilidade única

Esta skill fornece o template portátil para documentar exemplos de uso de qualquer projeto, cobrindo o padrão central de uso, cenários por componente, composição do ecossistema e anti-padrões com alternativas corretas. Ela não executa o código nem valida os exemplos em runtime — entrega a estrutura com placeholders e exemplos ORM para que o desenvolvedor preencha com casos reais. O escopo é exclusivamente exemplificar o uso correto da API pública; documentação de fundamentos, estrutura e roadmap são responsabilidades de outras skills. A seção de anti-padrões é obrigatória e deve sempre apresentar a alternativa correta ao lado do que não fazer.

Template portátil para documentação de exemplos de uso de um projecto.

## When to use

- Ao documentar exemplos de uso de um projecto novo.
- Ao padronizar a documentação de cenários e anti-padrões.
- Como referência para a estrutura de exemplos.

## When NOT to use

- Quando o objetivo for documentar fundamentos e nomenclatura — use `documentation-project-fundamentals-template`.
- Quando o objetivo for documentar a estrutura de arquivos e diretórios — use `documentation-project-structure-template`.
- Quando o objetivo for criar o roadmap estratégico — use `documentation-project-roadmap-template`.
- Quando o objetivo for documentar a API HTTP/REST com contratos OpenAPI — use `documentation-api-openapi`.
- Quando o projeto ainda não tem fundamentos documentados — execute `documentation-project-fundamentals-template` antes para estabelecer as convenções que os exemplos devem seguir.

## Estrutura do template

O template contém 5 partes:

1. **Padrão central de uso** — variantes de uso principal + injecção de dependências
2. **Cenários por componente** — configuração, execução, metadados para cada componente
3. **Módulo ou componente especial** — componentes com particularidades e UI de teste
4. **Composição do ecossistema (wiring completo)** — fluxo mínimo multi-módulo
5. **Anti-padrões** — tabela com o que NÃO fazer, porquê e alternativa correcta

Inclui também apêndice com scripts DDL e instruções de execução.

## Dependências (skills prévias)

| Skill | Quando executar antes |
| --- | --- |
| `documentation-project-fundamentals-template` | Quando as convenções de nomenclatura ainda não estiverem definidas — os exemplos devem seguir o padrão estabelecido nos fundamentos |

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| --- | --- | --- |
| Omitir a seção de anti-padrões por "não ter casos ruins conhecidos" | Anti-padrões revelam armadilhas comuns; omiti-los força cada desenvolvedor a aprendê-los na prática | Incluir pelo menos 3 anti-padrões comuns para o tipo de projeto; usar exemplos ORM como referência |
| Documentar exemplos sem testar se compilam/executam | Exemplos inválidos desorientam mais do que ajudam | Marcar exemplos não verificados explicitamente com `// EXEMPLO NÃO VERIFICADO` |
| Misturar exemplos de API pública com detalhes de implementação interna | Expõe internos que podem mudar; acopla a documentação à implementação | Documentar somente a interface pública; referenciar units internas apenas como contexto |
| Criar exemplos de wiring completo sem os componentes individualmente documentados | Dificulta o entendimento incremental | Sempre documentar componentes individualmente nas Partes 1-3 antes do wiring completo na Parte 4 |

## Métricas de sucesso

- O documento gerado contém as 5 partes do template com pelo menos um exemplo por parte (mesmo que em placeholder).
- A seção de anti-padrões contém pelo menos 3 entradas com alternativa correta para cada.
- Todos os exemplos de código seguem as convenções de nomenclatura definidas em `documentation-project-fundamentals-template`.

## Responsável principal

| Papel | Quem |
| --- | --- |
| Agent executor | `doc-agent-orchestrator` |
| Revisão humana | Desenvolvedor responsável pela API pública do projeto |
| Aprovação final | Tech Lead / Arquiteto do projeto |

---

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.1.0 |

## Changelog (este arquivo)

- 1.1.0 (09/04/2026): Migração V2 — adicionadas seções Responsabilidade única, When NOT to use, Dependências, Anti-padrões, Métricas de sucesso, Responsável principal; frontmatter expandido com thinking: minimal e category: documentation.
- 1.0.0 (04/04/2026): Versão inicial — conteúdo portátil extraído de `project-exemplos_V1.0.1.mdc` durante migração Fase 1.

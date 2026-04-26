---
name: quality-code-review-checklist
description: Checklist estruturado para revisão de código antes de merge — cobre memory management, exceções, nomenclatura, SQL injection, XSS, performance básica e aderência ao padrão do projeto. Triggers - "revisar código", "code review", "checklist de review", "antes de mergear", "aprovar PR", "pair review", "revisar antes do merge".
model: sonnet
thinking: normal
category: quality
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# quality-code-review-checklist

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## Responsabilidade única

Esta skill fornece o checklist estruturado para revisão de código antes de merge — cobrindo memory management, exceções, nomenclatura, SQL injection, XSS, performance básica e aderência ao padrão do projeto. Ela NÃO executa a revisão em si (use o command `code-review` para isso); apenas fornece o instrumento de verificação com os itens obrigatórios organizados por categoria.

## When to use

- Antes de aprovar um PR ou fazer merge de branch.
- Durante sessão de pair review para garantir cobertura completa.
- Ao revisar contribuições externas ou de novo membro do time.

## When NOT to use

- Para análise de regressão após refatoração → use `quality-regression-guard`.
- Para testes de aceite baseados em critérios da SPEC → use `quality-acceptance-testing`.
- Para executar a revisão de código com análise profunda → use o command `code-review`.

## Inputs

- Código a ser revisado (diff, PR, arquivo ou trecho colado).
- Padrões e convenções do projeto (disponíveis via `documentation-project-expert`).

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `documentation-project-expert` | Consultar convenções de nomenclatura e padrões do projeto antes de avaliar aderência |

## Workflow executável

1. **Abrir o código** — obter o diff ou conjunto de arquivos a revisar; identificar o escopo (módulo, camada, tecnologia).
2. **Percorrer o checklist por categoria** — percorrer cada grupo de itens na ordem abaixo; marcar cada item como OK, FAIL ou N/A com justificativa.
3. **Registrar issues com linha de referência** — para cada item FAIL, registrar: categoria, descrição do problema, arquivo:linha, severidade (crítico/alto/médio/baixo) e sugestão de correção.

## Checklist de validação

### Categoria: Memory Management (Delphi/FPC)

- [ ] Todos os objetos criados com `Create` são liberados em bloco `try..finally..Free`.
- [ ] Nenhum vazamento detectável via `ReportMemoryLeaksOnShutdown`.
- [ ] Strings de conexão e buffers sensíveis são zerados após uso.
- [ ] Sem `FreeAndNil` desnecessário em variáveis locais que já saem de escopo.

### Categoria: Tratamento de Exceções

- [ ] Exceções usam a hierarquia do projeto (`EProviderError` ou equivalente).
- [ ] Nenhum `except` vazio (silencia erros sem logging).
- [ ] `raise` sem argumento usado somente dentro de bloco `except` para re-raise.
- [ ] Exceções de recursos externos (DB, rede, arquivo) são tratadas com mensagem contextual.

### Categoria: Nomenclatura e Padrões

- [ ] Interfaces prefixadas com `I`, implementações com `T`, exceções com `E`, factories com `New`.
- [ ] Nomes de units, classes e métodos aderem ao padrão definido em `documentation-project-expert`.
- [ ] Sem abreviações não documentadas ou nomes genéricos (`Temp`, `Aux`, `Data2`).
- [ ] Constantes em UPPER_CASE ou PascalCase conforme padrão do projeto.

### Categoria: Segurança — SQL Injection

- [ ] Zero concatenação de string em queries SQL; uso exclusivo de parâmetros bindados.
- [ ] Nenhuma query construída a partir de input direto do usuário sem sanitização.
- [ ] Queries dinâmicas documentadas com justificativa quando inevitáveis.

### Categoria: Segurança — XSS (Web)

- [ ] Dados de usuário renderizados via binding seguro (nunca `innerHTML` direto).
- [ ] Props de componente tipadas; sem `any` não documentado em pontos de entrada de dados externos.
- [ ] Atributos HTML gerados dinamicamente são escapados antes da renderização.

### Categoria: Acessibilidade (Web)

- [ ] Elementos interativos possuem `aria-label` ou texto visível.
- [ ] Imagens decorativas têm `alt=""` e imagens informativas têm `alt` descritivo.
- [ ] Navegação por teclado funciona para todos os fluxos principais.

### Categoria: Performance Básica

- [ ] Nenhuma query N+1 detectável (loop com query dentro).
- [ ] Resultados de operações custosas são cacheados quando reutilizados no mesmo contexto.
- [ ] Sem bloqueio de thread principal com operações síncronas longas sem indicação ao usuário.

### Categoria: Geral

- [ ] Sem comentários `TODO` ou `FIXME` não registrados no tracker de dívida técnica.
- [ ] Cobertura de testes existe para o código novo ou modificado.
- [ ] Sem código comentado (código morto deve ser removido, não comentado).
- [ ] Separação UI/lógica respeitada: zero SQL ou regras de negócio em event handlers ou componentes de view.

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|------------------|---------------|
| Aprovar PR sem verificar memory management | Leaks acumulam silenciosamente; difíceis de diagnosticar em produção | Percorrer categoria Memory Management antes de qualquer aprovação |
| Ignorar nomenclatura por ser "só detalhe" | Nomes inconsistentes aumentam carga cognitiva e dificultam onboarding | Consultar `documentation-project-expert`; corrigir antes do merge, não depois |
| Checklist parcial por pressão de prazo | Issues críticos passam para produção; custo de correção multiplica | Marcar explicitamente itens como N/A quando não aplicáveis, mas nunca pular categorias inteiras |
| Registrar issue sem linha de referência | Desenvolvedor não sabe onde corrigir; retrabaho no próximo ciclo | Sempre indicar arquivo:linha para cada issue registrado |

## Métricas de sucesso

- Zero itens de severidade **crítico** pendentes ao aprovar o PR.
- Todos os `TODO` e `FIXME` do diff estão registrados em `Documentation/TechDebt.md`.
- Cada item FAIL tem arquivo:linha e sugestão de correção documentados.
- Checklist completo (nenhuma categoria pulada sem marcação N/A justificada).

## Responsável principal

| Papel | Quem |
|-------|------|
| Revisor backend Delphi/FPC | `dev-agent-backend` |
| Revisor frontend Web | `dev-agent-vuejs-core-expert` |

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Skill nova V2 — criada para lacuna quality no plano de migração V2.6.

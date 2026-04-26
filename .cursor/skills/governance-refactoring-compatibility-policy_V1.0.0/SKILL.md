---
name: governance-refactoring-compatibility-policy
description: Política OBRIGATÓRIA ao analisar, consolidar, estruturar, refatorar, renomear ou evoluir código existente em QUALQUER linguagem (Pascal, TypeScript, Python, C#, Java, Go, Rust, etc.). Força decisão explícita entre manter backward compat, marcar deprecated com remoção futura, ou quebrar agora.
model: opus
thinking: extended
category: governance-process
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

## Responsabilidade única

Esta skill governa decisões de refatoração que afetam compatibilidade — ela exige que o agente mapeie todos os consumidores antes de renomear/mover qualquer símbolo, e force uma escolha explícita entre: (A) manter backward compat, (B) deprecar com prazo, (C) quebrar agora. Existe separada de outras skills porque a violação dessa política causa regressões silenciosas em consumidores externos não óbvios.

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## When to use

**OBRIGATÓRIO** sempre que o usuário pedir uma das ações abaixo sobre código que **já existe e pode ter consumidores**:

### Categoria 1 — Análise

- "analisar [módulo/classe/unit]", "análise de impacto", "mapear módulo X", "revisar arquitetura"

### Categoria 2 — Consolidação

- "consolidar X e Y", "unificar módulos", "deduplicar código", "merge de features similares"

### Categoria 3 — Estruturação

- "estruturar projeto", "reorganizar pastas", "criar nova estrutura", "mover X para Y", "split unit em vários"

### Categoria 4 — Refatoração explícita

- "refatorar X" / "refactor X", "renomear método/classe/unit", "extrair X para módulo separado", "separar responsabilidades", "evoluir API", "deprecated", "remover método obsoleto"

### Regra de ouro

Se a operação envolve código que **já existe** E há possibilidade de consumidores externos, esta skill DEVE disparar antes de qualquer Edit/Write — **mesmo que o usuário não tenha usado a palavra "refatorar"**.

## When NOT to use

- Correções de typos em strings literais ou comentários sem impacto em API pública → usar edição direta.
- Adição de novos símbolos sem remover ou renomear os existentes (greenfield puro) → nenhuma skill necessária.
- Mudanças puramente internas sem API pública exposta (variáveis locais, helpers privados) → executar diretamente.

## Dependências (skills prévias)

Nenhuma dependência obrigatória — esta skill é pré-condição das demais skills de refatoração e análise.

## Workflow obrigatório

1. **Detectar** intenção de refatoração nas palavras do usuário.
2. **Mapear consumidores** ANTES de propor mudanças:
   - Grep no projeto pelos nomes a serem alterados.
   - Verificar workspace/monorepo por outros projetos que importam o módulo.
   - Listar **TODOS** os pontos de uso em formato tabela `arquivo:linha`.
3. **Apresentar 3 estratégias** ao usuário via `AskUserQuestion` (labels A/B/C):
   - **A — Backward compat total** (recomendado por padrão).
   - **B — Deprecated com remoção agendada** (próxima major).
   - **C — Quebrar agora** (requer frase explícita autorizando).
4. **NÃO executar nenhum Edit/Write** antes de receber a resposta.
5. **Ao executar**, gerar entrada de CHANGELOG correspondente à estratégia escolhida.

## Checklist antes de qualquer rename

- [ ] Identifiquei TODOS os consumidores via grep no workspace?
- [ ] Listei os pontos de uso em formato tabela?
- [ ] Apresentei as 3 estratégias (A/B/C) ao usuário via `AskUserQuestion`?
- [ ] Recebi resposta explícita do usuário?
- [ ] Se estratégia B: adicionei marcador `deprecated` da linguagem + entrada de CHANGELOG?
- [ ] Se estratégia C: tenho frase explícita do usuário autorizando a quebra?

## Estratégias detalhadas

### Estratégia A — Backward compat total (recomendada)

- Preservar **todos** os nomes públicos existentes.
- Refatoração interna é livre desde que a fachada pública não mude.
- **Padrão:** wrapper/facade thin que delega ao novo código.

**Quando usar:** biblioteca consumida por projetos externos; APIs públicas; SDKs.

### Estratégia B — Deprecated com remoção agendada

- Manter o nome antigo como wrapper que delega ao novo nome.
- Adicionar marcador `deprecated` com: nome de substituição + versão de remoção.
- Entrada no `CHANGELOG.md` documentando a transição.
- Remoção efetiva apenas na próxima major version.

### Estratégia C — Quebrar agora (excepcional)

- **REQUER** frase explícita do usuário autorizando: "pode quebrar", "não importa compat", "é só código novo".
- Não basta o usuário dizer "execute" / "faça" / "vai".
- Documentar no CHANGELOG como BREAKING CHANGE.
- Bumpar major version.

## Marcadores de deprecation por linguagem

| Linguagem | Marcador |
| --- | --- |
| Delphi/FPC | `deprecated 'Use NovoNome a partir da v X.Y'` |
| C# | `[Obsolete("Use NewName. Removed in vX.Y")]` |
| TypeScript / JavaScript | `/** @deprecated Use newName. Removed in vX.Y */` |
| Python | `warnings.warn("...", DeprecationWarning)` ou `@deprecated` (PEP 702) |
| Java | `@Deprecated(since="X.Y", forRemoval=true)` |
| Go | `// Deprecated: Use NewName. Removido na v2.0.` |
| Rust | `#[deprecated(since = "X.Y", note = "Use new_name")]` |
| Kotlin | `@Deprecated("Use newName", ReplaceWith("newName"))` |
| Swift | `@available(*, deprecated, message: "Use newName")` |
| Ruby | `Warning.warn("...")` ou gem `deprecate` |

## Exemplo de Wrapper thin (estratégia B) — Delphi / FPC

```pascal
type
  TConnectionHelper = class
  public
    class function GetDefaultPort(AProvider: TDatabaseProvider): Integer;
    class function GetPortaPadrao(AProvider: TDatabaseProvider): Integer;
      deprecated 'Use GetDefaultPort. Removido na v2.0.';
  end;
```

## Anti-padrões universais (NUNCA fazer)

- Renomear classe/método sem perguntar ao usuário.
- Assumir que "ninguém usa" sem fazer grep no workspace inteiro.
- Criar módulo novo com nomes diferentes dos originais e esperar que o usuário "ajuste depois".
- Misturar refatoração interna com mudança de API pública num único commit.
- Aplicar estratégia C porque o usuário disse "execute" — frase explícita de autorização é necessária.
- Usar `@deprecated` sem incluir versão de remoção e nome de substituição.
- Fazer estratégia B sem entrada correspondente no CHANGELOG.

## Anti-padrões

| Anti-padrão | Por que errado | Como corrigir |
| --- | --- | --- |
| Renomear símbolo público sem executar esta skill primeiro | Causa regressões silenciosas em consumidores não mapeados | Sempre acionar esta skill antes de qualquer rename |
| Escolher estratégia C sem listar consumidores | Pode quebrar projetos externos não identificados | Executar grep completo antes de propor quebra |
| Aceitar "execute" / "faça" como autorização para quebrar compat | Frase genérica não implica ciência do impacto | Exigir frase explícita de autorização |
| Misturar refatoração interna e mudança de API pública num único commit | Dificulta rastreamento de regressões e rollback | Separar em commits distintos |

## Métricas de sucesso

- Zero regressões em consumidores após cada rename — verificável rodando testes de integração.
- Decision log preenchido para cada símbolo modificado — cada rename/move deve ter entrada correspondente no CHANGELOG.

## Responsável principal

| Papel | Quem |
| --- | --- |
| Agent executor | `dev-agent-orchestrator` |
| Aprovador humano | Tech Lead / Arquiteto |
| Revisor de impacto | Desenvolvedor responsável pelo módulo afetado |

## Integração com outras skills (apenas genéricas)

- Estratégia B → atualizar `Documentation/Versionamento/CHANGELOG.md` (skill `documentation-versioning-changelog`).
- Refatoração arquitetural → executar `documentation-architecture` para registrar a decisão.

> Esta skill **não** referencia skills com afinidade de linguagem (`developer-delphi-*`, `JS-*`) — é universal por design.

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `governance-refactoring-compatibility-policy`; novo prefixo canônico `governance`. Conteúdo V2 preservado (FileVersion 1.1.0 da origem).

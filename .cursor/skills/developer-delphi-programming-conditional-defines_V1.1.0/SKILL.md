---
name: developer-delphi-programming-conditional-defines
description: Use when the user asks about compilation directives (USE_*, ORM.Defines.inc), how to enable/disable modules or engines, or how to write {$IF DEFINED(...)} blocks (and why NOT to use {$IFDEF}) for FireDAC, UniDAC, Zeos, SQLdb, USE_ATTRIBUTES, USE_ENTITY_MANAGER, USE_QUERY_BUILDER, USE_PARAMENTERS, USE_LOGGERS, USE_POOLCONNECTIONS. Canonical doc: .cursor/skills/developer-delphi-programming-conditional-defines_V1.1.0/exemplos/diretivas_compilacao.md.
model: haiku
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-programming-conditional-defines
## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Esta skill é a referência canônica para diretivas de compilação do projeto: habilitar/desabilitar engines e módulos via `ORM.Defines.inc`, escrever blocos `{$IF DEFINED(...)}` na ordem correta, e garantir que nenhum `{$IFDEF}` de engine seja introduzido. Ela aponta para o documento de verdade única (`diretivas_compilacao.md`) e exige leitura desse arquivo antes de responder com diretivas ou código condicional. Ela NÃO compila o projeto e NÃO implementa lógica de negócio.

## When to use

- Usuário pergunta quais diretivas existem ou como habilitar/desabilitar módulos ou engines.
- Usuário pergunta sobre `ORM.Defines.inc` (localização, inclusão `{$I ORM.Defines.inc}`).
- Usuário pergunta sobre engines de banco (`USE_UNIDAC`, `USE_FIREDAC`, `USE_ZEOS`, `USE_SQLDB`).
- Usuário pergunta sobre módulos opcionais (`USE_PARAMENTERS`, `USE_LOGGERS`, `USE_POOLCONNECTIONS`, `USE_ATTRIBUTES`, `USE_ENTITY_MANAGER`, `USE_QUERY_BUILDER`).
- Usuário pede exemplos de blocos condicionais ou ordem fixa das engines nas condicionais.
- Usuário pergunta sobre `uses` condicional por módulo ou engine.

## When NOT to use

- Não usar para compilar o projeto → use `developer-delphi-build-toolchain`.
- Não usar para arquitetura de módulos → use `developer-delphi-to-fpc-architecture-and-design`.
- Não usar para sintaxe de linguagem cross-compiler (generics, RTTI) → use `developer-delphi-to-fpc-language-core`.
- Não usar para organização de `uses` e RTL/FCL → use `developer-delphi-to-fpc-rtl-and-units`.

## Inputs

- Nome da engine ou módulo a habilitar/desabilitar.
- Contexto do bloco condicional `{$IF DEFINED(...)}` a escrever (tipo, Create, resultado, cast).

## Documento canônico

| Documento | Caminho | Conteúdo |
|-----------|---------|----------|
| **Diretivas de compilação** | `.cursor/skills/developer-delphi-programming-conditional-defines_V1.1.0/exemplos/diretivas_compilacao.md` | Como habilitar/desabilitar; módulos opcionais (USE_PARAMENTERS, USE_LOGGERS, USE_POOLCONNECTIONS); funcionalidades ORM (USE_ATTRIBUTES, USE_ENTITY_MANAGER, USE_QUERY_BUILDER); engines de banco (USE_UNIDAC, USE_FIREDAC, USE_ZEOS, USE_SQLDB); engines de serviços/email/HTTP/WebSocket; frameworks de controles; **construção de código** — ordem fixa das engines, padrão compacto (tipo, Create, resultado, cast), regras gerais, uses condicional; arquivo fonte ORM.Defines.inc. |

## Regra de uso

1. **Ao responder sobre diretivas (USE_*, habilitar/desabilitar, blocos condicionais):** ler `.cursor/skills/developer-delphi-programming-conditional-defines_V1.1.0/exemplos/diretivas_compilacao.md` e usar as tabelas, a ordem das engines e os padrões de código descritos lá. Não inventar diretivas nem ordem diferente.
2. **Ao escrever código com `{$IF DEFINED(...)}`:** seguir a ordem UNIDAC → FIREDAC → ZEOS → SQLDB → fallback; usar padrão compacto quando aplicável; fallback no último `{$ELSE}`.
3. **Ao alterar** diretivas_compilacao.md (novas diretivas, novos padrões): manter este SKILL.md alinhado à descrição do documento (seção "Documento canônico" e "When to use").

## Workflow executável

1. Identificar engine ou módulo alvo.
2. Ler `diretivas_compilacao.md`.
3. Responder com diretiva, ordem e padrão de código corretos do documento.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-build-toolchain` | Antes de compilar após alterar diretivas; garante uso do compilador correto com as novas flags |

## Resumo rápido (não substitui a leitura do documento)

- **Habilitar:** descomentar a linha `{$DEFINE ...}` em ORM.Defines.inc. **Desabilitar:** comentar com `//`.
- **Engines (um por compilação):** USE_UNIDAC, USE_FIREDAC (só Delphi), USE_ZEOS, USE_SQLDB (só FPC). Ordem nas condicionais: 1 UNIDAC, 2 FIREDAC, 3 ZEOS, 4 SQLDB, 5 fallback.
- **Módulos:** USE_PARAMENTERS, USE_LOGGERS, USE_POOLCONNECTIONS. **Funcionalidades:** USE_ATTRIBUTES (RTTI), USE_ENTITY_MANAGER (requer USE_ATTRIBUTES), USE_QUERY_BUILDER.
- **Código condicional:** Preferir `{$IF DEFINED(...)}`; encadear com `{$ELSE} {$IF DEFINED(...)}`; fallback no último `{$ELSE}` (TObject, nil, teNone, TDataSet).

Para detalhes exatos (tabelas completas, padrões compactos de declaração/Create/resultado/cast, uses condicional), **sempre consultar** `.cursor/skills/developer-delphi-programming-conditional-defines_V1.1.0/exemplos/diretivas_compilacao.md`.

## Checklist Delphi+FPC

- [ ] Compilação sem hints/warnings em Delphi (dcc32 + dcc64)
- [ ] Compilação sem hints/warnings em FPC (fpc32 + fpc64)
- [ ] Memory management: Create/Free em try..finally; sem leaks (ReportMemoryLeaksOnShutdown)
- [ ] Tratamento de exceções: hierarquia do projeto (EProviderError ou equivalente)
- [ ] Nomenclatura: prefixos T/I/E/F/A conforme documentation-project-expert
- [ ] Diretivas {$IF DEFINED(...)} conforme developer-delphi-programming-conditional-defines; sem nenhum {$IFDEF} de engine
- [ ] Separação UI/lógica: zero SQL ou regras de negócio em event handlers
- [ ] Plano inclui validação cross-compiler
- [ ] Referências a compile.md e diretivas_compilacao.md verificadas quando aplicável

## Exemplo mínimo compilável (ordem canônica UNIDAC → FIREDAC → ZEOS → SQLDB → fallback)

**Delphi (dcc32 / dcc64) — com encadeamento explícito e fallback nomeado:**

```pascal
program SampleDiretivasDelphi;
{$APPTYPE CONSOLE}
{$I ORM.Defines.inc}
begin
{$IF DEFINED(USE_UNIDAC)}
  WriteLn('engine=UniDAC');
{$ELSE} {$IF DEFINED(USE_FIREDAC)}
  WriteLn('engine=FireDAC');
{$ELSE} {$IF DEFINED(USE_ZEOS)}
  WriteLn('engine=Zeos');
{$ELSE} {$IF DEFINED(USE_SQLDB)}
  WriteLn('engine=SQLdb');
{$ELSE}
  WriteLn('engine=none (fallback)');
{$ENDIF} {$ENDIF} {$ENDIF} {$ENDIF}
end.
```

**Free Pascal (fpc32 / fpc64) — idem, com modo Delphi:**

```pascal
program SampleDiretivasFPC;
{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}
{$I ORM.Defines.inc}
begin
{$IF DEFINED(USE_UNIDAC)}
  WriteLn('engine=UniDAC');
{$ELSE} {$IF DEFINED(USE_FIREDAC)}
  WriteLn('engine=FireDAC');
{$ELSE} {$IF DEFINED(USE_ZEOS)}
  WriteLn('engine=Zeos');
{$ELSE} {$IF DEFINED(USE_SQLDB)}
  WriteLn('engine=SQLdb');
{$ELSE}
  WriteLn('engine=none (fallback)');
{$ENDIF} {$ENDIF} {$ENDIF} {$ENDIF}
end.
```

## Por que NÃO usar `{$IFDEF}` e `{$ELSEIF}` neste projeto

O padrão canônico do projeto é `{$IF DEFINED(X)}` + encadeamento `{$ELSE} {$IF DEFINED(Y)} ... {$ENDIF}` por 3 motivos técnicos:

1. **Segurança contra símbolo não declarado:** `{$IFDEF USE_X}` falha silenciosamente se `USE_X` nunca foi definido em lugar algum (não aparece em `ORM.Defines.inc`, não foi passado via CLI). Já `{$IF DEFINED(USE_X)}` sempre retorna `False` de forma segura.

2. **Portabilidade FPC:** alguns modos de compilação do FPC (especialmente `{$mode delphi}` com versões mais antigas do 3.0.x) têm comportamentos inconsistentes com `{$ELSEIF DEFINED(X)}`. O encadeamento explícito `{$ELSE} {$IF DEFINED(X)} ... {$ENDIF}` **sempre funciona igual** em Delphi + FPC + modo Delphi + modo ObjFPC.

3. **Clareza de escopo:** cada `{$IF}` pareia com exatamente um `{$ENDIF}`. Num bloco aninhado profundo (5 engines + fallback) o leitor conta `{$ENDIF}`s e sabe onde cada ramo termina. `{$ELSEIF}` esconde esse escopo e dificulta review.

**Regra:** use `{$ELSEIF}` apenas em projetos 100% Delphi (sem FPC). Neste projeto, `{$ELSEIF}` e `{$IFDEF}` em código de engine devem ser evitados.

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|------------------|---------------|
| Inventar diretivas `USE_*` sem ler diretivas_compilacao.md | Diretiva não existe no projeto; código nunca entra no bloco | Ler o documento canônico para obter a lista exata de diretivas disponíveis |
| Ordem errada das engines nas condicionais | Comportamento inesperado; engine errada ativada em ambiente específico | Seguir sempre: UNIDAC → FIREDAC → ZEOS → SQLDB → fallback |
| USE_FIREDAC em código cross-compiler compartilhado | FireDAC não existe no FPC; build FPC falha | Limitar USE_FIREDAC a blocos `{$IFDEF MSWINDOWS}` ou código Delphi-only |
| Sem fallback no último `{$ELSE}` | Runtime error se nenhuma engine estiver definida | Sempre incluir fallback com TObject/nil/teNone/TDataSet no último `{$ELSE}` |
| Usar `{$IFDEF}` com path hardcoded | Mistura diretivas de compilação com configuração de ambiente | Usar apenas `{$I ORM.Defines.inc}` para inclusão; paths ficam em cfg/opts |

## Métricas de sucesso

- Todo bloco `{$IF DEFINED(...)}` segue a ordem UNIDAC → FIREDAC → ZEOS → SQLDB → fallback.
- Nenhuma diretiva inventada fora das listadas em `diretivas_compilacao.md`.
- Build Delphi e FPC limpos após habilitar/desabilitar qualquer engine ou módulo.
- Fallback presente em todos os blocos condicionais de engine.

## Responsável principal

| Papel | Quem |
|-------|------|
| Guardião de diretivas | Desenvolvedor responsável pelo módulo afetado |
| Validador cross-compiler | CI/pipeline local (dcc32, dcc64, fpc32, fpc64) |

## Referencias

- `.cursor/skills/developer-delphi-programming-conditional-defines_V1.1.0/exemplos/diretivas_compilacao.md` (canônico)

## Changelog (este arquivo)

- 1.1.0 (24/04/2026): Fix Q1+Q7 — removidas 4 menções prescritivas de `{$IFDEF}` (description, §Responsabilidade única, §Inputs, §Checklist) que contradiziam o ensinamento canônico da própria skill ("Por que NÃO usar {$IFDEF}"). Skill agora é 100% consistente: ensina e usa apenas `{$IF DEFINED(...)}`. Paths auto-refs atualizados para V1.1.0.
- 1.0.0 (17/04/2026): Onda 3 do refactor — skill renomeada de `project-diretivas-compilacao_V*` para `developer-delphi-programming-conditional-defines_V1.0.0`. Conteúdo generificado (remoção de referências literais a 'Projeto v2.0 deste clone', paths absolutos, MXX concreto). Versão anterior arquivada em `.cursor/Backup/renamed-skills-20260417/skills/`.

- 1.2.0 (11/04/2026): Corrigido path self-referência → V1.2.0; exemplos enriquecidos com `USE_ATTRIBUTES`, `USE_ENTITY_MANAGER` (requer `USE_ATTRIBUTES`), `USE_QUERY_BUILDER`; header de exemplos atualizado V1.0.2 → V1.1.0.
- 1.1.0 (09/04/2026): Migração V2 — adicionados frontmatter `thinking: extended` e `category: developer-delphi`; seções Responsabilidade única, When NOT to use, Dependências (skills prévias), Checklist Delphi+FPC completo (9 itens), Exemplo mínimo compilável (Delphi + FPC), Anti-padrões, Métricas de sucesso, Responsável principal.
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).

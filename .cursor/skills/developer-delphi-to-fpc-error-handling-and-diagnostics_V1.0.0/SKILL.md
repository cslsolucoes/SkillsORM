---
name: developer-delphi-to-fpc-error-handling-and-diagnostics
description: Taxonomia de exceções por domínio, diagnóstico e práticas seguras de tratamento de erro em Delphi/FPC.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-error-handling-and-diagnostics

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## Responsabilidade única

Esta skill cobre a modelagem de hierarquias de exceções por domínio, investigação de falhas com base em logs e stack traces, padronização de blocos `try..except..finally` e propagação segura de erros em Delphi e FPC. Ela NÃO realiza refatoração arquitetural ampla e NÃO define estratégia de testes — seu foco é exclusivamente o tratamento correto, rastreável e seguro de erros em runtime.

## When to use

- Modelagem de erros, investigação de falhas, padronização de exceções.
- Criação de hierarquia de exceções por domínio (ex.: `EProviderError`, `EConnectionError`).
- Análise de stack traces e logs de runtime.

## When NOT to use

- Não usar para desenho de arquitetura completa → use `developer-delphi-to-fpc-architecture-and-design`.
- Não usar para definir estratégia de testes e quality gates → use `developer-delphi-testing-and-quality`.
- Não usar para otimização de memória ou detecção de leaks → use `developer-delphi-to-fpc-performance-and-memory`.
- Não usar para configurar logging multi-destino (módulo `Loggers`) → referenciar a documentação do módulo Loggers diretamente.

## Inputs

- Logs, stack traces, contexto do módulo.

## Workflow executável

1. Classificar erro por domínio.
2. Definir tipo de exceção e mensagem rastreável.
3. Propor correção com impacto delimitado.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-to-fpc-architecture-and-design` | Antes de definir hierarquia de exceções que abrange múltiplos módulos |
| `developer-delphi-to-fpc-language-core` | Antes de usar generics ou RTTI em exceções customizadas |

## Checklist Delphi+FPC

- [ ] Compilação sem hints/warnings em Delphi (dcc32 + dcc64)
- [ ] Compilação sem hints/warnings em FPC (fpc32 + fpc64)
- [ ] Memory management: Create/Free em try..finally; sem leaks (ReportMemoryLeaksOnShutdown)
- [ ] Tratamento de exceções: hierarquia do projeto (EProviderError ou equivalente)
- [ ] Nomenclatura: prefixos T/I/E/F/A conforme documentation-project-expert
- [ ] Diretivas {$IFDEF} conforme developer-delphi-programming-conditional-defines; sem mistura com paths
- [ ] Separação UI/lógica: zero SQL ou regras de negócio em event handlers
- [ ] Plano inclui validação cross-compiler
- [ ] Referências a compile.md e diretivas_compilacao.md verificadas quando aplicável
- [ ] Sem `except` vazio.
- [ ] Mensagem e contexto do erro preservados na propagação.

## Exemplo mínimo compilável

**Delphi (dcc32 / dcc64):**

```pascal
program SampleErrorDelphi;
{$APPTYPE CONSOLE}
uses SysUtils;
begin
  try
    raise Exception.Create('OK -- developer-delphi-to-fpc-error-handling-and-diagnostics');
  except
    on E: Exception do
      WriteLn(E.Message);
  end;
end.
```

**Free Pascal (fpc32 / fpc64):**

```pascal
program SampleErrorFPC;
{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}
uses SysUtils;
begin
  try
    raise Exception.Create('OK -- developer-delphi-to-fpc-error-handling-and-diagnostics');
  except
    on E: Exception do
      WriteLn(E.Message);
  end;
end.
```

**Unit de referência (Delphi + FPC):**

```pascal
unit Sample.Errors;
{$IF DEFINED(FPC)}
  {$mode delphi}
{$ENDIF}
interface

uses
  SysUtils;

type
  EDomainError = class(Exception);

implementation

end.
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|------------------|---------------|
| `except` vazio sem tratamento | Engole o erro silenciosamente; impossível diagnosticar em produção | Sempre tratar ou re-lançar com contexto: `on E: Exception do raise EDomainError.CreateFmt(...)` |
| Usar `Exception` genérica para erros de domínio | Impede captura seletiva; mistura erros de infra com erros de negócio | Criar hierarquia específica por domínio herdando de `EProviderError` ou equivalente |
| Mensagens de erro sem contexto (apenas 'Erro') | Impossível correlacionar com módulo/operação em produção | Incluir módulo, operação e parâmetros relevantes na mensagem: `'[Connections.Connect] host=%s port=%d'` |
| `finally` com lógica de negócio | `finally` sempre executa; lógica condicional se torna imprevisível | Usar `finally` apenas para liberação de recursos; lógica condicional no bloco `try` ou `except` |
| Re-lançar exceção com `raise E` (perde stack trace no Delphi) | Perde o stack trace original no Delphi moderno | Usar `raise` sem parâmetro dentro do `except` para preservar o stack trace |

## Métricas de sucesso

- Zero blocos `except` vazios em qualquer módulo do projeto.
- Hierarquia de exceções documentada com pelo menos um tipo por domínio crítico.
- Todas as exceções propagadas com mensagem rastreável (módulo + operação + parâmetros).
- Build limpo em Delphi e FPC após inclusão de novos tipos de exceção.

## Responsável principal

| Papel | Quem |
|-------|------|
| Modelador de exceções | Desenvolvedor responsável pelo módulo |
| Revisor de tratamento de erros | Líder técnico do projeto |

## Avaliacao de risco e confirmacao

- Se correção de erro exigir mudança transversal em módulo crítico, confirmar com usuário.

## Referencias

- Object Pascal Handbook (exception handling)
- RAD/FPC docs de exceptions

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `developer-delphi-error-handling-and-diagnostics`; novo prefixo canônico `developer-delphi`. Conteúdo idêntico ao V1.1.0 de origem; cross-references atualizadas para prefixo `developer-delphi-*`.

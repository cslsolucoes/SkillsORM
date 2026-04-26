---
name: developer-delphi-docs-to-structured-code
description: Converte documentação canônica em codificação estruturada por projeto/módulo com rastreabilidade e validação Delphi/FPC.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-docs-to-structured-code

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## Responsabilidade única

Esta skill transforma documentação canônica do projeto (`Documentation/Arquitetura`, `Regras de Negocio`, `Roadmap`, `Analise`) em código Object Pascal estruturado, com rastreabilidade entre requisito e implementação, plano incremental e validação obrigatória em Delphi e FPC. Ela NÃO cria documentação nova, NÃO decide arquitetura macro e NÃO executa build autônomo — apenas converte especificações existentes em implementação rastreável.

## When to use

- Quando o pedido é implementar módulo/projeto com base em `Documentation/`.
- Quando for necessário mapear requisitos documentados em units/interfaces/classes.
- Quando for produzir plano incremental de implementação com validação cross-compiler.

## When NOT to use

- Não usar quando a documentação base estiver insuficiente — primeiro qualificar lacunas com o usuário.
- Não usar para criar ou manter a própria documentação → use `developer-delphi-documentation-governance`.
- Não usar para decisões de arquitetura macro → use `developer-delphi-to-fpc-architecture-and-design`.
- Não usar para diagnóstico de exceções → use `developer-delphi-to-fpc-error-handling-and-diagnostics`.
- Não usar para build/compilação isolada → use `developer-delphi-to-fpc-build`.
- Não usar para configurar diretivas de engine → use `developer-delphi-programming-conditional-defines`.

## Inputs

- Escopo (projeto ou módulo).
- Documentação canônica (`Documentation/Arquitetura`, `Regras de Negocio`, `Roadmap`, `Analise`).
- Restrições técnicas e critérios de aceite.

## Workflow executável

1. Inventariar fontes documentais do escopo.
2. Extrair requisitos técnicos e não técnicos.
3. Mapear para units/interfaces/classes/dependências.
4. Produzir plano incremental de implementação.
5. Implementar por incrementos com validação Delphi/FPC.

## Saídas obrigatórias

- Especificação técnica derivada dos docs.
- Mapa de implementação por módulo.
- Plano incremental e checklist de validação.
- Relatório de lacunas documentais.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-to-fpc-architecture-and-design` | Antes de mapear módulos/interfaces quando o escopo envolver design de camadas |
| `developer-delphi-programming-conditional-defines` | Antes de gerar código com blocos `{$IFDEF}` de engine ou módulo opcional |
| `developer-delphi-build-toolchain` | Antes de escrever código com paths de compiladores ou referências a compile.md |

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
- [ ] Todos os incrementos com validação em ambos compiladores.
- [ ] Diretivas e diferenças de compilador mapeadas.

## Exemplo mínimo compilável

**Delphi (dcc32 / dcc64):**

```pascal
program SampleDocsToCodeDelphi;
{$APPTYPE CONSOLE}
begin
  WriteLn('OK -- developer-delphi-docs-to-structured-code');
end.
```

**Free Pascal (fpc32 / fpc64):**

```pascal
program SampleDocsToCodeFPC;
{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}
begin
  WriteLn('OK -- developer-delphi-docs-to-structured-code');
end.
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|------------------|---------------|
| Implementar sem ler a documentação canônica | Produz código que não reflete requisitos reais; gera retrabalho | Inventariar toda a documentação do escopo antes de escrever qualquer linha de código |
| Ignorar lacunas documentais e assumir comportamento | Lacunas viram bugs silenciosos em produção | Gerar relatório de lacunas e parar para decisão do usuário antes de prosseguir |
| Implementar tudo de uma vez sem plano incremental | Dificulta validação e rollback; mistura incrementos distintos | Dividir em incrementos pequenos, cada um com build válido em Delphi e FPC |
| Misturar requisito de negócio com detalhe de implementação no mapa | Torna o rastreamento impossível | Manter tabela clara: Requisito → Unit → Interface → Classe → Método |
| Não registrar rastreabilidade requisito↔código | Impede auditoria e manutenção futura | Adicionar comentário `{@ RN-XXXX }` ou tabela de mapeamento no entregável |

## Métricas de sucesso

- Mapa de implementação cobre 100% dos requisitos do escopo documentado.
- Relatório de lacunas entregue antes da primeira linha de código gerada.
- Cada incremento compila sem erros em dcc32, dcc64, fpc32, fpc64.
- Checklist de validação aprovado ao final de cada incremento.

## Responsável principal

| Papel | Quem |
|-------|------|
| Analista de requisitos | Desenvolvedor responsável pela extração da documentação |
| Implementador | Desenvolvedor Delphi/FPC do módulo |
| Validador cross-compiler | CI/pipeline local |

## Avaliacao de risco e confirmacao

- Se a documentação tiver ambiguidade crítica, parar e solicitar decisão do usuário.
- Se houver risco de alteração estrutural ampla, confirmar antes da implementação.

## Referencias

- `E:\CSL\ProvidersORM\Documentation`
- `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md`
- `.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md`

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `developer-delphi-docs-to-structured-code`; novo prefixo canônico `developer-delphi`. Conteúdo idêntico ao V1.1.0 de origem; cross-references atualizadas para prefixo `developer-delphi-*`.

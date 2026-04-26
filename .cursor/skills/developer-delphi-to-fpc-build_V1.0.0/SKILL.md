---
name: developer-delphi-to-fpc-build
description: Build por linha de comando (Delphi/FPC) com baseline de compatibilidade, tabela de divergências e quality gates.
model: haiku
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-build

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## Responsabilidade única

Esta skill cobre o ciclo completo de build por linha de comando para projetos Delphi/FPC: configuração de `dcc*.cfg` e `fpc*.opts`, execução de compilação Win32/Win64, captura e documentação de divergências entre compiladores em tabela padronizada, e definição de quality gates de compilação. Ela NÃO faz design de domínio, NÃO diagnostica exceções em runtime e NÃO gerencia releases ou pacotes de entrega.

## When to use

- Compilação CLI, configuração de `dcc*.cfg`, `fpc*.opts`, validação cross-compiler.
- Investigação de divergências Delphi × FPC (strings, inline vars, FireDAC vs SQLdb).
- Definição de quality gates de build no pipeline.

## When NOT to use

- Não usar para design de domínio ou arquitetura modular → use `developer-delphi-to-fpc-architecture-and-design`.
- Não usar para definir diretivas `USE_*` ou `{$IFDEF}` de módulos → use `developer-delphi-programming-conditional-defines`.
- Não usar para empacotamento e entrega de artefatos → use `developer-delphi-packaging-delivery`.
- Não usar para diagnóstico de exceções em runtime → use `developer-delphi-to-fpc-error-handling-and-diagnostics`.
- Não usar para consultar comandos CLI de banco de dados → use `developer-delphi-build-toolchain`.

## Inputs

- Arquivo principal (`.dpr`/`.lpr`), diretivas, perfis de build.

## Workflow executável

1. Ler `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md` e `.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md`.
2. Confirmar engine/módulos ativos por diretiva.
3. Rodar build Delphi e FPC.
4. Capturar divergências em tabela padronizada.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-programming-conditional-defines` | Antes de definir quais engines/módulos compilar (`USE_FIREDAC`, `USE_SQLDB`, etc.) |
| `developer-delphi-build-toolchain` | Para obter paths corretos dos compiladores e arquivos de configuração |

## Tabela condensada de divergencias (entregavel)

| Topico | Delphi | FPC | Status | Workaround |
|--------|--------|-----|--------|------------|
| string default | UnicodeString | AnsiString (modo delphi sem modeswitch unicode) | Divergente | Tipagem explicita/modeswitch |
| inline vars | Suportado | Nao suportado | Incompativel | Declaracao tradicional |
| FireDAC | Nativo | Nao suportado | Incompativel | Zeos/SQLdb |

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
- [ ] Build Delphi Win32/Win64 válido.
- [ ] Build FPC Win32/Win64 (ou alvo acordado) válido.
- [ ] Divergências registradas com workaround.

## Exemplo mínimo compilável

**Delphi (dcc32 / dcc64):**

```pascal
program SampleBuildDelphi;
{$APPTYPE CONSOLE}
begin
  WriteLn('OK -- developer-delphi-to-fpc-build');
end.
```

**Free Pascal (fpc32 / fpc64):**

```pascal
program SampleBuildFPC;
{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}
begin
  WriteLn('OK -- developer-delphi-to-fpc-build');
end.
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|------------------|---------------|
| Usar inline variables em código cross-compiler | FPC não suporta; causa erro de compilação | Usar declaração tradicional no bloco `var` |
| Hardcode de paths absolutos em `.cfg`/`.opts` | Quebra o build em outras máquinas | Usar paths relativos ou variáveis de ambiente |
| Ignorar hints/warnings do compilador | Frequentemente indicam bugs reais ou incompatibilidades futuras | Resolver todos os hints antes de fechar a tarefa |
| Alterar diretivas globais sem consultar a equipe | Pode quebrar o build de todos os módulos que dependem delas | Consultar `developer-delphi-programming-conditional-defines` e confirmar com líder técnico |
| Validar apenas um compilador (Delphi ou FPC) | Divergências silenciosas aparecem tarde demais | Sempre executar dcc32, dcc64, fpc32, fpc64 no ciclo de validação |

## Métricas de sucesso

- Build Delphi (Win32 + Win64) com exit code 0 e zero hints/warnings.
- Build FPC (Win32 + Win64) com exit code 0 e zero hints/warnings.
- Tabela de divergências atualizada com workaround para cada item divergente.
- Quality gates documentados e versionados no repositório.

## Responsável principal

| Papel | Quem |
|-------|------|
| Executor do build | Desenvolvedor responsável pela tarefa |
| Revisor de divergências | Líder técnico do módulo |
| CI/pipeline | Automação local (scripts de build) |

## Avaliacao de risco e confirmacao

- Se o build exigir alterar diretivas globais ou cfg/opts usados por toda a equipe, perguntar antes.

## Referencias

- `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md` (canônico para comandos CLI)
- `.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md`
- RAD Studio docs (Compiling)
- FPC docs (Compiler options)

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `developer-delphi-build-cross-compiler`; novo prefixo canônico `developer-delphi`. Conteúdo V2 preservado (FileVersion 1.1.0 da origem).

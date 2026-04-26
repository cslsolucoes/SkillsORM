---
name: project-master-orchestrator
description: Ponto de entrada para as skills de convenções e estrutura do projeto — ORM, compilação, bancos CLI, diretivas, roteiros, parâmetros, loggers, decompilação e padrões OOP. Coordena as 11 skills da família project-*.
model: sonnet
thinking: minimal
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Project Master Orchestrator

## Responsabilidade única

Ponto de entrada para qualquer consulta sobre convenções do projeto, estrutura do repositório, compilação Delphi/FPC, acesso a bancos de dados CLI, diretivas de compilação, roteiros de uso do ORM e padrões OOP obrigatórios. Esta skill não executa diretamente — seleciona a skill especialista correta da família `project-*`.

**Nota:** As skills `project-*` são frequentemente invocadas diretamente pelos agentes Delphi existentes. Este orquestrador serve como ponto de entrada para humanos ou agentes que precisam de orientação sobre qual skill usar sem conhecer os nomes individuais.

## When to use

- "convenções do projeto", "como compilar", "banco de dados CLI", "diretivas USE_*", "ORM.Defines", "estrutura do repo", "roteiro de uso", "decompile CHM", "abrir banco"
- Ao precisar de referência sobre padrões obrigatórios do projeto (Fluent, Factory, I/T naming, OOP)
- Ao precisar compilar ou acessar banco via linha de comando
- Ao nomear classes, interfaces ou units Delphi
- Ao verificar se o código segue os padrões OOP do projeto

## When NOT to use

- Para documentação técnica → `documentation-master-orchestrator`
- Para governança de processo → `governance-master-orchestrator`
- Para QA ou code review → `quality-master-orchestrator`
- Para implementação de features → `developer-delphi-master-orchestrator`

## Skills coordenadas (11)

| Skill | Responsabilidade | Quando invocar |
|-------|-----------------|----------------|
| `documentation-project-expert` | Convenções ORM: Fluent, Factory, I*/T*, blueprints, naming | Antes de implementar qualquer código ORM ou módulo |
| `developer-delphi-programming-oop-fluent` | Garantir que toda lógica de negócio seja OOP (sem procedures soltas) | Antes de criar qualquer unit de negócio, serviço ou repositório |
| `developer-delphi-programming-oop-naming` | Nomenclatura TModulo/IModulo e TModuloSubclasse + atributos `[Table]` para DB | Ao nomear classes, interfaces, units ou mapear tabelas em Delphi |
| `documentation-project-structure` | Mapa do repositório — pastas, arquivos, papel de cada camada | Ao precisar entender onde fica o quê no repo |
| `developer-delphi-build-toolchain` | Compilação Delphi/FPC (dcc32/dcc64/fpc) + acesso a bancos CLI | Ao compilar ou acessar banco via terminal |
| `developer-delphi-programming-conditional-defines` | Diretivas USE_*, ORM.Defines.inc, blocos `{$IFDEF}` | Ao trabalhar com engines ou compilação condicional |
| `developer-delphi-providers-orm-usage` | Roteiros de uso do ORM (Slim, DDL/DML, CRUD, Attributes) | Ao implementar padrões ORM pela primeira vez |
| `developer-delphi-providers-parameters` | Módulo Parameters — INI/JSON/Database; IParameters; fallback cascade | Ao carregar configuração de múltiplas fontes |
| `developer-delphi-providers-loggers` | Módulo Loggers — 10 destinos; 5 níveis; ILogger; USE_LOGGERS | Ao implementar logging no projeto |
| `project-open-database-cli` | Acesso CLI a bancos (mysql, sqlite3, isql, psql) | Ao inspecionar ou manipular banco via terminal |
| `project-decompile-chm` | Decompilação de arquivos `.chm` de documentação | Ao precisar extrair conteúdo de CHM |

## Matriz de decisão

| Cenário | Skill |
|---------|-------|
| Qual naming usar para módulo/submodulo? | `developer-delphi-programming-oop-naming` |
| Como garantir que o código é OOP? | `developer-delphi-programming-oop-fluent` |
| Qual naming usar para interface/classe/factory (ORM)? | `documentation-project-expert` |
| Onde fica a camada X no repositório? | `documentation-project-structure` |
| Como compilar o projeto para Win32/Win64? | `developer-delphi-build-toolchain` |
| Como usar USE_FIREDAC ou `{$IFDEF USE_ZEOS}`? | `developer-delphi-programming-conditional-defines` |
| Como fazer um CRUD com o ORM Slim? | `developer-delphi-providers-orm-usage` |
| Como carregar config de INI, JSON ou banco? | `developer-delphi-providers-parameters` |
| Como logar eventos em arquivo, banco ou e-mail? | `developer-delphi-providers-loggers` |
| Como abrir o banco SQLite pelo terminal? | `project-open-database-cli` |
| Preciso extrair docs de um arquivo .chm | `project-decompile-chm` |

## Sequência canônica para novo módulo

```
0. developer-delphi-programming-oop-naming   ← definir naming antes de qualquer implementação
1. documentation-project-expert             ← verificar convenções obrigatórias do ORM
2. developer-delphi-programming-oop-fluent       ← confirmar que o design segue o padrão OOP
3. documentation-project-structure          ← confirmar onde criar os arquivos
4. developer-delphi-programming-conditional-defines ← validar blocos {$IFDEF} se necessário
5. developer-delphi-providers-orm-usage            ← consultar exemplos de uso do ORM
6. developer-delphi-build-toolchain ← compilar e testar
```

## Anti-padrões

| Anti-padrão | Como corrigir |
|-------------|---------------|
| Nomear interface sem prefixo `I` ou implementação sem `T` | Consultar `developer-delphi-programming-oop-naming` antes de nomear |
| Criar submódulo com nome que não segue `TModuloSubclasse` | Consultar `developer-delphi-programming-oop-naming` para hierarquia correta |
| Escrever lógica de negócio em procedure solta | Consultar `developer-delphi-programming-oop-fluent` — toda lógica deve estar em classe |
| Hardcodar nome de tabela em SQL inline | Usar atributo `[Table('nome')]` na classe conforme `developer-delphi-programming-oop-naming` |
| Compilar sem saber os flags corretos | Usar `developer-delphi-build-toolchain` para o comando exato |
| Usar `{$IFDEF}` sem conhecer o ORM.Defines.inc | Consultar `developer-delphi-programming-conditional-defines` primeiro |

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.2.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.2.0 (13/04/2026): Adicionadas `developer-delphi-programming-oop-fluent` e `developer-delphi-programming-oop-naming` — total 11 skills; step 0 na sequência canônica; 2 novas entradas na matriz de decisão; 2 novos anti-padrões OOP.
- 1.1.0 (11/04/2026): Adicionadas `developer-delphi-providers-parameters` e `developer-delphi-providers-loggers` — total 9 skills; description e quick_ref atualizados.
- 1.0.0 (11/04/2026): Criação — skill orquestradora da família `project-*` (7 skills).
- 1.3.0 (24/04/2026): Rename E5a — `project-master-orchestrator` -> `project-master-orchestrator`. Motivo: diferenciar master-orchestrator de sub-orchestrators (regra N3 do plano de refactor).
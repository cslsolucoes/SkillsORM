---
name: developer-delphi-build-toolchain
description: Use when the user asks about compiling the project (Delphi, FPC, Go, Python), build commands, config files (dcc32.cfg, fpc32.opts, go.mod, requirements.txt), or database CLI access (mysql, sqlite3, isql, psql, sqlcmd), paths of tools, or connection config (Data/config.ini, config.json). Canonical docs: .cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md and .cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/database.md.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-build-toolchain
## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Esta skill é a referência canônica para compilação (Delphi, FPC, Go, Python) e acesso a bancos por CLI no **repositório aberto no workspace**. Ela aponta para os documentos de verdade única (`compile.md` e `database.md`) e exige leitura desses arquivos antes de responder com paths, parâmetros ou comandos. Política de paths: **dentro do repo** usar sempre **`${workspaceFolder}/...`** em tarefas/editores; **fora do repo** (FPC, RAD, etc.) caminhos absolutos ou placeholders (`{FPC_ROOT}`). Ela NÃO implementa lógica de negócio, NÃO opera bancos diretamente e NÃO configura diretivas de engine — apenas orienta como compilar e aceder a bancos com os dados locais do workspace.

## When to use

- Usuário pergunta como compilar o projeto (Delphi, FPC, Go ou Python).
- Usuário pergunta sobre parâmetros, arquivos de configuração ou paths de compiladores (dcc32, dcc64, fpc, go, python/pip).
- Usuário pergunta sobre acesso a banco de dados por CLI (MySQL, SQLite, Firebird, PostgreSQL, SQL Server).
- Usuário pergunta sobre paths das ferramentas CLI de banco (mysql, sqlite3, isql, psql, sqlcmd).
- Usuário pergunta sobre configuração de conexão (Data/config.ini, Data/config.json, chaves host/port/database).

## When NOT to use

- Não usar para operar bancos interativamente via terminal → use `project-open-database-cli`.
- Não usar para configurar diretivas `USE_*` ou `{$IFDEF}` de engine/módulo → use `developer-delphi-programming-conditional-defines`.
- Não usar para definir arquitetura de módulos → use `developer-delphi-to-fpc-architecture-and-design`.
- Não usar para diagnosticar erros de compilação ou divergências cross-compiler → use `developer-delphi-to-fpc-build`.

## Inputs

- Tipo de compilador ou banco de dados alvo.
- Nome do arquivo principal (`.dpr`, `.lpr`, `.go`, `.py`).

## Documentos canônicos

| Documento | Caminho | Conteúdo |
|-----------|---------|----------|
| **Compilação** | `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md` | Delphi (dcc32/dcc64, dcc32.cfg, dcc64.cfg), FPC (fpc32.opts, fpc64.opts), Go (go.mod, go build), Python (pyproject.toml, requirements.txt, venv). Paths das ferramentas, como usar cada compilador, tabelas resumo, política de paths em `.vscode/tasks.json` (secção 1.1). |
| **Banco de dados CLI** | `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/database.md` | MySQL (mysql), SQLite (sqlite3), Firebird (isql), PostgreSQL (psql), SQL Server (sqlcmd/MSSqlcmd). Paths das ferramentas, Data/config.ini e config.json, parâmetros de cada cliente, comandos de exemplo. |

## Regra de uso

1. **Ao responder sobre compilação (Delphi, FPC, Go, Python):** ler `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md` e usar os paths, arquivos de config e comandos descritos lá. Não inventar paths ou parâmetros.
2. **Ao responder sobre acesso a banco por CLI ou config de conexão:** ler `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/database.md` e usar os paths (MSSqlcmd, MySQL, SQLite, etc.), arquivos de config (Data/config.ini, config.json) e parâmetros descritos lá.
3. **Ao alterar** compile.md ou database.md (novos paths, novos bancos, novas ferramentas): manter este SKILL.md alinhado à descrição dos documentos (seção "Documentos canônicos" e "When to use").

## Workflow executável

1. Identificar se a pergunta é sobre compilação ou banco de dados CLI.
2. Ler o documento canônico correspondente (`compile.md` ou `database.md`).
3. Responder usando exclusivamente paths, parâmetros e comandos do documento lido.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-programming-conditional-defines` | Antes de compilar, verificar quais engines/módulos estão habilitados em `ORM.Defines.inc` |

## Resumo rápido (não substitui a leitura dos documentos)

- **Compilação:** dcc32/dcc64 usam dcc32.cfg/dcc64.cfg (carregamento automático); FPC usa **@fpc32.opts** / **@fpc64.opts** (obrigatório). Go: go.mod + `go build -o ...`. Python: requirements.txt ou pyproject.toml + venv + pip.
- **VS Code tasks:** qualquer ficheiro sob o workspace → **`${workspaceFolder}/...`**; nunca embutir letra de unidade ou caminho absoluto do clone; absoluto só fora do repo (ex.: FPC instalado, `{FPC_ROOT}` no template).
- **Bancos CLI:** config em Data/config.ini e Data/config.json; chaves host, port, username, password, database, schema, database_type. Paths: sqlcmd (MSSqlcmd), mysql, sqlite3, isql, psql conforme tabela em database.md (seção 1.1 e 8).

Para detalhes exatos (paths completos, exemplos de comando, tabelas comparativas), **sempre consultar** os documentos canônicos acima.

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

## Exemplo mínimo compilável

**Delphi (dcc32 / dcc64):**

```pascal
program SampleCompileDocsDelphi;
{$APPTYPE CONSOLE}
begin
  WriteLn('OK -- developer-delphi-build-toolchain');
end.
```

**Free Pascal (fpc32 / fpc64):**

```pascal
program SampleCompileDocsFPC;
{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}
begin
  WriteLn('OK -- developer-delphi-build-toolchain');
end.
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|------------------|---------------|
| Inventar paths de compiladores sem ler compile.md | Paths incorretos causam falha de build silenciosa | Sempre ler `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md` antes de responder |
| Omitir `@fpc32.opts` / `@fpc64.opts` no FPC | FPC não carrega opções automaticamente; build silenciosamente incompleto | Sempre incluir `@fpc32.opts` ou `@fpc64.opts` na linha de comando FPC |
| Usar paths de database.md desatualizados | Ferramentas CLI podem ter mudado de localização | Ler database.md para obter o path atual antes de responder |
| Responder sobre configuração de conexão sem ler config.ini/config.json | Credenciais ou portas erradas; conexão falha | Consultar `Data/config.ini` e `Data/config.json` para parâmetros reais |
| Alterar compile.md ou database.md sem atualizar este SKILL.md | SKILL.md fica desalinhado com os documentos canônicos | Atualizar a seção "Documentos canônicos" e "When to use" sempre que os docs mudarem |

## Métricas de sucesso

- Toda resposta sobre compilação usa paths e parâmetros lidos de `compile.md`.
- Toda resposta sobre banco CLI usa paths e parâmetros lidos de `database.md`.
- Zero paths ou parâmetros inventados sem base documental.
- `compile.md` e `database.md` alinhados com a descrição neste SKILL.md.

## Responsável principal

| Papel | Quem |
|-------|------|
| Mantenedor dos docs canônicos | Desenvolvedor responsável pelo ambiente de build |
| Usuário da skill | Qualquer desenvolvedor que precise compilar ou acessar banco |

## Referencias

- `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md` (canônico — compilação)
- `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/database.md` (canônico — banco CLI)

## Changelog (este arquivo)

- 1.0.0 (17/04/2026): Onda 3 do refactor — skill renomeada de `project-compile-database-docs_V*` para `developer-delphi-build-toolchain_V1.0.0`. Conteúdo generificado (remoção de referências literais a 'Projeto v2.0 deste clone', paths absolutos, MXX concreto). Versão anterior arquivada em `.cursor/Backup/renamed-skills-20260417/skills/`.

- 1.1.2 (12/04/2026): `compile.md` / `database.md` descaracterizados (sem nome de produto fixo); reforço explícito de **`${workspaceFolder}`** para todo o conteúdo sob o repo; §10 dos exemplos e referências `local_arquivos` em Templates; responsabilidade única e resumo rápido alinhados.
- 1.1.1 (12/04/2026): Política de paths em `.vscode/tasks.json` (`${workspaceFolder}` no repo; absoluto só fora); secção 1.1 em `compile.md`; referências canónicas alinhadas a `_V1.1.0/exemplos/`.
- 1.1.0 (09/04/2026): Migração V2 — adicionados frontmatter `thinking: extended` e `category: developer-delphi`; seções Responsabilidade única, When NOT to use, Dependências (skills prévias), Checklist Delphi+FPC completo (9 itens), Exemplo mínimo compilável (Delphi + FPC), Anti-padrões, Métricas de sucesso, Responsável principal.
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).

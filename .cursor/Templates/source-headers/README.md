# Templates — `source-headers/`

**FolderVersion:** 1.0.0 · **Data:** 16/04/2026

Cabeçalhos padrão para fontes de código. Aplicam-se quando um arquivo novo é criado em `projects/**/*.pas`, `*.dpr` ou `*.lpr`.

## Arquivos

| Template | Linguagem | Uso |
| -------- | --------- | --- |
| `pascal-unit-header.template` | Delphi/FreePascal | Prefixar qualquer unit, program ou library Pascal |

## Placeholders

| Placeholder | Descrição | Exemplo |
| ----------- | --------- | ------- |
| `{UNIT_NAME}` | Nome da unit (sem extensão) | `Providers.Common.SQLBuilder` |
| `{SHORT_DESCRIPTION}` | Descrição curta (1 linha) | `SQL Builder Commons para Provider v1.6.0` |
| `{LONG_DESCRIPTION}` | Descrição detalhada (1-3 parágrafos) | `Construção de SQL específico para cada provider ...` |
| `{FEATURES}` | Lista de características, cada linha prefixada por `  - ` | `  - Templates reutilizáveis\n  - 5 SGBDs suportados` |
| `{PROJECT_NAME}` | Nome canónico do projeto | `ProvidersORM` |
| `{PROJECT_VERSION}` | Versão do projeto (SemVer) | `1.6.0` |
| `{FILE_VERSION}` | Versão do arquivo (SemVer, independente do projeto) | `1.0.0` |
| `{AUTHOR}` | Autor canónico | `Claiton de Souza Linhares` |
| `{DATE}` | Data da primeira versão (formato BR) | `27/01/2025` |
| `{CHANGELOG_ENTRY}` | Descrição curta da primeira entrada | `Criação da unit.` |

## Regra associada

[backend-pascal-source-header_V1.0.0.mdc](../../rules/backend-pascal-source-header_V1.0.0.mdc) — exige o cabeçalho em arquivos Pascal novos em `projects/`.

## Aplicação

Templates de form-units (`{UNIT_NAME}.vcl.pas.template`, `.fmx.pas.template`, `.lcl.pas.template`) e de build-config (`{PROJECT_NAME}.dpr.template`, `.lpr.template`) **prefixam** este cabeçalho — ver cada um desses arquivos no próprio `.template`.

## Changelog

- 1.0.0 (16/04/2026): criação — template `pascal-unit-header.template` e documentação.

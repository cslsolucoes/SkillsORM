---
name: project-init-rules-generator
version: 1.0.0
skill_type: generator
model: sonnet
description: >
  Gera rules Cursor personalizadas para o projeto durante /init.
  Copia os 4 templates de templates/ (dentro desta skill),
  substitui todos os {PLACEHOLDERS} com valores reais coletados da FASE 3
  e de perguntas adicionais, e escreve os arquivos em .cursor/rules/.
  O arquivo projeto-orm_V1.0.mdc só é gerado se o projeto usar ProvidersORM.
triggers:
  - invocada automaticamente ao fim da FASE 3 do /init
  - invocada manualmente para regenerar rules de projeto existente
dependencies:
  - templates: templates/ (dentro desta skill)
  - destino: .cursor/rules/
  - skill-referencia: documentation-project-expert
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# project-init-rules-generator

## Escopo

Gera as 3–4 rules de projeto que ficam **ativas** em `.cursor/rules/` (lidas pelo Cursor em toda interação):

| Rule gerada | Template base | Sempre? |
|-------------|--------------|---------|
| `projeto-paths_V1.0.mdc` | `projeto_paths_V2.0.mdc` | sim |
| `projeto-estrutura_V1.0.mdc` | `projeto_estrutura_V2.0.mdc` | sim |
| `projeto-documentacao_V1.0.mdc` | `projeto_documentacao_V2.0.mdc` | sim |
| `projeto-orm_V1.0.mdc` | `projeto_orm_V2.0.mdc` | só se usa ProvidersORM |

As rules geradas têm `alwaysApply: true` (ou `false` para ORM) e ficam em `.cursor/rules/` — **não** alteram os templates em `.cursor/Templates/`.

---

## Quando usar

- Ao fim da **FASE 3** do comando `/init` (após geração dos arquivos de build)
- Para **regenerar** as rules de um projeto existente (ao mudar pacotes, sub-projetos ou estrutura)
- Para **onboarding** de novo colaborador que clona o repositório

---

## Inputs coletados

### Da FASE 3 do `/init` (já disponíveis)

| Variável | Parâmetro | Exemplo |
|----------|-----------|---------|
| `{PROJECT_NAME}` | P1 | `SkillORM` |
| `{FPC_ROOT}` | P7 | `D:\fpc\fpc` |
| `{LAZARUS_ROOT}` | P8 | `D:\fpc\lazarus` |
| `{FPC_OPM_ROOT}` | P9 | `D:\fpc\config_lazarus\...\packages` |
| `{DATE}` | automático | `12/04/2026` |

### Perguntas adicionais (fazer **uma por mensagem**, aguardar resposta)

**Q1 — Descrição do projeto** *(obrigatória)*
```
O que é o projeto {PROJECT_NAME}?
(Breve descrição — ex.: "ORM para Delphi/FPC com suporte a múltiplos engines SQL")
```

**Q2 — Engines de banco** *(obrigatória)*
```
Quais engines de banco de dados serão usados?
  1 — FireDAC   2 — UniDAC   3 — Zeos   4 — SQLdb   5 — Todos
(Ex.: 1,3 para FireDAC + Zeos · Enter para "a definir")
```

**Q3 — Módulos opcionais** *(obrigatória)*
```
Quais módulos opcionais estão ativos? (separar com vírgula)
  USE_LOGGERS · USE_PARAMENTERS · USE_POOLCONNECTIONS
  USE_ATTRIBUTES · USE_ENTITY_MANAGER · USE_QUERY_BUILDER
(Enter para "a definir")
```

**Q4 — Pasta de pacotes** *(obrigatória)*
```
Qual é a pasta raiz dos pacotes de terceiros?
(Padrão: E:\Pacote · Enter para padrão)
```

**Q5 — Sub-projetos / dependências externas** *(opcional)*
```
O projeto depende de sub-projetos externos? Liste-os no formato:
  NomeProjeto → caminho (ex.: ParamentersORM → E:\CSL\ParamentersORM)
(Enter para pular)
```

**Q6 — Pacotes principais** *(opcional)*
```
Quais pacotes de terceiros são usados? (Enter para preencher depois)
  Exemplos: Indy, Horse, JWT, DataSet-Serialize, UniDAC, DUnitX...
```

**Q7 — Usa ProvidersORM?** *(obrigatória)*
```
O projeto {PROJECT_NAME} consome o ProvidersORM como dependência?
  s — sim (gera projeto-orm_V1.0.mdc com acesso rápido à API)
  n — não
```

---

## Execução passo a passo

### Passo 1 — Coletar inputs

Fazer Q1→Q7 **individualmente**, aguardando resposta antes de prosseguir.
Valores padrão aplicados automaticamente quando o usuário pressiona Enter.

### Passo 2 — Montar tabela de substituição

```
{PROJECT_NAME}              ← P1
{DATE}                      ← data atual (DD/MM/AAAA)
{FPC_ROOT}                  ← P7 ou "D:\fpc\fpc"
{LAZARUS_ROOT}              ← P8 ou "D:\fpc\lazarus"
{FPC_OPM_ROOT}              ← P9 ou "D:\fpc\config_lazarus\...\packages"
{PROJECT_DESCRIPTION}       ← Q1
{DATABASE_ENGINES}          ← Q2 (expandir siglas: "FireDAC, Zeos")
{OPTIONAL_MODULES}          ← Q3 (ex.: "USE_LOGGERS, USE_PARAMENTERS")
{PACKAGES_ROOT}             ← Q4 ou "E:\Pacote"
{SUBPROJECTS}               ← Q5 (formatar como lista markdown)
{DATABASE_PACKAGES}         ← Q6 (seção banco)
{MAIN_PACKAGES}             ← Q6 (seção frameworks)
{TEST_PACKAGES}             ← Q6 (seção testes) ou "DUnitX → {PACKAGES_ROOT}\DUnitX"
{DEPENDENCIES_SECTION}      ← Q5 + Q6 combinados
{PROJECT_MAIN_DOC}          ← "README.md"
{PROJECT_MAIN_DOC_DESCRIPTION} ← "Hub da documentação — índice completo"
```

### Passo 3 — Gerar os arquivos

Para cada template em `templates/` (pasta da skill):

1. Ler conteúdo do template
2. Substituir todos os `{PLACEHOLDER}` pelos valores coletados
3. Escrever em `.cursor/rules/<nome-destino>`

```
projeto_paths_V2.0.mdc       →  .cursor/rules/projeto-paths_V1.0.mdc
projeto_estrutura_V2.0.mdc   →  .cursor/rules/projeto-estrutura_V1.0.mdc
projeto_documentacao_V2.0.mdc→  .cursor/rules/projeto-documentacao_V1.0.mdc
projeto_orm_V2.0.mdc         →  .cursor/rules/projeto-orm_V1.0.mdc  (só se Q7=s)
```

### Passo 4 — Confirmar ao usuário

Listar os arquivos criados em `.cursor/rules/` e informar:
- Quais placeholders foram preenchidos
- Quais ficaram como `{PLACEHOLDER}` (a preencher manualmente depois)
- Se `projeto-orm_V1.0.mdc` foi gerado ou não

---

## Regras de execução

- **Nunca sobrescrever** sem perguntar se o arquivo já existir em `.cursor/rules/`
- **Campos não preenchidos** (`Enter` sem valor): manter o `{PLACEHOLDER}` no arquivo gerado — comentar no início do arquivo: `<!-- TODO: substituir {PLACEHOLDER_NAME} -->`
- **Q5 e Q6 vazios:** usar seção placeholder com comentário `<!-- Preencher manualmente -->`
- **ProvidersORM (Q7=s):** no arquivo `projeto-orm_V1.0.mdc` gerado, os paths `E:\CSL\ProvidersORM\...` ficam **hardcoded** (não são placeholders — são caminhos canônicos do ProvidersORM)

---

## Exemplo de saída (projeto SkillORM)

**Inputs coletados:**
```
PROJECT_NAME    = SkillORM
PROJECT_DESCRIPTION = Biblioteca de skills para projetos Delphi/FPC com suporte ao pack .cursor/
DATABASE_ENGINES    = FireDAC, Zeos
OPTIONAL_MODULES    = USE_LOGGERS, USE_PARAMENTERS
PACKAGES_ROOT       = E:\Pacote
SUBPROJECTS         = ParamentersORM → E:\CSL\ParamentersORM
                      LoggersORM → E:\CSL\LoggersORM
FPC_ROOT            = D:\fpc\fpc
LAZARUS_ROOT        = D:\fpc\lazarus
FPC_OPM_ROOT        = D:\fpc\config_lazarus\onlinepackagemanager\packages
USA_ORM             = n
```

**Arquivos criados:**
```
✓ .cursor/rules/projeto-paths_V1.0.mdc
✓ .cursor/rules/projeto-estrutura_V1.0.mdc
✓ .cursor/rules/projeto-documentacao_V1.0.mdc
  (projeto-orm_V1.0.mdc não gerado — projeto não usa ProvidersORM)
```

---

## Skills relacionadas

| Skill | Relação |
|-------|---------|
| `documentation-project-expert` | Skill de referência para convenções do projeto — invocar após geração das rules |
| `developer-delphi-providers-orm-usage` | Roteiro de uso do ORM — consumido por `projeto-orm_V1.0.mdc` |
| `documentation-rules_creator` | Atualiza rules documentais manualmente |
| `documentation-project-structure` | Template genérico de estrutura de projeto |

---

## Changelog

- 1.0.0 (12/04/2026): Criação — skill de geração de rules de projeto durante `/init`; 4 templates V2.0; placeholders P1–P9 + Q1–Q7; condicional ProvidersORM.

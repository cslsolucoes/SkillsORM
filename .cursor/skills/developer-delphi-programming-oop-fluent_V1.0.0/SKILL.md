---
name: developer-delphi-programming-oop-fluent
description: >
  Padrão transversal obrigatório — toda programação no projeto deve ser orientada a
  objeto com fluência total. Usar ao criar qualquer unidade de lógica de negócio,
  serviço, repositório ou camada de aplicação. Garante que procedures soltas, código
  global e lógica não encapsulada sejam substituídos por classes, interfaces e
  fluent builders com terminal .Execute.
model: sonnet
thinking: normal
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Project OOP Standard

## Responsabilidade única

Garantir que **todo** código de negócio do projeto seja orientado a objeto com **fluência total**. Esta skill define o padrão transversal que se aplica a qualquer unit de domínio, serviço, repositório ou camada de aplicação. É a referência normativa consultada antes de criar qualquer unit de lógica de negócio.

---

## Regras obrigatórias

| Regra | Descrição |
| --- | --- |
| **Encapsulamento em classe** | Toda lógica de negócio vive dentro de uma classe — nunca em procedures ou functions soltas |
| **Interfaces definem contratos** | `I*` define o contrato público; `T*` implementa — código consumidor só conhece a interface |
| **Factory obrigatória** | Toda classe expõe `class function New: IInterface` como único ponto de criação |
| **Fluência total** | Toda operação de negócio usa fluent builder — `.OperacaoVerb.WithXxx.Execute` |
| **Sem variáveis globais** | Estado de negócio nunca é global — pertence à instância |
| **Sem procedures de domínio** | Procedures soltas são proibidas para lógica de negócio |
| **Campos privados** | Campos `F*` sempre `private`; acesso externo via `property` ou método público |

---

## Fluência Total — Fluent Builder (obrigatório)

Toda operação de negócio expõe um fluent builder terminado em `.Execute`. Padrão canônico:

```pascal
// 1. Factory — cria a instância do serviço principal
var Auth: IAuthService;
Auth := TAuthService.New(ARepo, AJwt, AObac);

// 2. Operação fluente — encadeia parâmetros até .Execute
var Result: TLoginResult;
Result := Auth
  .Login
  .WithEmail('dev@gestorerp.local')
  .WithPassword('Dev@123')
  .WithMachine('DEV-PC')
  .Execute;

// 3. Audit fluente
TAudit.Writer.New
  .LogAccess
  .WithContext(ACtx)
  .WithModule('M01')
  .WithAction('Login')
  .WithResult('OK')
  .Execute;
```

### Anatomia do fluent builder

| Elemento | Tipo retornado | Descrição |
| --- | --- | --- |
| `TXxx.New(deps)` | `IXxx` | Factory principal — cria a instância |
| `.OperacaoVerb` | `IOperacaoBuilder` | Inicia um sub-builder para a operação |
| `.WithXxx(valor)` | `IOperacaoBuilder` | Parâmetro fluente — retorna Self (encadeável) |
| `.Execute` | Tipo de resultado | Terminal — executa e retorna o resultado |

### Interfaces companion (.Interfaces.pas)

O `.Interfaces.pas` companion de uma classe contém:
- A **interface principal** da classe (`IAuthService`)
- Todos os **builder interfaces** usados por ela (`ILoginBuilder`, `IRefreshBuilder`, `ILogoutBuilder`, `IValidateTokenBuilder`)

```pascal
// Commons.Security.Service.Auth.Interfaces.pas
ILoginBuilder = interface
  function WithEmail(const AEmail: string): ILoginBuilder;
  function WithPassword(const APassword: string): ILoginBuilder;
  function WithMachine(const AMachine: string): ILoginBuilder;
  function Execute: TLoginResult;
end;

IAuthService = interface
  function Login: ILoginBuilder;
  function Refresh: IRefreshBuilder;
  function Logout: ILogoutBuilder;
  function ValidateToken: IValidateTokenBuilder;
end;
```

---

## Sub-fábricas (para classes com múltiplas responsabilidades)

Quando uma classe coordena múltiplos sub-domínios, usar sub-fábricas aninhadas:

```pascal
// Coordenador: TAudit.New inicia Writer e Reader
TAudit.New;                  // inicia Writer + Reader

// Sub-fábricas independentes:
TAudit.Writer.New            // retorna IAuditWriter
  .LogAccess
  .WithModule('M01')
  .Execute;

TAudit.Reader.New            // retorna IAuditReader (Onda futura)
  .ListPaged
  .WithFilter(AFilter)
  .Execute;
```

Cada sub-fábrica tem seu próprio par `*.pas` + `*.Interfaces.pas`:
- `Commons.Audit.Writer.pas` + `Commons.Audit.Writer.Interfaces.pas`
- `Commons.Audit.Reader.pas` + `Commons.Audit.Reader.Interfaces.pas`

---

## O que é OOP + Fluência neste projeto

| Permitido | Proibido |
| --- | --- |
| `TAuthService.New(repo, jwt).Login.WithEmail(e).Execute` | `function ValidarLogin(email, senha: string): Boolean;` solta |
| `ILoginBuilder.WithEmail(...): ILoginBuilder` | `procedure Login(var result: TLoginResult)` com out-param |
| `class function New: IXxx` como único construtor | `TXxx.Create` chamado diretamente pelo consumidor |
| `.Execute` sempre terminal da operação | Método que retorna resultado SEM terminal `.Execute` |
| Sub-fábrica `TAudit.Writer.New` | Método `TAudit.WriteLog(...)` sem fluência |

---

## When to use

- Ao criar qualquer unit de domínio, serviço, repositório ou controller
- Ao definir interfaces em `.Interfaces.pas` companions
- Como referência normativa antes de iniciar qualquer módulo MXX

## When NOT to use

- Utilitários puramente funcionais sem estado (funções matemáticas, conversores de string)
- UI/Formulários (`src/Views`) — seguem regra específica
- Units de constantes ou tipos simples sem comportamento

---

## Checklist de validação

- [ ] Toda classe expõe `class function New: IXxx`?
- [ ] Toda operação de negócio usa `.OperacaoVerb.WithXxx.Execute`?
- [ ] `.Interfaces.pas` contém interface principal + todos os builders?
- [ ] Sub-fábricas têm seus próprios `*.pas` + `*.Interfaces.pas`?
- [ ] Nenhuma procedure solta com lógica de negócio?
- [ ] Nenhum `TXxx.Create` chamado diretamente pelo consumidor?

## Dependências

- `developer-delphi-to-fpc-language-oop_V1.1.0` — sintaxe OOP Delphi
- `developer-delphi-programming-oop-naming_V1.0.0` — convenção de nomenclatura
- `backend-pascal-unit-naming_V1.2.0` — naming canônico de units

## Skills relacionadas

- `developer-delphi-modular-backend-scaffold_V1.0.0` — scaffold completo de módulo MXX
- `developer-delphi-to-fpc-patterns-creational_V1.1.0` — padrões Factory/Builder
- `project-master-orchestrator_V1.2.0` — orquestrador da família project-*

---

## Versão interna (arquivo)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.0.0 (17/04/2026): Onda 3 do refactor — skill renomeada de `project-oop-standard_V*` para `developer-delphi-programming-oop-fluent_V1.0.0`. Conteúdo generificado (remoção de referências literais a 'Projeto v2.0 deste clone', paths absolutos, MXX concreto). Versão anterior arquivada em `.cursor/Backup/renamed-skills-20260417/skills/`.

- 1.1.0 (15/04/2026): Adicionada seção "Fluência Total — Fluent Builder" com anatomia completa do padrão `.New.Op.WithXxx.Execute`; adicionada seção "Sub-fábricas" (`TAudit.Writer.New`, `TAudit.Reader.New`); atualizado checklist; interfaces companion agora documentam que carregam todos os builders da classe.
- 1.0.0 (13/04/2026): Criação — padrão transversal OOP obrigatório.
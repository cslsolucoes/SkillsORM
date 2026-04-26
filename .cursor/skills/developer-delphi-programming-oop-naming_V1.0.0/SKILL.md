---
name: developer-delphi-programming-oop-naming
description: >
  Convenção de nomenclatura OOP para módulos e submódulos Delphi: TModulo/IModulo,
  prefixo Commons. em Commons/, Controllers (não EntryPoint), fluent builder interfaces
  (IOperacaoBuilder). Escopo: apenas código Delphi (backend + módulos ORM).
model: sonnet
thinking: normal
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Project OOP Class Naming

## Responsabilidade única

Definir e aplicar a convenção de nomenclatura OOP para classes, interfaces e units Delphi do projeto. Garante que módulos mestres e submódulos sigam a hierarquia `TModulo / TModuloSubclasse`, que files em `Commons/` usem prefixo `Commons.`, que controllers usem `Controller` (não `EntryPoint`), e que fluent builders nomeiem suas interfaces conforme o padrão.

**Escopo:** apenas código Delphi (backend `projects/backend/` e módulos ORM em `projects/modules/`).

---

## Regra central — hierarquia de dois níveis

```text
Módulo master:   IModulo / TModulo
Submódulo:       IModuloSubclasse / TModuloSubclasse
Builder:         IOperacaoBuilder / TOperacaoBuilder
```

---

## Tabela de nomenclatura

| Artefato | Padrão | Exemplo |
| --- | --- | --- |
| Interface do módulo master | `IModulo` | `IAuthService` |
| Classe do módulo master | `TModulo` | `TAuthService` |
| Factory do módulo master | `TModulo.New: IModulo` | `TAuthService.New: IAuthService` |
| Interface do submódulo | `IModuloSubclasse` | `ILoginBuilder` |
| Classe do submódulo | `TModuloSubclasse` | `TLoginBuilder` |
| Factory do submódulo | `TModuloSubclasse.New: IModuloSubclasse` | `TLoginBuilder.New: ILoginBuilder` |
| Interface do controller | `IXxxController` | `IAuthController` |
| Classe do controller | `TXxxController` | `TAuthController` |
| Unit — módulo master | `ModuloConcept.Feature.pas` | `Commons.Security.Service.Auth.pas` |
| Unit — controller | `Access.Controller.Xxx.pas` | `Access.Controller.Auth.pas` |
| Unit — interfaces companion | `ModuloConcept.Feature.Interfaces.pas` | `Commons.Security.Service.Auth.Interfaces.pas` |

---

## Prefixo Commons. — obrigatório em Commons/

Todo arquivo que vive em `Commons/` usa `Commons.` como primeiro segmento:

```
Commons.Security.Domain.Entities.pas
Commons.Security.Domain.Types.pas
Commons.Access.Auth.Jwt.pas
Commons.Security.Service.Auth.pas
Commons.Security.Service.Obac.pas
Commons.Audit.Writer.pas
Commons.Message.Response.pas
```

Nunca `Security.Domain.Entities.pas` para um arquivo em `Commons/`.

---

## Controllers — sempre `Controller`, nunca `EntryPoint`

```pascal
// CORRETO
Access.Controller.Auth.pas         // TAuthController
Access.Controller.Users.pas        // TUsersController
Access.Controller.ServerMain.pas   // TServerMain (TRESTDWIdServicePooler)

// PROIBIDO
Access.EntryPoint.Auth.pas         // ← obsoleto
Access.Entry.Auth.pas              // ← incorreto
```

---

## Fluent Builder — naming das interfaces

Cada operação fluente tem sua interface nomeada como `IOperacaoBuilder`:

```pascal
ILoginBuilder = interface    // OperacaoVerb = Login → ILoginBuilder
  function WithEmail(...): ILoginBuilder;
  function WithPassword(...): ILoginBuilder;
  function Execute: TLoginResult;
end;

IRefreshBuilder = interface
  function WithToken(...): IRefreshBuilder;
  function Execute: TTokenResult;
end;
```

Todos os builders de uma classe ficam no `.Interfaces.pas` companion da classe principal:
- `Commons.Security.Service.Auth.Interfaces.pas` contém: `IAuthService` + `ILoginBuilder` + `IRefreshBuilder` + `ILogoutBuilder`

---

## Exemplos concretos do GestorERP — M01

| Conceito | Interface | Classe | Unit |
| --- | --- | --- | --- |
| Auth service | `IAuthService` | `TAuthService` | `Commons.Security.Service.Auth.pas` |
| Login builder | `ILoginBuilder` | `TLoginBuilder` | (em `Auth.Interfaces.pas`) |
| OBAC engine | `IOBACService` | `TOBACService` | `Commons.Security.Service.Obac.pas` |
| JWT utility | `IJwtService` | `TJwtService` | `Commons.Access.Auth.Jwt.pas` |
| Audit writer | `IAuditWriter` | `TAuditWriter` | `Commons.Audit.Writer.pas` |
| User repository | `IUserRepository` | `TUserRepository` | `Security.Repository.User.pas` |
| Auth controller | `IAuthController` | `TAuthController` | `Access.Controller.Auth.pas` |
| Bootstrap | `IBootstrap` | `TBootstrap` | `MainService.pas` (in `Core/`) |

---

## Regra de mapeamento DB — Atributos obrigatórios

Toda classe que mapeia uma tabela de banco de dados **deve** declarar o mapeamento via atributo:

```pascal
[Table('Users')]
TUserEntity = class(TInterfacedObject, IUserEntity)
  [Column('Id')]
  FId: string;
  [Column('Email')]
  FEmail: string;
end;
```

Regra de preferência: **atributo na classe > configuração externa > hardcoded**

---

## Regras de factory

- `class function New: IModulo` — único ponto de criação
- `class function New(deps): IModulo` — quando há dependências injetadas
- Nunca chamar `TXxx.Create` diretamente fora da factory
- Sub-fábricas: `TAudit.Writer.New: IAuditWriter` / `TAudit.Reader.New: IAuditReader`

---

## Canonical Pascal File Naming (MXX)

Authority rule: `.cursor/rules/backend-pascal-unit-naming_V1.2.0.mdc`

Key rules:
- `Commons/` files → `Commons.<Concept>.<SubClass>.<Feature>.pas`
- Controllers → `Access.Controller.Xxx.pas`
- No module prefix in file names (`Seguranca.Backend.dpr`, not `M01.Seguranca.Backend.dpr`)
- `X.Interfaces.pas` can only exist if `X.pas` exists as its base

---

## `.cursor/` Artifact Naming

| Artifact type | Format |
|---|---|
| Rules | `<kebab-name>_Vx.y.z.mdc` |
| Skills | `<kebab-name>_Vx.y.z/SKILL.md` |
| Agents | `<kebab-name>_Vx.y.z.md` |

Cross-reference: `.cursor/rules/backend-pascal-unit-naming_V1.2.0.mdc`.

---

## When to use

- Ao criar qualquer classe, interface, builder ou unit Delphi nova
- Antes de nomear um serviço, repositório, controller ou builder
- Ao mapear entidades de banco de dados

## When NOT to use

- Código Vue.js/JavaScript
- Classes de infraestrutura sem contrato de domínio
- Units de constantes ou tipos sem comportamento

## Dependências

- `developer-delphi-programming-oop-fluent_V1.0.0` — padrão OOP + fluência total
- `developer-delphi-to-fpc-language-oop_V1.1.0` — sintaxe Delphi
- `backend-pascal-unit-naming_V1.2.0` — naming canônico de units (rule)

## Skills relacionadas

- `developer-delphi-modular-backend-scaffold_V1.0.0` — scaffold de módulo MXX
- `documentation-project-expert_V1.0.0` — convenções ORM complementares
- `developer-delphi-to-fpc-patterns-creational_V1.1.0` — padrões Factory/Builder

---

## Versão interna (arquivo)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.0.0 (17/04/2026): Onda 3 do refactor — skill renomeada de `project-oop-class-naming_V*` para `developer-delphi-programming-oop-naming_V1.0.0`. Conteúdo generificado (remoção de referências literais a 'Projeto v2.0 deste clone', paths absolutos, MXX concreto). Versão anterior arquivada em `.cursor/Backup/renamed-skills-20260417/skills/`.

- 1.1.0 (15/04/2026): Adicionado prefixo obrigatório `Commons.` para arquivos em `Commons/`; renomeado Controllers (de `EntryPoint` para `Controller`); adicionada convenção de naming para fluent builders (`IOperacaoBuilder`); atualizada tabela de exemplos M01; referência a rule V1.2.0.
- 1.0.0 (13/04/2026): Criação — convenção TModulo/IModulo/TModuloSubclasse + atributos [Table] para mapeamento DB.

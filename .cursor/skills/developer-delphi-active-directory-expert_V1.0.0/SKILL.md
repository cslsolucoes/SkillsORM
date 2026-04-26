---
name: developer-delphi-active-directory-expert
description: Referência arquitetural do módulo ActiveDirectoryORM — IActiveDirectoryConnection (fluent builder), IActiveDirectoryService (auth/queries/write), TLDAPConfig, TActiveDirectoryHelper, hierarquia de exceções EAD* (40000-40006), constantes de porta/objectClass/atributos, diretiva USE_LDAP, ADRs. Usar antes de implementar qualquer código de integração LDAP/AD.
model: opus
thinking: extended
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

> **Path resolution:** o path real de `{ACTIVE_DIRECTORY_ORM_ROOT}` é lido de `.cursor/config.json._frameworks.activeDirectoryORM.installPath` (default `E:/CSL/ActiveDirectoryORM`). Override local opcional em `.workspace/context.json._frameworks_overrides.activeDirectoryORM`.

# developer-delphi-active-directory-expert

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Esta skill é a referência arquitetural do módulo ActiveDirectoryORM. Cobre interfaces públicas, padrões obrigatórios (Factory + Fluent Builder), hierarquia de exceções, constantes, helpers e decisões de arquitetura (ADRs). Não cobre roteiros passo-a-passo nem mapa de arquivos — essas responsabilidades pertencem às skills `developer-delphi-active-directory-roteiro` e `developer-delphi-active-directory-estrutura`.

## When to use

- Implementar qualquer código que use o módulo ActiveDirectoryORM
- Verificar quais métodos existem em IActiveDirectoryConnection ou IActiveDirectoryService
- Consultar hierarquia de exceções EAD* e seus códigos de erro
- Entender quais constantes usar (portas, objectClass, atributos LDAP)
- Verificar quais ADRs governam decisões de arquitetura (Synapse, SSL obrigatório em ChangePassword)
- Consultar o que USE_LDAP ativa vs. o que está sempre disponível

## When NOT to use

- Exemplos de código passo-a-passo → `developer-delphi-active-directory-roteiro`
- Localizar arquivos no repositório → `developer-delphi-active-directory-estrutura`
- Padrões gerais Delphi (Fluent, Factory, I/T naming) → `developer-delphi-to-fpc-architecture-and-design`

## Dependências (skills prévias)

| Skill | Quando executar antes |
| --- | --- |
| `developer-delphi-active-directory-estrutura` | Para confirmar paths antes de citar units |

## Arquitetura — 4 camadas

```
Camada 4 — Views
  ufrmActiveDirectoryTeste  ← sempre disponível
  ufrmLDAP_Teste            ← USE_LDAP only

Camada 3 — LDAP Service
  TActiveDirectoryService   ← USE_LDAP only (Synapse + ldapsend.pas)

Camada 2 — Core
  IActiveDirectoryConnection ← fluent config contract
  TActiveDirectoryConnection ← implementação do builder
  TActiveDirectory           ← factory (TActiveDirectory.New)

Camada 1 — Commons
  TLDAPConfig               ← record de configuração (10 campos)
  TLDAPEntry                ← entrada LDAP retornada por queries
  TActiveDirectoryHelper    ← métodos utilitários (filters, attributes, DN)
  Hierarquia EAD*           ← exceções centralizadas
  Constantes                ← portas, objectClass, atributos LDAP
```

**Fonte canônica:** `{ACTIVE_DIRECTORY_ORM_ROOT}/src/`

**Localização de produção:** `{BACKEND_ROOT}/src/Infrastructure/Integrations/ActiveDirectory/`

## Diretiva USE_LDAP

| O que ativa | O que está sempre disponível (sem diretiva) |
| --- | --- |
| `TActiveDirectoryService` | `IActiveDirectoryConnection` |
| `ufrmLDAP_Teste` | `TActiveDirectoryConnection` |
| Dependência do Synapse | `TActiveDirectory` (factory) |
| | Toda a camada Commons |

Ativação: `{$DEFINE USE_LDAP}` em `ORM.Defines.inc`.

## IActiveDirectoryConnection — Fluent Builder

Fonte: `src/Main/ActiveDirectory.Main.Interfaces.pas`

Todos os setters retornam `Self` (fluent). Extrair config final com `GetConfig`.

| Método | Tipo retorno | Descrição |
| --- | --- | --- |
| `Host(Value: string)` | Self | Servidor LDAP (obrigatório) |
| `Port(Value: Integer)` | Self | Porta (padrão: 389) |
| `BaseDN(Value: string)` | Self | DN base de busca |
| `BaseAuth(Value: string)` | Self | DN da conta de serviço |
| `Username(Value: string)` | Self | Usuário para autenticação |
| `Password(Value: string)` | Self | Senha |
| `UseSSL(Value: Boolean)` | Self | LDAPS (ajusta porta automaticamente) |
| `TimeOut(Value: Integer)` | Self | Timeout em segundos (padrão: 30) |
| `Version(Value: Integer)` | Self | Versão LDAP: 2 ou 3 (padrão: 3) |
| `AddSearchOU(Value: string)` | Self | Adiciona OU de busca (sem duplicatas) |
| `AddSearchOU(Value: TStringList)` | Self | Adiciona OUs de TStringList |
| `AddSearchOU(Value: TJSONArray)` | Self | Adiciona OUs de JSON array |
| `AddSearchOU(Value: TJSONObject)` | Self | Adiciona OUs de JSON object |
| `GetConfig` | `TLDAPConfig` | Extrai configuração como record |
| `SetConfig(Value: TLDAPConfig)` | Self | Substitui toda a configuração |
| `SetConfig(Value: TStringList)` | Self | Carrega de TStringList Chave=Valor |
| `SetConfig(Value: TJSONArray)` | Self | Carrega de JSON array |
| `SetConfig(Value: TJSONObject)` | Self | Carrega de JSON object |

**Factory:** `TActiveDirectory.New` retorna `IActiveDirectoryConnection`.

## IActiveDirectoryService — Operações LDAP

Fonte: `src/ActiveDirectory.Service.pas` — requer `{$DEFINE USE_LDAP}`

**Conexão:**

| Método | Retorno | Descrição |
| --- | --- | --- |
| `Connect` | Boolean | Conecta ao servidor LDAP |
| `Disconnect` | — | Desconecta |
| `TestConnection` | Boolean | Connect + Bind com BaseAuth/Password |

**Autenticação:**

| Método | Retorno | Descrição |
| --- | --- | --- |
| `Authenticate(Username, Password: string)` | Boolean | Busca em SearchOUs (cn/DN/sAMAccountName/UPN) + Bind |
| `AuthenticateUser(UserDN, Password: string)` | Boolean | Bind direto por DN completo |

**Consulta:**

| Método | Retorno | Descrição |
| --- | --- | --- |
| `SearchObjects(Filter: string; Attributes: TStringList)` | TObjectList | Busca com filtro LDAP |
| `SearchWithCustomFilter(Filter: string; Attributes: TStringList)` | TObjectList | Busca com filtro livre |
| `ListContainerObjects(ContainerDN: string)` | TObjectList | Lista objetos de um container/OU |
| `ListGroups(SearchOUs: TStringList)` | TObjectList | Lista grupos nas OUs especificadas |
| `GetGroupMembers(GroupDN: string)` | TStringList | Membros de um grupo (atributo member) |
| `GetObjectAttributes(ObjectDN: string; Attributes: TStringList)` | TStringList | Atributos de um objeto específico |

**Escrita (requer Connect + BindAsAdmin):**

| Método | Retorno | Descrição |
| --- | --- | --- |
| `SetAttributeValue(ObjectDN, Attribute, Value: string)` | Boolean | MO_Replace: substituir valor |
| `AddAttributeValue(ObjectDN, Attribute, Value: string)` | Boolean | MO_Add: adicionar valor |
| `DeleteAttributeValue(ObjectDN, Attribute, Value: string)` | Boolean | MO_Delete: remover valor |
| `SetAttributes(ObjectDN: string; Attributes: TStringList)` | Boolean | Múltiplos atributos de uma vez |
| `AddObject(ParentDN, CN: string; Attributes: TStringList)` | Boolean | Criar objeto AD |
| `DeleteObject(ObjectDN: string)` | Boolean | Remover objeto AD |
| `RenameObject(ObjectDN, NewCN: string)` | Boolean | ModifyDN |
| `AddMemberToGroup(GroupDN, MemberDN: string)` | Boolean | Adiciona ao atributo member |
| `RemoveMemberFromGroup(GroupDN, MemberDN: string)` | Boolean | Remove do atributo member |
| `ChangePassword(UserDN, OldPassword, NewPassword: string)` | Boolean | Requer UseSSL=True + UTF-16LE |

**Serialização:**

| Método | Retorno | Descrição |
| --- | --- | --- |
| `ToJSON(Entry: TLDAPEntry)` | TJSONObject | Serializa entrada LDAP para JSON |
| `ToJSONArray(Entries: TObjectList)` | TJSONArray | Serializa lista de entradas |

## TLDAPConfig — Record de Configuração

Fonte: `src/Commons/ActiveDirectory.Types.pas`

| Campo | Tipo | Padrão | Descrição |
| --- | --- | --- | --- |
| `Host` | string | '' | Servidor LDAP (obrigatório) |
| `Port` | Integer | 389 | Porta de conexão |
| `BaseDN` | string | '' | DN base de busca |
| `BaseAuth` | string | '' | DN da conta de serviço |
| `Username` | string | '' | Usuário para autenticação |
| `Password` | string | '' | Senha |
| `UseSSL` | Boolean | False | Usar LDAPS (636) |
| `TimeOut` | Integer | 30 | Timeout em segundos |
| `Version` | Integer | 3 | Versão do protocolo LDAP |
| `SearchOUs` | TStringList | nil | OUs de busca (caller cria e libera) |

**Nota:** `SearchOUs` usa semântica de referência — o caller é responsável por criar e liberar a TStringList.

## TActiveDirectoryHelper — Métodos Utilitários

Fonte: `src/Commons/ActiveDirectory.Helpers.pas`

**Grupo 1 — Filtros LDAP:**

| Método | Descrição |
| --- | --- |
| `EscapeFilterValue(Value: string)` | Escapa caracteres especiais LDAP |
| `BuildFilter(Attribute, Value: string)` | Cria filtro simples `(attr=value)` |
| `BuildFilterWithObjectClass(ObjectClass, Attribute, Value: string)` | Filtro com objectClass |
| `BuildFilterMultiple(Attributes: TStringList)` | Filtro OR com múltiplos atributos |
| `BuildFilterMultipleObjectTypes(ObjectClasses: TStringList)` | Filtro OR com múltiplas classes |
| `BuildUserSearchFilter(SearchValue: string)` | Filtro de busca de usuário (cn/DN/SAM/UPN) |

**Grupo 2 — Atributos padrão:**

| Método | Descrição |
| --- | --- |
| `AddDefaultAttributesForSearch(Attributes: TStringList)` | Atributos básicos de busca |
| `AddDefaultAttributesForDetailedSearch(Attributes: TStringList)` | Atributos detalhados |
| `AddDefaultAttributesForGroup(Attributes: TStringList)` | Atributos de grupo |
| `AddDefaultAttributesForUserSearch(Attributes: TStringList)` | Atributos de busca de usuário |
| `AddDefaultAttributesForOU(Attributes: TStringList)` | Atributos de OU |

**Grupo 3 — DN e utilitários:**

| Método | Descrição |
| --- | --- |
| `GetCommonName(DN: string)` | Extrai CN do DN completo |
| `GetAttributeFromDN(DN, AttributeType: string)` | Extrai atributo específico do DN |
| `ValidateDN(DN: string)` | Valida formato do DN (lança EADValidationException se inválido) |
| `GetAttributeValueFromList(Attributes: TStringList; AttributeName: string)` | Busca valor em lista |
| `GetObjectClassFromAttributes(Attributes: TStringList)` | Obtém objectClass de lista |
| `FormatObjectInfo(Entry: TLDAPEntry)` | Formata entrada LDAP para exibição |

## Hierarquia de Exceções EAD*

Fonte: `src/Commons/ActiveDirectory.Exceptions.pas`

Todas as exceções herdam de `EADException` que expõe propriedade `ErrorCode: Integer`.

| Classe | Código | Quando é lançada |
| --- | --- | --- |
| `EADException` | — | Classe base (não lançada diretamente) |
| `EADConnectionException` | 40001 | Falha ao conectar ao servidor LDAP |
| `EADAuthenticationException` | 40002 | Credenciais inválidas, Bind falhou |
| `EADValidationException` | 40003 | Porta inválida (fora 1–65535), TimeOut < 0, Version ≠ 2 ou 3, DN inválido, parâmetros nil |
| `EADNotFoundException` | 40004 | Objeto não encontrado no AD |
| `EADConfigurationException` | 40005 | Host vazio, configuração inválida |
| `EADWriteException` | 40006 | Falha em operação de escrita, ChangePassword sem UseSSL=True |

**Código base:** `ERR_LDAP_BASE = 40000` (fonte: `src/Commons/ActiveDirectory.Consts.pas`)

## Constantes-chave

Fonte: `src/Commons/ActiveDirectory.Consts.pas`

**Portas:**

| Constante | Valor | Uso |
| --- | --- | --- |
| `LDAP_PORT_DEFAULT` | 389 | Conexão padrão (sem SSL) |
| `LDAPS_PORT_DEFAULT` | 636 | Conexão SSL/TLS (LDAPS) |

**objectClass values:**

| Constante | Valor LDAP |
| --- | --- |
| `LDAP_OBJECTCLASS_USER` | `'user'` |
| `LDAP_OBJECTCLASS_COMPUTER` | `'computer'` |
| `LDAP_OBJECTCLASS_GROUP` | `'group'` |
| `LDAP_OBJECTCLASS_PERSON` | `'person'` |
| `LDAP_OBJECTCLASS_OU` | `'organizationalUnit'` |

**Atributos LDAP comuns:**

| Constante | Valor LDAP |
| --- | --- |
| `LDAP_ATTR_DN` | `'distinguishedName'` |
| `LDAP_ATTR_CN` | `'cn'` |
| `LDAP_ATTR_SAM` | `'sAMAccountName'` |
| `LDAP_ATTR_UPN` | `'userPrincipalName'` |
| `LDAP_ATTR_OBJECTCLASS` | `'objectClass'` |
| `LDAP_ATTR_MEMBER` | `'member'` |
| `LDAP_ATTR_MEMBEROF` | `'memberOf'` |
| `LDAP_ATTR_NAME` | `'name'` |
| `LDAP_ATTR_DESCRIPTION` | `'description'` |

## ADRs — Decisões de Arquitetura

| ADR | Decisão | Impacto no código |
| --- | --- | --- |
| DA-01 | Synapse como engine LDAP única (ldapsend.pas) | USE_LDAP obrigatório; sem suporte a outras libs |
| DA-02 | Fluent Builder via interface | Config sempre via IActiveDirectoryConnection, não TActiveDirectoryConnection diretamente |
| DA-03 | TLDAPConfig como record | Semântica de valor; SearchOUs é exceção (referência — caller gerencia lifetime) |
| DA-04 | ChangePassword requer UseSSL=True | AD obriga LDAPS para alteração de senha; EADWriteException (40006) se violado |
| DA-05 | Canônico movido para backend-delphi | Sandbox apenas para referência; produção em Infrastructure/Integrations/ActiveDirectory/ |
| DA-06 | VerifyCert=False em LDAPS | Certificados AD internos auto-assinados; não alterar sem acordo de infra |

## Estrutura de pastas

```
{ACTIVE_DIRECTORY_ORM_ROOT}/
├── src/
│   ├── ActiveDirectory.Service.pas     ← TActiveDirectoryService (USE_LDAP)
│   ├── Core/
│   │   ├── ActiveDirectory.Main.Interfaces.pas  ← IActiveDirectoryConnection
│   │   └── ActiveDirectory.Main.pas             ← TActiveDirectoryConnection, TActiveDirectory
│   └── Commons/
│       ├── ActiveDirectory.Types.pas       ← TLDAPConfig, TLDAPEntry
│       ├── ActiveDirectory.Consts.pas      ← constantes e ERR_LDAP_BASE
│       ├── ActiveDirectory.Exceptions.pas  ← hierarquia EAD*
│       ├── ActiveDirectory.Helpers.pas     ← TActiveDirectoryHelper
│       └── ActiveDirectory.Attributers.pas
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| --- | --- | --- |
| `ChangePassword` sem `UseSSL(True)` | AD recusa alteração de senha sem LDAPS; EADWriteException (40006) | Sempre UseSSL(True) + porta 636 antes de ChangePassword |
| Usar 389 ou 636 hardcoded no código | Quebra ao mudar porta; elimina rastreabilidade | Usar `LDAP_PORT_DEFAULT` / `LDAPS_PORT_DEFAULT` |
| Acessar units `src/Commons/` ou `src/Main/` diretamente em Views | Viola separação de camadas | Usar somente via IActiveDirectoryConnection / IActiveDirectoryService |
| Ignorar `ValidateDN` antes de operações de escrita | EADValidationException não tratada em runtime | Chamar `TActiveDirectoryHelper.ValidateDN(DN)` antes de SetAttributeValue/AddObject/etc. |

## Métricas de sucesso

- Nenhum método ou constante citado que não exista em `01-API-Nucleo.md` ou `03-Commons.md`
- Zero ocorrências de port hardcoded (389/636) no código fora de constantes
- Zero units de `src/Commons/` referenciadas diretamente em `src/Views/`
- ChangePassword sempre acompanhado de UseSSL=True na mesma configuração

## Responsável principal

| Papel | Quem |
| --- | --- |
| Executor | Desenvolvedor integração AD |
| Revisor | `developer-delphi-active-directory-orchestrator` |

---

## Changelog (este arquivo)

- 1.0.1 (17/04/2026): Onda 5 do refactor — paths hardcoded substituidos por placeholders `{ACTIVE_DIRECTORY_ORM_ROOT}` / `{REST_DATAWARE_ROOT}` resolvidos via `.cursor/config.json._frameworks`.

- 1.0.0 (12/04/2026): Criação — skill expert da família developer-delphi-active-directory-*.

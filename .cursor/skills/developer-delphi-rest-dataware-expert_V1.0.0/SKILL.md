---
name: developer-delphi-rest-dataware-expert
description: Arquitetura, APIs e componentes do framework REST DataWare (RDW) V2.1. Cobre as 5 camadas (Transport/Core/Database/Utils/Plugins), 11 componentes principais, 5 transportes HTTP, 9 drivers de banco, segurança JWT/OAuth2/AES-256, hierarquia de exceções eRESTDWException (12 classes), diretivas uRESTDW.inc e 6 ADRs. Fonte canônica: Documentation/Arquitetura/.
model: opus
thinking: extended
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-rest-dataware-expert

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Arquitetura completa, APIs e componentes do framework REST DataWare V2.1. Não contém exemplos de código — ver `developer-delphi-rest-dataware-roteiro`.

## When to use

- Entender a arquitetura das 5 camadas do RDW
- Conhecer interfaces, componentes e hierarquia de exceções
- Selecionar transporte HTTP (Indy, ICS, FpHttp, LAMW) ou driver de banco
- Entender fluxo de segurança JWT, OAuth2, AES-256
- Configurar diretivas de compilação em `uRESTDW.inc`
- Consultar ADRs e anti-padrões antes de implementar

## When NOT to use

- Exemplos práticos de código → `developer-delphi-rest-dataware-roteiro`
- Localização de arquivos → `developer-delphi-rest-dataware-estrutura`
- Active Directory / LDAP → `developer-delphi-active-directory-expert`

## Documentos canônicos

| Documento | Conteúdo |
| --- | --- |
| `app/modules/REST-DataWare/Documentation/Arquitetura/Arquitetura_RESTDataWare_V2.1.md` | Visão geral das 5 camadas |
| `app/modules/REST-DataWare/Documentation/Arquitetura/Arquitetura_Transport_V2.1.md` | 5 transportes HTTP e critérios de seleção |
| `app/modules/REST-DataWare/Documentation/Arquitetura/Arquitetura_Database_V2.1.md` | 9 drivers de banco e abstração TRESTDWDriverBase |
| `app/modules/REST-DataWare/Documentation/Arquitetura/Arquitetura_Security_V2.1.md` | JWT, Basic, AccessTag, AES-256, OAuth2 |
| `app/modules/REST-DataWare/Documentation/RESTDataWare_Overview.md` | Overview geral do framework |
| `app/modules/REST-DataWare/Documentation/Regras de Negocio/` | 25 RNs em 5 módulos (M00–M04) |

---

## Arquitetura — 5 camadas

| Camada | Componentes principais | Responsabilidade |
| --- | --- | --- |
| **Transport** | TRESTDWIdBase, TRESTDWICSBase, TRESTDWFpHttpBase, TRESTDWIdLAMW | Receber/enviar HTTP/HTTPS; intercambiável via diretiva |
| **Core + Basic** | TRESTDWClientSQL, TRESTDWTable, TRESTDWStoredProcedure, TRESTDWPoolerDB, TRESTDWParams, TRESTDWJSONValue | Lógica 3-tier, datasets, parâmetros, serialização JSON |
| **Database** | TRESTDWDriverBase, TRESTDWDrvQuery, TRESTDWDrvTable, TRESTDWDrvStoreProc | Abstração de driver; 9 implementações intercambiáveis |
| **Utils / Security** | TCripto, TRESTDWMassiveCache, ShellTools | AES-256, JWT, OAuth2, cache de operações em lote |
| **Plugins** | Wizards, Packages extras | Geração de código, integração com IDEs |

---

## Componentes principais (11)

| Componente | Tipo | Responsabilidade |
| --- | --- | --- |
| `TRESTDWClientSQL` | Dataset | Executa SQL no servidor REST; suporta parâmetros e cursores |
| `TRESTDWTable` | Dataset | Acesso a tabela sem SQL; Table Open/Insert/Edit/Delete |
| `TRESTDWStoredProcedure` | Dataset | Executa stored procedure no servidor |
| `TRESTDWPoolerDB` | Pooling | Gerencia pool de conexões de banco no servidor |
| `TRESTDWClientRESTBase` | Transport (cliente) | Base para transporte HTTP/HTTPS no cliente |
| `TRESTDWParams` | Params | Lista de parâmetros tipados (TRESTDWParam) para queries/SP |
| `TRESTDWJSONValue` | Serialização | Serialização/desserialização JSON — uso interno e externo |
| `TRESTDWMassiveCache` | Batch | Acumula INSERT/UPDATE/DELETE em memória; envia em lote único |
| `TRESTDWIdBase` | Transport (servidor) | Servidor HTTP baseado em Indy (transporte padrão) |
| `TRESTDWDriverBase` | Driver abstrato | Interface comum para todos os 9 drivers de banco |
| `TCripto` | Segurança | Criptografia AES-256, encoding Base64, geração JWT |

---

## Transportes HTTP (5)

| Transporte | Componente servidor | Diretiva | Quando usar |
| --- | --- | --- | --- |
| **Indy** (padrão) | `TRESTDWIdBase` | (padrão — sem diretiva extra) | Windows; padrão recomendado; suporta SSL |
| **ICS** | `TRESTDWICSBase` | `{$DEFINE RESTDWINDYICS}` | Alta performance; Windows; alternativa ao Indy |
| **FpHttp** | `TRESTDWFpHttpBase` | `{$DEFINE RESTDWFPHTTPCLIENT}` | Linux / macOS / Lazarus FPC; multi-plataforma |
| **HttpDef** | Interno | (implícito) | Transporte interno simplificado; casos especiais |
| **LAMW** | `TRESTDWIdLAMW` | `{$DEFINE RESTDWLAMWHTTPCLIENT}` | Android (LAMW framework) |

> **ADR RDW-01:** O transporte é intercambiável — trocar `TRESTDWIdBase` por `TRESTDWICSBase` sem alterar lógica de negócio.

---

## Drivers de banco (9)

| Driver | Diretiva | Bancos suportados |
| --- | --- | --- |
| **FireDAC** | `{$DEFINE RESTDWFIREDAC}` | 18 bancos: SQLite, PostgreSQL, MySQL, MSSQL, Oracle, Firebird, DB2, etc. |
| **Zeos** | `{$DEFINE RESTDWZEOS}` | 17 protocolos: PostgreSQL, MySQL, MSSQL, Oracle, Firebird, SQLite, etc. |
| **UniDAC** | `{$DEFINE RESTDWUNIDAC}` | 28 providers + SaaS: Oracle, MySQL, PostgreSQL, MSSQL, MongoDB, etc. |
| **IBDAC** | `{$DEFINE RESTDWIBDAC}` | Firebird / InterBase (otimizado) |
| **MyDAC** | `{$DEFINE RESTDWMYDAC}` | MySQL / MariaDB (otimizado) |
| **Interbase nativo** | `{$DEFINE RESTDWINTERBASE}` | InterBase nativo sem DAC externo |
| **Lazarus SQLdb** | `{$DEFINE RESTDWSQLDB}` | PostgreSQL, MySQL, SQLite, ODBC (Lazarus/FPC) |
| **ApolloDB** | `{$DEFINE RESTDWAPOLLODB}` | ApolloDB embedded |
| **AnyDAC** | `{$DEFINE RESTDWANYDAC}` | FireDAC anterior (legado) |

> **ADR RDW-02:** O driver é intercambiável — trocar diretiva em `uRESTDW.inc` sem alterar código de negócio.

---

## Abstração de driver — TRESTDWDriverBase

```
TRESTDWDriverBase (abstrato)
├── TRESTDWDrvQuery       — executa SQL de leitura
├── TRESTDWDrvTable       — acesso a tabela
└── TRESTDWDrvStoreProc   — stored procedure
```

Cada implementação de driver (ex.: `TRESTDWFireDACQuery`) herda de `TRESTDWDrvQuery` e implementa os métodos de acesso ao banco específico.

---

## Segurança

### JWT (JSON Web Token)

| Etapa | Descrição |
| --- | --- |
| 1. Geração | Servidor gera token via `TCripto.GenerateToken(Payload, SecretKey)` |
| 2. Distribuição | Endpoint `/newtoken` retorna o JWT ao cliente |
| 3. Uso | Cliente envia `Authorization: Bearer <token>` em cada requisição |
| 4. Renovação | Endpoint `/renewtoken` renova o token antes da expiração |

### Modos de autenticação

| Modo | Como configurar | Quando usar |
| --- | --- | --- |
| **Basic** | `TRESTDWPoolerDB.AuthorizationMode := amBasic` | Cenários simples com usuario/senha |
| **AccessTag** | `TRESTDWPoolerDB.AuthorizationMode := amAccessTag` | Token fixo por cliente/aplicação |
| **JWT Bearer** | `TRESTDWPoolerDB.AuthorizationMode := amJWT` | Sessões stateless, expiração configurável |
| **OAuth2** | Fluxo de 4 passos via TCripto + endpoints dedicados | Integração com provedores externos |

### AES-256 (TCripto)

```
TCripto.Encrypt(Text, Key)  → string Base64 criptografado
TCripto.Decrypt(Text, Key)  → string original
```

---

## MassiveCache

`TRESTDWMassiveCache` acumula operações DML (INSERT/UPDATE/DELETE) em memória no cliente e as envia em um único request HTTP ao servidor, reduzindo drasticamente o número de round-trips.

```
Cliente                           Servidor
  │  Acumular INSERTs/UPDATEs       │
  │  localmente em TMassiveBuffer   │
  │                                 │
  │──── ApplyUpdates (1 request) ──→│
  │                                 │  Executa batch no banco
  │←─── Resultado (success/errors)──│
```

> **ADR RDW-04:** Usar MassiveCache para toda operação de batch > 10 registros. Nunca fazer loop de ApplyUpdates linha a linha.

---

## Hierarquia de exceções

```
eRESTDWException (base)
├── eRESTDWSocketException          — erros de socket/rede
├── eRESTDWMessageException         — erros de mensagem/protocolo
├── eRESTDWTimeoutException         — timeout de conexão ou operação
├── eRESTDWNonBlockingException     — modo não-bloqueante
├── eRESTDWAuthException            — falha de autenticação
├── eRESTDWDriverException          — erro no driver de banco
├── eRESTDWQueryException           — erro de SQL/query
├── eRESTDWPoolException            — erro no pool de conexões
├── eRESTDWSerializationException   — erro de serialização JSON
├── eRESTDWConfigException          — configuração inválida
└── eRESTDWSecurityException        — violação de segurança/permissão
```

---

## Diretivas de compilação (uRESTDW.inc)

| Diretiva | Ativa | Quando usar |
| --- | --- | --- |
| `RESTDWFIREDAC` | Driver FireDAC | Delphi com FireDAC (padrão recomendado Windows) |
| `RESTDWZEOS` | Driver Zeos | Multiplataforma; Lazarus/FPC |
| `RESTDWUNIDAC` | Driver UniDAC | UniDAC disponível; máxima cobertura de bancos |
| `RESTDWIBDAC` | Driver IBDAC | Firebird/InterBase especializado |
| `RESTDWMYDAC` | Driver MyDAC | MySQL/MariaDB especializado |
| `RESTDWINTERBASE` | Driver IB nativo | InterBase sem componentes externos |
| `RESTDWSQLDB` | Driver SQLdb | Lazarus/FPC; gratuito |
| `RESTDWAPOLLODB` | Driver ApolloDB | ApolloDB embedded |
| `RESTDWANYDAC` | Driver AnyDAC | Legado (FireDAC antigo) |
| `RESTDWINDYICS` | Transporte ICS | Alta performance; alternativa ao Indy |
| `RESTDWFPHTTPCLIENT` | Transporte FpHttp | Linux/macOS/Lazarus |
| `RESTDWLAMWHTTPCLIENT` | Transporte LAMW | Android |

---

## ADRs (Architectural Decision Records)

| ADR | Decisão | Justificativa |
| --- | --- | --- |
| RDW-01 | Transporte intercambiável (Strategy) | Permite troca Indy↔ICS↔FpHttp sem alterar negócio |
| RDW-02 | Driver intercambiável (Strategy) | Permite troca FireDAC↔Zeos↔UniDAC via diretiva |
| RDW-03 | TRESTDWJSONValue como serialização única | Evitar dependências múltiplas de JSON; portável Delphi+FPC |
| RDW-04 | MassiveCache obrigatório para batch | Round-trips individuais causam degradação severa em lote |
| RDW-05 | Compatibilidade Delphi 7+ e Lazarus/FPC | Sem uso de generics modernos ou RTTI incompatível com FPC |
| RDW-06 | Licença GPL-3.0 obrigatória em arquivos fonte | Todos os arquivos `.pas`/`.inc` devem incluir cabeçalho GPL-3.0 |

---

## Anti-padrões

| Anti-padrão | Como corrigir |
| --- | --- |
| Referenciar `TRESTDWIdBase` diretamente no código de negócio | Usar interface de transporte; isolar criação no setup |
| Hardcodar driver (ex.: `TRESTDWFireDACQuery`) no código de negócio | Instanciar via diretiva; código de negócio usa `TRESTDWDrvQuery` |
| Usar HTTP sem SSL em produção | Sempre configurar certificado + HTTPS no servidor de produção |
| Loop de `ApplyUpdates` linha a linha | Usar `TRESTDWMassiveCache` para agrupar em batch único |
| Distribuir código-fonte sem cabeçalho GPL-3.0 | Inserir licença GPL-3.0 no topo de cada arquivo `.pas`/`.inc` |
| Nomear controller como `EntryPoint` | Usar `Access.Controller.Xxx` — `EntryPoint` é nomenclatura obsoleta |

---

## Implementações concretas por projeto

Padrões de implementação MXX-like (controllers com `.Controller.*` + `ServerMain` + `RegisterAllControllers` + handlers fluentes) são **instâncias** específicas de projetos que adoptam o framework RDW V2.1.

Para o clone **GestorERP**, ver skill específica:
[`.workspace/skills/gestorerp-mxx-rest-dataware-controllers_V1.0.0/SKILL.md`](../../../.workspace/skills/gestorerp-mxx-rest-dataware-controllers_V1.0.0/SKILL.md) — convenção `Access.Controller.*`, `TServerMain.RegisterAllControllers`, handlers fluentes OOP no padrão MXX.

Outros projetos devem criar a sua própria skill equivalente em `.workspace/skills/<projectId>-<framework>-rest-dataware-controllers_V*.md`.

## Path resolution

Path real do framework RDW V2.1 lido de `.cursor/config.json._frameworks.restDataWare.installPath` (default `C:/Users/Public/Documents/Embarcadero/Studio/Outros/REST-DataWare` — convenção Embarcadero). Override local opcional em `.workspace/context.json._frameworks_overrides.restDataWare`.

---

## Changelog (este arquivo)

- 1.0.2 (17/04/2026): Onda 5 do refactor — secção "GestorERP — Controllers e fluent handlers (MXX pattern)" removida (migrada para `.workspace/skills/gestorerp-mxx-rest-dataware-controllers_V1.0.0/SKILL.md`); skill passa a ser 100% genérica (documenta o framework RDW V2.1). Nota sobre `_frameworks.restDataWare.installPath` adicionada.
- 1.0.1 (15/04/2026): Adicionada seção "GestorERP — Controllers e fluent handlers (MXX pattern)": convenção `Access.Controller.*`, padrão `TServerMain.RegisterAllControllers`, handlers fluentes com OOP, encapsulamento Core/; anti-padrão `EntryPoint`.
- 1.0.0 (11/04/2026): Criação — expert da família developer-delphi-rest-dataware-*.

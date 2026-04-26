---
name: ActiveDirectoryORM LDAP RN-M01
overview: "Alinhar o módulo [app/modules/ActiveDirectoryORM](e:\\GestorERP\\app\\modules\\ActiveDirectoryORM) às exigências de **Segurança e Acesso** (RN-M01: AD bind, grupos/OUs para OBAC, sync AD), mantendo o pacote reutilizável, com API fluente 100% OO e camada **Attributers** para mapeamento tipado — e reduzir duplicação com o `ServiceLDAP` legado no backend."
todos:
  - id: pre-req-synapse-fork
    content: "PRÉ-REQUISITO: concluir plano synapse-ldap-fork_b3f4e901 (atualizar versões + migração para app/package/synapse; ldapsend.pas sem alteração)"
    status: pending
  - id: spike-ad
    content: "Spike em AD real: validar loop SearchPageSize+SearchCookie >1000 entradas; confirmar CertCAFile em Sock.SSL para tmLDAPSWithCA"
    status: pending
  - id: extend-config-fluent
    content: "Adicionar TTlsMode enum + constantes GC (3268/3269) + ILDAPSearchResult; estender IActiveDirectoryConnection com TlsMode(), CAFile(), PageSize(), UseGlobalCatalog(); corrigir constructor TLS no Service"
    status: pending
  - id: service-obac-api
    content: "Adicionar IActiveDirectoryService: GetUserDirectoryData, GetTransitiveGroups, GetAncestorOUs, SearchUsersPage (loop SearchPageSize/SearchCookie; fallback por OU)"
    status: pending
  - id: attributers-mapper
    content: "Implementar TLdapMapper<T> com FromSearchResult<T> e ToModifyList<T> (USE_ATTRIBUTES); modelos TAdUser/TAdGroup"
    status: pending
  - id: backend-consolidate
    content: "Migrar M01LdapAuthenticator + AD sync para ActiveDirectoryORM; marcar ServiceLDAP como legado"
    status: pending
  - id: validate-rn-m01
    content: "Validar bind, GetTransitiveGroups nested, SearchUsersPage >1000 entradas (cookie), LDAPS com CA; documentar limites Synapse no README"
    status: pending
isProject: false
---

# Plano: ActiveDirectoryORM — LDAP para Windows AD (OO + Fluente + Attributers)

## Contexto

Evolução do módulo `E:\GestorERP\app\modules\ActiveDirectoryORM` para atender 100% os requisitos de "Segurança e Acesso" (RN-M01) com foco em **servidor Windows AD via SSL/TLS**. O módulo deve permanecer reutilizável em outros projetos (zero referências ao GestorERP).

**Prompt original:** orientado a objeto 100%, fluente, Attributers — tudo mantido independente.

Referências:
- [RN-M01-001](e:\GestorERP\Documentation\RegrasNegocio\RN-M01%20-%20Seguran%C3%A7a%20e%20Acesso\GestorERP_RN-M01-001_M01_V1_1_0.md)
- [active-directory-reference.md](e:\GestorERP\Documentation\active-directory-reference.md) — referência técnica LDAP profunda (paginação, TLS, CBT, signing)

---

## Estado atual — confirmado por exploração

| Componente | Estado |
|---|---|
| `IActiveDirectoryConnection` fluente (Builder) | ✅ Existe — setters retornam Self |
| `IActiveDirectoryService` com 30+ métodos | ✅ Existe |
| LDAPS porta 636 (`FullSSL := True`) | ✅ Existe |
| StartTLS porta 389 (`AutoTLS := True`) | ✅ Existe |
| Hierarquia de exceções 6 tipos | ✅ Existe |
| `LdapAttribute` / `LdapObjectClass` RTTI | ✅ Existe |
| `TLdapMapper<T>` / pipeline LDAP→tipo | ❌ Não existe |
| `VerifyCert` configurável (hoje hardcoded False, linha 412) | ❌ Não existe |
| Porta Global Catalog 3268/3269 | ❌ Não existe |
| Paginação (OID 1.2.840.113556.1.4.319) | Synapse: sim (`SearchPageSize` + `SearchCookie`); ActiveDirectoryORM: integrar loop no serviço |
| `GetTransitiveGroups` (OBAC nested groups) | ❌ Não existe |
| `GetAncestorOUs` (claims JWT `ou`) | ❌ Não existe |
| `SearchUsersPage` com atributos (sync) | ❌ Não existe |

---

## Análise do pacote Indy (`E:\GestorERP\app\package\Indy`)

Indy **RADStudio-13.0-Florence-4-g7df1b623** tem suporte LDAP em `IdLDAPV3.pas` + `IdLDAPV3Coder.pas` com **Controls em nível de protocolo** (`TIdLDAPV3Control` com OID, controlValue, criticality). Porém:

- **Sem client de rede/socket** — apenas protocolo ASN.1
- **Sem SSL/TLS** — sem VerifyCert, sem CertCAFile
- **Sem operações de alto nível** — exigiria reimplementar toda a camada de transporte

**Conclusão:** Indy **não atende as especificações** como substituto do Synapse `TLDAPSend`. Manter Synapse para transporte/SSL.

---

## Avaliação Synapse (`ldapsend.pas`) vs lacunas do plano — LDAP / AD

Referência geral: [LDAP.com — Learn About LDAP](https://ldap.com/) (contexto de protocolo; implementação concreta abaixo é código Synapse).

### O que o Synapse **já implementa** (sem fork nem assembly)

- **Paginação RFC 2696 / controle Microsoft** — Em `TLDAPSend.Search`, se `SearchPageSize > 0`, o pacote anexa o control `1.2.840.113556.1.4.319` (paged results), envia `pageSize` + `cookie`, e no `SEARCH_DONE` decodifica o **novo cookie** em `FSearchCookie`. Padrão no construtor: `SearchPageSize := 0` (sem paging). Ficheiro: `app/backend-delphi/third_party/synapse/ldapsend.pas` (por volta das linhas 323–329, 1131–1140, 1184–1198).
- **StartTLS** — `StartTLS` chama `Extended('1.3.6.1.4.1.1466.20037', '')` e depois `SSLDoConnect` no socket (RFC 4511 / mecanismo estendido StartTLS).
- **Extended operation genérica** — `Extended(Name, Value)` para outros OIDs, se necessário no futuro.
- **Bind SASL** — Existe `BindSasl` (DIGEST-MD5 no comentário); **não** cobre cenários típicos Kerberos/GSSAPI do AD que exigiriam outra stack.

### O que **não** está exposto (ou é limitado)

- **Controls arbitrários no Search** — Só o control de **paged results** é montado automaticamente. Controls como ordenação no servidor (`1.2.840.113556.1.4.473`), SD flags, DirSync, etc. **não** têm API pronta; exigiria estender `Search` (Pascal/ASN.1 como já feito para paging), não assembly.
- **Grupos aninhados (OBAC)** — O filtro `LDAP_MATCHING_RULE_IN_CHAIN` (`1.2.840.113556.1.4.1941`) vai no **filtro** LDAP, não como control. A stack atual `Search` já envia o filtro traduzido; **nenhuma alteração no Synapse** é obrigatória para `GetTransitiveGroups` — só construir o filtro correto no módulo.
- **Channel Binding Token (CBT)** / **LDAP signing** em cenários extremos — São requisitos de **canal TLS ou SSPI**, não resolvíveis com um trecho de assembly na aplicação; dependeria de suporte na pilha SSL/Schannel/OpenSSL e do servidor. Documentar matriz suportado/não suportado no README do módulo.

### Assembly inline (Delphi) — avaliação

- **Não é necessário** para completar o plano: montagem BER já está em `asn1util` / `ldapsend` em Pascal.
- **Desaconselhado** para LDAP: manutenção, portabilidade Win32/Win64 e risco de segurança superam qualquer ganho marginal.
- Se no futuro for preciso um **control LDAP custom** raro, o caminho certo é **estender `TLDAPSend.Search`** (ou helper no módulo que monte o mesmo padrão ASN.1 que o paging usa), mantendo código revisável.

### Conclusão para o plano

- A lacuna de paginação é, na prática, no **consumidor** (`ActiveDirectoryORM`): atribuir `FLDAPSend.SearchPageSize` (ex. da config), fazer **loop** `SearchCookie` vazio → pesquisar → acumular `SearchResult` até cookie vazio.
- **Alternativa B (só por OU)** passa a ser **fallback** (servidor sem paging, ou política de timeout), não a estratégia principal.
- Nenhuma dependência de assembly para “atender o plano” com AD + SSL + sync paginado.

---

## IPWorks 2024 Delphi Edition (/nsoftware) — cobertura face ao plano

**Documentação:** [IPWorks 2024 Delphi — índice](https://cdn.nsoftware.com/help/IPJ/dlp/) e componente [LDAP](https://cdn.nsoftware.com/help/IPJ/dlp/LDAP.htm).

**O que o componente LDAP declara (índice oficial):**

- **Paginação / pesquisa em páginas:** propriedade `PageSize`; eventos `SearchPage`, `SearchComplete`, `SearchResult`, `SearchResultReference` — adequado a sync com muitos objetos (RN-M01) sem implementar manualmente o loop de cookie (embora por baixo seja o mesmo protocolo).
- **TLS/SSL:** `SSLEnabled`, `SSLStartMode`, `SSLCert`, `SSLAcceptServerCert`, `SSLProvider` + eventos `SSLServerAuthentication`, `SSLStatus` — cobre a lacuna de **certificado configurável** de forma mais explícita que o Synapse “cru”.
- **Operações:** `Bind`, `Search`, `Modify`, `ChangePassword`, `ExtendedRequest`, `Compare`, etc.; métodos de conveniência AD: `ListUserGroups`, `ListGroups`, `ListGroupMembers`, `ListComputers` — podem acelerar cenários OBAC/sync (a camada fluente/Attributers do módulo pode encapsular ou ignorar estes atalhos).
- **Outros:** `AuthMechanism`, `SortAttributes`, `LDAPVersion`, limites `SearchSizeLimit` / `SearchTimeLimit` — útil para políticas de servidor; **ExtendedRequest** permite operações estendidas quando necessário (confirmar OIDs suportados na doc detalhada e trial).

**Trade-offs:**

- **Produto comercial** (licença nsoftware); o ecossistema GestorERP já referencia IPWorks noutros contextos — reutilizar só onde a licença existir.
- **Independência do `ActiveDirectoryORM`:** para outros projetos sem IPWorks, manter **Synapse como backend por defeito**. Opcional: arquitectura com adapter (`ILDAPTransport` / `ILDAPClient`) com implementação Synapse **e**, condicionalmente, IPWorks (`{$DEFINE USE_IPWORKS_LDAP}` ou pacote satélite), sem acoplar o núcleo ao fornecedor.

**Conclusão:** IPWorks **suporta, em princípio, tudo o que o plano pede** (paging, SSL rico, bind/search/modify, extensões, helpers AD). **Não é requisito** para fechar o plano se a implementação Synapse + loop `SearchPageSize`/`SearchCookie` + TLS configurável for suficiente; IPWorks é **upgrade opcional** por produtividade, política de certificados ou requisitos SASL a validar no trial.

---

## Delphi-PRAXiS (www.delphipraxis.net)

**Não é um pacote LDAP.** É um **portal/comunidade** (fórum, Code-Library, notícias) em alemão para programadores Delphi. **Não substitui** Synapse nem IPWorks; não adiciona, por si, suporte técnico ao plano além de possível discussão ou exemplos pontuais na comunidade.

---

## ICS (Overbyte) — cobertura face ao plano

**Fonte:** [ICS Download](https://wiki.overbyte.eu/wiki/index.php/ICS_Download).

### O que atende

- **TLS/SSL robusto em Delphi:** stack mantida e evoluída, com OpenSSL atualizado e foco em segurança operacional.
- **Ecossistema para AD/LDAP enterprise:** a família ICS inclui cenários de autenticação, certificados, filtros de conexão, e telemetria de rede úteis para produção.
- **Compatibilidade Delphi moderna:** versões recentes suportam Delphi 13 e builds Win32/Win64 com OpenSSL atualizado.

### Limites para o nosso objetivo

- A página avaliada é **download/changelog**; não é especificação completa do componente LDAP.
- Para confirmar 100% de cobertura da lacuna RN-M01 (nested groups com matching rule, paging detalhado, extended controls específicos AD), é preciso validar a API LDAP do ICS no código/docs do componente usado no projeto.

### Conclusão prática

- **Sim, o ICS é candidato forte para atender o plano** no nível de transporte/segurança e operação enterprise.
- Ainda assim, para manter o módulo independente e portável, o plano mantém: **núcleo ActiveDirectoryORM agnóstico** + adapter de transporte opcional (`Synapse` padrão, `ICS` opcional por diretiva).

## Lacunas críticas para Windows AD via SSL/TLS

### Lacuna 1 — `VerifyCert` e TLS Mode configurável (bloqueante para produção)

**Bug confirmado:** linha 412 de `ActiveDirectory.Service.pas`:
```pascal
FLDAPSend.Sock.SSL.VerifyCert := False;  // hardcoded — inseguro em produção
```

**Implementação a adicionar (Fase A):**

```pascal
// Em ActiveDirectory.Types.pas — novo enum
TTlsMode = (
  tmNone,              // Sem TLS (porta 389 plain)
  tmStartTLS,          // StartTLS (porta 389 → upgrade)
  tmLDAPSNoCertCheck,  // LDAPS (porta 636) sem validar certificado (AD interno)
  tmLDAPSWithCA        // LDAPS (porta 636) validando CA — produção
);

// Em TLDAPConfig record — novos campos:
TLDAPConfig = record
  // ... existentes ...
  TlsMode: TTlsMode;  // substitui UseSSL + VerifyCert separados
  CAFile: string;     // caminho PEM/CA quando tmLDAPSWithCA
  PageSize: Integer;  // padrão: 1000
end;
```

**Interface fluente a adicionar em `IActiveDirectoryConnection`:**
```pascal
function TlsMode(AMode: TTlsMode): IActiveDirectoryConnection;
function CAFile(const APath: string): IActiveDirectoryConnection;
function PageSize(ASize: Integer): IActiveDirectoryConnection;
function UseGlobalCatalog(AValue: Boolean): IActiveDirectoryConnection;
```

**Lógica no constructor `TActiveDirectoryService.Create` (substituir bloco atual):**
```pascal
case FConfig.TlsMode of
  tmNone:
    begin FLDAPSend.FullSSL := False; FLDAPSend.AutoTLS := False; end;
  tmStartTLS:
    begin
      FLDAPSend.FullSSL := False; FLDAPSend.AutoTLS := True;
      if FLDAPSend.Sock.SSL <> nil then
        FLDAPSend.Sock.SSL.VerifyCert := False;
    end;
  tmLDAPSNoCertCheck:
    begin
      FLDAPSend.FullSSL := True; FLDAPSend.AutoTLS := False;
      if FLDAPSend.Sock.SSL <> nil then
        FLDAPSend.Sock.SSL.VerifyCert := False;
    end;
  tmLDAPSWithCA:
    begin
      FLDAPSend.FullSSL := True; FLDAPSend.AutoTLS := False;
      if FLDAPSend.Sock.SSL <> nil then
      begin
        FLDAPSend.Sock.SSL.VerifyCert := True;
        FLDAPSend.Sock.SSL.CertCAFile := FConfig.CAFile;
      end;
    end;
end;
```

**Backward compatibility:** `UseSSL(True)` em porta 636 → mapeado para `tmLDAPSNoCertCheck`.

---

### Lacuna 2 — Global Catalog (portas 3268/3269) não coberto

A lógica atual verifica apenas porta 636 para SSL. Portas GC ignoradas.

**Implementação (Fase A):**
```pascal
// Em ActiveDirectory.Consts.pas — novas constantes:
LDAP_GC_PORT_DEFAULT  = 3268;   // Global Catalog LDAP
LDAPS_GC_PORT_DEFAULT = 3269;   // Global Catalog LDAPS

// Função auxiliar no Service:
function IsSSLPort(APort: Integer): Boolean;
begin
  Result := (APort = LDAPS_PORT_DEFAULT) or (APort = LDAPS_GC_PORT_DEFAULT);
end;
```

---

### Lacuna 3 — Paginação LDAP — usar API nativa do Synapse

**Correcção:** `TLDAPSend` **suporta** paging quando `SearchPageSize > 0`; o cookie é lido/gravado em `SearchCookie` após cada `Search`.

**Decisão:** Implementação principal em `TActiveDirectoryService` (ou helper privado):

1. Guardar `LPrev := FLDAPSend.SearchPageSize`.
2. `FLDAPSend.SearchPageSize := Max(1, Min(FConfig.PageSize, 1000))` (ou valor da config).
3. `FLDAPSend.SearchCookie := ''`.
4. Repetir: executar `Search` → agregar entradas de `SearchResult` → se `SearchCookie` não vazio, próxima iteração; até cookie vazio ou erro.
5. Restaurar `SearchPageSize` / limpar cookie se necessário para não afetar outras pesquisas.

**Fallback:** Se o DC ou o filtro impedir paging estável, segmentar por `SearchOUs` ou reduzir escopo.

**Interface pública sugerida** (inalterada em espírito):

```pascal
function SearchUsersPage(
  const AFilter: string;
  const AAttributes: TStringList;
  APageSize: Integer = 1000
): TArray<ILDAPSearchResult>;
// Internamente: loop SearchCookie + Synapse paging
```

---

### Lacuna 4 — Windows Server 2025 — limitações Synapse (documentar, não implementar)

| Limitação | Quando impacta | Solução documentada |
|---|---|---|
| SASL/Signing (`LDAPServerIntegrity = 2`) | Signing obrigatório no DC | Usar LDAPS — TLS substitui signing |
| Channel Binding Token (`LdapEnforceChannelBinding = 2`) | WS2025 padrão futuro | Usar LDAPS — CBT opcional quando SSL ativo |
| Kerberos/NTLM bind | SASL com Kerberos não disponível no Synapse | Simple Bind via LDAPS |

**Em produção Windows AD:** `tmLDAPSWithCA` ou `tmLDAPSNoCertCheck` contorna todas as limitações acima.

---

## Sequência de execução

```
Fase 0 — Spike Synapse / AD
  - Provar em AD real: loop SearchPageSize + SearchCookie com >1000 resultados
  - Confirmar CertCAFile (ou equivalente) em Sock.SSL para tmLDAPSWithCA
  - Listar controls LDAP adicionais necessários além do paging; se nenhum, não forkar Synapse

Fase A — Contratos, tipos e TLS
  - TTlsMode enum em ActiveDirectory.Types.pas
  - Constantes GC (3268/3269) em ActiveDirectory.Consts.pas
  - ILDAPSearchResult / TLDAPAttributeBag (DN + mapa atributos)
  - IActiveDirectoryConnection: TlsMode(), CAFile(), PageSize(), UseGlobalCatalog()
  - Constructor: lógica SSL baseada em TTlsMode (não hardcoded)
  - IsSSLPort() para cobrir 636 e 3269

Fase B — Operações RN-M01 no serviço
  - GetUserDirectoryData(DN, Atributos) → ILDAPSearchResult
    * Atributos mínimos: sAMAccountName, mail, userPrincipalName, memberOf,
      objectGUID, whenChanged, distinguishedName
  - GetTransitiveGroups(UserDN) → TArray<string>
    * Filtro: (&(objectClass=group)(member:1.2.840.113556.1.4.1941:=<UserDN>))
  - GetAncestorOUs(UserDN) → TArray<string>
    * Parsing do DN: extrair cada OU= componente
  - SearchUsersPage(Filter, Attributes, PageSize) → TArray<ILDAPSearchResult>
    * Implementado com Synapse: SearchPageSize + loop SearchCookie; fallback por OU se necessário
    * objectGUID incluído obrigatoriamente no resultado

Fase C — Attributers e mapper
  - TLdapMapper<T> com FromSearchResult<T> e ToModifyList<T> (USE_ATTRIBUTES)
  - TAdUser modelo de referência:
      [LdapObjectClass('user')] TAdUser
        [LdapAttribute('objectGUID')]        ObjectGUID: TGuid
        [LdapAttribute('sAMAccountName')]    Login: string
        [LdapAttribute('mail')]              Email: string
        [LdapAttribute('distinguishedName')] DN: string
        [LdapAttribute('memberOf')]          Groups: TArray<string>
        [LdapAttribute('whenChanged')]       LastChanged: TDateTime
  - TAdGroup modelo de referência

Fase D — Integração GestorERP
  - M01LdapAuthenticator: usar IActiveDirectoryService.GetUserDirectoryData para claims
  - SegurancaAdminActions.M01SincronizarAD: substituir TODO por SearchUsersPage
  - ServiceLDAP.pas do backend: marcar como legado, não evoluir

Fase E — Validação
  - Bind admin, bind user (tmLDAPSNoCertCheck para AD interno)
  - Bind via tmLDAPSWithCA (CA file do DC)
  - GetTransitiveGroups com usuário em grupos nested
  - SearchUsersPage por OU com >100 usuários
  - Documentar no README: paging nativo Synapse; limites SASL/GSSAPI/CBT
```

---

## Arquivos críticos

| Arquivo | Fase | Ação |
|---|---|---|
| `src/Commons/ActiveDirectory.Types.pas` | A | Adicionar `TTlsMode`, campos `TlsMode`, `CAFile`, `PageSize` em `TLDAPConfig` |
| `src/Commons/ActiveDirectory.Consts.pas` | A | Adicionar `LDAP_GC_PORT_DEFAULT = 3268`, `LDAPS_GC_PORT_DEFAULT = 3269` |
| `src/Core/ActiveDirectory.Core.Interfaces.pas` | A, B | Adicionar fluentes TLS + GC + novos métodos serviço + `ILDAPSearchResult` |
| `src/ActiveDirectory.Service.pas` | A, B | Corrigir constructor TLS, adicionar `IsSSLPort`, implementar novos métodos |
| `src/Commons/ActiveDirectory.Attributers.pas` | C | Adicionar `TLdapMapper<T>`, `TAdUser`, `TAdGroup` |
| `README.md` do módulo | E | Documentar: paging via SearchPageSize; limites SASL/GSSAPI/CBT; modo TLS |
| `app/backend-delphi/.../M01LdapAuthenticator.pas` | D | Usar novos métodos: GetUserDirectoryData, GetTransitiveGroups |
| `app/backend-delphi/.../SegurancaAdminActions.pas` | D | Completar M01SincronizarAD com SearchUsersPage |

---

## Verificação end-to-end

1. `TActiveDirectory.New.Host('dc.empresa.local').Port(636).TlsMode(tmLDAPSWithCA).CAFile('ca.pem').GetConfig` — compila sem erro
2. `TActiveDirectoryService.New(config).Connect` — conecta em LDAPS com validação de CA
3. `TActiveDirectoryService.New(config).Connect` em `tmLDAPSNoCertCheck` — conecta sem CA (AD interno)
4. `GetTransitiveGroups(userDN)` → retorna grupos nested
5. `GetAncestorOUs(userDN)` → retorna `['OU=Financeiro', 'OU=BackOffice']`
6. `SearchUsersPage('(objectClass=user)', attrs)` → retorna lista com `objectGUID` preenchido (teste com >1000 objetos usando cookie)
7. `TLdapMapper<TAdUser>.FromSearchResult(result)` → `TAdUser.ObjectGUID` preenchido

---

## Controls futuros — DirSync e SD Flags (implementação concreta)

### Diagnóstico definitivo do Synapse (`ldapsend.pas`)

- `TLDAPSend` tem **zero métodos virtuais** (exceto destructor herdado)
- `FSock` é **private** — acessível via propriedade pública `Sock`
- `Search()` tem 100+ linhas; não será duplicado nem escondido
- `FSearchPageSize`/`FSearchCookie` são **private** — não acessíveis em subclasse sem getter

### Decisão: subclasse sem fork de ldapsend.pas

`TLDAPSend.Search()` não é virtual e não será alterado. A compatibilidade de versão é mantida — projetos existentes que usam `TLDAPSend` diretamente não são afetados.

**Estratégia:** `TActiveDirectoryLDAPSend` adiciona **métodos dedicados** para cada operação com controles especiais, construindo o pacote LDAP completo via `asn1util.pas` + propriedade pública `Sock`. Para buscas comuns com paginação, usa `inherited Search()` normalmente.

### Subclasse `TActiveDirectoryLDAPSend` — métodos dedicados

**Nova unit:** `src/Core/ActiveDirectory.LDAPControls.pas`

```pascal
TActiveDirectoryLDAPSend = class(TLDAPSend)
private
  FDirSyncCookie:   AnsiString;
  FDirSyncFlags:    Integer;
  FDirSyncMaxBytes: Integer;
  FSDFlags:         Integer;
  FDirSyncResult:   AnsiString;  // cookie retornado pelo DC após DirSync
  procedure ParseDirSyncResponseControl(const AData: AnsiString);
public
  constructor Create;

  // Métodos dedicados com controls LDAP — NÃO usam inherited Search()
  // Constroem pacote LDAP completo via asn1util + Sock
  function SearchDirSync(const ABase, AFilter: AnsiString;
    AScope: Integer; const AAttributes: TStringList): Boolean;
  function SearchWithSDFlags(const ABase, AFilter: AnsiString;
    AScope, ASDFlags: Integer; const AAttributes: TStringList): Boolean;

  // Helpers BER — reutilizáveis como class functions
  class function BuildControlBlock(const AOID: AnsiString; ACriticality: Boolean;
    const AValue: AnsiString): AnsiString;
  class function EncodeDirSyncControl(AFlags, AMaxBytes: Integer;
    const ACookie: AnsiString): AnsiString;
  class function EncodeSDFlagsControl(AFlags: Integer): AnsiString;
  class function BuildControlsBlock(const AControls: AnsiString): AnsiString;

  property DirSyncCookie:   AnsiString read FDirSyncCookie   write FDirSyncCookie;
  property DirSyncFlags:    Integer    read FDirSyncFlags     write FDirSyncFlags;
  property DirSyncMaxBytes: Integer    read FDirSyncMaxBytes  write FDirSyncMaxBytes;
  property SDFlags:         Integer    read FSDFlags          write FSDFlags;
  property DirSyncResult:   AnsiString read FDirSyncResult;
end;
```

**Uso no serviço:**

```pascal
// Busca normal com paginação (usa inherited Search() — não muda nada):
FLDAPSend.SearchPageSize := 1000;
FLDAPSend.Search(Base, False, LDAP_SCOPE_SUBTREE, Filter, Attrs);

// Busca DirSync (usa método dedicado da subclasse):
FLDAPSend.DirSyncCookie := FLastDirSyncCookie;
FLDAPSend.SearchDirSync(Base, '(objectClass=user)', LDAP_SCOPE_SUBTREE, Attrs);
FLastDirSyncCookie := FLDAPSend.DirSyncResult;
```

> **Compatibilidade garantida:** `TLDAPSend.Search()` permanece intacto. Qualquer código existente que instancia `TLDAPSend` diretamente continua funcionando. `TActiveDirectoryLDAPSend` adiciona capacidade — não altera comportamento herdado.

### Padrões BER

**DirSync** (`LDAP_OID_DIRSYNC = '1.2.840.113556.1.4.841'`):

```pascal
class function TActiveDirectoryLDAPSend.EncodeDirSyncControl(...): AnsiString;
var t: AnsiString;
begin
  // SEQUENCE { flags INTEGER, maxBytes INTEGER, cookie OCTET STRING }
  t := ASNObject(ASNEncInt(AFlags), ASN1_INT) +
       ASNObject(ASNEncInt(AMaxBytes), ASN1_INT) +
       ASNObject(ACookie, ASN1_OCTSTR);
  Result := ASNObject(t, ASN1_SEQ);
end;
```

**SD Flags** (`LDAP_OID_SD_FLAGS = '1.2.840.113556.1.4.801'`):

```pascal
class function TActiveDirectoryLDAPSend.EncodeSDFlagsControl(AFlags: Integer): AnsiString;
begin
  // SEQUENCE { flags INTEGER }
  Result := ASNObject(ASNObject(ASNEncInt(AFlags), ASN1_INT), ASN1_SEQ);
end;
```

**BuildControlBlock** (comum):

```pascal
class function TActiveDirectoryLDAPSend.BuildControlBlock(
  const AOID: AnsiString; ACriticality: Boolean; const AValue: AnsiString): AnsiString;
var c: AnsiString;
begin
  c := ASNObject(AOID, ASN1_OCTSTR);                        // controlType OID
  c := c + ASNObject(ASNEncInt(Ord(ACriticality)), ASN1_BOOL); // criticality
  c := c + ASNObject(AValue, ASN1_OCTSTR);                  // controlValue
  Result := ASNObject(c, ASN1_SEQ);                         // SEQUENCE
end;
```

### Constantes a adicionar em `ActiveDirectory.Consts.pas`

```pascal
LDAP_OID_PAGED_RESULTS = '1.2.840.113556.1.4.319';
LDAP_OID_DIRSYNC       = '1.2.840.113556.1.4.841';
LDAP_OID_SD_FLAGS      = '1.2.840.113556.1.4.801';

LDAP_DIRSYNC_OBJECT_SECURITY    = $00000001;
LDAP_DIRSYNC_ANCESTORS_FIRST    = $00000800;
LDAP_DIRSYNC_INCREMENTAL_VALUES = Integer($80000000);

LDAP_SD_OWNER = $00000001;
LDAP_SD_GROUP = $00000002;
LDAP_SD_DACL  = $00000004;
LDAP_SD_SACL  = $00000008;
LDAP_SD_ALL   = $00000007;
```

### Casos de uso dos controls

| Control | Quando usar | OID |
|---|---|---|
| **DirSync** | Sync incremental AD — só mudanças desde último cookie | `1.2.840.113556.1.4.841` |
| **SD Flags** | Ler `nTSecurityDescriptor` (DACL/SACL protegidos por padrão) | `1.2.840.113556.1.4.801` |
| **Paged Results** | Já implementado no Synapse via `SearchPageSize` | `1.2.840.113556.1.4.319` |

### Arquivos impactados

| Arquivo | Ação |
|---|---|
| `app/package/synapse/ldapsend.pas` | **Sem alteração** — compatibilidade preservada |
| `src/Core/ActiveDirectory.LDAPControls.pas` | **Criar** — `TActiveDirectoryLDAPSend` com métodos dedicados DirSync/SDFlags |
| `src/Commons/ActiveDirectory.Consts.pas` | Adicionar OIDs + flags DirSync + SD Flags |
| `src/ActiveDirectory.Service.pas` | `FLDAPSend: TActiveDirectoryLDAPSend` (em vez de `TLDAPSend`) |

---

## Pré-requisito — Plano Synapse (executar primeiro)

Ver plano `synapse-ldap-fork_b3f4e901.plan.md`:

- Atualizar versões em `app/package/synapse/` (blcksock 009.011.000 + demais units)
- Migração `third_party/synapse/` → `app/package/synapse/` (centralização)
- Atualização de build paths e remoção de `third_party/`

**`ldapsend.pas` não é alterado** — compatibilidade total com projetos existentes.

---

## Cobertura de controles LDAP — documentação Windows AD (seção 10.1)

| OID | Nome | Suporte Synapse base | Plano |
|---|---|---|---|
| `1.2.840.113556.1.4.319` | Simple Paged Results | ✅ SearchPageSize/Cookie | Já integrado |
| `1.3.6.1.4.1.1466.20037` | StartTLS | ✅ StartTLS() | Já integrado |
| `1.2.840.113556.1.4.801` | SD Flags | ❌ | TActiveDirectoryLDAPSend Fase 1 |
| `1.2.840.113556.1.4.841` | DirSync | ❌ | TActiveDirectoryLDAPSend Fase 1 |
| `1.2.840.113556.1.4.529` | Extended DN (GUID+SID no DN) | ❌ | Fase 2 (via novos métodos em TActiveDirectoryLDAPSend) |
| `1.2.840.113556.1.4.1338` | Show Deleted (tombstones) | ❌ | Fase 2 (via novos métodos em TActiveDirectoryLDAPSend) |
| `1.2.840.113556.1.4.1413` | Permissive Modify | ❌ | Fase 2 (via novos métodos em TActiveDirectoryLDAPSend) |
| `1.2.840.113556.1.4.473` | Server Side Sort | ❌ | Fase 2 (via novos métodos em TActiveDirectoryLDAPSend) |
| `1.2.840.113556.1.4.528` | Notification (async) | ❌ | Não planejado (async complexo) |

**TLS/SSL — cobertura:**

| Requisito | Status | Via |
|---|---|---|
| LDAPS porta 636 (tmLDAPSNoCertCheck) | Planejado Fase A | TTlsMode + blcksock FullSSL |
| LDAPS porta 636 (tmLDAPSWithCA) | Planejado Fase A | TTlsMode + CertCAFile |
| StartTLS porta 389 (tmStartTLS) | Planejado Fase A | TTlsMode + AutoTLS |
| Global Catalog 3268/3269 | Planejado Fase A | IsSSLPort() |
| TLS 1.2 | ✅ blcksock via OpenSSL | Nenhuma mudança |
| TLS 1.3 | ✅ blcksock 009.011.000 | Nenhuma mudança |
| SNI (Server Name Indication) | ✅ blcksock 009.011.000 (SNIHost) | Nenhuma mudança |
| SASL/Signing (`LDAPServerIntegrity=2`) | ❌ Documentar limitação | Simple Bind via LDAPS substitui |
| CBT (`LdapEnforceChannelBinding=2`) | ❌ Documentar limitação | LDAPS substitui |

### Passos da migração

**Passo 1 — Atualizar `app/package/synapse/` com arquivos mais novos do `third_party/`:**

Copiar os arquivos mais recentes (via comparação de versão):

```
third_party/synapse/blcksock.pas   → app/package/synapse/blcksock.pas   (009.011.000 > 009.010.002)
third_party/synapse/synautil.pas   → app/package/synapse/synautil.pas   (verificar versão)
third_party/synapse/synacode.pas   → app/package/synapse/synacode.pas   (verificar versão)
third_party/synapse/asn1util.pas   → app/package/synapse/asn1util.pas   (idêntico — ignorar)
third_party/synapse/ldapsend.pas   → app/package/synapse/ldapsend.pas   (idêntico — fork mínimo será aplicado aqui)
third_party/synapse/synafpc.pas    → app/package/synapse/synafpc.pas    (verificar versão)
third_party/synapse/synaip.pas     → app/package/synapse/synaip.pas     (verificar versão)
third_party/synapse/synsock.pas    → app/package/synapse/synsock.pas    (verificar versão)
third_party/synapse/jedi.inc       → app/package/synapse/jedi.inc       (verificar versão)
```

**Benefício do `blcksock.pas` 009.011.000:** suporte a `SNIHost` (TLS SNI — necessário para ambientes com múltiplos certificados no mesmo servidor); melhor gestão de EOF/WSAECONNRESET em LDAPS.

**Passo 2 — Atualizar caminhos de build:**

`dcc32.cfg` — substituir `third_party\synapse` por `..\..\package\synapse` (ou caminho absoluto):

```
# ANTES:
-I"E:\GestorERP\app\backend-delphi\third_party\synapse"
-U"E:\GestorERP\app\backend-delphi\third_party\synapse"

# DEPOIS:
-I"E:\GestorERP\app\package\synapse"
-U"E:\GestorERP\app\package\synapse"
```

`dcc64.cfg` — mesma substituição.

`GestorERP.Backend.dproj` — linhas 91-92:

```xml
<!-- ANTES: -->
<DCC_IncludeSearchPath>...;third_party\synapse;...</DCC_IncludeSearchPath>
<DCC_UnitSearchPath>...;third_party\synapse;...</DCC_UnitSearchPath>

<!-- DEPOIS (caminho relativo ao .dproj em app/backend-delphi/): -->
<DCC_IncludeSearchPath>...;..\..\package\synapse;...</DCC_IncludeSearchPath>
<DCC_UnitSearchPath>...;..\..\package\synapse;...</DCC_UnitSearchPath>
```

**Passo 4 — Compilar e verificar** (`dcc32` + `dcc64` sem erros).

**Passo 5 — Remover `third_party/synapse/`** após build verde confirmado.

### Arquivos de build impactados

| Arquivo | Mudança |
|---|---|
| `app/backend-delphi/dcc32.cfg` | Substituir path `third_party\synapse` → `..\..\package\synapse` |
| `app/backend-delphi/dcc64.cfg` | Idem |
| `app/backend-delphi/GestorERP.Backend.dproj` | Linhas 91-92: DCC_IncludeSearchPath + DCC_UnitSearchPath |

---

## Revisões do plano

- **2026-04-13 v1:** Análise inicial — paginação assumida ausente no Synapse (incorreto).
- **2026-04-13 v2:** Avaliação Synapse corrigida — `SearchPageSize`/`SearchCookie` implementam paginação; assembly descartado; Indy descartado.
- **2026-04-13 v3:** Controls futuros (DirSync, SD Flags) — decisão: subclasse `TActiveDirectoryLDAPSend` em nova unit `ActiveDirectory.LDAPControls.pas`; sem fork Synapse; novos métodos dedicados (`SearchDirSync`, `SearchWithSDFlags`) sem hiding nem override.
- **2026-04-13 v4:** Análise Synapse 40.1 (FPC/OPM) — `Search()` confirmado NÃO virtual; `ldapsend.pas` idêntico (001.007.001) → módulo compatível FPC; `blcksock.pas` mais novo no GestorERP (009.011.000 vs 009.010.002); `VerifyCert`/`CertCAFile` via `Sock.SSL.*`.
- **2026-04-13 v5:** Restrição de compatibilidade — `ldapsend.pas` sem alteração; novos métodos/classes apenas; method hiding descartado.
- **2026-04-13 (b):** Avaliados [IPWorks 2024 Delphi — LDAP](https://cdn.nsoftware.com/help/IPJ/dlp/LDAP.htm): cobre paging (`PageSize`, eventos `SearchPage`), SSL e operações AD; **opcional comercial** vs Synapse por defeito. [Delphi-PRAXiS](https://www.delphipraxis.net/) é **fórum**, não biblioteca — sem impacto técnico directo no plano.
- **2026-04-13 (c):** Avaliado [ICS Download](https://wiki.overbyte.eu/wiki/index.php/ICS_Download): forte em TLS/OpenSSL e operação Delphi enterprise; potencial para cobrir o plano via adapter opcional, mantendo `Synapse` como default no módulo independente.
---
name: Synapse — Migração + AD 100% em TLDAPSend (001.007.002) incl. GSSAPI/CBT/Signing/Password/Utils
overview: "Reescrever synapse-ldap-fork_b3f4e901.plan.md: migrar third_party→package, atualizar blcksock 009.011.000, adicionar em TLDAPSend tudo para compatibilidade AD 100%: controles AD, GSSAPI/Kerberos, CBT, LDAP Signing, operações de senha, helpers de conta, FileTime, RootDSE, escape, IsMemberOf, SearchAllPages, Sort. Sem dependência externa. Zero quebra de compatibilidade."
---

# Plano: synapse-ldap-fork — AD 100% em TLDAPSend (001.007.002)

## Decisão

Adicionar tudo diretamente em `TLDAPSend` — sem subclasse, sem dependência de ICS ou qualquer unit externa.
SSPI: inline types + `LoadLibrary('secur32.dll')` + `GetProcAddress`.
ssl_openssl.pas: adição mínima para hash do cert TLS (CBT).

---

## Conteúdo a escrever em synapse-ldap-fork_b3f4e901.plan.md

---

### Frontmatter

```yaml
name: Synapse — Migração + Compatibilidade AD 100% em TLDAPSend (001.007.002)
overview: >
  Migrar third_party/synapse → app/package/synapse; atualizar blcksock 009.011.000;
  adicionar em TLDAPSend: controles AD (DirSync/SDFlags/ExtDN/ShowDeleted/ShowRecycled/
  PermModify/TreeDelete/ServerSort), SASL GSSAPI/Kerberos (BindGSSAPI/BindGSSAPIWithCBT),
  LDAP Signing, operações de senha AD (ChangePassword/SetPassword/ForcePasswordChange),
  status de conta (IsAccountLocked/IsAccountDisabled/IsPasswordExpired), FileTime helpers,
  GetRootDSE, EscapeFilterValue/EscapeDNComponent, GUIDToLDAPEscape/SIDToLDAPEscape,
  IsMemberOf, SearchAllPages. Bump 001.007.001→001.007.002. Zero dependência externa.
todos:
  - id: backup-files
    content: "Criar backup .bak de todos os arquivos antes de qualquer alteração: blcksock.pas.bak, ssl_openssl.pas.bak, ssl_openssl_lib.pas.bak, ldapsend.pas.bak, synautil.pas.bak, synacode.pas.bak, synafpc.pas.bak, synaip.pas.bak, synsock.pas.bak, jedi.inc.bak, dcc32.cfg.bak, dcc64.cfg.bak, GestorERP.Backend.dproj.bak."
    status: pending
  - id: update-package-synapse
    content: "Copiar blcksock 009.011.000 de third_party; copiar synautil/synacode/synafpc/synaip/synsock/ssl_openssl se mais novos."
    status: pending
  - id: patch-ssl-openssl
    content: "Adicionar GetPeerCertDER + GetPeerCertSHA256Hash ao TSSLOpenSSL; declarações i2d_X509/EVP_Digest/EVP_sha256 em ssl_openssl_lib.pas."
    status: pending
  - id: patch-ldapsend-header
    content: "Bump 001.007.001→001.007.002; expandir changelog; adicionar constantes AD (portas GC, OIDs, UAC_*, matching rules, DirSync/SD flags, SSPI, CBT); inline SSPI types; global SSPI function pointers."
    status: pending
  - id: patch-ldapsend-fields-decls
    content: "Adicionar campos privados (DirSync, SSPI, Signing); novos métodos private/public/class/published; defaults no constructor; SSPICleanup no destructor."
    status: pending
  - id: patch-ldapsend-controls
    content: "Implementar: BuildADControl, WrapADControls, DoSearchAD, ParseDirSyncCookie, SearchDirSync, SearchWithSDFlags, SearchWithExtendedDN, SearchShowDeleted, SearchShowRecycled, ModifyPermissive, DeleteTree, SearchWithServerSort."
    status: pending
  - id: patch-ldapsend-gssapi
    content: "Implementar: LoadSSPIFunctions, GSSAPIStep, BuildCBTData, BindGSSAPI, BindGSSAPIWithCBT."
    status: pending
  - id: patch-ldapsend-signing
    content: "Implementar: SignLDAPMessage, VerifyLDAPMessage; integrar no DoSearchAD e Modify quando FSigningActive=True."
    status: pending
  - id: patch-ldapsend-password
    content: "Implementar: ChangePassword, SetPassword, ForcePasswordChange; helper EncodeUnicodePwd."
    status: pending
  - id: patch-ldapsend-utils
    content: "Implementar: IsAccountLocked, IsAccountDisabled, IsPasswordExpired (class functions); FileTimeToDateTime, DateTimeToFileTime; GetRootDSE; EscapeFilterValue, EscapeDNComponent; GUIDToLDAPEscape, SIDToLDAPEscape; IsMemberOf; SearchAllPages."
    status: pending
  - id: update-build-paths
    content: "Atualizar dcc32.cfg, dcc64.cfg, GestorERP.Backend.dproj: third_party\\synapse → app\\package\\synapse."
    status: pending
  - id: compile-verify
    content: "dcc32 + dcc64 zero erros; confirmar ldapsend 001.007.002 + blcksock 009.011.000 de app/package/synapse."
    status: pending
  - id: cleanup-third-party
    content: "Remover third_party/synapse/ após build verde."
    status: pending
  - id: generate-docs
    content: "Gerar documentação do pacote synapse 001.007.002 em app/package/synapse/Documentation/ usando documentation-agent-class-scanner + documentation-agent-class-writer: classes TLDAPSend, TSSLOpenSSL, TBlkSock; incluir FLOWCHART.md com diagrama Mermaid da arquitetura; README.md índice linkado."
    status: pending
isProject: false
```

---

## Contexto

Backend GestorERP usa `TLDAPSend` (`app/package/synapse/ldapsend.pas` 001.007.001)
via `Infrastructure/Integrations/ActiveDirectory/M01LdapAuthenticator`.

**Objetivos:**
1. Centralizar em `app/package/synapse/` (eliminar `third_party/`)
2. Atualizar blcksock 009.010.002 → 009.011.000 (fix WSAECONNRESET em LDAPS longas; OAuth2Token)
3. Adicionar **diretamente em `TLDAPSend`** — zero dependência externa:
   - Controles AD: DirSync, SD Flags, Extended DN, Show Deleted, Show Recycled, Permissive Modify, Tree Delete, Server Sort
   - Autenticação Kerberos: SASL GSSAPI via SSPI (`BindGSSAPI`, `BindGSSAPIWithCBT`)
   - LDAP Signing: integridade PDU via SSPI `MakeSignature`/`VerifySignature`
   - Senhas AD: `ChangePassword`, `SetPassword`, `ForcePasswordChange`
   - Status de conta: `IsAccountLocked`, `IsAccountDisabled`, `IsPasswordExpired`
   - Utilitários: FileTime, RootDSE, escape, GUID/SID, `IsMemberOf`, `SearchAllPages`
4. Adição mínima em `ssl_openssl.pas`: `GetPeerCertSHA256Hash` para CBT

**Garantia:** nenhum símbolo existente é removido ou alterado — apenas adições.
**SNIHost** já existe em 009.010.002 (linha 1455) — não é benefício do upgrade.

---

## Passo 0 — Backup dos arquivos originais (.bak)

Antes de qualquer edição, criar cópia `.bak` de cada arquivo que será modificado:

```powershell
# app/package/synapse/
Copy-Item "E:\GestorERP\app\package\synapse\blcksock.pas"          "E:\GestorERP\app\package\synapse\blcksock.pas.bak"
Copy-Item "E:\GestorERP\app\package\synapse\ssl_openssl.pas"       "E:\GestorERP\app\package\synapse\ssl_openssl.pas.bak"
Copy-Item "E:\GestorERP\app\package\synapse\ssl_openssl_lib.pas"   "E:\GestorERP\app\package\synapse\ssl_openssl_lib.pas.bak"
Copy-Item "E:\GestorERP\app\package\synapse\ldapsend.pas"          "E:\GestorERP\app\package\synapse\ldapsend.pas.bak"
Copy-Item "E:\GestorERP\app\package\synapse\synautil.pas"          "E:\GestorERP\app\package\synapse\synautil.pas.bak"
Copy-Item "E:\GestorERP\app\package\synapse\synacode.pas"          "E:\GestorERP\app\package\synapse\synacode.pas.bak"
Copy-Item "E:\GestorERP\app\package\synapse\synafpc.pas"           "E:\GestorERP\app\package\synapse\synafpc.pas.bak"
Copy-Item "E:\GestorERP\app\package\synapse\synaip.pas"            "E:\GestorERP\app\package\synapse\synaip.pas.bak"
Copy-Item "E:\GestorERP\app\package\synapse\synsock.pas"           "E:\GestorERP\app\package\synapse\synsock.pas.bak"
Copy-Item "E:\GestorERP\app\package\synapse\jedi.inc"              "E:\GestorERP\app\package\synapse\jedi.inc.bak"

# app/backend-delphi/ (configs de build)
Copy-Item "E:\GestorERP\app\backend-delphi\dcc32.cfg"                       "E:\GestorERP\app\backend-delphi\dcc32.cfg.bak"
Copy-Item "E:\GestorERP\app\backend-delphi\dcc64.cfg"                       "E:\GestorERP\app\backend-delphi\dcc64.cfg.bak"
Copy-Item "E:\GestorERP\app\backend-delphi\GestorERP.Backend.dproj"         "E:\GestorERP\app\backend-delphi\GestorERP.Backend.dproj.bak"
```

Para reverter qualquer arquivo: `Copy-Item arquivo.pas.bak arquivo.pas -Force`.

---

## Passo 1 — Atualizar app/package/synapse/

| Arquivo | Ação |
|---|---|
| `blcksock.pas` | Copiar de third_party (009.010.002 → 009.011.000) |
| `synautil.pas` | Verificar data; copiar se third_party mais novo |
| `synacode.pas` | Idem |
| `synafpc.pas` | Idem |
| `synaip.pas` | Idem |
| `synsock.pas` | Idem |
| `jedi.inc` | Idem |
| `ssl_openssl.pas` | **Editar** — Passo 2 |
| `ldapsend.pas` | **Editar** — Passos 3-9 |

---

## Passo 2 — ssl_openssl.pas: hash do certificado servidor

Adicionar em `TSSLOpenSSL` (seção public, após `StartTLS`):

```pascal
{:DER-encoded bytes of the server certificate. Empty if no peer cert.}
function GetPeerCertDER: AnsiString;

{:SHA-256 hash (32 raw bytes) of the server certificate DER.
  Used to build Channel Binding Token (tls-server-end-point, RFC 5929).}
function GetPeerCertSHA256Hash: AnsiString;
```

Implementação:

```pascal
function TSSLOpenSSL.GetPeerCertDER: AnsiString;
var
  Cert: PX509;
  Len: Integer;
  Buf: PByte;
begin
  Result := '';
  if FSsl = nil then Exit;
  Cert := SslGetPeerCertificate(FSsl);
  if Cert = nil then Exit;
  Len := i2d_X509(Cert, nil);
  if Len <= 0 then Exit;
  SetLength(Result, Len);
  Buf := PByte(PAnsiChar(Result));
  i2d_X509(Cert, @Buf);
  X509_free(Cert);
end;

function TSSLOpenSSL.GetPeerCertSHA256Hash: AnsiString;
var
  Der: AnsiString;
  Digest: array[0..31] of Byte;
  DigestLen: Cardinal;
begin
  Result := '';
  Der := GetPeerCertDER;
  if Der = '' then Exit;
  DigestLen := 32;
  EVP_Digest(PAnsiChar(Der), Length(Der), @Digest[0], @DigestLen, EVP_sha256, nil);
  SetLength(Result, 32);
  Move(Digest[0], Result[1], 32);
end;
```

Adicionar em `ssl_openssl_lib.pas` (se ausentes):

```pascal
function i2d_X509(x: PX509; buf: PPByte): Integer; cdecl; external LIBSSL;
function EVP_Digest(data: Pointer; count: Cardinal; md: Pointer;
  size: PCardinal; typ: Pointer; impl: Pointer): Integer; cdecl; external LIBSSL;
function EVP_sha256: Pointer; cdecl; external LIBSSL;
```

---

## Passo 3 — ldapsend.pas: bump de versão + constantes

### 3.1 Bump

```
ANTES: | Project : Ararat Synapse | 001.007.001 |
DEPOIS: | Project : Ararat Synapse | 001.007.002 |
```

Changelog a adicionar:

```
| 001.007.002 (2026-04-13): Full Windows AD support directly in TLDAPSend:          |
|   GC ports; AD control OIDs; UAC/DirSync/SD/ExtDN constants; SSPI inline types;  |
|   SearchDirSync, SearchWithSDFlags, SearchWithExtendedDN, SearchShowDeleted,      |
|   SearchShowRecycled, ModifyPermissive, DeleteTree, SearchWithServerSort;          |
|   BindGSSAPI, BindGSSAPIWithCBT (SSPI/Kerberos + RFC5929 CBT);                   |
|   LDAP Signing (MakeSignature/VerifySignature); ChangePassword, SetPassword,      |
|   ForcePasswordChange; IsAccountLocked/Disabled/Expired; FileTimeToDateTime;      |
|   GetRootDSE; EscapeFilterValue; EscapeDNComponent; GUIDToLDAPEscape;            |
|   SIDToLDAPEscape; IsMemberOf; SearchAllPages. ssl_openssl: GetPeerCertSHA256Hash.|
|   Zero external dependencies. Fully backward compatible. (fork GestorERP)        |
```

### 3.2 Constantes AD (inserir após `cLDAPProtocol = '389'`)

```pascal
  { Active Directory — Global Catalog ports }
  cLDAP_GC_PORT  = '3268';
  cLDAPS_GC_PORT = '3269';

  { AD LDAP control OIDs }
  LDAP_OID_PAGED_RESULTS  = '1.2.840.113556.1.4.319';
  LDAP_OID_DIRSYNC        = '1.2.840.113556.1.4.841';
  LDAP_OID_SD_FLAGS       = '1.2.840.113556.1.4.801';
  LDAP_OID_EXTENDED_DN    = '1.2.840.113556.1.4.529';
  LDAP_OID_SHOW_DELETED   = '1.2.840.113556.1.4.1338';
  LDAP_OID_SHOW_RECYCLED  = '1.2.840.113556.1.4.2064';
  LDAP_OID_PERM_MODIFY    = '1.2.840.113556.1.4.1413';
  LDAP_OID_TREE_DELETE    = '1.2.840.113556.1.4.805';
  LDAP_OID_SERVER_SORT    = '1.2.840.113556.1.4.473';
  LDAP_OID_NOTIFICATION   = '1.2.840.113556.1.4.528';

  { AD matching rules (use in filter strings, not as controls) }
  LDAP_MATCHING_RULE_BIT_AND  = '1.2.840.113556.1.4.803';
  LDAP_MATCHING_RULE_BIT_OR   = '1.2.840.113556.1.4.804';
  LDAP_MATCHING_RULE_IN_CHAIN = '1.2.840.113556.1.4.1941';

  { userAccountControl flags }
  UAC_ACCOUNTDISABLE       = $00000002;
  UAC_HOMEDIR_REQUIRED     = $00000008;
  UAC_LOCKOUT              = $00000010;
  UAC_PASSWD_NOTREQD       = $00000020;
  UAC_PASSWD_CANT_CHANGE   = $00000040;
  UAC_ENCRYPTED_TEXT_PWD   = $00000080;
  UAC_NORMAL_ACCOUNT       = $00000200;
  UAC_DONT_EXPIRE_PASSWD   = $00010000;
  UAC_SMARTCARD_REQUIRED   = $00040000;
  UAC_PASSWORD_EXPIRED     = $00800000;
  UAC_TRUSTED_FOR_DELEG    = $00080000;

  { DirSync flags }
  LDAP_DIRSYNC_OBJECT_SECURITY    = $00000001;
  LDAP_DIRSYNC_ANCESTORS_FIRST    = $00000800;
  LDAP_DIRSYNC_INCREMENTAL_VALUES = Integer($80000000);
  LDAP_DIRSYNC_MAX_BYTES_DEFAULT  = 1048576;

  { SD Flags (nTSecurityDescriptor parts) }
  LDAP_SD_OWNER = $00000001;
  LDAP_SD_GROUP = $00000002;
  LDAP_SD_DACL  = $00000004;
  LDAP_SD_SACL  = $00000008;
  LDAP_SD_ALL   = $00000007;   // OWNER+GROUP+DACL (SACL needs SeSecurityPrivilege)

  { Extended DN format flags }
  LDAP_EXTENDED_DN_HEX_STRING = 0;
  LDAP_EXTENDED_DN_STANDARD   = 1;

  { SSPI/Kerberos constants }
  LDAP_SASL_GSSAPI            = 'GSSAPI';
  LDAP_SPN_PREFIX             = 'ldap/';   // SPN format: ldap/<fqdn-dc>
  ISC_REQ_MUTUAL_AUTH         = $00000002;
  ISC_REQ_SEQUENCE_DETECT     = $00000008;
  ISC_REQ_CONFIDENTIALITY     = $00000010;
  ISC_REQ_INTEGRITY           = $00010000;
  SECBUFFER_VERSION           = 0;
  SECBUFFER_DATA              = 1;
  SECBUFFER_TOKEN             = 2;
  SECBUFFER_CHANNEL_BINDINGS  = 10;
  SECURITY_NETWORK_DREP       = 0;
  SEC_E_OK                    = 0;
  SEC_I_CONTINUE_NEEDED       = $00090312;
  SEC_I_COMPLETE_NEEDED       = $00090313;
  SEC_I_COMPLETE_AND_CONTINUE = $00090314;

  { Channel Binding Token prefix (RFC 5929) }
  LDAP_CBT_PREFIX = 'tls-server-end-point:';

  { Windows FILETIME epoch delta: days from 1601-01-01 to 1899-12-30 (Delphi TDateTime epoch) }
  LDAP_FILETIME_EPOCH_DAYS = 109205;
```

### 3.3 Tipos SSPI inline (seção `type`, antes de `TLDAPAttribute`)

```pascal
  { SSPI handle — secur32.dll (inline, sem dependência de unit externa) }
  TLDAPSecHandle = record
    dwLower: NativeUInt;
    dwUpper: NativeUInt;
  end;
  PLDAPSecHandle = ^TLDAPSecHandle;

  TLDAPSecBuffer = record
    cbBuffer:   Cardinal;
    BufferType: Cardinal;
    pvBuffer:   Pointer;
  end;
  PLDAPSecBuffer = ^TLDAPSecBuffer;

  TLDAPSecBufferDesc = record
    ulVersion: Cardinal;
    cBuffers:  Cardinal;
    pBuffers:  PLDAPSecBuffer;
  end;
```

> **Prefixo LDAP** nos tipos SSPI evita colisão com OverbyteIcsSspi se a unit for usada no mesmo projeto.

### 3.4 Variáveis globais — ponteiros SSPI (seção `var`, antes do `implementation`)

```pascal
var
  FLDAPSecur32Lib: HMODULE = 0;

  LDAP_AcquireCredentialsHandle: function(
    pszPrincipal, pszPackage: PWideChar; fCredentialUse: Cardinal;
    pvLogonID, pAuthData, pGetKeyFn, pvGetKeyArg: Pointer;
    phCredential: PLDAPSecHandle; ptsExpiry: Pointer): Integer; stdcall;

  LDAP_InitializeSecurityContext: function(
    phCredential, phContext: PLDAPSecHandle; pszTargetName: PWideChar;
    fContextReq, Reserved1, TargetDataRep: Cardinal;
    pInput: Pointer; Reserved2: Cardinal; phNewContext: PLDAPSecHandle;
    pOutput: Pointer; pfContextAttr: PCardinal; ptsExpiry: Pointer): Integer; stdcall;

  LDAP_CompleteAuthToken: function(
    phContext: PLDAPSecHandle; pToken: Pointer): Integer; stdcall;

  LDAP_MakeSignature: function(
    phContext: PLDAPSecHandle; fQOP: Cardinal;
    pMessage: Pointer; MessageSeqNo: Cardinal): Integer; stdcall;

  LDAP_VerifySignature: function(
    phContext: PLDAPSecHandle; pMessage: Pointer;
    MessageSeqNo: Cardinal; pfQOP: PCardinal): Integer; stdcall;

  LDAP_DeleteSecurityContext: function(
    phContext: PLDAPSecHandle): Integer; stdcall;

  LDAP_FreeCredentialsHandle: function(
    phCredential: PLDAPSecHandle): Integer; stdcall;
```

---

## Passo 4 — ldapsend.pas: campos + declarações em TLDAPSend

### 4.1 Novos campos privados (após `FExtValue: AnsiString`)

```pascal
    { AD DirSync state }
    FDirSyncCookie:   AnsiString;
    FDirSyncFlags:    Integer;
    FDirSyncMaxBytes: Integer;
    FDirSyncResult:   AnsiString;
    { SSPI/GSSAPI state }
    FSSPICred:        TLDAPSecHandle;
    FSSPICtx:         TLDAPSecHandle;
    FSSPIHaveCred:    Boolean;
    FSSPIHaveCtx:     Boolean;
    FSigningActive:   Boolean;
    FSigningSeqNo:    Cardinal;
```

### 4.2 Novos métodos privados

```pascal
    { AD helpers }
    function  BuildADControl(const AOID: AnsiString; ACritical: Boolean;
                             const AValue: AnsiString): AnsiString;
    function  WrapADControls(const AControlsBlock: AnsiString): AnsiString;
    function  DoSearchAD(const ABase, AFilter: AnsiString;
                         AScope: TLDAPSearchScope; const AAttributes: TStrings;
                         const AControlsBlock: AnsiString): Boolean;
    procedure ParseDirSyncCookie(const AResponseBlock: AnsiString);
    { Password }
    function  EncodeUnicodePwd(const APassword: AnsiString): AnsiString;
    { SSPI }
    procedure LoadSSPIFunctions;
    procedure SSPICleanup;
    function  GSSAPIStep(const AInToken: AnsiString; const ASPN: WideString;
                         const ACBTData: AnsiString;
                         out AOutToken: AnsiString): Integer;
    function  BuildCBTData(const ACertHash: AnsiString): AnsiString;
    { Signing }
    function  SignLDAPMessage(const AMsg: AnsiString): AnsiString;
    function  VerifyLDAPMessage(const ASignedMsg: AnsiString;
                                out APlain: AnsiString): Boolean;
```

### 4.3 Constructor e Destructor (sobrescrever)

```pascal
    constructor Create; override;
    destructor  Destroy; override;
```

Implementação:

```pascal
constructor TLDAPSend.Create;
begin
  inherited Create;
  { DirSync defaults }
  FDirSyncFlags    := LDAP_DIRSYNC_INCREMENTAL_VALUES;
  FDirSyncMaxBytes := LDAP_DIRSYNC_MAX_BYTES_DEFAULT;
  FDirSyncCookie   := '';
  FDirSyncResult   := '';
  { SSPI defaults }
  FSSPIHaveCred  := False;
  FSSPIHaveCtx   := False;
  FSigningActive := False;
  FSigningSeqNo  := 0;
end;

destructor TLDAPSend.Destroy;
begin
  SSPICleanup;
  inherited Destroy;
end;
```

### 4.4 Novos métodos públicos

```pascal
    { Binary encoding helper }
    function EncodeADControl(const AOID: AnsiString; ACritical: Boolean;
                             const AValue: AnsiString): AnsiString;

    { AD Search controls }
    function SearchDirSync(const ABase, AFilter: AnsiString;
                           AScope: TLDAPSearchScope;
                           const AAttributes: TStrings): Boolean;
    function SearchWithSDFlags(const ABase, AFilter: AnsiString;
                               AScope: TLDAPSearchScope; ASDFlags: Integer;
                               const AAttributes: TStrings): Boolean;
    function SearchWithExtendedDN(const ABase, AFilter: AnsiString;
                                  AScope: TLDAPSearchScope;
                                  const AAttributes: TStrings;
                                  AFlag: Integer = LDAP_EXTENDED_DN_STANDARD): Boolean;
    function SearchShowDeleted(const ABase, AFilter: AnsiString;
                               AScope: TLDAPSearchScope;
                               const AAttributes: TStrings): Boolean;
    function SearchShowRecycled(const ABase, AFilter: AnsiString;
                                AScope: TLDAPSearchScope;
                                const AAttributes: TStrings): Boolean;
    function SearchWithServerSort(const ABase, AFilter: AnsiString;
                                  AScope: TLDAPSearchScope;
                                  const ASortAttribute: AnsiString;
                                  const AAttributes: TStrings): Boolean;

    { AD Modify/Delete controls }
    function ModifyPermissive(const AObj: AnsiString; AOp: TLDAPModifyOp;
                              const AValue: TLDAPAttribute): Boolean;
    function DeleteTree(const AObj: AnsiString): Boolean;

    { SASL GSSAPI/Kerberos }
    function BindGSSAPI(const ASPN: AnsiString): Boolean;
    function BindGSSAPIWithCBT(const ASPN, ACertHash: AnsiString): Boolean;

    { Password operations (require LDAPS — port 636 or StartTLS) }
    function ChangePassword(const AUserDN, AOldPassword,
                            ANewPassword: AnsiString): Boolean;
    function SetPassword(const AUserDN, ANewPassword: AnsiString): Boolean;
    function ForcePasswordChange(const AUserDN: AnsiString): Boolean;

    { Account status (class functions — pure helpers, take UAC integer) }
    class function IsAccountLocked(AUac: Integer): Boolean;
    class function IsAccountDisabled(AUac: Integer): Boolean;
    class function IsPasswordExpired(AUac: Integer): Boolean;

    { FileTime helpers (class functions) }
    class function FileTimeToDateTime(AFileTime: Int64): TDateTime;
    class function DateTimeToFileTime(ADateTime: TDateTime): Int64;

    { RootDSE }
    function GetRootDSE(const AAttributes: TStrings): Boolean;

    { Filter / DN escaping (class functions) }
    class function EscapeFilterValue(const AValue: AnsiString): AnsiString;
    class function EscapeDNComponent(const AValue: AnsiString): AnsiString;

    { Binary attribute helpers (class functions) }
    class function GUIDToLDAPEscape(const AGUID: TGUID): AnsiString;
    class function SIDToLDAPEscape(const ASIDBytes: AnsiString): AnsiString;

    { Membership and pagination }
    function IsMemberOf(const AUserDN, AGroupDN, ABase: AnsiString): Boolean;
    function SearchAllPages(const ABase, AFilter: AnsiString;
                            AScope: TLDAPSearchScope;
                            const AAttributes: TStrings;
                            APageSize: Integer;
                            AAccumulate: TLDAPResultList): Boolean;
```

### 4.5 Novos published

```pascal
    property DirSyncCookie:   AnsiString read FDirSyncCookie   write FDirSyncCookie;
    property DirSyncFlags:    Integer    read FDirSyncFlags     write FDirSyncFlags;
    property DirSyncMaxBytes: Integer    read FDirSyncMaxBytes  write FDirSyncMaxBytes;
    property DirSyncResult:   AnsiString read FDirSyncResult;
    property SigningActive:    Boolean    read FSigningActive;
```

---

## Passo 5 — Implementação: controles AD

### BuildADControl

```pascal
function TLDAPSend.BuildADControl(const AOID: AnsiString;
  ACritical: Boolean; const AValue: AnsiString): AnsiString;
var
  c: AnsiString;
begin
  c := ASNObject(AOID, ASN1_OCTSTR)
     + ASNObject(ASNEncInt(Ord(ACritical)), ASN1_BOOL);
  if AValue <> '' then
    c := c + ASNObject(AValue, ASN1_OCTSTR);
  Result := ASNObject(c, ASN1_SEQ);
end;
```

### WrapADControls

```pascal
function TLDAPSend.WrapADControls(const AControlsBlock: AnsiString): AnsiString;
begin
  // LDAP controls are tagged as context [0] IMPLICIT SEQUENCE OF Control
  Result := ASNObject(AControlsBlock, $A0);
end;
```

### DoSearchAD

```pascal
function TLDAPSend.DoSearchAD(const ABase, AFilter: AnsiString;
  AScope: TLDAPSearchScope; const AAttributes: TStrings;
  const AControlsBlock: AnsiString): Boolean;
var
  s, attrlist: AnsiString;
  i: Integer;
begin
  // Build attribute list
  attrlist := '';
  if Assigned(AAttributes) then
    for i := 0 to AAttributes.Count - 1 do
      attrlist := attrlist + ASNObject(AAttributes[i], ASN1_OCTSTR);

  // Build SearchRequest PDU
  s := ASNObject(ABase, ASN1_OCTSTR)
     + ASNObject(ASNEncInt(Ord(AScope)), ASN1_ENUM)
     + ASNObject(ASNEncInt(0), ASN1_ENUM)   // derefAliases=never
     + ASNObject(ASNEncInt(0), ASN1_INT)    // sizeLimit
     + ASNObject(ASNEncInt(FTimeout), ASN1_INT)
     + ASNObject(ASNEncInt(0), ASN1_BOOL)   // typesOnly=false
     + TranslateFilter(AFilter)
     + ASNObject(attrlist, ASN1_SEQ);

  s := ASNObject(s, LDAP_ASN1_SEARCH_REQUEST);

  // Append controls block
  if AControlsBlock <> '' then
    s := s + AControlsBlock;

  if FSigningActive then
    FSock.SendString(SignLDAPMessage(BuildPacket(s)))
  else
    FSock.SendString(BuildPacket(s));

  Result := ReceiveSearchResult;
end;
```

### ParseDirSyncCookie

```pascal
procedure TLDAPSend.ParseDirSyncCookie(const AResponseBlock: AnsiString);
var
  x, t: Integer;
  s: AnsiString;
begin
  // Walk the SearchResultDone controls ($A0) to extract DirSync cookie
  // The cookie is in the controlValue OCTET STRING of OID 1.2.840.113556.1.4.841
  // Implementation: ASNItem walk looking for LDAP_OID_DIRSYNC then extract cookie bytes
  FDirSyncResult := '';  // set to '' if not found (no more changes)
  // ... (full ASNItem traversal)
end;
```

### SearchDirSync

```pascal
function TLDAPSend.SearchDirSync(const ABase, AFilter: AnsiString;
  AScope: TLDAPSearchScope; const AAttributes: TStrings): Boolean;
var
  cv, ctrl: AnsiString;
begin
  // DirSync control value: SEQUENCE { flags INT, maxBytes INT, cookie OCTET STRING }
  cv := ASNObject(ASNEncInt(FDirSyncFlags), ASN1_INT)
      + ASNObject(ASNEncInt(FDirSyncMaxBytes), ASN1_INT)
      + ASNObject(FDirSyncCookie, ASN1_OCTSTR);
  cv := ASNObject(cv, ASN1_SEQ);
  ctrl := WrapADControls(BuildADControl(LDAP_OID_DIRSYNC, True, cv));
  Result := DoSearchAD(ABase, AFilter, AScope, AAttributes, ctrl);
  if Result then ParseDirSyncCookie(FData);  // FData = raw response
end;
```

### SearchWithSDFlags

```pascal
function TLDAPSend.SearchWithSDFlags(const ABase, AFilter: AnsiString;
  AScope: TLDAPSearchScope; ASDFlags: Integer;
  const AAttributes: TStrings): Boolean;
var
  cv, ctrl: AnsiString;
begin
  cv := ASNObject(ASNObject(ASNEncInt(ASDFlags), ASN1_INT), ASN1_SEQ);
  ctrl := WrapADControls(BuildADControl(LDAP_OID_SD_FLAGS, True, cv));
  Result := DoSearchAD(ABase, AFilter, AScope, AAttributes, ctrl);
end;
```

### SearchWithExtendedDN

```pascal
function TLDAPSend.SearchWithExtendedDN(const ABase, AFilter: AnsiString;
  AScope: TLDAPSearchScope; const AAttributes: TStrings;
  AFlag: Integer): Boolean;
var
  cv, ctrl: AnsiString;
begin
  cv := ASNObject(ASNObject(ASNEncInt(AFlag), ASN1_INT), ASN1_SEQ);
  ctrl := WrapADControls(BuildADControl(LDAP_OID_EXTENDED_DN, False, cv));
  Result := DoSearchAD(ABase, AFilter, AScope, AAttributes, ctrl);
end;
```

### SearchShowDeleted / SearchShowRecycled (flag-only controls, no value)

```pascal
function TLDAPSend.SearchShowDeleted(const ABase, AFilter: AnsiString;
  AScope: TLDAPSearchScope; const AAttributes: TStrings): Boolean;
var
  ctrl: AnsiString;
begin
  ctrl := WrapADControls(BuildADControl(LDAP_OID_SHOW_DELETED, False, ''));
  Result := DoSearchAD(ABase, AFilter, AScope, AAttributes, ctrl);
end;

function TLDAPSend.SearchShowRecycled(const ABase, AFilter: AnsiString;
  AScope: TLDAPSearchScope; const AAttributes: TStrings): Boolean;
var
  ctrl: AnsiString;
begin
  ctrl := WrapADControls(BuildADControl(LDAP_OID_SHOW_RECYCLED, False, ''));
  Result := DoSearchAD(ABase, AFilter, AScope, AAttributes, ctrl);
end;
```

### ModifyPermissive

```pascal
function TLDAPSend.ModifyPermissive(const AObj: AnsiString;
  AOp: TLDAPModifyOp; const AValue: TLDAPAttribute): Boolean;
var
  ctrl, origCtrl: AnsiString;
begin
  // Save/restore FControls if TLDAPSend exposes it; otherwise inline the modify PDU
  // with Permissive Modify control appended
  ctrl := WrapADControls(BuildADControl(LDAP_OID_PERM_MODIFY, False, ''));
  // Use existing Modify logic + append ctrl to the packet
  Result := Modify(AObj, AOp, AValue);  // existing method — needs control injection
  // NOTE: if Modify does not accept extra controls, wrap its PDU with ctrl manually
end;
```

### DeleteTree

```pascal
function TLDAPSend.DeleteTree(const AObj: AnsiString): Boolean;
var
  s: AnsiString;
begin
  s := ASNObject(AObj, ASN1_OCTSTR);
  s := ASNObject(s, LDAP_ASN1_DEL_REQUEST);
  s := s + WrapADControls(BuildADControl(LDAP_OID_TREE_DELETE, False, ''));
  FSock.SendString(BuildPacket(s));
  Result := ReceiveResponse and (ResultCode = 0);
end;
```

### SearchWithServerSort

```pascal
function TLDAPSend.SearchWithServerSort(const ABase, AFilter: AnsiString;
  AScope: TLDAPSearchScope; const ASortAttribute: AnsiString;
  const AAttributes: TStrings): Boolean;
var
  cv, ctrl: AnsiString;
begin
  // SortKeyList ::= SEQUENCE OF SEQUENCE { attributeType OCTET STRING }
  cv := ASNObject(ASNObject(ASortAttribute, ASN1_OCTSTR), ASN1_SEQ);
  cv := ASNObject(cv, ASN1_SEQ);
  ctrl := WrapADControls(BuildADControl(LDAP_OID_SERVER_SORT, False, cv));
  Result := DoSearchAD(ABase, AFilter, AScope, AAttributes, ctrl);
end;
```

---

## Passo 6 — Implementação: SASL GSSAPI/Kerberos

### LoadSSPIFunctions

```pascal
procedure TLDAPSend.LoadSSPIFunctions;
begin
  if FLDAPSecur32Lib <> 0 then Exit;
  FLDAPSecur32Lib := LoadLibrary('secur32.dll');
  if FLDAPSecur32Lib = 0 then
    raise Exception.Create('secur32.dll not found — SSPI unavailable');
  @LDAP_AcquireCredentialsHandle  := GetProcAddress(FLDAPSecur32Lib, 'AcquireCredentialsHandleW');
  @LDAP_InitializeSecurityContext := GetProcAddress(FLDAPSecur32Lib, 'InitializeSecurityContextW');
  @LDAP_CompleteAuthToken         := GetProcAddress(FLDAPSecur32Lib, 'CompleteAuthToken');
  @LDAP_MakeSignature             := GetProcAddress(FLDAPSecur32Lib, 'MakeSignature');
  @LDAP_VerifySignature           := GetProcAddress(FLDAPSecur32Lib, 'VerifySignature');
  @LDAP_DeleteSecurityContext     := GetProcAddress(FLDAPSecur32Lib, 'DeleteSecurityContext');
  @LDAP_FreeCredentialsHandle     := GetProcAddress(FLDAPSecur32Lib, 'FreeCredentialsHandle');
end;
```

### SSPICleanup

```pascal
procedure TLDAPSend.SSPICleanup;
begin
  if FSSPIHaveCtx  then LDAP_DeleteSecurityContext(@FSSPICtx);
  if FSSPIHaveCred then LDAP_FreeCredentialsHandle(@FSSPICred);
  FSSPIHaveCtx   := False;
  FSSPIHaveCred  := False;
  FSigningActive := False;
  FSigningSeqNo  := 0;
end;
```

### GSSAPIStep

```pascal
function TLDAPSend.GSSAPIStep(const AInToken: AnsiString;
  const ASPN: WideString; const ACBTData: AnsiString;
  out AOutToken: AnsiString): Integer;
var
  InBufs:  array[0..1] of TLDAPSecBuffer;
  OutBufs: array[0..0] of TLDAPSecBuffer;
  InDesc, OutDesc: TLDAPSecBufferDesc;
  OutTok:  array[0..16383] of Byte;
  pCtx:    PLDAPSecHandle;
  CtxAttr: Cardinal;
begin
  AOutToken := '';
  LoadSSPIFunctions;

  if not FSSPIHaveCred then
  begin
    Result := LDAP_AcquireCredentialsHandle(nil, 'Kerberos', 2{OUTBOUND},
      nil, nil, nil, nil, @FSSPICred, nil);
    if Result <> SEC_E_OK then Exit;
    FSSPIHaveCred := True;
  end;

  // Input buffers
  InBufs[0].cbBuffer   := Length(AInToken);
  InBufs[0].BufferType := SECBUFFER_TOKEN;
  InBufs[0].pvBuffer   := PAnsiChar(AInToken);
  InBufs[1].cbBuffer   := 0;
  InBufs[1].BufferType := SECBUFFER_CHANNEL_BINDINGS;
  InBufs[1].pvBuffer   := nil;
  InDesc.ulVersion := SECBUFFER_VERSION;
  InDesc.cBuffers  := 1;
  InDesc.pBuffers  := @InBufs[0];
  if ACBTData <> '' then
  begin
    InBufs[1].cbBuffer   := Length(ACBTData);
    InBufs[1].pvBuffer   := PAnsiChar(ACBTData);
    InDesc.cBuffers      := 2;
  end;

  // Output buffer
  OutBufs[0].cbBuffer   := SizeOf(OutTok);
  OutBufs[0].BufferType := SECBUFFER_TOKEN;
  OutBufs[0].pvBuffer   := @OutTok[0];
  OutDesc.ulVersion := SECBUFFER_VERSION;
  OutDesc.cBuffers  := 1;
  OutDesc.pBuffers  := @OutBufs[0];

  if FSSPIHaveCtx then pCtx := @FSSPICtx else pCtx := nil;

  Result := LDAP_InitializeSecurityContext(
    @FSSPICred, pCtx, PWideChar(ASPN),
    ISC_REQ_INTEGRITY or ISC_REQ_SEQUENCE_DETECT or ISC_REQ_MUTUAL_AUTH,
    0, SECURITY_NETWORK_DREP,
    @InDesc, 0, @FSSPICtx, @OutDesc, @CtxAttr, nil);
  FSSPIHaveCtx := True;

  if (Result = SEC_I_COMPLETE_NEEDED) or (Result = SEC_I_COMPLETE_AND_CONTINUE) then
    LDAP_CompleteAuthToken(@FSSPICtx, @OutDesc);

  if OutBufs[0].cbBuffer > 0 then
  begin
    SetLength(AOutToken, OutBufs[0].cbBuffer);
    Move(OutTok[0], AOutToken[1], OutBufs[0].cbBuffer);
  end;

  if (Result = SEC_E_OK) and ((CtxAttr and ISC_REQ_INTEGRITY) <> 0) then
    FSigningActive := True;
end;
```

### BuildCBTData / BindGSSAPI / BindGSSAPIWithCBT

```pascal
function TLDAPSend.BuildCBTData(const ACertHash: AnsiString): AnsiString;
begin
  Result := LDAP_CBT_PREFIX + ACertHash;  // 'tls-server-end-point:' + 32 bytes SHA-256
end;

function TLDAPSend.BindGSSAPI(const ASPN: AnsiString): Boolean;
begin
  Result := BindGSSAPIWithCBT(ASPN, '');
end;

function TLDAPSend.BindGSSAPIWithCBT(const ASPN, ACertHash: AnsiString): Boolean;
var
  InToken, OutToken, CBT, s: AnsiString;
  Status: Integer;
  WSPN: WideString;
begin
  Result := False;
  WSPN := WideString(ASPN);
  if ACertHash <> '' then CBT := BuildCBTData(ACertHash)
  else CBT := '';

  SSPICleanup;
  InToken := '';
  repeat
    Status := GSSAPIStep(InToken, WSPN, CBT, OutToken);
    if (Status <> SEC_E_OK) and
       (Status <> SEC_I_CONTINUE_NEEDED) and
       (Status <> SEC_I_COMPLETE_NEEDED) and
       (Status <> SEC_I_COMPLETE_AND_CONTINUE) then
      Exit;

    if OutToken <> '' then
    begin
      // Send SASL BindRequest: version + username + [3] SASL (mechanism + credentials)
      s := ASNObject(ASNEncInt(FVersion), ASN1_INT)
         + ASNObject(FUsername, ASN1_OCTSTR)
         + ASNObject(
             ASNObject(LDAP_SASL_GSSAPI, ASN1_OCTSTR) +
             ASNObject(OutToken, ASN1_OCTSTR),
             $A3);
      s := ASNObject(s, LDAP_ASN1_BIND_REQUEST);
      FSock.SendString(BuildPacket(s));

      // Read BindResponse — extract serverSaslCreds as next InToken
      s := ReceiveResponse;
      s := DecodeResponse(s);
      if (FResultCode = 0) or (FResultCode = 14 {saslBindInProgress}) then
        InToken := s  // serverSaslCreds returned by DecodeResponse
      else
        Exit;
    end;
  until Status = SEC_E_OK;

  Result := True;
end;
```

---

## Passo 7 — Implementação: LDAP Signing

### SignLDAPMessage

```pascal
function TLDAPSend.SignLDAPMessage(const AMsg: AnsiString): AnsiString;
var
  Bufs: array[0..1] of TLDAPSecBuffer;
  Desc: TLDAPSecBufferDesc;
  SigBuf: array[0..255] of Byte;
begin
  Result := AMsg;
  if not FSigningActive then Exit;

  Bufs[0].cbBuffer   := Length(AMsg);
  Bufs[0].BufferType := SECBUFFER_DATA;
  Bufs[0].pvBuffer   := PAnsiChar(AMsg);
  Bufs[1].cbBuffer   := SizeOf(SigBuf);
  Bufs[1].BufferType := SECBUFFER_TOKEN;
  Bufs[1].pvBuffer   := @SigBuf[0];
  Desc.ulVersion := SECBUFFER_VERSION;
  Desc.cBuffers  := 2;
  Desc.pBuffers  := @Bufs[0];

  if LDAP_MakeSignature(@FSSPICtx, 0, @Desc, FSigningSeqNo) = SEC_E_OK then
  begin
    Inc(FSigningSeqNo);
    // Wire format: 4-byte LE sig length + sig bytes + original message
    SetLength(Result, 4 + Bufs[1].cbBuffer + Length(AMsg));
    PCardinal(@Result[1])^ := Bufs[1].cbBuffer;
    Move(SigBuf[0], Result[5], Bufs[1].cbBuffer);
    Move(AMsg[1], Result[5 + Integer(Bufs[1].cbBuffer)], Length(AMsg));
  end;
end;
```

### VerifyLDAPMessage

```pascal
function TLDAPSend.VerifyLDAPMessage(const ASignedMsg: AnsiString;
  out APlain: AnsiString): Boolean;
var
  SigLen: Cardinal;
  Bufs: array[0..1] of TLDAPSecBuffer;
  Desc: TLDAPSecBufferDesc;
  fQOP: Cardinal;
begin
  Result := True;
  APlain := ASignedMsg;
  if not FSigningActive then Exit;

  SigLen := PCardinal(@ASignedMsg[1])^;
  APlain := Copy(ASignedMsg, 5 + Integer(SigLen), MaxInt);

  Bufs[0].cbBuffer   := Length(APlain);
  Bufs[0].BufferType := SECBUFFER_DATA;
  Bufs[0].pvBuffer   := PAnsiChar(APlain);
  Bufs[1].cbBuffer   := SigLen;
  Bufs[1].BufferType := SECBUFFER_TOKEN;
  Bufs[1].pvBuffer   := PAnsiChar(ASignedMsg) + 4;

  Desc.ulVersion := SECBUFFER_VERSION;
  Desc.cBuffers  := 2;
  Desc.pBuffers  := @Bufs[0];

  Result := (LDAP_VerifySignature(@FSSPICtx, @Desc, FSigningSeqNo, @fQOP) = SEC_E_OK);
  if Result then Inc(FSigningSeqNo);
end;
```

---

## Passo 8 — Implementação: operações de senha AD

> Todas as operações de senha **exigem LDAPS** (porta 636 ou StartTLS).
> unicodePwd é transmitido como UTF-16LE entre aspas: `"SenhaAqui"`.

### EncodeUnicodePwd

```pascal
function TLDAPSend.EncodeUnicodePwd(const APassword: AnsiString): AnsiString;
var
  Quoted: WideString;
  Buf: AnsiString;
begin
  Quoted := WideString('"' + APassword + '"');
  SetLength(Buf, Length(Quoted) * 2);
  Move(Quoted[1], Buf[1], Length(Quoted) * 2);
  Result := Buf;
end;
```

### ChangePassword

```pascal
function TLDAPSend.ChangePassword(const AUserDN,
  AOldPassword, ANewPassword: AnsiString): Boolean;
var
  OldAttr, NewAttr: TLDAPAttribute;
begin
  OldAttr := TLDAPAttribute.Create;
  NewAttr := TLDAPAttribute.Create;
  try
    OldAttr.AttributeName := 'unicodePwd';
    OldAttr.Add(EncodeUnicodePwd(AOldPassword));
    NewAttr.AttributeName := 'unicodePwd';
    NewAttr.Add(EncodeUnicodePwd(ANewPassword));
    // AD requires delete-old + add-new in a single Modify request
    // Use ModifyOp sequence: modDelete then modAdd
    Result := Modify(AUserDN, MO_Delete, OldAttr) and
              Modify(AUserDN, MO_Add, NewAttr);
    // NOTE: ideal implementation sends both ops in ONE Modify PDU
    // If TLDAPSend.Modify does not support batching, build the PDU manually
  finally
    OldAttr.Free;
    NewAttr.Free;
  end;
end;
```

### SetPassword (admin reset)

```pascal
function TLDAPSend.SetPassword(const AUserDN,
  ANewPassword: AnsiString): Boolean;
var
  Attr: TLDAPAttribute;
begin
  Attr := TLDAPAttribute.Create;
  try
    Attr.AttributeName := 'unicodePwd';
    Attr.Add(EncodeUnicodePwd(ANewPassword));
    Result := Modify(AUserDN, MO_Replace, Attr);
  finally
    Attr.Free;
  end;
end;
```

### ForcePasswordChange

```pascal
function TLDAPSend.ForcePasswordChange(const AUserDN: AnsiString): Boolean;
var
  Attr: TLDAPAttribute;
begin
  Attr := TLDAPAttribute.Create;
  try
    Attr.AttributeName := 'pwdLastSet';
    Attr.Add('0');  // '0' forces change on next logon
    Result := Modify(AUserDN, MO_Replace, Attr);
  finally
    Attr.Free;
  end;
end;
```

---

## Passo 9 — Implementação: utilitários

### Account status (class functions)

```pascal
class function TLDAPSend.IsAccountLocked(AUac: Integer): Boolean;
begin
  Result := (AUac and UAC_LOCKOUT) <> 0;
end;

class function TLDAPSend.IsAccountDisabled(AUac: Integer): Boolean;
begin
  Result := (AUac and UAC_ACCOUNTDISABLE) <> 0;
end;

class function TLDAPSend.IsPasswordExpired(AUac: Integer): Boolean;
begin
  Result := (AUac and UAC_PASSWORD_EXPIRED) <> 0;
end;
```

### FileTime helpers

```pascal
class function TLDAPSend.FileTimeToDateTime(AFileTime: Int64): TDateTime;
const
  // Days from 1601-01-01 (FILETIME epoch) to 1899-12-30 (Delphi TDateTime epoch)
  EPOCH_DAYS    = Int64(109205);
  TICKS_PER_DAY = Int64(864000000000);  // 1 day = 86400 s * 10^7 100ns-ticks
begin
  // 0 and $7FFFFFFFFFFFFFFF are AD sentinel values meaning "never/not set"
  if (AFileTime = 0) or (AFileTime = $7FFFFFFFFFFFFFFF) then
  begin
    Result := 0;
    Exit;
  end;
  Result := (AFileTime - EPOCH_DAYS * TICKS_PER_DAY) / TICKS_PER_DAY;
end;

class function TLDAPSend.DateTimeToFileTime(ADateTime: TDateTime): Int64;
const
  EPOCH_DAYS    = Int64(109205);
  TICKS_PER_DAY = Int64(864000000000);
begin
  Result := Round(ADateTime * TICKS_PER_DAY) + EPOCH_DAYS * TICKS_PER_DAY;
end;
```

### GetRootDSE

```pascal
function TLDAPSend.GetRootDSE(const AAttributes: TStrings): Boolean;
begin
  // Empty base DN + lssBase scope + (objectClass=*) = RootDSE per RFC 4512
  Result := Search('', lssBase, '(objectClass=*)', AAttributes);
end;
```

### EscapeFilterValue (RFC 4515)

```pascal
class function TLDAPSend.EscapeFilterValue(const AValue: AnsiString): AnsiString;
var
  i: Integer;
  c: AnsiChar;
begin
  Result := '';
  for i := 1 to Length(AValue) do
  begin
    c := AValue[i];
    case c of
      '\': Result := Result + '\5c';
      '*': Result := Result + '\2a';
      '(': Result := Result + '\28';
      ')': Result := Result + '\29';
      #0:  Result := Result + '\00';
    else
      Result := Result + c;
    end;
  end;
end;
```

### EscapeDNComponent (RFC 4514)

```pascal
class function TLDAPSend.EscapeDNComponent(const AValue: AnsiString): AnsiString;
var
  i: Integer;
  c: AnsiChar;
begin
  Result := '';
  for i := 1 to Length(AValue) do
  begin
    c := AValue[i];
    case c of
      ',', '+', '"', '\', '<', '>', ';', '#':
        Result := Result + '\' + c;
      ' ':
        if (i = 1) or (i = Length(AValue)) then
          Result := Result + '\ '
        else
          Result := Result + c;
    else
      Result := Result + c;
    end;
  end;
end;
```

### GUIDToLDAPEscape / SIDToLDAPEscape

```pascal
class function TLDAPSend.GUIDToLDAPEscape(const AGUID: TGUID): AnsiString;
var
  i: Integer;
  b: array[0..15] of Byte;
begin
  Move(AGUID, b[0], 16);
  Result := '';
  for i := 0 to 15 do
    Result := Result + '\' + IntToHex(b[i], 2);
end;

class function TLDAPSend.SIDToLDAPEscape(const ASIDBytes: AnsiString): AnsiString;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(ASIDBytes) do
    Result := Result + '\' + IntToHex(Ord(ASIDBytes[i]), 2);
end;
```

### IsMemberOf

```pascal
function TLDAPSend.IsMemberOf(const AUserDN, AGroupDN, ABase: AnsiString): Boolean;
var
  Attrs: TStringList;
  Filter: AnsiString;
begin
  Result := False;
  Attrs := TStringList.Create;
  try
    Attrs.Add('distinguishedName');
    // LDAP_MATCHING_RULE_IN_CHAIN already supported natively by TranslateFilter
    Filter := '(&(distinguishedName=' + EscapeFilterValue(AUserDN) +
              ')(memberOf:' + LDAP_MATCHING_RULE_IN_CHAIN + ':=' +
              EscapeFilterValue(AGroupDN) + '))';
    Result := Search(ABase, lssWholeSubtree, Filter, Attrs)
              and (SearchResult.Count > 0);
  finally
    Attrs.Free;
  end;
end;
```

### SearchAllPages

```pascal
function TLDAPSend.SearchAllPages(const ABase, AFilter: AnsiString;
  AScope: TLDAPSearchScope; const AAttributes: TStrings;
  APageSize: Integer; AAccumulate: TLDAPResultList): Boolean;
begin
  // Save/set page settings
  FPageSize := APageSize;
  FPage     := True;
  FPageCookie := '';  // reset cookie for first page

  Result := True;
  repeat
    if not Search(ABase, AScope, AFilter, AAttributes) then
    begin
      Result := False;
      Break;
    end;
    // Accumulate entries from SearchResult into AAccumulate
    AAccumulate.AddStrings(SearchResult);
  until FPageCookie = '';  // empty cookie = no more pages
end;
```

> **Nota:** verificar nomes exatos de `FPageSize`, `FPage`, `FPageCookie` no código fonte de `ldapsend.pas` antes de implementar.

---

## Passo 10 — Atualizar caminhos de build

### dcc32.cfg / dcc64.cfg

```
ANTES:  ...third_party\synapse...
DEPOIS: ...E:\GestorERP\app\package\synapse...
```

### GestorERP.Backend.dproj (linhas 91-92)

```xml
<!-- ANTES: -->
<DCC_IncludeSearchPath>...;third_party\synapse;...</DCC_IncludeSearchPath>
<DCC_UnitSearchPath>...;third_party\synapse;...</DCC_UnitSearchPath>

<!-- DEPOIS: -->
<DCC_IncludeSearchPath>...;..\..\package\synapse;...</DCC_IncludeSearchPath>
<DCC_UnitSearchPath>...;..\..\package\synapse;...</DCC_UnitSearchPath>
```

---

## Passo 11 — Compilar e verificar

```powershell
dcc32 E:\GestorERP\app\backend-delphi\GestorERP.Backend.dpr
dcc64 E:\GestorERP\app\backend-delphi\GestorERP.Backend.dpr
```

Critérios:
- Zero erros em 32-bit e 64-bit
- `ldapsend` 001.007.002 resolvido de `app/package/synapse/`
- `blcksock` 009.011.000 idem
- `ServiceLDAP.pas` compila sem alteração

---

## Passo 12 — Remover third_party/synapse/

Após build verde confirmado:

```
E:\GestorERP\app\backend-delphi\third_party\synapse\  ← eliminar pasta completa
```

Se `third_party/` ficar vazia, eliminar também.

---

## Arquivos impactados

| Arquivo | Ação |
|---|---|
| `app/package/synapse/blcksock.pas` | Substituir por 009.011.000 |
| `app/package/synapse/ssl_openssl.pas` | Adicionar `GetPeerCertDER` + `GetPeerCertSHA256Hash` |
| `app/package/synapse/ssl_openssl_lib.pas` | Adicionar `i2d_X509`, `EVP_Digest`, `EVP_sha256` (se ausentes) |
| `app/package/synapse/ldapsend.pas` | Bump 001.007.002 + todas as adições |
| `app/package/synapse/*.pas` restantes | Verificar e copiar se third_party mais novo |
| `app/backend-delphi/dcc32.cfg` | Substituir path third_party |
| `app/backend-delphi/dcc64.cfg` | Idem |
| `app/backend-delphi/GestorERP.Backend.dproj` | Linhas 91-92 |
| `app/backend-delphi/third_party/synapse/` | **Remover** após build verde |

---

## Matriz de compatibilidade AD — resultado final

| Funcionalidade | Status |
|---|---|
| Paginação RFC 2696 | Nativo (existente) |
| LDAPS porta 636 + StartTLS | Nativo (existente) |
| SNI / CertCAFile / VerifyCert | Nativo (009.010.002, existente) |
| LDAP_MATCHING_RULE_IN_CHAIN | Nativo via filter (existente) |
| DirSync incremental | 001.007.002 |
| SD Flags (nTSecurityDescriptor) | 001.007.002 |
| Extended DN (GUID+SID no DN) | 001.007.002 |
| Show Deleted / Show Recycled | 001.007.002 |
| Permissive Modify | 001.007.002 |
| Tree Delete | 001.007.002 |
| Server Sort | 001.007.002 |
| SASL GSSAPI/Kerberos | 001.007.002 (`BindGSSAPI`) |
| Channel Binding Token (CBT) | 001.007.002 (`BindGSSAPIWithCBT`) |
| LDAP Signing | 001.007.002 (quando servidor negocia) |
| ChangePassword / SetPassword | 001.007.002 |
| ForcePasswordChange | 001.007.002 |
| IsAccountLocked/Disabled/Expired | 001.007.002 (class functions) |
| FileTime ↔ TDateTime | 001.007.002 (class functions) |
| GetRootDSE | 001.007.002 |
| EscapeFilterValue / EscapeDNComponent | 001.007.002 (class functions) |
| GUIDToLDAPEscape / SIDToLDAPEscape | 001.007.002 (class functions) |
| IsMemberOf (nested via CHAIN) | 001.007.002 |
| SearchAllPages | 001.007.002 |

---

## Passo 13 — Gerar documentação do pacote synapse

Após build verde + cleanup do `third_party/`, gerar documentação estruturada em:

```
app/package/synapse/Documentation/
  README.md          ← índice geral com tabelas por classe
  FLOWCHART.md       ← diagrama Mermaid da arquitetura
  TLDAPSend.md       ← documentação completa da classe principal
  TSSLOpenSSL.md     ← ssl_openssl.pas — adições GetPeerCertDER/SHA256Hash
  TBlockSocket.md    ← blcksock.pas — referência de uso (SNIHost, CertCAFile, VerifyCert)
```

### Escopo do scanner

Varrer `app/package/synapse/` para as classes:

| Classe | Arquivo |
|---|---|
| `TLDAPSend` | `ldapsend.pas` |
| `TLDAPAttribute`, `TLDAPAttributeList`, `TLDAPResult`, `TLDAPResultList` | `ldapsend.pas` |
| `TSSLOpenSSL` | `ssl_openssl.pas` |
| `TBlockSocket` | `blcksock.pas` |

### Conteúdo mínimo obrigatório de TLDAPSend.md

Seguir template 7 seções (documentation-agent-class-writer):

1. **O que é** — biblioteca LDAP Synapse Ararat v001.007.002, fork GestorERP, compatibilidade AD 100%
2. **Características** — backward compatible, sem dependências externas, SSPI inline
3. **Engine** — Delphi/FPC, secur32.dll (runtime), libssl (TLS)
4. **Funcionalidades** — tabela completa de todos os métodos públicos/class novos
5. **Aplicabilidades** — M01LdapAuthenticator, ActiveDirectoryORM, OBAC, sincronização AD
6. **Exemplos de Uso** — BindGSSAPI, SearchDirSync, IsMemberOf, FileTimeToDateTime, ChangePassword
7. **Relacionamentos** — TSSLOpenSSL (ssl_openssl.pas), M01LdapAuthenticator, ActiveDirectoryORM

### Agentes a invocar (após build verde)

```
documentation-agent-class-scanner  — varre ldapsend.pas, ssl_openssl.pas, blcksock.pas
documentation-agent-class-writer   — gera .md por classe
documentation-agent-class-indexer  — gera README.md + FLOWCHART.md
```

---

## Nota sobre ActiveDirectoryORM

`ActiveDirectoryORM` (`M01LdapAuthenticator`) usa diretamente `TLDAPSend` 001.007.002.
Não precisa criar `ActiveDirectory.LDAPControls.pas` separado.

Exemplos de uso direto:

```pascal
// Kerberos
FLDAPSend.BindGSSAPI('ldap/' + FConfig.Host);

// CBT (após LDAPS handshake)
FLDAPSend.BindGSSAPIWithCBT('ldap/' + FConfig.Host,
  FLDAPSend.Sock.SSL.GetPeerCertSHA256Hash);

// Verificar conta
Uac := StrToIntDef(GetAttr(Entry, 'userAccountControl'), 0);
if TLDAPSend.IsAccountLocked(Uac) then ...

// Timestamp
PwdLastSet := TLDAPSend.FileTimeToDateTime(
  StrToInt64Def(GetAttr(Entry, 'pwdLastSet'), 0));

// Membership aninhado para OBAC
if FLDAPSend.IsMemberOf(UserDN, AdminGroupDN, BaseDN) then ...

// Busca por objectGUID
Filter := '(objectGUID=' + TLDAPSend.GUIDToLDAPEscape(SomeGUID) + ')';
```

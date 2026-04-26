---
description: "Referência rápida — ActiveDirectoryORM: interfaces, exceções, constantes"
alwaysApply: false
---

# Quick Reference — developer-delphi-active-directory-expert

## Exceções EAD* — códigos de erro

| Classe | Código | Situação |
| --- | --- | --- |
| `EADConnectionException` | 40001 | Falha de conexão LDAP |
| `EADAuthenticationException` | 40002 | Credenciais inválidas / Bind falhou |
| `EADValidationException` | 40003 | Porta/timeout/versão inválidos; DN inválido; parâmetro nil |
| `EADNotFoundException` | 40004 | Objeto não encontrado no AD |
| `EADConfigurationException` | 40005 | Host vazio; configuração inválida |
| `EADWriteException` | 40006 | Falha de escrita; ChangePassword sem UseSSL |

## Constantes de porta

| Constante | Valor | Quando usar |
| --- | --- | --- |
| `LDAP_PORT_DEFAULT` | 389 | Conexão padrão |
| `LDAPS_PORT_DEFAULT` | 636 | LDAPS (UseSSL=True) |

## Interfaces principais

| Interface / Classe | Camada | Arquivo |
| --- | --- | --- |
| `IActiveDirectoryConnection` | Core | `src/Main/ActiveDirectory.Main.Interfaces.pas` |
| `TActiveDirectory` (factory) | Core | `src/Main/ActiveDirectory.Main.pas` |
| `IActiveDirectoryService` | Service | `src/ActiveDirectory.Service.pas` (USE_LDAP) |
| `TLDAPConfig` (record) | Commons | `src/Commons/ActiveDirectory.Types.pas` |
| `TActiveDirectoryHelper` | Commons | `src/Commons/ActiveDirectory.Helpers.pas` |

## Fluent Builder — estrutura mínima

```pascal
var
  LCfg: TLDAPConfig;
begin
  LCfg := TActiveDirectory.New
    .Host('ldap.empresa.com')
    .Port(LDAP_PORT_DEFAULT)
    .BaseDN('DC=empresa,DC=com')
    .BaseAuth('CN=svc,OU=Servicos,DC=empresa,DC=com')
    .Username('admin')
    .Password('senha')
    .GetConfig;
end;
```

## Diretiva USE_LDAP

- Ativa: `TActiveDirectoryService`, `ufrmLDAP_Teste`
- Sempre disponível: Core + Commons (sem diretiva)

→ Exemplos completos: [../exemplos/roteiro_config.md](../../developer-delphi-active-directory-roteiro_V1.0.0/exemplos/roteiro_config.md)

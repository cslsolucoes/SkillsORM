# Contas de Serviço Windows — Referência Completa

## Tabela de Decisão Rápida

| Conta | SID | Acesso à Rede | Acesso ao Sistema | Quando usar |
|-------|-----|--------------|------------------| ------------|
| `LocalSystem` | `S-1-5-18` | Sim (como computador) | Máximo (admin total) | EVITAR — apenas drivers, hardware, serviços de sistema críticos |
| `LocalService` | `S-1-5-19` | Não (anónimo) | Mínimo | Serviços sem necessidade de rede ou recursos privilegiados |
| `NetworkService` | `S-1-5-20` | Sim (como computador) | Reduzido | Serviços que acedem recursos de rede com identidade do computador |
| Conta personalizada | Configurável | Conforme permissões | Conforme permissões | Ambientes corporativos — princípio do mínimo privilégio |

---

## LocalSystem (`NT AUTHORITY\SYSTEM`)

**SID:** `S-1-5-18`

**Privilégios concedidos por padrão:**
- `SeAssignPrimaryTokenPrivilege`
- `SeAuditPrivilege`
- `SeBackupPrivilege`
- `SeChangeNotifyPrivilege`
- `SeCreateGlobalPrivilege`
- `SeCreatePagefilePrivilege`
- `SeCreatePermanentPrivilege`
- `SeCreateTokenPrivilege`
- `SeDebugPrivilege`
- `SeImpersonatePrivilege`
- `SeIncreaseBasePriorityPrivilege`
- `SeLoadDriverPrivilege`
- `SeRestorePrivilege`
- `SeSecurityPrivilege`
- `SeTakeOwnershipPrivilege`
- `SeTcbPrivilege`

**Acesso a recursos:**
- Rede: Acessa como `COMPUTADOR$` (identidade de máquina Kerberos)
- Registry: Acesso total a `HKLM`
- Sistema de ficheiros: Acesso total
- Chaves de criptografia de máquina: Sim

**Quando é obrigatório:**
- Instalação de drivers kernel
- Serviços de baixo nível do OS (SCM, LSASS, etc.)
- Alguns serviços de hardware

**Riscos:**
- Um bug ou vulnerabilidade tem acesso completo ao sistema
- Código malicioso injectado tem privilégios máximos
- Não recomendado pela Microsoft para serviços de aplicação

**Configurar:**
```batch
sc config "NomeServico" obj= LocalSystem
```

---

## LocalService (`NT AUTHORITY\LOCAL SERVICE`)

**SID:** `S-1-5-19`

**Privilégios concedidos por padrão:**
- `SeAssignPrimaryTokenPrivilege`
- `SeAuditPrivilege`
- `SeChangeNotifyPrivilege`
- `SeCreateGlobalPrivilege`
- `SeImpersonatePrivilege`
- `SeIncreaseQuotaPrivilege`
- `SeShutdownPrivilege`
- `SeUndockPrivilege`

**Acesso a recursos:**
- Rede: Acessa como **anónimo** (sem credenciais)
- Registry: Acesso a `HKLM\System\CurrentControlSet\Services\NomeServico`
- Sistema de ficheiros: Acesso limitado a pastas do sistema

**Quando usar:**
- Serviços que só acedem recursos locais
- Serviços de sincronização local
- Serviços de monitorização local
- Preferir sobre LocalSystem sempre que possível

**Limitações:**
- Sem acesso a shares de rede autenticados
- Sem acesso a Active Directory
- Sem acesso a recursos Kerberos

**Configurar:**
```batch
sc config "NomeServico" obj= "NT AUTHORITY\LocalService"
```

---

## NetworkService (`NT AUTHORITY\NETWORK SERVICE`)

**SID:** `S-1-5-20`

**Privilégios concedidos por padrão:**
- Subconjunto do LocalService
- `SeAssignPrimaryTokenPrivilege`
- `SeAuditPrivilege`
- `SeChangeNotifyPrivilege`
- `SeImpersonatePrivilege`
- `SeIncreaseQuotaPrivilege`

**Acesso a recursos:**
- Rede: Acessa como `COMPUTADOR$` (identidade Kerberos da máquina)
- Registry: Similar ao LocalService
- Sistema de ficheiros: Similar ao LocalService

**Quando usar:**
- IIS Worker Process (modo padrão)
- Serviços que precisam de acesso a recursos de rede
- Serviços que accedem SQL Server via Windows Auth na mesma máquina ou domínio
- SQL Server Agent, MSDTC

**Comparação com LocalSystem:**
- NetworkService tem acesso à rede como a máquina
- NetworkService NÃO tem privilégios administrativos locais
- NetworkService é substancialmente mais seguro que LocalSystem

**Configurar:**
```batch
sc config "NomeServico" obj= "NT AUTHORITY\NetworkService"
```

---

## Conta Personalizada (Domain ou Local User)

**Quando usar:**
- Ambientes corporativos com Active Directory
- Serviços que precisam de permissões específicas e auditáveis
- Conformidade com políticas de segurança (ISO 27001, etc.)
- Acesso a recursos de rede com controlo granular

**Criação de conta dedicada (PowerShell — AD):**
```powershell
# Criar conta de serviço no Active Directory
New-ADUser `
  -Name "svc-GestorERP" `
  -SamAccountName "svc-GestorERP" `
  -UserPrincipalName "svc-GestorERP@empresa.local" `
  -AccountPassword (ConvertTo-SecureString "SenhaComplexaAqui!" -AsPlainText -Force) `
  -PasswordNeverExpires $true `
  -CannotChangePassword $true `
  -Enabled $true `
  -Description "Conta de serviço para GestorERP Service"

# Atribuir apenas os privilégios necessários
# Grant "Log on as a service" via Group Policy ou secpol.msc:
# Local Security Policy > User Rights Assignment > Log on as a service
```

**Configurar no sc:**
```batch
sc config "GestorERPService" ^
  obj= "EMPRESA\svc-GestorERP" ^
  password= "SenhaComplexaAqui!"
```

**Permissão obrigatória — "Log on as a service":**
```batch
:: Via ntrights (Resource Kit) ou secedit
:: Ou via secpol.msc:
:: Security Settings > Local Policies > User Rights Assignment
:: > Log on as a service > Add > EMPRESA\svc-GestorERP
```

**Vantagens:**
- Permissões auditáveis e documentadas
- Possibilidade de revogar acesso sem impacto em outros serviços
- Senha pode ser gerida via LAPS (Local Admin Password Solution)
- Compatível com Managed Service Accounts (gMSA) no AD

---

## Managed Service Accounts (gMSA) — Opção avançada

Para ambientes com Active Directory, `gMSA` elimina a necessidade de gerir senhas manualmente:

```powershell
# Criar gMSA (requer AD com functional level 2012+)
New-ADServiceAccount `
  -Name "gMSA-GestorERP" `
  -DNSHostName "gestorerp.empresa.local" `
  -PrincipalsAllowedToRetrieveManagedPassword "Domain Computers"

# Instalar na máquina de serviço
Install-ADServiceAccount -Identity "gMSA-GestorERP"
Test-ADServiceAccount -Identity "gMSA-GestorERP"

# Configurar no sc (sem password — AD gere automaticamente)
sc config "GestorERPService" obj= "EMPRESA\gMSA-GestorERP$"
```

---

## Matriz de escolha por cenário

| Cenário | Conta recomendada |
|---------|------------------|
| Serviço de monitorização local | `LocalService` |
| Serviço de processamento de ficheiros locais | `LocalService` |
| Serviço que acede SQL Server na mesma máquina | `NetworkService` ou conta personalizada |
| Serviço que acede recursos de rede | `NetworkService` ou conta personalizada |
| Serviço em ambiente corporativo com AD | Conta personalizada ou gMSA |
| Driver ou serviço de sistema de baixo nível | `LocalSystem` (inevitável) |
| API/REST service (IIS) | `NetworkService` (padrão IIS) |
| Serviço com acesso a hardware específico | `LocalSystem` ou conta com privilégio específico |

---
skill: developer-delphi-windows-codesigning_V1.0.0
name: developer-delphi-windows-codesigning
description: Code Signing para aplicativos Windows com Delphi/FPC — certificados auto-assinados, OV/EV e distribuição.
version: 1.0.0
created: 2026-04-11
family: L (Windows Store / Desktop)
depends_on: []
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-windows-codesigning_V1.0.0

Skill completa de Code Signing para aplicativos Windows desenvolvidos com Delphi ou FPC/Lazarus.
Cobre certificados auto-assinados para testes, certificados OV/EV para distribuicao, assinatura
com signtool.exe e pipelines CI/CD sem hardcode de credenciais.

**PRE-REQUISITO DE:** `developer-delphi-windows-msix_V1.0.0`

---

## 1. Tipos de Certificado por Cenario

| Cenario | Tipo de Certificado | Custo | Ferramenta |
|---------|---------------------|-------|------------|
| Testes locais e desenvolvimento | Auto-assinado (`New-SelfSignedCertificate`) | Gratis | PowerShell 5.1+ |
| Distribuicao interna / sideload corporativo | OV Code Signing (DigiCert, Sectigo, GlobalSign) | USD 200-350/ano | signtool.exe |
| Distribuicao publica de alta confianca | EV Code Signing (token fisico obrigatorio) | USD 400-500/ano | signtool.exe + HSM |
| Microsoft Store | Nenhum - Microsoft assina apos certificacao | Incluso na conta | Partner Center |

> **OV vs EV:** Certificados EV eliminam o aviso SmartScreen imediatamente apos emissao.
> Certificados OV precisam construir reputacao ao longo do tempo para suprimir o aviso.
> Para a Store, nao assinar - o Partner Center assina automaticamente apos aprovacao.

---

## 2. Criar Certificado Auto-Assinado (Testes)

### 2.1 Criar, exportar e instalar com PowerShell

```powershell
# Criar certificado auto-assinado no store do usuario atual
$cert = New-SelfSignedCertificate `
  -Type Custom `
  -Subject "CN=Empresa LTDA, O=Empresa LTDA, C=BR" `
  -KeyUsage DigitalSignature `
  -FriendlyName "MeuApp Test Signing" `
  -CertStoreLocation "Cert:\CurrentUser\My" `
  -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3","2.5.29.19={text}")

# Verificar que o certificado foi criado
Write-Host "Thumbprint: $($cert.Thumbprint)"
Write-Host "Subject: $($cert.Subject)"
Write-Host "Expira em: $($cert.NotAfter)"

# Exportar certificado publico (.cer) - para instalar nas maquinas de teste
Export-Certificate -Cert $cert -FilePath "MeuApp_test.cer"
Write-Host "Exportado: MeuApp_test.cer"

# Exportar chave privada (.pfx) - para uso no signtool
$pwd = ConvertTo-SecureString -String "SenhaForte123!" -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath "MeuApp_test.pfx" -Password $pwd
Write-Host "Exportado: MeuApp_test.pfx"

# Instalar .cer no Trusted Root (requer Admin) - necessario nas maquinas de teste
# sem isso, a assinatura nao sera reconhecida como valida
Import-Certificate -FilePath "MeuApp_test.cer" `
  -CertStoreLocation "Cert:\LocalMachine\Root"
Write-Host "Certificado instalado no Trusted Root"
```

### 2.2 Verificar certificado instalado

```powershell
# Listar certificados de Code Signing no store pessoal
Get-ChildItem "Cert:\CurrentUser\My" | Where-Object {
  $_.EnhancedKeyUsageList.ObjectId -contains "1.3.6.1.5.5.7.3.3"
} | Select-Object Subject, Thumbprint, NotAfter

# Listar no Trusted Root
Get-ChildItem "Cert:\LocalMachine\Root" | Where-Object { $_.Subject -like "*Empresa LTDA*" }
```

---

## 3. Assinar com signtool.exe

### 3.1 Localizacao do signtool

```
C:\Program Files (x86)\Windows Kits\10\bin\10.0.{build}.0\x64\signtool.exe
```

Exemplo com build 26100 (Windows 11 SDK):
```
C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\signtool.exe
```

Adicionar ao PATH ou usar caminho completo nos scripts.

### 3.2 Assinar com arquivo PFX

```batch
REM Assinar MSIX com PFX (mais comum em CI/CD)
signtool sign ^
  /fd SHA256 ^
  /f "MeuApp_test.pfx" ^
  /p "SenhaForte123!" ^
  /tr http://timestamp.digicert.com ^
  /td SHA256 ^
  "GestorERP_1.0.0.0_x64.msix"
```

### 3.3 Assinar com certificado no store (sem PFX)

```batch
REM Assinar usando certificado instalado no store pelo subject
signtool sign ^
  /fd SHA256 ^
  /n "Empresa LTDA" ^
  /tr http://timestamp.digicert.com ^
  /td SHA256 ^
  "GestorERP_1.0.0.0_x64.msix"

REM Assinar usando thumbprint especifico
signtool sign ^
  /fd SHA256 ^
  /sha1 "THUMBPRINT_DO_CERTIFICADO" ^
  /tr http://timestamp.digicert.com ^
  /td SHA256 ^
  "GestorERP_1.0.0.0_x64.msix"
```

### 3.4 Verificar assinatura

```batch
REM Verificar assinatura (modo basico)
signtool verify /pa "GestorERP_1.0.0.0_x64.msix"

REM Verificar com verbose (mostra detalhes do certificado e timestamp)
signtool verify /pa /v "GestorERP_1.0.0.0_x64.msix"

REM Verificar todos os arquivos em um diretorio
signtool verify /pa /v ".\dist\*.msix"
```

---

## 4. Servidores de Timestamp Gratuitos

Sempre usar timestamp — sem ele, o MSIX expira quando o certificado expirar.
O timestamp prova que o arquivo foi assinado enquanto o certificado era valido.

| Provedor | URL RFC 3161 | URL Authenticode |
|---------|--------------|------------------|
| DigiCert | `http://timestamp.digicert.com` | `http://timestamp.digicert.com` |
| Comodo / Sectigo | `http://timestamp.sectigo.com` | `http://timestamp.comodoca.com` |
| GlobalSign | `http://timestamp.globalsign.com/scripts/timstamp.dll` | - |
| Entrust | `http://timestamp.entrust.net/TSS/RFC3161sha2TS` | - |

**Flag correto por tipo:**
- `/tr <url> /td SHA256` — timestamp RFC 3161 (recomendado, compativel com SHA-256)
- `/t <url>` — timestamp Authenticode legado (nao recomendado para novos projetos)

---

## 5. Pipeline CI/CD — PFX em Base64 sem Hardcode de Senha

### 5.1 Preparar o PFX para o pipeline (uma vez, localmente)

```powershell
# Converter PFX para Base64 e copiar para clipboard
$pfxBytes = [IO.File]::ReadAllBytes("MeuApp_signing.pfx")
$base64 = [Convert]::ToBase64String($pfxBytes)
$base64 | Set-Clipboard
Write-Host "Base64 copiado para clipboard. Cole em PFX_BASE64 no secret vault."
```

### 5.2 GitHub Actions — usando secrets

```yaml
# .github/workflows/build-and-sign.yml
- name: Sign MSIX
  env:
    PFX_BASE64: ${{ secrets.PFX_BASE64 }}
    PFX_PASSWORD: ${{ secrets.PFX_PASSWORD }}
  run: |
    # Reconstituir o PFX no runner
    $pfxBytes = [Convert]::FromBase64String($env:PFX_BASE64)
    [IO.File]::WriteAllBytes("signing.pfx", $pfxBytes)

    # Assinar
    signtool sign /fd SHA256 /f "signing.pfx" /p $env:PFX_PASSWORD `
      /tr http://timestamp.digicert.com /td SHA256 `
      ".\dist\GestorERP_${{ github.ref_name }}_x64.msix"

    # Limpar imediatamente apos uso
    Remove-Item "signing.pfx" -Force
    Write-Host "Assinatura concluida e PFX removido"
  shell: pwsh
```

### 5.3 Azure DevOps — usando Library Variables

```yaml
# azure-pipelines.yml
- task: PowerShell@2
  displayName: 'Sign MSIX'
  env:
    PFX_BASE64: $(PFX_BASE64)
    PFX_PASSWORD: $(PFX_PASSWORD)
  inputs:
    targetType: 'inline'
    script: |
      $pfxBytes = [Convert]::FromBase64String($env:PFX_BASE64)
      [IO.File]::WriteAllBytes("$(Agent.TempDirectory)\signing.pfx", $pfxBytes)

      signtool sign /fd SHA256 `
        /f "$(Agent.TempDirectory)\signing.pfx" `
        /p $env:PFX_PASSWORD `
        /tr http://timestamp.digicert.com /td SHA256 `
        "$(Build.ArtifactStagingDirectory)\GestorERP_$(Build.BuildNumber)_x64.msix"

      Remove-Item "$(Agent.TempDirectory)\signing.pfx" -Force
```

---

## 6. Regras de Seguranca

| Regra | Detalhes |
|-------|---------|
| NUNCA versionar .pfx | Adicionar `*.pfx` ao `.gitignore`. Sem excecoes. |
| Usar secret vault | GitHub Secrets, Azure Key Vault, HashiCorp Vault — nunca variavel de ambiente nao protegida |
| Certificado auto-assinado: escopo limitado | Valido APENAS em maquinas onde o `.cer` foi instalado manualmente no Trusted Root |
| PFX: tempo de vida no disco | Escrever, usar, apagar imediatamente. Nunca deixar no runner/agente |
| Para Store: nao assinar | O Partner Center assina apos aprovacao. Assinar antes pode causar conflito |
| Senha do PFX: rotacionar | A cada 12 meses ou ao desligar colaboradores com acesso |
| EV Certificate: HSM obrigatorio | O token fisico nao pode ser copiado. Nunca extrair a chave privada |

---

## Referencias

- `exemplos/codesigning_test.ps1` — script completo: criar + exportar + instalar + assinar
- `exemplos/signtool_usage.md` — referencia de flags do signtool
- `exemplos/ci_signing_pipeline.md` — pipelines GitHub Actions e Azure DevOps completos
- `consultas_rapidas/cert_tipos.md` — tabela detalhada de tipos de certificado
- `consultas_rapidas/signtool_referencia.md` — todos os flags do signtool
- `consultas_rapidas/timestamp_servers.md` — URLs de servidores gratuitos
- `templates/TEMPLATE_signing_script.ps1` — script parametrizado pronto para uso

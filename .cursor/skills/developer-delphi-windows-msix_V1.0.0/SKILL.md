---
name: developer-delphi-windows-msix
description: Empacotamento MSIX para aplicativos Delphi/FPC — .dproj, AppxManifest.xml, Deployment Manager, sideloading, WACK, Sparse Package.
model: sonnet
version: 1.0.0
created: 2026-04-11
family: L (Windows Store / Desktop)
depends_on: [developer-delphi-windows-codesigning_V1.0.0]
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-windows-msix_V1.0.0

Skill completa de empacotamento MSIX para aplicativos Delphi/FPC no Windows.
Cobre configuracao do .dproj, AppxManifest.xml, Deployment Manager, sideloading,
WACK, Sparse Package e tabela de decisao MSIX vs Inno Setup vs ClickOnce.

**DEPENDENCIA:** `developer-delphi-windows-codesigning_V1.0.0` deve existir antes desta skill.

---

## 1. Ativar MSIX no RAD Studio

### Via IDE

1. Menu **Project > Options**
2. Navegar para **Packages & Install > MSIX Packaging**
3. Habilitar o checkbox **Generate MSIX Package**
4. Preencher: Package Name, Publisher, Version, Display Name
5. Clicar em **OK** — o IDE insere as propriedades no `.dproj`

### Via .dproj — propriedades essenciais

```xml
<!-- PropertyGroup base Win64 — identidade do pacote -->
<PropertyGroup Condition="'$(Platform)'=='Win64'">
  <!-- Nome do pacote: deve ser identico ao registrado no Partner Center -->
  <MSIX_PackageIdentityName>Empresa.GestorERP</MSIX_PackageIdentityName>

  <!-- Publisher: DEVE ser identico ao Subject CN do certificado de assinatura -->
  <MSIX_PackagePublisher>CN=Empresa LTDA, O=Empresa LTDA, C=BR</MSIX_PackagePublisher>

  <!--
    CRITICO — Formato de versao: Major.Minor.Build.0
    O quarto componente DEVE ser SEMPRE 0 para submissao na Microsoft Store.
    1.0.0.1 e REJEITADO pela Store.
    Para patches: usar 1.0.1.0, nao 1.0.0.1
  -->
  <MSIX_PackageVersion>1.0.0.0</MSIX_PackageVersion>

  <MSIX_PackageDisplayName>GestorERP</MSIX_PackageDisplayName>
  <MSIX_PackageDescription>Sistema de gestao empresarial</MSIX_PackageDescription>
  <MSIX_PackageArchitecture>x64</MSIX_PackageArchitecture>
  <MSIX_PackageLogo>Assets\StoreLogo.png</MSIX_PackageLogo>
</PropertyGroup>

<!-- PropertyGroup Release Win64 — ativa geracao MSIX -->
<PropertyGroup Condition="'$(Cfg_2)'!='' and '$(Platform)'=='Win64'">
  <MSIX_Packaging>true</MSIX_Packaging>
  <DCC_Optimize>true</DCC_Optimize>
  <DCC_DebugInformation>0</DCC_DebugInformation>
  <DCC_LocalSymbols>false</DCC_LocalSymbols>
</PropertyGroup>
```

> **ATENCAO — Formato de versao:** O quarto componente deve ser SEMPRE `0` para apps
> submetidos a Microsoft Store. `1.0.0.1` e rejeitado automaticamente.
> Para patches: `1.0.1.0`. Para minors: `1.1.0.0`. Para majors: `2.0.0.0`.

---

## 2. AppxManifest.xml — Estrutura Completa para Win32 (runFullTrust)

```xml
<?xml version="1.0" encoding="utf-8"?>
<Package
  xmlns="http://schemas.microsoft.com/appx/manifest/foundation/windows10"
  xmlns:uap="http://schemas.microsoft.com/appx/manifest/uap/windows10"
  xmlns:rescap="http://schemas.microsoft.com/appx/manifest/foundation/windows10/restrictedcapabilities"
  IgnorableNamespaces="uap rescap">

  <!-- Identidade do pacote — deve ser identica ao .dproj e ao Partner Center -->
  <Identity
    Name="Empresa.GestorERP"
    Publisher="CN=Empresa LTDA, O=Empresa LTDA, C=BR"
    Version="1.0.0.0"
    ProcessorArchitecture="x64"/>

  <Properties>
    <DisplayName>GestorERP</DisplayName>
    <PublisherDisplayName>Empresa LTDA</PublisherDisplayName>
    <Logo>Assets\StoreLogo.png</Logo>
  </Properties>

  <Dependencies>
    <!-- Windows 10 1809 (build 17763) minimo recomendado para MSIX pleno -->
    <TargetDeviceFamily
      Name="Windows.Desktop"
      MinVersion="10.0.17763.0"
      MaxVersionTested="10.0.26100.0"/>
  </Dependencies>

  <Resources>
    <Resource Language="pt-BR"/>
    <Resource Language="en-US"/>
  </Resources>

  <Capabilities>
    <Capability Name="internetClient"/>
    <!--
      runFullTrust: OBRIGATORIO para apps Win32 classicos (Delphi/FPC).
      Permite acesso irrestrito ao sistema de arquivos, registry, etc.
      Requer aprovacao especial na Microsoft Store para apps que nao a usam.
    -->
    <rescap:Capability Name="runFullTrust"/>
  </Capabilities>

  <Applications>
    <Application
      Id="App"
      Executable="GestorERP.exe"
      EntryPoint="Windows.FullTrustApplication">
      <uap:VisualElements
        DisplayName="GestorERP"
        Description="Sistema de gestao empresarial"
        BackgroundColor="transparent"
        Square150x150Logo="Assets\Square150x150Logo.png"
        Square44x44Logo="Assets\Square44x44Logo.png">
        <uap:DefaultTile Wide310x150Logo="Assets\Wide310x150Logo.png"/>
        <uap:SplashScreen Image="Assets\SplashScreen.png"/>
      </uap:VisualElements>
    </Application>
  </Applications>
</Package>
```

### Assets obrigatorios (PNG, fundo transparente ou branco)

| Asset | Dimensao | Arquivo |
|-------|----------|---------|
| Store Logo | 50x50 px | `Assets\StoreLogo.png` |
| App List Icon (small) | 44x44 px | `Assets\Square44x44Logo.png` |
| App List Icon (medium) | 150x150 px | `Assets\Square150x150Logo.png` |
| Wide Tile | 310x150 px | `Assets\Wide310x150Logo.png` |
| Splash Screen | 620x300 px | `Assets\SplashScreen.png` |

> Recomendado: criar versoes escaladas (100%, 125%, 150%, 200%, 400%) para diferentes DPIs.
> Sufixo de escala: `Square44x44Logo.scale-100.png`, `Square44x44Logo.scale-200.png`, etc.

---

## 3. Deployment Manager — Dependencias Runtime

**Acessar:** Menu **Project > Deployment**
(Selecionar Platform = Win64, Configuration = Release)

### DLLs a incluir no pacote MSIX

| Categoria | Arquivos | Quando incluir |
|-----------|----------|----------------|
| RTL Delphi (dynamic) | `rtl.bpl`, `borlndmm.dll` | Sempre que nao usar static linking |
| VCL | `vcl.bpl`, `vclx.bpl`, `vclactnband.bpl` | Apps VCL |
| FMX | `fmx.bpl`, `fmxobj.bpl` | Apps FMX |
| FireDAC | `FireDAC.bpl`, drivers especificos | Se usar FireDAC |
| DataSnap | `dbrtl.bpl`, `dsnap.bpl` | Se usar DataSnap |
| VC++ Runtime | `msvcrXXX.dll`, `vcruntime.dll` | Se usar DLLs C++ nativas |
| Resources | `*.ini`, `*.json`, imagens, templates | Sempre que necessario |

> Para MSIX, o pacote e **autocontido**: TODAS as dependencias devem estar dentro do MSIX.
> Nao ha instalacao de runtime separada. O Deployment Manager define o que vai no pacote.

### Configuracao no Deployment Manager

1. Verificar a lista de arquivos para Platform=Win64, Config=Release
2. Adicionar DLLs ausentes com o botao "Add Files"
3. Marcar "Include in MSIX" para cada arquivo
4. Definir o Remote Path (subpasta dentro do MSIX)
5. Compilar com **Build > Build {Config} MSIX**

---

## 4. Sideloading para Testes

```powershell
# PASSO 1: Instalar certificado de teste (uma vez por maquina - requer Admin)
Import-Certificate -FilePath "MeuApp_test.cer" `
  -CertStoreLocation "Cert:\LocalMachine\Root"

# PASSO 2: Assinar o MSIX com certificado de teste
signtool sign /fd SHA256 /f "MeuApp_test.pfx" /p "senha" `
  /tr http://timestamp.digicert.com /td SHA256 `
  "GestorERP_1.0.0.0_x64.msix"

# PASSO 3: Instalar MSIX (sideload)
Add-AppxPackage -Path "GestorERP_1.0.0.0_x64.msix"

# PASSO 4: Verificar instalacao
Get-AppxPackage -Name "Empresa.GestorERP"

# PASSO 5: Atualizar (nova versao - versao DEVE ser maior que a instalada)
Add-AppxPackage -Path "GestorERP_1.0.1.0_x64.msix" -ForceUpdateFromAnyVersion

# PASSO 6: Desinstalar
Remove-AppxPackage (Get-AppxPackage -Name "Empresa.GestorERP").PackageFullName
```

---

## 5. WACK — Windows App Certification Kit

Executar ANTES de cada submissao a Microsoft Store.

### Localizacao

```
C:\Program Files (x86)\Windows Kits\10\App Certification Kit\appcert.exe
```

### Comando CLI

```batch
appcert.exe test ^
  -apptype DesktopApp ^
  -setuppath "GestorERP_1.0.0.0_x64.msix" ^
  -setuptype store ^
  -reportoutputpath ".\wack_report.xml"
```

### Erros mais frequentes

| Erro | Causa | Solucao |
|------|-------|---------|
| APIs proibidas: `RegOpenKey` | API deprecated; usar versao Ex | Substituir por `RegOpenKeyEx` |
| `CreateFile` com path hardcoded | Acesso a path absoluto nao permitido | Usar APIs de path relativo ao pacote |
| Capabilities nao declaradas | Capability usada mas nao no manifest | Adicionar ao AppxManifest.xml |
| Icone com fundo nao transparente | PNG com background solido | Recriar com fundo transparente |
| DLL ausente no pacote | Dependencia nao adicionada ao Deployment Manager | Incluir DLL no Deployment Manager |
| Versao com quarto componente != 0 | Ex.: `1.0.0.1` | Corrigir para `1.0.1.0` |

---

## 6. Sparse Package — Quando Usar

Para apps Win32 que precisam de identidade da Store mas nao podem ser totalmente containerizados
(ex.: escrita irrestrita em `C:\ProgramData`, acesso total ao registry):

- **Quando usar:** app legado com dependencias incompativeis com MSIX completo
- **Beneficios:** notificacoes Windows, atualizacoes silenciosas, presenca na Store
- **Limitacoes:** nao remove o aviso SmartScreen; instalacao mais complexa
- **Documentacao:** `https://docs.microsoft.com/windows/apps/desktop/modernize/grant-identity-to-nonpackaged-apps`

Registrar identidade sparse via PowerShell:
```powershell
# Necessario Windows 10 1809+
Add-AppxPackage -Path ".\SparsePackage.msix" -ExternalLocation "C:\Program Files\GestorERP"
```

---

## 7. Tabela de Decisao: MSIX vs Inno Setup vs ClickOnce

| Criterio | MSIX | Inno Setup | ClickOnce |
|----------|------|------------|-----------|
| Microsoft Store | Sim | Nao | Nao |
| Update automatico silencioso | Sim | Manual (download novo installer) | Sim |
| Sandbox/containerizacao | Sim | Nao | Parcial |
| Acesso irrestrito ao sistema | Nao (sem Sparse) | Sim | Nao |
| Rollback automatico | Sim | Nao | Sim |
| Instalacao sem admin | Sim (user scope) | Nao (tipicamente) | Sim |
| Tamanho do pacote | Maior (autocontido) | Menor | Medio |
| Complexidade de configuracao | Alta | Baixa | Media |
| Suporte a Delphi out-of-the-box | Sim (RAD Studio 11+) | Sim (script manual) | Sim (via IDE) |
| Custo de cert para distribuicao | OV/EV ($200-500/ano) | OV/EV ou auto-assinado | OV/EV ou auto-assinado |

---

## Referencias

- `exemplos/msix_dproj_config.md` — PropertyGroups .dproj completos e anotados
- `exemplos/appxmanifest_walkthrough.md` — AppxManifest.xml elemento por elemento
- `exemplos/sideload_testing.ps1` — script completo de install/update/remove
- `exemplos/wack_pre_submission.md` — passo-a-passo WACK com interpretacao do relatorio XML
- `exemplos/deployment_manager_guide.md` — guia do Deployment Manager
- `consultas_rapidas/msix_dproj_snippets.md` — tabela de todas as propriedades MSBuild MSIX
- `consultas_rapidas/msix_vs_inno_quando_usar.md` — tabela comparativa expandida
- `consultas_rapidas/appxmanifest_capabilities.md` — lista de capabilities comuns
- `consultas_rapidas/msix_erros_comuns.md` — erros, causas e solucoes
- `templates/TEMPLATE_appxmanifest.xml` — AppxManifest.xml base pronto para usar
- `templates/TEMPLATE_msix_release.dproj` — PropertyGroup Release Win64 MSIX
- `templates/TEMPLATE_deploy_msix.ps1` — pipeline completo build + sign + sideload

# Referência Rápida: .dproj Multi-Plataforma Completo

## PropertyGroups iOS + Android — Referência Completa

```xml
<!--
  .dproj multi-plataforma completo: iOS Device 64-bit + Android 64-bit
  Inserir dentro de <Project> no arquivo .dproj

  SUBSTITUICOES NECESSARIAS:
    com.empresa.meuapp  → Bundle ID / Package Name real
    Nome (ID)           → Nome e ID do certificado Apple Development
    Empresa (TEAMID)    → Nome e Team ID do certificado Apple Distribution
    App_*.mobileprovision → Nomes dos provisioning profiles importados
    .\certificates\meuapp.keystore → Caminho da keystore Android
    meuapp              → Alias definido no keytool
-->

<!-- ========================================================== -->
<!-- iOS Device 64-bit — BASE                                  -->
<!-- ========================================================== -->
<PropertyGroup Condition="'$(Platform)'=='iOSDevice64'">
  <DCC_Namespace>Macapi;iOSapi;FMX;System;Xml;Data;Datasnap;Web;Soap;$(DCC_Namespace)</DCC_Namespace>
  <VerInfo_CFBundleIdentifier>com.empresa.meuapp</VerInfo_CFBundleIdentifier>
  <VerInfo_CFBundleVersion>1.0.0</VerInfo_CFBundleVersion>
  <VerInfo_CFBundleShortVersionString>1.0</VerInfo_CFBundleShortVersionString>
  <VerInfo_MinimumOSVersion>16.0</VerInfo_MinimumOSVersion>
  <VerInfo_UIDeviceFamily>1,2</VerInfo_UIDeviceFamily>
  <VerInfo_CFBundleDisplayName>Meu App</VerInfo_CFBundleDisplayName>
</PropertyGroup>

<!-- iOS Device 64-bit — DEBUG                                  -->
<PropertyGroup Condition="'$(Cfg_1)'!='' and '$(Platform)'=='iOSDevice64'">
  <CodeSigningIdentity>Apple Development: Nome (ID)</CodeSigningIdentity>
  <ProvisioningProfile>App_Development.mobileprovision</ProvisioningProfile>
  <DCC_DebugInformation>2</DCC_DebugInformation>
</PropertyGroup>

<!-- iOS Device 64-bit — RELEASE APP STORE                      -->
<PropertyGroup Condition="'$(Cfg_2)'!='' and '$(Platform)'=='iOSDevice64'">
  <CodeSigningIdentity>Apple Distribution: Empresa (TEAMID)</CodeSigningIdentity>
  <ProvisioningProfile>App_AppStore.mobileprovision</ProvisioningProfile>
  <DCC_Optimize>true</DCC_Optimize>
  <DCC_DebugInformation>0</DCC_DebugInformation>
  <DCC_LocalDebugSymbols>false</DCC_LocalDebugSymbols>
</PropertyGroup>

<!-- ========================================================== -->
<!-- Android 64-bit — BASE                                     -->
<!-- ========================================================== -->
<PropertyGroup Condition="'$(Platform)'=='Android64'">
  <DCC_Namespace>Androidapi;FMX;System;Xml;Data;$(DCC_Namespace)</DCC_Namespace>
  <Android_ApplicationId>com.empresa.meuapp</Android_ApplicationId>
  <Android_MinSdkVersion>26</Android_MinSdkVersion>
  <Android_TargetSdkVersion>34</Android_TargetSdkVersion>
</PropertyGroup>

<!-- Android 64-bit — DEBUG                                     -->
<PropertyGroup Condition="'$(Cfg_1)'!='' and '$(Platform)'=='Android64'">
  <Android_VersionCode>1</Android_VersionCode>
  <Android_VersionName>1.0.0-debug</Android_VersionName>
  <DCC_DebugInformation>2</DCC_DebugInformation>
</PropertyGroup>

<!-- Android 64-bit — RELEASE PLAY STORE                        -->
<PropertyGroup Condition="'$(Cfg_2)'!='' and '$(Platform)'=='Android64'">
  <!-- INCREMENTAR versionCode a cada upload para o Play Store -->
  <Android_VersionCode>10</Android_VersionCode>
  <Android_VersionName>1.0.0</Android_VersionName>
  <Android_KeyStore>.\certificates\meuapp.keystore</Android_KeyStore>
  <Android_KeyStoreAlias>meuapp</Android_KeyStoreAlias>
  <!-- Senhas via variavel de ambiente — NUNCA hardcodar -->
  <Android_KeyStorePass>$(KEYSTORE_PASS)</Android_KeyStorePass>
  <Android_KeyAliasPass>$(KEY_ALIAS_PASS)</Android_KeyAliasPass>
  <!-- AAB obrigatorio para Google Play -->
  <Android_GenerateBundle>true</Android_GenerateBundle>
  <DCC_Optimize>true</DCC_Optimize>
  <DCC_DebugInformation>0</DCC_DebugInformation>
  <DCC_LocalDebugSymbols>false</DCC_LocalDebugSymbols>
</PropertyGroup>
```

## Condições de Configuração — Resumo

| Condição | Plataforma | Configuração |
|----------|------------|-------------|
| `'$(Platform)'=='iOSDevice64'` | iOS Device | Qualquer |
| `'$(Cfg_1)'!='' and '$(Platform)'=='iOSDevice64'` | iOS Device | Debug |
| `'$(Cfg_2)'!='' and '$(Platform)'=='iOSDevice64'` | iOS Device | Release |
| `'$(Platform)'=='Android64'` | Android | Qualquer |
| `'$(Cfg_1)'!='' and '$(Platform)'=='Android64'` | Android | Debug |
| `'$(Cfg_2)'!='' and '$(Platform)'=='Android64'` | Android | Release |

## Propriedades por Plataforma — Tabela Rápida

### iOS

| Propriedade | Descrição |
|-------------|-----------|
| `VerInfo_CFBundleIdentifier` | Bundle ID (ex.: com.empresa.app) |
| `VerInfo_CFBundleVersion` | Build number (ex.: 1.0.0) |
| `VerInfo_CFBundleShortVersionString` | Versao usuario (ex.: 1.0) |
| `VerInfo_MinimumOSVersion` | iOS minimo (ex.: 16.0) |
| `VerInfo_UIDeviceFamily` | 1=iPhone, 2=iPad, 1,2=Universal |
| `CodeSigningIdentity` | Nome completo do certificado |
| `ProvisioningProfile` | Nome do arquivo .mobileprovision |

### Android

| Propriedade | Descrição |
|-------------|-----------|
| `Android_ApplicationId` | Package name (ex.: com.empresa.app) |
| `Android_MinSdkVersion` | API minima (ex.: 26) |
| `Android_TargetSdkVersion` | API alvo (ex.: 34) |
| `Android_VersionCode` | Build number inteiro (ex.: 10) |
| `Android_VersionName` | Versao usuario (ex.: 1.0.0) |
| `Android_KeyStore` | Caminho da keystore |
| `Android_KeyStoreAlias` | Alias da chave |
| `Android_GenerateBundle` | true = gerar AAB |

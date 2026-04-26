---
name: developer-delphi-mobile-orchestrator
version: 1.1.0
description: "Orquestrador mobile Delphi FMX: ponto de entrada único para desenvolvimento iOS e Android. Roteia para skills especializadas, provê fluxo end-to-end de projeto mobile, tabela de decisões de plataforma e .dproj multi-plataforma completo."
model: sonnet
category: developer-delphi
family: K (Mobile)
thinking: false
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-mobile-orchestrator_V1.1.0

## Responsabilidade única

Ponto de entrada único para qualquer tarefa de desenvolvimento mobile Delphi FMX. Roteia para skills especializadas conforme o contexto, provê visão completa do fluxo iOS + Android (setup → develop → test → publish), tabela de decisões de plataforma e `.dproj` multi-plataforma comentado.

## When NOT to use

Esta é a skill de entrada — sempre consultar aqui primeiro para ser redirecionado à skill correta.

## Dependências (família K)

- `developer-delphi-ios-setup_V1.0.0`
- `developer-delphi-ios-publishing_V1.0.0`
- `developer-delphi-android-setup_V1.0.0`
- `developer-delphi-android-publishing_V1.0.0`
- `developer-delphi-fmx-layout_V1.1.0`
- `developer-delphi-fmx-animations_V1.0.0`
- `developer-delphi-fmx-effects_V1.0.0`
- `developer-delphi-fmx-components_V1.0.0`

---

## Tabela de Roteamento

| Contexto | Skill invocada |
|----------|---------------|
| Configurar iOS (PAServer, certificados, provisioning, SDK) | `developer-delphi-ios-setup_V1.0.0` |
| Configurar Android (SDK/NDK, permissoes, manifest) | `developer-delphi-android-setup_V1.0.0` |
| Publicar na Apple App Store (IPA, Transporter, App Store Connect) | `developer-delphi-ios-publishing_V1.0.0` |
| Publicar no Google Play Store (Keystore, AAB, Play Console) | `developer-delphi-android-publishing_V1.0.0` |
| UI/Layout FMX multi-plataforma | `developer-delphi-fmx-layout_V1.1.0` |
| Animacoes e transicoes FMX | `developer-delphi-fmx-animations_V1.0.0` |
| Efeitos visuais FMX | `developer-delphi-fmx-effects_V1.0.0` |
| Componentes FMX | `developer-delphi-fmx-components_V1.0.0` |
| Duvidas gerais mobile Delphi | **Esta skill** (decidir e rotear) |

---

## Fluxo Completo — Novo Projeto Mobile

```
1. Criar projeto FMX Multi-Device Application
   └── File > New > Multi-Device Application

2. Configurar plataformas
   ├── iOS  → developer-delphi-ios-setup_V1.0.0
   │   ├── PAServer no Mac
   │   ├── Certificado Apple Development
   │   ├── Provisioning Profile Development
   │   └── SDK Manager iOS
   └── Android → developer-delphi-android-setup_V1.0.0
       ├── Android SDK + NDK
       ├── AndroidManifest.template.xml
       └── Permissoes (manifest + runtime)

3. Desenvolver com FMX
   ├── Layout → developer-delphi-fmx-layout_V1.1.0
   ├── Animacoes → developer-delphi-fmx-animations_V1.0.0
   └── Componentes → developer-delphi-fmx-components_V1.0.0

4. Testar em dispositivo
   ├── iOS: deploy via PAServer para iPhone/iPad fisico
   └── Android: USB Debugging + deploy direto

5. Publicar
   ├── iOS → developer-delphi-ios-publishing_V1.0.0
   │   ├── Provisioning Profile App Store
   │   ├── Gerar IPA (Release + PAServer)
   │   ├── App Store Connect → registrar app
   │   └── Transporter → upload IPA
   └── Android → developer-delphi-android-publishing_V1.0.0
       ├── Keystore de producao
       ├── Gerar AAB (Release)
       ├── Google Play Console → criar app
       └── Upload AAB → Production
```

---

## Tabela de Decisoes de Plataforma

| Questao | Decisao |
|---------|---------|
| App Store ou Ad Hoc (iOS)? | App Store para distribuicao publica; Ad Hoc para testes (ate 100 UDIDs) |
| APK ou AAB (Android)? | AAB obrigatorio para novos apps Google Play desde agosto 2021 |
| Debug keystore ou Release keystore? | **NUNCA** usar debug keystore para publicacao |
| PAServer onde? | Sempre no Mac — obrigatorio para compilacao iOS |
| Play App Signing? | Recomendado — Google gerencia chave final de distribuicao |
| Internal vs Production (Android)? | Internal testing primeiro (sem revisao) → Producao |
| TestFlight ou direto App Store (iOS)? | TestFlight primeiro para beta → App Store |
| iOS simulador ou dispositivo fisico? | Simulador para desenvolvimento rapido; dispositivo fisico OBRIGATORIO antes de publicar |
| Android emulador ou dispositivo fisico? | Dispositivo fisico recomendado; emulador aceito para desenvolvimento |

---

## .dproj Multi-Plataforma — Estrutura Completa

```xml
<!-- ============================================================ -->
<!-- iOS Device 64-bit — BASE                                   -->
<!-- ============================================================ -->
<PropertyGroup Condition="'$(Platform)'=='iOSDevice64'">
  <DCC_Namespace>Macapi;iOSapi;FMX;System;Xml;Data;$(DCC_Namespace)</DCC_Namespace>
  <VerInfo_CFBundleIdentifier>com.empresa.meuapp</VerInfo_CFBundleIdentifier>
  <VerInfo_CFBundleVersion>1.0.0</VerInfo_CFBundleVersion>
  <VerInfo_CFBundleShortVersionString>1.0</VerInfo_CFBundleShortVersionString>
  <VerInfo_MinimumOSVersion>16.0</VerInfo_MinimumOSVersion>
  <VerInfo_UIDeviceFamily>1,2</VerInfo_UIDeviceFamily>
</PropertyGroup>

<!-- iOS Device 64-bit — DEBUG -->
<PropertyGroup Condition="'$(Cfg_1)'!='' and '$(Platform)'=='iOSDevice64'">
  <CodeSigningIdentity>Apple Development: Dev Name (DEVID)</CodeSigningIdentity>
  <ProvisioningProfile>MeuApp_Development.mobileprovision</ProvisioningProfile>
  <DCC_DebugInformation>2</DCC_DebugInformation>
</PropertyGroup>

<!-- iOS Device 64-bit — RELEASE App Store -->
<PropertyGroup Condition="'$(Cfg_2)'!='' and '$(Platform)'=='iOSDevice64'">
  <CodeSigningIdentity>Apple Distribution: Empresa (TEAMID)</CodeSigningIdentity>
  <ProvisioningProfile>MeuApp_AppStore.mobileprovision</ProvisioningProfile>
  <VerInfo_CFBundleVersion>1.0.1</VerInfo_CFBundleVersion>
  <DCC_Optimize>true</DCC_Optimize>
  <DCC_DebugInformation>0</DCC_DebugInformation>
</PropertyGroup>

<!-- ============================================================ -->
<!-- Android 64-bit — BASE                                      -->
<!-- ============================================================ -->
<PropertyGroup Condition="'$(Platform)'=='Android64'">
  <DCC_Namespace>Androidapi;FMX;System;Xml;Data;$(DCC_Namespace)</DCC_Namespace>
  <Android_ApplicationId>com.empresa.meuapp</Android_ApplicationId>
  <Android_MinSdkVersion>26</Android_MinSdkVersion>
  <Android_TargetSdkVersion>34</Android_TargetSdkVersion>
</PropertyGroup>

<!-- Android 64-bit — DEBUG -->
<PropertyGroup Condition="'$(Cfg_1)'!='' and '$(Platform)'=='Android64'">
  <Android_VersionCode>1</Android_VersionCode>
  <Android_VersionName>1.0.0-debug</Android_VersionName>
  <DCC_DebugInformation>2</DCC_DebugInformation>
</PropertyGroup>

<!-- Android 64-bit — RELEASE Play Store -->
<PropertyGroup Condition="'$(Cfg_2)'!='' and '$(Platform)'=='Android64'">
  <Android_VersionCode>10</Android_VersionCode>
  <Android_VersionName>1.0.0</Android_VersionName>
  <Android_KeyStore>.\certificates\meuapp.keystore</Android_KeyStore>
  <Android_KeyStoreAlias>meuapp</Android_KeyStoreAlias>
  <Android_KeyStorePass>$(KEYSTORE_PASS)</Android_KeyStorePass>
  <Android_KeyAliasPass>$(KEY_ALIAS_PASS)</Android_KeyAliasPass>
  <Android_GenerateBundle>true</Android_GenerateBundle>
  <DCC_Optimize>true</DCC_Optimize>
  <DCC_DebugInformation>0</DCC_DebugInformation>
</PropertyGroup>
```

---

## Referências Cruzadas — Família K Completa

| Skill | Responsabilidade |
|-------|-----------------|
| `developer-delphi-ios-setup_V1.0.0` | PAServer, certificados, provisioning, SDK iOS |
| `developer-delphi-android-setup_V1.0.0` | SDK/NDK, manifest, permissoes Android |
| `developer-delphi-ios-publishing_V1.0.0` | IPA, Info.plist, entitlements, App Store |
| `developer-delphi-android-publishing_V1.0.0` | Keystore, AAB, Google Play Console |
| **`developer-delphi-mobile-orchestrator_V1.1.0`** | **Roteamento e fluxo completo (esta skill)** |

## Anti-padrões

- Tentar publicar iOS sem Mac com PAServer rodando
- Usar mesma keystore para projetos diferentes (criar uma por app)
- Pular testes em Internal testing/TestFlight e ir direto para producao
- Desenvolver UI com logica de negocio nos Forms (separar via VM/Service)

## Metricas de sucesso

- Novo projeto mobile configurado para iOS + Android em menos de 2 horas
- Primeiro build Release (iOS + Android) bem-sucedido
- App publicado em Internal testing (Android) e TestFlight (iOS) na mesma semana

## Responsavel principal

Esta e a skill raiz da familia K — sem responsavel acima.

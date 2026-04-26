# Referência Rápida: Configuração .dproj para Android

## PropertyGroups Android 64-bit

### Base (todas as configurações)

```xml
<PropertyGroup Condition="'$(Platform)'=='Android64'">
  <!-- Namespaces obrigatórios para Android FMX -->
  <DCC_Namespace>Androidapi;FMX;System;Xml;Data;$(DCC_Namespace)</DCC_Namespace>
  <!-- Application ID — Package name do app -->
  <Android_ApplicationId>com.empresa.meuapp</Android_ApplicationId>
  <!-- SDK mínimo suportado -->
  <Android_MinSdkVersion>26</Android_MinSdkVersion>
  <!-- SDK alvo — Google Play exige >= 34 para novos apps -->
  <Android_TargetSdkVersion>34</Android_TargetSdkVersion>
</PropertyGroup>
```

### Debug

```xml
<PropertyGroup Condition="'$(Cfg_1)'!='' and '$(Platform)'=='Android64'">
  <!-- Usar debug keystore gerada automaticamente pelo Delphi -->
  <Android_VersionCode>1</Android_VersionCode>
  <Android_VersionName>1.0.0-debug</Android_VersionName>
  <DCC_DebugInformation>2</DCC_DebugInformation>
</PropertyGroup>
```

### Release (Play Store)

```xml
<PropertyGroup Condition="'$(Cfg_2)'!='' and '$(Platform)'=='Android64'">
  <!-- Versao — versionCode NUNCA pode regredir no Play Store -->
  <Android_VersionCode>10</Android_VersionCode>
  <Android_VersionName>1.0.0</Android_VersionName>

  <!-- Keystore de producao (usar variavel de ambiente para senhas) -->
  <Android_KeyStore>.\certificates\meuapp.keystore</Android_KeyStore>
  <Android_KeyStoreAlias>meuapp</Android_KeyStoreAlias>
  <Android_KeyStorePass>$(KEYSTORE_PASS)</Android_KeyStorePass>
  <Android_KeyAliasPass>$(KEY_ALIAS_PASS)</Android_KeyAliasPass>

  <!-- App Bundle — obrigatorio para Google Play desde ago/2021 -->
  <Android_GenerateBundle>true</Android_GenerateBundle>

  <!-- Otimizacoes de release -->
  <DCC_Optimize>true</DCC_Optimize>
  <DCC_DebugInformation>0</DCC_DebugInformation>
</PropertyGroup>
```

## Propriedades Importantes — Referência

| Propriedade | Descrição | Exemplo |
|-------------|-----------|---------|
| `Android_ApplicationId` | Package name único | `com.empresa.app` |
| `Android_MinSdkVersion` | API mínima | `26` |
| `Android_TargetSdkVersion` | API alvo | `34` |
| `Android_VersionCode` | Build number (inteiro incremental) | `10` |
| `Android_VersionName` | Versão exibida ao usuário | `1.0.0` |
| `Android_KeyStore` | Caminho da keystore | `.\certs\app.keystore` |
| `Android_KeyStoreAlias` | Alias dentro da keystore | `meuapp` |
| `Android_KeyStorePass` | Senha da keystore | `$(KEYSTORE_PASS)` |
| `Android_KeyAliasPass` | Senha do alias | `$(KEY_ALIAS_PASS)` |
| `Android_GenerateBundle` | Gerar AAB em vez de APK | `true` |

## Condições de Configuração no .dproj

| Condição | Significado |
|----------|-------------|
| `'$(Cfg_1)'!=''` | Configuração Debug |
| `'$(Cfg_2)'!=''` | Configuração Release |
| `'$(Platform)'=='Android64'` | Plataforma Android 64-bit |

## Saídas de Build

| Artefato | Caminho | Quando |
|----------|---------|--------|
| APK debug | `.\Android\Debug\<App>\bin\<App>.apk` | Debug build |
| APK release | `.\Android\Release\<App>\bin\<App>.apk` | Release sem bundle |
| AAB release | `.\Android\Release\<App>\bin\<App>.aab` | Release com bundle |

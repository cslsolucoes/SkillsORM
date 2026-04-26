# Guia: Configuração de Plataformas iOS e Android no Delphi

## Visão Comparativa das Plataformas

| Aspecto | iOS | Android |
|---------|-----|---------|
| Compilação | Cross-compile via Mac (PAServer) | Direto no Windows |
| Assinatura | Certificado Apple (Keychain) | Keystore Java (keytool) |
| Deploy para teste | USB + PAServer → iPhone/iPad | USB + ADB → dispositivo Android |
| Formato de distribuição | IPA (App Store) | AAB (Play Store) |
| Custo da conta de desenvolvedor | USD 99/ano | USD 25 (único) |
| Tempo de revisão | 1-3 dias | 1-7 dias (novos apps) |
| Localização dos builds | `.\iOSDevice64\Release\` | `.\Android\Release\` |

---

## iOS — Configuração Completa

### Connection Profile (PAServer)

```
Project > Options > Connection Profile
  Profile: MacLocal
  Host: 192.168.1.10    ← IP do Mac
  Port: 64211
  Password: [senha do paserver]
```

### SDK Manager iOS

```
Tools > Options > Deployment > SDK Manager
  + Add SDK
    Platform: iOS Device 64-bit
    Remote machine: MacLocal
    → Get From Remote Machine
```

### Certificados e Provisioning

```
Project > Options > Provisioning
  Import [certificado .p12] → senha do .p12
  Import [provisioning .mobileprovision]
  Debug: Apple Development + Development Profile
  Release: Apple Distribution + App Store Profile
```

### .dproj PropertyGroups iOS

```xml
<!-- Base -->
<PropertyGroup Condition="'$(Platform)'=='iOSDevice64'">
  <VerInfo_CFBundleIdentifier>com.empresa.app</VerInfo_CFBundleIdentifier>
  <VerInfo_MinimumOSVersion>16.0</VerInfo_MinimumOSVersion>
  <VerInfo_UIDeviceFamily>1,2</VerInfo_UIDeviceFamily>
</PropertyGroup>

<!-- Debug -->
<PropertyGroup Condition="'$(Cfg_1)'!='' and '$(Platform)'=='iOSDevice64'">
  <CodeSigningIdentity>Apple Development: Nome (ID)</CodeSigningIdentity>
  <ProvisioningProfile>App_Development.mobileprovision</ProvisioningProfile>
</PropertyGroup>

<!-- Release -->
<PropertyGroup Condition="'$(Cfg_2)'!='' and '$(Platform)'=='iOSDevice64'">
  <CodeSigningIdentity>Apple Distribution: Empresa (TEAMID)</CodeSigningIdentity>
  <ProvisioningProfile>App_AppStore.mobileprovision</ProvisioningProfile>
  <DCC_Optimize>true</DCC_Optimize>
  <DCC_DebugInformation>0</DCC_DebugInformation>
</PropertyGroup>
```

---

## Android — Configuração Completa

### SDK Manager Android

```
Tools > Options > Deployment > SDK Manager
  + Add SDK
    Platform: Android 64-bit
    Android SDK: C:\Users\<user>\AppData\Local\Android\Sdk
    Android NDK: C:\Users\<user>\AppData\Local\Android\Sdk\ndk\25.x.x
    Java JDK: C:\Program Files\Java\jdk-11
    → Update Local File Cache
```

### AndroidManifest.template.xml

Localizar em `.\Android\Debug\<App>\` após primeiro build, ou criar customizado.
Ver: `developer-delphi-android-setup_V1.0.0/exemplos/android_manifest_template.xml`

### Permissões

Dois níveis obrigatórios:
1. Declarar no `AndroidManifest.template.xml`
2. Solicitar em runtime via `PermissionsService.RequestPermissions`

Ver: `developer-delphi-android-setup_V1.0.0/exemplos/android_permissions_runtime.pas`

### .dproj PropertyGroups Android

```xml
<!-- Base -->
<PropertyGroup Condition="'$(Platform)'=='Android64'">
  <Android_ApplicationId>com.empresa.app</Android_ApplicationId>
  <Android_MinSdkVersion>26</Android_MinSdkVersion>
  <Android_TargetSdkVersion>34</Android_TargetSdkVersion>
</PropertyGroup>

<!-- Debug -->
<PropertyGroup Condition="'$(Cfg_1)'!='' and '$(Platform)'=='Android64'">
  <Android_VersionCode>1</Android_VersionCode>
  <Android_VersionName>1.0.0-debug</Android_VersionName>
</PropertyGroup>

<!-- Release -->
<PropertyGroup Condition="'$(Cfg_2)'!='' and '$(Platform)'=='Android64'">
  <Android_VersionCode>10</Android_VersionCode>
  <Android_VersionName>1.0.0</Android_VersionName>
  <Android_KeyStore>.\certificates\app.keystore</Android_KeyStore>
  <Android_KeyStoreAlias>meuapp</Android_KeyStoreAlias>
  <Android_KeyStorePass>$(KEYSTORE_PASS)</Android_KeyStorePass>
  <Android_KeyAliasPass>$(KEY_ALIAS_PASS)</Android_KeyAliasPass>
  <Android_GenerateBundle>true</Android_GenerateBundle>
  <DCC_Optimize>true</DCC_Optimize>
  <DCC_DebugInformation>0</DCC_DebugInformation>
</PropertyGroup>
```

---

## Compilação Condicional por Plataforma

```pascal
// Código específico por plataforma usando IFDEF
{$IFDEF IOS}
  // Código exclusivo iOS
  // Disponível: iOSapi.*, Macapi.*
{$ENDIF}

{$IFDEF ANDROID}
  // Código exclusivo Android
  // Disponível: Androidapi.*, FMX.Platform.Android
{$ENDIF}

{$IFDEF MSWINDOWS}
  // Código Windows (debug/simulação)
{$ENDIF}

// FMX.Platform para abstrações cross-platform
uses
  FMX.Platform;

// Exemplo: verificar plataforma em runtime
var
  LPlatform: IFMXApplicationService;
begin
  if TPlatformServices.Current.SupportsPlatformService(
       IFMXApplicationService, LPlatform) then
  begin
    // Plataforma suportada
  end;
end;
```

---

## Deploy e Teste por Plataforma

### iOS — Deploy no dispositivo

```
1. Conectar iPhone/iPad ao Mac via USB
2. No Xcode: confiar no computador (pop-up no dispositivo)
3. No RAD Studio: F9 (Run)
4. IDE conecta via PAServer → compila → deploya → inicia app
```

### Android — Deploy no dispositivo

```
1. Conectar Android via USB ao Windows (direto — sem Mac)
2. Aceitar diálogo de autorização USB no dispositivo
3. No RAD Studio: F9 (Run)
4. IDE usa ADB → instala APK → inicia app
```

### Verificar dispositivo conectado (Android)

```cmd
adb devices
# Resultado esperado:
# List of devices attached
# ABC123DEF456   device
```

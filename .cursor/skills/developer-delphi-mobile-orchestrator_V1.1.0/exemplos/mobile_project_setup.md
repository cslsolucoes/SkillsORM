# Guia: Configuração de Novo Projeto Mobile Delphi FMX

## Visão Geral

Este guia cobre a criação e configuração inicial de um projeto FMX Multi-Device Application para iOS e Android no RAD Studio.

## Pré-requisitos

### iOS
- Mac com Xcode instalado (mesma rede local que o Windows)
- PAServer instalado e rodando no Mac
- Apple Developer account (paga para publicação)
- Certificados e provisioning profiles configurados

### Android
- Android SDK (API 26+) e NDK instalados
- Java JDK 11+
- Dispositivo Android com USB Debugging (para testes)

---

## 1. Criar o Projeto

1. **File > New > Multi-Device Application**
2. Escolher template:
   - **Blank Application** — começa vazio
   - **Tab Application** — com TTabControl
   - **Master-Detail Application** — layout master/detail
3. Clicar **OK**

## 2. Configurar o Projeto

### Renomear arquivos de saída

**Project > Options > Delphi Compiler > Output:**
- Output directory: `.\bin\$(Platform)\$(Config)\`
- Unit output directory: `.\obj\$(Platform)\$(Config)\`

### Definir Bundle ID / Package Name

**Project > Options > Version Info:**
- Para iOS: `VerInfo_CFBundleIdentifier` = `com.empresa.meuapp`
- Para Android: configurar no `.dproj` diretamente (`Android_ApplicationId`)

Usar o mesmo identificador para ambas as plataformas para consistência.

---

## 3. Adicionar Plataformas

### iOS Device 64-bit

1. **Project > Add Platform** → `iOS Device - 64 bit`
2. No Project Manager: botão direito → **Activate**
3. **Project > Options > Connection Profile** → selecionar connection profile do Mac
4. **Tools > SDK Manager** → verificar SDK iOS sincronizado

Referência: `developer-delphi-ios-setup_V1.0.0`

### Android 64-bit

1. **Project > Add Platform** → `Android 64-bit`
2. No Project Manager: botão direito → **Activate**
3. **Tools > SDK Manager** → verificar SDK Android configurado

Referência: `developer-delphi-android-setup_V1.0.0`

---

## 4. Estrutura de Pastas Recomendada

```
MeuAppMobile/
  src/
    ufrm.Main.pas        ← Form principal
    ufrm.Main.fmx        ← Layout FMX
    uVM.Main.pas         ← ViewModel/Presenter (sem FMX)
    uSvc.Camera.pas      ← Service de camera
  assets/
    icon/
      icon_ios.png       ← 1024x1024
      icon_android.png   ← 512x512
    images/
  certificates/
    meuapp.keystore      ← Android (NAO versionar)
    MeuApp_Dev.mobileprovision    ← iOS Development
    MeuApp_AppStore.mobileprovision  ← iOS App Store
  MeuApp.dpr
  MeuApp.dproj
  .gitignore
```

### .gitignore obrigatório

```gitignore
# Keystores — NUNCA versionar
*.keystore
*.jks
certificates/*.keystore

# Provisioning profiles — opcional (podem ser recriados)
# *.mobileprovision

# Build outputs
Android/
iOSDevice*/
Win32/
Win64/
__history/
*.local
*.identcache
*.dcu
*.exe
*.dll
```

---

## 5. Estrutura .dproj para Multi-Plataforma

Adicionar no `.dproj` após a criação do projeto:

```xml
<!-- iOS — Base -->
<PropertyGroup Condition="'$(Platform)'=='iOSDevice64'">
  <VerInfo_CFBundleIdentifier>com.empresa.meuapp</VerInfo_CFBundleIdentifier>
  <VerInfo_MinimumOSVersion>16.0</VerInfo_MinimumOSVersion>
  <VerInfo_UIDeviceFamily>1,2</VerInfo_UIDeviceFamily>
</PropertyGroup>

<!-- iOS — Release App Store -->
<PropertyGroup Condition="'$(Cfg_2)'!='' and '$(Platform)'=='iOSDevice64'">
  <CodeSigningIdentity>Apple Distribution: Empresa (TEAMID)</CodeSigningIdentity>
  <ProvisioningProfile>MeuApp_AppStore.mobileprovision</ProvisioningProfile>
  <DCC_Optimize>true</DCC_Optimize>
  <DCC_DebugInformation>0</DCC_DebugInformation>
</PropertyGroup>

<!-- Android — Base -->
<PropertyGroup Condition="'$(Platform)'=='Android64'">
  <Android_ApplicationId>com.empresa.meuapp</Android_ApplicationId>
  <Android_MinSdkVersion>26</Android_MinSdkVersion>
  <Android_TargetSdkVersion>34</Android_TargetSdkVersion>
</PropertyGroup>

<!-- Android — Release Play Store -->
<PropertyGroup Condition="'$(Cfg_2)'!='' and '$(Platform)'=='Android64'">
  <Android_VersionCode>1</Android_VersionCode>
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

## 6. Primeiro Build por Plataforma

### Validar Build iOS (Debug)

1. Confirmar PAServer ativo no Mac
2. Project Manager → selecionar `iOS Device 64-bit` + `Debug`
3. **Run** (F9) → app deve deployar no iPhone/iPad conectado via USB

### Validar Build Android (Debug)

1. Conectar dispositivo Android com USB Debugging
2. Project Manager → selecionar `Android 64-bit` + `Debug`
3. **Run** (F9) → app deve instalar e iniciar no dispositivo

### Primeiro Build Release

Para cada plataforma, mudar para `Release` e executar **Build** (sem Deploy) para verificar que a assinatura está correta antes de submeter às lojas.

---

## 7. Próximos Passos

- iOS Publication: `developer-delphi-ios-publishing_V1.0.0`
- Android Publication: `developer-delphi-android-publishing_V1.0.0`
- UI/Layout: `developer-delphi-fmx-layout_V1.1.0`

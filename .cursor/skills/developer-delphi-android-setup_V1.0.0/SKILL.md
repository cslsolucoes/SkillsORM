---
name: developer-delphi-android-setup
version: 1.0.0
description: "Configuração completa da plataforma Android para projetos Delphi FMX: Android SDK/NDK via SDK Manager, AndroidManifest.template.xml, modelo de permissões em dois níveis (manifesto + runtime) e Android Services."
model: sonnet
category: developer-delphi
family: K (Mobile)
thinking: false
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-android-setup_V1.0.0

## Responsabilidade única

Configurar o ambiente de desenvolvimento Android para Delphi FMX: Android SDK/NDK, ativação da plataforma Android 64-bit, AndroidManifest.template.xml com variáveis de placeholder, modelo de permissões em dois níveis (declaração no manifesto + solicitação em runtime via PermissionsService) e Android Services.

## When NOT to use

- Publicação no Google Play → usar `developer-delphi-android-publishing_V1.0.0`
- Setup iOS → usar `developer-delphi-ios-setup_V1.0.0`
- Dúvidas sobre qual skill usar → usar `developer-delphi-mobile-orchestrator_V1.1.0`

## Dependências

- Android SDK (API Level 26+ mínimo, API 34 target recomendado)
- Android NDK (versão compatível com RAD Studio — verificar SDK Manager)
- Java JDK 11+
- Dispositivo físico com USB Debugging habilitado (para testes) ou emulador AVD

---

## 1. Pré-requisitos

| Componente | Versão mínima | Observação |
|------------|---------------|------------|
| Android SDK | API Level 26 (Android 8.0) | Target: API 34 para novos apps |
| Android NDK | 25.x+ | Versão compatível listada no SDK Manager |
| Java JDK | 11+ | JDK 17 recomendado |
| USB Debugging | — | Habilitado em Settings > Developer Options |

**Habilitar Developer Options no dispositivo:**
1. Settings > About Phone > Build Number (tocar 7 vezes)
2. Settings > Developer Options > USB Debugging → ON

---

## 2. SDK Manager — Configuração

**Tools > Options > Deployment > SDK Manager > + (Add SDK)**

| Campo | Valor |
|-------|-------|
| Platform | `Android 64-bit` |
| Android SDK | Caminho raiz do SDK (ex.: `C:\Android\sdk`) |
| Android NDK | Caminho do NDK (ex.: `C:\Android\ndk\25.2.9519653`) |
| Java JDK | Caminho do JDK (ex.: `C:\Program Files\Java\jdk-11`) |

Após preencher, clicar **Update Local File Cache** para sincronizar.

### Instalar SDK via Android Studio (alternativa recomendada)

1. Baixar Android Studio (gratuito): `developer.android.com/studio`
2. SDK Manager interno: instalar SDK Tools + NDK + Build Tools
3. Apontar o RAD Studio para os caminhos gerados

### Caminhos padrão (Android Studio)

```
C:\Users\<usuario>\AppData\Local\Android\Sdk\
  build-tools\34.0.0\
  ndk\25.2.9519653\
  platforms\android-34\
  platform-tools\      ← adb.exe aqui
```

---

## 3. Ativando Android no Projeto

1. **Project > Add Platform** → `Android 64-bit`
2. No **Project Manager**: botão direito na plataforma → **Activate**
3. Verificar: **Project > Options > Building > Delphi Compiler** → Target Platform = `Android 64-bit`

---

## 4. Configuração `.dproj` para Android

```xml
<!-- Base Android 64-bit -->
<PropertyGroup Condition="'$(Platform)'=='Android64'">
  <DCC_Namespace>Androidapi;FMX;System;Xml;Data;$(DCC_Namespace)</DCC_Namespace>
  <Android_ApplicationId>com.empresa.meuapp</Android_ApplicationId>
  <Android_MinSdkVersion>26</Android_MinSdkVersion>
  <Android_TargetSdkVersion>34</Android_TargetSdkVersion>
</PropertyGroup>
```

---

## 5. AndroidManifest.template.xml — Variáveis de Placeholder

RAD Studio gera o `AndroidManifest.xml` final a partir do `AndroidManifest.template.xml` substituindo placeholders em build.

### Tabela de Variáveis

| Placeholder | Substituído por |
|-------------|----------------|
| `%package%` | Package name / Application ID |
| `%versionCode%` | `Android_VersionCode` do .dproj |
| `%versionName%` | `Android_VersionName` do .dproj |
| `%minSdkVersion%` | `Android_MinSdkVersion` do .dproj |
| `%targetSdkVersion%` | `Android_TargetSdkVersion` do .dproj |
| `%label%` | Nome do app (definido no projeto) |
| `%libNameValue%` | Nome da biblioteca nativa gerada |
| `%app_icon%` | Recurso de ícone |

### Template Mínimo

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
  package="%package%"
  android:versionCode="%versionCode%"
  android:versionName="%versionName%">

  <uses-sdk android:minSdkVersion="%minSdkVersion%"
            android:targetSdkVersion="%targetSdkVersion%"/>

  <!-- Permissões declaradas aqui -->
  <uses-permission android:name="android.permission.INTERNET"/>

  <application android:label="%label%"
               android:icon="@drawable/ic_launcher"
               android:allowBackup="true"
               android:extractNativeLibs="true">
    <activity android:name="com.embarcadero.firemonkey.FMXNativeActivity"
              android:label="%label%"
              android:configChanges="orientation|keyboardHidden|screenSize|smallestScreenSize|layoutDirection|locale|fontScale|screenLayout|density|uiMode"
              android:exported="true">
      <meta-data android:name="android.app.lib_name" android:value="%libNameValue%"/>
      <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
      </intent-filter>
    </activity>
  </application>
</manifest>
```

---

## 6. Modelo de Permissões Android — Dois Níveis

Android exige duas etapas para usar permissões sensíveis (API 23+):

### Nível 1 — Declaração no Manifesto (obrigatório para toda permissão)

```xml
<!-- No AndroidManifest.template.xml, antes de <application> -->
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

### Nível 2 — Solicitação em Runtime (API 23+ obrigatório para "dangerous permissions")

```pascal
uses
  FMX.Platform.Android,
  Androidapi.Helpers;

procedure TForm1.BtnRequestPermissionClick(Sender: TObject);
begin
  PermissionsService.RequestPermissions(
    ['android.permission.CAMERA',
     'android.permission.READ_EXTERNAL_STORAGE'],
    procedure(const APermissions: TArray<string>;
              const AGrantResults: TArray<TPermissionStatus>)
    begin
      if (Length(AGrantResults) >= 2) and
         (AGrantResults[0] = TPermissionStatus.Granted) and
         (AGrantResults[1] = TPermissionStatus.Granted) then
        // Permissoes concedidas — prosseguir com a funcionalidade
        StartFunctionality
      else
        ShowMessage('Permissoes necessarias negadas.');
    end
  );
end;
```

---

## 7. Tabela Completa de Permissões por Categoria

| Categoria | Permissão Android | Nivel |
|-----------|-------------------|-------|
| Internet | `android.permission.INTERNET` | Normal |
| Rede (estado) | `android.permission.ACCESS_NETWORK_STATE` | Normal |
| Câmera | `android.permission.CAMERA` | Perigosa |
| Localização precisa | `android.permission.ACCESS_FINE_LOCATION` | Perigosa |
| Localização aproximada | `android.permission.ACCESS_COARSE_LOCATION` | Perigosa |
| Armazenamento leitura (até API 32) | `android.permission.READ_EXTERNAL_STORAGE` | Perigosa |
| Armazenamento escrita | `android.permission.WRITE_EXTERNAL_STORAGE` | Perigosa |
| Imagens (API 33+) | `android.permission.READ_MEDIA_IMAGES` | Perigosa |
| Vídeos (API 33+) | `android.permission.READ_MEDIA_VIDEO` | Perigosa |
| Áudio (API 33+) | `android.permission.READ_MEDIA_AUDIO` | Perigosa |
| Bluetooth (API 31+) | `android.permission.BLUETOOTH_CONNECT` | Perigosa |
| Contatos | `android.permission.READ_CONTACTS` | Perigosa |
| Microfone | `android.permission.RECORD_AUDIO` | Perigosa |
| Notificações (API 33+) | `android.permission.POST_NOTIFICATIONS` | Perigosa |
| Vibração | `android.permission.VIBRATE` | Normal |
| Wake Lock | `android.permission.WAKE_LOCK` | Normal |
| Receber boot | `android.permission.RECEIVE_BOOT_COMPLETED` | Normal |

> **Permissões "Perigosas"** requerem solicitação em runtime (Nível 2).
> **Permissões "Normais"** são concedidas automaticamente ao instalar o app.

---

## 8. Android Services

Para processamento em background sem UI:

```pascal
// Arquivo separado: MeuAppService.dpr
// Comunicação com a Activity via TLocalServiceConnection

uses
  System.Android.Service,
  Androidapi.JNI.GraphicsContentViewText;

type
  TMeuAppService = class(TAndroidService)
  protected
    function AndroidServiceStartCommand(const Sender: TObject;
      const Intent: JIntent; Flags, StartId: Integer): Integer; override;
  end;
```

- Declarar no `AndroidManifest.template.xml`:

```xml
<service android:name="com.embarcadero.firemonkey.FMXService"
         android:exported="false">
  <meta-data android:name="android.app.lib_name"
             android:value="%libNameValue%Service"/>
</service>
```

---

## 9. Referências Cruzadas — Família K

| Skill | Responsabilidade |
|-------|-----------------|
| **`developer-delphi-android-setup_V1.0.0`** | **Esta skill — setup Android** |
| `developer-delphi-android-publishing_V1.0.0` | Keystore, AAB, Google Play Console |
| `developer-delphi-ios-setup_V1.0.0` | PAServer, certificados, provisioning iOS |
| `developer-delphi-ios-publishing_V1.0.0` | IPA, App Store Connect |
| `developer-delphi-mobile-orchestrator_V1.1.0` | Roteamento e fluxo completo mobile |

## Anti-padrões

- Solicitar permissões no `OnCreate` sem verificar se já foram concedidas
- Usar `targetSdkVersion` desatualizado (Google Play exige API 34+ para novos apps)
- Esquecer de declarar permissão no manifesto (runtime request falhará silenciosamente)
- Usar `WRITE_EXTERNAL_STORAGE` em API 33+ (removida; usar MediaStore)

## Métricas de sucesso

- Build Android compila sem erros para `Android 64-bit`
- Deploy no dispositivo físico bem-sucedido em modo Debug
- Permissões solicitadas corretamente no runtime com callback funcional

## Responsável principal

`developer-delphi-mobile-orchestrator_V1.1.0`

# AppxManifest.xml — Capabilities Comuns

## Tipos de capability

| Tipo | Namespace | Exemplos | Aprovacao na Store |
|------|-----------|----------|--------------------|
| General capabilities | (default) | `internetClient`, `microphone` | Automatica |
| UAP capabilities | `uap:` | `enterpriseAuthentication`, `sharedUserCertificates` | Automatica |
| Restricted capabilities | `rescap:` | `runFullTrust`, `backgroundMediaPlayback` | Requer justificativa |
| Device capabilities | `DeviceCapability` | `bluetooth`, `webcam`, `usb` | Automatica |

---

## General Capabilities (mais comuns)

| Capability | Quando usar | Risco SmartScreen |
|-----------|-------------|-------------------|
| `internetClient` | App faz requisicoes HTTP/HTTPS de saida | Baixo |
| `internetClientServer` | App e servidor (escuta conexoes de entrada) | Medio |
| `privateNetworkClientServer` | Acesso a rede local/intranet | Baixo |
| `musicLibrary` | Leitura da biblioteca de musicas do usuario | Baixo |
| `picturesLibrary` | Leitura da biblioteca de fotos | Baixo |
| `videosLibrary` | Leitura da biblioteca de videos | Baixo |
| `documentsLibrary` | Leitura/escrita na pasta Documentos | Medio |
| `removableStorage` | Acesso a dispositivos USB/SD | Medio |

```xml
<Capabilities>
  <Capability Name="internetClient"/>
  <Capability Name="privateNetworkClientServer"/>
</Capabilities>
```

---

## Restricted Capabilities (requerem justificativa na Store)

| Capability | Quando usar | Justificativa tipica na Store |
|-----------|-------------|-------------------------------|
| `runFullTrust` | Apps Win32 classicos (Delphi, FPC, C++ nativo) | "App legado Win32 requer acesso total ao sistema" |
| `allowElevation` | App precisa de UAC elevation em sub-processos | "Instalacao de driver ou servico Windows" |
| `backgroundMediaPlayback` | Reproducao de midia em background | "Player de musica/radio" |
| `broadFileSystemAccess` | Acesso ao sistema de arquivos alem das pastas padrao | "Gerenciador de arquivos, IDE, backup tool" |
| `confirmAppClose` | Interceptar fechamento do app | "Editor com dados nao salvos" |
| `deviceUnlock` | Desbloquear dispositivo via app | "App de seguranca corporativa" |
| `extendedExecutionCritical` | Execucao critica no background | "App de monitoramento critico" |

```xml
<Capabilities>
  <Capability Name="internetClient"/>
  <rescap:Capability Name="runFullTrust"/>
  <!-- broadFileSystemAccess: necessita justificativa detalhada na Store -->
  <rescap:Capability Name="broadFileSystemAccess"/>
</Capabilities>
```

---

## Device Capabilities

```xml
<Capabilities>
  <!-- Bluetooth -->
  <DeviceCapability Name="bluetooth"/>

  <!-- Webcam/Camera -->
  <DeviceCapability Name="webcam"/>

  <!-- Microfone -->
  <DeviceCapability Name="microphone"/>

  <!-- Localizacao GPS -->
  <DeviceCapability Name="location"/>

  <!-- USB customizado (requer classe de dispositivo) -->
  <DeviceCapability Name="usb">
    <Device Id="any">
      <Function Type="classId:ff * *"/>  <!-- Classe vendor-specific -->
    </Device>
  </DeviceCapability>
</Capabilities>
```

---

## UAP Capabilities

| Capability UAP | Quando usar |
|----------------|-------------|
| `uap:enterpriseAuthentication` | Autenticacao com credenciais Windows (Kerberos/NTLM) |
| `uap:sharedUserCertificates` | Acesso a certificados do usuario para autenticacao |
| `uap:userAccountInformation` | Acesso ao nome/foto do usuario Windows |
| `uap:appointments` | Acesso ao calendario do usuario |
| `uap:contacts` | Acesso aos contatos do usuario |
| `uap:phoneCall` | Realizar chamadas telefonicas (dispositivos moveis) |

```xml
<Capabilities>
  <uap:Capability Name="enterpriseAuthentication"/>
  <uap:Capability Name="userAccountInformation"/>
</Capabilities>
```

---

## Regra pratica

> Declare APENAS as capabilities que o app realmente usa.
> Capabilities nao usadas que estao declaradas podem causar rejeicao no WACK.
> Capabilities usadas que nao estao declaradas causam SecurityException em runtime.

```xml
<!-- Configuracao tipica para app ERP Delphi Win32 com banco de dados -->
<Capabilities>
  <Capability Name="internetClient"/>           <!-- requisicoes HTTP p/ APIs -->
  <Capability Name="privateNetworkClientServer"/> <!-- banco de dados na rede local -->
  <rescap:Capability Name="runFullTrust"/>       <!-- app Win32 classico -->
</Capabilities>
```

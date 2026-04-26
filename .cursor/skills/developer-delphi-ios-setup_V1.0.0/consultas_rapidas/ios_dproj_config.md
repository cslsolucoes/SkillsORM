# Referência Rápida: Configuração .dproj para iOS

## PropertyGroups iOS Device 64-bit

### Base (todas as configurações)

```xml
<PropertyGroup Condition="'$(Platform)'=='iOSDevice64'">
  <!-- Namespaces obrigatórios para iOS -->
  <DCC_Namespace>Macapi;iOSapi;FMX;System;Xml;Data;Datasnap;Web;Soap;$(DCC_Namespace)</DCC_Namespace>
  <!-- Bundle Identifier — deve coincidir com App ID no portal Apple -->
  <VerInfo_CFBundleIdentifier>com.empresa.meuapp</VerInfo_CFBundleIdentifier>
  <!-- Versão exibida internamente (ex.: 1.0.0) -->
  <VerInfo_CFBundleVersion>1.0.0</VerInfo_CFBundleVersion>
  <!-- Versão exibida ao usuário (ex.: 1.0) -->
  <VerInfo_CFBundleShortVersionString>1.0</VerInfo_CFBundleShortVersionString>
  <!-- iOS mínimo suportado -->
  <VerInfo_MinimumOSVersion>16.0</VerInfo_MinimumOSVersion>
  <!-- 1=iPhone, 2=iPad, 1,2=Universal -->
  <VerInfo_UIDeviceFamily>1,2</VerInfo_UIDeviceFamily>
</PropertyGroup>
```

### Debug — Development

```xml
<PropertyGroup Condition="'$(Cfg_1)'!='' and '$(Platform)'=='iOSDevice64'">
  <!-- Identidade de assinatura — certificado Development -->
  <CodeSigningIdentity>Apple Development: Joao Silva (DEVID123)</CodeSigningIdentity>
  <!-- Provisioning profile de desenvolvimento -->
  <ProvisioningProfile>MeuApp_Development.mobileprovision</ProvisioningProfile>
  <!-- Debug info completo -->
  <DCC_DebugInformation>2</DCC_DebugInformation>
</PropertyGroup>
```

### Release — App Store Distribution

```xml
<PropertyGroup Condition="'$(Cfg_2)'!='' and '$(Platform)'=='iOSDevice64'">
  <!-- Identidade de assinatura — certificado Distribution -->
  <CodeSigningIdentity>Apple Distribution: Nome Empresa (TEAMID)</CodeSigningIdentity>
  <!-- Provisioning profile App Store -->
  <ProvisioningProfile>MeuApp_AppStore.mobileprovision</ProvisioningProfile>
  <!-- Otimizações de release -->
  <DCC_Optimize>true</DCC_Optimize>
  <DCC_DebugInformation>0</DCC_DebugInformation>
</PropertyGroup>
```

### Release — Ad Hoc

```xml
<PropertyGroup Condition="'$(Cfg_2)'!='' and '$(Platform)'=='iOSDevice64'">
  <CodeSigningIdentity>Apple Distribution: Nome Empresa (TEAMID)</CodeSigningIdentity>
  <ProvisioningProfile>MeuApp_AdHoc.mobileprovision</ProvisioningProfile>
  <DCC_Optimize>true</DCC_Optimize>
  <DCC_DebugInformation>0</DCC_DebugInformation>
</PropertyGroup>
```

## Propriedades Importantes — Referência

| Propriedade | Descrição | Exemplo |
|-------------|-----------|---------|
| `VerInfo_CFBundleIdentifier` | Bundle ID único do app | `com.empresa.app` |
| `VerInfo_CFBundleVersion` | Build number interno | `1.0.0` |
| `VerInfo_CFBundleShortVersionString` | Versão exibida ao usuário | `1.0` |
| `VerInfo_MinimumOSVersion` | iOS mínimo suportado | `16.0` |
| `VerInfo_UIDeviceFamily` | Família de dispositivos | `1,2` (Universal) |
| `CodeSigningIdentity` | Nome do certificado | `Apple Distribution: ...` |
| `ProvisioningProfile` | Nome/UUID do profile | `MeuApp_AppStore.mobileprovision` |
| `DCC_Optimize` | Otimização do compilador | `true` |
| `DCC_DebugInformation` | Nível de debug (0=nenhum, 2=completo) | `0` |

## Condições de Configuração no .dproj

| Condição | Significado |
|----------|-------------|
| `'$(Cfg_1)'!=''` | Configuração Debug (índice 1) |
| `'$(Cfg_2)'!=''` | Configuração Release (índice 2) |
| `'$(Platform)'=='iOSDevice64'` | Plataforma iOS Device 64-bit |
| Sem condição de cfg | Aplica a todas as configurações (base) |

## Verificação rápida no IDE

- **Project > Options > Version Info** → editar `VerInfo_*` visualmente
- **Project > Options > Provisioning** → associar certificado e profile
- **Project Manager** → confirmar plataforma iOS ativa (negrito)

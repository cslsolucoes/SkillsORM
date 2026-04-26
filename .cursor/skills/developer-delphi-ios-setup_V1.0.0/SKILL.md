---
name: developer-delphi-ios-setup
version: 1.0.0
description: "Configuração completa da plataforma iOS para projetos Delphi FMX: PAServer, certificados Apple, provisioning profiles, SDK Manager e configuração .dproj."
model: sonnet
category: developer-delphi
family: K (Mobile)
thinking: false
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-ios-setup_V1.0.0

## Responsabilidade única

Configurar o ambiente de desenvolvimento iOS para Delphi FMX: PAServer no Mac, certificados Apple Development/Distribution, provisioning profiles (Development/Ad Hoc/App Store), SDK Manager iOS e mapeamento `.dproj` para iOS Device 64-bit.

## When NOT to use

- Publicação na App Store → usar `developer-delphi-ios-publishing_V1.0.0`
- Setup Android → usar `developer-delphi-android-setup_V1.0.0`
- Dúvidas sobre qual skill usar → usar `developer-delphi-mobile-orchestrator_V1.1.0`

## Dependências

- Mac com Xcode instalado e conta Apple Developer ativa
- RAD Studio / Delphi 12+ instalado no Windows
- Rede local que permita conexão Windows → Mac (porta 64211)

---

## 1. PAServer — Platform Assistant Server

O PAServer é o agente que roda no Mac e permite ao IDE Windows compilar, deployar e debugar apps iOS.

**Instalação no Mac:**
- Abrir o installer do RAD Studio → componente `PAServer-<versão>.pkg`
- Ou baixar diretamente em: Help > Embarcadero Website > Downloads

**Iniciar o PAServer:**
```bash
./paserver -port 64211 -password suasenha
```
Manter rodando durante toda a sessão de compilação/deploy.

**Configurar Connection Profile no IDE Windows:**
- **Project > Options > Connection Profile > Add**
  - Profile name: `MacLocal` (ou qualquer nome)
  - Host: IP do Mac na rede local (ex.: `192.168.1.10`)
  - Port: `64211`
  - Password: senha definida no `paserver`
- Clicar **Test Connection** para validar

**Dicas:**
- Usar IP fixo no Mac para não precisar reconfigurar
- PAServer pode rodar como serviço no Mac (ver documentação Apple)

---

## 2. Certificado de Desenvolvedor iOS

### Tipos de Certificado

| Tipo | Uso |
|------|-----|
| `Apple Development` | Testes em dispositivo físico (desenvolvimento) |
| `Apple Distribution` | Ad Hoc (testes externos) e App Store |

### Criar Certificado no Mac via Xcode

1. Abrir **Xcode > Settings (⌘,) > Accounts**
2. Selecionar Apple ID → **Manage Certificates**
3. Clicar **+** → **Apple Development** (ou **Apple Distribution**)
4. Xcode gera e instala o certificado no Keychain automaticamente

### Exportar Certificado (.p12)

1. Abrir **Keychain Access** no Mac
2. Localizar certificado em **My Certificates**
3. Clic direito → **Export** → formato `.p12`
4. Definir senha de exportação (guardar em local seguro)

### Importar no RAD Studio

- **Project > Options > Provisioning**
- Clicar em **Import** → selecionar o `.p12`
- Informar a senha do `.p12`

---

## 3. Provisioning Profile

### Tipos de Provisioning Profile

| Tipo | Quando usar |
|------|-------------|
| `Development` | Testes em dispositivo físico (UDIDs autorizados) |
| `Ad Hoc` | Distribuição externa para testadores (até 100 UDIDs) |
| `App Store Distribution` | Publicação na App Store |

### Criar no Apple Developer Portal

1. Acessar `developer.apple.com > Certificates, IDs & Profiles > Profiles > +`
2. Selecionar tipo:
   - **iOS App Development** → Development
   - **Ad Hoc** → distribuição Ad Hoc
   - **App Store** → publicação
3. Selecionar **App ID** (Bundle ID do projeto — deve coincidir com `VerInfo_CFBundleIdentifier` no `.dproj`)
4. Selecionar **Certificate** (o criado no passo 2)
5. Para Development/Ad Hoc: selecionar **Devices** (UDIDs registrados)
6. Nomear e clicar **Generate**
7. Baixar o arquivo `.mobileprovision`

### Importar no RAD Studio

- **Project > Options > Provisioning**
- Clicar **Import** → selecionar `.mobileprovision`
- Associar ao certificado correto

---

## 4. SDK Manager — Configuração iOS

O SDK Manager sincroniza os headers e frameworks do iOS do Mac para o Windows.

**Adicionar SDK iOS:**
1. **Tools > Options > Deployment > SDK Manager**
2. Clicar **+** (Add SDK)
3. Selecionar Platform: `iOS Device 64-bit`
4. Em **Remote machine**, selecionar o connection profile configurado (PAServer)
5. Clicar **Get From Remote Machine** para baixar headers/frameworks
6. Aguardar sincronização (pode levar minutos na primeira vez)

**Atualização:** repetir sempre que atualizar o Xcode/iOS SDK no Mac.

---

## 5. Ativando Plataforma iOS no Projeto

1. **Project > Add Platform** → `iOS Device - 64 bit`
2. No **Project Manager** (painel direito): botão direito na plataforma iOS → **Activate**
3. Verificar: **Project > Options > Building > Delphi Compiler** → Target Platform = `iOS Device 64-bit`
4. Para distribuição: Configuration = `Release`

---

## 6. Configuração `.dproj` para iOS Device 64-bit

```xml
<!-- Base iOS Device 64-bit -->
<PropertyGroup Condition="'$(Platform)'=='iOSDevice64'">
  <DCC_Namespace>Macapi;iOSapi;FMX;System;Xml;Data;Datasnap;Web;Soap;$(DCC_Namespace)</DCC_Namespace>
  <VerInfo_CFBundleIdentifier>com.empresa.meuapp</VerInfo_CFBundleIdentifier>
  <VerInfo_CFBundleVersion>1.0.0</VerInfo_CFBundleVersion>
  <VerInfo_CFBundleShortVersionString>1.0</VerInfo_CFBundleShortVersionString>
  <VerInfo_MinimumOSVersion>16.0</VerInfo_MinimumOSVersion>
  <VerInfo_UIDeviceFamily>1,2</VerInfo_UIDeviceFamily>
</PropertyGroup>

<!-- Release App Store iOS Device 64-bit -->
<PropertyGroup Condition="'$(Cfg_2)'!='' and '$(Platform)'=='iOSDevice64'">
  <CodeSigningIdentity>Apple Distribution: Nome Empresa (TEAMID)</CodeSigningIdentity>
  <ProvisioningProfile>MeuApp_AppStore.mobileprovision</ProvisioningProfile>
  <DCC_Optimize>true</DCC_Optimize>
  <DCC_DebugInformation>0</DCC_DebugInformation>
</PropertyGroup>

<!-- Debug Development iOS Device 64-bit -->
<PropertyGroup Condition="'$(Cfg_1)'!='' and '$(Platform)'=='iOSDevice64'">
  <CodeSigningIdentity>Apple Development: Seu Nome (DEVID)</CodeSigningIdentity>
  <ProvisioningProfile>MeuApp_Development.mobileprovision</ProvisioningProfile>
  <DCC_DebugInformation>2</DCC_DebugInformation>
</PropertyGroup>
```

---

## 7. Referências Cruzadas — Família K

| Skill | Responsabilidade |
|-------|-----------------|
| **`developer-delphi-ios-setup_V1.0.0`** | **Esta skill — setup iOS** |
| `developer-delphi-ios-publishing_V1.0.0` | IPA, Info.plist, entitlements, App Store Connect |
| `developer-delphi-android-setup_V1.0.0` | SDK/NDK Android, manifest, permissões |
| `developer-delphi-android-publishing_V1.0.0` | Keystore, AAB, Google Play Console |
| `developer-delphi-mobile-orchestrator_V1.1.0` | Roteamento e fluxo completo mobile |

## Anti-padrões

- Usar certificado Distribution para desenvolvimento (desperdício de slots)
- Esquecer de atualizar o SDK Manager após atualizar Xcode no Mac
- Hardcodar TeamID ou nome do certificado sem parametrizar por configuração
- Usar provisionamento manual quando o automático do Xcode resolve mais fácil

## Métricas de sucesso

- Build iOS compila sem erros no Windows via PAServer
- Deploy no dispositivo físico bem-sucedido em modo Debug
- Build Release gera IPA válido assinado com Apple Distribution

## Responsável principal

`developer-delphi-mobile-orchestrator_V1.1.0`

# Guia: Provisioning Profiles iOS

## O que é um Provisioning Profile

Um provisioning profile combina três elementos:
1. **App ID** (Bundle Identifier) — identifica o app
2. **Certificate** — identifica o desenvolvedor/empresa
3. **Devices** (apenas Development/Ad Hoc) — UDIDs autorizados

Sem um provisioning profile válido, o iOS não executa o app.

## Tipos de Provisioning Profile

| Tipo | Uso | Dispositivos |
|------|-----|--------------|
| Development | Testes em dispositivo físico durante desenvolvimento | Somente UDIDs registrados |
| Ad Hoc | Distribuição externa para testadores | Até 100 UDIDs por ano |
| App Store | Publicação pública na App Store | Qualquer dispositivo |
| Enterprise | Distribuição interna sem App Store | Dispositivos da empresa |

## Pré-requisito: App ID (Bundle Identifier)

Antes de criar o provisioning profile, registrar o Bundle ID:

1. `developer.apple.com > Identifiers > +`
2. Tipo: **App IDs**
3. Selecionar **App** → **Continue**
4. Description: nome legível (ex.: `MeuApp`)
5. Bundle ID: `Explicit` → informar (ex.: `com.minhaempresa.meuapp`)
6. Capabilities: marcar apenas o necessário (Push Notifications, Sign in with Apple, etc.)
7. Clicar **Register**

## Criar Provisioning Profile

### No Apple Developer Portal

1. Acessar `developer.apple.com > Certificates, IDs & Profiles > Profiles`
2. Clicar **+**
3. Selecionar tipo:

**Para desenvolvimento:**
- iOS App Development → Continue

**Para distribuição Ad Hoc:**
- Ad Hoc → Continue

**Para App Store:**
- App Store Connect → Continue

4. **App ID**: selecionar o Bundle ID cadastrado
5. **Certificates**: selecionar o certificado correspondente
6. **Devices** (apenas Development/Ad Hoc): selecionar os UDIDs
7. **Profile Name**: nome descritivo (ex.: `MeuApp_Development`, `MeuApp_AppStore`)
8. Clicar **Generate**
9. Clicar **Download** para baixar o `.mobileprovision`

### Registrar UDIDs de Dispositivos

Para Development/Ad Hoc, o UDID do dispositivo deve estar registrado:

1. Conectar iPhone/iPad ao Mac com Xcode aberto
2. **Window > Devices and Simulators**
3. Selecionar o dispositivo → copiar o **Identifier** (UDID)
4. No portal: `Devices > +` → colar o UDID e dar um nome

Ou via Xcode: ao tentar rodar no dispositivo pela primeira vez, Xcode oferece registrar automaticamente.

## Importar no RAD Studio

1. Garantir que o certificado `.p12` já foi importado (ver `ios_certificate.md`)
2. **Project > Options** → selecionar plataforma `iOS Device - 64-bit`
3. Seção **Provisioning** → clicar **Import**
4. Selecionar o arquivo `.mobileprovision`
5. Em **Certificate** selecionar o certificado correspondente
6. Em **Provisioning Profile** selecionar o profile importado

## Verificar Provisioning Profile no RAD Studio

No painel Provisioning, verificar:
- **Expiration date**: profile não expirado
- **Certificate**: certificado vinculado e válido
- **Devices**: para Development/Ad Hoc, o dispositivo de teste está na lista

## Ciclo de Vida e Renovação

- Validade: **1 ano** (mesmo do certificado)
- Ao renovar o certificado, recriar o provisioning profile e importar novamente
- Profiles com certificado expirado ficam inválidos automaticamente
- Ao adicionar novos dispositivos de teste: recriar o profile Ad Hoc/Development com os novos UDIDs

## Troubleshooting

| Problema | Causa | Solução |
|----------|-------|---------|
| "No provisioning profile" | Profile não importado | Importar o `.mobileprovision` no RAD Studio |
| "Certificate has expired" | Certificado vencido | Renovar certificado e recriar profile |
| "Device not included" | UDID não registrado | Adicionar UDID no portal e recriar profile |
| "Bundle ID mismatch" | Bundle ID do projeto diferente do App ID | Corrigir `VerInfo_CFBundleIdentifier` no `.dproj` |
| "Entitlements error" | Capabilities divergentes | Verificar entitlements no App ID vs. no profile |

## Exemplo: Bundle ID no .dproj

O `VerInfo_CFBundleIdentifier` no `.dproj` deve coincidir exatamente com o App ID:

```xml
<PropertyGroup Condition="'$(Platform)'=='iOSDevice64'">
  <VerInfo_CFBundleIdentifier>com.minhaempresa.meuapp</VerInfo_CFBundleIdentifier>
</PropertyGroup>
```

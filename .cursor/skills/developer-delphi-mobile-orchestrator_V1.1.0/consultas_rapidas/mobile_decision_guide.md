# Guia de Decisões Mobile — Referência Rápida

## Tabela de Decisões Principais

| Questão | Decisão Correta | Nunca Fazer |
|---------|-----------------|-------------|
| App Store ou Ad Hoc? | App Store para publico; Ad Hoc para testes (max. 100 UDIDs) | Distribuir via Ad Hoc para producao publica |
| APK ou AAB? | **AAB obrigatorio** para novos apps Google Play desde ago/2021 | Publicar APK sem AAB em novos apps |
| Debug keystore ou Release keystore? | **SEMPRE** release keystore para publicacao | Publicar com debug.keystore gerada pelo Delphi |
| PAServer onde? | Sempre no Mac — obrigatorio para iOS | Tentar compilar iOS sem PAServer ativo |
| Play App Signing? | **Recomendado** — Google gerencia chave de distribuicao | Perder keystore sem Play App Signing configurado |
| Internal testing ou Production direto? | Internal testing → validar → Production | Publicar direto em Production sem testes |
| TestFlight ou App Store direto? | TestFlight → beta test → App Store | Publicar em App Store sem TestFlight antes |
| Simulador ou dispositivo fisico? | Dispositivo fisico OBRIGATORIO antes de publicar | Publicar app testado apenas em simulador |
| Senhas no .dproj? | **NUNCA** — usar variaveis de ambiente | Hardcodar senhas da keystore no .dproj |
| Keystore no git? | **NUNCA** — guardar fora do repositorio | Versionar `.keystore` no git |

---

## Roteamento por Tarefa

### Preciso configurar o ambiente iOS
→ `developer-delphi-ios-setup_V1.0.0`
- PAServer no Mac
- Certificados Apple
- Provisioning profiles
- SDK Manager iOS

### Preciso configurar o ambiente Android
→ `developer-delphi-android-setup_V1.0.0`
- Android SDK + NDK
- AndroidManifest.template.xml
- Permissoes (manifesto + runtime)

### Preciso publicar na App Store
→ `developer-delphi-ios-publishing_V1.0.0`
- Gerar IPA
- App Store Connect
- Transporter

### Preciso publicar no Google Play
→ `developer-delphi-android-publishing_V1.0.0`
- Criar/gerir keystore
- Gerar AAB assinado
- Google Play Console

### Tenho duvidas de UI/Layout FMX
→ `developer-delphi-fmx-layout_V1.1.0`

### Tenho duvidas de animacoes FMX
→ `developer-delphi-fmx-animations_V1.0.0`

---

## Erros Comuns e Solucoes Rapidas

| Erro | Solucao |
|------|---------|
| iOS: "Cannot connect to PAServer" | Iniciar PAServer no Mac: `./paserver -port 64211 -password ...` |
| iOS: "No valid certificate" | Importar `.p12` em Project > Options > Provisioning |
| iOS: "Provisioning profile expired" | Recriar profile no Apple Developer Portal |
| Android: "SDK not found" | Tools > SDK Manager > verificar caminhos SDK/NDK |
| Android: "Signing failed" | Verificar variaveis KEYSTORE_PASS e KEY_ALIAS_PASS |
| Android: "versionCode already used" | Incrementar Android_VersionCode no .dproj |
| Android: "targetSdkVersion too low" | Atualizar para Android_TargetSdkVersion >= 34 |
| iOS build: "Xcode not found" | Instalar Xcode no Mac e Command Line Tools |
| Android: permissao negada em runtime | Adicionar permissao no AndroidManifest.template.xml (Nivel 1) |

---

## Verificacao Rapida — Ambiente Pronto?

### iOS — Checklist

```
[ ] PAServer rodando no Mac (porta 64211)
[ ] Connection Profile configurado no RAD Studio
[ ] SDK iOS sincronizado (Tools > SDK Manager)
[ ] Certificado Apple Development importado
[ ] Provisioning Profile Development importado
[ ] iPhone/iPad confiado no Mac
```

### Android — Checklist

```
[ ] Android SDK instalado e apontado no SDK Manager
[ ] Android NDK instalado
[ ] Java JDK configurado
[ ] USB Debugging ativo no dispositivo
[ ] ADB reconhece o dispositivo (adb devices)
```

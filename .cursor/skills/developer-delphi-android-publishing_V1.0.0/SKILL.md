---
name: developer-delphi-android-publishing
version: 1.0.0
description: "Publicação de apps Android no Google Play: criação de keystore via keytool, configuração de assinatura no .dproj, geração de APK assinado e AAB, Google Play Console workflow (Internal→Production), Play App Signing e versionamento."
model: sonnet
category: developer-delphi
family: K (Mobile)
thinking: false
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-android-publishing_V1.0.0

## Responsabilidade única

Cobrir o ciclo completo de publicação Android: criação e gestão segura de keystore, configuração de assinatura no `.dproj` via variáveis de ambiente, geração de APK assinado e AAB (obrigatório para Google Play), workflow do Google Play Console (Internal → Closed → Open → Production), Play App Signing, versionamento (`versionCode`/`versionName`) e checklist pré-publicação.

## When NOT to use

- Setup do ambiente Android (SDK/NDK/manifest) → usar `developer-delphi-android-setup_V1.0.0`
- Publicação iOS → usar `developer-delphi-ios-publishing_V1.0.0`
- Dúvidas sobre qual skill usar → usar `developer-delphi-mobile-orchestrator_V1.1.0`

## Dependências

- `developer-delphi-android-setup_V1.0.0` — ambiente Android configurado
- JDK instalado (para `keytool` e `apksigner`)
- Conta Google Play Console criada (taxa única USD 25)

---

## 1. Keystore — CRITICO

A keystore e vinculada **permanentemente** ao app no Google Play. Nunca a perca.
Sem ela e impossivel publicar atualizacoes do mesmo app.

### Criar via keytool (JDK)

```bash
keytool -genkey -v \
  -keystore meuapp.keystore \
  -alias meuapp \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

**Campos solicitados:**
1. Senha da keystore (guardar em gerenciador de senhas)
2. Senha do alias (pode ser a mesma)
3. First and Last Name (seu nome ou nome da empresa)
4. Organization Unit (departamento — pode ser vazio)
5. Organization (nome da empresa)
6. City or Locality
7. State or Province
8. Country Code (BR para Brasil)

**Confirmar criacao:**

```bash
keytool -list -v -keystore meuapp.keystore
# Exibe detalhes do certificado criado
```

### Regras de Gestao

- Guardar em local seguro com **backup offline** (HD externo ou cofre)
- **NUNCA** versionar a keystore no repositorio git (adicionar ao `.gitignore`)
- Armazenar senhas em gerenciador de senhas (Bitwarden, 1Password, etc.)
- Usar variaveis de ambiente para senhas em CI/CD — **nunca hardcoded**

---

## 2. Configuracao de Assinatura no .dproj

```xml
<!-- Release Android 64-bit com assinatura e bundle -->
<PropertyGroup Condition="'$(Cfg_2)'!='' and '$(Platform)'=='Android64'">
  <!-- Keystore -->
  <Android_KeyStore>$(MSBuildProjectDirectory)\certificates\meuapp.keystore</Android_KeyStore>
  <Android_KeyStoreAlias>meuapp</Android_KeyStoreAlias>
  <!-- Senhas via variavel de ambiente (nao hardcoded) -->
  <Android_KeyStorePass>$(KEYSTORE_PASS)</Android_KeyStorePass>
  <Android_KeyAliasPass>$(KEY_ALIAS_PASS)</Android_KeyAliasPass>

  <!-- Release flags -->
  <DCC_Optimize>true</DCC_Optimize>
  <DCC_DebugInformation>0</DCC_DebugInformation>

  <!-- Versao -->
  <Android_VersionCode>10</Android_VersionCode>
  <Android_VersionName>1.0.0</Android_VersionName>

  <!-- App Bundle (obrigatorio para Play Store) -->
  <Android_GenerateBundle>true</Android_GenerateBundle>
</PropertyGroup>
```

### Variaveis de Ambiente para Senhas

No Windows (linha de comando, antes de compilar):
```cmd
set KEYSTORE_PASS=SuaSenhaKeystore
set KEY_ALIAS_PASS=SuaSenhaAlias
```

Em CI/CD (GitHub Actions, exemplo):
```yaml
env:
  KEYSTORE_PASS: ${{ secrets.KEYSTORE_PASS }}
  KEY_ALIAS_PASS: ${{ secrets.KEY_ALIAS_PASS }}
```

---

## 3. Geracao de APK Assinado

1. Platform = `Android 64-bit`, Configuration = `Release`
2. **Project > Deploy** → gera APK assinado com a keystore
3. Saida: `.\Android\Release\<AppName>\bin\<AppName>.apk`

**Verificar assinatura:**

```bash
apksigner verify --verbose meuapp.apk
# Saida esperada: "Verified using v2 scheme (APK Signature Scheme v2): true"
```

---

## 4. Geracao de Android App Bundle (.aab)

AAB e **obrigatorio** para novos apps no Google Play desde agosto 2021.

**No .dproj (XML):**
```xml
<Android_GenerateBundle>true</Android_GenerateBundle>
```

**Ou via IDE:**
- **Project > Options > Building > Android** → marcar **Build Android App Bundle**

Saida: `.\Android\Release\<AppName>\bin\<AppName>.aab`

**Vantagem do AAB sobre APK:**
- Google otimiza o bundle por dispositivo (menor download para o usuario)
- Suporte a Dynamic Delivery e modulos sob demanda

---

## 5. Configuracao .dproj Completa — Base + Release

```xml
<!-- Base Android 64-bit -->
<PropertyGroup Condition="'$(Platform)'=='Android64'">
  <Android_ApplicationId>com.empresa.meuapp</Android_ApplicationId>
  <Android_MinSdkVersion>26</Android_MinSdkVersion>
  <Android_TargetSdkVersion>34</Android_TargetSdkVersion>
</PropertyGroup>

<!-- Release Android 64-bit -->
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

## 6. Google Play Console — Estrutura

**Criar conta:** `play.google.com/console` (taxa unica USD 25)

**Criar novo app:**
- **All apps > Create app**
- Nome, idioma padrao, tipo (app/game), gratuito/pago

**Navegacao principal:**

| Secao | Funcao |
|-------|--------|
| `Dashboard` | Visao geral e metricas |
| `Release > Internal testing` | Testes internos (sem revisao, publicacao imediata) |
| `Release > Closed testing (Alpha)` | Testes com grupo fechado |
| `Release > Open testing (Beta)` | Testes abertos |
| `Release > Production` | Publicacao publica |
| `Store presence` | Metadados, screenshots, descricao |
| `Policy > App content` | Classificacao IARC, data safety |
| `Monetize` | Precos, produtos in-app |

---

## 7. Workflow de Upload e Publicacao

```
1. Production > Releases > Create new release
2. Upload AAB (ou APK)
3. Preencher "What's new" (notas por idioma)
4. Review release → Save
5. Rollout to production (100% ou gradual: 10% → 50% → 100%)
6. Aguardar revisao: geralmente 1-3 dias uteis para novos apps
```

**Recomendacao:** comecar sempre por **Internal testing** para validar o build antes de ir para producao.

---

## 8. Play App Signing (Recomendado)

Google gerencia a chave de assinatura final para distribuicao:
- Voce assina com **upload key** (sua keystore)
- Google re-assina com **app signing key** para distribuicao
- Configurar em: **Release > Setup > App integrity > App signing**

**Vantagem:** se perder a keystore de upload, pode solicitar reset da upload key. A chave de distribuicao permanece intacta.

---

## 9. Versionamento

- `Android_VersionCode`: inteiro incremental — **nunca reutilizar** (1, 2, 3...)
- `Android_VersionName`: string exibida ao usuario (ex.: "1.0.0", "2.1.3")
- Google Play rejeita upload com `versionCode` <= ao build anterior em producao

**Estrategia sugerida:**
- `versionCode`: incrementar sempre (pode usar timestamp ou numero sequencial)
- `versionName`: seguir SemVer (`MAJOR.MINOR.PATCH`)

---

## 10. Requisitos de Assets

| Asset | Especificacao |
|-------|--------------|
| Icone | 512x512 PNG, sem transparencia |
| Feature graphic | 1024x500 PNG |
| Screenshots phone | Min. 2, max. 8 por idioma |
| Screenshots tablet 7" | Recomendado |
| Screenshots tablet 10" | Recomendado |

---

## 11. Checklist Pre-Publicacao Android

- [ ] `Android_VersionCode` incrementado (nunca reutilizar)
- [ ] `Android_VersionName` atualizado
- [ ] AAB assinado com keystore de producao (nao debug keystore)
- [ ] `targetSdkVersion` atual (Google exige >= API 34 para novos apps)
- [ ] Screenshots: phone min. 2 + icone 512x512 + feature graphic 1024x500
- [ ] Politica de privacidade URL valida
- [ ] Classificacao de conteudo IARC preenchida
- [ ] Declaracao de acesso a dados (Data safety) preenchida
- [ ] Permissoes declaradas no manifesto <= permissoes realmente usadas
- [ ] Testado em dispositivo fisico com build Release antes do submit
- [ ] Play App Signing configurado (recomendado)

---

## Referências Cruzadas — Família K

| Skill | Responsabilidade |
|-------|-----------------|
| **`developer-delphi-android-publishing_V1.0.0`** | **Esta skill — publicacao Android** |
| `developer-delphi-android-setup_V1.0.0` | Setup do ambiente Android |
| `developer-delphi-ios-publishing_V1.0.0` | Publicacao iOS App Store |
| `developer-delphi-ios-setup_V1.0.0` | Setup do ambiente iOS |
| `developer-delphi-mobile-orchestrator_V1.1.0` | Roteamento e fluxo completo mobile |

## Anti-padrões

- Hardcodar senhas da keystore no `.dproj` (usar variaveis de ambiente)
- Versionar a keystore no git (adicionar ao `.gitignore`)
- Reutilizar `versionCode` (Play Store rejeita)
- Usar debug keystore para publicacao
- Publicar direto em Production sem testar em Internal testing

## Metricas de sucesso

- AAB gerado, assinado e verificado com `apksigner`
- Upload bem-sucedido no Play Console sem erros de politica
- App disponivel em Internal testing em menos de 1 hora apos upload

## Responsavel principal

`developer-delphi-mobile-orchestrator_V1.1.0`

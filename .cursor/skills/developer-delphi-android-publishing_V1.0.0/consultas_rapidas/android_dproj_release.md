# Referência Rápida: .dproj Release Android

## PropertyGroups para Release Play Store

### Base (todas as configurações)

```xml
<PropertyGroup Condition="'$(Platform)'=='Android64'">
  <Android_ApplicationId>com.empresa.meuapp</Android_ApplicationId>
  <Android_MinSdkVersion>26</Android_MinSdkVersion>
  <Android_TargetSdkVersion>34</Android_TargetSdkVersion>
</PropertyGroup>
```

### Release completo

```xml
<PropertyGroup Condition="'$(Cfg_2)'!='' and '$(Platform)'=='Android64'">
  <!-- Versao — versionCode NUNCA pode regredir -->
  <Android_VersionCode>10</Android_VersionCode>
  <Android_VersionName>1.0.0</Android_VersionName>

  <!-- Keystore — senhas via variavel de ambiente -->
  <Android_KeyStore>$(MSBuildProjectDirectory)\certificates\meuapp.keystore</Android_KeyStore>
  <Android_KeyStoreAlias>meuapp</Android_KeyStoreAlias>
  <Android_KeyStorePass>$(KEYSTORE_PASS)</Android_KeyStorePass>
  <Android_KeyAliasPass>$(KEY_ALIAS_PASS)</Android_KeyAliasPass>

  <!-- App Bundle obrigatorio para Play Store -->
  <Android_GenerateBundle>true</Android_GenerateBundle>

  <!-- Otimizacoes -->
  <DCC_Optimize>true</DCC_Optimize>
  <DCC_DebugInformation>0</DCC_DebugInformation>
  <DCC_LocalDebugSymbols>false</DCC_LocalDebugSymbols>
</PropertyGroup>
```

## Saídas de Build

| Artefato | Caminho | Upload para Play Store |
|----------|---------|----------------------|
| APK release | `.\Android\Release\<App>\bin\<App>.apk` | Apenas apps legados |
| **AAB release** | `.\Android\Release\<App>\bin\<App>.aab` | **Obrigatório novos apps** |

## Verificar AAB antes do Upload

```bash
# Verificar assinatura (build-tools 30+)
apksigner verify --verbose MeuApp.aab

# Dump manifest
java -jar bundletool.jar dump manifest --bundle=MeuApp.aab
```

## Variáveis de Ambiente para Senhas

```cmd
# Windows — sessao atual
set KEYSTORE_PASS=SuaSenhaKeystore
set KEY_ALIAS_PASS=SuaSenhaAlias

# Compilar
dcc64 MeuProjeto.dpr
```

## Checklist Rápido Pré-Upload

- [ ] `versionCode` incrementado
- [ ] `versionName` atualizado
- [ ] `targetSdkVersion` >= 34
- [ ] AAB assinado com keystore de PRODUCAO
- [ ] Testado em dispositivo físico (Release build)
- [ ] Screenshots atualizadas se houver mudancas visuais

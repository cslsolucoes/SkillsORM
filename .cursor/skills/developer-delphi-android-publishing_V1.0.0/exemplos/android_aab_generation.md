# Guia: Geração de Android App Bundle (.aab)

## Por que AAB em vez de APK?

Desde **agosto de 2021**, o Google Play **exige AAB** para novos apps e para atualizações de apps que já usavam APK.

| Formato | Tamanho | Otimização | Play Store |
|---------|---------|------------|------------|
| APK | Maior (contém todos os recursos) | Nenhuma | Aceito (apps legados) |
| AAB | Menor (Google gera APK por dispositivo) | Sim (Dynamic Delivery) | **Obrigatório para novos** |

**Vantagens do AAB:**
- Download menor para o usuário (Google remove recursos desnecessários para o dispositivo)
- Suporte a Dynamic Feature Modules
- Geração de APK otimizado por densidade de tela, CPU e idioma

## Configurar Geração de AAB no Delphi

### Via .dproj (XML)

```xml
<PropertyGroup Condition="'$(Cfg_2)'!='' and '$(Platform)'=='Android64'">
  <!-- Habilitar geracao de App Bundle -->
  <Android_GenerateBundle>true</Android_GenerateBundle>

  <!-- Assinatura -->
  <Android_KeyStore>.\certificates\meuapp.keystore</Android_KeyStore>
  <Android_KeyStoreAlias>meuapp</Android_KeyStoreAlias>
  <Android_KeyStorePass>$(KEYSTORE_PASS)</Android_KeyStorePass>
  <Android_KeyAliasPass>$(KEY_ALIAS_PASS)</Android_KeyAliasPass>

  <!-- Versao -->
  <Android_VersionCode>10</Android_VersionCode>
  <Android_VersionName>1.0.0</Android_VersionName>

  <!-- Otimizacoes -->
  <DCC_Optimize>true</DCC_Optimize>
  <DCC_DebugInformation>0</DCC_DebugInformation>
</PropertyGroup>
```

### Via IDE

1. **Project > Options > Building > Android**
2. Marcar opção **Build Android App Bundle (.aab)**
3. Garantir que a assinatura está configurada em **Signing**

## Gerar o AAB — Passo a Passo

### Pré-requisitos

- [ ] Keystore criada e disponível no caminho configurado
- [ ] Variáveis de ambiente `KEYSTORE_PASS` e `KEY_ALIAS_PASS` definidas
- [ ] Platform = `Android 64-bit` ativa no projeto
- [ ] Configuration = `Release`
- [ ] `Android_GenerateBundle = true` no `.dproj`

### Passos no IDE

1. No **Project Manager**: clicar em `Release` na configuração
2. Selecionar plataforma `Android 64-bit`
3. **Project > Build** (ou F9 para compilar e deployar)
4. Aguardar compilação

### Localizar o AAB gerado

```
<PastaDoProj>\Android\Release\<NomeProjeto>\bin\<NomeProjeto>.aab
```

Exemplo:
```
C:\MeusProjetos\GestorERP\Android\Release\GestorERP\bin\GestorERP.aab
```

## Verificar o AAB

### Verificar assinatura com apksigner

O `apksigner` está em: `%ANDROID_SDK%\build-tools\<versao>\apksigner.bat`

```bash
apksigner verify --verbose MeuApp.aab
# Nota: apksigner suporta verificacao de AAB a partir de build-tools 30.0.0+
```

### Inspecionar AAB com bundletool

Baixar `bundletool.jar` em: `https://github.com/google/bundletool/releases`

```bash
# Listar conteudo do AAB
java -jar bundletool.jar dump manifest --bundle=MeuApp.aab

# Gerar APKs de teste a partir do AAB (simula o que o Play Store faz)
java -jar bundletool.jar build-apks \
  --bundle=MeuApp.aab \
  --output=MeuApp.apks \
  --ks=meuapp.keystore \
  --ks-pass=pass:SuaSenha \
  --ks-key-alias=meuapp \
  --key-pass=pass:SuaSenha

# Instalar no dispositivo conectado
java -jar bundletool.jar install-apks --apks=MeuApp.apks
```

## Troubleshooting

| Problema | Causa | Solução |
|----------|-------|---------|
| "No keystore" | `Android_KeyStore` não configurado | Verificar caminho no `.dproj` |
| "Wrong keystore password" | Senha incorreta | Verificar variável de ambiente `KEYSTORE_PASS` |
| "AAB not generated" | `Android_GenerateBundle` não definido | Adicionar ao `.dproj` ou marcar no IDE |
| Build error de NDK | NDK desatualizado | Atualizar NDK via SDK Manager |
| AAB muito grande | Recursos desnecessários incluídos | Verificar itens no Deployment Manager |

## Upload do AAB no Play Console

Após gerar o AAB com sucesso:

1. Acessar `play.google.com/console`
2. Selecionar o app
3. **Release > [Internal testing / Production] > Create new release**
4. Clicar **Upload** → selecionar o arquivo `.aab`
5. Aguardar processamento (1-5 minutos)
6. Preencher release notes → **Save** → **Review release**

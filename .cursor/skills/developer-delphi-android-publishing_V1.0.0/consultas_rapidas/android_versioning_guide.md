# Referência Rápida: Versionamento Android

## Dois Campos de Versão

| Campo .dproj | Manifesto | Uso | Tipo |
|-------------|-----------|-----|------|
| `Android_VersionCode` | `android:versionCode` | Identificador interno — Play Store usa para ordenar versões | Inteiro crescente |
| `Android_VersionName` | `android:versionName` | Exibido ao usuário na Play Store e em Settings | String (ex.: "1.0.0") |

## Regras do VersionCode

1. **Sempre incrementar** — nunca pode ser igual ou menor que o anterior em produção
2. **Nunca reutilizar** — o Play Store rejeita uploads com versionCode já usado
3. **Inteiro positivo** — max. 2.100.000.000

### Estratégias de incremento

**Sequencial simples (recomendado para apps pequenos):**
```
1, 2, 3, 4, 5, ...
```

**Por versão (codifica MAJOR.MINOR.PATCH no número):**
```
# Formato: MMNNPP (major×10000 + minor×100 + patch)
1.0.0  → 10000
1.0.1  → 10001
1.1.0  → 10100
2.0.0  → 20000
```

**Por data e hora (garante unicidade em CI/CD):**
```
# AAAAMMDDhhmm
2026041109 30  → 202604110930
```

## VersionName — Convenção Sugerida

Seguir **SemVer (Semantic Versioning)**: `MAJOR.MINOR.PATCH`

| Tipo de mudança | Incrementar | Exemplo |
|-----------------|------------|---------|
| Breaking change / Feature major | MAJOR | 1.x.x → 2.0.0 |
| Nova feature backward-compatible | MINOR | 1.0.x → 1.1.0 |
| Bug fix | PATCH | 1.0.0 → 1.0.1 |

## No .dproj

```xml
<PropertyGroup Condition="'$(Cfg_2)'!='' and '$(Platform)'=='Android64'">
  <!-- Incrementar SEMPRE antes de cada upload para o Play Store -->
  <Android_VersionCode>10</Android_VersionCode>
  <!-- Atualizar conforme SemVer -->
  <Android_VersionName>1.0.0</Android_VersionName>
</PropertyGroup>
```

## Fluxo de Release com Versionamento

```
1. Codigo pronto para release
2. Incrementar Android_VersionCode no .dproj
3. Atualizar Android_VersionName se houver mudancas relevantes
4. Build Release → gerar AAB
5. Upload no Play Console com as notas "What's new"
6. Commitar o .dproj com os novos valores de versao no git
```

## Verificar versionCode do AAB gerado

```bash
java -jar bundletool.jar dump manifest --bundle=MeuApp.aab | grep -i version
# Saida: android:versionCode="10" android:versionName="1.0.0"
```

## Multi-plataforma: Sincronizar Versões

Para apps iOS + Android, manter versões consistentes:

| Campo iOS (.dproj) | Campo Android (.dproj) | Sincronizar? |
|-------------------|----------------------|--------------|
| `VerInfo_CFBundleVersion` | `Android_VersionCode` | Nao (logicas diferentes) |
| `VerInfo_CFBundleShortVersionString` | `Android_VersionName` | Sim (mesma string para o usuario) |

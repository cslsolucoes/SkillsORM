# .dproj — Configuracao MSIX Completa e Anotada

## Estrutura de PropertyGroups no .dproj

Um arquivo `.dproj` do RAD Studio organiza configuracoes em `<PropertyGroup>` com
condicoes que combinam `$(Platform)` e `$(Cfg_N)`. Para MSIX:

- `$(Platform)` = `Win64` — obrigatorio para MSIX
- `$(Cfg_1)` = Debug
- `$(Cfg_2)` = Release (onde MSIX e ativado)

---

## PropertyGroup 1 — Identidade base Win64

```xml
<!-- Condicao: qualquer configuracao, plataforma Win64 -->
<PropertyGroup Condition="'$(Platform)'=='Win64'">

  <!--
    MSIX_PackageIdentityName
    Identificador unico do pacote. Formato recomendado: Empresa.NomeApp
    - Deve ser identico ao registrado no Partner Center (Microsoft Store)
    - Para sideload: qualquer string valida sem espacos
    - Caracteres validos: letras, numeros, ponto, hifen
  -->
  <MSIX_PackageIdentityName>Empresa.GestorERP</MSIX_PackageIdentityName>

  <!--
    MSIX_PackagePublisher
    DEVE ser identico ao Subject DN do certificado de assinatura.
    Exemplo: se o certificado tem Subject "CN=Empresa LTDA, O=Empresa LTDA, C=BR",
    este campo deve ter exatamente esse valor.
    Qualquer diferenca causa erro na instalacao.
  -->
  <MSIX_PackagePublisher>CN=Empresa LTDA, O=Empresa LTDA, C=BR</MSIX_PackagePublisher>

  <!--
    MSIX_PackageVersion
    CRITICO: formato obrigatorio Major.Minor.Build.REVISION
    Para Microsoft Store: REVISION deve ser SEMPRE 0.
    Exemplos validos: 1.0.0.0 / 1.1.0.0 / 1.0.1.0
    Exemplos INVALIDOS para Store: 1.0.0.1 / 1.0.0.2
    Para sideload: qualquer formato valido funciona.
  -->
  <MSIX_PackageVersion>1.0.0.0</MSIX_PackageVersion>

  <!-- Nome de exibicao na Start Menu e Microsoft Store -->
  <MSIX_PackageDisplayName>GestorERP</MSIX_PackageDisplayName>

  <!-- Descricao exibida na Store e nas informacoes do pacote -->
  <MSIX_PackageDescription>Sistema de gestao empresarial para pequenas e medias empresas</MSIX_PackageDescription>

  <!-- Arquitetura: x64 para Win64. Tambem pode ser x86, arm64. -->
  <MSIX_PackageArchitecture>x64</MSIX_PackageArchitecture>

  <!-- Icone da Store: 50x50 px, PNG, fundo transparente -->
  <MSIX_PackageLogo>Assets\StoreLogo.png</MSIX_PackageLogo>

  <!-- Nome de exibicao do publisher (aparece na Store) -->
  <MSIX_PublisherDisplayName>Empresa LTDA</MSIX_PublisherDisplayName>

</PropertyGroup>
```

---

## PropertyGroup 2 — Release Win64 com MSIX ativo

```xml
<!-- Condicao: configuracao Release (Cfg_2) + plataforma Win64 -->
<PropertyGroup Condition="'$(Cfg_2)'!='' and '$(Platform)'=='Win64'">

  <!--
    MSIX_Packaging = true
    Ativa a geracao do .msix durante o build.
    O RAD Studio chama o MakeAppx.exe automaticamente apos o link.
  -->
  <MSIX_Packaging>true</MSIX_Packaging>

  <!-- Otimizacoes de Release -->
  <DCC_Optimize>true</DCC_Optimize>
  <DCC_DebugInformation>0</DCC_DebugInformation>
  <DCC_LocalSymbols>false</DCC_LocalSymbols>
  <DCC_SymbolReferenceInfo>0</DCC_SymbolReferenceInfo>

  <!--
    DCC_ImageBase
    Base address para o executavel. Padrao Delphi: $00400000.
    Para apps 64-bit, nao e necessario ajustar.
  -->
  <DCC_ImageBase>00400000</DCC_ImageBase>

  <!--
    MSIX_OutputDir
    Pasta onde o .msix sera gerado. Relativa ao diretorio do projeto.
    Se omitida, usa a pasta de saida padrao do build.
  -->
  <MSIX_OutputDir>dist</MSIX_OutputDir>

  <!--
    MSIX_AppxManifestFile
    Caminho para o AppxManifest.xml customizado.
    Se omitido, o RAD Studio gera um manifest automatico (menos customizavel).
    Recomendado: sempre fornecer um manifest proprio para producao.
  -->
  <MSIX_AppxManifestFile>AppxManifest.xml</MSIX_AppxManifestFile>

</PropertyGroup>
```

---

## PropertyGroup 3 — Debug Win64 (MSIX desativado)

```xml
<!-- Debug: MSIX_Packaging false para builds de desenvolvimento -->
<PropertyGroup Condition="'$(Cfg_1)'!='' and '$(Platform)'=='Win64'">
  <MSIX_Packaging>false</MSIX_Packaging>
  <DCC_Optimize>false</DCC_Optimize>
  <DCC_DebugInformation>2</DCC_DebugInformation>
  <DCC_LocalSymbols>true</DCC_LocalSymbols>
</PropertyGroup>
```

---

## Incrementar versao entre builds

O quarto componente deve ser sempre 0. Para incrementar:

| Tipo de mudanca | Versao anterior | Nova versao |
|-----------------|-----------------|-------------|
| Patch/bugfix | `1.0.0.0` | `1.0.1.0` |
| Feature (minor) | `1.0.1.0` | `1.1.0.0` |
| Breaking (major) | `1.1.0.0` | `2.0.0.0` |
| ERRADO (Store) | `1.0.0.0` | `1.0.0.1` |

Script PowerShell para auto-incrementar patch no .dproj:

```powershell
# Incrementa o terceiro componente da versao MSIX no .dproj
$dproj = "GestorERP.dproj"
$content = Get-Content $dproj -Raw

$content = $content -replace `
  '<MSIX_PackageVersion>(\d+)\.(\d+)\.(\d+)\.0</MSIX_PackageVersion>', `
  { param($m) "<MSIX_PackageVersion>$($m.Groups[1].Value).$($m.Groups[2].Value).$([int]$m.Groups[3].Value + 1).0</MSIX_PackageVersion>" }

Set-Content $dproj $content -Encoding UTF8
Write-Host "Versao incrementada no .dproj"
```

---

## Verificar PropertyGroups existentes

```powershell
# Mostrar todas as propriedades MSIX do .dproj
[xml]$dproj = Get-Content "GestorERP.dproj"
$dproj.Project.PropertyGroup | ForEach-Object {
    if ($_.MSIX_PackageVersion -or $_.MSIX_Packaging) {
        Write-Host "Condition: $($_.Condition)"
        Write-Host "  MSIX_PackageVersion : $($_.MSIX_PackageVersion)"
        Write-Host "  MSIX_Packaging      : $($_.MSIX_Packaging)"
        Write-Host ""
    }
}
```

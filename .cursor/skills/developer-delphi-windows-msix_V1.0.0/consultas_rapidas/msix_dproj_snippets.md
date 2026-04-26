# Propriedades MSBuild MSIX no .dproj — Referencia Completa

## Tabela de propriedades

| Propriedade | Tipo | Descricao | Exemplo |
|------------|------|-----------|---------|
| `MSIX_Packaging` | bool | Ativa geracao do .msix no build | `true` |
| `MSIX_PackageIdentityName` | string | Identificador unico do pacote (sem espacos) | `Empresa.GestorERP` |
| `MSIX_PackagePublisher` | string | Subject DN do certificado (deve coincidir exatamente) | `CN=Empresa LTDA, O=Empresa LTDA, C=BR` |
| `MSIX_PackageVersion` | string | Versao no formato `M.m.b.0` (4o componente sempre 0) | `1.0.0.0` |
| `MSIX_PackageDisplayName` | string | Nome exibido na Start Menu e Store | `GestorERP` |
| `MSIX_PackageDescription` | string | Descricao do app na Store | `Sistema de gestao empresarial` |
| `MSIX_PackageArchitecture` | enum | Arquitetura alvo: `x86`, `x64`, `arm64` | `x64` |
| `MSIX_PackageLogo` | path | Caminho relativo para o StoreLogo (50x50 PNG) | `Assets\StoreLogo.png` |
| `MSIX_PublisherDisplayName` | string | Nome do publisher exibido ao usuario | `Empresa LTDA` |
| `MSIX_AppxManifestFile` | path | Caminho para AppxManifest.xml customizado | `AppxManifest.xml` |
| `MSIX_OutputDir` | path | Pasta de saida do arquivo .msix gerado | `dist` |
| `MSIX_SigningEnabled` | bool | Habilita assinatura automatica pelo IDE (nao recomendado; usar signtool externo) | `false` |
| `MSIX_CertificateThumbprint` | string | Thumbprint do cert para assinatura automatica pelo IDE | `A1B2C3...` |
| `MSIX_PackageName` | string | Alias de `MSIX_PackageIdentityName` em versoes mais antigas do RAD Studio | `Empresa.GestorERP` |

---

## Condicoes MSBuild — referencia

| Condicao | Configuracao | Plataforma |
|----------|-------------|------------|
| `'$(Platform)'=='Win64'` | Qualquer | Win64 |
| `'$(Platform)'=='Win32'` | Qualquer | Win32 |
| `'$(Cfg_1)'!=''` | Debug | Qualquer |
| `'$(Cfg_2)'!=''` | Release | Qualquer |
| `'$(Cfg_2)'!='' and '$(Platform)'=='Win64'` | Release | Win64 |

---

## Exemplo completo minimo para MSIX funcional

```xml
<PropertyGroup Condition="'$(Platform)'=='Win64'">
  <MSIX_PackageIdentityName>Empresa.GestorERP</MSIX_PackageIdentityName>
  <MSIX_PackagePublisher>CN=Empresa LTDA, O=Empresa LTDA, C=BR</MSIX_PackagePublisher>
  <MSIX_PackageVersion>1.0.0.0</MSIX_PackageVersion>
  <MSIX_PackageDisplayName>GestorERP</MSIX_PackageDisplayName>
  <MSIX_PackageDescription>Sistema de gestao empresarial</MSIX_PackageDescription>
  <MSIX_PackageArchitecture>x64</MSIX_PackageArchitecture>
  <MSIX_PackageLogo>Assets\StoreLogo.png</MSIX_PackageLogo>
  <MSIX_PublisherDisplayName>Empresa LTDA</MSIX_PublisherDisplayName>
</PropertyGroup>

<PropertyGroup Condition="'$(Cfg_2)'!='' and '$(Platform)'=='Win64'">
  <MSIX_Packaging>true</MSIX_Packaging>
  <MSIX_AppxManifestFile>AppxManifest.xml</MSIX_AppxManifestFile>
  <MSIX_OutputDir>dist</MSIX_OutputDir>
</PropertyGroup>
```

---

## Script: incrementar versao automaticamente

```powershell
param([string]$DprojPath = "GestorERP.dproj", [string]$Component = "Build")

[xml]$dproj = Get-Content $DprojPath

foreach ($pg in $dproj.Project.PropertyGroup) {
    if ($pg.MSIX_PackageVersion) {
        $parts = $pg.MSIX_PackageVersion.Split('.')
        switch ($Component) {
            "Major" { $parts[0] = [string]([int]$parts[0] + 1); $parts[1]=$parts[2]="0" }
            "Minor" { $parts[1] = [string]([int]$parts[1] + 1); $parts[2]="0" }
            "Build" { $parts[2] = [string]([int]$parts[2] + 1) }
        }
        $parts[3] = "0"  # Sempre 0 para Store
        $newVersion = $parts -join "."
        $pg.MSIX_PackageVersion = $newVersion
        Write-Host "Versao atualizada: $newVersion"
    }
}

$dproj.Save($DprojPath)
```

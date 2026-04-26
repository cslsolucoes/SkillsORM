# AppxManifest.xml — Walkthrough Elemento por Elemento

## Declaracao XML e namespaces

```xml
<?xml version="1.0" encoding="utf-8"?>
<Package
  xmlns="http://schemas.microsoft.com/appx/manifest/foundation/windows10"
  xmlns:uap="http://schemas.microsoft.com/appx/manifest/uap/windows10"
  xmlns:rescap="http://schemas.microsoft.com/appx/manifest/foundation/windows10/restrictedcapabilities"
  IgnorableNamespaces="uap rescap">
```

| Namespace | Prefixo | Uso |
|-----------|---------|-----|
| foundation/windows10 | (default) | Elementos base: Identity, Properties, Dependencies, Capabilities |
| uap/windows10 | `uap:` | VisualElements, DefaultTile, SplashScreen, Protocol, FileTypeAssociation |
| restrictedcapabilities | `rescap:` | `runFullTrust` e outras capabilities restritas |

`IgnorableNamespaces`: lista os prefixos que o sistema pode ignorar em versoes antigas do Windows que nao os conhecem. Sempre incluir `uap rescap` aqui.

---

## Elemento: Identity

```xml
<Identity
  Name="Empresa.GestorERP"
  Publisher="CN=Empresa LTDA, O=Empresa LTDA, C=BR"
  Version="1.0.0.0"
  ProcessorArchitecture="x64"/>
```

| Atributo | Descricao | Regras |
|----------|-----------|--------|
| `Name` | Identificador unico do pacote | Sem espacos; deve coincidir com Partner Center |
| `Publisher` | Subject DN do certificado de assinatura | Deve ser IDENTICO ao certificado; diferenca = erro |
| `Version` | Versao no formato `M.m.b.0` | Quarto componente sempre 0 para Store |
| `ProcessorArchitecture` | `x86`, `x64` ou `arm64` | Deve coincidir com o build Delphi |

---

## Elemento: Properties

```xml
<Properties>
  <!-- Nome de exibicao (pode usar resource string: ms-resource:AppDisplayName) -->
  <DisplayName>GestorERP</DisplayName>

  <!-- Nome do publisher exibido ao usuario -->
  <PublisherDisplayName>Empresa LTDA</PublisherDisplayName>

  <!-- Icone da Store: 50x50 PNG -->
  <Logo>Assets\StoreLogo.png</Logo>

  <!-- Opcional: impede que o app apareça na busca de arquivos -->
  <!-- <uap:SupportedUsers>single</uap:SupportedUsers> -->
</Properties>
```

---

## Elemento: Dependencies

```xml
<Dependencies>
  <!--
    TargetDeviceFamily define os versoes minima e maxima testada do Windows.
    Name="Windows.Desktop": app para desktop (nao IoT, nao Xbox, nao HoloLens).
    MinVersion: build minimo necessario.
    MaxVersionTested: build mais alto testado pelo desenvolvedor.
  -->
  <TargetDeviceFamily
    Name="Windows.Desktop"
    MinVersion="10.0.17763.0"
    MaxVersionTested="10.0.26100.0"/>
  <!--
    Versoes de referencia:
      10.0.17763.0 = Windows 10 1809 (Outubro 2018) — minimo para MSIX pleno
      10.0.19041.0 = Windows 10 2004 (Maio 2020)
      10.0.22000.0 = Windows 11 21H2
      10.0.22621.0 = Windows 11 22H2
      10.0.26100.0 = Windows 11 24H2
  -->
</Dependencies>
```

---

## Elemento: Resources

```xml
<Resources>
  <!-- Idioma principal do app -->
  <Resource Language="pt-BR"/>
  <!-- Idioma secundario (fallback) -->
  <Resource Language="en-US"/>
  <!--
    Se o app suportar multiplos DPIs, adicionar:
    <Resource uap:Scale="100"/>
    <Resource uap:Scale="125"/>
    <Resource uap:Scale="150"/>
    <Resource uap:Scale="200"/>
  -->
</Resources>
```

---

## Elemento: Capabilities

```xml
<Capabilities>
  <!-- internetClient: acesso de saida a internet (mais comum) -->
  <Capability Name="internetClient"/>

  <!-- internetClientServer: servidor + cliente (para apps que ouvem conexoes) -->
  <!-- <Capability Name="internetClientServer"/> -->

  <!-- privateNetworkClientServer: rede local/intranet -->
  <!-- <Capability Name="privateNetworkClientServer"/> -->

  <!--
    runFullTrust: OBRIGATORIO para apps Win32 classicos (Delphi, FPC, C++ nativo).
    Permite acesso irrestrito ao sistema de arquivos, registry, processos, etc.
    Requer declaracao explicita como restricted capability.
    Na Microsoft Store: requer justificativa no processo de submissao.
  -->
  <rescap:Capability Name="runFullTrust"/>
</Capabilities>
```

---

## Elemento: Applications

```xml
<Applications>
  <Application
    Id="App"
    Executable="GestorERP.exe"
    EntryPoint="Windows.FullTrustApplication">
    <!--
      Id: identificador unico dentro do pacote (pode ter varios Apps por pacote).
      Executable: caminho do .exe relativo a raiz do pacote.
      EntryPoint: "Windows.FullTrustApplication" obrigatorio para Win32 com runFullTrust.
    -->

    <uap:VisualElements
      DisplayName="GestorERP"
      Description="Sistema de gestao empresarial"
      BackgroundColor="transparent"
      Square150x150Logo="Assets\Square150x150Logo.png"
      Square44x44Logo="Assets\Square44x44Logo.png">
      <!--
        BackgroundColor: "transparent" ou cor hex (#0078D7).
        Square150x150Logo: icone 150x150 (lista de apps, Start Menu).
        Square44x44Logo: icone 44x44 (barra de tarefas, lista pequena).
      -->

      <uap:DefaultTile Wide310x150Logo="Assets\Wide310x150Logo.png"/>
      <!--
        Wide310x150Logo: tile largo na Start Menu (opcional mas recomendado).
        Pode adicionar: LargeTile 310x310 com Square310x310Logo.
      -->

      <uap:SplashScreen Image="Assets\SplashScreen.png"/>
      <!--
        SplashScreen: tela de carregamento do app. 620x300 PNG.
        Exibida enquanto o processo inicializa.
      -->
    </uap:VisualElements>
  </Application>
</Applications>
```

---

## Extensoes opcionais (dentro de Application ou Package)

### Associacao de tipos de arquivo

```xml
<Extensions>
  <uap:Extension Category="windows.fileTypeAssociation">
    <uap:FileTypeAssociation Name="gestorerpfile">
      <uap:SupportedFileTypes>
        <uap:FileType>.gerp</uap:FileType>
      </uap:SupportedFileTypes>
    </uap:FileTypeAssociation>
  </uap:Extension>
</Extensions>
```

### Protocolo URI customizado

```xml
<Extensions>
  <uap:Extension Category="windows.protocol">
    <uap:Protocol Name="gestorerpapp">
      <uap:DisplayName>GestorERP Protocol</uap:DisplayName>
    </uap:Protocol>
  </uap:Extension>
</Extensions>
```

### Startup task (executar ao login)

```xml
<Extensions>
  <uap:Extension Category="windows.startupTask">
    <uap:StartupTask
      TaskId="GestorERPStartup"
      Enabled="true"
      DisplayName="GestorERP Startup"/>
  </uap:Extension>
</Extensions>
```

---

## Validar o AppxManifest.xml

```powershell
# Validar manifest sem empacotar (requer Windows SDK)
$makeappx = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\makeappx.exe"
& $makeappx pack /d ".\msix_staging" /p ".\dist\test.msix" /v

# Inspecionar manifest dentro de um MSIX existente
Expand-Archive "GestorERP_1.0.0.0_x64.msix" -DestinationPath ".\msix_inspect"
Get-Content ".\msix_inspect\AppxManifest.xml"
```

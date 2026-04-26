# Configuração `.dproj` para Library Multi-plataforma

## Estrutura Mínima

```xml
<?xml version="1.0" encoding="utf-8"?>
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <ProjectGuid>{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}</ProjectGuid>
    <ProjectVersion>19.4</ProjectVersion>
    <FrameworkType>None</FrameworkType>

    <!-- OBRIGATÓRIO: indica que é uma DLL, não um .exe -->
    <DCC_ProjectType>Library</DCC_ProjectType>

    <!-- Nome sem extensão — RAD Studio adiciona .dll ou .so conforme plataforma -->
    <!-- Não especificar aqui; controlado por DCC_ExeOutput -->
  </PropertyGroup>
```

## PropertyGroups por Plataforma

```xml
  <!-- ===== BASE (todos os targets) ===== -->
  <PropertyGroup>
    <DCC_Namespace>System;Winapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Bde;$(DCC_Namespace)</DCC_Namespace>

    <!-- Desactivar runtime packages — DLL standalone não deve depender de BPLs -->
    <DCC_UsePackage></DCC_UsePackage>

    <!-- Não gerar .dcu separado para cada unit — gerar directo no output -->
    <DCC_BplOutput>.\bpl\</DCC_BplOutput>
    <DCC_DcpOutput>.\dcp\</DCC_DcpOutput>
  </PropertyGroup>

  <!-- ===== Win32 ===== -->
  <PropertyGroup Condition="'$(Platform)'=='Win32'">
    <!-- Output da DLL -->
    <DCC_ExeOutput>.\bin\win32\</DCC_ExeOutput>
    <!-- Output dos .dcu intermediários -->
    <DCC_DcuOutput>.\dcu\win32\</DCC_DcuOutput>
    <!-- Defines específicos da plataforma -->
    <DCC_Define>WIN32_TARGET;$(DCC_Define)</DCC_Define>
    <!-- Gerar .map para debug em produção (opcional) -->
    <DCC_MapFile>3</DCC_MapFile>
  </PropertyGroup>

  <!-- ===== Win64 ===== -->
  <PropertyGroup Condition="'$(Platform)'=='Win64'">
    <DCC_ExeOutput>.\bin\win64\</DCC_ExeOutput>
    <DCC_DcuOutput>.\dcu\win64\</DCC_DcuOutput>
    <DCC_Define>WIN64_TARGET;$(DCC_Define)</DCC_Define>
    <DCC_MapFile>3</DCC_MapFile>
  </PropertyGroup>

  <!-- ===== Linux64 (requer PAServer + compilador cross-platform) ===== -->
  <PropertyGroup Condition="'$(Platform)'=='Linux64'">
    <DCC_ExeOutput>.\bin\linux64\</DCC_ExeOutput>
    <DCC_DcuOutput>.\dcu\linux64\</DCC_DcuOutput>
    <DCC_Define>LINUX64_TARGET;$(DCC_Define)</DCC_Define>
    <!-- Em Linux, o nome do ficheiro gerado será libNomeProjeto.so -->
  </PropertyGroup>

  <!-- ===== Configuração Debug ===== -->
  <PropertyGroup Condition="'$(Cfg_1)'!='' and '$(Platform)'!=''"
                 Condition2="'$(Config)'=='Debug'">
    <DCC_Define>DEBUG;$(DCC_Define)</DCC_Define>
    <DCC_Optimize>false</DCC_Optimize>
    <DCC_GenerateStackFrames>true</DCC_GenerateStackFrames>
    <DCC_DebugInformation>2</DCC_DebugInformation>  <!-- Full debug info -->
    <DCC_RemoteDebug>true</DCC_RemoteDebug>
  </PropertyGroup>

  <!-- ===== Configuração Release ===== -->
  <PropertyGroup Condition="'$(Cfg_2)'!='' and '$(Platform)'!=''"
                 Condition2="'$(Config)'=='Release'">
    <DCC_Define>RELEASE;$(DCC_Define)</DCC_Define>
    <DCC_Optimize>true</DCC_Optimize>
    <DCC_GenerateStackFrames>false</DCC_GenerateStackFrames>
    <DCC_DebugInformation>0</DCC_DebugInformation>
    <DCC_LocalDebugSymbols>false</DCC_LocalDebugSymbols>
  </PropertyGroup>
```

## Nomenclatura de Output

| Plataforma | Output RAD Studio 12 |
|-----------|---------------------|
| Win32 | `.\bin\win32\NomeProjeto.dll` |
| Win64 | `.\bin\win64\NomeProjeto.dll` |
| Linux64 | `.\bin\linux64\libNomeProjeto.so` |

**Nota:** RAD Studio adiciona o prefixo `lib` e a extensão `.so` automaticamente para Linux64. Não especificar no `.dproj`.

## Search Paths

```xml
  <PropertyGroup>
    <!-- Paths de busca de units — separar com ; -->
    <DCC_UnitSearchPath>
      ..\shared;
      ..\interfaces;
      $(DCC_UnitSearchPath)
    </DCC_UnitSearchPath>

    <!-- Include paths para ficheiros .inc -->
    <DCC_IncludePath>
      ..\includes;
      $(DCC_IncludePath)
    </DCC_IncludePath>
  </PropertyGroup>
```

## Desactivar Runtime Packages (crítico para DLLs standalone)

```xml
  <PropertyGroup>
    <!-- Runtime packages OFF — a DLL linka tudo estaticamente -->
    <!-- Se on, a DLL dependeria de BPLs no cliente -->
    <UsePackages>false</UsePackages>

    <!-- Ou especificamente: -->
    <DCC_UsePackage></DCC_UsePackage>
  </PropertyGroup>
```

## Manifesto e Recursos

```xml
  <PropertyGroup>
    <!-- Ficheiro de recursos (ícone, manifesto, versão) -->
    <DCC_Resource>$(PROJECTDIR)\NomeProjeto.res</DCC_Resource>
  </PropertyGroup>
```

## Exemplo Completo Mínimo Funcional

```xml
<?xml version="1.0" encoding="utf-8"?>
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <ProjectGuid>{11111111-2222-3333-4444-555555555555}</ProjectGuid>
    <ProjectVersion>19.4</ProjectVersion>
    <FrameworkType>None</FrameworkType>
    <AppType>Library</AppType>
    <DCC_ProjectType>Library</DCC_ProjectType>
    <MainSource>MinhaDLL.dpr</MainSource>
    <Base>true</Base>
  </PropertyGroup>

  <!-- Win32 -->
  <PropertyGroup Condition="'$(Platform)'=='Win32'">
    <DCC_ExeOutput>.\bin\win32\</DCC_ExeOutput>
    <DCC_DcuOutput>.\dcu\win32\</DCC_DcuOutput>
  </PropertyGroup>

  <!-- Win64 -->
  <PropertyGroup Condition="'$(Platform)'=='Win64'">
    <DCC_ExeOutput>.\bin\win64\</DCC_ExeOutput>
    <DCC_DcuOutput>.\dcu\win64\</DCC_DcuOutput>
  </PropertyGroup>

  <!-- Linux64 -->
  <PropertyGroup Condition="'$(Platform)'=='Linux64'">
    <DCC_ExeOutput>.\bin\linux64\</DCC_ExeOutput>
    <DCC_DcuOutput>.\dcu\linux64\</DCC_DcuOutput>
  </PropertyGroup>

  <!-- Compilar via CLI (dcc32/dcc64) -->
  <!-- dcc32 MinhaDLL.dpr -E.\bin\win32\ -N.\dcu\win32\ -->
  <!-- dcc64 MinhaDLL.dpr -E.\bin\win64\ -N.\dcu\win64\ -->

  <ItemGroup>
    <DCCReference Include="uMinhaDLLImpl.pas"/>
    <DCCReference Include="..\shared\PluginInterfaces.pas"/>
  </ItemGroup>

  <Import Project="$(BDS)\Bin\CodeGear.Delphi.Targets"
          Condition="Exists('$(BDS)\Bin\CodeGear.Delphi.Targets')"/>
</Project>
```

## Compilação CLI

```powershell
# Win32
dcc32 MinhaDLL.dpr -E.\bin\win32\ -N.\dcu\win32\

# Win64
dcc64 MinhaDLL.dpr -E.\bin\win64\ -N.\dcu\win64\

# FPC Linux64 (cross-compile a partir do Windows)
D:\fpc\fpc\bin\x86_64-win64\fpc.exe `
    -Tlinux -Px86_64 `
    -o.\bin\linux64\libMinhaDLL.so `
    MinhaDLL.lpr
```

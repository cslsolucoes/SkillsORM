# Deployment Manager — Guia para MSIX

## O que e o Deployment Manager

O **Deployment Manager** (Project > Deployment) e a ferramenta do RAD Studio que
define quais arquivos serao incluidos no pacote final (MSIX, instalador, etc.).
Para MSIX, e CRITICO: o pacote e autocontido — todas as dependencias devem
estar dentro do MSIX. Nao ha instalacao de runtime separada.

---

## Como acessar

1. Menu **Project > Deployment**
2. Na barra do Deployment Manager, selecionar:
   - **Platform:** Win64
   - **Configuration:** Release
3. A lista exibe todos os arquivos configurados para deploy

---

## Arquivos a incluir por categoria

### RTL e BPLs do Delphi (se usar dynamic linking)

| Arquivo | Localizacao padrao | Quando incluir |
|---------|--------------------|----------------|
| `rtl.bpl` | `C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\` | Sempre (se dynamic) |
| `borlndmm.dll` | Mesma pasta | Sempre (se dynamic) |
| `cc32260.dll` | Mesma pasta | Sempre (se dynamic, Win32) |
| `cc64260.dll` | Mesma pasta | Sempre (se dynamic, Win64) |

> **Alternativa: Static Linking**
> Habilitar em Project > Options > Delphi Compiler > Linking > `Link with runtime packages: false`
> Com static linking, os BPLs sao incorporados no .exe e nao precisam ser distribuidos.
> Aumenta o tamanho do .exe mas elimina dependencias de BPL.

### VCL (se usar framework VCL)

| Arquivo | Quando incluir |
|---------|----------------|
| `vcl.bpl` | Apps VCL sempre |
| `vclx.bpl` | Se usar controles VCL estendidos |
| `vclactnband.bpl` | Se usar ActionBand/ToolBar |
| `vclie.bpl` | Se usar TWebBrowser |
| `vclimg.bpl` | Se usar TPngImage, TGifImage, etc. |
| `bdertl.bpl` | Se usar BDE (legado, nao recomendado) |

### FMX (se usar FireMonkey)

| Arquivo | Quando incluir |
|---------|----------------|
| `fmx.bpl` | Sempre para apps FMX |
| `fmxobj.bpl` | Sempre para apps FMX |
| `fmxdae.bpl` | Se usar efeitos DAE |
| `fmx.Editor.bpl` | Se usar editores (apenas em modo dev) |

### FireDAC (acesso a banco de dados)

| Arquivo | Quando incluir |
|---------|----------------|
| `FireDAC.bpl` | Core FireDAC |
| `FireDACCommon.bpl` | Componentes comuns |
| `FireDACCommonDriver.bpl` | Driver base |
| `FireDACSQLiteDriver.bpl` | Driver SQLite |
| `FireDACMSSQLDriver.bpl` | Driver SQL Server |
| `FireDACMySQLDriver.bpl` | Driver MySQL |
| `FireDACPgDriver.bpl` | Driver PostgreSQL |
| `sqlite3.dll` | DLL nativa do SQLite |
| `midas.dll` | Se usar TClientDataSet/DataSnap |

### Visual C++ Redistributable

Necessario se o app usa DLLs que dependem do VC++ Runtime:

| Arquivo | Versao VC++ |
|---------|-------------|
| `vcruntime140.dll` | VC++ 2015-2022 |
| `msvcp140.dll` | VC++ 2015-2022 |
| `concrt140.dll` | VC++ 2015-2022 (Concurrency Runtime) |

Localizar em: `C:\Windows\System32\` ou nos pacotes redistributaveis do Visual Studio.

---

## Como adicionar arquivos ao Deployment Manager

### Via IDE

1. Abrir Project > Deployment
2. Clicar no botao **"Add Files"** (icone de pasta)
3. Selecionar os arquivos DLL/BPL desejados
4. Configurar o **Remote Path** (subpasta dentro do MSIX)
5. Verificar que o checkbox **"Include in MSIX"** esta marcado

### Via .dproj (manual)

```xml
<!-- Arquivo individual no Deployment Manager -->
<DeployFile LocalName="..\..\Windows\SysWOW64\sqlite3.dll"
            Configuration="Release"
            Class="Dependencies">
  <Platform Name="Win64">
    <RemoteDir>.\</RemoteDir>
    <RemoteName>sqlite3.dll</RemoteName>
    <Overwrite>true</Overwrite>
    <Enabled>1</Enabled>
  </Platform>
</DeployFile>
```

---

## Estrutura de pastas dentro do MSIX

O MSIX e descomprimido em uma pasta virtualizada. A estrutura recomendada:

```
GestorERP.exe              ← executavel principal (raiz)
Assets\                    ← icones e splash screen
  StoreLogo.png
  Square44x44Logo.png
  Square150x150Logo.png
  Wide310x150Logo.png
  SplashScreen.png
AppxManifest.xml           ← gerado automaticamente pelo RAD Studio
rtl.bpl                    ← BPLs (se dynamic linking)
vcl.bpl
FireDAC.bpl
sqlite3.dll                ← DLLs nativas
config\                    ← configuracoes do app (opcional)
  app.ini
templates\                 ← recursos adicionais (opcional)
```

---

## Verificar dependencias ausentes

### Usando Dependency Walker ou Dependencies

```powershell
# Instalar Dependencies (substituto moderno do Dependency Walker)
# https://github.com/lucasg/Dependencies

# Ou usar dumpbin do Visual Studio
dumpbin /dependents "GestorERP.exe"
```

### Script para listar DLLs usadas

```powershell
# Listar todas as DLLs importadas pelo executavel
$exe = ".\Win64\Release\GestorERP.exe"
$peBytes = [IO.File]::ReadAllBytes($exe)

# Alternativa: usar Get-Item com MUI
Write-Host "Use Dependency Walker ou dumpbin /dependents para analise completa."
Write-Host "Dumpbin (Visual Studio): dumpbin /dependents $exe"
```

---

## Teste de completude: VM limpa

**Fluxo recomendado antes de submeter a Store:**

1. Criar VM Windows 11 limpa (snapshot)
2. Instalar apenas o certificado de teste
3. Instalar o MSIX via sideload
4. Executar todas as funcionalidades do app
5. Se houver erro de DLL: adicionar ao Deployment Manager e repetir
6. Executar WACK na VM limpa
7. Reverter snapshot para proxima iteracao

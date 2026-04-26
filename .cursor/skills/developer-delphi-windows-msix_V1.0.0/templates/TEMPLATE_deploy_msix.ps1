#Requires -Version 5.1
<#
.SYNOPSIS
    Pipeline completo: build Delphi Win64 → assinar MSIX → sideload → verificar.

.DESCRIPTION
    Template de pipeline local ou CI/CD para:
      1. Compilar o projeto Delphi com dcc64
      2. Verificar que o MSIX foi gerado
      3. Assinar o MSIX com signtool (usando PFX ou secret do ambiente)
      4. Fazer sideload do MSIX (Add-AppxPackage)
      5. Verificar a instalacao
      6. (Opcional) Executar verificacao de assinatura

    COMO USAR:
      - Local: passar -PfxPath e -PfxPassword diretamente (apenas para dev/testes)
      - CI/CD: configurar PFX_BASE64 e PFX_PASSWORD como secrets; script le automaticamente

    PRE-REQUISITOS:
      - dcc64.exe no PATH (ou configurar DCC64Path)
      - Windows SDK com signtool.exe
      - Certificado .cer instalado no Trusted Root da maquina de teste

.PARAMETER ProjectFile
    Caminho para o arquivo .dpr do projeto Delphi.
    Ex.: GestorERP.dpr

.PARAMETER DprojFile
    Caminho para o arquivo .dproj (opcional; para extrair versao automaticamente).

.PARAMETER OutputDir
    Pasta onde o .msix sera gerado (deve coincidir com MSIX_OutputDir no .dproj).
    Padrao: .\dist

.PARAMETER PackageName
    Nome do pacote (campo Name do Identity no AppxManifest).
    Ex.: Empresa.GestorERP

.PARAMETER PfxPath
    Caminho para o .pfx. Opcional se PFX_BASE64 estiver no ambiente.

.PARAMETER PfxPassword
    Senha do .pfx. Opcional se PFX_PASSWORD estiver no ambiente.

.PARAMETER TimestampServer
    URL do servidor de timestamp. Padrao: http://timestamp.digicert.com

.PARAMETER SkipBuild
    Pula a compilacao (apenas empacotar/assinar/instalar).

.PARAMETER SkipSideload
    Pula a instalacao via sideload.

.PARAMETER DCC64Path
    Caminho do dcc64.exe se nao estiver no PATH.

.EXAMPLE
    # Pipeline completo local (desenvolvimento)
    .\TEMPLATE_deploy_msix.ps1 `
      -ProjectFile "GestorERP.dpr" `
      -PackageName "Empresa.GestorERP" `
      -PfxPath ".\certs\dev.pfx" `
      -PfxPassword "Senha@Dev2026"

.EXAMPLE
    # CI/CD (secrets via ambiente)
    $env:PFX_BASE64 = "base64_do_pfx..."
    $env:PFX_PASSWORD = "senha_do_pfx"
    .\TEMPLATE_deploy_msix.ps1 `
      -ProjectFile "GestorERP.dpr" `
      -PackageName "Empresa.GestorERP" `
      -SkipSideload   # Em CI: apenas build e sign, sem instalar

.NOTES
    Skill: developer-delphi-windows-msix_V1.0.0
    Dependencia: developer-delphi-windows-codesigning_V1.0.0
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$ProjectFile,

    [Parameter(Mandatory = $false)]
    [string]$DprojFile = "",

    [Parameter(Mandatory = $false)]
    [string]$OutputDir = ".\dist",

    [Parameter(Mandatory = $true)]
    [string]$PackageName,

    [Parameter(Mandatory = $false)]
    [string]$PfxPath = "",

    [Parameter(Mandatory = $false)]
    [string]$PfxPassword = "",

    [Parameter(Mandatory = $false)]
    [string]$TimestampServer = "http://timestamp.digicert.com",

    [Parameter(Mandatory = $false)]
    [switch]$SkipBuild,

    [Parameter(Mandatory = $false)]
    [switch]$SkipSideload,

    [Parameter(Mandatory = $false)]
    [string]$DCC64Path = "dcc64.exe"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$TIMESTAMP_FALLBACKS = @(
    $TimestampServer,
    "http://timestamp.digicert.com",
    "http://timestamp.sectigo.com",
    "http://timestamp.entrust.net/TSS/RFC3161sha2TS"
) | Select-Object -Unique

# ─── Funcoes ─────────────────────────────────────────────────────────────────

function Write-Step { param([string]$N, [string]$Msg)
    Write-Host "" ; Write-Host "[$N] $Msg" -ForegroundColor Cyan }
function Write-Ok   { param([string]$Msg) Write-Host "    OK: $Msg" -ForegroundColor Green }
function Write-Fail { param([string]$Msg) Write-Host "    ERRO: $Msg" -ForegroundColor Red ; exit 1 }

function Get-Signtool {
    $found = Get-ChildItem "C:\Program Files (x86)\Windows Kits\10\bin\*\x64\signtool.exe" `
        -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending |
        Select-Object -First 1 -ExpandProperty FullName
    if (-not $found) { Write-Fail "signtool.exe nao encontrado. Instale o Windows SDK." }
    return $found
}

function Get-PfxFromEnv {
    # Reconstituir PFX a partir da variavel de ambiente PFX_BASE64
    if (-not $env:PFX_BASE64) { return $null }
    $tmpPfx = Join-Path $env:TEMP "ci_signing_$([IO.Path]::GetRandomFileName()).pfx"
    $bytes = [Convert]::FromBase64String($env:PFX_BASE64)
    [IO.File]::WriteAllBytes($tmpPfx, $bytes)
    return $tmpPfx
}

function Get-MsixFile {
    param([string]$Dir)
    $msix = Get-ChildItem $Dir -Filter "*.msix" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if (-not $msix) { Write-Fail "Nenhum .msix encontrado em '$Dir'. Verificar build e MSIX_OutputDir." }
    return $msix.FullName
}

# ─── PASSO 1: Build com dcc64 ─────────────────────────────────────────────────

if (-not $SkipBuild) {
    Write-Step "1/5" "Compilando $ProjectFile com dcc64..."

    $dcc64 = $DCC64Path
    if (-not (Get-Command $dcc64 -ErrorAction SilentlyContinue)) {
        # Tentar localizar no PATH do RAD Studio
        $rsBase = "C:\Program Files (x86)\Embarcadero\Studio"
        $dcc64 = Get-ChildItem "$rsBase\*\bin\dcc64.exe" -ErrorAction SilentlyContinue |
            Sort-Object FullName -Descending |
            Select-Object -First 1 -ExpandProperty FullName
        if (-not $dcc64) { Write-Fail "dcc64.exe nao encontrado. Adicione ao PATH ou passe -DCC64Path." }
    }

    Write-Host "    dcc64: $dcc64"

    # Usar .cfg se existir
    $cfg = [IO.Path]::ChangeExtension($ProjectFile, ".cfg")
    if (Test-Path $cfg) {
        & $dcc64 "@$cfg" $ProjectFile
    } else {
        & $dcc64 $ProjectFile
    }

    if ($LASTEXITCODE -ne 0) { Write-Fail "dcc64 retornou codigo $LASTEXITCODE. Verificar erros de compilacao." }
    Write-Ok "Build concluido com sucesso."
} else {
    Write-Step "1/5" "Build ignorado (-SkipBuild)."
}

# ─── PASSO 2: Localizar MSIX gerado ──────────────────────────────────────────

Write-Step "2/5" "Localizando MSIX em '$OutputDir'..."
$msixFile = Get-MsixFile -Dir $OutputDir
Write-Ok "MSIX: $msixFile"

# ─── PASSO 3: Resolver credenciais de assinatura ─────────────────────────────

Write-Step "3/5" "Configurando assinatura..."

$tempPfx = $null
$effectivePfxPath = $PfxPath
$effectivePassword = $PfxPassword

# Tentar ambiente CI/CD se parametros nao fornecidos
if (-not $effectivePfxPath -or -not $effectivePassword) {
    if ($env:PFX_BASE64 -and $env:PFX_PASSWORD) {
        Write-Host "    Usando PFX do ambiente CI (PFX_BASE64 + PFX_PASSWORD)..."
        $tempPfx = Get-PfxFromEnv
        $effectivePfxPath = $tempPfx
        $effectivePassword = $env:PFX_PASSWORD
        Write-Ok "PFX reconstituido em arquivo temporario."
    } else {
        Write-Fail "Credenciais de assinatura ausentes. Fornecer -PfxPath + -PfxPassword OU configurar PFX_BASE64 + PFX_PASSWORD no ambiente."
    }
}

# ─── PASSO 3b: Assinar MSIX ───────────────────────────────────────────────────

$signtool = Get-Signtool
Write-Host "    signtool: $signtool"

$signed = $false
foreach ($ts in $TIMESTAMP_FALLBACKS) {
    Write-Host "    Tentando timestamp: $ts..."
    & $signtool sign /fd SHA256 /f $effectivePfxPath /p $effectivePassword /tr $ts /td SHA256 $msixFile 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "MSIX assinado com sucesso (timestamp: $ts)."
        $signed = $true
        break
    }
    Write-Host "    Falhou com $ts. Tentando proximo..." -ForegroundColor Yellow
}

# Limpar PFX temporario imediatamente
if ($tempPfx -and (Test-Path $tempPfx)) {
    Remove-Item $tempPfx -Force
    Write-Host "    PFX temporario removido."
}

if (-not $signed) { Write-Fail "Todos os servidores de timestamp falharam. Verificar conectividade." }

# Verificar assinatura
& $signtool verify /pa $msixFile 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Fail "Verificacao da assinatura falhou. MSIX pode estar corrompido." }
Write-Ok "Assinatura verificada."

# ─── PASSO 4: Sideload ────────────────────────────────────────────────────────

if (-not $SkipSideload) {
    Write-Step "4/5" "Instalando MSIX via sideload..."

    $existing = Get-AppxPackage -Name $PackageName -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "    Versao atual instalada: $($existing.Version). Atualizando..."
        Add-AppxPackage -Path $msixFile -ForceUpdateFromAnyVersion -ErrorAction Stop
    } else {
        Write-Host "    Primeira instalacao..."
        Add-AppxPackage -Path $msixFile -ErrorAction Stop
    }

    Write-Ok "Sideload concluido."
} else {
    Write-Step "4/5" "Sideload ignorado (-SkipSideload)."
}

# ─── PASSO 5: Verificar instalacao ───────────────────────────────────────────

Write-Step "5/5" "Verificando instalacao..."

$pkg = Get-AppxPackage -Name $PackageName -ErrorAction SilentlyContinue
if ($pkg) {
    Write-Ok "Pacote instalado:"
    Write-Host "    Name          : $($pkg.Name)"
    Write-Host "    Version       : $($pkg.Version)"
    Write-Host "    InstallLocation: $($pkg.InstallLocation)"
} else {
    if (-not $SkipSideload) {
        Write-Host "    AVISO: Pacote nao encontrado apos sideload. Pode precisar de reinicializacao." -ForegroundColor Yellow
    } else {
        Write-Host "    Sideload ignorado; verificacao de instalacao pulada." -ForegroundColor DarkGray
    }
}

# ─── Resumo ───────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  PIPELINE CONCLUIDO COM SUCESSO" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  MSIX assinado : $msixFile"
if ($pkg) { Write-Host "  Versao        : $($pkg.Version)" }
Write-Host ""

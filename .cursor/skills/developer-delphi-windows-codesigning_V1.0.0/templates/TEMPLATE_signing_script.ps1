#Requires -Version 5.1
<#
.SYNOPSIS
    Template de script de assinatura parametrizado para Code Signing com signtool.

.DESCRIPTION
    Script de assinatura pronto para uso em CI/CD ou execucao manual.
    Valida todos os inputs, assina o arquivo com signtool e verifica a assinatura.
    Suporta fallback automatico entre servidores de timestamp.

    COMO USAR:
      1. Copiar para o projeto (ex.: scripts\sign-release.ps1)
      2. Ajustar o caminho do signtool se necessario
      3. Em CI/CD: passar -PfxPath e -PfxPassword via variaveis de ambiente secretas
      4. NUNCA hardcodar a senha no script ou no repositorio

.PARAMETER PfxPath
    Caminho completo para o arquivo .pfx com certificado e chave privada.
    OBRIGATORIO.

.PARAMETER PfxPassword
    Senha do arquivo .pfx.
    OBRIGATORIO. Em CI/CD, passar via $env:PFX_PASSWORD.

.PARAMETER FilePath
    Caminho do arquivo a ser assinado (.msix, .exe, .dll, etc.).
    OBRIGATORIO.

.PARAMETER TimestampServer
    URL do servidor de timestamp RFC 3161.
    Padrao: http://timestamp.digicert.com
    Se falhar, o script tenta servidores alternativos automaticamente.

.PARAMETER Description
    Descricao do software (aparece no dialogo UAC).
    Opcional. Padrao: nome do arquivo sem extensao.

.PARAMETER DescriptionUrl
    URL para mais informacoes sobre o software.
    Opcional.

.PARAMETER SigntoolPath
    Caminho completo para signtool.exe.
    Se omitido, o script localiza automaticamente no Windows SDK.

.PARAMETER SkipVerify
    Se presente, pula a verificacao apos assinar (nao recomendado).

.EXAMPLE
    .\TEMPLATE_signing_script.ps1 `
      -PfxPath ".\certs\empresa.pfx" `
      -PfxPassword $env:PFX_PASSWORD `
      -FilePath ".\dist\GestorERP_1.0.0.0_x64.msix"

.EXAMPLE
    # CI/CD com todos os parametros via ambiente
    .\TEMPLATE_signing_script.ps1 `
      -PfxPath $env:PFX_PATH `
      -PfxPassword $env:PFX_PASSWORD `
      -FilePath $env:MSIX_PATH `
      -TimestampServer "http://timestamp.sectigo.com" `
      -Description "GestorERP" `
      -DescriptionUrl "https://empresa.com.br"

.NOTES
    Skill: developer-delphi-windows-codesigning_V1.0.0
    NUNCA versionar arquivos .pfx. Adicionar *.pfx ao .gitignore.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$PfxPath,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$PfxPassword,

    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$FilePath,

    [Parameter(Mandatory = $false)]
    [string]$TimestampServer = "http://timestamp.digicert.com",

    [Parameter(Mandatory = $false)]
    [string]$Description = "",

    [Parameter(Mandatory = $false)]
    [string]$DescriptionUrl = "",

    [Parameter(Mandatory = $false)]
    [string]$SigntoolPath = "",

    [Parameter(Mandatory = $false)]
    [switch]$SkipVerify
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ─── Servidores de fallback ──────────────────────────────────────────────────

$FallbackTimestampServers = @(
    $TimestampServer,
    "http://timestamp.digicert.com",
    "http://timestamp.sectigo.com",
    "http://timestamp.entrust.net/TSS/RFC3161sha2TS"
) | Select-Object -Unique

# ─── Localizar signtool ──────────────────────────────────────────────────────

function Get-SigntoolPath {
    param([string]$OverridePath)

    if ($OverridePath -and (Test-Path $OverridePath)) {
        return $OverridePath
    }

    $kitBase = "C:\Program Files (x86)\Windows Kits\10\bin"
    if (-not (Test-Path $kitBase)) {
        throw "Windows Kits nao encontrado em '$kitBase'. Instale o Windows SDK."
    }

    $found = Get-ChildItem "$kitBase\*\x64\signtool.exe" -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending |
        Select-Object -First 1 -ExpandProperty FullName

    if (-not $found) {
        throw "signtool.exe nao encontrado. Instale o Windows SDK com 'Windows SDK Signing Tools'."
    }

    return $found
}

# ─── Assinar com fallback de timestamp ───────────────────────────────────────

function Invoke-SignWithFallback {
    param(
        [string]$Signtool,
        [string]$PfxFile,
        [string]$Password,
        [string]$File,
        [string[]]$TimestampServers,
        [string]$Desc,
        [string]$DescUrl
    )

    foreach ($ts in $TimestampServers) {
        Write-Host "  Tentando timestamp: $ts" -ForegroundColor DarkCyan

        # Montar argumentos base
        $args = @("sign", "/fd", "SHA256", "/f", $PfxFile, "/p", $Password, "/tr", $ts, "/td", "SHA256")

        if ($Desc) { $args += @("/d", $Desc) }
        if ($DescUrl) { $args += @("/du", $DescUrl) }

        $args += $File

        # Executar signtool (suprimir password dos logs)
        $output = & $Signtool @args 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-Host "  Assinado com sucesso (timestamp: $ts)" -ForegroundColor Green
            return $true
        }

        Write-Host "  Falhou (codigo $LASTEXITCODE): $output" -ForegroundColor Yellow
    }

    return $false
}

# ─── Main ────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "=== Code Signing ===" -ForegroundColor Cyan
Write-Host "  Arquivo : $FilePath"
Write-Host "  PFX     : $PfxPath"
Write-Host "  TS      : $TimestampServer"
Write-Host ""

# Resolver caminhos absolutos
$PfxPath  = Resolve-Path $PfxPath
$FilePath = Resolve-Path $FilePath

# Definir descricao padrao
if (-not $Description) {
    $Description = [IO.Path]::GetFileNameWithoutExtension($FilePath)
}

# Localizar signtool
$st = Get-SigntoolPath -OverridePath $SigntoolPath
Write-Host "signtool : $st"
Write-Host ""

# Assinar com fallback
$ok = Invoke-SignWithFallback `
    -Signtool $st `
    -PfxFile $PfxPath `
    -Password $PfxPassword `
    -File $FilePath `
    -TimestampServers $FallbackTimestampServers `
    -Desc $Description `
    -DescUrl $DescriptionUrl

if (-not $ok) {
    Write-Host ""
    Write-Host "ERRO: Nenhum servidor de timestamp funcionou." -ForegroundColor Red
    Write-Host "Verifique a conectividade com a internet e tente novamente." -ForegroundColor Red
    exit 1
}

# Verificar assinatura (a menos que -SkipVerify seja passado)
if (-not $SkipVerify) {
    Write-Host ""
    Write-Host "Verificando assinatura..." -ForegroundColor Cyan

    $verifyOutput = & $st verify /pa /v $FilePath 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Verificacao OK." -ForegroundColor Green
    } else {
        Write-Host "ERRO na verificacao:" -ForegroundColor Red
        Write-Host $verifyOutput
        exit 1
    }
}

Write-Host ""
Write-Host "Code Signing concluido com sucesso." -ForegroundColor Green
Write-Host "  Arquivo assinado: $FilePath"
Write-Host ""
exit 0

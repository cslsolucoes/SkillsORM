<#
.SYNOPSIS
    Gera um par de arquivos de formulario (.pas + .dfm/.fmx/.lfm) a partir dos
    templates em .cursor/Templates/form-units/.

.DESCRIPTION
    O nome dos arquivos gerados corresponde ao -UnitName informado:
        ufrm.Connections -> ufrm.Connections.pas  +  ufrm.Connections.dfm (VCL)
                                                  +  ufrm.Connections.fmx (FMX)
                                                  +  ufrm.Connections.lfm (LCL)

    Frameworks suportados:
        VCL  — Delphi VCL Win32/Win64 (.dfm + .pas com uses Vcl.*)
        FMX  — Delphi FireMonkey (.fmx + .pas com uses FMX.*)
        LCL  — FPC/Lazarus LCL (.lfm + .pas com {$mode objfpc})

.PARAMETER UnitName
    Nome da unit (igual ao nome dos arquivos gerados, sem extensao).
    Ex.: "ufrm.Connections", "ufrmMain", "ufrm.Database"

.PARAMETER FormClass
    Nome da classe do formulario SEM o prefixo T.
    Ex.: "frmConnections" -> classe gerada sera TfrmConnections.
    Se omitido, usa o UnitName com o prefixo removido (parte apos o ultimo ponto).

.PARAMETER FormInstance
    Nome da variavel global de instancia. Padrao: igual a FormClass.

.PARAMETER FormCaption
    Titulo da janela (Caption). Padrao: igual a FormClass.

.PARAMETER Framework
    Framework alvo: VCL, FMX ou LCL. Padrao: VCL.

.PARAMETER LclVersion
    Versao do LCL (apenas para LCL). Padrao: 4.4.0.0.

.PARAMETER OutputDir
    Diretorio de destino relativo a raiz do repositorio. Padrao: src\Views.

.PARAMETER Force
    Sobrescrever arquivos existentes.

.PARAMETER ValidateOnly
    Apenas mostrar o que seria gerado, sem criar arquivos.

.EXAMPLE
    .\bootstrap-form-unit.ps1 -UnitName "ufrm.Connections" -Framework VCL

.EXAMPLE
    .\bootstrap-form-unit.ps1 -UnitName "ufrm.Main" -FormClass "frmMain" -FormCaption "Main" -Framework FMX -OutputDir "src\Views"

.EXAMPLE
    .\bootstrap-form-unit.ps1 -UnitName "ufrm.Database" -Framework LCL -Force
#>

# internal_file_version: 1.0.0
# Changelog (este arquivo):
# - 1.0.0 (04/04/2026): Versao inicial com versionamento interno. Geracao de
#   .pas + .dfm/.fmx/.lfm a partir de templates; frameworks VCL, FMX, LCL;
#   -ValidateOnly, -Force.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$UnitName,

    [string]$FormClass      = '',
    [string]$FormInstance   = '',
    [string]$FormCaption    = '',
    [string]$LclVersion     = '4.4.0.0',

    [ValidateSet('VCL', 'FMX', 'LCL')]
    [string]$Framework      = 'VCL',

    [string]$OutputDir      = 'src\Views',

    [switch]$Force,
    [switch]$ValidateOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

# =============================================================================
# Resolve raiz do repositorio (.cursor/scripts/ -> raiz)
# =============================================================================
$RepoRoot    = (Resolve-Path (Join-Path $PSScriptRoot '..\..'))
$TemplateDir = Join-Path $RepoRoot '.cursor\Templates\form-units'
$DestDir     = Join-Path $RepoRoot $OutputDir

# =============================================================================
# Resolve valores padrao para FormClass, FormInstance, FormCaption
# =============================================================================
if (-not $FormClass) {
    # Usa a parte apos o ultimo ponto; se nao houver ponto, usa o UnitName inteiro
    $FormClass = if ($UnitName -match '\.([^.]+)$') { $Matches[1] } else { $UnitName }
}
if (-not $FormInstance) { $FormInstance = $FormClass }
if (-not $FormCaption)  { $FormCaption  = $FormClass }

# =============================================================================
# Seleciona o par de templates conforme Framework
# =============================================================================
switch ($Framework) {
    'VCL' {
        $resourceTemplate = '{UNIT_NAME}.dfm.template'
        $resourceExt      = '.dfm'
        $pascalTemplate   = '{UNIT_NAME}.vcl.pas.template'
    }
    'FMX' {
        $resourceTemplate = '{UNIT_NAME}.fmx.template'
        $resourceExt      = '.fmx'
        $pascalTemplate   = '{UNIT_NAME}.fmx.pas.template'
    }
    'LCL' {
        $resourceTemplate = '{UNIT_NAME}.lfm.template'
        $resourceExt      = '.lfm'
        $pascalTemplate   = '{UNIT_NAME}.lcl.pas.template'
    }
}

$mappings = @(
    @{ Template = $resourceTemplate; Dest = "$UnitName$resourceExt" },
    @{ Template = $pascalTemplate;   Dest = "$UnitName.pas" }
)

# =============================================================================
# Tabela de substituicao
# =============================================================================
$replacements = [ordered]@{
    '{UNIT_NAME}'      = $UnitName
    '{FORM_CLASS}'     = $FormClass
    '{FORM_INSTANCE}'  = $FormInstance
    '{FORM_CAPTION}'   = $FormCaption
    '{LCL_VERSION}'    = $LclVersion
}

Write-Host ''
Write-Host "  bootstrap-form-unit — Framework: $Framework" -ForegroundColor Cyan
Write-Host "  Raiz      : $RepoRoot"    -ForegroundColor Gray
Write-Host "  Unit      : $UnitName"    -ForegroundColor Gray
Write-Host "  Classe    : T$FormClass"  -ForegroundColor Gray
Write-Host "  Caption   : $FormCaption" -ForegroundColor Gray
Write-Host "  Destino   : $OutputDir"   -ForegroundColor Gray
Write-Host ''

# =============================================================================
# Garante que o diretorio de destino existe
# =============================================================================
if (-not $ValidateOnly -and -not (Test-Path $DestDir)) {
    New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
    Write-Host "  [MKDIR]   $OutputDir" -ForegroundColor DarkGray
}

$created = 0
$skipped = 0
$errors  = 0

foreach ($m in $mappings) {

    $templatePath = Join-Path $TemplateDir $m.Template
    $destPath     = Join-Path $DestDir     $m.Dest

    # --- ValidateOnly ---
    if ($ValidateOnly) {
        $tplOk  = if (Test-Path $templatePath) { 'OK      ' } else { 'AUSENTE ' }
        $status = if (Test-Path $destPath)      { '[EXISTE] ' } else { '[NOVO]   ' }
        Write-Host "  $status  $OutputDir\$($m.Dest)  (template $tplOk)" -ForegroundColor Yellow
        continue
    }

    if (-not (Test-Path $templatePath)) {
        Write-Host "  [ERRO]    Template nao encontrado: $($m.Template)" -ForegroundColor Red
        $errors++
        continue
    }

    if ((Test-Path $destPath) -and -not $Force) {
        Write-Host "  [EXISTE]  $($m.Dest) — ja existe (use -Force para sobrescrever)" -ForegroundColor DarkGray
        $skipped++
        continue
    }

    try {
        $content = Get-Content -Path $templatePath -Raw -Encoding UTF8
        foreach ($key in $replacements.Keys) {
            $content = $content.Replace($key, $replacements[$key])
        }
        Set-Content -Path $destPath -Value $content -Encoding UTF8 -NoNewline
        Write-Host "  [CRIADO]  $OutputDir\$($m.Dest)" -ForegroundColor Green
        $created++
    } catch {
        Write-Host "  [ERRO]    Falha ao gerar $($m.Dest): $_" -ForegroundColor Red
        $errors++
    }
}

Write-Host ''
if ($ValidateOnly) {
    Write-Host '  Modo ValidateOnly — nenhum arquivo foi criado.' -ForegroundColor Yellow
} else {
    Write-Host "  Resumo: $created criado(s), $skipped ignorado(s), $errors erro(s)." -ForegroundColor Cyan
}
Write-Host ''

if ($errors -gt 0) { exit 1 }
exit 0

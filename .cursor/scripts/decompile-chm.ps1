<#
.SYNOPSIS
    Descompila ficheiros Microsoft Compiled HTML Help (.chm) para HTML via hh.exe (Windows).

.DESCRIPTION
    Invoca o visualizador de ajuda HTML do Windows (hh.exe) com -decompile.
    Em modo ficheiro único, a pasta de saída predefinida é {NomeSemExtensao}_chm_decompiled
    no mesmo directório do .chm. Em modo lote, aplica a mesma regra a cada .chm encontrado.

    Multiplataforma (Linux, macOS, Windows sem hh): use o script Python decompile_chm.py
    (backends 7-Zip / extract_chmLib / hh em modo auto).

    Requisitos: Windows com hh.exe (tipicamente C:\Windows\hh.exe).
    Equivalente Python: .cursor/scripts/decompile_chm.py (mesma semântica de pastas/filtros).

.PARAMETER ChmPath
    Caminho completo de um único ficheiro .chm.

.PARAMETER ChmDirectory
    Pasta que contém um ou mais ficheiros .chm (modo lote).

.PARAMETER Filter
    Com -ChmDirectory, filtro Wildcard (predefinição: *.chm).

.PARAMETER OutputDirectory
    Apenas com -ChmPath: pasta de saída explícita (criada se não existir).

.PARAMETER OutputSuffix
    Sufixo para o nome da pasta derivada do ficheiro (predefinição: _chm_decompiled).

.PARAMETER HhExe
    Caminho para hh.exe (predefinição: C:\Windows\hh.exe).

.PARAMETER ContinueOnError
    Em modo lote: não aborta no primeiro erro; devolve código 1 se alguma descompilação falhar.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File ".cursor\scripts\decompile-chm.ps1" -ChmPath ".\Doc\data.chm"

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File ".cursor\scripts\decompile-chm.ps1" -ChmDirectory ".\Doc-Delphi" -Filter "delphi13-*.chm"
#>
[CmdletBinding(DefaultParameterSetName = 'Single')]
param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Single', Position = 0)]
    [string] $ChmPath,

    [Parameter(Mandatory = $true, ParameterSetName = 'Batch')]
    [string] $ChmDirectory,

    [Parameter(ParameterSetName = 'Batch')]
    [string] $Filter = '*.chm',

    [Parameter(ParameterSetName = 'Single')]
    [string] $OutputDirectory,

    [Parameter(ParameterSetName = 'Single')]
    [Parameter(ParameterSetName = 'Batch')]
    [string] $OutputSuffix = '_chm_decompiled',

    [Parameter(ParameterSetName = 'Single')]
    [Parameter(ParameterSetName = 'Batch')]
    [string] $HhExe = 'C:\Windows\hh.exe',

    [Parameter(ParameterSetName = 'Batch')]
    [switch] $ContinueOnError
)

$ErrorActionPreference = 'Stop'

function Test-HhExecutable {
    param([string] $Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "hh.exe não encontrado: $Path"
    }
}

function Invoke-ChmDecompile {
    param(
        [string] $ChmFile,
        [string] $OutDir,
        [string] $Hh
    )
    $resolvedChm = (Resolve-Path -LiteralPath $ChmFile).Path
    if (-not $OutDir) {
        throw 'OutDir vazio.'
    }
    $parent = Split-Path -Parent $OutDir
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
    Write-Host "Decompilar: $resolvedChm -> $OutDir"
    & $Hh -decompile $OutDir $resolvedChm
    $hhExit = 0
    if (Test-Path -Path 'Variable:\LASTEXITCODE') {
        $hhExit = [int]$LASTEXITCODE
    }
    if ($hhExit -ne 0) {
        throw "hh.exe terminou com código $hhExit"
    }
}

Test-HhExecutable -Path $HhExe

if ($PSCmdlet.ParameterSetName -eq 'Single') {
    if (-not (Test-Path -LiteralPath $ChmPath -PathType Leaf)) {
        throw "Ficheiro .chm não encontrado: $ChmPath"
    }
    if ([System.IO.Path]::GetExtension($ChmPath) -notin @('.chm', '.CHM')) {
        Write-Warning "Extensão não é .chm: $ChmPath"
    }
    $fullChm = (Resolve-Path -LiteralPath $ChmPath).Path
    $dir = Split-Path -Parent $fullChm
    $stem = [System.IO.Path]::GetFileNameWithoutExtension($fullChm)
    if ($OutputDirectory) {
        $out = $OutputDirectory
    } else {
        $out = Join-Path $dir ($stem + $OutputSuffix)
    }
    Invoke-ChmDecompile -ChmFile $fullChm -OutDir $out -Hh $HhExe
    Write-Host 'Concluído (1 ficheiro).'
    exit 0
}

# Batch
if (-not (Test-Path -LiteralPath $ChmDirectory -PathType Container)) {
    throw "Pasta não encontrada: $ChmDirectory"
}
$dirResolved = (Resolve-Path -LiteralPath $ChmDirectory).Path
$list = Get-ChildItem -LiteralPath $dirResolved -Filter $Filter -File -ErrorAction Stop |
    Where-Object { $_.Extension -match '^\.chm$' }
if ($list.Count -eq 0) {
    Write-Warning "Nenhum .chm encontrado em $dirResolved com filtro $Filter"
    exit 0
}

$failed = 0
foreach ($f in $list) {
    $stem = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
    $out = Join-Path $f.DirectoryName ($stem + $OutputSuffix)
    try {
        Invoke-ChmDecompile -ChmFile $f.FullName -OutDir $out -Hh $HhExe
    } catch {
        $failed++
        Write-Warning $_.Exception.Message
        if (-not $ContinueOnError) {
            exit 1
        }
    }
}

if ($failed -gt 0) {
    Write-Warning "Terminado com $failed falha(s)."
    exit 1
}
Write-Host "Concluído ($($list.Count) ficheiro(s))."
exit 0

<#
.SYNOPSIS
    Materializa idempotentemente os arquivos paramétricos de raiz de um Skills Project
    (CLAUDE.md, LICENSE, privacy-policy.md, .workspace/context.json) a partir dos
    templates em .cursor/Templates/skills-project-bootstrap/.

.DESCRIPTION
    - Se o arquivo destino NÃO existe → cria com placeholders substituídos.
    - Se existe e a versão do template é MAIOR (SemVer) que a do materializado →
      faz backup em .cursor/Backup/skills-project/<timestamp>/ e sobrescreve.
    - Se existe e versões são iguais (ou ausente no materializado) → no-op.
    - Se a versão do materializado é MAIOR → warning, no-op (usuário customizou).

.PARAMETER ProjectName
    Nome do projeto. Default: nome do diretório raiz do repo.

.PARAMETER Company
    Empresa/organização. Default: 'CSL Tech Solutions'.

.PARAMETER Author
    Autor principal. Default: 'Claiton de Souza Linhares'.

.PARAMETER GithubUrl
    URL do GitHub do autor/empresa. Default: 'https://github.com/cslsolucoes'.

.PARAMETER ValidateOnly
    Apenas reporta o que falta/precisa de update; não escreve nada.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .cursor/scripts/bootstrap-skills-project.ps1 -ValidateOnly

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .cursor/scripts/bootstrap-skills-project.ps1
#>
[CmdletBinding()]
param(
    [string] $ProjectName,
    [string] $Company    = 'CSL Tech Solutions',
    [string] $Author     = 'Claiton de Souza Linhares',
    [string] $GithubUrl  = 'https://github.com/cslsolucoes',
    [switch] $ValidateOnly
)

$ErrorActionPreference = 'Stop'

$ScriptRoot   = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot     = Split-Path -Parent (Split-Path -Parent $ScriptRoot)
$TemplateRoot = Join-Path $RepoRoot '.cursor/Templates/skills-project-bootstrap'
$BackupRoot   = Join-Path $RepoRoot '.cursor/Backup/skills-project'

if (-not $ProjectName -or $ProjectName -eq '') {
    $ProjectName = Split-Path -Leaf $RepoRoot
}

$Year          = (Get-Date).Year.ToString()
$EffectiveDate = (Get-Date).ToString('MMMM dd, yyyy', [System.Globalization.CultureInfo]::InvariantCulture)

function Get-TemplateVersion {
    param([string] $Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    $content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    $patterns = @(
        '<!--\s*internal_template_version:\s*([0-9]+\.[0-9]+\.[0-9]+)[^>]*-->',
        '#\s*internal_template_version:\s*([0-9]+\.[0-9]+\.[0-9]+)',
        '"_internal_template_version"\s*:\s*"([0-9]+\.[0-9]+\.[0-9]+)"'
    )
    foreach ($p in $patterns) {
        $m = [regex]::Match($content, $p)
        if ($m.Success) { return [version]$m.Groups[1].Value }
    }
    return $null
}

function Compare-Version {
    param([version] $TemplateVer, [version] $MaterializedVer)
    if ($null -eq $TemplateVer)                           { return 'no-version' }
    if ($null -eq $MaterializedVer)                       { return 'no-materialized-version' }
    if ($TemplateVer -gt $MaterializedVer)                { return 'template-newer' }
    if ($TemplateVer -lt $MaterializedVer)                { return 'materialized-newer' }
    return 'equal'
}

function Apply-Placeholders {
    param([string] $Content)
    return $Content `
        -replace '\{PROJECT_NAME\}',   $ProjectName `
        -replace '\{COMPANY\}',        $Company `
        -replace '\{AUTHOR\}',         $Author `
        -replace '\{GITHUB_URL\}',     $GithubUrl `
        -replace '\{YEAR\}',           $Year `
        -replace '\{EFFECTIVE_DATE\}', $EffectiveDate
}

function Backup-File {
    param([string] $Path, [string] $Stamp)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $relative = (Resolve-Path -LiteralPath $Path).Path.Substring($RepoRoot.Length).TrimStart('\','/')
    $dest     = Join-Path (Join-Path $BackupRoot $Stamp) $relative
    $destDir  = Split-Path -Parent $dest
    if (-not (Test-Path -LiteralPath $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    Copy-Item -LiteralPath $Path -Destination $dest -Force
    Write-Host "  backup -> $dest"
}

$Targets = @(
    @{ Template = 'CLAUDE.template.md';                Destination = 'CLAUDE.md' },
    @{ Template = 'README.template.md';                Destination = 'README.md' },
    @{ Template = 'LICENSE.template';                  Destination = 'LICENSE' },
    @{ Template = 'privacy-policy.template.md';        Destination = 'privacy-policy.md' },
    @{ Template = 'workspace-context.template.json';   Destination = '.workspace/context.json' }
)

$Stamp     = (Get-Date).ToString('yyyyMMdd-HHmmss')
$missing   = 0
$updated   = 0
$skipped   = 0
$warnings  = 0

foreach ($t in $Targets) {
    $tplPath  = Join-Path $TemplateRoot $t.Template
    $destPath = Join-Path $RepoRoot     $t.Destination

    if (-not (Test-Path -LiteralPath $tplPath)) {
        Write-Warning "Template ausente: $tplPath"
        continue
    }

    $tplVer = Get-TemplateVersion -Path $tplPath
    $matVer = Get-TemplateVersion -Path $destPath
    $exists = Test-Path -LiteralPath $destPath
    $cmp    = Compare-Version -TemplateVer $tplVer -MaterializedVer $matVer

    if (-not $exists) {
        $missing++
        Write-Host "[missing] $($t.Destination)  (template v$tplVer)"
        if (-not $ValidateOnly) {
            $destDir = Split-Path -Parent $destPath
            if ($destDir -and -not (Test-Path -LiteralPath $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            $body = Get-Content -LiteralPath $tplPath -Raw -Encoding UTF8
            $body = Apply-Placeholders -Content $body
            [System.IO.File]::WriteAllText($destPath, $body, (New-Object System.Text.UTF8Encoding($false)))
            Write-Host "  created"
        }
        continue
    }

    switch ($cmp) {
        'equal' {
            $skipped++
            Write-Host "[ok]      $($t.Destination)  (v$matVer)"
        }
        'template-newer' {
            $updated++
            Write-Host "[update]  $($t.Destination)  (v$matVer -> v$tplVer)"
            if (-not $ValidateOnly) {
                Backup-File -Path $destPath -Stamp $Stamp
                $body = Get-Content -LiteralPath $tplPath -Raw -Encoding UTF8
                $body = Apply-Placeholders -Content $body
                [System.IO.File]::WriteAllText($destPath, $body, (New-Object System.Text.UTF8Encoding($false)))
                Write-Host "  rewritten"
            }
        }
        'materialized-newer' {
            $warnings++
            Write-Warning "[warn]    $($t.Destination): materializado v$matVer > template v$tplVer (no-op)"
        }
        'no-version' {
            $warnings++
            Write-Warning "[warn]    Template sem versão: $($t.Template) (no-op)"
        }
        'no-materialized-version' {
            $skipped++
            Write-Host "[ok?]     $($t.Destination)  (sem versao no materializado, template v$tplVer - no-op idempotente)"
        }
    }
}

Write-Host ""
Write-Host "[bootstrap-skills-project] missing=$missing updated=$updated ok=$skipped warnings=$warnings  validateOnly=$ValidateOnly"

if ($ValidateOnly -and ($missing -gt 0 -or $updated -gt 0)) {
    exit 1
}
exit 0

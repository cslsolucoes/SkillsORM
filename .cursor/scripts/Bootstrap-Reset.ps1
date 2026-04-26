<#
.SYNOPSIS
    Reset dos ficheiros de infraestrutura de IA ao estado base.

.DESCRIPTION
    Remove APENAS os ficheiros criados pelos scripts de bootstrap relacionados
    com a infraestrutura de IA (Claude Code, OpenCode, mirrors de IDE):

    Da raiz:
      - CLAUDE.md        (gerado por Install-MirrorConfigTemplate)
      - opencode.json    (gerado por Install-MirrorConfigTemplate)

    Dos mirrors (.claude/ .vscode/ .continue/ .opencode/):
      - settings.json, settings.local.json, extensions.json (configs geradas)
      - tasks.json       (restaurado do .bak se AutoStart fez upgrade)
      - todos os symlinks (geridos por bootstrap-mirror-symlinks.ps1)
      - pastas vazias apos remocao dos symlinks

    NAO toca em:
      - Ficheiros de projeto Delphi/FPC (*.dpr, *.dproj, *.lpr, *.lpi, *.lps,
        *.res, *.ico, *.inc, dcc32.cfg, dcc64.cfg, fpc32.opts, fpc64.opts)
      - src/, Documentation/, e qualquer outro ficheiro/pasta do utilizador
      - .cursor/ (SSOT — imutavel)
      - .vscode/tasks.json (preservado ou restaurado do .bak)

.PARAMETER WhatIf
    Mostra o que seria apagado/restaurado sem alterar nada.

.PARAMETER Force
    Nao pede confirmacao antes de apagar.

.EXAMPLE
    # Pre-visualizacao completa
    .\.cursor\scripts\bootstrap-reset.ps1 -WhatIf

    # Reset (com confirmacao interativa)
    .\.cursor\scripts\bootstrap-reset.ps1

    # Reset sem confirmacao
    .\.cursor\scripts\bootstrap-reset.ps1 -Force
#>

# internal_file_version: 1.4.0
# Changelog (este arquivo):
# - 1.4.0 (09/04/2026): Carrega .cursor/config.json para determinar mirrors activos;
#   secoes 1, 2, 4 e 5 usam apenas mirrorDirs e rootFiles habilitados no config;
#   secao 3 (tasks.json) condicional a .vscode habilitado; fallback ao comportamento
#   anterior se config.json ausente.
# - 1.3.0 (09/04/2026): Secoes 4 e 4b fundidas em limpeza profunda unica — move TUDO
#   dos mirrors para backup\ (exceto .vscode\tasks.json); cobre nomes exatos, sufixos
#   timestamp de resets anteriores e quaisquer outros residuos; local mode remove direto.
# - 1.2.0 (09/04/2026): Rename-RealWithTimestamp substituida por Move-ToBackup —
#   em vez de renomear no mesmo directorio, move para backup\{mirrorDir}\{nome}.{stamp};
#   pasta backup\ criada automaticamente se nao existir.
# - 1.1.0 (09/04/2026): Suporte a modo rede (Test-IsNetworkPath / $script:IsNetworkMode);
#   secao 4 — em modo rede renomeia copias reais com timestamp em vez de remover symlinks;
#   secao 4b — em modo rede renomeia pastas com conteudo (eram copias geridas);
#   nova funcao Move-ToBackup.
# - 1.0.4 (04/04/2026): Seccao 4b — remocao de pastas reais orfas e duplicados
#   do Explorer (pattern "nome (N)") nos mirrors; apenas pastas vazias sao removidas
#   (pastas com conteudo sao preservadas); ficheiros protegidos (settings.json etc.)
#   nao sao afectados pelo filtro de nomes de symlink.
# - 1.0.3 (04/04/2026): Escopo reduzido a ficheiros de IA exclusivamente — removidas
#   seccoes de projeto Delphi/FPC, build configs (dcc32.cfg etc.), build/ e
#   -IncludeSourceFiles; da raiz apaga apenas CLAUDE.md e opencode.json; ficheiros
#   de projecto e codigo do utilizador nunca sao tocados.
# - 1.0.2 (04/04/2026): Seccao 1 refatorada — wildcards substituidos por lista
#   explicita; Remove-IfExists exibe [N/A] em WhatIf para ficheiros ausentes.
# - 1.0.1 (04/04/2026): Adicionado opencode.json; restauro de tasks.json a partir
#   de tasks.json.bak; fallback para vscode-tasks-base.template.json.
# - 1.0.0 (04/04/2026): Versao inicial com versionamento interno.

param(
    [switch]$WhatIf,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

# ---------------------------------------------------------------------------
# Localizar raiz do repositorio (scripts/ -> .cursor/ -> raiz)
# ---------------------------------------------------------------------------
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot  = Split-Path -Parent $ScriptDir   # .cursor/
$RepoRoot  = Split-Path -Parent $RepoRoot    # raiz

# ---------------------------------------------------------------------------
# Detectar modo rede (sem symlinks — mirrors sao copias reais)
# ---------------------------------------------------------------------------
function Test-IsNetworkPath {
    param([string]$Path)
    if ($Path -match '^\\\\') { return $true }
    $qualifier = Split-Path -Qualifier $Path -ErrorAction SilentlyContinue
    if ($qualifier) {
        try {
            $di = [System.IO.DriveInfo]::new($qualifier)
            if ($di.DriveType -eq [System.IO.DriveType]::Network) { return $true }
        } catch { }
    }
    return $false
}
$script:IsNetworkMode = Test-IsNetworkPath -Path $RepoRoot

# ---------------------------------------------------------------------------
# Carregar configuracao de IAs activas (.cursor/config.json)
# ---------------------------------------------------------------------------
function Get-MirrorConfig {
    param([string]$RepoRoot)
    $default = @{
        EnabledDirs = @('.claude', '.vscode', '.continue', '.opencode')
        RootFiles   = @('CLAUDE.md', 'opencode.json')
        HasVscode   = $true
    }
    $configPath = Join-Path $RepoRoot '.cursor\config.json'
    if (-not (Test-Path $configPath)) { return $default }
    try {
        $cfg = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if (-not $cfg.ias) { return $default }
        $dirs = @(); $files = @(); $hasVscode = $false
        foreach ($prop in $cfg.ias.PSObject.Properties) {
            $ia = $prop.Value
            if ($ia.enabled -ne $true) { continue }
            if ($ia.mirrorDir) { $dirs += $ia.mirrorDir }
            if ($ia.mirrorDir -eq '.vscode') { $hasVscode = $true }
            if ($ia.rootFiles) { foreach ($f in $ia.rootFiles) { $files += $f } }
        }
        if ($dirs.Count -eq 0) { return $default }
        return @{ EnabledDirs = $dirs; RootFiles = $files; HasVscode = $hasVscode }
    } catch {
        Write-Host '  [AVISO]    Erro ao ler config.json -- usando configuracao padrao' -ForegroundColor Yellow
        return $default
    }
}
$mirrorCfg = Get-MirrorConfig -RepoRoot $RepoRoot

Write-Host ''
Write-Host '=== bootstrap-reset ===' -ForegroundColor Cyan
Write-Host "    Raiz: $RepoRoot"
if ($WhatIf) { Write-Host '    Modo: WhatIf (nenhum arquivo sera alterado)' -ForegroundColor Yellow }
Write-Host ''

# ---------------------------------------------------------------------------
# Confirmacao interativa (a menos que -Force ou -WhatIf)
# ---------------------------------------------------------------------------
if (-not $Force -and -not $WhatIf) {
    $answer = Read-Host 'Confirma o reset dos ficheiros de IA? [s/N]'
    if ($answer -notmatch '^[sS]$') {
        Write-Host 'Reset cancelado.' -ForegroundColor Yellow
        exit 0
    }
}

$deleted = 0
$skipped = 0

function Remove-IfExists {
    param([string]$Path, [string]$Label)
    if (Test-Path $Path) {
        if ($WhatIf) {
            Write-Host "  [WhatIf]   Apagaria: $Label" -ForegroundColor Yellow
        } else {
            Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "  [APAGADO]  $Label" -ForegroundColor Red
        }
        $script:deleted++
    } else {
        if ($WhatIf) {
            Write-Host "  [N/A]      $Label - nao existe" -ForegroundColor DarkGray
        }
        $script:skipped++
    }
}

function Move-ToBackup {
    <#
    .SYNOPSIS
        Move pasta ou ficheiro real para backup\{mirrorDir}\{nome}.{stamp}.
        Usado em modo rede onde mirrors sao copias reais, nao symlinks.
        Cria backup\{mirrorDir}\ automaticamente se nao existir.
    #>
    param([string]$Path, [string]$Label)
    $parent     = Split-Path -Path $Path -Parent
    $mirrorName = Split-Path -Path $parent -Leaf   # ex: .claude, .vscode
    $leaf       = Split-Path -Path $Path -Leaf     # ex: agents, rules
    $stamp      = Get-Date -Format 'yyyyMMdd_HHmmss'
    $backupDir  = Join-Path $RepoRoot "backup\$mirrorName"
    $dest       = Join-Path $backupDir "${leaf}.${stamp}"
    $i = 0
    while (Test-Path -LiteralPath $dest) { $i++; $dest = Join-Path $backupDir "${leaf}.${stamp}_${i}" }
    $destLeaf = Split-Path -Path $dest -Leaf
    if ($WhatIf) {
        Write-Host "  [WhatIf]   Moveria: $Label  ->  backup\$mirrorName\$destLeaf" -ForegroundColor Yellow
    } else {
        if (-not (Test-Path -LiteralPath $backupDir)) {
            New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        }
        try {
            Move-Item -LiteralPath $Path -Destination $dest -Force -ErrorAction Stop
            Write-Host "  [BACKUP]   $Label  ->  backup\$mirrorName\$destLeaf" -ForegroundColor Cyan
        } catch {
            # Fallback 1: Copy-Item + Remove (permissoes bloqueiam Move directo)
            try {
                Copy-Item -LiteralPath $Path -Destination $dest -Recurse -Force -ErrorAction Stop
                Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "  [BACKUP]   $Label  ->  backup\$mirrorName\$destLeaf (via copia)" -ForegroundColor Cyan
            } catch {
                # Fallback 2: robocopy /MIR para esvaziar e depois remover
                try {
                    $emptyDir = Join-Path ([System.IO.Path]::GetTempPath()) ('empty_' + [System.Guid]::NewGuid().ToString('N'))
                    New-Item -ItemType Directory -Path $emptyDir -Force | Out-Null
                    robocopy $emptyDir $Path /MIR /NJH /NJS /NFL /NDL | Out-Null
                    Remove-Item -LiteralPath $emptyDir -Force -ErrorAction SilentlyContinue
                    Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Host "  [REMOVIDO] $Label (permissao bloqueada — nao foi possivel fazer backup)" -ForegroundColor Yellow
                } catch {
                    Write-Host "  [AVISO]    $Label  ->  nao foi possivel remover: $($_.Exception.Message)" -ForegroundColor Red
                    $script:skipped++
                    return
                }
            }
        }
    }
    $script:deleted++
}

# ---------------------------------------------------------------------------
# 1. Ficheiros de IA na raiz (apenas os das IAs habilitadas no config)
# ---------------------------------------------------------------------------
Write-Host '--- Ficheiros de IA (raiz) ---' -ForegroundColor Cyan

foreach ($rootFile in $mirrorCfg.RootFiles) {
    Remove-IfExists (Join-Path $RepoRoot $rootFile) $rootFile
}

# ---------------------------------------------------------------------------
# 2. Configs de mirror gerados (apenas mirrors habilitados no config)
# ---------------------------------------------------------------------------
Write-Host ''
Write-Host '--- Configs de mirror ---' -ForegroundColor Cyan

# Ficheiros de config conhecidos por mirrorDir
$knownConfigs = @{
    '.claude'    = @('settings.json', 'settings.local.json')
    '.vscode'    = @('settings.json', 'extensions.json')
    '.continue'  = @('config.json', 'config.yaml')
    '.opencode'  = @('config.json')
}
foreach ($mirrorDir in $mirrorCfg.EnabledDirs) {
    if (-not $knownConfigs.ContainsKey($mirrorDir)) { continue }
    foreach ($fname in $knownConfigs[$mirrorDir]) {
        $rel = "$mirrorDir\$fname"
        Remove-IfExists (Join-Path $RepoRoot $rel) $rel
    }
}

# ---------------------------------------------------------------------------
# 3. Restauro de tasks.json (apenas se cursor/.vscode habilitado no config)
#    .bak existe  -> apagar tasks.json gerado, renomear .bak -> tasks.json
#    tasks.json ausente -> recriar do template base
#    tasks.json existe sem .bak -> ficheiro base intacto, preservar
# ---------------------------------------------------------------------------
Write-Host ''
Write-Host '--- Restauro tasks.json ---' -ForegroundColor Cyan

if (-not $mirrorCfg.HasVscode) {
    Write-Host '  [SKIP]     cursor/.vscode desabilitado no config.json' -ForegroundColor DarkGray
    $script:skipped++
} else {

$tasksPath        = Join-Path $RepoRoot '.vscode\tasks.json'
$backupPath       = Join-Path $RepoRoot '.vscode\tasks.json.bak'
$baseTemplatePath = Join-Path $RepoRoot '.cursor\Templates\mirror-config\vscode-tasks-base.template.json'

if (Test-Path -LiteralPath $backupPath) {
    if ($WhatIf) {
        Write-Host '  [WhatIf]   Restauraria: .vscode\tasks.json (de tasks.json.bak)' -ForegroundColor Yellow
        Write-Host '  [WhatIf]   Apagaria: .vscode\tasks.json.bak' -ForegroundColor Yellow
    } else {
        if (Test-Path -LiteralPath $tasksPath) {
            Remove-Item -Path $tasksPath -Force -ErrorAction SilentlyContinue
        }
        Rename-Item -LiteralPath $backupPath -NewName 'tasks.json' -Force
        Write-Host '  [RESTAURADO] .vscode\tasks.json  <-  tasks.json.bak' -ForegroundColor Green
        Write-Host '  [APAGADO]    .vscode\tasks.json.bak' -ForegroundColor Red
    }
    $script:deleted += 2
} elseif (-not (Test-Path -LiteralPath $tasksPath)) {
    if (Test-Path -LiteralPath $baseTemplatePath) {
        if ($WhatIf) {
            Write-Host '  [WhatIf]   Reconstruiria: .vscode\tasks.json (de vscode-tasks-base.template.json)' -ForegroundColor Yellow
        } else {
            $vscodeDir = Join-Path $RepoRoot '.vscode'
            if (-not (Test-Path $vscodeDir)) {
                New-Item -ItemType Directory -Path $vscodeDir -Force | Out-Null
            }
            Copy-Item -LiteralPath $baseTemplatePath -Destination $tasksPath -Force
            Write-Host '  [RECRIADO]   .vscode\tasks.json  <-  vscode-tasks-base.template.json' -ForegroundColor Green
        }
        $script:deleted++
    } else {
        Write-Host '  [AVISO]    tasks.json ausente e template base nao encontrado' -ForegroundColor Yellow
        $script:skipped++
    }
} else {
    Write-Host '  [SKIP]     tasks.json.bak ausente - tasks.json base preservado' -ForegroundColor DarkGray
    $script:skipped++
}

} # fim bloco else (HasVscode)

# ---------------------------------------------------------------------------
# 4. Limpeza profunda dos mirrors
#    Move TUDO para backup\ (modo rede) ou remove (modo local / symlinks),
#    exceto os ficheiros protegidos por pasta.
#    Cobre: copias actuais, residuos com sufixo timestamp, artefactos IDE.
# ---------------------------------------------------------------------------
Write-Host ''
if ($script:IsNetworkMode) {
    Write-Host '--- Limpeza dos mirrors (tudo -> backup/, exceto protegidos) ---' -ForegroundColor Cyan
} else {
    Write-Host '--- Limpeza dos mirrors (symlinks removidos, reais eliminados) ---' -ForegroundColor Cyan
}

# Ficheiros a preservar por pasta de mirror (inverso do que foi criado pelo bootstrap)
$protectedItems = @{
    '.vscode' = @('tasks.json')
}

foreach ($mirrorDir in $mirrorCfg.EnabledDirs) {
    $dirPath  = Join-Path $RepoRoot $mirrorDir
    if (-not (Test-Path $dirPath)) { continue }
    $keepList = if ($protectedItems.ContainsKey($mirrorDir)) { $protectedItems[$mirrorDir] } else { @() }

    Get-ChildItem -Path $dirPath -Force -ErrorAction SilentlyContinue |
        Where-Object { $keepList -notcontains $_.Name } |
        ForEach-Object {
            $isReparse = [bool]($_.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
            $label     = "$mirrorDir\$($_.Name)"
            if ($isReparse) {
                # Symlink / junction — sempre remover
                Remove-IfExists $_.FullName $label
            } elseif ($script:IsNetworkMode) {
                # Modo rede: copia real (actual, timestamp ou artefacto) -> backup
                Move-ToBackup -Path $_.FullName -Label $label
            } else {
                # Modo local: item real nao-symlink (artefacto) -> remover
                Remove-IfExists $_.FullName "$label (real, nao-symlink)"
            }
        }
}

# ---------------------------------------------------------------------------
# 5. Remover pastas dos mirrors se vazias
# ---------------------------------------------------------------------------
Write-Host ''
Write-Host '--- Pastas dos mirrors ---' -ForegroundColor Cyan

foreach ($mirrorDir in $mirrorCfg.EnabledDirs) {
    $dirPath = Join-Path $RepoRoot $mirrorDir
    if (-not (Test-Path $dirPath)) { continue }
    $remaining = Get-ChildItem -Path $dirPath -Force -ErrorAction SilentlyContinue
    if (-not $remaining) {
        Remove-IfExists $dirPath "$mirrorDir\"
    } else {
        $hint = if ($mirrorDir -eq '.vscode') { ' (tasks.json preservado)' } else { '' }
        Write-Host "  [SKIP]     $mirrorDir\ - contem $(@($remaining).Count) item(s)$hint" -ForegroundColor DarkGray
    }
}

# ---------------------------------------------------------------------------
# Resumo
# ---------------------------------------------------------------------------
Write-Host ''
Write-Host '=== Resumo ===' -ForegroundColor Cyan
if ($WhatIf) {
    Write-Host "  Seriam apagados: $deleted item(s)" -ForegroundColor Yellow
} else {
    Write-Host "  Apagados: $deleted item(s)" -ForegroundColor Green
}
Write-Host "  Ja ausentes / preservados: $skipped item(s)" -ForegroundColor DarkGray
Write-Host ''

if (-not $WhatIf) {
    Write-Host 'Reset concluido.' -ForegroundColor Green
    if ($script:IsNetworkMode) {
        Write-Host 'Execute o bootstrap para recriar copias e configs (modo rede):' -ForegroundColor Cyan
    } else {
        Write-Host 'Execute o bootstrap para recriar symlinks e configs:' -ForegroundColor Cyan
    }
    Write-Host '  powershell -ExecutionPolicy Bypass -File ".cursor\scripts\bootstrap-mirror-symlinks.ps1"'
    Write-Host ''
}

exit 0

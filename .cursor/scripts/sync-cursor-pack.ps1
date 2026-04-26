<#
.SYNOPSIS
    Sincroniza o pack .cursor/ de um projecto fonte para um ou mais projectos destino.

.DESCRIPTION
    Copia as pastas e ficheiros partilhados do pack .cursor/ (scripts, skills, Templates,
    agents, plans, commands, rules, README.md) para cada caminho de destino indicado.

    Apos a copia, remove ficheiros orfaos no destino que ja nao existam na fonte e
    verifica coerencia pos-copia (referencias a templates quebradas).

    Pastas obsoletas (Constitution/, Developer/) e ficheiros migrados (compile.md,
    database.md, diretivas_compilacao.md, VERSION.md, SKILLS_DOCUMENTATION_v3.0.8.md,
    MIRRORS_VALIDATION.md, BASE_STRUCTURE.md) sao removidos automaticamente do destino.

    Nao sincroniza ficheiros de configuracao especificos do projecto (.claude/settings.json,
    .vscode/settings.json, etc.) — apenas o conteudo partilhado do pack.

.PARAMETER DestinationPaths
    Array de caminhos absolutos de projectos destino.
    Cada caminho deve ser a raiz de um projecto (onde .cursor/ existe ou sera criado).

.PARAMETER WhatIf
    Simula a execucao sem alterar ficheiros. Mostra o que seria feito.

.PARAMETER Force
    Sobrescreve ficheiros no destino mesmo que sejam mais recentes.

.EXAMPLE
    .\sync-cursor-pack.ps1 -DestinationPaths "E:\CSL\ProvidersORM", "E:\CSL\ParamentersORM"
    Sincroniza o pack .cursor/ para os dois projectos.

.EXAMPLE
    .\sync-cursor-pack.ps1 -DestinationPaths "E:\CSL\ProvidersORM" -WhatIf
    Simula a sincronizacao sem alterar nada.
#>

# internal_file_version: 1.1.0
# Changelog (este arquivo):
# - 1.1.0 (17/04/2026): Onda 6 do refactor — (1) passa a forcar re-copia quando
#   conteudo difere (robocopy /IS /IT) para evitar residuos por timestamp desalinhado;
#   (2) valida destino pos-sync com validate_pack.py --no-instance-strings;
#   (3) regenera index.db do destino via pack_index_db.py --scan cursor se disponivel.
# - 1.0.1 (09/04/2026): config.json adicionado a PackFiles — sincronizado entre projectos
#   para manter configuracao de IAs consistente.
# - 1.0.0 (04/04/2026): Versao inicial. Sincronizacao de pack .cursor/ entre projectos;
#   limpeza de orfaos; remocao de pastas/ficheiros obsoletos (Constitution/, Developer/,
#   compile.md, database.md, etc.); verificacao de coerencia pos-copia.

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$DestinationPaths,

    [switch]$Force,

    # Desactiva validacao pos-sync (validate_pack.py --no-instance-strings).
    [switch]$SkipValidate,

    # Desactiva regeneracao de .cursor/index.db no destino apos sync.
    [switch]$SkipReindex
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

# --- Constantes ---

# Pastas do pack a sincronizar
$script:PackDirs = @(
    'scripts', 'skills', 'Templates', 'agents', 'plans', 'commands', 'rules'
)

# Ficheiros do pack a sincronizar (raiz de .cursor/)
$script:PackFiles = @(
    'README.md', 'VERSION.md', 'config.json'
)

# Pastas obsoletas a remover do destino
$script:ObsoleteDirs = @(
    'Constitution', 'Developer'
)

# Ficheiros obsoletos a remover do destino (raiz de .cursor/)
$script:ObsoleteFiles = @(
    'compile.md', 'database.md', 'diretivas_compilacao.md',
    'SKILLS_DOCUMENTATION_v3.0.8.md', 'SKILLS_DOCUMENTATION_v3.0.7.md',
    'MIRRORS_VALIDATION.md', 'BASE_STRUCTURE.md'
)

# Skills deprecadas a remover
$script:DeprecatedSkillPatterns = @(
    'cursor-rules-integration*',
    'migration-conflict-resolution_V1.0.1*',
    'superseded-definition*'
)

# --- Contadores ---
$script:Copied   = 0
$script:Removed  = 0
$script:Orphans  = 0
$script:Warnings = 0
$script:Errors   = 0

# =============================================================================
# Funcoes
# =============================================================================

function Resolve-SourceRoot {
    <#
    .SYNOPSIS
        Resolve a raiz do projecto fonte a partir de $PSScriptRoot.
    #>
    $candidate = (Resolve-Path (Join-Path $PSScriptRoot '..\..'))
    $cursorDir = Join-Path $candidate '.cursor'

    if (-not (Test-Path $cursorDir -PathType Container)) {
        Write-Host "[ERRO] Nao foi possivel localizar .cursor/ em: $candidate" -ForegroundColor Red
        exit 2
    }

    return $candidate.Path
}

function Remove-ObsoleteItems {
    <#
    .SYNOPSIS
        Remove pastas e ficheiros obsoletos do .cursor/ destino.
    #>
    param([string]$DestCursor)

    # Pastas obsoletas
    foreach ($dir in $script:ObsoleteDirs) {
        $path = Join-Path $DestCursor $dir
        if (Test-Path -LiteralPath $path) {
            if ($PSCmdlet.ShouldProcess($path, 'Remover pasta obsoleta')) {
                try {
                    Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction Stop
                    Write-Host "  [REMOVIDO] $dir/ (obsoleto)" -ForegroundColor Cyan
                    $script:Removed++
                } catch {
                    Write-Host "  [ERRO]     Nao foi possivel remover ${dir}/: $($_.Exception.Message)" -ForegroundColor Red
                    $script:Errors++
                }
            } else {
                Write-Host "  [WHATIF]   Removeria $dir/ (obsoleto)" -ForegroundColor DarkGray
            }
        }
    }

    # Ficheiros obsoletos
    foreach ($file in $script:ObsoleteFiles) {
        $path = Join-Path $DestCursor $file
        if (Test-Path -LiteralPath $path) {
            if ($PSCmdlet.ShouldProcess($path, 'Remover ficheiro obsoleto')) {
                try {
                    Remove-Item -LiteralPath $path -Force -ErrorAction Stop
                    Write-Host "  [REMOVIDO] $file (obsoleto)" -ForegroundColor Cyan
                    $script:Removed++
                } catch {
                    Write-Host "  [ERRO]     Nao foi possivel remover ${file}: $($_.Exception.Message)" -ForegroundColor Red
                    $script:Errors++
                }
            } else {
                Write-Host "  [WHATIF]   Removeria $file (obsoleto)" -ForegroundColor DarkGray
            }
        }
    }

    # Skills deprecadas
    $skillsDir = Join-Path $DestCursor 'skills'
    if (Test-Path -LiteralPath $skillsDir) {
        foreach ($pattern in $script:DeprecatedSkillPatterns) {
            $matches = Get-ChildItem -Path $skillsDir -Directory -Filter $pattern -ErrorAction SilentlyContinue
            foreach ($match in $matches) {
                if ($PSCmdlet.ShouldProcess($match.FullName, 'Remover skill deprecada')) {
                    try {
                        Remove-Item -LiteralPath $match.FullName -Recurse -Force -ErrorAction Stop
                        Write-Host "  [REMOVIDO] skills/$($match.Name) (deprecada)" -ForegroundColor Cyan
                        $script:Removed++
                    } catch {
                        Write-Host "  [ERRO]     Nao foi possivel remover skills/$($match.Name): $($_.Exception.Message)" -ForegroundColor Red
                        $script:Errors++
                    }
                } else {
                    Write-Host "  [WHATIF]   Removeria skills/$($match.Name) (deprecada)" -ForegroundColor DarkGray
                }
            }
        }
    }
}

function Sync-Directory {
    <#
    .SYNOPSIS
        Sincroniza uma pasta da fonte para o destino via robocopy /MIR.
    #>
    param(
        [string]$SourceDir,
        [string]$DestDir,
        [string]$Label
    )

    if (-not (Test-Path -LiteralPath $SourceDir)) {
        Write-Host "  [N/A]      $Label - pasta fonte nao existe" -ForegroundColor DarkGray
        return
    }

    if ($PSCmdlet.ShouldProcess("$SourceDir -> $DestDir", 'Sincronizar pasta')) {
        if (-not (Test-Path -LiteralPath $DestDir)) {
            New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
        }

        # Usar robocopy /MIR para espelhar (copia + remove orfaos).
        # /IS = re-copia ficheiros "iguais" (forca sobrescrita mesmo com timestamp desalinhado -> elimina residuos).
        # /IT = inclui ficheiros "tweaked" (atributos/seguranca diferentes).
        $robocopyArgs = @(
            $SourceDir, $DestDir,
            '/MIR', '/IS', '/IT', '/NFL', '/NDL', '/NJH', '/NJS', '/NP', '/R:1', '/W:1'
        )

        $result = & robocopy @robocopyArgs
        $exitCode = $LASTEXITCODE

        # robocopy: 0 = nada copiado, 1 = ficheiros copiados, 2 = extras removidos, 3 = ambos
        # >= 8 = erro
        if ($exitCode -ge 8) {
            Write-Host "  [ERRO]     $Label - robocopy falhou (exit=$exitCode)" -ForegroundColor Red
            $script:Errors++
        } elseif ($exitCode -ge 1) {
            Write-Host "  [SYNC]     $Label" -ForegroundColor Green
            $script:Copied++
        } else {
            Write-Host "  [OK]       $Label (sem alteracoes)" -ForegroundColor Green
        }
    } else {
        Write-Host "  [WHATIF]   Sincronizaria $Label" -ForegroundColor DarkGray
    }
}

function Sync-File {
    <#
    .SYNOPSIS
        Copia um ficheiro da fonte para o destino.
    #>
    param(
        [string]$SourceFile,
        [string]$DestFile,
        [string]$Label
    )

    if (-not (Test-Path -LiteralPath $SourceFile)) {
        Write-Host "  [N/A]      $Label - ficheiro fonte nao existe" -ForegroundColor DarkGray
        return
    }

    if ($PSCmdlet.ShouldProcess("$SourceFile -> $DestFile", 'Copiar ficheiro')) {
        $parentDir = Split-Path -Path $DestFile -Parent
        if (-not (Test-Path -LiteralPath $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }

        try {
            Copy-Item -Path $SourceFile -Destination $DestFile -Force -ErrorAction Stop
            Write-Host "  [SYNC]     $Label" -ForegroundColor Green
            $script:Copied++
        } catch {
            Write-Host "  [ERRO]     $Label - $($_.Exception.Message)" -ForegroundColor Red
            $script:Errors++
        }
    } else {
        Write-Host "  [WHATIF]   Copiaria $Label" -ForegroundColor DarkGray
    }
}

function Test-PostCopyCoherence {
    <#
    .SYNOPSIS
        Verifica coerencia pos-copia (referencias a templates quebradas).
    #>
    param([string]$DestCursor)

    $brokenRefs = 0

    # Verificar SKILL.md que referenciam templates/ — a pasta deve existir.
    # So avisa se existir referencia REAL a ficheiro em templates/ (p.ex. './templates/X.md',
    # 'templates/X.md'), nao apenas a palavra 'templates/' em prosa ou em link quebrado.
    $skillFiles = Get-ChildItem -Path (Join-Path $DestCursor 'skills') -Recurse -Filter 'SKILL.md' -ErrorAction SilentlyContinue
    foreach ($sf in $skillFiles) {
        $content = [System.IO.File]::ReadAllText($sf.FullName, [System.Text.Encoding]::UTF8)
        # Padroes reais: ./templates/<file>.<ext>, templates/<file>.<ext> (dentro da propria skill).
        $hasRealRef = $content -match '(?:^|[\s\(\[`])\.?/?templates/[A-Za-z0-9_][A-Za-z0-9_./-]*\.[A-Za-z0-9]+'
        if ($hasRealRef) {
            $skillDir = Split-Path -Path $sf.FullName -Parent
            $templateDir = Join-Path $skillDir 'templates'
            if (-not (Test-Path -LiteralPath $templateDir)) {
                Write-Host "  [AVISO]    $($sf.FullName) referencia templates/ mas pasta nao existe" -ForegroundColor Yellow
                $brokenRefs++
                $script:Warnings++
            }
        }
    }

    # Verificar referencia a .cursor/Templates/ que nao existam.
    # Regex tight: apenas caracteres validos de path (A-Z a-z 0-9 _ . - / ) evita capturar
    # lixo de markdown (backticks, asteriscos, parentheses, etc.).
    # Alem disso, cada match e saneado:
    #   - trim de trailing '/' e markdown chars
    #   - skip se vazio ou se parece ser dentro de codeblock `` ` ``
    $mdFiles = Get-ChildItem -Path $DestCursor -Recurse -Include '*.md', '*.mdc' -ErrorAction SilentlyContinue
    $trimChars = [char[]]@('/', '\', '`', '*', '_', ':', ';', '.', ',', ')', ']', '}', '"', [char]"'", '!', '?', ' ', "`t")
    foreach ($mf in $mdFiles) {
        $content = [System.IO.File]::ReadAllText($mf.FullName, [System.Text.Encoding]::UTF8)
        $regexMatches = [regex]::Matches($content, '\.cursor/Templates/([A-Za-z0-9_][A-Za-z0-9_./\-]*)')
        foreach ($rm in $regexMatches) {
            $raw = $rm.Groups[1].Value
            # Sanitiza trailing markdown noise
            $clean = $raw.TrimEnd($trimChars)
            # Skip: empty after clean, ou terminou em '/' sem nome (ex: 'Templates/')
            if ([string]::IsNullOrWhiteSpace($clean)) { continue }
            if ($clean -match '[`*]') { continue }  # ainda contem markdown -> captura invalida
            # Skip placeholders: '_V' sem versao, 'X_V<x.y.z>', padrao de nome com wildcard.
            if ($clean -match '_V$') { continue }
            if ($clean -match '(?i)TEMPLATE_Docs_README$') { continue }
            # Skip se for apenas um segmento sem '.' (directorio top-level referenciado sem ficheiro)
            # Ainda assim verificamos se directorio existe — deixamos cair.

            $refPath = Join-Path $DestCursor "Templates\$clean"
            $refPath = $refPath -replace '/', '\'
            $refPath = $refPath.TrimEnd($trimChars)

            if (-not (Test-Path -LiteralPath $refPath -ErrorAction SilentlyContinue)) {
                $relativeMd = $mf.FullName.Replace($DestCursor, '').TrimStart('\', '/')
                Write-Host ('  [AVISO]    ' + $relativeMd + ' referencia Templates/' + $clean + ' - verificar') -ForegroundColor Yellow
                $brokenRefs++
                $script:Warnings++
            }
        }
    }

    return $brokenRefs
}

function Invoke-PostSyncValidation {
    <#
    .SYNOPSIS
        Executa validate_pack.py --no-instance-strings no destino para
        detectar residuos (paths absolutos, literais MXX concretos, nome
        de clones especificos).
    #>
    param([string]$DestRoot)

    $validate = Join-Path $DestRoot '.cursor/scripts/validate_pack.py'
    if (-not (Test-Path -LiteralPath $validate)) {
        Write-Host '  [SKIP]     validate_pack.py nao encontrado no destino' -ForegroundColor DarkGray
        return 0
    }

    Push-Location $DestRoot
    try {
        $output = & python '.cursor/scripts/validate_pack.py' '--no-instance-strings' 2>&1
        $exitCode = $LASTEXITCODE
        if ($exitCode -eq 0) {
            Write-Host '  [OK]       validate_pack --no-instance-strings: PASS' -ForegroundColor Green
            return 0
        } else {
            Write-Host "  [AVISO]    validate_pack --no-instance-strings: FALHOU (exit=$exitCode)" -ForegroundColor Yellow
            $output | ForEach-Object { Write-Host "             $_" -ForegroundColor Yellow }
            $script:Warnings++
            return $exitCode
        }
    } finally {
        Pop-Location
    }
}

function Invoke-PostSyncReindex {
    <#
    .SYNOPSIS
        Regenera .cursor/index.db no destino apos sync.
    #>
    param([string]$DestRoot)

    $indexer = Join-Path $DestRoot '.cursor/scripts/pack_index_db.py'
    if (-not (Test-Path -LiteralPath $indexer)) {
        Write-Host '  [SKIP]     pack_index_db.py nao encontrado no destino' -ForegroundColor DarkGray
        return
    }

    Push-Location $DestRoot
    try {
        $null = & python '.cursor/scripts/pack_index_db.py' '--scan' 'cursor' 2>&1
        $exitCode = $LASTEXITCODE
        if ($exitCode -eq 0) {
            Write-Host '  [OK]       index.db regenerado (scope=cursor)' -ForegroundColor Green
        } else {
            Write-Host "  [AVISO]    pack_index_db --scan cursor falhou (exit=$exitCode)" -ForegroundColor Yellow
            $script:Warnings++
        }
    } finally {
        Pop-Location
    }
}

# =============================================================================
# Main
# =============================================================================

Write-Host ''
Write-Host '================================================================' -ForegroundColor Cyan
Write-Host '  sync-cursor-pack  -  Sincronizacao do pack .cursor/' -ForegroundColor Cyan
Write-Host '================================================================' -ForegroundColor Cyan
Write-Host ''

# 1. Resolver fonte
$SourceRoot = Resolve-SourceRoot
$SourceCursor = Join-Path $SourceRoot '.cursor'
Write-Host "[OK] Fonte: $SourceRoot" -ForegroundColor Green
Write-Host ''

# 2. Processar cada destino
foreach ($destPath in $DestinationPaths) {
    $destPath = $destPath.TrimEnd('\', '/')

    Write-Host '----------------------------------------------------------------' -ForegroundColor White
    Write-Host "  Destino: $destPath" -ForegroundColor White
    Write-Host '----------------------------------------------------------------' -ForegroundColor White

    if (-not (Test-Path -LiteralPath $destPath -PathType Container)) {
        Write-Host "  [ERRO] Caminho nao encontrado: $destPath" -ForegroundColor Red
        $script:Errors++
        continue
    }

    $destCursor = Join-Path $destPath '.cursor'
    if (-not (Test-Path -LiteralPath $destCursor)) {
        if ($PSCmdlet.ShouldProcess($destCursor, 'Criar pasta .cursor')) {
            New-Item -ItemType Directory -Path $destCursor -Force | Out-Null
            Write-Host '  [CRIADO]   .cursor/' -ForegroundColor Green
        }
    }

    # 2a. Remover itens obsoletos
    Write-Host ''
    Write-Host '  --- Remocao de itens obsoletos ---' -ForegroundColor Cyan
    Remove-ObsoleteItems -DestCursor $destCursor

    # 2b. Sincronizar pastas
    Write-Host ''
    Write-Host '  --- Sincronizacao de pastas ---' -ForegroundColor Cyan
    foreach ($dir in $script:PackDirs) {
        $srcDir  = Join-Path $SourceCursor $dir
        $dstDir  = Join-Path $destCursor $dir
        Sync-Directory -SourceDir $srcDir -DestDir $dstDir -Label $dir
    }

    # 2c. Sincronizar ficheiros
    Write-Host ''
    Write-Host '  --- Sincronizacao de ficheiros ---' -ForegroundColor Cyan
    foreach ($file in $script:PackFiles) {
        $srcFile = Join-Path $SourceCursor $file
        $dstFile = Join-Path $destCursor $file
        Sync-File -SourceFile $srcFile -DestFile $dstFile -Label $file
    }

    # 2d. Verificacao de coerencia
    Write-Host ''
    Write-Host '  --- Verificacao de coerencia ---' -ForegroundColor Cyan
    $brokenCount = Test-PostCopyCoherence -DestCursor $destCursor
    if ($brokenCount -eq 0) {
        Write-Host '  [OK]       Sem referencias quebradas detectadas' -ForegroundColor Green
    } else {
        Write-Host "  [AVISO]    $brokenCount referencia(s) potencialmente quebrada(s)" -ForegroundColor Yellow
    }

    # 2e. Regenerar index.db no destino (scope=cursor)
    if (-not $SkipReindex) {
        Write-Host ''
        Write-Host '  --- Regeneracao de index.db ---' -ForegroundColor Cyan
        Invoke-PostSyncReindex -DestRoot $destPath
    }

    # 2f. Validacao pos-sync (deteccao de residuos)
    if (-not $SkipValidate) {
        Write-Host ''
        Write-Host '  --- Validacao pos-sync (residuos) ---' -ForegroundColor Cyan
        $null = Invoke-PostSyncValidation -DestRoot $destPath
    }

    Write-Host ''
}

# 3. Sumario
Write-Host ''
Write-Host '=== Sumario ===' -ForegroundColor Cyan
Write-Host "  Pastas/ficheiros sincronizados: $($script:Copied)" -ForegroundColor Green
Write-Host "  Itens obsoletos removidos:      $($script:Removed)" -ForegroundColor Cyan
Write-Host "  Avisos:                         $($script:Warnings)" -ForegroundColor Yellow
Write-Host "  Erros:                          $($script:Errors)" -ForegroundColor Red
Write-Host ''

if ($script:Errors -gt 0) {
    Write-Host '  Sincronizacao concluida com erros.' -ForegroundColor Red
    exit 4
} elseif ($script:Warnings -gt 0) {
    Write-Host '  Sincronizacao concluida com avisos.' -ForegroundColor Yellow
    exit 3
} else {
    Write-Host '  Sincronizacao concluida com sucesso.' -ForegroundColor Green
    exit 0
}

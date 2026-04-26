<#
.SYNOPSIS
    Bootstrap dos espelhos (.claude/, .vscode/, .continue/, .opencode/) via ligacoes simbolicas
    para .cursor/.

.DESCRIPTION
    Cria pastas espelho e ligacoes simbolicas (symlinks) de .cursor/ para os
    directorios .claude/, .vscode/, .continue/ e .opencode/, permitindo que Claude Code,
    VS Code, Continue.dev e OpenCode acedam ao mesmo conteudo (skills, rules, agents, etc.)
    sem duplicacao.

    Distingue symlink/junction (reparse point) de pasta/ficheiro real via Get-Item -LiteralPath.
    Se o link ja existir e apontar para .cursor: nao recria. Se existir pasta/ficheiro real no
    caminho: sincroniza o conteudo com .cursor/ via robocopy (diretorios) ou Copy-Item (ficheiros).

    Em caminhos de rede (UNC ou drive mapeado) symlinks nao sao suportados pelo Windows;
    o script detecta automaticamente este caso e usa copia/sincronizacao (robocopy /MIR).

    Symlinks criados em caminhos locais dentro do repositorio usam alvos relativos
    (ex.: ..\.cursor\skills); caminhos externos usam alvos absolutos.

    Requer privilegios de Administrador ou Modo de Programador do Windows (apenas em modo local).
    Sem privilegios de Administrador, o script tenta reabrir-se automaticamente
    via UAC (RunAs), salvo com -NoElevation. Em modo rede, elevacao nao e necessaria.

.PARAMETER ValidateOnly
    Verificar estado dos symlinks sem criar nem alterar nada.

.PARAMETER Repair
    Corrigir symlinks quebrados (alvo incorrecto ou inexistente).

.PARAMETER Force
    Alem de -Repair: substituir symlink/junction com alvo incorrecto (remove e recria).
    Pastas/ficheiros reais a bloquear sao sempre renomeados com sufixo .yyyyMMdd_HHmmss (nao precisa de -Force).

.PARAMETER NoElevation
    Nao solicitar UAC; aplica a verificacao classica (Admin ou Modo Programador + teste de symlink).

.PARAMETER FromElevation
    Uso interno: indicador apos relancamento elevado (nao repetir RunAs).

.EXAMPLE
    .\bootstrap-mirror-symlinks.ps1
    Cria todos os symlinks em falta.

.EXAMPLE
    .\bootstrap-mirror-symlinks.ps1 -ValidateOnly
    Verifica estado dos symlinks e reporta.

.EXAMPLE
    .\bootstrap-mirror-symlinks.ps1 -Repair -Force
    Repara symlinks quebrados e substitui ficheiros reais (backup automatico).

.EXAMPLE
    .\bootstrap-mirror-symlinks.ps1 -NoElevation
    Nao abre UAC; util apenas se ja tiver Modo Programador com symlinks funcionais.
#>

# internal_file_version: 1.1.7
# Changelog (este arquivo):
# - 1.1.7 (09/04/2026): New-MirrorSymlinkCreateOnly — Push-Location para o directorio
#   pai do link antes de New-Item SymbolicLink; New-Item resolve targets relativos contra
#   o CWD do processo (C:\Windows\System32 em sessoes elevadas), causando alvos errados
#   como C:\Windows\.cursor\agents em vez de E:\repo\.cursor\agents.
# - 1.1.6 (09/04/2026): Invoke-BootstrapRelaunchElevated — adicionado -WorkingDirectory
#   $scriptWorkDir ao Start-Process; sem este parametro a sessao elevada iniciava em
#   C:\WINDOWS\ tornando $PSScriptRoot e $PSCommandPath incorrectos.
# - 1.1.5 (09/04/2026): Resolve-RepoRoot — usa $script:ThisScriptPath (capturado antes
#   de Set-StrictMode) em vez de $PSScriptRoot; $PSScriptRoot resolvia para C:\WINDOWS\
#   em sessoes relancadas via UAC, causando caminhos errados para os symlinks.
# - 1.1.4 (09/04/2026): Get-MirrorConfig — carrega .cursor/config.json para determinar
#   mirrors activos; Get-SymlinkMappings usa mirrors do config; Install-MirrorConfigTemplate
#   filtra configMappings por IA habilitada (campo MirrorDir); Invoke-ValidationChecklist
#   usa enabledMirrors do config nos checks V2-V5/V12; V7 (.claude/plans) condicional.
# - 1.1.3 (09/04/2026): ConvertTo-MappedDrive — se caminho UNC sem mapeamento existente,
#   cria New-PSDrive temporario (letra livre Z->T) e converte o caminho; drive removido
#   em Invoke-FinalExit; Resolve-RepoRoot usa Invoke-FinalExit em vez de exit directo.
# - 1.1.2 (09/04/2026): Resolve-RepoRoot — usa [IO.Path]::GetFullPath em vez de
#   Resolve-Path (que em sessao elevada devolve prefixo PSProvider e nao resolve ..);
#   normaliza UNC para drive mapeado via Get-PSDrive; strip do prefixo FileSystem::.
# - 1.1.1 (09/04/2026): Get-SymlinkTargetPath corrigido — [Uri]::new() requer prefixo
#   "file:///" para caminhos Windows (sem o prefixo lancava UriFormatException, catch
#   silencioso causava fallback para caminho absoluto em todos os casos); substituidas
#   expressoes "if" inline em atribuicoes por blocos if/else padrao (seguranca PS5.1).
# - 1.1.0 (09/04/2026): Modo rede (Test-IsNetworkPath) — copiar/sincronizar via robocopy
#   em vez de symlinks; Sync-MirrorContent para copia de diretorios e ficheiros;
#   Get-SymlinkTargetPath — symlinks relativos para destinos dentro do repo (absolutos
#   fora); conteudo real existente nao-vazio -> Sync-MirrorContent (sem backup+symlink);
#   Invoke-FinalExit — pausa se erro em janela UAC (-FromElevation), fecha automaticamente
#   se sucesso; elevacao ignorada em modo rede; Test-MirrorEntryOk para checklist
#   ValidateOnly em modo rede; Install-MirrorConfigTemplate usa .Replace() com escape
#   JSON para paths Windows ({REPO_ROOT} -> double-backslash em destinos .json).
# - 1.0.4 (04/04/2026): VERSION.md restaurado em $fileMappings (removido por
#   engano na v1.0.3); checklist V5 verifica VERSION.md + README.md; pasta real
#   vazia tratada como artefacto (removida antes de criar symlink); verificacao
#   pos-criacao garante que New-Item criou symlink real (nao pasta por fallback).
# - 1.0.3 (04/04/2026): Migracao Fase 8c — $dirMappings: removidos 'Constitution' e
#   'Developer' (extintos); adicionado 'commands' (nova pasta). $fileMappings: removidos
#   compile.md, database.md, diretivas_compilacao.md, SKILLS_DOCUMENTATION_v3.0.8.md,
#   VERSION.md (todos migrados para skills). readmeMappings mantido (README.md unico
#   ficheiro na raiz de .cursor/). Checklist V2-V4 e V5 actualizados para reflectir
#   as novas listas. Mensagem de erro na funcao Test-AdminElevation actualizada
#   (removida referencia a Constitution/Developer).
# - 1.0.2 (04/04/2026): Removido vscode-tasks.template.json de Install-MirrorConfigTemplate
#   — gerido exclusivamente pelo bootstrap-autostart-mirrors.ps1 (Install-TasksTemplate).
# - 1.0.1 (04/04/2026): Corrigidas 5 chamadas Split-Path -LiteralPath ... -Parent/-Leaf
#   incompativeis com PowerShell 5.1 (parameter sets distintos); substituido -LiteralPath
#   por -Path nas linhas afetadas. Erro impedia criacao de symlinks via UAC (RunAs).
# - 1.0.0 (04/04/2026): Versao inicial com versionamento interno. Suporte a
#   .claude/, .vscode/, .continue/ e .opencode/; elevacao UAC; -ValidateOnly,
#   -Repair, -Force; checklist de validacao V1-V12; templates de config.

[CmdletBinding()]
param(
    [switch]$ValidateOnly,
    [switch]$Repair,
    [switch]$Force,
    [switch]$NoElevation,
    [switch]$FromElevation
)

# Caminho deste .ps1 (para RunAs relancar o ficheiro correcto)
$script:ThisScriptPath = $PSCommandPath
if ([string]::IsNullOrWhiteSpace($script:ThisScriptPath)) {
    $script:ThisScriptPath = $MyInvocation.MyCommand.Path
}

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

# --- Contadores globais ---
$script:Created       = 0
$script:Ok            = 0
$script:Skipped       = 0
$script:Repaired      = 0
$script:Conflicts     = 0
$script:Errors        = 0
$script:IsNetworkMode = $false
# --- Drive temporario criado por ConvertTo-MappedDrive (removido em Invoke-FinalExit) ---
$script:TempDriveName = $null

# --- Ficheiros de configuracao protegidos (nunca substituir por symlink) ---
$script:ProtectedFiles = @(
    '.vscode\settings.json',
    '.vscode\tasks.json',
    '.vscode\extensions.json',
    '.claude\settings.json',
    '.claude\settings.local.json'
)

# =============================================================================
# Funcoes
# =============================================================================

function Get-MirrorConfig {
    <#
    .SYNOPSIS
        Carrega .cursor/config.json e devolve estrutura com mirrors habilitados.
        Fallback ao conjunto completo se config ausente ou invalido.
    #>
    param([string]$RepoRoot)
    $default = @{
        EnabledDirs = @('.claude', '.vscode', '.continue', '.opencode')
        RootFiles   = @('CLAUDE.md', 'opencode.json')
        HasVscode   = $true
        HasClaude   = $true
    }
    $configPath = Join-Path $RepoRoot '.cursor\config.json'
    if (-not (Test-Path $configPath)) { return $default }
    try {
        $cfg = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if (-not $cfg.ias) { return $default }
        $dirs = @(); $files = @(); $hasVscode = $false; $hasClaude = $false
        foreach ($prop in $cfg.ias.PSObject.Properties) {
            $ia = $prop.Value
            if ($ia.enabled -ne $true) { continue }
            if ($ia.mirrorDir) { $dirs += $ia.mirrorDir }
            if ($ia.mirrorDir -eq '.vscode') { $hasVscode = $true }
            if ($ia.mirrorDir -eq '.claude')  { $hasClaude = $true }
            if ($ia.rootFiles) { foreach ($f in $ia.rootFiles) { $files += $f } }
        }
        if ($dirs.Count -eq 0) { return $default }
        return @{ EnabledDirs = $dirs; RootFiles = $files; HasVscode = $hasVscode; HasClaude = $hasClaude }
    } catch {
        return $default
    }
}

function Invoke-FinalExit {
    <#
    .SYNOPSIS
        Encerra o script com o codigo indicado.
        Remove drive temporario criado por ConvertTo-MappedDrive (se existir).
        Se estiver a correr numa janela elevada (-FromElevation) e houver erro,
        pausa para o utilizador ler a mensagem antes de fechar a janela.
    #>
    param([int]$Code)
    # Remover drive temporario se foi criado nesta sessao
    if (-not [string]::IsNullOrEmpty($script:TempDriveName)) {
        Remove-PSDrive -Name $script:TempDriveName -Force -ErrorAction SilentlyContinue
        $script:TempDriveName = $null
    }
    if ($FromElevation -and $Code -ne 0) {
        Write-Host ''
        Write-Host '  Pressione Enter para fechar esta janela...' -ForegroundColor Yellow
        $null = Read-Host
    }
    exit $Code
}

function Test-IsWindowsAdministrator {
    <#
    .SYNOPSIS
        True se o token actual tiver a role BuiltinAdministrators (elevado ou nao).
    #>
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}

function Test-IsNetworkPath {
    <#
    .SYNOPSIS
        True se o caminho estiver numa localizacao de rede (UNC ou drive mapeado de rede).
        Em caminhos de rede o Windows nao suporta symlinks — usar modo copia.
    #>
    param([string]$Path)
    # Caminho UNC (\\servidor\share\...)
    if ($Path -match '^\\\\') { return $true }
    # Drive mapeado para rede
    $qualifier = Split-Path -Qualifier $Path -ErrorAction SilentlyContinue
    if ($qualifier) {
        try {
            $di = [System.IO.DriveInfo]::new($qualifier)
            if ($di.DriveType -eq [System.IO.DriveType]::Network) { return $true }
        } catch { }
    }
    return $false
}

function Invoke-BootstrapRelaunchElevated {
    <#
    .SYNOPSIS
        Relanca este script com Start-Process -Verb RunAs (UAC).
    #>
    $scriptPath = $script:ThisScriptPath
    if (-not $scriptPath -or -not (Test-Path -LiteralPath $scriptPath)) {
        Write-Host '[ERRO] Nao foi possivel determinar o caminho do script para elevacao.' -ForegroundColor Red
        exit 1
    }

    $hostExe = (Get-Process -Id $PID -ErrorAction SilentlyContinue).Path
    if (-not $hostExe -or -not (Test-Path -LiteralPath $hostExe)) {
        $hostExe = if ($PSVersionTable.PSEdition -eq 'Core') { 'pwsh.exe' } else { 'powershell.exe' }
    }

    $argList = [System.Collections.Generic.List[string]]::new()
    $argList.Add('-NoProfile')
    $argList.Add('-ExecutionPolicy')
    $argList.Add('Bypass')
    $argList.Add('-File')
    $argList.Add($scriptPath)
    $argList.Add('-FromElevation')
    if ($Repair) { $argList.Add('-Repair') }
    if ($Force) { $argList.Add('-Force') }

    Write-Host ''
    Write-Host '[INFO] Privilegios de Administrador necessarios para criar symlinks.' -ForegroundColor Cyan
    Write-Host '[INFO] A solicitar elevacao (UAC)  -  confirme na janela do Windows.' -ForegroundColor Cyan
    Write-Host ''

    # Passar o directorio de trabalho para que $PSCommandPath e $PSScriptRoot
    # resolvam correctamente na sessao elevada (sem -WorkingDirectory o processo
    # elevado inicia em C:\WINDOWS\ e $PSScriptRoot fica incorrecto).
    $scriptWorkDir = [System.IO.Path]::GetDirectoryName($scriptPath)

    try {
        $p = Start-Process -FilePath $hostExe -Verb RunAs -ArgumentList $argList.ToArray() `
            -WorkingDirectory $scriptWorkDir -PassThru -Wait
        if ($null -eq $p) {
            exit 1
        }
        exit $p.ExitCode
    } catch {
        Write-Host ('[ERRO] Elevacao cancelada ou falhou: ' + $_.Exception.Message) -ForegroundColor Red
        exit 1
    }
}

function Test-AdminElevation {
    <#
    .SYNOPSIS
        Verifica se o processo tem privilegios de Administrador ou Modo de Programador.
    #>
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )

    $devMode = $false
    try {
        $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
        if (Test-Path $regPath) {
            $val = Get-ItemProperty -Path $regPath -Name 'AllowDevelopmentWithoutDevLicense' -ErrorAction SilentlyContinue
            if ($val -and $val.AllowDevelopmentWithoutDevLicense -eq 1) {
                $devMode = $true
            }
        }
    } catch {
        # Chave nao existe  -  ignorar
    }

    if (-not $isAdmin -and -not $devMode) {
        Write-Host ''
        Write-Host '  ============================================================' -ForegroundColor Red
        Write-Host '  ERRO: Este script requer privilegios de Administrador' -ForegroundColor Red
        Write-Host '        para criar ligacoes simbolicas.' -ForegroundColor Red
        Write-Host '  ============================================================' -ForegroundColor Red
        Write-Host ''
        Write-Host '  Accoes possiveis:' -ForegroundColor Yellow
        Write-Host '    1. Abrir o Cursor / terminal como Administrador' -ForegroundColor Yellow
        Write-Host '       (botao direito > Executar como administrador).' -ForegroundColor Yellow
        Write-Host '    2. Activar o Modo de Programador do Windows' -ForegroundColor Yellow
        Write-Host '       (Definicoes > Privacidade e seguranca > Para programadores).' -ForegroundColor Yellow
        Write-Host '    3. Contactar o suporte da equipa se nenhuma opcao' -ForegroundColor Yellow
        Write-Host '       estiver disponivel.' -ForegroundColor Yellow
        Write-Host ''
        Write-Host '  Sem elevacao, skills, rules, agents, commands' -ForegroundColor Gray
        Write-Host '  e Templates de .cursor/ NAO estarao acessiveis via espelhos' -ForegroundColor Gray
        Write-Host '  (.claude/, .vscode/, .continue/, .opencode/).' -ForegroundColor Gray
        Write-Host ''
        exit 1
    }

    if ($isAdmin) {
        Write-Host '[OK] Privilegios de Administrador detectados.' -ForegroundColor Green
    } elseif ($devMode) {
        Write-Host '[INFO] Modo de Programador detectado  -  a verificar capacidade de criar symlinks...' -ForegroundColor Cyan
        # Testar criacao real de symlink (DevMode pode nao ser suficiente em IoT/LTSC)
        $testDir = Join-Path $env:TEMP "symlink_test_$(Get-Random)"
        $testLink = "${testDir}_link"
        try {
            New-Item -ItemType Directory -Path $testDir -Force | Out-Null
            New-Item -ItemType SymbolicLink -Path $testLink -Target $testDir -Force -ErrorAction Stop | Out-Null
            Remove-Item $testLink -Force
            Remove-Item $testDir -Force
            Write-Host '[OK] Modo de Programador  -  symlinks funcionais.' -ForegroundColor Green
        } catch {
            Remove-Item $testDir -Force -ErrorAction SilentlyContinue
            Write-Host ''
            Write-Host '  ============================================================' -ForegroundColor Red
            Write-Host '  ERRO: Modo de Programador activo mas insuficiente para' -ForegroundColor Red
            Write-Host '        criar symlinks nesta edicao do Windows.' -ForegroundColor Red
            Write-Host '  ============================================================' -ForegroundColor Red
            Write-Host ''
            Write-Host '  Esta edicao do Windows (IoT Enterprise / LTSC) requer' -ForegroundColor Yellow
            Write-Host '  privilegios de Administrador para ligacoes simbolicas.' -ForegroundColor Yellow
            Write-Host ''
            Write-Host '  Abrir o Cursor / terminal como Administrador' -ForegroundColor Yellow
            Write-Host '  (botao direito > Executar como administrador).' -ForegroundColor Yellow
            Write-Host ''
            exit 1
        }
    }
}

function ConvertTo-MappedDrive {
    <#
    .SYNOPSIS
        Normaliza um caminho UNC para letra de unidade:
        1. Remove prefixo PSProvider se presente.
        2. Verifica drives existentes (incluindo DisplayRoot) para mapeamento compativel.
        3. Se nenhum mapeamento existir, cria New-PSDrive temporario (letra livre Z->T)
           e armazena o nome em $script:TempDriveName para remocao em Invoke-FinalExit.
        Seguro em sessao elevada onde drives de rede podem nao estar mapeados.
    #>
    param([string]$Path)

    # 1. Strip do prefixo PSProvider (ex: "Microsoft.PowerShell.Core\FileSystem::")
    if ($Path -match '^[^:]+::(.+)$') { $Path = $Matches[1] }

    # Nao e UNC — nao precisa de conversao
    if ($Path -notmatch '^\\\\') { return $Path }

    # 2. Verificar drives existentes com DisplayRoot (mapeamentos de rede)
    $drives = Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue |
              Where-Object { -not [string]::IsNullOrEmpty($_.DisplayRoot) }
    foreach ($drv in $drives) {
        $unc = $drv.DisplayRoot.TrimEnd('\')
        if ($Path.StartsWith($unc, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $drv.Root.TrimEnd('\') + $Path.Substring($unc.Length)
        }
    }

    # 3. Sem mapeamento existente — extrair raiz UNC (\\servidor\share) e criar drive temp
    if ($Path -match '^(\\\\[^\\]+\\[^\\]+)(\\.*)?$') {
        $shareRoot = $Matches[1]           # ex: \\192.168.1.100\Projetos
        $remainder = if ($Matches[2]) { $Matches[2] } else { '' }

        # Encontrar letra livre (Z -> T, evita colidir com drives comuns)
        $usedLetters = (Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue).Name
        $tempLetter  = $null
        foreach ($letter in @('Z','Y','X','W','V','U','T')) {
            if ($usedLetters -notcontains $letter) { $tempLetter = $letter; break }
        }

        if ($tempLetter) {
            try {
                New-PSDrive -Name $tempLetter -PSProvider FileSystem -Root $shareRoot `
                            -Scope Global -ErrorAction Stop | Out-Null
                $script:TempDriveName = $tempLetter
                Write-Host "  [INFO]     Drive temporario criado: ${tempLetter}: -> $shareRoot" -ForegroundColor DarkCyan
                return $tempLetter + ':' + $remainder
            } catch {
                Write-Host "  [AVISO]    Nao foi possivel criar drive temporario para $shareRoot : $($_.Exception.Message)" -ForegroundColor Yellow
            }
        } else {
            Write-Host '  [AVISO]    Nenhuma letra livre disponivel (T-Z) para drive temporario.' -ForegroundColor Yellow
        }
    }

    # Fallback: retornar caminho UNC sem conversao
    return $Path
}

function Resolve-RepoRoot {
    <#
    .SYNOPSIS
        Resolve a raiz do repositorio a partir do caminho real do script.
        Usa $script:ThisScriptPath (capturado antes de Set-StrictMode) para
        garantir o caminho correcto mesmo em sessoes elevadas via UAC onde
        $PSScriptRoot pode resolver para C:\WINDOWS\.
        Usa [IO.Path]::GetFullPath para resolver ".." sem depender de
        Resolve-Path (que em sessao elevada devolve prefixo PSProvider).
    #>
    # Preferir $script:ThisScriptPath (caminho real do ficheiro .ps1)
    # $PSScriptRoot pode ser C:\WINDOWS\ em sessoes UAC relancadas
    $scriptDir = $null
    if (-not [string]::IsNullOrWhiteSpace($script:ThisScriptPath)) {
        $scriptDir = [System.IO.Path]::GetDirectoryName($script:ThisScriptPath)
    }
    if ([string]::IsNullOrWhiteSpace($scriptDir) -or -not (Test-Path $scriptDir -PathType Container)) {
        $scriptDir = $PSScriptRoot
    }
    $raw       = Join-Path $scriptDir '..\..'
    $resolved  = [System.IO.Path]::GetFullPath($raw)
    $resolved  = ConvertTo-MappedDrive -Path $resolved
    $cursorDir = Join-Path $resolved '.cursor'

    if (-not (Test-Path $cursorDir -PathType Container)) {
        Write-Host "[ERRO] Nao foi possivel localizar .cursor/ em: $resolved" -ForegroundColor Red
        Invoke-FinalExit -Code 2
    }

    return $resolved
}

function Get-SymlinkMappings {
    <#
    .SYNOPSIS
        Retorna a lista de todos os mappings de symlinks a criar.
    #>
    param([string]$RepoRoot)

    $mirrors = (Get-MirrorConfig -RepoRoot $RepoRoot).EnabledDirs

    # Directorios de .cursor/ a espelhar
    $dirMappings = @(
        'agents', 'commands', 'plans', 'rules', 'skills', 'Templates'
    )

    # Ficheiros de .cursor/ a espelhar
    $fileMappings = @(
        'VERSION.md'
    )

    # Ficheiros opcionais (so se existirem)
    $optionalFileMappings = @(
        @{ Source = 'Documentation\ROTEIROS_CONSOLIDADO.md'; Name = 'ROTEIROS_CONSOLIDADO.md' },
        @{ Source = 'Documentation\LOGICA_DATABASE.md';      Name = 'LOGICA_DATABASE.md' }
    )

    # Symlink do README.md do .cursor para cada mirror
    $readmeMappings = @(
        @{ Source = '.cursor\README.md'; Name = 'README.md' }
    )

    $result = @()

    foreach ($mirror in $mirrors) {
        # Directorios
        foreach ($dir in $dirMappings) {
            $result += [PSCustomObject]@{
                Source   = Join-Path $RepoRoot ".cursor\$dir"
                LinkPath = Join-Path $RepoRoot "$mirror\$dir"
                Type     = 'Directory'
                Optional = $false
                Mirror   = $mirror
            }
        }

        # Ficheiros de .cursor/
        foreach ($file in $fileMappings) {
            $result += [PSCustomObject]@{
                Source   = Join-Path $RepoRoot ".cursor\$file"
                LinkPath = Join-Path $RepoRoot "$mirror\$file"
                Type     = 'File'
                Optional = $false
                Mirror   = $mirror
            }
        }

        # README.md
        foreach ($rm in $readmeMappings) {
            $result += [PSCustomObject]@{
                Source   = Join-Path $RepoRoot $rm.Source
                LinkPath = Join-Path $RepoRoot "$mirror\$($rm.Name)"
                Type     = 'File'
                Optional = $false
                Mirror   = $mirror
            }
        }

        # Ficheiros opcionais
        foreach ($opt in $optionalFileMappings) {
            $result += [PSCustomObject]@{
                Source   = Join-Path $RepoRoot $opt.Source
                LinkPath = Join-Path $RepoRoot "$mirror\$($opt.Name)"
                Type     = 'File'
                Optional = $true
                Mirror   = $mirror
            }
        }
    }

    return $result
}

function Test-IsProtected {
    <#
    .SYNOPSIS
        Verifica se um path esta na lista de ficheiros protegidos.
    #>
    param([string]$RepoRoot, [string]$LinkPath)

    $relativePath = $LinkPath.Replace($RepoRoot, '').TrimStart('\', '/')
    foreach ($protected in $script:ProtectedFiles) {
        if ($relativePath -eq $protected) {
            return $true
        }
    }
    return $false
}

function Resolve-SourcePathFull {
    <#
    .SYNOPSIS
        Caminho completo normalizado da fonte do symlink.
    #>
    param([string]$Source)
    try {
        $rp = Resolve-Path -LiteralPath $Source -ErrorAction Stop
        return [System.IO.Path]::GetFullPath($rp.Path)
    } catch {
        return $null
    }
}

function Test-IsFilesystemReparseLink {
    <#
    .SYNOPSIS
        True se a entrada for symlink, junction ou outro reparse point (nao e ficheiro/pasta "real").
    #>
    param($Item)
    if ($null -eq $Item) { return $false }
    if ($Item.LinkType -eq 'SymbolicLink' -or $Item.LinkType -eq 'Junction') { return $true }
    if ($Item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { return $true }
    return $false
}

function Get-SymlinkItemTargetFullPath {
    <#
    .SYNOPSIS
        Target declarado no link, como caminho absoluto normalizado.
    #>
    param([string]$LinkPath, $Item)
    if ($null -eq $Item) { return $null }
    $raw = $Item.Target
    if ($null -eq $raw) { return $null }
    if ($raw -is [array]) { $raw = $raw[0] }
    $candidate = [string]$raw
    if ([string]::IsNullOrWhiteSpace($candidate)) { return $null }
    if (-not [System.IO.Path]::IsPathRooted($candidate)) {
        $candidate = Join-Path (Split-Path -Path $LinkPath -Parent) $candidate
    }
    try {
        return [System.IO.Path]::GetFullPath($candidate)
    } catch {
        return $candidate
    }
}

function Test-SymlinkItemMatchesSource {
    <#
    .SYNOPSIS
        True se o link (symlink/junction) aponta para a mesma localizacao que Source.
    #>
    param([string]$LinkPath, $Item, [string]$Source)
    $expected = Resolve-SourcePathFull -Source $Source
    if ([string]::IsNullOrWhiteSpace($expected)) { return $false }

    $declared = Get-SymlinkItemTargetFullPath -LinkPath $LinkPath -Item $Item
    if (-not [string]::IsNullOrWhiteSpace($declared)) {
        if ([string]::Equals($expected, $declared, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }

    try {
        $resolved = [System.IO.Path]::GetFullPath((Resolve-Path -LiteralPath $LinkPath -ErrorAction Stop).Path)
        if ([string]::Equals($expected, $resolved, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    } catch {
        # alvo inacessivel ou link quebrado
    }
    return $false
}

function Backup-RealPathWithTimestamp {
    <#
    .SYNOPSIS
        Renomeia ficheiro ou pasta real (nao link) para <nome>.yyyyMMdd_HHmmss[_n].
    #>
    param([string]$Path)
    $parent = Split-Path -Path $Path -Parent
    $leaf = Split-Path -Path $Path -Leaf
    $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $newName = "${leaf}.${stamp}"
    $dest = Join-Path $parent $newName
    $i = 0
    while (Test-Path -LiteralPath $dest) {
        $i++
        $dest = Join-Path $parent "${leaf}.${stamp}_${i}"
    }
    $finalLeaf = Split-Path -Path $dest -Leaf
    Rename-Item -LiteralPath $Path -NewName $finalLeaf -Force
    return $finalLeaf
}

function Get-SymlinkTargetPath {
    <#
    .SYNOPSIS
        Devolve o caminho do alvo do symlink: relativo se source esta dentro do repo
        e no mesmo drive que LinkPath; absoluto caso contrario.
        Compativel com PS 5.1 / .NET Framework (usa Uri.MakeRelativeUri).
        Nota: [Uri]::new() requer prefixo file:/// para caminhos Windows — sem o prefixo
        lanca UriFormatException (caminho Windows nao e URI valido).
    #>
    param([string]$Source, [string]$LinkPath, [string]$RepoRoot)
    $srcDrive  = Split-Path -Qualifier $Source  -ErrorAction SilentlyContinue
    $linkDrive = Split-Path -Qualifier $LinkPath -ErrorAction SilentlyContinue
    if ($srcDrive -and $linkDrive -and
        [string]::Equals($srcDrive, $linkDrive, [System.StringComparison]::OrdinalIgnoreCase) -and
        $Source.StartsWith($RepoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        $linkParent = Split-Path -Path $LinkPath -Parent
        try {
            $fromSlash = $linkParent.TrimEnd('\') -replace '\\', '/'
            $toSlash   = $Source -replace '\\', '/'
            $fromUri   = [Uri]::new("file:///$fromSlash/")
            $toUri     = [Uri]::new("file:///$toSlash")
            $rel = [Uri]::UnescapeDataString($fromUri.MakeRelativeUri($toUri).ToString())
            return ($rel -replace '/', '\')
        } catch { }
    }
    return $Source   # fallback: caminho absoluto
}

function Sync-MirrorContent {
    <#
    .SYNOPSIS
        Sincroniza source para DestPath (modo rede ou conteudo real existente).
        Diretorios: robocopy /MIR. Ficheiros: Copy-Item -Force.
    #>
    param(
        [string]$Source,
        [string]$DestPath,
        [string]$Type,
        [string]$Label
    )
    $parentDir = Split-Path -Path $DestPath -Parent
    if (-not (Test-Path -LiteralPath $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }
    if ($Type -eq 'Directory') {
        & robocopy $Source $DestPath /MIR /R:0 /W:0 /NP /NFL /NDL /NJH /NJS | Out-Null
        $rc = $LASTEXITCODE
        if ($rc -le 3) {
            Write-Host "  [SINCRONIZADO] $Label" -ForegroundColor Green
            $script:Created++
        } else {
            Write-Host "  [ERRO]     $Label  -  robocopy falhou (exit $rc)" -ForegroundColor Red
            $script:Errors++
        }
    } else {
        try {
            Copy-Item -LiteralPath $Source -Destination $DestPath -Force
            Write-Host "  [SINCRONIZADO] $Label" -ForegroundColor Green
            $script:Created++
        } catch {
            Write-Host "  [ERRO]     $Label  -  $($_.Exception.Message)" -ForegroundColor Red
            $script:Errors++
        }
    }
}

function Test-MirrorEntryOk {
    <#
    .SYNOPSIS
        True se a entrada de mirror esta no estado correcto:
        - Modo local: deve ser symlink.
        - Modo rede: basta existir (e uma copia real).
    #>
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    if ($script:IsNetworkMode) { return $true }
    return (Get-Item -LiteralPath $Path -Force).LinkType -eq 'SymbolicLink'
}

function New-MirrorSymlinkCreateOnly {
    <#
    .SYNOPSIS
        Cria symlink quando o caminho LinkPath esta livre (nao chamar se entrada existir).
    #>
    param(
        [string]$Source,
        [string]$LinkPath,
        [string]$Label,
        [string]$LogVerb,
        [string]$RepoRoot
    )

    $parentDir = Split-Path -Path $LinkPath -Parent
    if (-not (Test-Path -LiteralPath $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    try {
        $target = Get-SymlinkTargetPath -Source $Source -LinkPath $LinkPath -RepoRoot $RepoRoot
        # New-Item resolve caminhos relativos contra o CWD do processo (em sessoes elevadas
        # o CWD e C:\Windows\System32). Mudar para o directorio pai do link garante que
        # targets relativos sao resolvidos correctamente.
        $linkParentDir = Split-Path -Path $LinkPath -Parent
        Push-Location -LiteralPath $linkParentDir
        try {
            New-Item -ItemType SymbolicLink -Path $LinkPath -Target $target -ErrorAction Stop | Out-Null
        } finally {
            Pop-Location
        }

        # Verificar que e realmente um symlink (nao pasta real criada por fallback silencioso)
        $created = Get-Item -LiteralPath $LinkPath -Force -ErrorAction SilentlyContinue
        if ($null -ne $created -and -not (Test-IsFilesystemReparseLink -Item $created)) {
            Remove-Item -LiteralPath $LinkPath -Force -Recurse -ErrorAction SilentlyContinue
            Write-Host "  [ERRO]     $Label  -  criado como pasta real (nao symlink) - removido" -ForegroundColor Red
            $script:Errors++
            return
        }

        Write-Host "  [$LogVerb] $Label" -ForegroundColor $(if ($LogVerb -eq 'CRIADO') { 'Green' } else { 'Cyan' })
        if ($LogVerb -eq 'CRIADO') {
            $script:Created++
        } elseif ($LogVerb -eq 'REPARADO') {
            $script:Repaired++
        }
    } catch [System.UnauthorizedAccessException] {
        Write-Host ('  [ERRO]     ' + $Label + ' - privilegios insuficientes para criar symlink') -ForegroundColor Red
        Write-Host '             Executar como Administrador (Modo de Programador pode nao ser suficiente nesta edicao do Windows).' -ForegroundColor Red
        $script:Errors++
    } catch {
        Write-Host "  [ERRO]     $Label  -  $($_.Exception.Message)" -ForegroundColor Red
        $script:Errors++
    }
}

function New-MirrorSymlink {
    param(
        [string]$Source,
        [string]$LinkPath,
        [string]$Type,
        [bool]$Optional,
        [string]$RepoRoot
    )

    $label = $LinkPath.Replace($RepoRoot, '').TrimStart('\', '/')

    # --- Modo rede: copiar/sincronizar em vez de criar symlinks ---
    if ($script:IsNetworkMode) {
        if (-not (Test-Path -LiteralPath $Source)) {
            if ($Optional) {
                Write-Host ('  [IGNORADO] ' + $label + ' - fonte opcional nao existe') -ForegroundColor DarkGray
                $script:Skipped++
                return
            }
            Write-Host ('  [ERRO]     ' + $label + ' - fonte obrigatoria nao encontrada: ' + $Source) -ForegroundColor Red
            $script:Errors++
            return
        }
        Sync-MirrorContent -Source $Source -DestPath $LinkPath -Type $Type -Label $label
        return
    }

    # Verificar se fonte existe
    if (-not (Test-Path -LiteralPath $Source)) {
        if ($Optional) {
            Write-Host ('  [IGNORADO] ' + $label + ' - fonte opcional nao existe') -ForegroundColor DarkGray
            $script:Skipped++
            return
        }
        Write-Host ('  [ERRO]     ' + $label + ' - fonte obrigatoria nao encontrada: ' + $Source) -ForegroundColor Red
        $script:Errors++
        return
    }

    # Entrada no destino: usar -LiteralPath (inclui symlink quebrado; Test-Path sem -Literal pode mentir)
    $destExists = Test-Path -LiteralPath $LinkPath

    if (-not $destExists) {
        New-MirrorSymlinkCreateOnly -Source $Source -LinkPath $LinkPath -Label $label -LogVerb 'CRIADO' -RepoRoot $RepoRoot
        return
    }

    $item = Get-Item -LiteralPath $LinkPath -Force

    if (Test-IsFilesystemReparseLink -Item $item) {
        if (Test-SymlinkItemMatchesSource -LinkPath $LinkPath -Item $item -Source $Source) {
            Write-Host "  [OK]       $label" -ForegroundColor Green
            $script:Ok++
            return
        }

        if ($Repair -or $Force) {
            try {
                # Nunca -Recurse: remove apenas o link, nao o destino
                Remove-Item -LiteralPath $LinkPath -Force -ErrorAction Stop
            } catch {
                Write-Host "  [ERRO]     $label  -  nao foi possivel remover link antigo: $($_.Exception.Message)" -ForegroundColor Red
                $script:Errors++
                return
            }
            New-MirrorSymlinkCreateOnly -Source $Source -LinkPath $LinkPath -Label $label -LogVerb 'REPARADO' -RepoRoot $RepoRoot
            return
        }

        $broken = -not (Test-Path -Path $LinkPath -ErrorAction SilentlyContinue)
        if ($broken) {
            Write-Host "  [AVISO]    $label  -  symlink/junction quebrado ou alvo incorrecto. Usar -Repair ou -Force." -ForegroundColor Yellow
        } else {
            Write-Host "  [AVISO]    $label  -  symlink/junction com alvo incorrecto. Usar -Repair ou -Force." -ForegroundColor Yellow
        }
        $script:Conflicts++
        return
    }

    # Ficheiro ou pasta real (sem reparse / nao e link)
    if (Test-IsProtected -RepoRoot $RepoRoot -LinkPath $LinkPath) {
        Write-Host ('  [IGNORADO] ' + $label + '  -  ficheiro de configuracao especifico (protegido)') -ForegroundColor DarkYellow
        $script:Skipped++
        return
    }

    # Pasta real VAZIA — remover directamente (artefacto de IDE/Explorer)
    if ((Get-Item -LiteralPath $LinkPath -Force).PSIsContainer) {
        $children = Get-ChildItem -Path $LinkPath -Force -ErrorAction SilentlyContinue
        if (-not $children) {
            try {
                Remove-Item -LiteralPath $LinkPath -Force -ErrorAction Stop
                Write-Host ('  [REMOVIDO] ' + $label + '  -  pasta real vazia (artefacto)') -ForegroundColor Cyan
            } catch {
                Write-Host "  [ERRO]     $label  -  nao foi possivel remover pasta vazia: $($_.Exception.Message)" -ForegroundColor Red
                $script:Errors++
                return
            }
            New-MirrorSymlinkCreateOnly -Source $Source -LinkPath $LinkPath -Label $label -LogVerb 'CRIADO' -RepoRoot $RepoRoot
            return
        }
    }

    # Pasta/ficheiro real COM conteudo — sincronizar com .cursor/ (sem backup nem symlink)
    Write-Host ('  [AVISO]    ' + $label + '  -  pasta/ficheiro real com conteudo: sincronizando com .cursor/') -ForegroundColor Yellow
    Sync-MirrorContent -Source $Source -DestPath $LinkPath -Type $Type -Label $label
}

function Test-SymlinkHealth {
    <#
    .SYNOPSIS
        Verifica saude de um symlink para modo -ValidateOnly.
    #>
    param(
        [string]$Source,
        [string]$LinkPath,
        [string]$Type,
        [bool]$Optional,
        [string]$RepoRoot
    )

    $label = $LinkPath.Replace($RepoRoot, '').TrimStart('\', '/')

    if (-not (Test-Path -LiteralPath $Source)) {
        if ($Optional) {
            Write-Host "  [N/A]      $label  -  fonte opcional nao existe" -ForegroundColor DarkGray
            return 'skip'
        } else {
            Write-Host "  [FALHA]    $label  -  fonte obrigatoria nao encontrada" -ForegroundColor Red
            return 'fail'
        }
    }

    if (-not (Test-Path -LiteralPath $LinkPath)) {
        Write-Host "  [FALTA]    $label  -  entrada nao existe" -ForegroundColor Yellow
        return 'fail'
    }

    $item = Get-Item -LiteralPath $LinkPath -Force
    if (-not (Test-IsFilesystemReparseLink -Item $item)) {
        if (Test-IsProtected -RepoRoot $RepoRoot -LinkPath $LinkPath) {
            Write-Host ('  [OK]       ' + $label + '  -  ficheiro de configuracao (protegido, nao symlink)') -ForegroundColor Green
            return 'ok'
        }
        Write-Host ('  [AVISO]    ' + $label + '  -  e ficheiro/pasta real, nao symlink') -ForegroundColor Yellow
        return 'warn'
    }

    if (Test-SymlinkItemMatchesSource -LinkPath $LinkPath -Item $item -Source $Source) {
        Write-Host "  [OK]       $label" -ForegroundColor Green
        return 'ok'
    }

    if (-not (Test-Path -Path $LinkPath -ErrorAction SilentlyContinue)) {
        Write-Host "  [QUEBRADO] $label  -  link existe mas o alvo nao resolve" -ForegroundColor Red
        return 'fail'
    }

    Write-Host "  [AVISO]    $label  -  link nao aponta para .cursor (alvo diferente)" -ForegroundColor Yellow
    return 'warn'
}

function Install-MirrorConfigTemplate {
    <#
    .SYNOPSIS
        Copia templates de configuracao para mirrors que nao tenham os ficheiros.
    #>
    param([string]$RepoRoot)

    $templateDir = Join-Path $RepoRoot '.cursor\Templates\mirror-config'
    if (-not (Test-Path $templateDir)) {
        Write-Host '  [AVISO] Pasta mirror-config nao encontrada  -  ignorando templates de config.' -ForegroundColor Yellow
        return
    }

    # Derive project name from repo folder name
    $projectName = Split-Path $RepoRoot -Leaf

    $enabledDirs = (Get-MirrorConfig -RepoRoot $RepoRoot).EnabledDirs

    $configMappings = @(
        @{ Template = 'vscode-settings.template.json';       Dest = '.vscode\settings.json';       MirrorDir = '.vscode'   },
        # vscode-tasks.template.json — gerido exclusivamente pelo bootstrap-autostart-mirrors.ps1
        # (Install-TasksTemplate). Nao incluir aqui para evitar conflito com o .bak.
        @{ Template = 'vscode-extensions.template.json';     Dest = '.vscode\extensions.json';     MirrorDir = '.vscode'   },
        @{ Template = 'claude-settings.template.json';       Dest = '.claude\settings.json';       MirrorDir = '.claude'   },
        @{ Template = 'claude-settings-local.template.json'; Dest = '.claude\settings.local.json'; MirrorDir = '.claude'   },
        @{ Template = 'claude-md.template.md';               Dest = 'CLAUDE.md';                   MirrorDir = '.claude'   },
        @{ Template = 'opencode.json.template';              Dest = 'opencode.json';               MirrorDir = '.opencode' }
    ) | Where-Object { $enabledDirs -contains $_.MirrorDir }

    Write-Host ''
    Write-Host '--- Templates de configuracao ---' -ForegroundColor Cyan

    foreach ($mapping in $configMappings) {
        $destPath = Join-Path $RepoRoot $mapping.Dest
        $srcPath  = Join-Path $templateDir $mapping.Template
        $label    = $mapping.Dest

        if (Test-Path $destPath) {
            Write-Host ('  [EXISTE]   ' + $label + '  -  ficheiro ja existe (nao substituido)') -ForegroundColor DarkGray
        } elseif (Test-Path $srcPath) {
            $parentDir = Split-Path $destPath -Parent
            if (-not (Test-Path $parentDir)) {
                New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            }
            # Substituir placeholders ao copiar.
            # Para destinos JSON: escapar '\' -> '\\' nos valores substituidos
            # (caminhos Windows com '\' simples sao JSON invalido).
            $content = [System.IO.File]::ReadAllText($srcPath, [System.Text.Encoding]::UTF8)
            $isJson  = $destPath -match '\.(json)$' -or $srcPath -match '\.(json|json\.template)$'
            $repoRootSub    = if ($isJson) { $RepoRoot    -replace '\\', '\\\\' } else { $RepoRoot }
            $projectNameSub = $projectName   # nomes de projecto nao contem '\' tipicamente
            $content = $content.Replace('{REPO_ROOT}',    $repoRootSub)
            $content = $content.Replace('{PROJECT_NAME}', $projectNameSub)
            [System.IO.File]::WriteAllText($destPath, $content, [System.Text.Encoding]::UTF8)
            Write-Host "  [COPIADO]  $label  -  inicializado a partir do template" -ForegroundColor Green
        } else {
            Write-Host "  [N/A]      $label  -  template nao encontrado: $($mapping.Template)" -ForegroundColor DarkGray
        }
    }
}

function Invoke-ValidationChecklist {
    <#
    .SYNOPSIS
        Executa os 12 checks de validacao.
    #>
    param([string]$RepoRoot)

    $mirrorCfg      = Get-MirrorConfig -RepoRoot $RepoRoot
    $enabledMirrors = $mirrorCfg.EnabledDirs

    Write-Host ''
    Write-Host '=== Checklist de validacao ===' -ForegroundColor Cyan
    Write-Host ''

    $failures = 0

    # V1: Sem Docs/ residual (excluir changelog)
    # Nota: regex \bDocs/ e case-sensitive e nao matcha '.cursor/docs/' (lowercase, valido)
    # nem '.docs/' (dotfolder raiz, valido). So detecta refs legacy a 'Docs/' (capital D),
    # tipicamente apontando para a antiga pasta produto 'Docs/' -> renomeada para 'Documentation/'.
    $docsRefs = Get-ChildItem -Path (Join-Path $RepoRoot '.cursor') -Recurse -Include '*.md','*.mdc' -ErrorAction SilentlyContinue |
        Select-String -Pattern '\bDocs/' -ErrorAction SilentlyContinue |
        Where-Object { $_.Line -notmatch '^\s*-\s*\d' -and $_.Line -notmatch 'Changelog' -and $_.Line -notmatch 'alias legado' -and $_.Line -notmatch 'EXAMPLE' }
    if ($docsRefs -and $docsRefs.Count -gt 0) {
        Write-Host ('  [AVISO]  V1   -  ' + $docsRefs.Count + ' referencia(s) a Docs/ encontrada(s)') -ForegroundColor Yellow
    } else {
        Write-Host "  [OK]     V1   -  Sem referencias residuais a Docs/" -ForegroundColor Green
    }

    if ($script:IsNetworkMode) { $modeLabel = 'copias' } else { $modeLabel = 'symlinks' }

    # V2-V4: Diretorios de mirror (symlinks em modo local, copias em modo rede)
    $expectedDirs = @('agents', 'commands', 'plans', 'rules', 'skills', 'Templates')
    foreach ($mirror in $enabledMirrors) {
        $count = 0
        foreach ($dir in $expectedDirs) {
            $p = Join-Path $RepoRoot "$mirror\$dir"
            if (Test-MirrorEntryOk -Path $p) { $count++ }
        }
        $vNum = switch ($mirror) {
            '.claude'    { 'V2' }
            '.continue'  { 'V3' }
            '.vscode'    { 'V4' }
            '.opencode'  { 'V13' }
            default      { 'V?' }
        }
        if ($count -eq $expectedDirs.Count) {
            Write-Host "  [OK]     $vNum   -  ${mirror}/: $count/$($expectedDirs.Count) $modeLabel de directorio" -ForegroundColor Green
        } else {
            Write-Host "  [FALHA]  $vNum   -  ${mirror}/: $count/$($expectedDirs.Count) $modeLabel de directorio" -ForegroundColor Red
            $failures++
        }
    }

    # V5: Ficheiros de mirror (VERSION.md + README.md)
    $expectedFiles = @('VERSION.md', 'README.md')
    foreach ($mirror in $enabledMirrors) {
        $count = 0
        foreach ($file in $expectedFiles) {
            $p = Join-Path $RepoRoot "$mirror\$file"
            if (Test-MirrorEntryOk -Path $p) { $count++ }
        }
        if ($count -eq $expectedFiles.Count) {
            Write-Host "  [OK]     V5   -  ${mirror}/: $count/$($expectedFiles.Count) $modeLabel de ficheiro" -ForegroundColor Green
        } else {
            Write-Host "  [FALHA]  V5   -  ${mirror}/: $count/$($expectedFiles.Count) $modeLabel de ficheiro" -ForegroundColor Red
            $failures++
        }
    }

    # V7: plans/ acessivel (apenas se .claude habilitado)
    if ($mirrorCfg.HasClaude) {
        $plansLink = Join-Path $RepoRoot '.claude\plans'
        if (Test-MirrorEntryOk -Path $plansLink) {
            Write-Host "  [OK]     V7   -  .claude/plans $modeLabel funciona" -ForegroundColor Green
        } else {
            Write-Host "  [FALHA]  V7   -  .claude/plans em falta ou invalido" -ForegroundColor Red
            $failures++
        }
    } else {
        Write-Host '  [SKIP]   V7   -  .claude desabilitado no config.json' -ForegroundColor DarkGray
    }

    # V9: Configs protegidos NAO sao symlinks
    $configOk = $true
    foreach ($protected in $script:ProtectedFiles) {
        $p = Join-Path $RepoRoot $protected
        if ((Test-Path $p) -and ((Get-Item $p -Force).LinkType -eq 'SymbolicLink')) {
            Write-Host ('  [FALHA]  V9   -  ' + $protected + ' e symlink (deveria ser ficheiro real)') -ForegroundColor Red
            $configOk = $false
            $failures++
        }
    }
    if ($configOk) {
        Write-Host '  [OK]     V9   -  Ficheiros de configuracao protegidos intactos' -ForegroundColor Green
    }

    # V11: Sem "Como usar este template" em rules activas
    $templateHowto = Get-ChildItem -Path (Join-Path $RepoRoot '.cursor\rules') -Filter 'project-*.mdc' -ErrorAction SilentlyContinue |
        Select-String -Pattern '## Como usar este template' -ErrorAction SilentlyContinue
    if ($templateHowto -and $templateHowto.Count -gt 0) {
        Write-Host ('  [AVISO]  V11  -  ' + $templateHowto.Count + " ficheiro(s) com secao 'Como usar este template'") -ForegroundColor Yellow
    } else {
        Write-Host '  [OK]     V11  -  Sem "Como usar este template" em rules activas' -ForegroundColor Green
    }

    # V12: README.md nos mirrors (symlink em modo local; copia real em modo rede)
    $readmeOk = $true
    foreach ($mirror in $enabledMirrors) {
        $rp = Join-Path $RepoRoot "$mirror\README.md"
        if ((Test-Path -LiteralPath $rp) -and -not $script:IsNetworkMode -and
            ((Get-Item $rp -Force).LinkType -ne 'SymbolicLink')) {
            Write-Host ('  [AVISO]  V12  -  ' + $mirror + '/README.md e ficheiro real (possivel copia stale)') -ForegroundColor Yellow
            $readmeOk = $false
        }
    }
    if ($readmeOk) {
        if ($script:IsNetworkMode) { $v12Label = 'copias' } else { $v12Label = 'symlinks ou ausentes' }
        Write-Host "  [OK]     V12  -  README.md nos mirrors actualizados ($v12Label)" -ForegroundColor Green
    }

    Write-Host ''
    return $failures
}

function Write-Report {
    <#
    .SYNOPSIS
        Sumario final.
    #>
    param([string]$Mode)

    Write-Host ''
    Write-Host '=== Sumario ===' -ForegroundColor Cyan
    Write-Host "  Modo:       $Mode"
    if ($Mode -ne 'ValidateOnly') {
        Write-Host "  Criados:    $($script:Created)" -ForegroundColor Green
        Write-Host "  OK:         $($script:Ok)" -ForegroundColor Green
        Write-Host "  Reparados:  $($script:Repaired)" -ForegroundColor Cyan
        Write-Host "  Ignorados:  $($script:Skipped)" -ForegroundColor DarkGray
        Write-Host "  Conflitos:  $($script:Conflicts)" -ForegroundColor Yellow
        Write-Host "  Erros:      $($script:Errors)" -ForegroundColor Red
    }
    Write-Host ''
}

# =============================================================================
# Main
# =============================================================================

Write-Host ''
Write-Host '================================================================' -ForegroundColor Cyan
Write-Host '  Bootstrap dos Espelhos  -  .cursor/ -> .claude/.vscode/.continue/.opencode' -ForegroundColor Cyan
Write-Host '================================================================' -ForegroundColor Cyan
Write-Host ''

# 1. Resolver raiz do repositorio e detectar modo rede (antes da checagem de elevacao)
$RepoRoot = Resolve-RepoRoot
$script:IsNetworkMode = Test-IsNetworkPath -Path $RepoRoot
Write-Host "[OK] Raiz do repositorio: $RepoRoot" -ForegroundColor Green
if ($script:IsNetworkMode) {
    Write-Host '[INFO] Caminho de rede detectado  -  modo COPIA (sem symlinks).' -ForegroundColor Cyan
}
Write-Host ''

# 2. Elevacao (RunAs) ou verificacao de privilegios (apenas modo local, apenas quando altera ficheiros)
if (-not $ValidateOnly) {
    if ($script:IsNetworkMode) {
        Write-Host '[INFO] Modo rede  -  elevacao de administrador nao necessaria.' -ForegroundColor Cyan
    } else {
        if (-not $NoElevation -and -not $FromElevation -and -not (Test-IsWindowsAdministrator)) {
            Invoke-BootstrapRelaunchElevated
            # Invoke-BootstrapRelaunchElevated termina o processo com exit
        }
        Test-AdminElevation
    }
} else {
    Write-Host '[INFO] Modo ValidateOnly  -  verificacao de admin ignorada (operacao somente leitura).' -ForegroundColor Cyan
}

# 3. Obter mappings
$mappings = Get-SymlinkMappings -RepoRoot $RepoRoot

if ($ValidateOnly) {
    # --- Modo ValidateOnly ---
    Write-Host '--- Modo: ValidateOnly (verificacao sem alteracoes) ---' -ForegroundColor Cyan
    Write-Host ''

    $failCount = 0
    $currentMirror = ''
    foreach ($m in $mappings) {
        if ($m.Mirror -ne $currentMirror) {
            $currentMirror = $m.Mirror
            Write-Host ''
            Write-Host "--- $currentMirror ---" -ForegroundColor White
        }
        $result = Test-SymlinkHealth -Source $m.Source -LinkPath $m.LinkPath -Type $m.Type -Optional $m.Optional -RepoRoot $RepoRoot
        if ($result -eq 'fail') { $failCount++ }
    }

    $checkFailures = Invoke-ValidationChecklist -RepoRoot $RepoRoot
    $totalFailures = $failCount + $checkFailures

    Write-Report -Mode 'ValidateOnly'

    if ($totalFailures -gt 0) {
        Write-Host ('  ' + $totalFailures + ' problema(s) encontrado(s).') -ForegroundColor Yellow
        Write-Host '  Correr sem -ValidateOnly para criar/sincronizar entradas em falta.' -ForegroundColor Yellow
        Write-Host '  Usar -Repair para corrigir symlinks quebrados (modo local).' -ForegroundColor Yellow
        Invoke-FinalExit -Code 3
    } else {
        Write-Host '  Todos os checks passaram.' -ForegroundColor Green
        Invoke-FinalExit -Code 0
    }
} else {
    # --- Modo criacao/sincronizacao ---
    $currentMirror = ''
    foreach ($m in $mappings) {
        if ($m.Mirror -ne $currentMirror) {
            $currentMirror = $m.Mirror
            Write-Host ''
            Write-Host "--- $currentMirror ---" -ForegroundColor White

            # Garantir que pasta mirror existe
            $mirrorDir = Join-Path $RepoRoot $currentMirror
            if (-not (Test-Path $mirrorDir)) {
                New-Item -ItemType Directory -Path $mirrorDir -Force | Out-Null
                Write-Host "  [CRIADO]   pasta ${currentMirror}/" -ForegroundColor Green
            }
        }

        New-MirrorSymlink -Source $m.Source -LinkPath $m.LinkPath -Type $m.Type -Optional $m.Optional -RepoRoot $RepoRoot
    }

    # Instalar templates de configuracao
    Install-MirrorConfigTemplate -RepoRoot $RepoRoot

    # Validacao pos-criacao
    $checkFailures = Invoke-ValidationChecklist -RepoRoot $RepoRoot

    Write-Report -Mode 'Bootstrap'

    if ($script:Errors -gt 0) {
        Invoke-FinalExit -Code 4
    } elseif ($script:Conflicts -gt 0) {
        Write-Host '  Existem conflitos. Usar -Force para substituir ficheiros reais.' -ForegroundColor Yellow
        Invoke-FinalExit -Code 3
    } else {
        Write-Host '  Bootstrap concluido com sucesso.' -ForegroundColor Green
        Invoke-FinalExit -Code 0
    }
}





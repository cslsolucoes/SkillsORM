<#
.SYNOPSIS
    Auto-start do bootstrap de espelhos — executado automaticamente ao abrir a pasta.

.DESCRIPTION
    1) Executa validacao (-ValidateOnly) — nao precisa de admin.
    2) Exit 0: tudo OK, termina silenciosamente.
    3) Exit 3: symlinks em falta — tenta criar (Bootstrap completo).
       Se falhar por falta de privilegios: mostra instrucao e sai com 0
       (nao falha a task — apenas avisa o utilizador).
    4) Outros exit codes: propaga o erro.
#>

# internal_file_version: 1.0.8
# Changelog (este arquivo):
# - 1.0.8 (12/04/2026): Install-TasksTemplate — removida substituicao de placeholders
#   {PROJECT_NAME}, {PROJECT_DPR} e {FPC_ROOT}; template vscode-tasks.template.json
#   agora usa variaveis nativas do VSCode (${workspaceFolderBasename}, ${workspaceFolder},
#   ${env:FPC_ROOT}) resolvidas pelo proprio editor em tempo de execucao.
# - 1.0.7 (11/04/2026): Nomenclatura canónica bootstrap-autostart-mirrors.ps1 (família Bootstrap-* com bootstrap-mirror-symlinks.ps1).
# - 1.0.6 (09/04/2026): Install-IgnoreFiles — cria ficheiros *ignore na raiz a partir
#   dos templates em .cursor/Templates/mirror-config/ para cada IA habilitada no config;
#   substitui {PROJECT_NAME}; nao sobrescreve se o ficheiro ja existir (preserva customizacoes).
# - 1.0.5 (09/04/2026): Carrega .cursor/config.json para determinar mirrors activos;
#   Install-TasksTemplate so executa se cursor (mirrorDir .vscode) estiver habilitado;
#   mensagem de instrucao de elevacao lista apenas mirrors habilitados no config.
# - 1.0.4 (09/04/2026): Substituidas expressoes "if" inline em atribuicoes (linhas 157/167)
#   por blocos if/else padrao — evita parse error em PS5.1 ao carregar de caminho UNC.
# - 1.0.3 (09/04/2026): Deteccao de modo rede (Test-IsNetworkPath); Install-TasksTemplate
#   usa .Replace() + escape JSON (\ -> \\) em vez de -replace regex — corrige caminhos
#   Windows invalidos em JSON; mensagens actualizadas para modo rede; bloco de instrucao
#   de elevacao suprimido em modo rede (nao necesssario).
# - 1.0.2 (04/04/2026): Corrigido calculo de $repoRoot nos dois ramos (validateCode -eq 0
#   e createCode -eq 0) — faltava um nivel de Split-Path -Parent (scripts/ -> .cursor/ -> raiz);
#   o caminho resultava em .cursor/ em vez da raiz, impedindo que Install-TasksTemplate
#   encontrasse vscode-tasks.template.json e actualizasse tasks.json.
# - 1.0.1 (04/04/2026): Install-TasksTemplate — faz backup do tasks.json base para
#   tasks.json.bak e deploya o template completo (tasks build Delphi/FPC e CLI de banco)
#   com substituicao de {REPO_ROOT}, {PROJECT_NAME}, {PROJECT_DPR}, {FPC_ROOT};
#   chamada nos dois ramos (OK e criacao bem-sucedida).
# - 1.0.0 (04/04/2026): Versao inicial com versionamento interno. Auto-start ao
#   abrir pasta; validacao sem admin; detecao de projeto (.dpr/.lpr); instrucao
#   /iniciar; elevacao UAC quando necessario.

[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'
$bootstrap = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'bootstrap-mirror-symlinks.ps1'

# Raiz do repositorio (scripts/ -> .cursor/ -> raiz) — calculado aqui para uso global
$script:RepoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))

# Detectar modo rede (sem symlinks — mirrors sao copias reais)
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
$script:IsNetworkMode = Test-IsNetworkPath -Path $script:RepoRoot

# =============================================================================
# Carregar configuracao de IAs activas (.cursor/config.json)
# =============================================================================
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
$script:MirrorCfg = Get-MirrorConfig -RepoRoot $script:RepoRoot

# =============================================================================
# Funcao: Install-TasksTemplate
#   Faz backup de tasks.json (base) -> tasks.json.bak e deploya o template
#   completo. O template usa variaveis nativas do VSCode (${workspaceFolderBasename},
#   ${workspaceFolder}, ${env:FPC_ROOT}) — nenhuma substituicao de placeholder
#   necessaria. Executa apenas uma vez por sessao de bootstrap (guarda-se com
#   a existencia do .bak).
# =============================================================================
function Install-TasksTemplate {
    param([string]$RepoRoot)

    $tasksPath    = Join-Path $RepoRoot '.vscode\tasks.json'
    $backupPath   = Join-Path $RepoRoot '.vscode\tasks.json.bak'
    $templatePath = Join-Path $RepoRoot '.cursor\Templates\mirror-config\vscode-tasks.template.json'

    # Ja feito numa sessao anterior
    if (Test-Path -LiteralPath $backupPath) { return }

    # Template em falta — nao actuar
    if (-not (Test-Path -LiteralPath $templatePath)) {
        Write-Host '  [AVISO]    vscode-tasks.template.json nao encontrado — tasks.json nao actualizado.' -ForegroundColor Yellow
        return
    }

    # Backup do ficheiro base
    if (Test-Path -LiteralPath $tasksPath) {
        Copy-Item -LiteralPath $tasksPath -Destination $backupPath -Force
        Write-Host '  [BACKUP]   .vscode\tasks.json  ->  tasks.json.bak' -ForegroundColor Cyan
    }

    # Ler template e remover apenas a linha _template_info do JSON.
    # Todas as variaveis (${workspaceFolderBasename}, ${workspaceFolder},
    # ${env:FPC_ROOT}) sao resolvidas pelo proprio VSCode em tempo de execucao.
    $content = [System.IO.File]::ReadAllText($templatePath, [System.Text.Encoding]::UTF8)
    $lines = $content -split "`n" | Where-Object { $_ -notmatch '"_template_info"' }
    $content = $lines -join "`n"

    [System.IO.File]::WriteAllText($tasksPath, $content, [System.Text.Encoding]::UTF8)
    Write-Host '  [COPIADO]  .vscode\tasks.json  <-  vscode-tasks.template.json' -ForegroundColor Green
}

# =============================================================================
# Funcao: Install-IgnoreFiles
#   Cria os ficheiros *ignore na raiz para cada IA habilitada no config que
#   tenha ignoreTemplate definido. Nao sobrescreve se ja existir.
# =============================================================================
function Install-IgnoreFiles {
    param([string]$RepoRoot)

    $configPath = Join-Path $RepoRoot '.cursor\config.json'
    if (-not (Test-Path $configPath)) { return }
    try {
        $cfg = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
    } catch { return }
    if (-not $cfg.ias) { return }

    # Derivar PROJECT_NAME do .dpr/.lpr existente, fallback ao nome da pasta
    $projectName = Split-Path $RepoRoot -Leaf
    $dprFile = Get-ChildItem -Path $RepoRoot -Filter '*.dpr' -File -ErrorAction SilentlyContinue |
               Where-Object { $_.Name -notlike '*.template' } | Select-Object -First 1
    if (-not $dprFile) {
        $dprFile = Get-ChildItem -Path $RepoRoot -Filter '*.lpr' -File -ErrorAction SilentlyContinue |
                   Where-Object { $_.Name -notlike '*.template' } | Select-Object -First 1
    }
    if ($dprFile) {
        $firstLine = Get-Content $dprFile.FullName -TotalCount 5 -ErrorAction SilentlyContinue |
                     Where-Object { $_ -match '^\s*program\s+(\w+)\s*;' } | Select-Object -First 1
        if ($firstLine -match '^\s*program\s+(\w+)\s*;') {
            $projectName = $Matches[1]
        } else {
            $projectName = [System.IO.Path]::GetFileNameWithoutExtension($dprFile.Name)
        }
    }

    foreach ($prop in $cfg.ias.PSObject.Properties) {
        $ia = $prop.Value
        if ($ia.enabled -ne $true) { continue }
        if (-not $ia.ignoreTemplate) { continue }
        if (-not $ia.ignoreFile)     { continue }

        $destPath     = Join-Path $RepoRoot $ia.ignoreFile
        $templatePath = Join-Path $RepoRoot ".cursor\Templates\mirror-config\$($ia.ignoreTemplate)"

        # Ja existe — preservar customizacoes do utilizador
        if (Test-Path -LiteralPath $destPath) { continue }

        if (-not (Test-Path -LiteralPath $templatePath)) {
            Write-Host "  [AVISO]    Template $($ia.ignoreTemplate) nao encontrado — $($ia.ignoreFile) nao criado." -ForegroundColor Yellow
            continue
        }

        $content = [System.IO.File]::ReadAllText($templatePath, [System.Text.Encoding]::UTF8)
        $content = $content.Replace('{PROJECT_NAME}', $projectName)
        [System.IO.File]::WriteAllText($destPath, $content, [System.Text.Encoding]::UTF8)
        Write-Host "  [CRIADO]   $($ia.ignoreFile)  <-  $($ia.ignoreTemplate)  (projeto: $projectName)" -ForegroundColor Green
    }
}

# =============================================================================
# Passo 1: Validacao (sem admin necessario)
# =============================================================================
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $bootstrap -ValidateOnly
$validateCode = $LASTEXITCODE

if ($validateCode -eq 0) {
    Write-Host ''
    Write-Host '  [AUTO-START] Espelhos OK.' -ForegroundColor Green

    # Upgrade de tasks.json (uma unica vez) — apenas se cursor/.vscode estiver habilitado
    if ($script:MirrorCfg.HasVscode) {
        Install-TasksTemplate -RepoRoot $script:RepoRoot
    }

    # Criar ficheiros *ignore para cada IA habilitada (apenas se nao existirem)
    Install-IgnoreFiles -RepoRoot $script:RepoRoot

    # Verifica se existe projeto (.dpr ou .lpr) na raiz
    $hasDpr = (Get-ChildItem -Path $script:RepoRoot -Filter '*.dpr' -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -notlike '*.template' })
    $hasLpr = (Get-ChildItem -Path $script:RepoRoot -Filter '*.lpr' -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -notlike '*.template' })

    if (-not $hasDpr -and -not $hasLpr) {
        Write-Host ''
        Write-Host '  ============================================================' -ForegroundColor Cyan
        Write-Host '  [PROJETO] Nenhum projeto encontrado na raiz.' -ForegroundColor Cyan
        Write-Host '  ============================================================' -ForegroundColor Cyan
        Write-Host ''
        Write-Host '  >>> Abra o chat do Cursor (Ctrl+L) e escreva:' -ForegroundColor Yellow
        Write-Host ''
        Write-Host '        /init' -ForegroundColor White
        Write-Host ''
        Write-Host '  O assistente ira perguntar o nome do projeto e criar' -ForegroundColor Gray
        Write-Host '  automaticamente todos os arquivos necessarios.' -ForegroundColor Gray
        Write-Host '  ============================================================' -ForegroundColor Cyan
        Write-Host ''
    }

    exit 0
}

if ($validateCode -eq 3) {
    if ($script:IsNetworkMode) { $actionLabel = 'copias' } else { $actionLabel = 'symlinks' }
    Write-Host ''
    Write-Host "  [AUTO-START] Espelhos em falta — a tentar criacao de $actionLabel..." -ForegroundColor Yellow
    Write-Host ''

    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $bootstrap
    $createCode = $LASTEXITCODE

    if ($createCode -eq 0) {
        Write-Host ''
        if ($script:IsNetworkMode) { $successLabel = 'Copias criadas' } else { $successLabel = 'Symlinks criados' }
        Write-Host "  [AUTO-START] $successLabel com sucesso." -ForegroundColor Green
        Write-Host ''

        # Upgrade de tasks.json (uma unica vez) — apenas se cursor/.vscode estiver habilitado
        if ($script:MirrorCfg.HasVscode) {
            Install-TasksTemplate -RepoRoot $script:RepoRoot
        }

        # Criar ficheiros *ignore para cada IA habilitada (apenas se nao existirem)
        Install-IgnoreFiles -RepoRoot $script:RepoRoot

        exit 0
    }

    # Falhou
    if ($script:IsNetworkMode) {
        # Modo rede: elevacao nao e necessaria — erro inesperado
        Write-Host ''
        Write-Host '  ============================================================' -ForegroundColor Red
        Write-Host '  [AUTO-START] ERRO AO CRIAR COPIAS (modo rede)' -ForegroundColor Red
        Write-Host '  ============================================================' -ForegroundColor Red
        Write-Host ''
        Write-Host '  Execute o bootstrap manualmente para ver o erro:' -ForegroundColor Cyan
        Write-Host '    powershell -ExecutionPolicy Bypass -File ".cursor\scripts\bootstrap-mirror-symlinks.ps1"' -ForegroundColor DarkCyan
        Write-Host ''
    } else {
        # Modo local: provavelmente falta de privilegios de Administrador
        Write-Host ''
        Write-Host '  ============================================================' -ForegroundColor Yellow
        Write-Host '  [AUTO-START] CONFIGURACAO INICIAL NECESSARIA (uma unica vez)' -ForegroundColor Yellow
        Write-Host '  ============================================================' -ForegroundColor Yellow
        Write-Host ''
        $mirrorList = ($script:MirrorCfg.EnabledDirs | ForEach-Object { "$_/" }) -join ' '
        Write-Host "  Os espelhos ($mirrorList) nao existem." -ForegroundColor Cyan
        Write-Host '  E necessario executar o bootstrap UMA VEZ como Administrador.' -ForegroundColor Cyan
        Write-Host ''
        Write-Host '  OPCAO 1 — Reabrir o Cursor como Admin (recomendado):' -ForegroundColor White
        Write-Host '    1. Fechar o Cursor.' -ForegroundColor Gray
        Write-Host '    2. Botao direito no icone > Executar como administrador.' -ForegroundColor Gray
        Write-Host '    3. Abrir esta pasta — o auto-start criara os symlinks.' -ForegroundColor Gray
        Write-Host ''
        Write-Host '  OPCAO 2 — Terminal > Executar Tarefa:' -ForegroundColor White
        Write-Host '    "Mirror Bootstrap: Full Run"' -ForegroundColor DarkCyan
        Write-Host ''
        Write-Host '  Apos criados, o auto-start funcionara sem Admin nas proximas sessoes.' -ForegroundColor Gray
        Write-Host ''
    }
    exit 0
}

# Exit code inesperado — propaga
Write-Host ''
Write-Host "  [AUTO-START] Erro no bootstrap (exit code: $validateCode)." -ForegroundColor Red
Write-Host ''
exit $validateCode

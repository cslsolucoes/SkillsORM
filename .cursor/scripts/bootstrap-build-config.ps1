<#
.SYNOPSIS
    Gera arquivos de configuracao de build CLI, projeto Delphi e projeto FPC/Lazarus
    a partir dos templates em .cursor/Templates/build-config/.

.DESCRIPTION
    Gera: dcc32.cfg, dcc64.cfg, fpc32.opts, fpc64.opts,
          {PROJECT_NAME}.dpr, {PROJECT_NAME}.dproj,
          {PROJECT_NAME}.lpr, {PROJECT_NAME}.lpi, {PROJECT_NAME}.lps

    O nome do .dpr e .dproj e determinado pelo parametro -ProjectName
    (ou detectado automaticamente pelo arquivo .dpr existente na raiz).

    Nao sobrescreve arquivos existentes a menos que -Force seja especificado.

.PARAMETER ProjectName
    Nome do projeto (sera usado em "program {ProjectName};" e nos nomes dos arquivos).
    Se omitido, detecta a partir do .dpr existente na raiz.

.PARAMETER ProjectVersion
    Versao do formato do projeto Delphi. Padrao: 20.3 (RAD Studio 12 Athens).

.PARAMETER ProjectGuid
    GUID do projeto no formato {XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}.
    Se omitido, gera automaticamente.

.PARAMETER ConditionalDefines
    Defines condicionais adicionais separados por ponto-e-virgula.
    Ex.: "FRAMEWORK_VCL;USE_FIREDAC". Padrao: "FRAMEWORK_VCL"

.PARAMETER MainFormUnit
    Nome da unit do formulario principal (sem extensao). Ex.: ufrm.Principal
    Padrao: ufrm.Main

.PARAMETER MainFormClass
    Nome da classe do formulario principal (sem o T). Ex.: frmPrincipal
    Padrao: frmMain

.PARAMETER StudioVersion
    Versao do RAD Studio / Embarcadero. Ex.: 23.0, 22.0. Padrao: 23.0

.PARAMETER ZeosRoot
    Raiz da instalacao Zeos. Ex.: P:\PACOTE\zeosdbo

.PARAMETER DatasetSerializeRoot
    Raiz do DataSet.Serialize. Ex.: P:\PACOTE\dataset-serialize

.PARAMETER SynapseRoot
    Raiz do Synapse. Ex.: P:\PACOTE\synapse

.PARAMETER UnidacRoot
    Raiz do UniDAC (Devart). Ex.: P:\PACOTE\Unidac

.PARAMETER FpcRoot
    Raiz da instalacao FPC (subpasta fpc/). Ex.: D:\fpc\fpc

.PARAMETER LazarusRoot
    Raiz da instalacao Lazarus. Ex.: D:\fpc\lazarus

.PARAMETER FpcOpmRoot
    Raiz dos pacotes OPM do Lazarus. Ex.: D:\fpc\config_lazarus\onlinepackagemanager\packages

.PARAMETER Force
    Sobrescrever arquivos existentes na raiz do projeto.

.PARAMETER ValidateOnly
    Apenas verificar quais arquivos estao ausentes, sem gerar nada.

.PARAMETER SkipProjectFiles
    Nao gerar .dpr e .dproj (apenas cfg/opts).

.EXAMPLE
    .\bootstrap-build-config.ps1 -ProjectName "ProvidersORM" -StudioVersion 23.0

.EXAMPLE
    .\bootstrap-build-config.ps1 -ValidateOnly

.EXAMPLE
    .\bootstrap-build-config.ps1 -ProjectName "MeuApp" -ConditionalDefines "FRAMEWORK_VCL;USE_FIREDAC" -Force
#>

# internal_file_version: 1.2.0
# Changelog (este arquivo):
# - 1.2.0 (25/04/2026): Gera também `.workspace/context.json` (template) quando ausente,
#   mantendo dados específicos do clone fora do pack `.cursor/`.
# - 1.1.0 (16/04/2026): Gera tambem 4 arquivos de ignore (.gitignore, .claudeignore,
#   .cursorignore, .continueignore) a partir dos novos templates em build-config/.
#   Nunca sobrescreve (respeita existentes mesmo sem -Force para ignore files).
# - 1.0.0 (04/04/2026): Versao inicial com versionamento interno. Geracao de
#   dcc32.cfg, dcc64.cfg, fpc32.opts, fpc64.opts, .dpr, .dproj, .lpr, .lpi, .lps;
#   detecao automatica de ProjectName; -ValidateOnly, -Force, -SkipProjectFiles,
#   -SkipLazarusFiles.

[CmdletBinding()]
param(
    [string]$ProjectName = '',
    [string]$ProjectVersion = '20.3',
    [string]$ProjectGuid = '',
    [string]$ConditionalDefines = 'FRAMEWORK_VCL',
    [string]$MainFormUnit = 'ufrm.Main',
    [string]$MainFormClass = 'frmMain',
    [string]$StudioVersion = '23.0',
    [string]$ZeosRoot = 'P:\PACOTE\zeosdbo',
    [string]$DatasetSerializeRoot = 'P:\PACOTE\dataset-serialize',
    [string]$SynapseRoot = 'P:\PACOTE\synapse',
    [string]$UnidacRoot = 'P:\PACOTE\Unidac',
    [string]$FpcRoot = 'D:\fpc\fpc',
    [string]$LazarusRoot = 'D:\fpc\lazarus',
    [string]$FpcOpmRoot = 'D:\fpc\config_lazarus\onlinepackagemanager\packages',
    [switch]$Force,
    [switch]$ValidateOnly,
    [switch]$SkipProjectFiles,
    [switch]$SkipLazarusFiles
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

# =============================================================================
# Resolve raiz do repositorio a partir de $PSScriptRoot (.cursor/scripts/)
# =============================================================================
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..'))
$TemplateDir = Join-Path $RepoRoot '.cursor\Templates\build-config'
$WorkspaceDir = Join-Path $RepoRoot '.workspace'
$WorkspaceContextPath = Join-Path $WorkspaceDir 'context.json'

# =============================================================================
# Detecta PROJECT_NAME a partir de .dpr existente (se nao informado)
# =============================================================================
if (-not $ProjectName) {
    $dprFiles = Get-ChildItem -Path $RepoRoot -Filter '*.dpr' -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notlike '*.dpr.template' }
    if (-not $dprFiles) {
        $dprFiles = Get-ChildItem -Path $RepoRoot -Filter '*.lpr' -File -ErrorAction SilentlyContinue
    }
    if ($dprFiles) {
        # Le o "program NomeProjeto;" do arquivo para garantir consistencia
        $firstLine = Get-Content -Path $dprFiles[0].FullName -TotalCount 5 |
        Where-Object { $_ -match '^\s*program\s+(\w+)\s*;' } |
        Select-Object -First 1
        if ($firstLine -match '^\s*program\s+(\w+)\s*;') {
            $ProjectName = $Matches[1]
        }
        else {
            $ProjectName = [System.IO.Path]::GetFileNameWithoutExtension($dprFiles[0].Name)
        }
    }
    else {
        $ProjectName = 'Project'
        Write-Host '  [AVISO]  Nenhum .dpr encontrado - usando nome padrao "Project".' -ForegroundColor Yellow
    }
}

$ProjectDpr = "$ProjectName.dpr"

# Gera GUID se nao informado
if (-not $ProjectGuid) {
    $ProjectGuid = '{' + [System.Guid]::NewGuid().ToString().ToUpper() + '}'
}

Write-Host ''
Write-Host '  bootstrap-build-config - Geracao de arquivos de build e projeto Delphi' -ForegroundColor Cyan
Write-Host "  Raiz    : $RepoRoot"          -ForegroundColor Gray
Write-Host "  Projeto : $ProjectName"        -ForegroundColor Gray
Write-Host "  GUID    : $ProjectGuid"        -ForegroundColor Gray
Write-Host "  Studio  : $StudioVersion"      -ForegroundColor Gray
Write-Host "  Defines : $ConditionalDefines" -ForegroundColor Gray
Write-Host ''

# =============================================================================
# Mapeamentos: template (nome no disco) -> destino (nome final na raiz)
# Os templates de .dpr/.dproj tem "{PROJECT_NAME}" no proprio nome do arquivo.
# =============================================================================
$mappings = @(
    @{ Template = 'dcc32.cfg.template'; Dest = 'dcc32.cfg'; Skip = $false; NeverOverwrite = $false },
    @{ Template = 'dcc64.cfg.template'; Dest = 'dcc64.cfg'; Skip = $false; NeverOverwrite = $false },
    @{ Template = 'fpc32.opts.template'; Dest = 'fpc32.opts'; Skip = $false; NeverOverwrite = $false },
    @{ Template = 'fpc64.opts.template'; Dest = 'fpc64.opts'; Skip = $false; NeverOverwrite = $false },
    @{ Template = '{PROJECT_NAME}.dpr.template'; Dest = "$ProjectName.dpr"; Skip = $SkipProjectFiles.IsPresent; NeverOverwrite = $false },
    @{ Template = '{PROJECT_NAME}.dproj.template'; Dest = "$ProjectName.dproj"; Skip = $SkipProjectFiles.IsPresent; NeverOverwrite = $false },
    @{ Template = '{PROJECT_NAME}.lpr.template'; Dest = "$ProjectName.lpr"; Skip = $SkipLazarusFiles.IsPresent; NeverOverwrite = $false },
    @{ Template = '{PROJECT_NAME}.lpi.template'; Dest = "$ProjectName.lpi"; Skip = $SkipLazarusFiles.IsPresent; NeverOverwrite = $false },
    @{ Template = '{PROJECT_NAME}.lps.template'; Dest = "$ProjectName.lps"; Skip = $SkipLazarusFiles.IsPresent; NeverOverwrite = $false },
    # Ignore files — nunca sobrescritos (preservam configuracao manual do usuario)
    @{ Template = '.gitignore.template'; Dest = '.gitignore'; Skip = $false; NeverOverwrite = $true },
    @{ Template = '.claudeignore.template'; Dest = '.claudeignore'; Skip = $false; NeverOverwrite = $true },
    @{ Template = '.cursorignore.template'; Dest = '.cursorignore'; Skip = $false; NeverOverwrite = $true },
    @{ Template = '.continueignore.template'; Dest = '.continueignore'; Skip = $false; NeverOverwrite = $true }
)

# =============================================================================
# Tabela de substituicao (placeholders -> valores reais)
# =============================================================================
$replacements = [ordered]@{
    '{PROJECT_NAME}'           = $ProjectName
    '{PROJECT_DPR}'            = $ProjectDpr
    '{PROJECT_GUID}'           = $ProjectGuid
    '{PROJECT_VERSION}'        = $ProjectVersion
    '{CONDITIONAL_DEFINES}'    = $ConditionalDefines
    '{MAIN_FORM_UNIT}'         = $MainFormUnit
    '{MAIN_FORM_CLASS}'        = $MainFormClass
    '{MAIN_FORM_INSTANCE}'     = $MainFormClass   # instancia tem mesmo nome da classe (sem T)
    '{REPO_ROOT}'              = $RepoRoot
    '{STUDIO_VERSION}'         = $StudioVersion
    '{ZEOS_ROOT}'              = $ZeosRoot
    '{DATASET_SERIALIZE_ROOT}' = $DatasetSerializeRoot
    '{SYNAPSE_ROOT}'           = $SynapseRoot
    '{UNIDAC_ROOT}'            = $UnidacRoot
    '{FPC_ROOT}'               = $FpcRoot
    '{LAZARUS_ROOT}'           = $LazarusRoot
    '{FPC_OPM_ROOT}'           = $FpcOpmRoot
    '{DATE}'                   = (Get-Date -Format 'dd/MM/yyyy')
}

$created = 0
$skipped = 0
$errors = 0

foreach ($m in $mappings) {

    if ($m.Skip) { continue }

    # Nome do template pode conter {PROJECT_NAME} no proprio filename
    $templateFileName = $m.Template.Replace('{PROJECT_NAME}', $ProjectName)
    # Tenta primeiro pelo nome substituido, depois pelo nome original (com chaves)
    $templatePath = Join-Path $TemplateDir $templateFileName
    if (-not (Test-Path $templatePath)) {
        $templatePath = Join-Path $TemplateDir $m.Template
    }

    $destPath = Join-Path $RepoRoot $m.Dest

    # --- ValidateOnly ---
    if ($ValidateOnly) {
        $tplOk = if (Test-Path $templatePath) { 'OK' } else { 'AUSENTE' }
        $status = if (Test-Path $destPath) { '[EXISTE] ' } else { '[AUSENTE]' }
        Write-Host "  $status  $($m.Dest)  (template: $tplOk)" -ForegroundColor Yellow
        continue
    }

    # --- Template ausente ---
    if (-not (Test-Path $templatePath)) {
        Write-Host "  [ERRO]    Template nao encontrado: $($m.Template)" -ForegroundColor Red
        $errors++
        continue
    }

    # --- Destino ja existe ---
    $neverOverwrite = $false
    if ($m.ContainsKey('NeverOverwrite')) { $neverOverwrite = [bool]$m.NeverOverwrite }

    if (Test-Path $destPath) {
        if ($neverOverwrite) {
            Write-Host "  [EXISTE]  $($m.Dest) - ja existe (nunca sobrescrito)" -ForegroundColor DarkGray
            $skipped++
            continue
        }
        if (-not $Force) {
            Write-Host "  [EXISTE]  $($m.Dest) - ja existe (use -Force para sobrescrever)" -ForegroundColor DarkGray
            $skipped++
            continue
        }
    }

    # --- Gera arquivo ---
    try {
        $content = Get-Content -Path $templatePath -Raw -Encoding UTF8
        foreach ($key in $replacements.Keys) {
            $content = $content.Replace($key, $replacements[$key])
        }
        Set-Content -Path $destPath -Value $content -Encoding UTF8 -NoNewline
        Write-Host "  [CRIADO]  $($m.Dest)" -ForegroundColor Green
        $created++
    }
    catch {
        Write-Host "  [ERRO]    Falha ao gerar $($m.Dest): $_" -ForegroundColor Red
        $errors++
    }
}

# =============================================================================
# .workspace/context.json (template) — específico do clone (não propagado)
# =============================================================================
if ($ValidateOnly) {
    $wsStatus = if (Test-Path $WorkspaceContextPath) { '[EXISTE] ' } else { '[AUSENTE]' }
    Write-Host "  $wsStatus  .workspace/context.json  (template gerado pelo bootstrap)" -ForegroundColor Yellow
}
else {
    if (-not (Test-Path $WorkspaceDir)) {
        New-Item -Path $WorkspaceDir -ItemType Directory -Force | Out-Null
    }

    if (-not (Test-Path $WorkspaceContextPath)) {
        $contextTemplate = @"
{
  "_note": "Contexto específico deste clone/workspace. Este ficheiro NÃO é propagado pelo pack `.cursor/`.",
  "projectName": "$ProjectName",
  "backendRoot": "",
  "modules": [],
  "_frameworks_overrides": {
    "_note": "Overrides locais (paths/versões) por máquina/projeto. Use as mesmas chaves de `.cursor/config.json` → `_frameworks`."
  }
}
"@
        try {
            Set-Content -Path $WorkspaceContextPath -Value $contextTemplate -Encoding UTF8 -NoNewline
            Write-Host '  [CRIADO]  .workspace/context.json' -ForegroundColor Green
            $created++
        }
        catch {
            Write-Host "  [ERRO]    Falha ao gerar .workspace/context.json: $_" -ForegroundColor Red
            $errors++
        }
    }
    else {
        Write-Host '  [EXISTE]  .workspace/context.json - ja existe (nao sobrescrito)' -ForegroundColor DarkGray
        $skipped++
    }
}

Write-Host ''
if ($ValidateOnly) {
    Write-Host '  Modo ValidateOnly - nenhum arquivo foi criado.' -ForegroundColor Yellow
}
else {
    Write-Host "  Resumo: $created criado(s), $skipped ignorado(s), $errors erro(s)." -ForegroundColor Cyan
}
Write-Host ''

if ($errors -gt 0) { exit 1 }
exit 0

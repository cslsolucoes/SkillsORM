#Requires -Version 5.1
<#
.SYNOPSIS
    Script de sideload, verificacao e remocao de MSIX para testes.

.DESCRIPTION
    Automatiza o fluxo completo de teste de MSIX via sideloading:
      1. Instalar certificado de teste no Trusted Root
      2. Instalar o MSIX (Add-AppxPackage)
      3. Verificar a instalacao
      4. (Opcional) Desinstalar apos os testes

    PRE-REQUISITO: Sideloading habilitado em Settings > For Developers > Developer Mode
    ou via Group Policy (AllowAllTrustedApps).

.PARAMETER MsixPath
    Caminho para o arquivo .msix a instalar.

.PARAMETER CertPath
    Caminho para o arquivo .cer do certificado de teste.
    Necessario apenas se o certificado nao estiver instalado.

.PARAMETER PackageName
    Nome do pacote (campo Name do Identity no AppxManifest.xml).
    Ex.: Empresa.GestorERP
    Usado para verificar e desinstalar.

.PARAMETER Action
    Acao a executar:
      Install   — instalar o MSIX (padrao)
      Update    — atualizar para nova versao (ForceUpdateFromAnyVersion)
      Uninstall — desinstalar o pacote
      Verify    — apenas verificar se esta instalado

.PARAMETER SkipCertInstall
    Se presente, pula a instalacao do certificado (assume ja instalado).

.EXAMPLE
    # Instalar (primeira vez)
    .\sideload_testing.ps1 `
      -MsixPath ".\dist\GestorERP_1.0.0.0_x64.msix" `
      -CertPath ".\certs\codesigning_test.cer" `
      -PackageName "Empresa.GestorERP"

.EXAMPLE
    # Atualizar para nova versao
    .\sideload_testing.ps1 `
      -MsixPath ".\dist\GestorERP_1.0.1.0_x64.msix" `
      -PackageName "Empresa.GestorERP" `
      -Action Update `
      -SkipCertInstall

.EXAMPLE
    # Desinstalar
    .\sideload_testing.ps1 -PackageName "Empresa.GestorERP" -Action Uninstall

.NOTES
    Skill: developer-delphi-windows-msix_V1.0.0
    Requer execucao como Administrador para instalar o certificado no LocalMachine\Root.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$MsixPath = "",

    [Parameter(Mandatory = $false)]
    [string]$CertPath = "",

    [Parameter(Mandatory = $true)]
    [string]$PackageName,

    [Parameter(Mandatory = $false)]
    [ValidateSet("Install", "Update", "Uninstall", "Verify")]
    [string]$Action = "Install",

    [Parameter(Mandatory = $false)]
    [switch]$SkipCertInstall
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ─── Funcoes auxiliares ──────────────────────────────────────────────────────

function Write-Step { param([string]$Msg) Write-Host "" ; Write-Host ">>> $Msg" -ForegroundColor Cyan }
function Write-Ok   { param([string]$Msg) Write-Host "    [OK] $Msg" -ForegroundColor Green }
function Write-Warn { param([string]$Msg) Write-Host "    [AVISO] $Msg" -ForegroundColor Yellow }
function Write-Fail { param([string]$Msg) Write-Host "    [ERRO] $Msg" -ForegroundColor Red }

function Test-IsAdmin {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}

function Get-InstalledPackage {
    param([string]$Name)
    Get-AppxPackage -Name $Name -ErrorAction SilentlyContinue
}

# ─── Acao: Verify ────────────────────────────────────────────────────────────

function Invoke-Verify {
    Write-Step "Verificando instalacao de '$PackageName'..."
    $pkg = Get-InstalledPackage -Name $PackageName
    if ($pkg) {
        Write-Ok "Pacote instalado:"
        Write-Host "    Name          : $($pkg.Name)"
        Write-Host "    Version       : $($pkg.Version)"
        Write-Host "    PackageFullName: $($pkg.PackageFullName)"
        Write-Host "    InstallLocation: $($pkg.InstallLocation)"
        Write-Host "    Status        : $($pkg.Status)"
    } else {
        Write-Warn "Pacote '$PackageName' NAO esta instalado."
    }
    return $pkg
}

# ─── Acao: Instalar certificado ───────────────────────────────────────────────

function Install-TestCertificate {
    if ($SkipCertInstall) {
        Write-Warn "Instalacao de certificado ignorada (-SkipCertInstall)."
        return
    }

    if (-not $CertPath) {
        Write-Warn "CertPath nao fornecido. Pulando instalacao de certificado."
        Write-Warn "Se o MSIX nao estiver assinado com certificado confiavel, a instalacao falhara."
        return
    }

    if (-not (Test-Path $CertPath)) {
        throw "Arquivo .cer nao encontrado: $CertPath"
    }

    Write-Step "Instalando certificado de teste..."
    Write-Host "    Arquivo: $CertPath"

    if (Test-IsAdmin) {
        Import-Certificate -FilePath $CertPath -CertStoreLocation "Cert:\LocalMachine\Root" | Out-Null
        Write-Ok "Certificado instalado em Cert:\LocalMachine\Root (todos os usuarios)."
    } else {
        Write-Warn "Sem privilegios de Admin. Instalando em Cert:\CurrentUser\Root (usuario atual)."
        Import-Certificate -FilePath $CertPath -CertStoreLocation "Cert:\CurrentUser\Root" | Out-Null
        Write-Ok "Certificado instalado em Cert:\CurrentUser\Root."
        Write-Warn "Para instalar para todos os usuarios, execute como Administrador."
    }
}

# ─── Acao: Install ────────────────────────────────────────────────────────────

function Invoke-Install {
    if (-not $MsixPath) { throw "-MsixPath e obrigatorio para Install." }
    if (-not (Test-Path $MsixPath)) { throw "MSIX nao encontrado: $MsixPath" }

    Install-TestCertificate

    Write-Step "Instalando MSIX..."
    Write-Host "    Arquivo: $MsixPath"

    # Verificar se ja esta instalado
    $existing = Get-InstalledPackage -Name $PackageName
    if ($existing) {
        Write-Warn "Pacote ja instalado (versao $($existing.Version)). Use -Action Update para atualizar."
        return
    }

    Add-AppxPackage -Path $MsixPath -ErrorAction Stop
    Write-Ok "MSIX instalado com sucesso."

    Invoke-Verify | Out-Null
}

# ─── Acao: Update ─────────────────────────────────────────────────────────────

function Invoke-Update {
    if (-not $MsixPath) { throw "-MsixPath e obrigatorio para Update." }
    if (-not (Test-Path $MsixPath)) { throw "MSIX nao encontrado: $MsixPath" }

    Install-TestCertificate

    Write-Step "Atualizando MSIX..."
    Write-Host "    Arquivo: $MsixPath"

    $existing = Get-InstalledPackage -Name $PackageName
    if ($existing) {
        Write-Host "    Versao atual: $($existing.Version)"
    } else {
        Write-Warn "Pacote nao instalado. Instalando como novo..."
    }

    # ForceUpdateFromAnyVersion permite downgrade tambem (util em testes)
    Add-AppxPackage -Path $MsixPath -ForceUpdateFromAnyVersion -ErrorAction Stop
    Write-Ok "MSIX atualizado com sucesso."

    Invoke-Verify | Out-Null
}

# ─── Acao: Uninstall ──────────────────────────────────────────────────────────

function Invoke-Uninstall {
    Write-Step "Desinstalando '$PackageName'..."

    $pkg = Get-InstalledPackage -Name $PackageName
    if (-not $pkg) {
        Write-Warn "Pacote '$PackageName' nao esta instalado. Nada a fazer."
        return
    }

    Write-Host "    PackageFullName: $($pkg.PackageFullName)"
    Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction Stop
    Write-Ok "Pacote desinstalado com sucesso."

    # Confirmar remocao
    Start-Sleep -Milliseconds 500
    $check = Get-InstalledPackage -Name $PackageName
    if ($check) {
        Write-Warn "Pacote ainda aparece instalado. Pode precisar de reinicializacao."
    } else {
        Write-Ok "Confirmado: pacote removido do sistema."
    }
}

# ─── Dispatcher ──────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "=== MSIX Sideload Testing ===" -ForegroundColor Cyan
Write-Host "  PackageName : $PackageName"
Write-Host "  Action      : $Action"
if ($MsixPath) { Write-Host "  MSIX        : $MsixPath" }
Write-Host ""

switch ($Action) {
    "Install"   { Invoke-Install }
    "Update"    { Invoke-Update }
    "Uninstall" { Invoke-Uninstall }
    "Verify"    { Invoke-Verify | Out-Null }
}

Write-Host ""
Write-Host "Concluido." -ForegroundColor Green
Write-Host ""

#Requires -Version 5.1
<#
.SYNOPSIS
    Script completo de Code Signing para testes locais com certificado auto-assinado.

.DESCRIPTION
    Executa o fluxo completo de Code Signing para desenvolvimento e testes:
      1. Cria certificado auto-assinado com as extensoes corretas para Code Signing
      2. Exporta o certificado publico (.cer) para distribuicao nas maquinas de teste
      3. Exporta o certificado com chave privada (.pfx) para uso no signtool
      4. Instala o .cer no Trusted Root (requer Admin)
      5. Assina um arquivo de teste com signtool
      6. Verifica a assinatura

.PARAMETER SubjectName
    Nome do Subject do certificado. Ex.: "CN=Empresa LTDA, O=Empresa LTDA, C=BR"

.PARAMETER FriendlyName
    Nome amigavel do certificado. Ex.: "MeuApp Test Signing"

.PARAMETER OutputFolder
    Pasta onde os arquivos .cer e .pfx serao exportados. Padrao: pasta atual.

.PARAMETER PfxPassword
    Senha para proteger o arquivo .pfx. OBRIGATORIO.

.PARAMETER FileToSign
    Caminho do arquivo a ser assinado para teste (opcional).
    Se nao informado, cria um arquivo dummy para testar.

.PARAMETER TimestampServer
    URL do servidor de timestamp. Padrao: http://timestamp.digicert.com

.EXAMPLE
    .\codesigning_test.ps1 `
      -SubjectName "CN=GestorERP Dev, O=Empresa LTDA, C=BR" `
      -FriendlyName "GestorERP Dev Signing" `
      -PfxPassword "Senha@Dev2026" `
      -OutputFolder ".\certs"

.NOTES
    ATENCAO: Este script e apenas para TESTES LOCAIS.
    NUNCA use certificado auto-assinado em producao ou na Microsoft Store.
    NUNCA versione o arquivo .pfx no controle de versao.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$SubjectName = "CN=GestorERP Dev, O=Empresa LTDA, C=BR",

    [Parameter(Mandatory = $false)]
    [string]$FriendlyName = "GestorERP Dev Signing",

    [Parameter(Mandatory = $true)]
    [string]$PfxPassword,

    [Parameter(Mandatory = $false)]
    [string]$OutputFolder = ".",

    [Parameter(Mandatory = $false)]
    [string]$FileToSign = "",

    [Parameter(Mandatory = $false)]
    [string]$TimestampServer = "http://timestamp.digicert.com"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ─── Funcoes auxiliares ─────────────────────────────────────────────────────

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host ">>> $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "    [OK] $Message" -ForegroundColor Green
}

function Write-Fail {
    param([string]$Message)
    Write-Host "    [ERRO] $Message" -ForegroundColor Red
}

function Find-SignTool {
    $kitBase = "C:\Program Files (x86)\Windows Kits\10\bin"
    if (-not (Test-Path $kitBase)) {
        throw "Windows Kits nao encontrado em '$kitBase'. Instale o Windows SDK."
    }

    $signtool = Get-ChildItem "$kitBase\*\x64\signtool.exe" |
        Sort-Object FullName -Descending |
        Select-Object -First 1 -ExpandProperty FullName

    if (-not $signtool) {
        throw "signtool.exe nao encontrado. Instale o Windows SDK (componente 'Windows SDK Signing Tools')."
    }
    return $signtool
}

# ─── Validacoes iniciais ─────────────────────────────────────────────────────

Write-Step "Validando prerequisitos..."

# Criar pasta de saida se nao existir
if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
    Write-Success "Pasta '$OutputFolder' criada."
}

$OutputFolder = Resolve-Path $OutputFolder

# Verificar se signtool esta disponivel
$signtoolPath = Find-SignTool
Write-Success "signtool encontrado: $signtoolPath"

# ─── PASSO 1: Criar certificado auto-assinado ────────────────────────────────

Write-Step "Criando certificado auto-assinado..."
Write-Host "    Subject: $SubjectName"
Write-Host "    Friendly Name: $FriendlyName"

$cert = New-SelfSignedCertificate `
    -Type Custom `
    -Subject $SubjectName `
    -KeyUsage DigitalSignature `
    -FriendlyName $FriendlyName `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -TextExtension @(
        "2.5.29.37={text}1.3.6.1.5.5.7.3.3",  # Extended Key Usage: Code Signing
        "2.5.29.19={text}"                        # Basic Constraints: nao e CA
    )

Write-Success "Certificado criado."
Write-Host "    Thumbprint : $($cert.Thumbprint)"
Write-Host "    Valido de  : $($cert.NotBefore)"
Write-Host "    Valido ate : $($cert.NotAfter)"

# ─── PASSO 2: Exportar certificado publico (.cer) ────────────────────────────

Write-Step "Exportando certificado publico (.cer)..."

$cerPath = Join-Path $OutputFolder "codesigning_test.cer"
Export-Certificate -Cert $cert -FilePath $cerPath | Out-Null
Write-Success "Exportado: $cerPath"
Write-Host "    INSTRUCAO: Copiar este .cer para cada maquina de teste e instalar no Trusted Root."

# ─── PASSO 3: Exportar chave privada (.pfx) ──────────────────────────────────

Write-Step "Exportando chave privada (.pfx)..."

$pfxPath = Join-Path $OutputFolder "codesigning_test.pfx"
$securePwd = ConvertTo-SecureString -String $PfxPassword -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath $pfxPath -Password $securePwd | Out-Null

Write-Success "Exportado: $pfxPath"
Write-Host "    ATENCAO: Nao versione este arquivo. Adicione '*.pfx' ao .gitignore." -ForegroundColor Yellow

# ─── PASSO 4: Instalar .cer no Trusted Root ──────────────────────────────────

Write-Step "Instalando .cer no Trusted Root da maquina local..."

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if ($isAdmin) {
    Import-Certificate -FilePath $cerPath -CertStoreLocation "Cert:\LocalMachine\Root" | Out-Null
    Write-Success "Certificado instalado em Cert:\LocalMachine\Root"
    Write-Host "    Esta maquina agora confia em binarios assinados com este certificado."
} else {
    Write-Host "    [AVISO] Nao e administrador. Instalando no store do usuario atual..." -ForegroundColor Yellow
    Import-Certificate -FilePath $cerPath -CertStoreLocation "Cert:\CurrentUser\Root" | Out-Null
    Write-Host "    Instalado em Cert:\CurrentUser\Root (valido apenas para este usuario)." -ForegroundColor Yellow
    Write-Host "    Para instalar para todos os usuarios, execute como Administrador." -ForegroundColor Yellow
}

# ─── PASSO 5: Assinar arquivo de teste ───────────────────────────────────────

Write-Step "Assinando arquivo de teste..."

if ($FileToSign -eq "" -or -not (Test-Path $FileToSign)) {
    # Criar arquivo dummy para teste
    $dummyPath = Join-Path $OutputFolder "signing_test_dummy.exe"
    # Copiar o proprio PowerShell como arquivo de teste (ja e um PE valido)
    Copy-Item -Path (Get-Command "powershell.exe").Source -Destination $dummyPath
    $FileToSign = $dummyPath
    Write-Host "    Arquivo de teste criado: $dummyPath"
}

Write-Host "    Arquivo a assinar: $FileToSign"
Write-Host "    Timestamp server : $TimestampServer"

$signArgs = @(
    "sign",
    "/fd", "SHA256",
    "/f", "`"$pfxPath`"",
    "/p", "`"$PfxPassword`"",
    "/tr", $TimestampServer,
    "/td", "SHA256",
    "`"$FileToSign`""
)

$signOutput = & $signtoolPath sign /fd SHA256 /f "$pfxPath" /p "$PfxPassword" /tr $TimestampServer /td SHA256 "$FileToSign" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Success "Arquivo assinado com sucesso."
} else {
    Write-Fail "Falha na assinatura. Saida do signtool:"
    Write-Host $signOutput
    exit 1
}

# ─── PASSO 6: Verificar assinatura ───────────────────────────────────────────

Write-Step "Verificando assinatura..."

$verifyOutput = & $signtoolPath verify /pa /v "$FileToSign" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Success "Assinatura verificada com sucesso."
} else {
    Write-Fail "Verificacao falhou. Saida:"
    Write-Host $verifyOutput
    exit 1
}

# ─── Resumo final ────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESUMO DO AMBIENTE DE CODE SIGNING" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Thumbprint  : $($cert.Thumbprint)"
Write-Host "  Subject     : $($cert.Subject)"
Write-Host "  Valido ate  : $($cert.NotAfter)"
Write-Host "  .cer        : $cerPath"
Write-Host "  .pfx        : $pfxPath"
Write-Host "  signtool    : $signtoolPath"
Write-Host ""
Write-Host "  PROXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "  1. Copiar '$cerPath' para as maquinas de teste"
Write-Host "  2. Instalar o .cer no Trusted Root de cada maquina de teste"
Write-Host "  3. Usar o .pfx no signtool para assinar builds (dev)"
Write-Host "  4. Para CI/CD: converter .pfx para Base64 e salvar em secret"
Write-Host ""
Write-Host "  IMPORTANTE: Nunca versione o arquivo .pfx!" -ForegroundColor Red
Write-Host ""

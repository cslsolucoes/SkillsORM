<#
  transform-headers-adorm.ps1
  Fase 3 — Adds Company: field and normalizes YYYY-MM-DD dates in
  ActiveDirectoryORM headers. Creates header for ufrmLDAP_Teste.pas.

  Usage:
    powershell -ExecutionPolicy Bypass -File transform-headers-adorm.ps1 [-WhatIf]
#>
param([switch]$WhatIf)

$ErrorActionPreference = 'Stop'
$ADPath    = 'E:\GestorERP\projects\modules\ActiveDirectoryORM\src'
$Company   = 'CSL Tech Solutions'
$Author    = 'Claiton de Souza Linhares'
$ProjName  = 'ActiveDirectoryORM'
$ProjVer   = '1.0.0'
$Today     = '14/04/2026'
$SEP       = '=' * 77

# ---------------------------------------------------------------------------
# Normalize YYYY-MM-DD dates to DD/MM/YYYY anywhere in a string
# ---------------------------------------------------------------------------
function ConvertDate([string]$text) {
    return [Regex]::Replace($text,
        '(\d{4})-(\d{2})-(\d{2})',
        { param($m) "$($m.Groups[3].Value)/$($m.Groups[2].Value)/$($m.Groups[1].Value)" })
}

# ---------------------------------------------------------------------------
# Add Company: field and normalize dates in a file that has canonical header
# ---------------------------------------------------------------------------
function Invoke-UpdateHeader([string]$FilePath) {
    $enc     = [System.Text.Encoding]::GetEncoding(65001)
    $content = [System.IO.File]::ReadAllText($FilePath, $enc)

    # Must have canonical header
    if ($content -notmatch '(?ms)^\{[ ]+={3,}') {
        Write-Host "  SKIP (no canonical header): $(Split-Path $FilePath -Leaf)"
        return $false
    }
    # Skip if Company: already present
    if ($content -match '^\s+Company:') {
        Write-Host "  SKIP (Company already present): $(Split-Path $FilePath -Leaf)"
        return $false
    }

    $nl    = if ($content -match '\r\n') { "`r`n" } else { "`n" }
    $lines = $content -split '\r?\n'

    $modified = [System.Collections.Generic.List[string]]::new()
    $companyAdded = $false

    foreach ($line in $lines) {
        # Insert Company: after FileVersion: line
        if (-not $companyAdded -and $line -match '^\s+FileVersion:') {
            $modified.Add($line) | Out-Null
            $modified.Add("  Company:        $Company") | Out-Null
            $companyAdded = $true
            continue
        }
        # Normalize YYYY-MM-DD dates in Date: field and in changelog entries
        if ($line -match '^\s+Date:\s' -or $line -match '^\s+- ') {
            $modified.Add((ConvertDate $line)) | Out-Null
        } else {
            $modified.Add($line) | Out-Null
        }
    }

    if (-not $companyAdded) {
        Write-Host "  WARN (ProjectVersion not found): $(Split-Path $FilePath -Leaf)"
        return $false
    }

    $newContent = $modified -join $nl
    if ($WhatIf) {
        Write-Host "  [WhatIf] update: $(Split-Path $FilePath -Leaf)"
    } else {
        [System.IO.File]::WriteAllText($FilePath, $newContent, $enc)
        Write-Host "  OK: $(Split-Path $FilePath -Leaf)"
    }
    return $true
}

# ---------------------------------------------------------------------------
# Create header for ufrmLDAP_Teste.pas (no existing header)
# ---------------------------------------------------------------------------
function Invoke-CreateLdapTesteHeader([string]$FilePath) {
    $enc     = [System.Text.Encoding]::GetEncoding(65001)
    $content = [System.IO.File]::ReadAllText($FilePath, $enc)

    $nl    = if ($content -match '\r\n') { "`r`n" } else { "`n" }
    $lines = $content -split '\r?\n'

    # find unit declaration line
    $unitLine = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^unit\s') { $unitLine = $i; break }
    }
    if ($unitLine -eq -1) { Write-Host "  SKIP (no unit): $(Split-Path $FilePath -Leaf)"; return $false }

    $unitName = if ($lines[$unitLine] -match '^unit\s+(\S+);') { $Matches[1] } else { 'ufrmLDAP_Teste' }

    $header = @(
        "{ $SEP",
        "  $unitName - Formulario de teste de integracao LDAP",
        '',
        "  Project:        $ProjName",
        "  ProjectVersion: $ProjVer",
        "  FileVersion:    1.0.0",
        "  Company:        $Company",
        "  Author:         $Author",
        "  Date:           $Today",
        '',
        '  Changelog (file):',
        "  - 1.0.0 ($Today): Cabecario adicionado.",
        "  $SEP }"
    )

    $before = $lines[0..$unitLine]
    $skipTo = $unitLine + 1
    while ($skipTo -lt $lines.Count -and $lines[$skipTo] -eq '') { $skipTo++ }
    $after  = if ($skipTo -lt $lines.Count) { $lines[$skipTo..($lines.Count - 1)] } else { @() }

    $newContent = (@($before) + @('') + $header + @('') + @($after)) -join $nl

    if ($WhatIf) {
        Write-Host "  [WhatIf] create: $(Split-Path $FilePath -Leaf)"
    } else {
        [System.IO.File]::WriteAllText($FilePath, $newContent, $enc)
        Write-Host "  OK (created): $(Split-Path $FilePath -Leaf)"
    }
    return $true
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
$files = Get-ChildItem -Path $ADPath -Recurse -Filter '*.pas'
Write-Host "Found $($files.Count) .pas files in $ADPath"
Write-Host ''

$updated = 0; $created = 0; $skipped = 0
foreach ($f in $files) {
    if ($f.Name -eq 'ufrmLDAP_Teste.pas') {
        $r = Invoke-CreateLdapTesteHeader -FilePath $f.FullName
        if ($r) { $created++ } else { $skipped++ }
    } else {
        $r = Invoke-UpdateHeader -FilePath $f.FullName
        if ($r) { $updated++ } else { $skipped++ }
    }
}

Write-Host ''
Write-Host "=== Done: $updated updated, $created created, $skipped skipped ==="

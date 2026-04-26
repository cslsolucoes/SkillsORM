<#
  transform-headers-backend.ps1
  Transforms Pascal unit headers in E:\GestorERP\projects\backend\ to the
  canonical ProvidersORM format with { ===...=== } delimiters.
  Handles both old-style structured headers AND files with no/minimal header.

  Usage:
    powershell -ExecutionPolicy Bypass -File transform-headers-backend.ps1 [-WhatIf]
#>
param([switch]$WhatIf)

$ErrorActionPreference = 'Stop'
$BackendPath = 'E:\GestorERP\projects\backend'
$Author      = 'Claiton de Souza Linhares'
$Company     = 'CSL Tech Solutions'
$ProjVersion = '1.0.0'
$Today       = '14/04/2026'
$SEP         = '=' * 77

# ---------------------------------------------------------------------------
# Title suffix lookup
# ---------------------------------------------------------------------------
function Get-TitleSuffix([string]$UnitName) {
    $parts = $UnitName -split '\.'
    $last  = $parts[-1]
    $prev  = if ($parts.Count -ge 2) { $parts[-2] } else { '' }
    $key   = "$prev.$last"

    switch -Regex ($key) {
        'Domain\.Entities$'         { return 'Entidades de dominio' }
        '\.Entities$'               { return 'Entidades de dominio' }
        'Repository\.Interface$'    { return 'Contrato do repositorio administrativo' }
        'Integration\.Interface$'   { return 'Contrato do autenticador externo' }
        'MainService\.Interfaces$'  { return 'Contratos base do servico principal' }
        '\.Interfaces$'             { return 'Contratos do modulo' }
        'Service\.AdminActions$'    { return 'Acoes administrativas de Seguranca' }
        'Service\.Actions$'         { return 'Acoes do servico' }
        'Service\.Obac$'            { return 'Controle de acesso baseado em objeto (OBAC)' }
        'Service\.Password$'        { return 'Gerenciamento de senhas' }
        'Repository\.Auth$'         { return 'Repositorio de autenticacao e OBAC' }
        'Repository\.Admin$'        { return 'Repositorio administrativo M01' }
        'Auth\.Jwt$'                { return 'Emissao e validacao de tokens JWT HS256' }
        'Auth\.SHA256$'             { return 'Hash HMAC-SHA256 para autenticacao' }
        'Auth\.RequestContext$'     { return 'Contexto da requisicao autenticada' }
        'Integration\.Ldap$'        { return 'Autenticador LDAP' }
        'Ldap\.Service$'            { return 'Servico de integracao LDAP/Active Directory' }
        'Commons\.Logging$'         { return 'Bridge de log (ProvidersORM Loggers)' }
        'Commons\.Parameters$'      { return 'Bridge de parametros (ProvidersORM Parameters)' }
        'Commons\.Encoding$'        { return 'Shim de codificacao Base64/UTF-8' }
        'Connection\.Interfaces$'   { return 'Contrato da fabrica de conexao ORM' }
        'MainService\.Connection$'  { return 'Fabrica de conexao ORM' }
        'Message\.Request$'         { return 'Contrato de mensagem de requisicao REST' }
        'MainService\.Container$'   { return 'Container de injecao de dependencia (DI)' }
        'EntryPoint\.ServerMain$'   { return 'Registro e inicializacao dos entrypoints REST' }
        'EntryPoint\.Security$'     { return 'Entrypoints de seguranca e OBAC' }
        'EntryPoint\.Helpers$'      { return 'Funcoes auxiliares dos entrypoints' }
        'Access\.EntryPoint$'       { return 'Entrypoints de autenticacao' }
        'Logger\.Bridge$'           { return 'Bridge de log (ProvidersORM Loggers)' }
        'Parameters\.Bridge$'       { return 'Bridge de parametros (ProvidersORM Parameters)' }
        '\.Connection$'             { return 'Fabrica de conexao ORM' }
        '\.Repository$'             { return 'Repositorio de dados' }
        '\.Service$'                { return 'Servico de dominio' }
        '\.DTOs\.'                  { return "DTOs - $last" }
        '\.JsonKeys$'               { return 'Chaves JSON dos DTOs' }
        default {
            if ($UnitName -match 'RDW') { return "Entrypoints REST - $last" }
            return $last
        }
    }
}

# ---------------------------------------------------------------------------
# Build canonical header lines (shared by transform and create)
# ---------------------------------------------------------------------------
function Build-Header([string]$UnitName, [string]$Project, [string]$FileVersion,
                      [string]$Date, [string[]]$DescLines, [string[]]$PadraoLines,
                      [string[]]$ChangelogLines) {
    $out = [System.Collections.Generic.List[string]]::new()
    $out.Add("{ $SEP")                                       | Out-Null
    $out.Add("  $UnitName - $(Get-TitleSuffix $UnitName)")  | Out-Null
    $out.Add('')                                              | Out-Null

    if ($DescLines -and $DescLines.Count -gt 0) {
        $out.Add("  $($DescLines -join ' ')")               | Out-Null
        $out.Add('')                                          | Out-Null
    }
    if ($PadraoLines -and $PadraoLines.Count -gt 0) {
        foreach ($pl in $PadraoLines) { $out.Add("  $pl")  | Out-Null }
        $out.Add('')                                          | Out-Null
    }

    $out.Add("  Project:        $Project")    | Out-Null
    $out.Add("  ProjectVersion: $ProjVersion")| Out-Null
    $out.Add("  FileVersion:    $FileVersion")| Out-Null
    $out.Add("  Company:        $Company")    | Out-Null
    $out.Add("  Author:         $Author")     | Out-Null
    $out.Add("  Date:           $Date")       | Out-Null
    $out.Add('')                               | Out-Null
    $out.Add('  Changelog (file):')            | Out-Null

    if ($ChangelogLines -and $ChangelogLines.Count -gt 0) {
        foreach ($cl in $ChangelogLines) { $out.Add($cl) | Out-Null }
    } else {
        $out.Add("  - 1.0.0 ($Today): Cabecario adicionado.") | Out-Null
    }
    $out.Add("  $SEP }") | Out-Null
    return $out.ToArray()
}

# ---------------------------------------------------------------------------
# Transform a file that HAS an old-style structured header (Project: field)
# ---------------------------------------------------------------------------
function Invoke-Transform([string]$FilePath) {
    $enc     = [System.Text.Encoding]::GetEncoding(65001)
    $content = [System.IO.File]::ReadAllText($FilePath, $enc)

    if ($content -notmatch '(?m)^unit\s+(\S+);') { return $false }
    $unitName = $Matches[1]

    $nl    = if ($content -match '\r\n') { "`r`n" } else { "`n" }
    $lines = $content -split '\r?\n'

    # find header: { on own line followed by Project:
    $hStart = -1; $hEnd = -1
    for ($i = 0; $i -lt [Math]::Min(25, $lines.Count); $i++) {
        if ($lines[$i] -eq '{' -and
            $i + 1 -lt $lines.Count -and
            $lines[$i + 1] -match '^\s+Project:') {
            $hStart = $i; break
        }
    }
    if ($hStart -eq -1) { return $false }
    for ($i = $hStart + 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -eq '}') { $hEnd = $i; break }
    }
    if ($hEnd -eq -1) { return $false }

    # parse fields
    $project        = 'GestorERP.Backend'
    $fileVersion    = '1.0.0'
    $date           = $Today
    $escopoLines    = [System.Collections.Generic.List[string]]::new()
    $padraoLines    = [System.Collections.Generic.List[string]]::new()
    $changelogLines = [System.Collections.Generic.List[string]]::new()
    $state          = 'fields'

    foreach ($line in $lines[($hStart + 1)..($hEnd - 1)]) {
        switch ($state) {
            'fields' {
                if      ($line -match '^\s+Project:\s+(.+)') {
                    $raw = $Matches[1].Trim()
                    if ($raw -match '(GestorERP\.\S+)') { $project = $Matches[1] }
                    else                                 { $project = $raw }
                }
                elseif  ($line -match '^\s+FileVersion:\s+(.+)')   { $fileVersion = $Matches[1].Trim() }
                elseif  ($line -match '^\s+Date:\s+(.+)')          { $date        = $Matches[1].Trim() }
                elseif  ($line -match '^\s+Author:')               { <# skip #> }
                elseif  ($line -match '^\s+Escopo:\s*(.*)') {
                    $state = 'escopo'
                    $r = $Matches[1].Trim(); if ($r) { $escopoLines.Add($r) | Out-Null }
                }
                elseif  ($line -match '^\s+Padr')                  { $state = 'padrao' }
                elseif  ($line -match '^\s+Changelog:')            { $state = 'changelog' }
            }
            'escopo' {
                if      ($line -match '^\s+Padr')                  { $state = 'padrao' }
                elseif  ($line -match '^\s+Changelog:')            { $state = 'changelog' }
                elseif  ($line -match '^\s+(Project|FileVersion|Author|Date):') { <# skip #> }
                else    { $t = $line.Trim(); if ($t) { $escopoLines.Add($t) | Out-Null } }
            }
            'padrao' {
                if      ($line -match '^\s+Changelog:')            { $state = 'changelog' }
                else    { $t = $line.Trim(); if ($t) { $padraoLines.Add($t) | Out-Null } }
            }
            'changelog' { $changelogLines.Add($line) | Out-Null }
        }
    }

    $newHdr = Build-Header -UnitName $unitName -Project $project `
                            -FileVersion $fileVersion -Date $date `
                            -DescLines $escopoLines.ToArray() `
                            -PadraoLines $padraoLines.ToArray() `
                            -ChangelogLines $changelogLines.ToArray()

    $before   = if ($hStart -gt 0) { $lines[0..($hStart - 1)] } else { @() }
    $after    = if ($hEnd + 1 -lt $lines.Count) { $lines[($hEnd + 1)..($lines.Count - 1)] } else { @() }
    $newContent = (@($before) + $newHdr + @($after)) -join $nl

    if (-not $WhatIf) { [System.IO.File]::WriteAllText($FilePath, $newContent, $enc) }
    return $true
}

# ---------------------------------------------------------------------------
# Create header for a file that has NO structured header (or a simple comment)
# ---------------------------------------------------------------------------
function Invoke-CreateHeader([string]$FilePath) {
    $enc     = [System.Text.Encoding]::GetEncoding(65001)
    $content = [System.IO.File]::ReadAllText($FilePath, $enc)

    if ($content -notmatch '(?m)^unit\s+(\S+);') { return $false }
    $unitName = $Matches[1]

    $nl    = if ($content -match '\r\n') { "`r`n" } else { "`n" }
    $lines = $content -split '\r?\n'

    # find unit declaration line
    $unitLine = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^unit\s') { $unitLine = $i; break }
    }
    if ($unitLine -eq -1) { return $false }

    # check if there is a simple { ... } block right after (possibly with blank lines)
    $simpleStart = -1; $simpleEnd = -1
    $simpleDesc  = @()
    for ($i = $unitLine + 1; $i -lt [Math]::Min($unitLine + 5, $lines.Count); $i++) {
        if ($lines[$i] -eq '') { continue }
        if ($lines[$i] -match '^{') {
            $simpleStart = $i
            # find closing }
            for ($j = $i; $j -lt $lines.Count; $j++) {
                if ($lines[$j] -match '^\}$' -or ($j -gt $i -and $lines[$j] -match '\}$')) {
                    $simpleEnd = $j; break
                }
                if ($lines[$j] -match '^\{[^$].*\}$' -or $lines[$j] -match '^\{.*\}$') {
                    $simpleEnd = $j; break  # single-line block
                }
            }
            # extract text from simple block
            if ($simpleEnd -ge $simpleStart) {
                $blockText = ($lines[$simpleStart..$simpleEnd] | ForEach-Object {
                    $_ -replace '^\s*\{', '' -replace '\}\s*$', '' | ForEach-Object { $_.Trim() }
                } | Where-Object { $_ -ne '' })
                $simpleDesc = $blockText
            }
        }
        break  # stop after first non-blank line
    }

    $newHdr = Build-Header -UnitName $unitName -Project 'GestorERP.Backend' `
                            -FileVersion '1.0.0' -Date $Today `
                            -DescLines $simpleDesc `
                            -PadraoLines @() `
                            -ChangelogLines @()

    # reassemble: unit line + blank + new header + blank + rest
    $before = $lines[0..$unitLine]   # unit XXX; line
    $skipTo = $unitLine + 1
    # skip blank lines after unit declaration
    while ($skipTo -lt $lines.Count -and $lines[$skipTo] -eq '') { $skipTo++ }
    # skip old simple block if found
    if ($simpleStart -ge 0 -and $simpleEnd -ge 0) { $skipTo = $simpleEnd + 1 }
    # skip blank lines after old block
    while ($skipTo -lt $lines.Count -and $lines[$skipTo] -eq '') { $skipTo++ }

    $after = if ($skipTo -lt $lines.Count) { $lines[$skipTo..($lines.Count - 1)] } else { @() }
    $newContent = (@($before) + @('') + $newHdr + @('') + @($after)) -join $nl

    if (-not $WhatIf) { [System.IO.File]::WriteAllText($FilePath, $newContent, $enc) }
    return $true
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
$files = Get-ChildItem -Path $BackendPath -Recurse -Filter '*.pas' |
         Where-Object { $_.FullName -notmatch '\\Compiled\\' }

Write-Host "Found $($files.Count) .pas files in $BackendPath"
Write-Host ''

$transformed = 0; $created = 0; $skipped = 0
foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::GetEncoding(65001))

    if ($content -match "(?ms)^\{\r?\n\s+Project:") {
        # Has old-style header
        $r = Invoke-Transform -FilePath $f.FullName
        if ($r) {
            if ($WhatIf) { Write-Host "  [WhatIf] transform: $($f.Name)" }
            else          { Write-Host "  OK (transformed): $($f.Name)" }
            $transformed++
        } else {
            Write-Host "  SKIP: $($f.Name)"; $skipped++
        }
    } else {
        # No structured header - create from scratch
        $r = Invoke-CreateHeader -FilePath $f.FullName
        if ($r) {
            if ($WhatIf) { Write-Host "  [WhatIf] create: $($f.Name)" }
            else          { Write-Host "  OK (created): $($f.Name)" }
            $created++
        } else {
            Write-Host "  SKIP: $($f.Name)"; $skipped++
        }
    }
}

Write-Host ''
Write-Host "=== Done: $transformed transformed, $created created, $skipped skipped ==="

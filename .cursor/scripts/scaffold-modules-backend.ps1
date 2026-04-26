<#
  scaffold-modules-backend.ps1
  Cria arquivos scaffold para M02-M26 alinhando com o padrao de M01.
  Arquivos existentes nunca sao sobrescritos.

  Usage:
    powershell -ExecutionPolicy Bypass -File scaffold-modules-backend.ps1 [-WhatIf]
#>
param([switch]$WhatIf)

$ErrorActionPreference = 'Stop'
$BackendPath = 'E:\GestorERP\projects\backend'
$Today       = '15/04/2026'
$Author      = 'Claiton de Souza Linhares'
$Company     = 'CSL Tech Solutions'
$ProjVer     = '1.0.0'
$SEP         = '=' * 77
$enc         = [System.Text.Encoding]::GetEncoding(65001)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
function Write-Pas([string]$Path, [string]$Content) {
    if (Test-Path $Path) { Write-Host "  SKIP (exists): $(Split-Path $Path -Leaf)"; return }
    if ($WhatIf) { Write-Host "  [WhatIf] $Path"; return }
    $dir = Split-Path $Path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    [System.IO.File]::WriteAllText($Path, $Content, $enc)
    Write-Host "  NEW: $(Split-Path $Path -Leaf)"
}

function Remove-GitKeep([string]$Dir) {
    if (-not (Test-Path $Dir)) { return }
    Get-ChildItem -Path $Dir -Recurse -Filter '.gitkeep' | ForEach-Object {
        if ($WhatIf) { Write-Host "  [WhatIf] remove gitkeep: $($_.FullName)" }
        else { Remove-Item $_.FullName -Force; Write-Host "  DEL gitkeep: $($_.DirectoryName)" }
    }
}

function Rename-ModulosDir([string]$ModPath) {
    $old = Join-Path $ModPath 'Modulos'
    $new = Join-Path $ModPath 'modules'
    if (-not (Test-Path $old)) { return }
    if (Test-Path $new) { Write-Host "  SKIP rename (modules exists)"; return }
    if ($WhatIf) { Write-Host "  [WhatIf] rename Modulos->modules" }
    else { Rename-Item -Path $old -NewName 'modules'; Write-Host "  RENAME: Modulos->modules" }
}

# ---------------------------------------------------------------------------
# Header builder (ASCII only)
# ---------------------------------------------------------------------------
function Build-Header([string]$UnitName, [string]$Title, [string]$Version, [string]$Date, [string[]]$Changelog) {
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("{ $SEP") | Out-Null
    $lines.Add("  $UnitName - $Title") | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add("  Project:        GestorERP.Backend") | Out-Null
    $lines.Add("  ProjectVersion: $ProjVer") | Out-Null
    $lines.Add("  FileVersion:    $Version") | Out-Null
    $lines.Add("  Company:        $Company") | Out-Null
    $lines.Add("  Author:         $Author") | Out-Null
    $lines.Add("  Date:           $Date") | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add('  Changelog (file):') | Out-Null
    foreach ($cl in $Changelog) { $lines.Add($cl) | Out-Null }
    $lines.Add("  $SEP }") | Out-Null
    return $lines -join "`r`n"
}

# ---------------------------------------------------------------------------
# Content builders
# ---------------------------------------------------------------------------
function New-LoggerBridge([string]$BasePath) {
    $path = "$BasePath\Commons\Bridges\Commons.Logger.Bridge.pas"
    $hdr  = Build-Header 'Commons.Logger.Bridge' 'Bridge de log (ProvidersORM Loggers)' '1.0.0' $Today @("  - 1.0.0 ($Today): Scaffold inicial.")
    $body = 'unit Commons.Logger.Bridge;' + "`r`n`r`n" + $hdr + "`r`n`r`n" `
          + "interface`r`n`r`ntype`r`n  TLoggerBridge = class`r`n  public`r`n" `
          + "    class procedure Info(const AMessage: string); static;`r`n" `
          + "    class procedure Error(const AMessage: string); static;`r`n" `
          + "  end;`r`n`r`nimplementation`r`n`r`nuses`r`n  System.SysUtils;`r`n`r`n" `
          + "class procedure TLoggerBridge.Info(const AMessage: string);`r`nbegin`r`n" `
          + "  Writeln(FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' [INFO] ' + AMessage);`r`nend;`r`n`r`n" `
          + "class procedure TLoggerBridge.Error(const AMessage: string);`r`nbegin`r`n" `
          + "  Writeln(FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' [ERROR] ' + AMessage);`r`nend;`r`n`r`nend.`r`n"
    Write-Pas $path $body
}

function New-ParametersBridge([string]$BasePath) {
    $path = "$BasePath\Commons\Bridges\Commons.Parameters.Bridge.pas"
    # Copy from M03 (reference file)
    $ref  = "$BackendPath\M03-Clientes\Commons\Bridges\Commons.Parameters.Bridge.pas"
    if (Test-Path $ref) {
        Write-Pas $path ([System.IO.File]::ReadAllText($ref, $enc))
    } else {
        $hdr  = Build-Header 'Commons.Parameters.Bridge' 'Bridge de parametros (ProvidersORM Parameters)' '1.0.0' $Today @("  - 1.0.0 ($Today): Scaffold inicial.")
        $body = "unit Commons.Parameters.Bridge;`r`n`r`n$hdr`r`n`r`ninterface`r`n`r`ntype`r`n  TParametersBridge = class`r`n  public`r`n    class function GetPort: Integer; static;`r`n    class function GetDatabaseIniPath: string; static;`r`n  end;`r`n`r`nimplementation`r`n`r`nuses System.SysUtils, System.IniFiles;`r`n`r`nfunction ExeDir: string; begin Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))); end;`r`n`r`nfunction ResolveConfigIni: string;`r`nvar L1, L2: string;`r`nbegin`r`n  L1 := ExeDir + 'config' + PathDelim + 'database.ini';`r`n  if FileExists(L1) then Exit(L1);`r`n  L2 := ExpandFileName(ExeDir + '..' + PathDelim + '..' + PathDelim + 'config' + PathDelim + 'database.ini');`r`n  if FileExists(L2) then Exit(L2);`r`n  Result := L1;`r`nend;`r`n`r`nclass function TParametersBridge.GetPort: Integer;`r`nvar LIni: TMemIniFile; LPath: string;`r`nbegin`r`n  Result := 9000; LPath := ResolveConfigIni;`r`n  if not FileExists(LPath) then Exit;`r`n  LIni := TMemIniFile.Create(LPath, TEncoding.UTF8);`r`n  try Result := LIni.ReadInteger('server', 'port', 9000); finally LIni.Free; end;`r`nend;`r`n`r`nclass function TParametersBridge.GetDatabaseIniPath: string;`r`nbegin Result := ResolveConfigIni; end;`r`n`r`nend.`r`n"
        Write-Pas $path $body
    }
}

function New-RequestContext([string]$BasePath) {
    $path = "$BasePath\Commons\Bridges\Auth\Commons.Auth.RequestContext.pas"
    $ref  = "$BackendPath\M03-Clientes\Commons\Bridges\Auth\Commons.Auth.RequestContext.pas"
    if (Test-Path $ref) {
        Write-Pas $path ([System.IO.File]::ReadAllText($ref, $enc))
    } else {
        Write-Host "  WARN: M03 RequestContext not found, skipping $path"
    }
}

function New-JsonKeys([string]$BasePath, [string]$Domain) {
    $path = "$BasePath\Commons\DTOs\Contracts.DTOs.$Domain.JsonKeys.pas"
    $unit = "Contracts.DTOs.$Domain.JsonKeys"
    $hdr  = Build-Header $unit "Chaves JSON dos DTOs - $Domain" '1.0.0' $Today @("  - 1.0.0 ($Today): Scaffold inicial.")
    $body = "unit $unit;`r`n`r`n$hdr`r`n`r`ninterface`r`n`r`nconst`r`n" `
          + "  J_${Domain}_ID         = 'id';`r`n" `
          + "  J_${Domain}_EMPRESA_ID = 'empresaId';`r`n" `
          + "  J_${Domain}_NOME       = 'nome';`r`n" `
          + "  J_${Domain}_ATIVO      = 'ativo';`r`n`r`nimplementation`r`n`r`nend.`r`n"
    Write-Pas $path $body
}

function New-EntryPoint([string]$BasePath, [string]$Domain, [string]$MCode, [string]$UrlPath) {
    $path = "$BasePath\Core\EntryPoints\Presentation.RDW.$Domain.pas"
    $unit = "Presentation.RDW.$Domain"
    $hdr  = Build-Header $unit "Entrypoints REST - $Domain" '1.0.0' $Today @("  - 1.0.0 ($Today): Scaffold inicial $MCode.")
    $body = "unit $unit;`r`n`r`n$hdr`r`n`r`ninterface`r`n`r`nuses`r`n  uRESTDWServerEvents;`r`n`r`n" `
          + "procedure Register${Domain}Events(AServerEvents: TRESTDWServerEvents);`r`n`r`nimplementation`r`n`r`nuses`r`n" `
          + "  System.SysUtils, System.Classes, System.JSON,`r`n" `
          + "  uRESTDWParams, uRESTDWConsts,`r`n" `
          + "  Commons.Auth.RequestContext,`r`n" `
          + "  Commons.Logger.Bridge;`r`n`r`ntype`r`n" `
          + "  T${Domain}Events = class`r`n  public`r`n" `
          + "    class procedure List(Var Params: TRESTDWParams; Const Result: TStringList;`r`n" `
          + "      Const RequestType: TRequestType; Var StatusCode: Integer; RequestHeader: TStringList);`r`n" `
          + "  end;`r`n`r`n" `
          + "class procedure T${Domain}Events.List(Var Params: TRESTDWParams; Const Result: TStringList;`r`n" `
          + "  Const RequestType: TRequestType; Var StatusCode: Integer; RequestHeader: TStringList);`r`nbegin`r`n" `
          + "  { TODO: implementar listagem de $Domain }`r`n" `
          + "  StatusCode := 200;`r`n" `
          + "  Result.Text := '{""data"":[],""message"":""$MCode nao implementado""}';`r`nend;`r`n`r`n" `
          + "procedure Register${Domain}Events(AServerEvents: TRESTDWServerEvents);`r`nvar E: TRESTDWEvent;`r`nbegin`r`n" `
          + "  E := TRESTDWEvent(AServerEvents.Events.Add);`r`n" `
          + "  E.EventName := '$UrlPath';`r`n" `
          + "  E.BaseUrl   := '/api/v1/';`r`n" `
          + "  E.DataMode  := dmRAW;`r`n" `
          + "  E.OnReplyEventByType := T${Domain}Events.List;`r`n" `
          + "  E.Routes.All.NeedAuthorization := True;`r`nend;`r`n`r`nend.`r`n"
    Write-Pas $path $body
}

function New-Entities([string]$BasePath, [string]$ModDir, [string]$Domain, [string]$MCode) {
    $path = "$BasePath\$ModDir\$Domain\Domain\Domain.$Domain.Entities.pas"
    $unit = "Domain.$Domain.Entities"
    $hdr  = Build-Header $unit "Entidades de dominio" '1.0.0' $Today @("  - 1.0.0 ($Today): Scaffold inicial $MCode.")
    $body = "unit $unit;`r`n`r`n$hdr`r`n`r`ninterface`r`n`r`nuses`r`n  System.SysUtils;`r`n`r`ntype`r`n" `
          + "  T${MCode}${Domain}Row = record`r`n" `
          + "    Id:        TGUID;`r`n" `
          + "    EmpresaId: TGUID;`r`n" `
          + "    Nome:      string;`r`n" `
          + "    Ativo:     Boolean;`r`n" `
          + "    CreatedAt: TDateTime;`r`n" `
          + "    UpdatedAt: TDateTime;`r`n" `
          + "  end;`r`n`r`nimplementation`r`n`r`nend.`r`n"
    Write-Pas $path $body
}

function New-RepoInterface([string]$BasePath, [string]$ModDir, [string]$Domain, [string]$MCode) {
    $path = "$BasePath\$ModDir\$Domain\Interfaces\Contracts.Interfaces.$Domain.I${Domain}Repository.pas"
    $unit = "Contracts.Interfaces.$Domain.I${Domain}Repository"
    $guid = [Guid]::NewGuid().ToString('D').ToUpper()
    $hdr  = Build-Header $unit "Contrato do repositorio de $Domain" '1.0.0' $Today @("  - 1.0.0 ($Today): Scaffold inicial $MCode.")
    $body = "unit $unit;`r`n`r`n$hdr`r`n`r`ninterface`r`n`r`nuses`r`n" `
          + "  System.SysUtils,`r`n  System.JSON,`r`n  Providers.Connection.Interfaces;`r`n`r`ntype`r`n" `
          + "  I${Domain}Repository = interface`r`n    ['{$guid}']`r`n" `
          + "    function List(AConn: IConnection; const AEmpresaId: TGUID;`r`n" `
          + "      APage, APageSize: Integer; out ATotal: Integer): TJSONArray;`r`n" `
          + "    function TryGetById(AConn: IConnection; const AId, AEmpresaId: TGUID;`r`n" `
          + "      out AObj: TJSONObject): Boolean;`r`n" `
          + "    function TryInsert(AConn: IConnection; const AEmpresaId: TGUID;`r`n" `
          + "      const ABody: TJSONObject; out ANewId: string;`r`n" `
          + "      out AErrorCode, AErrorMsg: string): Boolean;`r`n" `
          + "    function TryUpdate(AConn: IConnection; const AId, AEmpresaId: TGUID;`r`n" `
          + "      const ABody: TJSONObject; out AErrorCode, AErrorMsg: string): Boolean;`r`n" `
          + "    function TryDelete(AConn: IConnection; const AId, AEmpresaId: TGUID;`r`n" `
          + "      out AErrorCode, AErrorMsg: string): Boolean;`r`n" `
          + "  end;`r`n`r`nimplementation`r`n`r`nend.`r`n"
    Write-Pas $path $body
}

function New-Repository([string]$BasePath, [string]$ModDir, [string]$Domain, [string]$MCode) {
    $path = "$BasePath\$ModDir\$Domain\Repositories\Infrastructure.Repositories.$Domain.${Domain}Repository.pas"
    $unit = "Infrastructure.Repositories.$Domain.${Domain}Repository"
    $hdr  = Build-Header $unit "Repositorio de dados - $Domain" '1.0.0' $Today @("  - 1.0.0 ($Today): Scaffold inicial $MCode.")
    $body = "unit $unit;`r`n`r`n$hdr`r`n`r`ninterface`r`n`r`nuses`r`n" `
          + "  System.SysUtils,`r`n  System.JSON,`r`n  Providers.Connection.Interfaces,`r`n" `
          + "  Contracts.Interfaces.$Domain.I${Domain}Repository;`r`n`r`ntype`r`n" `
          + "  T${Domain}Repository = class(TInterfacedObject, I${Domain}Repository)`r`n  public`r`n" `
          + "    function List(AConn: IConnection; const AEmpresaId: TGUID;`r`n" `
          + "      APage, APageSize: Integer; out ATotal: Integer): TJSONArray;`r`n" `
          + "    function TryGetById(AConn: IConnection; const AId, AEmpresaId: TGUID;`r`n" `
          + "      out AObj: TJSONObject): Boolean;`r`n" `
          + "    function TryInsert(AConn: IConnection; const AEmpresaId: TGUID;`r`n" `
          + "      const ABody: TJSONObject; out ANewId: string;`r`n" `
          + "      out AErrorCode, AErrorMsg: string): Boolean;`r`n" `
          + "    function TryUpdate(AConn: IConnection; const AId, AEmpresaId: TGUID;`r`n" `
          + "      const ABody: TJSONObject; out AErrorCode, AErrorMsg: string): Boolean;`r`n" `
          + "    function TryDelete(AConn: IConnection; const AId, AEmpresaId: TGUID;`r`n" `
          + "      out AErrorCode, AErrorMsg: string): Boolean;`r`n" `
          + "  end;`r`n`r`nimplementation`r`n`r`n" `
          + "function T${Domain}Repository.List(AConn: IConnection; const AEmpresaId: TGUID;`r`n" `
          + "  APage, APageSize: Integer; out ATotal: Integer): TJSONArray;`r`n" `
          + "begin ATotal := 0; Result := TJSONArray.Create; { TODO: SELECT } end;`r`n`r`n" `
          + "function T${Domain}Repository.TryGetById(AConn: IConnection; const AId, AEmpresaId: TGUID;`r`n" `
          + "  out AObj: TJSONObject): Boolean;`r`n" `
          + "begin AObj := nil; Result := False; { TODO: SELECT BY ID } end;`r`n`r`n" `
          + "function T${Domain}Repository.TryInsert(AConn: IConnection; const AEmpresaId: TGUID;`r`n" `
          + "  const ABody: TJSONObject; out ANewId: string; out AErrorCode, AErrorMsg: string): Boolean;`r`n" `
          + "begin ANewId := ''; AErrorCode := ''; AErrorMsg := ''; Result := False; { TODO: INSERT } end;`r`n`r`n" `
          + "function T${Domain}Repository.TryUpdate(AConn: IConnection; const AId, AEmpresaId: TGUID;`r`n" `
          + "  const ABody: TJSONObject; out AErrorCode, AErrorMsg: string): Boolean;`r`n" `
          + "begin AErrorCode := ''; AErrorMsg := ''; Result := False; { TODO: UPDATE } end;`r`n`r`n" `
          + "function T${Domain}Repository.TryDelete(AConn: IConnection; const AId, AEmpresaId: TGUID;`r`n" `
          + "  out AErrorCode, AErrorMsg: string): Boolean;`r`n" `
          + "begin AErrorCode := ''; AErrorMsg := ''; Result := False; { TODO: DELETE } end;`r`n`r`nend.`r`n"
    Write-Pas $path $body
}

function New-ServiceActions([string]$BasePath, [string]$ModDir, [string]$Domain, [string]$MCode) {
    $path = "$BasePath\$ModDir\$Domain\Services\Application.$Domain.${Domain}Actions.pas"
    $unit = "Application.$Domain.${Domain}Actions"
    $hdr  = Build-Header $unit "Acoes do servico - $Domain" '1.0.0' $Today @("  - 1.0.0 ($Today): Scaffold inicial $MCode.")
    $body = "unit $unit;`r`n`r`n$hdr`r`n`r`ninterface`r`n`r`nuses`r`n" `
          + "  System.SysUtils,`r`n  System.JSON,`r`n  Providers.Connection.Interfaces,`r`n" `
          + "  Contracts.Interfaces.$Domain.I${Domain}Repository;`r`n`r`n" `
          + "function ${MCode}List(AConn: IConnection; ARepo: I${Domain}Repository;`r`n" `
          + "  const AEmpresaId: TGUID; APage, APageSize: Integer; out ATotal: Integer): TJSONArray;`r`n" `
          + "function ${MCode}GetById(AConn: IConnection; ARepo: I${Domain}Repository;`r`n" `
          + "  const AId, AEmpresaId: TGUID; out AObj: TJSONObject): Boolean;`r`n" `
          + "function ${MCode}Create(AConn: IConnection; ARepo: I${Domain}Repository;`r`n" `
          + "  const AEmpresaId: TGUID; const ABody: TJSONObject;`r`n" `
          + "  out ANewId, AErrCode, AErrMsg: string): Boolean;`r`n" `
          + "function ${MCode}Update(AConn: IConnection; ARepo: I${Domain}Repository;`r`n" `
          + "  const AId, AEmpresaId: TGUID; const ABody: TJSONObject;`r`n" `
          + "  out AErrCode, AErrMsg: string): Boolean;`r`n" `
          + "function ${MCode}Delete(AConn: IConnection; ARepo: I${Domain}Repository;`r`n" `
          + "  const AId, AEmpresaId: TGUID; out AErrCode, AErrMsg: string): Boolean;`r`n`r`nimplementation`r`n`r`n" `
          + "function ${MCode}List(AConn: IConnection; ARepo: I${Domain}Repository;`r`n" `
          + "  const AEmpresaId: TGUID; APage, APageSize: Integer; out ATotal: Integer): TJSONArray;`r`n" `
          + "begin Result := ARepo.List(AConn, AEmpresaId, APage, APageSize, ATotal); end;`r`n`r`n" `
          + "function ${MCode}GetById(AConn: IConnection; ARepo: I${Domain}Repository;`r`n" `
          + "  const AId, AEmpresaId: TGUID; out AObj: TJSONObject): Boolean;`r`n" `
          + "begin Result := ARepo.TryGetById(AConn, AId, AEmpresaId, AObj); end;`r`n`r`n" `
          + "function ${MCode}Create(AConn: IConnection; ARepo: I${Domain}Repository;`r`n" `
          + "  const AEmpresaId: TGUID; const ABody: TJSONObject;`r`n" `
          + "  out ANewId, AErrCode, AErrMsg: string): Boolean;`r`n" `
          + "begin Result := ARepo.TryInsert(AConn, AEmpresaId, ABody, ANewId, AErrCode, AErrMsg); end;`r`n`r`n" `
          + "function ${MCode}Update(AConn: IConnection; ARepo: I${Domain}Repository;`r`n" `
          + "  const AId, AEmpresaId: TGUID; const ABody: TJSONObject;`r`n" `
          + "  out AErrCode, AErrMsg: string): Boolean;`r`n" `
          + "begin Result := ARepo.TryUpdate(AConn, AId, AEmpresaId, ABody, AErrCode, AErrMsg); end;`r`n`r`n" `
          + "function ${MCode}Delete(AConn: IConnection; ARepo: I${Domain}Repository;`r`n" `
          + "  const AId, AEmpresaId: TGUID; out AErrCode, AErrMsg: string): Boolean;`r`n" `
          + "begin Result := ARepo.TryDelete(AConn, AId, AEmpresaId, AErrCode, AErrMsg); end;`r`n`r`nend.`r`n"
    Write-Pas $path $body
}

function New-Dcc32Cfg([string]$BasePath, [string]$Domain, [string]$ModDir, [string]$MCode) {
    $path = "$BasePath\dcc32.cfg"
    if (Test-Path $path) { Write-Host "  SKIP (exists): dcc32.cfg"; return }
    if ($WhatIf) { Write-Host "  [WhatIf] dcc32.cfg"; return }

    $dprName = (Get-ChildItem $BasePath -Filter '*.dpr' | Select-Object -First 1).BaseName
    $lines = [System.Collections.Generic.List[string]]::new()

    $lines.Add("# ==============================================================================") | Out-Null
    $lines.Add("# dcc32.cfg - $MCode.$Domain.Backend (Win32)") | Out-Null
    $lines.Add("# Uso: dcc32 $dprName.dpr") | Out-Null
    $lines.Add("# ==============================================================================") | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add("# 1. Caminhos proprios do modulo") | Out-Null
    $lines.Add('-U"."') | Out-Null
    $lines.Add('-U"Core\EntryPoints"') | Out-Null
    $lines.Add('-U"Core\Bootstrap"') | Out-Null
    $lines.Add('-U"Commons\Bridges"') | Out-Null
    $lines.Add('-U"Commons\Bridges\Auth"') | Out-Null
    $lines.Add('-U"Commons\DTOs"') | Out-Null
    $lines.Add('-U"Commons\Consts"') | Out-Null
    $lines.Add('-U"Commons\Types"') | Out-Null
    $lines.Add('-U"Commons\Exceptions"') | Out-Null
    $lines.Add("-U`"$ModDir\$Domain\Domain`"") | Out-Null
    $lines.Add("-U`"$ModDir\$Domain\Interfaces`"") | Out-Null
    $lines.Add("-U`"$ModDir\$Domain\Repositories`"") | Out-Null
    $lines.Add("-U`"$ModDir\$Domain\Services`"") | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add("# 2. M01 - Seguranca (JWT, Auth, MainService)") | Out-Null
    $lines.Add('-U"..\M01-Seguranca_Acesso"') | Out-Null
    $lines.Add('-U"..\M01-Seguranca_Acesso\Commons"') | Out-Null
    $lines.Add('-U"..\M01-Seguranca_Acesso\Core"') | Out-Null
    $lines.Add('-U"..\M01-Seguranca_Acesso\modules"') | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add("# 3. REST-DataWare") | Out-Null
    $lines.Add('-U"..\..\modules\REST-DataWare\CORE\Source\Basic"') | Out-Null
    $lines.Add('-U"..\..\modules\REST-DataWare\CORE\Source\Basic\Crypto"') | Out-Null
    $lines.Add('-U"..\..\modules\REST-DataWare\CORE\Source\Basic\Mechanics"') | Out-Null
    $lines.Add('-U"..\..\modules\REST-DataWare\CORE\Source\Plugins\Memdataset"') | Out-Null
    $lines.Add('-U"..\..\modules\REST-DataWare\CORE\Source\Consts"') | Out-Null
    $lines.Add('-U"..\..\modules\REST-DataWare\CORE\Source\Database_Drivers"') | Out-Null
    $lines.Add('-U"..\..\modules\REST-DataWare\CORE\Source\Database_Drivers\FireDACPhysLink"') | Out-Null
    $lines.Add('-U"..\..\modules\REST-DataWare\CORE\Source\Includes"') | Out-Null
    $lines.Add('-U"..\..\modules\REST-DataWare\CORE\Source\Sockets\Indy"') | Out-Null
    $lines.Add('-U"..\..\modules\REST-DataWare\CORE\Source\utils"') | Out-Null
    $lines.Add('-U"..\..\modules\REST-DataWare\CORE\Source\utils\JSON"') | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add("# 4. ProvidersORM") | Out-Null
    $lines.Add('-U"..\..\modules\ProvidersORM\src"') | Out-Null
    $lines.Add('-U"..\..\modules\ProvidersORM\src\Commons"') | Out-Null
    $lines.Add('-U"..\..\modules\ProvidersORM\src\Main"') | Out-Null
    $lines.Add('-U"..\..\modules\ProvidersORM\src\modules\Connections"') | Out-Null
    $lines.Add('-U"..\..\modules\ProvidersORM\src\modules\PoolConnections"') | Out-Null
    $lines.Add('-U"..\..\modules\ProvidersORM\src\modules\Database"') | Out-Null
    $lines.Add('-U"..\..\modules\ProvidersORM\src\modules\Database\EntityManager"') | Out-Null
    $lines.Add('-U"..\..\modules\ProvidersORM\src\modules\Database\Fields"') | Out-Null
    $lines.Add('-U"..\..\modules\ProvidersORM\src\modules\Database\QueryBuilder"') | Out-Null
    $lines.Add('-U"..\..\modules\ProvidersORM\src\modules\Database\Schemas"') | Out-Null
    $lines.Add('-U"..\..\modules\ProvidersORM\src\modules\Database\Tables"') | Out-Null
    $lines.Add('-U"..\..\modules\ProvidersORM\src\modules\Database\TypeDatabase"') | Out-Null
    $lines.Add('-U"..\..\modules\ProvidersORM\src\modules\Exceptions"') | Out-Null
    $lines.Add('-U"..\..\modules\ProvidersORM\src\modules\Loggers"') | Out-Null
    $lines.Add('-U"..\..\modules\ProvidersORM\src\modules\Loggers\Commons"') | Out-Null
    $lines.Add('-U"..\..\modules\ProvidersORM\src\modules\Loggers\TextFiles"') | Out-Null
    $lines.Add('-U"..\..\modules\ProvidersORM\src\modules\Parameters"') | Out-Null
    $lines.Add('-U"..\..\modules\ProvidersORM\src\modules\Parameters\IniFiles"') | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add("# 5. ParamentersORM") | Out-Null
    $lines.Add('-U"..\..\modules\ParamentersORM\src"') | Out-Null
    $lines.Add('-U"..\..\modules\ParamentersORM\src\Commons"') | Out-Null
    $lines.Add('-U"..\..\modules\ParamentersORM\src\Attributes"') | Out-Null
    $lines.Add('-U"..\..\modules\ParamentersORM\src\IniFiles"') | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add("# 6. Packages") | Out-Null
    $lines.Add('-U"..\..\package\delphi-jose-jwt\Source\Common"') | Out-Null
    $lines.Add('-U"..\..\package\delphi-jose-jwt\Source\JOSE"') | Out-Null
    $lines.Add('-U"..\..\package\dataset-serialize\src"') | Out-Null
    $lines.Add('-U"..\..\package\synapse"') | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add("# 7. Includes") | Out-Null
    $lines.Add('-I"."') | Out-Null
    $lines.Add('-I"..\..\modules\REST-DataWare\CORE\Source\Includes"') | Out-Null
    $lines.Add('-I"..\..\modules\ProvidersORM"') | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add("# 8. Diretorios de saida") | Out-Null
    $lines.Add('-E"Compiled\EXE\Debug\Win32"') | Out-Null
    $lines.Add('-N"Compiled\DCU\Debug\Win32"') | Out-Null
    $lines.Add('-NO"Compiled\DCU\Debug\Win32"') | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add("# 9. Opcoes de compilacao") | Out-Null
    $lines.Add('-$O-') | Out-Null
    $lines.Add('-$W+') | Out-Null
    $lines.Add('-$C+') | Out-Null
    $lines.Add('-$D+') | Out-Null
    $lines.Add('-$L+') | Out-Null
    $lines.Add('-$Y+') | Out-Null
    $lines.Add('-Q') | Out-Null
    $lines.Add('-TX.exe') | Out-Null
    $lines.Add('-VN') | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add("# 10. Aliases e namespaces") | Out-Null
    $lines.Add('-AGenerics.Collections=System.Generics.Collections;Generics.Defaults=System.Generics.Defaults;WinTypes=Winapi.Windows;WinProcs=Winapi.Windows') | Out-Null
    $lines.Add('-NSWinapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;System;Xml;Data;Datasnap;Web;Soap;Vcl;Vcl.Imaging') | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add("# 11. Defines") | Out-Null
    $lines.Add('-DDEBUG') | Out-Null
    $lines.Add('') | Out-Null
    $lines.Add("# FIM - $MCode.$Domain.Backend dcc32.cfg") | Out-Null

    $content = $lines -join "`r`n"
    [System.IO.File]::WriteAllText($path, $content, $enc)
    Write-Host "  NEW: dcc32.cfg"
}

# ---------------------------------------------------------------------------
# Module table
# ---------------------------------------------------------------------------
$mods = @(
    [pscustomobject]@{ Id='M02'; Dir='M02-Cadastros_Base';         Domain='Cadastros';       Code='M02'; Url='cadastros';        HasBridges=$true;  HasAuth=$false; HasDomain=$true;  ModDir='modules' },
    [pscustomobject]@{ Id='M03'; Dir='M03-Clientes';               Domain='Clientes';        Code='M03'; Url='clientes';         HasBridges=$true;  HasAuth=$true;  HasDomain=$true;  ModDir='modules' },
    [pscustomobject]@{ Id='M04'; Dir='M04-Empresas';               Domain='Empresas';        Code='M04'; Url='empresas';         HasBridges=$true;  HasAuth=$true;  HasDomain=$true;  ModDir='modules' },
    [pscustomobject]@{ Id='M05'; Dir='M05-Financeiro';             Domain='Financeiro';      Code='M05'; Url='financeiro';       HasBridges=$true;  HasAuth=$true;  HasDomain=$true;  ModDir='modules' },
    [pscustomobject]@{ Id='M06'; Dir='M06-Fiscal_NFe';             Domain='Fiscal';          Code='M06'; Url='fiscal';           HasBridges=$true;  HasAuth=$true;  HasDomain=$true;  ModDir='modules' },
    [pscustomobject]@{ Id='M07'; Dir='M07-Documentos_Comunicacao'; Domain='Documentos';      Code='M07'; Url='documentos';       HasBridges=$false; HasAuth=$false; HasDomain=$false; ModDir='Modulos' },
    [pscustomobject]@{ Id='M08'; Dir='M08-LGPD_Auditoria';         Domain='Auditoria';       Code='M08'; Url='auditoria';        HasBridges=$true;  HasAuth=$false; HasDomain=$true;  ModDir='modules' },
    [pscustomobject]@{ Id='M09'; Dir='M09-Estoque_Produtos';       Domain='Estoque';         Code='M09'; Url='estoque';          HasBridges=$false; HasAuth=$false; HasDomain=$false; ModDir='Modulos' },
    [pscustomobject]@{ Id='M10'; Dir='M10-Ordens_Servico';         Domain='OrdensServico';   Code='M10'; Url='ordens-servico';   HasBridges=$false; HasAuth=$false; HasDomain=$false; ModDir='Modulos' },
    [pscustomobject]@{ Id='M11'; Dir='M11-Orcamentos';             Domain='Orcamentos';      Code='M11'; Url='orcamentos';       HasBridges=$false; HasAuth=$false; HasDomain=$false; ModDir='Modulos' },
    [pscustomobject]@{ Id='M12'; Dir='M12-Veiculos';               Domain='Veiculos';        Code='M12'; Url='veiculos';         HasBridges=$false; HasAuth=$false; HasDomain=$false; ModDir='Modulos' },
    [pscustomobject]@{ Id='M13'; Dir='M13-Vendas';                 Domain='Vendas';          Code='M13'; Url='vendas';           HasBridges=$false; HasAuth=$false; HasDomain=$false; ModDir='Modulos' },
    [pscustomobject]@{ Id='M14'; Dir='M14-Proposta';               Domain='Proposta';        Code='M14'; Url='proposta';         HasBridges=$false; HasAuth=$false; HasDomain=$false; ModDir='Modulos' },
    [pscustomobject]@{ Id='M15'; Dir='M15-Comissoes';              Domain='Comissoes';       Code='M15'; Url='comissoes';        HasBridges=$false; HasAuth=$false; HasDomain=$false; ModDir='Modulos' },
    [pscustomobject]@{ Id='M16'; Dir='M16-Execucao_Servicos';      Domain='ExecucaoServicos';Code='M16'; Url='execucao-servicos';HasBridges=$false; HasAuth=$false; HasDomain=$false; ModDir='Modulos' },
    [pscustomobject]@{ Id='M17'; Dir='M17-Frota';                  Domain='Frota';           Code='M17'; Url='frota';            HasBridges=$false; HasAuth=$false; HasDomain=$false; ModDir='Modulos' },
    [pscustomobject]@{ Id='M18'; Dir='M18-Roteiros';               Domain='Roteiros';        Code='M18'; Url='roteiros';         HasBridges=$false; HasAuth=$false; HasDomain=$false; ModDir='Modulos' },
    [pscustomobject]@{ Id='M19'; Dir='M19-Caixa';                  Domain='Caixa';           Code='M19'; Url='caixa';            HasBridges=$false; HasAuth=$false; HasDomain=$false; ModDir='Modulos' },
    [pscustomobject]@{ Id='M20'; Dir='M20-Bancos';                 Domain='Bancos';          Code='M20'; Url='bancos';           HasBridges=$false; HasAuth=$false; HasDomain=$false; ModDir='Modulos' },
    [pscustomobject]@{ Id='M21'; Dir='M21-Boletos_Remessa';        Domain='Boletos';         Code='M21'; Url='boletos';          HasBridges=$false; HasAuth=$false; HasDomain=$false; ModDir='Modulos' },
    [pscustomobject]@{ Id='M22'; Dir='M22-Compras_Fornecedores';   Domain='Compras';         Code='M22'; Url='compras';          HasBridges=$false; HasAuth=$false; HasDomain=$false; ModDir='Modulos' },
    [pscustomobject]@{ Id='M23'; Dir='M23-PDV';                    Domain='PDV';             Code='M23'; Url='pdv';              HasBridges=$false; HasAuth=$false; HasDomain=$false; ModDir='Modulos' },
    [pscustomobject]@{ Id='M24'; Dir='M24-RH_Funcionarios';        Domain='RH';              Code='M24'; Url='rh';               HasBridges=$false; HasAuth=$false; HasDomain=$false; ModDir='Modulos' },
    [pscustomobject]@{ Id='M25'; Dir='M25-Mala_Direta_Marketing';  Domain='MalaDireta';      Code='M25'; Url='mala-direta';      HasBridges=$false; HasAuth=$false; HasDomain=$false; ModDir='Modulos' },
    [pscustomobject]@{ Id='M26'; Dir='M26-Alugueis_Locacao';       Domain='Alugueis';        Code='M26'; Url='alugueis';         HasBridges=$false; HasAuth=$false; HasDomain=$false; ModDir='Modulos' }
)

# ---------------------------------------------------------------------------
# Main loop
# ---------------------------------------------------------------------------
$totalNew = 0; $totalSkip = 0

foreach ($m in $mods) {
    $basePath = "$BackendPath\$($m.Dir)"
    Write-Host ""
    Write-Host "=== $($m.Id) - $($m.Domain) ==="

    # 1. Rename Modulos -> modules (scaffold modules)
    if ($m.ModDir -eq 'Modulos') {
        Rename-ModulosDir $basePath
        # Update reference after rename
        $m.ModDir = 'modules'
    }

    # 2. Remove .gitkeep
    Remove-GitKeep $basePath

    # 3. dcc32.cfg
    New-Dcc32Cfg $basePath $m.Domain $m.ModDir $m.Code

    # 4. Bridges
    if (-not $m.HasBridges) {
        New-LoggerBridge    $basePath
        New-ParametersBridge $basePath
    }

    # 5. Auth bridge (where missing)
    if (-not $m.HasAuth) {
        New-RequestContext $basePath
    }

    # 6. DTOs JsonKeys
    New-JsonKeys $basePath $m.Domain

    # 7. Core EntryPoints
    New-EntryPoint $basePath $m.Domain $m.Code $m.Url

    # 8. Domain layer (only for scaffold modules)
    if (-not $m.HasDomain) {
        New-Entities      $basePath $m.ModDir $m.Domain $m.Code
        New-RepoInterface $basePath $m.ModDir $m.Domain $m.Code
        New-Repository    $basePath $m.ModDir $m.Domain $m.Code
        New-ServiceActions $basePath $m.ModDir $m.Domain $m.Code
    }
}

Write-Host ""
Write-Host "=== Concluido ==="

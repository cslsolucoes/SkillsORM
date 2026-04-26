{ =============================================================================
  TEMPLATE_loadlibrary_wrapper.pas
  Classe wrapper cross-platform para LoadLibrary / dlopen.

  Como usar:
    1. Substituir {LIBRARY_NAME} pelo nome da DLL
    2. Adicionar os tipos de função da sua DLL na secção "Tipos de função"
    3. Adicionar os campos de ponteiro em TDynamicLibrary
    4. Implementar os métodos de API em TDynamicLibrary
    5. Chamar ResolveSymbols no constructor

  Placeholders:
    {LIBRARY_NAME}   — nome base da DLL (sem extensão)
    {FUNC_TYPE}      — nome do tipo de função a importar
    {PROC_NAME}      — nome do símbolo exportado pela DLL
  ============================================================================= }

unit TEMPLATE_loadlibrary_wrapper;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  SysUtils
  {$IFDEF FPC}
  , dynlibs
  {$ELSE}
    {$IFDEF MSWINDOWS}
    , Winapi.Windows
    {$ENDIF}
    {$IFDEF POSIX}
    , Posix.Dlfcn
    {$ENDIF}
  {$ENDIF}
  ;

// ===========================================================================
// Tipos de plataforma — abstractos para cross-platform
// ===========================================================================
{$IFDEF FPC}
  TLibHandleNative = TLibHandle;
{$ELSE}
  {$IFDEF MSWINDOWS}
  TLibHandleNative = HMODULE;
  {$ELSE}
  TLibHandleNative = NativeUInt;
  {$ENDIF}
{$ENDIF}

const
{$IFDEF FPC}
  INVALID_LIB = NilHandle;
{$ELSE}
  INVALID_LIB = 0;
{$ENDIF}

// ===========================================================================
// Declarações de tipos de função da DLL
// (espelham os exports — ajustar conforme a DLL concreta)
// ===========================================================================
type
  // --- Versão ---
  T{LIBRARY_NAME}_GetVersion = function: Integer;
    {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

  T{LIBRARY_NAME}_GetVersionStr = function: PChar;
    {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

  // --- Ciclo de vida ---
  T{LIBRARY_NAME}_Create = function(out AHandle: Pointer): LongBool;
    {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

  T{LIBRARY_NAME}_Destroy = procedure(AHandle: Pointer);
    {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

  // --- Operações --- (adicionar conforme necessário)
  T{LIBRARY_NAME}_Execute = function(
    AHandle: Pointer;
    AInput: Integer;
    AResultBuffer: PChar;
    ABufferSize: Integer): Integer;
    {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

// ===========================================================================
// TDynamicLibrary — wrapper base cross-platform
// (usar como ancestral para wrappers específicos)
// ===========================================================================
  TDynamicLibrary = class
  private
    FHandle: TLibHandleNative;
    FPath: string;
    FLoaded: Boolean;
  protected
    // Resolver um símbolo — retorna nil se não encontrado
    function GetProc(const AProcName: string): Pointer;
    // Resolver e lançar excepção se não encontrado
    function GetProcRequired(const AProcName: string): Pointer;
    // Subclasses chamam aqui para resolver todos os símbolos
    procedure ResolveSymbols; virtual; abstract;
  public
    constructor Create(const ALibPath: string);
    destructor  Destroy; override;

    property IsLoaded: Boolean read FLoaded;
    property Path: string read FPath;
  end;

// ===========================================================================
// T{LIBRARY_NAME}Wrapper — wrapper concreto para {LIBRARY_NAME}.dll
// ===========================================================================
  T{LIBRARY_NAME}Wrapper = class(TDynamicLibrary)
  private
    // Ponteiros para funções resolvidas
    FGetVersion:    T{LIBRARY_NAME}_GetVersion;
    FGetVersionStr: T{LIBRARY_NAME}_GetVersionStr;
    FCreate:        T{LIBRARY_NAME}_Create;
    FDestroy:       T{LIBRARY_NAME}_Destroy;
    FExecute:       T{LIBRARY_NAME}_Execute;

    // Handle opaco do objecto na DLL (se aplicável)
    FInstanceHandle: Pointer;
  protected
    procedure ResolveSymbols; override;
  public
    constructor Create(const ALibPath: string = '');
    destructor  Destroy; override;

    // API exposta — delega para a DLL
    function  GetVersion: Integer;
    function  GetVersionString: string;
    function  Execute(AInput: Integer): string;

    property InstanceHandle: Pointer read FInstanceHandle;
  end;

implementation

// ===========================================================================
// TDynamicLibrary — implementação
// ===========================================================================

constructor TDynamicLibrary.Create(const ALibPath: string);
begin
  inherited Create;
  FPath := ALibPath;
  FLoaded := False;

  {$IFDEF FPC}
    FHandle := LoadLibrary(ALibPath);
    if FHandle = NilHandle then
      raise Exception.CreateFmt(
        'Falha ao carregar "%s": %s', [ALibPath, GetLoadErrorStr]);
  {$ELSE}
    {$IFDEF MSWINDOWS}
      FHandle := LoadLibrary(PChar(ALibPath));
      if FHandle = 0 then
        raise Exception.CreateFmt(
          'Falha ao carregar "%s": %s (erro %d)',
          [ALibPath, SysErrorMessage(GetLastError), GetLastError]);
    {$ELSE}
      // Delphi POSIX
      FHandle := TLibHandleNative(dlopen(
        MarshaledAString(TMarshaledAString(ALibPath)),
        RTLD_LAZY or RTLD_LOCAL));
      if FHandle = 0 then
        raise Exception.CreateFmt(
          'dlopen falhou "%s": %s',
          [ALibPath, string(UTF8String(dlerror))]);
    {$ENDIF}
  {$ENDIF}

  try
    ResolveSymbols; // chamado na subclasse
    FLoaded := True;
  except
    // Falhou ao resolver símbolos — descarregar e propagar
    {$IFDEF FPC}
      UnloadLibrary(FHandle);
    {$ELSE}
      {$IFDEF MSWINDOWS} FreeLibrary(FHandle);
      {$ELSE} dlclose(FHandle); {$ENDIF}
    {$ENDIF}
    FHandle := INVALID_LIB;
    raise;
  end;
end;

destructor TDynamicLibrary.Destroy;
begin
  if FHandle <> INVALID_LIB then
  begin
    {$IFDEF FPC}
      UnloadLibrary(FHandle);
    {$ELSE}
      {$IFDEF MSWINDOWS} FreeLibrary(FHandle);
      {$ELSE} dlclose(FHandle); {$ENDIF}
    {$ENDIF}
    FHandle := INVALID_LIB;
  end;
  FLoaded := False;
  inherited;
end;

function TDynamicLibrary.GetProc(const AProcName: string): Pointer;
begin
  {$IFDEF FPC}
    Result := GetProcedureAddress(FHandle, AProcName);
  {$ELSE}
    {$IFDEF MSWINDOWS}
      Result := GetProcAddress(FHandle, PChar(AProcName));
    {$ELSE}
      Result := dlsym(FHandle, MarshaledAString(TMarshaledAString(AProcName)));
    {$ENDIF}
  {$ENDIF}
end;

function TDynamicLibrary.GetProcRequired(const AProcName: string): Pointer;
begin
  Result := GetProc(AProcName);
  if Result = nil then
    raise Exception.CreateFmt(
      'Símbolo obrigatório "%s" não encontrado em "%s"',
      [AProcName, FPath]);
end;

// ===========================================================================
// T{LIBRARY_NAME}Wrapper — implementação
// ===========================================================================

constructor T{LIBRARY_NAME}Wrapper.Create(const ALibPath: string);
var
  LPath: string;
begin
  // Caminho por defeito — convenção de nomenclatura por plataforma
  if ALibPath = '' then
    LPath :=
      {$IFDEF MSWINDOWS} '{LIBRARY_NAME}.dll'
      {$ELSE}            'lib{LIBRARY_NAME}.so'
      {$ENDIF}
  else
    LPath := ALibPath;

  inherited Create(LPath); // chama ResolveSymbols internamente

  // Criar instância na DLL (se a DLL usa o padrão de handle opaco)
  FInstanceHandle := nil;
  if not FCreate(FInstanceHandle) then
    raise Exception.CreateFmt(
      'Create{LIBRARY_NAME} falhou em "%s"', [Path]);
end;

destructor T{LIBRARY_NAME}Wrapper.Destroy;
begin
  // Destruir a instância NA DLL antes de descarregar (ordem importa!)
  if FInstanceHandle <> nil then
  begin
    if Assigned(FDestroy) then
      FDestroy(FInstanceHandle);
    FInstanceHandle := nil;
  end;
  inherited; // descarrega a DLL
end;

procedure T{LIBRARY_NAME}Wrapper.ResolveSymbols;
begin
  // Obrigatórios — lança excepção se ausentes
  @FGetVersion    := GetProcRequired('Get{LIBRARY_NAME}Version');
  @FGetVersionStr := GetProcRequired('Get{LIBRARY_NAME}VersionString');
  @FCreate        := GetProcRequired('Create{LIBRARY_NAME}');
  @FDestroy       := GetProcRequired('Destroy{LIBRARY_NAME}');
  @FExecute       := GetProcRequired('{LIBRARY_NAME}_Execute');
end;

function T{LIBRARY_NAME}Wrapper.GetVersion: Integer;
begin
  Result := FGetVersion();
end;

function T{LIBRARY_NAME}Wrapper.GetVersionString: string;
begin
  Result := string(FGetVersionStr());
end;

function T{LIBRARY_NAME}Wrapper.Execute(AInput: Integer): string;
var
  LBuffer: array[0..4095] of Char;
  LNeeded: Integer;
begin
  LNeeded := FExecute(FInstanceHandle, AInput, @LBuffer[0], SizeOf(LBuffer));

  if LNeeded < 0 then
  begin
    // Buffer insuficiente — alocar exacto e repetir
    SetLength(Result, Abs(LNeeded) + 1);
    FExecute(FInstanceHandle, AInput, PChar(Result), Length(Result));
    Result := PChar(Result); // trim no null-terminator
  end
  else if LNeeded = 0 then
    Result := ''
  else
    Result := string(LBuffer);
end;

end.

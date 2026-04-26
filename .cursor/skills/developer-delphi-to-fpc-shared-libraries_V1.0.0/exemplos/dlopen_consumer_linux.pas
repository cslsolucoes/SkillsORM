{ =============================================================================
  dlopen_consumer_linux.pas
  Host Linux/macOS que carrega libExemploBasico.so dinamicamente.

  Demonstra:
    - Delphi: Posix.Dlfcn — dlopen, dlsym, dlclose, dlerror
    - FPC: dynlibs — LoadLibrary, GetProcedureAddress, UnloadLibrary
    - {$IFDEF FPC} blocks para compatibilidade total
    - Wrapper class cross-platform TDynamicLibrary
    - Tratamento de erros com dlerror / GetLoadErrorStr

  Compilar (Delphi Linux64 via PAServer):
    Via RAD Studio IDE com plataforma Linux64

  Compilar (FPC Linux64):
    fpc -Tlinux -Px86_64 dlopen_consumer_linux.pas

  Compilar (FPC Windows — usa LoadLibrary internamente via dynlibs):
    fpc -Twin64 -Px86_64 dlopen_consumer_linux.pas
  ============================================================================= }

unit dlopen_consumer_linux;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  SysUtils
  {$IFDEF FPC}
  , dynlibs   // FPC cross-platform: LoadLibrary/GetProcedureAddress/UnloadLibrary
  {$ELSE}
    {$IFDEF POSIX}
    , Posix.Dlfcn   // Delphi POSIX: dlopen/dlsym/dlclose/dlerror
    {$ENDIF}
    {$IFDEF MSWINDOWS}
    , Winapi.Windows
    {$ENDIF}
  {$ENDIF}
  ;

// =========================================================================
// Tipos de handle — abstractos para cross-platform
// =========================================================================
{$IFDEF FPC}
  TLibHandle_t = TLibHandle;   // FPC: dynlibs.TLibHandle = NativeUInt
{$ELSE}
  {$IFDEF POSIX}
  TLibHandle_t = NativeUInt;   // Delphi POSIX: dlopen retorna Pointer (=NativeUInt)
  {$ELSE}
  TLibHandle_t = HMODULE;      // Delphi Windows
  {$ENDIF}
{$ENDIF}

// Sentinel para "não carregado"
const
{$IFDEF FPC}
  INVALID_LIB_HANDLE = NilHandle;
{$ELSE}
  INVALID_LIB_HANDLE = 0;
{$ENDIF}

// =========================================================================
// Declaração dos tipos de função (espelha os exports da DLL/SO)
// =========================================================================
type
  // Em Linux, usar cdecl; em Windows, usar stdcall.
  // A macro {$IFDEF MSWINDOWS} torna a declaração portável.
  TGetLibraryVersion = function: Integer;
    {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

  TSomarInteiros = function(A, B: Integer): Integer;
    {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

  TFormatarTexto = function(AValor: Integer; ABuffer: PChar; ASize: Integer): Integer;
    {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

  TCriarHandle = function(AID: Integer): Pointer;
    {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

  TAdicionarValor = function(AHandle: Pointer; AValor: Double): LongBool;
    {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

  TObterMedia = function(AHandle: Pointer; out AMedia: Double): LongBool;
    {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

  TDestruirHandle = procedure(AHandle: Pointer);
    {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

// =========================================================================
// Helpers cross-platform — encapsulam as diferenças de API
// =========================================================================

// Carregar biblioteca — retorna INVALID_LIB_HANDLE em caso de falha
function LibLoad(const APath: string): TLibHandle_t;

// Obter endereço de símbolo — retorna nil se não encontrado
function LibGetProc(AHandle: TLibHandle_t; const AProcName: string): Pointer;

// Descarregar biblioteca
procedure LibUnload(AHandle: TLibHandle_t);

// Obter mensagem de erro do último LibLoad/LibGetProc
function LibGetError: string;

implementation

// -------------------------------------------------------------------------
// Implementação dos helpers
// -------------------------------------------------------------------------

function LibLoad(const APath: string): TLibHandle_t;
begin
  {$IFDEF FPC}
    Result := LoadLibrary(APath);
  {$ELSE}
    {$IFDEF POSIX}
      // RTLD_LAZY: resolve símbolos ao primeiro uso (mais rápido ao carregar)
      // RTLD_NOW:  resolve tudo imediatamente (falha rápida se símbolo ausente)
      // RTLD_LOCAL: símbolos não exportados para outras bibliotecas (padrão seguro)
      Result := TLibHandle_t(dlopen(MarshaledAString(TMarshaledAString(APath)), RTLD_LAZY or RTLD_LOCAL));
    {$ELSE}
      Result := LoadLibrary(PChar(APath));
    {$ENDIF}
  {$ENDIF}
end;

function LibGetProc(AHandle: TLibHandle_t; const AProcName: string): Pointer;
begin
  {$IFDEF FPC}
    Result := GetProcedureAddress(AHandle, AProcName);
  {$ELSE}
    {$IFDEF POSIX}
      Result := dlsym(AHandle, MarshaledAString(TMarshaledAString(AProcName)));
    {$ELSE}
      Result := GetProcAddress(AHandle, PChar(AProcName));
    {$ENDIF}
  {$ENDIF}
end;

procedure LibUnload(AHandle: TLibHandle_t);
begin
  if AHandle = INVALID_LIB_HANDLE then Exit;
  {$IFDEF FPC}
    UnloadLibrary(AHandle);
  {$ELSE}
    {$IFDEF POSIX}
      dlclose(AHandle);
    {$ELSE}
      FreeLibrary(AHandle);
    {$ENDIF}
  {$ENDIF}
end;

function LibGetError: string;
begin
  {$IFDEF FPC}
    Result := GetLoadErrorStr;
  {$ELSE}
    {$IFDEF POSIX}
      Result := string(UTF8String(dlerror));
    {$ELSE}
      Result := SysErrorMessage(GetLastError);
    {$ENDIF}
  {$ENDIF}
end;

end.

{ =============================================================================
  Exemplo de uso directo (sem wrapper) — programa console
  ============================================================================= }

{
program UsarSO;

uses
  SysUtils,
  dlopen_consumer_linux;

const
  // Convenção Linux: prefixo "lib" e extensão ".so"
  // Em Windows seria "ExemploBasico.dll" (sem prefixo)
  LIB_PATH =
    {$IFDEF MSWINDOWS} 'ExemploBasico.dll'
    {$ELSE}            './libExemploBasico.so'
    {$ENDIF};

var
  LHandle: TLibHandle_t;
  LGetVer: TGetLibraryVersion;
  LSomar: TSomarInteiros;
  LFormatar: TFormatarTexto;
  LCriar: TCriarHandle;
  LAdd: TAdicionarValor;
  LMedia: TObterMedia;
  LDestr: TDestruirHandle;
  LCtxHandle: Pointer;
  LMediaVal: Double;
  LBuffer: array[0..255] of Char;
begin
  // --- Carregar a biblioteca ---
  LHandle := LibLoad(LIB_PATH);
  if LHandle = INVALID_LIB_HANDLE then
  begin
    Writeln('ERRO ao carregar biblioteca: ', LibGetError);
    Halt(1);
  end;
  try
    // --- Resolver símbolos ---
    @LGetVer  := LibGetProc(LHandle, 'GetLibraryVersion');
    @LSomar   := LibGetProc(LHandle, 'SomarInteiros');
    @LFormatar:= LibGetProc(LHandle, 'FormatarTexto');
    @LCriar   := LibGetProc(LHandle, 'CriarHandle');
    @LAdd     := LibGetProc(LHandle, 'AdicionarValor');
    @LMedia   := LibGetProc(LHandle, 'ObterMedia');
    @LDestr   := LibGetProc(LHandle, 'DestruirHandle');

    // Verificar símbolos críticos
    if not (Assigned(LGetVer) and Assigned(LSomar) and Assigned(LCriar)) then
    begin
      Writeln('ERRO: símbolos críticos ausentes: ', LibGetError);
      Halt(2);
    end;

    // --- Usar a biblioteca ---
    Writeln('Versão  : ', LGetVer());
    Writeln('10+20   : ', LSomar(10, 20));

    LFormatar(99, @LBuffer[0], SizeOf(LBuffer));
    Writeln('Texto   : ', LBuffer);

    // --- Opaque handle ---
    LCtxHandle := LCriar(2001);
    if LCtxHandle <> nil then
    try
      LAdd(LCtxHandle, 100.0);
      LAdd(LCtxHandle, 200.0);
      LAdd(LCtxHandle, 300.0);
      if LMedia(LCtxHandle, LMediaVal) then
        Writeln('Média   : ', LMediaVal:0:2);
    finally
      LDestr(LCtxHandle);
    end;

  finally
    // SEMPRE descarregar — mesmo se ocorrer excepção
    LibUnload(LHandle);
  end;
end.
}

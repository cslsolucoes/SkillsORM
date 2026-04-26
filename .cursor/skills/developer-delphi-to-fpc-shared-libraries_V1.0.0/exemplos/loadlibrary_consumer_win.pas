{ =============================================================================
  loadlibrary_consumer_win.pas
  Host Windows que carrega ExemploBasico.dll dinamicamente.

  Demonstra:
    - LoadLibrary com error handling completo
    - GetProcAddress para múltiplas funções
    - FreeLibrary no finally (garantido)
    - Classe wrapper TDLLWrapper com constructor/destructor
    - Padrão de uso com opaque handle

  Compilar como parte de uma aplicação VCL ou console:
    dcc32 -u"Winapi.Windows;System.SysUtils" loadlibrary_consumer_win.pas
  ============================================================================= }

unit loadlibrary_consumer_win;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF}
  System.SysUtils;

// =========================================================================
// Declaração dos tipos de função (deve espelhar os exports da DLL)
// =========================================================================
type
  // Usando stdcall para todos — convenção Windows
  TGetLibraryVersion  = function: Integer; stdcall;
  TGetLibraryName     = function: PChar; stdcall;
  TSomarInteiros      = function(A, B: Integer): Integer; stdcall;
  TCalcularMedia      = function(AValues: PDouble; ACount: Integer;
                          out AMedia: Double): LongBool; stdcall;
  TFormatarTexto      = function(AValor: Integer; ABuffer: PChar;
                          ABufferSize: Integer): Integer; stdcall;
  TCriarHandle        = function(AID: Integer): Pointer; stdcall;
  TAdicionarValor     = function(AHandle: Pointer; AValor: Double): LongBool; stdcall;
  TObterMedia         = function(AHandle: Pointer; out AMedia: Double): LongBool; stdcall;
  TDestruirHandle     = procedure(AHandle: Pointer); stdcall;

// =========================================================================
// TDLLWrapper — encapsula LoadLibrary/FreeLibrary e resolve símbolos
// =========================================================================
type
  TDLLWrapper = class
  private
    FHandle: HMODULE;
    FPath: string;

    // Ponteiros para as funções resolvidas
    FGetVersion:    TGetLibraryVersion;
    FGetName:       TGetLibraryName;
    FSomar:         TSomarInteiros;
    FCalcMedia:     TCalcularMedia;
    FFormatar:      TFormatarTexto;
    FCriarHandle:   TCriarHandle;
    FAddValor:      TAdicionarValor;
    FObterMedia:    TObterMedia;
    FDestrHandle:   TDestruirHandle;

    procedure ResolverSimbolos;
    function  GetProcStrict(const AProcName: string): Pointer;
  public
    constructor Create(const ALibPath: string);
    destructor  Destroy; override;

    // API exposta — delega para as funções da DLL
    function  GetVersion: Integer;
    function  GetName: string;
    function  Somar(A, B: Integer): Integer;
    function  CalcularMedia(const AValues: array of Double): Double;
    function  Formatar(AValor: Integer): string;

    // Opaque handle API
    function  CriarContexto(AID: Integer): Pointer;
    procedure AdicionarValor(AHandle: Pointer; AValor: Double);
    function  ObterMedia(AHandle: Pointer): Double;
    procedure DestruirContexto(AHandle: Pointer);

    property IsLoaded: Boolean read (FHandle <> 0);
    property Path: string read FPath;
  end;

implementation

// -------------------------------------------------------------------------
// GetProcStrict — resolve símbolo e lança excepção se não encontrado
// -------------------------------------------------------------------------
function TDLLWrapper.GetProcStrict(const AProcName: string): Pointer;
begin
  Result := GetProcAddress(FHandle, PChar(AProcName));
  if Result = nil then
    raise Exception.CreateFmt(
      'Símbolo "%s" não encontrado em "%s" (código %d)',
      [AProcName, FPath, GetLastError]);
end;

// -------------------------------------------------------------------------
// ResolverSimbolos — chamado uma vez no constructor
// -------------------------------------------------------------------------
procedure TDLLWrapper.ResolverSimbolos;
begin
  // Obrigatórios — lança excepção se ausentes
  @FGetVersion  := GetProcStrict('GetLibraryVersion');
  @FGetName     := GetProcStrict('GetLibraryName');
  @FSomar       := GetProcStrict('SomarInteiros');
  @FCalcMedia   := GetProcStrict('CalcularMedia');
  @FFormatar    := GetProcStrict('FormatarTexto');
  @FCriarHandle := GetProcStrict('CriarHandle');
  @FAddValor    := GetProcStrict('AdicionarValor');
  @FObterMedia  := GetProcStrict('ObterMedia');
  @FDestrHandle := GetProcStrict('DestruirHandle');
end;

// -------------------------------------------------------------------------
// Constructor
// -------------------------------------------------------------------------
constructor TDLLWrapper.Create(const ALibPath: string);
begin
  inherited Create;
  FPath := ALibPath;
  FHandle := LoadLibrary(PChar(ALibPath));
  if FHandle = 0 then
    raise Exception.CreateFmt(
      'Falha ao carregar "%s": %s (código %d)',
      [ALibPath, SysErrorMessage(GetLastError), GetLastError]);
  try
    ResolverSimbolos;
  except
    // Se a resolução falhar, descarregar antes de propagar
    FreeLibrary(FHandle);
    FHandle := 0;
    raise;
  end;
end;

// -------------------------------------------------------------------------
// Destructor — SEMPRE liberta FHandle mesmo se outras coisas falharem
// -------------------------------------------------------------------------
destructor TDLLWrapper.Destroy;
begin
  if FHandle <> 0 then
  begin
    FreeLibrary(FHandle);
    FHandle := 0;
  end;
  inherited;
end;

// =========================================================================
// Implementação dos métodos da API
// =========================================================================

function TDLLWrapper.GetVersion: Integer;
begin
  Result := FGetVersion();
end;

function TDLLWrapper.GetName: string;
begin
  Result := string(FGetName());
end;

function TDLLWrapper.Somar(A, B: Integer): Integer;
begin
  Result := FSomar(A, B);
end;

function TDLLWrapper.CalcularMedia(const AValues: array of Double): Double;
begin
  Result := 0;
  if Length(AValues) = 0 then Exit;
  if not FCalcMedia(@AValues[0], Length(AValues), Result) then
    raise Exception.Create('CalcularMedia falhou na DLL');
end;

function TDLLWrapper.Formatar(AValor: Integer): string;
var
  LBuffer: array[0..511] of Char;
  LNeeded: Integer;
begin
  LNeeded := FFormatar(AValor, @LBuffer[0], SizeOf(LBuffer));
  if LNeeded < 0 then
  begin
    // Buffer foi insuficiente — alocar tamanho exacto e repetir
    SetLength(Result, Abs(LNeeded) + 1);
    FFormatar(AValor, PChar(Result), Length(Result));
    Result := PChar(Result); // trim ao null-terminator
  end
  else
    Result := string(LBuffer);
end;

function TDLLWrapper.CriarContexto(AID: Integer): Pointer;
begin
  Result := FCriarHandle(AID);
  if Result = nil then
    raise Exception.Create('CriarHandle retornou nil — sem memória?');
end;

procedure TDLLWrapper.AdicionarValor(AHandle: Pointer; AValor: Double);
begin
  if not FAddValor(AHandle, AValor) then
    raise Exception.Create('AdicionarValor falhou — handle inválido?');
end;

function TDLLWrapper.ObterMedia(AHandle: Pointer): Double;
begin
  if not FObterMedia(AHandle, Result) then
    raise Exception.Create('ObterMedia falhou — sem dados ou handle inválido');
end;

procedure TDLLWrapper.DestruirContexto(AHandle: Pointer);
begin
  if AHandle <> nil then
    FDestrHandle(AHandle);
end;

end.

{ =============================================================================
  Exemplo de uso — aplicação console (programa separado)
  ============================================================================= }

{
program ConsumorDLL;

uses
  System.SysUtils,
  loadlibrary_consumer_win;

var
  LDLL: TDLLWrapper;
  LHandle: Pointer;
  LValores: array of Double;
begin
  // --- Carregamento básico com LoadLibrary directo ---
  // (sem wrapper — para demonstrar o padrão manual)
  var LHModule := LoadLibrary('ExemploBasico.dll');
  if LHModule = 0 then
  begin
    Writeln('ERRO: ', SysErrorMessage(GetLastError));
    Halt(1);
  end;
  try
    var LGetVer: TGetLibraryVersion;
    @LGetVer := GetProcAddress(LHModule, 'GetLibraryVersion');
    if Assigned(LGetVer) then
      Writeln('Versão (directo): ', LGetVer);
  finally
    FreeLibrary(LHModule); // SEMPRE no finally
  end;

  Writeln;

  // --- Carregamento via wrapper (recomendado) ---
  LDLL := TDLLWrapper.Create('ExemploBasico.dll');
  try
    Writeln('Versão DLL  : ', LDLL.GetVersion);
    Writeln('Nome DLL    : ', LDLL.GetName);
    Writeln('2 + 3       : ', LDLL.Somar(2, 3));
    Writeln('Formatado   : ', LDLL.Formatar(42));

    SetLength(LValores, 5);
    LValores[0] := 10; LValores[1] := 20; LValores[2] := 30;
    LValores[3] := 40; LValores[4] := 50;
    Writeln('Média       : ', LDLL.CalcularMedia(LValores):0:2);

    // --- Opaque handle ---
    LHandle := LDLL.CriarContexto(1001);
    try
      LDLL.AdicionarValor(LHandle, 15.5);
      LDLL.AdicionarValor(LHandle, 25.0);
      LDLL.AdicionarValor(LHandle, 9.5);
      Writeln('Média handle: ', LDLL.ObterMedia(LHandle):0:2);
    finally
      LDLL.DestruirContexto(LHandle);
    end;

  finally
    LDLL.Free;
  end;
end.
}

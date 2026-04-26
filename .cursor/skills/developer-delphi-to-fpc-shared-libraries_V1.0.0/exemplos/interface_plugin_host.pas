{ =============================================================================
  interface_plugin_host.pas
  Sistema de plugins via interfaces — lado do HOST (aplicação principal).

  Demonstra:
    - LoadPlugin(APath) com tratamento de erros completo
    - Listagem de plugins num directório
    - Chamada polimórfica via IPlugin
    - Supports check para IPlugin2 (extensão backwards-compatible)
    - TPluginManager com ciclo de vida correcto

  O host NÃO linka contra as DLLs em tempo de compilação —
  tudo é carregado dinamicamente para suportar extensibilidade.
  ============================================================================= }

unit interface_plugin_host;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  SysUtils,
  Classes,
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF}
  {$IFDEF FPC}
  dynlibs,
  {$ENDIF}
  {$IFNDEF FPC}
    {$IFDEF POSIX}
    Posix.Dlfcn,
    {$ENDIF}
  {$ENDIF}
  Generics.Collections,
  PluginInterfaces; // unit de interfaces partilhada (ver interface_plugin_impl.pas)

// =========================================================================
// TPluginInfo — metadados de um plugin carregado
// =========================================================================
type
  TPluginInfo = record
    Path: string;
    Plugin: IPlugin;
    Name: string;
    Version: Integer;
    HasV2: Boolean;
  end;

// =========================================================================
// TPluginManager — gestão do ciclo de vida de plugins
// =========================================================================
  TPluginManager = class
  private
    type
      {$IFDEF MSWINDOWS}
      THandleType = HMODULE;
      {$ELSE}
      THandleType = NativeUInt;
      {$ENDIF}

    var
      FPlugins: TList<TPluginInfo>;
      FHandles: TDictionary<string, THandleType>; // path → handle

    function  InternalLoad(const APath: string): THandleType;
    procedure InternalUnload(AHandle: THandleType);
    function  InternalGetProc(AHandle: THandleType; const AName: string): Pointer;

  public
    constructor Create;
    destructor  Destroy; override;

    // Carrega um único ficheiro .dll ou .so
    // Lança excepção se o ficheiro não for um plugin válido ou incompatível.
    function  LoadPlugin(const APath: string): IPlugin;

    // Carrega todos os plugins num directório (extensão .dll ou .so)
    // Plugins inválidos são ignorados (erro no log) — não lança excepção.
    procedure LoadPluginsFromDir(const ADir: string;
                const AMask: string = '');

    // Descarregar todos os plugins (chamado automaticamente no destructor)
    procedure UnloadAll;

    // Chamar Execute em todos os plugins carregados
    procedure ExecuteAll(const AContext: string);

    // Listar plugins (cópia snapshot — thread-safe para leitura)
    function  GetPluginList: TArray<TPluginInfo>;

    property Count: Integer read (FPlugins.Count);
  end;

implementation

// =========================================================================
// Helpers de carregamento cross-platform
// =========================================================================

function TPluginManager.InternalLoad(const APath: string): THandleType;
begin
  {$IFDEF FPC}
    Result := LoadLibrary(APath);
    if Result = NilHandle then
      raise Exception.CreateFmt('LoadLibrary falhou "%s": %s',
        [APath, GetLoadErrorStr]);
  {$ELSE}
    {$IFDEF MSWINDOWS}
      Result := LoadLibrary(PChar(APath));
      if Result = 0 then
        raise Exception.CreateFmt('LoadLibrary falhou "%s": %s (erro %d)',
          [APath, SysErrorMessage(GetLastError), GetLastError]);
    {$ELSE}
      // Delphi POSIX (Linux/macOS)
      Result := THandleType(dlopen(MarshaledAString(TMarshaledAString(APath)),
                                   RTLD_LAZY or RTLD_LOCAL));
      if Result = 0 then
        raise Exception.CreateFmt('dlopen falhou "%s": %s',
          [APath, string(UTF8String(dlerror))]);
    {$ENDIF}
  {$ENDIF}
end;

procedure TPluginManager.InternalUnload(AHandle: THandleType);
begin
  {$IFDEF FPC}
    UnloadLibrary(AHandle);
  {$ELSE}
    {$IFDEF MSWINDOWS}
      FreeLibrary(AHandle);
    {$ELSE}
      dlclose(AHandle);
    {$ENDIF}
  {$ENDIF}
end;

function TPluginManager.InternalGetProc(AHandle: THandleType;
  const AName: string): Pointer;
begin
  {$IFDEF FPC}
    Result := GetProcedureAddress(AHandle, AName);
  {$ELSE}
    {$IFDEF MSWINDOWS}
      Result := GetProcAddress(AHandle, PChar(AName));
    {$ELSE}
      Result := dlsym(AHandle, MarshaledAString(TMarshaledAString(AName)));
    {$ENDIF}
  {$ENDIF}
end;

// =========================================================================
// TPluginManager — implementação
// =========================================================================

constructor TPluginManager.Create;
begin
  inherited;
  FPlugins := TList<TPluginInfo>.Create;
  FHandles := TDictionary<string, THandleType>.Create;
end;

destructor TPluginManager.Destroy;
begin
  UnloadAll;
  FPlugins.Free;
  FHandles.Free;
  inherited;
end;

function TPluginManager.LoadPlugin(const APath: string): IPlugin;
var
  LHandle: THandleType;
  LFactory: TPluginFactory;
  LPlugin: IPlugin;
  LPlugin2: IPlugin2;
  LInfo: TPluginInfo;
  LAbsPath: string;
begin
  Result := nil;
  LAbsPath := ExpandFileName(APath);

  // Evitar carregar o mesmo plugin duas vezes
  if FHandles.ContainsKey(LAbsPath) then
    raise Exception.CreateFmt('Plugin "%s" já está carregado', [LAbsPath]);

  LHandle := InternalLoad(LAbsPath);
  try
    // Verificar presença da factory — contrato mínimo de um plugin válido
    @LFactory := InternalGetProc(LHandle, 'CreatePlugin');
    if not Assigned(LFactory) then
      raise Exception.CreateFmt(
        '"%s" não exporta CreatePlugin — não é um plugin válido', [LAbsPath]);

    // Invocar factory — retorna IPlugin (reference counted)
    LPlugin := LFactory();
    if LPlugin = nil then
      raise Exception.CreateFmt('CreatePlugin retornou nil em "%s"', [LAbsPath]);

    // Verificar compatibilidade com o host
    if not LPlugin.IsCompatible(PLUGIN_VERSION) then
      raise Exception.CreateFmt(
        'Plugin "%s" incompatível — versão %d, requer host >= %d',
        [LAbsPath, LPlugin.GetVersion, PLUGIN_VERSION]);

    // Montar info
    LInfo.Path     := LAbsPath;
    LInfo.Plugin   := LPlugin;
    LInfo.Name     := LPlugin.GetName;
    LInfo.Version  := LPlugin.GetVersion;
    LInfo.HasV2    := Supports(LPlugin, IPlugin2, LPlugin2);

    FPlugins.Add(LInfo);
    FHandles.Add(LAbsPath, LHandle);

    Result := LPlugin;
    Writeln(Format('[PluginManager] Carregado: %s v%d%s',
      [LInfo.Name, LInfo.Version, IfThen(LInfo.HasV2, ' (IPlugin2)', '')]));

  except
    // Se qualquer coisa falhar após InternalLoad, descarregar
    InternalUnload(LHandle);
    raise;
  end;
end;

procedure TPluginManager.LoadPluginsFromDir(const ADir: string;
  const AMask: string);
var
  LSR: TSearchRec;
  LMask: string;
  LFullPath: string;
begin
  if AMask <> '' then
    LMask := AMask
  else
    LMask :=
      {$IFDEF MSWINDOWS} '*.dll'
      {$ELSE}            '*.so'
      {$ENDIF};

  if FindFirst(IncludeTrailingPathDelimiter(ADir) + LMask, faAnyFile, LSR) = 0 then
  try
    repeat
      if (LSR.Attr and faDirectory) = 0 then
      begin
        LFullPath := IncludeTrailingPathDelimiter(ADir) + LSR.Name;
        try
          LoadPlugin(LFullPath);
        except
          on E: Exception do
            // Plugin inválido ou incompatível — ignorar e continuar
            Writeln(Format('[PluginManager] Ignorado "%s": %s',
              [LSR.Name, E.Message]));
        end;
      end;
    until FindNext(LSR) <> 0;
  finally
    FindClose(LSR);
  end;
end;

procedure TPluginManager.UnloadAll;
var
  LPair: TPair<string, THandleType>;
begin
  // Libertar interfaces ANTES de descarregar as DLLs
  // (as interfaces têm ponteiros para código na DLL)
  FPlugins.Clear; // Clear decrementa reference count → Release → destructor na DLL

  // Agora descarregar as DLLs
  for LPair in FHandles do
    InternalUnload(LPair.Value);
  FHandles.Clear;
end;

procedure TPluginManager.ExecuteAll(const AContext: string);
var
  LInfo: TPluginInfo;
  LPlugin2: IPlugin2;
begin
  for LInfo in FPlugins do
  begin
    try
      // Verificar se suporta versão 2 (configuração antes de executar)
      if LInfo.HasV2 and Supports(LInfo.Plugin, IPlugin2, LPlugin2) then
        LPlugin2.Configure('{"context":"' + AContext + '"}');

      LInfo.Plugin.Execute(AContext);
    except
      on E: Exception do
        Writeln(Format('[PluginManager] Erro no plugin "%s": %s',
          [LInfo.Name, E.Message]));
    end;
  end;
end;

function TPluginManager.GetPluginList: TArray<TPluginInfo>;
var
  I: Integer;
begin
  SetLength(Result, FPlugins.Count);
  for I := 0 to FPlugins.Count - 1 do
    Result[I] := FPlugins[I];
end;

end.

{ =============================================================================
  Exemplo de uso — programa principal
  ============================================================================= }
{
program GestorERP;

uses
  SysUtils,
  interface_plugin_host,
  PluginInterfaces;

var
  LManager: TPluginManager;
  LPlugins: TArray<TPluginInfo>;
  LPlugin2: IPlugin2;
  LInfo: TPluginInfo;
begin
  LManager := TPluginManager.Create;
  try
    // Carregar todos os plugins da pasta plugins/
    LManager.LoadPluginsFromDir(ExtractFilePath(ParamStr(0)) + 'plugins');

    Writeln('Plugins carregados: ', LManager.Count);
    Writeln;

    // Listar com detalhes
    LPlugins := LManager.GetPluginList;
    for LInfo in LPlugins do
    begin
      Write(Format('  [%s] v%d', [LInfo.Name, LInfo.Version]));
      if LInfo.HasV2 then
      begin
        if Supports(LInfo.Plugin, IPlugin2, LPlugin2) then
          Write(Format(' | Autor: %s', [LPlugin2.GetAuthor]));
      end;
      Writeln;
    end;

    Writeln;

    // Executar todos
    LManager.ExecuteAll('GestorERP:inicializar');

  finally
    LManager.Free; // UnloadAll chamado no destructor
  end;
end.
}

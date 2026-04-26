unit TEMPLATE_bpl_loader;
(*
  TEMPLATE: Loader Dinâmico de BPL com Interface de Plugin
  Skill: developer-delphi-to-fpc-architecture-modules_V1.0.0

  INSTRUCOES DE USO:
    1. Copiar para o projeto com nome adequado: ex. uPlugin.Loader.pas
    2. Definir IPlugin em unit compartilhada (uPlugin.Interfaces.pas).
    3. Substituir IPlugin e TCreatePluginFunc pelas interfaces reais.
    4. Cada BPL/DLL de plugin deve exportar a função 'CreatePlugin' (stdcall).
    5. Compilar: dcc32 / dcc64 (Delphi) | LoadPackage é Windows-only.

  ESTRUTURA ESPERADA DO PLUGIN BPL:
    - Exporta: function CreatePlugin: IPlugin; stdcall;
    - Depende apenas de: uPlugin.Interfaces.pas (interface compartilhada)
    - NAO depende de units internas do app host

  CICLO DE VIDA:
    TPluginLoader.Create
    → CarregarDiretorio / CarregarBPL   (LoadPackage + GetProcAddress)
    → [usar plugins via IPlugin]
    → TPluginLoader.Free                (FPlugins.Clear + UnloadPackage)
*)
{$IFDEF FPC}
  {$mode delphi}
  {$H+}
{$ENDIF}

interface

uses
  SysUtils, Classes
  {$IFDEF MSWINDOWS}, Windows{$ENDIF};

// =============================================================================
// Interface de plugin — mover para unit compartilhada em projeto real
// Ex.: uPlugin.Interfaces.pas
// =============================================================================

type
  IPlugin = interface
    ['{FFFFFFFF-EEEE-DDDD-CCCC-BBBBBBBBBBBB}']  // SUBSTITUIR GUID
    function Nome: string;
    function Versao: string;
    function Descricao: string;
    procedure Inicializar(const AConfig: string);
    procedure Executar(const AParametro: string);
    procedure Finalizar;
  end;

  // Tipo da função factory exportada pelo BPL/DLL
  TCreatePluginFunc = function: IPlugin; stdcall;

// =============================================================================
// Loader de plugins
// =============================================================================

  TPluginInfo = record
    Nome: string;
    Versao: string;
    Caminho: string;
    Handle: HMODULE;
  end;

  TPluginLoader = class
  private
    FPlugins: TInterfaceList;
    FInfos: array of TPluginInfo;
    FInfoCount: Integer;
    FConfig: string;
    procedure AdicionarPlugin(const AHandle: HMODULE; const ACaminho: string;
      const APlugin: IPlugin);
  public
    constructor Create(const AConfig: string = '');
    destructor Destroy; override;

    // Carregamento
    procedure CarregarBPL(const ACaminho: string);
    procedure CarregarDiretorio(const ADiretorio: string;
      const AMascara: string = '*.bpl');

    // Acesso
    function Count: Integer;
    function Plugin(AIndex: Integer): IPlugin;
    function Info(AIndex: Integer): TPluginInfo;
    function EncontrarPorNome(const ANome: string): IPlugin;

    // Descarregamento
    procedure DescarregarTodos;
  end;

implementation

constructor TPluginLoader.Create(const AConfig: string);
begin
  inherited Create;
  FPlugins := TInterfaceList.Create;
  FConfig := AConfig;
  FInfoCount := 0;
  SetLength(FInfos, 32);
end;

destructor TPluginLoader.Destroy;
begin
  DescarregarTodos;
  FPlugins.Free;
  inherited;
end;

procedure TPluginLoader.AdicionarPlugin(const AHandle: HMODULE;
  const ACaminho: string; const APlugin: IPlugin);
begin
  FPlugins.Add(APlugin);

  if FInfoCount >= Length(FInfos) then
    SetLength(FInfos, Length(FInfos) + 32);

  FInfos[FInfoCount].Nome    := APlugin.Nome;
  FInfos[FInfoCount].Versao  := APlugin.Versao;
  FInfos[FInfoCount].Caminho := ACaminho;
  FInfos[FInfoCount].Handle  := AHandle;
  Inc(FInfoCount);
end;

procedure TPluginLoader.CarregarBPL(const ACaminho: string);
{$IFDEF MSWINDOWS}
var
  H: HMODULE;
  CreatePlugin: TCreatePluginFunc;
  Plugin: IPlugin;
begin
  if not FileExists(ACaminho) then
    raise Exception.CreateFmt('Plugin não encontrado: %s', [ACaminho]);

  // Passo 1: Carregar o BPL (executa initialization das units internas)
  H := LoadPackage(ACaminho);
  if H = 0 then
    raise Exception.CreateFmt(
      'Falha ao carregar BPL "%s": %s',
      [ExtractFileName(ACaminho), SysErrorMessage(GetLastError)]);

  try
    // Passo 2: Localizar função factory exportada
    @CreatePlugin := GetProcAddress(H, 'CreatePlugin');
    if not Assigned(CreatePlugin) then
      raise Exception.CreateFmt(
        'BPL "%s" não exporta CreatePlugin (stdcall)',
        [ExtractFileName(ACaminho)]);

    // Passo 3: Criar instância via factory
    Plugin := CreatePlugin;
    if Plugin = nil then
      raise Exception.CreateFmt(
        'CreatePlugin retornou nil para "%s"',
        [ExtractFileName(ACaminho)]);

    // Passo 4: Inicializar com configuração do loader
    Plugin.Inicializar(FConfig);

    // Passo 5: Registrar
    AdicionarPlugin(H, ACaminho, Plugin);

  except
    // Descarregar em caso de falha para evitar handle leak
    UnloadPackage(H);
    raise;
  end;
end;
{$ELSE}
begin
  raise Exception.Create('LoadPackage disponível apenas em Windows');
end;
{$ENDIF}

procedure TPluginLoader.CarregarDiretorio(const ADiretorio: string;
  const AMascara: string);
var
  Busca: TSearchRec;
  Caminho: string;
begin
  if not DirectoryExists(ADiretorio) then
    Exit; // diretório inexistente não é erro — pode não haver plugins

  if FindFirst(IncludeTrailingPathDelimiter(ADiretorio) + AMascara,
               faAnyFile, Busca) = 0 then
  try
    repeat
      if (Busca.Attr and faDirectory) = 0 then
      begin
        Caminho := IncludeTrailingPathDelimiter(ADiretorio) + Busca.Name;
        try
          CarregarBPL(Caminho);
        except
          on E: Exception do
            // Log do erro mas continua carregando os demais plugins
            WriteLn(Format('[PluginLoader] Aviso: falha ao carregar %s: %s',
              [Busca.Name, E.Message]));
        end;
      end;
    until FindNext(Busca) <> 0;
  finally
    FindClose(Busca);
  end;
end;

function TPluginLoader.Count: Integer;
begin
  Result := FPlugins.Count;
end;

function TPluginLoader.Plugin(AIndex: Integer): IPlugin;
begin
  if (AIndex < 0) or (AIndex >= FPlugins.Count) then
    raise Exception.CreateFmt('TPluginLoader.Plugin: índice %d fora do intervalo [0..%d]',
      [AIndex, FPlugins.Count - 1]);
  Result := FPlugins[AIndex] as IPlugin;
end;

function TPluginLoader.Info(AIndex: Integer): TPluginInfo;
begin
  if (AIndex < 0) or (AIndex >= FInfoCount) then
    raise Exception.CreateFmt('TPluginLoader.Info: índice %d fora do intervalo',
      [AIndex]);
  Result := FInfos[AIndex];
end;

function TPluginLoader.EncontrarPorNome(const ANome: string): IPlugin;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FPlugins.Count - 1 do
  begin
    if SameText((FPlugins[I] as IPlugin).Nome, ANome) then
    begin
      Result := FPlugins[I] as IPlugin;
      Break;
    end;
  end;
end;

procedure TPluginLoader.DescarregarTodos;
{$IFDEF MSWINDOWS}
var
  I: Integer;
  H: HMODULE;
begin
  // ORDEM CRÍTICA:
  // 1. Finalizar cada plugin (notifica o plugin para liberar seus recursos)
  for I := 0 to FPlugins.Count - 1 do
  begin
    try
      (FPlugins[I] as IPlugin).Finalizar;
    except
      // Ignorar erros de finalização — continuar descarregando
    end;
  end;

  // 2. Liberar TODAS as referências de interface ANTES de descarregar BPLs
  //    (interfaces apontam para código dentro dos BPLs)
  FPlugins.Clear;

  // 3. Descarregar os BPLs (executa finalization das units internas)
  for I := 0 to FInfoCount - 1 do
  begin
    H := FInfos[I].Handle;
    if H <> 0 then
    begin
      try
        UnloadPackage(H);
      except
        // Ignorar erros de descarregamento
      end;
      FInfos[I].Handle := 0;
    end;
  end;
  FInfoCount := 0;
end;
{$ELSE}
begin
  for I := 0 to FPlugins.Count - 1 do
  begin
    try
      (FPlugins[I] as IPlugin).Finalizar;
    except
    end;
  end;
  FPlugins.Clear;
  FInfoCount := 0;
end;
{$ENDIF}

end.

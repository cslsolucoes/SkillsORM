(*
  EXEMPLO: Módulo como BPL — LoadPackage, Initialize, Finalize
  Skill: developer-delphi-to-fpc-architecture-modules_V1.0.0

  CONTEXTO:
    BPL (Borland Package Library) = DLL especializada do Delphi.
    Contém units Delphi compiladas; compartilha RTL e VCL/FMX com o app host.

  TIPOS DE PACKAGES:
    Runtime Package:
      - Usado em tempo de execução pela aplicação.
      - Deve estar no caminho do executável (mesma pasta ou PATH do sistema).
      - Criado com: File → New → Package

    Design-time Package:
      - Instalado no IDE para registrar componentes.
      - Não distribuído com a aplicação.
      - Contém Register procedure.

    Static Linking (sem package):
      - Todo código linkado no .exe; sem dependência de .bpl externo.
      - Executável maior; sem "DLL Hell" de versão.
      - Project → Options → Packages → "Link with runtime packages" = OFF

    Dynamic Linking (com runtime packages):
      - .exe menor; .bpl compartilhados entre apps.
      - Deve distribuir os .bpl junto com o executável.
      - Project → Options → Packages → "Link with runtime packages" = ON

  ESTE ARQUIVO demonstra:
    1. Como usar LoadPackage/UnloadPackage para carregar BPL dinamicamente.
    2. Estrutura de um package com Initialize/Finalize.
    3. Obter factory de plugin via GetProcAddress.

  Compilar: dcc32 bpl_module.pas  OU  dcc64 bpl_module.pas
  (Nota: LoadPackage requer MSWINDOWS; a parte de demo funciona em qualquer SO)
*)
program bpl_module;
{$APPTYPE CONSOLE}
{$IFDEF FPC}
  {$mode delphi}
  {$H+}
{$ENDIF}

uses
  SysUtils, Classes
  {$IFDEF MSWINDOWS}, Windows{$ENDIF};

// =============================================================================
// Interface compartilhada (normalmente em unit separada distribuida com o app)
// Tanto o app host quanto o plugin dependem DESTA interface.
// =============================================================================

type
  IPlugin = interface
    ['{A0B1C2D3-E4F5-6789-ABCD-EF0123456789}']
    function Nome: string;
    function Versao: string;
    procedure Executar(const AParametro: string);
  end;

  // Tipo da funcao factory exportada pelo BPL/DLL
  // O plugin exporta: function CreatePlugin: IPlugin; stdcall;
  TCreatePluginFunc = function: IPlugin; stdcall;

// =============================================================================
// Simulacao de plugin em memoria (substitui BPL real para este exemplo)
// Em um BPL real, este codigo estaria no package, nao no app.
// =============================================================================

type
  TRelatorioPlugin = class(TInterfacedObject, IPlugin)
  public
    function Nome: string;
    function Versao: string;
    procedure Executar(const AParametro: string);
  end;

function TRelatorioPlugin.Nome: string;
begin
  Result := 'Plugin de Relatorio';
end;

function TRelatorioPlugin.Versao: string;
begin
  Result := '1.0.0';
end;

procedure TRelatorioPlugin.Executar(const AParametro: string);
begin
  WriteLn(Format('[%s v%s] Gerando relatorio: %s', [Nome, Versao, AParametro]));
end;

// =============================================================================
// Loader de plugins — carrega BPL/DLL em runtime
// =============================================================================

type
  TPluginLoader = class
  private
    FPlugins: TInterfaceList;
    FHandles: array of HMODULE;
    FHandleCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure CarregarBPL(const ACaminho: string);
    procedure CarregarPluginSimulado; // substitui BPL real neste exemplo
    function PluginCount: Integer;
    function Plugin(AIndex: Integer): IPlugin;
    procedure DescarregarTodos;
  end;

constructor TPluginLoader.Create;
begin
  inherited Create;
  FPlugins := TInterfaceList.Create;
  FHandleCount := 0;
  SetLength(FHandles, 16);
end;

destructor TPluginLoader.Destroy;
begin
  DescarregarTodos;
  FPlugins.Free;
  inherited;
end;

procedure TPluginLoader.CarregarBPL(const ACaminho: string);
{$IFDEF MSWINDOWS}
var
  H: HMODULE;
  CreatePlugin: TCreatePluginFunc;
  Plugin: IPlugin;
begin
  // Passo 1: Carregar o package (BPL e DLL sao identicos para LoadPackage)
  // LoadPackage chama DllMain + InitializePackage do BPL
  H := LoadPackage(ACaminho);
  if H = 0 then
    raise Exception.CreateFmt(
      'Falha ao carregar package "%s": %s', [ACaminho, SysErrorMessage(GetLastError)]);

  // Passo 2: Obter ponteiro para a funcao factory exportada
  @CreatePlugin := GetProcAddress(H, 'CreatePlugin');
  if not Assigned(CreatePlugin) then
  begin
    UnloadPackage(H);
    raise Exception.CreateFmt(
      'Package "%s" nao exporta "CreatePlugin"', [ACaminho]);
  end;

  // Passo 3: Criar instancia do plugin via factory
  Plugin := CreatePlugin;
  if Plugin = nil then
  begin
    UnloadPackage(H);
    raise Exception.CreateFmt(
      'CreatePlugin retornou nil para "%s"', [ACaminho]);
  end;

  // Passo 4: Registrar plugin e handle para descarregamento posterior
  FPlugins.Add(Plugin);
  FHandles[FHandleCount] := H;
  Inc(FHandleCount);

  WriteLn(Format('BPL carregado: %s (Plugin: %s v%s)',
    [ExtractFileName(ACaminho), Plugin.Nome, Plugin.Versao]));
end;
{$ELSE}
begin
  raise Exception.Create('LoadPackage disponivel apenas em Windows');
end;
{$ENDIF}

procedure TPluginLoader.CarregarPluginSimulado;
var
  Plugin: IPlugin;
begin
  // Substitui CarregarBPL neste exemplo — sem arquivo .bpl real necessario
  Plugin := TRelatorioPlugin.Create;
  FPlugins.Add(Plugin);
  WriteLn(Format('Plugin simulado carregado: %s v%s', [Plugin.Nome, Plugin.Versao]));
end;

procedure TPluginLoader.DescarregarTodos;
{$IFDEF MSWINDOWS}
var
  I: Integer;
begin
  // Liberar interfaces ANTES de descarregar o package
  // (interfaces apontam para codigo no BPL — descarregar antes = crash)
  FPlugins.Clear;

  for I := 0 to FHandleCount - 1 do
  begin
    if FHandles[I] <> 0 then
    begin
      // UnloadPackage chama FinalizePackage + FreeLibrary
      UnloadPackage(FHandles[I]);
      FHandles[I] := 0;
    end;
  end;
  FHandleCount := 0;
end;
{$ELSE}
begin
  FPlugins.Clear;
end;
{$ENDIF}

function TPluginLoader.PluginCount: Integer;
begin
  Result := FPlugins.Count;
end;

function TPluginLoader.Plugin(AIndex: Integer): IPlugin;
begin
  Result := FPlugins[AIndex] as IPlugin;
end;

// =============================================================================
// Como seria a unit do BPL (para referencia — nao compilar separado aqui)
// =============================================================================

(*
  ESTRUTURA DO ARQUIVO .dpr DO PACKAGE (MeuPlugin.dpk):

    package MeuPlugin;

    {$R *.res}
    {$ALIGN 8}
    {$ASSERTIONS ON}
    {$BOOLEVAL OFF}
    {$DEBUGINFO OFF}
    {$EXTENDEDSYNTAX ON}
    {$IMPORTEDDATA ON}
    {$IOCHECKS ON}
    {$LOCALSYMBOLS ON}
    {$LONGSTRINGS ON}
    {$OPENSTRINGS ON}
    {$OPTIMIZATION OFF}
    {$OVERFLOWCHECKS OFF}
    {$RANGECHECKS OFF}
    {$REFERENCEINFO ON}
    {$SAFEDIVIDE OFF}
    {$STACKFRAMES ON}
    {$TYPEDADDRESS OFF}
    {$VARSTRINGCHECKS ON}
    {$WRITEABLECONST OFF}
    {$MINENUMSIZE 1}
    {$IMAGEBASE $400000}
    {$DESCRIPTION 'Plugin de Relatorio'}
    {$RUNONLY}
    {$IMPLICITBUILD ON}

    requires
      rtl,
      vcl;

    contains
      uPlugin.Interfaces in 'uPlugin.Interfaces.pas',
      uRelatorio.Impl in 'uRelatorio.Impl.pas';

    end.

  UNIT DO PLUGIN (uRelatorio.Impl.pas):

    unit uRelatorio.Impl;
    interface
    uses uPlugin.Interfaces;
    type
      TRelatorioPlugin = class(TInterfacedObject, IPlugin)
        ...
      end;
    // Funcao exportada — entry point para o app host
    function CreatePlugin: IPlugin; stdcall;
    implementation
    function CreatePlugin: IPlugin; stdcall;
    begin
      Result := TRelatorioPlugin.Create;
    end;
    exports CreatePlugin;
    end.
*)

// =============================================================================
// Programa principal
// =============================================================================

var
  Loader: TPluginLoader;
  I: Integer;
begin
  WriteLn('=== Exemplo: BPL Module — Carregamento Dinamico de Plugins ===');
  WriteLn;

  Loader := TPluginLoader.Create;
  try
    // Em producao: CarregarBPL('plugins\MeuPlugin.bpl')
    // Neste exemplo: simular sem arquivo .bpl
    Loader.CarregarPluginSimulado;

    WriteLn;
    WriteLn(Format('Total de plugins carregados: %d', [Loader.PluginCount]));
    WriteLn;

    // Executar cada plugin via interface
    for I := 0 to Loader.PluginCount - 1 do
    begin
      WriteLn(Format('--- Executando plugin [%d]: %s ---', [I, Loader.Plugin(I).Nome]));
      Loader.Plugin(I).Executar('parametro-de-teste');
    end;
  finally
    // DescarregarTodos libera interfaces antes de UnloadPackage
    Loader.Free;
  end;

  WriteLn;
  WriteLn('OK -- developer-delphi-to-fpc-architecture-modules :: bpl_module');
end.

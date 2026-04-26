{ =============================================================================
  interface_plugin_impl.pas
  Sistema de plugins via interfaces — lado da DLL (plugin).

  Demonstra:
    - TMyPlugin implementando IPlugin e IPlugin2
    - CreatePlugin: IPlugin; stdcall; exportado
    - Projecto library com exports mínimos
    - TInterfacedObject — reference counting automático

  Este ficheiro representa o conteúdo da DLL do plugin.
  A unit PluginInterfaces.pas é COMPARTILHADA entre host e DLL
  (compilada em ambos, sem linking entre si).
  ============================================================================= }

{ ============================================================================
  PluginInterfaces.pas — unit compartilhada (compilar em host E em cada DLL)
  ============================================================================ }

unit PluginInterfaces;

interface

const
  // Versão do protocolo de interface — inteiro YYYYMMDD
  // Host e plugin usam esta constante para verificar compatibilidade.
  PLUGIN_VERSION = 20260411;

type
  // -----------------------------------------------------------------------
  // IPlugin — interface base (V1)
  // GUID OBRIGATÓRIO para Supports() e QueryInterface().
  // Gerar novo GUID: Ctrl+Shift+G no RAD Studio; no FPC usar guidgen ou uuidgen.
  // -----------------------------------------------------------------------
  IPlugin = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']

    // Metadados do plugin
    function GetName: WideString;          // WideString: COM-safe na fronteira DLL
    function GetVersion: Integer;          // YYYYMMDD
    function GetDescription: WideString;

    // Verificar compatibilidade — plugin recebe a versão do host
    // Retorna True se pode operar com este host.
    function IsCompatible(AHostVersion: Integer): Boolean;

    // Ponto de entrada principal — AContext é JSON ou identificador de operação
    procedure Execute(const AContext: WideString);
  end;

  // -----------------------------------------------------------------------
  // IPlugin2 — interface estendida (V2), backwards-compatible
  // Hosts antigos (que não conhecem IPlugin2) continuam a funcionar.
  // Plugins antigos (que não implementam IPlugin2) são detectados via Supports().
  // -----------------------------------------------------------------------
  IPlugin2 = interface(IPlugin)
    ['{B2C3D4E5-F6A7-8901-BCDE-F12345678901}']
    function GetAuthor: WideString;
    function GetLicense: WideString;
    procedure Configure(const AJSON: WideString);  // configuração antes de Execute
    procedure ExecuteAsync(const AContext: WideString); // não bloqueia
  end;

  // -----------------------------------------------------------------------
  // Tipo da factory exportada pela DLL
  // Calling convention DEVE ser stdcall (Windows) ou cdecl (Linux).
  // -----------------------------------------------------------------------
  TPluginFactory = function: IPlugin;
    {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}

implementation
end.

{ ============================================================================
  uMeuPlugin.pas — implementação do plugin (dentro da DLL)
  ============================================================================ }

unit uMeuPlugin;

interface

uses
  SysUtils,
  PluginInterfaces;

type
  // -----------------------------------------------------------------------
  // TMyPlugin — implementa IPlugin e IPlugin2
  // TInterfacedObject fornece _AddRef/_Release/_QueryInterface automaticamente.
  // Memória alocada e gerida DENTRO DA DLL — sem problema de fronteira.
  // -----------------------------------------------------------------------
  TMyPlugin = class(TInterfacedObject, IPlugin, IPlugin2)
  private
    FConfigured: Boolean;
    FLastContext: WideString;
    FAuthor: WideString;
  protected
    // --- IPlugin ---
    function  GetName: WideString;
    function  GetVersion: Integer;
    function  GetDescription: WideString;
    function  IsCompatible(AHostVersion: Integer): Boolean;
    procedure Execute(const AContext: WideString);

    // --- IPlugin2 ---
    function  GetAuthor: WideString;
    function  GetLicense: WideString;
    procedure Configure(const AJSON: WideString);
    procedure ExecuteAsync(const AContext: WideString);
  public
    constructor Create;
    destructor  Destroy; override;
  end;

implementation

{ TMyPlugin }

constructor TMyPlugin.Create;
begin
  inherited;
  FConfigured := False;
  FAuthor     := 'Equipa GestorERP';
  // Inicializar recursos do plugin aqui
end;

destructor TMyPlugin.Destroy;
begin
  // Libertar recursos — chamado automaticamente quando reference count chega a 0
  // Estamos DENTRO DA DLL, portanto usamos o heap correcto.
  inherited;
end;

function TMyPlugin.GetName: WideString;
begin
  Result := 'MeuPlugin';
end;

function TMyPlugin.GetVersion: Integer;
begin
  Result := PLUGIN_VERSION; // usa a constante da interface partilhada
end;

function TMyPlugin.GetDescription: WideString;
begin
  Result := 'Plugin de exemplo para GestorERP — demonstra IPlugin e IPlugin2';
end;

function TMyPlugin.IsCompatible(AHostVersion: Integer): Boolean;
begin
  // Compatível com qualquer host >= 20260101 (1 de Janeiro de 2026)
  // Política: manter compatibilidade com últimas 2 versões do host.
  Result := AHostVersion >= 20260101;
end;

procedure TMyPlugin.Execute(const AContext: WideString);
begin
  // Guardar último contexto para auditoria
  FLastContext := AContext;

  // Lógica real do plugin aqui
  // AContext pode ser: 'GestorERP:inicializar', 'GestorERP:processar:NF', etc.
  if Pos('inicializar', string(AContext)) > 0 then
    begin
      // setup inicial
    end
  else if Pos('processar', string(AContext)) > 0 then
    begin
      // processamento principal
    end;

  // NUNCA lançar excepções não tratadas através da fronteira da DLL
  // — pode causar crash se o host não tiver o mesmo RTL de excepções.
  // Tratar internamente e reportar via código de retorno ou IPlugin2.Configure.
end;

function TMyPlugin.GetAuthor: WideString;
begin
  Result := FAuthor;
end;

function TMyPlugin.GetLicense: WideString;
begin
  Result := 'MIT';
end;

procedure TMyPlugin.Configure(const AJSON: WideString);
begin
  // Parsear JSON de configuração — usar unit JSON do Delphi ou FPC
  // Exemplo: {"author":"Nome","debug":true}
  FConfigured := True;
  // Extrair campos do JSON...
end;

procedure TMyPlugin.ExecuteAsync(const AContext: WideString);
begin
  // Implementar execução assíncrona se o plugin suportar.
  // CUIDADO: threads criadas dentro de uma DLL partilham o processo do host.
  // Sincronização com o host é responsabilidade do plugin.
  //
  // Implementação simples: delegar para Execute (síncrono como fallback)
  Execute(AContext);
end;

end.

{ ============================================================================
  MeuPlugin.dpr — ficheiro de projecto da DLL do plugin
  ============================================================================ }

{
library MeuPlugin;

{$R *.res}

uses
  // NÃO incluir ShareMem — a interface IPlugin usa WideString (COM-safe)
  // e TInterfacedObject — ambos seguros sem ShareMem.
  System.SysUtils,
  PluginInterfaces in '..\shared\PluginInterfaces.pas',
  uMeuPlugin in 'uMeuPlugin.pas';

// -----------------------------------------------------------------------
// CreatePlugin — factory exportada (único export obrigatório)
// -----------------------------------------------------------------------
function CreatePlugin: IPlugin;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}
begin
  // TMyPlugin herda de TInterfacedObject — reference counting automático.
  // O host recebe a interface; quando sair de scope, _Release é chamado
  // e TMyPlugin.Destroy liberta a memória NO HEAP DESTA DLL.
  Result := TMyPlugin.Create;
end;

// -----------------------------------------------------------------------
// GetPluginVersion — export opcional mas recomendado para diagnóstico
// -----------------------------------------------------------------------
function GetPluginVersion: Integer;
  {$IFDEF MSWINDOWS} stdcall; {$ELSE} cdecl; {$ENDIF}
begin
  Result := PLUGIN_VERSION;
end;

exports
  CreatePlugin,      // obrigatório — contrato do sistema de plugins
  GetPluginVersion;  // recomendado — diagnóstico sem instanciar o plugin

begin
  // Sem inicialização especial — TMyPlugin.Create trata de tudo
end.
}

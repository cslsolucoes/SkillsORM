unit composite;
{
  Composite Pattern em Delphi — árvore de componentes UI com operações recursivas
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Interface Component — operações uniformes para Leaf e Composite
// ---------------------------------------------------------------------------
type
  IUIComponent = interface
  ['{CO000001-0000-0000-0000-000000000001}']
    procedure Render(AIndent: Integer);
    function  GetNome: string;
    function  GetVisible: Boolean;
    procedure SetVisible(AVal: Boolean);
    function  Calcular: Integer;  // ex: soma de "pesos" da árvore
    property Nome: string read GetNome;
    property Visible: Boolean read GetVisible write SetVisible;
  end;

// ---------------------------------------------------------------------------
// Leaf — componente sem filhos
// ---------------------------------------------------------------------------
type
  TUILabel = class(TInterfacedObject, IUIComponent)
  private
    FNome:    string;
    FTexto:   string;
    FVisible: Boolean;
    FPeso:    Integer;
  public
    constructor Create(const ANome, ATexto: string; APeso: Integer = 1);
    procedure Render(AIndent: Integer);
    function  GetNome: string;
    function  GetVisible: Boolean;
    procedure SetVisible(AVal: Boolean);
    function  Calcular: Integer;
  end;

  TUIButton = class(TInterfacedObject, IUIComponent)
  private
    FNome:    string;
    FCaption: string;
    FVisible: Boolean;
    FEnabled: Boolean;
    FPeso:    Integer;
  public
    constructor Create(const ANome, ACaption: string; APeso: Integer = 2);
    procedure Render(AIndent: Integer);
    function  GetNome: string;
    function  GetVisible: Boolean;
    procedure SetVisible(AVal: Boolean);
    function  Calcular: Integer;
    property Enabled: Boolean read FEnabled write FEnabled;
  end;

// ---------------------------------------------------------------------------
// Composite — contém filhos (Leaf ou outros Composite)
// ---------------------------------------------------------------------------
type
  TUIPanel = class(TInterfacedObject, IUIComponent)
  private
    FNome:     string;
    FTitulo:   string;
    FVisible:  Boolean;
    FFilhos:   TList<IUIComponent>;
  public
    constructor Create(const ANome, ATitulo: string);
    destructor Destroy; override;
    // Gerência de filhos
    procedure Add(AComp: IUIComponent);
    procedure Remove(AComp: IUIComponent);
    function  Find(const ANome: string): IUIComponent;
    function  Count: Integer;
    // IUIComponent
    procedure Render(AIndent: Integer);
    function  GetNome: string;
    function  GetVisible: Boolean;
    procedure SetVisible(AVal: Boolean);  // propaga para filhos
    function  Calcular: Integer;          // soma recursiva
  end;

  TUIForm = class(TUIPanel)
  private
    FTitulo: string;
  public
    constructor Create(const ANome, ATitulo: string);
    procedure Render(AIndent: Integer); reintroduce;
  end;

// ---------------------------------------------------------------------------
// Visitor-like — operação recursiva sobre a árvore
// ---------------------------------------------------------------------------
type
  TUIVisitor = reference to procedure(AComp: IUIComponent; ALevel: Integer);

procedure PercorrerArvore(ARoot: IUIComponent; AVisitor: TUIVisitor; ALevel: Integer = 0);

implementation

// ---------------------------------------------------------------------------
// TUILabel
// ---------------------------------------------------------------------------

constructor TUILabel.Create(const ANome, ATexto: string; APeso: Integer);
begin inherited Create; FNome := ANome; FTexto := ATexto; FPeso := APeso; FVisible := True; end;

procedure TUILabel.Render(AIndent: Integer);
var Pad: string;
begin
  Pad := StringOfChar(' ', AIndent * 2);
  if FVisible then Writeln(Pad, '[Label:', FNome, '] ', FTexto)
  else Writeln(Pad, '[Label:', FNome, '] (hidden)');
end;

function TUILabel.GetNome: string;    begin Result := FNome; end;
function TUILabel.GetVisible: Boolean; begin Result := FVisible; end;
procedure TUILabel.SetVisible(AVal: Boolean); begin FVisible := AVal; end;
function TUILabel.Calcular: Integer;  begin Result := FPeso; end;

// ---------------------------------------------------------------------------
// TUIButton
// ---------------------------------------------------------------------------

constructor TUIButton.Create(const ANome, ACaption: string; APeso: Integer);
begin inherited Create; FNome := ANome; FCaption := ACaption; FPeso := APeso;
  FVisible := True; FEnabled := True; end;

procedure TUIButton.Render(AIndent: Integer);
var Pad: string;
begin
  Pad := StringOfChar(' ', AIndent * 2);
  if FVisible then
    Writeln(Pad, '[Btn:', FNome, '] "', FCaption, '"',
      IfThen(FEnabled, '', ' (disabled)'))
  else
    Writeln(Pad, '[Btn:', FNome, '] (hidden)');
end;

function TUIButton.GetNome: string;    begin Result := FNome; end;
function TUIButton.GetVisible: Boolean; begin Result := FVisible; end;
procedure TUIButton.SetVisible(AVal: Boolean); begin FVisible := AVal; end;
function TUIButton.Calcular: Integer;  begin Result := FPeso; end;

// ---------------------------------------------------------------------------
// TUIPanel
// ---------------------------------------------------------------------------

constructor TUIPanel.Create(const ANome, ATitulo: string);
begin inherited Create; FNome := ANome; FTitulo := ATitulo; FVisible := True;
  FFilhos := TList<IUIComponent>.Create; end;

destructor TUIPanel.Destroy;
begin FFilhos.Free; inherited; end;

procedure TUIPanel.Add(AComp: IUIComponent);
begin FFilhos.Add(AComp); end;

procedure TUIPanel.Remove(AComp: IUIComponent);
begin FFilhos.Remove(AComp); end;

function TUIPanel.Find(const ANome: string): IUIComponent;
var C: IUIComponent;
    Sub: TUIPanel;
begin
  for C in FFilhos do
  begin
    if C.Nome = ANome then Exit(C);
    if C is TUIPanel then
    begin
      Result := TUIPanel(C).Find(ANome);
      if Result <> nil then Exit;
    end;
  end;
  Result := nil;
end;

function TUIPanel.Count: Integer;
begin Result := FFilhos.Count; end;

procedure TUIPanel.Render(AIndent: Integer);
var Pad: string;
    C: IUIComponent;
begin
  Pad := StringOfChar(' ', AIndent * 2);
  Writeln(Pad, '[Panel:', FNome, '] ', FTitulo);
  if FVisible then
    for C in FFilhos do C.Render(AIndent + 1);
end;

function TUIPanel.GetNome: string;    begin Result := FNome; end;
function TUIPanel.GetVisible: Boolean; begin Result := FVisible; end;

procedure TUIPanel.SetVisible(AVal: Boolean);
var C: IUIComponent;
begin
  FVisible := AVal;
  for C in FFilhos do C.Visible := AVal;  // propaga recursivamente
end;

function TUIPanel.Calcular: Integer;
var C: IUIComponent;
begin
  Result := 0;
  for C in FFilhos do Inc(Result, C.Calcular);  // soma recursiva
end;

// ---------------------------------------------------------------------------
// TUIForm
// ---------------------------------------------------------------------------

constructor TUIForm.Create(const ANome, ATitulo: string);
begin inherited Create(ANome, ATitulo); FTitulo := ATitulo; end;

procedure TUIForm.Render(AIndent: Integer);
var C: IUIComponent;
begin
  Writeln('╔══ Form:', GetNome, ' — ', FTitulo, ' ══╗');
  for C in FFilhos do C.Render(1);
  Writeln('╚══════════════╝');
end;

// ---------------------------------------------------------------------------
// PercorrerArvore
// ---------------------------------------------------------------------------

procedure PercorrerArvore(ARoot: IUIComponent; AVisitor: TUIVisitor; ALevel: Integer);
var C: IUIComponent;
begin
  AVisitor(ARoot, ALevel);
  if ARoot is TUIPanel then
    for C in TUIPanel(ARoot).FFilhos do
      PercorrerArvore(C, AVisitor, ALevel + 1);
end;

// ---------------------------------------------------------------------------
// USO:
//   var Form := TUIForm.Create('frmPrincipal', 'Gestão de Pedidos');
//   var PanelTopo := TUIPanel.Create('pnlTopo', 'Cabeçalho');
//   PanelTopo.Add(TUILabel.Create('lblTitulo', 'Pedidos'));
//   PanelTopo.Add(TUIButton.Create('btnNovo', 'Novo Pedido'));
//
//   var PanelGrid := TUIPanel.Create('pnlGrid', 'Lista');
//   PanelGrid.Add(TUILabel.Create('lblInfo', 'Nenhum pedido'));
//   PanelGrid.Add(TUIButton.Create('btnExcluir', 'Excluir', 3));
//
//   Form.Add(PanelTopo);
//   Form.Add(PanelGrid);
//   Form.Render(0);
//
//   // Ocultar seção inteira (recursivo)
//   PanelGrid.Visible := False;
//
//   // Calcular "peso" total da árvore
//   Writeln('Peso total: ', Form.Calcular);  // soma recursiva
//
//   // Percorrer com visitor
//   PercorrerArvore(Form,
//     procedure(C: IUIComponent; L: Integer)
//     begin Writeln(StringOfChar('-', L*2), C.Nome); end);
// ---------------------------------------------------------------------------

end.

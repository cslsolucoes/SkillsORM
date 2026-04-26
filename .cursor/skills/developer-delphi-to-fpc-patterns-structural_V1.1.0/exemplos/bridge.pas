unit bridge;
{
  Bridge Pattern em Delphi — abstração (Shape) desacoplada de implementação (Renderer)
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Math;

// ---------------------------------------------------------------------------
// Implementação (Bridge) — como renderizar
// ---------------------------------------------------------------------------
type
  IRenderer = interface
  ['{BR000001-0000-0000-0000-000000000001}']
    procedure RenderCircle(X, Y, Raio: Double);
    procedure RenderRect(X, Y, W, H: Double);
    procedure RenderLine(X1, Y1, X2, Y2: Double);
    procedure RenderText(X, Y: Double; const ATexto: string);
    function  GetNome: string;
    property Nome: string read GetNome;
  end;

// ---------------------------------------------------------------------------
// Implementações concretas de renderização
// ---------------------------------------------------------------------------
type
  TConsoleRenderer = class(TInterfacedObject, IRenderer)
  public
    procedure RenderCircle(X, Y, Raio: Double);
    procedure RenderRect(X, Y, W, H: Double);
    procedure RenderLine(X1, Y1, X2, Y2: Double);
    procedure RenderText(X, Y: Double; const ATexto: string);
    function  GetNome: string;
  end;

  TSVG_Renderer = class(TInterfacedObject, IRenderer)
  private
    FSB: TStringBuilder;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RenderCircle(X, Y, Raio: Double);
    procedure RenderRect(X, Y, W, H: Double);
    procedure RenderLine(X1, Y1, X2, Y2: Double);
    procedure RenderText(X, Y: Double; const ATexto: string);
    function  GetNome: string;
    function  ObterSVG: string;
  end;

  TOpenGLRenderer = class(TInterfacedObject, IRenderer)
  public
    procedure RenderCircle(X, Y, Raio: Double);
    procedure RenderRect(X, Y, W, H: Double);
    procedure RenderLine(X1, Y1, X2, Y2: Double);
    procedure RenderText(X, Y: Double; const ATexto: string);
    function  GetNome: string;
  end;

// ---------------------------------------------------------------------------
// Abstração — o que desenhar (independente de como)
// ---------------------------------------------------------------------------
type
  TShape = class abstract
  protected
    FRenderer: IRenderer;
  public
    constructor Create(ARenderer: IRenderer);
    procedure Desenhar; virtual; abstract;
    procedure TrocarRenderer(ARenderer: IRenderer);
    function  GetDescricao: string; virtual; abstract;
  end;

// ---------------------------------------------------------------------------
// Abstrações refinadas — formas concretas
// ---------------------------------------------------------------------------
type
  TCirculo = class(TShape)
  private
    FX, FY, FRaio: Double;
  public
    constructor Create(ARenderer: IRenderer; X, Y, Raio: Double);
    procedure Desenhar; override;
    function  GetDescricao: string; override;
    function  Area: Double;
  end;

  TRetangulo = class(TShape)
  private
    FX, FY, FW, FH: Double;
  public
    constructor Create(ARenderer: IRenderer; X, Y, W, H: Double);
    procedure Desenhar; override;
    function  GetDescricao: string; override;
    function  Area: Double;
    function  Perimetro: Double;
  end;

  TLinha = class(TShape)
  private
    FX1, FY1, FX2, FY2: Double;
  public
    constructor Create(ARenderer: IRenderer; X1, Y1, X2, Y2: Double);
    procedure Desenhar; override;
    function  GetDescricao: string; override;
    function  Comprimento: Double;
  end;

  TTexto = class(TShape)
  private
    FX, FY: Double;
    FConteudo: string;
  public
    constructor Create(ARenderer: IRenderer; X, Y: Double; const AConteudo: string);
    procedure Desenhar; override;
    function  GetDescricao: string; override;
  end;

implementation

// ---------------------------------------------------------------------------
// TConsoleRenderer
// ---------------------------------------------------------------------------

procedure TConsoleRenderer.RenderCircle(X, Y, Raio: Double);
begin Writeln(Format('[Console] Círculo em (%.1f,%.1f) r=%.1f', [X, Y, Raio])); end;

procedure TConsoleRenderer.RenderRect(X, Y, W, H: Double);
begin Writeln(Format('[Console] Rect (%.1f,%.1f) %.1fx%.1f', [X, Y, W, H])); end;

procedure TConsoleRenderer.RenderLine(X1, Y1, X2, Y2: Double);
begin Writeln(Format('[Console] Linha (%.1f,%.1f)→(%.1f,%.1f)', [X1, Y1, X2, Y2])); end;

procedure TConsoleRenderer.RenderText(X, Y: Double; const ATexto: string);
begin Writeln(Format('[Console] Text (%.1f,%.1f) "%s"', [X, Y, ATexto])); end;

function TConsoleRenderer.GetNome: string;
begin Result := 'Console'; end;

// ---------------------------------------------------------------------------
// TSVG_Renderer
// ---------------------------------------------------------------------------

constructor TSVG_Renderer.Create;
begin inherited Create; FSB := TStringBuilder.Create;
  FSB.AppendLine('<svg xmlns="http://www.w3.org/2000/svg">'); end;

destructor TSVG_Renderer.Destroy;
begin FSB.Free; inherited; end;

procedure TSVG_Renderer.RenderCircle(X, Y, Raio: Double);
begin FSB.AppendLine(Format('<circle cx="%.1f" cy="%.1f" r="%.1f" fill="blue"/>',
  [X, Y, Raio])); end;

procedure TSVG_Renderer.RenderRect(X, Y, W, H: Double);
begin FSB.AppendLine(Format('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" fill="green"/>',
  [X, Y, W, H])); end;

procedure TSVG_Renderer.RenderLine(X1, Y1, X2, Y2: Double);
begin FSB.AppendLine(Format('<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="black"/>',
  [X1, Y1, X2, Y2])); end;

procedure TSVG_Renderer.RenderText(X, Y: Double; const ATexto: string);
begin FSB.AppendLine(Format('<text x="%.1f" y="%.1f">%s</text>', [X, Y, ATexto])); end;

function TSVG_Renderer.GetNome: string;
begin Result := 'SVG'; end;

function TSVG_Renderer.ObterSVG: string;
begin
  Result := FSB.ToString + '</svg>';
end;

// ---------------------------------------------------------------------------
// TOpenGLRenderer
// ---------------------------------------------------------------------------

procedure TOpenGLRenderer.RenderCircle(X, Y, Raio: Double);
begin Writeln(Format('[OpenGL] glCircle(%.1f, %.1f, %.1f)', [X, Y, Raio])); end;

procedure TOpenGLRenderer.RenderRect(X, Y, W, H: Double);
begin Writeln(Format('[OpenGL] glRect(%.1f, %.1f, %.1f, %.1f)', [X, Y, W, H])); end;

procedure TOpenGLRenderer.RenderLine(X1, Y1, X2, Y2: Double);
begin Writeln(Format('[OpenGL] glLine(%.1f,%.1f, %.1f,%.1f)', [X1, Y1, X2, Y2])); end;

procedure TOpenGLRenderer.RenderText(X, Y: Double; const ATexto: string);
begin Writeln(Format('[OpenGL] glText(%.1f, %.1f, "%s")', [X, Y, ATexto])); end;

function TOpenGLRenderer.GetNome: string;
begin Result := 'OpenGL'; end;

// ---------------------------------------------------------------------------
// TShape (base)
// ---------------------------------------------------------------------------

constructor TShape.Create(ARenderer: IRenderer);
begin inherited Create; FRenderer := ARenderer; end;

procedure TShape.TrocarRenderer(ARenderer: IRenderer);
begin FRenderer := ARenderer; end;

// ---------------------------------------------------------------------------
// TCirculo
// ---------------------------------------------------------------------------

constructor TCirculo.Create(ARenderer: IRenderer; X, Y, Raio: Double);
begin inherited Create(ARenderer); FX := X; FY := Y; FRaio := Raio; end;

procedure TCirculo.Desenhar;
begin FRenderer.RenderCircle(FX, FY, FRaio); end;

function TCirculo.GetDescricao: string;
begin Result := Format('Círculo[%.1f,%.1f r=%.1f]', [FX, FY, FRaio]); end;

function TCirculo.Area: Double;
begin Result := Pi * FRaio * FRaio; end;

// ---------------------------------------------------------------------------
// TRetangulo
// ---------------------------------------------------------------------------

constructor TRetangulo.Create(ARenderer: IRenderer; X, Y, W, H: Double);
begin inherited Create(ARenderer); FX := X; FY := Y; FW := W; FH := H; end;

procedure TRetangulo.Desenhar;
begin FRenderer.RenderRect(FX, FY, FW, FH); end;

function TRetangulo.GetDescricao: string;
begin Result := Format('Rect[%.1f,%.1f %.1fx%.1f]', [FX, FY, FW, FH]); end;

function TRetangulo.Area: Double;     begin Result := FW * FH; end;
function TRetangulo.Perimetro: Double; begin Result := 2 * (FW + FH); end;

// ---------------------------------------------------------------------------
// TLinha
// ---------------------------------------------------------------------------

constructor TLinha.Create(ARenderer: IRenderer; X1, Y1, X2, Y2: Double);
begin inherited Create(ARenderer); FX1 := X1; FY1 := Y1; FX2 := X2; FY2 := Y2; end;

procedure TLinha.Desenhar;
begin FRenderer.RenderLine(FX1, FY1, FX2, FY2); end;

function TLinha.GetDescricao: string;
begin Result := Format('Linha[(%.1f,%.1f)→(%.1f,%.1f)]', [FX1, FY1, FX2, FY2]); end;

function TLinha.Comprimento: Double;
begin Result := Sqrt(Sqr(FX2 - FX1) + Sqr(FY2 - FY1)); end;

// ---------------------------------------------------------------------------
// TTexto
// ---------------------------------------------------------------------------

constructor TTexto.Create(ARenderer: IRenderer; X, Y: Double; const AConteudo: string);
begin inherited Create(ARenderer); FX := X; FY := Y; FConteudo := AConteudo; end;

procedure TTexto.Desenhar;
begin FRenderer.RenderText(FX, FY, FConteudo); end;

function TTexto.GetDescricao: string;
begin Result := Format('Text[%.1f,%.1f "%s"]', [FX, FY, FConteudo]); end;

// ---------------------------------------------------------------------------
// USO:
//   // Mesmo código de abstração, renderers trocados livremente
//   var ConsR := TConsoleRenderer.Create;
//   var SVGR  := TSVG_Renderer.Create;
//   var GLRR  := TOpenGLRenderer.Create;
//
//   var C := TCirculo.Create(ConsR, 100, 100, 50);
//   C.Desenhar;     // [Console] Círculo em (100.0,100.0) r=50.0
//   C.TrocarRenderer(SVGR);
//   C.Desenhar;     // <circle cx="100.0" cy="100.0" r="50.0"/>
//   C.TrocarRenderer(GLRR);
//   C.Desenhar;     // [OpenGL] glCircle(100.0, 100.0, 50.0)
//
//   // Área independente do renderer
//   Writeln(Format('Área: %.2f', [C.Area]));  // 7853.98
//
//   // Mesma forma, 3 renderers sem alterar TCirculo
//   var R := TRetangulo.Create(SVGR, 10, 20, 200, 100);
//   R.Desenhar;
//   Writeln(TSVG_Renderer(SVGR).ObterSVG);
// ---------------------------------------------------------------------------

end.

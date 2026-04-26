unit drag_sem_titlebar;
{
  EXEMPLO: Drag de TForm sem titlebar (FMX / GestorERP)
  Compilavel: dcc32 / dcc64
  Demonstra:
    - Form sem borda (BorderStyle = bsNone)
    - Arrastar pelo header via MouseDown + MouseMove
    - Funciona em Windows, macOS, iOS, Android
    - Snap nas bordas da tela (opcional)
}

interface

uses
  System.SysUtils, System.Classes, System.Types,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Platform,
  FMX.Layouts, FMX.StdCtrls, FMX.Objects, FMX.Graphics;

type
  TFrmSemTitlebar = class(TForm)
  private
    // Componentes do header
    RecHeader  : TRectangle;
    LblTitulo  : TLabel;
    BtnFechar  : TButton;
    BtnMinimizar: TButton;

    // Variaveis de controle do drag
    FDragAtivo: Boolean;
    FDragPos  : TPointF;

    // --- Handlers do header ---
    procedure HeaderMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure HeaderMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Single);
    procedure HeaderMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);

    // --- Handlers dos botoes ---
    procedure BtnFecharClick(Sender: TObject);
    procedure BtnMinimizarClick(Sender: TObject);

    procedure ConstruirLayout;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

constructor TFrmSemTitlebar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  // Remover barra de titulo nativa do SO
  BorderStyle := TFmxFormBorderStyle.None;

  // Dimensoes
  Width  := 480;
  Height := 320;

  // Centralizar na tela
  Position := TFormPosition.ScreenCenter;

  // Fundo do form
  Fill.Color := $FFF0F0F0;

  ConstruirLayout;
end;

procedure TFrmSemTitlebar.ConstruirLayout;
var
  RecCorpo: TRectangle;
begin
  // Header: area de drag + titulo + botoes
  RecHeader := TRectangle.Create(Self);
  RecHeader.Parent := Self;
  RecHeader.Align  := TAlignLayout.Top;
  RecHeader.Height := 40;
  RecHeader.Fill.Color  := $FF2C3E50;
  RecHeader.Stroke.Kind := TBrushKind.None;
  RecHeader.Cursor      := crSizeAll; // cursor de mover
  RecHeader.Padding.Rect := TRectF.Create(8, 0, 8, 0);

  // Eventos de drag no header
  RecHeader.OnMouseDown := HeaderMouseDown;
  RecHeader.OnMouseMove := HeaderMouseMove;
  RecHeader.OnMouseUp   := HeaderMouseUp;

  // Titulo
  LblTitulo := TLabel.Create(Self);
  LblTitulo.Parent := RecHeader;
  LblTitulo.Align  := TAlignLayout.Client;
  LblTitulo.Text   := 'GestorERP';
  LblTitulo.TextSettings.FontColor    := $FFFFFFFF;
  LblTitulo.TextSettings.Font.Size    := 13;
  LblTitulo.TextSettings.Font.Style   := [TFontStyle.fsBold];
  LblTitulo.TextSettings.HorzAlign    := TTextAlign.Leading;
  // Nao capturar eventos no label — passa para o RecHeader
  LblTitulo.HitTest := False;

  // Botao fechar
  BtnFechar := TButton.Create(Self);
  BtnFechar.Parent  := RecHeader;
  BtnFechar.Align   := TAlignLayout.Right;
  BtnFechar.Width   := 32;
  BtnFechar.Text    := 'X';
  BtnFechar.OnClick := BtnFecharClick;
  BtnFechar.StyleLookup := 'clearbuttonStyle'; // sem borda

  // Botao minimizar
  BtnMinimizar := TButton.Create(Self);
  BtnMinimizar.Parent  := RecHeader;
  BtnMinimizar.Align   := TAlignLayout.Right;
  BtnMinimizar.Width   := 32;
  BtnMinimizar.Text    := '_';
  BtnMinimizar.Margins.Right := 2;
  BtnMinimizar.OnClick := BtnMinimizarClick;

  // Corpo do form
  RecCorpo := TRectangle.Create(Self);
  RecCorpo.Parent := Self;
  RecCorpo.Align  := TAlignLayout.Client;
  RecCorpo.Fill.Color  := $FFFFFFFF;
  RecCorpo.Stroke.Kind := TBrushKind.None;
  RecCorpo.Padding.Rect := TRectF.Create(16, 16, 16, 16);
end;

procedure TFrmSemTitlebar.HeaderMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Button <> TMouseButton.mbLeft then Exit;
  FDragAtivo := True;
  // Guardar posicao relativa ao header onde o mouse clicou
  FDragPos := TPointF.Create(X, Y);
end;

procedure TFrmSemTitlebar.HeaderMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
begin
  if not FDragAtivo then Exit;
  if not (ssLeft in Shift) then
  begin
    FDragAtivo := False;
    Exit;
  end;

  // Deslocar o form
  Left := Left + Round(X - FDragPos.X);
  Top  := Top  + Round(Y - FDragPos.Y);

  // Opcional: manter dentro da tela
  if Left < 0 then Left := 0;
  if Top  < 0 then Top  := 0;
end;

procedure TFrmSemTitlebar.HeaderMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  FDragAtivo := False;
end;

procedure TFrmSemTitlebar.BtnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmSemTitlebar.BtnMinimizarClick(Sender: TObject);
begin
  // WindowState := TWindowState.wsMinimized; — disponivel em Windows/Mac
  {$IFDEF MSWINDOWS}
  WindowState := TWindowState.wsMinimized;
  {$ENDIF}
end;

end.

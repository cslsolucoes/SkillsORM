unit TEMPLATE_drag_form;
{
  TEMPLATE: Form draggavel sem titlebar (FMX / GestorERP)
  Uso: copie e renomeie. Substitua TFrmDragTemplate pelo nome do seu form.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Layouts, FMX.StdCtrls, FMX.Objects;

type
  TFrmDragTemplate = class(TForm)
  private
    // --- Header draggavel ---
    FRecHeader : TRectangle;
    FLblTitulo : TLabel;
    FBtnFechar : TButton;

    // --- Area de conteudo ---
    FRecConteudo: TRectangle;

    // --- Controle de drag ---
    FDragAtivo: Boolean;
    FDragPos  : TPointF;

    procedure ConstruirLayout;
    procedure ConfigurarForm;

    procedure HeaderMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure HeaderMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure HeaderMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure BtnFecharClick(Sender: TObject);

  protected
    // Subclasse preenche a area de conteudo
    property AreaConteudo: TRectangle read FRecConteudo;

  public
    constructor Create(AOwner: TComponent); override;

    // Alterar titulo do header
    procedure SetTitulo(const ATitulo: string);
  end;

implementation

constructor TFrmDragTemplate.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ConfigurarForm;
  ConstruirLayout;
end;

procedure TFrmDragTemplate.ConfigurarForm;
begin
  BorderStyle   := TFmxFormBorderStyle.None;
  Position      := TFormPosition.ScreenCenter;
  Width         := 520;
  Height        := 380;
  Fill.Color    := $FFFFFFFF;
  Transparency  := False;
end;

procedure TFrmDragTemplate.ConstruirLayout;
begin
  // Header
  FRecHeader := TRectangle.Create(Self);
  FRecHeader.Parent := Self;
  FRecHeader.Align  := TAlignLayout.Top;
  FRecHeader.Height := 44;
  FRecHeader.Fill.Color  := $FF2C3E50;
  FRecHeader.Stroke.Kind := TBrushKind.None;
  FRecHeader.Padding.Rect := TRectF.Create(12, 0, 4, 0);
  FRecHeader.Cursor := crSizeAll;

  FRecHeader.OnMouseDown := HeaderMouseDown;
  FRecHeader.OnMouseMove := HeaderMouseMove;
  FRecHeader.OnMouseUp   := HeaderMouseUp;

  // Titulo
  FLblTitulo := TLabel.Create(Self);
  FLblTitulo.Parent := FRecHeader;
  FLblTitulo.Align  := TAlignLayout.Client;
  FLblTitulo.Text   := 'Titulo do Form';
  FLblTitulo.TextSettings.FontColor  := $FFFFFFFF;
  FLblTitulo.TextSettings.Font.Size  := 13;
  FLblTitulo.TextSettings.Font.Style := [TFontStyle.fsBold];
  FLblTitulo.TextSettings.HorzAlign  := TTextAlign.Leading;
  FLblTitulo.HitTest := False;

  // Botao fechar
  FBtnFechar := TButton.Create(Self);
  FBtnFechar.Parent  := FRecHeader;
  FBtnFechar.Align   := TAlignLayout.Right;
  FBtnFechar.Width   := 36;
  FBtnFechar.Text    := 'x';
  FBtnFechar.StyleLookup := 'clearbuttonStyle';
  FBtnFechar.OnClick := BtnFecharClick;

  // Conteudo
  FRecConteudo := TRectangle.Create(Self);
  FRecConteudo.Parent := Self;
  FRecConteudo.Align  := TAlignLayout.Client;
  FRecConteudo.Fill.Color  := $FFFFFFFF;
  FRecConteudo.Stroke.Kind := TBrushKind.None;
  FRecConteudo.Padding.Rect := TRectF.Create(20, 20, 20, 20);
end;

procedure TFrmDragTemplate.SetTitulo(const ATitulo: string);
begin
  FLblTitulo.Text := ATitulo;
end;

procedure TFrmDragTemplate.HeaderMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Button <> TMouseButton.mbLeft then Exit;
  FDragAtivo := True;
  FDragPos   := TPointF.Create(X, Y);
end;

procedure TFrmDragTemplate.HeaderMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
begin
  if not FDragAtivo then Exit;
  if not (ssLeft in Shift) then
  begin
    FDragAtivo := False;
    Exit;
  end;
  Left := Left + Round(X - FDragPos.X);
  Top  := Top  + Round(Y - FDragPos.Y);
  if Left < 0 then Left := 0;
  if Top  < 0 then Top  := 0;
end;

procedure TFrmDragTemplate.HeaderMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  FDragAtivo := False;
end;

procedure TFrmDragTemplate.BtnFecharClick(Sender: TObject);
begin
  Close;
end;

end.

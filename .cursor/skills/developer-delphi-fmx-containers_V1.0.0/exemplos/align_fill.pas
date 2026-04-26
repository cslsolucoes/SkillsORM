unit align_fill;
// Exemplo: todos os valores de TAlignLayout com Fill e Stroke
// Mostra comportamento visual de cada Align em runtime

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Layouts, FMX.StdCtrls,
  FMX.Types, System.UITypes;

type
  TFormAlignFill = class(TForm)
  private
    procedure DemonstrarAligns;
    procedure DemonstrarFills;
    procedure DemonstrarStrokes;
    function CriarRect(AParent: TControl; AAlign: TAlignLayout;
      AColor: TAlphaColor; const ALegenda: string): TRectangle;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

constructor TFormAlignFill.Create(AOwner: TComponent);
begin
  inherited;
  DemonstrarAligns;
  DemonstrarFills;
  DemonstrarStrokes;
end;

function TFormAlignFill.CriarRect(AParent: TControl; AAlign: TAlignLayout;
  AColor: TAlphaColor; const ALegenda: string): TRectangle;
var Lbl: TLabel;
begin
  Result := TRectangle.Create(Self);
  Result.Parent := AParent;
  Result.Align  := AAlign;
  Result.Fill.Color := AColor;
  Result.Stroke.Kind := TBrushKind.None;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Result;
  Lbl.Align  := TAlignLayout.Client;
  Lbl.Text   := ALegenda;
  Lbl.TextSettings.FontColor := $FFFFFFFF;
  Lbl.TextSettings.HorzAlign := TTextAlign.Center;
  Lbl.TextSettings.VertAlign := TTextAlign.Center;
  Lbl.AutoSize := False;
end;

procedure TFormAlignFill.DemonstrarAligns;
var RecFundo: TRectangle;
begin
  // Container principal
  RecFundo := TRectangle.Create(Self);
  RecFundo.Parent := Self;
  RecFundo.Align  := TAlignLayout.Client;
  RecFundo.Fill.Color := $FFF0F0F0;
  RecFundo.Stroke.Kind := TBrushKind.None;

  // Top: header fixo
  with CriarRect(RecFundo, TAlignLayout.Top, $FF2C3E50, 'Top (Header)') do
    Height := 60;

  // Bottom: footer fixo
  with CriarRect(RecFundo, TAlignLayout.Bottom, $FF27AE60, 'Bottom (Footer)') do
    Height := 50;

  // Left: sidebar
  with CriarRect(RecFundo, TAlignLayout.Left, $FF8E44AD, 'Left (Sidebar)') do
    Width := 120;

  // Client: ocupa o restante
  CriarRect(RecFundo, TAlignLayout.Client, $FF3498DB, 'Client (Conteúdo)');
end;

procedure TFormAlignFill.DemonstrarFills;
var RecDemo, RecGrad, RecNone: TRectangle;
begin
  // Gradiente diagonal
  RecGrad := TRectangle.Create(Self);
  RecGrad.Parent := Self;
  RecGrad.Position.X := 10; RecGrad.Position.Y := 200;
  RecGrad.Width := 150; RecGrad.Height := 80;
  RecGrad.Fill.Kind := TBrushKind.Gradient;
  RecGrad.Fill.Gradient.Style := TGradientStyle.Linear;
  RecGrad.Fill.Gradient.Points[0].Color  := $FF1ABC9C;
  RecGrad.Fill.Gradient.Points[0].Offset := 0;
  RecGrad.Fill.Gradient.Points[1].Color  := $FF2980B9;
  RecGrad.Fill.Gradient.Points[1].Offset := 1;
  RecGrad.Fill.Gradient.StartPosition.X := 0;
  RecGrad.Fill.Gradient.StartPosition.Y := 0;
  RecGrad.Fill.Gradient.StopPosition.X  := 1;
  RecGrad.Fill.Gradient.StopPosition.Y  := 1;
  RecGrad.Stroke.Kind := TBrushKind.None;
  RecGrad.XRadius := 8; RecGrad.YRadius := 8;

  // Sem preenchimento (transparente)
  RecNone := TRectangle.Create(Self);
  RecNone.Parent := Self;
  RecNone.Position.X := 170; RecNone.Position.Y := 200;
  RecNone.Width := 150; RecNone.Height := 80;
  RecNone.Fill.Kind := TBrushKind.None;
  RecNone.Stroke.Kind := TBrushKind.Solid;
  RecNone.Stroke.Color := $FF3498DB;
  RecNone.Stroke.Thickness := 2;
  RecNone.XRadius := 8; RecNone.YRadius := 8;
end;

procedure TFormAlignFill.DemonstrarStrokes;
var Rec: TRectangle;
begin
  // Borda tracejada
  Rec := TRectangle.Create(Self);
  Rec.Parent := Self;
  Rec.Position.X := 10; Rec.Position.Y := 300;
  Rec.Width := 150; Rec.Height := 60;
  Rec.Fill.Kind := TBrushKind.None;
  Rec.Stroke.Kind  := TBrushKind.Solid;
  Rec.Stroke.Color := $FFE74C3C;
  Rec.Stroke.Thickness := 1.5;
  Rec.Stroke.Dash  := TStrokeDash.Dash;
  Rec.XRadius := 6; Rec.YRadius := 6;
end;

end.

unit hover_animation;
// Exemplo: hover card completo com color + scale animation

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Layouts, FMX.StdCtrls,
  FMX.Ani, FMX.Types, System.UITypes;

type
  TFormHoverAnimation = class(TForm)
  private
    procedure CriarCards;
    function CriarCardHover(AX, AY: Single; const ATitulo, ADesc: string;
      ACor: TAlphaColor): TRectangle;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

constructor TFormHoverAnimation.Create(AOwner: TComponent);
begin
  inherited;
  CriarCards;
end;

procedure TFormHoverAnimation.CriarCards;
begin
  CriarCardHover(16,  16, 'Dashboard', 'Visão geral do sistema', $FF3498DB);
  CriarCardHover(216, 16, 'Clientes',  'Gestão de clientes',     $FF27AE60);
  CriarCardHover(416, 16, 'Relatórios','Análises e gráficos',    $FFE74C3C);
end;

function TFormHoverAnimation.CriarCardHover(AX, AY: Single;
  const ATitulo, ADesc: string; ACor: TAlphaColor): TRectangle;
var
  RecCard, RecIcone: TRectangle;
  LblTitulo, LblDesc: TLabel;
begin
  RecCard := TRectangle.Create(Self);
  RecCard.Parent := Self;
  RecCard.Position.X := AX;
  RecCard.Position.Y := AY;
  RecCard.Width  := 180;
  RecCard.Height := 120;
  RecCard.Fill.Color := $FFFFFFFF;
  RecCard.Stroke.Kind := TBrushKind.Solid;
  RecCard.Stroke.Color := $FFE8E8E8;
  RecCard.Stroke.Thickness := 1;
  RecCard.XRadius := 12; RecCard.YRadius := 12;
  RecCard.ClipChildren := False; // para sombra funcionar
  RecCard.Cursor := crHandPoint;

  // Padding interno
  RecCard.Padding.Left   := 16;
  RecCard.Padding.Top    := 16;
  RecCard.Padding.Right  := 16;
  RecCard.Padding.Bottom := 16;

  // Ícone colorido
  RecIcone := TRectangle.Create(Self);
  RecIcone.Parent := RecCard;
  RecIcone.Align  := TAlignLayout.Top;
  RecIcone.Height := 36;
  RecIcone.Width  := 36;
  RecIcone.Align  := TAlignLayout.None;
  RecIcone.Position.X := 0;
  RecIcone.Position.Y := 0;
  RecIcone.Fill.Color := ACor;
  RecIcone.Stroke.Kind := TBrushKind.None;
  RecIcone.XRadius := 8; RecIcone.YRadius := 8;
  RecIcone.Width  := 36;
  RecIcone.Height := 36;

  LblTitulo := TLabel.Create(Self);
  LblTitulo.Parent := RecCard;
  LblTitulo.Position.X := 0;
  LblTitulo.Position.Y := 44;
  LblTitulo.Width  := RecCard.Width - 32;
  LblTitulo.Height := 22;
  LblTitulo.Text   := ATitulo;
  LblTitulo.TextSettings.Font.Size  := 14;
  LblTitulo.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblTitulo.TextSettings.FontColor  := $FF333333;
  LblTitulo.AutoSize := False;

  LblDesc := TLabel.Create(Self);
  LblDesc.Parent := RecCard;
  LblDesc.Position.X := 0;
  LblDesc.Position.Y := 68;
  LblDesc.Width  := RecCard.Width - 32;
  LblDesc.Height := 16;
  LblDesc.Text   := ADesc;
  LblDesc.TextSettings.Font.Size := 11;
  LblDesc.TextSettings.FontColor := $FF999999;
  LblDesc.AutoSize := False;

  // ============================================================
  // HOVER: cor + escala + stroke
  // ============================================================
  RecCard.OnMouseEnter := procedure(Sender: TObject)
  var Card: TRectangle;
  begin
    Card := Sender as TRectangle;
    // Fundo levemente colorido
    TAnimator.AnimateColor(Card, 'Fill.Color', $FFF0F7FF, 0.15);
    // Borda da cor do card
    TAnimator.AnimateColor(Card, 'Stroke.Color', ACor, 0.15);
    // Scale up sutil (1.0 → 1.03)
    TAnimator.AnimateFloat(Card, 'Scale.X', 1.03, 0.15,
      TAnimationType.Out, TInterpolationType.Back);
    TAnimator.AnimateFloat(Card, 'Scale.Y', 1.03, 0.15,
      TAnimationType.Out, TInterpolationType.Back);
  end;

  RecCard.OnMouseLeave := procedure(Sender: TObject)
  var Card: TRectangle;
  begin
    Card := Sender as TRectangle;
    // Voltar ao estado original
    TAnimator.AnimateColor(Card, 'Fill.Color', $FFFFFFFF, 0.15);
    TAnimator.AnimateColor(Card, 'Stroke.Color', $FFE8E8E8, 0.15);
    TAnimator.AnimateFloat(Card, 'Scale.X', 1.0, 0.15,
      TAnimationType.Out, TInterpolationType.Cubic);
    TAnimator.AnimateFloat(Card, 'Scale.Y', 1.0, 0.15,
      TAnimationType.Out, TInterpolationType.Cubic);
  end;

  // Click: flash de cor para feedback
  RecCard.OnClick := procedure(Sender: TObject)
  var Card: TRectangle;
  begin
    Card := Sender as TRectangle;
    TAnimator.AnimateColor(Card, 'Fill.Color', ACor, 0.08);
    TAnimator.AnimateColorDelay(Card, 'Fill.Color', $FFF0F7FF, 0.15, 0.1);
  end;

  Result := RecCard;
end;

end.

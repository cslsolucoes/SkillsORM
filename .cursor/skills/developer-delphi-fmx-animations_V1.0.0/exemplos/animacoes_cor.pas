unit animacoes_cor;
// Exemplo: TColorAnimation, hover color, estado ativo

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Layouts, FMX.StdCtrls,
  FMX.Ani, FMX.Types, System.UITypes;

type
  TFormAnimacoesCor = class(TForm)
  private
    procedure DemoHoverCard;
    procedure DemoBotaoEstado;
    procedure DemoColorAnimation;
    function CriarCard(ACor: TAlphaColor; AX, AY: Single): TRectangle;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

constructor TFormAnimacoesCor.Create(AOwner: TComponent);
begin
  inherited;
  DemoHoverCard;
  DemoBotaoEstado;
  DemoColorAnimation;
end;

function TFormAnimacoesCor.CriarCard(ACor: TAlphaColor; AX, AY: Single): TRectangle;
begin
  Result := TRectangle.Create(Self);
  Result.Parent := Self;
  Result.Position.X := AX;
  Result.Position.Y := AY;
  Result.Width  := 180;
  Result.Height := 80;
  Result.Fill.Color := ACor;
  Result.Stroke.Kind := TBrushKind.None;
  Result.XRadius := 8; Result.YRadius := 8;
  Result.Cursor := crHandPoint;
end;

procedure TFormAnimacoesCor.DemoHoverCard;
var
  RecCard: TRectangle;
  COR_NORMAL: TAlphaColor;
  COR_HOVER: TAlphaColor;
begin
  COR_NORMAL := $FFFFFFFF;
  COR_HOVER  := $FFE8F4FD;

  RecCard := CriarCard(COR_NORMAL, 16, 16);
  RecCard.Stroke.Kind := TBrushKind.Solid;
  RecCard.Stroke.Color := $FFD0D0D0;

  // Hover: animar cor de fundo ao passar o mouse
  RecCard.OnMouseEnter := procedure(Sender: TObject)
  begin
    TAnimator.AnimateColor(Sender as TControl, 'Fill.Color', COR_HOVER, 0.15);
    TAnimator.AnimateColor(Sender as TControl, 'Stroke.Color', $FF3498DB, 0.15);
  end;

  RecCard.OnMouseLeave := procedure(Sender: TObject)
  begin
    TAnimator.AnimateColor(Sender as TControl, 'Fill.Color', COR_NORMAL, 0.15);
    TAnimator.AnimateColor(Sender as TControl, 'Stroke.Color', $FFD0D0D0, 0.15);
  end;
end;

procedure TFormAnimacoesCor.DemoBotaoEstado;
var
  RecBotao: TRectangle;
  LblBotao: TLabel;
  FAtivo: Boolean;
begin
  FAtivo := False;

  RecBotao := CriarCard($FF3498DB, 216, 16);
  RecBotao.Width := 120;

  LblBotao := TLabel.Create(Self);
  LblBotao.Parent := RecBotao;
  LblBotao.Align  := TAlignLayout.Client;
  LblBotao.Text   := 'Inativo';
  LblBotao.TextSettings.FontColor := $FFFFFFFF;
  LblBotao.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblBotao.TextSettings.HorzAlign := TTextAlign.Center;
  LblBotao.TextSettings.VertAlign := TTextAlign.Center;
  LblBotao.AutoSize := False;

  // Toggle de estado com animação de cor
  RecBotao.OnClick := procedure(Sender: TObject)
  begin
    FAtivo := not FAtivo;
    if FAtivo then
    begin
      TAnimator.AnimateColor(RecBotao, 'Fill.Color', $FF27AE60, 0.2);
      LblBotao.Text := 'Ativo';
    end
    else
    begin
      TAnimator.AnimateColor(RecBotao, 'Fill.Color', $FF3498DB, 0.2);
      LblBotao.Text := 'Inativo';
    end;
  end;
end;

procedure TFormAnimacoesCor.DemoColorAnimation;
var
  RecAnim: TRectangle;
  AnimCor: TColorAnimation;
begin
  // TColorAnimation declarativo — anima em loop entre duas cores
  RecAnim := CriarCard($FFFF6B6B, 16, 110);

  AnimCor := TColorAnimation.Create(RecAnim);
  AnimCor.Parent       := RecAnim;      // pai = componente que anima
  AnimCor.PropertyName := 'Fill.Color';
  AnimCor.StartValue   := $FFFF6B6B;    // vermelho
  AnimCor.StopValue    := $FF4ECDC4;    // turquesa
  AnimCor.Duration     := 1.5;
  AnimCor.Loop         := True;
  AnimCor.AutoReverse  := True;         // vai e volta automaticamente
  AnimCor.Interpolation := TInterpolationType.Sinusoidal;
  AnimCor.AnimationType := TAnimationType.InOut;
  AnimCor.Start;
end;

end.

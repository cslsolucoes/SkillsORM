unit TEMPLATE_hover_card;
// TEMPLATE: Card completo com hover (color + scale) pronto para uso

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Layouts, FMX.StdCtrls,
  FMX.Ani, FMX.Types, System.UITypes;

// ============================================================
// FUNÇÃO: CriarCardHover
// Cria um TRectangle card com animações de hover integradas
//
// Parâmetros:
//   AOwner         — dono dos componentes
//   AParent        — container pai
//   AX, AY, AW, AH — posição e tamanho
//   ACorFundo      — cor de fundo normal
//   ACorHover      — cor de fundo no hover (nil = calcular automaticamente)
//   ACorBorda      — cor da borda no hover
//   AEscalaHover   — fator de escala no hover (ex: 1.02)
// ============================================================

type
  TCardHoverConfig = record
    CorFundoNormal: TAlphaColor;
    CorFundoHover: TAlphaColor;
    CorBordaNormal: TAlphaColor;
    CorBordaHover: TAlphaColor;
    EscalaHover: Single;
    DuracaoMs: Single; // duração em segundos
  end;

function ConfigCardPadrao: TCardHoverConfig;

function CriarCardHover(AOwner: TComponent; AParent: TControl;
  AX, AY, AW, AH: Single;
  const AConfig: TCardHoverConfig): TRectangle;

// Aplica hover em card já existente
procedure AplicarHover(ACard: TRectangle; const AConfig: TCardHoverConfig);

implementation

function ConfigCardPadrao: TCardHoverConfig;
begin
  Result.CorFundoNormal := $FFFFFFFF;
  Result.CorFundoHover  := $FFF0F7FF;
  Result.CorBordaNormal := $FFE8E8E8;
  Result.CorBordaHover  := $FF3498DB;
  Result.EscalaHover    := 1.025;
  Result.DuracaoMs      := 0.15;
end;

procedure AplicarHover(ACard: TRectangle; const AConfig: TCardHoverConfig);
begin
  // Garantir que stroke está configurado para animação funcionar
  if ACard.Stroke.Kind = TBrushKind.None then
  begin
    ACard.Stroke.Kind  := TBrushKind.Solid;
    ACard.Stroke.Color := AConfig.CorBordaNormal;
    ACard.Stroke.Thickness := 1;
  end;

  // ClipChildren=False é necessário para Scale não cortar sombra
  ACard.ClipChildren := False;

  ACard.OnMouseEnter := procedure(Sender: TObject)
  var C: TRectangle;
  begin
    C := Sender as TRectangle;
    TAnimator.AnimateColor(C, 'Fill.Color', AConfig.CorFundoHover, AConfig.DuracaoMs);
    TAnimator.AnimateColor(C, 'Stroke.Color', AConfig.CorBordaHover, AConfig.DuracaoMs);
    if AConfig.EscalaHover <> 1.0 then
    begin
      TAnimator.AnimateFloat(C, 'Scale.X', AConfig.EscalaHover, AConfig.DuracaoMs,
        TAnimationType.Out, TInterpolationType.Back);
      TAnimator.AnimateFloat(C, 'Scale.Y', AConfig.EscalaHover, AConfig.DuracaoMs,
        TAnimationType.Out, TInterpolationType.Back);
    end;
  end;

  ACard.OnMouseLeave := procedure(Sender: TObject)
  var C: TRectangle;
  begin
    C := Sender as TRectangle;
    TAnimator.AnimateColor(C, 'Fill.Color', AConfig.CorFundoNormal, AConfig.DuracaoMs);
    TAnimator.AnimateColor(C, 'Stroke.Color', AConfig.CorBordaNormal, AConfig.DuracaoMs);
    if AConfig.EscalaHover <> 1.0 then
    begin
      TAnimator.AnimateFloat(C, 'Scale.X', 1.0, AConfig.DuracaoMs,
        TAnimationType.Out, TInterpolationType.Cubic);
      TAnimator.AnimateFloat(C, 'Scale.Y', 1.0, AConfig.DuracaoMs,
        TAnimationType.Out, TInterpolationType.Cubic);
    end;
  end;

  // Feedback de clique: flash
  ACard.OnClick := procedure(Sender: TObject)
  var C: TRectangle;
  begin
    C := Sender as TRectangle;
    TAnimator.AnimateColor(C, 'Fill.Color', AConfig.CorBordaHover, 0.06);
    TAnimator.AnimateColorDelay(C, 'Fill.Color', AConfig.CorFundoHover,
      AConfig.DuracaoMs, 0.08);
  end;
end;

function CriarCardHover(AOwner: TComponent; AParent: TControl;
  AX, AY, AW, AH: Single;
  const AConfig: TCardHoverConfig): TRectangle;
begin
  Result := TRectangle.Create(AOwner);
  Result.Parent := AParent;
  Result.Position.X := AX;
  Result.Position.Y := AY;
  Result.Width  := AW;
  Result.Height := AH;
  Result.Fill.Color := AConfig.CorFundoNormal;
  Result.Stroke.Kind  := TBrushKind.Solid;
  Result.Stroke.Color := AConfig.CorBordaNormal;
  Result.Stroke.Thickness := 1;
  Result.XRadius := 12; Result.YRadius := 12;
  Result.Cursor := crHandPoint;

  // Padding padrão
  Result.Padding.Left   := 16;
  Result.Padding.Top    := 16;
  Result.Padding.Right  := 16;
  Result.Padding.Bottom := 16;

  AplicarHover(Result, AConfig);
end;

// ============================================================
// EXEMPLO DE USO:
//
// var Config := ConfigCardPadrao;
// Config.CorBordaHover := $FF27AE60; // verde no hover
//
// var Card := CriarCardHover(Self, RecBody, 16, 16, 200, 120, Config);
// // Adicionar conteúdo dentro de Card...
//
// // Ou aplicar hover em card já existente:
// AplicarHover(RecCardExistente, ConfigCardPadrao);
// ============================================================

end.

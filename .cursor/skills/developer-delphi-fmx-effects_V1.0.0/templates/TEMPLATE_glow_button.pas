unit TEMPLATE_glow_button;
// TEMPLATE: Botão com TGlowEffect + animação no hover e clique

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Effects,
  FMX.Ani, FMX.Types, System.UITypes;

// Configura botão retangular com glow animado
// ABtn      = TRectangle que age como botão
// AGlowColor = cor do glow (padrão: azul primário)
procedure ConfigurarBotaoGlow(ABtn: TRectangle;
  AGlowColor: TAlphaColor = $FF3498DB);

// Configurar botão de ação crítica (vermelho — ex: deletar)
procedure ConfigurarBotaoGlowCritico(ABtn: TRectangle);

// Configurar botão de sucesso (verde — ex: salvar)
procedure ConfigurarBotaoGlowSucesso(ABtn: TRectangle);

implementation

procedure ConfigurarBotaoGlow(ABtn: TRectangle; AGlowColor: TAlphaColor);
var
  Glow  : TGlowEffect;
  IGlow : TInnerGlowEffect;
begin
  ABtn.ClipChildren := False;
  ABtn.Cursor       := crHandPoint;

  // 1. Glow externo — invisível em repouso
  Glow := TGlowEffect.Create(ABtn);
  Glow.Parent    := ABtn;
  Glow.GlowColor := AGlowColor;
  Glow.Softness  := 0;

  // 2. Inner glow sutil sempre presente (botão "brilhante")
  IGlow := TInnerGlowEffect.Create(ABtn);
  IGlow.Parent    := ABtn;
  IGlow.GlowColor := AGlowColor;
  IGlow.Softness  := 3; // sutil

  // HOVER: acende o glow externo
  ABtn.OnMouseEnter := procedure(Sender: TObject)
  begin
    TAnimator.AnimateFloat(Glow, 'Softness', 8, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
    TAnimator.AnimateFloat(IGlow, 'Softness', 6, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
  end;

  // MOUSE LEAVE: apaga o glow externo, volta inner glow sutil
  ABtn.OnMouseLeave := procedure(Sender: TObject)
  begin
    TAnimator.AnimateFloat(Glow, 'Softness', 0, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
    TAnimator.AnimateFloat(IGlow, 'Softness', 3, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
  end;

  // CLIQUE: pulso de glow intenso + retorno
  ABtn.OnMouseDown := procedure(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Single)
  begin
    TAnimator.StopAnimation(Glow, 'Softness');
    TAnimator.AnimateFloat(Glow, 'Softness', 14, 0.10,
      TAnimationType.Out, TInterpolationType.Cubic);
  end;

  ABtn.OnMouseUp := procedure(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Single)
  begin
    // Retornar ao estado de hover (mouse ainda sobre o botão)
    TAnimator.AnimateFloat(Glow, 'Softness', 8, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
  end;
end;

procedure ConfigurarBotaoGlowCritico(ABtn: TRectangle);
begin
  // Vermelho — deletar, desativar, ação irreversível
  ConfigurarBotaoGlow(ABtn, $FFE74C3C);
end;

procedure ConfigurarBotaoGlowSucesso(ABtn: TRectangle);
begin
  // Verde — salvar, confirmar, aprovar
  ConfigurarBotaoGlow(ABtn, $FF27AE60);
end;

// ============================================================
// USO:
//
// procedure TFormPrincipal.FormCreate(Sender: TObject);
// begin
//   ConfigurarBotaoGlow(RecBtnSalvar);              // azul padrão
//   ConfigurarBotaoGlowSucesso(RecBtnConfirmar);    // verde
//   ConfigurarBotaoGlowCritico(RecBtnDeletar);      // vermelho
//   ConfigurarBotaoGlow(RecBtnPremium, $FFD4AC0D);  // dourado
// end;
//
// REQUISITO no .fmx (ou antes de chamar):
//   RecBtnSalvar.XRadius := 8; RecBtnSalvar.YRadius := 8;
//   RecBtnSalvar.Fill.Color := $FF3498DB;   // mesma cor do glow
//   RecBtnSalvar.HitTest := True;
//
// DICA DE COR:
//   Usar a mesma cor no Fill.Color do botão e no GlowColor
//   para o efeito mais coeso. O glow "emana" da cor do botão.
//
// DESATIVAR GLOW (ex: botão disabled):
//   Glow.Enabled := False;
//   ABtn.Opacity := 0.4; // visual de desabilitado
// ============================================================

end.

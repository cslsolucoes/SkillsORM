unit shadow_effect;
// TShadowEffect em runtime: criar, configurar e animar sombra de cards FMX

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Effects,
  FMX.Ani, FMX.Types, System.UITypes;

// Adiciona sombra padrão a qualquer TControl
function AdicionarSombra(AControl: TControl;
  ASoftness: Single = 0.3;
  ADistance: Single = 4;
  ADirection: Single = 315;
  AColor: TAlphaColor = $40000000): TShadowEffect;

// Anima sombra no hover (cresce ao entrar, diminui ao sair)
procedure AplicarSombraHover(ACard: TRectangle);

implementation

function AdicionarSombra(AControl: TControl;
  ASoftness, ADistance, ADirection: Single;
  AColor: TAlphaColor): TShadowEffect;
begin
  // IMPORTANTE: ClipChildren=False para sombra não ser cortada
  AControl.ClipChildren := False;

  Result := TShadowEffect.Create(AControl);
  Result.Parent      := AControl;
  Result.Softness    := ASoftness;
  Result.Distance    := ADistance;
  Result.Direction   := ADirection; // 315 = nordeste (padrão material)
  Result.ShadowColor := AColor;
  Result.Enabled     := True;
end;

procedure AplicarSombraHover(ACard: TRectangle);
var
  Shadow: TShadowEffect;
begin
  ACard.ClipChildren := False;

  // Sombra inicial: pequena e sutil
  Shadow := TShadowEffect.Create(ACard);
  Shadow.Parent      := ACard;
  Shadow.Softness    := 0.15;
  Shadow.Distance    := 2;
  Shadow.Direction   := 315;
  Shadow.ShadowColor := $30000000;

  ACard.OnMouseEnter := procedure(Sender: TObject)
  begin
    // Sombra cresce no hover
    TAnimator.AnimateFloat(ACard, 'Shadow.Distance', 8, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
    TAnimator.AnimateFloat(ACard, 'Shadow.Softness', 0.40, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
    // Leve elevação: subir levemente
    TAnimator.AnimateFloat(ACard, 'Position.Y',
      ACard.Position.Y - 2, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
  end;

  ACard.OnMouseLeave := procedure(Sender: TObject)
  begin
    // Sombra diminui ao sair
    TAnimator.AnimateFloat(ACard, 'Shadow.Distance', 2, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
    TAnimator.AnimateFloat(ACard, 'Shadow.Softness', 0.15, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
    // Voltar à posição original
    TAnimator.AnimateFloat(ACard, 'Position.Y',
      ACard.Position.Y + 2, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
  end;
end;

// ============================================================
// EXEMPLO DE USO:
//
// // Sombra simples em qualquer controle:
// AdicionarSombra(RecCard);
//
// // Sombra mais pronunciada:
// AdicionarSombra(RecCard, 0.5, 8, 315, $60000000);
//
// // Sombra colorida (azul):
// AdicionarSombra(RecCard, 0.4, 6, 270, $403498DB);
//
// // Hover com animação de sombra (card que "flutua"):
// AplicarSombraHover(RecMeuCard);
//
// DIREÇÕES COMUNS:
// 0   = direita
// 90  = baixo (mais natural, segue luz de cima)
// 180 = esquerda
// 270 = cima
// 315 = nordeste (padrão Material Design)
// ============================================================

end.

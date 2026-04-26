unit glow_effect;
// TGlowEffect: brilho externo em componentes FMX
// TInnerGlowEffect: brilho interno

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Effects,
  FMX.Ani, FMX.Types, System.UITypes;

// Adiciona glow externo a um controle
function AdicionarGlow(AControl: TControl;
  AGlowColor: TAlphaColor = $FF3498DB;
  ASoftness: Single = 5): TGlowEffect;

// Adiciona glow interno a um controle
function AdicionarInnerGlow(AControl: TControl;
  AGlowColor: TAlphaColor = $FFFF9800;
  ASoftness: Single = 8): TInnerGlowEffect;

// Aplica glow animado no hover (aparece ao entrar, some ao sair)
procedure AplicarGlowHover(AControl: TControl;
  AGlowColor: TAlphaColor = $FF3498DB);

implementation

function AdicionarGlow(AControl: TControl;
  AGlowColor: TAlphaColor; ASoftness: Single): TGlowEffect;
begin
  AControl.ClipChildren := False;
  Result := TGlowEffect.Create(AControl);
  Result.Parent    := AControl;
  Result.GlowColor := AGlowColor;
  Result.Softness  := ASoftness;
end;

function AdicionarInnerGlow(AControl: TControl;
  AGlowColor: TAlphaColor; ASoftness: Single): TInnerGlowEffect;
begin
  Result := TInnerGlowEffect.Create(AControl);
  Result.Parent    := AControl;
  Result.GlowColor := AGlowColor;
  Result.Softness  := ASoftness;
end;

procedure AplicarGlowHover(AControl: TControl;
  AGlowColor: TAlphaColor);
var
  Glow: TGlowEffect;
begin
  AControl.ClipChildren := False;

  Glow := TGlowEffect.Create(AControl);
  Glow.Parent    := AControl;
  Glow.GlowColor := AGlowColor;
  Glow.Softness  := 0; // começa invisível

  AControl.OnMouseEnter := procedure(Sender: TObject)
  begin
    TAnimator.AnimateFloat(Glow, 'Softness', 6, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
  end;

  AControl.OnMouseLeave := procedure(Sender: TObject)
  begin
    TAnimator.AnimateFloat(Glow, 'Softness', 0, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
  end;
end;

// ============================================================
// EXEMPLO DE USO:
//
// // Glow azul em card:
// AdicionarGlow(RecCard, $FF3498DB, 6);
//
// // Glow interno laranja em badge:
// AdicionarInnerGlow(RecBadge, $FFFF5722, 10);
//
// // Glow animado no hover:
// AplicarGlowHover(RecBotao, $FF27AE60); // verde
//
// COR DE GLOW SUGERIDA POR TIPO:
// Sucesso:  $FF27AE60 (verde)
// Erro:     $FFE74C3C (vermelho)
// Atenção:  $FFF39C12 (laranja)
// Info:     $FF3498DB (azul)
// Premium:  $FFD4AC0D (dourado)
// ============================================================

end.

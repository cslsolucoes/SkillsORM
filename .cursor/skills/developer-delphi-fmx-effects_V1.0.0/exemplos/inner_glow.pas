unit inner_glow;
// TInnerGlowEffect: brilho interno em botões e componentes de destaque FMX

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Effects,
  FMX.Ani, FMX.Types, System.UITypes;

// Adiciona inner glow simples (variante semântica por tipo)
function IGlowPrimario(AControl: TControl;
  ASoftness: Single = 8): TInnerGlowEffect;

function IGlowSucesso(AControl: TControl;
  ASoftness: Single = 8): TInnerGlowEffect;

function IGlowErro(AControl: TControl;
  ASoftness: Single = 8): TInnerGlowEffect;

function IGlowAtencao(AControl: TControl;
  ASoftness: Single = 8): TInnerGlowEffect;

// Adiciona inner glow com cor e softness explícitos
function AdicionarInnerGlow(AControl: TControl;
  AGlowColor: TAlphaColor;
  ASoftness: Single): TInnerGlowEffect;

// Botão com inner glow animado no clique (pulso)
procedure AplicarPulsoCliqueInnerGlow(AControl: TControl;
  AGlowColor: TAlphaColor = $FF3498DB);

// Remover inner glow existente
procedure RemoverInnerGlow(AControl: TControl);

implementation

const
  // Cores semânticas para inner glow
  COR_PRIMARIO  : TAlphaColor = $FF3498DB; // azul
  COR_SUCESSO   : TAlphaColor = $FF27AE60; // verde
  COR_ERRO      : TAlphaColor = $FFE74C3C; // vermelho
  COR_ATENCAO   : TAlphaColor = $FFF39C12; // laranja

function AdicionarInnerGlow(AControl: TControl;
  AGlowColor: TAlphaColor; ASoftness: Single): TInnerGlowEffect;
begin
  Result := TInnerGlowEffect.Create(AControl);
  Result.Parent    := AControl;
  Result.GlowColor := AGlowColor;
  Result.Softness  := ASoftness;
end;

function IGlowPrimario(AControl: TControl; ASoftness: Single): TInnerGlowEffect;
begin
  Result := AdicionarInnerGlow(AControl, COR_PRIMARIO, ASoftness);
end;

function IGlowSucesso(AControl: TControl; ASoftness: Single): TInnerGlowEffect;
begin
  Result := AdicionarInnerGlow(AControl, COR_SUCESSO, ASoftness);
end;

function IGlowErro(AControl: TControl; ASoftness: Single): TInnerGlowEffect;
begin
  Result := AdicionarInnerGlow(AControl, COR_ERRO, ASoftness);
end;

function IGlowAtencao(AControl: TControl; ASoftness: Single): TInnerGlowEffect;
begin
  Result := AdicionarInnerGlow(AControl, COR_ATENCAO, ASoftness);
end;

procedure AplicarPulsoCliqueInnerGlow(AControl: TControl;
  AGlowColor: TAlphaColor);
var
  IGlow: TInnerGlowEffect;
begin
  // Cria inner glow "escondido" (Softness=0)
  IGlow := TInnerGlowEffect.Create(AControl);
  IGlow.Parent    := AControl;
  IGlow.GlowColor := AGlowColor;
  IGlow.Softness  := 0;

  AControl.OnMouseDown := procedure(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Single)
  begin
    // Brilha no clique
    TAnimator.AnimateFloat(IGlow, 'Softness', 12, 0.10,
      TAnimationType.Out, TInterpolationType.Cubic);
  end;

  AControl.OnMouseUp := procedure(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Single)
  begin
    // Apaga após soltar
    TAnimator.AnimateFloat(IGlow, 'Softness', 0, 0.25,
      TAnimationType.Out, TInterpolationType.Cubic);
  end;

  // Garantir que o botão responde a cliques
  AControl.HitTest := True;
end;

procedure RemoverInnerGlow(AControl: TControl);
var
  I: Integer;
begin
  // Percorre os efeitos em ordem reversa para remoção segura
  for I := AControl.Effects.Count - 1 downto 0 do
  begin
    if AControl.Effects[I] is TInnerGlowEffect then
    begin
      AControl.Effects[I].Free;
      Break; // Remove apenas o primeiro encontrado
    end;
  end;
end;

// ============================================================
// EXEMPLO DE USO:
//
// // Botão primário com inner glow azul:
// IGlowPrimario(BtnSalvar, 6);
//
// // Badge de sucesso com inner glow verde:
// IGlowSucesso(RecBadgeOk, 10);
//
// // Input com erro: inner glow vermelho:
// IGlowErro(RecCampoCPF, 8);
//
// // Botão com pulso no clique:
// AplicarPulsoCliqueInnerGlow(BtnConfirmar, $FF8E44AD); // roxo
//
// // Remover inner glow:
// RemoverInnerGlow(RecBadge);
//
// INTENSIDADE POR CONTEXTO:
//  4-6  = toque sutil (inputs em foco)
//  8-10 = destaque médio (badges, status)
// 12-15 = destaque forte (erro crítico, alertas)
// ============================================================

end.

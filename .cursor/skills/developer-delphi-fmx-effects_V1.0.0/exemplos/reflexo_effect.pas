unit reflexo_effect;
// TReflectionEffect: reflexo espelhado abaixo do componente FMX

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Effects,
  FMX.Ani, FMX.Types, System.UITypes;

// Adiciona reflexo padrão
function AdicionarReflexo(AControl: TControl;
  ALength: Single = 0.5;
  AOpacity: Single = 0.3): TReflectionEffect;

// Reflexo com fade animado (aparece ao entrar)
procedure AplicarReflexoHover(AControl: TControl;
  ALength: Single = 0.5);

implementation

function AdicionarReflexo(AControl: TControl;
  ALength: Single; AOpacity: Single): TReflectionEffect;
begin
  // IMPORTANTE: ClipChildren := False para o reflexo não ser cortado
  AControl.ClipChildren := False;

  Result := TReflectionEffect.Create(AControl);
  Result.Parent  := AControl;
  Result.Length  := ALength;   // 0=sem reflexo, 1=reflexo total
  Result.Opacity := AOpacity;  // 0=invisível, 1=opaco
end;

procedure AplicarReflexoHover(AControl: TControl; ALength: Single);
var
  Reflexo: TReflectionEffect;
begin
  AControl.ClipChildren := False;

  Reflexo := TReflectionEffect.Create(AControl);
  Reflexo.Parent  := AControl;
  Reflexo.Length  := ALength;
  Reflexo.Opacity := 0; // começa invisível

  AControl.OnMouseEnter := procedure(Sender: TObject)
  begin
    TAnimator.AnimateFloat(Reflexo, 'Opacity', 0.35, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
  end;

  AControl.OnMouseLeave := procedure(Sender: TObject)
  begin
    TAnimator.AnimateFloat(Reflexo, 'Opacity', 0, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
  end;
end;

// ============================================================
// EXEMPLO DE USO:
//
// // Reflexo simples em logo ou imagem:
// AdicionarReflexo(ImgLogo, 0.6, 0.25);
//
// // Reflexo curto em card:
// AdicionarReflexo(RecCard, 0.3, 0.15);
//
// // Reflexo animado no hover:
// AplicarReflexoHover(RecDestaque, 0.5);
//
// VALORES DE Length:
//  0.0 = sem reflexo
//  0.3 = reflexo curto (sutil)
//  0.5 = reflexo médio (padrão)
//  0.8 = reflexo longo
//  1.0 = reflexo total (mesmo tamanho do componente)
//
// VALORES DE Opacity:
//  0.1-0.2 = muito sutil
//  0.3     = padrão (natural)
//  0.5+    = muito pronunciado (evitar em UIs limpas)
//
// NOTA:
// TReflectionEffect reflete o conteúdo do próprio componente
// (imagem, texto, bordas). Resultado melhor em imagens e logos.
// Em retângulos sólidos o efeito é menos interessante.
//
// ClipChildren := False é OBRIGATÓRIO para o reflexo aparecer
// fora dos limites do componente pai.
// ============================================================

end.

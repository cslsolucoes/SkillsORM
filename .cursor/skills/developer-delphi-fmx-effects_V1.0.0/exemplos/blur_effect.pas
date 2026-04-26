unit blur_effect;
// TBlurEffect: desfoque gaussiano em componentes FMX
// Principal uso: fundo fosco atrás de modais/drawers

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Effects,
  FMX.Ani, FMX.Types, System.UITypes;

// Adiciona blur simples a um controle
function AdicionarBlur(AControl: TControl;
  ASoftness: Single = 8): TBlurEffect;

// Ativar blur com animação (cresce de 0 até ASoftness)
procedure AtivarBlurAnimado(AControl: TControl;
  ASoftness: Single = 8; ADuracao: Single = 0.20);

// Desativar blur com animação (reduz até 0) e libera ao fim
procedure DesativarBlurAnimado(ABlur: TBlurEffect;
  ADuracao: Single = 0.20; AOnFim: TProc = nil);

implementation

function AdicionarBlur(AControl: TControl;
  ASoftness: Single): TBlurEffect;
begin
  Result := TBlurEffect.Create(AControl);
  Result.Parent   := AControl;
  Result.Softness := ASoftness;
end;

procedure AtivarBlurAnimado(AControl: TControl;
  ASoftness: Single; ADuracao: Single);
var
  Blur: TBlurEffect;
begin
  // Verificar se já existe um blur
  var I: Integer;
  for I := 0 to AControl.Effects.Count - 1 do
    if AControl.Effects[I] is TBlurEffect then
    begin
      // Já existe: animar o existente
      TAnimator.AnimateFloat(AControl.Effects[I] as TBlurEffect,
        'Softness', ASoftness, ADuracao);
      Exit;
    end;

  // Criar novo blur
  Blur := TBlurEffect.Create(AControl);
  Blur.Parent   := AControl;
  Blur.Softness := 0;
  TAnimator.AnimateFloat(Blur, 'Softness', ASoftness, ADuracao,
    TAnimationType.Out, TInterpolationType.Cubic);
end;

procedure DesativarBlurAnimado(ABlur: TBlurEffect;
  ADuracao: Single; AOnFim: TProc);
var
  Anim: TFloatAnimation;
begin
  if not Assigned(ABlur) then
  begin
    if Assigned(AOnFim) then AOnFim();
    Exit;
  end;

  Anim := TFloatAnimation.Create(ABlur);
  Anim.Parent       := ABlur;
  Anim.PropertyName := 'Softness';
  Anim.StartValue   := ABlur.Softness;
  Anim.StopValue    := 0;
  Anim.Duration     := ADuracao;
  Anim.OnFinish := procedure(Sender: TObject)
  begin
    ABlur.Free;
    if Assigned(AOnFim) then AOnFim();
    Anim.Free;
  end;
  Anim.Start;
end;

// ============================================================
// EXEMPLO DE USO:
//
// // Blur simples (estático):
// var Blur := AdicionarBlur(RecFundo, 10);
//
// // Blur animado ao abrir modal:
// AtivarBlurAnimado(RecConteudoPrincipal, 8, 0.20);
//
// // Remover blur com animação ao fechar modal:
// DesativarBlurAnimado(FBlurFundo, 0.20, procedure
// begin
//   RecModal.Visible := False;
// end);
//
// VALORES DE SOFTNESS:
// 0  = sem blur (nítido)
// 2  = blur leve (foco suave)
// 5  = blur médio
// 8  = blur de fundo fosco (modal)
// 12 = blur forte (desfoque total)
//
// LIMITAÇÃO:
// TBlurEffect borra o conteúdo DO PRÓPRIO componente.
// Para efeito "frosted glass", aplicar em RecConteudoPrincipal
// (não no overlay/modal que fica por cima).
// ============================================================

end.

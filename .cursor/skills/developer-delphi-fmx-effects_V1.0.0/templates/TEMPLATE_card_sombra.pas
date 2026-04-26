unit TEMPLATE_card_sombra;
// TEMPLATE: Card com TShadowEffect — criação runtime recomendada
// Padrão: sombra sutil em repouso, pronunciada no hover

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Effects,
  FMX.Ani, FMX.Types, System.UITypes;

// Adicionar sombra a um card existente (chamada única no FormCreate)
procedure ConfigurarCardComSombra(ACard: TRectangle);

implementation

procedure ConfigurarCardComSombra(ACard: TRectangle);
var
  Shadow: TShadowEffect;
begin
  // 1. CRITICO: permitir renderização fora dos limites do card
  ACard.ClipChildren := False;

  // 2. Criar sombra em repouso — sutil
  Shadow := TShadowEffect.Create(ACard);
  Shadow.Parent      := ACard;
  Shadow.Softness    := 0.15;
  Shadow.Distance    := 2;
  Shadow.Direction   := 315;     // nordeste (padrão Material)
  Shadow.ShadowColor := $30000000; // preto 19%
  Shadow.Enabled     := True;

  // 3. Hover: sombra cresce + card sobe levemente
  ACard.OnMouseEnter := procedure(Sender: TObject)
  begin
    TAnimator.AnimateFloat(Shadow, 'Distance',    8, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
    TAnimator.AnimateFloat(Shadow, 'Softness',  0.40, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
    TAnimator.AnimateColor(Shadow, 'ShadowColor', $50000000, 0.20);
    // Leve elevação visual
    TAnimator.AnimateFloat(ACard, 'Position.Y',
      ACard.Position.Y - 2, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
  end;

  // 4. MouseLeave: volta ao estado de repouso
  ACard.OnMouseLeave := procedure(Sender: TObject)
  begin
    TAnimator.AnimateFloat(Shadow, 'Distance',    2, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
    TAnimator.AnimateFloat(Shadow, 'Softness', 0.15, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
    TAnimator.AnimateColor(Shadow, 'ShadowColor', $30000000, 0.20);
    // Voltar posição original
    TAnimator.AnimateFloat(ACard, 'Position.Y',
      ACard.Position.Y + 2, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
  end;

  // 5. Cursor de mão para indicar clicabilidade
  ACard.Cursor := crHandPoint;
end;

// ============================================================
// USO:
//
// procedure TFormPrincipal.FormCreate(Sender: TObject);
// begin
//   ConfigurarCardComSombra(RecCard1);
//   ConfigurarCardComSombra(RecCard2);
//   ConfigurarCardComSombra(RecCard3);
// end;
//
// REQUISITO no .fmx (ou FormCreate antes de chamar este proc):
//   RecCard1.XRadius := 12; RecCard1.YRadius := 12;
//   RecCard1.Fill.Color := claWhite;
//
// VARIAÇÕES:
//   // Sombra colorida (azul para card selecionado):
//   Shadow.ShadowColor := $403498DB;
//
//   // Sombra mais pronunciada para card de destaque:
//   Shadow.Softness := 0.5; Shadow.Distance := 8;
//   Shadow.ShadowColor := $60000000;
// ============================================================

end.

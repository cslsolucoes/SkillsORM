unit TEMPLATE_animacao_entrada;
// TEMPLATE: Animação de entrada reutilizável para qualquer container/item
// Uso: chamar AnimarEntrada() após criar/carregar os controles

interface

uses
  FMX.Controls, FMX.Ani, FMX.Types;

// ============================================================
// PROCEDIMENTO UTILITÁRIO: AnimarEntrada
// Anima todos os filhos diretos de AContainer com fade + slide
//
// Parâmetros:
//   AContainer   — o pai cujos filhos serão animados
//   ADelayBase   — delay antes de começar (segundos)
//   AStagger     — delay extra entre cada item (segundos)
//   ASlide       — pixels de deslocamento vertical inicial
//   ADuracao     — duração de cada animação individual
// ============================================================

procedure AnimarEntrada(AContainer: TControl;
  ADelayBase: Single = 0;
  AStagger: Single = 0.06;
  ASlide: Single = 18;
  ADuracao: Single = 0.30);

// ============================================================
// PROCEDIMENTO UTILITÁRIO: AnimarEntradaUnico
// Anima um único componente com fade + slide
// ============================================================
procedure AnimarEntradaUnico(AControl: TControl;
  ADelay: Single = 0;
  ASlide: Single = 18;
  ADuracao: Single = 0.30);

implementation

procedure AnimarEntradaUnico(AControl: TControl;
  ADelay: Single; ASlide: Single; ADuracao: Single);
var
  OriginalY: Single;
begin
  OriginalY := AControl.Position.Y;

  // Estado inicial: invisível e deslocado para baixo
  AControl.Opacity    := 0;
  AControl.Position.Y := OriginalY + ASlide;

  // Fade in
  TAnimator.AnimateFloatDelay(AControl, 'Opacity', 1.0, ADuracao, ADelay,
    TAnimationType.Out, TInterpolationType.Cubic);

  // Slide up para posição original
  TAnimator.AnimateFloatDelay(AControl, 'Position.Y', OriginalY, ADuracao, ADelay,
    TAnimationType.Out, TInterpolationType.Cubic);
end;

procedure AnimarEntrada(AContainer: TControl;
  ADelayBase: Single; AStagger: Single; ASlide: Single; ADuracao: Single);
var
  I: Integer;
begin
  for I := 0 to AContainer.ControlsCount - 1 do
    AnimarEntradaUnico(
      AContainer.Controls[I],
      ADelayBase + I * AStagger,
      ASlide,
      ADuracao
    );
end;

// ============================================================
// EXEMPLO DE USO:
//
// // No AfterShow ou após CarregarDados:
// AnimarEntrada(LayoutItens);
//
// // Com delay de 0.2s e stagger de 0.08s entre itens:
// AnimarEntrada(LayoutItens, 0.2, 0.08);
//
// // Animar apenas um item específico:
// AnimarEntradaUnico(RecCard, 0.1);
// ============================================================

end.

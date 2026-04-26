unit animacoes_basicas;
// Exemplo: AnimateFloat, AnimateColor, delay, stop — TAnimator básico

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Layouts, FMX.StdCtrls,
  FMX.Ani, FMX.Types, System.UITypes;

type
  TFormAnimacoesBasicas = class(TForm)
  private
    RecDemo: TRectangle;
    procedure CriarInterface;
    procedure DemoAnimateFloat;
    procedure DemoAnimateColor;
    procedure DemoAnimateDelay;
    procedure DemoStopAnimation;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

constructor TFormAnimacoesBasicas.Create(AOwner: TComponent);
begin
  inherited;
  CriarInterface;
end;

procedure TFormAnimacoesBasicas.CriarInterface;
begin
  RecDemo := TRectangle.Create(Self);
  RecDemo.Parent := Self;
  RecDemo.Position.X := 50;
  RecDemo.Position.Y := 50;
  RecDemo.Width  := 200;
  RecDemo.Height := 80;
  RecDemo.Fill.Color := $FF3498DB;
  RecDemo.Stroke.Kind := TBrushKind.None;
  RecDemo.XRadius := 8; RecDemo.YRadius := 8;
  RecDemo.Opacity := 0; // começa invisível

  // Disparar demos sequencialmente via cliques em produção
  // Para fins didáticos, encadeamos via OnFinish
  DemoAnimateFloat;
end;

procedure TFormAnimacoesBasicas.DemoAnimateFloat;
begin
  // Fade in: Opacity 0 → 1
  TAnimator.AnimateFloat(
    RecDemo,               // alvo
    'Opacity',             // propriedade published Single
    1.0,                   // valor final
    0.5,                   // duração em segundos
    TAnimationType.Out,    // easing: desacelera no final
    TInterpolationType.Cubic  // curva suave
  );

  // Slide: mover Position.X de 50 para 100
  TAnimator.AnimateFloat(RecDemo, 'Position.X', 100, 0.5,
    TAnimationType.Out, TInterpolationType.Cubic);

  // Múltiplas propriedades simultâneas são chamadas sequencialmente
  // (TAnimator cria uma animação independente para cada propriedade)
  TAnimator.AnimateFloat(RecDemo, 'Width', 300, 0.5,
    TAnimationType.Out, TInterpolationType.Back); // ultrapassa e volta
end;

procedure TFormAnimacoesBasicas.DemoAnimateColor;
begin
  // AnimateColor: altera Fill.Color para verde
  TAnimator.AnimateColor(
    RecDemo,
    'Fill.Color',
    $FF27AE60,   // verde
    0.4          // duração (sem tipo/interpolação = padrão Linear)
  );

  // Volta ao azul após 0.4s via delay
  TAnimator.AnimateColorDelay(RecDemo, 'Fill.Color', $FF3498DB, 0.4, 0.5);
end;

procedure TFormAnimacoesBasicas.DemoAnimateDelay;
begin
  // Animação com delay: começa APÓS 1.0 segundo
  TAnimator.AnimateFloatDelay(
    RecDemo,
    'RotationAngle',
    45.0,          // valor final (graus)
    0.6,           // duração
    1.0            // delay antes de iniciar
  );

  // Sequência encadeada: Y se move após 0.3s de delay
  TAnimator.AnimateFloatDelay(RecDemo, 'Position.Y', 150, 0.4, 0.3);
  TAnimator.AnimateFloatDelay(RecDemo, 'Position.Y', 50,  0.4, 0.8);
end;

procedure TFormAnimacoesBasicas.DemoStopAnimation;
begin
  // Iniciar uma animação longa
  TAnimator.AnimateFloat(RecDemo, 'Opacity', 0, 5.0); // 5 segundos

  // Parar a animação imediatamente (em um evento de click por exemplo)
  TAnimator.StopAnimation(RecDemo, 'Opacity');

  // Parar TODAS as animações do componente
  TAnimator.StopAllAnimation(RecDemo);
end;

end.

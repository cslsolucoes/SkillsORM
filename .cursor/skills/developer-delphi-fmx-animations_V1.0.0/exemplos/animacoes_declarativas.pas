unit animacoes_declarativas;
// TFloatAnimation e TColorAnimation como objetos — abordagem declarativa/design-time
// Diferença de TAnimator (runtime one-shot) vs TFloatAnimation (objeto reutilizável, loop, OnFinish)

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Layouts, FMX.StdCtrls,
  FMX.Ani, FMX.Types, System.UITypes;

// Criação declarativa em runtime de TFloatAnimation
procedure DemoFloatAnimationComOnFinish(AControl: TControl);

// Criação declarativa de TColorAnimation em loop
procedure DemoColorAnimationLoop(AControl: TRectangle);

// Animação de sequência encadeada via OnFinish
procedure DemoSequenciaEncadeada(AControl: TControl);

// Animar com TPathAnimation (movimento por caminho)
procedure DemoPathAnimation(AControl: TControl; AParent: TControl);

implementation

procedure DemoFloatAnimationComOnFinish(AControl: TControl);
var
  Anim: TFloatAnimation;
begin
  // TFloatAnimation como objeto com ciclo de vida gerenciado
  Anim := TFloatAnimation.Create(AControl);
  Anim.Parent       := AControl;
  Anim.PropertyName := 'Opacity';
  Anim.StartValue   := 0.0;
  Anim.StopValue    := 1.0;
  Anim.Duration     := 0.40;
  Anim.Delay        := 0.10;
  Anim.Interpolation := TInterpolationType.Cubic;
  Anim.AnimationType := TAnimationType.Out;
  Anim.AutoReverse  := False;
  Anim.Loop         := False;

  // OnFinish: executar lógica após a animação terminar
  // IMPORTANTE: liberar Anim dentro do OnFinish para evitar leak
  Anim.OnFinish := procedure(Sender: TObject)
  begin
    // Aqui: mostrar próximo elemento, habilitar botão, etc.
    AControl.HitTest := True; // reabilitar interação após fade-in
    Anim.Free; // liberar a animação (ela foi concluída)
  end;

  AControl.Opacity := 0;
  AControl.HitTest := False; // desabilitar interação durante animação
  Anim.Start;
end;

procedure DemoColorAnimationLoop(AControl: TRectangle);
var
  Anim: TColorAnimation;
begin
  // TColorAnimation em loop com AutoReverse — pulsa continuamente
  Anim := TColorAnimation.Create(AControl);
  Anim.Parent       := AControl;
  Anim.PropertyName := 'Fill.Color';
  Anim.StartValue   := $FFFFFFFF; // branco
  Anim.StopValue    := $FF3498DB; // azul
  Anim.Duration     := 1.5;
  Anim.Loop         := True;
  Anim.AutoReverse  := True; // vai e volta automaticamente
  Anim.Interpolation := TInterpolationType.Sinusoidal;
  Anim.AnimationType := TAnimationType.InOut;

  // Para parar mais tarde:
  // Anim.Stop;  ou  TAnimator.StopAnimation(AControl, 'Fill.Color');

  Anim.Start;
end;

procedure DemoSequenciaEncadeada(AControl: TControl);
// Demonstra como encadear 3 animações: fade-in → escala up → escala normal
var
  AnimFade: TFloatAnimation;
  AnimScaleUp, AnimScaleDown: TFloatAnimation;
begin
  // Passo 1: Fade in
  AnimFade := TFloatAnimation.Create(AControl);
  AnimFade.Parent       := AControl;
  AnimFade.PropertyName := 'Opacity';
  AnimFade.StartValue   := 0;
  AnimFade.StopValue    := 1.0;
  AnimFade.Duration     := 0.25;

  // Passo 2: Scale up (inicia ao fim do fade)
  AnimScaleUp := TFloatAnimation.Create(AControl);
  AnimScaleUp.Parent       := AControl;
  AnimScaleUp.PropertyName := 'Scale.X';
  AnimScaleUp.StartValue   := 1.0;
  AnimScaleUp.StopValue    := 1.05;
  AnimScaleUp.Duration     := 0.20;

  // Passo 3: Scale normal (inicia ao fim do scale up)
  AnimScaleDown := TFloatAnimation.Create(AControl);
  AnimScaleDown.Parent       := AControl;
  AnimScaleDown.PropertyName := 'Scale.X';
  AnimScaleDown.StartValue   := 1.05;
  AnimScaleDown.StopValue    := 1.0;
  AnimScaleDown.Duration     := 0.20;

  // Encadeamento via OnFinish
  AnimFade.OnFinish := procedure(Sender: TObject)
  begin
    AnimFade.Free;
    // Animar Scale.Y junto com Scale.X para manter proporção
    TAnimator.AnimateFloat(AControl, 'Scale.Y', 1.05, 0.20,
      TAnimationType.Out, TInterpolationType.Back);
    AnimScaleUp.Start;
  end;

  AnimScaleUp.OnFinish := procedure(Sender: TObject)
  begin
    AnimScaleUp.Free;
    TAnimator.AnimateFloat(AControl, 'Scale.Y', 1.0, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);
    AnimScaleDown.Start;
  end;

  AnimScaleDown.OnFinish := procedure(Sender: TObject)
  begin
    AnimScaleDown.Free;
    // Animação completa — liberar ambas Scale.Y estava sendo gerenciada por TAnimator
  end;

  // Iniciar a sequência
  AControl.Opacity := 0;
  AnimFade.Start;
end;

procedure DemoPathAnimation(AControl: TControl; AParent: TControl);
var
  Anim: TPathAnimation;
begin
  // TPathAnimation: mover controle por um caminho definido
  Anim := TPathAnimation.Create(AControl);
  Anim.Parent    := AControl;
  Anim.Duration  := 2.0;
  Anim.Loop      := True;
  Anim.AutoReverse := True;

  // Definir caminho como string SVG path (M=moveto, L=lineto, C=curveto)
  // Exemplo: semicírculo
  Anim.Path.Data := 'M 0 0 Q 100 -80 200 0'; // curva quadrática

  Anim.Start;
end;

// ============================================================
// DIFERENÇA FUNDAMENTAL:
//
// TAnimator.AnimateFloat (runtime, one-shot):
//   + Simples de usar: uma linha
//   + Sem necessidade de gerenciar objeto
//   - Sem OnFinish nativo fácil
//   - Não pode ser pausado/retomado
//
// TFloatAnimation (objeto, reutilizável):
//   + OnFinish para encadeamento
//   + Loop e AutoReverse
//   + Pode ser pausado (Stop/Start)
//   + Configurável em design-time (.fmx)
//   - Precisa gerenciar lifecycle (Free no OnFinish se não loop)
//
// REGRA: Use TAnimator para animações simples one-shot.
//        Use TFloatAnimation para OnFinish, loops ou design-time.
// ============================================================

end.

# Padrões de Animação Prontos — Copy-Paste

## 1. Entrada de tela (fade + slide up)

```pascal
// Chamar após criar os controles / carregar dados
procedure AnimarEntradaTela(AContainer: TControl; ADelayBase: Single = 0);
var I: Integer; C: TControl;
begin
  for I := 0 to AContainer.ControlsCount - 1 do
  begin
    C := AContainer.Controls[I];
    C.Opacity := 0;
    C.Position.Y := C.Position.Y + 18;
    TAnimator.AnimateFloatDelay(C, 'Opacity', 1.0, 0.30, ADelayBase + I * 0.06,
      TAnimationType.Out, TInterpolationType.Cubic);
    TAnimator.AnimateFloatDelay(C, 'Position.Y', C.Position.Y - 18, 0.30,
      ADelayBase + I * 0.06, TAnimationType.Out, TInterpolationType.Cubic);
  end;
end;
```

## 2. Abertura de modal (scale + fade)

```pascal
procedure AbrirModal(AModal: TControl; AOverlay: TControl = nil);
begin
  // Overlay semitransparente (opcional)
  if Assigned(AOverlay) then
  begin
    AOverlay.Opacity := 0;
    AOverlay.Visible := True;
    TAnimator.AnimateFloat(AOverlay, 'Opacity', 1.0, 0.20);
  end;

  // Modal: começa pequeno e invisível
  AModal.Scale.X := 0.88;
  AModal.Scale.Y := 0.88;
  AModal.Opacity := 0;
  AModal.Visible := True;

  TAnimator.AnimateFloat(AModal, 'Opacity', 1.0, 0.25,
    TAnimationType.Out, TInterpolationType.Cubic);
  TAnimator.AnimateFloat(AModal, 'Scale.X', 1.0, 0.28,
    TAnimationType.Out, TInterpolationType.Back);
  TAnimator.AnimateFloat(AModal, 'Scale.Y', 1.0, 0.28,
    TAnimationType.Out, TInterpolationType.Back);
end;
```

## 3. Fechamento de modal (scale down + fade)

```pascal
procedure FecharModal(AModal: TControl; AOverlay: TControl = nil;
  AOnFim: TProc = nil);
begin
  TAnimator.AnimateFloat(AModal, 'Opacity', 0, 0.18,
    TAnimationType.In, TInterpolationType.Cubic);
  TAnimator.AnimateFloat(AModal, 'Scale.X', 0.88, 0.18,
    TAnimationType.In, TInterpolationType.Cubic);
  TAnimator.AnimateFloat(AModal, 'Scale.Y', 0.88, 0.18,
    TAnimationType.In, TInterpolationType.Cubic);

  if Assigned(AOverlay) then
    TAnimator.AnimateFloat(AOverlay, 'Opacity', 0, 0.18);

  // Executar após a animação terminar
  var Anim := TFloatAnimation.Create(AModal);
  Anim.Parent := AModal;
  Anim.PropertyName := 'Opacity';
  Anim.StartValue := AModal.Opacity;
  Anim.StopValue  := 0;
  Anim.Duration   := 0.18;
  Anim.OnFinish   := procedure(Sender: TObject)
  begin
    AModal.Visible := False;
    if Assigned(AOverlay) then AOverlay.Visible := False;
    if Assigned(AOnFim) then AOnFim();
    Anim.Free;
  end;
  Anim.Start;
end;
```

## 4. Hover em card (cor + borda)

```pascal
// Aplicar OnMouseEnter/OnMouseLeave em qualquer TRectangle
RecCard.OnMouseEnter := procedure(Sender: TObject)
begin
  TAnimator.AnimateColor(Sender as TControl, 'Fill.Color', $FFF0F7FF, 0.15);
  TAnimator.AnimateColor(Sender as TControl, 'Stroke.Color', $FF3498DB, 0.15);
  TAnimator.AnimateFloat(Sender as TControl, 'Scale.X', 1.02, 0.15,
    TAnimationType.Out, TInterpolationType.Back);
  TAnimator.AnimateFloat(Sender as TControl, 'Scale.Y', 1.02, 0.15,
    TAnimationType.Out, TInterpolationType.Back);
end;

RecCard.OnMouseLeave := procedure(Sender: TObject)
begin
  TAnimator.AnimateColor(Sender as TControl, 'Fill.Color', $FFFFFFFF, 0.15);
  TAnimator.AnimateColor(Sender as TControl, 'Stroke.Color', $FFE8E8E8, 0.15);
  TAnimator.AnimateFloat(Sender as TControl, 'Scale.X', 1.0, 0.15,
    TAnimationType.Out, TInterpolationType.Cubic);
  TAnimator.AnimateFloat(Sender as TControl, 'Scale.Y', 1.0, 0.15,
    TAnimationType.Out, TInterpolationType.Cubic);
end;
```

## 5. Tab switch (fade entre painéis)

```pascal
procedure TrocarTab(APainelAtual, APainelNovo: TControl);
begin
  if APainelAtual = APainelNovo then Exit;

  // Fade out do atual
  TAnimator.AnimateFloat(APainelAtual, 'Opacity', 0, 0.15,
    TAnimationType.Out, TInterpolationType.Linear);

  // Mostrar novo (com opacity 0) e fade in após delay
  APainelNovo.Opacity := 0;
  APainelNovo.Visible := True;
  TAnimator.AnimateFloatDelay(APainelNovo, 'Opacity', 1.0, 0.15,
    0.10, TAnimationType.Out, TInterpolationType.Linear);

  // Esconder o atual após a saída
  var AnimOut := TFloatAnimation.Create(APainelAtual);
  AnimOut.Parent := APainelAtual;
  AnimOut.PropertyName := 'Opacity';
  AnimOut.StartValue := APainelAtual.Opacity;
  AnimOut.StopValue  := 0;
  AnimOut.Duration   := 0.15;
  AnimOut.OnFinish := procedure(Sender: TObject)
  begin
    APainelAtual.Visible := False;
    AnimOut.Free;
  end;
  AnimOut.Start;
end;
```

## 6. Sidebar colapsável

```pascal
procedure AnimarSidebar(ARecSidebar: TRectangle; AAbrir: Boolean);
const
  LARGURA_ABERTA  = 240;
  LARGURA_FECHADA = 60;
var
  Alvo: Single;
begin
  Alvo := IfThen(AAbrir, LARGURA_ABERTA, LARGURA_FECHADA);
  TAnimator.AnimateFloat(ARecSidebar, 'Width', Alvo, 0.25,
    TAnimationType.Out, TInterpolationType.Cubic);
end;
```

## 7. Notificação pop (slide down + elastic)

```pascal
procedure MostrarNotificacao(ANotif: TControl; ADuracao: Single = 3.0);
var
  YFim: Single;
begin
  YFim := ANotif.Position.Y;
  ANotif.Position.Y := YFim - 60; // começa acima
  ANotif.Opacity := 0;
  ANotif.Visible := True;

  // Entrada: slide down + elastic
  TAnimator.AnimateFloat(ANotif, 'Position.Y', YFim, 0.40,
    TAnimationType.Out, TInterpolationType.Elastic);
  TAnimator.AnimateFloat(ANotif, 'Opacity', 1.0, 0.20);

  // Saída após ADuracao segundos
  TAnimator.AnimateFloatDelay(ANotif, 'Opacity', 0, 0.20, ADuracao);
  TAnimator.AnimateFloatDelay(ANotif, 'Position.Y', YFim - 60, 0.20,
    ADuracao, TAnimationType.In, TInterpolationType.Cubic);
end;
```

## 8. Loading spinner (rotação contínua)

```pascal
procedure IniciarSpinner(AControl: TControl);
var Anim: TFloatAnimation;
begin
  Anim := TFloatAnimation.Create(AControl);
  Anim.Parent       := AControl;
  Anim.PropertyName := 'RotationAngle';
  Anim.StartValue   := 0;
  Anim.StopValue    := 360;
  Anim.Duration     := 1.0;
  Anim.Loop         := True;
  Anim.Interpolation := TInterpolationType.Linear;
  Anim.AnimationType := TAnimationType.InOut;
  Anim.Start;
  // Para parar: Anim.Stop; ou TAnimator.StopAnimation(AControl, 'RotationAngle');
end;
```

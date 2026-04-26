unit TEMPLATE_animacao_saida;
// TEMPLATE: Animação de saída reutilizável com callback ao terminar
// Uso: chamar AnimarSaida() antes de destruir/esconder o componente

interface

uses
  FMX.Controls, FMX.Ani, FMX.Types;

// ============================================================
// PROCEDIMENTO: AnimarSaida
// Anima a saída de um componente (fade + slide para baixo)
// e executa o callback AOnFim quando a animação terminar.
//
// Parâmetros:
//   AControl  — componente a ser animado
//   AOnFim    — callback executado ao fim (nil = sem callback)
//   ASlide    — pixels de deslocamento vertical ao sair
//   ADuracao  — duração em segundos
// ============================================================
procedure AnimarSaida(AControl: TControl;
  AOnFim: TProc = nil;
  ASlide: Single = 18;
  ADuracao: Single = 0.25);

// ============================================================
// PROCEDIMENTO: AnimarSaidaUnico
// Alias de AnimarSaida com mesma assinatura de AnimarEntradaUnico
// para facilitar substituição
// ============================================================
procedure AnimarSaidaUnico(AControl: TControl;
  ADelay: Single = 0;
  ASlide: Single = 18;
  ADuracao: Single = 0.25;
  AOnFim: TProc = nil);

// ============================================================
// PROCEDIMENTO: AnimarSaidaTodos
// Anima a saída de todos os filhos de AContainer em ordem reversa
// Executa AOnFim após o último item terminar
// ============================================================
procedure AnimarSaidaTodos(AContainer: TControl;
  AOnFim: TProc = nil;
  AStagger: Single = 0.04;
  ASlide: Single = 18;
  ADuracao: Single = 0.20);

implementation

procedure AnimarSaida(AControl: TControl;
  AOnFim: TProc;
  ASlide: Single;
  ADuracao: Single);
var
  OriginalY: Single;
  Anim: TFloatAnimation;
begin
  OriginalY := AControl.Position.Y;

  // Fade out
  TAnimator.AnimateFloat(AControl, 'Opacity', 0, ADuracao,
    TAnimationType.In, TInterpolationType.Cubic);

  // Slide para baixo
  TAnimator.AnimateFloat(AControl, 'Position.Y', OriginalY + ASlide, ADuracao,
    TAnimationType.In, TInterpolationType.Cubic);

  // Usar TFloatAnimation separado apenas para o OnFinish
  // (TAnimator não expõe OnFinish diretamente)
  Anim := TFloatAnimation.Create(AControl);
  Anim.Parent        := AControl;
  Anim.PropertyName  := 'Opacity';
  Anim.StartValue    := AControl.Opacity;
  Anim.StopValue     := 0;
  Anim.Duration      := ADuracao;
  Anim.Interpolation := TInterpolationType.Cubic;
  Anim.AnimationType := TAnimationType.In;
  Anim.OnFinish := procedure(Sender: TObject)
  begin
    if Assigned(AOnFim) then
      AOnFim();
    Anim.Free;
  end;
  Anim.Start;
end;

procedure AnimarSaidaUnico(AControl: TControl;
  ADelay: Single;
  ASlide: Single;
  ADuracao: Single;
  AOnFim: TProc);
var
  OriginalY: Single;
  Anim: TFloatAnimation;
begin
  OriginalY := AControl.Position.Y;

  // Fade out com delay
  TAnimator.AnimateFloatDelay(AControl, 'Opacity', 0, ADuracao, ADelay,
    TAnimationType.In, TInterpolationType.Cubic);

  // Slide com delay
  TAnimator.AnimateFloatDelay(AControl, 'Position.Y', OriginalY + ASlide, ADuracao,
    ADelay, TAnimationType.In, TInterpolationType.Cubic);

  // Callback via TFloatAnimation
  if Assigned(AOnFim) then
  begin
    Anim := TFloatAnimation.Create(AControl);
    Anim.Parent       := AControl;
    Anim.PropertyName := 'Opacity';
    Anim.StartValue   := AControl.Opacity;
    Anim.StopValue    := 0;
    Anim.Duration     := ADuracao;
    Anim.Delay        := ADelay;
    Anim.OnFinish := procedure(Sender: TObject)
    begin
      AOnFim();
      Anim.Free;
    end;
    Anim.Start;
  end;
end;

procedure AnimarSaidaTodos(AContainer: TControl;
  AOnFim: TProc;
  AStagger: Single;
  ASlide: Single;
  ADuracao: Single);
var
  I, Count: Integer;
  Ultimo: TControl;
begin
  Count := AContainer.ControlsCount;
  if Count = 0 then
  begin
    if Assigned(AOnFim) then AOnFim();
    Exit;
  end;

  // Animar em ordem reversa (último item primeiro)
  // O callback AOnFim é executado pelo PRIMEIRO item (o que aparece último na tela)
  for I := Count - 1 downto 0 do
  begin
    var Delay := (Count - 1 - I) * AStagger;
    var IsUltimo := (I = 0);

    if IsUltimo and Assigned(AOnFim) then
    begin
      // Último a ser animado executa o callback
      AnimarSaidaUnico(AContainer.Controls[I], Delay, ASlide, ADuracao, AOnFim);
    end
    else
    begin
      AnimarSaidaUnico(AContainer.Controls[I], Delay, ASlide, ADuracao, nil);
    end;
  end;
end;

// ============================================================
// EXEMPLO DE USO:
//
// // Saída simples com callback para destruir o componente:
// AnimarSaida(RecModal, procedure
// begin
//   RecModal.Visible := False;
//   // ou RecModal.Free; se quiser destruir
// end);
//
// // Saída de todos os itens de um layout antes de recarregar:
// AnimarSaidaTodos(LayoutItens, procedure
// begin
//   // Limpar e recarregar dados
//   for var I := LayoutItens.ControlsCount - 1 downto 0 do
//     LayoutItens.Controls[I].Free;
//   CarregarNovosDados;
//   AnimarEntrada(LayoutItens);
// end);
//
// // Substituição de painel com saída + entrada:
// AnimarSaida(PainelAtual, procedure
// begin
//   PainelAtual.Visible := False;
//   PainelNovo.Visible := True;
//   AnimarEntradaUnico(PainelNovo, 0);
// end);
// ============================================================

end.

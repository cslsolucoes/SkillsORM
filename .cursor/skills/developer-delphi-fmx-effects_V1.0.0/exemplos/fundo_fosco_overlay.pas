unit fundo_fosco_overlay;
// Padrão "Fundo Fosco" para modais FMX
// Combina TRectangle semitransparente + TBlurEffect no conteúdo abaixo

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Effects,
  FMX.Ani, FMX.Types, System.UITypes;

type
  // Contexto do overlay — guarda referências para abrir/fechar
  TOverlayFosco = record
    RecOverlay : TRectangle;   // retângulo escuro semitransparente
    BlurFundo  : TBlurEffect;  // blur aplicado ao conteúdo abaixo
  end;

// Abre overlay fosco sobre o formulário
// AConteudo   = painel/retângulo ABAIXO do modal (ex: RecConteudoPrincipal)
// AFormParent = parent do overlay (geralmente o próprio TForm)
// Retorna contexto para fechar depois
function AbrirFundoFosco(AConteudo: TControl;
  AFormParent: TFmxObject): TOverlayFosco;

// Fecha overlay com animação e callback opcional
procedure FecharFundoFosco(var ACtx: TOverlayFosco;
  AOnFim: TProc = nil);

implementation

function AbrirFundoFosco(AConteudo: TControl;
  AFormParent: TFmxObject): TOverlayFosco;
var
  Overlay : TRectangle;
  Blur    : TBlurEffect;
begin
  // 1. Criar overlay semitransparente
  //    Deve ser filho do form para cobrir TUDO
  Overlay := TRectangle.Create(AFormParent);
  Overlay.Parent := AFormParent;
  Overlay.Align  := TAlignLayout.Client; // ocupa o form inteiro
  Overlay.Fill.Color := $88000000;       // preto 53% opaco
  Overlay.Stroke.Kind := TBrushKind.None;
  Overlay.HitTest := True;  // bloqueia cliques no conteúdo abaixo
  Overlay.Opacity := 0;
  Overlay.Visible := True;

  // Animar entrada do overlay
  TAnimator.AnimateFloat(Overlay, 'Opacity', 1.0, 0.20,
    TAnimationType.Out, TInterpolationType.Cubic);

  // 2. Aplicar blur no CONTEÚDO (não no overlay!)
  //    O blur é aplicado ao conteúdo principal que fica ABAIXO
  Blur := TBlurEffect.Create(AConteudo);
  Blur.Parent   := AConteudo;
  Blur.Softness := 0;
  TAnimator.AnimateFloat(Blur, 'Softness', 6, 0.20,
    TAnimationType.Out, TInterpolationType.Cubic);

  // Retornar contexto para fechar depois
  Result.RecOverlay := Overlay;
  Result.BlurFundo   := Blur;
end;

procedure FecharFundoFosco(var ACtx: TOverlayFosco; AOnFim: TProc);
var
  Overlay : TRectangle;
  Blur    : TBlurEffect;
  Anim    : TFloatAnimation;
begin
  Overlay := ACtx.RecOverlay;
  Blur    := ACtx.BlurFundo;

  // Limpar referências imediatamente
  ACtx.RecOverlay := nil;
  ACtx.BlurFundo  := nil;

  if not Assigned(Overlay) then
  begin
    if Assigned(AOnFim) then AOnFim();
    Exit;
  end;

  // Animar saída do blur
  if Assigned(Blur) then
    TAnimator.AnimateFloat(Blur, 'Softness', 0, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);

  // Animar saída do overlay + destruir tudo no fim
  Anim := TFloatAnimation.Create(Overlay);
  Anim.Parent       := Overlay;
  Anim.PropertyName := 'Opacity';
  Anim.StartValue   := Overlay.Opacity;
  Anim.StopValue    := 0;
  Anim.Duration     := 0.20;
  Anim.OnFinish := procedure(Sender: TObject)
  begin
    if Assigned(Blur) then
      Blur.Free;
    Overlay.Free;
    Anim.Free;
    if Assigned(AOnFim) then AOnFim();
  end;
  Anim.Start;
end;

// ============================================================
// EXEMPLO DE USO COMPLETO:
//
// private
//   FOverlay: TOverlayFosco;
//   FModalContent: TRectangle;
//
// procedure TFormPrincipal.AbrirModal;
// begin
//   // 1. Abrir fundo fosco
//   FOverlay := AbrirFundoFosco(RecConteudoPrincipal, Self);
//
//   // 2. Criar/mostrar o modal por CIMA do overlay
//   FModalContent := TRectangle.Create(Self);
//   FModalContent.Parent := Self;
//   FModalContent.Position.X := 100;
//   FModalContent.Position.Y := 100;
//   FModalContent.Width  := 400;
//   FModalContent.Height := 300;
//   FModalContent.Fill.Color := claWhite;
//   FModalContent.XRadius := 12;
//   FModalContent.YRadius := 12;
//   // ... adicionar conteúdo ao modal
// end;
//
// procedure TFormPrincipal.FecharModal;
// begin
//   // 1. Destruir modal
//   FreeAndNil(FModalContent);
//
//   // 2. Fechar fundo fosco com callback
//   FecharFundoFosco(FOverlay, procedure
//   begin
//     // Executado após a animação de saída terminar
//     ShowMessage('Modal fechado!');
//   end);
// end;
//
// ESTRUTURA DE LAYERS (de baixo para cima):
//   TForm
//   └── RecConteudoPrincipal  ← TBlurEffect aplicado aqui
//       └── [conteúdo principal]
//   └── RecOverlay ($88000000, Align=Client, HitTest=True)
//   └── FModalContent (TRectangle branco, por cima de tudo)
//
// IMPORTANTE:
// - BlurEffect vai NO CONTEÚDO ABAIXO (não no overlay)
// - O overlay bloqueia cliques com HitTest=True
// - Salvar TOverlayFosco como variável de instância para fechar depois
// ============================================================

end.

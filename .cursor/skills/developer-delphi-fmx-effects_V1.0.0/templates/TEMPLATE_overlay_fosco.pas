unit TEMPLATE_overlay_fosco;
// TEMPLATE: Overlay fosco com blur para modais FMX
// Padrão completo: abrir/fechar overlay + gestão de ciclo de vida

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Effects,
  FMX.Ani, FMX.Types, System.UITypes;

// ============================================================
// COPIAR PARA O FORM:
// ============================================================
//
// private
//   FOverlayRect : TRectangle;
//   FBlurFundo   : TBlurEffect;
//   FModalContent: TRectangle; // ou TPanel/TFrame
//
// procedure AbrirOverlayFosco;
// procedure FecharOverlayFosco(AOnFim: TProc = nil);
// ============================================================

procedure DemoAbrirOverlayFosco(
  AConteudo: TControl;   // RecConteudoPrincipal (recebe o blur)
  AFormParent: TFmxObject; // Self (o form — parent do overlay)
  out AOverlay: TRectangle;
  out ABlur: TBlurEffect);

procedure DemoFecharOverlayFosco(
  var AOverlay: TRectangle;
  var ABlur: TBlurEffect;
  AOnFim: TProc = nil);

implementation

procedure DemoAbrirOverlayFosco(
  AConteudo: TControl;
  AFormParent: TFmxObject;
  out AOverlay: TRectangle;
  out ABlur: TBlurEffect);
begin
  // PASSO 1: overlay escuro semitransparente
  //   - Align=Client para cobrir o form inteiro
  //   - HitTest=True para bloquear cliques no conteúdo abaixo
  //   - Opacity inicia em 0 (animado para 1)
  AOverlay := TRectangle.Create(AFormParent);
  AOverlay.Parent          := AFormParent;
  AOverlay.Align           := TAlignLayout.Client;
  AOverlay.Fill.Color      := $88000000;  // preto 53%
  AOverlay.Stroke.Kind     := TBrushKind.None;
  AOverlay.HitTest         := True;
  AOverlay.Opacity         := 0;
  AOverlay.Visible         := True;

  TAnimator.AnimateFloat(AOverlay, 'Opacity', 1.0, 0.20,
    TAnimationType.Out, TInterpolationType.Cubic);

  // PASSO 2: blur no CONTEÚDO PRINCIPAL (abaixo do overlay)
  //   Aplicar em RecConteudoPrincipal — NÃO no overlay
  //   Simula "frosted glass"
  ABlur := TBlurEffect.Create(AConteudo);
  ABlur.Parent   := AConteudo;
  ABlur.Softness := 0;

  TAnimator.AnimateFloat(ABlur, 'Softness', 6, 0.20,
    TAnimationType.Out, TInterpolationType.Cubic);
end;

procedure DemoFecharOverlayFosco(
  var AOverlay: TRectangle;
  var ABlur: TBlurEffect;
  AOnFim: TProc);
var
  Overlay : TRectangle;
  Blur    : TBlurEffect;
  Anim    : TFloatAnimation;
begin
  Overlay := AOverlay;
  Blur    := ABlur;

  // Limpar referências imediatamente (guard contra double-free)
  AOverlay := nil;
  ABlur    := nil;

  if not Assigned(Overlay) then
  begin
    if Assigned(AOnFim) then AOnFim();
    Exit;
  end;

  // Remover blur com animação
  if Assigned(Blur) then
    TAnimator.AnimateFloat(Blur, 'Softness', 0, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);

  // Animar saída do overlay e destruir tudo no OnFinish
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
// EXEMPLO COMPLETO DE USO NO FORM:
//
// procedure TFormPrincipal.BtnAbrirModalClick(Sender: TObject);
// begin
//   // 1. Abrir overlay fosco
//   DemoAbrirOverlayFosco(
//     RecConteudoPrincipal, Self,
//     FOverlayRect, FBlurFundo);
//
//   // 2. Criar e posicionar o modal por CIMA do overlay
//   FModalContent := TRectangle.Create(Self);
//   FModalContent.Parent     := Self;
//   FModalContent.Width      := 480;
//   FModalContent.Height     := 320;
//   FModalContent.Position.X := (Self.Width  - FModalContent.Width)  / 2;
//   FModalContent.Position.Y := (Self.Height - FModalContent.Height) / 2;
//   FModalContent.Fill.Color := claWhite;
//   FModalContent.XRadius    := 16;
//   FModalContent.YRadius    := 16;
//   // Sombra no modal:
//   var S := TShadowEffect.Create(FModalContent);
//   S.Parent := FModalContent;
//   S.Softness := 0.5; S.Distance := 12; S.ShadowColor := $60000000;
//   FModalContent.ClipChildren := False;
//   // ... adicionar conteúdo ao modal ...
//
//   // Animar entrada do modal
//   FModalContent.Opacity := 0;
//   TAnimator.AnimateFloat(FModalContent, 'Opacity', 1.0, 0.20);
// end;
//
// procedure TFormPrincipal.FecharModal;
// begin
//   // 1. Animar saída do modal
//   TAnimator.AnimateFloat(FModalContent, 'Opacity', 0, 0.15);
//   TAnimator.AnimateFloatDelay(FModalContent, 'Position.Y',
//     FModalContent.Position.Y + 20, 0.15, 0.0);
//
//   // 2. Fechar overlay com callback para destruir modal
//   DemoFecharOverlayFosco(FOverlayRect, FBlurFundo, procedure
//   begin
//     FreeAndNil(FModalContent);
//   end);
// end;
//
// ESTRUTURA DE LAYERS (de baixo para cima, na ordem de criação):
//   TForm
//   +-- RecConteudoPrincipal  <-- TBlurEffect aqui
//       +-- [conteúdo principal: menus, tabs, grids...]
//   +-- FOverlayRect          <-- preto semitransparente, bloqueia cliques
//   +-- FModalContent         <-- modal branco, por cima de tudo
// ============================================================

end.

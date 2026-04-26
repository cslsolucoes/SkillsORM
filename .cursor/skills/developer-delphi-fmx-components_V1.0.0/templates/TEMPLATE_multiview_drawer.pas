unit TEMPLATE_multiview_drawer;
// TEMPLATE: Drawer lateral com TMultiView + animacao de conteudo
// Padrão GestorERP: menu lateral com navegação por módulos

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.MultiView,
  FMX.Ani, FMX.Types, System.UITypes, System.SysUtils;

// Configurar o MultiView como drawer lateral esquerdo
// AForm = TForm onde o MultiView está
// AMultiView = componente TMultiView do form
// ABtnHamburguer = botão que abre/fecha o drawer
procedure InicializarDrawer(
  AForm: TForm;
  AMultiView: TMultiView;
  ABtnHamburguer: TControl);

// Navegar para um módulo (fecha drawer + anima conteudo)
// AConteudoPrincipal = painel que recebe os módulos
// AModuloIndex = índice do módulo selecionado
procedure NavegarParaModulo(
  AMultiView: TMultiView;
  AConteudoPrincipal: TControl;
  AModuloIndex: Integer;
  AOnCarregarModulo: TProc<Integer>);

implementation

procedure InicializarDrawer(
  AForm: TForm;
  AMultiView: TMultiView;
  ABtnHamburguer: TControl);
begin
  // Modo drawer com sobreposição (padrão mobile)
  AMultiView.Mode := TMultiViewMode.Drawer;
  AMultiView.DrawerOptions.Placement     := TPlacement.Left;
  AMultiView.DrawerOptions.Overlap       := True;
  AMultiView.DrawerOptions.TouchAreaSize := 16;
  AMultiView.DrawerOptions.DurationSliding := 0.22;
  AMultiView.ShadowOptions.Enabled       := True;
  AMultiView.ShadowOptions.Color         := $60000000;

  // Registrar botão hambúrguer
  if Assigned(ABtnHamburguer) then
    AMultiView.MasterButton := ABtnHamburguer;
end;

procedure NavegarParaModulo(
  AMultiView: TMultiView;
  AConteudoPrincipal: TControl;
  AModuloIndex: Integer;
  AOnCarregarModulo: TProc<Integer>);
begin
  // 1. Fechar drawer
  if AMultiView.IsShown then
    AMultiView.HideMaster;

  // 2. Animar saída do conteúdo atual
  TAnimator.AnimateFloat(AConteudoPrincipal, 'Opacity', 0, 0.15,
    TAnimationType.Out, TInterpolationType.Cubic);

  // 3. Após a saída: carregar novo módulo + animar entrada
  TAnimator.AnimateFloatDelay(
    AConteudoPrincipal, 'Opacity', 0, 0.001, 0.15);

  var Anim := TFloatAnimation.Create(AConteudoPrincipal);
  Anim.Parent       := AConteudoPrincipal;
  Anim.PropertyName := 'Opacity';
  Anim.StartValue   := 0;
  Anim.StopValue    := 0;
  Anim.Duration     := 0.15;
  Anim.Delay        := 0.15;
  Anim.OnFinish := procedure(Sender: TObject)
  begin
    // Carregar novo módulo
    if Assigned(AOnCarregarModulo) then
      AOnCarregarModulo(AModuloIndex);

    // Animar entrada
    TAnimator.AnimateFloat(AConteudoPrincipal, 'Opacity', 1.0, 0.20,
      TAnimationType.Out, TInterpolationType.Cubic);

    Anim.Free;
  end;
  Anim.Start;
end;

// ============================================================
// USO NO FORM:
//
// procedure TFormPrincipal.FormCreate(Sender: TObject);
// begin
//   InicializarDrawer(Self, MultiView1, BtnHamburguer);
// end;
//
// procedure TFormPrincipal.LstMenuItemClick(const Sender: TObject;
//   const AItem: TListBoxItem);
// begin
//   NavegarParaModulo(MultiView1, RecConteudoPrincipal,
//     AItem.Tag,
//     procedure(const Idx: Integer)
//     begin
//       // Destruir frame atual
//       while RecConteudoPrincipal.ControlsCount > 0 do
//         RecConteudoPrincipal.Controls[0].Free;
//
//       // Criar frame do módulo
//       case Idx of
//         0: CriarFrameVendas(RecConteudoPrincipal);
//         1: CriarFrameEstoque(RecConteudoPrincipal);
//         2: CriarFrameFinanceiro(RecConteudoPrincipal);
//       end;
//     end);
// end;
//
// DICA: Atribuir Tag ao TListBoxItem no design-time:
//   LstMenuItemVendas.Tag    := 0;
//   LstMenuItemEstoque.Tag   := 1;
//   LstMenuItemFinanceiro.Tag := 2;
//
// ESTRUTURA RECOMENDADA NO .FMX:
//   TForm1
//   +-- TMultiView (Width=240, Align=Left)
//   |   +-- TRectangle (fundo do menu, Align=Client)
//   |       +-- RecMenuHeader (logo/avatar)
//   |       +-- TListBox (itens de menu, Align=Client)
//   +-- TLayout (Master)
//       Align = Client
//       +-- RecHeader (Align=Top, Height=56)
//       |   +-- BtnHamburguer
//       |   +-- LblTitulo
//       +-- RecConteudoPrincipal (Align=Client)
// ============================================================

end.

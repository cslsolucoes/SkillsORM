unit tmultiview_uso;
// TMultiView: navegação lateral (drawer), panel e popover em FMX

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.MultiView,
  FMX.Ani, FMX.Types, System.UITypes;

// Configurar MultiView como drawer lateral esquerdo
procedure ConfigurarDrawerEsquerdo(AMultiView: TMultiView;
  ABtnHamburguer: TControl);

// Configurar MultiView como drawer direito
procedure ConfigurarDrawerDireito(AMultiView: TMultiView;
  ABtnHamburguer: TControl);

// Abrir/fechar programaticamente
procedure AbrirDrawer(AMultiView: TMultiView);
procedure FecharDrawer(AMultiView: TMultiView);
procedure AlternarDrawer(AMultiView: TMultiView);

implementation

procedure ConfigurarDrawerEsquerdo(AMultiView: TMultiView;
  ABtnHamburguer: TControl);
begin
  // Modo Drawer: painel desliza por cima do conteúdo
  AMultiView.Mode := TMultiViewMode.Drawer;

  // Placement: à esquerda
  AMultiView.DrawerOptions.Placement := TPlacement.Left;

  // Drawer sobrepõe (não empurra) o conteúdo
  AMultiView.DrawerOptions.Overlap := True;

  // Área de swipe para abrir (em pixels, a partir da borda esquerda)
  AMultiView.DrawerOptions.TouchAreaSize := 16;

  // Sombra lateral ativada
  AMultiView.ShadowOptions.Enabled := True;
  AMultiView.ShadowOptions.Color   := $60000000;

  // Botão hambúrguer que controla o drawer
  if Assigned(ABtnHamburguer) then
    AMultiView.MasterButton := ABtnHamburguer;
end;

procedure ConfigurarDrawerDireito(AMultiView: TMultiView;
  ABtnHamburguer: TControl);
begin
  AMultiView.Mode := TMultiViewMode.Drawer;
  AMultiView.DrawerOptions.Placement     := TPlacement.Right;
  AMultiView.DrawerOptions.Overlap       := True;
  AMultiView.DrawerOptions.TouchAreaSize := 16;
  AMultiView.ShadowOptions.Enabled := True;
  AMultiView.ShadowOptions.Color   := $60000000;

  if Assigned(ABtnHamburguer) then
    AMultiView.MasterButton := ABtnHamburguer;
end;

procedure AbrirDrawer(AMultiView: TMultiView);
begin
  if not AMultiView.IsShown then
    AMultiView.ShowMaster;
end;

procedure FecharDrawer(AMultiView: TMultiView);
begin
  if AMultiView.IsShown then
    AMultiView.HideMaster;
end;

procedure AlternarDrawer(AMultiView: TMultiView);
begin
  if AMultiView.IsShown then
    AMultiView.HideMaster
  else
    AMultiView.ShowMaster;
end;

// ============================================================
// EXEMPLO DE USO:
//
// No FormCreate:
//   ConfigurarDrawerEsquerdo(MultiView1, BtnHamburguer);
//
// No click do hambúrguer (se não usar MasterButton):
//   AlternarDrawer(MultiView1);
//
// Para fechar ao clicar em item de menu:
//   procedure TFormPrincipal.ItemMenuClick(Sender: TObject);
//   begin
//     FecharDrawer(MultiView1);
//     NavegarPara(TItemSelecionado);
//   end;
//
// MODOS DE TMultiViewMode:
//   Drawer          — painel lateral deslizante
//   Panel           — painel fixo sempre visível (desktop)
//   Popover         — balão flutuante (iPad-like)
//   PlatformBehaviour — automático por plataforma
//
// ESTRUTURA ESPERADA NO .FMX:
//   TForm
//   +-- TMultiView (MultiView1)
//   |   +-- TLayout (conteúdo do menu)
//   |       +-- RecMenuHeader
//   |       +-- TListBox (itens de menu)
//   +-- TLayout (Master — conteúdo principal)
//       +-- RecHeader
//           +-- BtnHamburguer
//       +-- RecConteudoPrincipal
// ============================================================

end.

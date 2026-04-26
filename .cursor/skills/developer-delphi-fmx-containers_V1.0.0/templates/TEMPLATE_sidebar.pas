unit TEMPLATE_sidebar;
// TEMPLATE: Sidebar colapsável com TRectangle + Align=Left
// Padrão: sidebar fixa ou colapsável via animação de Width

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Layouts, FMX.StdCtrls,
  FMX.Ani, FMX.Types, System.UITypes;

type
  TFormSidebar = class(TForm)
  private
    RecSidebar: TRectangle;
    RecBody: TRectangle;
    BtnToggle: TRectangle;       // botão hamburguer na sidebar
    FSidebarAberta: Boolean;
    FSidebarWidth: Single;

    procedure CriarLayout;
    procedure CriarSidebar;
    procedure CriarBody;
    procedure OnToggleSidebar(Sender: TObject);
    procedure AdicionarItemMenu(const ATexto: string; AIconeCor: TAlphaColor;
      APosY: Single);
  public
    constructor Create(AOwner: TComponent); override;
  end;

const
  SIDEBAR_WIDTH_ABERTA   = 240;
  SIDEBAR_WIDTH_FECHADA  = 60;  // só ícones visíveis
  SIDEBAR_COR            = $FF2C3E50;
  BODY_COR               = $FFF5F6FA;
  ANIMATION_DURATION     = 0.25; // segundos

implementation

constructor TFormSidebar.Create(AOwner: TComponent);
begin
  inherited;
  FSidebarAberta := True;
  FSidebarWidth  := SIDEBAR_WIDTH_ABERTA;
  CriarLayout;
end;

procedure TFormSidebar.CriarLayout;
begin
  CriarSidebar;
  CriarBody;
end;

procedure TFormSidebar.CriarSidebar;
var
  LblLogo: TLabel;
  RecDivisor: TRectangle;
begin
  RecSidebar := TRectangle.Create(Self);
  RecSidebar.Parent := Self;
  RecSidebar.Align  := TAlignLayout.Left;
  RecSidebar.Width  := FSidebarWidth;
  RecSidebar.Fill.Color := SIDEBAR_COR;
  RecSidebar.Stroke.Kind := TBrushKind.None;

  // Logo / título da aplicação
  LblLogo := TLabel.Create(Self);
  LblLogo.Parent := RecSidebar;
  LblLogo.Position.X := 16;
  LblLogo.Position.Y := 20;
  LblLogo.Width  := RecSidebar.Width - 56; // espaço para o botão toggle
  LblLogo.Height := 36;
  LblLogo.Text   := 'GestorERP';
  LblLogo.TextSettings.Font.Size  := 16;
  LblLogo.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblLogo.TextSettings.FontColor  := $FFFFFFFF;
  LblLogo.TextSettings.HorzAlign  := TTextAlign.Leading;
  LblLogo.TextSettings.VertAlign  := TTextAlign.Center;
  LblLogo.AutoSize := False;

  // Botão toggle (hamburguer)
  BtnToggle := TRectangle.Create(Self);
  BtnToggle.Parent := RecSidebar;
  BtnToggle.Position.X := RecSidebar.Width - 44;
  BtnToggle.Position.Y := 18;
  BtnToggle.Width  := 36;
  BtnToggle.Height := 36;
  BtnToggle.Fill.Kind := TBrushKind.None;
  BtnToggle.Stroke.Kind := TBrushKind.None;
  BtnToggle.XRadius := 6; BtnToggle.YRadius := 6;
  BtnToggle.Cursor := crHandPoint;
  BtnToggle.OnClick := OnToggleSidebar;

  var LblHamburguer := TLabel.Create(Self);
  LblHamburguer.Parent := BtnToggle;
  LblHamburguer.Align  := TAlignLayout.Client;
  LblHamburguer.Text   := '☰';
  LblHamburguer.TextSettings.FontColor := $FFFFFFFF;
  LblHamburguer.TextSettings.Font.Size := 18;
  LblHamburguer.TextSettings.HorzAlign := TTextAlign.Center;
  LblHamburguer.TextSettings.VertAlign := TTextAlign.Center;
  LblHamburguer.AutoSize := False;

  // Divisor
  RecDivisor := TRectangle.Create(Self);
  RecDivisor.Parent := RecSidebar;
  RecDivisor.Position.X := 0;
  RecDivisor.Position.Y := 64;
  RecDivisor.Width  := RecSidebar.Width;
  RecDivisor.Height := 1;
  RecDivisor.Fill.Color := $40FFFFFF; // branco 25% transparente
  RecDivisor.Stroke.Kind := TBrushKind.None;

  // Itens do menu
  AdicionarItemMenu('Dashboard',    $FF3498DB, 80);
  AdicionarItemMenu('Clientes',     $FF27AE60, 124);
  AdicionarItemMenu('Produtos',     $FFE67E22, 168);
  AdicionarItemMenu('Financeiro',   $FF9B59B6, 212);
  AdicionarItemMenu('Configurações',$FF7F8C8D, 256);
end;

procedure TFormSidebar.AdicionarItemMenu(const ATexto: string;
  AIconeCor: TAlphaColor; APosY: Single);
var
  RecItem, RecIcone: TRectangle;
  LblTexto: TLabel;
begin
  RecItem := TRectangle.Create(Self);
  RecItem.Parent := RecSidebar;
  RecItem.Position.X := 0;
  RecItem.Position.Y := APosY;
  RecItem.Width  := RecSidebar.Width;
  RecItem.Height := 40;
  RecItem.Fill.Kind := TBrushKind.None;
  RecItem.Stroke.Kind := TBrushKind.None;
  RecItem.Cursor := crHandPoint;

  // Ícone colorido
  RecIcone := TRectangle.Create(Self);
  RecIcone.Parent := RecItem;
  RecIcone.Position.X := 14;
  RecIcone.Position.Y := 8;
  RecIcone.Width  := 24;
  RecIcone.Height := 24;
  RecIcone.Fill.Color := AIconeCor;
  RecIcone.Stroke.Kind := TBrushKind.None;
  RecIcone.XRadius := 6; RecIcone.YRadius := 6;

  // Texto do menu (visível apenas com sidebar aberta)
  LblTexto := TLabel.Create(Self);
  LblTexto.Parent := RecItem;
  LblTexto.Position.X := 48;
  LblTexto.Position.Y := 0;
  LblTexto.Width  := RecSidebar.Width - 56;
  LblTexto.Height := 40;
  LblTexto.Text   := ATexto;
  LblTexto.TextSettings.FontColor := $FFECF0F1;
  LblTexto.TextSettings.Font.Size := 13;
  LblTexto.TextSettings.HorzAlign := TTextAlign.Leading;
  LblTexto.TextSettings.VertAlign := TTextAlign.Center;
  LblTexto.AutoSize := False;

  // Hover: escurecer item ao passar o mouse
  RecItem.OnMouseEnter := procedure(Sender: TObject)
  begin
    (Sender as TRectangle).Fill.Kind  := TBrushKind.Solid;
    (Sender as TRectangle).Fill.Color := $20FFFFFF;
  end;
  RecItem.OnMouseLeave := procedure(Sender: TObject)
  begin
    (Sender as TRectangle).Fill.Kind := TBrushKind.None;
  end;
end;

procedure TFormSidebar.CriarBody;
var
  LblBemVindo: TLabel;
begin
  RecBody := TRectangle.Create(Self);
  RecBody.Parent := Self;
  RecBody.Align  := TAlignLayout.Client;
  RecBody.Fill.Color := BODY_COR;
  RecBody.Stroke.Kind := TBrushKind.None;
  RecBody.Padding.Left   := 24;
  RecBody.Padding.Top    := 24;
  RecBody.Padding.Right  := 24;
  RecBody.Padding.Bottom := 24;

  LblBemVindo := TLabel.Create(Self);
  LblBemVindo.Parent := RecBody;
  LblBemVindo.Align  := TAlignLayout.Top;
  LblBemVindo.Height := 40;
  LblBemVindo.Text   := 'Conteúdo principal';
  LblBemVindo.TextSettings.Font.Size  := 20;
  LblBemVindo.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblBemVindo.TextSettings.FontColor  := $FF2C3E50;
  LblBemVindo.AutoSize := False;
end;

procedure TFormSidebar.OnToggleSidebar(Sender: TObject);
var
  TargetWidth: Single;
begin
  FSidebarAberta := not FSidebarAberta;

  if FSidebarAberta then
    TargetWidth := SIDEBAR_WIDTH_ABERTA
  else
    TargetWidth := SIDEBAR_WIDTH_FECHADA;

  // Animação suave de largura
  TAnimator.AnimateFloat(RecSidebar, 'Width', TargetWidth, ANIMATION_DURATION,
    TAnimationType.Out, TInterpolationType.Cubic);
end;

end.

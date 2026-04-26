unit responsive_layout;
// Exemplo: layout responsivo ao resize do form
// Padrão: OnResize reposiciona/redimensiona elementos em Align=None
// Elementos com Align automático se ajustam sem código extra

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Layouts, FMX.StdCtrls,
  FMX.Types, System.UITypes, System.Classes;

type
  TFormResponsivo = class(TForm)
  private
    // Elementos com Align automático (sem código extra)
    RecHeader: TRectangle;      // Align=Top — se ajusta automaticamente
    RecSidebar: TRectangle;     // Align=Left — se ajusta automaticamente
    RecBody: TRectangle;        // Align=Client — se ajusta automaticamente

    // Elementos posicionados manualmente (precisam de OnResize)
    RecCard1: TRectangle;       // card flutuante (Align=None)
    RecCard2: TRectangle;       // card flutuante (Align=None)
    RecCard3: TRectangle;       // card flutuante (Align=None)

    procedure CriarLayout;
    procedure CriarCards;
    procedure AjustarCards;
    procedure FormResize(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

const
  HEADER_HEIGHT  = 60;
  SIDEBAR_WIDTH  = 200;
  CARD_HEIGHT    = 80;
  CARD_MARGIN    = 16;
  CARDS_PER_ROW  = 3;  // quantos cards por linha (responsivo quando < 600px → 2)

constructor TFormResponsivo.Create(AOwner: TComponent);
begin
  inherited;
  OnResize := FormResize;
  CriarLayout;
  CriarCards;
  AjustarCards; // posicionamento inicial
end;

procedure TFormResponsivo.CriarLayout;
begin
  // Header — Align=Top: largura automática, altura fixa
  RecHeader := TRectangle.Create(Self);
  RecHeader.Parent := Self;
  RecHeader.Align  := TAlignLayout.Top;
  RecHeader.Height := HEADER_HEIGHT;
  RecHeader.Fill.Color := $FF2C3E50;
  RecHeader.Stroke.Kind := TBrushKind.None;

  var Lbl := TLabel.Create(Self);
  Lbl.Parent := RecHeader;
  Lbl.Align  := TAlignLayout.Client;
  Lbl.Text   := 'Layout Responsivo — redimensione a janela';
  Lbl.TextSettings.FontColor := $FFFFFFFF;
  Lbl.TextSettings.Font.Size := 14;
  Lbl.TextSettings.HorzAlign := TTextAlign.Center;
  Lbl.TextSettings.VertAlign := TTextAlign.Center;
  Lbl.AutoSize := False;

  // Sidebar — Align=Left: largura fixa, altura automática
  RecSidebar := TRectangle.Create(Self);
  RecSidebar.Parent := Self;
  RecSidebar.Align  := TAlignLayout.Left;
  RecSidebar.Width  := SIDEBAR_WIDTH;
  RecSidebar.Fill.Color := $FF34495E;
  RecSidebar.Stroke.Kind := TBrushKind.None;

  // Body — Align=Client: ocupa o restante (sem código em OnResize!)
  RecBody := TRectangle.Create(Self);
  RecBody.Parent := Self;
  RecBody.Align  := TAlignLayout.Client;
  RecBody.Fill.Color := $FFF5F5F5;
  RecBody.Stroke.Kind := TBrushKind.None;
  RecBody.Padding.Left   := CARD_MARGIN;
  RecBody.Padding.Top    := CARD_MARGIN;
  RecBody.Padding.Right  := CARD_MARGIN;
  RecBody.Padding.Bottom := CARD_MARGIN;
end;

procedure TFormResponsivo.CriarCards;
  function NovoCard(ACor: TAlphaColor; const ATexto: string): TRectangle;
  var Lbl: TLabel;
  begin
    Result := TRectangle.Create(Self);
    Result.Parent := RecBody;
    Result.Align  := TAlignLayout.None; // posição manual → precisa de OnResize
    Result.Height := CARD_HEIGHT;
    Result.Fill.Color := ACor;
    Result.Stroke.Kind := TBrushKind.None;
    Result.XRadius := 8; Result.YRadius := 8;

    Lbl := TLabel.Create(Self);
    Lbl.Parent := Result;
    Lbl.Align  := TAlignLayout.Client;
    Lbl.Text   := ATexto;
    Lbl.TextSettings.FontColor := $FFFFFFFF;
    Lbl.TextSettings.Font.Style := [TFontStyle.fsBold];
    Lbl.TextSettings.HorzAlign := TTextAlign.Center;
    Lbl.TextSettings.VertAlign := TTextAlign.Center;
    Lbl.AutoSize := False;
  end;
begin
  RecCard1 := NovoCard($FF3498DB, 'Card 1');
  RecCard2 := NovoCard($FF27AE60, 'Card 2');
  RecCard3 := NovoCard($FFE74C3C, 'Card 3');
end;

procedure TFormResponsivo.AjustarCards;
var
  AreaLargura: Single;
  ColsCount: Integer;
  CardWidth: Single;
  X, Y: Single;
  I: Integer;
  Cards: array[0..2] of TRectangle;
begin
  // Largura disponível = RecBody.Width - 2*CARD_MARGIN (Padding já desconta)
  AreaLargura := RecBody.Width - CARD_MARGIN; // Padding.Right já está configurado

  // Layout responsivo: se a área for < 400px, 2 colunas; senão 3 colunas
  if AreaLargura < 400 then
    ColsCount := 2
  else
    ColsCount := CARDS_PER_ROW;

  // Largura de cada card = área disponível / colunas - espaço entre eles
  CardWidth := (AreaLargura - (ColsCount - 1) * CARD_MARGIN) / ColsCount;

  Cards[0] := RecCard1;
  Cards[1] := RecCard2;
  Cards[2] := RecCard3;

  for I := 0 to 2 do
  begin
    X := (I mod ColsCount) * (CardWidth + CARD_MARGIN);
    Y := (I div ColsCount) * (CARD_HEIGHT + CARD_MARGIN);

    Cards[I].Position.X := X;
    Cards[I].Position.Y := Y;
    Cards[I].Width      := CardWidth;
  end;
end;

procedure TFormResponsivo.FormResize(Sender: TObject);
begin
  // Align=Top, Left, Client se ajustam automaticamente — só reposicionar Align=None
  AjustarCards;
end;

end.

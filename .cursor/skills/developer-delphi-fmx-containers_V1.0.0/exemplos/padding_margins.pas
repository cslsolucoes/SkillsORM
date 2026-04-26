unit padding_margins;
// Exemplo: Padding vs Margins no FMX
// Padding = espaço INTERNO (entre borda do container e seus filhos)
// Margins = espaço EXTERNO (entre o componente e seus vizinhos/pai)

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Layouts, FMX.StdCtrls,
  FMX.Types, System.UITypes;

type
  TFormPaddingMargins = class(TForm)
  private
    procedure DemonstrarPadding;
    procedure DemonstrarMargins;
    procedure DemonstrarCombinado;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

constructor TFormPaddingMargins.Create(AOwner: TComponent);
begin
  inherited;
  DemonstrarPadding;
  DemonstrarMargins;
  DemonstrarCombinado;
end;

procedure TFormPaddingMargins.DemonstrarPadding;
var
  RecExterno, RecInterno: TRectangle;
  Lbl: TLabel;
begin
  // Container externo: Padding empurra os filhos para dentro
  RecExterno := TRectangle.Create(Self);
  RecExterno.Parent := Self;
  RecExterno.Position.X := 10;
  RecExterno.Position.Y := 10;
  RecExterno.Width  := 260;
  RecExterno.Height := 100;
  RecExterno.Fill.Color := $FF3498DB;
  RecExterno.Stroke.Kind := TBrushKind.None;
  RecExterno.XRadius := 8; RecExterno.YRadius := 8;

  // Padding interno: 16px em todos os lados
  // Os filhos só podem ocupar a área interna (Width-32 x Height-32)
  RecExterno.Padding.Left   := 16;
  RecExterno.Padding.Top    := 16;
  RecExterno.Padding.Right  := 16;
  RecExterno.Padding.Bottom := 16;

  // Filho com Align=Client ocupa apenas a área com padding descontado
  RecInterno := TRectangle.Create(Self);
  RecInterno.Parent := RecExterno;
  RecInterno.Align  := TAlignLayout.Client; // ocupa 228x68 (260-32 x 100-32)
  RecInterno.Fill.Color := $FFFFFFFF;
  RecInterno.Stroke.Kind := TBrushKind.None;
  RecInterno.XRadius := 4; RecInterno.YRadius := 4;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := RecInterno;
  Lbl.Align  := TAlignLayout.Client;
  Lbl.Text   := 'Padding: 16px em todos os lados';
  Lbl.TextSettings.HorzAlign := TTextAlign.Center;
  Lbl.TextSettings.VertAlign := TTextAlign.Center;
  Lbl.AutoSize := False;
end;

procedure TFormPaddingMargins.DemonstrarMargins;
var
  RecPai, RecA, RecB, RecC: TRectangle;
begin
  // Container pai com 3 filhos — cada filho tem Margins que cria espaçamento externo
  RecPai := TRectangle.Create(Self);
  RecPai.Parent := Self;
  RecPai.Position.X := 10;
  RecPai.Position.Y := 130;
  RecPai.Width  := 260;
  RecPai.Height := 120;
  RecPai.Fill.Color := $FFF0F0F0;
  RecPai.Stroke.Kind := TBrushKind.None;

  // Filho A — Margins.Bottom = 8 cria espaço embaixo dele
  RecA := TRectangle.Create(Self);
  RecA.Parent := RecPai;
  RecA.Align  := TAlignLayout.Top;
  RecA.Height := 30;
  RecA.Fill.Color := $FF27AE60;
  RecA.Stroke.Kind := TBrushKind.None;
  RecA.Margins.Bottom := 8; // 8px de espaço abaixo do RecA

  // Filho B — Margins em todos os lados
  RecB := TRectangle.Create(Self);
  RecB.Parent := RecPai;
  RecB.Align  := TAlignLayout.Top;
  RecB.Height := 30;
  RecB.Fill.Color := $FFE74C3C;
  RecB.Stroke.Kind := TBrushKind.None;
  RecB.Margins.Left   := 20; // recua 20px da esquerda
  RecB.Margins.Right  := 20; // recua 20px da direita
  RecB.Margins.Bottom := 8;

  // Filho C — sem margins para comparação
  RecC := TRectangle.Create(Self);
  RecC.Parent := RecPai;
  RecC.Align  := TAlignLayout.Top;
  RecC.Height := 30;
  RecC.Fill.Color := $FF9B59B6;
  RecC.Stroke.Kind := TBrushKind.None;
  // sem Margins — encosta direto no espaço disponível
end;

procedure TFormPaddingMargins.DemonstrarCombinado;
var
  RecCard: TRectangle;
  RecHeader: TRectangle;
  RecBody: TRectangle;
  LblTitulo, LblConteudo: TLabel;
begin
  // Card real: usa Padding no card + Margins nos elementos internos
  RecCard := TRectangle.Create(Self);
  RecCard.Parent := Self;
  RecCard.Position.X := 10;
  RecCard.Position.Y := 270;
  RecCard.Width  := 260;
  RecCard.Height := 140;
  RecCard.Fill.Color := $FFFFFFFF;
  RecCard.Stroke.Kind := TBrushKind.Solid;
  RecCard.Stroke.Color := $FFE0E0E0;
  RecCard.Stroke.Thickness := 1;
  RecCard.XRadius := 12; RecCard.YRadius := 12;

  // Header do card — sem padding, vai de borda a borda (cima/esq/dir)
  RecHeader := TRectangle.Create(Self);
  RecHeader.Parent := RecCard;
  RecHeader.Align  := TAlignLayout.Top;
  RecHeader.Height := 44;
  RecHeader.Fill.Color := $FF2C3E50;
  RecHeader.Stroke.Kind := TBrushKind.None;
  RecHeader.XRadius := 12; RecHeader.YRadius := 12;
  // Apenas cantos superiores arredondados
  RecHeader.Corners := [TCorner.TopLeft, TCorner.TopRight];

  LblTitulo := TLabel.Create(Self);
  LblTitulo.Parent := RecHeader;
  LblTitulo.Align  := TAlignLayout.Client;
  LblTitulo.Text   := 'Título do Card';
  LblTitulo.TextSettings.FontColor := $FFFFFFFF;
  LblTitulo.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblTitulo.TextSettings.HorzAlign := TTextAlign.Center;
  LblTitulo.TextSettings.VertAlign := TTextAlign.Center;
  LblTitulo.AutoSize := False;

  // Body do card — usa Padding para espaçamento interno
  RecBody := TRectangle.Create(Self);
  RecBody.Parent := RecCard;
  RecBody.Align  := TAlignLayout.Client;
  RecBody.Fill.Kind := TBrushKind.None;
  RecBody.Stroke.Kind := TBrushKind.None;
  RecBody.Padding.Left   := 16;
  RecBody.Padding.Top    := 12;
  RecBody.Padding.Right  := 16;
  RecBody.Padding.Bottom := 12;

  LblConteudo := TLabel.Create(Self);
  LblConteudo.Parent := RecBody;
  LblConteudo.Align  := TAlignLayout.Client;
  LblConteudo.Text   := 'Conteúdo do card com Padding interno de 16px e o header sem padding para ir de borda a borda.';
  LblConteudo.TextSettings.Font.Size := 12;
  LblConteudo.TextSettings.FontColor := $FF555555;
  LblConteudo.TextSettings.WordWrap  := True;
  LblConteudo.TextSettings.HorzAlign := TTextAlign.Leading;
  LblConteudo.TextSettings.VertAlign := TTextAlign.Leading;
  LblConteudo.AutoSize := False;
end;

end.

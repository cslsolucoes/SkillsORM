unit TEMPLATE_card_layout;
// TEMPLATE: Card com sombra, rounded corners, padding e header opcional
// Uso: copiar CriarCard() e adaptar cores/textos para o projeto

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Layouts, FMX.StdCtrls,
  FMX.Effects, FMX.Types, System.UITypes;

// ============================================================
// FUNÇÃO UTILITÁRIA: CriarCard
// Retorna TRectangle configurado como card pronto para uso
// ============================================================
// Parâmetros:
//   AOwner   — dono dos componentes criados (para limpeza automática)
//   AParent  — container pai onde o card será inserido
//   AX, AY   — posição (quando Align=None)
//   AW, AH   — largura e altura do card
//   AComSombra — True = adiciona TShadowEffect
// ============================================================

type
  TFormCardTemplate = class(TForm)
  public
    // Cria um card completo com sombra e padding
    function CriarCard(AOwner: TComponent; AParent: TControl;
      AX, AY, AW, AH: Single; AComSombra: Boolean = True): TRectangle;

    // Cria um card com header colorido + área de conteúdo
    function CriarCardComHeader(AOwner: TComponent; AParent: TControl;
      AX, AY, AW, AH: Single;
      const ATitulo: string;
      ACorHeader: TAlphaColor = $FF2C3E50): TRectangle;
  end;

implementation

function TFormCardTemplate.CriarCard(AOwner: TComponent; AParent: TControl;
  AX, AY, AW, AH: Single; AComSombra: Boolean): TRectangle;
var
  Sombra: TShadowEffect;
begin
  Result := TRectangle.Create(AOwner);
  Result.Parent := AParent;

  // Posição e tamanho
  Result.Position.X := AX;
  Result.Position.Y := AY;
  Result.Width      := AW;
  Result.Height     := AH;

  // Visual
  Result.Fill.Color := $FFFFFFFF;         // fundo branco
  Result.Stroke.Kind := TBrushKind.Solid;
  Result.Stroke.Color := $FFE8E8E8;       // borda cinza muito clara
  Result.Stroke.Thickness := 1;
  Result.XRadius := 12;
  Result.YRadius := 12;

  // Sombra sutil
  if AComSombra then
  begin
    Result.ClipChildren := False;         // OBRIGATÓRIO para sombra extrapolar
    Sombra := TShadowEffect.Create(AOwner);
    Sombra.Parent    := Result;
    Sombra.ShadowColor := $40000000;      // preto 25% transparente
    Sombra.Direction  := 315;             // diagonal inferior direita
    Sombra.Distance   := 4;
    Sombra.Softness   := 0.3;
    Sombra.Enabled    := True;
  end;

  // Padding interno para conteúdo
  Result.Padding.Left   := 16;
  Result.Padding.Top    := 16;
  Result.Padding.Right  := 16;
  Result.Padding.Bottom := 16;
end;

function TFormCardTemplate.CriarCardComHeader(AOwner: TComponent;
  AParent: TControl; AX, AY, AW, AH: Single;
  const ATitulo: string; ACorHeader: TAlphaColor): TRectangle;
var
  RecHeader: TRectangle;
  RecBody: TRectangle;
  LblTitulo: TLabel;
  Sombra: TShadowEffect;
begin
  // Card raiz (sem padding — o padding será no body)
  Result := TRectangle.Create(AOwner);
  Result.Parent := AParent;
  Result.Position.X := AX;
  Result.Position.Y := AY;
  Result.Width      := AW;
  Result.Height     := AH;
  Result.Fill.Color := $FFFFFFFF;
  Result.Stroke.Kind := TBrushKind.None;
  Result.XRadius := 12;
  Result.YRadius := 12;
  Result.ClipChildren := True;  // clip para rounded corners funcionar no header

  // Sombra no card raiz
  Result.ClipChildren := False; // precisa ser False para sombra
  Sombra := TShadowEffect.Create(AOwner);
  Sombra.Parent    := Result;
  Sombra.ShadowColor := $30000000;
  Sombra.Direction  := 315;
  Sombra.Distance   := 3;
  Sombra.Softness   := 0.25;

  // Header colorido — ocupa a largura total, sem padding
  RecHeader := TRectangle.Create(AOwner);
  RecHeader.Parent := Result;
  RecHeader.Align  := TAlignLayout.Top;
  RecHeader.Height := 44;
  RecHeader.Fill.Color := ACorHeader;
  RecHeader.Stroke.Kind := TBrushKind.None;
  RecHeader.XRadius := 12; RecHeader.YRadius := 12;
  RecHeader.Corners := [TCorner.TopLeft, TCorner.TopRight]; // só cantos superiores

  LblTitulo := TLabel.Create(AOwner);
  LblTitulo.Parent := RecHeader;
  LblTitulo.Align  := TAlignLayout.Client;
  LblTitulo.Text   := ATitulo;
  LblTitulo.TextSettings.FontColor := $FFFFFFFF;
  LblTitulo.TextSettings.Font.Size := 14;
  LblTitulo.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblTitulo.TextSettings.HorzAlign := TTextAlign.Center;
  LblTitulo.TextSettings.VertAlign := TTextAlign.Center;
  LblTitulo.AutoSize := False;

  // Body com padding para o conteúdo
  RecBody := TRectangle.Create(AOwner);
  RecBody.Parent := Result;
  RecBody.Align  := TAlignLayout.Client;
  RecBody.Fill.Kind := TBrushKind.None;
  RecBody.Stroke.Kind := TBrushKind.None;
  RecBody.Padding.Left   := 16;
  RecBody.Padding.Top    := 12;
  RecBody.Padding.Right  := 16;
  RecBody.Padding.Bottom := 12;

  // Adicionar conteúdo em RecBody.Children[] ou como filho de RecBody
  // Ex: LblConteudo.Parent := RecBody;
end;

end.

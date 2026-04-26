unit animacao_cascata;
// Exemplo: animação em cascata (stagger) — N itens com delay crescente

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Layouts, FMX.StdCtrls,
  FMX.Ani, FMX.Types, System.UITypes;

type
  TFormAnimacaoCascata = class(TForm)
  private
    LayoutItens: TLayout;
    procedure CriarItens;
    procedure AnimarCascata;
    procedure AnimarSaida;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

const
  ITEM_COUNT  = 6;
  ITEM_HEIGHT = 64;
  ITEM_GAP    = 8;
  STAGGER_MS  = 0.06; // delay entre cada item em segundos

constructor TFormAnimacaoCascata.Create(AOwner: TComponent);
begin
  inherited;
  CriarItens;
  AnimarCascata;
end;

procedure TFormAnimacaoCascata.CriarItens;
var
  RecFundo: TRectangle;
  Scroll: TVertScrollBox;
  I: Integer;
  RecItem: TRectangle;
  LblTitulo, LblSub: TLabel;
  Cores: array[0..5] of TAlphaColor;
begin
  Cores[0] := $FF3498DB;
  Cores[1] := $FF27AE60;
  Cores[2] := $FFE74C3C;
  Cores[3] := $FF9B59B6;
  Cores[4] := $FFE67E22;
  Cores[5] := $FF1ABC9C;

  // Container de fundo
  RecFundo := TRectangle.Create(Self);
  RecFundo.Parent := Self;
  RecFundo.Align  := TAlignLayout.Client;
  RecFundo.Fill.Color := $FFF5F6FA;
  RecFundo.Stroke.Kind := TBrushKind.None;
  RecFundo.Padding.Left   := 16;
  RecFundo.Padding.Top    := 16;
  RecFundo.Padding.Right  := 16;
  RecFundo.Padding.Bottom := 16;

  Scroll := TVertScrollBox.Create(Self);
  Scroll.Parent := RecFundo;
  Scroll.Align  := TAlignLayout.Client;

  LayoutItens := TLayout.Create(Self);
  LayoutItens.Parent := Scroll;
  LayoutItens.Align  := TAlignLayout.Top;
  LayoutItens.Height := ITEM_COUNT * (ITEM_HEIGHT + ITEM_GAP);

  for I := 0 to ITEM_COUNT - 1 do
  begin
    RecItem := TRectangle.Create(Self);
    RecItem.Parent := LayoutItens;
    RecItem.Align  := TAlignLayout.Top;
    RecItem.Height := ITEM_HEIGHT;
    RecItem.Fill.Color := $FFFFFFFF;
    RecItem.Stroke.Kind := TBrushKind.Solid;
    RecItem.Stroke.Color := $FFE8E8E8;
    RecItem.Stroke.Thickness := 1;
    RecItem.XRadius := 8; RecItem.YRadius := 8;
    RecItem.Margins.Bottom := ITEM_GAP;

    // Barra colorida lateral
    var RecBarra := TRectangle.Create(Self);
    RecBarra.Parent := RecItem;
    RecBarra.Align  := TAlignLayout.Left;
    RecBarra.Width  := 4;
    RecBarra.Fill.Color := Cores[I mod Length(Cores)];
    RecBarra.Stroke.Kind := TBrushKind.None;
    RecBarra.XRadius := 4; RecBarra.YRadius := 4;
    RecBarra.Corners := [TCorner.TopLeft, TCorner.BottomLeft];

    // Textos
    var RecTextos := TRectangle.Create(Self);
    RecTextos.Parent := RecItem;
    RecTextos.Align  := TAlignLayout.Client;
    RecTextos.Fill.Kind := TBrushKind.None;
    RecTextos.Stroke.Kind := TBrushKind.None;
    RecTextos.Padding.Left := 12;
    RecTextos.Padding.Top  := 10;

    LblTitulo := TLabel.Create(Self);
    LblTitulo.Parent := RecTextos;
    LblTitulo.Align  := TAlignLayout.Top;
    LblTitulo.Height := 22;
    LblTitulo.Text   := 'Item ' + IntToStr(I + 1);
    LblTitulo.TextSettings.Font.Style := [TFontStyle.fsBold];
    LblTitulo.TextSettings.Font.Size  := 14;
    LblTitulo.TextSettings.FontColor  := $FF333333;
    LblTitulo.AutoSize := False;

    LblSub := TLabel.Create(Self);
    LblSub.Parent := RecTextos;
    LblSub.Align  := TAlignLayout.Top;
    LblSub.Height := 18;
    LblSub.Text   := 'Subtítulo do item número ' + IntToStr(I + 1);
    LblSub.TextSettings.Font.Size  := 11;
    LblSub.TextSettings.FontColor  := $FF999999;
    LblSub.AutoSize := False;
  end;
end;

procedure TFormAnimacaoCascata.AnimarCascata;
var
  I: Integer;
  Ctrl: TControl;
  OriginalY: Single;
begin
  // Animar cada item: fade in + slide up, com delay crescente
  for I := 0 to LayoutItens.ControlsCount - 1 do
  begin
    Ctrl := LayoutItens.Controls[I];
    Ctrl.Opacity := 0;

    // Guardar Y original e deslocar para baixo
    OriginalY := Ctrl.Position.Y;
    Ctrl.Position.Y := OriginalY + 20;

    // Fade in com stagger
    TAnimator.AnimateFloatDelay(Ctrl, 'Opacity', 1.0, 0.3, I * STAGGER_MS);

    // Slide up de volta para posição original
    TAnimator.AnimateFloatDelay(Ctrl, 'Position.Y', OriginalY, 0.3,
      I * STAGGER_MS,
      TAnimationType.Out, TInterpolationType.Cubic);
  end;
end;

procedure TFormAnimacaoCascata.AnimarSaida;
var
  I: Integer;
  Ctrl: TControl;
begin
  // Animação de saída: fade out + slide down, ordem inversa
  for I := LayoutItens.ControlsCount - 1 downto 0 do
  begin
    var DelayIdx := LayoutItens.ControlsCount - 1 - I;
    Ctrl := LayoutItens.Controls[I];

    TAnimator.AnimateFloatDelay(Ctrl, 'Opacity', 0, 0.2,
      DelayIdx * (STAGGER_MS * 0.5));
    TAnimator.AnimateFloatDelay(Ctrl, 'Position.Y',
      Ctrl.Position.Y + 16, 0.2,
      DelayIdx * (STAGGER_MS * 0.5),
      TAnimationType.In, TInterpolationType.Cubic);
  end;
end;

end.

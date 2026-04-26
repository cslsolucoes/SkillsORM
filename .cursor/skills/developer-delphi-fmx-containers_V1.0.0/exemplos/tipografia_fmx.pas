unit tipografia_fmx;
// Exemplo: tipografia FMX — TLabel, TText, TextSettings, FontFamily, WordWrap
// Demonstra hierarquia de tamanhos e cores do projeto GestorERP

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Layouts, FMX.StdCtrls,
  FMX.Types, System.UITypes;

type
  TFormTipografia = class(TForm)
  private
    procedure DemonstrarLabels;
  public
    constructor Create(AOwner: TComponent); override;
  end;

const
  FONT_TITULO    = 22;
  FONT_SUBTITULO = 16;
  FONT_CORPO     = 13;
  FONT_CAPTION   = 11;

  COR_TEXTO_PRINCIPAL  = $FF222222;
  COR_TEXTO_SECUNDARIO = $FF999999;
  COR_TEXTO_CLARO      = $FFFFFFFF;
  COR_TEXTO_DESTAQUE   = $FF4A90E2;

implementation

constructor TFormTipografia.Create(AOwner: TComponent);
begin
  inherited;
  DemonstrarLabels;
end;

procedure TFormTipografia.DemonstrarLabels;
var
  RecFundo: TRectangle;
  LblTitulo, LblSub, LblCorpo, LblCaption: TLabel;
  TxtBold: TText;

  function NovoLabel(const AText: string; AFontSize: Single;
    AColor: TAlphaColor; ABold: Boolean; Y: Single): TLabel;
  begin
    Result := TLabel.Create(Self);
    Result.Parent := RecFundo;
    Result.Position.X := 20;
    Result.Position.Y := Y;
    Result.Width := RecFundo.Width - 40;
    Result.Height := AFontSize + 10;
    Result.Text := AText;
    Result.TextSettings.Font.Family := 'Segoe UI';
    Result.TextSettings.Font.Size   := AFontSize;
    Result.TextSettings.FontColor   := AColor;
    Result.TextSettings.HorzAlign   := TTextAlign.Leading;
    Result.TextSettings.VertAlign   := TTextAlign.Center;
    Result.TextSettings.WordWrap    := False;
    Result.AutoSize := False;
    if ABold then
      Result.TextSettings.Font.Style := [TFontStyle.fsBold];
  end;

begin
  RecFundo := TRectangle.Create(Self);
  RecFundo.Parent := Self;
  RecFundo.Align  := TAlignLayout.Client;
  RecFundo.Fill.Color := $FFFFFFFF;
  RecFundo.Stroke.Kind := TBrushKind.None;
  RecFundo.Padding.Left := 20;
  RecFundo.Padding.Top  := 20;

  // Hierarquia tipográfica
  NovoLabel('Título da Tela (22px Bold)',     FONT_TITULO,    COR_TEXTO_PRINCIPAL, True, 20);
  NovoLabel('Subtítulo / KPI Label (16px)',   FONT_SUBTITULO, COR_TEXTO_PRINCIPAL, False, 60);
  NovoLabel('Texto de corpo (13px)',          FONT_CORPO,     COR_TEXTO_PRINCIPAL, False, 90);
  NovoLabel('Caption / metadado (11px)',      FONT_CAPTION,   COR_TEXTO_SECUNDARIO, False, 115);
  NovoLabel('Link / ação destaque (13px)',    FONT_CORPO,     COR_TEXTO_DESTAQUE, False, 140);

  // TLabel com WordWrap
  var LblWrap := TLabel.Create(Self);
  LblWrap.Parent := RecFundo;
  LblWrap.Position.X := 20;
  LblWrap.Position.Y := 170;
  LblWrap.Width  := 300;
  LblWrap.Height := 60;
  LblWrap.Text := 'Este é um texto longo que deve quebrar automaticamente em múltiplas linhas quando WordWrap estiver habilitado.';
  LblWrap.TextSettings.Font.Size := FONT_CORPO;
  LblWrap.TextSettings.FontColor := COR_TEXTO_PRINCIPAL;
  LblWrap.TextSettings.WordWrap  := True;
  LblWrap.AutoSize := False;
end;

end.

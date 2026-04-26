unit TEMPLATE_header_footer;
// TEMPLATE: Header fixo + Footer fixo + Conteúdo scrollável
// Estrutura padrão para telas do GestorERP

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Layouts, FMX.StdCtrls,
  FMX.Types, System.UITypes;

// ============================================================
// ESTRUTURA DO LAYOUT:
//
//  ┌─────────────────────────────────┐ ← RecFundo (Client)
//  │ RecHeader (Top, Height=76)      │
//  │  LblTitulo (Client)             │
//  │  BtnVoltar (Left, Width=48)     │
//  ├─────────────────────────────────┤
//  │ ScrollConteudo (Client)         │
//  │  LayoutItens (Top, grows)       │
//  │    [cards, formulários, etc.]   │
//  ├─────────────────────────────────┤
//  │ RecFooter (Bottom, Height=64)   │
//  │  BtnSalvar  (Right)             │
//  │  BtnCancelar (Right)            │
//  └─────────────────────────────────┘
//
// REGRA: criar Bottom ANTES de Client para Align funcionar
// ============================================================

type
  TFormHeaderFooter = class(TForm)
  protected
    // Containers
    RecFundo: TRectangle;
    RecHeader: TRectangle;
    RecFooter: TRectangle;
    ScrollConteudo: TVertScrollBox;
    LayoutItens: TLayout;

    // Controles do header
    LblTitulo: TLabel;
    BtnVoltar: TRectangle;

    // Controles do footer
    BtnSalvar: TRectangle;
    BtnCancelar: TRectangle;

    procedure CriarEstrutura;
    procedure CriarHeader(const ATitulo: string; AComBotaoVoltar: Boolean);
    procedure CriarFooter(AComBotaoSalvar: Boolean; AComBotaoCancelar: Boolean);
    procedure CriarScroll;

    // Sobrescrever para popular o conteúdo
    procedure PreencherConteudo; virtual;

    // Eventos — sobrescrever nas telas filhas
    procedure OnBtnVoltarClick(Sender: TObject); virtual;
    procedure OnBtnSalvarClick(Sender: TObject); virtual;
    procedure OnBtnCancelarClick(Sender: TObject); virtual;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

constructor TFormHeaderFooter.Create(AOwner: TComponent);
begin
  inherited;
  CriarEstrutura;
  PreencherConteudo;
end;

procedure TFormHeaderFooter.CriarEstrutura;
begin
  // Container raiz
  RecFundo := TRectangle.Create(Self);
  RecFundo.Parent := Self;
  RecFundo.Align  := TAlignLayout.Client;
  RecFundo.Fill.Color := $FFF5F6FA;
  RecFundo.Stroke.Kind := TBrushKind.None;

  CriarHeader('Título da Tela', True);
  CriarFooter(True, True);  // Footer ANTES de Client!
  CriarScroll;
end;

procedure TFormHeaderFooter.CriarHeader(const ATitulo: string;
  AComBotaoVoltar: Boolean);
var
  RecLinhaInferior: TRectangle;
begin
  RecHeader := TRectangle.Create(Self);
  RecHeader.Parent := RecFundo;
  RecHeader.Align  := TAlignLayout.Top;
  RecHeader.Height := 76;
  RecHeader.Fill.Color := $FF2C3E50;
  RecHeader.Stroke.Kind := TBrushKind.None;

  // Botão voltar (opcional, à esquerda)
  if AComBotaoVoltar then
  begin
    BtnVoltar := TRectangle.Create(Self);
    BtnVoltar.Parent := RecHeader;
    BtnVoltar.Align  := TAlignLayout.Left;
    BtnVoltar.Width  := 60;
    BtnVoltar.Fill.Kind := TBrushKind.None;
    BtnVoltar.Stroke.Kind := TBrushKind.None;
    BtnVoltar.Cursor := crHandPoint;
    BtnVoltar.OnClick := OnBtnVoltarClick;

    var LblSeta := TLabel.Create(Self);
    LblSeta.Parent := BtnVoltar;
    LblSeta.Align  := TAlignLayout.Client;
    LblSeta.Text   := '←';
    LblSeta.TextSettings.FontColor := $FFFFFFFF;
    LblSeta.TextSettings.Font.Size := 20;
    LblSeta.TextSettings.HorzAlign := TTextAlign.Center;
    LblSeta.TextSettings.VertAlign := TTextAlign.Center;
    LblSeta.AutoSize := False;
  end;

  // Título centralizado
  LblTitulo := TLabel.Create(Self);
  LblTitulo.Parent := RecHeader;
  LblTitulo.Align  := TAlignLayout.Client;
  LblTitulo.Text   := ATitulo;
  LblTitulo.TextSettings.Font.Size  := 18;
  LblTitulo.TextSettings.Font.Style := [TFontStyle.fsBold];
  LblTitulo.TextSettings.FontColor  := $FFFFFFFF;
  LblTitulo.TextSettings.HorzAlign  := TTextAlign.Center;
  LblTitulo.TextSettings.VertAlign  := TTextAlign.Center;
  LblTitulo.AutoSize := False;

  // Linha inferior do header (separador sutil)
  RecLinhaInferior := TRectangle.Create(Self);
  RecLinhaInferior.Parent := RecHeader;
  RecLinhaInferior.Align  := TAlignLayout.Bottom;
  RecLinhaInferior.Height := 1;
  RecLinhaInferior.Fill.Color := $20000000;
  RecLinhaInferior.Stroke.Kind := TBrushKind.None;
end;

procedure TFormHeaderFooter.CriarFooter(AComBotaoSalvar: Boolean;
  AComBotaoCancelar: Boolean);
  function NovoBotao(const ATexto: string; ACorFundo: TAlphaColor;
    ACorTexto: TAlphaColor; AWidth: Single): TRectangle;
  var Lbl: TLabel;
  begin
    Result := TRectangle.Create(Self);
    Result.Parent := RecFooter;
    Result.Align  := TAlignLayout.Right;
    Result.Width  := AWidth;
    Result.Margins.Right := 12;
    Result.Margins.Top   := 12;
    Result.Margins.Bottom := 12;
    Result.Fill.Color := ACorFundo;
    Result.Stroke.Kind := TBrushKind.None;
    Result.XRadius := 8; Result.YRadius := 8;
    Result.Cursor := crHandPoint;

    Lbl := TLabel.Create(Self);
    Lbl.Parent := Result;
    Lbl.Align  := TAlignLayout.Client;
    Lbl.Text   := ATexto;
    Lbl.TextSettings.FontColor := ACorTexto;
    Lbl.TextSettings.Font.Style := [TFontStyle.fsBold];
    Lbl.TextSettings.HorzAlign  := TTextAlign.Center;
    Lbl.TextSettings.VertAlign  := TTextAlign.Center;
    Lbl.AutoSize := False;
  end;
begin
  RecFooter := TRectangle.Create(Self);
  RecFooter.Parent := RecFundo;
  RecFooter.Align  := TAlignLayout.Bottom; // OBRIGATÓRIO: criar antes do Client
  RecFooter.Height := 64;
  RecFooter.Fill.Color := $FFFFFFFF;
  RecFooter.Stroke.Kind := TBrushKind.Solid;
  RecFooter.Stroke.Color := $FFE8E8E8;
  RecFooter.Stroke.Thickness := 1;
  // Só borda superior
  RecFooter.Sides := [TSide.Top];

  if AComBotaoSalvar then
  begin
    BtnSalvar := NovoBotao('Salvar', $FF27AE60, $FFFFFFFF, 100);
    BtnSalvar.OnClick := OnBtnSalvarClick;
  end;

  if AComBotaoCancelar then
  begin
    BtnCancelar := NovoBotao('Cancelar', $FFF0F0F0, $FF555555, 100);
    BtnCancelar.OnClick := OnBtnCancelarClick;
  end;
end;

procedure TFormHeaderFooter.CriarScroll;
begin
  ScrollConteudo := TVertScrollBox.Create(Self);
  ScrollConteudo.Parent := RecFundo;
  ScrollConteudo.Align  := TAlignLayout.Client; // ocupa o restante
  ScrollConteudo.ShowScrollBars := True;

  LayoutItens := TLayout.Create(Self);
  LayoutItens.Parent := ScrollConteudo;
  LayoutItens.Align  := TAlignLayout.Top;
  LayoutItens.Height := 0;  // cresce conforme filhos são adicionados
  LayoutItens.Padding.Left   := 16;
  LayoutItens.Padding.Top    := 16;
  LayoutItens.Padding.Right  := 16;
  LayoutItens.Padding.Bottom := 24;
end;

procedure TFormHeaderFooter.PreencherConteudo;
begin
  // Override nas telas filhas:
  // var Rec := TRectangle.Create(Self);
  // Rec.Parent := LayoutItens;
  // Rec.Align  := TAlignLayout.Top;
  // Rec.Height := 80;
  // ...
end;

procedure TFormHeaderFooter.OnBtnVoltarClick(Sender: TObject);
begin
  Close;
end;

procedure TFormHeaderFooter.OnBtnSalvarClick(Sender: TObject);
begin
  // Override para implementar save
end;

procedure TFormHeaderFooter.OnBtnCancelarClick(Sender: TObject);
begin
  Close;
end;

end.

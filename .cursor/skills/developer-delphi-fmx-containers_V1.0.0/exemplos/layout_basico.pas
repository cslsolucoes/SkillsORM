unit layout_basico;
// Exemplo: estrutura básica de tela FMX com Header + Conteúdo + Footer
// Compilar com: dcc32 ou dcc64

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Layouts, FMX.StdCtrls,
  FMX.Types, System.UITypes;

type
  TFormLayoutBasico = class(TForm)
  private
    RecFundo: TRectangle;          // container raiz
    RecHeader: TRectangle;         // toolbar superior
    RecFooter: TRectangle;         // barra de ações inferior
    ScrollConteudo: TVertScrollBox;// área scrollável central
    LayoutItens: TLayout;          // organizador de itens no scroll
    LblTitulo: TLabel;             // título no header
    procedure CriarLayout;
    procedure CriarHeader;
    procedure CriarFooter;
    procedure CriarConteudo;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{ TFormLayoutBasico }

constructor TFormLayoutBasico.Create(AOwner: TComponent);
begin
  inherited;
  CriarLayout;
end;

procedure TFormLayoutBasico.CriarLayout;
begin
  // Container raiz que preenche o form inteiro
  RecFundo := TRectangle.Create(Self);
  RecFundo.Parent := Self;
  RecFundo.Align  := TAlignLayout.Client;
  RecFundo.Fill.Color := $FFF2F2F2;         // cinza suave
  RecFundo.Stroke.Kind := TBrushKind.None;

  CriarHeader;
  CriarFooter;   // Footer ANTES de Client para Align funcionar corretamente
  CriarConteudo; // Client ocupa o restante após Top e Bottom
end;

procedure TFormLayoutBasico.CriarHeader;
begin
  RecHeader := TRectangle.Create(Self);
  RecHeader.Parent := RecFundo;
  RecHeader.Align  := TAlignLayout.Top;
  RecHeader.Height := 76;
  RecHeader.Fill.Color := $FF2C3E50;        // azul escuro
  RecHeader.Stroke.Kind := TBrushKind.None;

  LblTitulo := TLabel.Create(Self);
  LblTitulo.Parent := RecHeader;
  LblTitulo.Align  := TAlignLayout.Client;
  LblTitulo.Text   := 'Título da Tela';
  LblTitulo.TextSettings.Font.Size   := 18;
  LblTitulo.TextSettings.Font.Style  := [TFontStyle.fsBold];
  LblTitulo.TextSettings.FontColor   := $FFFFFFFF;
  LblTitulo.TextSettings.HorzAlign   := TTextAlign.Center;
  LblTitulo.TextSettings.VertAlign   := TTextAlign.Center;
  LblTitulo.AutoSize := False;
end;

procedure TFormLayoutBasico.CriarFooter;
begin
  RecFooter := TRectangle.Create(Self);
  RecFooter.Parent := RecFundo;
  RecFooter.Align  := TAlignLayout.Bottom;
  RecFooter.Height := 60;
  RecFooter.Fill.Color := $FFFFFFFF;
  RecFooter.Stroke.Kind := TBrushKind.None;
  // Adicionar botões aqui conforme necessidade
end;

procedure TFormLayoutBasico.CriarConteudo;
begin
  ScrollConteudo := TVertScrollBox.Create(Self);
  ScrollConteudo.Parent := RecFundo;
  ScrollConteudo.Align  := TAlignLayout.Client;
  ScrollConteudo.ShowScrollBars := True;

  LayoutItens := TLayout.Create(Self);
  LayoutItens.Parent := ScrollConteudo;
  LayoutItens.Align  := TAlignLayout.Top;
  LayoutItens.Height := 0;  // cresce dinamicamente ao adicionar filhos
  LayoutItens.Padding.Left   := 16;
  LayoutItens.Padding.Top    := 16;
  LayoutItens.Padding.Right  := 16;
  LayoutItens.Padding.Bottom := 16;
end;

end.

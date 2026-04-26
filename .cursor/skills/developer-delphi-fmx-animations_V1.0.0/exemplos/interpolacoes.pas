unit interpolacoes;
// Demonstração visual de todos os TInterpolationType disponíveis no FMX
// Cria cards lado a lado, cada um animando com uma interpolação diferente

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Layouts, FMX.StdCtrls,
  FMX.Ani, FMX.Types, System.UITypes, System.SysUtils;

// ============================================================
// PROCEDIMENTO: DemoTodasInterpolacoes
// Cria um layout com 11 cards, cada um demonstrando uma
// interpolação diferente ao clicar em um botão "Animar Todos"
// ============================================================
procedure DemoTodasInterpolacoes(AParent: TControl);

// ============================================================
// PROCEDIMENTO: AnimarComInterpolacao
// Anima um único controle com a interpolação especificada
// ============================================================
procedure AnimarComInterpolacao(AControl: TControl;
  AInterp: TInterpolationType; ADelay: Single = 0);

implementation

type
  TInterpolacaoInfo = record
    Tipo: TInterpolationType;
    Nome: string;
    Descricao: string;
    CorFundo: TAlphaColor;
  end;

const
  INTERPOLACOES: array[0..10] of TInterpolacaoInfo = (
    (Tipo: TInterpolationType.Linear;      Nome: 'Linear';      Descricao: 'Velocidade constante';         CorFundo: $FFE8F4FD),
    (Tipo: TInterpolationType.Quadratic;   Nome: 'Quadratic';   Descricao: 'Desacelera suavemente';        CorFundo: $FFEAF6F8),
    (Tipo: TInterpolationType.Cubic;       Nome: 'Cubic ★';     Descricao: 'Padrão recomendado';           CorFundo: $FFE8F8F5),
    (Tipo: TInterpolationType.Quartic;     Nome: 'Quartic';     Descricao: 'Desacelera abruptamente';      CorFundo: $FFFFFDE7),
    (Tipo: TInterpolationType.Quintic;     Nome: 'Quintic';     Descricao: 'Extremamente abrupto';         CorFundo: $FFFFF3E0),
    (Tipo: TInterpolationType.Sinusoidal;  Nome: 'Sinusoidal';  Descricao: 'Curva senoidal suave';         CorFundo: $FFFCE4EC),
    (Tipo: TInterpolationType.Exponential; Nome: 'Exponential'; Descricao: 'Cai exponencialmente';         CorFundo: $FFF3E5F5),
    (Tipo: TInterpolationType.Circular;    Nome: 'Circular';    Descricao: 'Baseado em arco';              CorFundo: $FFE8EAF6),
    (Tipo: TInterpolationType.Elastic;     Nome: 'Elastic ★';   Descricao: 'Oscila como mola';             CorFundo: $FFFFE0B2),
    (Tipo: TInterpolationType.Back;        Nome: 'Back ★';      Descricao: 'Ultrapassa e volta (pop)';     CorFundo: $FFFFD7D7),
    (Tipo: TInterpolationType.Bounce;      Nome: 'Bounce';      Descricao: 'Quica ao chegar';              CorFundo: $FFD7FFD7)
  );

procedure AnimarComInterpolacao(AControl: TControl;
  AInterp: TInterpolationType; ADelay: Single);
var
  OriginalX: Single;
begin
  OriginalX := AControl.Position.X;

  // Mover para esquerda
  AControl.Position.X := OriginalX - 30;
  AControl.Opacity := 0.3;

  // Animar de volta com a interpolação escolhida
  TAnimator.AnimateFloatDelay(AControl, 'Position.X', OriginalX, 0.50, ADelay,
    TAnimationType.Out, AInterp);

  TAnimator.AnimateFloatDelay(AControl, 'Opacity', 1.0, 0.30, ADelay,
    TAnimationType.Out, TInterpolationType.Linear);
end;

procedure DemoTodasInterpolacoes(AParent: TControl);
var
  Scroll: TVertScrollBox;
  I: Integer;
  Card: TRectangle;
  LblNome, LblDesc: TLabel;
begin
  Scroll := TVertScrollBox.Create(AParent.Owner);
  Scroll.Parent := AParent;
  Scroll.Align := TAlignLayout.Client;
  Scroll.AniCalculations.AutoShowing := False;

  for I := 0 to High(INTERPOLACOES) do
  begin
    Card := TRectangle.Create(AParent.Owner);
    Card.Parent := Scroll;
    Card.Position.X := 16;
    Card.Position.Y := 16 + I * 72;
    Card.Width  := 300;
    Card.Height := 60;
    Card.Fill.Color   := INTERPOLACOES[I].CorFundo;
    Card.Stroke.Color := $FFD0D0D0;
    Card.Stroke.Thickness := 1;
    Card.XRadius := 8;
    Card.YRadius := 8;
    Card.Tag := I; // índice da interpolação

    LblNome := TLabel.Create(AParent.Owner);
    LblNome.Parent := Card;
    LblNome.Position.X := 12;
    LblNome.Position.Y := 8;
    LblNome.Text := INTERPOLACOES[I].Nome;
    LblNome.TextSettings.Font.Style := [TFontStyle.fsBold];
    LblNome.TextSettings.Font.Size := 13;

    LblDesc := TLabel.Create(AParent.Owner);
    LblDesc.Parent := Card;
    LblDesc.Position.X := 12;
    LblDesc.Position.Y := 30;
    LblDesc.Text := INTERPOLACOES[I].Descricao;
    LblDesc.TextSettings.Font.Size := 11;
    LblDesc.TextSettings.FontColor := $FF666666;

    // Associar animação ao clique
    Card.OnClick := procedure(Sender: TObject)
    var Idx: Integer;
    begin
      Idx := (Sender as TRectangle).Tag;
      AnimarComInterpolacao(Sender as TRectangle,
        INTERPOLACOES[Idx].Tipo, 0);
    end;
  end;
end;

// ============================================================
// EXEMPLO DE USO:
//
// // Em FormCreate ou AfterShow:
// DemoTodasInterpolacoes(LayoutConteudo);
//
// // Animar um controle específico com Back+Out (pop effect):
// AnimarComInterpolacao(RecCard, TInterpolationType.Back, 0.1);
//
// // Animar com Elastic+Out (spring effect):
// AnimarComInterpolacao(RecNotif, TInterpolationType.Elastic, 0);
// ============================================================

end.

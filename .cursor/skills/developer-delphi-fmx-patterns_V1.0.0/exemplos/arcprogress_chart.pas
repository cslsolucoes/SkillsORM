unit arcprogress_chart;
{
  EXEMPLO: TArc como progressbar circular (FMX / GestorERP)
  Compilavel: dcc32 / dcc64
  Demonstra:
    - TArc com StartAngle=-90 (inicia no topo)
    - Calculo de EndAngle a partir do percentual
    - Animacao suave com TAnimator
    - Label central com o valor
    - Variante: multiplos arcos (donut chart)
}

interface

uses
  System.SysUtils, System.Classes, System.Math,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Ani,
  FMX.Layouts, FMX.StdCtrls, FMX.Objects, FMX.Graphics;

// ---------------------------------------------------------------------------
// Componente reutilizavel: arco de progresso circular
// ---------------------------------------------------------------------------
type
  TArcProgress = class(TLayout)
  private
    FArcFundo   : TArc;  // anel cinza de fundo
    FArcValor   : TArc;  // anel colorido de progresso
    FLblValor   : TLabel;
    FLblCaption : TLabel;
    FPercentual : Single;
    FCorProgresso: TAlphaColor;

    procedure Construir;
    procedure AtualizarVisual(AAnimado: Boolean);
  public
    constructor Create(AOwner: TComponent); override;

    // Definir percentual (0.0 a 100.0), opcionalmente com animacao
    procedure SetPercentual(AValor: Single; AAnimado: Boolean = True);

    // Texto abaixo do arco (ex.: 'Vendas', 'Meta')
    property Caption: string write (FLblCaption.Text);
    property CorProgresso: TAlphaColor read FCorProgresso write FCorProgresso;
    property Percentual: Single read FPercentual;
  end;

// ---------------------------------------------------------------------------
// Form de exemplo com dashboard de indicadores
// ---------------------------------------------------------------------------
type
  TFrmDashboard = class(TForm)
  private
    ArcVendas  : TArcProgress;
    ArcMeta    : TArcProgress;
    ArcClientes: TArcProgress;
    procedure ConstruirLayout;
    procedure BtnSimularClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

// ---------------------------------------------------------------------------
// TArcProgress
// ---------------------------------------------------------------------------

constructor TArcProgress.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCorProgresso := $FF3498DB; // azul padrao
  Width  := 120;
  Height := 140;
  Construir;
end;

procedure TArcProgress.Construir;
var
  RecArea: TRectangle;
begin
  // Container quadrado para os arcos
  RecArea := TRectangle.Create(Self);
  RecArea.Parent := Self;
  RecArea.Align  := TAlignLayout.Top;
  RecArea.Height := 110;
  RecArea.Fill.Kind   := TBrushKind.None;
  RecArea.Stroke.Kind := TBrushKind.None;

  // Arco de fundo (cinza, completo)
  FArcFundo := TArc.Create(Self);
  FArcFundo.Parent      := RecArea;
  FArcFundo.Align       := TAlignLayout.Center;
  FArcFundo.Width       := 90;
  FArcFundo.Height      := 90;
  FArcFundo.StartAngle  := 0;
  FArcFundo.EndAngle    := 360;
  FArcFundo.Stroke.Color     := $FFE0E0E0;
  FArcFundo.Stroke.Thickness := 10;
  FArcFundo.Fill.Kind        := TBrushKind.None;

  // Arco de progresso (colorido, dinamico)
  FArcValor := TArc.Create(Self);
  FArcValor.Parent      := RecArea;
  FArcValor.Align       := TAlignLayout.Center;
  FArcValor.Width       := 90;
  FArcValor.Height      := 90;
  FArcValor.StartAngle  := -90; // inicia no topo (12h)
  FArcValor.EndAngle    := -90; // sera animado
  FArcValor.Stroke.Color     := FCorProgresso;
  FArcValor.Stroke.Thickness := 10;
  FArcValor.Fill.Kind        := TBrushKind.None;

  // Label do valor (centralizado sobre o arco)
  FLblValor := TLabel.Create(Self);
  FLblValor.Parent := RecArea;
  FLblValor.Align  := TAlignLayout.Center;
  FLblValor.Text   := '0%';
  FLblValor.TextSettings.Font.Size  := 18;
  FLblValor.TextSettings.Font.Style := [TFontStyle.fsBold];
  FLblValor.TextSettings.FontColor  := $FF2C3E50;
  FLblValor.HitTest := False;

  // Label de legenda abaixo
  FLblCaption := TLabel.Create(Self);
  FLblCaption.Parent := Self;
  FLblCaption.Align  := TAlignLayout.Client;
  FLblCaption.Text   := '';
  FLblCaption.TextSettings.Font.Size   := 12;
  FLblCaption.TextSettings.FontColor   := $FF7F8C8D;
  FLblCaption.TextSettings.HorzAlign   := TTextAlign.Center;
end;

procedure TArcProgress.SetPercentual(AValor: Single; AAnimado: Boolean);
begin
  // Limitar a 0..100
  FPercentual := Max(0, Min(100, AValor));
  AtualizarVisual(AAnimado);
end;

procedure TArcProgress.AtualizarVisual(AAnimado: Boolean);
var
  AngFinal: Single;
begin
  // -90 + (percentual/100) * 360 = angulo final
  AngFinal := -90 + (FPercentual / 100) * 360;

  // Atualizar cor do arco (pode ter mudado)
  FArcValor.Stroke.Color := FCorProgresso;

  // Atualizar label
  FLblValor.Text := Round(FPercentual).ToString + '%';

  if AAnimado then
  begin
    TAnimator.AnimateFloat(FArcValor, 'EndAngle', AngFinal, 0.6,
      TAnimationType.Out, TInterpolationType.Cubic);
  end
  else
    FArcValor.EndAngle := AngFinal;
end;

// ---------------------------------------------------------------------------
// TFrmDashboard
// ---------------------------------------------------------------------------

constructor TFrmDashboard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width  := 500;
  Height := 200;
  Fill.Color := $FFFAFAFA;
  ConstruirLayout;
end;

procedure TFrmDashboard.ConstruirLayout;
var
  Layout: TLayout;
  BtnSimular: TButton;
begin
  // Layout horizontal para os 3 arcos
  Layout := TLayout.Create(Self);
  Layout.Parent := Self;
  Layout.Align  := TAlignLayout.Top;
  Layout.Height := 150;
  Layout.Padding.Rect := TRectF.Create(20, 10, 20, 0);

  ArcVendas := TArcProgress.Create(Layout);
  ArcVendas.Parent := Layout;
  ArcVendas.Align  := TAlignLayout.Left;
  ArcVendas.Width  := 140;
  ArcVendas.CorProgresso := $FF27AE60; // verde
  ArcVendas.FLblCaption.Text := 'Vendas';

  ArcMeta := TArcProgress.Create(Layout);
  ArcMeta.Parent := Layout;
  ArcMeta.Align  := TAlignLayout.Left;
  ArcMeta.Width  := 140;
  ArcMeta.CorProgresso := $FF3498DB; // azul
  ArcMeta.FLblCaption.Text := 'Meta';

  ArcClientes := TArcProgress.Create(Layout);
  ArcClientes.Parent := Layout;
  ArcClientes.Align  := TAlignLayout.Left;
  ArcClientes.Width  := 140;
  ArcClientes.CorProgresso := $FFE74C3C; // vermelho
  ArcClientes.FLblCaption.Text := 'Novos Clientes';

  // Botao para simular dados
  BtnSimular := TButton.Create(Self);
  BtnSimular.Parent  := Self;
  BtnSimular.Align   := TAlignLayout.Bottom;
  BtnSimular.Height  := 40;
  BtnSimular.Text    := 'Simular Dados';
  BtnSimular.OnClick := BtnSimularClick;

  // Valores iniciais
  ArcVendas.SetPercentual(72, False);
  ArcMeta.SetPercentual(55, False);
  ArcClientes.SetPercentual(33, False);
end;

procedure TFrmDashboard.BtnSimularClick(Sender: TObject);
begin
  // Animar para novos valores
  ArcVendas.SetPercentual(Random(100));
  ArcMeta.SetPercentual(Random(100));
  ArcClientes.SetPercentual(Random(100));
end;

end.

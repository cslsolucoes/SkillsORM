unit TEMPLATE_arc_progress;
{
  TEMPLATE: Arco de progresso circular animado (FMX / GestorERP)
  Uso: copie e inclua no seu form. Substitua TFrmArcTemplate.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Classes, System.Math,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Ani,
  FMX.Layouts, FMX.StdCtrls, FMX.Objects, FMX.Graphics;

type
  TArcProgressWidget = class(TLayout)
  private
    FArcFundo  : TArc;
    FArcValor  : TArc;
    FLblValor  : TLabel;
    FLblCaption: TLabel;
    FPercentual: Single;
    FCor       : TAlphaColor;
    FEspessura : Single;

    procedure Construir;
  public
    constructor Create(AOwner: TComponent); override;

    // Define o percentual (0..100), opcionalmente animado
    procedure Definir(APercentual: Single; AAnimado: Boolean = True;
      ADuracao: Single = 0.6);

    // Configuracoes visuais
    property Cor       : TAlphaColor read FCor       write FCor;
    property Espessura : Single      read FEspessura  write FEspessura;
    property Legenda   : string      write (FLblCaption.Text);
    property Percentual: Single      read FPercentual;
  end;

implementation

constructor TArcProgressWidget.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCor       := $FF3498DB; // azul
  FEspessura := 10;
  Width      := 120;
  Height     := 145;
  Construir;
end;

procedure TArcProgressWidget.Construir;
var
  RecCirculo: TLayout;
begin
  // Container para os arcos
  RecCirculo := TLayout.Create(Self);
  RecCirculo.Parent := Self;
  RecCirculo.Align  := TAlignLayout.Top;
  RecCirculo.Height := 110;

  // Arco de fundo (anel cinza completo)
  FArcFundo := TArc.Create(Self);
  FArcFundo.Parent           := RecCirculo;
  FArcFundo.Align            := TAlignLayout.Center;
  FArcFundo.Width            := 90;
  FArcFundo.Height           := 90;
  FArcFundo.StartAngle       := 0;
  FArcFundo.EndAngle         := 360;
  FArcFundo.Fill.Kind        := TBrushKind.None;
  FArcFundo.Stroke.Color     := $FFE8E8E8;
  FArcFundo.Stroke.Thickness := FEspessura;

  // Arco de progresso (inicia zerado, sera animado)
  FArcValor := TArc.Create(Self);
  FArcValor.Parent           := RecCirculo;
  FArcValor.Align            := TAlignLayout.Center;
  FArcValor.Width            := 90;
  FArcValor.Height           := 90;
  FArcValor.StartAngle       := -90; // topo (12 horas)
  FArcValor.EndAngle         := -90; // zerado
  FArcValor.Fill.Kind        := TBrushKind.None;
  FArcValor.Stroke.Color     := FCor;
  FArcValor.Stroke.Thickness := FEspessura;
  FArcValor.Stroke.Cap       := TStrokeCap.Round; // pontas arredondadas

  // Valor percentual centralizado
  FLblValor := TLabel.Create(Self);
  FLblValor.Parent := RecCirculo;
  FLblValor.Align  := TAlignLayout.Center;
  FLblValor.Width  := 80;
  FLblValor.Height := 30;
  FLblValor.Text   := '0%';
  FLblValor.TextSettings.Font.Size  := 18;
  FLblValor.TextSettings.Font.Style := [TFontStyle.fsBold];
  FLblValor.TextSettings.FontColor  := $FF2C3E50;
  FLblValor.TextSettings.HorzAlign  := TTextAlign.Center;
  FLblValor.HitTest := False;

  // Legenda abaixo do circulo
  FLblCaption := TLabel.Create(Self);
  FLblCaption.Parent := Self;
  FLblCaption.Align  := TAlignLayout.Client;
  FLblCaption.Text   := '';
  FLblCaption.TextSettings.Font.Size  := 12;
  FLblCaption.TextSettings.FontColor  := $FF95A5A6;
  FLblCaption.TextSettings.HorzAlign  := TTextAlign.Center;
end;

procedure TArcProgressWidget.Definir(APercentual: Single; AAnimado: Boolean;
  ADuracao: Single);
var
  AngFinal: Single;
begin
  FPercentual := Max(0, Min(100, APercentual));
  AngFinal    := -90 + (FPercentual / 100) * 360;

  // Atualizar cor (pode ter mudado)
  FArcValor.Stroke.Color := FCor;

  // Atualizar texto
  FLblValor.Text := Round(FPercentual).ToString + '%';

  if AAnimado then
    TAnimator.AnimateFloat(FArcValor, 'EndAngle', AngFinal, ADuracao,
      TAnimationType.Out, TInterpolationType.Cubic)
  else
    FArcValor.EndAngle := AngFinal;
end;

// ---------------------------------------------------------------------------
// COMO USAR:
//
//   var Arc := TArcProgressWidget.Create(Self);
//   Arc.Parent  := RecDashboard;
//   Arc.Align   := TAlignLayout.Left;
//   Arc.Width   := 140;
//   Arc.Cor     := $FF27AE60;  // verde
//   Arc.Legenda := 'Vendas';
//   Arc.Definir(72);           // 72% animado
//
// ---------------------------------------------------------------------------

end.

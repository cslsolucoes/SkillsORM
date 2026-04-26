unit tab_switch_animation;
// Troca de abas com animação fade out/in entre painéis
// Padrão GestorERP: painéis sobrepostos com Opacity animada

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Layouts, FMX.StdCtrls,
  FMX.Ani, FMX.Types, System.UITypes;

// ============================================================
// PROCEDIMENTO: TrocarTab
// Anima a transição entre dois painéis (fade out + fade in)
// APainelAtual — painel que será escondido
// APainelNovo  — painel que será mostrado
// ============================================================
procedure TrocarTab(APainelAtual, APainelNovo: TControl);

// ============================================================
// PROCEDIMENTO: TrocarTabComSlide
// Transição com fade + slide lateral (mais dramática)
// ADirecao: -1 = slide para esquerda, +1 = slide para direita
// ============================================================
procedure TrocarTabComSlide(APainelAtual, APainelNovo: TControl;
  ADirecao: Integer = -1);

// ============================================================
// CLASSE: TTabAnimator
// Gerencia múltiplas abas com animação integrada
// ============================================================
type
  TTabAnimator = class
  private
    FPainelAtivo: TControl;
  public
    constructor Create;
    // Registrar painel inicial (visível)
    procedure SetPainelInicial(APainel: TControl);
    // Trocar para novo painel
    procedure Trocar(APainelNovo: TControl);
  end;

implementation

procedure TrocarTab(APainelAtual, APainelNovo: TControl);
var
  AnimSaida: TFloatAnimation;
begin
  if APainelAtual = APainelNovo then Exit;

  // 1. Fade out do painel atual (0.15s)
  TAnimator.AnimateFloat(APainelAtual, 'Opacity', 0, 0.15,
    TAnimationType.Out, TInterpolationType.Linear);

  // 2. Preparar novo painel: invisível
  APainelNovo.Opacity := 0;
  APainelNovo.Visible := True;

  // 3. Fade in do novo painel com delay de 0.10s
  //    (esperar o fade-out terminar parcialmente)
  TAnimator.AnimateFloatDelay(APainelNovo, 'Opacity', 1.0, 0.15,
    0.10, TAnimationType.Out, TInterpolationType.Linear);

  // 4. Esconder painel atual ao fim do fade-out
  //    Usar TFloatAnimation com OnFinish para saber quando terminou
  AnimSaida := TFloatAnimation.Create(APainelAtual);
  AnimSaida.Parent       := APainelAtual;
  AnimSaida.PropertyName := 'Opacity';
  AnimSaida.StartValue   := APainelAtual.Opacity;
  AnimSaida.StopValue    := 0;
  AnimSaida.Duration     := 0.15;
  AnimSaida.Interpolation := TInterpolationType.Linear;
  AnimSaida.OnFinish := procedure(Sender: TObject)
  begin
    APainelAtual.Visible := False; // ocultar após animação
    AnimSaida.Free;
  end;
  AnimSaida.Start;
end;

procedure TrocarTabComSlide(APainelAtual, APainelNovo: TControl;
  ADirecao: Integer);
var
  Largura: Single;
  AnimSaida: TFloatAnimation;
begin
  if APainelAtual = APainelNovo then Exit;

  Largura := APainelAtual.Width;

  // Fade + slide do painel atual para fora
  TAnimator.AnimateFloat(APainelAtual, 'Opacity', 0, 0.20,
    TAnimationType.Out, TInterpolationType.Cubic);
  TAnimator.AnimateFloat(APainelAtual, 'Position.X',
    APainelAtual.Position.X + ADirecao * (Largura * 0.15), 0.20,
    TAnimationType.Out, TInterpolationType.Cubic);

  // Posicionar novo painel vindo do lado oposto
  APainelNovo.Position.X := APainelNovo.Position.X + ADirecao * (-Largura * 0.15);
  APainelNovo.Opacity := 0;
  APainelNovo.Visible := True;

  // Fade + slide do novo painel para dentro
  TAnimator.AnimateFloatDelay(APainelNovo, 'Opacity', 1.0, 0.20,
    0.10, TAnimationType.Out, TInterpolationType.Cubic);
  TAnimator.AnimateFloatDelay(APainelNovo, 'Position.X',
    APainelNovo.Position.X + ADirecao * Largura * 0.15,
    0.20, 0.10, TAnimationType.Out, TInterpolationType.Cubic);

  // Limpar painel atual
  AnimSaida := TFloatAnimation.Create(APainelAtual);
  AnimSaida.Parent       := APainelAtual;
  AnimSaida.PropertyName := 'Opacity';
  AnimSaida.StartValue   := APainelAtual.Opacity;
  AnimSaida.StopValue    := 0;
  AnimSaida.Duration     := 0.20;
  AnimSaida.OnFinish := procedure(Sender: TObject)
  begin
    APainelAtual.Visible := False;
    AnimSaida.Free;
  end;
  AnimSaida.Start;
end;

{ TTabAnimator }

constructor TTabAnimator.Create;
begin
  inherited;
  FPainelAtivo := nil;
end;

procedure TTabAnimator.SetPainelInicial(APainel: TControl);
begin
  FPainelAtivo := APainel;
  APainel.Opacity := 1.0;
  APainel.Visible := True;
end;

procedure TTabAnimator.Trocar(APainelNovo: TControl);
begin
  if not Assigned(FPainelAtivo) then
  begin
    SetPainelInicial(APainelNovo);
    Exit;
  end;

  if FPainelAtivo = APainelNovo then Exit;

  TrocarTab(FPainelAtivo, APainelNovo);
  FPainelAtivo := APainelNovo;
end;

// ============================================================
// EXEMPLO DE USO:
//
// // Setup inicial (todos os painéis criados, apenas 1 visível):
// RecPainelDashboard.Visible := True;
// RecPainelRelatorios.Visible := False;
// RecPainelConfig.Visible := False;
//
// // Ao clicar em aba "Relatórios":
// TrocarTab(RecPainelAtual, RecPainelRelatorios);
// RecPainelAtual := RecPainelRelatorios;
//
// // Com TTabAnimator (gerencia automaticamente qual está ativo):
// var TabAnim := TTabAnimator.Create;
// TabAnim.SetPainelInicial(RecPainelDashboard);
//
// // Ao clicar em aba:
// TabAnim.Trocar(RecPainelRelatorios);
// ============================================================

end.

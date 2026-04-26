unit progressbar_arc;
// TArc como progressbar circular animado — padrão GestorERP

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Ani,
  FMX.Types, System.UITypes;

type
  // Configuração de um arco de progresso
  TArcProgressConfig = record
    Cor        : TAlphaColor;
    Espessura  : Single;   // largura da linha do arco
    Porcentagem: Single;   // 0..100
  end;

// Criar arco de progresso circular sobre um container
// AContainer = TRectangle pai onde o arco será criado
// Retorna o TArc criado (para animar depois)
function CriarArcProgress(AContainer: TControl;
  const AConfig: TArcProgressConfig): TArc;

// Atualizar progresso com animação
procedure AnimarProgresso(AArc: TArc; APorcentagem: Single;
  ADuracao: Single = 0.50);

// Setar progresso sem animação (instantâneo)
procedure SetarProgresso(AArc: TArc; APorcentagem: Single);

// Cor por domínio GestorERP
function CorDominio(const ADominio: string): TAlphaColor;

implementation

const
  // Ângulo de início do arco (topo = -90°)
  ANGULO_INICIO = -90.0;

function PorcentagemParaAngulo(APct: Single): Single;
begin
  // 100% = 360° completos
  Result := ANGULO_INICIO + (360.0 * APct / 100.0);
end;

function CriarArcProgress(AContainer: TControl;
  const AConfig: TArcProgressConfig): TArc;
var
  Arc: TArc;
begin
  Arc := TArc.Create(AContainer);
  Arc.Parent     := AContainer;
  Arc.Align      := TAlignLayout.Client;  // preenche o container
  Arc.Margins.Rect := TRectF.Create(8, 8, 8, 8); // margem interna

  // Não preencher — apenas a linha do arco
  Arc.Fill.Kind := TBrushKind.None;

  // Cor e espessura da linha
  Arc.Stroke.Color     := AConfig.Cor;
  Arc.Stroke.Thickness := AConfig.Espessura;
  Arc.Stroke.Kind      := TBrushKind.Solid;

  // Ângulo de início (topo do círculo)
  Arc.StartAngle := ANGULO_INICIO;

  // Posição inicial do arco
  Arc.EndAngle := PorcentagemParaAngulo(AConfig.Porcentagem);

  Result := Arc;
end;

procedure AnimarProgresso(AArc: TArc; APorcentagem: Single;
  ADuracao: Single);
var
  AlvoAngulo: Single;
begin
  // Limitar entre 0 e 100
  if APorcentagem < 0   then APorcentagem := 0;
  if APorcentagem > 100 then APorcentagem := 100;

  AlvoAngulo := PorcentagemParaAngulo(APorcentagem);

  TAnimator.AnimateFloat(AArc, 'EndAngle', AlvoAngulo, ADuracao,
    TAnimationType.Out, TInterpolationType.Cubic);
end;

procedure SetarProgresso(AArc: TArc; APorcentagem: Single);
begin
  if APorcentagem < 0   then APorcentagem := 0;
  if APorcentagem > 100 then APorcentagem := 100;

  TAnimator.StopAnimation(AArc, 'EndAngle');
  AArc.EndAngle := PorcentagemParaAngulo(APorcentagem);
end;

function CorDominio(const ADominio: string): TAlphaColor;
begin
  // Padrão de cores do GestorERP por domínio
  if ADominio = 'vendas'      then Exit($FF3498DB); // azul
  if ADominio = 'estoque'     then Exit($FF27AE60); // verde
  if ADominio = 'financeiro'  then Exit($FFD4AC0D); // dourado
  if ADominio = 'producao'    then Exit($FF8E44AD); // roxo
  if ADominio = 'rh'          then Exit($FF16A085); // verde-azul
  if ADominio = 'alerta'      then Exit($FFE74C3C); // vermelho
  if ADominio = 'atencao'     then Exit($FFF39C12); // laranja
  Result := $FF3498DB; // azul padrão
end;

// ============================================================
// EXEMPLO DE USO:
//
// var ArcVendas: TArc;
//
// procedure TFormDashboard.FormCreate(Sender: TObject);
// var Config: TArcProgressConfig;
// begin
//   // Criar arco de vendas
//   Config.Cor         := CorDominio('vendas');
//   Config.Espessura   := 8;
//   Config.Porcentagem := 0;  // começa zerado
//   ArcVendas := CriarArcProgress(RecProgressVendas, Config);
//
//   // Animar para 75% na entrada
//   AnimarProgresso(ArcVendas, 75, 0.80);
// end;
//
// procedure TFormDashboard.AtualizarProgresso(APct: Single);
// begin
//   AnimarProgresso(ArcVendas, APct, 0.50);
// end;
//
// ESTRUTURA RECOMENDADA NO .FMX:
//   RecProgressVendas: TRectangle (60x60, XRadius=30, Fill=fundo escuro)
//   +-- LblPercent: TLabel (centralizado, texto '75%')
//   +-- [TArc criado em runtime via CriarArcProgress]
//
// O TArc é criado em runtime (não no .fmx) para facilitar
// a animação do EndAngle via TAnimator.
//
// PARA ARCO DE FUNDO (trilha cinza):
//   var Trilha := TArc.Create(AContainer);
//   Trilha.Parent := AContainer;
//   Trilha.Align  := TAlignLayout.Client;
//   Trilha.Margins.Rect := TRectF.Create(8, 8, 8, 8);
//   Trilha.Fill.Kind := TBrushKind.None;
//   Trilha.Stroke.Color     := $20FFFFFF; // trilha sutil
//   Trilha.Stroke.Thickness := 8;
//   Trilha.StartAngle := -90;
//   Trilha.EndAngle   := 270; // círculo completo
//   // Criar DEPOIS a trilha para o arco de progresso ficar na frente
// ============================================================

end.

unit lazy_load_pattern;
// Padrão Lazy Load + Animação do GestorERP
// Controles são criados apenas quando o container fica visível (OnResized)
// e animados com entrada ao serem carregados pela primeira vez

interface

uses
  FMX.Forms, FMX.Controls, FMX.Objects, FMX.Layouts, FMX.StdCtrls,
  FMX.Ani, FMX.Types, System.UITypes, System.Threading;

// ============================================================
// PADRÃO 1: Lazy Load via RecFundoResize (padrão GestorERP)
// - RecFundoResize com Align=Client no form/frame
// - OnResized: verificar ControlsCount = 0 antes de criar
// - Animar entrada após criação
// ============================================================

type
  // Frame de exemplo que implementa o padrão lazy load
  TFrameLazyExemplo = class(TFrame)
  private
    FCarregado: Boolean;
    FCarregando: Boolean;
    procedure CarregarConteudo;
    procedure AnimarEntradaConteudo;
  public
    constructor Create(AOwner: TComponent); override;
    // Evento chamado quando o container redimensiona
    // Configurar: RecFundoResize.OnResized := OnContainerResized
    procedure OnContainerResized(Sender: TObject);
  end;

// ============================================================
// PADRÃO 2: Lazy Load com dados assíncronos
// - Carregar dados em background (TTask)
// - Criar controles na UI thread após carga
// - Animar após criação
// ============================================================
procedure CarregarDadosComAnimacao(
  AContainer: TControl;
  ACarregarDados: TProc;            // executa em background
  ACriarControles: TProc;           // executa na UI thread
  AOnConcluido: TProc = nil);       // callback final

// ============================================================
// UTILITÁRIO: AnimarEntrada
// Anima todos os filhos diretos de AContainer (fade + slide up)
// ============================================================
procedure AnimarEntrada(AContainer: TControl;
  ADelayBase: Single = 0;
  AStagger: Single = 0.06;
  ASlide: Single = 18;
  ADuracao: Single = 0.30);

implementation

procedure AnimarEntrada(AContainer: TControl;
  ADelayBase, AStagger, ASlide, ADuracao: Single);
var
  I: Integer;
  C: TControl;
  OriginalY: Single;
begin
  for I := 0 to AContainer.ControlsCount - 1 do
  begin
    C := AContainer.Controls[I];
    OriginalY := C.Position.Y;

    // Estado inicial: invisível e abaixo
    C.Opacity    := 0;
    C.Position.Y := OriginalY + ASlide;

    // Fade in com delay escalonado
    TAnimator.AnimateFloatDelay(C, 'Opacity', 1.0, ADuracao,
      ADelayBase + I * AStagger,
      TAnimationType.Out, TInterpolationType.Cubic);

    // Slide up para posição original
    TAnimator.AnimateFloatDelay(C, 'Position.Y', OriginalY, ADuracao,
      ADelayBase + I * AStagger,
      TAnimationType.Out, TInterpolationType.Cubic);
  end;
end;

{ TFrameLazyExemplo }

constructor TFrameLazyExemplo.Create(AOwner: TComponent);
begin
  inherited;
  FCarregado  := False;
  FCarregando := False;
end;

procedure TFrameLazyExemplo.OnContainerResized(Sender: TObject);
var
  Container: TControl;
begin
  Container := Sender as TControl;

  // PADRÃO CHAVE: verificar ControlsCount = 0 antes de criar
  // Isso garante que só carrega UMA VEZ, mesmo se o form for redimensionado
  if Container.ControlsCount = 0 then
  begin
    if not FCarregando then
    begin
      FCarregando := True;
      CarregarConteudo;
    end;
  end;
end;

procedure TFrameLazyExemplo.CarregarConteudo;
var
  I: Integer;
  Card: TRectangle;
  Lbl: TLabel;
begin
  // Criar controles (em produção: criar a partir de dados reais)
  for I := 1 to 5 do
  begin
    Card := TRectangle.Create(Owner);
    // Usar o container do frame como pai
    // (em produção: usar RecFundoResize ou o layout correspondente)
    Card.Parent := Self;
    Card.Position.X := 16;
    Card.Position.Y := 16 + (I - 1) * 80;
    Card.Width  := 300;
    Card.Height := 68;
    Card.Fill.Color := $FFF8F9FA;
    Card.Stroke.Color := $FFE0E0E0;
    Card.XRadius := 8;
    Card.YRadius := 8;

    Lbl := TLabel.Create(Owner);
    Lbl.Parent := Card;
    Lbl.Position.X := 12;
    Lbl.Position.Y := 12;
    Lbl.Text := 'Item ' + I.ToString;
  end;

  FCarregado  := True;
  FCarregando := False;

  // Animar entrada após criar todos os controles
  AnimarEntradaConteudo;
end;

procedure TFrameLazyExemplo.AnimarEntradaConteudo;
begin
  // Pequeno delay para garantir que o layout foi calculado
  TAnimator.AnimateFloatDelay(Self, 'Opacity', 1.0, 0.01, 0.05);

  // Animar os filhos
  AnimarEntrada(Self, 0.05, 0.06, 18, 0.30);
end;

procedure CarregarDadosComAnimacao(
  AContainer: TControl;
  ACarregarDados: TProc;
  ACriarControles: TProc;
  AOnConcluido: TProc);
begin
  // Mostrar spinner/placeholder durante carga
  AContainer.Opacity := 0.5;

  // Carregar dados em background
  TTask.Run(procedure
  begin
    ACarregarDados; // executa em thread de background

    // Voltar para UI thread para criar controles
    TThread.Synchronize(nil, procedure
    begin
      ACriarControles; // criar controles na UI thread

      // Restaurar opacity e animar entrada
      AContainer.Opacity := 1.0;
      AnimarEntrada(AContainer, 0, 0.06, 18, 0.30);

      if Assigned(AOnConcluido) then
        AOnConcluido;
    end);
  end);
end;

// ============================================================
// EXEMPLO COMPLETO DE USO (em um TFrame ou TForm):
//
// // 1. No .fmx/.dfm: criar RecFundoResize com Align=Client
// //    Configurar: RecFundoResize.OnResized := RecFundoResizeResized
//
// procedure TFrmListagem.RecFundoResizeResized(Sender: TObject);
// begin
//   // Só carrega se ainda não carregado (ControlsCount = 0)
//   if RecFundoResize.ControlsCount = 0 then
//     CarregarLista;
// end;
//
// procedure TFrmListagem.CarregarLista;
// begin
//   CarregarDadosComAnimacao(
//     RecFundoResize,
//     procedure begin
//       // Buscar dados do banco (thread background)
//       FDados := FRepository.BuscarTodos;
//     end,
//     procedure begin
//       // Criar cards com os dados (UI thread)
//       for var D in FDados do
//         CriarCard(RecFundoResize, D);
//     end
//   );
// end;
// ============================================================

end.

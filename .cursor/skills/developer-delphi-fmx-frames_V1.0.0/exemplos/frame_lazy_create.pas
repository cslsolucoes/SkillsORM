unit frame_lazy_create;
{
  EXEMPLO: Frame Lazy-Load — criar so quando necessario (FMX)
  Compilavel: dcc32 / dcc64
  Demonstra:
    - Criar frame apenas quando tab/aba fica visivel
    - ControlsCount = 0 como flag "nao criado ainda"
    - Lazy-load em TTabControl (cada aba cria seu frame so na primeira abertura)
    - Liberacao em destrutor do form
}

interface

uses
  System.SysUtils, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Layouts, FMX.StdCtrls, FMX.Objects,
  FMX.TabControl;

type
  TFrameConteudo = class(TFrame)
  public
    procedure Inicializar(const ANome: string);
  end;

type
  TFrmComAbas = class(TForm)
  private
    TabCtrl: TTabControl;
    TabClientes: TTabItem;
    TabPedidos : TTabItem;
    TabRelat   : TTabItem;

    procedure TabCtrlChange(Sender: TObject);
    procedure CriarFrameSeNecessario(ATab: TTabItem);
    procedure CriarFrameClientes;
    procedure CriarFramePedidos;
    procedure CriarFrameRelatorios;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

// ---------------------------------------------------------------------------
// TFrameConteudo
// ---------------------------------------------------------------------------

procedure TFrameConteudo.Inicializar(const ANome: string);
var
  Lbl: TLabel;
begin
  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Align  := TAlignLayout.Center;
  Lbl.Text   := 'Frame carregado: ' + ANome;
  Lbl.TextSettings.Font.Size := 16;
end;

// ---------------------------------------------------------------------------
// TFrmComAbas
// ---------------------------------------------------------------------------

constructor TFrmComAbas.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  TabCtrl := TTabControl.Create(Self);
  TabCtrl.Parent := Self;
  TabCtrl.Align  := TAlignLayout.Client;
  TabCtrl.OnChange := TabCtrlChange;

  TabClientes := TTabItem.Create(TabCtrl);
  TabClientes.Parent := TabCtrl;
  TabClientes.Text   := 'Clientes';

  TabPedidos := TTabItem.Create(TabCtrl);
  TabPedidos.Parent := TabCtrl;
  TabPedidos.Text   := 'Pedidos';

  TabRelat := TTabItem.Create(TabCtrl);
  TabRelat.Parent := TabCtrl;
  TabRelat.Text   := 'Relatorios';

  // Criar apenas o frame da aba inicial
  CriarFrameSeNecessario(TabCtrl.ActiveTab);
end;

procedure TFrmComAbas.TabCtrlChange(Sender: TObject);
begin
  // Chamado cada vez que o usuario muda de aba
  CriarFrameSeNecessario(TabCtrl.ActiveTab);
end;

procedure TFrmComAbas.CriarFrameSeNecessario(ATab: TTabItem);
begin
  if not Assigned(ATab) then Exit;

  // ControlsCount = 0 significa que a aba ainda nao tem frame
  if ATab.ControlsCount > 0 then Exit; // ja tem frame — nao recriar

  if ATab = TabClientes then
    CriarFrameClientes
  else if ATab = TabPedidos then
    CriarFramePedidos
  else if ATab = TabRelat then
    CriarFrameRelatorios;
end;

procedure TFrmComAbas.CriarFrameClientes;
var
  Frame: TFrameConteudo;
begin
  Frame := TFrameConteudo.Create(TabClientes);
  Frame.Parent := TabClientes;
  Frame.Align  := TAlignLayout.Client;
  Frame.Inicializar('Clientes');
  // Frame.CarregarDados; // carregar dados pesados so aqui
end;

procedure TFrmComAbas.CriarFramePedidos;
var
  Frame: TFrameConteudo;
begin
  Frame := TFrameConteudo.Create(TabPedidos);
  Frame.Parent := TabPedidos;
  Frame.Align  := TAlignLayout.Client;
  Frame.Inicializar('Pedidos');
end;

procedure TFrmComAbas.CriarFrameRelatorios;
var
  Frame: TFrameConteudo;
begin
  Frame := TFrameConteudo.Create(TabRelat);
  Frame.Parent := TabRelat;
  Frame.Align  := TAlignLayout.Client;
  Frame.Inicializar('Relatorios');
end;

// ---------------------------------------------------------------------------
// QUANDO USAR LAZY-LOAD?
//
//   1. Abas com dados pesados: so carregar quando o usuario abrir a aba
//   2. Formularios com muitos subpaineis: evitar processamento desnecessario
//   3. Apps mobile: economizar memoria (frames nao visitados nao existem)
//
// ALTERNATIVA: OnResize do container
//
//   procedure TFrm.RecContainerResized(Sender: TObject);
//   begin
//     if RecContainer.ControlsCount = 0 then
//       CriarFrameFilho;
//   end;
//
// ---------------------------------------------------------------------------

end.

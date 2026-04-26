unit frame_destruir_tudo;
{
  EXEMPLO: Padrao DestruirTudo — trocar frames sem memory leak (GestorERP)
  Compilavel: dcc32 / dcc64
  Demonstra:
    - DestruirTudo: liberar todos os filhos de um container
    - TrocarFrame: destruir + criar novo frame atomicamente
    - Guarda referencia tipada para acesso posterior
    - Protecao contra double-free
}

interface

uses
  System.SysUtils, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Layouts, FMX.StdCtrls, FMX.Objects;

// Frames que podem ser exibidos no form principal
type
  TFrameQualquer = class(TFrame)
  public
    NomeFrame: string; // apenas para identificacao no exemplo
  end;

type
  TFrmPrincipal = class(TForm)
  private
    RecConteiner: TRectangle; // container onde os frames sao exibidos
    FFrameAtivo: TFrameQualquer; // referencia tipada ao frame atual

    // Destroi TODOS os controles filhos do RecConteiner
    procedure DestruirTudo;

    // Destroi o frame atual (se houver) e cria um novo
    procedure TrocarFrame(ANovoFrame: TFrameQualquer);

    // Helpers para cada secao do sistema
    procedure AbrirDashboard;
    procedure AbrirClientes;
    procedure AbrirPedidos;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

constructor TFrmPrincipal.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  // Configurar container
  RecConteiner := TRectangle.Create(Self);
  RecConteiner.Parent := Self;
  RecConteiner.Align  := TAlignLayout.Client;
  RecConteiner.Fill.Color := $FFF5F5F5;
  RecConteiner.Stroke.Kind := TBrushKind.None;
end;

procedure TFrmPrincipal.DestruirTudo;
var
  I: Integer;
begin
  // Iterar de tras para frente para evitar erros de indice ao remover
  for I := RecConteiner.ControlsCount - 1 downto 0 do
    RecConteiner.Controls[I].Free;

  // Limpar referencia — o objeto foi destruido
  FFrameAtivo := nil;
end;

procedure TFrmPrincipal.TrocarFrame(ANovoFrame: TFrameQualquer);
begin
  // Passo 1: destruir o que estava no container
  DestruirTudo;

  // Passo 2: configurar o novo frame
  ANovoFrame.Parent := RecConteiner;
  ANovoFrame.Align  := TAlignLayout.Client;

  // Passo 3: guardar referencia
  FFrameAtivo := ANovoFrame;
end;

procedure TFrmPrincipal.AbrirDashboard;
var
  Frame: TFrameQualquer;
begin
  Frame := TFrameQualquer.Create(Self);
  Frame.NomeFrame := 'Dashboard';
  TrocarFrame(Frame);
end;

procedure TFrmPrincipal.AbrirClientes;
var
  Frame: TFrameQualquer;
begin
  // Criar frame ja com parametros antes de passar para TrocarFrame
  Frame := TFrameQualquer.Create(Self);
  Frame.NomeFrame := 'Clientes';
  // Frame.Carregar(params...);
  TrocarFrame(Frame);
end;

procedure TFrmPrincipal.AbrirPedidos;
var
  Frame: TFrameQualquer;
begin
  Frame := TFrameQualquer.Create(Self);
  Frame.NomeFrame := 'Pedidos';
  TrocarFrame(Frame);
end;

// ---------------------------------------------------------------------------
// NOTA IMPORTANTE — por que iterar de tras para frente?
//
//   Controls[0..N-1] e um array dinamico. Ao chamar Controls[I].Free,
//   o controle se remove do array, deslocando os indices.
//   Iterando de N-1 downto 0, cada .Free remove o ultimo elemento —
//   os indices anteriores nao sao afetados.
//
//   ERRADO (causa AV):
//     for I := 0 to RecConteiner.ControlsCount - 1 do
//       RecConteiner.Controls[I].Free;
//
//   CORRETO:
//     for I := RecConteiner.ControlsCount - 1 downto 0 do
//       RecConteiner.Controls[I].Free;
// ---------------------------------------------------------------------------

end.

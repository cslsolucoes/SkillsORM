unit frame_parametros;
{
  EXEMPLO: Passar parametros para TFrame (FMX)
  Compilavel: dcc32 / dcc64
  Demonstra:
    - Constructor com parametros
    - Properties publicas com setter
    - Interface IParametrizavel (padrao DI-friendly)
    - Record de configuracao (VO — Value Object)
}

interface

uses
  System.SysUtils, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Layouts, FMX.StdCtrls, FMX.Objects;

// ---------------------------------------------------------------------------
// Value Object com todos os parametros do frame
// ---------------------------------------------------------------------------
type
  TFramePedidoParams = record
    CodigoPedido  : Integer;
    CodigoCliente : Integer;
    NomeCliente   : string;
    SomenteLeitura: Boolean;
    class function Novo(ACodPedido, ACodCliente: Integer;
      const ANome: string; ASomenteLeitura: Boolean): TFramePedidoParams; static;
  end;

// ---------------------------------------------------------------------------
// Frame: recebe parametros de 3 formas diferentes
// ---------------------------------------------------------------------------
type
  TFramePedido = class(TFrame)
  private
    FParams: TFramePedidoParams;
    LblCliente: TLabel;
    LblPedido : TLabel;
    procedure AplicarParams;
  public
    // FORMA 1: Constructor com parametros (imutavel — parametros definidos na criacao)
    constructor CreateComParams(AOwner: TComponent;
      const AParams: TFramePedidoParams); reintroduce;

    // FORMA 2: Property com setter (mutavel — pode ser alterado depois)
    procedure SetParams(const AParams: TFramePedidoParams);

    // FORMA 3: Metodo Carregar explicito (padrao GestorERP mais comum)
    procedure Carregar(ACodigoPedido, ACodigoCliente: Integer;
      const ANomeCliente: string; ASomenteLeitura: Boolean = False);

    property Params: TFramePedidoParams read FParams;
  end;

implementation

// ---------------------------------------------------------------------------
// TFramePedidoParams
// ---------------------------------------------------------------------------

class function TFramePedidoParams.Novo(ACodPedido, ACodCliente: Integer;
  const ANome: string; ASomenteLeitura: Boolean): TFramePedidoParams;
begin
  Result.CodigoPedido   := ACodPedido;
  Result.CodigoCliente  := ACodCliente;
  Result.NomeCliente    := ANome;
  Result.SomenteLeitura := ASomenteLeitura;
end;

// ---------------------------------------------------------------------------
// TFramePedido
// ---------------------------------------------------------------------------

constructor TFramePedido.CreateComParams(AOwner: TComponent;
  const AParams: TFramePedidoParams);
begin
  inherited Create(AOwner);

  // Construir layout minimo
  LblCliente := TLabel.Create(Self);
  LblCliente.Parent := Self;
  LblCliente.Align  := TAlignLayout.Top;
  LblCliente.Height := 28;

  LblPedido := TLabel.Create(Self);
  LblPedido.Parent := Self;
  LblPedido.Align  := TAlignLayout.Top;
  LblPedido.Height := 28;
  LblPedido.Margins.Top := 4;

  // Armazenar e aplicar
  FParams := AParams;
  AplicarParams;
end;

procedure TFramePedido.SetParams(const AParams: TFramePedidoParams);
begin
  FParams := AParams;
  AplicarParams;
end;

procedure TFramePedido.Carregar(ACodigoPedido, ACodigoCliente: Integer;
  const ANomeCliente: string; ASomenteLeitura: Boolean);
begin
  FParams.CodigoPedido   := ACodigoPedido;
  FParams.CodigoCliente  := ACodigoCliente;
  FParams.NomeCliente    := ANomeCliente;
  FParams.SomenteLeitura := ASomenteLeitura;
  AplicarParams;
end;

procedure TFramePedido.AplicarParams;
begin
  if not Assigned(LblCliente) then Exit;

  LblCliente.Text := Format('Cliente: %d — %s',
    [FParams.CodigoCliente, FParams.NomeCliente]);

  LblPedido.Text := Format('Pedido #%d', [FParams.CodigoPedido]);

  // Somente leitura: desabilitar edicao
  // Se tiver TEdit no frame, setar Enabled := not FParams.SomenteLeitura
end;

// ---------------------------------------------------------------------------
// Uso (em outro form):
//
//   // FORMA 1: Constructor
//   var Params := TFramePedidoParams.Novo(101, 5, 'Joao Silva', False);
//   var Frame1 := TFramePedido.CreateComParams(Self, Params);
//   Frame1.Parent := RecConteiner;
//   Frame1.Align  := TAlignLayout.Client;
//
//   // FORMA 2: Property
//   var Frame2 := TFramePedido.Create(Self);
//   Frame2.SetParams(TFramePedidoParams.Novo(102, 7, 'Maria Santos', True));
//
//   // FORMA 3: Metodo Carregar (mais legivel, padrao GestorERP)
//   var Frame3 := TFramePedido.Create(Self);
//   Frame3.Parent := RecConteiner;
//   Frame3.Align  := TAlignLayout.Client;
//   Frame3.Carregar(103, 9, 'Carlos Oliveira');
// ---------------------------------------------------------------------------

end.

unit state;
{
  State Pattern em Delphi — máquina de estados de pedido de compra
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Forward declarations
// ---------------------------------------------------------------------------
type
  TPedidoContext = class;

// ---------------------------------------------------------------------------
// Interface State
// ---------------------------------------------------------------------------
  IEstadoPedido = interface
  ['{ES000001-0000-0000-0000-000000000001}']
    procedure Confirmar(ACtx: TPedidoContext);
    procedure Pagar(ACtx: TPedidoContext);
    procedure Enviar(ACtx: TPedidoContext);
    procedure Entregar(ACtx: TPedidoContext);
    procedure Cancelar(ACtx: TPedidoContext);
    function  GetNome: string;
    property Nome: string read GetNome;
  end;

// ---------------------------------------------------------------------------
// Context — mantém referência ao estado atual
// ---------------------------------------------------------------------------
  TPedidoContext = class
  private
    FEstado:   IEstadoPedido;
    FNumero:   string;
    FCliente:  string;
    FTotal:    Currency;
    FHistorico: TStringList;
    procedure RegistrarTransicao(const AMsg: string);
  public
    constructor Create(const ANumero, ACliente: string; ATotal: Currency);
    destructor Destroy; override;
    procedure SetEstado(AEstado: IEstadoPedido);
    // Ações — delegadas ao estado atual
    procedure Confirmar;
    procedure Pagar;
    procedure Enviar;
    procedure Entregar;
    procedure Cancelar;
    function  EstadoAtual: string;
    function  ObterHistorico: string;
    property Numero: string read FNumero;
    property Cliente: string read FCliente;
    property Total: Currency read FTotal;
  end;

// ---------------------------------------------------------------------------
// Estados concretos
// ---------------------------------------------------------------------------
type
  TEstadoAguardandoConfirmacao = class(TInterfacedObject, IEstadoPedido)
  public
    procedure Confirmar(ACtx: TPedidoContext);
    procedure Pagar(ACtx: TPedidoContext);
    procedure Enviar(ACtx: TPedidoContext);
    procedure Entregar(ACtx: TPedidoContext);
    procedure Cancelar(ACtx: TPedidoContext);
    function  GetNome: string;
  end;

  TEstadoConfirmado = class(TInterfacedObject, IEstadoPedido)
  public
    procedure Confirmar(ACtx: TPedidoContext);
    procedure Pagar(ACtx: TPedidoContext);
    procedure Enviar(ACtx: TPedidoContext);
    procedure Entregar(ACtx: TPedidoContext);
    procedure Cancelar(ACtx: TPedidoContext);
    function  GetNome: string;
  end;

  TEstadoPago = class(TInterfacedObject, IEstadoPedido)
  public
    procedure Confirmar(ACtx: TPedidoContext);
    procedure Pagar(ACtx: TPedidoContext);
    procedure Enviar(ACtx: TPedidoContext);
    procedure Entregar(ACtx: TPedidoContext);
    procedure Cancelar(ACtx: TPedidoContext);
    function  GetNome: string;
  end;

  TEstadoEnviado = class(TInterfacedObject, IEstadoPedido)
  public
    procedure Confirmar(ACtx: TPedidoContext);
    procedure Pagar(ACtx: TPedidoContext);
    procedure Enviar(ACtx: TPedidoContext);
    procedure Entregar(ACtx: TPedidoContext);
    procedure Cancelar(ACtx: TPedidoContext);
    function  GetNome: string;
  end;

  TEstadoEntregue = class(TInterfacedObject, IEstadoPedido)
  public
    procedure Confirmar(ACtx: TPedidoContext);
    procedure Pagar(ACtx: TPedidoContext);
    procedure Enviar(ACtx: TPedidoContext);
    procedure Entregar(ACtx: TPedidoContext);
    procedure Cancelar(ACtx: TPedidoContext);
    function  GetNome: string;
  end;

  TEstadoCancelado = class(TInterfacedObject, IEstadoPedido)
  public
    procedure Confirmar(ACtx: TPedidoContext);
    procedure Pagar(ACtx: TPedidoContext);
    procedure Enviar(ACtx: TPedidoContext);
    procedure Entregar(ACtx: TPedidoContext);
    procedure Cancelar(ACtx: TPedidoContext);
    function  GetNome: string;
  end;

implementation

// ---------------------------------------------------------------------------
// TPedidoContext
// ---------------------------------------------------------------------------

constructor TPedidoContext.Create(const ANumero, ACliente: string; ATotal: Currency);
begin
  inherited Create;
  FNumero    := ANumero;
  FCliente   := ACliente;
  FTotal     := ATotal;
  FHistorico := TStringList.Create;
  SetEstado(TEstadoAguardandoConfirmacao.Create);
end;

destructor TPedidoContext.Destroy;
begin FHistorico.Free; inherited; end;

procedure TPedidoContext.SetEstado(AEstado: IEstadoPedido);
begin
  FEstado := AEstado;
  RegistrarTransicao('→ ' + AEstado.Nome);
end;

procedure TPedidoContext.RegistrarTransicao(const AMsg: string);
begin
  FHistorico.Add(Format('[%s] %s', [FormatDateTime('hh:nn:ss', Now), AMsg]));
end;

procedure TPedidoContext.Confirmar; begin FEstado.Confirmar(Self); end;
procedure TPedidoContext.Pagar;     begin FEstado.Pagar(Self); end;
procedure TPedidoContext.Enviar;    begin FEstado.Enviar(Self); end;
procedure TPedidoContext.Entregar;  begin FEstado.Entregar(Self); end;
procedure TPedidoContext.Cancelar;  begin FEstado.Cancelar(Self); end;

function TPedidoContext.EstadoAtual: string;
begin Result := FEstado.Nome; end;

function TPedidoContext.ObterHistorico: string;
begin Result := FHistorico.Text; end;

// ---------------------------------------------------------------------------
// Helper para ações inválidas
// ---------------------------------------------------------------------------

procedure AcaoInvalida(const AEstado, AAcao: string);
begin
  Writeln(Format('[Estado:%s] Ação "%s" não permitida neste estado', [AEstado, AAcao]));
end;

// ---------------------------------------------------------------------------
// TEstadoAguardandoConfirmacao
// ---------------------------------------------------------------------------

procedure TEstadoAguardandoConfirmacao.Confirmar(ACtx: TPedidoContext);
begin
  Writeln('[Pedido] Confirmado!');
  ACtx.SetEstado(TEstadoConfirmado.Create);
end;

procedure TEstadoAguardandoConfirmacao.Pagar(ACtx: TPedidoContext);
begin AcaoInvalida(GetNome, 'Pagar'); end;

procedure TEstadoAguardandoConfirmacao.Enviar(ACtx: TPedidoContext);
begin AcaoInvalida(GetNome, 'Enviar'); end;

procedure TEstadoAguardandoConfirmacao.Entregar(ACtx: TPedidoContext);
begin AcaoInvalida(GetNome, 'Entregar'); end;

procedure TEstadoAguardandoConfirmacao.Cancelar(ACtx: TPedidoContext);
begin
  Writeln('[Pedido] Cancelado antes da confirmação.');
  ACtx.SetEstado(TEstadoCancelado.Create);
end;

function TEstadoAguardandoConfirmacao.GetNome: string;
begin Result := 'Aguardando Confirmação'; end;

// ---------------------------------------------------------------------------
// TEstadoConfirmado
// ---------------------------------------------------------------------------

procedure TEstadoConfirmado.Confirmar(ACtx: TPedidoContext);
begin AcaoInvalida(GetNome, 'Confirmar'); end;

procedure TEstadoConfirmado.Pagar(ACtx: TPedidoContext);
begin
  Writeln(Format('[Pedido] Pagamento de R$%.2f recebido!', [ACtx.Total]));
  ACtx.SetEstado(TEstadoPago.Create);
end;

procedure TEstadoConfirmado.Enviar(ACtx: TPedidoContext);
begin AcaoInvalida(GetNome, 'Enviar'); end;

procedure TEstadoConfirmado.Entregar(ACtx: TPedidoContext);
begin AcaoInvalida(GetNome, 'Entregar'); end;

procedure TEstadoConfirmado.Cancelar(ACtx: TPedidoContext);
begin
  Writeln('[Pedido] Cancelado após confirmação.');
  ACtx.SetEstado(TEstadoCancelado.Create);
end;

function TEstadoConfirmado.GetNome: string;
begin Result := 'Confirmado'; end;

// ---------------------------------------------------------------------------
// TEstadoPago
// ---------------------------------------------------------------------------

procedure TEstadoPago.Confirmar(ACtx: TPedidoContext); begin AcaoInvalida(GetNome, 'Confirmar'); end;
procedure TEstadoPago.Pagar(ACtx: TPedidoContext);     begin AcaoInvalida(GetNome, 'Pagar'); end;

procedure TEstadoPago.Enviar(ACtx: TPedidoContext);
begin
  Writeln('[Pedido] Enviado para transporte!');
  ACtx.SetEstado(TEstadoEnviado.Create);
end;

procedure TEstadoPago.Entregar(ACtx: TPedidoContext);
begin AcaoInvalida(GetNome, 'Entregar'); end;

procedure TEstadoPago.Cancelar(ACtx: TPedidoContext);
begin AcaoInvalida(GetNome, 'Cancelar — estornos tratados externamente'); end;

function TEstadoPago.GetNome: string;
begin Result := 'Pago'; end;

// ---------------------------------------------------------------------------
// TEstadoEnviado
// ---------------------------------------------------------------------------

procedure TEstadoEnviado.Confirmar(ACtx: TPedidoContext); begin AcaoInvalida(GetNome, 'Confirmar'); end;
procedure TEstadoEnviado.Pagar(ACtx: TPedidoContext);     begin AcaoInvalida(GetNome, 'Pagar'); end;
procedure TEstadoEnviado.Enviar(ACtx: TPedidoContext);    begin AcaoInvalida(GetNome, 'Enviar'); end;

procedure TEstadoEnviado.Entregar(ACtx: TPedidoContext);
begin
  Writeln('[Pedido] Entregue ao cliente!');
  ACtx.SetEstado(TEstadoEntregue.Create);
end;

procedure TEstadoEnviado.Cancelar(ACtx: TPedidoContext);
begin AcaoInvalida(GetNome, 'Cancelar — item em trânsito'); end;

function TEstadoEnviado.GetNome: string;
begin Result := 'Enviado'; end;

// ---------------------------------------------------------------------------
// TEstadoEntregue / TEstadoCancelado — estados finais
// ---------------------------------------------------------------------------

procedure TEstadoEntregue.Confirmar(ACtx: TPedidoContext); begin AcaoInvalida(GetNome, 'Confirmar'); end;
procedure TEstadoEntregue.Pagar(ACtx: TPedidoContext);     begin AcaoInvalida(GetNome, 'Pagar'); end;
procedure TEstadoEntregue.Enviar(ACtx: TPedidoContext);    begin AcaoInvalida(GetNome, 'Enviar'); end;
procedure TEstadoEntregue.Entregar(ACtx: TPedidoContext);  begin AcaoInvalida(GetNome, 'Entregar'); end;
procedure TEstadoEntregue.Cancelar(ACtx: TPedidoContext);  begin AcaoInvalida(GetNome, 'Cancelar'); end;
function TEstadoEntregue.GetNome: string; begin Result := 'Entregue (Final)'; end;

procedure TEstadoCancelado.Confirmar(ACtx: TPedidoContext); begin AcaoInvalida(GetNome, 'Confirmar'); end;
procedure TEstadoCancelado.Pagar(ACtx: TPedidoContext);     begin AcaoInvalida(GetNome, 'Pagar'); end;
procedure TEstadoCancelado.Enviar(ACtx: TPedidoContext);    begin AcaoInvalida(GetNome, 'Enviar'); end;
procedure TEstadoCancelado.Entregar(ACtx: TPedidoContext);  begin AcaoInvalida(GetNome, 'Entregar'); end;
procedure TEstadoCancelado.Cancelar(ACtx: TPedidoContext);  begin AcaoInvalida(GetNome, 'Cancelar'); end;
function TEstadoCancelado.GetNome: string; begin Result := 'Cancelado (Final)'; end;

// ---------------------------------------------------------------------------
// USO:
//   var P := TPedidoContext.Create('PED-001', 'Alice', 299.90);
//   Writeln('Estado: ', P.EstadoAtual);  // Aguardando Confirmação
//
//   P.Pagar;       // Ação inválida — não confirmado ainda
//   P.Confirmar;   // → Confirmado
//   P.Pagar;       // → Pago
//   P.Enviar;      // → Enviado
//   P.Entregar;    // → Entregue (Final)
//   P.Cancelar;    // Ação inválida — estado final
//
//   Writeln(P.ObterHistorico);
//   // [hh:nn:ss] → Aguardando Confirmação
//   // [hh:nn:ss] → Confirmado
//   // [hh:nn:ss] → Pago
//   // [hh:nn:ss] → Enviado
//   // [hh:nn:ss] → Entregue (Final)
// ---------------------------------------------------------------------------

end.

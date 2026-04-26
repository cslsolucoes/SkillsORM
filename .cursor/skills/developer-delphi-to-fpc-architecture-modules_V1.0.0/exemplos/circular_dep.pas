(*
  EXEMPLO: Detectar e resolver dependências circulares entre units Delphi
  Skill: developer-delphi-to-fpc-architecture-modules_V1.0.0

  PROBLEMA — Circular unit reference:
    O compilador Delphi emite: "[dcc32 Error] uA.pas: E2047 Circular unit reference to uB"
    Quando: uA usa uB (interface section) E uB usa uA (interface section).

  CAUSAS COMUNS:
    1. Dois módulos se referenciam mutuamente nas interfaces.
    2. Um tipo compartilhado está definido em um dos módulos em vez de em um base.
    3. Um formulário e sua lógica de negócio se referenciam.

  SOLUCOES:
    A) Mover tipo compartilhado para unit base (sem dependências).
    B) Mover um dos uses para a secao "implementation" (quando viavel).
    C) Usar forward declaration (type TClasse = class) para quebrar dependencia de tipo.
    D) Introduzir interface (I*) para desacoplar os dois módulos.

  ESTE ARQUIVO demonstra as solucoes A, B e D em um único exemplo compilavel.
  Compilar: dcc32 circular_dep.pas  OU  dcc64 circular_dep.pas
*)
program circular_dep;
{$APPTYPE CONSOLE}
{$IFDEF FPC}
  {$mode delphi}
  {$H+}
{$ENDIF}

uses
  SysUtils;

// =============================================================================
// PROBLEMA SIMULADO (comentado — nao compila se descomentado):
//
//   unit uCliente;        unit uPedido;
//   interface             interface
//   uses uPedido;  ←───┐  uses uCliente;  ──→ CIRCULAR!
//   type               │  type
//     TCliente = class  │    TPedido = class
//       FPedidos: TList;│      FCliente: TCliente;
//     end;              └───────────────────────
// =============================================================================

// =============================================================================
// SOLUCAO A: Tipo compartilhado em unit base (sem deps circulares)
// Normalmente seria: uCommon.Types.pas
// =============================================================================

type
  // Tipos basicos sem dependencias — colocar em unit "Common" ou "Types"
  TClienteID = type Integer;
  TPedidoID  = type Integer;
  TValor     = type Double;

// =============================================================================
// SOLUCAO D: Usar interfaces para desacoplar (preferida para deps entre modulos)
// uCliente.Interfaces.pas
// uPedido.Interfaces.pas
// Cada modulo depende APENAS das interfaces, nunca das implementacoes.
// =============================================================================

type
  // Forward declaration — permite referenciar antes de definir completamente
  IPedido = interface;

  ICliente = interface
    ['{11111111-2222-3333-4444-555555555555}']
    function GetID: TClienteID;
    function GetNome: string;
    function PedidoCount: Integer;
    property ID: TClienteID read GetID;
    property Nome: string read GetNome;
  end;

  IPedido = interface
    ['{AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE}']
    function GetID: TPedidoID;
    function GetValor: TValor;
    function GetClienteID: TClienteID;
    property ID: TPedidoID read GetID;
    property Valor: TValor read GetValor;
    property ClienteID: TClienteID read GetClienteID;
  end;

// =============================================================================
// Implementacoes (em projeto real: units separadas)
// TCliente depende de IPedido (interface), nunca de TPedido (classe concreta)
// TPedido depende de ICliente (interface), nunca de TCliente (classe concreta)
// =============================================================================

type
  TPedidoImpl = class(TInterfacedObject, IPedido)
  private
    FID: TPedidoID;
    FValor: TValor;
    FClienteID: TClienteID;
    function GetID: TPedidoID;
    function GetValor: TValor;
    function GetClienteID: TClienteID;
  public
    constructor Create(const AID: TPedidoID; const AValor: TValor; const AClienteID: TClienteID);
  end;

  TClienteImpl = class(TInterfacedObject, ICliente)
  private
    FID: TClienteID;
    FNome: string;
    FPedidos: TInterfaceList; // lista de IPedido — nao de TPedidoImpl
    function GetID: TClienteID;
    function GetNome: string;
  public
    constructor Create(const AID: TClienteID; const ANome: string);
    destructor Destroy; override;
    procedure AdicionarPedido(const APedido: IPedido);
    function PedidoCount: Integer;
  end;

// --- TPedidoImpl ---

constructor TPedidoImpl.Create(const AID: TPedidoID; const AValor: TValor; const AClienteID: TClienteID);
begin
  inherited Create;
  FID := AID;
  FValor := AValor;
  FClienteID := AClienteID;
end;

function TPedidoImpl.GetID: TPedidoID;
begin
  Result := FID;
end;

function TPedidoImpl.GetValor: TValor;
begin
  Result := FValor;
end;

function TPedidoImpl.GetClienteID: TClienteID;
begin
  Result := FClienteID;
end;

// --- TClienteImpl ---

constructor TClienteImpl.Create(const AID: TClienteID; const ANome: string);
begin
  inherited Create;
  FID := AID;
  FNome := ANome;
  FPedidos := TInterfaceList.Create;
end;

destructor TClienteImpl.Destroy;
begin
  FPedidos.Free;
  inherited;
end;

procedure TClienteImpl.AdicionarPedido(const APedido: IPedido);
begin
  FPedidos.Add(APedido);
end;

function TClienteImpl.GetID: TClienteID;
begin
  Result := FID;
end;

function TClienteImpl.GetNome: string;
begin
  Result := FNome;
end;

function TClienteImpl.PedidoCount: Integer;
begin
  Result := FPedidos.Count;
end;

// =============================================================================
// SOLUCAO B (comentada — apenas conceitual)
// Quando nao e possivel separar tipos, mover uses para implementation section:
//
//   unit uA;
//   interface
//   // SEM uses uB aqui
//   type TClasseA = class ... end;
//   implementation
//   uses uB;   ← uses na implementation: compila sem circular reference
//   ...
//
// LIMITACAO: tipos de uB nao podem aparecer na interface section de uA.
// Util apenas quando uA usa uB apenas em implementacoes de metodos.
// =============================================================================

// =============================================================================
// Programa principal — demonstracao
// =============================================================================

var
  Cliente: ICliente;
  Pedido1, Pedido2: IPedido;
begin
  WriteLn('=== Exemplo: Resolucao de Dependencias Circulares ===');
  WriteLn;

  // Criar cliente
  Cliente := TClienteImpl.Create(1, 'Ana Beatriz');

  // Criar pedidos referenciando o cliente por ID (nao por objeto)
  // Evita dependencia circular em runtime tambem
  Pedido1 := TPedidoImpl.Create(101, 250.00, Cliente.ID);
  Pedido2 := TPedidoImpl.Create(102, 875.50, Cliente.ID);

  // Associar pedidos ao cliente via interface
  TClienteImpl(Cliente).AdicionarPedido(Pedido1);
  TClienteImpl(Cliente).AdicionarPedido(Pedido2);

  WriteLn(Format('Cliente: ID=%d Nome=%s | Pedidos: %d',
    [Cliente.ID, Cliente.Nome, Cliente.PedidoCount]));
  WriteLn(Format('Pedido1: ID=%d Valor=R$ %.2f ClienteID=%d',
    [Pedido1.ID, Pedido1.Valor, Pedido1.ClienteID]));
  WriteLn(Format('Pedido2: ID=%d Valor=R$ %.2f ClienteID=%d',
    [Pedido2.ID, Pedido2.Valor, Pedido2.ClienteID]));

  WriteLn;
  WriteLn('Resumo das solucoes aplicadas:');
  WriteLn('  A) TClienteID/TPedidoID em unit base (sem deps)');
  WriteLn('  B) uses na implementation section (quando necessario)');
  WriteLn('  D) Interfaces ICliente/IPedido desacoplam as implementacoes');

  WriteLn;
  WriteLn('OK -- developer-delphi-to-fpc-architecture-modules :: circular_dep');
end.

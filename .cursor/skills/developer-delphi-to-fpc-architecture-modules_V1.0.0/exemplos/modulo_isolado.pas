(*
  EXEMPLO: Módulo isolado com interface pública e implementação privada
  Skill: developer-delphi-to-fpc-architecture-modules_V1.0.0

  PADRAO APLICADO:
    - Interface pública em unit separada (*.Interfaces) — os consumidores só veem isso.
    - Implementação privada na unit de impl — ninguém usa diretamente.
    - Factory pública como único ponto de criação — esconde o tipo concreto.

  ARQUIVOS NORMALMENTE SERIAM:
    uPagamento.Interfaces.pas   ← interface pública (esta unit)
    uPagamento.Impl.pas         ← implementação (segundo bloco abaixo)
    uPagamento.Factory.pas      ← factory (terceiro bloco)

  NESTE ARQUIVO: tudo em um único .pas para ser compilável standalone.
  Compilar: dcc32 modulo_isolado.pas  OU  dcc64 modulo_isolado.pas
*)
program modulo_isolado;
{$APPTYPE CONSOLE}
{$IFDEF FPC}
  {$mode delphi}
  {$H+}
{$ENDIF}

uses
  SysUtils;

// =============================================================================
// SECAO 1: Interface publica (normalmente em uPagamento.Interfaces.pas)
// =============================================================================

type
  // Contrato publico — tudo que o consumidor precisa saber
  IPagamento = interface
    ['{C1D2E3F4-A5B6-7890-ABCD-EF0123456789}']
    function Processar(const AValor: Double; const ADescricao: string): Boolean;
    function UltimaTransacaoID: string;
    function SaldoDisponivel: Double;
  end;

  // Factory publica — unico ponto de criacao
  // Em um projeto real estaria em uPagamento.Factory.pas
  TPagamentoFactory = class
  public
    // Convencao: New retorna a interface; esconde o tipo concreto
    class function New(const AProvedor: string): IPagamento;
  end;

// =============================================================================
// SECAO 2: Implementacao privada (normalmente em uPagamento.Impl.pas)
// Os consumidores NAO devem usar TPixPagamento diretamente —
// sempre usar via interface IPagamento e TPagamentoFactory.New
// =============================================================================

type
  TPixPagamento = class(TInterfacedObject, IPagamento)
  private
    FProvedor: string;
    FUltimaTransacaoID: string;
    FSaldo: Double;
  public
    constructor Create(const AProvedor: string);
    function Processar(const AValor: Double; const ADescricao: string): Boolean;
    function UltimaTransacaoID: string;
    function SaldoDisponivel: Double;
  end;

  TCartaoPagamento = class(TInterfacedObject, IPagamento)
  private
    FProvedor: string;
    FUltimaTransacaoID: string;
    FSaldo: Double;
  public
    constructor Create(const AProvedor: string);
    function Processar(const AValor: Double; const ADescricao: string): Boolean;
    function UltimaTransacaoID: string;
    function SaldoDisponivel: Double;
  end;

// =============================================================================
// Implementacoes
// =============================================================================

constructor TPixPagamento.Create(const AProvedor: string);
begin
  inherited Create;
  FProvedor := AProvedor;
  FSaldo := 5000.00; // saldo simulado
  FUltimaTransacaoID := '';
end;

function TPixPagamento.Processar(const AValor: Double; const ADescricao: string): Boolean;
begin
  if AValor > FSaldo then
  begin
    WriteLn(Format('[PIX][%s] Saldo insuficiente: %.2f < %.2f', [FProvedor, FSaldo, AValor]));
    Result := False;
    Exit;
  end;
  FSaldo := FSaldo - AValor;
  FUltimaTransacaoID := Format('PIX-%s-%d', [FProvedor, Random(99999)]);
  WriteLn(Format('[PIX][%s] Processado: R$ %.2f | Desc: %s | ID: %s',
    [FProvedor, AValor, ADescricao, FUltimaTransacaoID]));
  Result := True;
end;

function TPixPagamento.UltimaTransacaoID: string;
begin
  Result := FUltimaTransacaoID;
end;

function TPixPagamento.SaldoDisponivel: Double;
begin
  Result := FSaldo;
end;

constructor TCartaoPagamento.Create(const AProvedor: string);
begin
  inherited Create;
  FProvedor := AProvedor;
  FSaldo := 10000.00;
  FUltimaTransacaoID := '';
end;

function TCartaoPagamento.Processar(const AValor: Double; const ADescricao: string): Boolean;
begin
  if AValor > FSaldo then
  begin
    WriteLn(Format('[CARTAO][%s] Limite insuficiente: %.2f < %.2f', [FProvedor, FSaldo, AValor]));
    Result := False;
    Exit;
  end;
  FSaldo := FSaldo - AValor;
  FUltimaTransacaoID := Format('CARD-%s-%d', [FProvedor, Random(99999)]);
  WriteLn(Format('[CARTAO][%s] Processado: R$ %.2f | Desc: %s | ID: %s',
    [FProvedor, AValor, ADescricao, FUltimaTransacaoID]));
  Result := True;
end;

function TCartaoPagamento.UltimaTransacaoID: string;
begin
  Result := FUltimaTransacaoID;
end;

function TCartaoPagamento.SaldoDisponivel: Double;
begin
  Result := FSaldo;
end;

// =============================================================================
// Factory — unico ponto de criacao (normalmente em uPagamento.Factory.pas)
// =============================================================================

class function TPagamentoFactory.New(const AProvedor: string): IPagamento;
begin
  // Logica de selecao do tipo concreto — oculta dos consumidores
  if SameText(AProvedor, 'PIX') then
    Result := TPixPagamento.Create(AProvedor)
  else if SameText(AProvedor, 'CARTAO') then
    Result := TCartaoPagamento.Create(AProvedor)
  else
    raise Exception.CreateFmt('Provedor de pagamento nao suportado: %s', [AProvedor]);
end;

// =============================================================================
// Programa principal — usa APENAS a interface e a factory; nunca o tipo concreto
// =============================================================================

procedure ProcessarVenda(const APagamento: IPagamento; const AValor: Double);
begin
  // O codigo aqui nao sabe se e PIX ou Cartao — depende apenas de IPagamento
  WriteLn(Format('Saldo antes: R$ %.2f', [APagamento.SaldoDisponivel]));
  if APagamento.Processar(AValor, 'Venda #001') then
    WriteLn(Format('Sucesso! ID: %s | Saldo apos: R$ %.2f',
      [APagamento.UltimaTransacaoID, APagamento.SaldoDisponivel]))
  else
    WriteLn('Pagamento recusado.');
end;

var
  Pagamento: IPagamento;
begin
  Randomize;
  WriteLn('=== Exemplo: Modulo Isolado com Interface Publica ===');
  WriteLn;

  // Consumidor usa APENAS TPagamentoFactory.New e IPagamento
  // Nunca: TPixPagamento.Create diretamente

  WriteLn('--- Testando PIX ---');
  Pagamento := TPagamentoFactory.New('PIX');
  ProcessarVenda(Pagamento, 150.00);
  WriteLn;

  WriteLn('--- Testando CARTAO ---');
  Pagamento := TPagamentoFactory.New('CARTAO');
  ProcessarVenda(Pagamento, 3500.00);
  WriteLn;

  WriteLn('--- Testando valor acima do saldo ---');
  Pagamento := TPagamentoFactory.New('PIX');
  ProcessarVenda(Pagamento, 9999.00);
  WriteLn;

  try
    WriteLn('--- Testando provedor invalido ---');
    Pagamento := TPagamentoFactory.New('BOLETO');
  except
    on E: Exception do
      WriteLn('Excecao esperada: ' + E.Message);
  end;

  WriteLn;
  WriteLn('OK -- developer-delphi-to-fpc-architecture-modules :: modulo_isolado');
end.

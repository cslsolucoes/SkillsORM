unit chain_of_resp;
{
  Chain of Responsibility em Delphi — pipeline de handlers por alçada de crédito
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Request — dados que percorrem a cadeia
// ---------------------------------------------------------------------------
type
  TStatusSolicitacao = (ssAguardando, ssAprovada, ssRejeitada, ssEscalada);

  TSolicitacaoCredito = record
    Id:         string;
    Cliente:    string;
    Valor:      Currency;
    Pontuacao:  Integer;   // score de crédito 0-1000
    Status:     TStatusSolicitacao;
    Responsavel: string;
    Motivo:     string;
  end;

// ---------------------------------------------------------------------------
// Interface Handler
// ---------------------------------------------------------------------------
type
  IAprovadorCredito = interface
  ['{CR000001-0000-0000-0000-000000000001}']
    procedure SetProximo(AProximo: IAprovadorCredito);
    procedure ProcessarSolicitacao(var ASolic: TSolicitacaoCredito);
    function  GetNome: string;
    property Nome: string read GetNome;
  end;

// ---------------------------------------------------------------------------
// Base abstrata — implementa a cadeia de delegação
// ---------------------------------------------------------------------------
type
  TAprovadorBase = class abstract(TInterfacedObject, IAprovadorCredito)
  protected
    FProximo: IAprovadorCredito;
    FNome:    string;
    FAlcada:  Currency;  // valor máximo que pode aprovar
    procedure Aprovar(var ASolic: TSolicitacaoCredito; const AMotivo: string);
    procedure Rejeitar(var ASolic: TSolicitacaoCredito; const AMotivo: string);
    procedure PassarAdiante(var ASolic: TSolicitacaoCredito);
    function  PodeAprovar(const ASolic: TSolicitacaoCredito): Boolean; virtual;
  public
    constructor Create(const ANome: string; AAlcada: Currency);
    procedure SetProximo(AProximo: IAprovadorCredito);
    procedure ProcessarSolicitacao(var ASolic: TSolicitacaoCredito); virtual; abstract;
    function  GetNome: string;
  end;

// ---------------------------------------------------------------------------
// Handlers concretos — por alçada hierárquica
// ---------------------------------------------------------------------------
type
  TAnalistaCredito = class(TAprovadorBase)
  public
    constructor Create;
    procedure ProcessarSolicitacao(var ASolic: TSolicitacaoCredito); override;
  end;

  TSupervisorCredito = class(TAprovadorBase)
  public
    constructor Create;
    procedure ProcessarSolicitacao(var ASolic: TSolicitacaoCredito); override;
  end;

  TGerenteCredito = class(TAprovadorBase)
  public
    constructor Create;
    procedure ProcessarSolicitacao(var ASolic: TSolicitacaoCredito); override;
  end;

  TDiretorCredito = class(TAprovadorBase)
  public
    constructor Create;
    procedure ProcessarSolicitacao(var ASolic: TSolicitacaoCredito); override;
  end;

// ---------------------------------------------------------------------------
// Handler de filtro — verifica pontuação antes de aprovar valor
// ---------------------------------------------------------------------------
type
  TFiltroScoreCredito = class(TAprovadorBase)
  private
    FScoreMinimo: Integer;
  public
    constructor Create(AScoreMinimo: Integer);
    procedure ProcessarSolicitacao(var ASolic: TSolicitacaoCredito); override;
  end;

// ---------------------------------------------------------------------------
// Pipeline builder — facilita montar a cadeia
// ---------------------------------------------------------------------------
type
  TCadeiaCredito = class
  private
    FFirst: IAprovadorCredito;
    FLast:  IAprovadorCredito;
  public
    function Adicionar(AHandler: IAprovadorCredito): TCadeiaCredito;
    procedure Processar(var ASolic: TSolicitacaoCredito);
  end;

// Helper
function NovaSolicitacao(const ACliente: string; AValor: Currency;
  APontuacao: Integer): TSolicitacaoCredito;

implementation

uses System.DateUtils;

var GContadorId: Integer = 0;

// ---------------------------------------------------------------------------
// TAprovadorBase
// ---------------------------------------------------------------------------

constructor TAprovadorBase.Create(const ANome: string; AAlcada: Currency);
begin inherited Create; FNome := ANome; FAlcada := AAlcada; end;

procedure TAprovadorBase.SetProximo(AProximo: IAprovadorCredito);
begin FProximo := AProximo; end;

function TAprovadorBase.GetNome: string;
begin Result := FNome; end;

function TAprovadorBase.PodeAprovar(const ASolic: TSolicitacaoCredito): Boolean;
begin Result := ASolic.Valor <= FAlcada; end;

procedure TAprovadorBase.Aprovar(var ASolic: TSolicitacaoCredito; const AMotivo: string);
begin
  ASolic.Status     := ssAprovada;
  ASolic.Responsavel := FNome;
  ASolic.Motivo     := AMotivo;
  Writeln(Format('[%s] APROVADO R$%.2f para %s: %s',
    [FNome, ASolic.Valor, ASolic.Cliente, AMotivo]));
end;

procedure TAprovadorBase.Rejeitar(var ASolic: TSolicitacaoCredito; const AMotivo: string);
begin
  ASolic.Status     := ssRejeitada;
  ASolic.Responsavel := FNome;
  ASolic.Motivo     := AMotivo;
  Writeln(Format('[%s] REJEITADO R$%.2f para %s: %s',
    [FNome, ASolic.Valor, ASolic.Cliente, AMotivo]));
end;

procedure TAprovadorBase.PassarAdiante(var ASolic: TSolicitacaoCredito);
begin
  if FProximo <> nil then
  begin
    Writeln(Format('[%s] Escalando para %s...', [FNome, FProximo.Nome]));
    ASolic.Status := ssEscalada;
    FProximo.ProcessarSolicitacao(ASolic);
  end
  else
  begin
    Writeln(Format('[%s] Sem próximo handler — rejeitando por falta de alçada', [FNome]));
    Rejeitar(ASolic, 'Valor excede maior alçada disponível');
  end;
end;

// ---------------------------------------------------------------------------
// Handlers por alçada
// ---------------------------------------------------------------------------

constructor TAnalistaCredito.Create;
begin inherited Create('Analista de Crédito', 5000); end;

procedure TAnalistaCredito.ProcessarSolicitacao(var ASolic: TSolicitacaoCredito);
begin
  if PodeAprovar(ASolic) then
    Aprovar(ASolic, 'Dentro da alçada de analista')
  else
    PassarAdiante(ASolic);
end;

constructor TSupervisorCredito.Create;
begin inherited Create('Supervisor de Crédito', 25000); end;

procedure TSupervisorCredito.ProcessarSolicitacao(var ASolic: TSolicitacaoCredito);
begin
  if PodeAprovar(ASolic) then
    Aprovar(ASolic, 'Dentro da alçada de supervisor')
  else
    PassarAdiante(ASolic);
end;

constructor TGerenteCredito.Create;
begin inherited Create('Gerente de Crédito', 100000); end;

procedure TGerenteCredito.ProcessarSolicitacao(var ASolic: TSolicitacaoCredito);
begin
  if PodeAprovar(ASolic) then
    Aprovar(ASolic, 'Aprovado pela gerência')
  else
    PassarAdiante(ASolic);
end;

constructor TDiretorCredito.Create;
begin inherited Create('Diretor Financeiro', 1000000); end;

procedure TDiretorCredito.ProcessarSolicitacao(var ASolic: TSolicitacaoCredito);
begin
  if PodeAprovar(ASolic) then
    Aprovar(ASolic, 'Aprovado pela diretoria')
  else
    Rejeitar(ASolic, 'Excede alçada máxima — necessita comitê');
end;

// ---------------------------------------------------------------------------
// TFiltroScoreCredito
// ---------------------------------------------------------------------------

constructor TFiltroScoreCredito.Create(AScoreMinimo: Integer);
begin inherited Create('Filtro Score', MaxCurrency); FScoreMinimo := AScoreMinimo; end;

procedure TFiltroScoreCredito.ProcessarSolicitacao(var ASolic: TSolicitacaoCredito);
begin
  if ASolic.Pontuacao < FScoreMinimo then
    Rejeitar(ASolic, Format('Score %d abaixo do mínimo %d', [ASolic.Pontuacao, FScoreMinimo]))
  else
    PassarAdiante(ASolic);
end;

// ---------------------------------------------------------------------------
// TCadeiaCredito
// ---------------------------------------------------------------------------

function TCadeiaCredito.Adicionar(AHandler: IAprovadorCredito): TCadeiaCredito;
begin
  if FFirst = nil then FFirst := AHandler;
  if FLast  <> nil then FLast.SetProximo(AHandler);
  FLast := AHandler;
  Result := Self;
end;

procedure TCadeiaCredito.Processar(var ASolic: TSolicitacaoCredito);
begin
  if FFirst <> nil then FFirst.ProcessarSolicitacao(ASolic)
  else raise EInvalidOperation.Create('Cadeia vazia');
end;

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

function NovaSolicitacao(const ACliente: string; AValor: Currency;
  APontuacao: Integer): TSolicitacaoCredito;
begin
  Inc(GContadorId);
  Result.Id        := Format('SOL-%04d', [GContadorId]);
  Result.Cliente   := ACliente;
  Result.Valor     := AValor;
  Result.Pontuacao := APontuacao;
  Result.Status    := ssAguardando;
  Result.Responsavel := '';
  Result.Motivo    := '';
end;

// ---------------------------------------------------------------------------
// USO:
//   var Cadeia := TCadeiaCredito.Create;
//   Cadeia
//     .Adicionar(TFiltroScoreCredito.Create(500))  // rejeita score < 500
//     .Adicionar(TAnalistaCredito.Create)          // até R$5.000
//     .Adicionar(TSupervisorCredito.Create)        // até R$25.000
//     .Adicionar(TGerenteCredito.Create)           // até R$100.000
//     .Adicionar(TDiretorCredito.Create);          // até R$1.000.000
//
//   var S1 := NovaSolicitacao('Alice', 3000, 750);
//   Cadeia.Processar(S1);   // Analista aprova
//
//   var S2 := NovaSolicitacao('Bob', 50000, 680);
//   Cadeia.Processar(S2);   // Gerente aprova
//
//   var S3 := NovaSolicitacao('Carol', 200, 300);
//   Cadeia.Processar(S3);   // Filtro score rejeita
//
//   var S4 := NovaSolicitacao('Dave', 2000000, 900);
//   Cadeia.Processar(S4);   // Diretor rejeita (excede alçada máxima)
// ---------------------------------------------------------------------------

end.

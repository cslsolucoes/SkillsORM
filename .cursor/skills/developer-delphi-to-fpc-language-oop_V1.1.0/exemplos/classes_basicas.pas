unit classes_basicas;
{
  EXEMPLO: Classes basicas em Delphi — declaration, constructor, destructor
  Compilavel: dcc32 / dcc64
  Demonstra:
    - Declaracao de classe com secoes de visibilidade
    - Constructor com parametros
    - Destructor override (obrigatorio em classes com recursos)
    - Properties com getter/setter
    - Metodos de instancia
    - FreeAndNil e boas praticas de gerenciamento de memoria
}

interface

uses
  System.SysUtils, System.Classes;

// ---------------------------------------------------------------------------
// Classe simples: Conta Bancaria
// ---------------------------------------------------------------------------
type
  TContaBancaria = class(TObject)
  private
    FNumero    : string;
    FSaldo     : Currency;
    FTitular   : string;
    FHistorico : TStringList; // recurso que precisamos liberar

    procedure SetSaldo(AValor: Currency);
    function  GetNumero: string;

  public
    constructor Create(const ANumero, ATitular: string; ASaldoInicial: Currency = 0);
    destructor Destroy; override; // SEMPRE override, nunca override;final em TObject

    procedure Depositar(AValor: Currency);
    procedure Sacar(AValor: Currency);
    function  ExtratoFormatado: string;

    property Numero   : string   read GetNumero;
    property Saldo    : Currency read FSaldo   write SetSaldo;
    property Titular  : string   read FTitular;
    property Historico: TStringList read FHistorico;
  end;

// ---------------------------------------------------------------------------
// Excecao especializada
// ---------------------------------------------------------------------------
type
  ESaldoInsuficiente = class(Exception)
  private
    FSaldoAtual: Currency;
    FValorSaque: Currency;
  public
    constructor Create(ASaldoAtual, AValorSaque: Currency);
    property SaldoAtual: Currency read FSaldoAtual;
    property ValorSaque: Currency read FValorSaque;
  end;

implementation

// ---------------------------------------------------------------------------
// TContaBancaria
// ---------------------------------------------------------------------------

constructor TContaBancaria.Create(const ANumero, ATitular: string;
  ASaldoInicial: Currency);
begin
  inherited Create; // chamar inherited em constructor SEMPRE

  FNumero   := ANumero;
  FTitular  := ATitular;
  FSaldo    := ASaldoInicial;

  // Criar recursos gerenciados por esta classe
  FHistorico := TStringList.Create;
  FHistorico.Add(Format('[%s] Conta aberta. Saldo inicial: %s',
    [DateTimeToStr(Now), CurrToStr(ASaldoInicial)]));
end;

destructor TContaBancaria.Destroy;
begin
  // Liberar recursos criados no constructor (ordem inversa de criacao)
  FHistorico.Free; // .Free e seguro mesmo se FHistorico = nil
  // FHistorico := nil; // opcional — objeto esta sendo destruido

  inherited Destroy; // chamar inherited em destructor SEMPRE, no final
end;

function TContaBancaria.GetNumero: string;
begin
  Result := FNumero;
end;

procedure TContaBancaria.SetSaldo(AValor: Currency);
begin
  if AValor < 0 then
    raise Exception.Create('Saldo nao pode ser negativo');
  FSaldo := AValor;
end;

procedure TContaBancaria.Depositar(AValor: Currency);
begin
  if AValor <= 0 then
    raise Exception.CreateFmt('Valor de deposito invalido: %s', [CurrToStr(AValor)]);

  FSaldo := FSaldo + AValor;
  FHistorico.Add(Format('[%s] Deposito: +%s | Saldo: %s',
    [DateTimeToStr(Now), CurrToStr(AValor), CurrToStr(FSaldo)]));
end;

procedure TContaBancaria.Sacar(AValor: Currency);
begin
  if AValor <= 0 then
    raise Exception.CreateFmt('Valor de saque invalido: %s', [CurrToStr(AValor)]);

  if AValor > FSaldo then
    raise ESaldoInsuficiente.Create(FSaldo, AValor);

  FSaldo := FSaldo - AValor;
  FHistorico.Add(Format('[%s] Saque: -%s | Saldo: %s',
    [DateTimeToStr(Now), CurrToStr(AValor), CurrToStr(FSaldo)]));
end;

function TContaBancaria.ExtratoFormatado: string;
begin
  Result := Format('Conta: %s | Titular: %s | Saldo: %s',
    [FNumero, FTitular, FormatCurr('#,##0.00', FSaldo)]);
end;

// ---------------------------------------------------------------------------
// ESaldoInsuficiente
// ---------------------------------------------------------------------------

constructor ESaldoInsuficiente.Create(ASaldoAtual, AValorSaque: Currency);
begin
  FSaldoAtual := ASaldoAtual;
  FValorSaque := AValorSaque;
  inherited CreateFmt('Saldo insuficiente. Saldo: %s, Saque solicitado: %s',
    [CurrToStr(ASaldoAtual), CurrToStr(AValorSaque)]);
end;

// ---------------------------------------------------------------------------
// Demonstracao de uso e boas praticas
// ---------------------------------------------------------------------------
procedure DemonstrarConta;
var
  Conta: TContaBancaria;
begin
  // PADRAO CORRETO: criar e liberar com try/finally
  Conta := TContaBancaria.Create('001-2345-6', 'Maria Silva', 1000.00);
  try
    Conta.Depositar(500.00);
    Conta.Sacar(200.00);

    try
      Conta.Sacar(2000.00); // vai lancar ESaldoInsuficiente
    except
      on E: ESaldoInsuficiente do
        Writeln('Erro: ', E.Message,
          ' | Saldo atual: ', E.SaldoAtual:6:2);
    end;

    Writeln(Conta.ExtratoFormatado);
    Writeln(Conta.Historico.Text);

  finally
    Conta.Free; // ou FreeAndNil(Conta) se variavel pode ser usada depois
  end;

  // FreeAndNil: libera E seta para nil — util para verificar depois
  // FreeAndNil(Conta);
  // if Assigned(Conta) then ... // False — seguro
end;

end.

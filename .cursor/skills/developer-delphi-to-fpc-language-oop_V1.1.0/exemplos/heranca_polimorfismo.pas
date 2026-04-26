unit heranca_polimorfismo;
{
  EXEMPLO: Heranca e polimorfismo em Delphi
  Compilavel: dcc32 / dcc64
  Demonstra:
    - virtual / override / abstract / final
    - inherited para chamar implementacao da base
    - Dynamic dispatch via variavel do tipo base
    - is / as para verificacao e cast de tipo
    - overload para multiplas assinaturas
    - sealed class (sealed)
}

interface

uses
  System.SysUtils, System.Math;

// ---------------------------------------------------------------------------
// Hierarquia de formas geometricas
// ---------------------------------------------------------------------------
type
  // Classe base abstrata (nao pode ser instanciada diretamente)
  TForma = class abstract
  private
    FNome: string;
    FCor : string;
  public
    constructor Create(const ANome, ACor: string);

    // Metodos abstratos: subclasses DEVEM implementar
    function Area:      Double; virtual; abstract;
    function Perimetro: Double; virtual; abstract;

    // Metodo virtual: subclasses PODEM sobrescrever
    function Descricao: string; virtual;

    property Nome: string read FNome;
    property Cor : string read FCor;
  end;

type
  // Subclasse concreta
  TCirculo = class(TForma)
  private
    FRaio: Double;
  public
    constructor Create(ARaio: Double; const ACor: string = 'Azul');
    function Area:      Double; override;
    function Perimetro: Double; override;
    function Descricao: string; override; // sobrescreve E chama inherited
    property Raio: Double read FRaio;
  end;

type
  TRetangulo = class(TForma)
  private
    FLargura, FAltura: Double;
  public
    constructor Create(ALargura, AAltura: Double; const ACor: string = 'Verde');
    function Area:      Double; override;
    function Perimetro: Double; override;

    // overload: mesmo nome, assinaturas diferentes
    function Contem(AX, AY: Double): Boolean; overload;
    function Contem(const AForma: TForma): Boolean; overload; // mesma assinatura com tipo diferente
  end;

type
  // Sealed: nao pode ser herdada
  TQuadrado = class sealed (TRetangulo)
  public
    constructor Create(ALado: Double; const ACor: string = 'Amarelo');
  end;

implementation

// ---------------------------------------------------------------------------
// TForma
// ---------------------------------------------------------------------------

constructor TForma.Create(const ANome, ACor: string);
begin
  inherited Create;
  FNome := ANome;
  FCor  := ACor;
end;

function TForma.Descricao: string;
begin
  Result := Format('%s (%s): area=%.2f, perimetro=%.2f',
    [FNome, FCor, Area, Perimetro]);
end;

// ---------------------------------------------------------------------------
// TCirculo
// ---------------------------------------------------------------------------

constructor TCirculo.Create(ARaio: Double; const ACor: string);
begin
  inherited Create('Circulo', ACor); // chama constructor da base
  FRaio := ARaio;
end;

function TCirculo.Area: Double;
begin
  Result := Pi * FRaio * FRaio;
end;

function TCirculo.Perimetro: Double;
begin
  Result := 2 * Pi * FRaio;
end;

function TCirculo.Descricao: string;
begin
  // inherited chama TForma.Descricao (que ja chama Area/Perimetro via VMT)
  Result := inherited Descricao + Format(' | raio=%.2f', [FRaio]);
end;

// ---------------------------------------------------------------------------
// TRetangulo
// ---------------------------------------------------------------------------

constructor TRetangulo.Create(ALargura, AAltura: Double; const ACor: string);
begin
  inherited Create('Retangulo', ACor);
  FLargura := ALargura;
  FAltura  := AAltura;
end;

function TRetangulo.Area: Double;
begin
  Result := FLargura * FAltura;
end;

function TRetangulo.Perimetro: Double;
begin
  Result := 2 * (FLargura + FAltura);
end;

function TRetangulo.Contem(AX, AY: Double): Boolean;
begin
  Result := (AX >= 0) and (AX <= FLargura) and
            (AY >= 0) and (AY <= FAltura);
end;

function TRetangulo.Contem(const AForma: TForma): Boolean;
begin
  // Verificacao de tipo em tempo de execucao
  if AForma is TCirculo then
  begin
    var C := AForma as TCirculo;
    Result := (C.Raio <= FLargura / 2) and (C.Raio <= FAltura / 2);
  end
  else
    Result := AForma.Area <= Area;
end;

// ---------------------------------------------------------------------------
// TQuadrado (sealed)
// ---------------------------------------------------------------------------

constructor TQuadrado.Create(ALado: Double; const ACor: string);
begin
  inherited Create(ALado, ALado, ACor); // lado = largura = altura
  // Trocar nome (acesso ao campo privado via inherited nao e possivel
  // sem propriedade publica — aqui apenas ilustrativo)
end;

// ---------------------------------------------------------------------------
// Demonstracao de polimorfismo
// ---------------------------------------------------------------------------
procedure DemonstrarPolimorfismo;
var
  Formas: array of TForma;
  F: TForma;
begin
  SetLength(Formas, 3);
  Formas[0] := TCirculo.Create(5.0);
  Formas[1] := TRetangulo.Create(4.0, 6.0);
  Formas[2] := TQuadrado.Create(3.0);

  try
    // Polimorfismo: chamar Descricao em cada TForma sem saber o tipo real
    for F in Formas do
      Writeln(F.Descricao); // VMT direciona para a implementacao correta

    // Verificacao de tipo em runtime
    for F in Formas do
    begin
      if F is TCirculo then
        Writeln('Eh um circulo! Raio = ', TCirculo(F).Raio:4:2)
      else if F is TQuadrado then
        Writeln('Eh um quadrado (tambem e TRetangulo)!')
      else if F is TRetangulo then
        Writeln('Eh um retangulo puro.');
    end;

    // Cast seguro com as (lanca EInvalidCast se tipo errado)
    for F in Formas do
    begin
      if F is TRetangulo then
      begin
        var R := F as TRetangulo; // cast verificado
        Writeln('Retangulo: ', R.Contem(1.0, 1.0));
      end;
    end;

    // Cast inseguro (sem verificacao): usar so quando CERTEZA do tipo
    var C := TCirculo(Formas[0]); // equivale a cast C sem verificacao
    Writeln('Raio (cast direto): ', C.Raio:4:2);

  finally
    for F in Formas do F.Free;
  end;
end;

end.

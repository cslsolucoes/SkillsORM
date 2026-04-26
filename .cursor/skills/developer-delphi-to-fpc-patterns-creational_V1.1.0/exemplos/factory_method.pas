unit factory_method;
{
  Factory Method em Delphi — registro dinâmico de tipos
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Interface do produto
// ---------------------------------------------------------------------------
type
  IAnimal = interface
  ['{70000007-0000-0000-0000-000000000007}']
    function FazerSom: string;
    function GetNome: string;
    property Nome: string read GetNome;
  end;

// ---------------------------------------------------------------------------
// Produtos concretos
// ---------------------------------------------------------------------------
type
  TCao = class(TInterfacedObject, IAnimal)
  public
    function FazerSom: string;
    function GetNome: string;
  end;

  TGato = class(TInterfacedObject, IAnimal)
  public
    function FazerSom: string;
    function GetNome: string;
  end;

  TPapagaio = class(TInterfacedObject, IAnimal)
  private
    FPalavra: string;
  public
    constructor Create(const APalavra: string = 'Olá!');
    function FazerSom: string;
    function GetNome: string;
  end;

// ---------------------------------------------------------------------------
// Factory simples — switch/if
// ---------------------------------------------------------------------------
type
  TAnimalFactory = class
  public
    class function New(const ATipo: string): IAnimal;
  end;

// ---------------------------------------------------------------------------
// Factory com registro dinâmico — extensível sem modificar factory
// ---------------------------------------------------------------------------
type
  TAnimalCreator = TFunc<IAnimal>;

  TAnimalRegistry = class
  private
    class var FRegistry: TDictionary<string, TAnimalCreator>;
    class constructor Create;
    class destructor Destroy;
  public
    class procedure Registrar(const ATipo: string; ACreator: TAnimalCreator);
    class function  Criar(const ATipo: string): IAnimal;
    class function  TiposDisponiveis: TArray<string>;
  end;

// ---------------------------------------------------------------------------
// Factory Method via herança (GoF clássico)
// ---------------------------------------------------------------------------
type
  TAnimalCreatorBase = class abstract
  public
    // Factory Method: subclasse decide qual produto criar
    function CriarAnimal: IAnimal; virtual; abstract;

    // Template Method que usa o factory method
    procedure ApresentarAnimal;
  end;

  TCaoCreator = class(TAnimalCreatorBase)
  public
    function CriarAnimal: IAnimal; override;
  end;

  TGatoCreator = class(TAnimalCreatorBase)
  public
    function CriarAnimal: IAnimal; override;
  end;

implementation

// ---------------------------------------------------------------------------
// Produtos
// ---------------------------------------------------------------------------

function TCao.FazerSom: string;    begin Result := 'Au Au!'; end;
function TCao.GetNome: string;     begin Result := 'Cão'; end;

function TGato.FazerSom: string;   begin Result := 'Miau!'; end;
function TGato.GetNome: string;    begin Result := 'Gato'; end;

constructor TPapagaio.Create(const APalavra: string);
begin inherited Create; FPalavra := APalavra; end;

function TPapagaio.FazerSom: string; begin Result := FPalavra; end;
function TPapagaio.GetNome: string;  begin Result := 'Papagaio'; end;

// ---------------------------------------------------------------------------
// TAnimalFactory — simples
// ---------------------------------------------------------------------------

class function TAnimalFactory.New(const ATipo: string): IAnimal;
begin
  case ATipo.ToLower of
    'cao', 'dog':     Result := TCao.Create;
    'gato', 'cat':    Result := TGato.Create;
    'papagaio','bird':Result := TPapagaio.Create;
  else
    raise EArgumentException.CreateFmt('Animal "%s" desconhecido', [ATipo]);
  end;
end;

// ---------------------------------------------------------------------------
// TAnimalRegistry — extensível
// ---------------------------------------------------------------------------

class constructor TAnimalRegistry.Create;
begin
  FRegistry := TDictionary<string, TAnimalCreator>.Create;
  // Registrar tipos padrão
  Registrar('cao',      function: IAnimal begin Result := TCao.Create; end);
  Registrar('gato',     function: IAnimal begin Result := TGato.Create; end);
  Registrar('papagaio', function: IAnimal begin Result := TPapagaio.Create; end);
end;

class destructor TAnimalRegistry.Destroy;
begin
  FRegistry.Free;
end;

class procedure TAnimalRegistry.Registrar(const ATipo: string; ACreator: TAnimalCreator);
begin
  FRegistry.AddOrSetValue(ATipo.ToLower, ACreator);
end;

class function TAnimalRegistry.Criar(const ATipo: string): IAnimal;
var Creator: TAnimalCreator;
begin
  if not FRegistry.TryGetValue(ATipo.ToLower, Creator) then
    raise EArgumentException.CreateFmt('Tipo "%s" não registrado', [ATipo]);
  Result := Creator();
end;

class function TAnimalRegistry.TiposDisponiveis: TArray<string>;
begin
  Result := FRegistry.Keys.ToArray;
end;

// ---------------------------------------------------------------------------
// GoF Factory Method via herança
// ---------------------------------------------------------------------------

procedure TAnimalCreatorBase.ApresentarAnimal;
var A: IAnimal;
begin
  A := CriarAnimal;  // chama o factory method da subclasse
  Writeln(Format('%s diz: %s', [A.Nome, A.FazerSom]));
end;

function TCaoCreator.CriarAnimal: IAnimal;
begin Result := TCao.Create; end;

function TGatoCreator.CriarAnimal: IAnimal;
begin Result := TGato.Create; end;

// ---------------------------------------------------------------------------
// USO:
//   // Factory simples
//   var A := TAnimalFactory.New('cao');
//   Writeln(A.FazerSom);   // Au Au!
//
//   // Registry (extensível — adicionar novos tipos sem modificar factory)
//   TAnimalRegistry.Registrar('lobo',
//     function: IAnimal
//     begin
//       Result := TCao.Create;  // placeholder; seria TLobo em prod
//     end);
//   var L := TAnimalRegistry.Criar('lobo');
//   Writeln(L.FazerSom);
//
//   for var T in TAnimalRegistry.TiposDisponiveis do Write(T,' ');
//
//   // GoF clássico
//   var Creator: TAnimalCreatorBase := TCaoCreator.Create;
//   Creator.ApresentarAnimal;   // Cão diz: Au Au!
//   Creator.Free;
// ---------------------------------------------------------------------------

end.

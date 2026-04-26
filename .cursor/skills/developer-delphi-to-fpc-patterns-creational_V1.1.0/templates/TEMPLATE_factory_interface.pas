unit TEMPLATE_factory_interface;
{
  TEMPLATE: Factory com interface + registro dinâmico de tipos
  ─────────────────────────────────────────────────────────────
  Substituir:
    IProduto       → interface do produto (ex.: IAnimal, IHandler)
    TBaseProduto   → classe base opcional
    TProduto_A/B   → implementações concretas
    TFactory       → nome da factory
    'tipo_a'/'b'   → chaves de registro (strings lowercase)
  ─────────────────────────────────────────────────────────────
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// 1. Interface do produto
// ---------------------------------------------------------------------------
type
  IProduto = interface
  ['{00000000-0000-0000-0000-000000000001}']  // gerar novo GUID
    function Execute(const AInput: string): string;
    function GetTipo: string;
    property Tipo: string read GetTipo;
  end;

// ---------------------------------------------------------------------------
// 2. Implementações concretas
// ---------------------------------------------------------------------------
type
  TProduto_A = class(TInterfacedObject, IProduto)
  public
    function Execute(const AInput: string): string;
    function GetTipo: string;
  end;

  TProduto_B = class(TInterfacedObject, IProduto)
  public
    function Execute(const AInput: string): string;
    function GetTipo: string;
  end;

// ---------------------------------------------------------------------------
// 3. Factory com registro dinâmico
// ---------------------------------------------------------------------------
type
  TProdutoCreator = TFunc<IProduto>;

  TFactory = class
  private
    class var FRegistry: TDictionary<string, TProdutoCreator>;
    class constructor Create;
    class destructor Destroy;
  public
    // Registrar novo tipo — sem modificar a factory
    class procedure Registrar(const ATipo: string; ACreator: TProdutoCreator);
    // Criar por chave
    class function Criar(const ATipo: string): IProduto;
    // Criar com guard — retorna nil se não encontrado
    class function TentarCriar(const ATipo: string; out AProduto: IProduto): Boolean;
    // Tipos disponíveis
    class function Tipos: TArray<string>;
  end;

// Atalho global
function NovoProduto(const ATipo: string): IProduto;

implementation

// ---------------------------------------------------------------------------
// TProduto_A
// ---------------------------------------------------------------------------

function TProduto_A.Execute(const AInput: string): string;
begin Result := 'A processou: ' + AInput; end;

function TProduto_A.GetTipo: string;
begin Result := 'tipo_a'; end;

// ---------------------------------------------------------------------------
// TProduto_B
// ---------------------------------------------------------------------------

function TProduto_B.Execute(const AInput: string): string;
begin Result := 'B transformou: ' + AInput; end;

function TProduto_B.GetTipo: string;
begin Result := 'tipo_b'; end;

// ---------------------------------------------------------------------------
// TFactory
// ---------------------------------------------------------------------------

class constructor TFactory.Create;
begin
  FRegistry := TDictionary<string, TProdutoCreator>.Create;
  // Registro padrão — adicionar tipos adicionais via Registrar()
  Registrar('tipo_a', function: IProduto begin Result := TProduto_A.Create; end);
  Registrar('tipo_b', function: IProduto begin Result := TProduto_B.Create; end);
end;

class destructor TFactory.Destroy;
begin FRegistry.Free; end;

class procedure TFactory.Registrar(const ATipo: string; ACreator: TProdutoCreator);
begin FRegistry.AddOrSetValue(ATipo.ToLower, ACreator); end;

class function TFactory.Criar(const ATipo: string): IProduto;
var Creator: TProdutoCreator;
begin
  if not FRegistry.TryGetValue(ATipo.ToLower, Creator) then
    raise EArgumentException.CreateFmt(
      'Tipo "%s" não registrado. Disponíveis: %s',
      [ATipo, string.Join(', ', Tipos)]);
  Result := Creator();
end;

class function TFactory.TentarCriar(const ATipo: string; out AProduto: IProduto): Boolean;
var Creator: TProdutoCreator;
begin
  Result := FRegistry.TryGetValue(ATipo.ToLower, Creator);
  if Result then AProduto := Creator()
  else AProduto := nil;
end;

class function TFactory.Tipos: TArray<string>;
begin Result := FRegistry.Keys.ToArray; end;

function NovoProduto(const ATipo: string): IProduto;
begin Result := TFactory.Criar(ATipo); end;

// ---------------------------------------------------------------------------
// COMO USAR ESTE TEMPLATE
//
// 1. Copie este arquivo, renomeie e substitua os placeholders.
// 2. Para adicionar tipo sem modificar a factory:
//
//    TFactory.Registrar('tipo_c',
//      function: IProduto begin Result := TProduto_C.Create; end);
//
// 3. Uso básico:
//    var P := NovoProduto('tipo_a');
//    Writeln(P.Execute('dados'));
//
// 4. Guard clause (sem raise):
//    var P: IProduto;
//    if TFactory.TentarCriar('desconhecido', P) then
//      Writeln(P.Execute('x'))
//    else
//      Writeln('tipo não encontrado');
// ---------------------------------------------------------------------------

end.

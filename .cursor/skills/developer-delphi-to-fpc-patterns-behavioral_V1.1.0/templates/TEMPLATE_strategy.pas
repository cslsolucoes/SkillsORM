unit TEMPLATE_strategy;
{
  TEMPLATE: Strategy com registro dinâmico + context
  ───────────────────────────────────────────────────
  Substituir:
    IEstrategia     → interface da estratégia
    TContexto       → classe que usa a estratégia
    TEstrat_A/B     → estratégias concretas
    Executar()      → método da estratégia
  ───────────────────────────────────────────────────
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// 1. Interface da estratégia
// ---------------------------------------------------------------------------
type
  IEstrategia = interface
  ['{00000000-0000-0000-0000-000000000030}']  // gerar novo GUID
    function Executar(const AInput: string): string;
    function GetNome: string;
    property Nome: string read GetNome;
  end;

// ---------------------------------------------------------------------------
// 2. Estratégias concretas
// ---------------------------------------------------------------------------
type
  TEstrat_A = class(TInterfacedObject, IEstrategia)
  public
    function Executar(const AInput: string): string;
    function GetNome: string;
  end;

  TEstrat_B = class(TInterfacedObject, IEstrategia)
  public
    function Executar(const AInput: string): string;
    function GetNome: string;
  end;

  // Estratégia inline com anonymous method
  TLambdaEstrategia = class(TInterfacedObject, IEstrategia)
  private
    FNome: string;
    FExec: reference to function(const AInput: string): string;
  public
    constructor Create(const ANome: string;
      AExec: reference to function(const AInput: string): string);
    function Executar(const AInput: string): string;
    function GetNome: string;
  end;

// ---------------------------------------------------------------------------
// 3. Contexto — usa a estratégia sem saber qual é
// ---------------------------------------------------------------------------
type
  TContexto = class
  private
    FEstrategia: IEstrategia;
  public
    constructor Create(AEstrategia: IEstrategia);
    procedure SetEstrategia(AEstrategia: IEstrategia);
    function  Executar(const AInput: string): string;
    function  EstrategiaAtual: string;
    property  Estrategia: IEstrategia read FEstrategia write SetEstrategia;
  end;

// ---------------------------------------------------------------------------
// 4. Registry dinâmico — extensível sem modificar o contexto
// ---------------------------------------------------------------------------
type
  TEstrategiaRegistry = class
  private
    class var FReg: TDictionary<string, IEstrategia>;
    class constructor Create;
    class destructor Destroy;
  public
    class procedure Registrar(const ANome: string; AEst: IEstrategia);
    class function  Obter(const ANome: string): IEstrategia;
    class function  TentarObter(const ANome: string; out AEst: IEstrategia): Boolean;
    class function  Nomes: TArray<string>;
  end;

implementation

// ---------------------------------------------------------------------------
// TEstrat_A
// ---------------------------------------------------------------------------

function TEstrat_A.Executar(const AInput: string): string;
begin Result := 'A(' + AInput + ')'; end;

function TEstrat_A.GetNome: string;
begin Result := 'estrategia_a'; end;

// ---------------------------------------------------------------------------
// TEstrat_B
// ---------------------------------------------------------------------------

function TEstrat_B.Executar(const AInput: string): string;
begin Result := 'B[' + AInput.ToUpper + ']'; end;

function TEstrat_B.GetNome: string;
begin Result := 'estrategia_b'; end;

// ---------------------------------------------------------------------------
// TLambdaEstrategia
// ---------------------------------------------------------------------------

constructor TLambdaEstrategia.Create(const ANome: string;
  AExec: reference to function(const AInput: string): string);
begin inherited Create; FNome := ANome; FExec := AExec; end;

function TLambdaEstrategia.Executar(const AInput: string): string;
begin Result := FExec(AInput); end;

function TLambdaEstrategia.GetNome: string;
begin Result := FNome; end;

// ---------------------------------------------------------------------------
// TContexto
// ---------------------------------------------------------------------------

constructor TContexto.Create(AEstrategia: IEstrategia);
begin inherited Create; FEstrategia := AEstrategia; end;

procedure TContexto.SetEstrategia(AEstrategia: IEstrategia);
begin FEstrategia := AEstrategia; end;

function TContexto.Executar(const AInput: string): string;
begin Result := FEstrategia.Executar(AInput); end;

function TContexto.EstrategiaAtual: string;
begin Result := FEstrategia.Nome; end;

// ---------------------------------------------------------------------------
// TEstrategiaRegistry
// ---------------------------------------------------------------------------

class constructor TEstrategiaRegistry.Create;
begin
  FReg := TDictionary<string, IEstrategia>.Create;
  // Registrar estratégias padrão
  Registrar('a', TEstrat_A.Create);
  Registrar('b', TEstrat_B.Create);
end;

class destructor TEstrategiaRegistry.Destroy;
begin FReg.Free; end;

class procedure TEstrategiaRegistry.Registrar(const ANome: string; AEst: IEstrategia);
begin FReg.AddOrSetValue(ANome.ToLower, AEst); end;

class function TEstrategiaRegistry.Obter(const ANome: string): IEstrategia;
begin
  if not FReg.TryGetValue(ANome.ToLower, Result) then
    raise EArgumentException.CreateFmt(
      'Estratégia "%s" não registrada. Disponíveis: %s',
      [ANome, string.Join(', ', Nomes)]);
end;

class function TEstrategiaRegistry.TentarObter(const ANome: string;
  out AEst: IEstrategia): Boolean;
begin Result := FReg.TryGetValue(ANome.ToLower, AEst); end;

class function TEstrategiaRegistry.Nomes: TArray<string>;
begin Result := FReg.Keys.ToArray; end;

// ---------------------------------------------------------------------------
// COMO USAR ESTE TEMPLATE
//
// 1. Renomeie IEstrategia e TContexto conforme o domínio.
// 2. Adicione estratégias sem alterar o contexto.
//
// Uso básico:
//   var Ctx := TContexto.Create(TEstrat_A.Create);
//   Writeln(Ctx.Executar('dados'));   // A(dados)
//   Ctx.SetEstrategia(TEstrat_B.Create);
//   Writeln(Ctx.Executar('dados'));   // B[DADOS]
//
// Registry (estratégia vinda de config):
//   var E := TEstrategiaRegistry.Obter('b');
//   Ctx.SetEstrategia(E);
//
// Estratégia lambda (inline):
//   TEstrategiaRegistry.Registrar('reverse',
//     TLambdaEstrategia.Create('reverse',
//       function(const S: string): string
//       var I: Integer;
//       begin
//         Result := '';
//         for I := Length(S) downto 1 do Result := Result + S[I];
//       end));
//   Writeln(TEstrategiaRegistry.Obter('reverse').Executar('abc'));  // cba
// ---------------------------------------------------------------------------

end.

unit constraints;
{
  Generics — constraints de tipo em Delphi
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Constraint: class — T deve ser tipo referência (descende de TObject)
// ---------------------------------------------------------------------------
type
  TCache<T: class> = class
  private
    FItems: TDictionary<string, T>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Adicionar(const AChave: string; AItem: T);
    function  Obter(const AChave: string): T;
    function  Contem(const AChave: string): Boolean;
  end;

// ---------------------------------------------------------------------------
// Constraint: class + constructor — pode criar instâncias com T.Create
// ---------------------------------------------------------------------------
type
  TFabrica<T: class, constructor> = class
  public
    function CriarNova: T;
    function CriarArray(AQuantidade: Integer): TArray<T>;
  end;

// ---------------------------------------------------------------------------
// Constraint: interface — T deve implementar a interface
// ---------------------------------------------------------------------------
type
  IDisposable = interface
  ['{11111111-2222-3333-4444-555566667777}']
    procedure Dispose;
  end;

  TRecurso<T: IDisposable> = class
  private
    FRecurso: T;
  public
    constructor Create(ARecurso: T);
    destructor Destroy; override;
    property Recurso: T read FRecurso;
  end;

// ---------------------------------------------------------------------------
// Constraint: base class — T deve ser TAnimal ou descendente
// ---------------------------------------------------------------------------
type
  TAnimal = class
  public
    procedure FazerSom; virtual; abstract;
  end;

  TCaes = TAnimal;
  TGato = class(TAnimal)
    procedure FazerSom; override;
  end;
  TCao = class(TAnimal)
    procedure FazerSom; override;
  end;

  TZoologico<T: TAnimal, constructor> = class
  private
    FAnimais: TObjectList<TAnimal>;
  public
    constructor Create;
    destructor Destroy; override;
    function  AdicionarAnimal: T;
    procedure FazerBarulho;
  end;

// ---------------------------------------------------------------------------
// Constraint combinado: class + constructor + interface
// ---------------------------------------------------------------------------
type
  IValidavel = interface
  ['{AAAABBBB-CCCC-DDDD-EEEE-FFFF00001111}']
    function EhValido: Boolean;
  end;

  TValidadorFactory<T: class, constructor, IValidavel> = class
  public
    function CriarEValidar: T;  // cria e verifica EhValido antes de retornar
  end;

implementation

// ---------------------------------------------------------------------------
// TCache<T>
// ---------------------------------------------------------------------------

constructor TCache<T>.Create;
begin
  inherited Create;
  FItems := TDictionary<string, T>.Create;
end;

destructor TCache<T>.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure TCache<T>.Adicionar(const AChave: string; AItem: T);
begin
  FItems.AddOrSetValue(AChave, AItem);
end;

function TCache<T>.Obter(const AChave: string): T;
begin
  if not FItems.TryGetValue(AChave, Result) then
    Result := nil;
end;

function TCache<T>.Contem(const AChave: string): Boolean;
begin
  Result := FItems.ContainsKey(AChave);
end;

// ---------------------------------------------------------------------------
// TFabrica<T>
// ---------------------------------------------------------------------------

function TFabrica<T>.CriarNova: T;
begin
  Result := T.Create;
end;

function TFabrica<T>.CriarArray(AQuantidade: Integer): TArray<T>;
var I: Integer;
begin
  SetLength(Result, AQuantidade);
  for I := 0 to AQuantidade - 1 do
    Result[I] := T.Create;
end;

// ---------------------------------------------------------------------------
// TRecurso<T>
// ---------------------------------------------------------------------------

constructor TRecurso<T>.Create(ARecurso: T);
begin
  inherited Create;
  FRecurso := ARecurso;
end;

destructor TRecurso<T>.Destroy;
begin
  if FRecurso <> nil then
    FRecurso.Dispose;
  inherited;
end;

// ---------------------------------------------------------------------------
// TAnimal implementations
// ---------------------------------------------------------------------------

procedure TGato.FazerSom;
begin Writeln('Miau!'); end;

procedure TCao.FazerSom;
begin Writeln('Au Au!'); end;

// ---------------------------------------------------------------------------
// TZoologico<T>
// ---------------------------------------------------------------------------

constructor TZoologico<T>.Create;
begin
  inherited Create;
  FAnimais := TObjectList<TAnimal>.Create(True); // owns objects
end;

destructor TZoologico<T>.Destroy;
begin
  FAnimais.Free;
  inherited;
end;

function TZoologico<T>.AdicionarAnimal: T;
var A: T;
begin
  A := T.Create;
  FAnimais.Add(A);
  Result := A;
end;

procedure TZoologico<T>.FazerBarulho;
var A: TAnimal;
begin
  for A in FAnimais do
    A.FazerSom;
end;

// ---------------------------------------------------------------------------
// TValidadorFactory<T>
// ---------------------------------------------------------------------------

function TValidadorFactory<T>.CriarEValidar: T;
var Obj: T;
begin
  Obj := T.Create;
  if not (Obj as IValidavel).EhValido then
  begin
    Obj.Free;
    raise EInvalidOpException.Create('Objeto criado inválido');
  end;
  Result := Obj;
end;

// ---------------------------------------------------------------------------
// USO:
//
//   // class constraint
//   var ZooGatos := TZoologico<TGato>.Create;
//   ZooGatos.AdicionarAnimal;
//   ZooGatos.AdicionarAnimal;
//   ZooGatos.FazerBarulho;  // Miau! Miau!
//   ZooGatos.Free;
//
//   // class + constructor
//   var Fab := TFabrica<TStringList>.Create;
//   var Lista := Fab.CriarNova;  // TStringList.Create
//   Lista.Free; Fab.Free;
//
//   // constraints combinados resumo:
//   // <T: class>                     → só tipos referência
//   // <T: record>                    → só tipos valor
//   // <T: constructor>               → T.Create disponível
//   // <T: IInterface>                → T suporta QueryInterface
//   // <T: TBase>                     → T é TBase ou descendente
//   // <T: class, constructor>        → combina class + factory
//   // <T: class, constructor, IFoo>  → combina os três
// ---------------------------------------------------------------------------

end.

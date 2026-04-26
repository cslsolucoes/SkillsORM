unit generic_factory;
{
  Generics — Factory genérica com constraints
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Interface base para objetos criáveis pela factory
// ---------------------------------------------------------------------------
type
  IInitializable = interface
  ['{10000001-0000-0000-0000-000000000001}']
    procedure Initialize(const AParams: TArray<string>);
  end;

// ---------------------------------------------------------------------------
// Factory simples: cria T sem parâmetros (constraint: class, constructor)
// ---------------------------------------------------------------------------
type
  TSimpleFactory<T: class, constructor> = class
  public
    class function Criar: T;
    class function CriarN(AQuantidade: Integer): TObjectList<T>;
  end;

// ---------------------------------------------------------------------------
// Factory com registro de tipos por nome (Registry pattern)
// ---------------------------------------------------------------------------
type
  TRegistroFactory = class
  private
    class var FRegistro: TDictionary<string, TClass>;
    class constructor Create;
    class destructor Destroy;
  public
    class procedure Registrar(const ANome: string; AClasse: TClass);
    class function  Criar(const ANome: string): TObject;
    class function  Criar<T: class>(const ANome: string): T;
    class function  Nomes: TArray<string>;
  end;

// ---------------------------------------------------------------------------
// Abstract Factory genérica
// ---------------------------------------------------------------------------
type
  IConexao = interface
  ['{20000002-0000-0000-0000-000000000002}']
    procedure Conectar(const ADSN: string);
    procedure Desconectar;
    function  EstaConectado: Boolean;
  end;

  IConexaoFactory<T: IConexao> = interface
  ['{30000003-0000-0000-0000-000000000003}']
    function CriarConexao: T;
  end;

  // Implementação de exemplo
  TConexaoMock = class(TInterfacedObject, IConexao)
  private
    FConectado: Boolean;
  public
    procedure Conectar(const ADSN: string);
    procedure Desconectar;
    function  EstaConectado: Boolean;
  end;

  TConexaoMockFactory = class(TInterfacedObject, IConexaoFactory<IConexao>)
  public
    function CriarConexao: IConexao;
  end;

implementation

// ---------------------------------------------------------------------------
// TSimpleFactory<T>
// ---------------------------------------------------------------------------

class function TSimpleFactory<T>.Criar: T;
begin
  Result := T.Create;
end;

class function TSimpleFactory<T>.CriarN(AQuantidade: Integer): TObjectList<T>;
var
  Lista: TObjectList<T>;
  I    : Integer;
begin
  Lista := TObjectList<T>.Create(True);
  for I := 1 to AQuantidade do
    Lista.Add(T.Create);
  Result := Lista;
end;

// ---------------------------------------------------------------------------
// TRegistroFactory
// ---------------------------------------------------------------------------

class constructor TRegistroFactory.Create;
begin
  FRegistro := TDictionary<string, TClass>.Create;
end;

class destructor TRegistroFactory.Destroy;
begin
  FRegistro.Free;
end;

class procedure TRegistroFactory.Registrar(const ANome: string; AClasse: TClass);
begin
  FRegistro.AddOrSetValue(ANome.ToLower, AClasse);
end;

class function TRegistroFactory.Criar(const ANome: string): TObject;
var
  Classe: TClass;
begin
  if not FRegistro.TryGetValue(ANome.ToLower, Classe) then
    raise EArgumentException.CreateFmt('Tipo "%s" não registrado', [ANome]);
  Result := Classe.Create;
end;

class function TRegistroFactory.Criar<T>(const ANome: string): T;
var Obj: TObject;
begin
  Obj := Criar(ANome);
  if not (Obj is T) then
  begin
    Obj.Free;
    raise EInvalidCastException.CreateFmt('"%s" não é %s', [ANome, T.ClassName]);
  end;
  Result := Obj as T;
end;

class function TRegistroFactory.Nomes: TArray<string>;
begin
  Result := FRegistro.Keys.ToArray;
end;

// ---------------------------------------------------------------------------
// TConexaoMock
// ---------------------------------------------------------------------------

procedure TConexaoMock.Conectar(const ADSN: string);
begin
  Writeln('Mock conectando a: ', ADSN);
  FConectado := True;
end;

procedure TConexaoMock.Desconectar;
begin
  FConectado := False;
end;

function TConexaoMock.EstaConectado: Boolean;
begin Result := FConectado; end;

// ---------------------------------------------------------------------------
// TConexaoMockFactory
// ---------------------------------------------------------------------------

function TConexaoMockFactory.CriarConexao: IConexao;
begin
  Result := TConexaoMock.Create;
end;

// ---------------------------------------------------------------------------
// USO:
//
//   // Factory simples
//   var SL := TSimpleFactory<TStringList>.Criar;
//   SL.Add('item'); SL.Free;
//
//   var Tres := TSimpleFactory<TStringList>.CriarN(3);
//   Tres.Free; // libera os 3 TStringList
//
//   // Registry factory
//   TRegistroFactory.Registrar('stringlist', TStringList);
//   TRegistroFactory.Registrar('lista',      TStringList);
//   var SL2 := TRegistroFactory.Criar<TStringList>('stringlist');
//   SL2.Free;
//
//   // Abstract factory via interface
//   var Fab: IConexaoFactory<IConexao> := TConexaoMockFactory.Create;
//   var Conn := Fab.CriarConexao;
//   Conn.Conectar('DSN=teste;');
//   Writeln(Conn.EstaConectado);  // True
// ---------------------------------------------------------------------------

end.

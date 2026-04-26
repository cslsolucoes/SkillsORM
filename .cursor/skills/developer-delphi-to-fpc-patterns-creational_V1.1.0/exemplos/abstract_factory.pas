unit abstract_factory;
{
  Abstract Factory em Delphi — IDBFactory por engine (SQLite / PostgreSQL)
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Produtos abstratos — interfaces independentes do engine
// ---------------------------------------------------------------------------
type
  IDBConnection = interface
  ['{AB000001-0000-0000-0000-000000000001}']
    procedure Conectar(const AConnStr: string);
    procedure Desconectar;
    function  Conectado: Boolean;
    function  GetEngine: string;
    property Engine: string read GetEngine;
  end;

  IDBCommand = interface
  ['{AB000002-0000-0000-0000-000000000002}']
    procedure SetSQL(const ASQL: string);
    procedure AdicionarParam(const ANome: string; AValor: Variant);
    function  Executar: Integer;   // rows affected
    function  GetEngine: string;
    property Engine: string read GetEngine;
  end;

  IDBQuery = interface
  ['{AB000003-0000-0000-0000-000000000003}']
    procedure Abrir(const ASQL: string);
    procedure Fechar;
    function  EOF: Boolean;
    procedure Next;
    function  FieldAsString(const ANome: string): string;
    function  FieldAsInteger(const ANome: string): Integer;
    function  GetEngine: string;
    property Engine: string read GetEngine;
  end;

// ---------------------------------------------------------------------------
// Abstract Factory — interface da fábrica
// ---------------------------------------------------------------------------
type
  IDBFactory = interface
  ['{AB000004-0000-0000-0000-000000000004}']
    function NewConnection: IDBConnection;
    function NewCommand(AConn: IDBConnection): IDBCommand;
    function NewQuery(AConn: IDBConnection): IDBQuery;
    function GetEngine: string;
    property Engine: string read GetEngine;
  end;

// ---------------------------------------------------------------------------
// Produtos concretos — SQLite
// ---------------------------------------------------------------------------
type
  TSQLiteConnection = class(TInterfacedObject, IDBConnection)
  private
    FConnStr: string;
    FConectado: Boolean;
  public
    procedure Conectar(const AConnStr: string);
    procedure Desconectar;
    function  Conectado: Boolean;
    function  GetEngine: string;
  end;

  TSQLiteCommand = class(TInterfacedObject, IDBCommand)
  private
    FConn: IDBConnection;
    FSQL: string;
    FParams: TDictionary<string, Variant>;
  public
    constructor Create(AConn: IDBConnection);
    destructor Destroy; override;
    procedure SetSQL(const ASQL: string);
    procedure AdicionarParam(const ANome: string; AValor: Variant);
    function  Executar: Integer;
    function  GetEngine: string;
  end;

  TSQLiteQuery = class(TInterfacedObject, IDBQuery)
  private
    FConn: IDBConnection;
    FRows: TList<TDictionary<string, string>>;
    FCursor: Integer;
  public
    constructor Create(AConn: IDBConnection);
    destructor Destroy; override;
    procedure Abrir(const ASQL: string);
    procedure Fechar;
    function  EOF: Boolean;
    procedure Next;
    function  FieldAsString(const ANome: string): string;
    function  FieldAsInteger(const ANome: string): Integer;
    function  GetEngine: string;
  end;

// ---------------------------------------------------------------------------
// Produtos concretos — PostgreSQL
// ---------------------------------------------------------------------------
type
  TPostgresConnection = class(TInterfacedObject, IDBConnection)
  private
    FConnStr: string;
    FConectado: Boolean;
  public
    procedure Conectar(const AConnStr: string);
    procedure Desconectar;
    function  Conectado: Boolean;
    function  GetEngine: string;
  end;

  TPostgresCommand = class(TInterfacedObject, IDBCommand)
  private
    FConn: IDBConnection;
    FSQL: string;
    FParams: TDictionary<string, Variant>;
  public
    constructor Create(AConn: IDBConnection);
    destructor Destroy; override;
    procedure SetSQL(const ASQL: string);
    procedure AdicionarParam(const ANome: string; AValor: Variant);
    function  Executar: Integer;
    function  GetEngine: string;
  end;

  TPostgresQuery = class(TInterfacedObject, IDBQuery)
  private
    FConn: IDBConnection;
    FCursor: Integer;
  public
    constructor Create(AConn: IDBConnection);
    procedure Abrir(const ASQL: string);
    procedure Fechar;
    function  EOF: Boolean;
    procedure Next;
    function  FieldAsString(const ANome: string): string;
    function  FieldAsInteger(const ANome: string): Integer;
    function  GetEngine: string;
  end;

// ---------------------------------------------------------------------------
// Fábricas concretas
// ---------------------------------------------------------------------------
type
  TSQLiteFactory = class(TInterfacedObject, IDBFactory)
  public
    function NewConnection: IDBConnection;
    function NewCommand(AConn: IDBConnection): IDBCommand;
    function NewQuery(AConn: IDBConnection): IDBQuery;
    function GetEngine: string;
  end;

  TPostgresFactory = class(TInterfacedObject, IDBFactory)
  public
    function NewConnection: IDBConnection;
    function NewCommand(AConn: IDBConnection): IDBCommand;
    function NewQuery(AConn: IDBConnection): IDBQuery;
    function GetEngine: string;
  end;

// Seletor de fábrica
function DBFactoryPara(const AEngine: string): IDBFactory;

implementation

// ---------------------------------------------------------------------------
// TSQLiteConnection
// ---------------------------------------------------------------------------

procedure TSQLiteConnection.Conectar(const AConnStr: string);
begin FConnStr := AConnStr; FConectado := True;
  Writeln('[SQLite] Conectado: ', AConnStr); end;

procedure TSQLiteConnection.Desconectar;
begin FConectado := False; Writeln('[SQLite] Desconectado'); end;

function TSQLiteConnection.Conectado: Boolean;
begin Result := FConectado; end;

function TSQLiteConnection.GetEngine: string;
begin Result := 'SQLite'; end;

// ---------------------------------------------------------------------------
// TSQLiteCommand
// ---------------------------------------------------------------------------

constructor TSQLiteCommand.Create(AConn: IDBConnection);
begin inherited Create; FConn := AConn;
  FParams := TDictionary<string, Variant>.Create; end;

destructor TSQLiteCommand.Destroy;
begin FParams.Free; inherited; end;

procedure TSQLiteCommand.SetSQL(const ASQL: string);
begin FSQL := ASQL; end;

procedure TSQLiteCommand.AdicionarParam(const ANome: string; AValor: Variant);
begin FParams.AddOrSetValue(ANome, AValor); end;

function TSQLiteCommand.Executar: Integer;
begin
  Writeln('[SQLite] Executar: ', FSQL);
  Result := 1; // simulado
end;

function TSQLiteCommand.GetEngine: string;
begin Result := 'SQLite'; end;

// ---------------------------------------------------------------------------
// TSQLiteQuery
// ---------------------------------------------------------------------------

constructor TSQLiteQuery.Create(AConn: IDBConnection);
begin inherited Create; FConn := AConn;
  FRows := TList<TDictionary<string, string>>.Create; FCursor := -1; end;

destructor TSQLiteQuery.Destroy;
var Row: TDictionary<string, string>;
begin
  for Row in FRows do Row.Free;
  FRows.Free; inherited;
end;

procedure TSQLiteQuery.Abrir(const ASQL: string);
var Row: TDictionary<string, string>;
begin
  Writeln('[SQLite] Query: ', ASQL);
  // Simular 2 linhas de resultado
  Row := TDictionary<string, string>.Create;
  Row.Add('id', '1'); Row.Add('nome', 'Alice'); FRows.Add(Row);
  Row := TDictionary<string, string>.Create;
  Row.Add('id', '2'); Row.Add('nome', 'Bob'); FRows.Add(Row);
  FCursor := 0;
end;

procedure TSQLiteQuery.Fechar;
begin FCursor := -1; end;

function TSQLiteQuery.EOF: Boolean;
begin Result := (FCursor < 0) or (FCursor >= FRows.Count); end;

procedure TSQLiteQuery.Next;
begin Inc(FCursor); end;

function TSQLiteQuery.FieldAsString(const ANome: string): string;
begin
  if EOF then raise EInvalidOperation.Create('EOF');
  if not FRows[FCursor].TryGetValue(ANome, Result) then Result := '';
end;

function TSQLiteQuery.FieldAsInteger(const ANome: string): Integer;
begin Result := StrToIntDef(FieldAsString(ANome), 0); end;

function TSQLiteQuery.GetEngine: string;
begin Result := 'SQLite'; end;

// ---------------------------------------------------------------------------
// TPostgresConnection
// ---------------------------------------------------------------------------

procedure TPostgresConnection.Conectar(const AConnStr: string);
begin FConnStr := AConnStr; FConectado := True;
  Writeln('[Postgres] Conectado: ', AConnStr); end;

procedure TPostgresConnection.Desconectar;
begin FConectado := False; Writeln('[Postgres] Desconectado'); end;

function TPostgresConnection.Conectado: Boolean;
begin Result := FConectado; end;

function TPostgresConnection.GetEngine: string;
begin Result := 'PostgreSQL'; end;

// ---------------------------------------------------------------------------
// TPostgresCommand
// ---------------------------------------------------------------------------

constructor TPostgresCommand.Create(AConn: IDBConnection);
begin inherited Create; FConn := AConn;
  FParams := TDictionary<string, Variant>.Create; end;

destructor TPostgresCommand.Destroy;
begin FParams.Free; inherited; end;

procedure TPostgresCommand.SetSQL(const ASQL: string);
begin FSQL := ASQL; end;

procedure TPostgresCommand.AdicionarParam(const ANome: string; AValor: Variant);
begin FParams.AddOrSetValue(ANome, AValor); end;

function TPostgresCommand.Executar: Integer;
begin
  Writeln('[Postgres] Executar: ', FSQL);
  Result := 1;
end;

function TPostgresCommand.GetEngine: string;
begin Result := 'PostgreSQL'; end;

// ---------------------------------------------------------------------------
// TPostgresQuery
// ---------------------------------------------------------------------------

constructor TPostgresQuery.Create(AConn: IDBConnection);
begin inherited Create; FConn := AConn; FCursor := 0; end;

procedure TPostgresQuery.Abrir(const ASQL: string);
begin Writeln('[Postgres] Query: ', ASQL); FCursor := 0; end;

procedure TPostgresQuery.Fechar;
begin FCursor := -1; end;

function TPostgresQuery.EOF: Boolean;
begin Result := FCursor >= 2; end;  // simula 2 linhas

procedure TPostgresQuery.Next;
begin Inc(FCursor); end;

function TPostgresQuery.FieldAsString(const ANome: string): string;
begin
  case FCursor of
    0: if ANome = 'id' then Result := '10' else Result := 'Carlos';
    1: if ANome = 'id' then Result := '11' else Result := 'Diana';
  else Result := '';
  end;
end;

function TPostgresQuery.FieldAsInteger(const ANome: string): Integer;
begin Result := StrToIntDef(FieldAsString(ANome), 0); end;

function TPostgresQuery.GetEngine: string;
begin Result := 'PostgreSQL'; end;

// ---------------------------------------------------------------------------
// Fábricas concretas
// ---------------------------------------------------------------------------

function TSQLiteFactory.NewConnection: IDBConnection;
begin Result := TSQLiteConnection.Create; end;

function TSQLiteFactory.NewCommand(AConn: IDBConnection): IDBCommand;
begin Result := TSQLiteCommand.Create(AConn); end;

function TSQLiteFactory.NewQuery(AConn: IDBConnection): IDBQuery;
begin Result := TSQLiteQuery.Create(AConn); end;

function TSQLiteFactory.GetEngine: string;
begin Result := 'SQLite'; end;

function TPostgresFactory.NewConnection: IDBConnection;
begin Result := TPostgresConnection.Create; end;

function TPostgresFactory.NewCommand(AConn: IDBConnection): IDBCommand;
begin Result := TPostgresCommand.Create(AConn); end;

function TPostgresFactory.NewQuery(AConn: IDBConnection): IDBQuery;
begin Result := TPostgresQuery.Create(AConn); end;

function TPostgresFactory.GetEngine: string;
begin Result := 'PostgreSQL'; end;

// ---------------------------------------------------------------------------
// Seletor
// ---------------------------------------------------------------------------

function DBFactoryPara(const AEngine: string): IDBFactory;
begin
  case AEngine.ToLower of
    'sqlite':     Result := TSQLiteFactory.Create;
    'postgres',
    'postgresql': Result := TPostgresFactory.Create;
  else
    raise EArgumentException.CreateFmt('Engine "%s" não suportado', [AEngine]);
  end;
end;

// ---------------------------------------------------------------------------
// USO:
//   // Mesmo código cliente — engine trocado pela factory
//   procedure UsarBancoDados(AFactory: IDBFactory);
//   var
//     Conn: IDBConnection;
//     Qry: IDBQuery;
//   begin
//     Conn := AFactory.NewConnection;
//     Conn.Conectar('server=localhost;db=app');
//     Qry := AFactory.NewQuery(Conn);
//     Qry.Abrir('SELECT id, nome FROM usuarios');
//     while not Qry.EOF do
//     begin
//       Writeln(Qry.FieldAsString('id'), ' - ', Qry.FieldAsString('nome'));
//       Qry.Next;
//     end;
//     Conn.Desconectar;
//   end;
//
//   UsarBancoDados(DBFactoryPara('sqlite'));     // SQLite
//   UsarBancoDados(DBFactoryPara('postgres'));   // PostgreSQL
//   // Zero alteração no código cliente
// ---------------------------------------------------------------------------

end.

unit adapter;
{
  Adapter Pattern em Delphi — adaptar ILegacyDB para IModernDB
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Interface moderna — o que o código novo espera
// ---------------------------------------------------------------------------
type
  IModernDB = interface
  ['{AD000001-0000-0000-0000-000000000001}']
    procedure Connect(const AConnStr: string);
    procedure Disconnect;
    function  Execute(const ASQL: string; const AParams: TArray<string>): Integer;
    function  QueryFirst(const ASQL: string): TDictionary<string, string>;
    function  QueryAll(const ASQL: string): TArray<TDictionary<string, string>>;
    function  IsConnected: Boolean;
  end;

// ---------------------------------------------------------------------------
// Interface legada — código que não podemos alterar
// ---------------------------------------------------------------------------
type
  ILegacyDB = interface
  ['{AD000002-0000-0000-0000-000000000002}']
    procedure Open(AConnStr: PChar);
    procedure Close;
    function  RunSQL(AQuery: PChar; AParamCount: Integer;
                     AParams: PPChar): LongInt;
    function  FetchRow(AColName: PChar): PChar;
    function  NextRow: Boolean;
    function  Connected: LongBool;
  end;

// ---------------------------------------------------------------------------
// Implementação da interface legada (simulada)
// ---------------------------------------------------------------------------
type
  TLegacyDBImpl = class(TInterfacedObject, ILegacyDB)
  private
    FConnected: Boolean;
    FRows: TList<TDictionary<string, string>>;
    FCursor: Integer;
    procedure PopularDados;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Open(AConnStr: PChar);
    procedure Close;
    function  RunSQL(AQuery: PChar; AParamCount: Integer; AParams: PPChar): LongInt;
    function  FetchRow(AColName: PChar): PChar;
    function  NextRow: Boolean;
    function  Connected: LongBool;
  end;

// ---------------------------------------------------------------------------
// Adapter — wraps ILegacyDB, expõe IModernDB
// ---------------------------------------------------------------------------
type
  TLegacyDBAdapter = class(TInterfacedObject, IModernDB)
  private
    FLegacy: ILegacyDB;
    FLastSQL: string;
    function ParamsToArray(const AParams: TArray<string>): TArray<PChar>;
  public
    constructor Create(ALegacy: ILegacyDB);
    // IModernDB
    procedure Connect(const AConnStr: string);
    procedure Disconnect;
    function  Execute(const ASQL: string; const AParams: TArray<string>): Integer;
    function  QueryFirst(const ASQL: string): TDictionary<string, string>;
    function  QueryAll(const ASQL: string): TArray<TDictionary<string, string>>;
    function  IsConnected: Boolean;
  end;

// ---------------------------------------------------------------------------
// Two-way adapter — adapta em ambas as direções (raro, mas útil)
// ---------------------------------------------------------------------------
type
  TBidirectionalAdapter = class(TInterfacedObject, IModernDB, ILegacyDB)
  private
    FModern: IModernDB;
  public
    constructor Create(AModern: IModernDB);
    // IModernDB — delega direto
    procedure Connect(const AConnStr: string);
    procedure Disconnect;
    function  Execute(const ASQL: string; const AParams: TArray<string>): Integer;
    function  QueryFirst(const ASQL: string): TDictionary<string, string>;
    function  QueryAll(const ASQL: string): TArray<TDictionary<string, string>>;
    function  IsConnected: Boolean;
    // ILegacyDB — converte para chamadas modernas
    procedure Open(AConnStr: PChar);
    procedure Close;
    function  RunSQL(AQuery: PChar; AParamCount: Integer; AParams: PPChar): LongInt;
    function  FetchRow(AColName: PChar): PChar;
    function  NextRow: Boolean;
    function  Connected: LongBool;
  end;

implementation

// ---------------------------------------------------------------------------
// TLegacyDBImpl
// ---------------------------------------------------------------------------

constructor TLegacyDBImpl.Create;
begin inherited Create; FRows := TList<TDictionary<string, string>>.Create; FCursor := -1; end;

destructor TLegacyDBImpl.Destroy;
var R: TDictionary<string, string>;
begin for R in FRows do R.Free; FRows.Free; inherited; end;

procedure TLegacyDBImpl.PopularDados;
var R: TDictionary<string, string>;
begin
  FRows.Clear;
  R := TDictionary<string, string>.Create; R.Add('id', '1'); R.Add('nome', 'Alice'); FRows.Add(R);
  R := TDictionary<string, string>.Create; R.Add('id', '2'); R.Add('nome', 'Bob');   FRows.Add(R);
  FCursor := 0;
end;

procedure TLegacyDBImpl.Open(AConnStr: PChar);
begin FConnected := True; Writeln('[Legacy] Open: ', AConnStr); end;

procedure TLegacyDBImpl.Close;
begin FConnected := False; end;

function TLegacyDBImpl.RunSQL(AQuery: PChar; AParamCount: Integer; AParams: PPChar): LongInt;
begin Writeln('[Legacy] SQL: ', AQuery); PopularDados; Result := FRows.Count; end;

function TLegacyDBImpl.FetchRow(AColName: PChar): PChar;
var V: string;
begin
  if (FCursor >= 0) and (FCursor < FRows.Count) then
  begin
    if FRows[FCursor].TryGetValue(string(AColName), V) then
      Result := PChar(V)
    else Result := '';
  end
  else Result := '';
end;

function TLegacyDBImpl.NextRow: Boolean;
begin Inc(FCursor); Result := FCursor < FRows.Count; end;

function TLegacyDBImpl.Connected: LongBool;
begin Result := FConnected; end;

// ---------------------------------------------------------------------------
// TLegacyDBAdapter
// ---------------------------------------------------------------------------

constructor TLegacyDBAdapter.Create(ALegacy: ILegacyDB);
begin inherited Create; FLegacy := ALegacy; end;

function TLegacyDBAdapter.ParamsToArray(const AParams: TArray<string>): TArray<PChar>;
var I: Integer;
begin
  SetLength(Result, Length(AParams));
  for I := 0 to High(AParams) do Result[I] := PChar(AParams[I]);
end;

procedure TLegacyDBAdapter.Connect(const AConnStr: string);
begin FLegacy.Open(PChar(AConnStr)); end;

procedure TLegacyDBAdapter.Disconnect;
begin FLegacy.Close; end;

function TLegacyDBAdapter.IsConnected: Boolean;
begin Result := FLegacy.Connected; end;

function TLegacyDBAdapter.Execute(const ASQL: string; const AParams: TArray<string>): Integer;
var PArr: TArray<PChar>;
begin
  PArr := ParamsToArray(AParams);
  if Length(PArr) > 0 then
    Result := FLegacy.RunSQL(PChar(ASQL), Length(PArr), @PArr[0])
  else
    Result := FLegacy.RunSQL(PChar(ASQL), 0, nil);
end;

function TLegacyDBAdapter.QueryFirst(const ASQL: string): TDictionary<string, string>;
begin
  Execute(ASQL, []);
  Result := TDictionary<string, string>.Create;
  Result.Add('id',   string(FLegacy.FetchRow('id')));
  Result.Add('nome', string(FLegacy.FetchRow('nome')));
end;

function TLegacyDBAdapter.QueryAll(const ASQL: string): TArray<TDictionary<string, string>>;
var Rows: TList<TDictionary<string, string>>;
    Row: TDictionary<string, string>;
begin
  Execute(ASQL, []);
  Rows := TList<TDictionary<string, string>>.Create;
  try
    Row := TDictionary<string, string>.Create;
    Row.Add('id',   string(FLegacy.FetchRow('id')));
    Row.Add('nome', string(FLegacy.FetchRow('nome')));
    Rows.Add(Row);
    while FLegacy.NextRow do
    begin
      Row := TDictionary<string, string>.Create;
      Row.Add('id',   string(FLegacy.FetchRow('id')));
      Row.Add('nome', string(FLegacy.FetchRow('nome')));
      Rows.Add(Row);
    end;
    Result := Rows.ToArray;
  finally
    Rows.Free;
  end;
end;

// ---------------------------------------------------------------------------
// TBidirectionalAdapter
// ---------------------------------------------------------------------------

constructor TBidirectionalAdapter.Create(AModern: IModernDB);
begin inherited Create; FModern := AModern; end;

procedure TBidirectionalAdapter.Connect(const AConnStr: string);    begin FModern.Connect(AConnStr); end;
procedure TBidirectionalAdapter.Disconnect;                          begin FModern.Disconnect; end;
function  TBidirectionalAdapter.IsConnected: Boolean;               begin Result := FModern.IsConnected; end;
function  TBidirectionalAdapter.Execute(const ASQL: string; const AParams: TArray<string>): Integer;
begin Result := FModern.Execute(ASQL, AParams); end;
function  TBidirectionalAdapter.QueryFirst(const ASQL: string): TDictionary<string, string>;
begin Result := FModern.QueryFirst(ASQL); end;
function  TBidirectionalAdapter.QueryAll(const ASQL: string): TArray<TDictionary<string, string>>;
begin Result := FModern.QueryAll(ASQL); end;

procedure TBidirectionalAdapter.Open(AConnStr: PChar);              begin FModern.Connect(string(AConnStr)); end;
procedure TBidirectionalAdapter.Close;                               begin FModern.Disconnect; end;
function  TBidirectionalAdapter.RunSQL(AQuery: PChar; AParamCount: Integer; AParams: PPChar): LongInt;
begin Result := FModern.Execute(string(AQuery), []); end;
function  TBidirectionalAdapter.FetchRow(AColName: PChar): PChar;   begin Result := nil; end;
function  TBidirectionalAdapter.NextRow: Boolean;                    begin Result := False; end;
function  TBidirectionalAdapter.Connected: LongBool;                 begin Result := FModern.IsConnected; end;

// ---------------------------------------------------------------------------
// USO:
//   // Código legado já existente
//   var LegacyImpl := TLegacyDBImpl.Create;
//
//   // Adaptador — código moderno usa IModernDB sem saber do legado
//   var DB: IModernDB := TLegacyDBAdapter.Create(LegacyImpl);
//   DB.Connect('server=old-host;db=legacy');
//   var Rows := DB.QueryAll('SELECT * FROM clientes');
//   for var R in Rows do
//     Writeln(R['id'], ' - ', R['nome']);
//   DB.Disconnect;
// ---------------------------------------------------------------------------

end.

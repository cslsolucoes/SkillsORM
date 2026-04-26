unit builder_pattern;
{
  Builder Pattern em Delphi — QueryBuilder fluente com method chaining
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Produto — SQL Query configurada
// ---------------------------------------------------------------------------
type
  TQueryConfig = record
    Tabela:    string;
    Campos:    TArray<string>;
    Condicoes: TArray<string>;
    OrdemPor:  TArray<string>;
    Limite:    Integer;
    Offset:    Integer;
    Joins:     TArray<string>;
    function ToSQL: string;
  end;

// ---------------------------------------------------------------------------
// Builder fluente
// ---------------------------------------------------------------------------
type
  TQueryBuilder = class
  private
    FTabela:    string;
    FCampos:    TStringList;
    FCondicoes: TStringList;
    FOrdemPor:  TStringList;
    FJoins:     TStringList;
    FLimite:    Integer;
    FOffset:    Integer;
  public
    constructor Create;
    destructor Destroy; override;

    // Configuração — cada método retorna Self para encadeamento
    function From(const ATabela: string): TQueryBuilder;
    function Select(const ACampos: array of string): TQueryBuilder;
    function Where(const ACondicao: string): TQueryBuilder;
    function AndWhere(const ACondicao: string): TQueryBuilder;
    function OrWhere(const ACondicao: string): TQueryBuilder;
    function OrderBy(const ACampo: string; ADesc: Boolean = False): TQueryBuilder;
    function Limit(AQtd: Integer): TQueryBuilder;
    function Skip(AQtd: Integer): TQueryBuilder;
    function Join(const ATabela, ACondicao: string): TQueryBuilder;
    function LeftJoin(const ATabela, ACondicao: string): TQueryBuilder;

    // Terminador — constrói o produto
    function Build: TQueryConfig;
    function ToSQL: string;  // atalho — Build + ToSQL
    procedure Reset;
  end;

// ---------------------------------------------------------------------------
// Builder para HTTP Request (exemplo diferente de domínio)
// ---------------------------------------------------------------------------
type
  THTTPMethod = (hmGET, hmPOST, hmPUT, hmDELETE, hmPATCH);

  THTTPRequest = record
    URL:     string;
    Method:  THTTPMethod;
    Headers: TDictionary<string, string>;
    Body:    string;
    Timeout: Integer;
    function MethodStr: string;
    function Describe: string;
  end;

  THTTPRequestBuilder = class
  private
    FURL:     string;
    FMethod:  THTTPMethod;
    FHeaders: TDictionary<string, string>;
    FBody:    string;
    FTimeout: Integer;
    procedure Validar;
  public
    constructor Create;
    destructor Destroy; override;

    function URL(const AURL: string): THTTPRequestBuilder;
    function Method(AMethod: THTTPMethod): THTTPRequestBuilder;
    function Header(const ANome, AValor: string): THTTPRequestBuilder;
    function BearerToken(const AToken: string): THTTPRequestBuilder;
    function ContentType(const AType: string): THTTPRequestBuilder;
    function Body(const ABody: string): THTTPRequestBuilder;
    function JsonBody(const AJSON: string): THTTPRequestBuilder;
    function Timeout(AMs: Integer): THTTPRequestBuilder;

    function Build: THTTPRequest;  // valida e constrói
  end;

implementation

// ---------------------------------------------------------------------------
// TQueryConfig
// ---------------------------------------------------------------------------

function TQueryConfig.ToSQL: string;
var
  Parts: TStringList;
  Campo, Cond, Ord, Join: string;
  Primeiro: Boolean;
begin
  Parts := TStringList.Create;
  try
    // SELECT
    if Length(Campos) = 0 then
      Parts.Add('SELECT *')
    else
      Parts.Add('SELECT ' + string.Join(', ', Campos));

    // FROM
    Parts.Add('FROM ' + Tabela);

    // JOINs
    for Join in Joins do
      Parts.Add(Join);

    // WHERE
    if Length(Condicoes) > 0 then
      Parts.Add('WHERE ' + string.Join(' AND ', Condicoes));

    // ORDER BY
    if Length(OrdemPor) > 0 then
      Parts.Add('ORDER BY ' + string.Join(', ', OrdemPor));

    // LIMIT / OFFSET
    if Limite > 0 then
      Parts.Add('LIMIT ' + IntToStr(Limite));
    if Offset > 0 then
      Parts.Add('OFFSET ' + IntToStr(Offset));

    Result := Parts.Text.Trim;
    Result := Result.Replace(sLineBreak, ' ');
  finally
    Parts.Free;
  end;
end;

// ---------------------------------------------------------------------------
// TQueryBuilder
// ---------------------------------------------------------------------------

constructor TQueryBuilder.Create;
begin
  inherited Create;
  FCampos    := TStringList.Create;
  FCondicoes := TStringList.Create;
  FOrdemPor  := TStringList.Create;
  FJoins     := TStringList.Create;
  FLimite    := 0;
  FOffset    := 0;
end;

destructor TQueryBuilder.Destroy;
begin
  FCampos.Free; FCondicoes.Free; FOrdemPor.Free; FJoins.Free;
  inherited;
end;

procedure TQueryBuilder.Reset;
begin
  FTabela := ''; FCampos.Clear; FCondicoes.Clear;
  FOrdemPor.Clear; FJoins.Clear; FLimite := 0; FOffset := 0;
end;

function TQueryBuilder.From(const ATabela: string): TQueryBuilder;
begin FTabela := ATabela; Result := Self; end;

function TQueryBuilder.Select(const ACampos: array of string): TQueryBuilder;
var C: string;
begin for C in ACampos do FCampos.Add(C); Result := Self; end;

function TQueryBuilder.Where(const ACondicao: string): TQueryBuilder;
begin FCondicoes.Clear; FCondicoes.Add(ACondicao); Result := Self; end;

function TQueryBuilder.AndWhere(const ACondicao: string): TQueryBuilder;
begin FCondicoes.Add(ACondicao); Result := Self; end;

function TQueryBuilder.OrWhere(const ACondicao: string): TQueryBuilder;
var UltIdx: Integer;
begin
  UltIdx := FCondicoes.Count - 1;
  if UltIdx >= 0 then
    FCondicoes[UltIdx] := '(' + FCondicoes[UltIdx] + ' OR ' + ACondicao + ')'
  else
    FCondicoes.Add(ACondicao);
  Result := Self;
end;

function TQueryBuilder.OrderBy(const ACampo: string; ADesc: Boolean): TQueryBuilder;
begin
  if ADesc then FOrdemPor.Add(ACampo + ' DESC')
  else FOrdemPor.Add(ACampo);
  Result := Self;
end;

function TQueryBuilder.Limit(AQtd: Integer): TQueryBuilder;
begin FLimite := AQtd; Result := Self; end;

function TQueryBuilder.Skip(AQtd: Integer): TQueryBuilder;
begin FOffset := AQtd; Result := Self; end;

function TQueryBuilder.Join(const ATabela, ACondicao: string): TQueryBuilder;
begin FJoins.Add('JOIN ' + ATabela + ' ON ' + ACondicao); Result := Self; end;

function TQueryBuilder.LeftJoin(const ATabela, ACondicao: string): TQueryBuilder;
begin FJoins.Add('LEFT JOIN ' + ATabela + ' ON ' + ACondicao); Result := Self; end;

function TQueryBuilder.Build: TQueryConfig;
var I: Integer;
begin
  if FTabela = '' then
    raise EInvalidOperation.Create('Builder: From() obrigatório');

  Result.Tabela := FTabela;

  SetLength(Result.Campos, FCampos.Count);
  for I := 0 to FCampos.Count - 1 do Result.Campos[I] := FCampos[I];

  SetLength(Result.Condicoes, FCondicoes.Count);
  for I := 0 to FCondicoes.Count - 1 do Result.Condicoes[I] := FCondicoes[I];

  SetLength(Result.OrdemPor, FOrdemPor.Count);
  for I := 0 to FOrdemPor.Count - 1 do Result.OrdemPor[I] := FOrdemPor[I];

  SetLength(Result.Joins, FJoins.Count);
  for I := 0 to FJoins.Count - 1 do Result.Joins[I] := FJoins[I];

  Result.Limite := FLimite;
  Result.Offset := FOffset;
end;

function TQueryBuilder.ToSQL: string;
begin Result := Build.ToSQL; end;

// ---------------------------------------------------------------------------
// THTTPRequest
// ---------------------------------------------------------------------------

function THTTPRequest.MethodStr: string;
const Names: array[THTTPMethod] of string = ('GET','POST','PUT','DELETE','PATCH');
begin Result := Names[Method]; end;

function THTTPRequest.Describe: string;
begin
  Result := Format('%s %s (timeout=%dms)', [MethodStr, URL, Timeout]);
end;

// ---------------------------------------------------------------------------
// THTTPRequestBuilder
// ---------------------------------------------------------------------------

constructor THTTPRequestBuilder.Create;
begin
  inherited Create;
  FHeaders := TDictionary<string, string>.Create;
  FMethod  := hmGET;
  FTimeout := 30000;
end;

destructor THTTPRequestBuilder.Destroy;
begin FHeaders.Free; inherited; end;

function THTTPRequestBuilder.URL(const AURL: string): THTTPRequestBuilder;
begin FURL := AURL; Result := Self; end;

function THTTPRequestBuilder.Method(AMethod: THTTPMethod): THTTPRequestBuilder;
begin FMethod := AMethod; Result := Self; end;

function THTTPRequestBuilder.Header(const ANome, AValor: string): THTTPRequestBuilder;
begin FHeaders.AddOrSetValue(ANome, AValor); Result := Self; end;

function THTTPRequestBuilder.BearerToken(const AToken: string): THTTPRequestBuilder;
begin Result := Header('Authorization', 'Bearer ' + AToken); end;

function THTTPRequestBuilder.ContentType(const AType: string): THTTPRequestBuilder;
begin Result := Header('Content-Type', AType); end;

function THTTPRequestBuilder.Body(const ABody: string): THTTPRequestBuilder;
begin FBody := ABody; Result := Self; end;

function THTTPRequestBuilder.JsonBody(const AJSON: string): THTTPRequestBuilder;
begin ContentType('application/json'); FBody := AJSON; Result := Self; end;

function THTTPRequestBuilder.Timeout(AMs: Integer): THTTPRequestBuilder;
begin FTimeout := AMs; Result := Self; end;

procedure THTTPRequestBuilder.Validar;
begin
  if FURL = '' then raise EInvalidOperation.Create('URL obrigatória');
  if (FMethod in [hmPOST, hmPUT, hmPATCH]) and (FBody = '') then
    raise EInvalidOperation.Create('Body obrigatório para ' + THTTPRequest(default(THTTPRequest)).MethodStr);
end;

function THTTPRequestBuilder.Build: THTTPRequest;
var K: string;
begin
  Validar;
  Result.URL     := FURL;
  Result.Method  := FMethod;
  Result.Body    := FBody;
  Result.Timeout := FTimeout;
  Result.Headers := TDictionary<string, string>.Create;
  for K in FHeaders.Keys do
    Result.Headers.Add(K, FHeaders[K]);
end;

// ---------------------------------------------------------------------------
// USO:
//   // QueryBuilder fluente
//   var SQL := TQueryBuilder.Create
//     .From('usuarios')
//     .Select(['id', 'nome', 'email'])
//     .Where('ativo = 1')
//     .AndWhere('idade > 18')
//     .OrderBy('nome')
//     .Limit(10)
//     .ToSQL;
//   Writeln(SQL);
//   // SELECT id, nome, email FROM usuarios WHERE ativo = 1 AND idade > 18 ORDER BY nome LIMIT 10
//
//   // Com JOIN
//   var SQL2 := TQueryBuilder.Create
//     .From('pedidos p')
//     .Select(['p.id', 'c.nome', 'p.total'])
//     .Join('clientes c', 'c.id = p.cliente_id')
//     .Where('p.status = ''aberto''')
//     .OrderBy('p.data', True)  // DESC
//     .Build.ToSQL;
//
//   // HTTPRequestBuilder
//   var Req := THTTPRequestBuilder.Create
//     .URL('https://api.exemplo.com/usuarios')
//     .Method(hmPOST)
//     .BearerToken('meu-token-jwt')
//     .JsonBody('{"nome":"Alice"}')
//     .Timeout(5000)
//     .Build;
//   Writeln(Req.Describe);
// ---------------------------------------------------------------------------

end.

unit TEMPLATE_http_stub;
///  TEMPLATE: Stub de cliente HTTP para testes de integracao sem servidor real.
///  ===========================================================================
///  Como usar:
///   1. Substituir ITODO_HttpClient pela interface real do cliente HTTP do projeto
///   2. Implementar THttpClientStub com os endpoints necessarios
///   3. Injetar o stub no servico via construtor
///   4. Verificar chamadas via propriedades do stub
///
///  Nao requer servidor HTTP real — usa implementacao in-memory.
///  Para testes que precisam de servidor real, usar TIdHTTPServer (Indy)
///  ou equivalente — ver consulta_rapida/integration_vs_unit.md.

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  DUnitX.TestFramework;

type
  // ---------------------------------------------------------------------------
  // Record de request/response HTTP
  // ---------------------------------------------------------------------------

  THttpRequest = record
    Metodo: string; // GET, POST, PUT, DELETE
    Url:    string;
    Corpo:  string;
    Headers: TDictionary<string, string>;
  end;

  THttpResponse = record
    StatusCode: Integer;
    Corpo:      string;
    Headers:    TDictionary<string, string>;
    constructor Create(AStatusCode: Integer; const ACorpo: string);
  end;

  // ---------------------------------------------------------------------------
  // Interface do cliente HTTP — dependencia a ser stubada
  // ---------------------------------------------------------------------------

  ITODO_HttpClient = interface
    ['{A1B2C3D4-0060-0000-0000-000000000060}']
    function Get(const AUrl: string): THttpResponse;
    function Post(const AUrl, ACorpo: string): THttpResponse;
    function Put(const AUrl, ACorpo: string): THttpResponse;
    function Delete(const AUrl: string): THttpResponse;
  end;

  // ---------------------------------------------------------------------------
  // Stub de HTTP — registra chamadas e retorna respostas configuradas
  // ---------------------------------------------------------------------------

  THttpClientStub = class(TInterfacedObject, ITODO_HttpClient)
  private
    FRespostas:   TDictionary<string, THttpResponse>; // key: "METODO:url"
    FChamadas:    TList<THttpRequest>;
  public
    constructor Create;
    destructor  Destroy; override;

    /// Configurar resposta para uma combinacao metodo+url
    procedure ConfigurarResposta(const AMetodo, AUrl: string; AStatusCode: Integer;
      const ACorpo: string = '');

    /// Verificar quantas vezes uma URL foi chamada
    function ContagemChamadas(const AMetodo, AUrl: string): Integer;

    /// Ultima chamada recebida
    function UltimaChamada: THttpRequest;

    /// Implementacoes de ITODO_HttpClient
    function Get(const AUrl: string): THttpResponse;
    function Post(const AUrl, ACorpo: string): THttpResponse;
    function Put(const AUrl, ACorpo: string): THttpResponse;
    function Delete(const AUrl: string): THttpResponse;
  end;

  // ---------------------------------------------------------------------------
  // Servico que usa o cliente HTTP
  // ---------------------------------------------------------------------------

  TTODO_ApiServico = class
  private
    FHttp:    ITODO_HttpClient;
    FBaseUrl: string;
  public
    constructor Create(const AHttp: ITODO_HttpClient; const ABaseUrl: string);
    function  BuscarRecurso(AId: Integer): string;
    procedure CriarRecurso(const AJson: string);
    function  RecursoExiste(AId: Integer): Boolean;
  end;

  // ---------------------------------------------------------------------------
  // TestFixture com HTTP stub
  // ---------------------------------------------------------------------------

  [TestFixture]
  [Category('HttpStub')]
  TTODO_ApiServicoTests = class
  private
    FHttpStub: THttpClientStub;
    FServico:  TTODO_ApiServico;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure BuscarRecurso_IdValido_RetornaCorpo;

    [Test]
    procedure BuscarRecurso_Status404_RetornaVazio;

    [Test]
    procedure CriarRecurso_JsonValido_ChamaPost;

    [Test]
    procedure RecursoExiste_Status200_RetornaTrue;

    [Test]
    procedure RecursoExiste_Status404_RetornaFalse;
  end;

implementation

// ---------------------------------------------------------------------------
// THttpResponse
// ---------------------------------------------------------------------------

constructor THttpResponse.Create(AStatusCode: Integer; const ACorpo: string);
begin
  StatusCode := AStatusCode;
  Corpo      := ACorpo;
  Headers    := nil;
end;

// ---------------------------------------------------------------------------
// THttpClientStub
// ---------------------------------------------------------------------------

constructor THttpClientStub.Create;
begin
  inherited Create;
  FRespostas := TDictionary<string, THttpResponse>.Create;
  FChamadas  := TList<THttpRequest>.Create;
end;

destructor THttpClientStub.Destroy;
begin
  FRespostas.Free;
  FChamadas.Free;
  inherited;
end;

procedure THttpClientStub.ConfigurarResposta(
  const AMetodo, AUrl: string; AStatusCode: Integer; const ACorpo: string);
begin
  FRespostas.AddOrSetValue(UpperCase(AMetodo) + ':' + AUrl,
    THttpResponse.Create(AStatusCode, ACorpo));
end;

function THttpClientStub.ContagemChamadas(const AMetodo, AUrl: string): Integer;
var
  Req: THttpRequest;
  Key: string;
begin
  Result := 0;
  Key    := UpperCase(AMetodo) + ':' + AUrl;
  for Req in FChamadas do
    if UpperCase(Req.Metodo) + ':' + Req.Url = Key then
      Inc(Result);
end;

function THttpClientStub.UltimaChamada: THttpRequest;
begin
  if FChamadas.Count = 0 then
  begin
    Result.Metodo := '';
    Result.Url    := '';
    Result.Corpo  := '';
  end
  else
    Result := FChamadas[FChamadas.Count - 1];
end;

function THttpClientStub.Get(const AUrl: string): THttpResponse;
var
  Req: THttpRequest;
  Key: string;
begin
  Req.Metodo  := 'GET';
  Req.Url     := AUrl;
  Req.Corpo   := '';
  Req.Headers := nil;
  FChamadas.Add(Req);

  Key := 'GET:' + AUrl;
  if FRespostas.ContainsKey(Key) then
    Result := FRespostas[Key]
  else
    Result := THttpResponse.Create(404, '');
end;

function THttpClientStub.Post(const AUrl, ACorpo: string): THttpResponse;
var
  Req: THttpRequest;
  Key: string;
begin
  Req.Metodo  := 'POST';
  Req.Url     := AUrl;
  Req.Corpo   := ACorpo;
  Req.Headers := nil;
  FChamadas.Add(Req);

  Key := 'POST:' + AUrl;
  if FRespostas.ContainsKey(Key) then
    Result := FRespostas[Key]
  else
    Result := THttpResponse.Create(201, '');
end;

function THttpClientStub.Put(const AUrl, ACorpo: string): THttpResponse;
var
  Req: THttpRequest;
  Key: string;
begin
  Req.Metodo  := 'PUT';
  Req.Url     := AUrl;
  Req.Corpo   := ACorpo;
  Req.Headers := nil;
  FChamadas.Add(Req);

  Key := 'PUT:' + AUrl;
  if FRespostas.ContainsKey(Key) then
    Result := FRespostas[Key]
  else
    Result := THttpResponse.Create(200, '');
end;

function THttpClientStub.Delete(const AUrl: string): THttpResponse;
var
  Req: THttpRequest;
  Key: string;
begin
  Req.Metodo  := 'DELETE';
  Req.Url     := AUrl;
  Req.Corpo   := '';
  Req.Headers := nil;
  FChamadas.Add(Req);

  Key := 'DELETE:' + AUrl;
  if FRespostas.ContainsKey(Key) then
    Result := FRespostas[Key]
  else
    Result := THttpResponse.Create(204, '');
end;

// ---------------------------------------------------------------------------
// TTODO_ApiServico
// ---------------------------------------------------------------------------

constructor TTODO_ApiServico.Create(const AHttp: ITODO_HttpClient; const ABaseUrl: string);
begin
  inherited Create;
  FHttp    := AHttp;
  FBaseUrl := ABaseUrl;
end;

function TTODO_ApiServico.BuscarRecurso(AId: Integer): string;
var
  Resp: THttpResponse;
begin
  Resp   := FHttp.Get(FBaseUrl + '/recursos/' + IntToStr(AId));
  if Resp.StatusCode = 200 then
    Result := Resp.Corpo
  else
    Result := '';
end;

procedure TTODO_ApiServico.CriarRecurso(const AJson: string);
begin
  FHttp.Post(FBaseUrl + '/recursos', AJson);
end;

function TTODO_ApiServico.RecursoExiste(AId: Integer): Boolean;
var
  Resp: THttpResponse;
begin
  Resp   := FHttp.Get(FBaseUrl + '/recursos/' + IntToStr(AId));
  Result := Resp.StatusCode = 200;
end;

// ---------------------------------------------------------------------------
// TTODO_ApiServicoTests
// ---------------------------------------------------------------------------

procedure TTODO_ApiServicoTests.Setup;
begin
  FHttpStub := THttpClientStub.Create;
  FServico  := TTODO_ApiServico.Create(FHttpStub, 'https://api.exemplo.com');
end;

procedure TTODO_ApiServicoTests.TearDown;
begin
  FServico.Free;
  FServico  := nil;
  FHttpStub := nil;
end;

procedure TTODO_ApiServicoTests.BuscarRecurso_IdValido_RetornaCorpo;
begin
  FHttpStub.ConfigurarResposta('GET', 'https://api.exemplo.com/recursos/42',
    200, '{"id":42,"nome":"Recurso A"}');

  var Resultado := FServico.BuscarRecurso(42);

  Assert.AreEqual('{"id":42,"nome":"Recurso A"}', Resultado,
    'BuscarRecurso deve retornar o corpo da resposta HTTP 200');
  Assert.AreEqual(1, FHttpStub.ContagemChamadas('GET',
    'https://api.exemplo.com/recursos/42'),
    'GET deve ter sido chamado uma vez');
end;

procedure TTODO_ApiServicoTests.BuscarRecurso_Status404_RetornaVazio;
begin
  // Nao configurar resposta = stub retorna 404 por padrao
  var Resultado := FServico.BuscarRecurso(999);
  Assert.AreEqual('', Resultado, '404 deve retornar string vazia');
end;

procedure TTODO_ApiServicoTests.CriarRecurso_JsonValido_ChamaPost;
begin
  FHttpStub.ConfigurarResposta('POST', 'https://api.exemplo.com/recursos', 201, '');

  FServico.CriarRecurso('{"nome":"Novo"}');

  Assert.AreEqual(1, FHttpStub.ContagemChamadas('POST',
    'https://api.exemplo.com/recursos'),
    'POST deve ter sido chamado uma vez');
  Assert.AreEqual('{"nome":"Novo"}', FHttpStub.UltimaChamada.Corpo,
    'Corpo do POST deve ser o JSON passado');
end;

procedure TTODO_ApiServicoTests.RecursoExiste_Status200_RetornaTrue;
begin
  FHttpStub.ConfigurarResposta('GET', 'https://api.exemplo.com/recursos/1', 200, '{}');
  Assert.IsTrue(FServico.RecursoExiste(1));
end;

procedure TTODO_ApiServicoTests.RecursoExiste_Status404_RetornaFalse;
begin
  Assert.IsFalse(FServico.RecursoExiste(404));
end;

initialization
  TDUnitX.RegisterTestFixture(TTODO_ApiServicoTests);

end.

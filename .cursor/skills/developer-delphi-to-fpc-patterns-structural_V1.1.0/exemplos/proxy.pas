unit proxy;
{
  Proxy Pattern em Delphi — lazy-loading + proxy de cache
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections, System.SyncObjs;

// ---------------------------------------------------------------------------
// Interface do serviço real
// ---------------------------------------------------------------------------
type
  IRelatorioService = interface
  ['{PX000001-0000-0000-0000-000000000001}']
    function  Gerar(const AId: string): string;
    function  Listar: TArray<string>;
    procedure Invalidar(const AId: string);
  end;

// ---------------------------------------------------------------------------
// Serviço real — operação cara (simulada)
// ---------------------------------------------------------------------------
type
  TRelatorioServiceReal = class(TInterfacedObject, IRelatorioService)
  private
    FCallCount: Integer;
  public
    function  Gerar(const AId: string): string;
    function  Listar: TArray<string>;
    procedure Invalidar(const AId: string);
    property CallCount: Integer read FCallCount;
  end;

// ---------------------------------------------------------------------------
// Proxy 1 — Lazy Loading
//   O serviço real só é criado quando realmente necessário
// ---------------------------------------------------------------------------
type
  TRelatorioLazyProxy = class(TInterfacedObject, IRelatorioService)
  private
    FReal: IRelatorioService;
    procedure EnsureReal;
  public
    function  Gerar(const AId: string): string;
    function  Listar: TArray<string>;
    procedure Invalidar(const AId: string);
  end;

// ---------------------------------------------------------------------------
// Proxy 2 — Cache
//   Armazena resultados, evita chamadas repetidas ao serviço real
// ---------------------------------------------------------------------------
type
  TRelatorioCache = record
    Conteudo:  string;
    CriadoEm: TDateTime;
  end;

  TRelatoriosCacheProxy = class(TInterfacedObject, IRelatorioService)
  private
    FReal:      IRelatorioService;
    FCache:     TDictionary<string, TRelatorioCache>;
    FTTL:       Double;  // minutos
    function    EstaExpirado(const AEntry: TRelatorioCache): Boolean;
  public
    constructor Create(AReal: IRelatorioService; ATTLMinutes: Double = 5);
    destructor Destroy; override;
    function  Gerar(const AId: string): string;
    function  Listar: TArray<string>;
    procedure Invalidar(const AId: string);
    function  CacheSize: Integer;
  end;

// ---------------------------------------------------------------------------
// Proxy 3 — Proteção (controle de acesso)
// ---------------------------------------------------------------------------
type
  TPermissao = (pLeitura, pEscrita, pAdmin);
  TPermissoes = set of TPermissao;

  TRelatorioSecurityProxy = class(TInterfacedObject, IRelatorioService)
  private
    FReal:       IRelatorioService;
    FPermissoes: TPermissoes;
    procedure Verificar(APermissao: TPermissao; const AOp: string);
  public
    constructor Create(AReal: IRelatorioService; APerms: TPermissoes);
    function  Gerar(const AId: string): string;
    function  Listar: TArray<string>;
    procedure Invalidar(const AId: string);
  end;

// Composição de proxies — cache + security wrapping lazy
function CriarRelatorioService(APerms: TPermissoes): IRelatorioService;

implementation

// ---------------------------------------------------------------------------
// TRelatorioServiceReal
// ---------------------------------------------------------------------------

function TRelatorioServiceReal.Gerar(const AId: string): string;
begin
  Inc(FCallCount);
  // Simular operação cara (I/O, DB query, etc.)
  Sleep(10);
  Result := Format('[Relat#%s] Conteúdo gerado em %s (chamada #%d)',
    [AId, FormatDateTime('hh:nn:ss.zzz', Now), FCallCount]);
end;

function TRelatorioServiceReal.Listar: TArray<string>;
begin
  Inc(FCallCount);
  Result := ['rel-001', 'rel-002', 'rel-003'];
end;

procedure TRelatorioServiceReal.Invalidar(const AId: string);
begin Writeln('[Real] Invalidar: ', AId); end;

// ---------------------------------------------------------------------------
// TRelatorioLazyProxy
// ---------------------------------------------------------------------------

procedure TRelatorioLazyProxy.EnsureReal;
begin
  if FReal = nil then
  begin
    Writeln('[LazyProxy] Criando serviço real...');
    FReal := TRelatorioServiceReal.Create;
  end;
end;

function TRelatorioLazyProxy.Gerar(const AId: string): string;
begin EnsureReal; Result := FReal.Gerar(AId); end;

function TRelatorioLazyProxy.Listar: TArray<string>;
begin EnsureReal; Result := FReal.Listar; end;

procedure TRelatorioLazyProxy.Invalidar(const AId: string);
begin EnsureReal; FReal.Invalidar(AId); end;

// ---------------------------------------------------------------------------
// TRelatoriosCacheProxy
// ---------------------------------------------------------------------------

constructor TRelatoriosCacheProxy.Create(AReal: IRelatorioService; ATTLMinutes: Double);
begin
  inherited Create;
  FReal  := AReal;
  FTTL   := ATTLMinutes / (24 * 60);  // converter para fração de dia
  FCache := TDictionary<string, TRelatorioCache>.Create;
end;

destructor TRelatoriosCacheProxy.Destroy;
begin FCache.Free; inherited; end;

function TRelatoriosCacheProxy.EstaExpirado(const AEntry: TRelatorioCache): Boolean;
begin Result := (Now - AEntry.CriadoEm) > FTTL; end;

function TRelatoriosCacheProxy.Gerar(const AId: string): string;
var Entry: TRelatorioCache;
begin
  if FCache.TryGetValue(AId, Entry) and not EstaExpirado(Entry) then
  begin
    Writeln('[Cache] HIT para ', AId);
    Result := Entry.Conteudo;
  end
  else
  begin
    Writeln('[Cache] MISS para ', AId);
    Result := FReal.Gerar(AId);
    Entry.Conteudo  := Result;
    Entry.CriadoEm := Now;
    FCache.AddOrSetValue(AId, Entry);
  end;
end;

function TRelatoriosCacheProxy.Listar: TArray<string>;
begin Result := FReal.Listar; end;

procedure TRelatoriosCacheProxy.Invalidar(const AId: string);
begin
  FCache.Remove(AId);
  FReal.Invalidar(AId);
end;

function TRelatoriosCacheProxy.CacheSize: Integer;
begin Result := FCache.Count; end;

// ---------------------------------------------------------------------------
// TRelatorioSecurityProxy
// ---------------------------------------------------------------------------

constructor TRelatorioSecurityProxy.Create(AReal: IRelatorioService; APerms: TPermissoes);
begin inherited Create; FReal := AReal; FPermissoes := APerms; end;

procedure TRelatorioSecurityProxy.Verificar(APermissao: TPermissao; const AOp: string);
begin
  if not (APermissao in FPermissoes) then
    raise EAccessViolation.CreateFmt(
      'Acesso negado à operação "%s"', [AOp]);
end;

function TRelatorioSecurityProxy.Gerar(const AId: string): string;
begin Verificar(pLeitura, 'Gerar'); Result := FReal.Gerar(AId); end;

function TRelatorioSecurityProxy.Listar: TArray<string>;
begin Verificar(pLeitura, 'Listar'); Result := FReal.Listar; end;

procedure TRelatorioSecurityProxy.Invalidar(const AId: string);
begin Verificar(pAdmin, 'Invalidar'); FReal.Invalidar(AId); end;

// ---------------------------------------------------------------------------
// Composição de proxies
// ---------------------------------------------------------------------------

function CriarRelatorioService(APerms: TPermissoes): IRelatorioService;
var LazyReal: IRelatorioService;
    Cached:   IRelatorioService;
begin
  // Camadas: Security → Cache → Lazy → Real
  LazyReal := TRelatorioLazyProxy.Create;
  Cached   := TRelatoriosCacheProxy.Create(LazyReal, 10);
  Result   := TRelatorioSecurityProxy.Create(Cached, APerms);
end;

// ---------------------------------------------------------------------------
// USO:
//   // Lazy proxy — serviço real criado só na primeira chamada
//   var S: IRelatorioService := TRelatorioLazyProxy.Create;
//   Writeln(S.Gerar('001'));  // agora o real é criado
//
//   // Cache proxy
//   var Real := TRelatorioServiceReal.Create;
//   var Cached := TRelatoriosCacheProxy.Create(Real, 5); // TTL 5 min
//   Writeln(Cached.Gerar('001'));  // MISS → chama real
//   Writeln(Cached.Gerar('001'));  // HIT → retorna cache
//   Cached.Invalidar('001');       // limpa cache + real
//
//   // Composição com segurança
//   var SvcAdmin := CriarRelatorioService([pLeitura, pEscrita, pAdmin]);
//   var SvcUser  := CriarRelatorioService([pLeitura]);
//   Writeln(SvcUser.Gerar('002'));   // OK
//   SvcUser.Invalidar('002');        // EAccessViolation!
// ---------------------------------------------------------------------------

end.

unit object_pool;
{
  Object Pool em Delphi — pool de objetos reutilizáveis com Acquire/Release
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.SyncObjs, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Interface do objeto poolável
// ---------------------------------------------------------------------------
type
  IPoolable = interface
  ['{PO000001-0000-0000-0000-000000000001}']
    procedure OnAcquire;   // chamado ao sair do pool
    procedure OnRelease;   // chamado ao voltar ao pool
    function  IsValid: Boolean;  // objeto ainda utilizável?
  end;

// ---------------------------------------------------------------------------
// Pool genérico thread-safe
// ---------------------------------------------------------------------------
type
  TObjectPool<T: IPoolable> = class
  private type
    TFactory = TFunc<T>;
  private
    FAvailable: TStack<T>;
    FInUse:     TList<T>;
    FFactory:   TFactory;
    FLock:      TCriticalSection;
    FMaxSize:   Integer;
    FMinSize:   Integer;
    procedure PreAquecer;
  public
    constructor Create(AFactory: TFactory; AMinSize: Integer = 2; AMaxSize: Integer = 10);
    destructor Destroy; override;
    function  Acquire: T;
    procedure Release(AObj: T);
    function  TotalCriados: Integer;
    function  Disponiveis: Integer;
    function  EmUso: Integer;
  end;

// ---------------------------------------------------------------------------
// Objeto concreto 1 — TConexaoSimulada (conexão de banco simulada)
// ---------------------------------------------------------------------------
type
  TConexaoSimulada = class(TInterfacedObject, IPoolable)
  private
    FId:        Integer;
    FConectada: Boolean;
    class var FContador: Integer;
  public
    constructor Create;
    procedure OnAcquire;
    procedure OnRelease;
    function  IsValid: Boolean;
    function  Executar(const ASQL: string): string;
    property Id: Integer read FId;
  end;

// ---------------------------------------------------------------------------
// Objeto concreto 2 — TBufferSimulado (buffer reutilizável)
// ---------------------------------------------------------------------------
type
  TBufferSimulado = class(TInterfacedObject, IPoolable)
  private
    FDados: TBytes;
    FTamanho: Integer;
    FEmUso: Boolean;
  public
    constructor Create(ATamanho: Integer = 4096);
    procedure OnAcquire;
    procedure OnRelease;
    function  IsValid: Boolean;
    procedure Escrever(const ABytes: TBytes);
    function  Ler: TBytes;
    property Tamanho: Integer read FTamanho;
  end;

// ---------------------------------------------------------------------------
// Pool com scoped acquire — RAII automático via record
// ---------------------------------------------------------------------------
type
  TPoolScope<T: IPoolable> = record
  private
    FPool: TObjectPool<T>;
    FObj:  T;
  public
    constructor Create(APool: TObjectPool<T>);
    procedure Dispose;
    property Obj: T read FObj;
  end;

implementation

// ---------------------------------------------------------------------------
// TObjectPool<T>
// ---------------------------------------------------------------------------

constructor TObjectPool<T>.Create(AFactory: TFactory; AMinSize, AMaxSize: Integer);
begin
  inherited Create;
  FFactory   := AFactory;
  FMinSize   := AMinSize;
  FMaxSize   := AMaxSize;
  FAvailable := TStack<T>.Create;
  FInUse     := TList<T>.Create;
  FLock      := TCriticalSection.Create;
  PreAquecer;
end;

destructor TObjectPool<T>.Destroy;
begin
  FAvailable.Free;
  FInUse.Free;
  FLock.Free;
  inherited;
end;

procedure TObjectPool<T>.PreAquecer;
var I: Integer;
begin
  for I := 1 to FMinSize do
    FAvailable.Push(FFactory());
end;

function TObjectPool<T>.Acquire: T;
begin
  FLock.Enter;
  try
    // Tentar pegar do pool; se vazio e dentro do limite, criar novo
    if FAvailable.Count > 0 then
      Result := FAvailable.Pop
    else if (FInUse.Count + FAvailable.Count) < FMaxSize then
      Result := FFactory()
    else
      raise EInvalidOperation.CreateFmt(
        'Pool esgotado (max=%d)', [FMaxSize]);

    // Rejeitar inválidos — criar substituto
    if not Result.IsValid then
      Result := FFactory();

    FInUse.Add(Result);
    Result.OnAcquire;
  finally
    FLock.Leave;
  end;
end;

procedure TObjectPool<T>.Release(AObj: T);
begin
  FLock.Enter;
  try
    if FInUse.Remove(AObj) >= 0 then
    begin
      AObj.OnRelease;
      if AObj.IsValid then
        FAvailable.Push(AObj);
      // inválido — simplesmente descartado (GC cuida)
    end;
  finally
    FLock.Leave;
  end;
end;

function TObjectPool<T>.TotalCriados: Integer;
begin
  FLock.Enter;
  try Result := FAvailable.Count + FInUse.Count;
  finally FLock.Leave; end;
end;

function TObjectPool<T>.Disponiveis: Integer;
begin FLock.Enter; try Result := FAvailable.Count; finally FLock.Leave; end; end;

function TObjectPool<T>.EmUso: Integer;
begin FLock.Enter; try Result := FInUse.Count; finally FLock.Leave; end; end;

// ---------------------------------------------------------------------------
// TConexaoSimulada
// ---------------------------------------------------------------------------

constructor TConexaoSimulada.Create;
begin
  inherited Create;
  Inc(FContador);
  FId := FContador;
  FConectada := True;
  Writeln(Format('[Conn#%d] Criada', [FId]));
end;

procedure TConexaoSimulada.OnAcquire;
begin Writeln(Format('[Conn#%d] Adquirida', [FId])); end;

procedure TConexaoSimulada.OnRelease;
begin Writeln(Format('[Conn#%d] Devolvida ao pool', [FId])); end;

function TConexaoSimulada.IsValid: Boolean;
begin Result := FConectada; end;

function TConexaoSimulada.Executar(const ASQL: string): string;
begin
  Result := Format('[Conn#%d] SQL: %s → OK', [FId, ASQL]);
end;

// ---------------------------------------------------------------------------
// TBufferSimulado
// ---------------------------------------------------------------------------

constructor TBufferSimulado.Create(ATamanho: Integer);
begin
  inherited Create;
  FTamanho := ATamanho;
  SetLength(FDados, FTamanho);
  FEmUso := False;
end;

procedure TBufferSimulado.OnAcquire;
begin
  FEmUso := True;
  FillChar(FDados[0], FTamanho, 0);  // limpar ao adquirir
end;

procedure TBufferSimulado.OnRelease;
begin FEmUso := False; end;

function TBufferSimulado.IsValid: Boolean;
begin Result := Length(FDados) = FTamanho; end;

procedure TBufferSimulado.Escrever(const ABytes: TBytes);
var Len: Integer;
begin
  Len := Min(Length(ABytes), FTamanho);
  Move(ABytes[0], FDados[0], Len);
end;

function TBufferSimulado.Ler: TBytes;
begin
  SetLength(Result, FTamanho);
  Move(FDados[0], Result[0], FTamanho);
end;

// ---------------------------------------------------------------------------
// TPoolScope<T> — RAII
// ---------------------------------------------------------------------------

constructor TPoolScope<T>.Create(APool: TObjectPool<T>);
begin
  FPool := APool;
  FObj  := APool.Acquire;
end;

procedure TPoolScope<T>.Dispose;
begin
  if FPool <> nil then
  begin
    FPool.Release(FObj);
    FPool := nil;
  end;
end;

// ---------------------------------------------------------------------------
// USO:
//   // Criar pool de conexões (min 2, max 5)
//   var Pool := TObjectPool<TConexaoSimulada>.Create(
//     function: TConexaoSimulada begin Result := TConexaoSimulada.Create; end,
//     2, 5);
//   try
//     // Adquirir e usar
//     var C1 := Pool.Acquire;
//     var C2 := Pool.Acquire;
//     Writeln(C1.Executar('SELECT 1'));
//     Writeln(C2.Executar('SELECT 2'));
//     // Devolver ao pool
//     Pool.Release(C1);
//     Pool.Release(C2);
//     Writeln('Disponíveis: ', Pool.Disponiveis);   // 2
//     Writeln('Em uso: ', Pool.EmUso);              // 0
//   finally
//     Pool.Free;
//   end;
//
//   // Pool de buffers
//   var BufPool := TObjectPool<TBufferSimulado>.Create(
//     function: TBufferSimulado begin Result := TBufferSimulado.Create(8192); end,
//     3, 20);
//   var Buf := BufPool.Acquire;
//   Buf.Escrever(TEncoding.UTF8.GetBytes('Hello World'));
//   BufPool.Release(Buf);
// ---------------------------------------------------------------------------

end.

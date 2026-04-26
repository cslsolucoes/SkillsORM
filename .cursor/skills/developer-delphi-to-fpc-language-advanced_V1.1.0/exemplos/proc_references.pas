unit proc_references;
{
  TProc<T>, TFunc<T,R> — tipos de referência procedural em Delphi
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Tipos de referência procedural (System.SysUtils)
// TProc<T>        = reference to procedure(Arg1: T)
// TFunc<T, R>     = reference to function(Arg1: T): R
// TProc           = reference to procedure
// TFunc<R>        = reference to function: R
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Passagem como parâmetro
// ---------------------------------------------------------------------------

// Filtrar lista de strings com predicado TFunc
function FiltrarStrings(const ALista: TArray<string>;
  APred: TFunc<string, Boolean>): TArray<string>;

// Mapear lista com transformação TFunc
function MapearStrings(const ALista: TArray<string>;
  ATransf: TFunc<string, string>): TArray<string>;

// Executar ação em cada elemento TProc
procedure ParaCada(const ALista: TArray<string>; AAcao: TProc<string>);

// ---------------------------------------------------------------------------
// Composição de funções
// ---------------------------------------------------------------------------
function Compor<T>(AFirst: TFunc<T, T>; ASecond: TFunc<T, T>): TFunc<T, T>;

// ---------------------------------------------------------------------------
// Retry com TFunc<Boolean>
// ---------------------------------------------------------------------------
function TentarN(ATentativas: Integer; AAcao: TFunc<Boolean>): Boolean;

// ---------------------------------------------------------------------------
// Multicast event com TProc<T>
// ---------------------------------------------------------------------------
type
  TMulticastEvent<T> = class
  private
    FHandlers: TList<TProc<T>>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Adicionar(AHandler: TProc<T>);
    procedure Remover(AHandler: TProc<T>);
    procedure Disparar(const AArg: T);
    property Count: Integer read (FHandlers.Count);
  end;

// ---------------------------------------------------------------------------
// TFunc como strategy/command
// ---------------------------------------------------------------------------
type
  TComando = TProc;

  TFila = class
  private
    FComandos: TQueue<TComando>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Enfileirar(AComando: TComando);
    procedure ExecutarTodos;
  end;

implementation

// ---------------------------------------------------------------------------
// FiltrarStrings
// ---------------------------------------------------------------------------

function FiltrarStrings(const ALista: TArray<string>;
  APred: TFunc<string, Boolean>): TArray<string>;
var
  Item: string;
  Res : TArray<string>;
  N   : Integer;
begin
  N := 0;
  SetLength(Res, Length(ALista));
  for Item in ALista do
    if APred(Item) then
    begin Res[N] := Item; Inc(N); end;
  SetLength(Res, N);
  Result := Res;
end;

// ---------------------------------------------------------------------------
// MapearStrings
// ---------------------------------------------------------------------------

function MapearStrings(const ALista: TArray<string>;
  ATransf: TFunc<string, string>): TArray<string>;
var I: Integer;
begin
  SetLength(Result, Length(ALista));
  for I := 0 to High(ALista) do
    Result[I] := ATransf(ALista[I]);
end;

// ---------------------------------------------------------------------------
// ParaCada
// ---------------------------------------------------------------------------

procedure ParaCada(const ALista: TArray<string>; AAcao: TProc<string>);
var Item: string;
begin
  for Item in ALista do AAcao(Item);
end;

// ---------------------------------------------------------------------------
// Compor<T> — f(g(x))
// ---------------------------------------------------------------------------

function Compor<T>(AFirst: TFunc<T, T>; ASecond: TFunc<T, T>): TFunc<T, T>;
begin
  Result := function(AArg: T): T
  begin
    Result := ASecond(AFirst(AArg));
  end;
end;

// ---------------------------------------------------------------------------
// TentarN
// ---------------------------------------------------------------------------

function TentarN(ATentativas: Integer; AAcao: TFunc<Boolean>): Boolean;
var I: Integer;
begin
  for I := 1 to ATentativas do
    if AAcao() then Exit(True);
  Result := False;
end;

// ---------------------------------------------------------------------------
// TMulticastEvent<T>
// ---------------------------------------------------------------------------

constructor TMulticastEvent<T>.Create;
begin
  inherited Create;
  FHandlers := TList<TProc<T>>.Create;
end;

destructor TMulticastEvent<T>.Destroy;
begin
  FHandlers.Free;
  inherited;
end;

procedure TMulticastEvent<T>.Adicionar(AHandler: TProc<T>);
begin
  FHandlers.Add(AHandler);
end;

procedure TMulticastEvent<T>.Remover(AHandler: TProc<T>);
begin
  FHandlers.Remove(AHandler);
end;

procedure TMulticastEvent<T>.Disparar(const AArg: T);
var H: TProc<T>;
begin
  for H in FHandlers do H(AArg);
end;

// ---------------------------------------------------------------------------
// TFila
// ---------------------------------------------------------------------------

constructor TFila.Create;
begin
  inherited Create;
  FComandos := TQueue<TComando>.Create;
end;

destructor TFila.Destroy;
begin
  FComandos.Free;
  inherited;
end;

procedure TFila.Enfileirar(AComando: TComando);
begin
  FComandos.Enqueue(AComando);
end;

procedure TFila.ExecutarTodos;
begin
  while FComandos.Count > 0 do
    FComandos.Dequeue()();
end;

// ---------------------------------------------------------------------------
// USO:
//   var Nomes := TArray<string>.Create('Ana','Bob','Carlos','Daniela','Eva');
//
//   // Filtrar: só nomes com mais de 3 chars
//   var Longos := FiltrarStrings(Nomes,
//     function(S: string): Boolean begin Result := Length(S) > 3; end);
//   // ['Carlos', 'Daniela', 'Eva'] — espera: Carlos, Daniela
//
//   // Mapear: toUpper
//   var Upper := MapearStrings(Nomes,
//     function(S: string): string begin Result := S.ToUpper; end);
//
//   // ParaCada com ação
//   ParaCada(Nomes, procedure(S: string) begin Writeln(S); end);
//
//   // Composição: trim + uppercase
//   var Normalizar := Compor<string>(
//     function(S: string): string begin Result := S.Trim; end,
//     function(S: string): string begin Result := S.ToUpper; end);
//   Writeln(Normalizar('  hello  '));  // HELLO
//
//   // Multicast
//   var OnNovo := TMulticastEvent<string>.Create;
//   OnNovo.Adicionar(procedure(S: string) begin Writeln('Log: ', S); end);
//   OnNovo.Adicionar(procedure(S: string) begin Writeln('Email: ', S); end);
//   OnNovo.Disparar('Novo cliente');
//   OnNovo.Free;
//
//   // Fila de comandos
//   var Fila := TFila.Create;
//   Fila.Enfileirar(procedure begin Writeln('Cmd 1'); end);
//   Fila.Enfileirar(procedure begin Writeln('Cmd 2'); end);
//   Fila.ExecutarTodos;
//   Fila.Free;
// ---------------------------------------------------------------------------

end.

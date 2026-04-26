unit closures;
{
  Closures em Delphi — captura de variáveis, memoização, contador
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Closure simples: contador com estado encapsulado
// ---------------------------------------------------------------------------
function CriarContador(AInicio: Integer = 0): TFunc<Integer>;
function CriarContadorComReset: TPair<TFunc<Integer>, TProc>;

// ---------------------------------------------------------------------------
// Closure com acumulador: soma parcial
// ---------------------------------------------------------------------------
function CriarAcumulador(AInicial: Double = 0): TFunc<Double, Double>;

// ---------------------------------------------------------------------------
// Memoização genérica via closure
// ---------------------------------------------------------------------------
function Memoizar<T, R>(AFunc: TFunc<T, R>): TFunc<T, R>;

// ---------------------------------------------------------------------------
// Closure em loop — armadilha clássica
// ---------------------------------------------------------------------------
procedure DemoArmadilhaLoop;
procedure DemoArmadilhaLoopCorrigida;

// ---------------------------------------------------------------------------
// Closure como estratégia (Strategy pattern sem classe)
// ---------------------------------------------------------------------------
type
  TOrdenadorStr = TFunc<string, string, Integer>;

function CriarOrdenadorPorTamanho(ADecrescente: Boolean): TOrdenadorStr;
function CriarOrdenadorAlfabetico(ACaseSensitive: Boolean): TOrdenadorStr;

implementation

// ---------------------------------------------------------------------------
// CriarContador
// ---------------------------------------------------------------------------

function CriarContador(AInicio: Integer): TFunc<Integer>;
var FN: Integer;
begin
  FN     := AInicio;
  Result := function: Integer
  begin
    Inc(FN);
    Result := FN;
  end;
end;

function CriarContadorComReset: TPair<TFunc<Integer>, TProc>;
var FN: Integer;
begin
  FN := 0;
  Result := TPair<TFunc<Integer>, TProc>.Create(
    function: Integer begin Inc(FN); Result := FN; end,
    procedure begin FN := 0; end);
end;

// ---------------------------------------------------------------------------
// CriarAcumulador
// ---------------------------------------------------------------------------

function CriarAcumulador(AInicial: Double): TFunc<Double, Double>;
var FAcum: Double;
begin
  FAcum  := AInicial;
  Result := function(AValor: Double): Double
  begin
    FAcum  := FAcum + AValor;
    Result := FAcum;
  end;
end;

// ---------------------------------------------------------------------------
// Memoizar<T, R> — cache de resultados via closure + dicionário
// ---------------------------------------------------------------------------

function Memoizar<T, R>(AFunc: TFunc<T, R>): TFunc<T, R>;
var FCache: TDictionary<T, R>;
begin
  FCache := TDictionary<T, R>.Create;
  // FCache é capturado — vive enquanto o closure existir
  Result := function(AArg: T): R
  var Res: R;
  begin
    if not FCache.TryGetValue(AArg, Res) then
    begin
      Res := AFunc(AArg);
      FCache.Add(AArg, Res);
    end;
    Result := Res;
  end;
  // ATENÇÃO: FCache nunca é liberado nesta implementação simplificada.
  // Em produção, embrulhar o closure em um objeto que Free o cache no destructor.
end;

// ---------------------------------------------------------------------------
// Armadilha do loop — todos os closures capturam a MESMA variável I
// ---------------------------------------------------------------------------

procedure DemoArmadilhaLoop;
var
  I       : Integer;
  Handlers: TArray<TFunc<Integer>>;
begin
  SetLength(Handlers, 3);
  for I := 0 to 2 do
    Handlers[I] := function: Integer begin Result := I; end;
    // PROBLEMA: todos capturam a variável I por referência!
    // Quando executados, I já terminou com valor 3 (após o loop)

  Writeln('=== Armadilha do loop (ERRADO) ===');
  for var H in Handlers do
    Write(H(), ' ');  // 3 3 3 — INESPERADO!
  Writeln;
end;

// ---------------------------------------------------------------------------
// Solução: capturar em variável local imutável dentro do escopo correto
// ---------------------------------------------------------------------------

function CriarHandlerParaI(AI: Integer): TFunc<Integer>;
begin
  // AI é um parâmetro — cada chamada cria uma cópia independente
  Result := function: Integer begin Result := AI; end;
end;

procedure DemoArmadilhaLoopCorrigida;
var
  I       : Integer;
  Handlers: TArray<TFunc<Integer>>;
begin
  SetLength(Handlers, 3);
  for I := 0 to 2 do
    Handlers[I] := CriarHandlerParaI(I);  // cada closure captura AI próprio

  Writeln('=== Loop corrigido (CERTO) ===');
  for var H in Handlers do
    Write(H(), ' ');  // 0 1 2 — CORRETO
  Writeln;
end;

// ---------------------------------------------------------------------------
// Estratégias como closures
// ---------------------------------------------------------------------------

function CriarOrdenadorPorTamanho(ADecrescente: Boolean): TOrdenadorStr;
begin
  if ADecrescente then
    Result := function(const A, B: string): Integer
    begin Result := Length(B) - Length(A); end
  else
    Result := function(const A, B: string): Integer
    begin Result := Length(A) - Length(B); end;
end;

function CriarOrdenadorAlfabetico(ACaseSensitive: Boolean): TOrdenadorStr;
begin
  if ACaseSensitive then
    Result := function(const A, B: string): Integer
    begin Result := CompareStr(A, B); end
  else
    Result := function(const A, B: string): Integer
    begin Result := CompareText(A, B); end;
end;

// ---------------------------------------------------------------------------
// USO:
//   // Contador
//   var C := CriarContador(10);
//   Writeln(C()); Writeln(C()); Writeln(C());  // 11 12 13
//
//   // Contador com reset
//   var Par := CriarContadorComReset;
//   var Incrementar := Par.Key;
//   var Reset       := Par.Value;
//   Writeln(Incrementar()); // 1
//   Writeln(Incrementar()); // 2
//   Reset();
//   Writeln(Incrementar()); // 1
//
//   // Acumulador
//   var Acum := CriarAcumulador(100);
//   Writeln(Acum(10));  // 110
//   Writeln(Acum(5));   // 115
//
//   // Memoização
//   var ContChamadas := 0;
//   var Quadrado := Memoizar<Integer,Integer>(
//     function(N: Integer): Integer begin Inc(ContChamadas); Result := N*N; end);
//   Writeln(Quadrado(5));  // 25, ContChamadas=1
//   Writeln(Quadrado(5));  // 25, ContChamadas=1 (do cache)
//   Writeln(Quadrado(3));  // 9,  ContChamadas=2
//
//   // Armadilha
//   DemoArmadilhaLoop;          // imprime: 3 3 3
//   DemoArmadilhaLoopCorrigida; // imprime: 0 1 2
// ---------------------------------------------------------------------------

end.

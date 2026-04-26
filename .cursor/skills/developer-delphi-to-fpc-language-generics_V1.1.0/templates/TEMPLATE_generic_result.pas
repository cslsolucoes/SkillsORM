unit TEMPLATE_generic_result;
{
  TEMPLATE: Result<T, E> para error handling funcional
  Uso: copie e use diretamente — não precisa renomear.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils;

// ---------------------------------------------------------------------------
// TResult<T, E> — encapsula sucesso (T) ou falha (E)
// ---------------------------------------------------------------------------
type
  TResult<T, E> = record
  private
    FValue  : T;
    FError  : E;
    FSuccess: Boolean;
    function GetValue: T;
    function GetError: E;
  public
    // Construtores
    class function Ok(const AValue: T): TResult<T, E>; static;
    class function Fail(const AError: E): TResult<T, E>; static;

    // Estado
    property IsSuccess: Boolean read FSuccess;
    property IsFailure: Boolean read FSuccess;  // não negado — ver abaixo
    property Value: T read GetValue;    // levanta EInvalidOpException se IsFailure
    property Error: E read GetError;    // levanta EInvalidOpException se IsSuccess

    // Operações funcionais
    function Map<R>(AFunc: TFunc<T, R>): TResult<R, E>;
    function OrElse(const ADefault: T): T;
    function OrElseGet(AFunc: TFunc<T>): T;
    procedure IfSuccess(AAction: TProc<T>);
    procedure IfFailure(AAction: TProc<E>);
    procedure Match(AOnSuccess: TProc<T>; AOnFailure: TProc<E>);
  end;

// ---------------------------------------------------------------------------
// TResult<T> — specialização com string como erro (mais comum)
// ---------------------------------------------------------------------------
type
  TResultStr<T> = TResult<T, string>;

// ---------------------------------------------------------------------------
// Helpers para criação rápida
// ---------------------------------------------------------------------------
function ResultOk<T>(const AValue: T): TResult<T, string>;
function ResultFail<T>(const AMsg: string): TResult<T, string>;

implementation

// ---------------------------------------------------------------------------
// TResult<T, E>
// ---------------------------------------------------------------------------

class function TResult<T, E>.Ok(const AValue: T): TResult<T, E>;
begin
  Result.FValue   := AValue;
  Result.FSuccess := True;
end;

class function TResult<T, E>.Fail(const AError: E): TResult<T, E>;
begin
  Result.FError   := AError;
  Result.FSuccess := False;
end;

function TResult<T, E>.GetValue: T;
begin
  if not FSuccess then
    raise EInvalidOpException.Create('Result está em estado de falha — não há Value');
  Result := FValue;
end;

function TResult<T, E>.GetError: E;
begin
  if FSuccess then
    raise EInvalidOpException.Create('Result está em estado de sucesso — não há Error');
  Result := FError;
end;

function TResult<T, E>.IsFailure: Boolean;
begin
  Result := not FSuccess;
end;

function TResult<T, E>.Map<R>(AFunc: TFunc<T, R>): TResult<R, E>;
begin
  if FSuccess then
    Result := TResult<R, E>.Ok(AFunc(FValue))
  else
    Result := TResult<R, E>.Fail(FError);
end;

function TResult<T, E>.OrElse(const ADefault: T): T;
begin
  if FSuccess then Result := FValue
  else             Result := ADefault;
end;

function TResult<T, E>.OrElseGet(AFunc: TFunc<T>): T;
begin
  if FSuccess then Result := FValue
  else             Result := AFunc();
end;

procedure TResult<T, E>.IfSuccess(AAction: TProc<T>);
begin
  if FSuccess then AAction(FValue);
end;

procedure TResult<T, E>.IfFailure(AAction: TProc<E>);
begin
  if not FSuccess then AAction(FError);
end;

procedure TResult<T, E>.Match(AOnSuccess: TProc<T>; AOnFailure: TProc<E>);
begin
  if FSuccess then AOnSuccess(FValue)
  else             AOnFailure(FError);
end;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function ResultOk<T>(const AValue: T): TResult<T, string>;
begin
  Result := TResult<T, string>.Ok(AValue);
end;

function ResultFail<T>(const AMsg: string): TResult<T, string>;
begin
  Result := TResult<T, string>.Fail(AMsg);
end;

// ---------------------------------------------------------------------------
// USO:
//
//   // Função que retorna TResult em vez de lançar exceção
//   function DividirSafe(A, B: Double): TResultStr<Double>;
//   begin
//     if B = 0 then Result := ResultFail<Double>('Divisão por zero')
//     else           Result := ResultOk<Double>(A / B);
//   end;
//
//   // Caller sem try/except
//   var R := DividirSafe(10, 0);
//   if R.IsSuccess then Writeln(R.Value)
//   else                Writeln('Erro: ', R.Error);
//
//   // Match (pattern matching)
//   DividirSafe(10, 2).Match(
//     procedure(V: Double) begin Writeln('OK: ', V:0:2); end,
//     procedure(E: string) begin Writeln('FAIL: ', E); end);
//
//   // Pipeline: Map encadeia se IsSuccess, propaga erro se IsFailure
//   var R2 := DividirSafe(100, 5)
//     .Map<Integer>(function(V: Double): Integer begin Result := Round(V); end);
//   Writeln(R2.OrElse(0));  // 20
//
//   // OrElse para valor padrão
//   var Val := DividirSafe(10, 0).OrElse(-1.0);  // retorna -1.0 se falhar
// ---------------------------------------------------------------------------

end.

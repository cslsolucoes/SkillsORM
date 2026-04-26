unit TEMPLATE_nullable;
{
  TEMPLATE: TNullable<T> record com HasValue/Value/OrElse
  Uso: copie e use diretamente — não precisa renomear.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils;

// ---------------------------------------------------------------------------
// TNullable<T> — valor que pode estar ausente (como SQL NULL)
// ---------------------------------------------------------------------------
type
  TNullable<T> = record
  private
    FValue   : T;
    FHasValue: Boolean;
    function GetValue: T;
  public
    // Construtores (usar class functions em record)
    class function Create(const AValue: T): TNullable<T>; static;
    class function Empty: TNullable<T>; static;

    // Estado
    property HasValue: Boolean read FHasValue;
    property Value: T read GetValue;  // levanta exceção se !HasValue

    // Recuperar valor com fallback
    function OrElse(const ADefault: T): T;
    function OrElseGet(AFunc: TFunc<T>): T;
    procedure IfHasValue(AAction: TProc<T>);

    // Transformação
    function Map<R>(AFunc: TFunc<T, R>): TNullable<R>;
    function Filter(APred: TFunc<T, Boolean>): TNullable<T>;

    // Operadores implícitos para conveniência de atribuição
    class operator Implicit(const AValue: T): TNullable<T>;
    class operator Implicit(const ANullable: TNullable<T>): T;
    class operator Equal(const A, B: TNullable<T>): Boolean;

    // ToString
    function ToString: string;
  end;

// ---------------------------------------------------------------------------
// Aliases tipados comuns
// ---------------------------------------------------------------------------
type
  TNullableInt      = TNullable<Integer>;
  TNullableStr      = TNullable<string>;
  TNullableDouble   = TNullable<Double>;
  TNullableBool     = TNullable<Boolean>;
  TNullableDateTime = TNullable<TDateTime>;

// ---------------------------------------------------------------------------
// Helpers de criação rápida
// ---------------------------------------------------------------------------
function NullableInt(AValue: Integer): TNullableInt;
function NullableStr(const AValue: string): TNullableStr;
function NullableDouble(AValue: Double): TNullableDouble;
function NullableBool(AValue: Boolean): TNullableBool;

implementation

// ---------------------------------------------------------------------------
// TNullable<T>
// ---------------------------------------------------------------------------

class function TNullable<T>.Create(const AValue: T): TNullable<T>;
begin
  Result.FValue    := AValue;
  Result.FHasValue := True;
end;

class function TNullable<T>.Empty: TNullable<T>;
begin
  Result.FHasValue := False;
  System.FillChar(Result.FValue, SizeOf(T), 0);
end;

function TNullable<T>.GetValue: T;
begin
  if not FHasValue then
    raise EInvalidOpException.Create('Nullable<T> não possui valor (HasValue = False)');
  Result := FValue;
end;

function TNullable<T>.OrElse(const ADefault: T): T;
begin
  if FHasValue then Result := FValue
  else              Result := ADefault;
end;

function TNullable<T>.OrElseGet(AFunc: TFunc<T>): T;
begin
  if FHasValue then Result := FValue
  else              Result := AFunc();
end;

procedure TNullable<T>.IfHasValue(AAction: TProc<T>);
begin
  if FHasValue then AAction(FValue);
end;

function TNullable<T>.Map<R>(AFunc: TFunc<T, R>): TNullable<R>;
begin
  if FHasValue then Result := TNullable<R>.Create(AFunc(FValue))
  else              Result := TNullable<R>.Empty;
end;

function TNullable<T>.Filter(APred: TFunc<T, Boolean>): TNullable<T>;
begin
  if FHasValue and APred(FValue) then Result := Self
  else                                Result := TNullable<T>.Empty;
end;

class operator TNullable<T>.Implicit(const AValue: T): TNullable<T>;
begin
  Result := TNullable<T>.Create(AValue);
end;

class operator TNullable<T>.Implicit(const ANullable: TNullable<T>): T;
begin
  Result := ANullable.Value; // levanta se !HasValue
end;

class operator TNullable<T>.Equal(const A, B: TNullable<T>): Boolean;
begin
  if A.FHasValue <> B.FHasValue then Exit(False);
  if not A.FHasValue then Exit(True); // ambos vazios
  // Comparação simples via CompareMem — funciona para tipos primitivos/records sem ponteiros
  Result := CompareMem(@A.FValue, @B.FValue, SizeOf(T));
end;

function TNullable<T>.ToString: string;
begin
  if FHasValue then
    Result := TValue.From<T>(FValue).ToString
  else
    Result := 'NULL';
end;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function NullableInt(AValue: Integer): TNullableInt;
begin Result := TNullableInt.Create(AValue); end;

function NullableStr(const AValue: string): TNullableStr;
begin Result := TNullableStr.Create(AValue); end;

function NullableDouble(AValue: Double): TNullableDouble;
begin Result := TNullableDouble.Create(AValue); end;

function NullableBool(AValue: Boolean): TNullableBool;
begin Result := TNullableBool.Create(AValue); end;

// ---------------------------------------------------------------------------
// USO:
//
//   // Criar com valor
//   var Nome: TNullableStr := NullableStr('Maria');
//   Writeln(Nome.HasValue);         // True
//   Writeln(Nome.Value);            // Maria
//   Writeln(Nome.OrElse('Anônimo')); // Maria
//
//   // Criar vazio
//   var Idade: TNullableInt := TNullableInt.Empty;
//   Writeln(Idade.HasValue);           // False
//   Writeln(Idade.OrElse(0));          // 0
//   Writeln(Idade.ToString);           // NULL
//
//   // Operador implícito
//   var N: TNullableInt := 42;    // Implicit(Integer) → TNullable
//   var V: Integer      := N;     // Implicit(TNullable) → Integer
//
//   // Map: transforma se HasValue, propaga vazio se não
//   var NomeUpper := Nome.Map<string>(
//     function(S: string): string begin Result := S.ToUpper; end);
//   Writeln(NomeUpper.OrElse(''));  // MARIA
//
//   // Filter: anula se predicado falhar
//   var IdadeMaior := Idade.Filter(
//     function(N: Integer): Boolean begin Result := N >= 18; end);
//   // Idade.HasValue = False → IdadeMaior.HasValue = False (propagou)
//
//   // IfHasValue: executar só se tiver valor
//   Nome.IfHasValue(procedure(S: string) begin Writeln('Olá, ', S); end);
//
//   // Uso em records de domínio (campos opcionais)
//   type
//     TFuncionario = record
//       Nome      : string;
//       Salario   : Double;
//       DataDemis : TNullableDateTime; // NULL = ainda ativo
//     end;
// ---------------------------------------------------------------------------

end.

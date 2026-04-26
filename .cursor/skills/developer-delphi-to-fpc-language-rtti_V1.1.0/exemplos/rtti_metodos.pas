unit rtti_metodos;
{
  RTTI — TRttiMethod: Invoke com array of TValue
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Rtti;

// ---------------------------------------------------------------------------
// Classe de serviço para demonstração de invocação via RTTI
// ---------------------------------------------------------------------------
type
  TCalculadora = class
  public
    function Somar(A, B: Integer): Integer;
    function Multiplicar(A, B: Double): Double;
    procedure ExibirMensagem(const AMsg: string);
    function Fatorial(N: Integer): Integer;
    class function Versao: string;
  end;

// ---------------------------------------------------------------------------
// Utilitários de invocação via RTTI
// ---------------------------------------------------------------------------

// Invocar método de instância por nome
function InvocarMetodo(AInstance: TObject; const ANomeMetodo: string;
  const AParams: array of TValue): TValue;

// Invocar método de classe (static) por nome
function InvocarMetodoClasse(AClass: TClass; const ANomeMetodo: string;
  const AParams: array of TValue): TValue;

// Verificar se método existe
function MetodoExiste(AInstance: TObject; const ANomeMetodo: string): Boolean;

// Listar todos os métodos públicos com assinaturas
procedure ListarMetodosPublicos(AClass: TClass);

implementation

// ---------------------------------------------------------------------------
// TCalculadora
// ---------------------------------------------------------------------------

function TCalculadora.Somar(A, B: Integer): Integer;
begin Result := A + B; end;

function TCalculadora.Multiplicar(A, B: Double): Double;
begin Result := A * B; end;

procedure TCalculadora.ExibirMensagem(const AMsg: string);
begin Writeln('MSG: ', AMsg); end;

function TCalculadora.Fatorial(N: Integer): Integer;
begin
  if N <= 1 then Result := 1
  else Result := N * Fatorial(N - 1);
end;

class function TCalculadora.Versao: string;
begin Result := '1.0.0'; end;

// ---------------------------------------------------------------------------
// InvocarMetodo
// ---------------------------------------------------------------------------

function InvocarMetodo(AInstance: TObject; const ANomeMetodo: string;
  const AParams: array of TValue): TValue;
var
  Ctx    : TRttiContext;
  Tipo   : TRttiType;
  Metodo : TRttiMethod;
  Params : TArray<TValue>;
  I      : Integer;
begin
  Ctx := TRttiContext.Create;
  try
    Tipo   := Ctx.GetType(AInstance.ClassType);
    Metodo := Tipo.GetMethod(ANomeMetodo);
    if Metodo = nil then
      raise EArgumentException.CreateFmt('Método "%s" não encontrado em %s',
        [ANomeMetodo, Tipo.Name]);

    // Copiar array of const para TArray<TValue>
    SetLength(Params, Length(AParams));
    for I := 0 to High(AParams) do
      Params[I] := AParams[I];

    Result := Metodo.Invoke(AInstance, Params);
  finally
    Ctx.Free;
  end;
end;

// ---------------------------------------------------------------------------
// InvocarMetodoClasse
// ---------------------------------------------------------------------------

function InvocarMetodoClasse(AClass: TClass; const ANomeMetodo: string;
  const AParams: array of TValue): TValue;
var
  Ctx    : TRttiContext;
  Tipo   : TRttiType;
  Metodo : TRttiMethod;
  Params : TArray<TValue>;
  I      : Integer;
begin
  Ctx := TRttiContext.Create;
  try
    Tipo   := Ctx.GetType(AClass);
    Metodo := Tipo.GetMethod(ANomeMetodo);
    if Metodo = nil then
      raise EArgumentException.CreateFmt('Método de classe "%s" não encontrado', [ANomeMetodo]);
    if not Metodo.IsClassMethod then
      raise EInvalidOpException.CreateFmt('"%s" não é método de classe', [ANomeMetodo]);

    SetLength(Params, Length(AParams));
    for I := 0 to High(AParams) do
      Params[I] := AParams[I];

    Result := Metodo.Invoke(AClass, Params);
  finally
    Ctx.Free;
  end;
end;

// ---------------------------------------------------------------------------
// MetodoExiste
// ---------------------------------------------------------------------------

function MetodoExiste(AInstance: TObject; const ANomeMetodo: string): Boolean;
var
  Ctx  : TRttiContext;
  Tipo : TRttiType;
begin
  Ctx := TRttiContext.Create;
  try
    Tipo   := Ctx.GetType(AInstance.ClassType);
    Result := Tipo.GetMethod(ANomeMetodo) <> nil;
  finally
    Ctx.Free;
  end;
end;

// ---------------------------------------------------------------------------
// ListarMetodosPublicos
// ---------------------------------------------------------------------------

procedure ListarMetodosPublicos(AClass: TClass);
var
  Ctx    : TRttiContext;
  Tipo   : TRttiType;
  Metodo : TRttiMethod;
  Params : TArray<TRttiParameter>;
  Param  : TRttiParameter;
  ParStr : string;
  RetStr : string;
begin
  Ctx := TRttiContext.Create;
  try
    Tipo := Ctx.GetType(AClass);
    Writeln('=== Métodos públicos de ', Tipo.Name, ' ===');
    for Metodo in Tipo.GetMethods do
    begin
      if Metodo.Visibility < mvPublic then Continue;
      Params := Metodo.GetParameters;
      ParStr := '';
      for Param in Params do
      begin
        if ParStr <> '' then ParStr := ParStr + '; ';
        ParStr := ParStr + Param.Name + ': ' + Param.ParamType.Name;
      end;
      if Metodo.ReturnType <> nil then
        RetStr := ': ' + Metodo.ReturnType.Name
      else
        RetStr := '';
      if Metodo.IsClassMethod then
        Writeln(Format('  [class] %s(%s)%s', [Metodo.Name, ParStr, RetStr]))
      else
        Writeln(Format('  %s(%s)%s', [Metodo.Name, ParStr, RetStr]));
    end;
  finally
    Ctx.Free;
  end;
end;

// ---------------------------------------------------------------------------
// USO:
//   var Calc := TCalculadora.Create;
//
//   // Invocar Somar(10, 5)
//   var Res := InvocarMetodo(Calc, 'Somar',
//     [TValue.From<Integer>(10), TValue.From<Integer>(5)]);
//   Writeln(Res.AsInteger);  // 15
//
//   // Invocar Multiplicar(3.0, 4.0)
//   var ResD := InvocarMetodo(Calc, 'Multiplicar',
//     [TValue.From<Double>(3.0), TValue.From<Double>(4.0)]);
//   Writeln(ResD.AsExtended:0:2);  // 12.00
//
//   // Invocar ExibirMensagem
//   InvocarMetodo(Calc, 'ExibirMensagem',
//     [TValue.From<string>('Olá via RTTI!')]);
//
//   // Método de classe
//   var Ver := InvocarMetodoClasse(TCalculadora, 'Versao', []);
//   Writeln(Ver.AsString);  // 1.0.0
//
//   // Listar métodos
//   ListarMetodosPublicos(TCalculadora);
//   Calc.Free;
// ---------------------------------------------------------------------------

end.

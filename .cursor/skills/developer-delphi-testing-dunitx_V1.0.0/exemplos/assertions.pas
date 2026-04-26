unit assertions;
///  Demonstra todos os metodos Assert.* do DUnitX com exemplos praticos.
///  Compilavel como unit de projeto DUnitX.

interface

uses
  System.SysUtils,
  System.Classes,
  DUnitX.TestFramework;

type
  EExcecaoCustom = class(Exception);

  [TestFixture]
  [Category('Assertions')]
  TAssertionsDemo = class
  public
    // Igualdade e diferenca
    [Test] procedure Assert_AreEqual_Inteiros;
    [Test] procedure Assert_AreEqual_Strings;
    [Test] procedure Assert_AreEqual_ComMensagem;
    [Test] procedure Assert_AreNotEqual;

    // Booleano
    [Test] procedure Assert_IsTrue;
    [Test] procedure Assert_IsFalse;

    // Nulidade
    [Test] procedure Assert_IsNull;
    [Test] procedure Assert_IsNotNull;

    // Ponto flutuante (com tolerancia)
    [Test] procedure Assert_AreEqual_Double_ComTolerance;

    // Strings
    [Test] procedure Assert_Contains;
    [Test] procedure Assert_StartsWith;
    [Test] procedure Assert_EndsWith;

    // Excecoes
    [Test] procedure Assert_WillRaise;
    [Test] procedure Assert_WillNotRaise;

    // Tipos e heranca
    [Test] procedure Assert_InheritsFrom;
    [Test] procedure Assert_IsType;

    // Colecoes
    [Test] procedure Assert_IsEmpty;
    [Test] procedure Assert_IsNotEmpty;
  end;

implementation

// ---------------------------------------------------------------------------
// Igualdade e diferenca
// ---------------------------------------------------------------------------

procedure TAssertionsDemo.Assert_AreEqual_Inteiros;
begin
  Assert.AreEqual(42, 40 + 2);
  Assert.AreEqual(0, 0);
  Assert.AreEqual(-1, -1);
end;

procedure TAssertionsDemo.Assert_AreEqual_Strings;
begin
  Assert.AreEqual('Delphi', 'Del' + 'phi');
  Assert.AreEqual('', '');
end;

procedure TAssertionsDemo.Assert_AreEqual_ComMensagem;
begin
  var Calculado := 2 * 3;
  Assert.AreEqual(6, Calculado,
    Format('Esperado 6, obtido %d — verificar calculo', [Calculado]));
end;

procedure TAssertionsDemo.Assert_AreNotEqual;
begin
  Assert.AreNotEqual(1, 2);
  Assert.AreNotEqual('A', 'B');
end;

// ---------------------------------------------------------------------------
// Booleano
// ---------------------------------------------------------------------------

procedure TAssertionsDemo.Assert_IsTrue;
begin
  Assert.IsTrue(1 = 1);
  Assert.IsTrue(Length('Delphi') > 0);
  Assert.IsTrue(True, 'Condicao deve ser verdadeira');
end;

procedure TAssertionsDemo.Assert_IsFalse;
begin
  Assert.IsFalse(1 = 2);
  Assert.IsFalse(False, 'Condicao deve ser falsa');
end;

// ---------------------------------------------------------------------------
// Nulidade
// ---------------------------------------------------------------------------

procedure TAssertionsDemo.Assert_IsNull;
var
  Obj: TObject;
begin
  Obj := nil;
  Assert.IsNull(Obj, 'Objeto deve ser nil antes de criar');
end;

procedure TAssertionsDemo.Assert_IsNotNull;
var
  Obj: TObject;
begin
  Obj := TObject.Create;
  try
    Assert.IsNotNull(Obj, 'Objeto criado nao deve ser nil');
  finally
    Obj.Free;
  end;
end;

// ---------------------------------------------------------------------------
// Ponto flutuante com tolerancia
// ---------------------------------------------------------------------------

procedure TAssertionsDemo.Assert_AreEqual_Double_ComTolerance;
begin
  // Terceiro parametro e a tolerancia (epsilon)
  Assert.AreEqual(3.14159, 22.0 / 7.0, 0.002,
    'Aproximacao de pi deve estar dentro da tolerancia de 0.002');
end;

// ---------------------------------------------------------------------------
// Strings
// ---------------------------------------------------------------------------

procedure TAssertionsDemo.Assert_Contains;
begin
  Assert.Contains('Delphi', 'elph');
  Assert.Contains('Hello World', 'World');
end;

procedure TAssertionsDemo.Assert_StartsWith;
begin
  Assert.StartsWith('Delphi', 'Del');
  Assert.StartsWith('unit test', 'unit');
end;

procedure TAssertionsDemo.Assert_EndsWith;
begin
  Assert.EndsWith('Delphi', 'phi');
  Assert.EndsWith('unit test', 'test');
end;

// ---------------------------------------------------------------------------
// Excecoes
// ---------------------------------------------------------------------------

procedure TAssertionsDemo.Assert_WillRaise;
begin
  // Verifica que o bloco lanca a excecao esperada
  Assert.WillRaise(
    procedure
    begin
      raise EExcecaoCustom.Create('erro simulado');
    end,
    EExcecaoCustom,
    'Deve lancar EExcecaoCustom');
end;

procedure TAssertionsDemo.Assert_WillNotRaise;
begin
  // Verifica que o bloco NAO lanca excecao
  Assert.WillNotRaise(
    procedure
    var
      S: TStringList;
    begin
      S := TStringList.Create;
      try
        S.Add('item');
      finally
        S.Free;
      end;
    end,
    'Operacao segura nao deve lancar excecao');
end;

// ---------------------------------------------------------------------------
// Tipos e heranca
// ---------------------------------------------------------------------------

procedure TAssertionsDemo.Assert_InheritsFrom;
begin
  // Verifica que TStringList herda de TStrings
  Assert.InheritsFrom(TStrings, TStringList,
    'TStringList deve herdar de TStrings');
end;

procedure TAssertionsDemo.Assert_IsType;
var
  Obj: TObject;
begin
  Obj := TStringList.Create;
  try
    Assert.IsType<TStringList>(Obj,
      'Objeto deve ser do tipo TStringList');
  finally
    Obj.Free;
  end;
end;

// ---------------------------------------------------------------------------
// Colecoes
// ---------------------------------------------------------------------------

procedure TAssertionsDemo.Assert_IsEmpty;
var
  Lista: TStringList;
begin
  Lista := TStringList.Create;
  try
    Assert.IsEmpty(Lista, 'Lista recem criada deve estar vazia');
  finally
    Lista.Free;
  end;
end;

procedure TAssertionsDemo.Assert_IsNotEmpty;
var
  Lista: TStringList;
begin
  Lista := TStringList.Create;
  try
    Lista.Add('item');
    Assert.IsNotEmpty(Lista, 'Lista com um item nao deve ser vazia');
  finally
    Lista.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TAssertionsDemo);

end.

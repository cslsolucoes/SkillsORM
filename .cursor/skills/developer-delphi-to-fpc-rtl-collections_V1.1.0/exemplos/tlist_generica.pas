unit tlist_generica;
{
  TList<T> — Add, Remove, Find, Sort, ForEach
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections, System.Generics.Defaults;

// ---------------------------------------------------------------------------
// Tipo de domínio
// ---------------------------------------------------------------------------
type
  TProduto = class
  public
    Id:    Integer;
    Nome:  string;
    Preco: Currency;
    Estoque: Integer;
    constructor Create(AId: Integer; const ANome: string;
      APreco: Currency; AEstoque: Integer = 0);
    function ToString: string; override;
  end;

// ---------------------------------------------------------------------------
// Exemplos de uso de TList<T>
// ---------------------------------------------------------------------------
procedure DemoListaBasica;
procedure DemoSortCustom;
procedure DemoBusca;
procedure DemoTransformacao;

implementation

// ---------------------------------------------------------------------------
// TProduto
// ---------------------------------------------------------------------------

constructor TProduto.Create(AId: Integer; const ANome: string;
  APreco: Currency; AEstoque: Integer);
begin
  inherited Create;
  Id := AId; Nome := ANome; Preco := APreco; Estoque := AEstoque;
end;

function TProduto.ToString: string;
begin
  Result := Format('[%d] %s R$%.2f estq=%d', [Id, Nome, Preco, Estoque]);
end;

// ---------------------------------------------------------------------------
// DemoListaBasica
// ---------------------------------------------------------------------------

procedure DemoListaBasica;
var Lista: TList<TProduto>;
    P: TProduto;
begin
  Lista := TList<TProduto>.Create;
  try
    // Adicionar
    Lista.Add(TProduto.Create(1, 'Caneta', 2.50, 100));
    Lista.Add(TProduto.Create(2, 'Caderno', 15.90, 50));
    Lista.Add(TProduto.Create(3, 'Borracha', 1.20, 200));
    Lista.Add(TProduto.Create(4, 'Lápis', 0.90, 150));

    Writeln('--- Lista básica (', Lista.Count, ' itens) ---');
    for P in Lista do Writeln(P.ToString);

    // Remover por índice
    Lista[1].Free;        // liberar o objeto antes de remover
    Lista.Delete(1);      // remover da lista
    Writeln('Após remover índice 1: ', Lista.Count, ' itens');

    // Remover por objeto
    var PBorracha: TProduto := nil;
    for P in Lista do
      if P.Nome = 'Borracha' then begin PBorracha := P; Break; end;
    if PBorracha <> nil then
    begin
      Lista.Remove(PBorracha);
      PBorracha.Free;
    end;
    Writeln('Após remover Borracha: ', Lista.Count, ' itens');

    // Insert em posição específica
    Lista.Insert(0, TProduto.Create(5, 'Régua', 3.50, 80));
    Writeln('Após Insert em 0: ', Lista[0].Nome);

    // Acessar por índice
    Writeln('Último: ', Lista.Last.Nome);
    Writeln('Primeiro: ', Lista.First.Nome);

    // Limpar liberando objetos
    for P in Lista do P.Free;
    Lista.Clear;
    Writeln('Após Clear: ', Lista.Count);
  finally
    Lista.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoSortCustom
// ---------------------------------------------------------------------------

procedure DemoSortCustom;
var Lista: TList<TProduto>;
    P: TProduto;
    CompPreco: IComparer<TProduto>;
    CompNome:  IComparer<TProduto>;
begin
  Lista := TList<TProduto>.Create;
  try
    Lista.Add(TProduto.Create(1, 'Zebra',  10.00));
    Lista.Add(TProduto.Create(2, 'Abacaxi', 5.00));
    Lista.Add(TProduto.Create(3, 'Mango',  15.00));
    Lista.Add(TProduto.Create(4, 'Banana',  3.50));

    // Ordenar por preço crescente
    CompPreco := TComparer<TProduto>.Construct(
      function(const A, B: TProduto): Integer
      begin
        if A.Preco < B.Preco then Result := -1
        else if A.Preco > B.Preco then Result := 1
        else Result := 0;
      end);
    Lista.Sort(CompPreco);
    Write('Por preço: ');
    for P in Lista do Write(P.Nome, '(', P.Preco:0:2, ') ');
    Writeln;

    // Ordenar por nome decrescente
    CompNome := TComparer<TProduto>.Construct(
      function(const A, B: TProduto): Integer
      begin Result := -CompareStr(A.Nome, B.Nome); end);  // negativo = decrescente
    Lista.Sort(CompNome);
    Write('Por nome desc: ');
    for P in Lista do Write(P.Nome, ' ');
    Writeln;

    for P in Lista do P.Free;
  finally
    Lista.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoBusca
// ---------------------------------------------------------------------------

procedure DemoBusca;
var Lista: TList<TProduto>;
    P, Encontrado: TProduto;
begin
  Lista := TList<TProduto>.Create;
  try
    Lista.Add(TProduto.Create(1, 'Mouse', 89.90));
    Lista.Add(TProduto.Create(2, 'Teclado', 149.90));
    Lista.Add(TProduto.Create(3, 'Monitor', 899.00));

    // Busca com predicate (FindAll retorna nova lista)
    Writeln('--- Busca ---');

    // IndexOf por predicado (manual)
    Encontrado := nil;
    for P in Lista do
      if P.Nome = 'Teclado' then begin Encontrado := P; Break; end;
    if Encontrado <> nil then
      Writeln('Encontrado: ', Encontrado.ToString);

    // ContainsKey equivalente — usar Contains com comparer
    var ContainsComp := TEqualityComparer<TProduto>.Construct(
      function(const A, B: TProduto): Boolean begin Result := A.Id = B.Id; end,
      function(const A: TProduto): Integer begin Result := A.Id; end);
    // TList não tem Contains com comparer diretamente — usar IndexOf com loop ou TDictionary

    // Filtrar com Where (manual — ou usar linq_style.pas)
    var Caros: TList<TProduto> := TList<TProduto>.Create;
    try
      for P in Lista do
        if P.Preco > 100 then Caros.Add(P);
      Write('Caros (>100): ');
      for P in Caros do Write(P.Nome, ' ');
      Writeln;
    finally Caros.Free; end;

    for P in Lista do P.Free;
  finally
    Lista.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoTransformacao
// ---------------------------------------------------------------------------

procedure DemoTransformacao;
var Numeros: TList<Integer>;
    Quadrados: TList<Integer>;
    N, Q: Integer;
    Total: Integer;
begin
  Numeros := TList<Integer>.Create;
  try
    for N := 1 to 10 do Numeros.Add(N);

    // Map: transformar cada elemento
    Quadrados := TList<Integer>.Create;
    try
      for N in Numeros do Quadrados.Add(N * N);
      Write('Quadrados: ');
      for Q in Quadrados do Write(Q, ' ');
      Writeln;
    finally Quadrados.Free; end;

    // Reduce: acumular
    Total := 0;
    for N in Numeros do Inc(Total, N);
    Writeln('Soma 1..10 = ', Total);

    // ForEach com ação lateral
    Write('Ímpares: ');
    for N in Numeros do
      if Odd(N) then Write(N, ' ');
    Writeln;

    // TList<Integer> de inteiros (value type — sem Free individual)
  finally
    Numeros.Free;
  end;
end;

// ---------------------------------------------------------------------------
// USO:
//   DemoListaBasica;
//   DemoSortCustom;
//   DemoBusca;
//   DemoTransformacao;
// ---------------------------------------------------------------------------

end.

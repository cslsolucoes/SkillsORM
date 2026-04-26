unit tsortedlist;
{
  TSortedList<T> — sempre ordenada, busca binária, TComparer customizado
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections, System.Generics.Defaults;

procedure DemoSortedListInteiros;
procedure DemoSortedListStrings;
procedure DemoSortedListCustom;
procedure DemoSortedListBuscaBinaria;
procedure DemoSortedListProdutos;

implementation

// ---------------------------------------------------------------------------
// DemoSortedListInteiros — inserção automática em ordem crescente
// ---------------------------------------------------------------------------

procedure DemoSortedListInteiros;
var SL: TSortedList<Integer, string>;
    I: Integer;
begin
  // TSortedList<TKey, TValue> — chave define a ordem
  SL := TSortedList<Integer, string>.Create;
  try
    // Inserir fora de ordem — a lista mantém ordenação por chave
    SL.Add(30, 'trinta');
    SL.Add(10, 'dez');
    SL.Add(50, 'cinquenta');
    SL.Add(20, 'vinte');
    SL.Add(40, 'quarenta');

    Writeln('--- Ordenado por chave ---');
    for I := 0 to SL.Count - 1 do
      Writeln(SL.Keys[I], ' → ', SL.Values[I]);
    // Saída: 10, 20, 30, 40, 50

    // Acesso por chave
    Writeln('SL[30] = ', SL[30]);

    // ContainsKey / ContainsValue
    Writeln('ContainsKey(20): ', SL.ContainsKey(20));
    Writeln('ContainsValue(''dez''): ', SL.ContainsValue('dez'));

    // IndexOfKey — posição na lista ordenada
    Writeln('IndexOfKey(30): ', SL.IndexOfKey(30));  // 2

    // Remover
    SL.Remove(20);
    Writeln('Após Remove(20), Count=', SL.Count);
  finally
    SL.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoSortedListStrings — ordem lexicográfica por padrão
// ---------------------------------------------------------------------------

procedure DemoSortedListStrings;
var SL: TSortedList<string, Integer>;
    Pair: TPair<string, Integer>;
begin
  SL := TSortedList<string, Integer>.Create;
  try
    SL.Add('banana',    3);
    SL.Add('abacaxi',   7);
    SL.Add('cereja',    2);
    SL.Add('damasco',   5);
    SL.Add('amora',     9);

    Writeln('--- Ordenado alfabeticamente ---');
    for Pair in SL do
      Writeln(Pair.Key, ': ', Pair.Value);
    // abacaxi, amora, banana, cereja, damasco

    // TryGetValue
    var V: Integer;
    if SL.TryGetValue('banana', V) then
      Writeln('banana qty: ', V);
  finally
    SL.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoSortedListCustom — comparer personalizado (ordem decrescente)
// ---------------------------------------------------------------------------

procedure DemoSortedListCustom;
var Comp: IComparer<Integer>;
    SL:   TSortedList<Integer, string>;
    I:    Integer;
begin
  // Comparer decrescente
  Comp := TComparer<Integer>.Construct(
    function(const A, B: Integer): Integer
    begin Result := B - A; end);  // invertido

  SL := TSortedList<Integer, string>.Create(Comp);
  try
    SL.Add(10, 'dez');
    SL.Add(50, 'cinquenta');
    SL.Add(30, 'trinta');
    SL.Add(20, 'vinte');

    Writeln('--- Decrescente ---');
    for I := 0 to SL.Count - 1 do
      Writeln(SL.Keys[I], ': ', SL.Values[I]);
    // 50, 30, 20, 10
  finally
    SL.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoSortedListBuscaBinaria — IndexOfKey é O(log n)
// ---------------------------------------------------------------------------

procedure DemoSortedListBuscaBinaria;
var SL: TSortedList<Integer, string>;
    I, N: Integer;
begin
  SL := TSortedList<Integer, string>.Create;
  try
    // Popular com 1000 entradas
    for N := 1 to 1000 do
      SL.Add(N, 'item' + N.ToString);

    Writeln('Count: ', SL.Count);

    // IndexOfKey usa busca binária — O(log n)
    I := SL.IndexOfKey(500);
    Writeln('IndexOfKey(500): ', I);   // 499

    I := SL.IndexOfKey(1);
    Writeln('IndexOfKey(1): ', I);     // 0

    I := SL.IndexOfKey(1000);
    Writeln('IndexOfKey(1000): ', I);  // 999

    // Chave inexistente retorna -1
    I := SL.IndexOfKey(9999);
    Writeln('IndexOfKey(9999): ', I);  // -1

    // Keys/Values são acessíveis por índice
    Writeln('Keys[0]=', SL.Keys[0], '  Keys[999]=', SL.Keys[999]);
  finally
    SL.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoSortedListProdutos — chave record + comparer por prioridade
// ---------------------------------------------------------------------------

type
  TChaveProduto = record
    Prioridade: Integer;
    Nome:       string;
  end;

  TProdutoInfo = record
    Estoque: Integer;
    Preco:   Currency;
  end;

procedure DemoSortedListProdutos;
var Comp: IComparer<TChaveProduto>;
    SL:   TSortedList<TChaveProduto, TProdutoInfo>;
    I:    Integer;
    K:    TChaveProduto;
    V:    TProdutoInfo;
begin
  // Comparer: menor prioridade primeiro; se igual, alfabético
  Comp := TComparer<TChaveProduto>.Construct(
    function(const A, B: TChaveProduto): Integer
    begin
      Result := A.Prioridade - B.Prioridade;
      if Result = 0 then
        Result := CompareStr(A.Nome, B.Nome);
    end);

  SL := TSortedList<TChaveProduto, TProdutoInfo>.Create(Comp);
  try
    K.Prioridade := 2; K.Nome := 'Caneta';
    V.Estoque := 100; V.Preco := 2.50;
    SL.Add(K, V);

    K.Prioridade := 1; K.Nome := 'Monitor';
    V.Estoque := 5; V.Preco := 899.00;
    SL.Add(K, V);

    K.Prioridade := 1; K.Nome := 'Teclado';
    V.Estoque := 20; V.Preco := 149.90;
    SL.Add(K, V);

    K.Prioridade := 3; K.Nome := 'Borracha';
    V.Estoque := 500; V.Preco := 0.90;
    SL.Add(K, V);

    Writeln('--- Produtos por prioridade+nome ---');
    for I := 0 to SL.Count - 1 do
    begin
      K := SL.Keys[I];
      V := SL.Values[I];
      Writeln(Format('[P%d] %-12s estq=%-4d R$%.2f',
        [K.Prioridade, K.Nome, V.Estoque, V.Preco]));
    end;
    // [P1] Monitor    ...
    // [P1] Teclado    ...
    // [P2] Caneta     ...
    // [P3] Borracha   ...
  finally
    SL.Free;
  end;
end;

// ---------------------------------------------------------------------------
// USO:
//   DemoSortedListInteiros;
//   DemoSortedListStrings;
//   DemoSortedListCustom;
//   DemoSortedListBuscaBinaria;
//   DemoSortedListProdutos;
// ---------------------------------------------------------------------------

end.

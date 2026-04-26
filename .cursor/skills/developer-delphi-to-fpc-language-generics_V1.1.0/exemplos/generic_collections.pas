unit generic_collections;
{
  Generics — TList<T>, TDictionary<K,V>, TQueue<T>, TStack<T>, TObjectList<T>
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections, System.Generics.Defaults;

// ---------------------------------------------------------------------------
// Exemplos práticos com TList<T>
// ---------------------------------------------------------------------------
procedure ExemploTList;

// ---------------------------------------------------------------------------
// Exemplos práticos com TDictionary<K,V>
// ---------------------------------------------------------------------------
procedure ExemploTDictionary;

// ---------------------------------------------------------------------------
// Exemplos práticos com TQueue<T> e TStack<T>
// ---------------------------------------------------------------------------
procedure ExemploQueueStack;

// ---------------------------------------------------------------------------
// TObjectList<T> — lista que OWNS os objetos
// ---------------------------------------------------------------------------
type
  TProduto = class
  public
    Nome : string;
    Preco: Double;
    constructor Create(const ANome: string; APreco: Double);
  end;

procedure ExemploTObjectList;

// ---------------------------------------------------------------------------
// TSortedDictionary via TDictionary + manual sort
// ---------------------------------------------------------------------------
procedure ExemploOrdenacaoCustom;

implementation

// ---------------------------------------------------------------------------
// TProduto
// ---------------------------------------------------------------------------

constructor TProduto.Create(const ANome: string; APreco: Double);
begin
  inherited Create;
  Nome  := ANome;
  Preco := APreco;
end;

// ---------------------------------------------------------------------------
// TList<T>
// ---------------------------------------------------------------------------

procedure ExemploTList;
var
  Lista  : TList<Integer>;
  Sorted : TList<string>;
begin
  // --- Inteiros ---
  Lista := TList<Integer>.Create;
  try
    Lista.Add(10); Lista.Add(30); Lista.Add(20);
    Lista.Sort;   // ordena com comparer padrão
    Writeln('TList<Integer> ordenada:');
    for var N in Lista do Write(N, ' ');  // 10 20 30
    Writeln;

    Lista.Insert(1, 15);  // insere 15 na posição 1
    Writeln('Após Insert(1,15): ', Lista[0],' ',Lista[1],' ',Lista[2],' ',Lista[3]);

    Writeln('Contains(30): ', Lista.Contains(30));
    Writeln('IndexOf(30): ',  Lista.IndexOf(30));
    Lista.Remove(30);
    Writeln('Após Remove(30) Count: ', Lista.Count);  // 3
  finally
    Lista.Free;
  end;

  // --- Strings com comparer case-insensitive ---
  Sorted := TList<string>.Create(
    TComparer<string>.Construct(
      function(const L, R: string): Integer
      begin
        Result := CompareText(L, R);
      end));
  try
    Sorted.Add('Zebra'); Sorted.Add('Abelha'); Sorted.Add('Mango');
    Sorted.Sort;
    Writeln('TList<string> case-insensitive:');
    for var S in Sorted do Write(S, ' ');  // Abelha Mango Zebra
    Writeln;
  finally
    Sorted.Free;
  end;
end;

// ---------------------------------------------------------------------------
// TDictionary<K,V>
// ---------------------------------------------------------------------------

procedure ExemploTDictionary;
var
  Dict  : TDictionary<string, Integer>;
  Valor : Integer;
  Par   : TPair<string, Integer>;
begin
  Dict := TDictionary<string, Integer>.Create;
  try
    // Adicionar
    Dict.Add('Alpha', 1);
    Dict.Add('Beta',  2);
    Dict.Add('Gamma', 3);
    Dict.AddOrSetValue('Alpha', 10);  // atualiza sem exceção

    // Ler — dois modos
    Writeln('Alpha = ', Dict['Alpha']);              // 10
    if Dict.TryGetValue('Beta', Valor) then
      Writeln('Beta = ', Valor);                     // 2

    Writeln('ContainsKey Delta: ', Dict.ContainsKey('Delta'));  // False
    Writeln('ContainsValue 3: ',   Dict.ContainsValue(3));      // True

    // Iterar — ordem NÃO garantida em TDictionary
    Writeln('Todos os pares:');
    for Par in Dict do
      Writeln('  ', Par.Key, ' -> ', Par.Value);

    // Remover
    Dict.Remove('Gamma');
    Writeln('Após Remove(Gamma) Count: ', Dict.Count);  // 2

    // Iterar só chaves / só valores
    Writeln('Chaves: ');
    for var K in Dict.Keys do Write(K, ' ');
    Writeln;
    Writeln('Valores: ');
    for var V in Dict.Values do Write(V, ' ');
    Writeln;
  finally
    Dict.Free;
  end;
end;

// ---------------------------------------------------------------------------
// TQueue<T> e TStack<T>
// ---------------------------------------------------------------------------

procedure ExemploQueueStack;
var
  Fila  : TQueue<string>;
  Pilha : TStack<Integer>;
begin
  // --- FIFO ---
  Fila := TQueue<string>.Create;
  try
    Fila.Enqueue('A'); Fila.Enqueue('B'); Fila.Enqueue('C');
    Writeln('TQueue (FIFO): ');
    while Fila.Count > 0 do
      Write(Fila.Dequeue, ' ');  // A B C
    Writeln;
    // Peek — ver próximo sem remover
    Fila.Enqueue('X'); Fila.Enqueue('Y');
    Writeln('Peek: ', Fila.Peek);  // X (não remove)
    Writeln('Count após Peek: ', Fila.Count);  // 2
  finally
    Fila.Free;
  end;

  // --- LIFO ---
  Pilha := TStack<Integer>.Create;
  try
    Pilha.Push(1); Pilha.Push(2); Pilha.Push(3);
    Writeln('TStack (LIFO): ');
    while Pilha.Count > 0 do
      Write(Pilha.Pop, ' ');  // 3 2 1
    Writeln;
  finally
    Pilha.Free;
  end;
end;

// ---------------------------------------------------------------------------
// TObjectList<T> — gerencia ciclo de vida dos objetos
// ---------------------------------------------------------------------------

procedure ExemploTObjectList;
var
  Produtos: TObjectList<TProduto>;
  P       : TProduto;
begin
  // OwnsObjects = True (padrão) → .Free em cada objeto ao remover/destruir
  Produtos := TObjectList<TProduto>.Create(True);
  try
    Produtos.Add(TProduto.Create('Maçã',   2.50));
    Produtos.Add(TProduto.Create('Banana', 1.20));
    Produtos.Add(TProduto.Create('Uva',    5.90));

    // Ordenar por preço (comparer inline)
    Produtos.Sort(TComparer<TProduto>.Construct(
      function(const A, B: TProduto): Integer
      begin
        if A.Preco < B.Preco then Result := -1
        else if A.Preco > B.Preco then Result := 1
        else Result := 0;
      end));

    Writeln('Produtos por preço:');
    for P in Produtos do
      Writeln(Format('  %s: R$ %.2f', [P.Nome, P.Preco]));

    // Buscar com TEnumerable.Where não existe nativo; usa loop:
    var MaisCaros: TList<TProduto> := TList<TProduto>.Create;
    try
      for P in Produtos do
        if P.Preco > 2.0 then MaisCaros.Add(P);
      Writeln('Mais caros que R$2,00:');
      for P in MaisCaros do Writeln('  ', P.Nome);
    finally
      MaisCaros.Free; // não owns — não libera os objetos
    end;
  finally
    Produtos.Free; // libera todos os TProduto automaticamente
  end;
end;

// ---------------------------------------------------------------------------
// Ordenação customizada com comparer externo
// ---------------------------------------------------------------------------

procedure ExemploOrdenacaoCustom;
var
  Nomes: TArray<string>;
  Cmp  : IComparer<string>;
begin
  Nomes := TArray<string>.Create('banana', 'Maçã', 'UVAS', 'abacaxi');

  // Comparer por comprimento do nome
  Cmp := TComparer<string>.Construct(
    function(const A, B: string): Integer
    begin
      Result := Length(A) - Length(B);
    end);

  TArray.Sort<string>(Nomes, Cmp);

  Writeln('Ordenados por comprimento:');
  for var S in Nomes do Write(S, ' ');  // Maçã UVAS banana abacaxi
  Writeln;
end;

// ---------------------------------------------------------------------------
// USO: chamar qualquer procedure acima diretamente ou em um begin..end.
//   ExemploTList;
//   ExemploTDictionary;
//   ExemploQueueStack;
//   ExemploTObjectList;
//   ExemploOrdenacaoCustom;
// ---------------------------------------------------------------------------

end.

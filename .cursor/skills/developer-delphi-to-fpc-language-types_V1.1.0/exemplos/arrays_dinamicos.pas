unit arrays_dinamicos;
{
  EXEMPLO: Arrays dinamicos em Delphi — TArray<T>, SetLength, Copy
  Compilavel: dcc32 / dcc64
  Demonstra:
    - Dynamic array: declaracao, SetLength, acesso
    - TArray<T>: alias moderno e preferido
    - Copy: copiar fatia
    - Insert, Delete, Append (via SetLength + atribuicao)
    - Ordenacao com TArray.Sort<T>
    - Array de records e interfaces
    - Multidimensional dinamico
}

interface

uses
  System.SysUtils, System.Generics.Collections,
  System.Generics.Defaults;

procedure DemonstrarBasico;
procedure DemonstrarCopiaFatia;
procedure DemonstrarInsertDelete;
procedure DemonstrarOrdenacao;
procedure DemonstrarMultidimensional;

implementation

procedure DemonstrarBasico;
var
  A: array of Integer;     // dynamic array classico
  B: TArray<Integer>;      // alias moderno — preferido
  I: Integer;
begin
  // Alocar
  SetLength(A, 5);           // 5 elementos, inicializados com 0
  SetLength(B, 5);

  // Preencher
  for I := 0 to High(A) do
    A[I] := I * 10;          // 0, 10, 20, 30, 40

  // TArray<T> e identico internamente — prefira para APIs genericas
  B := TArray<Integer>.Create(1, 2, 3, 4, 5); // construtor inline

  // Tamanho
  Writeln('Length(A) = ', Length(A)); // 5
  Writeln('High(A)   = ', High(A));   // 4 (ultimo indice)
  Writeln('Low(A)    = ', Low(A));    // sempre 0 em dynamic arrays

  // Redimensionar (preserva conteudo ate o novo tamanho)
  SetLength(A, 8);  // 5 -> 8: os 3 novos elementos sao 0
  SetLength(A, 3);  // 8 -> 3: elementos 3..7 sao descartados

  // Limpar
  SetLength(A, 0); // ou: A := nil;
  Writeln('Apos limpar: Length = ', Length(A)); // 0
  Writeln('Nil? ', A = nil); // True
end;

procedure DemonstrarCopiaFatia;
var
  Orig, Copia, Fatia: TArray<Integer>;
begin
  Orig := TArray<Integer>.Create(10, 20, 30, 40, 50);

  // Copia completa (Copy sem parametros de indice)
  Copia := Copy(Orig);            // copia profunda dos elementos
  Copia[0] := 999;                // nao afeta Orig

  // Fatia: a partir do indice 1, 3 elementos
  Fatia := Copy(Orig, 1, 3);     // [20, 30, 40]
  Writeln(Fatia[0]); // 20

  // Atencao: Copy e uma copia de VALORES
  // Para arrays de tipos de referencia (classes), copia apenas o ponteiro
  var Objs: TArray<TObject>;
  SetLength(Objs, 3);
  Objs[0] := TObject.Create;
  var ObjosCopia := Copy(Objs);
  // ObjosCopia[0] e o mesmo objeto que Objs[0]! Nao e deep copy.
  Objs[0].Free; // libera o objeto — ObjosCopia[0] agora e dangling pointer!
end;

procedure DemonstrarInsertDelete;
var
  A: TArray<Integer>;
  I: Integer;
begin
  A := TArray<Integer>.Create(1, 2, 3, 4, 5);

  // Inserir no indice 2 (deslocar elementos para a direita)
  Insert(99, A, 2);
  // A = [1, 2, 99, 3, 4, 5]

  // Remover elemento do indice 2
  Delete(A, 2, 1); // a partir do indice 2, remover 1 elemento
  // A = [1, 2, 3, 4, 5]

  // Append (adicionar ao final)
  SetLength(A, Length(A) + 1);
  A[High(A)] := 6;
  // A = [1, 2, 3, 4, 5, 6]

  // Remover todos — mesma abordagem com Delete
  Delete(A, 0, Length(A));
  // Ou: SetLength(A, 0);

  // Concatenar dois arrays
  var B: TArray<Integer> := TArray<Integer>.Create(7, 8, 9);
  var C: TArray<Integer>;
  SetLength(C, Length(A) + Length(B));
  if Length(A) > 0 then Move(A[0], C[0], Length(A) * SizeOf(Integer));
  if Length(B) > 0 then Move(B[0], C[Length(A)], Length(B) * SizeOf(Integer));
end;

procedure DemonstrarOrdenacao;
var
  Nums: TArray<Integer>;
  Strs: TArray<string>;
begin
  Nums := TArray<Integer>.Create(5, 2, 8, 1, 9, 3);

  // Ordenacao crescente
  TArray.Sort<Integer>(Nums);
  // Nums = [1, 2, 3, 5, 8, 9]

  // Ordenacao decrescente com comparer customizado
  TArray.Sort<Integer>(Nums,
    TComparer<Integer>.Construct(
      function(const L, R: Integer): Integer
      begin
        Result := R - L; // invertido = decrescente
      end));
  // Nums = [9, 8, 5, 3, 2, 1]

  // Strings: ordenacao case-insensitive
  Strs := TArray<string>.Create('Zebra', 'ana', 'Banana');
  TArray.Sort<string>(Strs,
    TComparer<string>.Construct(
      function(const L, R: string): Integer
      begin
        Result := CompareText(L, R);
      end));

  // Busca binaria (array deve estar ordenado)
  TArray.Sort<Integer>(Nums); // re-ordenar crescente
  var Idx: Integer;
  if TArray.BinarySearch<Integer>(Nums, 5, Idx) then
    Writeln('Encontrado no indice ', Idx);
end;

procedure DemonstrarMultidimensional;
var
  Matriz: array of array of Integer;
  L, C: Integer;
begin
  // Matriz 3x4
  SetLength(Matriz, 3);
  for L := 0 to 2 do
    SetLength(Matriz[L], 4);

  // Preencher
  for L := 0 to 2 do
    for C := 0 to 3 do
      Matriz[L][C] := L * 10 + C;

  // Acessar
  Writeln(Matriz[1][2]); // 12

  // ATENÇÃO: cada "linha" e um array independente
  // Matriz[0] pode ter tamanho diferente de Matriz[1]
  // Para garantir uniformidade: verificar Length(Matriz[I])
end;

end.

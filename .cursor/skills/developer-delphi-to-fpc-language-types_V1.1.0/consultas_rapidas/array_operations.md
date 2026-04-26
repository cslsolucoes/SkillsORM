# Operações em Arrays — Referência Rápida

## Dynamic array: operações essenciais

```pascal
var A: TArray<Integer>;

// Criar/dimensionar
SetLength(A, 10);               // 10 elementos zerados
A := TArray<Integer>.Create(1,2,3,4,5);  // inicialização inline

// Tamanho
Length(A)          // número de elementos
High(A)            // último índice (= Length(A) - 1)
Low(A)             // sempre 0 em dynamic array
A = nil            // true se não alocado

// Ler/escrever
A[0] := 42;
var V := A[High(A)];

// Redimensionar (preserva conteúdo até o novo tamanho)
SetLength(A, 20);  // cresce: 10 novos = 0
SetLength(A, 5);   // encolhe: elementos 5..9 descartados

// Limpar
SetLength(A, 0);   // ou A := nil;
```

## Copiar e fatiar

```pascal
var B := Copy(A);          // cópia completa
var F := Copy(A, 2, 3);    // fatia: índice 2, 3 elementos

// ATENÇÃO: Copy é cópia de valores
// Para arrays de classes: copia ponteiro, não objeto
```

## Inserir / remover

```pascal
Insert(99, A, 2);       // insere 99 no índice 2, desloca o resto
Delete(A, 2, 1);        // remove 1 elemento a partir do índice 2
Delete(A, 0, Length(A)); // remove tudo
```

## Adicionar ao final

```pascal
// Idioma padrão (sem library function)
SetLength(A, Length(A) + 1);
A[High(A)] := NovoValor;

// Com TList<T> (mais eficiente para múltiplos appends):
var L := TList<Integer>.Create;
L.Add(1); L.Add(2); L.Add(3);
A := L.ToArray;
L.Free;
```

## Concatenar dois arrays

```pascal
// Abordagem manual
var C: TArray<Integer>;
SetLength(C, Length(A) + Length(B));
if Length(A) > 0 then Move(A[0], C[0],         Length(A) * SizeOf(Integer));
if Length(B) > 0 then Move(B[0], C[Length(A)], Length(B) * SizeOf(Integer));
```

## Ordenar

```pascal
uses System.Generics.Collections, System.Generics.Defaults;

// Crescente (padrão)
TArray.Sort<Integer>(A);

// Decrescente
TArray.Sort<Integer>(A,
  TComparer<Integer>.Construct(function(const L,R: Integer): Integer
  begin Result := R - L; end));

// Por campo de record
TArray.Sort<TCliente>(Clientes,
  TComparer<TCliente>.Construct(function(const L,R: TCliente): Integer
  begin Result := CompareText(L.Nome, R.Nome); end));
```

## Busca

```pascal
// Linear (não requer ordenação)
function IndexOf(A: TArray<Integer>; V: Integer): Integer;
begin
  for Result := 0 to High(A) do
    if A[Result] = V then Exit;
  Result := -1;
end;

// Binária (array deve estar ordenado)
var Idx: Integer;
if TArray.BinarySearch<Integer>(A, 42, Idx) then
  Writeln('Encontrado no índice ', Idx);
```

## Converter List ↔ Array

```pascal
// TList<T> → TArray<T>
var Lista := TList<Integer>.Create;
Lista.Add(1); Lista.Add(2);
var Arr := Lista.ToArray;
Lista.Free;

// TArray<T> → TList<T>
var Lista2 := TList<Integer>.Create(Arr);
```

## Low/High em array estático vs dinâmico

```pascal
var A: array[5..10] of Integer; // estático, base 5
Low(A)  = 5
High(A) = 10
Length(A) = 6

var B: array of Integer;        // dinâmico, sempre base 0
Low(B)  = 0
High(B) = Length(B) - 1
```

# Comparadores Customizados — TComparer\<T\> e IComparer\<T\>

## Conceito

`IComparer<T>` é a interface de comparação usada por `TList<T>.Sort`, `TSortedList<K,V>`, `TObjectList<T>.Sort` e `BinarySearch`. `TComparer<T>.Construct` cria uma instância a partir de um anonymous method.

---

## Sintaxe básica

```pascal
uses System.Generics.Defaults;

var Comp: IComparer<TProduto>;

Comp := TComparer<TProduto>.Construct(
  function(const A, B: TProduto): Integer
  begin
    // Retorna < 0 se A < B, 0 se iguais, > 0 se A > B
    if A.Preco < B.Preco then Result := -1
    else if A.Preco > B.Preco then Result := 1
    else Result := 0;
  end);

Lista.Sort(Comp);
```

---

## Padrões comuns

### Ordem numérica crescente
```pascal
function(const A, B: Integer): Integer
begin Result := A - B; end
// Cuidado: overflow com valores extremos — usar CompareValue(A, B) se necessário
```

### Ordem numérica decrescente
```pascal
function(const A, B: Integer): Integer
begin Result := B - A; end
```

### Ordem por string (case-sensitive)
```pascal
function(const A, B: TFuncionario): Integer
begin Result := CompareStr(A.Nome, B.Nome); end
```

### Ordem por string (case-insensitive)
```pascal
function(const A, B: TFuncionario): Integer
begin Result := CompareText(A.Nome, B.Nome); end
```

### Ordem por Currency/Double
```pascal
function(const A, B: TProduto): Integer
begin
  if A.Preco < B.Preco then Result := -1
  else if A.Preco > B.Preco then Result := 1
  else Result := 0;
end
// CompareValue(A.Preco, B.Preco) também funciona para Double
```

### Ordenação multi-critério
```pascal
function(const A, B: TFuncionario): Integer
begin
  // Primário: departamento
  Result := Ord(A.Depto) - Ord(B.Depto);
  if Result <> 0 then Exit;
  // Secundário: salário decrescente
  if A.Salario > B.Salario then Result := -1
  else if A.Salario < B.Salario then Result := 1
  // Terciário: nome
  else Result := CompareStr(A.Nome, B.Nome);
end
```

---

## BinarySearch com IComparer

```pascal
var Lista: TList<TProduto>;
    Comp: IComparer<TProduto>;
    Idx:  Integer;
    Target: TProduto;
begin
  // IMPORTANTE: a lista DEVE estar ordenada pelo mesmo critério
  Lista.Sort(Comp);

  Target.Preco := 89.90;
  if Lista.BinarySearch(Target, Idx, Comp) then
    Writeln('Encontrado no índice ', Idx)
  else
    Writeln('Não encontrado; seria inserido em ', Idx);
end;
```

---

## IEqualityComparer\<T\> — para TDictionary e Contains

```pascal
uses System.Generics.Defaults;

var EqComp: IEqualityComparer<TProduto>;

EqComp := TEqualityComparer<TProduto>.Construct(
  // Igualdade
  function(const A, B: TProduto): Boolean
  begin Result := A.Id = B.Id; end,
  // Hash — deve ser consistente com Equals
  function(const A: TProduto): Integer
  begin Result := A.Id; end);

var D: TDictionary<TProduto, string>;
D := TDictionary<TProduto, string>.Create(EqComp);
```

---

## TComparer\<T\>.Default

Comparador padrão para o tipo — baseado em `THasher<T>` para primitivos e strings:

```pascal
var Comp := TComparer<Integer>.Default;  // crescente natural
var Comp := TComparer<string>.Default;   // lexicográfico case-sensitive
```

---

## Classe própria de comparer (reutilizável)

```pascal
type
  TProdutoCompPrecoDesc = class(TComparer<TProduto>)
  public
    function Compare(const A, B: TProduto): Integer; override;
  end;

function TProdutoCompPrecoDesc.Compare(const A, B: TProduto): Integer;
begin
  if A.Preco > B.Preco then Result := -1
  else if A.Preco < B.Preco then Result := 1
  else Result := 0;
end;

// Uso:
Lista.Sort(TProdutoCompPrecoDesc.Create);
```

---

## Armadilhas

1. **Subtração de inteiros como comparer** — pode overflow com valores extremos negativos/positivos. Use `CompareValue` ou comparação explícita.
2. **BinarySearch em lista não-ordenada** — resultado indefinido.
3. **Hash inconsistente** — se `Equals(A,B)=True` então `Hash(A)=Hash(B)` obrigatório; violação corrompem TDictionary.
4. **Comparer e TSortedList** — o comparer passado no construtor define a chave de ordenação permanentemente; não pode ser trocado.

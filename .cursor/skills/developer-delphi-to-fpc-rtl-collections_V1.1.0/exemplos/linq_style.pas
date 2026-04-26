unit linq_style;
{
  LINQ-style sobre TList<T> — Where, Select, GroupBy, OrderBy, Aggregate
  Compilavel: dcc32 / dcc64
  Nota: padrão manual via anonymous methods — não usa TEnumerable diretamente
}

interface

uses
  System.SysUtils, System.Generics.Collections, System.Generics.Defaults;

type
  // ---------------------------------------------------------------------------
  // Tipos de domínio
  // ---------------------------------------------------------------------------
  TDepartamento = (dTech, dVendas, dRH, dFinanceiro);

  TFuncionario = class
  public
    Id:          Integer;
    Nome:        string;
    Depto:       TDepartamento;
    Salario:     Currency;
    AnosEmpresa: Integer;
    constructor Create(AId: Integer; const ANome: string;
      ADepto: TDepartamento; ASalario: Currency; AAnosEmpresa: Integer);
    function ToString: string; override;
  end;

  // ---------------------------------------------------------------------------
  // "Extensões" LINQ-like para TList<T>
  // ---------------------------------------------------------------------------

  // Where — filtrar
  function Where<T>(AList: TList<T>;
    APredicate: TFunc<T, Boolean>): TList<T>;

  // Select — transformar (map)
  function Select<T, R>(AList: TList<T>;
    ASelector: TFunc<T, R>): TList<R>;

  // FirstOrDefault — primeiro que satisfaz ou default
  function FirstOrDefault<T: class>(AList: TList<T>;
    APredicate: TFunc<T, Boolean>): T;

  // Any / All
  function Any<T>(AList: TList<T>;
    APredicate: TFunc<T, Boolean>): Boolean;
  function All<T>(AList: TList<T>;
    APredicate: TFunc<T, Boolean>): Boolean;

  // Aggregate — reduzir
  function Aggregate<T, R>(AList: TList<T>;
    ASeed: R; AFunc: TFunc<R, T, R>): R;

  // Sum / Max / Min (Currency)
  function SumCurrency<T>(AList: TList<T>;
    ASelector: TFunc<T, Currency>): Currency;
  function MaxCurrency<T>(AList: TList<T>;
    ASelector: TFunc<T, Currency>): Currency;
  function MinCurrency<T>(AList: TList<T>;
    ASelector: TFunc<T, Currency>): Currency;

  // OrderBy (nova lista ordenada)
  function OrderBy<T>(AList: TList<T>;
    AComparer: IComparer<T>): TList<T>;

  // GroupBy — dicionário categoria→lista
  function GroupBy<T, K>(AList: TList<T>;
    AKeySelector: TFunc<T, K>): TObjectDictionary<K, TList<T>>;

procedure DemoWhereSelect;
procedure DemoGroupBy;
procedure DemoOrderBy;
procedure DemoAggregateSumMax;
procedure DemoPipeline;

implementation

// ---------------------------------------------------------------------------
// TFuncionario
// ---------------------------------------------------------------------------

constructor TFuncionario.Create(AId: Integer; const ANome: string;
  ADepto: TDepartamento; ASalario: Currency; AAnosEmpresa: Integer);
begin
  inherited Create;
  Id := AId; Nome := ANome; Depto := ADepto;
  Salario := ASalario; AnosEmpresa := AAnosEmpresa;
end;

function TFuncionario.ToString: string;
const NomeDepto: array[TDepartamento] of string = ('Tech','Vendas','RH','Financeiro');
begin
  Result := Format('[%d] %-12s %-10s R$%7.2f %d anos',
    [Id, Nome, NomeDepto[Depto], Salario, AnosEmpresa]);
end;

// ---------------------------------------------------------------------------
// Implementação das funções LINQ-style
// ---------------------------------------------------------------------------

function Where<T>(AList: TList<T>;
  APredicate: TFunc<T, Boolean>): TList<T>;
var Item: T;
begin
  Result := TList<T>.Create;
  for Item in AList do
    if APredicate(Item) then Result.Add(Item);
end;

function Select<T, R>(AList: TList<T>;
  ASelector: TFunc<T, R>): TList<R>;
var Item: T;
begin
  Result := TList<R>.Create;
  for Item in AList do Result.Add(ASelector(Item));
end;

function FirstOrDefault<T: class>(AList: TList<T>;
  APredicate: TFunc<T, Boolean>): T;
var Item: T;
begin
  Result := nil;
  for Item in AList do
    if APredicate(Item) then begin Result := Item; Exit; end;
end;

function Any<T>(AList: TList<T>;
  APredicate: TFunc<T, Boolean>): Boolean;
var Item: T;
begin
  for Item in AList do
    if APredicate(Item) then begin Result := True; Exit; end;
  Result := False;
end;

function All<T>(AList: TList<T>;
  APredicate: TFunc<T, Boolean>): Boolean;
var Item: T;
begin
  for Item in AList do
    if not APredicate(Item) then begin Result := False; Exit; end;
  Result := True;
end;

function Aggregate<T, R>(AList: TList<T>;
  ASeed: R; AFunc: TFunc<R, T, R>): R;
var Item: T;
begin
  Result := ASeed;
  for Item in AList do Result := AFunc(Result, Item);
end;

function SumCurrency<T>(AList: TList<T>;
  ASelector: TFunc<T, Currency>): Currency;
var Item: T;
begin
  Result := 0;
  for Item in AList do Result := Result + ASelector(Item);
end;

function MaxCurrency<T>(AList: TList<T>;
  ASelector: TFunc<T, Currency>): Currency;
var Item: T;
    V:    Currency;
begin
  if AList.Count = 0 then begin Result := 0; Exit; end;
  Result := ASelector(AList[0]);
  for Item in AList do
  begin
    V := ASelector(Item);
    if V > Result then Result := V;
  end;
end;

function MinCurrency<T>(AList: TList<T>;
  ASelector: TFunc<T, Currency>): Currency;
var Item: T;
    V:    Currency;
begin
  if AList.Count = 0 then begin Result := 0; Exit; end;
  Result := ASelector(AList[0]);
  for Item in AList do
  begin
    V := ASelector(Item);
    if V < Result then Result := V;
  end;
end;

function OrderBy<T>(AList: TList<T>;
  AComparer: IComparer<T>): TList<T>;
begin
  Result := TList<T>.Create;
  Result.AddRange(AList);
  Result.Sort(AComparer);
end;

function GroupBy<T, K>(AList: TList<T>;
  AKeySelector: TFunc<T, K>): TObjectDictionary<K, TList<T>>;
var Item: T;
    Key:  K;
    Grupo: TList<T>;
begin
  Result := TObjectDictionary<K, TList<T>>.Create([doOwnsValues]);
  for Item in AList do
  begin
    Key := AKeySelector(Item);
    if not Result.TryGetValue(Key, Grupo) then
    begin
      Grupo := TList<T>.Create;
      Result.Add(Key, Grupo);
    end;
    Grupo.Add(Item);
  end;
end;

// ---------------------------------------------------------------------------
// Dataset compartilhado
// ---------------------------------------------------------------------------

function CriarFuncionarios: TObjectList<TFuncionario>;
begin
  Result := TObjectList<TFuncionario>.Create;
  Result.Add(TFuncionario.Create(1, 'Alice',   dTech,       8500, 3));
  Result.Add(TFuncionario.Create(2, 'Bob',     dVendas,     5200, 1));
  Result.Add(TFuncionario.Create(3, 'Carol',   dTech,      12000, 7));
  Result.Add(TFuncionario.Create(4, 'Dave',    dRH,         4800, 2));
  Result.Add(TFuncionario.Create(5, 'Eve',     dFinanceiro, 9500, 5));
  Result.Add(TFuncionario.Create(6, 'Frank',   dVendas,     6300, 4));
  Result.Add(TFuncionario.Create(7, 'Grace',   dTech,       7200, 2));
  Result.Add(TFuncionario.Create(8, 'Heitor',  dRH,         5100, 6));
  Result.Add(TFuncionario.Create(9, 'Iris',    dFinanceiro,11000, 8));
  Result.Add(TFuncionario.Create(10,'João',    dVendas,     4500, 1));
end;

// ---------------------------------------------------------------------------
// DemoWhereSelect
// ---------------------------------------------------------------------------

procedure DemoWhereSelect;
var Todos: TObjectList<TFuncionario>;
    Tech:  TList<TFuncionario>;
    Nomes: TList<string>;
    F:     TFuncionario;
    N:     string;
begin
  Todos := CriarFuncionarios;
  try
    // Where — só Tech com salário > 8000
    Tech := Where<TFuncionario>(Todos,
      function(F: TFuncionario): Boolean
      begin Result := (F.Depto = dTech) and (F.Salario > 8000); end);
    try
      Writeln('--- Tech salário > 8000 ---');
      for F in Tech do Writeln(F.ToString);
    finally Tech.Free; end;

    // Select — projetar nomes
    Nomes := Select<TFuncionario, string>(Todos,
      function(F: TFuncionario): string
      begin Result := F.Nome + ' (R$' + CurrToStr(F.Salario) + ')'; end);
    try
      Writeln('--- Nomes com salário ---');
      for N in Nomes do Writeln(N);
    finally Nomes.Free; end;

    // Any / All
    Writeln('Any salario > 10000: ',
      Any<TFuncionario>(Todos, function(F: TFuncionario): Boolean
      begin Result := F.Salario > 10000; end));

    Writeln('All salario > 3000: ',
      All<TFuncionario>(Todos, function(F: TFuncionario): Boolean
      begin Result := F.Salario > 3000; end));

    // FirstOrDefault
    F := FirstOrDefault<TFuncionario>(Todos,
      function(X: TFuncionario): Boolean
      begin Result := X.AnosEmpresa > 6; end);
    if F <> nil then Writeln('Primeiro com >6 anos: ', F.Nome);
  finally
    Todos.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoGroupBy
// ---------------------------------------------------------------------------

procedure DemoGroupBy;
var Todos:  TObjectList<TFuncionario>;
    Grupos: TObjectDictionary<TDepartamento, TList<TFuncionario>>;
    Depto:  TDepartamento;
    Grupo:  TList<TFuncionario>;
    F:      TFuncionario;
const NomeDepto: array[TDepartamento] of string = ('Tech','Vendas','RH','Financeiro');
begin
  Todos := CriarFuncionarios;
  try
    Grupos := GroupBy<TFuncionario, TDepartamento>(Todos,
      function(F: TFuncionario): TDepartamento
      begin Result := F.Depto; end);
    try
      Writeln('--- GROUP BY Departamento ---');
      for Depto in Grupos.Keys do
      begin
        Grupo := Grupos[Depto];
        Writeln(NomeDepto[Depto], ' (', Grupo.Count, ' funcionários):');
        for F in Grupo do
          Write('  ', F.Nome, ' R$', F.Salario:0:2);
        Writeln;
      end;
    finally Grupos.Free; end;
  finally
    Todos.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoOrderBy
// ---------------------------------------------------------------------------

procedure DemoOrderBy;
var Todos:   TObjectList<TFuncionario>;
    PorSal:  TList<TFuncionario>;
    PorAnos: TList<TFuncionario>;
    F:       TFuncionario;
begin
  Todos := CriarFuncionarios;
  try
    // Ordenar por salário decrescente
    PorSal := OrderBy<TFuncionario>(Todos,
      TComparer<TFuncionario>.Construct(
        function(const A, B: TFuncionario): Integer
        begin
          if A.Salario > B.Salario then Result := -1
          else if A.Salario < B.Salario then Result := 1
          else Result := 0;
        end));
    try
      Writeln('--- Por salário desc ---');
      for F in PorSal do
        Writeln(F.Nome, ' R$', F.Salario:0:2);
    finally PorSal.Free; end;

    // Ordenar por anos de empresa asc, desempate por nome
    PorAnos := OrderBy<TFuncionario>(Todos,
      TComparer<TFuncionario>.Construct(
        function(const A, B: TFuncionario): Integer
        begin
          Result := A.AnosEmpresa - B.AnosEmpresa;
          if Result = 0 then Result := CompareStr(A.Nome, B.Nome);
        end));
    try
      Writeln('--- Por anos asc ---');
      for F in PorAnos do
        Writeln(F.AnosEmpresa, ' anos  ', F.Nome);
    finally PorAnos.Free; end;
  finally
    Todos.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoAggregateSumMax
// ---------------------------------------------------------------------------

procedure DemoAggregateSumMax;
var Todos:      TObjectList<TFuncionario>;
    TotalFolha: Currency;
    MaiorSal:   Currency;
    MenorSal:   Currency;
    ContaTech:  Integer;
begin
  Todos := CriarFuncionarios;
  try
    TotalFolha := SumCurrency<TFuncionario>(Todos,
      function(F: TFuncionario): Currency begin Result := F.Salario; end);
    Writeln('Folha total: R$', TotalFolha:0:2);

    MaiorSal := MaxCurrency<TFuncionario>(Todos,
      function(F: TFuncionario): Currency begin Result := F.Salario; end);
    Writeln('Maior salário: R$', MaiorSal:0:2);

    MenorSal := MinCurrency<TFuncionario>(Todos,
      function(F: TFuncionario): Currency begin Result := F.Salario; end);
    Writeln('Menor salário: R$', MenorSal:0:2);

    // Aggregate genérico — contar Tech
    ContaTech := Aggregate<TFuncionario, Integer>(Todos, 0,
      function(Acc: Integer; F: TFuncionario): Integer
      begin
        if F.Depto = dTech then Result := Acc + 1
        else Result := Acc;
      end);
    Writeln('Funcionários Tech: ', ContaTech);
  finally
    Todos.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoPipeline — composição de operações (WHERE → ORDERBY → SELECT → SUM)
// ---------------------------------------------------------------------------

procedure DemoPipeline;
var Todos:     TObjectList<TFuncionario>;
    Seniores:  TList<TFuncionario>;
    Ordenados: TList<TFuncionario>;
    Nomes:     TList<string>;
    TotalSal:  Currency;
    N:         string;
begin
  Todos := CriarFuncionarios;
  try
    // 1. Where: funcionários com >= 4 anos
    Seniores := Where<TFuncionario>(Todos,
      function(F: TFuncionario): Boolean
      begin Result := F.AnosEmpresa >= 4; end);
    try
      // 2. OrderBy: salário decrescente
      Ordenados := OrderBy<TFuncionario>(Seniores,
        TComparer<TFuncionario>.Construct(
          function(const A, B: TFuncionario): Integer
          begin
            if A.Salario > B.Salario then Result := -1
            else if A.Salario < B.Salario then Result := 1
            else Result := 0;
          end));
      try
        // 3. Select: nome formatado
        Nomes := Select<TFuncionario, string>(Ordenados,
          function(F: TFuncionario): string
          begin Result := F.Nome + ' (' + F.AnosEmpresa.ToString + ' anos)'; end);
        try
          Writeln('--- Seniores ordenados por salário ---');
          for N in Nomes do Writeln(N);
        finally Nomes.Free; end;

        // 4. Sum: total da folha desses seniores
        TotalSal := SumCurrency<TFuncionario>(Ordenados,
          function(F: TFuncionario): Currency begin Result := F.Salario; end);
        Writeln('Folha seniores: R$', TotalSal:0:2);
      finally Ordenados.Free; end;
    finally Seniores.Free; end;
  finally
    Todos.Free;
  end;
end;

// ---------------------------------------------------------------------------
// USO:
//   DemoWhereSelect;
//   DemoGroupBy;
//   DemoOrderBy;
//   DemoAggregateSumMax;
//   DemoPipeline;
// ---------------------------------------------------------------------------

end.

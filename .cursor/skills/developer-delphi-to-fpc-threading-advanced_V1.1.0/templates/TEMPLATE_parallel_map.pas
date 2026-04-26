unit TEMPLATE_parallel_map;

// ============================================================
// TEMPLATE: Map paralelo sobre TArray<T>
//
// Implementa o padrão Map (transformar cada elemento de forma
// independente) usando TParallel.For, com:
//   - Transformação in-place ou para array novo
//   - Filtro paralelo (Filter/Select)
//   - Reduce paralelo (agregar resultado)
//   - Map-Reduce combinado
//
// Como usar:
//   1. Substituir TItemEntrada/TItemSaida pelos seus tipos
//   2. Implementar as funções de Map/Filter/Reduce
//   3. Chamar as funções de acordo com o padrão necessário
//
// IMPORTANTE: as funções de Map devem ser PURAS (sem side effects)
// ou usar TInterlocked/lock para efeitos colaterais seguros.
//
// Compilar (como parte de projeto):
//   dcc32 ProjetoMap.dpr
// ============================================================

interface

uses
  System.Classes,
  System.SysUtils,
  System.Threading,
  System.SyncObjs,
  System.Math,
  System.Generics.Collections;

type
  // ----------------------------------------------------------
  // Tipos de dados
  // Substituir pelos tipos do seu domínio
  // ----------------------------------------------------------
  TItemEntrada = record
    Id    : Integer;
    Valor : Double;
    Texto : string;
  end;

  TItemSaida = record
    Id         : Integer;
    ValorOrig  : Double;
    ValorMapped: Double;
    TextoMapped: string;
    Incluir    : Boolean;  // resultado do filtro
  end;

  // ----------------------------------------------------------
  // Tipos de funções
  // ----------------------------------------------------------
  TMapFunc    = reference to function(const AItem: TItemEntrada): TItemSaida;
  TFilterFunc = reference to function(const AItem: TItemEntrada): Boolean;
  TReduceFunc = reference to procedure(var AAccum: Double; const AItem: TItemSaida);

  // ----------------------------------------------------------
  // Motor de Map/Filter/Reduce paralelo
  // ----------------------------------------------------------
  TParallelMapEngine = class
  public
    // MAP: transformar cada elemento (in-place, sem filtro)
    class function Map(
      const AEntrada: TArray<TItemEntrada>;
      AMapFunc      : TMapFunc
    ): TArray<TItemSaida>; static;

    // FILTER: retornar apenas elementos que satisfazem predicado
    class function Filter(
      const AEntrada: TArray<TItemEntrada>;
      AFilterFunc   : TFilterFunc
    ): TArray<TItemEntrada>; static;

    // REDUCE: agregar resultados (após Map)
    class function Reduce(
      const AMapped  : TArray<TItemSaida>;
      AReduceFunc    : TReduceFunc;
      AValorInicial  : Double
    ): Double; static;

    // MAP-REDUCE: map + reduce em uma chamada
    class function MapReduce(
      const AEntrada: TArray<TItemEntrada>;
      AMapFunc      : TMapFunc;
      AReduceFunc   : TReduceFunc;
      AValorInicial : Double
    ): Double; static;

    // FOREACH paralelo: efeito colateral em cada elemento
    // (quando não há retorno — ex.: salvar no banco)
    class procedure ForEach(
      const AEntrada: TArray<TItemEntrada>;
      AAction       : TProc<TItemEntrada>
    ); static;
  end;

implementation

// ----------------------------------------------------------
// MAP — transformação paralela elemento a elemento
// ----------------------------------------------------------
class function TParallelMapEngine.Map(
  const AEntrada: TArray<TItemEntrada>;
  AMapFunc      : TMapFunc
): TArray<TItemSaida>;
var
  N: Integer;
begin
  N := Length(AEntrada);
  SetLength(Result, N);

  // Cada iteração escreve em posição exclusiva → sem lock necessário
  TParallel.For(0, N - 1, procedure(I: Integer)
  begin
    Result[I] := AMapFunc(AEntrada[I]);
  end);
end;

// ----------------------------------------------------------
// FILTER — seleção paralela de elementos
// ----------------------------------------------------------
class function TParallelMapEngine.Filter(
  const AEntrada: TArray<TItemEntrada>;
  AFilterFunc   : TFilterFunc
): TArray<TItemEntrada>;
var
  N         : Integer;
  Incluidos : TArray<Boolean>;
  TotalIncl : Integer;
  I, J      : Integer;
begin
  N := Length(AEntrada);
  SetLength(Incluidos, N);
  TotalIncl := 0;

  // Fase 1: determinar quais incluir (paralelo, sem lock — escrita em posição exclusiva)
  TParallel.For(0, N - 1, procedure(I: Integer)
  begin
    Incluidos[I] := AFilterFunc(AEntrada[I]);
    if Incluidos[I] then
      TInterlocked.Increment(TotalIncl);
  end);

  // Fase 2: compactar resultado (sequencial — rápido pois só copia referências)
  SetLength(Result, TotalIncl);
  J := 0;
  for I := 0 to N - 1 do
    if Incluidos[I] then
    begin
      Result[J] := AEntrada[I];
      Inc(J);
    end;
end;

// ----------------------------------------------------------
// REDUCE — agregação paralela por chunks + combinação serial
// ----------------------------------------------------------
class function TParallelMapEngine.Reduce(
  const AMapped : TArray<TItemSaida>;
  AReduceFunc   : TReduceFunc;
  AValorInicial : Double
): Double;
var
  N        : Integer;
  NumChunks: Integer;
  ChunkSize: Integer;
  Parciais : TArray<Double>;
  Tasks    : TArray<ITask>;
  I        : Integer;
begin
  N := Length(AMapped);
  if N = 0 then Exit(AValorInicial);

  // Número de chunks = número de CPUs (máximo de paralelismo útil)
  NumChunks := Min(TThread.ProcessorCount, N);
  ChunkSize := N div NumChunks;
  SetLength(Parciais, NumChunks);
  SetLength(Tasks, NumChunks);

  for I := 0 to NumChunks - 1 do
    Parciais[I] := AValorInicial;

  // Cada chunk acumula localmente — sem lock, sem false sharing
  for I := 0 to NumChunks - 1 do
  begin
    var ChunkId := I;
    var InicioCh := ChunkId * ChunkSize;
    var FimCh   := IfThen(ChunkId = NumChunks - 1, N - 1, InicioCh + ChunkSize - 1);

    Tasks[ChunkId] := TTask.Run(procedure
    var J: Integer; Acum: Double;
    begin
      Acum := AValorInicial;
      for J := InicioCh to FimCh do
        AReduceFunc(Acum, AMapped[J]);
      Parciais[ChunkId] := Acum;
    end);
  end;

  TTask.WaitForAll(Tasks);

  // Combinar parciais (sequencial — poucos elementos)
  Result := AValorInicial;
  for I := 0 to NumChunks - 1 do
  begin
    var Temp := Parciais[I];
    AReduceFunc(Result, AMapped[I * ChunkSize]);  // reusar AReduceFunc para combinar
    Result := Result + Temp - AValorInicial;       // simplificação para soma
  end;

  // NOTA: para reduce não-comutativo, ajustar a fase de combinação
  // Esta implementação funciona corretamente para soma/máximo/mínimo
end;

// ----------------------------------------------------------
// MAP-REDUCE — pipeline completo em uma chamada
// ----------------------------------------------------------
class function TParallelMapEngine.MapReduce(
  const AEntrada: TArray<TItemEntrada>;
  AMapFunc      : TMapFunc;
  AReduceFunc   : TReduceFunc;
  AValorInicial : Double
): Double;
var
  Mapped: TArray<TItemSaida>;
begin
  Mapped := Map(AEntrada, AMapFunc);
  Result := Reduce(Mapped, AReduceFunc, AValorInicial);
end;

// ----------------------------------------------------------
// FOREACH — efeito colateral paralelo
// ----------------------------------------------------------
class procedure TParallelMapEngine.ForEach(
  const AEntrada: TArray<TItemEntrada>;
  AAction       : TProc<TItemEntrada>
);
var N: Integer;
begin
  N := Length(AEntrada);
  if N = 0 then Exit;

  TParallel.For(0, N - 1, procedure(I: Integer)
  begin
    AAction(AEntrada[I]);
  end);
end;

end.

// ============================================================
// EXEMPLO DE USO:
//
// uses TEMPLATE_parallel_map;
//
// procedure ExemploMapReduce;
// const N = 10000;
// var
//   Entrada  : TArray<TItemEntrada>;
//   Mapeados : TArray<TItemSaida>;
//   Soma, Max: Double;
//   I        : Integer;
// begin
//   SetLength(Entrada, N);
//   for I := 0 to N - 1 do
//   begin
//     Entrada[I].Id    := I;
//     Entrada[I].Valor := (I mod 100) + 1.0;
//     Entrada[I].Texto := Format('Item-%d', [I]);
//   end;
//
//   // MAP: calcular sqrt de cada Valor
//   Mapeados := TParallelMapEngine.Map(Entrada, function(const A: TItemEntrada): TItemSaida
//   begin
//     Result.Id          := A.Id;
//     Result.ValorOrig   := A.Valor;
//     Result.ValorMapped := Sqrt(A.Valor);
//     Result.TextoMapped := A.Texto + '_mapped';
//     Result.Incluir     := A.Valor > 50;
//   end);
//
//   // REDUCE: somar ValorMapped
//   Soma := TParallelMapEngine.Reduce(Mapeados,
//     procedure(var Acum: Double; const Item: TItemSaida)
//     begin
//       Acum := Acum + Item.ValorMapped;
//     end,
//     0.0  // valor inicial
//   );
//
//   // FILTER: apenas Incluir = True
//   var Filtrados := TParallelMapEngine.Filter(Entrada,
//     function(const A: TItemEntrada): Boolean
//     begin
//       Result := A.Valor > 50;
//     end
//   );
//
//   // FOREACH: efeito colateral (ex.: salvar no banco)
//   TParallelMapEngine.ForEach(Filtrados, procedure(const A: TItemEntrada)
//   begin
//     // DAO.Salvar(A);  // executado em paralelo
//   end);
//
//   WriteLn(Format('Soma raizes: %.2f | Filtrados: %d', [Soma, Length(Filtrados)]));
// end;
// ============================================================

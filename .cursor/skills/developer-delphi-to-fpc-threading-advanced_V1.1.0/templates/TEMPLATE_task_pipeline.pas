unit TEMPLATE_task_pipeline;

// ============================================================
// TEMPLATE: Pipeline de Tasks com TTask e TThreadedQueue<T>
//
// Padrão pipeline: dados fluem por estágios de processamento
// encadeados, cada estágio em sua própria TTask concorrente.
//
// Diagrama:
//   [Fonte] → [Estágio 1] → [Estágio 2] → [Estágio N] → [Destino]
//   Cada seta representa uma TThreadedQueue<T>
//   Cada bloco é uma TTask independente
//
// Como usar:
//   1. Definir TItemEntrada, TItemIntermediario, TItemSaida
//   2. Implementar TProcessadorEstagioN.Processar para cada estágio
//   3. Chamar TPipeline.Executar e aguardar conclusão
//   4. Coletar resultados de FSaida
//
// Compilar (como parte de projeto):
//   dcc32 ProjetoPipeline.dpr  (que use esta unit)
// ============================================================

interface

uses
  System.Classes,
  System.SysUtils,
  System.Threading,
  System.SyncObjs,
  System.Generics.Collections;

const
  CAPACIDADE_FILA_PIPELINE = 50;
  PIPELINE_POP_TIMEOUT     = 500;  // ms — para verificar Terminated

type
  // ----------------------------------------------------------
  // Tipos de dados em cada estágio
  // Substituir pelos tipos do seu domínio
  // ----------------------------------------------------------
  TItemEntrada = record
    Id   : Integer;
    Dados: string;
  end;

  TItemMedio = record  // resultado do estágio 1
    Id         : Integer;
    DadosOriginais: string;
    DadosTransformados: string;
  end;

  TItemSaida = record  // resultado do estágio 2 (saída final)
    Id        : Integer;
    Resultado : string;
    Sucesso   : Boolean;
  end;

  // Sentinela genérica (Id = -1 indica fim)
  function CriarSentinelaEntrada: TItemEntrada;
  function CriarSentinelaMedio  : TItemMedio;

  // ----------------------------------------------------------
  // Interfaces dos processadores de estágio
  // ----------------------------------------------------------
  IProcessadorEstagio1 = interface
    function Processar(const AEntrada: TItemEntrada): TItemMedio;
  end;

  IProcessadorEstagio2 = interface
    function Processar(const AEntrada: TItemMedio): TItemSaida;
  end;

  // ----------------------------------------------------------
  // Implementações concretas (substituir pela lógica real)
  // ----------------------------------------------------------
  TProcessadorEstagio1 = class(TInterfacedObject, IProcessadorEstagio1)
  public
    function Processar(const AEntrada: TItemEntrada): TItemMedio;
  end;

  TProcessadorEstagio2 = class(TInterfacedObject, IProcessadorEstagio2)
  public
    function Processar(const AEntrada: TItemMedio): TItemSaida;
  end;

  // ----------------------------------------------------------
  // Pipeline orquestrador
  // ----------------------------------------------------------
  TPipelineMetrics = record
    ItensFonte    : Integer;
    ItensEstagio1 : Integer;
    ItensEstagio2 : Integer;
    ItensSaida    : Integer;
    Erros         : Integer;
    DuracaoMs     : Integer;
  end;

  TPipeline = class
  private
    // Filas entre estágios
    FFila01 : TThreadedQueue<TItemEntrada>;  // Fonte → Estágio 1
    FFila12 : TThreadedQueue<TItemMedio>;    // Estágio 1 → Estágio 2
    FSaida  : TList<TItemSaida>;             // Estágio 2 → Resultado final

    // Processadores
    FProc1  : IProcessadorEstagio1;
    FProc2  : IProcessadorEstagio2;

    // Métricas
    FMetrics: TPipelineMetrics;
    FLockSaida: TCriticalSection;

    // Tasks dos estágios
    FTaskFonte  : ITask;
    FTaskEstagio1: ITask;
    FTaskEstagio2: ITask;

    // Dados de entrada (simplificado — em produção: stream, banco, etc.)
    FItensEntrada: TArray<TItemEntrada>;

    procedure ExecutarFonte;
    procedure ExecutarEstagio1;
    procedure ExecutarEstagio2;

  public
    constructor Create(AProc1: IProcessadorEstagio1; AProc2: IProcessadorEstagio2);
    destructor Destroy; override;

    // Configurar entrada
    procedure SetItensEntrada(const AItens: TArray<TItemEntrada>);

    // Executar pipeline e aguardar conclusão
    procedure Executar;

    // Acessar resultados após Executar
    property Saida   : TList<TItemSaida>    read FSaida;
    property Metrics : TPipelineMetrics     read FMetrics;
  end;

implementation

// ----------------------------------------------------------
function CriarSentinelaEntrada: TItemEntrada;
begin Result.Id := -1; Result.Dados := 'SENTINELA'; end;

function CriarSentinelaMedio: TItemMedio;
begin Result.Id := -1; Result.DadosOriginais := 'SENTINELA'; Result.DadosTransformados := ''; end;

// ----------------------------------------------------------
// TProcessadorEstagio1 — transformação de dados de entrada
// ----------------------------------------------------------
function TProcessadorEstagio1.Processar(const AEntrada: TItemEntrada): TItemMedio;
begin
  // TODO: implementar lógica real
  // Exemplo: normalizar texto, validar, enriquecer com dados externos
  Sleep(10);  // simula processamento

  Result.Id                   := AEntrada.Id;
  Result.DadosOriginais       := AEntrada.Dados;
  Result.DadosTransformados   := AEntrada.Dados.ToUpper + '_TRANSFORMADO';
end;

// ----------------------------------------------------------
// TProcessadorEstagio2 — persistência ou geração de saída
// ----------------------------------------------------------
function TProcessadorEstagio2.Processar(const AEntrada: TItemMedio): TItemSaida;
begin
  // TODO: implementar lógica real
  // Exemplo: salvar no banco, gerar relatório, enviar para API
  Sleep(15);  // simula escrita no banco

  Result.Id       := AEntrada.Id;
  Result.Resultado := Format('[OK] ID=%d: %s', [AEntrada.Id, AEntrada.DadosTransformados]);
  Result.Sucesso  := True;
end;

// ----------------------------------------------------------
// TPipeline — construtor/destrutor
// ----------------------------------------------------------
constructor TPipeline.Create(AProc1: IProcessadorEstagio1; AProc2: IProcessadorEstagio2);
begin
  inherited Create;
  FProc1     := AProc1;
  FProc2     := AProc2;
  FFila01    := TThreadedQueue<TItemEntrada>.Create(CAPACIDADE_FILA_PIPELINE, INFINITE, PIPELINE_POP_TIMEOUT);
  FFila12    := TThreadedQueue<TItemMedio>.Create(CAPACIDADE_FILA_PIPELINE, INFINITE, PIPELINE_POP_TIMEOUT);
  FSaida     := TList<TItemSaida>.Create;
  FLockSaida := TCriticalSection.Create;
  FillChar(FMetrics, SizeOf(FMetrics), 0);
end;

destructor TPipeline.Destroy;
begin
  FLockSaida.Free;
  FSaida.Free;
  FFila12.Free;
  FFila01.Free;
  inherited;
end;

procedure TPipeline.SetItensEntrada(const AItens: TArray<TItemEntrada>);
begin
  FItensEntrada := AItens;
end;

// ----------------------------------------------------------
// Fonte: empurra itens de entrada na fila 01
// ----------------------------------------------------------
procedure TPipeline.ExecutarFonte;
var
  Item: TItemEntrada;
begin
  for Item in FItensEntrada do
  begin
    FFila01.PushItem(Item);
    TInterlocked.Increment(FMetrics.ItensFonte);
  end;
  FFila01.PushItem(CriarSentinelaEntrada);  // sentinela: fim da fonte
end;

// ----------------------------------------------------------
// Estágio 1: lê da fila 01, processa, empurra na fila 12
// ----------------------------------------------------------
procedure TPipeline.ExecutarEstagio1;
var
  Item : TItemEntrada;
  Medio: TItemMedio;
  Res  : TWaitResult;
begin
  while True do
  begin
    Res := FFila01.PopItem(Item);
    case Res of
      wrSignaled:
      begin
        if Item.Id = -1 then Break;  // sentinela

        try
          Medio := FProc1.Processar(Item);
          FFila12.PushItem(Medio);
          TInterlocked.Increment(FMetrics.ItensEstagio1);
        except
          on E: Exception do
          begin
            TInterlocked.Increment(FMetrics.Erros);
            // Log do erro — em produção: usar logger centralizado
          end;
        end;
      end;
      wrTimeout  : { sem item — continua loop };
      wrAbandoned: Break;
      wrError    : Break;
    end;
  end;
  FFila12.PushItem(CriarSentinelaMedio);  // propagar sentinela
end;

// ----------------------------------------------------------
// Estágio 2: lê da fila 12, processa, grava na saída final
// ----------------------------------------------------------
procedure TPipeline.ExecutarEstagio2;
var
  Item  : TItemMedio;
  Saida : TItemSaida;
  Res   : TWaitResult;
begin
  while True do
  begin
    Res := FFila12.PopItem(Item);
    case Res of
      wrSignaled:
      begin
        if Item.Id = -1 then Break;  // sentinela

        try
          Saida := FProc2.Processar(Item);
          FLockSaida.Enter;
          try
            FSaida.Add(Saida);
          finally
            FLockSaida.Leave;
          end;
          TInterlocked.Increment(FMetrics.ItensEstagio2);
        except
          on E: Exception do
            TInterlocked.Increment(FMetrics.Erros);
        end;
      end;
      wrTimeout  : { sem item — continua loop };
      wrAbandoned: Break;
      wrError    : Break;
    end;
  end;
  TInterlocked.Exchange(FMetrics.ItensSaida, FSaida.Count);
end;

// ----------------------------------------------------------
// Executar o pipeline completo
// ----------------------------------------------------------
procedure TPipeline.Executar;
var
  Inicio: TDateTime;
begin
  Inicio := Now;

  // Iniciar estágios em paralelo (cada um é uma TTask independente)
  FTaskEstagio1 := TTask.Run(procedure begin ExecutarEstagio1; end);
  FTaskEstagio2 := TTask.Run(procedure begin ExecutarEstagio2; end);
  FTaskFonte    := TTask.Run(procedure begin ExecutarFonte;    end);

  // Aguardar todos os estágios terminarem
  TTask.WaitForAll([FTaskFonte, FTaskEstagio1, FTaskEstagio2]);

  FMetrics.DuracaoMs := Round((Now - Inicio) * 24 * 60 * 60 * 1000);
end;

end.

// ============================================================
// EXEMPLO DE USO:
//
// uses TEMPLATE_task_pipeline;
//
// var
//   Pipeline: TPipeline;
//   Itens   : TArray<TItemEntrada>;
//   I       : Integer;
//   Item    : TItemSaida;
// begin
//   SetLength(Itens, 100);
//   for I := 0 to 99 do
//   begin
//     Itens[I].Id    := I;
//     Itens[I].Dados := Format('Dados-%d', [I]);
//   end;
//
//   Pipeline := TPipeline.Create(TProcessadorEstagio1.Create, TProcessadorEstagio2.Create);
//   try
//     Pipeline.SetItensEntrada(Itens);
//     Pipeline.Executar;
//
//     WriteLn(Format('Pipeline concluido em %d ms', [Pipeline.Metrics.DuracaoMs]));
//     WriteLn(Format('Processados: %d | Erros: %d', [Pipeline.Metrics.ItensSaida, Pipeline.Metrics.Erros]));
//
//     for Item in Pipeline.Saida do
//       WriteLn(Item.Resultado);
//   finally
//     Pipeline.Free;
//   end;
// end;
// ============================================================

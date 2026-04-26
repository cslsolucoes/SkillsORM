unit TEMPLATE_producer_consumer;

// ============================================================
// TEMPLATE: Produtor-Consumidor com TThreadedQueue<T>
//
// Padrão clássico onde N produtores geram itens e M consumidores
// os processam, todos coordenados por uma fila thread-safe.
//
// Como usar:
//   1. Copie esta unit para seu projeto
//   2. Substitua TItemDados pelos campos do seu domínio
//   3. Implemente TProdutorConcreto.Produzir e TConsumidorConcreto.Consumir
//   4. Ajuste NUM_PRODUTORES, NUM_CONSUMIDORES e CAPACIDADE_FILA
//
// Compilar (como parte de projeto):
//   dcc32 ProjetoPC.dpr  (que use esta unit)
// ============================================================

interface

uses
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  System.Generics.Collections;

const
  CAPACIDADE_FILA  = 100;    // máximo de itens em espera
  TIMEOUT_PUSH     = 5000;   // ms para desistir de inserir (fila cheia)
  TIMEOUT_POP      = 500;    // ms para verificar Terminated (fila vazia)

type
  // ----------------------------------------------------------
  // Item de dados trocado entre produtor e consumidor
  // Substituir pelos campos necessários
  // ----------------------------------------------------------
  TItemDados = record
    Id    : Int64;
    Origem: string;
    Carga : TBytes;    // payload genérico
    // Adicione campos conforme necessário
  end;

  // Sentinela: item especial que sinaliza fim da produção
  // Convenção: Id = -1 → consumidor deve encerrar
  function CriarSentinela: TItemDados;

  // ----------------------------------------------------------
  // Produtor base — herdar e implementar Produzir
  // ----------------------------------------------------------
  TProdutorBase = class(TThread)
  private
    FFila: TThreadedQueue<TItemDados>;
    FId  : Integer;
  protected
    procedure Execute; override;
    // IMPLEMENTAR: produzir itens e chamar Publicar para cada um
    procedure Produzir; virtual; abstract;
    procedure Publicar(const AItem: TItemDados);
  public
    constructor Create(AFila: TThreadedQueue<TItemDados>; AId: Integer);
    property Id: Integer read FId;
  end;

  // ----------------------------------------------------------
  // Consumidor base — herdar e implementar Consumir
  // ----------------------------------------------------------
  TConsumidorBase = class(TThread)
  private
    FFila: TThreadedQueue<TItemDados>;
    FId  : Integer;
  protected
    procedure Execute; override;
    // IMPLEMENTAR: processar um item recebido
    procedure Consumir(const AItem: TItemDados); virtual; abstract;
  public
    constructor Create(AFila: TThreadedQueue<TItemDados>; AId: Integer);
    property Id: Integer read FId;
  end;

  // ----------------------------------------------------------
  // Orquestrador do padrão produtor-consumidor
  // ----------------------------------------------------------
  TOrquestradorPC = class
  private
    FFila      : TThreadedQueue<TItemDados>;
    FProdutores: TObjectList<TProdutorBase>;
    FConsumidores: TObjectList<TConsumidorBase>;
    FNumProdutores: Integer;
    FNumConsumidores: Integer;
    procedure EnviarSentinelas;
  public
    constructor Create(ANumProdutores, ANumConsumidores: Integer);
    destructor Destroy; override;
    procedure AdicionarProdutor(AProdutor: TProdutorBase);
    procedure AdicionarConsumidor(AConsumidor: TConsumidorBase);
    procedure Iniciar;
    procedure AguardarConclusao;
  end;

implementation

// ----------------------------------------------------------
function CriarSentinela: TItemDados;
begin
  Result.Id     := -1;
  Result.Origem := 'SENTINELA';
  Result.Carga  := nil;
end;

// ----------------------------------------------------------
// TProdutorBase
// ----------------------------------------------------------

constructor TProdutorBase.Create(AFila: TThreadedQueue<TItemDados>; AId: Integer);
begin
  inherited Create(True);
  FFila := AFila;
  FId   := AId;
  FreeOnTerminate := False;
end;

procedure TProdutorBase.Execute;
begin
  try
    Produzir;   // chama Publicar internamente para cada item
  except
    on E: Exception do
    begin
      // Log do erro — em produção, usar sistema de log centralizado
      TThread.Queue(nil, procedure
      begin
        // Substituir por: Logger.Error(Format('[PRODUTOR %d] %s', [FId, E.Message]));
      end);
    end;
  end;
  // Produtor terminou: NÃO envia sentinela aqui
  // O orquestrador envia uma sentinela por consumidor após todos produtores terminarem
end;

procedure TProdutorBase.Publicar(const AItem: TItemDados);
var
  QueueResult: TWaitResult;
begin
  // PushItem bloqueia se fila cheia (até TIMEOUT_PUSH ms)
  QueueResult := FFila.PushItem(AItem);
  case QueueResult of
    wrSignaled : { ok — item inserido };
    wrTimeout  : raise ETimeout.Create(
                   Format('[PRODUTOR %d] Timeout: fila cheia após %d ms', [FId, TIMEOUT_PUSH]));
    wrAbandoned: Exit;  // fila foi destruída
    wrError    : raise EInvalidOperation.Create(Format('[PRODUTOR %d] Erro na fila', [FId]));
  end;
end;

// ----------------------------------------------------------
// TConsumidorBase
// ----------------------------------------------------------

constructor TConsumidorBase.Create(AFila: TThreadedQueue<TItemDados>; AId: Integer);
begin
  inherited Create(True);
  FFila := AFila;
  FId   := AId;
  FreeOnTerminate := False;
end;

procedure TConsumidorBase.Execute;
var
  Item       : TItemDados;
  QueueResult: TWaitResult;
begin
  while not Terminated do
  begin
    // PopItem bloqueia até haver item (ou timeout para verificar Terminated)
    QueueResult := FFila.PopItem(Item, TIMEOUT_POP);

    case QueueResult of
      wrSignaled:
      begin
        // Verificar sentinela de encerramento
        if Item.Id = -1 then
          Break;  // consumidor encerra graciosamente

        try
          Consumir(Item);
        except
          on E: Exception do
          begin
            TThread.Queue(nil, procedure
            begin
              // Substituir por: Logger.Error(Format('[CONSUMIDOR %d] %s', [FId, E.Message]));
            end);
          end;
        end;
      end;

      wrTimeout  : { sem item no período — recheck Terminated na próxima iteração };
      wrAbandoned: Break;  // fila destruída
      wrError    : Break;  // erro irrecuperável
    end;
  end;
end;

// ----------------------------------------------------------
// TOrquestradorPC
// ----------------------------------------------------------

constructor TOrquestradorPC.Create(ANumProdutores, ANumConsumidores: Integer);
begin
  inherited Create;
  FNumProdutores   := ANumProdutores;
  FNumConsumidores := ANumConsumidores;
  FFila            := TThreadedQueue<TItemDados>.Create(
                        CAPACIDADE_FILA,
                        TIMEOUT_PUSH,    // PushItem timeout
                        TIMEOUT_POP      // PopItem timeout
                      );
  FProdutores      := TObjectList<TProdutorBase>.Create(False);   // não destrói itens
  FConsumidores    := TObjectList<TConsumidorBase>.Create(False);
end;

destructor TOrquestradorPC.Destroy;
begin
  FConsumidores.Free;
  FProdutores.Free;
  FFila.Free;
  inherited;
end;

procedure TOrquestradorPC.AdicionarProdutor(AProdutor: TProdutorBase);
begin
  FProdutores.Add(AProdutor);
end;

procedure TOrquestradorPC.AdicionarConsumidor(AConsumidor: TConsumidorBase);
begin
  FConsumidores.Add(AConsumidor);
end;

procedure TOrquestradorPC.Iniciar;
var
  T: TThread;
begin
  for T in FConsumidores do T.Start;
  for T in FProdutores   do T.Start;
end;

procedure TOrquestradorPC.EnviarSentinelas;
var
  I: Integer;
begin
  // Uma sentinela por consumidor garante que todos encerrem
  for I := 1 to FConsumidores.Count do
    FFila.PushItem(CriarSentinela);
end;

procedure TOrquestradorPC.AguardarConclusao;
var
  T: TThread;
begin
  // 1. Aguardar todos os produtores terminarem
  for T in FProdutores do T.WaitFor;

  // 2. Enviar sentinela para cada consumidor (protocolo de encerramento)
  EnviarSentinelas;

  // 3. Aguardar todos os consumidores terminarem
  for T in FConsumidores do T.WaitFor;
end;

end.

// ============================================================
// EXEMPLO DE USO:
//
// type
//   TMeuProdutor = class(TProdutorBase)
//   protected
//     procedure Produzir; override;
//   end;
//
//   TMeuConsumidor = class(TConsumidorBase)
//   protected
//     procedure Consumir(const AItem: TItemDados); override;
//   end;
//
// procedure TMeuProdutor.Produzir;
// var I: Integer; Item: TItemDados;
// begin
//   for I := 1 to 1000 do
//   begin
//     if Terminated then Break;
//     Item.Id     := I;
//     Item.Origem := Format('Produtor-%d', [Self.Id]);
//     Publicar(Item);   // bloqueia se fila cheia
//   end;
// end;
//
// procedure TMeuConsumidor.Consumir(const AItem: TItemDados);
// begin
//   // Processar AItem — executa em thread de consumidor
//   SalvarNoBanco(AItem);
// end;
//
// // Na aplicação:
// var Orc: TOrquestradorPC;
// Orc := TOrquestradorPC.Create(2 {produtores}, 4 {consumidores});
// try
//   Orc.AdicionarProdutor(TMeuProdutor.Create(Orc.FFila, 1));  // FFila precisa ser público
//   Orc.AdicionarConsumidor(TMeuConsumidor.Create(Orc.FFila, 1));
//   // ... adicionar demais produtores/consumidores
//   Orc.Iniciar;
//   Orc.AguardarConclusao;
// finally
//   // Liberar threads manualmente (FreeOnTerminate = False)
//   // ...
//   Orc.Free;
// end;
// ============================================================

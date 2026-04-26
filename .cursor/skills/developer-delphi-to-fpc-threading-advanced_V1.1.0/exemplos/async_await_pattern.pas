program async_await_pattern;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.Classes,
  System.SysUtils,
  System.Threading,
  System.SyncObjs;

// ============================================================
// Exemplo: TTask como async/await — padrão Future e continuações
//
// Delphi não tem async/await nativo, mas TTask<T> permite
// o mesmo padrão:
//   1. Lançar task (async)
//   2. Fazer outras coisas enquanto task executa
//   3. Obter resultado (.Value) quando necessário (await)
//
// Compilar:
//   dcc32 async_await_pattern.pas
//   dcc64 async_await_pattern.pas
// ============================================================

var
  GLock: TCriticalSection;

procedure Log(const S: string);
begin
  GLock.Enter;
  try WriteLn(S);
  finally GLock.Leave;
  end;
end;

// ----------------------------------------------------------
// Simula operacoes assincronas (I/O, calculo, rede)
// ----------------------------------------------------------
function BuscarDadosUsuarioAsync(AId: Integer): ITask<string>;
begin
  Result := TTask<string>.Run(function: string
  begin
    Sleep(200);  // simula chamada de rede
    Result := Format('{"id":%d,"nome":"Usuario %d","email":"u%d@exemplo.com"}',
                     [AId, AId, AId]);
  end);
end;

function CalcularDesconto(const AJson: string): ITask<Double>;
begin
  Result := TTask<Double>.Run(function: Double
  var Valor: Double;
  begin
    Sleep(100);  // simula calculo em servidor
    Valor := 1000.0 * (Length(AJson) mod 10 + 1);  // desconto ficticio
    Result := Valor * 0.15;
  end);
end;

function SalvarPedidoAsync(const AInfo: string): ITask<Boolean>;
begin
  Result := TTask<Boolean>.Run(function: Boolean
  begin
    Sleep(150);  // simula escrita no banco
    Log('[ASYNC] Pedido salvo: ' + AInfo.Substring(0, Min(30, Length(AInfo))));
    Result := True;
  end);
end;

// ----------------------------------------------------------
// Parte 1: Future simples — async/await sequencial
// ----------------------------------------------------------
procedure DemonstrarFutureSimples;
var
  TF: ITask<string>;
  Dados: string;
begin
  WriteLn('--- Future simples (sequencial) ---');

  Log('[MAIN] Disparando busca de dados (async)...');

  // ASYNC: lança a task sem esperar
  TF := BuscarDadosUsuarioAsync(42);

  Log('[MAIN] Fazendo outras coisas enquanto busca...');
  Sleep(50);
  Log('[MAIN] Ainda fazendo outras coisas...');
  Sleep(50);

  // AWAIT: bloqueia aqui ate ter o resultado
  Dados := TF.Value;
  Log('[MAIN] Dados recebidos: ' + Dados);
end;

// ----------------------------------------------------------
// Parte 2: Encadeamento de futures (composicao async)
// ----------------------------------------------------------
procedure DemonstrarEncadeamento;
var
  TFDados   : ITask<string>;
  TFDesconto: ITask<Double>;
  TFSalvar  : ITask<Boolean>;
  Dados     : string;
  Desconto  : Double;
  Sucesso   : Boolean;
begin
  WriteLn;
  WriteLn('--- Encadeamento de futures ---');

  // Etapa 1: buscar usuario (async)
  TFDados := BuscarDadosUsuarioAsync(7);
  Log('[MAIN] [1/3] Buscando usuario...');

  // Etapa 2: calcular desconto com o resultado (await + async)
  Dados    := TFDados.Value;            // await etapa 1
  TFDesconto := CalcularDesconto(Dados); // lança etapa 2 com resultado de 1
  Log(Format('[MAIN] [2/3] Usuario obtido. Calculando desconto para: %s', [Dados.Substring(0,20)]));

  // Etapa 3: salvar pedido (await + async)
  Desconto := TFDesconto.Value;          // await etapa 2
  var Info := Format('usuario=%d desconto=%.2f', [7, Desconto]);
  TFSalvar := SalvarPedidoAsync(Info);  // lança etapa 3
  Log(Format('[MAIN] [3/3] Desconto calculado: %.2f. Salvando pedido...', [Desconto]));

  Sucesso := TFSalvar.Value;             // await etapa 3
  Log(Format('[MAIN] Pipeline concluido. Sucesso: %s', [BoolToStr(Sucesso, True)]));
end;

// ----------------------------------------------------------
// Parte 3: Futures em paralelo — aguardar todos
// ----------------------------------------------------------
procedure DemonstrarParalelo;
var
  Tasks   : array[1..3] of ITask<string>;
  Inicio  : TDateTime;
  I       : Integer;
begin
  WriteLn;
  WriteLn('--- Futures em paralelo (fan-out/fan-in) ---');

  Inicio := Now;

  // Fan-out: disparar todas as buscas ao mesmo tempo
  Tasks[1] := BuscarDadosUsuarioAsync(1);
  Tasks[2] := BuscarDadosUsuarioAsync(2);
  Tasks[3] := BuscarDadosUsuarioAsync(3);
  Log('[MAIN] 3 buscas disparadas em paralelo...');

  // Fan-in: coletar resultados (await cada um)
  for I := 1 to 3 do
  begin
    var Dados := Tasks[I].Value;
    Log(Format('[MAIN] Usuario %d: %s', [I, Dados.Substring(0, 25)]));
  end;

  var Ms := Round((Now - Inicio) * 24 * 60 * 60 * 1000);
  WriteLn(Format('[MAIN] 3 buscas paralelas em %d ms (serial seria ~600 ms)', [Ms]));
end;

// ----------------------------------------------------------
// Parte 4: Continuacao na UI thread com Queue
// ----------------------------------------------------------
procedure DemonstrarContinuacaoUI;
var
  T: ITask;
begin
  WriteLn;
  WriteLn('--- Continuacao na UI thread com Queue ---');

  // Padrao: Task de background → notifica UI via Queue ao concluir
  T := TTask.Run(procedure
  var Resultado: string;
  begin
    Log('[BG] Processando dados pesados...');
    Sleep(300);
    Resultado := 'Dados processados com sucesso';

    // Continuacao: atualizar UI (main thread) ao concluir
    TThread.Queue(nil, procedure
    begin
      // Em app VCL/FMX: Label1.Caption := Resultado; ProgressBar1.Position := 100;
      Log('[UI] Continuacao executou na main thread: ' + Resultado);
    end);
  end);

  T.Wait;
  Sleep(50);  // aguardar Queue ser processada (em app real, nao seria necessario)
end;

// ----------------------------------------------------------
// Parte 5: Tratamento de erro em futures
// ----------------------------------------------------------
procedure DemonstrarErroFuture;
var
  TF: ITask<Integer>;
begin
  WriteLn;
  WriteLn('--- Erro em TTask<T>.Value ---');

  TF := TTask<Integer>.Run(function: Integer
  begin
    Sleep(50);
    raise EInvalidOperation.Create('Falha ao calcular valor');
    Result := 0;  // nunca alcancado
  end);

  try
    var V := TF.Value;  // relança a excecao da task aqui
    Log(Format('[MAIN] Valor: %d', [V]));
  except
    on E: EInvalidOperation do
      Log('[MAIN] Excecao capturada via .Value: ' + E.Message);
    on E: EAggregateException do
      Log('[MAIN] AggregateException: ' + E.InnerException.Message);
  end;
end;

// ----------------------------------------------------------
// Programa principal
// ----------------------------------------------------------
begin
  GLock := TCriticalSection.Create;
  try
    WriteLn('=== Async/Await Pattern com TTask<T> ===');
    WriteLn;

    DemonstrarFutureSimples;
    DemonstrarEncadeamento;
    DemonstrarParalelo;
    DemonstrarContinuacaoUI;
    DemonstrarErroFuture;

  finally
    GLock.Free;
  end;

  WriteLn;
  WriteLn('Pressione Enter para sair.');
  ReadLn;
end.

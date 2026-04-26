program tparallel;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.Classes,
  System.SysUtils,
  System.Threading,
  System.SyncObjs,
  System.Generics.Collections;

// ============================================================
// Exemplo: TParallel.For — iteracao paralela, LoopState.Break,
//          acumuladores por thread, deteccao de excecoes
//
// Compilar:
//   dcc32 tparallel.pas
//   dcc64 tparallel.pas
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
// Parte 1: TParallel.For basico — processamento paralelo de array
// ----------------------------------------------------------
procedure DemonstrarBasico;
const N = 10;
var
  Dados    : array[0..N-1] of Integer;
  Resultados: array[0..N-1] of Integer;
  I        : Integer;
  Inicio   : TDateTime;
begin
  WriteLn('--- TParallel.For basico ---');

  for I := 0 to N - 1 do Dados[I] := (I + 1) * 10;

  Inicio := Now;

  TParallel.For(0, N - 1, procedure(I: Integer)
  begin
    // Cada iteracao roda em thread diferente — sem compartilhamento de escrita
    Sleep(20);  // simula calculo pesado
    Resultados[I] := Dados[I] * Dados[I];  // escrita em posicao exclusiva: seguro
  end);

  // Aqui todas as iteracoes JA concluiram (TParallel.For e bloqueante)
  var Ms := Round((Now - Inicio) * 24 * 60 * 60 * 1000);
  Write(Format('[MAIN] Concluido em %d ms. Resultados: ', [Ms]));
  for I := 0 to N - 1 do Write(Resultados[I], ' ');
  WriteLn;
end;

// ----------------------------------------------------------
// Parte 2: LoopState.Break — parar ao encontrar valor
// ----------------------------------------------------------
procedure DemonstrarBreak;
const N = 100;
var
  Dados : array[0..N-1] of Integer;
  I     : Integer;
  Alvo  : Integer;
  Achado: Boolean;
begin
  WriteLn;
  WriteLn('--- TParallel.For com LoopState.Break ---');

  for I := 0 to N - 1 do Dados[I] := I;
  Alvo   := 42;
  Achado := False;

  TParallel.For(0, N - 1, procedure(I: Integer; LoopState: TParallelLoopState)
  begin
    if Dados[I] = Alvo then
    begin
      TInterlocked.Exchange(Integer(Achado), Integer(True));  // escrita atomica
      Log(Format('[THREAD] Encontrou alvo=%d em I=%d — chamando Break', [Alvo, I]));
      LoopState.Break;
      // Iteracoes com indice > I nao serao INICIADAS apos Break
      // Iteracoes ja em execucao continuam ate terminar
    end;
  end);

  WriteLn(Format('[MAIN] Alvo %d %s', [Alvo, IfThen(Achado, 'encontrado', 'nao encontrado')]));
end;

// ----------------------------------------------------------
// Parte 3: Acumulador com TInterlocked — soma segura em paralelo
// ----------------------------------------------------------
procedure DemonstrarAcumulador;
const N = 1000;
var
  Dados       : array[0..N-1] of Integer;
  TotalParalelo: Integer;
  TotalSequencial: Int64;
  I           : Integer;
begin
  WriteLn;
  WriteLn('--- Acumulador paralelo com TInterlocked ---');

  for I := 0 to N - 1 do Dados[I] := I + 1;  // 1..1000

  // Calculo sequencial para referencia
  TotalSequencial := 0;
  for I := 0 to N - 1 do Inc(TotalSequencial, Dados[I]);

  // Calculo paralelo — CORRETO com TInterlocked
  TotalParalelo := 0;
  TParallel.For(0, N - 1, procedure(I: Integer)
  begin
    TInterlocked.Add(TotalParalelo, Dados[I]);  // atomico
  end);

  WriteLn(Format('Total sequencial : %d', [TotalSequencial]));
  WriteLn(Format('Total paralelo   : %d', [TotalParalelo]));
  WriteLn(Format('Correto          : %s', [IfThen(TotalSequencial = TotalParalelo, 'SIM', 'NAO')]));
end;

// ----------------------------------------------------------
// Parte 4: Acumulacao local por thread — melhor performance
//          Evita false sharing e contenção em TInterlocked
// ----------------------------------------------------------
procedure DemonstrarAcumulacaoLocal;
const N = 10000;
var
  Dados         : array[0..N-1] of Integer;
  TotalInterlocked: Integer;
  TotalLocal    : Integer;
  I             : Integer;
  InicioA, InicioB: TDateTime;
  MsA, MsB      : Integer;
begin
  WriteLn;
  WriteLn('--- Acumulacao local vs TInterlocked em cada iteracao ---');

  for I := 0 to N - 1 do Dados[I] := 1;

  // Abordagem A: TInterlocked em CADA iteracao (mais contencao)
  TotalInterlocked := 0;
  InicioA := Now;
  TParallel.For(0, N - 1, procedure(I: Integer)
  begin
    TInterlocked.Add(TotalInterlocked, Dados[I]);
  end);
  MsA := Round((Now - InicioA) * 24 * 60 * 60 * 1000);

  // Abordagem B: acumular localmente, TInterlocked so ao final de cada "chunk"
  // Nota: TParallel.For nao expoe chunks diretamente; simulamos com indice
  TotalLocal := 0;
  InicioB := Now;
  TParallel.For(0, N - 1, procedure(I: Integer)
  var Local: Integer;
  begin
    Local := Dados[I];  // acumula localmente
    // Em cenario real: processar bloco e so entao somar
    TInterlocked.Add(TotalLocal, Local);
    // Para chunk real: dividir o range manualmente com TTask por segmentos
  end);
  MsB := Round((Now - InicioB) * 24 * 60 * 60 * 1000);

  WriteLn(Format('Total A (interlocked por iter): %d em %d ms', [TotalInterlocked, MsA]));
  WriteLn(Format('Total B (local por iter)      : %d em %d ms', [TotalLocal, MsB]));
end;

// ----------------------------------------------------------
// Parte 5: Verificar resultado do loop (LoopResult)
// ----------------------------------------------------------
procedure DemonstrarLoopResult;
const N = 50;
var
  Info: TParallelLoopResult;
  FalhouEm: Integer;
begin
  WriteLn;
  WriteLn('--- TParallelLoopResult ---');

  FalhouEm := -1;

  Info := TParallel.For(0, N - 1, procedure(I: Integer; LoopState: TParallelLoopState)
  begin
    if I = 25 then
    begin
      TInterlocked.CompareExchange(FalhouEm, I, -1);
      LoopState.Break;
    end;
    Sleep(2);
  end);

  WriteLn(Format('Loop completou  : %s', [BoolToStr(Info.Completed, True)]));
  WriteLn(Format('Loop exceptional: %s', [BoolToStr(Info.IsExceptional, True)]));
  if FalhouEm >= 0 then
    WriteLn(Format('Break chamado em: %d', [FalhouEm]));
end;

// ----------------------------------------------------------
// Programa principal
// ----------------------------------------------------------
begin
  GLock := TCriticalSection.Create;
  try
    WriteLn('=== Exemplos TParallel.For ===');
    WriteLn;

    DemonstrarBasico;
    DemonstrarBreak;
    DemonstrarAcumulador;
    DemonstrarAcumulacaoLocal;
    DemonstrarLoopResult;

  finally
    GLock.Free;
  end;

  WriteLn;
  WriteLn('Pressione Enter para sair.');
  ReadLn;
end.

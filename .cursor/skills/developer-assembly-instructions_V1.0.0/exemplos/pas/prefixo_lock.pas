unit prefixo_lock;
{
  prefixo_lock.pas
  Demonstra LOCK XADD para incremento atômico thread-safe.

  LOCK: prefixo que garante acesso exclusivo ao barramento durante a instrução.
  Só funciona com instruções que acessam memória: ADD, AND, OR, XOR, INC, DEC,
  XADD, XCHG (XCHG tem LOCK implícito quando acessa memória), BTC, BTS, BTR, CMPXCHG.

  Compilar: dcc32 prefixo_lock.pas
}

{$APPTYPE CONSOLE}
program prefixo_lock;

uses
  Classes,
  SysUtils;

var
  GContador: Integer;     // contador compartilhado entre threads

// Incremento atômico: retorna o valor ANTERIOR (antes do incremento)
// Equivale a: oldVal = __sync_fetch_and_add(&GContador, 1)
function IncrementoAtomico(var Destino: Integer): Integer;
asm
  // EAX = @Destino (ponteiro para a variável)
  MOV   ECX, 1          // ECX = valor a adicionar
  LOCK  XADD [EAX], ECX // [EAX] += ECX; ECX = valor anterior (atômico)
  MOV   EAX, ECX        // retornar valor anterior
end;

// Decremento atômico
function DecrementoAtomico(var Destino: Integer): Integer;
asm
  MOV   ECX, -1
  LOCK  XADD [EAX], ECX // Destino -= 1; ECX = valor anterior
  MOV   EAX, ECX
end;

// Adicionar valor atômico: retorna valor anterior
function AdicionarAtomico(var Destino: Integer; Valor: Integer): Integer;
asm
  // EAX = @Destino, EDX = Valor
  LOCK  XADD [EAX], EDX // Destino += Valor; EDX = valor anterior
  MOV   EAX, EDX
end;

// Compare-and-Swap (CAS): se Destino = Esperado, substitui por Novo
// Retorna o valor ANTIGO (independente de ter trocado ou não)
function CompararTrocar(var Destino: Integer; Esperado, Novo: Integer): Integer;
// EAX = @Destino, EDX = Esperado, ECX = Novo
asm
  // CMPXCHG: se [EAX] = AL/AX/EAX (implicit), troca por ECX
  // O "Esperado" deve estar em EAX para CMPXCHG
  PUSH EBX
  MOV  EBX, ECX         // EBX = Novo
  MOV  ECX, EDX         // ECX = Esperado
  MOV  EDX, EAX         // EDX = @Destino
  MOV  EAX, ECX         // EAX = Esperado (CMPXCHG usa EAX como comparador)
  LOCK CMPXCHG [EDX], EBX  // se [EDX] = EAX, [EDX] = EBX; EAX = valor original
  // EAX contém o valor anterior (retorno automático)
  POP  EBX
end;

// LOCK INC e LOCK DEC direto (mais simples, mas não retorna o valor anterior)
procedure IncrAtomicoDireto(var Destino: Integer);
asm
  LOCK INC dword ptr [EAX]    // Destino++ atômico, sem retorno de valor
end;

procedure DecrAtomicoDireto(var Destino: Integer);
asm
  LOCK DEC dword ptr [EAX]
end;

// Thread que incrementa o contador
type
  TWorkerThread = class(TThread)
  private
    FIteracoes: Integer;
  public
    constructor Create(Iteracoes: Integer);
    procedure Execute; override;
  end;

constructor TWorkerThread.Create(Iteracoes: Integer);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FIteracoes := Iteracoes;
end;

procedure TWorkerThread.Execute;
var
  I: Integer;
begin
  for I := 1 to FIteracoes do
    IncrementoAtomico(GContador);
end;

const
  N_THREADS = 4;
  N_ITERS = 1000;

var
  Threads: array[0..N_THREADS-1] of TWorkerThread;
  I, OldVal: Integer;

begin
  WriteLn('=== LOCK XADD — Incremento Atômico ===');
  WriteLn;

  // Testes unitários
  GContador := 0;
  OldVal := IncrementoAtomico(GContador);
  WriteLn('IncrementoAtomico(0): oldVal=', OldVal, ' novoVal=', GContador);  // 0, 1

  OldVal := IncrementoAtomico(GContador);
  WriteLn('IncrementoAtomico(1): oldVal=', OldVal, ' novoVal=', GContador);  // 1, 2

  OldVal := DecrementoAtomico(GContador);
  WriteLn('DecrementoAtomico(2): oldVal=', OldVal, ' novoVal=', GContador);  // 2, 1

  OldVal := AdicionarAtomico(GContador, 10);
  WriteLn('AdicionarAtomico(1, 10): oldVal=', OldVal, ' novoVal=', GContador); // 1, 11
  WriteLn;

  // Teste de Compare-and-Swap
  GContador := 42;
  OldVal := CompararTrocar(GContador, 42, 100);  // Esperado=42, Novo=100
  WriteLn('CAS(42→100), Esperado=42: oldVal=', OldVal, ' GContador=', GContador); // 42, 100

  OldVal := CompararTrocar(GContador, 42, 200);  // Esperado=42 (mas agora é 100 → falha)
  WriteLn('CAS(42→200), Esperado=42: oldVal=', OldVal, ' GContador=', GContador); // 100, 100
  WriteLn;

  // Teste multi-thread: sem race condition graças ao LOCK
  WriteLn(Format('Iniciando %d threads com %d iteracoes cada...', [N_THREADS, N_ITERS]));
  GContador := 0;
  for I := 0 to N_THREADS - 1 do
    Threads[I] := TWorkerThread.Create(N_ITERS);

  // Aguardar todas as threads
  Sleep(500);  // simples espera (em código real, usar WaitForMultipleObjects)

  WriteLn(Format('Esperado: %d', [N_THREADS * N_ITERS]));
  WriteLn(Format('Obtido:   %d', [GContador]));
  WriteLn('Correto: ', GContador = N_THREADS * N_ITERS);
  WriteLn;

  ReadLn;
end.

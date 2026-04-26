unit TEMPLATE_atomic_inc;
{
  TEMPLATE_atomic_inc.pas
  Template para incremento atômico com LOCK XADD.
  Padrão para contadores thread-safe sem TInterlocked ou sistema de runtime.

  INSTRUÇÕES DE USO:
  1. Copiar e renomear
  2. Substituir o tipo da variável se necessário (suporta 8/16/32/64-bit)
  3. Usar AtomicInc/AtomicDec para todos os acessos ao contador compartilhado
  4. Nunca misturar acessos não-atômicos (sem LOCK) com acessos atômicos

  NOTA: Em Delphi moderno, usar System.TInterlocked.Increment em vez disto.
  Este template é didático e para casos onde o controle fino é necessário.
}

{$APPTYPE CONSOLE}
program TEMPLATE_atomic_inc;

var
  GContador: Integer;

// Incremento atômico de 32-bit: retorna valor ANTERIOR
function AtomicInc(var Destino: Integer): Integer; overload;
asm
  MOV   ECX, 1
  LOCK  XADD [EAX], ECX    // [EAX] += 1; ECX = valor_anterior (atômico)
  MOV   EAX, ECX            // retorna valor anterior
end;

// Decremento atômico de 32-bit: retorna valor ANTERIOR
function AtomicDec(var Destino: Integer): Integer; overload;
asm
  MOV   ECX, -1
  LOCK  XADD [EAX], ECX    // [EAX] -= 1; ECX = valor_anterior
  MOV   EAX, ECX
end;

// Adicionar atômico: retorna valor ANTERIOR
function AtomicAdd(var Destino: Integer; Delta: Integer): Integer;
asm
  // EAX = @Destino, EDX = Delta
  LOCK  XADD [EAX], EDX    // [EAX] += Delta; EDX = valor_anterior
  MOV   EAX, EDX
end;

// Compare-and-Swap (CAS) 32-bit
// Se Destino = Esperado, então Destino = NovoValor
// Retorna valor ANTIGO (independente de ter trocado)
function AtomicCAS(var Destino: Integer; Esperado, NovoValor: Integer): Integer;
// EAX = @Destino, EDX = Esperado, ECX = NovoValor
asm
  PUSH  EBX
  MOV   EBX, ECX           // EBX = NovoValor
  MOV   ECX, EDX           // ECX = Esperado
  MOV   EDX, EAX           // EDX = @Destino
  MOV   EAX, ECX           // EAX = Esperado (CMPXCHG compara com EAX)
  LOCK  CMPXCHG [EDX], EBX // se [EDX]=EAX, [EDX]=EBX; EAX=valor_original
  POP   EBX
end;

// LOCK INC direto (mais simples — não retorna valor)
procedure AtomicIncVoid(var Destino: Integer);
asm
  LOCK  INC dword ptr [EAX]
end;

// Leitura atômica (em x86, leituras de 32-bit alinhadas já são atômicas)
// Este wrapper é para documentação/portabilidade
function AtomicRead(const Destino: Integer): Integer;
begin
  Result := Destino;  // em x86, leitura de 32-bit alinhado é atômica
end;

// Escrita atômica (em x86, escritas de 32-bit alinhadas já são atômicas)
procedure AtomicWrite(var Destino: Integer; Valor: Integer);
begin
  Destino := Valor;  // em x86, escrita de 32-bit alinhado é atômica
end;

var
  OldVal: Integer;

begin
  WriteLn('=== Template Incremento Atômico ===');
  WriteLn;

  GContador := 0;
  WriteLn('Inicial: ', GContador);

  OldVal := AtomicInc(GContador);
  WriteLn('Após AtomicInc: old=', OldVal, ' novo=', GContador);   // 0, 1

  OldVal := AtomicInc(GContador);
  WriteLn('Após AtomicInc: old=', OldVal, ' novo=', GContador);   // 1, 2

  OldVal := AtomicDec(GContador);
  WriteLn('Após AtomicDec: old=', OldVal, ' novo=', GContador);   // 2, 1

  OldVal := AtomicAdd(GContador, 10);
  WriteLn('Após AtomicAdd(10): old=', OldVal, ' novo=', GContador); // 1, 11

  WriteLn;

  // CAS: troca 11 por 100
  OldVal := AtomicCAS(GContador, 11, 100);
  WriteLn('CAS(11→100): old=', OldVal, ' novo=', GContador, ' sucesso=', OldVal=11); // 11, 100, True

  // CAS com valor errado: não troca
  OldVal := AtomicCAS(GContador, 11, 200);
  WriteLn('CAS(11→200): old=', OldVal, ' novo=', GContador, ' sucesso=', OldVal=11); // 100, 100, False

  ReadLn;
end.

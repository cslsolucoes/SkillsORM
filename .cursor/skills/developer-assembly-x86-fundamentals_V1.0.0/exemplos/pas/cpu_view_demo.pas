unit cpu_view_demo;
{
  cpu_view_demo.pas
  Procedura mínima para inspecionar no CPU View do RAD Studio.

  Como usar:
  1. Compilar com dcc32 ou dcc64
  2. Abrir no RAD Studio
  3. View -> Debug Windows -> CPU View (Ctrl+Alt+C)
  4. Colocar breakpoint na linha do bloco asm
  5. Executar com F9; quando parar, observar:
     - Painel superior: disassembly das instruções
     - Painel esquerdo: registradores em tempo real
     - Painel inferior: conteúdo da stack

  Compilar: dcc32 cpu_view_demo.pas  ou  dcc64 cpu_view_demo.pas
}

{$APPTYPE CONSOLE}

program cpu_view_demo;

procedure DemoRegistradores;
var
  A, B, C: Integer;
begin
  A := 10;
  B := 20;
  C := 0;

  asm
    // Ponto de observação: colocar breakpoint AQUI no CPU View
    // No painel de registradores, observar EAX, EDX, ECX antes e depois

    MOV EAX, A      // EAX = 10
    MOV EDX, B      // EDX = 20

    // Operação simples
    ADD EAX, EDX    // EAX = 30

    // Multiplicação: observar como EDX muda
    MOV EDX, 3
    IMUL EDX        // EDX:EAX = EAX * EDX = 90; EDX = 0 (resultado cabe em EAX)

    MOV C, EAX      // C = 90
  end;

  WriteLn('A=', A, ' B=', B, ' C=', C);
end;

procedure DemoFlagsEFLAGS;
var
  X: Integer;
begin
  X := 5;
  asm
    // Demonstra como CMP afeta EFLAGS
    // No CPU View, observar o painel de flags após cada CMP

    MOV EAX, X      // EAX = 5

    CMP EAX, 5      // EAX - 5 = 0  → ZF=1, SF=0, CF=0, OF=0
    CMP EAX, 10     // EAX - 10 = -5 → ZF=0, SF=1, CF=1, OF=0
    CMP EAX, 0      // EAX - 0 = 5  → ZF=0, SF=0, CF=0, OF=0

    TEST EAX, EAX   // EAX AND EAX = 5 → ZF=0 (não é zero)
    TEST EAX, 1     // EAX AND 1 = 1  → ZF=0 (bit 0 está setado)
    TEST EAX, 2     // EAX AND 2 = 0  → ZF=1 (bit 1 NÃO está setado)

    // Operações de shift — observar CF
    MOV EAX, 0x80000000  // bit 31 setado
    SHL EAX, 1           // CF = 1 (bit deslocado para fora), EAX = 0
  end;
end;

begin
  WriteLn('=== Demo CPU View ===');
  DemoRegistradores;
  DemoFlagsEFLAGS;
  WriteLn('Concluido.');
  ReadLn;
end.

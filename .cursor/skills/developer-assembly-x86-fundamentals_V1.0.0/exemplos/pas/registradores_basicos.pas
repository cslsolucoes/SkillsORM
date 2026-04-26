unit registradores_basicos;
{
  registradores_basicos.pas
  Demonstra movimentação de valores entre registradores no bloco asm..end do Delphi.
  Compatível com dcc32 (32-bit).

  Compilar: dcc32 registradores_basicos.pas
}

{$APPTYPE CONSOLE}

program registradores_basicos;

// Retorna A + B usando registradores EAX e EDX
function Soma(A, B: Integer): Integer;
asm
  // Convenção "register" do Delphi 32-bit:
  // EAX = A (1° param), EDX = B (2° param)
  // Retorno em EAX
  ADD EAX, EDX      // EAX = A + B
end;

// Demonstra cópia e manipulação de registradores
procedure DemoMovimentos;
var
  X, Y, Z: Integer;
begin
  X := 100;
  Y := 200;
  Z := 0;

  asm
    // Carregar variáveis locais nos registradores
    MOV EAX, X         // EAX = 100
    MOV ECX, Y         // ECX = 200

    // Operações entre registradores
    MOV EDX, EAX       // EDX = EAX = 100 (cópia)
    XCHG EAX, ECX      // swap: EAX = 200, ECX = 100

    // Operações de byte, word dentro de EAX
    MOV AL, 0xFF       // altera apenas byte baixo: EAX = 0x000000FF (era 200 = 0xC8)
    // Atenção: AH ainda guarda bits [15:8] do valor anterior

    MOV AH, 0x00       // limpa byte alto: AX = 0x00FF
    MOVZX EAX, AX      // zero-extend AX para EAX: EAX = 0x000000FF = 255

    // Salvar resultado
    MOV Z, EAX         // Z = 255
  end;

  WriteLn('X=', X, ' Y=', Y, ' Z=', Z);
end;

// Demonstra preservação obrigatória de EBX, ESI, EDI em 32-bit
procedure DemoPreservacao;
var
  Resultado: Integer;
begin
  Resultado := 0;
  asm
    // EBX é callee-saved — DEVE ser preservado!
    PUSH EBX            // salva EBX
    PUSH ESI            // salva ESI

    MOV EBX, 7         // usa EBX livremente
    MOV ESI, 6
    IMUL EBX, ESI      // EBX = 7 * 6 = 42
    MOV Resultado, EBX

    POP ESI             // restaura ESI
    POP EBX             // restaura EBX
  end;
  WriteLn('7 * 6 = ', Resultado);
end;

begin
  WriteLn('=== Registradores Basicos ===');
  WriteLn('Soma(3, 4) = ', Soma(3, 4));
  DemoMovimentos;
  DemoPreservacao;
  ReadLn;
end.

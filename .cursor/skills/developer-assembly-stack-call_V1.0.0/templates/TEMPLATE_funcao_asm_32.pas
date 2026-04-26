unit TEMPLATE_funcao_asm_32;
{
  TEMPLATE_funcao_asm_32.pas
  Esqueleto completo de função ASM pura Win32.

  INSTRUÇÕES DE USO:
  1. Copiar e renomear
  2. Definir os parâmetros (convenção register: EAX, EDX, ECX)
  3. Implementar a lógica no bloco asm
  4. Manter PUSH/POP dos registradores callee-saved usados
  5. Certificar que o retorno está em EAX (inteiro) ou ST(0) (float)

  CONVENÇÃO REGISTER (padrão Delphi 32-bit):
    EAX = 1° param ou Self
    EDX = 2° param
    ECX = 3° param
    Retorno: EAX (inteiro), ST(0) (float), EDX:EAX (Int64)
    Preservar: EBX, ESI, EDI, EBP, ESP
}

{$APPTYPE CONSOLE}
program TEMPLATE_funcao_asm_32;

// ---------------------------------------------------------------------------
// TEMPLATE: Função com retorno inteiro
// Parâmetros: EAX=P1, EDX=P2, ECX=P3
// ---------------------------------------------------------------------------
function MinhaFuncao(P1, P2, P3: Integer): Integer;
asm
  // === SALVAR registradores callee-saved que serão usados ===
  PUSH EBX
  // PUSH ESI   // descomentar se necessário
  // PUSH EDI   // descomentar se necessário

  // === IMPLEMENTAÇÃO ===
  // Substitua esta seção pela lógica desejada:
  MOV  EBX, EAX     // EBX = P1
  ADD  EBX, EDX     // EBX = P1 + P2
  ADD  EBX, ECX     // EBX = P1 + P2 + P3
  MOV  EAX, EBX     // EAX = resultado (retorno implícito)

  // === RESTAURAR na ordem INVERSA ===
  POP  EBX
  // POP  EDI
  // POP  ESI
end;

// ---------------------------------------------------------------------------
// TEMPLATE: Método de objeto (Self em EAX)
// ---------------------------------------------------------------------------
type
  TMinhaClasse = class
  private
    FCampo: Integer;
  public
    constructor Create(V: Integer);
    function MeuMetodo(Param: Integer): Integer;
    procedure MeuProcedimento(Param: Integer);
  end;

constructor TMinhaClasse.Create(V: Integer);
begin
  inherited Create;
  FCampo := V;
end;

function TMinhaClasse.MeuMetodo(Param: Integer): Integer;
// EAX = Self, EDX = Param
asm
  PUSH EBX
  MOV  EBX, EAX            // EBX = Self
  MOV  EAX, [EBX].TMinhaClasse.FCampo   // EAX = Self.FCampo
  ADD  EAX, EDX            // EAX = FCampo + Param
  POP  EBX
end;

procedure TMinhaClasse.MeuProcedimento(Param: Integer);
// EAX = Self, EDX = Param
asm
  ADD  [EAX].TMinhaClasse.FCampo, EDX   // FCampo += Param
end;

// ---------------------------------------------------------------------------
// TEMPLATE: Função com loop sobre array
// EAX = Array Ptr, EDX = N
// ---------------------------------------------------------------------------
function SomarArray(Arr: PInteger; N: Integer): Integer;
asm
  PUSH EBX
  PUSH ESI

  MOV  EBX, EAX          // EBX = Arr
  MOV  ESI, EDX          // ESI = N
  XOR  EAX, EAX          // EAX = 0 (acumulador)

  TEST ESI, ESI
  JLE  @fim

@loop:
  ADD  EAX, [EBX]        // EAX += *Arr
  ADD  EBX, 4            // Arr++
  DEC  ESI
  JNZ  @loop

@fim:
  POP  ESI
  POP  EBX
end;

var
  Obj: TMinhaClasse;
  Arr: array[0..4] of Integer;
  I: Integer;

begin
  WriteLn('=== Template Função ASM Win32 ===');
  WriteLn;

  WriteLn('MinhaFuncao(1, 2, 3) = ', MinhaFuncao(1, 2, 3));  // 6

  Obj := TMinhaClasse.Create(100);
  try
    WriteLn('FCampo = 100');
    WriteLn('MeuMetodo(50) = ', Obj.MeuMetodo(50));   // 150
    Obj.MeuProcedimento(25);
    WriteLn('Após MeuProcedimento(25): ', Obj.MeuMetodo(0)); // 125
  finally
    Obj.Free;
  end;

  for I := 0 to 4 do Arr[I] := (I+1) * 10;
  WriteLn('SomarArray([10,20,30,40,50]) = ', SomarArray(@Arr[0], 5)); // 150

  ReadLn;
end.

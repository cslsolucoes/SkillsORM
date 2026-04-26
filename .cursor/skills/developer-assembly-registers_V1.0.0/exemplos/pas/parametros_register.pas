unit parametros_register;
{
  parametros_register.pas
  Demonstra a convenção "register" do Delphi 32-bit:
  EAX = 1° parâmetro, EDX = 2° parâmetro, ECX = 3° parâmetro

  Compilar: dcc32 parametros_register.pas
}

{$APPTYPE CONSOLE}
program parametros_register;

// ---------------------------------------------------------------------------
// Função com 3 parâmetros — convenção "register" (padrão do Delphi)
// EAX = P1, EDX = P2, ECX = P3
// Retorno: EAX
// ---------------------------------------------------------------------------
function Soma3(P1, P2, P3: Integer): Integer;
// Entrada: EAX=P1, EDX=P2, ECX=P3
// Saída:   EAX = P1 + P2 + P3
asm
  ADD EAX, EDX     // EAX = P1 + P2
  ADD EAX, ECX     // EAX = P1 + P2 + P3
end;

// ---------------------------------------------------------------------------
// Demonstração explícita: ler e exibir os valores nos registradores
// ---------------------------------------------------------------------------
procedure MostrarParametros(P1, P2, P3: Integer);
var
  ValEAX, ValEDX, ValECX: Integer;
begin
  ValEAX := 0;
  ValEDX := 0;
  ValECX := 0;
  asm
    // EAX = P1, EDX = P2, ECX = P3 (convenção register)
    MOV ValEAX, EAX    // captura P1 de EAX
    MOV ValEDX, EDX    // captura P2 de EDX
    MOV ValECX, ECX    // captura P3 de ECX
  end;
  WriteLn('  P1 em EAX = ', ValEAX);
  WriteLn('  P2 em EDX = ', ValEDX);
  WriteLn('  P3 em ECX = ', ValECX);
end;

// ---------------------------------------------------------------------------
// 4° parâmetro vai para a stack
// ---------------------------------------------------------------------------
function Soma4(P1, P2, P3, P4: Integer): Integer;
// P1 = EAX, P2 = EDX, P3 = ECX, P4 = [EBP+8] (stack, após prologue)
// Esta função usa Pascal + asm combinados
var
  S: Integer;
begin
  S := 0;
  asm
    MOV EAX, P1      // recarregar P1 (EAX pode ter sido alterado pelo begin/var)
    ADD EAX, P2
    ADD EAX, P3
    ADD EAX, P4      // P4 é acessado como variável local (o Delphi resolve o offset)
    MOV S, EAX
  end;
  Result := S;
end;

// ---------------------------------------------------------------------------
// Função com resultado em Int64 (retorno em EDX:EAX em 32-bit)
// ---------------------------------------------------------------------------
function MultiplicaInt64(A, B: Integer): Int64;
// A = EAX, B = EDX
// Retorno: Int64 em EDX:EAX
asm
  IMUL EDX          // EDX:EAX = EAX * EDX (com sinal, 64-bit resultado)
  // Delphi 32-bit monta EDX:EAX como Int64 automaticamente
end;

// ---------------------------------------------------------------------------
// Passagem de self em método de objeto
// ---------------------------------------------------------------------------
type
  TMinhaClasse = class
  private
    FValor: Integer;
  public
    constructor Create(V: Integer);
    function GetValorViaAsm: Integer;
    procedure SomarViaAsm(N: Integer);
  end;

constructor TMinhaClasse.Create(V: Integer);
begin
  inherited Create;
  FValor := V;
end;

function TMinhaClasse.GetValorViaAsm: Integer;
// EAX = Self (ponteiro para o objeto)
// Retorno: EAX = Self.FValor
asm
  // EAX = Self; FValor está no offset 4 (após VMT pointer de 4 bytes)
  // NOTA: o offset real depende do compilador e outros campos — usar variável pelo nome!
  MOV EAX, [EAX].TMinhaClasse.FValor    // acesso pelo nome do campo
end;

procedure TMinhaClasse.SomarViaAsm(N: Integer);
// EAX = Self, EDX = N
asm
  // Self = EAX, N = EDX
  ADD [EAX].TMinhaClasse.FValor, EDX    // FValor += N
end;

var
  Obj: TMinhaClasse;

begin
  WriteLn('=== Convenção Register Delphi 32-bit ===');
  WriteLn;

  WriteLn('Soma3(1, 2, 3) = ', Soma3(1, 2, 3));      // 6
  WriteLn('Soma3(10, 20, 30) = ', Soma3(10, 20, 30)); // 60
  WriteLn;

  WriteLn('Parâmetros chegam em:');
  MostrarParametros(111, 222, 333);
  WriteLn;

  WriteLn('Soma4(1, 2, 3, 4) = ', Soma4(1, 2, 3, 4)); // 10
  WriteLn;

  WriteLn('7 * 8 = ', MultiplicaInt64(7, 8));          // 56
  WriteLn('1000000 * 1000000 = ', MultiplicaInt64(1000000, 1000000)); // 1000000000000
  WriteLn;

  Obj := TMinhaClasse.Create(42);
  try
    WriteLn('Objeto.FValor = ', Obj.GetValorViaAsm);   // 42
    Obj.SomarViaAsm(8);
    WriteLn('Após SomarViaAsm(8) = ', Obj.GetValorViaAsm); // 50
  finally
    Obj.Free;
  end;

  ReadLn;
end.

unit self_access;
{
  self_access.pas
  Demonstra como Self chega em EAX (32-bit) e como acessar campos
  do objeto via [EAX + offset] ou pelo nome do campo no asm do Delphi.

  Compilar: dcc32 self_access.pas
}

{$APPTYPE CONSOLE}
program self_access;

type
  // Objeto com múltiplos campos para demonstrar offsets
  TContador = class
  private
    FInicial: Integer;   // offset 4 (após VMT ptr de 4 bytes em 32-bit)
    FAtual: Integer;     // offset 8
    FPassos: Integer;    // offset 12
  public
    constructor Create(ValorInicial: Integer);
    procedure IncrementarViaAsm;
    procedure DecrementarViaAsm;
    procedure ResetViaAsm;
    function GetAtual: Integer;
    function GetSoma: Integer;
    procedure ImprimirEstado;
  end;

constructor TContador.Create(ValorInicial: Integer);
begin
  inherited Create;
  FInicial := ValorInicial;
  FAtual   := ValorInicial;
  FPassos  := 0;
end;

procedure TContador.IncrementarViaAsm;
// EAX = Self (Delphi 32-bit "register")
// Acesso via nome do campo — Delphi resolve o offset correto
asm
  INC [EAX].TContador.FAtual     // FAtual++
  INC [EAX].TContador.FPassos    // FPassos++
end;

procedure TContador.DecrementarViaAsm;
// EAX = Self
asm
  DEC [EAX].TContador.FAtual     // FAtual--
  INC [EAX].TContador.FPassos    // FPassos++ (conta operações)
end;

procedure TContador.ResetViaAsm;
// EAX = Self
asm
  PUSH EBX                        // EBX é callee-saved!
  MOV  EBX, EAX                   // EBX = Self (preserva Self)
  MOV  ECX, [EBX].TContador.FInicial  // ECX = FInicial
  MOV  [EBX].TContador.FAtual, ECX    // FAtual = FInicial
  INC  [EBX].TContador.FPassos        // FPassos++
  POP  EBX
end;

function TContador.GetAtual: Integer;
// EAX = Self
// Retorno: EAX = FAtual
asm
  MOV EAX, [EAX].TContador.FAtual   // EAX = Self.FAtual (substitui Self em EAX)
end;

function TContador.GetSoma: Integer;
// Retorna FInicial + FAtual + FPassos (demonstração de múltiplos campos)
// EAX = Self
asm
  PUSH EBX
  MOV  EBX, EAX                       // EBX = Self
  MOV  EAX, [EBX].TContador.FInicial  // EAX = FInicial
  ADD  EAX, [EBX].TContador.FAtual    // EAX += FAtual
  ADD  EAX, [EBX].TContador.FPassos   // EAX += FPassos
  POP  EBX
end;

procedure TContador.ImprimirEstado;
begin
  WriteLn(Format('  FInicial=%d  FAtual=%d  FPassos=%d',
    [FInicial, FAtual, FPassos]));
end;

// ---------------------------------------------------------------------------
// Método com parâmetro: Self + 1 param (EAX=Self, EDX=param)
// ---------------------------------------------------------------------------
type
  TCalculadora = class
  private
    FMemoria: Int64;
  public
    constructor Create;
    procedure ArmazenarViaAsm(Valor: Integer);
    function RecuperarInt: Integer;
  end;

constructor TCalculadora.Create;
begin
  inherited Create;
  FMemoria := 0;
end;

procedure TCalculadora.ArmazenarViaAsm(Valor: Integer);
// EAX = Self, EDX = Valor (32-bit "register")
asm
  MOVSX EDX, EDX                      // sign-extend EDX para garantir
  MOV   [EAX].TCalculadora.FMemoria, EDX  // FMemoria = Valor (escreve 32-bit em campo Int64)
  // Nota: campo Int64 tem 8 bytes; escrevemos apenas 4 bytes baixos
  // Para valores Int64 completos, usar 2 MOVs ou MOVQ com XMM
end;

function TCalculadora.RecuperarInt: Integer;
// EAX = Self
asm
  MOV EAX, [EAX].TCalculadora.FMemoria  // carrega 32 bits baixos de FMemoria
end;

var
  Contador: TContador;
  Calc: TCalculadora;
  I: Integer;

begin
  WriteLn('=== Self e Acesso a Campos via Assembly ===');
  WriteLn;

  Contador := TContador.Create(100);
  try
    WriteLn('Estado inicial:');
    Contador.ImprimirEstado;

    // Incrementar 5 vezes
    for I := 1 to 5 do
      Contador.IncrementarViaAsm;
    WriteLn('Após 5 incrementos:');
    Contador.ImprimirEstado;
    WriteLn('GetAtual() = ', Contador.GetAtual);

    // Decrementar 2 vezes
    Contador.DecrementarViaAsm;
    Contador.DecrementarViaAsm;
    WriteLn('Após 2 decrementos:');
    Contador.ImprimirEstado;

    // Reset
    Contador.ResetViaAsm;
    WriteLn('Após reset:');
    Contador.ImprimirEstado;

    WriteLn('GetSoma() = ', Contador.GetSoma);
  finally
    Contador.Free;
  end;

  WriteLn;

  Calc := TCalculadora.Create;
  try
    Calc.ArmazenarViaAsm(42);
    WriteLn('Calculadora: armazenou 42, recuperou ', Calc.RecuperarInt);
    Calc.ArmazenarViaAsm(-1);
    WriteLn('Calculadora: armazenou -1, recuperou ', Calc.RecuperarInt);
  finally
    Calc.Free;
  end;

  WriteLn;
  ReadLn;
end.

unit stack_inspect;
// Inspecao manual do ESP/RSP e conteudo da pilha
// Util para detectar stack imbalance em rotinas asm
{$APPTYPE CONSOLE}
interface

// Obter valor atual de ESP (Win32) ou RSP (Win64)
function ObterESP: Pointer; assembler;

// Verificar balance da pilha — retorna True se ESP/RSP igual antes e apos
function VerificarBalance(Proc: TProc): Boolean;

// Leitura de valores na pilha (relativo ao frame atual)
function LerPilha(Offset: Integer): NativeUInt;

implementation

function ObterESP: Pointer; assembler;
asm
{$IFDEF WIN32}
  MOV EAX, ESP    // EAX = endereco atual do topo da pilha
{$ENDIF WIN32}
{$IFDEF WIN64}
  MOV RAX, RSP    // RAX = endereco atual do topo da pilha (x64)
{$ENDIF WIN64}
end;

function VerificarBalance(Proc: TProc): Boolean;
// Chama Proc e verifica se ESP/RSP foi preservado corretamente
var
  EspAntes, EspDepois: Pointer;
begin
  EspAntes := ObterESP;
  // Chamar a procedure (Pascal chama sem problemas)
  Proc;
  EspDepois := ObterESP;

  Result := (EspAntes = EspDepois);

  if not Result then
    OutputDebugString(PChar(Format(
      '[STACK IMBALANCE] Antes: %p Depois: %p Diferenca: %d bytes',
      [EspAntes, EspDepois, NativeInt(EspDepois) - NativeInt(EspAntes)])));
end;

function LerPilha(Offset: Integer): NativeUInt;
// Ler valor relativo ao frame pointer atual
// Offset = 0: EBP/RBP atual
// Offset = 4: EBP anterior (Win32) ou offset = 8 em Win64
// Offset = 8: endereco de retorno (Win32)
begin
  asm
{$IFDEF WIN32}
    MOV EAX, EBP          // EBP = frame pointer
    MOV ECX, Offset       // ECX = offset solicitado
    MOV EAX, [EAX + ECX]  // EAX = valor em [EBP + Offset]
    MOV Result, EAX
{$ENDIF WIN32}
{$IFDEF WIN64}
    MOV RAX, RBP
    MOVSXD RCX, Offset    // sign-extend Offset para 64-bit
    MOV RAX, [RAX + RCX]
    MOV Result, RAX
{$ENDIF WIN64}
  end;
end;

end.

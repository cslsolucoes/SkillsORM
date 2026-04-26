unit inline_basico;
// Blocos asm..end basicos dentro de funcoes Pascal
// Valido: Win32 e Win64 apenas (nao iOS/Android)
{$APPTYPE CONSOLE}
interface

function SomarInline(A, B: Integer): Integer;
function MaximoInline(A, B: Integer): Integer;
function AbsoluteInline(N: Integer): Integer;

implementation

function SomarInline(A, B: Integer): Integer;
// Mistura Pascal e asm: calcula A + B no bloco asm,
// mas retorno e declarado normalmente
begin
  asm
    // Win32 register: A=EAX, B=EDX
    // Esta funcao usa convencao register (padrao)
    // O bloco asm pode deixar o resultado em EAX
    MOV EAX, A   // Delphi resolve 'A' para o registrador/posicao correto
    ADD EAX, B
    MOV Result, EAX  // @Result ou Result: armazena em variavel de retorno
  end;
end;

function MaximoInline(A, B: Integer): Integer;
begin
  asm
    MOV EAX, A
    CMP EAX, B
    JGE @retornaA
    MOV EAX, B     // B e maior
  @retornaA:
    MOV Result, EAX
  end;
end;

function AbsoluteInline(N: Integer): Integer;
begin
  asm
    MOV  EAX, N
    TEST EAX, EAX
    JNS  @positivo    // Jump if Not Sign (N >= 0)
    NEG  EAX          // EAX = -EAX
  @positivo:
    MOV  Result, EAX
  end;
end;

end.

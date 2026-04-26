unit breakpoint_asm;
// INT 3 como breakpoint manual em codigo assembly Delphi
// Uso: pausar execucao em condicoes especificas durante debug
{$APPTYPE CONSOLE}
interface

// Breakpoint incondicional (sempre para no debugger)
procedure BreakpointIncondicional;

// Breakpoint condicional (para somente se Condicao = True)
procedure BreakpointCondicional(Condicao: Boolean);

// Breakpoint com contagem (para apos N chamadas)
var
  GContadorBreak: Integer = 0;
procedure BreakpointContagem(N: Integer);

// Assert em assembly (para se expressao for False)
procedure AssertAsm(Condicao: Boolean; const Msg: string);

implementation

procedure BreakpointIncondicional;
asm
  // INT 3 = opcode 0xCC = software interrupt 3
  // O debugger captura este trap e pausa a execucao
  // SEM debugger: gera exception SIGTRAP/Breakpoint
  {$IFDEF DEBUG}
  INT 3
  {$ENDIF}
end;

procedure BreakpointCondicional(Condicao: Boolean);
// Win32: Condicao = AL (Boolean e byte, EAX registro)
asm
  {$IFDEF DEBUG}
  TEST AL, AL     // verifica se Condicao e True (nao-zero)
  JZ   @fim       // se False, pular o INT 3
  INT  3          // parar no debugger somente se True
@fim:
  {$ENDIF}
end;

procedure BreakpointContagem(N: Integer);
// Para apos N chamadas — util para bugs que ocorrem em iteracao especifica
begin
  Inc(GContadorBreak);
  if GContadorBreak >= N then
  begin
    GContadorBreak := 0;
    asm
      {$IFDEF DEBUG}
      INT 3
      {$ENDIF}
    end;
  end;
end;

procedure AssertAsm(Condicao: Boolean; const Msg: string);
// Verificar pre-condicao — similar a Assert() mas com INT 3 em vez de excecao
begin
  if not Condicao then
  begin
    // Mostrar mensagem (OutputDebugString nao bloqueante):
    OutputDebugString(PChar('[ASM ASSERT FAIL] ' + Msg));
    asm
      {$IFDEF DEBUG}
      INT 3   // parar no debugger
      {$ENDIF}
    end;
  end;
end;

end.

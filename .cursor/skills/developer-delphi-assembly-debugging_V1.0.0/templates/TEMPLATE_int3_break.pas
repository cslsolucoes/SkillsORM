unit TEMPLATE_int3_break;
// TEMPLATE: INT 3 condicional para debug de assembly
// Sempre proteger com {$IFDEF DEBUG} — remover em producao
{$APPTYPE CONSOLE}
interface

// Substituir: condicao de parada, logica de debug
procedure DebugBreakSe(Condicao: Boolean);
procedure DebugBreakApos(var Contador: Integer; N: Integer);

implementation

procedure DebugBreakSe(Condicao: Boolean);
asm
{$IFDEF DEBUG}
  // Boolean em AL (parte baixa de EAX, Win32) ou CL (Win64)
{$IFDEF WIN32}
  TEST AL, AL        // Condicao = True?
  JZ   @fim_break
  INT  3             // parar no debugger
@fim_break:
{$ENDIF WIN32}
{$IFDEF WIN64}
  TEST CL, CL
  JZ   @fim_break64
  INT  3
@fim_break64:
{$ENDIF WIN64}
{$ENDIF DEBUG}
end;

procedure DebugBreakApos(var Contador: Integer; N: Integer);
// Para no debugger apos N chamadas — util para bugs em loops
begin
{$IFDEF DEBUG}
  Inc(Contador);
  if Contador >= N then
  begin
    Contador := 0;  // reset para permitir re-uso
    asm
      INT 3
    end;
  end;
{$ENDIF}
end;

// CHECKLIST ANTES DE COMMITAR:
// [ ] Todos os INT 3 estao protegidos com {$IFDEF DEBUG}
// [ ] OutputDebugString removido ou protegido com {$IFDEF DEBUG}
// [ ] RDTSC/benchmark code removido de paths de producao

end.

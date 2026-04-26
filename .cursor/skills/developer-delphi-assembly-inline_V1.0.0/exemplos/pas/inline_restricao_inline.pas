unit inline_restricao_inline;
// Demonstra a restricao: `inline` + `asm` = ERRO E2426
// e a solucao correta
{$APPTYPE CONSOLE}
interface

// ERRADO: nao compilara — E2426 Cannot inline assembler procedures
// function SomarERRADO(A, B: Integer): Integer; inline;
// asm
//   ADD EAX, EDX
// end;

// CORRETO: sem inline — usar apenas asm
function SomarCorreto(A, B: Integer): Integer;

// ALTERNATIVA: se quiser inlining de performance, usar Pascal puro
// O compilador Delphi otimiza Pascal melhor que tenta inlinear asm
function SomarPascalInline(A, B: Integer): Integer; inline;

implementation

function SomarCorreto(A, B: Integer): Integer;
asm
  // Win32: A=EAX, B=EDX
  ADD EAX, EDX
end;

function SomarPascalInline(A, B: Integer): Integer; inline;
begin
  // Este sim pode ser inline — sem asm
  Result := A + B;
  // O compilador Delphi pode gerar codigo otimo para isso
end;

// RESTRICOES ADICIONAIS no built-in assembler Delphi:
//
// 1. Tipos gerenciados NAO podem ser manipulados diretamente:
//    - string, AnsiString, UnicodeString
//    - interface, IInterface
//    - array dinamico (TArray<T>)
//    - Variant
//    Acesso direto corrompera o reference count!
//
// 2. Plataformas suportadas:
//    - Win32 (dcc32): SIM
//    - Win64 (dcc64): SIM
//    - macOS x64 (dcc64 via Delphi): SIM
//    - iOS ARM (dccios): NAO — compilador LLVM
//    - Android ARM (dccaarm): NAO — compilador LLVM
//    - Linux x64 (via FPC): SIM (sintaxe FPC, nao Delphi)
//
// 3. Labels: sempre usar @prefix para labels locais:
//    CORRETO: @MeuLabel
//    ERRADO:  MeuLabel (conflito potencial com Pascal)

end.

program breakpoints_condicionais;
{$APPTYPE CONSOLE}
{$IFDEF FPC}
  {$mode delphi}
{$ENDIF}
(*
  EXEMPLO: Breakpoints condicionais, de contagem e por grupo
  Compilar: dcc32 breakpoints_condicionais.pas  OU  dcc64 breakpoints_condicionais.pas

  USO NO IDE:
    1. Clique na margem esquerda para criar um breakpoint (ponto vermelho).
    2. Clique direito no breakpoint → "Properties" (Delphi) ou "Edit Breakpoint".
    3. Campo "Condition": digitar expressão Pascal — ex.: I = 50
       → O debugger só para quando a expressão for TRUE.
    4. Campo "Pass Count": digitar N → o debugger só para na N-ésima vez que
       a linha for atingida (independente de condição).
    5. Campo "Group": agrupar breakpoints; usar View → Breakpoints para
       habilitar/desabilitar grupos inteiros.
    6. Opção "Log Message": escrever mensagem no Event Log sem parar execução
       (equivale a OutputDebugString sem alterar código).

  DICA — Binary Search Debugging:
    Se não sabe onde o bug ocorre em um loop de 1000 iterações:
    - Coloque breakpoint condicional em I = 500.
    - Se o bug já aconteceu → testar I = 250.
    - Se ainda não aconteceu → testar I = 750.
    - Repetir até isolar a iteração exata.
*)
uses
  SysUtils;

type
  TItem = record
    ID: Integer;
    Valor: Double;
  end;

procedure ProcessarItens(const AItens: array of TItem);
var
  I: Integer;
  Soma: Double;
begin
  Soma := 0;
  for I := Low(AItens) to High(AItens) do
  begin
    // === PONTO DE BREAKPOINT CONDICIONAL ===
    // Condition sugerida: (AItens[I].Valor < 0) OR (I = 50)
    // Pass Count sugerido: 10  (para apenas na 10a iteracao)
    Soma := Soma + AItens[I].Valor;

    // Verificacao que pode gerar bug em runtime — boa candidata a breakpoint
    if AItens[I].Valor < 0 then
    begin
      // === PONTO DE BREAKPOINT SEM CONDICAO ===
      // Parar aqui sempre que valor for negativo
      WriteLn(Format('Atencao: item[%d] tem valor negativo: %.2f', [I, AItens[I].Valor]));
    end;
  end;
  WriteLn(Format('Soma total: %.2f', [Soma]));
end;

procedure DemonstrarContagem;
var
  I: Integer;
begin
  WriteLn('--- Demonstracao de Pass Count ---');
  for I := 1 to 100 do
  begin
    // === BREAKPOINT COM PASS COUNT = 25 ===
    // O debugger so para quando esta linha for atingida pela 25a vez.
    // Util quando o bug ocorre apos muitas iteracoes normais.
    Write(Format('%d ', [I]));
    if I mod 10 = 0 then
      WriteLn;
  end;
  WriteLn;
end;

var
  Itens: array[0..9] of TItem;
  I: Integer;
begin
  // Inicializar itens de teste (item 5 tem valor negativo intencional)
  for I := 0 to 9 do
  begin
    Itens[I].ID := I + 1;
    if I = 5 then
      Itens[I].Valor := -99.99  // valor problematico — breakpoint condicional aqui
    else
      Itens[I].Valor := (I + 1) * 10.5;
  end;

  WriteLn('=== Exemplo: Breakpoints Condicionais ===');
  WriteLn;

  ProcessarItens(Itens);
  WriteLn;
  DemonstrarContagem;

  WriteLn;
  WriteLn('OK -- developer-delphi-debugging-techniques :: breakpoints_condicionais');
end.

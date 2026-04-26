program output_debug;
{$APPTYPE CONSOLE}
{$IFDEF FPC}
  {$mode delphi}
{$ENDIF}
(*
  EXEMPLO: OutputDebugString, DebugBreak e AllocConsole
  Compilar: dcc32 output_debug.pas  OU  dcc64 output_debug.pas

  OutputDebugString:
    - Envia mensagem ao debugger sem interromper execucao.
    - Visivel no Event Log do IDE (View → Event Log).
    - Visivel no DebugView da Sysinternals quando executando fora do IDE.
    - SEMPRE proteger com {$IFDEF DEBUG} para nao vazar para producao.

  DebugBreak (Windows API):
    - Equivale a inserir int3 (breakpoint de software) no codigo.
    - Quando o debugger esta anexado: para na linha chamada.
    - Quando nao ha debugger: gera exception STATUS_BREAKPOINT.
    - Usar apenas para situacoes excepcionais de diagnostico; remover antes do commit.

  AllocConsole:
    - Aloca uma janela de console para aplicacoes GUI (VCL/FMX).
    - Permite usar WriteLn em aplicacoes que nao tem console.
    - Util durante debugging de forms sem alterar tipo do projeto.
    - NUNCA deixar em producao — interfere na UX.

  FastMM4 — memory leak detection:
    - Adicionar FastMM4 como PRIMEIRO unit nas uses do .dpr.
    - Definir ReportMemoryLeaksOnShutdown := True em debug builds.
    - Ao fechar a aplicacao, FastMM4 exibe relatorio de blocos nao liberados.
    - Em producao: NÃO incluir FastMM4 ou desabilitar relatorio.
*)
uses
  SysUtils
  {$IFDEF MSWINDOWS}, Windows{$ENDIF};

// Wrapper seguro para OutputDebugString — protegido por define
procedure DebugLog(const AMsg: string);
begin
  {$IFDEF DEBUG}
  {$IFDEF MSWINDOWS}
  OutputDebugString(PChar('[DEBUG] ' + AMsg));
  {$ELSE}
  // FPC em Linux/macOS: stderr como alternativa
  WriteLn(ErrOutput, '[DEBUG] ' + AMsg);
  {$ENDIF}
  {$ENDIF}
end;

// DebugLogFmt — conveniencia com formatacao
procedure DebugLogFmt(const AFmt: string; const AArgs: array of const);
begin
  {$IFDEF DEBUG}
  DebugLog(Format(AFmt, AArgs));
  {$ENDIF}
end;

procedure SimularProcessamento(const AIteracoes: Integer);
var
  I: Integer;
  Valor: Double;
begin
  DebugLog('SimularProcessamento: iniciando');
  DebugLogFmt('Iteracoes solicitadas: %d', [AIteracoes]);

  for I := 1 to AIteracoes do
  begin
    Valor := I * 3.14159;

    // Log apenas em marcos — evitar flood de mensagens
    if I mod 10 = 0 then
      DebugLogFmt('Progresso: %d/%d | Valor=%.4f', [I, AIteracoes, Valor]);
  end;

  DebugLog('SimularProcessamento: concluido');
end;

procedure DemonstrarDebugBreak;
begin
  {$IFDEF DEBUG}
  {$IFDEF MSWINDOWS}
  // DebugBreak so deve ser chamado quando debugger esta anexado.
  // Em producao esta linha NUNCA deve existir.
  // Descomente apenas durante sessao ativa de debugging:
  // DebugBreak;
  DebugLog('DemonstrarDebugBreak: DebugBreak comentado (seguro para execucao normal)');
  {$ENDIF}
  {$ENDIF}
end;

procedure ExemploFastMM4;
begin
  // Para usar FastMM4:
  // 1. Adicionar FastMM4.pas ao projeto (disponivel em github.com/pleriche/FastMM4).
  // 2. FastMM4 deve ser o PRIMEIRO unit nas uses do arquivo .dpr:
  //      uses FastMM4, SysUtils, ...;
  // 3. No inicio do programa (antes de qualquer alocacao):
  //      {$IFDEF DEBUG}
  //      ReportMemoryLeaksOnShutdown := True;
  //      {$ENDIF}
  // 4. Ao fechar a aplicacao, FastMM4 mostrara janela com blocos nao liberados.
  //
  // Exemplo de relatorio FastMM4:
  //   "A memory block has been leaked. The size is: 32"
  //   "This block was allocated by thread 0x1234, and the stack trace (return addresses)
  //    at the time was: [...]"
  //
  // Para rastreamento detalhado (stack trace por alocacao):
  //   Definir: {$DEFINE FullDebugMode} antes de incluir FastMM4.

  WriteLn('FastMM4: consulte comentarios no codigo para instrucoes de uso.');
  WriteLn('  - adicionar FastMM4 como 1o unit no .dpr');
  WriteLn('  - ReportMemoryLeaksOnShutdown := True em {$IFDEF DEBUG}');
end;

procedure ExemploEurekaLogMadExcept;
begin
  // EurekaLog / MadExcept — crash reporters para producao:
  //
  // EUREKA LOG:
  //   - Adicionar EurekaLog ao projeto via Delphi Package Manager ou manualmente.
  //   - Configura automaticamente hook no Application.OnException.
  //   - Ao ocorrer unhandled exception: gera .elog com call stack completo,
  //     valores de variaveis locais, estado das threads e info do SO.
  //   - Pode enviar por email ou HTTP automaticamente.
  //
  // MADEXCEPT:
  //   - Instalacao via package; usa hook em nivel de SO (SEH).
  //   - Intercepta tanto exceptions Delphi quanto crashes do SO (AV, etc.).
  //   - Gera report com: call stack, modulos carregados, registradores da CPU,
  //     conteudo da pilha em bytes.
  //   - Suporta envio automatico ao servidor do desenvolvedor.
  //
  // INTERPRETANDO O CALL STACK DO CRASH REPORT:
  //   - Ler de cima para baixo: o frame DO TOPO e onde o crash ocorreu.
  //   - Frames abaixo mostram a cadeia de chamadas que levou ao crash.
  //   - Numeros de linha sao precisos apenas se o .map ou .tds foi gerado
  //     junto com o executavel de producao.
  //   - Para gerar .map: Project → Options → Linker → Map file = detailed.

  WriteLn('EurekaLog/MadExcept: consulte comentarios no codigo para instrucoes de integracao.');
end;

begin
  WriteLn('=== Exemplo: OutputDebugString, DebugBreak e AllocConsole ===');
  WriteLn;

  // Demonstrar OutputDebugString (visivel no Event Log do IDE / DebugView)
  DebugLog('Programa iniciando');

  SimularProcessamento(30);

  DemonstrarDebugBreak;

  WriteLn;
  ExemploFastMM4;
  WriteLn;
  ExemploEurekaLogMadExcept;

  DebugLog('Programa finalizando normalmente');

  WriteLn;
  WriteLn('OK -- developer-delphi-debugging-techniques :: output_debug');
end.

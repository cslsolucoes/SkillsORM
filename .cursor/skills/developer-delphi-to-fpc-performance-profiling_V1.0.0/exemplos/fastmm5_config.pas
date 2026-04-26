program fastmm5_config;
{$APPTYPE CONSOLE}
{$R *.res}
///  Demonstra configuracao do FastMM5 para diagnostico de leaks em Delphi.
///  Compilavel com: dcc32 fastmm5_config.pas  ou  dcc64 fastmm5_config.pas
///
///  PRE-REQUISITO: FastMM5 instalado e acessivel no Search Path do projeto.
///  Se FastMM5 nao estiver disponivel, o codigo compila com {$DEFINE FASTMM5_AUSENTE}
///  e exibe instrucoes de instalacao.
///
///  Tecnicas demonstradas:
///   1. Configuracao minima de FastMM5 (LogToFile, OutputDebugString, sem MessageBoxes)
///   2. Leitura programatica do log de leaks via GetCurrentMemoryUsage
///   3. Padrao de uso: habilitar antes de Application.Initialize no .dpr
///   4. Diferenca entre FullDebugMode (dev) e producao

uses
  System.SysUtils,
  System.Classes
  {$IFNDEF FASTMM5_AUSENTE}
  , FastMM5
  {$ENDIF};

// ---------------------------------------------------------------------------
// Funcoes auxiliares de demonstracao
// ---------------------------------------------------------------------------

/// Simula configuracao de FastMM5 conforme recomendado para build de diagnostico.
/// Na pratica, estas atribuicoes ficam no inicio do .dpr, antes de Application.Initialize.
procedure ConfigurarFastMM5;
begin
  {$IFNDEF FASTMM5_AUSENTE}
  // Gravar log de leaks em arquivo NomeProjeto_MemoryManager_EventLog.txt
  FastMM_LogToFile                  := True;
  // Enviar mensagens para OutputDebugString (visivel no debugger IDE / DebugView)
  FastMM_OutputDebugString          := True;
  // Desabilitar MessageBox — essencial para servicos e headless builds
  FastMM_MessageBoxes               := False;
  // Registrar stack trace de cada alocacao (FullDebugMode — ~3-5x mais lento)
  // Desabilitar em producao; habilitar apenas em build de diagnostico
  FastMM_EnterDebugMode;
  WriteLn('[FastMM5] Configurado: LogToFile=True, OutputDebugString=True, MessageBoxes=False');
  WriteLn('[FastMM5] FullDebugMode habilitado (apenas para diagnostico)');
  {$ELSE}
  WriteLn('[FastMM5] AUSENTE — instale via GetIt ou copie FastMM5.pas para o Search Path.');
  WriteLn('          Instrucoes: https://github.com/pleriche/FastMM5');
  {$ENDIF}
end;

/// Demonstra leitura de uso atual de memoria via FastMM5.
procedure ExibirUsoDeMemoria;
begin
  {$IFNDEF FASTMM5_AUSENTE}
  var Stats: TFastMM_UsageSummary;
  FastMM_GetUsageSummary(Stats);
  WriteLn(Format('[FastMM5] Alocacoes ativas : %d blocos / %d bytes',
    [Stats.AllocatedBlocks, Stats.AllocatedBytes]));
  {$ELSE}
  WriteLn('[FastMM5] GetUsageSummary nao disponivel (FastMM5 ausente).');
  {$ENDIF}
end;

/// Cria um leak intencional para validar que FastMM5 o detecta.
/// ATENCAO: nao copiar esse padrao para codigo de producao.
procedure CriarLeakIntencional;
var
  Lista: TStringList;
begin
  Lista := TStringList.Create;
  Lista.Add('leak intencional para demonstracao');
  // Free intencionalmente omitido para demonstrar deteccao
  WriteLn('[Demo] TStringList criado sem Free — FastMM5 deve reportar 1 leak.');
end;

/// Cria e libera corretamente para comparacao.
procedure CriarSemLeak;
var
  Lista: TStringList;
begin
  Lista := TStringList.Create;
  try
    Lista.Add('sem leak');
    WriteLn('[Demo] TStringList criado e liberado corretamente.');
  finally
    Lista.Free;
  end;
end;

// ---------------------------------------------------------------------------
// Configuracoes de FastMM5 para referencia rapida (comentadas)
// ---------------------------------------------------------------------------
//
//  FastMM_LogToFile              := True;   // log em arquivo
//  FastMM_OutputDebugString      := True;   // visivel no debugger
//  FastMM_MessageBoxes           := False;  // nunca em producao
//  FastMM_EnterDebugMode;                   // FullDebugMode: stack traces
//  FastMM_ExitDebugMode;                    // sair do FullDebugMode
//
//  Localizar o arquivo de log gerado:
//    <ExeDir>\<NomeProjeto>_MemoryManager_EventLog.txt
//
//  Exemplo de entrada no log:
//    A memory block of 48 bytes was allocated at address 0x... and was not freed.
//    The allocation number was 12.
//    Stack trace of when the block was allocated:
//      ...
// ---------------------------------------------------------------------------

begin
  try
    ConfigurarFastMM5;
    WriteLn;
    CriarSemLeak;
    CriarLeakIntencional;
    WriteLn;
    ExibirUsoDeMemoria;
    WriteLn;
    WriteLn('OK -- developer-delphi-to-fpc-performance-profiling / fastmm5_config');
    WriteLn('Verifique o arquivo de log gerado pelo FastMM5 para detalhes do leak.');
    // Nota: FastMM5 emite o relatorio de leaks automaticamente no final do processo.
    Halt(0);
  except
    on E: Exception do
    begin
      WriteLn('ERRO: ' + E.Message);
      Halt(1);
    end;
  end;
end.

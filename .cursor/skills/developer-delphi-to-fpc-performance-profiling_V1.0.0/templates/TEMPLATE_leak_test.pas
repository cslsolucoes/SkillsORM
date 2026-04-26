program TEMPLATE_leak_test;
{$APPTYPE CONSOLE}
{$R *.res}
///  TEMPLATE: Test case que verifica ausencia de leaks de memoria.
///  ==============================================================
///  Como usar:
///   1. Renomear para leak_test_NomeModulo.pas
///   2. Substituir as secoes {TODO} pelas classes e operacoes do modulo
///   3. Habilitar FastMM5 no Search Path OU usar ReportMemoryLeaksOnShutdown
///   4. Compilar e executar; qualquer leak aparece no log / OutputDebugString
///   5. dcc32 leak_test_NomeModulo.pas  ou  dcc64 ...
///
///  Compilavel sem modificacoes com: dcc32 TEMPLATE_leak_test.pas
///
///  Estrategia:
///   - ReportMemoryLeaksOnShutdown := True  (nativo do RTL Delphi)
///   - FastMM5 com LogToFile (se disponivel) para stack trace completo
///   - Cada "caso de teste" cria e destroi objetos; ao final verifica saida

uses
  System.SysUtils,
  System.Classes;

// ---------------------------------------------------------------------------
// Configuracao de deteccao de leaks
// ---------------------------------------------------------------------------

procedure ConfigurarDeteccaoLeaks;
begin
  // Habilitar relatorio de leaks do RTL (nao requer FastMM5 externo)
  ReportMemoryLeaksOnShutdown := True;

  // Se FastMM5 estiver disponivel, adicionar 'FastMM5' ao uses e descomentar:
  // FastMM_LogToFile         := True;
  // FastMM_OutputDebugString := True;
  // FastMM_MessageBoxes      := False;
  // FastMM_EnterDebugMode;

  WriteLn('[LeakTest] Deteccao de leaks habilitada (ReportMemoryLeaksOnShutdown).');
end;

// ---------------------------------------------------------------------------
// {TODO} Definir as classes do modulo a testar
// ---------------------------------------------------------------------------

type
  // Exemplo de classe simples para demonstracao
  TExemploServico = class
  private
    FDados: TStringList;
    FNome:  string;
  public
    constructor Create(const ANome: string);
    destructor Destroy; override;
    procedure Processar;
    property Nome: string read FNome;
  end;

constructor TExemploServico.Create(const ANome: string);
begin
  inherited Create;
  FNome  := ANome;
  FDados := TStringList.Create; // recurso interno
end;

destructor TExemploServico.Destroy;
begin
  FDados.Free; // liberar recurso interno
  inherited;
end;

procedure TExemploServico.Processar;
begin
  FDados.Add('resultado de ' + FNome);
end;

// ---------------------------------------------------------------------------
// Casos de teste de ausencia de leak
// ---------------------------------------------------------------------------

/// Caso 1: criar e destruir objeto simples
procedure TesteSimples;
var
  Svc: TExemploServico;
begin
  Write('  [Caso 1] Criar/destruir TExemploServico... ');
  Svc := TExemploServico.Create('teste-simples');
  try
    Svc.Processar;
    // {TODO} adicionar assercoes de comportamento aqui
    if Svc.Nome <> 'teste-simples' then
      raise Exception.Create('Nome incorreto');
  finally
    Svc.Free; // OBRIGATORIO no finally
  end;
  WriteLn('OK');
end;

/// Caso 2: criar lista de objetos com OwnsObjects
procedure TesteLista;
var
  Lista: TObjectList;
  I:     Integer;
begin
  Write('  [Caso 2] Lista com OwnsObjects=True... ');
  Lista := TObjectList.Create(True {OwnsObjects});
  try
    for I := 1 to 5 do
      Lista.Add(TExemploServico.Create('item-' + IntToStr(I)));
    // {TODO} validar comportamento da lista
    if Lista.Count <> 5 then
      raise Exception.Create('Contagem incorreta');
  finally
    Lista.Free; // libera lista E os 5 TExemploServico
  end;
  WriteLn('OK');
end;

/// Caso 3: excecao durante operacao — garantir que Free e chamado
procedure TesteComExcecao;
var
  Svc: TExemploServico;
begin
  Write('  [Caso 3] Excecao durante operacao (Free garantido)... ');
  Svc := TExemploServico.Create('teste-excecao');
  try
    // {TODO} simular operacao que pode lancar excecao
    try
      raise Exception.Create('excecao simulada');
    except
      on E: Exception do
        ; // tratar mas nao propagar neste caso
    end;
  finally
    Svc.Free; // SEMPRE executado, mesmo com excecao
  end;
  WriteLn('OK');
end;

/// {TODO} Adicionar mais casos de teste do modulo real aqui
// procedure TesteNomeModulo;
// begin
//   ...
// end;

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
var
  Falhas: Integer;
begin
  ConfigurarDeteccaoLeaks;
  WriteLn;
  WriteLn('=== Leak Test: TODO_NomeModulo ===');
  WriteLn;

  Falhas := 0;

  try
    TesteSimples;
  except
    on E: Exception do
    begin
      WriteLn('  FALHA: ' + E.Message);
      Inc(Falhas);
    end;
  end;

  try
    TesteLista;
  except
    on E: Exception do
    begin
      WriteLn('  FALHA: ' + E.Message);
      Inc(Falhas);
    end;
  end;

  try
    TesteComExcecao;
  except
    on E: Exception do
    begin
      WriteLn('  FALHA: ' + E.Message);
      Inc(Falhas);
    end;
  end;

  WriteLn;
  if Falhas = 0 then
  begin
    WriteLn('Resultado: TODOS OS CASOS PASSARAM');
    WriteLn('Verificar log do FastMM5 / saida de ReportMemoryLeaksOnShutdown');
    WriteLn('para confirmar ausencia de leaks apos saida do processo.');
    WriteLn;
    WriteLn('OK -- TEMPLATE_leak_test');
    // ReportMemoryLeaksOnShutdown exibe relatorio automaticamente ao Halt
    Halt(0);
  end
  else
  begin
    WriteLn(Format('Resultado: %d CASO(S) FALHARAM', [Falhas]));
    Halt(1);
  end;
end.

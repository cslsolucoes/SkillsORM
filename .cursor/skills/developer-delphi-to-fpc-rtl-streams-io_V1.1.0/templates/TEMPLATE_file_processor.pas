unit TEMPLATE_file_processor;
{
  TEMPLATE: Processador de arquivo linha a linha com TStreamReader
  Substitua TResultado e ProcessarLinha conforme seu domínio.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Interface do processador
// ---------------------------------------------------------------------------
type
  // Substitua por seu tipo de resultado
  TResultado = record
    NumLinha: Integer;
    Conteudo: string;
    Valido:   Boolean;
  end;

  // Callback de progresso (opcional)
  TProgressCallback = reference to procedure(ALinhaAtual, ATotalBytes: Int64);

  // Interface do processador
  IFileProcessor = interface
    ['{FFFFFFFF-0000-1111-2222-333344445555}']
    function Processar(const ACaminho: string): TArray<TResultado>;
    function ProcessarComFiltro(const ACaminho: string;
      APredicate: TFunc<string, Boolean>): TArray<TResultado>;
    procedure ProcessarStreaming(const ACaminho: string;
      ACallback: TProc<TResultado>);
    property OnProgress: TProgressCallback write SetOnProgress;
    procedure SetOnProgress(const ACallback: TProgressCallback);
  end;

// ---------------------------------------------------------------------------
// Implementação
// ---------------------------------------------------------------------------
  TFileProcessor = class(TInterfacedObject, IFileProcessor)
  private
    FEncoding:    TEncoding;
    FOnProgress:  TProgressCallback;
    FBufferSize:  Integer;

    procedure SetOnProgress(const ACallback: TProgressCallback);
    function ProcessarLinha(const ALinha: string; ANumLinha: Integer): TResultado;
    procedure ReportarProgresso(ALinhaAtual, ATotalBytes: Int64);
  public
    constructor Create(AEncoding: TEncoding = nil; ABufferSize: Integer = 4096);

    function Processar(const ACaminho: string): TArray<TResultado>;
    function ProcessarComFiltro(const ACaminho: string;
      APredicate: TFunc<string, Boolean>): TArray<TResultado>;
    procedure ProcessarStreaming(const ACaminho: string;
      ACallback: TProc<TResultado>);

    property OnProgress: TProgressCallback write SetOnProgress;
  end;

function NewFileProcessor(AEncoding: TEncoding = nil): IFileProcessor;

implementation

// ---------------------------------------------------------------------------
// TFileProcessor
// ---------------------------------------------------------------------------

constructor TFileProcessor.Create(AEncoding: TEncoding; ABufferSize: Integer);
begin
  inherited Create;
  FEncoding   := AEncoding;
  FBufferSize := ABufferSize;
  if FEncoding = nil then FEncoding := TEncoding.UTF8;
end;

procedure TFileProcessor.SetOnProgress(const ACallback: TProgressCallback);
begin FOnProgress := ACallback; end;

procedure TFileProcessor.ReportarProgresso(ALinhaAtual, ATotalBytes: Int64);
begin
  if Assigned(FOnProgress) then
    FOnProgress(ALinhaAtual, ATotalBytes);
end;

function TFileProcessor.ProcessarLinha(const ALinha: string;
  ANumLinha: Integer): TResultado;
begin
  // ---- SUBSTITUA esta lógica pelo processamento real ----
  Result.NumLinha := ANumLinha;
  Result.Conteudo := ALinha.Trim;
  Result.Valido   := Result.Conteudo <> '';

  // Exemplos de processamento:
  // - Parse CSV: Result.Campos := ALinha.Split([',']);
  // - Validação: Result.Valido := ALinha.StartsWith('PREFIX');
  // - Transformação: Result.Conteudo := ALinha.ToUpper;
  // -------------------------------------------------------
end;

function TFileProcessor.Processar(const ACaminho: string): TArray<TResultado>;
var SR:      TStreamReader;
    Lista:   TList<TResultado>;
    Linha:   string;
    NLinha:  Integer;
    TotalSz: Int64;
begin
  if not TFile.Exists(ACaminho) then
    raise EFileNotFoundException.Create('Arquivo não encontrado: ' + ACaminho);

  TotalSz := TFile.GetSize(ACaminho);
  Lista   := TList<TResultado>.Create;
  try
    SR := TStreamReader.Create(ACaminho, FEncoding, True, FBufferSize);
    try
      NLinha := 0;
      while not SR.EndOfStream do
      begin
        Linha := SR.ReadLine;
        Inc(NLinha);
        Lista.Add(ProcessarLinha(Linha, NLinha));
        ReportarProgresso(NLinha, TotalSz);
      end;
    finally
      SR.Free;
    end;
    Result := Lista.ToArray;
  finally
    Lista.Free;
  end;
end;

function TFileProcessor.ProcessarComFiltro(const ACaminho: string;
  APredicate: TFunc<string, Boolean>): TArray<TResultado>;
var SR:     TStreamReader;
    Lista:  TList<TResultado>;
    Linha:  string;
    NLinha: Integer;
begin
  if not TFile.Exists(ACaminho) then
    raise EFileNotFoundException.Create('Arquivo não encontrado: ' + ACaminho);

  Lista := TList<TResultado>.Create;
  try
    SR := TStreamReader.Create(ACaminho, FEncoding, True, FBufferSize);
    try
      NLinha := 0;
      while not SR.EndOfStream do
      begin
        Linha := SR.ReadLine;
        Inc(NLinha);
        if APredicate(Linha) then
          Lista.Add(ProcessarLinha(Linha, NLinha));
      end;
    finally
      SR.Free;
    end;
    Result := Lista.ToArray;
  finally
    Lista.Free;
  end;
end;

procedure TFileProcessor.ProcessarStreaming(const ACaminho: string;
  ACallback: TProc<TResultado>);
var SR:     TStreamReader;
    Linha:  string;
    NLinha: Integer;
begin
  // Streaming: não acumula em memória — ideal para arquivos grandes
  if not TFile.Exists(ACaminho) then
    raise EFileNotFoundException.Create('Arquivo não encontrado: ' + ACaminho);

  SR := TStreamReader.Create(ACaminho, FEncoding, True, FBufferSize);
  try
    NLinha := 0;
    while not SR.EndOfStream do
    begin
      Linha := SR.ReadLine;
      Inc(NLinha);
      ACallback(ProcessarLinha(Linha, NLinha));
    end;
  finally
    SR.Free;
  end;
end;

function NewFileProcessor(AEncoding: TEncoding): IFileProcessor;
begin
  Result := TFileProcessor.Create(AEncoding);
end;

// ---------------------------------------------------------------------------
// Exemplo de uso (comentado — descomente para testar)
// ---------------------------------------------------------------------------
(*
procedure DemoFileProcessor;
var Proc:      IFileProcessor;
    Resultado: TArray<TResultado>;
    R:         TResultado;
begin
  Proc := NewFileProcessor(TEncoding.UTF8);

  // Configurar progresso
  Proc.OnProgress := procedure(Linha, TotalBytes: Int64)
  begin
    if Linha mod 100 = 0 then
      Writeln('Linha ', Linha, ' / bytes total: ', TotalBytes);
  end;

  // Processar tudo
  Resultado := Proc.Processar('dados.csv');
  Writeln('Total linhas: ', Length(Resultado));

  // Processar com filtro — só linhas que começam com 'ERR'
  Resultado := Proc.ProcessarComFiltro('log.txt',
    function(L: string): Boolean
    begin Result := L.StartsWith('ERR'); end);

  // Streaming — sem acumular em memória
  Proc.ProcessarStreaming('grande_arquivo.txt',
    procedure(R: TResultado)
    begin
      if R.Valido then
        Writeln(R.NumLinha, ': ', R.Conteudo);
    end);
end;
*)

end.

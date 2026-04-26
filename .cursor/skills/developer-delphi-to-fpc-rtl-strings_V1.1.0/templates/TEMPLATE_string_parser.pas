unit TEMPLATE_string_parser;
{
  TEMPLATE: Parser de strings com TRegEx + TStringBuilder
  Adapte os padrões e campos conforme seu formato de entrada.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.RegularExpressions,
  System.Generics.Collections, System.Classes;

// ---------------------------------------------------------------------------
// Tipos de resultado do parser — adapte conforme seu domínio
// ---------------------------------------------------------------------------
type
  TErroParser = record
    Linha:    Integer;
    Coluna:   Integer;
    Mensagem: string;
  end;

  TCampoExtraido = record
    Nome:  string;
    Valor: string;
    Linha: Integer;
  end;

  TResultadoParser = record
    Campos:   TArray<TCampoExtraido>;
    Erros:    TArray<TErroParser>;
    Sucesso:  Boolean;
    function ToString: string;
  end;

// ---------------------------------------------------------------------------
// Interface do parser
// ---------------------------------------------------------------------------
  IStringParser = interface
    ['{11223344-5566-7788-AABB-CCDDEEFF0011}']
    function ParsearTexto(const ATexto: string): TResultadoParser;
    function ParsearArquivo(const ACaminho: string): TResultadoParser;
    function FormatarSaida(const AResultado: TResultadoParser): string;
  end;

// ---------------------------------------------------------------------------
// Padrões RegEx configuráveis
// ---------------------------------------------------------------------------
  TParserConfig = record
    // Substitua pelos padrões reais do seu formato
    PatternChave:  string;  // ex.: '^\s*(\w+)\s*[=:]\s*(.+?)\s*$'
    PatternData:   string;  // ex.: '\d{4}-\d{2}-\d{2}'
    PatternValor:  string;  // ex.: '[\d.,]+'
    ComentarioMarca: string; // ex.: '#' ou '//'
    Delimitador:   Char;    // separador de campos (ex.: ',', ';', #9)
  end;

// ---------------------------------------------------------------------------
// Implementação
// ---------------------------------------------------------------------------
  TStringParser = class(TInterfacedObject, IStringParser)
  private
    FConfig: TParserConfig;
    FREChave, FREData, FREValor: TRegEx;

    procedure InicializarPadroesRE;
    function  ProcessarLinha(const ALinha: string; ANumLinha: Integer;
      var Erros: TList<TErroParser>): TArray<TCampoExtraido>;
    function  LinhaEhComentario(const ALinha: string): Boolean;
  public
    constructor Create(const AConfig: TParserConfig);

    function ParsearTexto(const ATexto: string): TResultadoParser;
    function ParsearArquivo(const ACaminho: string): TResultadoParser;
    function FormatarSaida(const AResultado: TResultadoParser): string;
  end;

function NewStringParser(const AConfig: TParserConfig): IStringParser;

// Helper para criar config padrão (key=value)
function DefaultKeyValueConfig: TParserConfig;

implementation

uses System.IOUtils;

// ---------------------------------------------------------------------------
// TResultadoParser
// ---------------------------------------------------------------------------

function TResultadoParser.ToString: string;
var SB: TStringBuilder;
    C:  TCampoExtraido;
    E:  TErroParser;
begin
  SB := TStringBuilder.Create;
  try
    SB.AppendFormat('Campos: %d  Erros: %d  Sucesso: %s'#13#10,
      [Length(Campos), Length(Erros), BoolToStr(Sucesso, True)]);
    for C in Campos do
      SB.AppendFormat('  [L%d] %s = %s'#13#10, [C.Linha, C.Nome, C.Valor]);
    for E in Erros do
      SB.AppendFormat('  ERRO L%d:%d — %s'#13#10, [E.Linha, E.Coluna, E.Mensagem]);
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

// ---------------------------------------------------------------------------
// TStringParser
// ---------------------------------------------------------------------------

constructor TStringParser.Create(const AConfig: TParserConfig);
begin
  inherited Create;
  FConfig := AConfig;
  InicializarPadroesRE;
end;

procedure TStringParser.InicializarPadroesRE;
begin
  if FConfig.PatternChave <> '' then
    FREChave := TRegEx.Create(FConfig.PatternChave, [roIgnoreCase]);
  if FConfig.PatternData <> '' then
    FREData := TRegEx.Create(FConfig.PatternData);
  if FConfig.PatternValor <> '' then
    FREValor := TRegEx.Create(FConfig.PatternValor);
end;

function TStringParser.LinhaEhComentario(const ALinha: string): Boolean;
var Trimada: string;
begin
  Trimada := ALinha.Trim;
  Result := (Trimada = '') or
    ((FConfig.ComentarioMarca <> '') and
      Trimada.StartsWith(FConfig.ComentarioMarca));
end;

function TStringParser.ProcessarLinha(const ALinha: string;
  ANumLinha: Integer; var Erros: TList<TErroParser>): TArray<TCampoExtraido>;
var Lista:  TList<TCampoExtraido>;
    M:      TMatch;
    Campo:  TCampoExtraido;
    Erro:   TErroParser;
begin
  Lista := TList<TCampoExtraido>.Create;
  try
    if FConfig.PatternChave <> '' then
    begin
      M := FREChave.Match(ALinha);
      if M.Success and (M.Groups.Count >= 3) then
      begin
        Campo.Linha := ANumLinha;
        Campo.Nome  := M.Groups[1].Value.Trim;
        Campo.Valor := M.Groups[2].Value.Trim;
        Lista.Add(Campo);
      end
      else if not LinhaEhComentario(ALinha) then
      begin
        // Linha não vazia e não bate com padrão — registrar como erro
        Erro.Linha    := ANumLinha;
        Erro.Coluna   := 1;
        Erro.Mensagem := 'Linha não reconhecida: ' + ALinha.Trim.Substring(0, 50);
        Erros.Add(Erro);
      end;
    end
    else if FConfig.Delimitador <> #0 then
    begin
      // Parser CSV-like por delimitador
      var Partes := ALinha.Split([FConfig.Delimitador]);
      for var I := 0 to High(Partes) do
      begin
        Campo.Linha := ANumLinha;
        Campo.Nome  := 'col' + I.ToString;
        Campo.Valor := Partes[I].Trim;
        Lista.Add(Campo);
      end;
    end;

    Result := Lista.ToArray;
  finally
    Lista.Free;
  end;
end;

function TStringParser.ParsearTexto(const ATexto: string): TResultadoParser;
var SR:     TStringReader;
    Linha:  string;
    NLinha: Integer;
    CamposL: TArray<TCampoExtraido>;
    ListaCampos: TList<TCampoExtraido>;
    ListaErros:  TList<TErroParser>;
begin
  ListaCampos := TList<TCampoExtraido>.Create;
  ListaErros  := TList<TErroParser>.Create;
  try
    SR := TStringReader.Create(ATexto);
    try
      NLinha := 0;
      Linha := SR.ReadLine;
      while Linha <> '' do
      begin
        Inc(NLinha);
        if not LinhaEhComentario(Linha) then
        begin
          CamposL := ProcessarLinha(Linha, NLinha, ListaErros);
          ListaCampos.AddRange(CamposL);
        end;
        Linha := SR.ReadLine;
      end;
    finally
      SR.Free;
    end;

    Result.Campos  := ListaCampos.ToArray;
    Result.Erros   := ListaErros.ToArray;
    Result.Sucesso := Length(Result.Erros) = 0;
  finally
    ListaCampos.Free;
    ListaErros.Free;
  end;
end;

function TStringParser.ParsearArquivo(const ACaminho: string): TResultadoParser;
begin
  if not TFile.Exists(ACaminho) then
    raise EFileNotFoundException.Create('Arquivo não encontrado: ' + ACaminho);
  var Conteudo := TFile.ReadAllText(ACaminho, TEncoding.UTF8);
  Result := ParsearTexto(Conteudo);
end;

function TStringParser.FormatarSaida(
  const AResultado: TResultadoParser): string;
var SB:  TStringBuilder;
    C:   TCampoExtraido;
    E:   TErroParser;
    LenMax: Integer;
begin
  SB := TStringBuilder.Create;
  try
    // Calcular largura máxima do nome para alinhamento
    LenMax := 0;
    for C in AResultado.Campos do
      if C.Nome.Length > LenMax then LenMax := C.Nome.Length;
    Inc(LenMax, 2);

    SB.AppendLine('=== Resultado do Parser ===');
    SB.AppendFormat('Campos: %d  |  Erros: %d  |  %s'#13#10,
      [Length(AResultado.Campos), Length(AResultado.Erros),
       IfThen(AResultado.Sucesso, 'OK', 'COM ERROS')]);
    SB.AppendLine(StringOfChar('-', 50));

    for C in AResultado.Campos do
      SB.AppendFormat('[L%3d] %s %s'#13#10,
        [C.Linha, C.Nome.PadRight(LenMax), C.Valor]);

    if Length(AResultado.Erros) > 0 then
    begin
      SB.AppendLine(StringOfChar('-', 50));
      SB.AppendLine('ERROS:');
      for E in AResultado.Erros do
        SB.AppendFormat('  L%d:%d — %s'#13#10, [E.Linha, E.Coluna, E.Mensagem]);
    end;

    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

function NewStringParser(const AConfig: TParserConfig): IStringParser;
begin
  Result := TStringParser.Create(AConfig);
end;

function DefaultKeyValueConfig: TParserConfig;
begin
  Result.PatternChave    := '^\s*(\w[\w.]*)\s*[=:]\s*(.+?)\s*$';
  Result.PatternData     := '';
  Result.PatternValor    := '';
  Result.ComentarioMarca := '#';
  Result.Delimitador     := #0;
end;

// ---------------------------------------------------------------------------
// Exemplo de uso (comentado — descomente para testar)
// ---------------------------------------------------------------------------
(*
procedure DemoStringParser;
var Config:    TParserConfig;
    Parser:    IStringParser;
    Resultado: TResultadoParser;
    Texto:     string;
begin
  Texto :=
    '# Configuração do sistema'#13#10 +
    'nome = GestorERP'#13#10 +
    'versao: 2.0'#13#10 +
    'debug = true'#13#10 +
    'max_conexoes = 10'#13#10 +
    'linha inválida sem separador'#13#10 +
    'timeout = 30';

  Config := DefaultKeyValueConfig;
  Parser := NewStringParser(Config);

  Resultado := Parser.ParsearTexto(Texto);
  Writeln(Parser.FormatarSaida(Resultado));
end;
*)

end.

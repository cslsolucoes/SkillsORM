unit facade;
{
  Facade Pattern em Delphi — Facade para subsistema de relatórios
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Subsistema 1 — Acesso a dados
// ---------------------------------------------------------------------------
type
  TDataAccessLayer = class
  private
    FConectado: Boolean;
  public
    procedure Conectar(const AConnStr: string);
    procedure Desconectar;
    function  ConsultarDados(const ASQL: string): TArray<TArray<string>>;
    function  ContarRegistros(const ATabela: string): Integer;
  end;

// ---------------------------------------------------------------------------
// Subsistema 2 — Formatação
// ---------------------------------------------------------------------------
type
  TFormatoRelatorio = (frCSV, frHTML, frTexto);

  TRelatorioFormatter = class
  public
    function FormatarCSV(const ACabecalho: TArray<string>;
                         const ADados: TArray<TArray<string>>): string;
    function FormatarHTML(const ATitulo: string;
                          const ACabecalho: TArray<string>;
                          const ADados: TArray<TArray<string>>): string;
    function FormatarTexto(const ATitulo: string;
                           const ACabecalho: TArray<string>;
                           const ADados: TArray<TArray<string>>): string;
  end;

// ---------------------------------------------------------------------------
// Subsistema 3 — Exportação
// ---------------------------------------------------------------------------
type
  TExportEngine = class
  public
    procedure SalvarArquivo(const AConteudo, ACaminho: string);
    procedure EnviarEmail(const ADestinatario, AAssunto, ACorpo: string);
    procedure ImprimirConsole(const AConteudo: string);
  end;

// ---------------------------------------------------------------------------
// Subsistema 4 — Log e Auditoria
// ---------------------------------------------------------------------------
type
  TAuditLogger = class
  private
    FLog: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegistrarGeracao(const ARelat, AFormato: string);
    procedure RegistrarErro(const AMsg: string);
    function  ObterLog: string;
  end;

// ---------------------------------------------------------------------------
// FACADE — interface simplificada para o cliente
//   Esconde toda a complexidade dos 4 subsistemas
// ---------------------------------------------------------------------------
type
  TOpcoesRelatorio = record
    Titulo:       string;
    SQL:          string;
    Cabecalho:    TArray<string>;
    Formato:      TFormatoRelatorio;
    CaminhoSaida: string;         // vazio = não salvar
    EmailDest:    string;         // vazio = não enviar
    Imprimir:     Boolean;
  end;

  TRelatorioFacade = class
  private
    FData:      TDataAccessLayer;
    FFormatter: TRelatorioFormatter;
    FExport:    TExportEngine;
    FAudit:     TAuditLogger;
    FConnStr:   string;
    function FormatarConteudo(const AConf: TOpcoesRelatorio;
                               const ADados: TArray<TArray<string>>): string;
  public
    constructor Create(const AConnStr: string);
    destructor Destroy; override;
    // Interface simplificada — um método faz tudo
    function GerarRelatorio(const AOpts: TOpcoesRelatorio): string;
    // Atalhos convenientes
    function GerarCSV(const ASQL: string; const ACabecalho: TArray<string>): string;
    function GerarHTML(const ATitulo, ASQL: string; const ACabecalho: TArray<string>): string;
    function ObterAudit: string;
  end;

// Helper para construir TOpcoesRelatorio
function NovasOpcoes(const ATitulo, ASQL: string): TOpcoesRelatorio;

implementation

// ---------------------------------------------------------------------------
// TDataAccessLayer
// ---------------------------------------------------------------------------

procedure TDataAccessLayer.Conectar(const AConnStr: string);
begin FConectado := True; Writeln('[DAL] Conectado: ', AConnStr); end;

procedure TDataAccessLayer.Desconectar;
begin FConectado := False; end;

function TDataAccessLayer.ConsultarDados(const ASQL: string): TArray<TArray<string>>;
begin
  Writeln('[DAL] Query: ', ASQL);
  // Simular resultado
  SetLength(Result, 3);
  Result[0] := ['1', 'Alice', '25'];
  Result[1] := ['2', 'Bob',   '30'];
  Result[2] := ['3', 'Carol', '28'];
end;

function TDataAccessLayer.ContarRegistros(const ATabela: string): Integer;
begin Result := 3; end;

// ---------------------------------------------------------------------------
// TRelatorioFormatter
// ---------------------------------------------------------------------------

function TRelatorioFormatter.FormatarCSV(const ACabecalho: TArray<string>;
  const ADados: TArray<TArray<string>>): string;
var SB: TStringBuilder;
    Row: TArray<string>;
begin
  SB := TStringBuilder.Create;
  try
    SB.AppendLine(string.Join(';', ACabecalho));
    for Row in ADados do SB.AppendLine(string.Join(';', Row));
    Result := SB.ToString;
  finally SB.Free; end;
end;

function TRelatorioFormatter.FormatarHTML(const ATitulo: string;
  const ACabecalho: TArray<string>; const ADados: TArray<TArray<string>>): string;
var SB: TStringBuilder;
    Row: TArray<string>;
    C: string;
begin
  SB := TStringBuilder.Create;
  try
    SB.AppendLine('<html><body>');
    SB.AppendLine('<h2>' + ATitulo + '</h2>');
    SB.AppendLine('<table border="1">');
    SB.Append('<tr>');
    for C in ACabecalho do SB.Append('<th>' + C + '</th>');
    SB.AppendLine('</tr>');
    for Row in ADados do
    begin
      SB.Append('<tr>');
      for C in Row do SB.Append('<td>' + C + '</td>');
      SB.AppendLine('</tr>');
    end;
    SB.AppendLine('</table></body></html>');
    Result := SB.ToString;
  finally SB.Free; end;
end;

function TRelatorioFormatter.FormatarTexto(const ATitulo: string;
  const ACabecalho: TArray<string>; const ADados: TArray<TArray<string>>): string;
var SB: TStringBuilder;
    Row: TArray<string>;
begin
  SB := TStringBuilder.Create;
  try
    SB.AppendLine('=== ' + ATitulo + ' ===');
    SB.AppendLine(string.Join(' | ', ACabecalho));
    SB.AppendLine(StringOfChar('-', 40));
    for Row in ADados do SB.AppendLine(string.Join(' | ', Row));
    Result := SB.ToString;
  finally SB.Free; end;
end;

// ---------------------------------------------------------------------------
// TExportEngine
// ---------------------------------------------------------------------------

procedure TExportEngine.SalvarArquivo(const AConteudo, ACaminho: string);
begin Writeln('[Export] Salvo em: ', ACaminho, ' (', Length(AConteudo), ' bytes)'); end;

procedure TExportEngine.EnviarEmail(const ADestinatario, AAssunto, ACorpo: string);
begin Writeln('[Export] Email para: ', ADestinatario, ' assunto: ', AAssunto); end;

procedure TExportEngine.ImprimirConsole(const AConteudo: string);
begin Writeln(AConteudo); end;

// ---------------------------------------------------------------------------
// TAuditLogger
// ---------------------------------------------------------------------------

constructor TAuditLogger.Create;
begin inherited Create; FLog := TStringList.Create; end;

destructor TAuditLogger.Destroy;
begin FLog.Free; inherited; end;

procedure TAuditLogger.RegistrarGeracao(const ARelat, AFormato: string);
begin FLog.Add(Format('[%s] Gerado "%s" formato=%s',
  [FormatDateTime('hh:nn:ss', Now), ARelat, AFormato])); end;

procedure TAuditLogger.RegistrarErro(const AMsg: string);
begin FLog.Add(Format('[%s] ERRO: %s', [FormatDateTime('hh:nn:ss', Now), AMsg])); end;

function TAuditLogger.ObterLog: string;
begin Result := FLog.Text; end;

// ---------------------------------------------------------------------------
// TRelatorioFacade
// ---------------------------------------------------------------------------

constructor TRelatorioFacade.Create(const AConnStr: string);
begin
  inherited Create;
  FConnStr   := AConnStr;
  FData      := TDataAccessLayer.Create;
  FFormatter := TRelatorioFormatter.Create;
  FExport    := TExportEngine.Create;
  FAudit     := TAuditLogger.Create;
  FData.Conectar(FConnStr);
end;

destructor TRelatorioFacade.Destroy;
begin
  FData.Desconectar;
  FData.Free; FFormatter.Free; FExport.Free; FAudit.Free;
  inherited;
end;

function TRelatorioFacade.FormatarConteudo(const AConf: TOpcoesRelatorio;
  const ADados: TArray<TArray<string>>): string;
begin
  case AConf.Formato of
    frCSV:   Result := FFormatter.FormatarCSV(AConf.Cabecalho, ADados);
    frHTML:  Result := FFormatter.FormatarHTML(AConf.Titulo, AConf.Cabecalho, ADados);
    frTexto: Result := FFormatter.FormatarTexto(AConf.Titulo, AConf.Cabecalho, ADados);
  end;
end;

function TRelatorioFacade.GerarRelatorio(const AOpts: TOpcoesRelatorio): string;
var Dados:   TArray<TArray<string>>;
    Conteudo: string;
begin
  try
    Dados    := FData.ConsultarDados(AOpts.SQL);
    Conteudo := FormatarConteudo(AOpts, Dados);

    if AOpts.CaminhoSaida <> '' then
      FExport.SalvarArquivo(Conteudo, AOpts.CaminhoSaida);

    if AOpts.EmailDest <> '' then
      FExport.EnviarEmail(AOpts.EmailDest, 'Relatório: ' + AOpts.Titulo, Conteudo);

    if AOpts.Imprimir then
      FExport.ImprimirConsole(Conteudo);

    FAudit.RegistrarGeracao(AOpts.Titulo,
      ['CSV','HTML','Texto'][Ord(AOpts.Formato)]);
    Result := Conteudo;
  except
    on E: Exception do
    begin
      FAudit.RegistrarErro(E.Message);
      raise;
    end;
  end;
end;

function TRelatorioFacade.GerarCSV(const ASQL: string;
  const ACabecalho: TArray<string>): string;
var Opts: TOpcoesRelatorio;
begin
  Opts := NovasOpcoes('Exportação CSV', ASQL);
  Opts.Cabecalho := ACabecalho;
  Opts.Formato   := frCSV;
  Result := GerarRelatorio(Opts);
end;

function TRelatorioFacade.GerarHTML(const ATitulo, ASQL: string;
  const ACabecalho: TArray<string>): string;
var Opts: TOpcoesRelatorio;
begin
  Opts := NovasOpcoes(ATitulo, ASQL);
  Opts.Cabecalho := ACabecalho;
  Opts.Formato   := frHTML;
  Result := GerarRelatorio(Opts);
end;

function TRelatorioFacade.ObterAudit: string;
begin Result := FAudit.ObterLog; end;

function NovasOpcoes(const ATitulo, ASQL: string): TOpcoesRelatorio;
begin
  Result.Titulo       := ATitulo;
  Result.SQL          := ASQL;
  Result.Formato      := frTexto;
  Result.CaminhoSaida := '';
  Result.EmailDest    := '';
  Result.Imprimir     := False;
end;

// ---------------------------------------------------------------------------
// USO:
//   // Cliente usa apenas a Facade — não conhece DAL, Formatter, Export, Audit
//   var F := TRelatorioFacade.Create('server=localhost;db=gestao');
//   try
//     // Simples: só quer o conteúdo
//     var CSV := F.GerarCSV('SELECT * FROM usuarios', ['id','nome','idade']);
//     Writeln(CSV);
//
//     // Completo: salvar + email
//     var Opts := NovasOpcoes('Relatório Mensal', 'SELECT * FROM pedidos');
//     Opts.Cabecalho    := ['id', 'nome', 'valor'];
//     Opts.Formato      := frHTML;
//     Opts.CaminhoSaida := 'C:\relatorios\mensal.html';
//     Opts.EmailDest    := 'gerente@empresa.com';
//     F.GerarRelatorio(Opts);
//
//     Writeln(F.ObterAudit);
//   finally
//     F.Free;
//   end;
// ---------------------------------------------------------------------------

end.

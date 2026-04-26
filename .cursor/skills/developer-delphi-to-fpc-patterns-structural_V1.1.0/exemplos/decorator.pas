unit decorator;
{
  Decorator pattern em Delphi — ILogger com cadeia de decoradores
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Interface base do componente
// ---------------------------------------------------------------------------
type
  ILogger = interface
  ['{80000008-0000-0000-0000-000000000008}']
    procedure Log(const AMsg: string);
    procedure LogFmt(const AFmt: string; const AArgs: array of const);
  end;

// ---------------------------------------------------------------------------
// Componente concreto base (sem decoração)
// ---------------------------------------------------------------------------
type
  TConsoleLogger = class(TInterfacedObject, ILogger)
  public
    procedure Log(const AMsg: string);
    procedure LogFmt(const AFmt: string; const AArgs: array of const);
  end;

  TMemoryLogger = class(TInterfacedObject, ILogger)
  private
    FLines: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Log(const AMsg: string);
    procedure LogFmt(const AFmt: string; const AArgs: array of const);
    function  GetLines: TStrings;
  end;

// ---------------------------------------------------------------------------
// Base abstrata dos decoradores — delega para FInner
// ---------------------------------------------------------------------------
type
  TLoggerDecorator = class abstract(TInterfacedObject, ILogger)
  protected
    FInner: ILogger;
  public
    constructor Create(AInner: ILogger);
    procedure Log(const AMsg: string); virtual;
    procedure LogFmt(const AFmt: string; const AArgs: array of const); virtual;
  end;

// ---------------------------------------------------------------------------
// Decoradores concretos — cada um adiciona um aspecto
// ---------------------------------------------------------------------------
type
  // Adiciona timestamp prefix
  TTimestampLogger = class(TLoggerDecorator)
  private
    FFormato: string;
  public
    constructor Create(AInner: ILogger; const AFormato: string = 'hh:nn:ss.zzz');
    procedure Log(const AMsg: string); override;
  end;

  // Adiciona prefixo de nível (INFO, ERROR, WARN)
  TLevelLogger = class(TLoggerDecorator)
  private
    FNivel: string;
  public
    constructor Create(AInner: ILogger; const ANivel: string);
    procedure Log(const AMsg: string); override;
  end;

  // Filtra mensagens por substring proibida
  TFilterLogger = class(TLoggerDecorator)
  private
    FPalavrasProibidas: TArray<string>;
  public
    constructor Create(AInner: ILogger; const APalavras: TArray<string>);
    procedure Log(const AMsg: string); override;
  end;

  // Duplica o log para dois destinos
  TMultiplexLogger = class(TInterfacedObject, ILogger)
  private
    FLoggers: TArray<ILogger>;
  public
    constructor Create(const ALoggers: TArray<ILogger>);
    procedure Log(const AMsg: string);
    procedure LogFmt(const AFmt: string; const AArgs: array of const);
  end;

// Factory fluente para construir cadeia de decoradores
function LoggerPara(ABase: ILogger): ILogger;
function ComTimestamp(ALogger: ILogger; const AFmt: string = 'hh:nn:ss'): ILogger;
function ComNivel(ALogger: ILogger; const ANivel: string): ILogger;
function ComFiltro(ALogger: ILogger; const APalavras: TArray<string>): ILogger;

implementation

// ---------------------------------------------------------------------------
// TConsoleLogger
// ---------------------------------------------------------------------------

procedure TConsoleLogger.Log(const AMsg: string);
begin Writeln(AMsg); end;

procedure TConsoleLogger.LogFmt(const AFmt: string; const AArgs: array of const);
begin Writeln(Format(AFmt, AArgs)); end;

// ---------------------------------------------------------------------------
// TMemoryLogger
// ---------------------------------------------------------------------------

constructor TMemoryLogger.Create;
begin inherited Create; FLines := TStringList.Create; end;

destructor TMemoryLogger.Destroy;
begin FLines.Free; inherited; end;

procedure TMemoryLogger.Log(const AMsg: string);
begin FLines.Add(AMsg); end;

procedure TMemoryLogger.LogFmt(const AFmt: string; const AArgs: array of const);
begin FLines.Add(Format(AFmt, AArgs)); end;

function TMemoryLogger.GetLines: TStrings;
begin Result := FLines; end;

// ---------------------------------------------------------------------------
// TLoggerDecorator — base
// ---------------------------------------------------------------------------

constructor TLoggerDecorator.Create(AInner: ILogger);
begin inherited Create; FInner := AInner; end;

procedure TLoggerDecorator.Log(const AMsg: string);
begin FInner.Log(AMsg); end;

procedure TLoggerDecorator.LogFmt(const AFmt: string; const AArgs: array of const);
begin FInner.LogFmt(AFmt, AArgs); end;

// ---------------------------------------------------------------------------
// TTimestampLogger
// ---------------------------------------------------------------------------

constructor TTimestampLogger.Create(AInner: ILogger; const AFormato: string);
begin inherited Create(AInner); FFormato := AFormato; end;

procedure TTimestampLogger.Log(const AMsg: string);
begin
  FInner.Log(Format('[%s] %s', [FormatDateTime(FFormato, Now), AMsg]));
end;

// ---------------------------------------------------------------------------
// TLevelLogger
// ---------------------------------------------------------------------------

constructor TLevelLogger.Create(AInner: ILogger; const ANivel: string);
begin inherited Create(AInner); FNivel := ANivel.ToUpper; end;

procedure TLevelLogger.Log(const AMsg: string);
begin
  FInner.Log(Format('[%s] %s', [FNivel, AMsg]));
end;

// ---------------------------------------------------------------------------
// TFilterLogger
// ---------------------------------------------------------------------------

constructor TFilterLogger.Create(AInner: ILogger; const APalavras: TArray<string>);
begin inherited Create(AInner); FPalavrasProibidas := APalavras; end;

procedure TFilterLogger.Log(const AMsg: string);
var P: string;
begin
  for P in FPalavrasProibidas do
    if AMsg.ToLower.Contains(P.ToLower) then Exit;  // filtrado — não passa
  FInner.Log(AMsg);
end;

// ---------------------------------------------------------------------------
// TMultiplexLogger
// ---------------------------------------------------------------------------

constructor TMultiplexLogger.Create(const ALoggers: TArray<ILogger>);
begin inherited Create; FLoggers := ALoggers; end;

procedure TMultiplexLogger.Log(const AMsg: string);
var L: ILogger;
begin for L in FLoggers do L.Log(AMsg); end;

procedure TMultiplexLogger.LogFmt(const AFmt: string; const AArgs: array of const);
var L: ILogger;
begin for L in FLoggers do L.LogFmt(AFmt, AArgs); end;

// ---------------------------------------------------------------------------
// Helpers fluentes
// ---------------------------------------------------------------------------

function LoggerPara(ABase: ILogger): ILogger;
begin Result := ABase; end;

function ComTimestamp(ALogger: ILogger; const AFmt: string): ILogger;
begin Result := TTimestampLogger.Create(ALogger, AFmt); end;

function ComNivel(ALogger: ILogger; const ANivel: string): ILogger;
begin Result := TLevelLogger.Create(ALogger, ANivel); end;

function ComFiltro(ALogger: ILogger; const APalavras: TArray<string>): ILogger;
begin Result := TFilterLogger.Create(ALogger, APalavras); end;

// ---------------------------------------------------------------------------
// USO:
//   // Simples
//   var L: ILogger := TConsoleLogger.Create;
//   L.Log('Mensagem simples');
//
//   // Cadeia de decoradores
//   var LDecorado: ILogger :=
//     ComFiltro(
//       ComTimestamp(
//         ComNivel(
//           TConsoleLogger.Create, 'INFO'),
//         'hh:nn:ss'),
//       ['senha', 'password']);
//   LDecorado.Log('Usuário logado');        // [INFO] [09:15:30] Usuário logado
//   LDecorado.Log('Senha: 1234');           // filtrado — não aparece
//
//   // Multiplex — log simultâneo para console e memória
//   var Mem := TMemoryLogger.Create;
//   var Multi: ILogger := TMultiplexLogger.Create(
//     [TConsoleLogger.Create, Mem]);
//   Multi.Log('Para os dois');
//   Writeln(Mem.GetLines.Count);  // 1
// ---------------------------------------------------------------------------

end.

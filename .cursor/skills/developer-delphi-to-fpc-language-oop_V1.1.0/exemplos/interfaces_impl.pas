unit interfaces_impl;
{
  EXEMPLO: Interfaces em Delphi — IInterface, TInterfacedObject, GUID
  Compilavel: dcc32 / dcc64
  Demonstra:
    - Declarar interface com GUID
    - Implementar com TInterfacedObject (reference counting)
    - Implementar com TObject (sem reference counting)
    - QueryInterface, _AddRef, _Release
    - Interface como parametro (mais seguro que classe)
    - Multiplas interfaces em uma classe
    - Ciclos de referencia e como evitar (weak references)
}

interface

uses
  System.SysUtils;

// ---------------------------------------------------------------------------
// Interfaces do dominio
// ---------------------------------------------------------------------------
type
  ILogger = interface
  ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    procedure Log(const AMensagem: string);
    procedure LogErro(const AMensagem: string; AException: Exception = nil);
    function  NivelAtivo: Boolean;
  end;

type
  IRepositorio<T> = interface
  ['{12345678-1234-1234-1234-123456789012}']
    function BuscarPorId(AId: Integer): T;
    procedure Salvar(const AItem: T);
    procedure Excluir(AId: Integer);
  end;

// ---------------------------------------------------------------------------
// Implementacao com TInterfacedObject (reference counting automatico)
// ---------------------------------------------------------------------------
type
  TConsoleLogger = class(TInterfacedObject, ILogger)
  private
    FPrefixo: string;
  public
    constructor Create(const APrefixo: string = '');
    procedure Log(const AMensagem: string);
    procedure LogErro(const AMensagem: string; AException: Exception = nil);
    function  NivelAtivo: Boolean;
  end;

// ---------------------------------------------------------------------------
// Implementacao COM DUAS interfaces
// ---------------------------------------------------------------------------
type
  IDesligavel = interface
  ['{AABBCCDD-1122-3344-5566-778899AABBCC}']
    procedure Desligar;
    function  EstaLigado: Boolean;
  end;

type
  TServicoLogger = class(TInterfacedObject, ILogger, IDesligavel)
  private
    FLigado: Boolean;
  public
    constructor Create;
    // ILogger
    procedure Log(const AMensagem: string);
    procedure LogErro(const AMensagem: string; AException: Exception = nil);
    function  NivelAtivo: Boolean;
    // IDesligavel
    procedure Desligar;
    function  EstaLigado: Boolean;
  end;

// ---------------------------------------------------------------------------
// Implementacao sem reference counting (classe gerencia proprio ciclo de vida)
// ---------------------------------------------------------------------------
type
  TFileLogger = class(TObject, ILogger)
  private
    FArquivo: string;
    // Implementar manualmente _AddRef/_Release que nao liberam o objeto
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    constructor Create(const AArquivo: string);
    procedure Log(const AMensagem: string);
    procedure LogErro(const AMensagem: string; AException: Exception = nil);
    function  NivelAtivo: Boolean;
  end;

implementation

// ---------------------------------------------------------------------------
// TConsoleLogger
// ---------------------------------------------------------------------------

constructor TConsoleLogger.Create(const APrefixo: string);
begin
  inherited Create;
  FPrefixo := APrefixo;
end;

procedure TConsoleLogger.Log(const AMensagem: string);
begin
  if FPrefixo.IsEmpty then
    Writeln('[LOG] ', AMensagem)
  else
    Writeln('[', FPrefixo, '] ', AMensagem);
end;

procedure TConsoleLogger.LogErro(const AMensagem: string; AException: Exception);
begin
  if Assigned(AException) then
    Writeln('[ERRO] ', AMensagem, ': ', AException.Message)
  else
    Writeln('[ERRO] ', AMensagem);
end;

function TConsoleLogger.NivelAtivo: Boolean;
begin
  Result := True;
end;

// ---------------------------------------------------------------------------
// TServicoLogger
// ---------------------------------------------------------------------------

constructor TServicoLogger.Create;
begin
  inherited Create;
  FLigado := True;
end;

procedure TServicoLogger.Log(const AMensagem: string);
begin
  if FLigado then Writeln('[SVC] ', AMensagem);
end;

procedure TServicoLogger.LogErro(const AMensagem: string; AException: Exception);
begin
  if FLigado then Writeln('[SVC-ERRO] ', AMensagem);
end;

function TServicoLogger.NivelAtivo: Boolean;
begin
  Result := FLigado;
end;

procedure TServicoLogger.Desligar;
begin
  FLigado := False;
  Writeln('Servico desligado.');
end;

function TServicoLogger.EstaLigado: Boolean;
begin
  Result := FLigado;
end;

// ---------------------------------------------------------------------------
// TFileLogger (sem reference counting gerenciado)
// ---------------------------------------------------------------------------

constructor TFileLogger.Create(const AArquivo: string);
begin
  inherited Create;
  FArquivo := AArquivo;
end;

function TFileLogger.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then Result := S_OK
  else Result := E_NOINTERFACE;
end;

function TFileLogger._AddRef: Integer;
begin
  Result := -1; // desabilita reference counting
end;

function TFileLogger._Release: Integer;
begin
  Result := -1; // desabilita reference counting — NAO auto-destroi
end;

procedure TFileLogger.Log(const AMensagem: string);
begin
  // AppendToFile(FArquivo, AMensagem);
  Writeln('[FILE] ', AMensagem);
end;

procedure TFileLogger.LogErro(const AMensagem: string; AException: Exception);
begin
  Writeln('[FILE-ERRO] ', AMensagem);
end;

function TFileLogger.NivelAtivo: Boolean;
begin
  Result := True;
end;

// ---------------------------------------------------------------------------
// Demonstracao de uso
// ---------------------------------------------------------------------------
procedure DemonstrarInterfaces;
var
  Log: ILogger;
  Svc: IDesligavel;
begin
  // TInterfacedObject: atribuir a variavel de interface gerencia o ciclo de vida
  Log := TConsoleLogger.Create('APP');
  // Quando Log sair do escopo ou for atribuido nil:
  //   _Release decrementa RefCount para 0 → objeto destruido automaticamente

  Log.Log('Sistema iniciado');

  try
    raise Exception.Create('Erro de teste');
  except
    on E: Exception do
      Log.LogErro('Falha no processo', E);
  end;

  // Multiplas interfaces: variaveis separadas, mesmo objeto
  var ServicoObj := TServicoLogger.Create;
  Log := ServicoObj;  // ILogger
  Svc := ServicoObj;  // IDesligavel (mesmo objeto, RefCount=2)

  Log.Log('Via ILogger');
  Svc.Desligar;
  Writeln('Ainda ativo? ', Log.NivelAtivo); // False

  // QueryInterface: verificar se objeto suporta outra interface
  if Supports(Log, IDesligavel, Svc) then
    Writeln('Log suporta IDesligavel');

  // TFileLogger: ciclo de vida gerenciado manualmente
  var FileLog := TFileLogger.Create('app.log');
  try
    var LogI: ILogger := FileLog; // nao vai auto-destruir
    LogI.Log('Escrevendo no arquivo');
  finally
    FileLog.Free; // deve liberar manualmente
  end;
end;

end.

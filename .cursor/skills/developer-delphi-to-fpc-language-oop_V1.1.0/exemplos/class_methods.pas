unit class_methods;
{
  EXEMPLO: Class methods, class vars, Singleton em Delphi
  Compilavel: dcc32 / dcc64
  Demonstra:
    - class var: compartilhado entre todas as instancias
    - class function / class procedure: sem acesso a Self de instancia
    - class property: via class getter/setter
    - Singleton pattern com class var
    - Factory method como class function
    - Contagem de instancias
}

interface

uses
  System.SysUtils, System.SyncObjs;

// ---------------------------------------------------------------------------
// Contador de instancias com class var
// ---------------------------------------------------------------------------
type
  TRastreado = class
  private
    class var FContagem: Integer;
    FId: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    class function Contagem: Integer;
    property Id: Integer read FId;
  end;

// ---------------------------------------------------------------------------
// Singleton com thread safety
// ---------------------------------------------------------------------------
type
  TConfig = class
  private
    class var FInstancia: TConfig;
    class var FLock: TCriticalSection;

    FBancoDados: string;
    FServidor  : string;

    constructor Create; // privado — nao permite instanciar diretamente
  public
    class function GetInstancia: TConfig;
    class procedure Liberar;
    class constructor Create; // executado uma vez ao carregar a unit
    class destructor Destroy;

    property BancoDados: string read FBancoDados write FBancoDados;
    property Servidor  : string read FServidor   write FServidor;
  end;

// ---------------------------------------------------------------------------
// Factory method com class function
// ---------------------------------------------------------------------------
type
  TConexaoTipo = (ctFireDAC, ctUniDAC, ctZeos);

  TConexao = class abstract
  public
    class function Criar(ATipo: TConexaoTipo): TConexao;
    procedure Conectar; virtual; abstract;
    procedure Desconectar; virtual; abstract;
  end;

  TConexaoFireDAC = class(TConexao)
  public
    procedure Conectar;    override;
    procedure Desconectar; override;
  end;

  TConexaoUniDAC = class(TConexao)
  public
    procedure Conectar;    override;
    procedure Desconectar; override;
  end;

implementation

// ---------------------------------------------------------------------------
// TRastreado
// ---------------------------------------------------------------------------

constructor TRastreado.Create;
begin
  inherited Create;
  Inc(FContagem);
  FId := FContagem;
end;

destructor TRastreado.Destroy;
begin
  Dec(FContagem);
  inherited;
end;

class function TRastreado.Contagem: Integer;
begin
  Result := FContagem;
end;

// ---------------------------------------------------------------------------
// TConfig (Singleton)
// ---------------------------------------------------------------------------

class constructor TConfig.Create;
begin
  // Executado uma unica vez ao carregar a unit (antes de qualquer uso)
  FInstancia := nil;
  FLock      := TCriticalSection.Create;
end;

class destructor TConfig.Destroy;
begin
  // Executado ao descarregar a unit (no finalization)
  FreeAndNil(FInstancia);
  FreeAndNil(FLock);
end;

constructor TConfig.Create;
begin
  inherited Create;
  FBancoDados := 'gestordb';
  FServidor   := 'localhost';
end;

class function TConfig.GetInstancia: TConfig;
begin
  // Double-checked locking para thread safety
  if not Assigned(FInstancia) then
  begin
    FLock.Enter;
    try
      if not Assigned(FInstancia) then
        FInstancia := TConfig.Create;
    finally
      FLock.Leave;
    end;
  end;
  Result := FInstancia;
end;

class procedure TConfig.Liberar;
begin
  FLock.Enter;
  try
    FreeAndNil(FInstancia);
  finally
    FLock.Leave;
  end;
end;

// ---------------------------------------------------------------------------
// TConexao (Factory)
// ---------------------------------------------------------------------------

class function TConexao.Criar(ATipo: TConexaoTipo): TConexao;
begin
  case ATipo of
    ctFireDAC: Result := TConexaoFireDAC.Create;
    ctUniDAC : Result := TConexaoUniDAC.Create;
  else
    raise Exception.CreateFmt('Tipo de conexao nao suportado: %d', [Ord(ATipo)]);
  end;
end;

procedure TConexaoFireDAC.Conectar;    begin Writeln('FireDAC: Conectando...'); end;
procedure TConexaoFireDAC.Desconectar; begin Writeln('FireDAC: Desconectando.'); end;
procedure TConexaoUniDAC.Conectar;     begin Writeln('UniDAC: Conectando...');  end;
procedure TConexaoUniDAC.Desconectar;  begin Writeln('UniDAC: Desconectando.'); end;

// ---------------------------------------------------------------------------
// Demonstracao
// ---------------------------------------------------------------------------
procedure DemonstrarClassMethods;
var
  A, B: TRastreado;
  Conn: TConexao;
begin
  Writeln('Instancias antes: ', TRastreado.Contagem); // 0

  A := TRastreado.Create;
  B := TRastreado.Create;
  Writeln('Instancias: ', TRastreado.Contagem); // 2
  Writeln('A.Id = ', A.Id, ', B.Id = ', B.Id);

  FreeAndNil(A);
  Writeln('Instancias apos Free(A): ', TRastreado.Contagem); // 1
  FreeAndNil(B);

  // Singleton
  TConfig.GetInstancia.BancoDados := 'producao';
  Writeln(TConfig.GetInstancia.BancoDados); // 'producao'
  // Mesma instancia — class var compartilhada

  // Factory
  Conn := TConexao.Criar(ctFireDAC);
  try
    Conn.Conectar;
    Conn.Desconectar;
  finally
    Conn.Free;
  end;
end;

end.

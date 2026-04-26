unit TEMPLATE_singleton_safe;
{
  TEMPLATE: Singleton thread-safe Double-Checked Locking
  ───────────────────────────────────────────────────────
  Substituir:
    TServico       → nome da sua classe singleton
    IServico       → interface opcional (melhor testabilidade)
  ───────────────────────────────────────────────────────
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.SyncObjs;

// ---------------------------------------------------------------------------
// 1. Interface (recomendado — permite mock em testes)
// ---------------------------------------------------------------------------
type
  IServico = interface
  ['{00000000-0000-0000-0000-000000000003}']  // gerar novo GUID
    procedure Executar(const AComando: string);
    function  Configurar(const AChave, AValor: string): IServico;
    function  Obter(const AChave: string): string;
  end;

// ---------------------------------------------------------------------------
// 2. Implementação singleton
// ---------------------------------------------------------------------------
type
  TServico = class(TInterfacedObject, IServico)
  private
    // ── Infraestrutura singleton ──────────────────────────────────────────
    class var FInstancia: TServico;
    class var FLock: TCriticalSection;
    class constructor Create;   // inicializa FLock
    class destructor Destroy;   // destrói instância + lock

    // ── Estado interno ────────────────────────────────────────────────────
    // Adicionar campos de negócio aqui
    FConfig: array of record Chave, Valor: string; end;

    // Construtor privado — impede new() externo
    constructor CreateInternal;
  public
    // ── Acesso ao singleton ───────────────────────────────────────────────
    class function GetInstance: TServico;
    // Para testes: permite destruir e recriar
    class procedure ResetInstance;

    // ── Interface de negócio ──────────────────────────────────────────────
    procedure Executar(const AComando: string);
    function  Configurar(const AChave, AValor: string): IServico;
    function  Obter(const AChave: string): string;
  end;

// Atalho global (opcional — preferir injeção de dependência)
function Servico: TServico;

implementation

// ---------------------------------------------------------------------------
// Infraestrutura singleton
// ---------------------------------------------------------------------------

class constructor TServico.Create;
begin
  FLock := TCriticalSection.Create;
  // NÃO criar FInstancia aqui — lazy initialization via GetInstance
end;

class destructor TServico.Destroy;
begin
  FreeAndNil(FInstancia);
  FreeAndNil(FLock);
end;

constructor TServico.CreateInternal;
begin
  inherited Create;
  // Inicializar estado interno
  SetLength(FConfig, 0);
end;

class function TServico.GetInstance: TServico;
begin
  // Verificação sem lock — fast path
  if FInstancia = nil then
  begin
    FLock.Enter;
    try
      // Segunda verificação dentro do lock — garante unicidade
      if FInstancia = nil then
        FInstancia := TServico.CreateInternal;
    finally
      FLock.Leave;
    end;
  end;
  Result := FInstancia;
end;

class procedure TServico.ResetInstance;
begin
  FLock.Enter;
  try FreeAndNil(FInstancia);
  finally FLock.Leave; end;
end;

// ---------------------------------------------------------------------------
// Interface de negócio
// ---------------------------------------------------------------------------

procedure TServico.Executar(const AComando: string);
begin
  Writeln('[Servico] Executar: ', AComando);
  // Implementar lógica aqui
end;

function TServico.Configurar(const AChave, AValor: string): IServico;
var I, N: Integer;
begin
  // Buscar existente
  for I := 0 to High(FConfig) do
    if FConfig[I].Chave = AChave then
    begin
      FConfig[I].Valor := AValor;
      Result := Self; Exit;
    end;
  // Adicionar novo
  N := Length(FConfig);
  SetLength(FConfig, N + 1);
  FConfig[N].Chave := AChave;
  FConfig[N].Valor := AValor;
  Result := Self;
end;

function TServico.Obter(const AChave: string): string;
var I: Integer;
begin
  for I := 0 to High(FConfig) do
    if FConfig[I].Chave = AChave then
    begin Result := FConfig[I].Valor; Exit; end;
  Result := '';
end;

function Servico: TServico;
begin Result := TServico.GetInstance; end;

// ---------------------------------------------------------------------------
// COMO USAR ESTE TEMPLATE
//
// 1. Renomeie TServico e IServico conforme o domínio.
// 2. NÃO exponha TServico diretamente — prefira IServico para testabilidade.
// 3. Injete IServico como dependência nos construtores, não chame GetInstance
//    dentro do código de negócio.
//
// Uso básico:
//   TServico.GetInstance
//     .Configurar('host', 'localhost')
//     .Configurar('porta', '5432');
//   Writeln(TServico.GetInstance.Obter('host'));  // localhost
//   TServico.GetInstance.Executar('conectar');
//
// Em testes (reset entre testes):
//   procedure TTesteServico.TearDown;
//   begin TServico.ResetInstance; end;
//
// Injeção de dependência (recomendado):
//   type TRepositorio = class
//   private
//     FServico: IServico;
//   public
//     constructor Create(AServico: IServico);
//   end;
//   // Em produção:
//   var R := TRepositorio.Create(TServico.GetInstance);
//   // Em testes:
//   var R := TRepositorio.Create(TServicoMock.Create);
// ---------------------------------------------------------------------------

end.

(*
  EXEMPLO: Namespaces Delphi — convenção Company.Product.Module.Unit
  Skill: developer-delphi-to-fpc-architecture-modules_V1.0.0

  NAMESPACES NO DELPHI:
    O Delphi usa o ponto (".") como separador de namespace no nome das units.
    Nao ha keyword "namespace" — o nome da unit IS o namespace.

    Convencao recomendada:
      Empresa.Produto.Modulo.Responsabilidade
      GestorERP.Clientes.Repository.SQLite
      GestorERP.Common.Types
      GestorERP.Pagamento.Interfaces

  UNIT SCOPE NAMES (atalho no IDE):
    Project → Options → Delphi Compiler → Unit Scope Names
    Ex.: adicionar "GestorERP.Common" → permite usar "Types" em vez de "GestorERP.Common.Types"
    Analogia ao "using namespace" do C++.

  CONFLITO DE NOMES:
    Se existir "Types" em System.Types E em GestorERP.Common.Types,
    o compilador usa o primeiro encontrado na lista de Unit Scope Names.
    Regra: mais especifico tem prioridade; desambiguar com nome completo.

  ESTE ARQUIVO demonstra a convencao em um unico .pas compilavel.
  Compilar: dcc32 unit_namespaces.pas  OU  dcc64 unit_namespaces.pas
*)
program unit_namespaces;
{$APPTYPE CONSOLE}
{$IFDEF FPC}
  {$mode delphi}
  {$H+}
{$ENDIF}

uses
  SysUtils;

// =============================================================================
// Simulacao de tipos que normalmente estariam em units separadas com namespace
// Em um projeto real cada bloco seria um arquivo .pas diferente.
// =============================================================================

// --- GestorERP.Common.Types ---
// Caminho real: src/Commons/GestorERP.Common.Types.pas
type
  TEntityID   = type Integer;   // ID generico de entidade
  TValorMoeda = type Currency;  // valor monetario com precisao de moeda
  TStatusItem = (siAtivo, siInativo, siExcluido);

// --- GestorERP.Clientes.Interfaces ---
// Caminho real: src/Modulos/Clientes/GestorERP.Clientes.Interfaces.pas
type
  IClienteRepository = interface
    ['{CCCCCCCC-DDDD-EEEE-FFFF-000000000001}']
    function BuscarPorID(const AID: TEntityID): Boolean;
    function NomeCliente: string;
    function StatusCliente: TStatusItem;
  end;

// --- GestorERP.Clientes.Repository.Memory ---
// Caminho real: src/Modulos/Clientes/GestorERP.Clientes.Repository.Memory.pas
// (alternativa SQLite estaria em GestorERP.Clientes.Repository.SQLite.pas)
type
  TClienteRepositoryMemory = class(TInterfacedObject, IClienteRepository)
  private
    FID: TEntityID;
    FNome: string;
    FStatus: TStatusItem;
    FEncontrado: Boolean;
  public
    constructor Create;
    function BuscarPorID(const AID: TEntityID): Boolean;
    function NomeCliente: string;
    function StatusCliente: TStatusItem;
  end;

constructor TClienteRepositoryMemory.Create;
begin
  inherited Create;
  FEncontrado := False;
  FNome := '';
  FStatus := siInativo;
end;

function TClienteRepositoryMemory.BuscarPorID(const AID: TEntityID): Boolean;
begin
  // Simulacao de dados em memoria
  case AID of
    1: begin FNome := 'Carlos Mendes'; FStatus := siAtivo; FID := AID; FEncontrado := True; end;
    2: begin FNome := 'Fernanda Lima';  FStatus := siAtivo; FID := AID; FEncontrado := True; end;
    3: begin FNome := 'Roberto Alves'; FStatus := siInativo; FID := AID; FEncontrado := True; end;
  else
    FEncontrado := False;
  end;
  Result := FEncontrado;
end;

function TClienteRepositoryMemory.NomeCliente: string;
begin
  if not FEncontrado then
    raise Exception.Create('BuscarPorID deve ser chamado antes de NomeCliente');
  Result := FNome;
end;

function TClienteRepositoryMemory.StatusCliente: TStatusItem;
begin
  if not FEncontrado then
    raise Exception.Create('BuscarPorID deve ser chamado antes de StatusCliente');
  Result := FStatus;
end;

// --- GestorERP.Clientes.Factory ---
// Caminho real: src/Modulos/Clientes/GestorERP.Clientes.Factory.pas
type
  TClienteRepositoryFactory = class
  public
    // New(engine) → retorna implementacao adequada para o engine solicitado
    class function New(const AEngine: string = 'memory'): IClienteRepository;
  end;

class function TClienteRepositoryFactory.New(const AEngine: string): IClienteRepository;
begin
  if SameText(AEngine, 'memory') then
    Result := TClienteRepositoryMemory.Create
  else
    raise Exception.CreateFmt(
      'GestorERP.Clientes.Factory: engine nao suportado: %s', [AEngine]);
end;

// =============================================================================
// Convencao de nomenclatura — tabela de referencia rapida
// =============================================================================

procedure ExibirConvencaoNomenclatura;
begin
  WriteLn('--- Convencao de Nomenclatura de Units ---');
  WriteLn;
  WriteLn('Padrao: Empresa.Produto.Modulo.Responsabilidade');
  WriteLn;
  WriteLn('Exemplos por camada:');
  WriteLn('  Domain/Entities:    GestorERP.Clientes.Cliente');
  WriteLn('  Value Objects:      GestorERP.Clientes.Endereco');
  WriteLn('  Interfaces:         GestorERP.Clientes.Interfaces');
  WriteLn('  Implementacao:      GestorERP.Clientes.Impl');
  WriteLn('  Repository SQLite:  GestorERP.Clientes.Repository.SQLite');
  WriteLn('  Repository Memory:  GestorERP.Clientes.Repository.Memory');
  WriteLn('  Factory:            GestorERP.Clientes.Factory');
  WriteLn('  Use Case:           GestorERP.Clientes.UseCases.CriarCliente');
  WriteLn('  Utils/Helpers:      GestorERP.Common.StringHelpers');
  WriteLn('  Types compartilhados: GestorERP.Common.Types');
  WriteLn;
  WriteLn('Arquivos de formulario (VCL/FMX):');
  WriteLn('  ufrm.Main.pas       (sem namespace — convencao herdada)');
  WriteLn('  ufrm.Cliente.pas');
  WriteLn;
  WriteLn('Unit Scope Names (Project → Options → Delphi Compiler):');
  WriteLn('  GestorERP.Common → permite usar "Types" ao inves de "GestorERP.Common.Types"');
  WriteLn('  GestorERP.Clientes → permite usar "Interfaces" ao inves do nome completo');
end;

// =============================================================================
// Programa principal
// =============================================================================

const
  StatusStr: array[TStatusItem] of string = ('Ativo', 'Inativo', 'Excluido');

var
  Repo: IClienteRepository;
  IDs: array of TEntityID;
  I: Integer;
  ID: TEntityID;
begin
  WriteLn('=== Exemplo: Namespaces Delphi — Company.Product.Module.Unit ===');
  WriteLn;

  ExibirConvencaoNomenclatura;

  WriteLn;
  WriteLn('--- Demonstracao: GestorERP.Clientes.Repository.Memory ---');
  WriteLn;

  // Factory retorna a interface — sem depender do tipo concreto
  Repo := TClienteRepositoryFactory.New('memory');

  SetLength(IDs, 4);
  IDs[0] := 1; IDs[1] := 2; IDs[2] := 3; IDs[3] := 99;

  for I := 0 to High(IDs) do
  begin
    ID := IDs[I];
    if Repo.BuscarPorID(ID) then
      WriteLn(Format('  ID=%d | Nome=%-20s | Status=%s',
        [ID, Repo.NomeCliente, StatusStr[Repo.StatusCliente]]))
    else
      WriteLn(Format('  ID=%d | NAO ENCONTRADO', [ID]));
  end;

  WriteLn;
  WriteLn('OK -- developer-delphi-to-fpc-architecture-modules :: unit_namespaces');
end.

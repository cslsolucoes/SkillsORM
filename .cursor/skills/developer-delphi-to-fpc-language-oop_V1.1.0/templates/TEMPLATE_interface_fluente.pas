unit TEMPLATE_interface_fluente;
{
  TEMPLATE: Interface fluente para Builder/Query
  Uso: copie e renomeie. Substitua ENTIDADE.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Interface fluente para construcao de query de entidade
// ---------------------------------------------------------------------------
type
  TOrdem = (orAscendente, orDescendente);

  IQueryEntidade = interface
  ['{FFFFFFFF-EEEE-DDDD-CCCC-BBBBAAAABBBB}'] // substituir por GUID real
    // Filtros (retornam Self para encadeamento)
    function PorId(AId: Integer): IQueryEntidade;
    function PorNome(const ANome: string): IQueryEntidade;
    function AtivosApenas: IQueryEntidade;
    function ComStatus(AStatus: Integer): IQueryEntidade;

    // Ordenacao
    function OrdenadoPor(const ACampo: string;
      AOrdem: TOrdem = orAscendente): IQueryEntidade;

    // Paginacao
    function Pagina(APagina, ITensPorPagina: Integer): IQueryEntidade;

    // Execucao (terminais — nao retornam interface)
    function Executar: TArray<string>; // substituir pelo tipo real
    function Contar: Integer;
    function PrimeiroOuNil: string;    // substituir pelo tipo real
    function Existe: Boolean;

    // Inspecao
    function ToSQL: string;
  end;

// ---------------------------------------------------------------------------
// Implementacao
// ---------------------------------------------------------------------------
type
  TQueryEntidade = class(TInterfacedObject, IQueryEntidade)
  private
    FFiltros  : TStringList;
    FOrdemPor : string;
    FPagina   : Integer;
    FPorPagina: Integer;
    FLimite   : Integer;

    procedure AddFiltro(const AFiltro: string);

  public
    constructor Create;
    destructor Destroy; override;

    function PorId(AId: Integer): IQueryEntidade;
    function PorNome(const ANome: string): IQueryEntidade;
    function AtivosApenas: IQueryEntidade;
    function ComStatus(AStatus: Integer): IQueryEntidade;
    function OrdenadoPor(const ACampo: string; AOrdem: TOrdem): IQueryEntidade;
    function Pagina(APagina, AItensPorPagina: Integer): IQueryEntidade;
    function Executar: TArray<string>;
    function Contar: Integer;
    function PrimeiroOuNil: string;
    function Existe: Boolean;
    function ToSQL: string;
  end;

// Factory function (padrao preferido — sem expor classe)
function NovaQueryEntidade: IQueryEntidade;

implementation

function NovaQueryEntidade: IQueryEntidade;
begin
  Result := TQueryEntidade.Create;
end;

constructor TQueryEntidade.Create;
begin
  inherited Create;
  FFiltros   := TStringList.Create;
  FPorPagina := 50;
  FPagina    := 1;
  FLimite    := -1;
end;

destructor TQueryEntidade.Destroy;
begin
  FFiltros.Free;
  inherited;
end;

procedure TQueryEntidade.AddFiltro(const AFiltro: string);
begin
  FFiltros.Add(AFiltro);
end;

function TQueryEntidade.PorId(AId: Integer): IQueryEntidade;
begin
  AddFiltro(Format('id = %d', [AId]));
  Result := Self;
end;

function TQueryEntidade.PorNome(const ANome: string): IQueryEntidade;
begin
  AddFiltro(Format('nome LIKE ''%%%s%%''', [ANome.Replace('''', '''''')]));
  Result := Self;
end;

function TQueryEntidade.AtivosApenas: IQueryEntidade;
begin
  AddFiltro('ativo = 1');
  Result := Self;
end;

function TQueryEntidade.ComStatus(AStatus: Integer): IQueryEntidade;
begin
  AddFiltro(Format('status = %d', [AStatus]));
  Result := Self;
end;

function TQueryEntidade.OrdenadoPor(const ACampo: string;
  AOrdem: TOrdem): IQueryEntidade;
begin
  FOrdemPor := ACampo;
  if AOrdem = orDescendente then FOrdemPor := FOrdemPor + ' DESC';
  Result := Self;
end;

function TQueryEntidade.Pagina(APagina, AItensPorPagina: Integer): IQueryEntidade;
begin
  FPagina    := APagina;
  FPorPagina := AItensPorPagina;
  Result := Self;
end;

function TQueryEntidade.ToSQL: string;
var
  SQL: string;
begin
  SQL := 'SELECT * FROM entidade';
  if FFiltros.Count > 0 then
    SQL := SQL + ' WHERE ' + String.Join(' AND ', FFiltros.ToStringArray);
  if not FOrdemPor.IsEmpty then
    SQL := SQL + ' ORDER BY ' + FOrdemPor;
  if FPorPagina > 0 then
    SQL := SQL + Format(' LIMIT %d OFFSET %d',
      [FPorPagina, (FPagina - 1) * FPorPagina]);
  Result := SQL;
end;

function TQueryEntidade.Executar: TArray<string>;
begin
  // FDataset.Open(ToSQL);
  // Mapear para array de entidades
  SetLength(Result, 0); // placeholder
end;

function TQueryEntidade.Contar: Integer;
begin
  Result := 0; // FDataset.RecordCount
end;

function TQueryEntidade.PrimeiroOuNil: string;
begin
  Result := ''; // FDataset.IsEmpty ? '' : MapearPrimeiro
end;

function TQueryEntidade.Existe: Boolean;
begin
  Result := Contar > 0;
end;

// ---------------------------------------------------------------------------
// USO:
//   var Clientes := NovaQueryEntidade
//     .PorNome('Maria')
//     .AtivosApenas
//     .ComStatus(1)
//     .OrdenadoPor('nome')
//     .Pagina(2, 20)
//     .Executar;
//
//   Writeln(NovaQueryEntidade.PorNome('x').ToSQL);
//   // SELECT * FROM entidade WHERE nome LIKE '%x%' AND ativo = 1
// ---------------------------------------------------------------------------

end.

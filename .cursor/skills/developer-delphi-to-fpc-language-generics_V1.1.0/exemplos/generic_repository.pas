unit generic_repository;
{
  Generics — Repository pattern genérico com IRepository<T, TId>
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Interface genérica de repositório
// ---------------------------------------------------------------------------
type
  IRepository<T: class; TId> = interface
  ['{40000004-0000-0000-0000-000000000004}']
    function  ObterPorId(const AId: TId): T;
    function  ObterTodos: TObjectList<T>;
    function  ObterOnde(APredicado: TFunc<T, Boolean>): TObjectList<T>;
    procedure Salvar(AEntidade: T);
    procedure Excluir(const AId: TId);
    function  Existe(const AId: TId): Boolean;
    function  Contar: Integer;
  end;

// ---------------------------------------------------------------------------
// Entidades de domínio
// ---------------------------------------------------------------------------
type
  TEntidadeBase = class
  private
    FId: Integer;
  public
    property Id: Integer read FId write FId;
  end;

  TProduto = class(TEntidadeBase)
  private
    FNome  : string;
    FPreco : Double;
    FEstoque: Integer;
  public
    constructor Create(AId: Integer; const ANome: string; APreco: Double; AEstoque: Integer);
    property Nome   : string  read FNome    write FNome;
    property Preco  : Double  read FPreco   write FPreco;
    property Estoque: Integer read FEstoque write FEstoque;
    function ToString: string; override;
  end;

// ---------------------------------------------------------------------------
// Repositório em memória genérico (implementação base reutilizável)
// ---------------------------------------------------------------------------
type
  TMemoryRepository<T: TEntidadeBase; TId> = class(
    TInterfacedObject, IRepository<T, TId>)
  private
    FDados: TObjectDictionary<TId, T>;
    FGetId: TFunc<T, TId>;
  public
    constructor Create(AGetId: TFunc<T, TId>);
    destructor Destroy; override;

    function  ObterPorId(const AId: TId): T;
    function  ObterTodos: TObjectList<T>;
    function  ObterOnde(APredicado: TFunc<T, Boolean>): TObjectList<T>;
    procedure Salvar(AEntidade: T);
    procedure Excluir(const AId: TId);
    function  Existe(const AId: TId): Boolean;
    function  Contar: Integer;
  end;

// ---------------------------------------------------------------------------
// Repositório concreto de Produto
// ---------------------------------------------------------------------------
type
  IProdutoRepository = interface(IRepository<TProduto, Integer>)
  ['{50000005-0000-0000-0000-000000000005}']
    function ObterPorFaixaPreco(AMin, AMax: Double): TObjectList<TProduto>;
    function ObterComEstoque: TObjectList<TProduto>;
  end;

  TProdutoRepository = class(TMemoryRepository<TProduto, Integer>,
    IProdutoRepository)
  public
    function ObterPorFaixaPreco(AMin, AMax: Double): TObjectList<TProduto>;
    function ObterComEstoque: TObjectList<TProduto>;
  end;

// Factory
function NovoProdutoRepository: IProdutoRepository;

implementation

// ---------------------------------------------------------------------------
// TProduto
// ---------------------------------------------------------------------------

constructor TProduto.Create(AId: Integer; const ANome: string;
  APreco: Double; AEstoque: Integer);
begin
  inherited Create;
  Id      := AId;
  FNome   := ANome;
  FPreco  := APreco;
  FEstoque:= AEstoque;
end;

function TProduto.ToString: string;
begin
  Result := Format('TProduto{Id=%d, Nome=%s, Preco=%.2f, Estoque=%d}',
    [Id, FNome, FPreco, FEstoque]);
end;

// ---------------------------------------------------------------------------
// TMemoryRepository<T, TId>
// ---------------------------------------------------------------------------

constructor TMemoryRepository<T, TId>.Create(AGetId: TFunc<T, TId>);
begin
  inherited Create;
  FGetId := AGetId;
  FDados := TObjectDictionary<TId, T>.Create([doOwnsValues]);
end;

destructor TMemoryRepository<T, TId>.Destroy;
begin
  FDados.Free;
  inherited;
end;

function TMemoryRepository<T, TId>.ObterPorId(const AId: TId): T;
begin
  if not FDados.TryGetValue(AId, Result) then
    Result := nil;
end;

function TMemoryRepository<T, TId>.ObterTodos: TObjectList<T>;
var P: TPair<TId, T>;
begin
  Result := TObjectList<T>.Create(False); // não owns — objetos no dict
  for P in FDados do
    Result.Add(P.Value);
end;

function TMemoryRepository<T, TId>.ObterOnde(
  APredicado: TFunc<T, Boolean>): TObjectList<T>;
var P: TPair<TId, T>;
begin
  Result := TObjectList<T>.Create(False);
  for P in FDados do
    if APredicado(P.Value) then
      Result.Add(P.Value);
end;

procedure TMemoryRepository<T, TId>.Salvar(AEntidade: T);
var Id: TId;
begin
  Id := FGetId(AEntidade);
  if FDados.ContainsKey(Id) then
    FDados[Id] := AEntidade  // substitui (dict owns, mas não libera old aqui — simplificado)
  else
    FDados.Add(Id, AEntidade);
end;

procedure TMemoryRepository<T, TId>.Excluir(const AId: TId);
begin
  FDados.Remove(AId); // TObjectDictionary com doOwnsValues → libera automaticamente
end;

function TMemoryRepository<T, TId>.Existe(const AId: TId): Boolean;
begin
  Result := FDados.ContainsKey(AId);
end;

function TMemoryRepository<T, TId>.Contar: Integer;
begin
  Result := FDados.Count;
end;

// ---------------------------------------------------------------------------
// TProdutoRepository
// ---------------------------------------------------------------------------

function TProdutoRepository.ObterPorFaixaPreco(AMin, AMax: Double): TObjectList<TProduto>;
begin
  Result := ObterOnde(
    function(P: TProduto): Boolean
    begin
      Result := (P.Preco >= AMin) and (P.Preco <= AMax);
    end);
end;

function TProdutoRepository.ObterComEstoque: TObjectList<TProduto>;
begin
  Result := ObterOnde(
    function(P: TProduto): Boolean
    begin
      Result := P.Estoque > 0;
    end);
end;

function NovoProdutoRepository: IProdutoRepository;
begin
  Result := TProdutoRepository.Create(
    function(P: TProduto): Integer begin Result := P.Id; end);
end;

// ---------------------------------------------------------------------------
// USO:
//   var Repo := NovoProdutoRepository;
//
//   // Adicionar
//   Repo.Salvar(TProduto.Create(1, 'Maçã',   2.50, 100));
//   Repo.Salvar(TProduto.Create(2, 'Banana', 1.20, 0));
//   Repo.Salvar(TProduto.Create(3, 'Uva',    5.90, 50));
//
//   Writeln('Total: ', Repo.Contar);  // 3
//
//   var P := Repo.ObterPorId(2);
//   if P <> nil then Writeln(P.ToString);
//
//   var EmEstoque := Repo.ObterComEstoque;
//   Writeln('Em estoque: ', EmEstoque.Count);  // 2
//   EmEstoque.Free;
//
//   var Baratos := Repo.ObterPorFaixaPreco(1.0, 3.0);
//   for var Prod in Baratos do Writeln(Prod.Nome);
//   Baratos.Free;
//
//   Repo.Excluir(2);
//   Writeln('Após excluir: ', Repo.Contar);  // 2
// ---------------------------------------------------------------------------

end.

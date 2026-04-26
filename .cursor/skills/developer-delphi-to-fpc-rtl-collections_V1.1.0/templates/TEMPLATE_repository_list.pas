unit TEMPLATE_repository_list;
{
  TEMPLATE: Repositório em memória com TDictionary (CRUD + query)
  Substitua TEntidade, TId e os campos conforme seu domínio.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections, System.Generics.Defaults;

// ---------------------------------------------------------------------------
// Substitua pelo seu tipo de entidade
// ---------------------------------------------------------------------------
type
  TId = Integer;

  TEntidade = class
  public
    Id:     TId;
    Nome:   string;
    Ativo:  Boolean;
    Valor:  Currency;
    constructor Create(AId: TId; const ANome: string;
      AAtivo: Boolean = True; AValor: Currency = 0);
    function Clone: TEntidade; virtual;
    function ToString: string; override;
  end;

// ---------------------------------------------------------------------------
// Interface do repositório
// ---------------------------------------------------------------------------
  IRepositorio<TKey; TEntity: class> = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    procedure Adicionar(const AEntidade: TEntity);
    procedure Atualizar(const AEntidade: TEntity);
    procedure Remover(const AId: TKey);
    function  BuscarPorId(const AId: TKey): TEntity;
    function  TentarBuscarPorId(const AId: TKey; out AEntidade: TEntity): Boolean;
    function  Listar: TArray<TEntity>;
    function  Filtrar(APredicate: TFunc<TEntity, Boolean>): TArray<TEntity>;
    function  Contagem: Integer;
    function  Existe(const AId: TKey): Boolean;
    procedure Limpar;
  end;

// ---------------------------------------------------------------------------
// Implementação base com TDictionary
// ---------------------------------------------------------------------------
  TRepositorioBase<TKey; TEntity: class> = class(
    TInterfacedObject,
    IRepositorio<TKey, TEntity>)
  private
    FStorage: TObjectDictionary<TKey, TEntity>;
    FNextId:  TKey;
  protected
    function ProximoId: TKey; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Adicionar(const AEntidade: TEntity);
    procedure Atualizar(const AEntidade: TEntity);
    procedure Remover(const AId: TKey);
    function  BuscarPorId(const AId: TKey): TEntity;
    function  TentarBuscarPorId(const AId: TKey; out AEntidade: TEntity): Boolean;
    function  Listar: TArray<TEntity>;
    function  Filtrar(APredicate: TFunc<TEntity, Boolean>): TArray<TEntity>;
    function  Contagem: Integer;
    function  Existe(const AId: TKey): Boolean;
    procedure Limpar;
  end;

// ---------------------------------------------------------------------------
// Repositório concreto de TEntidade
// ---------------------------------------------------------------------------
  TEntidadeRepositorio = class(TRepositorioBase<TId, TEntidade>)
  public
    // Queries específicas de domínio
    function BuscarPorNome(const ANome: string): TArray<TEntidade>;
    function ListarAtivos: TArray<TEntidade>;
    function SomarValores: Currency;
  end;

function NewEntidadeRepositorio: IRepositorio<TId, TEntidade>;

implementation

// ---------------------------------------------------------------------------
// TEntidade
// ---------------------------------------------------------------------------

constructor TEntidade.Create(AId: TId; const ANome: string;
  AAtivo: Boolean; AValor: Currency);
begin
  inherited Create;
  Id := AId; Nome := ANome; Ativo := AAtivo; Valor := AValor;
end;

function TEntidade.Clone: TEntidade;
begin
  Result := TEntidade.Create(Id, Nome, Ativo, Valor);
end;

function TEntidade.ToString: string;
begin
  Result := Format('[%d] %s  ativo=%s  R$%.2f',
    [Id, Nome, BoolToStr(Ativo, True), Valor]);
end;

// ---------------------------------------------------------------------------
// TRepositorioBase<TKey, TEntity>
// ---------------------------------------------------------------------------

constructor TRepositorioBase<TKey, TEntity>.Create;
begin
  inherited;
  // doOwnsValues: Free automático dos objetos ao Remove/Limpar
  FStorage := TObjectDictionary<TKey, TEntity>.Create([doOwnsValues]);
end;

destructor TRepositorioBase<TKey, TEntity>.Destroy;
begin
  FStorage.Free;
  inherited;
end;

function TRepositorioBase<TKey, TEntity>.ProximoId: TKey;
begin
  // Sobrescreva para IDs não-inteiros
  raise ENotImplemented.Create('ProximoId deve ser implementado');
end;

procedure TRepositorioBase<TKey, TEntity>.Adicionar(const AEntidade: TEntity);
begin
  if FStorage.ContainsKey(AEntidade.Id) then
    raise EArgumentException.CreateFmt(
      'Entidade com Id=%s já existe', [TValue.From(AEntidade.Id).ToString]);
  FStorage.Add(AEntidade.Id, AEntidade);
end;

procedure TRepositorioBase<TKey, TEntity>.Atualizar(const AEntidade: TEntity);
begin
  if not FStorage.ContainsKey(AEntidade.Id) then
    raise EKeyNotFoundException.CreateFmt(
      'Entidade com Id=%s não encontrada', [TValue.From(AEntidade.Id).ToString]);
  // Remove o antigo (Free automático) e insere o novo
  FStorage.Remove(AEntidade.Id);
  FStorage.Add(AEntidade.Id, AEntidade);
end;

procedure TRepositorioBase<TKey, TEntity>.Remover(const AId: TKey);
begin
  if not FStorage.ContainsKey(AId) then
    raise EKeyNotFoundException.Create('Id não encontrado para remoção');
  FStorage.Remove(AId);  // Free automático (doOwnsValues)
end;

function TRepositorioBase<TKey, TEntity>.BuscarPorId(const AId: TKey): TEntity;
begin
  if not FStorage.TryGetValue(AId, Result) then
    raise EKeyNotFoundException.CreateFmt('Id não encontrado', []);
end;

function TRepositorioBase<TKey, TEntity>.TentarBuscarPorId(
  const AId: TKey; out AEntidade: TEntity): Boolean;
begin
  Result := FStorage.TryGetValue(AId, AEntidade);
end;

function TRepositorioBase<TKey, TEntity>.Listar: TArray<TEntity>;
var I: Integer;
    Pair: TPair<TKey, TEntity>;
begin
  SetLength(Result, FStorage.Count);
  I := 0;
  for Pair in FStorage do
  begin
    Result[I] := Pair.Value;
    Inc(I);
  end;
end;

function TRepositorioBase<TKey, TEntity>.Filtrar(
  APredicate: TFunc<TEntity, Boolean>): TArray<TEntity>;
var Lista: TList<TEntity>;
    Pair:  TPair<TKey, TEntity>;
begin
  Lista := TList<TEntity>.Create;
  try
    for Pair in FStorage do
      if APredicate(Pair.Value) then Lista.Add(Pair.Value);
    Result := Lista.ToArray;
  finally Lista.Free; end;
end;

function TRepositorioBase<TKey, TEntity>.Contagem: Integer;
begin Result := FStorage.Count; end;

function TRepositorioBase<TKey, TEntity>.Existe(const AId: TKey): Boolean;
begin Result := FStorage.ContainsKey(AId); end;

procedure TRepositorioBase<TKey, TEntity>.Limpar;
begin FStorage.Clear; end;  // Clear com doOwnsValues → Free todos

// ---------------------------------------------------------------------------
// TEntidadeRepositorio — queries específicas
// ---------------------------------------------------------------------------

function TEntidadeRepositorio.BuscarPorNome(const ANome: string): TArray<TEntidade>;
begin
  Result := Filtrar(
    function(E: TEntidade): Boolean
    begin Result := CompareText(E.Nome, ANome) = 0; end);
end;

function TEntidadeRepositorio.ListarAtivos: TArray<TEntidade>;
begin
  Result := Filtrar(
    function(E: TEntidade): Boolean begin Result := E.Ativo; end);
end;

function TEntidadeRepositorio.SomarValores: Currency;
var E: TEntidade;
begin
  Result := 0;
  for E in Listar do Result := Result + E.Valor;
end;

function NewEntidadeRepositorio: IRepositorio<TId, TEntidade>;
begin
  Result := TEntidadeRepositorio.Create;
end;

// ---------------------------------------------------------------------------
// Exemplo de uso (comentado — descomente para testar)
// ---------------------------------------------------------------------------
(*
procedure DemoRepositorio;
var Repo: IRepositorio<TId, TEntidade>;
    E:    TEntidade;
    Lista: TArray<TEntidade>;
begin
  Repo := NewEntidadeRepositorio;

  Repo.Adicionar(TEntidade.Create(1, 'Alice',  True,  1500));
  Repo.Adicionar(TEntidade.Create(2, 'Bob',    False,  800));
  Repo.Adicionar(TEntidade.Create(3, 'Carol',  True,  2200));

  Writeln('Count: ', Repo.Contagem);

  E := Repo.BuscarPorId(2);
  Writeln('BuscarPorId(2): ', E.ToString);

  Lista := Repo.Filtrar(
    function(X: TEntidade): Boolean begin Result := X.Ativo; end);
  Writeln('Ativos: ', Length(Lista));

  Repo.Remover(2);
  Writeln('Após Remover(2): ', Repo.Contagem);
end;
*)

end.

unit TEMPLATE_cache_lru;
{
  TEMPLATE: Cache LRU (Least Recently Used) com TDictionary + lista de acesso
  Tamanho máximo configurável; evicção automática do item menos recente.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Nó duplamente ligado para manter ordem LRU
// ---------------------------------------------------------------------------
type
  TLRUNode<K, V> = class
  public
    Key:   K;
    Value: V;
    Prev:  TLRUNode<K, V>;
    Next:  TLRUNode<K, V>;
    constructor Create(const AKey: K; const AValue: V);
  end;

// ---------------------------------------------------------------------------
// Cache LRU genérico
// ---------------------------------------------------------------------------
  TLRUCache<K, V> = class
  private
    FCapacity: Integer;
    FMap:      TDictionary<K, TLRUNode<K, V>>;
    FHead:     TLRUNode<K, V>;  // mais recente (sentinel)
    FTail:     TLRUNode<K, V>;  // menos recente (sentinel)
    FHits:     Integer;
    FMisses:   Integer;

    procedure MoveToFront(ANode: TLRUNode<K, V>);
    procedure RemoveNode(ANode: TLRUNode<K, V>);
    procedure AddToFront(ANode: TLRUNode<K, V>);
    procedure EvictLRU;
  public
    constructor Create(ACapacity: Integer);
    destructor Destroy; override;

    // Leitura — retorna True e seta AValue se cache HIT
    function TryGet(const AKey: K; out AValue: V): Boolean;

    // Escrita — insere ou atualiza; evicta se necessário
    procedure Put(const AKey: K; const AValue: V);

    // Remover explícito
    procedure Remove(const AKey: K);

    // Verificar presença sem afetar ordem LRU
    function ContainsKey(const AKey: K): Boolean;

    // Limpar tudo
    procedure Clear;

    property Count:    Integer read FMap.Count;
    property Capacity: Integer read FCapacity;
    property Hits:     Integer read FHits;
    property Misses:   Integer read FMisses;

    // Razão de acerto (0.0–1.0)
    function HitRate: Double;

    // Snapshot da ordem LRU (mais recente primeiro)
    function LRUOrder: TArray<K>;
  end;

// ---------------------------------------------------------------------------
// Especialização para chave string, valor string
// ---------------------------------------------------------------------------
  TStringLRUCache = TLRUCache<string, string>;

implementation

// ---------------------------------------------------------------------------
// TLRUNode<K,V>
// ---------------------------------------------------------------------------

constructor TLRUNode<K, V>.Create(const AKey: K; const AValue: V);
begin inherited Create; Key := AKey; Value := AValue; end;

// ---------------------------------------------------------------------------
// TLRUCache<K,V>
// ---------------------------------------------------------------------------

constructor TLRUCache<K, V>.Create(ACapacity: Integer);
begin
  inherited Create;
  if ACapacity < 1 then
    raise EArgumentOutOfRangeException.Create('Capacity deve ser >= 1');
  FCapacity := ACapacity;
  FMap := TDictionary<K, TLRUNode<K, V>>.Create(ACapacity);

  // Sentinelas — simplificam as operações de lista (sem checar nil)
  FHead := TLRUNode<K, V>.Create(Default(K), Default(V));  // mais recente
  FTail := TLRUNode<K, V>.Create(Default(K), Default(V));  // menos recente
  FHead.Next := FTail;
  FTail.Prev := FHead;
end;

destructor TLRUCache<K, V>.Destroy;
begin
  Clear;
  FHead.Free;
  FTail.Free;
  FMap.Free;
  inherited;
end;

procedure TLRUCache<K, V>.RemoveNode(ANode: TLRUNode<K, V>);
begin
  ANode.Prev.Next := ANode.Next;
  ANode.Next.Prev := ANode.Prev;
  ANode.Prev := nil;
  ANode.Next := nil;
end;

procedure TLRUCache<K, V>.AddToFront(ANode: TLRUNode<K, V>);
begin
  ANode.Next := FHead.Next;
  ANode.Prev := FHead;
  FHead.Next.Prev := ANode;
  FHead.Next := ANode;
end;

procedure TLRUCache<K, V>.MoveToFront(ANode: TLRUNode<K, V>);
begin
  RemoveNode(ANode);
  AddToFront(ANode);
end;

procedure TLRUCache<K, V>.EvictLRU;
var LRUNode: TLRUNode<K, V>;
begin
  // O nó menos recente fica logo antes de FTail
  LRUNode := FTail.Prev;
  if LRUNode = FHead then Exit;  // cache vazio
  FMap.Remove(LRUNode.Key);
  RemoveNode(LRUNode);
  LRUNode.Free;
end;

function TLRUCache<K, V>.TryGet(const AKey: K; out AValue: V): Boolean;
var Node: TLRUNode<K, V>;
begin
  if FMap.TryGetValue(AKey, Node) then
  begin
    MoveToFront(Node);  // marcar como mais recente
    AValue := Node.Value;
    Inc(FHits);
    Result := True;
  end
  else
  begin
    Inc(FMisses);
    Result := False;
  end;
end;

procedure TLRUCache<K, V>.Put(const AKey: K; const AValue: V);
var Node: TLRUNode<K, V>;
begin
  if FMap.TryGetValue(AKey, Node) then
  begin
    // Atualizar valor + mover para frente
    Node.Value := AValue;
    MoveToFront(Node);
  end
  else
  begin
    // Novo item — evictar se cheio
    if FMap.Count >= FCapacity then EvictLRU;
    Node := TLRUNode<K, V>.Create(AKey, AValue);
    AddToFront(Node);
    FMap.Add(AKey, Node);
  end;
end;

procedure TLRUCache<K, V>.Remove(const AKey: K);
var Node: TLRUNode<K, V>;
begin
  if FMap.TryGetValue(AKey, Node) then
  begin
    FMap.Remove(AKey);
    RemoveNode(Node);
    Node.Free;
  end;
end;

function TLRUCache<K, V>.ContainsKey(const AKey: K): Boolean;
begin Result := FMap.ContainsKey(AKey); end;

procedure TLRUCache<K, V>.Clear;
var Node, Next: TLRUNode<K, V>;
begin
  FMap.Clear;
  Node := FHead.Next;
  while Node <> FTail do
  begin
    Next := Node.Next;
    Node.Free;
    Node := Next;
  end;
  FHead.Next := FTail;
  FTail.Prev := FHead;
  FHits   := 0;
  FMisses := 0;
end;

function TLRUCache<K, V>.HitRate: Double;
var Total: Integer;
begin
  Total := FHits + FMisses;
  if Total = 0 then Result := 0
  else Result := FHits / Total;
end;

function TLRUCache<K, V>.LRUOrder: TArray<K>;
var Lista: TList<K>;
    Node:  TLRUNode<K, V>;
begin
  Lista := TList<K>.Create;
  try
    Node := FHead.Next;
    while Node <> FTail do
    begin
      Lista.Add(Node.Key);
      Node := Node.Next;
    end;
    Result := Lista.ToArray;
  finally Lista.Free; end;
end;

// ---------------------------------------------------------------------------
// Exemplo de uso (comentado — descomente para testar)
// ---------------------------------------------------------------------------
(*
procedure DemoLRUCache;
var Cache: TLRUCache<Integer, string>;
    V: string;
    K: Integer;
begin
  Cache := TLRUCache<Integer, string>.Create(3);  // capacidade 3
  try
    Cache.Put(1, 'um');
    Cache.Put(2, 'dois');
    Cache.Put(3, 'três');
    // Ordem LRU: [3, 2, 1] (3 mais recente)

    Cache.TryGet(1, V);  // acessa 1 → passa para frente
    // Ordem: [1, 3, 2]

    Cache.Put(4, 'quatro');  // evicta 2 (LRU)
    // Ordem: [4, 1, 3]

    Writeln('Contém 2? ', Cache.ContainsKey(2));  // False
    Writeln('Contém 3? ', Cache.ContainsKey(3));  // True

    Writeln('HitRate: ', Cache.HitRate:0:2);
    Write('Ordem LRU: ');
    for K in Cache.LRUOrder do Write(K, ' ');
    Writeln;
  finally
    Cache.Free;
  end;
end;
*)

end.

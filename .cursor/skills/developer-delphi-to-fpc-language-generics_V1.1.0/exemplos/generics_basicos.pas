unit generics_basicos;
{
  Generics em Delphi — declaração e instanciação básica
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils;

// ---------------------------------------------------------------------------
// Classe genérica simples: TBox<T>
// ---------------------------------------------------------------------------
type
  TBox<T> = class
  private
    FValue: T;
  public
    constructor Create(const AValue: T);
    function GetValue: T;
    procedure SetValue(const AValue: T);
    function ToString: string; override;
    property Value: T read GetValue write SetValue;
  end;

// ---------------------------------------------------------------------------
// Par genérico: TPair<TKey, TValue>
// ---------------------------------------------------------------------------
type
  TPairGen<TKey, TValue> = record
    Key  : TKey;
    Value: TValue;
    class function Create(const AKey: TKey; const AVal: TValue): TPairGen<TKey, TValue>; static;
  end;

// ---------------------------------------------------------------------------
// Stack genérico: TStack<T>
// ---------------------------------------------------------------------------
type
  TGenericStack<T> = class
  private
    FItems: TArray<T>;
    FCount: Integer;
    procedure Grow;
  public
    constructor Create;
    procedure Push(const AItem: T);
    function  Pop: T;
    function  Peek: T;
    function  IsEmpty: Boolean;
    property  Count: Integer read FCount;
  end;

implementation

// ---------------------------------------------------------------------------
// TBox<T>
// ---------------------------------------------------------------------------

constructor TBox<T>.Create(const AValue: T);
begin
  inherited Create;
  FValue := AValue;
end;

function TBox<T>.GetValue: T;
begin
  Result := FValue;
end;

procedure TBox<T>.SetValue(const AValue: T);
begin
  FValue := AValue;
end;

function TBox<T>.ToString: string;
begin
  Result := Format('Box<%s>', [GetTypeName(TypeInfo(T))]);
end;

// ---------------------------------------------------------------------------
// TPairGen<TKey, TValue>
// ---------------------------------------------------------------------------

class function TPairGen<TKey, TValue>.Create(const AKey: TKey;
  const AVal: TValue): TPairGen<TKey, TValue>;
begin
  Result.Key   := AKey;
  Result.Value := AVal;
end;

// ---------------------------------------------------------------------------
// TGenericStack<T>
// ---------------------------------------------------------------------------

constructor TGenericStack<T>.Create;
begin
  inherited Create;
  FCount := 0;
  SetLength(FItems, 4);
end;

procedure TGenericStack<T>.Grow;
begin
  SetLength(FItems, Length(FItems) * 2);
end;

procedure TGenericStack<T>.Push(const AItem: T);
begin
  if FCount = Length(FItems) then Grow;
  FItems[FCount] := AItem;
  Inc(FCount);
end;

function TGenericStack<T>.Pop: T;
begin
  if FCount = 0 then
    raise EInvalidOpException.Create('Stack vazio');
  Dec(FCount);
  Result := FItems[FCount];
end;

function TGenericStack<T>.Peek: T;
begin
  if FCount = 0 then
    raise EInvalidOpException.Create('Stack vazio');
  Result := FItems[FCount - 1];
end;

function TGenericStack<T>.IsEmpty: Boolean;
begin
  Result := FCount = 0;
end;

// ---------------------------------------------------------------------------
// USO:
//   var BoxInt := TBox<Integer>.Create(42);
//   Writeln(BoxInt.Value);   // 42
//   BoxInt.Free;
//
//   var BoxStr := TBox<string>.Create('Delphi');
//   Writeln(BoxStr.Value);   // Delphi
//   BoxStr.Free;
//
//   var Pilha := TGenericStack<string>.Create;
//   Pilha.Push('A'); Pilha.Push('B');
//   Writeln(Pilha.Pop);  // B
//   Pilha.Free;
//
//   var Par := TPairGen<string, Integer>.Create('idade', 30);
//   Writeln(Par.Key, '=', Par.Value);  // idade=30
// ---------------------------------------------------------------------------

end.

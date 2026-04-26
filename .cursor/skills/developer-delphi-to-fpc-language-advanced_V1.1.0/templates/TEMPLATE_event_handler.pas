unit TEMPLATE_event_handler;
{
  TEMPLATE: Event handler com TProc<T> e multicast
  Uso: copie, renomeie e substitua EVENTO pelo tipo de argumento.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// TEventArgs — base para argumentos de evento
// ---------------------------------------------------------------------------
type
  TEventArgs = class
  private
    FHandled: Boolean;
  public
    property Handled: Boolean read FHandled write FHandled;
  end;

  // Exemplo: args de evento de mudança de valor
  TValueChangedArgs<T> = class(TEventArgs)
  private
    FOldValue: T;
    FNewValue: T;
  public
    constructor Create(const AOld, ANew: T);
    property OldValue: T read FOldValue;
    property NewValue: T read FNewValue;
  end;

// ---------------------------------------------------------------------------
// TMulticastEvent<TArgs> — evento com múltiplos handlers
// ---------------------------------------------------------------------------
type
  TEventHandler<TArgs: TEventArgs> = reference to procedure(
    ASender: TObject; AArgs: TArgs);

  TMulticastEvent<TArgs: TEventArgs> = class
  private
    FHandlers: TList<TEventHandler<TArgs>>;
    FSender  : TObject;
  public
    constructor Create(ASender: TObject);
    destructor Destroy; override;

    // Assinar/cancelar
    procedure Adicionar(AHandler: TEventHandler<TArgs>);
    procedure Remover(AHandler: TEventHandler<TArgs>);

    // Disparar
    procedure Disparar(AArgs: TArgs);
    procedure DisparadoCom(AArgs: TArgs);  // alias mais fluente

    property Count: Integer read (FHandlers.Count);
  end;

// ---------------------------------------------------------------------------
// Observable<T> — objeto que publica evento quando propriedade muda
// ---------------------------------------------------------------------------
type
  TObservableValue<T> = class
  private
    FValue       : T;
    FOnChanged   : TMulticastEvent<TValueChangedArgs<T>>;

    function  GetValue: T;
    procedure SetValue(const ANew: T);
  public
    constructor Create(const AInicial: T);
    destructor Destroy; override;

    // Assinar mudanças
    procedure QuandoMudar(AHandler: TEventHandler<TValueChangedArgs<T>>);

    property Value  : T read GetValue write SetValue;
    property OnChanged: TMulticastEvent<TValueChangedArgs<T>> read FOnChanged;
  end;

// ---------------------------------------------------------------------------
// TEventBus — barramento central de eventos (pub/sub por tipo)
// ---------------------------------------------------------------------------
type
  TSimpleHandler = reference to procedure(AData: TObject);

  TEventBus = class
  private
    FHandlers: TDictionary<string, TList<TSimpleHandler>>;
    class var FInstance: TEventBus;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assinar(const ATopic: string; AHandler: TSimpleHandler);
    procedure Publicar(const ATopic: string; AData: TObject = nil);
    procedure Limpar(const ATopic: string);

    class function Instance: TEventBus;
    class procedure ReleaseInstance;
  end;

implementation

// ---------------------------------------------------------------------------
// TValueChangedArgs<T>
// ---------------------------------------------------------------------------

constructor TValueChangedArgs<T>.Create(const AOld, ANew: T);
begin
  inherited Create;
  FOldValue := AOld;
  FNewValue := ANew;
end;

// ---------------------------------------------------------------------------
// TMulticastEvent<TArgs>
// ---------------------------------------------------------------------------

constructor TMulticastEvent<TArgs>.Create(ASender: TObject);
begin
  inherited Create;
  FSender   := ASender;
  FHandlers := TList<TEventHandler<TArgs>>.Create;
end;

destructor TMulticastEvent<TArgs>.Destroy;
begin
  FHandlers.Free;
  inherited;
end;

procedure TMulticastEvent<TArgs>.Adicionar(AHandler: TEventHandler<TArgs>);
begin
  FHandlers.Add(AHandler);
end;

procedure TMulticastEvent<TArgs>.Remover(AHandler: TEventHandler<TArgs>);
begin
  FHandlers.Remove(AHandler);
end;

procedure TMulticastEvent<TArgs>.Disparar(AArgs: TArgs);
var H: TEventHandler<TArgs>;
begin
  for H in FHandlers do
  begin
    if AArgs.Handled then Break;  // handler marcou como tratado — parar propagação
    H(FSender, AArgs);
  end;
end;

procedure TMulticastEvent<TArgs>.DisparadoCom(AArgs: TArgs);
begin Disparar(AArgs); end;

// ---------------------------------------------------------------------------
// TObservableValue<T>
// ---------------------------------------------------------------------------

constructor TObservableValue<T>.Create(const AInicial: T);
begin
  inherited Create;
  FValue     := AInicial;
  FOnChanged := TMulticastEvent<TValueChangedArgs<T>>.Create(Self);
end;

destructor TObservableValue<T>.Destroy;
begin
  FOnChanged.Free;
  inherited;
end;

function TObservableValue<T>.GetValue: T;
begin Result := FValue; end;

procedure TObservableValue<T>.SetValue(const ANew: T);
var Args: TValueChangedArgs<T>;
begin
  // Não disparar se valor não mudou (comparação por TComparer)
  if TComparer<T>.Default.Compare(FValue, ANew) = 0 then Exit;

  Args := TValueChangedArgs<T>.Create(FValue, ANew);
  try
    FValue := ANew;
    FOnChanged.Disparar(Args);
  finally
    Args.Free;
  end;
end;

procedure TObservableValue<T>.QuandoMudar(AHandler: TEventHandler<TValueChangedArgs<T>>);
begin
  FOnChanged.Adicionar(AHandler);
end;

// ---------------------------------------------------------------------------
// TEventBus
// ---------------------------------------------------------------------------

constructor TEventBus.Create;
begin
  inherited Create;
  FHandlers := TDictionary<string, TList<TSimpleHandler>>.Create;
end;

destructor TEventBus.Destroy;
var Par: TPair<string, TList<TSimpleHandler>>;
begin
  for Par in FHandlers do Par.Value.Free;
  FHandlers.Free;
  inherited;
end;

procedure TEventBus.Assinar(const ATopic: string; AHandler: TSimpleHandler);
var Lista: TList<TSimpleHandler>;
begin
  if not FHandlers.TryGetValue(ATopic, Lista) then
  begin
    Lista := TList<TSimpleHandler>.Create;
    FHandlers.Add(ATopic, Lista);
  end;
  Lista.Add(AHandler);
end;

procedure TEventBus.Publicar(const ATopic: string; AData: TObject);
var
  Lista: TList<TSimpleHandler>;
  H    : TSimpleHandler;
begin
  if FHandlers.TryGetValue(ATopic, Lista) then
    for H in Lista do H(AData);
end;

procedure TEventBus.Limpar(const ATopic: string);
var Lista: TList<TSimpleHandler>;
begin
  if FHandlers.TryGetValue(ATopic, Lista) then Lista.Clear;
end;

class function TEventBus.Instance: TEventBus;
begin
  if FInstance = nil then FInstance := TEventBus.Create;
  Result := FInstance;
end;

class procedure TEventBus.ReleaseInstance;
begin FreeAndNil(FInstance); end;

// ---------------------------------------------------------------------------
// USO:
//   // Observable value
//   var NomeUsuario := TObservableValue<string>.Create('');
//   NomeUsuario.QuandoMudar(
//     procedure(Sender: TObject; Args: TValueChangedArgs<string>)
//     begin
//       Writeln(Format('Nome mudou: "%s" → "%s"', [Args.OldValue, Args.NewValue]));
//     end);
//   NomeUsuario.Value := 'Maria';   // dispara evento
//   NomeUsuario.Value := 'Maria';   // NÃO dispara (valor igual)
//   NomeUsuario.Value := 'João';    // dispara evento
//   NomeUsuario.Free;
//
//   // Event bus global
//   TEventBus.Instance.Assinar('cliente.criado',
//     procedure(AData: TObject) begin Writeln('Novo cliente!'); end);
//   TEventBus.Instance.Publicar('cliente.criado');
//   TEventBus.ReleaseInstance;
// ---------------------------------------------------------------------------

initialization
  // Nenhum estado global inicializado aqui

finalization
  TEventBus.ReleaseInstance;

end.

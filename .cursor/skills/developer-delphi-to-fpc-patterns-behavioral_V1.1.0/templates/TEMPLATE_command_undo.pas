unit TEMPLATE_command_undo;
{
  TEMPLATE: Command + Undo/Redo stack completo
  ─────────────────────────────────────────────
  Substituir:
    IComando        → interface dos comandos
    TReceptor       → objeto que sofre as operações
    TComando_X/Y    → comandos concretos
    THistorico      → pilha de undo/redo
  ─────────────────────────────────────────────
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// 1. Interface do comando
// ---------------------------------------------------------------------------
type
  IComando = interface
  ['{00000000-0000-0000-0000-000000000050}']  // gerar novo GUID
    procedure Execute;
    procedure Undo;
    function  GetDescricao: string;
    function  PodeDesfazer: Boolean;
    property Descricao: string read GetDescricao;
  end;

// ---------------------------------------------------------------------------
// 2. Receptor — objeto que sofre as operações
// ---------------------------------------------------------------------------
type
  TReceptor = class
  private
    FEstado: string;
    FValor:  Integer;
  public
    constructor Create(const AEstado: string = ''; AValor: Integer = 0);
    procedure AplicarOperacao(const AOp: string; AValor: Integer);
    procedure DesfazerOperacao(const AEstadoAnterior: string; AValorAnterior: Integer);
    function  Snapshot: string;
    property Estado: string  read FEstado;
    property Valor:  Integer read FValor;
  end;

// ---------------------------------------------------------------------------
// 3. Comando concreto A — operação reversível com estado salvo
// ---------------------------------------------------------------------------
type
  TComandoA = class(TInterfacedObject, IComando)
  private
    FReceptor:       TReceptor;
    FNovoEstado:     string;
    FNovoValor:      Integer;
    FEstadoAnterior: string;   // salvo em Execute para Undo
    FValorAnterior:  Integer;
  public
    constructor Create(AReceptor: TReceptor; const ANovoEstado: string; ANovoValor: Integer);
    procedure Execute;
    procedure Undo;
    function  GetDescricao: string;
    function  PodeDesfazer: Boolean;
  end;

// ---------------------------------------------------------------------------
// 4. Comando concreto B — irreversível (não entra no Undo stack)
// ---------------------------------------------------------------------------
type
  TComandoIrreversivelB = class(TInterfacedObject, IComando)
  private
    FDescricao: string;
  public
    constructor Create(const ADescricao: string);
    procedure Execute;
    procedure Undo;               // noop
    function  GetDescricao: string;
    function  PodeDesfazer: Boolean;  // retorna False
  end;

// ---------------------------------------------------------------------------
// 5. MacroCommand — agrupa vários comandos como um
// ---------------------------------------------------------------------------
type
  TMacro = class(TInterfacedObject, IComando)
  private
    FComandos: TList<IComando>;
    FNome:     string;
  public
    constructor Create(const ANome: string);
    destructor Destroy; override;
    function  Adicionar(ACmd: IComando): TMacro;  // fluente
    procedure Execute;
    procedure Undo;
    function  GetDescricao: string;
    function  PodeDesfazer: Boolean;
  end;

// ---------------------------------------------------------------------------
// 6. Histórico — Undo/Redo stack
// ---------------------------------------------------------------------------
type
  THistorico = class
  private
    FUndo:    TList<IComando>;  // TList para poder limitar tamanho
    FRedo:    TStack<IComando>;
    FMaxSize: Integer;
  public
    constructor Create(AMaxSize: Integer = 50);
    destructor Destroy; override;
    procedure Executar(ACmd: IComando);   // execute + push (se desfazível)
    procedure Desfazer;
    procedure Refazer;
    procedure DesfazerTudo;
    function  PodeDesfazer: Boolean;
    function  PodeRefazer: Boolean;
    function  UndoCount: Integer;
    function  RedoCount: Integer;
    procedure ListarHistorico;
  end;

implementation

// ---------------------------------------------------------------------------
// TReceptor
// ---------------------------------------------------------------------------

constructor TReceptor.Create(const AEstado: string; AValor: Integer);
begin inherited Create; FEstado := AEstado; FValor := AValor; end;

procedure TReceptor.AplicarOperacao(const AOp: string; AValor: Integer);
begin FEstado := AOp; FValor := AValor;
  Writeln(Format('[Receptor] Aplicar: %s=%d', [AOp, AValor])); end;

procedure TReceptor.DesfazerOperacao(const AEstadoAnterior: string; AValorAnterior: Integer);
begin FEstado := AEstadoAnterior; FValor := AValorAnterior;
  Writeln(Format('[Receptor] Restaurado: %s=%d', [AEstadoAnterior, AValorAnterior])); end;

function TReceptor.Snapshot: string;
begin Result := Format('%s=%d', [FEstado, FValor]); end;

// ---------------------------------------------------------------------------
// TComandoA
// ---------------------------------------------------------------------------

constructor TComandoA.Create(AReceptor: TReceptor; const ANovoEstado: string; ANovoValor: Integer);
begin inherited Create; FReceptor := AReceptor;
  FNovoEstado := ANovoEstado; FNovoValor := ANovoValor; end;

procedure TComandoA.Execute;
begin
  // CRÍTICO: salvar estado antes de modificar
  FEstadoAnterior := FReceptor.Estado;
  FValorAnterior  := FReceptor.Valor;
  FReceptor.AplicarOperacao(FNovoEstado, FNovoValor);
end;

procedure TComandoA.Undo;
begin FReceptor.DesfazerOperacao(FEstadoAnterior, FValorAnterior); end;

function TComandoA.GetDescricao: string;
begin Result := Format('ComandoA(%s=%d)', [FNovoEstado, FNovoValor]); end;

function TComandoA.PodeDesfazer: Boolean;
begin Result := True; end;

// ---------------------------------------------------------------------------
// TComandoIrreversivelB
// ---------------------------------------------------------------------------

constructor TComandoIrreversivelB.Create(const ADescricao: string);
begin inherited Create; FDescricao := ADescricao; end;

procedure TComandoIrreversivelB.Execute;
begin Writeln('[Irreversível] ', FDescricao); end;

procedure TComandoIrreversivelB.Undo;
begin (* noop — irreversível *) end;

function TComandoIrreversivelB.GetDescricao: string;
begin Result := FDescricao; end;

function TComandoIrreversivelB.PodeDesfazer: Boolean;
begin Result := False; end;  // ← não será adicionado ao Undo stack

// ---------------------------------------------------------------------------
// TMacro
// ---------------------------------------------------------------------------

constructor TMacro.Create(const ANome: string);
begin inherited Create; FNome := ANome; FComandos := TList<IComando>.Create; end;

destructor TMacro.Destroy;
begin FComandos.Free; inherited; end;

function TMacro.Adicionar(ACmd: IComando): TMacro;
begin FComandos.Add(ACmd); Result := Self; end;

procedure TMacro.Execute;
var C: IComando;
begin for C in FComandos do C.Execute; end;

procedure TMacro.Undo;
var I: Integer;
begin  // undo em ordem reversa
  for I := FComandos.Count - 1 downto 0 do
    if FComandos[I].PodeDesfazer then FComandos[I].Undo;
end;

function TMacro.GetDescricao: string;
begin Result := Format('Macro[%s](%d)', [FNome, FComandos.Count]); end;

function TMacro.PodeDesfazer: Boolean;
begin Result := True; end;

// ---------------------------------------------------------------------------
// THistorico
// ---------------------------------------------------------------------------

constructor THistorico.Create(AMaxSize: Integer);
begin
  inherited Create;
  FMaxSize := AMaxSize;
  FUndo    := TList<IComando>.Create;
  FRedo    := TStack<IComando>.Create;
end;

destructor THistorico.Destroy;
begin FUndo.Free; FRedo.Free; inherited; end;

procedure THistorico.Executar(ACmd: IComando);
begin
  ACmd.Execute;
  if ACmd.PodeDesfazer then
  begin
    // Limitar tamanho: remover entrada mais antiga
    if FUndo.Count >= FMaxSize then FUndo.Delete(0);
    FUndo.Add(ACmd);
    FRedo.Clear;  // nova ação limpa Redo
  end;
end;

procedure THistorico.Desfazer;
var Cmd: IComando;
begin
  if FUndo.Count = 0 then Exit;
  Cmd := FUndo.Last;
  FUndo.Delete(FUndo.Count - 1);
  Cmd.Undo;
  FRedo.Push(Cmd);
end;

procedure THistorico.Refazer;
var Cmd: IComando;
begin
  if FRedo.Count = 0 then Exit;
  Cmd := FRedo.Pop;
  Cmd.Execute;
  FUndo.Add(Cmd);
end;

procedure THistorico.DesfazerTudo;
begin while FUndo.Count > 0 do Desfazer; end;

function THistorico.PodeDesfazer: Boolean; begin Result := FUndo.Count > 0; end;
function THistorico.PodeRefazer: Boolean;  begin Result := FRedo.Count > 0; end;
function THistorico.UndoCount: Integer;    begin Result := FUndo.Count; end;
function THistorico.RedoCount: Integer;    begin Result := FRedo.Count; end;

procedure THistorico.ListarHistorico;
var I: Integer;
begin
  Writeln('Histórico Undo (', FUndo.Count, ' itens):');
  for I := FUndo.Count - 1 downto 0 do
    Writeln('  ', FUndo[I].Descricao);
end;

// ---------------------------------------------------------------------------
// COMO USAR ESTE TEMPLATE
//
// 1. Renomeie TReceptor para o objeto de domínio (TDocument, TCanvas, etc.).
// 2. Em Execute: salve o estado ANTES de modificar o receptor.
// 3. Em Undo: restaure o estado salvo.
// 4. Comandos irreversíveis: PodeDesfazer := False.
//
// Uso básico:
//   var R := TReceptor.Create('inicial', 0);
//   var H := THistorico.Create;
//
//   H.Executar(TComandoA.Create(R, 'estado_1', 10));
//   H.Executar(TComandoA.Create(R, 'estado_2', 20));
//   Writeln(R.Snapshot);  // estado_2=20
//   H.Desfazer;
//   Writeln(R.Snapshot);  // estado_1=10
//   H.Refazer;
//   Writeln(R.Snapshot);  // estado_2=20
//
// Macro:
//   var M := TMacro.Create('operação-composta')
//     .Adicionar(TComandoA.Create(R, 'passo_1', 1))
//     .Adicionar(TComandoA.Create(R, 'passo_2', 2));
//   H.Executar(M);  // um único Undo desfaz toda a macro
// ---------------------------------------------------------------------------

end.

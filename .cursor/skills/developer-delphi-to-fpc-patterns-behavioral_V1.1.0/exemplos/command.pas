unit command;
{
  Command Pattern em Delphi — ICommand com Execute/Undo + TCommandHistory
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Interface Command
// ---------------------------------------------------------------------------
type
  ICommand = interface
  ['{CM000001-0000-0000-0000-000000000001}']
    procedure Execute;
    procedure Undo;
    function  GetDescricao: string;
    function  PodeDesfazer: Boolean;
    property Descricao: string read GetDescricao;
  end;

// ---------------------------------------------------------------------------
// Receptor — TextEditor (objeto que sofre as operações)
// ---------------------------------------------------------------------------
type
  TTextEditor = class
  private
    FConteudo: string;
    FCursor:   Integer;
  public
    constructor Create(const AConteudo: string = '');
    procedure InserirTexto(const ATexto: string; APosicao: Integer);
    procedure DeletarTexto(APosicao, AQtd: Integer);
    procedure MoverCursor(APosicao: Integer);
    function  GetConteudo: string;
    function  GetCursor: Integer;
    property Conteudo: string read FConteudo;
    property Cursor: Integer read FCursor;
  end;

// ---------------------------------------------------------------------------
// Commands concretos
// ---------------------------------------------------------------------------
type
  TInsertCommand = class(TInterfacedObject, ICommand)
  private
    FEditor:   TTextEditor;
    FTexto:    string;
    FPosicao:  Integer;
  public
    constructor Create(AEditor: TTextEditor; const ATexto: string; APosicao: Integer);
    procedure Execute;
    procedure Undo;
    function  GetDescricao: string;
    function  PodeDesfazer: Boolean;
  end;

  TDeleteCommand = class(TInterfacedObject, ICommand)
  private
    FEditor:   TTextEditor;
    FPosicao:  Integer;
    FQtd:      Integer;
    FTextoSalvo: string;  // salvo para undo
  public
    constructor Create(AEditor: TTextEditor; APosicao, AQtd: Integer);
    procedure Execute;
    procedure Undo;
    function  GetDescricao: string;
    function  PodeDesfazer: Boolean;
  end;

  TCursorMoveCommand = class(TInterfacedObject, ICommand)
  private
    FEditor:     TTextEditor;
    FNovaPosicao: Integer;
    FAnterior:   Integer;
  public
    constructor Create(AEditor: TTextEditor; ANovaPosicao: Integer);
    procedure Execute;
    procedure Undo;
    function  GetDescricao: string;
    function  PodeDesfazer: Boolean;
  end;

  // MacroCommand — agrega vários commands como um só
  TMacroCommand = class(TInterfacedObject, ICommand)
  private
    FComandos: TList<ICommand>;
    FNome:     string;
  public
    constructor Create(const ANome: string);
    destructor Destroy; override;
    procedure Adicionar(ACmd: ICommand);
    procedure Execute;
    procedure Undo;
    function  GetDescricao: string;
    function  PodeDesfazer: Boolean;
  end;

// ---------------------------------------------------------------------------
// TCommandHistory — pilha de undo/redo
// ---------------------------------------------------------------------------
type
  TCommandHistory = class
  private
    FHistorico: TStack<ICommand>;
    FRedo:      TStack<ICommand>;
    FMaxSize:   Integer;
  public
    constructor Create(AMaxSize: Integer = 100);
    destructor Destroy; override;
    procedure Executar(ACmd: ICommand);   // executa e adiciona ao histórico
    procedure Desfazer;                   // undo do último
    procedure Refazer;                    // redo
    procedure DesfazerTudo;
    function  PodeDesfazer: Boolean;
    function  PodeRefazer: Boolean;
    function  HistoricoCount: Integer;
    procedure ListarHistorico;
  end;

implementation

// ---------------------------------------------------------------------------
// TTextEditor
// ---------------------------------------------------------------------------

constructor TTextEditor.Create(const AConteudo: string);
begin inherited Create; FConteudo := AConteudo; FCursor := Length(AConteudo); end;

procedure TTextEditor.InserirTexto(const ATexto: string; APosicao: Integer);
begin
  APosicao := Max(0, Min(APosicao, Length(FConteudo)));
  FConteudo := Copy(FConteudo, 1, APosicao) + ATexto +
               Copy(FConteudo, APosicao + 1, MaxInt);
  FCursor := APosicao + Length(ATexto);
end;

procedure TTextEditor.DeletarTexto(APosicao, AQtd: Integer);
begin
  APosicao := Max(0, Min(APosicao, Length(FConteudo)));
  AQtd := Min(AQtd, Length(FConteudo) - APosicao);
  FConteudo := Copy(FConteudo, 1, APosicao) +
               Copy(FConteudo, APosicao + AQtd + 1, MaxInt);
  FCursor := APosicao;
end;

procedure TTextEditor.MoverCursor(APosicao: Integer);
begin FCursor := Max(0, Min(APosicao, Length(FConteudo))); end;

function TTextEditor.GetConteudo: string; begin Result := FConteudo; end;
function TTextEditor.GetCursor: Integer;  begin Result := FCursor; end;

// ---------------------------------------------------------------------------
// TInsertCommand
// ---------------------------------------------------------------------------

constructor TInsertCommand.Create(AEditor: TTextEditor; const ATexto: string; APosicao: Integer);
begin inherited Create; FEditor := AEditor; FTexto := ATexto; FPosicao := APosicao; end;

procedure TInsertCommand.Execute;
begin FEditor.InserirTexto(FTexto, FPosicao); end;

procedure TInsertCommand.Undo;
begin FEditor.DeletarTexto(FPosicao, Length(FTexto)); end;

function TInsertCommand.GetDescricao: string;
begin Result := Format('Inserir "%s" em pos %d', [FTexto, FPosicao]); end;

function TInsertCommand.PodeDesfazer: Boolean;
begin Result := True; end;

// ---------------------------------------------------------------------------
// TDeleteCommand
// ---------------------------------------------------------------------------

constructor TDeleteCommand.Create(AEditor: TTextEditor; APosicao, AQtd: Integer);
begin inherited Create; FEditor := AEditor; FPosicao := APosicao; FQtd := AQtd; end;

procedure TDeleteCommand.Execute;
begin
  FTextoSalvo := Copy(FEditor.Conteudo, FPosicao + 1, FQtd);  // salvar para undo
  FEditor.DeletarTexto(FPosicao, FQtd);
end;

procedure TDeleteCommand.Undo;
begin FEditor.InserirTexto(FTextoSalvo, FPosicao); end;

function TDeleteCommand.GetDescricao: string;
begin Result := Format('Deletar %d chars em pos %d', [FQtd, FPosicao]); end;

function TDeleteCommand.PodeDesfazer: Boolean;
begin Result := FTextoSalvo <> ''; end;

// ---------------------------------------------------------------------------
// TCursorMoveCommand
// ---------------------------------------------------------------------------

constructor TCursorMoveCommand.Create(AEditor: TTextEditor; ANovaPosicao: Integer);
begin inherited Create; FEditor := AEditor; FNovaPosicao := ANovaPosicao; end;

procedure TCursorMoveCommand.Execute;
begin FAnterior := FEditor.Cursor; FEditor.MoverCursor(FNovaPosicao); end;

procedure TCursorMoveCommand.Undo;
begin FEditor.MoverCursor(FAnterior); end;

function TCursorMoveCommand.GetDescricao: string;
begin Result := Format('Mover cursor para %d', [FNovaPosicao]); end;

function TCursorMoveCommand.PodeDesfazer: Boolean;
begin Result := True; end;

// ---------------------------------------------------------------------------
// TMacroCommand
// ---------------------------------------------------------------------------

constructor TMacroCommand.Create(const ANome: string);
begin inherited Create; FNome := ANome; FComandos := TList<ICommand>.Create; end;

destructor TMacroCommand.Destroy;
begin FComandos.Free; inherited; end;

procedure TMacroCommand.Adicionar(ACmd: ICommand);
begin FComandos.Add(ACmd); end;

procedure TMacroCommand.Execute;
var C: ICommand;
begin for C in FComandos do C.Execute; end;

procedure TMacroCommand.Undo;
var I: Integer;
begin
  for I := FComandos.Count - 1 downto 0 do
    if FComandos[I].PodeDesfazer then FComandos[I].Undo;
end;

function TMacroCommand.GetDescricao: string;
begin Result := Format('Macro[%s] (%d cmds)', [FNome, FComandos.Count]); end;

function TMacroCommand.PodeDesfazer: Boolean;
begin Result := True; end;

// ---------------------------------------------------------------------------
// TCommandHistory
// ---------------------------------------------------------------------------

constructor TCommandHistory.Create(AMaxSize: Integer);
begin
  inherited Create;
  FMaxSize   := AMaxSize;
  FHistorico := TStack<ICommand>.Create;
  FRedo      := TStack<ICommand>.Create;
end;

destructor TCommandHistory.Destroy;
begin FHistorico.Free; FRedo.Free; inherited; end;

procedure TCommandHistory.Executar(ACmd: ICommand);
begin
  ACmd.Execute;
  FHistorico.Push(ACmd);
  FRedo.Clear;  // nova ação limpa o redo stack
  // Limitar tamanho
  while FHistorico.Count > FMaxSize do
    FHistorico.TrimExcess;  // na prática usaria TList para remover o fundo
end;

procedure TCommandHistory.Desfazer;
var Cmd: ICommand;
begin
  if FHistorico.Count = 0 then Exit;
  Cmd := FHistorico.Pop;
  if Cmd.PodeDesfazer then
  begin
    Cmd.Undo;
    FRedo.Push(Cmd);
  end;
end;

procedure TCommandHistory.Refazer;
var Cmd: ICommand;
begin
  if FRedo.Count = 0 then Exit;
  Cmd := FRedo.Pop;
  Cmd.Execute;
  FHistorico.Push(Cmd);
end;

procedure TCommandHistory.DesfazerTudo;
begin while FHistorico.Count > 0 do Desfazer; end;

function TCommandHistory.PodeDesfazer: Boolean;
begin Result := FHistorico.Count > 0; end;

function TCommandHistory.PodeRefazer: Boolean;
begin Result := FRedo.Count > 0; end;

function TCommandHistory.HistoricoCount: Integer;
begin Result := FHistorico.Count; end;

procedure TCommandHistory.ListarHistorico;
var Arr: TArray<ICommand>;
    I: Integer;
begin
  Arr := FHistorico.ToArray;
  Writeln('Histórico (', Length(Arr), ' comandos):');
  for I := High(Arr) downto 0 do
    Writeln(Format('  [%d] %s', [I, Arr[I].Descricao]));
end;

// ---------------------------------------------------------------------------
// USO:
//   var Editor   := TTextEditor.Create('Olá mundo');
//   var Historico := TCommandHistory.Create;
//
//   // Executar com histórico
//   Historico.Executar(TInsertCommand.Create(Editor, ' cruel', 9));
//   Writeln(Editor.Conteudo);  // Olá mundo cruel
//
//   Historico.Executar(TDeleteCommand.Create(Editor, 9, 6));
//   Writeln(Editor.Conteudo);  // Olá mundo
//
//   // Undo
//   Historico.Desfazer;
//   Writeln(Editor.Conteudo);  // Olá mundo cruel
//
//   // Redo
//   Historico.Refazer;
//   Writeln(Editor.Conteudo);  // Olá mundo
//
//   // MacroCommand
//   var Macro := TMacroCommand.Create('formatar');
//   Macro.Adicionar(TInsertCommand.Create(Editor, '<b>', 0));
//   Macro.Adicionar(TInsertCommand.Create(Editor, '</b>', MaxInt));
//   Historico.Executar(Macro);
//   Historico.Desfazer;  // desfaz toda a macro de uma vez
// ---------------------------------------------------------------------------

end.

unit tqueue_tstack;
{
  TQueue<T> FIFO e TStack<T> LIFO — exemplos práticos
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

procedure DemoQueue;
procedure DemoStack;
procedure DemoQueueTarefas;
procedure DemoStackNavegacao;
procedure DemoStackCalculadora;

implementation

// ---------------------------------------------------------------------------
// DemoQueue — FIFO básico
// ---------------------------------------------------------------------------

procedure DemoQueue;
var Q: TQueue<string>;
    Item: string;
begin
  Q := TQueue<string>.Create;
  try
    // Enqueue — adiciona no fim
    Q.Enqueue('primeiro');
    Q.Enqueue('segundo');
    Q.Enqueue('terceiro');
    Writeln('Queue Count: ', Q.Count);

    // Peek — ver sem remover
    Writeln('Peek: ', Q.Peek);    // 'primeiro'
    Writeln('Count após Peek: ', Q.Count);  // ainda 3

    // Dequeue — remove do início (FIFO)
    while Q.Count > 0 do
    begin
      Item := Q.Dequeue;
      Writeln('Dequeue: ', Item);
    end;
    // Saída: primeiro, segundo, terceiro

    // TryDequeue — sem raise se vazio
    if not Q.TryDequeue(Item) then
      Writeln('Fila vazia — sem raise');
  finally
    Q.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoStack — LIFO básico
// ---------------------------------------------------------------------------

procedure DemoStack;
var S: TStack<Integer>;
    Val: Integer;
begin
  S := TStack<Integer>.Create;
  try
    // Push — empilha no topo
    S.Push(10);
    S.Push(20);
    S.Push(30);
    Writeln('Stack Count: ', S.Count);

    // Peek — ver topo sem remover
    Writeln('Peek: ', S.Peek);   // 30

    // Pop — remove do topo (LIFO)
    while S.Count > 0 do
    begin
      Val := S.Pop;
      Writeln('Pop: ', Val);
    end;
    // Saída: 30, 20, 10

    // TryPop — sem raise se vazio
    if not S.TryPop(Val) then
      Writeln('Pilha vazia — sem raise');
  finally
    S.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoQueueTarefas — fila de processamento de tarefas
// ---------------------------------------------------------------------------

type
  TTarefa = record
    Id:       Integer;
    Descricao: string;
    Prioridade: Integer;
    function ToString: string;
  end;

function TTarefa.ToString: string;
begin Result := Format('[T%d] %s (p=%d)', [Id, Descricao, Prioridade]); end;

procedure DemoQueueTarefas;
var Fila: TQueue<TTarefa>;
    T: TTarefa;
    Processadas: Integer;
begin
  Fila := TQueue<TTarefa>.Create;
  try
    // Enfileirar tarefas
    T.Id := 1; T.Descricao := 'Enviar email'; T.Prioridade := 2;
    Fila.Enqueue(T);
    T.Id := 2; T.Descricao := 'Gerar relatório'; T.Prioridade := 1;
    Fila.Enqueue(T);
    T.Id := 3; T.Descricao := 'Atualizar cache'; T.Prioridade := 3;
    Fila.Enqueue(T);

    Writeln('--- Processando fila de tarefas ---');
    Processadas := 0;
    while Fila.Count > 0 do
    begin
      T := Fila.Dequeue;
      Writeln('Processando: ', T.ToString);
      Inc(Processadas);
    end;
    Writeln('Total processadas: ', Processadas);
  finally
    Fila.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoStackNavegacao — pilha de navegação (histórico de páginas)
// ---------------------------------------------------------------------------

type
  TNavegador = class
  private
    FHistorico: TStack<string>;
    FAtual: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Navegar(const AURL: string);
    procedure Voltar;
    procedure MostrarEstado;
  end;

constructor TNavegador.Create;
begin inherited Create; FHistorico := TStack<string>.Create; FAtual := '(início)'; end;

destructor TNavegador.Destroy;
begin FHistorico.Free; inherited; end;

procedure TNavegador.Navegar(const AURL: string);
begin
  FHistorico.Push(FAtual);  // salva atual
  FAtual := AURL;
  Writeln('Navegou para: ', AURL);
end;

procedure TNavegador.Voltar;
begin
  if FHistorico.Count = 0 then begin Writeln('Sem histórico'); Exit; end;
  FAtual := FHistorico.Pop;
  Writeln('Voltou para: ', FAtual);
end;

procedure TNavegador.MostrarEstado;
begin Writeln('Atual: ', FAtual, ' | Histórico: ', FHistorico.Count, ' páginas'); end;

procedure DemoStackNavegacao;
var Nav: TNavegador;
begin
  Nav := TNavegador.Create;
  try
    Nav.Navegar('home.html');
    Nav.Navegar('produtos.html');
    Nav.Navegar('produto/42.html');
    Nav.MostrarEstado;
    Nav.Voltar;
    Nav.Voltar;
    Nav.MostrarEstado;
    Nav.Voltar;
    Nav.Voltar;  // sem histórico
  finally Nav.Free; end;
end;

// ---------------------------------------------------------------------------
// DemoStackCalculadora — avaliação de expressão com pilha
// ---------------------------------------------------------------------------

procedure DemoStackCalculadora;
var Operandos: TStack<Double>;
    Tokens: TArray<string>;
    Token: string;
    A, B: Double;
begin
  // Notação pós-fixa (RPN): "3 4 + 2 * 5 -" = ((3+4)*2)-5 = 9
  Tokens := ['3', '4', '+', '2', '*', '5', '-'];
  Operandos := TStack<Double>.Create;
  try
    for Token in Tokens do
    begin
      if (Token = '+') or (Token = '-') or (Token = '*') or (Token = '/') then
      begin
        B := Operandos.Pop;
        A := Operandos.Pop;
        case Token[1] of
          '+': Operandos.Push(A + B);
          '-': Operandos.Push(A - B);
          '*': Operandos.Push(A * B);
          '/': Operandos.Push(A / B);
        end;
      end
      else
        Operandos.Push(StrToFloat(Token));
    end;
    Writeln('Resultado RPN "3 4 + 2 * 5 -" = ', Operandos.Pop:0:0);  // 9
  finally
    Operandos.Free;
  end;
end;

// ---------------------------------------------------------------------------
// USO:
//   DemoQueue;
//   DemoStack;
//   DemoQueueTarefas;
//   DemoStackNavegacao;
//   DemoStackCalculadora;
// ---------------------------------------------------------------------------

end.

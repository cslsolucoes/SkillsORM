unit tobjectlist;
{
  TObjectList<T> — OwnsObjects, auto-destroy, hierarquia de tipos
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

type
  TAnimal = class
  private
    FNome: string;
  public
    constructor Create(const ANome: string);
    function Falar: string; virtual; abstract;
    property Nome: string read FNome;
  end;

  TCao = class(TAnimal)
    function Falar: string; override;
  end;

  TGato = class(TAnimal)
    function Falar: string; override;
  end;

procedure DemoObjectListBasico;
procedure DemoObjectListOwnership;
procedure DemoObjectListPolimorfismo;
procedure DemoObjectListPorValor;

implementation

// ---------------------------------------------------------------------------
// TAnimal + subclasses
// ---------------------------------------------------------------------------

constructor TAnimal.Create(const ANome: string);
begin inherited Create; FNome := ANome; end;

function TCao.Falar: string;  begin Result := 'Au Au!'; end;
function TGato.Falar: string; begin Result := 'Miau!'; end;

// ---------------------------------------------------------------------------
// DemoObjectListBasico
// ---------------------------------------------------------------------------

procedure DemoObjectListBasico;
var Lista: TObjectList<TAnimal>;
    A: TAnimal;
begin
  // OwnsObjects = True por padrão — Free dos objetos é automático
  Lista := TObjectList<TAnimal>.Create;  // OwnsObjects=True
  try
    Lista.Add(TCao.Create('Rex'));
    Lista.Add(TGato.Create('Mimi'));
    Lista.Add(TCao.Create('Bolinha'));

    Writeln('--- Animais (', Lista.Count, ') ---');
    for A in Lista do
      Writeln(A.Nome, ' diz: ', A.Falar);

    // Remover por índice — o objeto É liberado automaticamente
    Lista.Delete(1);  // remove e Free Mimi
    Writeln('Após Delete(1): ', Lista.Count, ' animais');
  finally
    Lista.Free;  // libera Rex e Bolinha automaticamente
  end;
end;

// ---------------------------------------------------------------------------
// DemoObjectListOwnership — diferença OwnsObjects True vs False
// ---------------------------------------------------------------------------

procedure DemoObjectListOwnership;
var ListaDono:   TObjectList<TAnimal>;
    ListaEmprest: TObjectList<TAnimal>;
    Cao: TAnimal;
begin
  Cao := TCao.Create('Thor');

  // OwnsObjects = True: lista é dona
  ListaDono := TObjectList<TAnimal>.Create(True);
  try
    ListaDono.Add(TCao.Create('Buddy'));
    // NÃO adicionar Cao aqui — seria liberado pelo Free da lista
    Writeln('ListaDono.Count = ', ListaDono.Count);
  finally
    ListaDono.Free;  // libera Buddy; não temos mais acesso a ele
  end;

  // OwnsObjects = False: lista emprestada — não libera
  ListaEmprest := TObjectList<TAnimal>.Create(False);
  try
    ListaEmprest.Add(Cao);  // só referência, não transfere ownership
    Writeln('ListaEmprest: ', ListaEmprest[0].Nome);
  finally
    ListaEmprest.Free;  // NÃO libera Cao
  end;
  // Precisamos liberar Cao manualmente
  Cao.Free;

  Writeln('OwnsObjects demo concluído');
end;

// ---------------------------------------------------------------------------
// DemoObjectListPolimorfismo — lista de base com subtipos
// ---------------------------------------------------------------------------

procedure DemoObjectListPolimorfismo;
var Animais: TObjectList<TAnimal>;
    A: TAnimal;
begin
  Animais := TObjectList<TAnimal>.Create;
  try
    Animais.Add(TCao.Create('Rex'));
    Animais.Add(TGato.Create('Whiskers'));
    Animais.Add(TCao.Create('Max'));
    Animais.Add(TGato.Create('Luna'));

    // Polimorfismo — Falar() virtual chama subtipo correto
    Writeln('--- Todos falam ---');
    for A in Animais do
      Writeln(A.Nome, ': ', A.Falar);

    // Filtrar por tipo com "is"
    Writeln('--- Só cães ---');
    for A in Animais do
      if A is TCao then Writeln(A.Nome);

    // Contar por tipo
    var NCaes := 0; var NGatos := 0;
    for A in Animais do
      if A is TCao then Inc(NCaes) else Inc(NGatos);
    Writeln(Format('Cães: %d  Gatos: %d', [NCaes, NGatos]));
  finally
    Animais.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoObjectListPorValor — quando T é record/value type, usar TList<T>
// ---------------------------------------------------------------------------

type
  TPontoValor = record
    X, Y: Double;
    function ToString: string;
  end;

function TPontoValor.ToString: string;
begin Result := Format('(%.1f, %.1f)', [X, Y]); end;

procedure DemoObjectListPorValor;
var Pontos: TList<TPontoValor>;
    P: TPontoValor;
begin
  // Records: usar TList<T>, não TObjectList<T>
  // TObjectList é apenas para TObject e descendentes
  Pontos := TList<TPontoValor>.Create;
  try
    P.X := 1.0; P.Y := 2.0; Pontos.Add(P);
    P.X := 3.0; P.Y := 4.0; Pontos.Add(P);
    P.X := 5.0; P.Y := 6.0; Pontos.Add(P);

    Writeln('--- Pontos (records, sem Free) ---');
    for P in Pontos do Writeln(P.ToString);
  finally
    Pontos.Free;  // não precisa Free individual — records são valor
  end;
end;

// ---------------------------------------------------------------------------
// USO:
//   DemoObjectListBasico;
//   DemoObjectListOwnership;
//   DemoObjectListPolimorfismo;
//   DemoObjectListPorValor;
// ---------------------------------------------------------------------------

end.

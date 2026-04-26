unit anon_methods;
{
  Anonymous methods em Delphi — comparação com procedure of object
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Tipo: procedure of object (clássico — Delphi sempre suportou)
// ---------------------------------------------------------------------------
type
  TNotificacaoHandler = procedure(const AMsg: string) of object;

  TPublicador = class
  private
    FHandlers: TList<TNotificacaoHandler>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assinar(AHandler: TNotificacaoHandler);
    procedure Publicar(const AMsg: string);
  end;

// ---------------------------------------------------------------------------
// Tipo: anonymous method (Delphi 2009+)
// ---------------------------------------------------------------------------
type
  THandler = reference to procedure(const AMsg: string);

  TPublicadorAnon = class
  private
    FHandlers: TList<THandler>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assinar(AHandler: THandler);
    procedure Publicar(const AMsg: string);
  end;

// ---------------------------------------------------------------------------
// Demonstrações
// ---------------------------------------------------------------------------

// Demonstra procedure of object — requer instância como "self"
procedure DemoProceOfObject;

// Demonstra anonymous method — sem instância necessária
procedure DemoAnonMethod;

// Demonstra diferença na captura de estado
procedure DemoCaptura;

implementation

// ---------------------------------------------------------------------------
// TPublicador (procedure of object)
// ---------------------------------------------------------------------------

constructor TPublicador.Create;
begin
  inherited Create;
  FHandlers := TList<TNotificacaoHandler>.Create;
end;

destructor TPublicador.Destroy;
begin
  FHandlers.Free;
  inherited;
end;

procedure TPublicador.Assinar(AHandler: TNotificacaoHandler);
begin
  FHandlers.Add(AHandler);
end;

procedure TPublicador.Publicar(const AMsg: string);
var H: TNotificacaoHandler;
begin
  for H in FHandlers do H(AMsg);
end;

// ---------------------------------------------------------------------------
// TPublicadorAnon (anonymous method)
// ---------------------------------------------------------------------------

constructor TPublicadorAnon.Create;
begin
  inherited Create;
  FHandlers := TList<THandler>.Create;
end;

destructor TPublicadorAnon.Destroy;
begin
  FHandlers.Free;
  inherited;
end;

procedure TPublicadorAnon.Assinar(AHandler: THandler);
begin
  FHandlers.Add(AHandler);
end;

procedure TPublicadorAnon.Publicar(const AMsg: string);
var H: THandler;
begin
  for H in FHandlers do H(AMsg);
end;

// ---------------------------------------------------------------------------
// DemoProceOfObject — precisa de classe receptora
// ---------------------------------------------------------------------------

type
  TReceptor = class
  private
    FNome: string;
  public
    constructor Create(const ANome: string);
    procedure OnMensagem(const AMsg: string);
  end;

constructor TReceptor.Create(const ANome: string);
begin inherited Create; FNome := ANome; end;

procedure TReceptor.OnMensagem(const AMsg: string);
begin Writeln(FNome, ' recebeu: ', AMsg); end;

procedure DemoProceOfObject;
var
  Pub : TPublicador;
  R1  : TReceptor;
  R2  : TReceptor;
begin
  Pub := TPublicador.Create;
  R1  := TReceptor.Create('Receptor-A');
  R2  := TReceptor.Create('Receptor-B');
  try
    Pub.Assinar(R1.OnMensagem);
    Pub.Assinar(R2.OnMensagem);
    Pub.Publicar('Evento 1');
    // Receptor-A recebeu: Evento 1
    // Receptor-B recebeu: Evento 1
  finally
    Pub.Free; R1.Free; R2.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoAnonMethod — sem classe receptora necessária
// ---------------------------------------------------------------------------

procedure DemoAnonMethod;
var
  Pub     : TPublicadorAnon;
  Contador: Integer;
begin
  Pub      := TPublicadorAnon.Create;
  Contador := 0;
  try
    // Captura variável local 'Contador' (closure!)
    Pub.Assinar(
      procedure(const AMsg: string)
      begin
        Inc(Contador);
        Writeln(Format('[%d] %s', [Contador, AMsg]));
      end);

    // Pode assinar diretamente com procedimento livre
    Pub.Assinar(
      procedure(const AMsg: string)
      begin
        Writeln('LOG: ', AMsg.ToUpper);
      end);

    Pub.Publicar('Evento A');
    Pub.Publicar('Evento B');
    // [1] Evento A
    // LOG: EVENTO A
    // [2] Evento B
    // LOG: EVENTO B
    Writeln('Total processado pelo closure: ', Contador);  // 2
  finally
    Pub.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoCaptura — diferença fundamental entre os dois tipos
// ---------------------------------------------------------------------------

procedure DemoCaptura;
var
  // Procedure of object NÃO pode ser criada inline
  // Precisa de método de classe → impede captura de variáveis locais

  // Anonymous method CAPTURA variáveis por REFERÊNCIA
  N     : Integer;
  Dobrar: TFunc<Integer>;
begin
  N := 10;

  // N é capturado por referência — mudanças em N refletem no closure
  Dobrar := function: Integer begin Result := N * 2; end;

  Writeln(Dobrar());  // 20
  N := 30;
  Writeln(Dobrar());  // 60 — N mudou, closure reflete a mudança!

  // IMPORTANTE: ciclo de vida
  // O anonymous method mantém a variável capturada viva enquanto
  // existir alguma referência ao closure — mesmo após sair do escopo original.
  // Usar com cuidado em loops para evitar captura inesperada.
end;

// ---------------------------------------------------------------------------
// USO:
//   DemoProceOfObject;
//   DemoAnonMethod;
//   DemoCaptura;
// ---------------------------------------------------------------------------

end.

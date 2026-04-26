program memory_leak_patterns;
{$APPTYPE CONSOLE}
{$R *.res}
///  Demonstra os 5 padroes mais comuns de memory leak em Delphi e como evita-los.
///  Compilavel com: dcc32 memory_leak_patterns.pas  ou  dcc64 memory_leak_patterns.pas
///
///  Padroes cobertos:
///   1. Objeto criado sem try..finally (excecao antes do Free)
///   2. TList sem OwnsObjects=True (itens nao liberados)
///   3. Referencia circular entre interfaces (quebrar com [weak])
///   4. Evento nao desregistrado (TNotifyEvent aponta para objeto destruido)
///   5. Anonymous method captura interface em closure circular

uses
  System.SysUtils,
  System.Classes,
  Generics.Collections;

// ---------------------------------------------------------------------------
// Padrao 1: try..finally obrigatorio para todo objeto criado manualmente
// ---------------------------------------------------------------------------

procedure Padrao1_SemLeak;
var
  Lista: TStringList;
begin
  // CORRETO: Free sempre executado, mesmo com excecao
  Lista := TStringList.Create;
  try
    Lista.Add('item A');
    Lista.Add('item B');
    // se houver excecao aqui, Lista.Free sera chamado no finally
    WriteLn('[P1] Correto: ' + Lista[0] + ', ' + Lista[1]);
  finally
    Lista.Free;
  end;
end;

procedure Padrao1_ComLeak_NaoProduzido;
begin
  // ERRADO (apenas referencia — nao executar):
  // var Lista := TStringList.Create;
  // Lista.Add('x');
  // raise Exception.Create('falha');  // <-- Free nunca chamado → leak
  // Lista.Free;
  WriteLn('[P1] Anti-padrao: criar sem try..finally — excecao provoca leak.');
end;

// ---------------------------------------------------------------------------
// Padrao 2: TObjectList com OwnsObjects=True libera itens automaticamente
// ---------------------------------------------------------------------------

type
  TServico = class
  public
    Nome: string;
    constructor Create(const ANome: string);
    destructor Destroy; override;
  end;

constructor TServico.Create(const ANome: string);
begin
  inherited Create;
  Nome := ANome;
end;

destructor TServico.Destroy;
begin
  WriteLn('[TServico] Destruido: ' + Nome);
  inherited;
end;

procedure Padrao2_TObjectList_OwnsObjects;
var
  Servicos: TObjectList<TServico>;
begin
  // CORRETO: OwnsObjects=True — lista libera os objetos no Destroy/Clear
  Servicos := TObjectList<TServico>.Create(True {OwnsObjects});
  try
    Servicos.Add(TServico.Create('Servico-A'));
    Servicos.Add(TServico.Create('Servico-B'));
    WriteLn('[P2] TObjectList com OwnsObjects=True: itens destruidos ao liberar lista.');
  finally
    Servicos.Free; // <-- libera a lista E os 2 TServico internamente
  end;
end;

procedure Padrao2_TList_SemOwns_NaoProduzido;
begin
  // ERRADO (apenas referencia):
  // var L := TList<TServico>.Create;  // TList nao tem OwnsObjects
  // L.Add(TServico.Create('X'));
  // L.Free;  // <-- libera apenas a lista; TServico X vaza
  WriteLn('[P2] Anti-padrao: TList<T> nao libera os itens — usar TObjectList<T>.');
end;

// ---------------------------------------------------------------------------
// Padrao 3: Referencia circular entre interfaces — quebrar com [weak]
// ---------------------------------------------------------------------------

type
  IFilho  = interface;
  IPai    = interface
    ['{A1B2C3D4-0001-0000-0000-000000000001}']
    procedure SetFilho(const AFilho: IFilho);
    function  GetNome: string;
  end;

  IFilho = interface
    ['{B2C3D4E5-0002-0000-0000-000000000002}']
    function GetNome: string;
  end;

  TPai = class(TInterfacedObject, IPai)
  private
    // [weak] quebra a referencia forte — sem [weak] seria circular
    [weak] FFilho: IFilho;
  public
    class function New: IPai;
    procedure SetFilho(const AFilho: IFilho);
    function  GetNome: string;
  end;

  TFilho = class(TInterfacedObject, IFilho)
  private
    FPai: IPai; // referencia forte para o pai (OK — pai usa [weak] para filho)
  public
    class function New(const APai: IPai): IFilho;
    function GetNome: string;
  end;

class function TPai.New: IPai;
begin
  Result := TPai.Create;
end;

procedure TPai.SetFilho(const AFilho: IFilho);
begin
  FFilho := AFilho;
end;

function TPai.GetNome: string;
begin
  Result := 'Pai';
  if FFilho <> nil then
    Result := Result + ' (filho: ' + FFilho.GetNome + ')';
end;

class function TFilho.New(const APai: IPai): IFilho;
var
  F: TFilho;
begin
  F      := TFilho.Create;
  F.FPai := APai;
  Result := F;
end;

function TFilho.GetNome: string;
begin
  Result := 'Filho';
end;

procedure Padrao3_ReferenciaCiclar_ComWeak;
var
  Pai:   IPai;
  Filho: IFilho;
begin
  Pai   := TPai.New;
  Filho := TFilho.New(Pai);
  Pai.SetFilho(Filho);
  // Com [weak] em TPai.FFilho, o ref-count do Filho nao e incrementado por Pai.
  // Quando Filho sai de escopo, seu refcount chega a 0 e e destruido.
  // Sem [weak], ambos ficam com refcount >= 1 mesmo fora de escopo → leak.
  WriteLn('[P3] ' + Pai.GetNome + ' — referencia circular quebrada com [weak].');
end;

// ---------------------------------------------------------------------------
// Padrao 4: Evento desregistrado no destrutor para evitar dangling pointer
// ---------------------------------------------------------------------------

type
  TPublicador = class
  public
    OnAtualizacao: TNotifyEvent;
    procedure Publicar;
  end;

  TAssinante = class
  private
    FPublicador: TPublicador;
  public
    constructor Create(APub: TPublicador);
    destructor Destroy; override;
    procedure AoAtualizar(Sender: TObject);
  end;

procedure TPublicador.Publicar;
begin
  if Assigned(OnAtualizacao) then
    OnAtualizacao(Self);
end;

constructor TAssinante.Create(APub: TPublicador);
begin
  inherited Create;
  FPublicador              := APub;
  FPublicador.OnAtualizacao := AoAtualizar; // registra evento
end;

destructor TAssinante.Destroy;
begin
  // CORRETO: desregistrar antes de destruir para evitar dangling pointer
  if Assigned(FPublicador) and (@FPublicador.OnAtualizacao = @AoAtualizar) then
    FPublicador.OnAtualizacao := nil;
  inherited;
end;

procedure TAssinante.AoAtualizar(Sender: TObject);
begin
  WriteLn('[P4] Assinante notificado pela publicacao.');
end;

procedure Padrao4_EventoDesregistrado;
var
  Pub:  TPublicador;
  Ass:  TAssinante;
begin
  Pub := TPublicador.Create;
  try
    Ass := TAssinante.Create(Pub);
    try
      Pub.Publicar; // Assinante recebe evento
    finally
      Ass.Free; // destrutor desregistra OnAtualizacao
    end;
    // Pub.Publicar aqui seria seguro: OnAtualizacao = nil
    WriteLn('[P4] Evento desregistrado no destrutor — sem dangling pointer.');
  finally
    Pub.Free;
  end;
end;

// ---------------------------------------------------------------------------
// Padrao 5: Anonymous method e closure — evitar captura circular de interface
// ---------------------------------------------------------------------------

procedure Padrao5_AnonymousSemClosure;
var
  Lista:  TStringList;
  Acao:   TProc;
  CopiaLocal: string; // copia de valor, nao referencia ao objeto
begin
  Lista := TStringList.Create;
  try
    Lista.Add('alpha');
    Lista.Add('beta');

    // CORRETO: captura uma copia do valor, nao do objeto interface
    CopiaLocal := Lista.CommaText;
    Acao := procedure
    begin
      WriteLn('[P5] Valor capturado: ' + CopiaLocal);
    end;

    Lista.Free; // libera a lista ANTES de chamar Acao
    Lista := nil;

    Acao(); // seguro: CopiaLocal e independente de Lista
  except
    on E: Exception do
    begin
      if Assigned(Lista) then Lista.Free;
      raise;
    end;
  end;
end;

begin
  try
    WriteLn('=== Padroes de Memory Leak em Delphi ===');
    WriteLn;
    Padrao1_SemLeak;
    Padrao1_ComLeak_NaoProduzido;
    WriteLn;
    Padrao2_TObjectList_OwnsObjects;
    Padrao2_TList_SemOwns_NaoProduzido;
    WriteLn;
    Padrao3_ReferenciaCiclar_ComWeak;
    WriteLn;
    Padrao4_EventoDesregistrado;
    WriteLn;
    Padrao5_AnonymousSemClosure;
    WriteLn;
    WriteLn('OK -- developer-delphi-to-fpc-performance-profiling / memory_leak_patterns');
    Halt(0);
  except
    on E: Exception do
    begin
      WriteLn('ERRO: ' + E.Message);
      Halt(1);
    end;
  end;
end.

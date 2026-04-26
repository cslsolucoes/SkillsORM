program watches_avancados;
{$APPTYPE CONSOLE}
{$IFDEF FPC}
  {$mode delphi}
{$ENDIF}
(*
  EXEMPLO: Watch expressions avancadas no Delphi Debugger
  Compilar: dcc32 watches_avancados.pas  OU  dcc64 watches_avancados.pas

  COMO ADICIONAR WATCHES NO IDE:
    View → Debug Windows → Watches (Ctrl+Alt+W)
    Clicar com direito → Add Watch → digitar expressao.

  EXPRESSOES UTEIS PARA WATCHES:
    Objeto simples:
      Cliente.Nome           → valor da propriedade
      Cliente.Saldo          → campo numerico

    Expressoes calculadas:
      Length(MeuArray)       → tamanho do array dinamico
      High(MeuArray)         → ultimo indice valido

    Cast para tipo especifico:
      (TCliente(Obj)).Saldo  → cast de TObject para TCliente
      (ICliente(Intf)).Nome  → interface para tipo concreto

    Inspecao de memoria:
      @MeuRegistro           → endereco de memoria do registro
      Pointer(MeuObjeto)     → ponteiro bruto do objeto

    Class View (clicar no watch → expandir arvore):
      Mostra todos os campos/propriedades em arvore navegavel.

    Memory View (View → Debug Windows → CPU → Memory):
      Digitar endereco: @MinhaVar  ou  Pointer(MeuObjeto)
      Exibe bytes brutos de memoria naquele endereco.

    Registrador (apenas na CPU View):
      EAX  EBX  ECX  EDX  (Win32)
      RAX  RBX  RCX  RDX  (Win64)
*)
uses
  SysUtils, Generics.Collections;

type
  ICliente = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    function GetNome: string;
    function GetSaldo: Double;
    property Nome: string read GetNome;
    property Saldo: Double read GetSaldo;
  end;

  TCliente = class(TInterfacedObject, ICliente)
  private
    FNome: string;
    FSaldo: Double;
    FHistorico: TList<Double>;
    function GetNome: string;
    function GetSaldo: Double;
  public
    constructor Create(const ANome: string; const ASaldo: Double);
    destructor Destroy; override;
    procedure AdicionarLancamento(const AValor: Double);
    property Nome: string read GetNome;
    property Saldo: Double read GetSaldo;
    property Historico: TList<Double> read FHistorico;
  end;

constructor TCliente.Create(const ANome: string; const ASaldo: Double);
begin
  inherited Create;
  FNome := ANome;
  FSaldo := ASaldo;
  FHistorico := TList<Double>.Create;
end;

destructor TCliente.Destroy;
begin
  FHistorico.Free;
  inherited;
end;

procedure TCliente.AdicionarLancamento(const AValor: Double);
begin
  FSaldo := FSaldo + AValor;
  FHistorico.Add(AValor);
end;

function TCliente.GetNome: string;
begin
  Result := FNome;
end;

function TCliente.GetSaldo: Double;
begin
  Result := FSaldo;
end;

procedure InspecionarCliente(const ACliente: TCliente);
var
  I: Integer;
  Total: Double;
begin
  // === PARAR AQUI E ADICIONAR OS SEGUINTES WATCHES: ===
  //
  //   ACliente.Nome              → string da propriedade
  //   ACliente.Saldo             → saldo atual (Double)
  //   ACliente.Historico.Count   → quantos lancamentos
  //   Length(ACliente.FHistorico.ToArray)  → alternativa
  //   (TCliente(ACliente)).FNome → campo privado via cast
  //
  // No Class View: expandir "ACliente" para ver arvore completa de campos.
  // No Memory View: digitar @ACliente.FNome para ver bytes da string.

  Total := 0;
  for I := 0 to ACliente.Historico.Count - 1 do
  begin
    // === WATCH UTIL AQUI: ===
    //   I                          → iteracao atual
    //   ACliente.Historico[I]      → valor do lancamento
    //   Total                      → acumulador
    Total := Total + ACliente.Historico[I];
  end;

  WriteLn(Format('Cliente: %s | Saldo: %.2f | Lancamentos: %d | Soma historico: %.2f',
    [ACliente.Nome, ACliente.Saldo, ACliente.Historico.Count, Total]));
end;

var
  C: TCliente;
  Intf: ICliente;
begin
  WriteLn('=== Exemplo: Watches Avancados ===');
  WriteLn;

  C := TCliente.Create('Maria Silva', 1000.00);
  try
    C.AdicionarLancamento(500.00);
    C.AdicionarLancamento(-200.00);
    C.AdicionarLancamento(750.00);

    // Obter interface — watch util: (TCliente(Intf)).FSaldo
    Intf := C;

    // === WATCH UTIL AQUI ===
    // Intf — exibe o ponteiro da interface
    // (TCliente(Pointer(Intf)^)).FNome — acesso via ponteiro bruto (avancado)

    InspecionarCliente(C);

    WriteLn(Format('Via interface: Nome=%s  Saldo=%.2f', [Intf.Nome, Intf.Saldo]));
  finally
    Intf := nil;
    C.Free;
  end;

  WriteLn;
  WriteLn('OK -- developer-delphi-debugging-techniques :: watches_avancados');
end.

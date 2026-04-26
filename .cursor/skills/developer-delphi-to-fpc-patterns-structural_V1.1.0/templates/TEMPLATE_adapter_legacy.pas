unit TEMPLATE_adapter_legacy;
{
  TEMPLATE: Adapter de código legado para interface moderna
  ─────────────────────────────────────────────────────────
  Substituir:
    IModerno        → interface moderna que o código novo usa
    ILegado         → interface legada que não pode alterar
    TLegadoImpl     → implementação legada existente
    TAdapter        → adapter concreto
  ─────────────────────────────────────────────────────────
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// 1. Interface moderna — o contrato que o código novo espera
// ---------------------------------------------------------------------------
type
  TResultadoModerno = record
    Sucesso:  Boolean;
    Dados:    string;
    Erro:     string;
    function ToString: string;
  end;

  IModerno = interface
  ['{00000000-0000-0000-0000-000000000020}']  // gerar novo GUID
    function Executar(const AComando: string; const AParams: TArray<string>): TResultadoModerno;
    function Consultar(const AChave: string): string;
    function Listar: TArray<string>;
    procedure Configurar(const AChave, AValor: string);
  end;

// ---------------------------------------------------------------------------
// 2. Interface legada — código existente que não pode ser modificado
//    (pode ser uma DLL, COM object, terceiro, etc.)
// ---------------------------------------------------------------------------
type
  ILegado = interface
  ['{00000000-0000-0000-0000-000000000021}']
    // API legada com convenções diferentes (PChar, LongInt, etc.)
    function  DoCmd(ACmd: PAnsiChar; AParamStr: PAnsiChar): LongInt;
    function  GetValue(AKey: PAnsiChar): PAnsiChar;
    procedure SetParam(AKey: PAnsiChar; AVal: PAnsiChar);
    function  ListKeys: PAnsiChar;  // retorna CSV
  end;

// ---------------------------------------------------------------------------
// 3. Implementação legada (simulada — em produção já existe)
// ---------------------------------------------------------------------------
type
  TLegadoImpl = class(TInterfacedObject, ILegado)
  private
    FStore: TDictionary<string, string>;
    FLastList: AnsiString;  // buffer para PAnsiChar
  public
    constructor Create;
    destructor Destroy; override;
    function  DoCmd(ACmd: PAnsiChar; AParamStr: PAnsiChar): LongInt;
    function  GetValue(AKey: PAnsiChar): PAnsiChar;
    procedure SetParam(AKey: PAnsiChar; AVal: PAnsiChar);
    function  ListKeys: PAnsiChar;
  end;

// ---------------------------------------------------------------------------
// 4. Adapter — implementa IModerno, wraps ILegado
// ---------------------------------------------------------------------------
type
  TAdapter = class(TInterfacedObject, IModerno)
  private
    FLegado: ILegado;
    function JuntarParams(const AParams: TArray<string>): string;
    function InterpretarResultado(ACode: LongInt): TResultadoModerno;
  public
    constructor Create(ALegado: ILegado);
    // IModerno
    function Executar(const AComando: string; const AParams: TArray<string>): TResultadoModerno;
    function Consultar(const AChave: string): string;
    function Listar: TArray<string>;
    procedure Configurar(const AChave, AValor: string);
  end;

// Factory: cria o legado e o adapter juntos
function NovoServicoModerno: IModerno;

implementation

// ---------------------------------------------------------------------------
// TResultadoModerno
// ---------------------------------------------------------------------------

function TResultadoModerno.ToString: string;
begin
  if Sucesso then Result := 'OK: ' + Dados
  else Result := 'ERRO: ' + Erro;
end;

// ---------------------------------------------------------------------------
// TLegadoImpl (simulação — substitua pela real)
// ---------------------------------------------------------------------------

constructor TLegadoImpl.Create;
begin
  inherited Create;
  FStore := TDictionary<string, string>.Create;
  FStore.Add('versao', '1.0');
  FStore.Add('status', 'ativo');
end;

destructor TLegadoImpl.Destroy;
begin FStore.Free; inherited; end;

function TLegadoImpl.DoCmd(ACmd: PAnsiChar; AParamStr: PAnsiChar): LongInt;
var Cmd: string;
begin
  Cmd := string(ACmd);
  Writeln('[Legado] DoCmd: ', Cmd, ' params=', AParamStr);
  if Cmd = 'executar' then Result := 0   // 0 = sucesso
  else if Cmd = 'listar' then Result := 0
  else Result := -1;  // -1 = erro
end;

function TLegadoImpl.GetValue(AKey: PAnsiChar): PAnsiChar;
var V: string;
begin
  if FStore.TryGetValue(string(AKey), V) then
    Result := PAnsiChar(AnsiString(V))
  else
    Result := nil;
end;

procedure TLegadoImpl.SetParam(AKey: PAnsiChar; AVal: PAnsiChar);
begin FStore.AddOrSetValue(string(AKey), string(AVal)); end;

function TLegadoImpl.ListKeys: PAnsiChar;
var Keys: TArray<string>;
begin
  Keys := FStore.Keys.ToArray;
  FLastList := AnsiString(string.Join(',', Keys));
  Result := PAnsiChar(FLastList);
end;

// ---------------------------------------------------------------------------
// TAdapter
// ---------------------------------------------------------------------------

constructor TAdapter.Create(ALegado: ILegado);
begin inherited Create; FLegado := ALegado; end;

function TAdapter.JuntarParams(const AParams: TArray<string>): string;
begin Result := string.Join('|', AParams); end;

function TAdapter.InterpretarResultado(ACode: LongInt): TResultadoModerno;
begin
  Result.Sucesso := (ACode = 0);
  if Result.Sucesso then
    Result.Dados := 'Executado com sucesso'
  else
  begin
    Result.Erro := Format('Código de erro legado: %d', [ACode]);
    Result.Dados := '';
  end;
end;

function TAdapter.Executar(const AComando: string;
  const AParams: TArray<string>): TResultadoModerno;
var Codigo: LongInt;
begin
  // Converter: string moderna → PAnsiChar legada
  Codigo := FLegado.DoCmd(
    PAnsiChar(AnsiString(AComando)),
    PAnsiChar(AnsiString(JuntarParams(AParams))));
  Result := InterpretarResultado(Codigo);
end;

function TAdapter.Consultar(const AChave: string): string;
var P: PAnsiChar;
begin
  P := FLegado.GetValue(PAnsiChar(AnsiString(AChave)));
  if P <> nil then Result := string(AnsiString(P))
  else Result := '';
end;

function TAdapter.Listar: TArray<string>;
var CSV: string;
begin
  CSV := string(AnsiString(FLegado.ListKeys));
  if CSV = '' then Result := []
  else Result := CSV.Split([',']);
end;

procedure TAdapter.Configurar(const AChave, AValor: string);
begin
  FLegado.SetParam(
    PAnsiChar(AnsiString(AChave)),
    PAnsiChar(AnsiString(AValor)));
end;

function NovoServicoModerno: IModerno;
begin Result := TAdapter.Create(TLegadoImpl.Create); end;

// ---------------------------------------------------------------------------
// COMO USAR ESTE TEMPLATE
//
// 1. Substitua ILegado pela interface real do código legado (DLL, COM, etc.).
// 2. Substitua TLegadoImpl pelo objeto legado existente.
// 3. Em TAdapter, converta cada método: assinatura moderna → chamada legada.
//    Regra: toda conversão (tipos, encoding, convenções) fica no adapter.
// 4. O código cliente nunca vê ILegado — só IModerno.
//
// Uso:
//   var S := NovoServicoModerno;
//   S.Configurar('timeout', '30');
//   var R := S.Executar('executar', ['param1', 'param2']);
//   if R.Sucesso then Writeln(R.Dados)
//   else Writeln(R.Erro);
//   Writeln('Versão: ', S.Consultar('versao'));
//   for var K in S.Listar do Writeln('Chave: ', K);
//
// Injetar legado externo (DLL, etc.):
//   var LegadoDLL: ILegado := TDLLWrapperLegado.Create('legacy.dll');
//   var S: IModerno := TAdapter.Create(LegadoDLL);
// ---------------------------------------------------------------------------

end.

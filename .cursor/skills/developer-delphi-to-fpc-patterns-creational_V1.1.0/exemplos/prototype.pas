unit prototype;
{
  Prototype Pattern em Delphi — Clone via interface + cópia profunda
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Interface Prototype
// ---------------------------------------------------------------------------
type
  ICloneable = interface
  ['{PR000001-0000-0000-0000-000000000001}']
    function Clone: ICloneable;
  end;

// Versão tipada genérica para evitar casts
  ICloneableOf<T: ICloneable> = interface(ICloneable)
  ['{PR000002-0000-0000-0000-000000000002}']
    function TypedClone: T;
  end;

// ---------------------------------------------------------------------------
// Produto 1 — TEndereco (cópia profunda de record embutido)
// ---------------------------------------------------------------------------
type
  TEndereco = record
    Rua:     string;
    Cidade:  string;
    Estado:  string;
    CEP:     string;
    function ToString: string;
  end;

  IFicha = ICloneableOf<IFicha>;

  TFicha = class(TInterfacedObject, ICloneable, IFicha)
  private
    FNome:     string;
    FIdade:    Integer;
    FEndereco: TEndereco;
    FTags:     TList<string>;
  public
    constructor Create(const ANome: string; AIdade: Integer);
    destructor Destroy; override;
    // Prototype
    function Clone: ICloneable;
    function TypedClone: IFicha;
    // Configuração
    function SetEndereco(const ARua, ACidade, AEstado, ACEP: string): TFicha;
    procedure AdicionarTag(const ATag: string);
    function  ToString: string; override;
    // Acesso
    property Nome: string read FNome write FNome;
    property Idade: Integer read FIdade write FIdade;
  end;

// ---------------------------------------------------------------------------
// Produto 2 — TConfiguracaoRelatorio (template / protótipo de relatório)
// ---------------------------------------------------------------------------
type
  TRelatorioConfig = class(TInterfacedObject, ICloneable)
  private
    FTitulo:    string;
    FOrientacao:string;
    FMargem:    Integer;
    FColunas:   TStringList;
    FFiltros:   TDictionary<string, string>;
  public
    constructor Create(const ATitulo: string);
    destructor Destroy; override;
    function Clone: ICloneable;
    function AdicionarColuna(const ANome: string): TRelatorioConfig;
    function AdicionarFiltro(const AChave, AValor: string): TRelatorioConfig;
    function ComOrientacao(const AOri: string): TRelatorioConfig;
    function ComMargem(AMargens: Integer): TRelatorioConfig;
    function Descrever: string;
    property Titulo: string read FTitulo write FTitulo;
  end;

// ---------------------------------------------------------------------------
// Registro de protótipos — fábrica baseada em clones
// ---------------------------------------------------------------------------
type
  TPrototypeRegistry = class
  private
    FProtos: TDictionary<string, ICloneable>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Registrar(const ANome: string; AProto: ICloneable);
    function  Clonar(const ANome: string): ICloneable;
    function  Existe(const ANome: string): Boolean;
  end;

implementation

// ---------------------------------------------------------------------------
// TEndereco
// ---------------------------------------------------------------------------

function TEndereco.ToString: string;
begin Result := Format('%s, %s/%s (%s)', [Rua, Cidade, Estado, CEP]); end;

// ---------------------------------------------------------------------------
// TFicha
// ---------------------------------------------------------------------------

constructor TFicha.Create(const ANome: string; AIdade: Integer);
begin
  inherited Create;
  FNome  := ANome;
  FIdade := AIdade;
  FTags  := TList<string>.Create;
end;

destructor TFicha.Destroy;
begin FTags.Free; inherited; end;

function TFicha.Clone: ICloneable;
begin Result := TypedClone; end;

function TFicha.TypedClone: IFicha;
var Copia: TFicha;
    Tag: string;
begin
  Copia := TFicha.Create(FNome, FIdade);
  Copia.FEndereco := FEndereco;  // cópia de record (valor) — automática
  // cópia profunda da lista
  for Tag in FTags do
    Copia.FTags.Add(Tag);
  Result := Copia;
end;

function TFicha.SetEndereco(const ARua, ACidade, AEstado, ACEP: string): TFicha;
begin
  FEndereco.Rua    := ARua;
  FEndereco.Cidade := ACidade;
  FEndereco.Estado := AEstado;
  FEndereco.CEP    := ACEP;
  Result := Self;
end;

procedure TFicha.AdicionarTag(const ATag: string);
begin FTags.Add(ATag); end;

function TFicha.ToString: string;
var SB: TStringBuilder;
    Tag: string;
begin
  SB := TStringBuilder.Create;
  try
    SB.AppendFormat('Ficha[%s, %d anos]', [FNome, FIdade]);
    if FEndereco.Cidade <> '' then
      SB.AppendFormat(' end=%s', [FEndereco.ToString]);
    if FTags.Count > 0 then
    begin
      SB.Append(' tags=[');
      for Tag in FTags do SB.AppendFormat('%s,', [Tag]);
      SB.Append(']');
    end;
    Result := SB.ToString;
  finally SB.Free; end;
end;

// ---------------------------------------------------------------------------
// TRelatorioConfig
// ---------------------------------------------------------------------------

constructor TRelatorioConfig.Create(const ATitulo: string);
begin
  inherited Create;
  FTitulo     := ATitulo;
  FOrientacao := 'Portrait';
  FMargem     := 20;
  FColunas    := TStringList.Create;
  FFiltros    := TDictionary<string, string>.Create;
end;

destructor TRelatorioConfig.Destroy;
begin FColunas.Free; FFiltros.Free; inherited; end;

function TRelatorioConfig.Clone: ICloneable;
var Copia: TRelatorioConfig;
    K, C: string;
begin
  Copia := TRelatorioConfig.Create(FTitulo);
  Copia.FOrientacao := FOrientacao;
  Copia.FMargem     := FMargem;
  for C in FColunas do Copia.FColunas.Add(C);
  for K in FFiltros.Keys do Copia.FFiltros.Add(K, FFiltros[K]);
  Result := Copia;
end;

function TRelatorioConfig.AdicionarColuna(const ANome: string): TRelatorioConfig;
begin FColunas.Add(ANome); Result := Self; end;

function TRelatorioConfig.AdicionarFiltro(const AChave, AValor: string): TRelatorioConfig;
begin FFiltros.AddOrSetValue(AChave, AValor); Result := Self; end;

function TRelatorioConfig.ComOrientacao(const AOri: string): TRelatorioConfig;
begin FOrientacao := AOri; Result := Self; end;

function TRelatorioConfig.ComMargem(AMargens: Integer): TRelatorioConfig;
begin FMargem := AMargens; Result := Self; end;

function TRelatorioConfig.Descrever: string;
begin
  Result := Format('[Relat] %s | %s | margem=%d | cols=%d | filtros=%d',
    [FTitulo, FOrientacao, FMargem, FColunas.Count, FFiltros.Count]);
end;

// ---------------------------------------------------------------------------
// TPrototypeRegistry
// ---------------------------------------------------------------------------

constructor TPrototypeRegistry.Create;
begin inherited Create; FProtos := TDictionary<string, ICloneable>.Create; end;

destructor TPrototypeRegistry.Destroy;
begin FProtos.Free; inherited; end;

procedure TPrototypeRegistry.Registrar(const ANome: string; AProto: ICloneable);
begin FProtos.AddOrSetValue(ANome, AProto); end;

function TPrototypeRegistry.Clonar(const ANome: string): ICloneable;
var Proto: ICloneable;
begin
  if not FProtos.TryGetValue(ANome, Proto) then
    raise EArgumentException.CreateFmt('Protótipo "%s" não registrado', [ANome]);
  Result := Proto.Clone;
end;

function TPrototypeRegistry.Existe(const ANome: string): Boolean;
begin Result := FProtos.ContainsKey(ANome); end;

// ---------------------------------------------------------------------------
// USO:
//   // Clone direto
//   var Original := TFicha.Create('Alice', 30);
//   Original.SetEndereco('Rua A', 'São Paulo', 'SP', '01000-000');
//   Original.AdicionarTag('cliente');
//   var Copia := (Original.TypedClone as TFicha);
//   Copia.Nome := 'Bob';  // independente do original
//   Writeln(Original.ToString);
//   Writeln(Copia.ToString);
//
//   // Registry de protótipos (template factory)
//   var Reg := TPrototypeRegistry.Create;
//   var BaseRelat := TRelatorioConfig.Create('Relatório Base')
//     .AdicionarColuna('id').AdicionarColuna('nome').ComMargem(15);
//   Reg.Registrar('base', BaseRelat);
//   // Cria variante sem alterar o template
//   var R := Reg.Clonar('base') as TRelatorioConfig;
//   R.Titulo := 'Relatório Mensal';
//   R.AdicionarFiltro('mes', '04');
//   Writeln(R.Descrever);
// ---------------------------------------------------------------------------

end.

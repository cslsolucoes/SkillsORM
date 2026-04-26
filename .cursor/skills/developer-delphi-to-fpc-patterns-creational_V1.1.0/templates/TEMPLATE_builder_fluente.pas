unit TEMPLATE_builder_fluente;
{
  TEMPLATE: Builder Fluente com validação e terminador Build
  ──────────────────────────────────────────────────────────
  Substituir:
    TProduto      → struct/record do produto final
    IBuilder      → interface do builder
    TBuilder      → implementação do builder
    campos Fx     → campos do produto
  ──────────────────────────────────────────────────────────
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// 1. Produto — imutável após Build
// ---------------------------------------------------------------------------
type
  TProduto = record
    Nome:       string;
    Descricao:  string;
    Preco:      Currency;
    Quantidade: Integer;
    Tags:       TArray<string>;
    Ativo:      Boolean;
    function Descrever: string;
    function IsValid: Boolean;
  end;

// ---------------------------------------------------------------------------
// 2. Interface do Builder — fluent API declarada como contrato
// ---------------------------------------------------------------------------
type
  IBuilder = interface
  ['{00000000-0000-0000-0000-000000000002}']  // gerar novo GUID
    function WithNome(const ANome: string): IBuilder;
    function WithDescricao(const ADesc: string): IBuilder;
    function WithPreco(APreco: Currency): IBuilder;
    function WithQuantidade(AQtd: Integer): IBuilder;
    function WithTag(const ATag: string): IBuilder;
    function Active: IBuilder;
    function Inactive: IBuilder;
    function Build: TProduto;   // terminador — valida e constrói
    procedure Reset;            // reutilizar o mesmo builder
  end;

// ---------------------------------------------------------------------------
// 3. Implementação do Builder
// ---------------------------------------------------------------------------
type
  TBuilder = class(TInterfacedObject, IBuilder)
  private
    FNome:       string;
    FDescricao:  string;
    FPreco:      Currency;
    FQuantidade: Integer;
    FTags:       TList<string>;
    FAtivo:      Boolean;
    procedure Validar;
  public
    constructor Create;
    destructor Destroy; override;
    function WithNome(const ANome: string): IBuilder;
    function WithDescricao(const ADesc: string): IBuilder;
    function WithPreco(APreco: Currency): IBuilder;
    function WithQuantidade(AQtd: Integer): IBuilder;
    function WithTag(const ATag: string): IBuilder;
    function Active: IBuilder;
    function Inactive: IBuilder;
    function Build: TProduto;
    procedure Reset;
  end;

// Fábrica
function NewBuilder: IBuilder;

implementation

// ---------------------------------------------------------------------------
// TProduto
// ---------------------------------------------------------------------------

function TProduto.Descrever: string;
begin
  Result := Format('[%s] R$%.2f x%d %s',
    [Nome, Preco, Quantidade, IfThen(Ativo, 'ATIVO', 'INATIVO')]);
end;

function TProduto.IsValid: Boolean;
begin Result := (Nome <> '') and (Preco >= 0) and (Quantidade >= 0); end;

// ---------------------------------------------------------------------------
// TBuilder
// ---------------------------------------------------------------------------

constructor TBuilder.Create;
begin
  inherited Create;
  FTags := TList<string>.Create;
  Reset;
end;

destructor TBuilder.Destroy;
begin FTags.Free; inherited; end;

procedure TBuilder.Reset;
begin
  FNome := ''; FDescricao := ''; FPreco := 0;
  FQuantidade := 1; FAtivo := True; FTags.Clear;
end;

function TBuilder.WithNome(const ANome: string): IBuilder;
begin FNome := ANome; Result := Self; end;

function TBuilder.WithDescricao(const ADesc: string): IBuilder;
begin FDescricao := ADesc; Result := Self; end;

function TBuilder.WithPreco(APreco: Currency): IBuilder;
begin FPreco := APreco; Result := Self; end;

function TBuilder.WithQuantidade(AQtd: Integer): IBuilder;
begin FQuantidade := AQtd; Result := Self; end;

function TBuilder.WithTag(const ATag: string): IBuilder;
begin FTags.Add(ATag); Result := Self; end;

function TBuilder.Active: IBuilder;
begin FAtivo := True; Result := Self; end;

function TBuilder.Inactive: IBuilder;
begin FAtivo := False; Result := Self; end;

procedure TBuilder.Validar;
begin
  if FNome.Trim = '' then
    raise EInvalidOperation.Create('Builder: Nome é obrigatório');
  if FPreco < 0 then
    raise EInvalidOperation.CreateFmt('Builder: Preço inválido (%.2f)', [FPreco]);
  if FQuantidade < 0 then
    raise EInvalidOperation.CreateFmt('Builder: Quantidade inválida (%d)', [FQuantidade]);
end;

function TBuilder.Build: TProduto;
var I: Integer;
begin
  Validar;
  Result.Nome       := FNome;
  Result.Descricao  := FDescricao;
  Result.Preco      := FPreco;
  Result.Quantidade := FQuantidade;
  Result.Ativo      := FAtivo;
  SetLength(Result.Tags, FTags.Count);
  for I := 0 to FTags.Count - 1 do
    Result.Tags[I] := FTags[I];
end;

function NewBuilder: IBuilder;
begin Result := TBuilder.Create; end;

// ---------------------------------------------------------------------------
// COMO USAR ESTE TEMPLATE
//
// 1. Renomeie TProduto, IBuilder, TBuilder conforme o domínio.
// 2. Adicione campos necessários como propriedades With* / fluent.
// 3. Coloque TODA validação em Validar — nunca nos configuradores.
//
// Exemplo de uso:
//   var P := NewBuilder
//     .WithNome('Cadeira')
//     .WithPreco(299.90)
//     .WithQuantidade(5)
//     .WithTag('mobilia')
//     .WithTag('escritorio')
//     .Active
//     .Build;
//   Writeln(P.Descrever);
//   // [Cadeira] R$299,90 x5 ATIVO
//
// Reuso do builder:
//   var B := NewBuilder;
//   var P1 := B.WithNome('Mesa').WithPreco(450).Build;
//   B.Reset;
//   var P2 := B.WithNome('Sofá').WithPreco(1200).Build;
// ---------------------------------------------------------------------------

end.

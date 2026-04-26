# Estrutura de Classes — Delphi Style Guide

## 1. Ordem de Escopos de Visibilidade

Do mais restritivo ao menos restritivo:

```pascal
type
  TCliente = class(TInterfacedObject, ICliente)
  strict private
    // Fields — sempre aqui
    FNome: string;
    FIdade: Integer;
    FValorTotal: Currency;

  private
    // Getters e Setters
    procedure SetNome(const ANome: string);
    function GetNome: string;

  protected
    // Métodos acessíveis por subclasses
    function GetIdade: Integer; virtual;

  public
    // Interface pública
    constructor Create(const ANome: string; AIdade: Integer);
    destructor Destroy; override;

    procedure ProcessarPedido(const APedido: TPedido);
    function CalcularDesconto(const AValor: Currency): Currency;

    property Nome: string read GetNome write SetNome;
    property Idade: Integer read GetIdade;
    property ValorTotal: Currency read FValorTotal;

  published
    // Apenas para componentes registrados
  end;
```

## 2. Fields (Atributos)

- Sempre em `strict private` (preferencial) ou `private`
- Prefixo `F` obrigatório
- CamelCase após o prefixo
- NUNCA expostos diretamente — sempre via propriedades

```pascal
strict private
  FNome: string;           // ✅
  FValorTotal: Currency;   // ✅
  FAtivo: Boolean;         // ✅
```

## 3. Métodos

- Verbo no infinitivo: `Calcular`, `Validar`, `Salvar`, `Buscar`
- CamelCase
- Tamanho ideal: 20–30 linhas. Acima de 50: refatorar com Extract Method
- Uma responsabilidade por método (SRP)

```pascal
// ✅ Método focado
function TClienteService.CalcularDesconto(const AValor: Currency): Currency;
begin
  if AValor <= 0 then
    raise EArgumentoInvalido.Create('Valor deve ser maior que zero');

  Result := AValor * FPercentualDesconto / 100;
end;
```

## 4. Parâmetros

- Prefixo `A` obrigatório
- CamelCase após o prefixo
- Sem prefixo de tipo (`sNome`, `iCount` — proibido)
- `const` para `string`, `record`, `array` — sempre
- `const` para interfaces — NUNCA (quebra ARC)
- 3 parâmetros: tolerável. 4+: criar DTO

```pascal
// ✅ CORRETO
procedure ProcessarVenda(const ANome: string; AValor: Currency;
  AQuantidade: Integer);

// ❌ ERRADO — notação húngara, sem const
procedure ProcessarVenda(sNome: string; dValor: Double; iQtd: Integer);
```

## 5. Resultado de Functions

Escrever diretamente na variável `Result`:

```pascal
// ✅ CORRETO
function CalcularICMS(const ABase: Currency; const AAliquota: Double): Currency;
begin
  Result := ABase * AAliquota / 100;
end;

// ❌ ERRADO — variável auxiliar desnecessária
function CalcularICMS(const ABase: Currency; const AAliquota: Double): Currency;
var LValor: Currency;
begin
  LValor := ABase * AAliquota / 100;
  Result := LValor;
end;
```

## 6. Propriedades

- CamelCase sem prefixo
- Getter/Setter com prefixo `Get`/`Set`

```pascal
property Nome: string read GetNome write SetNome;
property ValorTotal: Currency read FValorTotal;  // somente leitura
property Ativo: Boolean read FAtivo write FAtivo; // sem getter/setter dedicado
```

## 7. Interfaces

- Prefixo `I` obrigatório
- Herdam de `IInterface`
- GUID gerado com Ctrl+Shift+G no Delphi IDE (NUNCA digitado manualmente)
- Classes implementadoras herdam de `TInterfacedObject`

```pascal
type
  IClienteService = interface
    ['{GUID-GERADO-PELO-IDE}']
    function BuscarPorCodigo(ACodigo: Integer): TCliente;
    procedure Salvar(const ACliente: TCliente);
  end;

  TClienteServiceFireDAC = class(TInterfacedObject, IClienteService)
  strict private
    FConexao: IDbConnection;
  public
    constructor Create(AConexao: IDbConnection);
    function BuscarPorCodigo(ACodigo: Integer): TCliente;
    procedure Salvar(const ACliente: TCliente);
  end;
```

## 8. DTOs (Data Transfer Objects)

Para métodos com 4+ parâmetros, agrupar em Record ou classe:

```pascal
type
  TDadosCliente = record
    Nome: string;
    CPF: string;
    Endereco: string;
    Cidade: string;
    UF: string;
  end;

// ✅ Com DTO — limpo
function CadastrarCliente(const ADados: TDadosCliente): Boolean;

// ❌ Políade — 5 parâmetros
function CadastrarCliente(ANome, ACPF, AEndereco, ACidade, AUF: string): Boolean;
```

## 9. Princípios SOLID

| Letra | Princípio | Aplicação em Delphi |
|---|---|---|
| S | Responsabilidade Única | Uma classe = um motivo para mudar |
| O | Aberto/Fechado | Herança e interfaces para extensão |
| L | Substituição de Liskov | Subclasses substituem a base sem quebrar |
| I | Segregação de Interface | Várias interfaces específicas > uma geral |
| D | Inversão de Dependência | Dependa de `IInterface`, não de `TClasse` |

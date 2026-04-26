# TCustomAttribute — Declarar, Aplicar e Ler

## Declarar um attribute

```pascal
// 1. Herdar de TCustomAttribute
type
  TRequiredAttribute = class(TCustomAttribute)
  private
    FMensagem: string;
  public
    constructor Create(const AMensagem: string = 'Campo obrigatório');
    property Mensagem: string read FMensagem;
  end;

// 2. Implementar
constructor TRequiredAttribute.Create(const AMensagem: string);
begin inherited Create; FMensagem := AMensagem; end;
```

## Aplicar attributes

```pascal
// Na classe
[TTable('clientes')]
TCliente = class
  // Na propriedade
  [TRequired('Nome é obrigatório')]
  [TMaxLength(100)]
  property Nome: string ...;

  // Sem parâmetros
  [TIgnore]
  property SenhaHash: string ...;

  // Múltiplos attributes empilhados
  [TRequired]
  [TColumn('email')]
  [TMaxLength(200)]
  property Email: string ...;
end;
```

## Ler attributes via RTTI

```pascal
uses System.Rtti;

var Ctx := TRttiContext.Create;
try
  // Atributos da CLASSE
  var Tipo := Ctx.GetType(TCliente);
  for var Attr in Tipo.GetAttributes do
    if Attr is TTableAttribute then
      Writeln((Attr as TTableAttribute).Nome);

  // Atributos de PROPRIEDADE
  var Prop := Tipo.GetProperty('Nome');
  for var Attr in Prop.GetAttributes do
  begin
    if Attr is TRequiredAttribute then
      Writeln('Required: ', (Attr as TRequiredAttribute).Mensagem);
    if Attr is TMaxLengthAttribute then
      Writeln('MaxLen: ', (Attr as TMaxLengthAttribute).MaxLen);
  end;

  // Atributos de MÉTODO
  var Metodo := Tipo.GetMethod('Salvar');
  for var Attr in Metodo.GetAttributes do
    Writeln(Attr.ClassName);
finally
  Ctx.Free;
end;
```

## Patterns de attributes comuns

```pascal
// Validação
TRequiredAttribute     → campo obrigatório
TMaxLengthAttribute    → tamanho máximo
TMinValueAttribute     → valor mínimo numérico
TRegexAttribute        → validação por regex

// ORM
TTableAttribute        → nome da tabela
TColumnAttribute       → nome da coluna + PK flag
TForeignKeyAttribute   → chave estrangeira
TIgnoreAttribute       → não mapear este campo

// Serialização JSON
TJsonPropertyAttribute → nome no JSON
TJsonIgnoreAttribute   → excluir do JSON
TJsonRequiredAttribute → obrigatório na deserialização

// DI (Injeção de Dependência)
TInjectAttribute       → marcar dependência a injetar
TSingletonAttribute    → escopo singleton
```

## Boas práticas

```pascal
// BOA PRÁTICA: suffix 'Attribute' — permite omitir no uso
type TRequiredAttribute = class(TCustomAttribute) ...

// No código:
[Required]       // sem 'Attribute' — Delphi aceita ambos
[TRequired]      // com prefixo T — também funciona

// NÃO herdar de outra coisa além de TCustomAttribute
// (ou de outro attribute custom)
type TMeuAttr = class(TCustomAttribute) ...  // OK
type TMeuAttr = class(TPersistent) ...       // NÃO faz um attribute!

// Attributes são instâncias reais — construtores com parâmetros
// DEVEM ter valores padrão ou sobrecarga sem parâmetros:
[TRequired]               // usa Create padrão
[TRequired('msg custom')] // usa Create com parâmetro
```

## Verificar existência de attribute

```pascal
function TemAttribute<T: TCustomAttribute>(ARtti: TRttiObject): Boolean;
var Attr: TCustomAttribute;
begin
  for Attr in ARtti.GetAttributes do
    if Attr is T then Exit(True);
  Result := False;
end;

// Uso:
if TemAttribute<TRequiredAttribute>(Prop) then
  Writeln('Prop ', Prop.Name, ' é obrigatória');
```

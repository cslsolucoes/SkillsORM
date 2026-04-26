unit attributes;
{
  RTTI — TCustomAttribute: declarar, aplicar e ler
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Rtti;

// ---------------------------------------------------------------------------
// Atributos customizados
// ---------------------------------------------------------------------------
type
  // Marcar campo/propriedade como obrigatória
  TRequiredAttribute = class(TCustomAttribute)
  private
    FMensagem: string;
  public
    constructor Create(const AMensagem: string = 'Campo obrigatório');
    property Mensagem: string read FMensagem;
  end;

  // Mapear propriedade para nome de coluna de banco de dados
  TColumnAttribute = class(TCustomAttribute)
  private
    FNome   : string;
    FPrimary: Boolean;
  public
    constructor Create(const ANome: string; APrimary: Boolean = False);
    property Nome   : string  read FNome;
    property Primary: Boolean read FPrimary;
  end;

  // Marcar classe como entidade de tabela
  TTableAttribute = class(TCustomAttribute)
  private
    FNome: string;
  public
    constructor Create(const ANome: string);
    property Nome: string read FNome;
  end;

  // Marcar propriedade como não mapeável (ignorar)
  TIgnoreAttribute = class(TCustomAttribute);

  // Definir tamanho máximo de um campo string
  TMaxLengthAttribute = class(TCustomAttribute)
  private
    FMaxLen: Integer;
  public
    constructor Create(AMaxLen: Integer);
    property MaxLen: Integer read FMaxLen;
  end;

// ---------------------------------------------------------------------------
// Classe de domínio decorada com atributos
// ---------------------------------------------------------------------------
type
  [TTable('clientes')]
  TClienteEntity = class
  private
    FId   : Integer;
    FNome : string;
    FEmail: string;
    FSenha: string;
  public
    [TColumn('id', True)]
    property Id: Integer read FId write FId;

    [TRequired('Nome é obrigatório')]
    [TColumn('nome')]
    [TMaxLength(100)]
    property Nome: string read FNome write FNome;

    [TRequired]
    [TColumn('email')]
    [TMaxLength(200)]
    property Email: string read FEmail write FEmail;

    [TIgnore]
    property Senha: string read FSenha write FSenha;
  end;

// ---------------------------------------------------------------------------
// Leitura de atributos via RTTI
// ---------------------------------------------------------------------------

// Validar objeto: retorna lista de erros baseada em TRequired
function ValidarObjeto(AInstance: TObject): TArray<string>;

// Obter nome de tabela (TTable attribute)
function ObterNomeTabela(AClass: TClass): string;

// Gerar SQL INSERT genérico via atributos TColumn/TIgnore
function GerarInsertSQL(AInstance: TObject): string;

implementation

// ---------------------------------------------------------------------------
// Atributos
// ---------------------------------------------------------------------------

constructor TRequiredAttribute.Create(const AMensagem: string);
begin inherited Create; FMensagem := AMensagem; end;

constructor TColumnAttribute.Create(const ANome: string; APrimary: Boolean);
begin inherited Create; FNome := ANome; FPrimary := APrimary; end;

constructor TTableAttribute.Create(const ANome: string);
begin inherited Create; FNome := ANome; end;

constructor TMaxLengthAttribute.Create(AMaxLen: Integer);
begin inherited Create; FMaxLen := AMaxLen; end;

// ---------------------------------------------------------------------------
// ValidarObjeto
// ---------------------------------------------------------------------------

function ValidarObjeto(AInstance: TObject): TArray<string>;
var
  Ctx   : TRttiContext;
  Tipo  : TRttiType;
  Prop  : TRttiProperty;
  Attr  : TCustomAttribute;
  Val   : TValue;
  Erros : TArray<string>;
  N     : Integer;
begin
  N := 0;
  SetLength(Erros, 32);
  Ctx := TRttiContext.Create;
  try
    Tipo := Ctx.GetType(AInstance.ClassType);
    for Prop in Tipo.GetProperties do
    begin
      for Attr in Prop.GetAttributes do
      begin
        if Attr is TRequiredAttribute then
        begin
          Val := Prop.GetValue(AInstance);
          if Val.IsEmpty or
             ((Val.Kind = tkUString) and (Val.AsString.Trim = '')) then
          begin
            if N < Length(Erros) then
            begin
              Erros[N] := (Attr as TRequiredAttribute).Mensagem + ' [' + Prop.Name + ']';
              Inc(N);
            end;
          end;
        end;
        if Attr is TMaxLengthAttribute then
        begin
          Val := Prop.GetValue(AInstance);
          if (Val.Kind = tkUString) and
             (Length(Val.AsString) > (Attr as TMaxLengthAttribute).MaxLen) then
          begin
            if N < Length(Erros) then
            begin
              Erros[N] := Format('%s excede o tamanho máximo de %d chars [%s]',
                [(Attr as TMaxLengthAttribute).MaxLen.ToString,
                 (Attr as TMaxLengthAttribute).MaxLen, Prop.Name]);
              Inc(N);
            end;
          end;
        end;
      end;
    end;
  finally
    Ctx.Free;
  end;
  SetLength(Erros, N);
  Result := Erros;
end;

// ---------------------------------------------------------------------------
// ObterNomeTabela
// ---------------------------------------------------------------------------

function ObterNomeTabela(AClass: TClass): string;
var
  Ctx  : TRttiContext;
  Tipo : TRttiType;
  Attr : TCustomAttribute;
begin
  Result := AClass.ClassName; // fallback
  Ctx := TRttiContext.Create;
  try
    Tipo := Ctx.GetType(AClass);
    for Attr in Tipo.GetAttributes do
      if Attr is TTableAttribute then
      begin
        Result := (Attr as TTableAttribute).Nome;
        Exit;
      end;
  finally
    Ctx.Free;
  end;
end;

// ---------------------------------------------------------------------------
// GerarInsertSQL
// ---------------------------------------------------------------------------

function GerarInsertSQL(AInstance: TObject): string;
var
  Ctx     : TRttiContext;
  Tipo    : TRttiType;
  Prop    : TRttiProperty;
  Attr    : TCustomAttribute;
  Tabela  : string;
  Cols    : TArray<string>;
  Vals    : TArray<string>;
  NC      : Integer;
  ColNome : string;
  Val     : TValue;
  Ignorar : Boolean;
  Primary : Boolean;
begin
  Tabela := ObterNomeTabela(AInstance.ClassType);
  NC := 0;
  SetLength(Cols, 32);
  SetLength(Vals, 32);

  Ctx := TRttiContext.Create;
  try
    Tipo := Ctx.GetType(AInstance.ClassType);
    for Prop in Tipo.GetProperties do
    begin
      if Prop.Visibility < mvPublic then Continue;
      Ignorar := False;
      Primary := False;
      ColNome := Prop.Name;
      for Attr in Prop.GetAttributes do
      begin
        if Attr is TIgnoreAttribute then begin Ignorar := True; Break; end;
        if Attr is TColumnAttribute then
        begin
          ColNome := (Attr as TColumnAttribute).Nome;
          Primary := (Attr as TColumnAttribute).Primary;
        end;
      end;
      if Ignorar or Primary then Continue;

      Val := Prop.GetValue(AInstance);
      Cols[NC] := ColNome;
      if Val.Kind in [tkUString, tkString] then
        Vals[NC] := QuotedStr(Val.AsString)
      else
        Vals[NC] := Val.ToString;
      Inc(NC);
    end;
  finally
    Ctx.Free;
  end;

  SetLength(Cols, NC);
  SetLength(Vals, NC);

  Result := Format('INSERT INTO %s (%s) VALUES (%s)',
    [Tabela,
     String.Join(', ', Cols),
     String.Join(', ', Vals)]);
end;

// ---------------------------------------------------------------------------
// USO:
//   var C := TClienteEntity.Create;
//   C.Id    := 1;
//   C.Nome  := 'Maria';
//   C.Email := 'maria@email.com';
//   C.Senha := 'secreta';  // ignorada no SQL
//
//   var Erros := ValidarObjeto(C);
//   if Length(Erros) = 0 then
//   begin
//     var SQL := GerarInsertSQL(C);
//     Writeln(SQL);
//     // INSERT INTO clientes (nome, email) VALUES ('Maria', 'maria@email.com')
//   end;
//
//   Writeln(ObterNomeTabela(TClienteEntity));  // clientes
//   C.Free;
// ---------------------------------------------------------------------------

end.

unit rtti_propriedades;
{
  RTTI — TRttiProperty: GetValue, SetValue, iteração
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Rtti;

// ---------------------------------------------------------------------------
// Objeto de domínio para demonstração
// ---------------------------------------------------------------------------
type
  TCliente = class
  private
    FId    : Integer;
    FNome  : string;
    FEmail : string;
    FAtivo : Boolean;
    FSaldo : Double;
  public
    constructor Create(AId: Integer; const ANome, AEmail: string;
      AAtivo: Boolean; ASaldo: Double);
    property Id   : Integer read FId    write FId;
    property Nome : string  read FNome  write FNome;
    property Email: string  read FEmail write FEmail;
    property Ativo: Boolean read FAtivo write FAtivo;
    property Saldo: Double  read FSaldo write FSaldo;
  end;

// ---------------------------------------------------------------------------
// Helpers RTTI para propriedades
// ---------------------------------------------------------------------------

// Ler valor de propriedade por nome
function LerPropriedade(AInstance: TObject; const ANomeProp: string): TValue;

// Gravar valor de propriedade por nome
procedure GravarPropriedade(AInstance: TObject; const ANomeProp: string;
  const AValor: TValue);

// Copiar propriedades de mesmo nome entre dois objetos (shallow copy)
procedure CopiarPropriedades(AOrigem, ADestino: TObject);

// Imprimir todas as propriedades de um objeto
procedure DumparObjeto(AInstance: TObject);

implementation

// ---------------------------------------------------------------------------
// TCliente
// ---------------------------------------------------------------------------

constructor TCliente.Create(AId: Integer; const ANome, AEmail: string;
  AAtivo: Boolean; ASaldo: Double);
begin
  inherited Create;
  FId    := AId;
  FNome  := ANome;
  FEmail := AEmail;
  FAtivo := AAtivo;
  FSaldo := ASaldo;
end;

// ---------------------------------------------------------------------------
// LerPropriedade
// ---------------------------------------------------------------------------

function LerPropriedade(AInstance: TObject; const ANomeProp: string): TValue;
var
  Ctx : TRttiContext;
  Tipo: TRttiType;
  Prop: TRttiProperty;
begin
  Ctx := TRttiContext.Create;
  try
    Tipo := Ctx.GetType(AInstance.ClassType);
    Prop := Tipo.GetProperty(ANomeProp);
    if Prop = nil then
      raise EArgumentException.CreateFmt('Propriedade "%s" não encontrada', [ANomeProp]);
    Result := Prop.GetValue(AInstance);
  finally
    Ctx.Free;
  end;
end;

// ---------------------------------------------------------------------------
// GravarPropriedade
// ---------------------------------------------------------------------------

procedure GravarPropriedade(AInstance: TObject; const ANomeProp: string;
  const AValor: TValue);
var
  Ctx : TRttiContext;
  Tipo: TRttiType;
  Prop: TRttiProperty;
begin
  Ctx := TRttiContext.Create;
  try
    Tipo := Ctx.GetType(AInstance.ClassType);
    Prop := Tipo.GetProperty(ANomeProp);
    if Prop = nil then
      raise EArgumentException.CreateFmt('Propriedade "%s" não encontrada', [ANomeProp]);
    if not Prop.IsWritable then
      raise EInvalidOpException.CreateFmt('Propriedade "%s" é somente leitura', [ANomeProp]);
    Prop.SetValue(AInstance, AValor);
  finally
    Ctx.Free;
  end;
end;

// ---------------------------------------------------------------------------
// CopiarPropriedades — copia propriedades writable com mesmo nome e tipo
// ---------------------------------------------------------------------------

procedure CopiarPropriedades(AOrigem, ADestino: TObject);
var
  Ctx      : TRttiContext;
  TipoOrig : TRttiType;
  TipoDest : TRttiType;
  PropOrig : TRttiProperty;
  PropDest : TRttiProperty;
  Valor    : TValue;
begin
  Ctx := TRttiContext.Create;
  try
    TipoOrig := Ctx.GetType(AOrigem.ClassType);
    TipoDest := Ctx.GetType(ADestino.ClassType);

    for PropOrig in TipoOrig.GetProperties do
    begin
      if PropOrig.Visibility < mvPublic then Continue;
      PropDest := TipoDest.GetProperty(PropOrig.Name);
      if (PropDest <> nil) and PropDest.IsWritable
        and (PropOrig.PropertyType = PropDest.PropertyType) then
      begin
        Valor := PropOrig.GetValue(AOrigem);
        PropDest.SetValue(ADestino, Valor);
      end;
    end;
  finally
    Ctx.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DumparObjeto
// ---------------------------------------------------------------------------

procedure DumparObjeto(AInstance: TObject);
var
  Ctx : TRttiContext;
  Tipo: TRttiType;
  Prop: TRttiProperty;
  Val : TValue;
begin
  Ctx := TRttiContext.Create;
  try
    Tipo := Ctx.GetType(AInstance.ClassType);
    Writeln('--- ', Tipo.Name, ' ---');
    for Prop in Tipo.GetProperties do
    begin
      if Prop.Visibility < mvPublic then Continue;
      Val := Prop.GetValue(AInstance);
      Writeln(Format('  %s = %s', [Prop.Name, Val.ToString]));
    end;
  finally
    Ctx.Free;
  end;
end;

// ---------------------------------------------------------------------------
// USO:
//   var C := TCliente.Create(1, 'Maria', 'maria@x.com', True, 1500.0);
//   DumparObjeto(C);
//
//   // Ler por nome
//   var Val := LerPropriedade(C, 'Nome');
//   Writeln(Val.AsString);  // Maria
//
//   // Gravar por nome
//   GravarPropriedade(C, 'Saldo', TValue.From<Double>(2000.0));
//   Writeln(C.Saldo);  // 2000.0
//
//   // Copiar entre instâncias
//   var C2 := TCliente.Create(0, '', '', False, 0);
//   CopiarPropriedades(C, C2);
//   // C2.Nome = 'Maria', C2.Email = 'maria@x.com', ...
//   C.Free; C2.Free;
// ---------------------------------------------------------------------------

end.

unit rtti_basico;
{
  RTTI em Delphi — TRttiContext, GetType, enumeração de membros
  Compilavel: dcc32 / dcc64
  Requer: System.Rtti
}

interface

uses
  System.SysUtils, System.Rtti, System.TypInfo;

// ---------------------------------------------------------------------------
// Classe de exemplo para inspeção via RTTI
// ---------------------------------------------------------------------------
type
  TPessoa = class
  private
    FNome : string;
    FIdade: Integer;
  public
    constructor Create(const ANome: string; AIdade: Integer);
    procedure Saudar;
    function  ToString: string; override;
    property Nome : string  read FNome  write FNome;
    property Idade: Integer read FIdade write FIdade;
  end;

// ---------------------------------------------------------------------------
// Utilitário: listar membros de qualquer classe via RTTI
// ---------------------------------------------------------------------------
procedure ListarPropriedades(AInstance: TObject);
procedure ListarMetodos(AInstance: TObject);
procedure InspecionarClasse(AClass: TClass);

implementation

// ---------------------------------------------------------------------------
// TPessoa
// ---------------------------------------------------------------------------

constructor TPessoa.Create(const ANome: string; AIdade: Integer);
begin
  inherited Create;
  FNome  := ANome;
  FIdade := AIdade;
end;

procedure TPessoa.Saudar;
begin
  Writeln(Format('Olá, sou %s e tenho %d anos.', [FNome, FIdade]));
end;

function TPessoa.ToString: string;
begin
  Result := Format('TPessoa{Nome=%s, Idade=%d}', [FNome, FIdade]);
end;

// ---------------------------------------------------------------------------
// ListarPropriedades — lê propriedades published + public via RTTI
// ---------------------------------------------------------------------------

procedure ListarPropriedades(AInstance: TObject);
var
  Ctx : TRttiContext;
  Tipo: TRttiType;
  Prop: TRttiProperty;
  Val : TValue;
begin
  Ctx  := TRttiContext.Create;
  try
    Tipo := Ctx.GetType(AInstance.ClassType);
    Writeln('=== Propriedades de ', Tipo.Name, ' ===');
    for Prop in Tipo.GetProperties do
    begin
      Val := Prop.GetValue(AInstance);
      Writeln(Format('  [%s] %s : %s = %s',
        [Prop.Visibility.ToString, Prop.Name,
         Prop.PropertyType.Name, Val.ToString]));
    end;
  finally
    Ctx.Free;
  end;
end;

// ---------------------------------------------------------------------------
// ListarMetodos — inspeciona métodos public/published via RTTI
// ---------------------------------------------------------------------------

procedure ListarMetodos(AInstance: TObject);
var
  Ctx    : TRttiContext;
  Tipo   : TRttiType;
  Metodo : TRttiMethod;
  Params : TArray<TRttiParameter>;
  Param  : TRttiParameter;
  ParStr : string;
begin
  Ctx := TRttiContext.Create;
  try
    Tipo := Ctx.GetType(AInstance.ClassType);
    Writeln('=== Métodos de ', Tipo.Name, ' ===');
    for Metodo in Tipo.GetMethods do
    begin
      if Metodo.Visibility < mvPublic then Continue;
      Params := Metodo.GetParameters;
      ParStr := '';
      for Param in Params do
      begin
        if ParStr <> '' then ParStr := ParStr + ', ';
        ParStr := ParStr + Param.Name + ': ' + Param.ParamType.Name;
      end;
      if Metodo.ReturnType <> nil then
        Writeln(Format('  function %s(%s): %s', [Metodo.Name, ParStr, Metodo.ReturnType.Name]))
      else
        Writeln(Format('  procedure %s(%s)', [Metodo.Name, ParStr]));
    end;
  finally
    Ctx.Free;
  end;
end;

// ---------------------------------------------------------------------------
// InspecionarClasse — info sobre hierarquia e interfaces implementadas
// ---------------------------------------------------------------------------

procedure InspecionarClasse(AClass: TClass);
var
  Ctx  : TRttiContext;
  Tipo : TRttiType;
  Base : TRttiType;
begin
  Ctx := TRttiContext.Create;
  try
    Tipo := Ctx.GetType(AClass);
    Writeln('=== Classe: ', Tipo.Name, ' ===');
    Writeln('  QualifiedName: ', Tipo.QualifiedName);

    Base := Tipo.BaseType;
    Write('  Hierarquia: ', Tipo.Name);
    while Base <> nil do
    begin
      Write(' -> ', Base.Name);
      Base := Base.BaseType;
    end;
    Writeln;
  finally
    Ctx.Free;
  end;
end;

// ---------------------------------------------------------------------------
// USO:
//   var P := TPessoa.Create('Maria', 30);
//   ListarPropriedades(P);
//   ListarMetodos(P);
//   InspecionarClasse(TPessoa);
//   P.Free;
// ---------------------------------------------------------------------------

end.

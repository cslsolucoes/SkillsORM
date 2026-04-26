unit visibility;
{
  EXEMPLO: Visibilidade em Delphi — private/protected/public/published/strict
  Compilavel: dcc32 / dcc64
  Demonstra:
    - Diferenca entre private e strict private
    - protected: acessivel em subclasses de qualquer unit
    - published: gera RTTI completo para o campo
    - Quando usar cada visibilidade
}

interface

uses
  System.SysUtils, System.TypInfo;

// ---------------------------------------------------------------------------
// Classe demonstrando todas as visibilidades
// ---------------------------------------------------------------------------
type
  TBase = class
  strict private
    // Acessivel SOMENTE por TBase — nem subclasses na mesma unit
    FSegredoAbsoluto: string;
    procedure MetodoEstritamentePrivado;

  private
    // Acessivel por TBase E qualquer classe na MESMA UNIT
    FPrivadoDaUnit: string;
    procedure MetodoPrivadoDaUnit;

  strict protected
    // Acessivel por TBase e subclasses de OUTRAS UNITS — mas nao por codigo na mesma unit
    FProtegidoEstrito: string;

  protected
    // Acessivel por TBase, subclasses (qualquer unit) e codigo na mesma unit
    FProtegido: string;
    procedure MetodoProtegido; virtual;

  public
    // Acessivel por todos
    constructor Create;
    procedure MetodoPublico;
    property Publico: string read FPrivadoDaUnit write FPrivadoDaUnit;

  published
    // Acessivel por todos + gera RTTI completo (usado por DFM, RTTI reflection)
    // Apenas property pode ser published (nao variaveis diretas)
    property PublishedProp: string read FProtegido write FProtegido;
  end;

type
  // Subclasse na MESMA UNIT
  TSubclasseNaMesmaUnit = class(TBase)
  public
    procedure Testar;
  end;

implementation

// ---------------------------------------------------------------------------
// TBase
// ---------------------------------------------------------------------------

constructor TBase.Create;
begin
  inherited Create;
  FSegredoAbsoluto := 'apenas TBase ve isso';
  FPrivadoDaUnit   := 'unit inteira ve isso';
  FProtegido       := 'subclasses veem isso';
  FProtegidoEstrito := 'subclasses externas veem isso';
end;

procedure TBase.MetodoEstritamentePrivado;
begin
  Writeln('strict private: ', FSegredoAbsoluto);
end;

procedure TBase.MetodoPrivadoDaUnit;
begin
  // Pode acessar strict private (ainda estamos em TBase)
  Writeln('private da unit: ', FPrivadoDaUnit);
  MetodoEstritamentePrivado;
end;

procedure TBase.MetodoProtegido;
begin
  Writeln('protected: ', FProtegido);
end;

procedure TBase.MetodoPublico;
begin
  // Pode acessar tudo
  Writeln(FSegredoAbsoluto);       // strict private: OK (estamos em TBase)
  Writeln(FPrivadoDaUnit);         // private: OK
  Writeln(FProtegido);             // protected: OK
  MetodoEstritamentePrivado;
  MetodoPrivadoDaUnit;
  MetodoProtegido;
end;

// ---------------------------------------------------------------------------
// TSubclasseNaMesmaUnit
// ---------------------------------------------------------------------------

procedure TSubclasseNaMesmaUnit.Testar;
begin
  // FSegredoAbsoluto: ERRO — strict private nao acessivel nem por subclasse
  // Writeln(FSegredoAbsoluto); // ERRO de compilacao

  Writeln(FPrivadoDaUnit);   // OK — mesma unit
  // FProtegidoEstrito: ERRO se for subclasse de outra unit, mas aqui e mesma unit
  // Na verdade strict protected e acessivel por subclasses de QUALQUER unit
  Writeln(FProtegidoEstrito); // OK — subclasse
  Writeln(FProtegido);        // OK — subclasse
  MetodoProtegido;            // OK — protected
end;

// ---------------------------------------------------------------------------
// Demonstrar RTTI em property published
// ---------------------------------------------------------------------------
procedure DemonstrarPublished;
var
  Obj: TBase;
  PropInfo: PPropInfo;
begin
  Obj := TBase.Create;
  try
    // published gera RTTI — posso inspecionar e modificar por nome
    PropInfo := GetPropInfo(TBase, 'PublishedProp');
    if Assigned(PropInfo) then
    begin
      SetStrProp(Obj, PropInfo, 'Valor via RTTI');
      Writeln('Via RTTI: ', GetStrProp(Obj, PropInfo));
    end;

    // Listar todas as properties published
    var PropList: PPropList;
    var Count := GetPropList(TBase.ClassInfo, tkAny, nil);
    GetMem(PropList, Count * SizeOf(PPropInfo));
    try
      GetPropList(TBase.ClassInfo, tkAny, PropList);
      for var I := 0 to Count - 1 do
        Writeln('  Property: ', PropList^[I]^.Name);
    finally
      FreeMem(PropList);
    end;
  finally
    Obj.Free;
  end;
end;

end.

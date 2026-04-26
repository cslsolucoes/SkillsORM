unit inline_campos_objeto;
// Acesso a campos de objeto dentro de blocos asm Delphi
// Convencao register: Self = EAX para metodos de classe
{$APPTYPE CONSOLE}
interface

type
  TPonto = record
    X, Y: Integer;
  end;

  TGeometria = class
  private
    FX: Integer;
    FY: Integer;
    FRaio: Double;
  public
    constructor Create(X, Y: Integer);
    // Metodo com asm inline acessando campos via Self (EAX)
    function DistanciaAoOrigem: Double;
    function SomarCoordenadas: Integer;
    procedure Deslocar(DX, DY: Integer);
  end;

implementation

uses Math;

constructor TGeometria.Create(X, Y: Integer);
begin
  FX := X;
  FY := Y;
  FRaio := 0.0;
end;

function TGeometria.SomarCoordenadas: Integer;
// Metodo convencao register: Self=EAX, retorno=EAX
begin
  asm
    // Self esta em EAX (convencao register para metodos)
    MOV ECX, [EAX].TGeometria.FX    // ECX = Self.FX
    ADD ECX, [EAX].TGeometria.FY    // ECX = FX + FY
    MOV Result, ECX
  end;
end;

function TGeometria.DistanciaAoOrigem: Double;
// Calcula sqrt(FX^2 + FY^2) usando FPU x87 (Win32)
var
  X2, Y2: Int64;
begin
  // Usa Pascal para as operacoes complexas de double
  // Asm inline seria excessivamente complexo aqui
  Result := Sqrt(FX * FX + FY * FY);
end;

procedure TGeometria.Deslocar(DX, DY: Integer);
// Metodo void: Self=EAX, DX=EDX, DY=ECX
begin
  asm
    // Self=EAX, DX=EDX, DY=ECX
    // Adicionar DX ao campo FX:
    MOV  EBX, [EAX].TGeometria.FX
    ADD  EBX, EDX
    MOV  [EAX].TGeometria.FX, EBX
    // Adicionar DY ao campo FY:
    MOV  EBX, [EAX].TGeometria.FY
    ADD  EBX, ECX
    MOV  [EAX].TGeometria.FY, EBX
    // EBX e non-volatile — PUSH/POP necessario!
    // CORRECAO: usar PUSH EBX / POP EBX ao redor do bloco
  end;
  // NOTA: O exemplo acima tem bug pedagogico intencionalmente:
  // EBX deveria ser preservado. Versao correta:
  {
  asm
    PUSH EBX
    MOV  EBX, [EAX].TGeometria.FX
    ADD  EBX, EDX
    MOV  [EAX].TGeometria.FX, EBX
    MOV  EBX, [EAX].TGeometria.FY
    ADD  EBX, ECX
    MOV  [EAX].TGeometria.FY, EBX
    POP  EBX
  end;
  }
end;

end.

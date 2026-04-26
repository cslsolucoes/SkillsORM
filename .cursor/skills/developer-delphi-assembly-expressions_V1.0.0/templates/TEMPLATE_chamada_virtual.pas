unit TEMPLATE_chamada_virtual;
// TEMPLATE: Chamada de metodo virtual via VMTOFFSET
// Substituir: TMinhaClasse, MeuMetodoVirtual
{$APPTYPE CONSOLE}
interface

type
  TMinhaClasse = class
  public
    // O metodo DEVE ser `virtual` para usar VMTOFFSET
    procedure MeuMetodoVirtual; virtual;
    function MeuMetodoFunc: Integer; virtual;
  end;

// Chamada via VMTOFFSET (asm direto)
procedure ChamarMetodoVirtual(Obj: TMinhaClasse);
function ChamarFuncaoVirtual(Obj: TMinhaClasse): Integer;

implementation

procedure TMinhaClasse.MeuMetodoVirtual;
begin
  WriteLn('MeuMetodoVirtual');
end;

function TMinhaClasse.MeuMetodoFunc: Integer;
begin
  Result := 0;
end;

procedure ChamarMetodoVirtual(Obj: TMinhaClasse);
// Equivale a: Obj.MeuMetodoVirtual;
// Mas via asm com VMTOFFSET (sem dispatch por nome em runtime)
begin
  asm
{$IFDEF WIN32}
    // Obj = EAX (convencao register, 1o param)
    MOV ECX, [EAX]        // ECX = ponteiro para VMT de Obj
    CALL DWORD PTR [ECX + VMTOFFSET TMinhaClasse.MeuMetodoVirtual]
    // NOTA: Self (EAX) e passado implicitamente pela convencao CALL
{$ENDIF WIN32}
{$IFDEF WIN64}
    // Obj = RCX (Win64, 1o param)
    MOV RAX, [RCX]        // RAX = ponteiro para VMT
    CALL QWORD PTR [RAX + VMTOFFSET TMinhaClasse.MeuMetodoVirtual]
{$ENDIF WIN64}
  end;
end;

function ChamarFuncaoVirtual(Obj: TMinhaClasse): Integer;
begin
  asm
{$IFDEF WIN32}
    MOV ECX, [EAX]
    CALL DWORD PTR [ECX + VMTOFFSET TMinhaClasse.MeuMetodoFunc]
    // Resultado em EAX (Integer)
{$ENDIF WIN32}
  end;
end;

end.

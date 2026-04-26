unit vmtoffset_virtual;
// Uso de VMTOFFSET para chamar metodos virtuais diretamente via VMT offset
// Evita overhead do dispatch por nome — util em hot paths
{$APPTYPE CONSOLE}
interface

type
  TAnimal = class
  public
    // Metodos VIRTUAIS — entram na VMT
    procedure FazerSom; virtual;
    function Descrever: string; virtual;
    function ContarPernas: Integer; virtual;
  end;

  TCao = class(TAnimal)
  public
    procedure FazerSom; override;
    function ContarPernas: Integer; override;
  end;

// Chamar FazerSom diretamente via VMTOFFSET (sem dispatch por nome)
procedure ChamarFazerSomDireto(Obj: TAnimal);

implementation

procedure TAnimal.FazerSom;
begin
  WriteLn('...');
end;

function TAnimal.Descrever: string;
begin
  Result := 'Animal';
end;

function TAnimal.ContarPernas: Integer;
begin
  Result := 0;
end;

procedure TCao.FazerSom;
begin
  WriteLn('Au au!');
end;

function TCao.ContarPernas: Integer;
begin
  Result := 4;
end;

procedure ChamarFazerSomDireto(Obj: TAnimal);
// Equivale a: Obj.FazerSom;
// Mas sem lookup por nome — usa offset fixo na VMT
begin
  asm
{$IFDEF WIN32}
    // Obj esta em EAX (convencao register, 1o param)
    // Estrutura do objeto:
    // [EAX+0] = ponteiro para VMT
    // [EAX+4] = ... campos do objeto ...

    // VMT layout:
    // [VMT + VMTOFFSET TAnimal.FazerSom] = ponteiro para FazerSom

    MOV ECX, [EAX]        // ECX = ponteiro para VMT do objeto
    CALL DWORD PTR [ECX + VMTOFFSET TAnimal.FazerSom]
    // Obs: Delphi gera exatamente este codigo para chamadas virtuais normais!
    // VMTOFFSET e util quando se quer garantir o offset sem criar instancia de objeto

    // ALTERNATIVA com objeto em variavel:
    // MOV EAX, Obj
    // MOV ECX, [EAX]
    // CALL [ECX + VMTOFFSET TAnimal.FazerSom]
{$ENDIF WIN32}
  end;
end;

end.

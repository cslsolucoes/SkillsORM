unit TEMPLATE_metodo_asm;
{
  TEMPLATE_metodo_asm.pas
  Template de método de objeto com acesso a Self e campos via assembly.

  INSTRUÇÕES DE USO:
  1. Copiar e renomear
  2. Substituir TMinhaClasse pelo nome da classe real
  3. Substituir FMeuCampo pelos campos reais
  4. Implementar a lógica no bloco asm

  REGRAS:
  - 32-bit: Self chega em EAX; salvar EAX em EBX se precisar de EAX para cálculos
  - 64-bit: Self chega em RCX; não destruir RCX antes de terminar de ler campos
  - Usar nome do campo na notação [EAX].TClasse.Campo — Delphi resolve o offset
  - Preservar EBX/RBX se usado (callee-saved)
}

{$APPTYPE CONSOLE}
program TEMPLATE_metodo_asm;

type
  TMinhaClasse = class
  private
    FMeuCampo: Integer;       // campo inteiro
    FOutroCampo: Integer;     // outro campo
  public
    constructor Create(Valor: Integer);
    function GetCampo: Integer;
    procedure SetCampo(Valor: Integer);
    function Calcular(Fator: Integer): Integer;
    procedure ImprimirCampos;
  end;

constructor TMinhaClasse.Create(Valor: Integer);
begin
  inherited Create;
  FMeuCampo   := Valor;
  FOutroCampo := Valor * 2;
end;

// ---------------------------------------------------------------------------
// Getter: retorna FMeuCampo
// 32-bit: EAX = Self → substituído pelo valor do campo
// 64-bit: RCX = Self → resultado em RAX
// ---------------------------------------------------------------------------
function TMinhaClasse.GetCampo: Integer;
asm
  {$IFDEF CPUX64}
    MOV EAX, [RCX].TMinhaClasse.FMeuCampo
  {$ELSE}
    MOV EAX, [EAX].TMinhaClasse.FMeuCampo
  {$ENDIF}
end;

// ---------------------------------------------------------------------------
// Setter: FMeuCampo := Valor
// 32-bit: EAX = Self, EDX = Valor
// 64-bit: RCX = Self, EDX = Valor (RDX na verdade, mas campo é Integer = 32-bit)
// ---------------------------------------------------------------------------
procedure TMinhaClasse.SetCampo(Valor: Integer);
asm
  {$IFDEF CPUX64}
    MOV [RCX].TMinhaClasse.FMeuCampo, EDX
  {$ELSE}
    MOV [EAX].TMinhaClasse.FMeuCampo, EDX
  {$ENDIF}
end;

// ---------------------------------------------------------------------------
// Método com parâmetro: multiplica FMeuCampo por Fator
// 32-bit: EAX = Self, EDX = Fator
// 64-bit: RCX = Self, EDX = Fator
// ---------------------------------------------------------------------------
function TMinhaClasse.Calcular(Fator: Integer): Integer;
asm
  {$IFDEF CPUX64}
    MOV  EAX, [RCX].TMinhaClasse.FMeuCampo  // EAX = FMeuCampo
    IMUL EAX, EDX                             // EAX = FMeuCampo * Fator
  {$ELSE}
    // EAX = Self, EDX = Fator
    PUSH EBX                                  // preservar EBX
    MOV  EBX, EAX                             // EBX = Self
    MOV  EAX, [EBX].TMinhaClasse.FMeuCampo   // EAX = FMeuCampo
    IMUL EAX, EDX                             // EAX = FMeuCampo * Fator
    POP  EBX                                  // restaurar EBX
  {$ENDIF}
end;

procedure TMinhaClasse.ImprimirCampos;
begin
  WriteLn('  FMeuCampo   = ', FMeuCampo);
  WriteLn('  FOutroCampo = ', FOutroCampo);
end;

var
  Obj: TMinhaClasse;

begin
  Obj := TMinhaClasse.Create(10);
  try
    WriteLn('=== Template Metodo ASM ===');
    Obj.ImprimirCampos;
    WriteLn('GetCampo() = ', Obj.GetCampo);
    WriteLn('Calcular(5) = ', Obj.Calcular(5));  // 50

    Obj.SetCampo(99);
    WriteLn('Após SetCampo(99): GetCampo() = ', Obj.GetCampo);
    WriteLn('Calcular(2) = ', Obj.Calcular(2));   // 198
  finally
    Obj.Free;
  end;
  ReadLn;
end.

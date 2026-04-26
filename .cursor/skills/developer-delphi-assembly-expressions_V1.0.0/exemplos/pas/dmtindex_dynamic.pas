unit dmtindex_dynamic;
// Uso de DMTINDEX para metodos `dynamic` em Delphi
// Metodos `dynamic` usam DMT (Dynamic Method Table) com indices negativos
// Diferente de `virtual` que usa VMT com offsets positivos
{$APPTYPE CONSOLE}
interface

type
  TBase = class
  public
    // Metodo VIRTUAL — entra na VMT (offset positivo)
    procedure MetodoVirtual; virtual;

    // Metodo DYNAMIC — entra na DMT (indice negativo unico)
    // Use `dynamic` para hierarquias onde poucos descendentes sobrescrevem o metodo
    // (economiza espaco na VMT de classes que nao sobrescrevem)
    procedure MetodoDynamic; dynamic;
    function MetodoDynFunc: Integer; dynamic;
  end;

implementation

procedure TBase.MetodoVirtual;
begin
  WriteLn('MetodoVirtual de TBase');
end;

procedure TBase.MetodoDynamic;
begin
  WriteLn('MetodoDynamic de TBase');
end;

function TBase.MetodoDynFunc: Integer;
begin
  Result := 42;
end;

// NOTA SOBRE DMTINDEX:
// DMTINDEX TBase.MetodoDynamic retorna um inteiro NEGATIVO
// Este valor e o indice na DMT do objeto para dispatch dinamico
//
// O dispatch dinamico e feito via System.@DynamicDispatch ou @CallDynaInst
// NAO e um simples CALL [VMT + offset] como nos metodos virtual!
//
// Uso pratico:
// asm
//   MOV EAX, DMTINDEX TBase.MetodoDynamic
//   // EAX = indice negativo
//   // Para chamar: precisa do sistema de dispatch do Delphi
// end;
//
// Em geral, prefira `virtual` sobre `dynamic` para codigo assembly —
// o dispatch virtual (VMTOFFSET) e mais simples e previsivel.

end.

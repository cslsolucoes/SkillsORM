unit TEMPLATE_acesso_campo;
// TEMPLATE: Acesso a campos de record/objeto via asm
// Substituir: TMinhaEstrutura, NomeCampo, tipo de operacao
{$APPTYPE CONSOLE}
interface

type
  TMinhaEstrutura = record
    Campo1: Integer;   // offset 0
    Campo2: Double;    // offset 4 (ou 8 com alinhamento)
    Campo3: Boolean;   // offset 12 (ou depois de Campo2)
  end;

// Ler campo de record via ponteiro
function LerCampo1(P: ^TMinhaEstrutura): Integer; assembler;

// Escrever em campo de record
procedure EscreverCampo1(P: ^TMinhaEstrutura; Valor: Integer);

implementation

function LerCampo1(P: ^TMinhaEstrutura): Integer; assembler;
// Win32: P=EAX (ponteiro para TMinhaEstrutura)
asm
  // Acesso pelo nome do campo (Delphi calcula o offset):
  MOV EAX, [EAX].TMinhaEstrutura.Campo1
  // Alternativa com DWORD PTR e offset manual:
  // MOV EAX, DWORD PTR [EAX + 0]  // Campo1 esta no offset 0
end;

procedure EscreverCampo1(P: ^TMinhaEstrutura; Valor: Integer);
// Win32: P=EAX, Valor=EDX
begin
  asm
    MOV [EAX].TMinhaEstrutura.Campo1, EDX
    // Alternativa:
    // MOV DWORD PTR [EAX], EDX
  end;
end;

end.

unit TEMPLATE_classe_base;
{
  TEMPLATE: Classe base com interface, factory method e ciclo de vida
  Uso: copie e renomeie. Substitua ENTIDADE.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils;

// ---------------------------------------------------------------------------
// Interface publica da entidade (contrato)
// ---------------------------------------------------------------------------
type
  IEntidade = interface
  ['{00000000-0000-0000-0000-000000000001}'] // substituir por GUID real: Ctrl+Shift+G
    function  GetId: Integer;
    function  GetNome: string;
    procedure SetNome(const AValor: string);
    function  EhValido: Boolean;
    function  Validar: string;
    property  Id  : Integer read GetId;
    property  Nome: string  read GetNome write SetNome;
  end;

// ---------------------------------------------------------------------------
// Classe base abstrata
// ---------------------------------------------------------------------------
type
  TEntidadeBase = class abstract(TInterfacedObject, IEntidade)
  private
    FId  : Integer;
    FNome: string;

    function  GetId: Integer;
    function  GetNome: string;
    procedure SetNome(const AValor: string);

  protected
    // Subclasse implementa validacao especifica
    function DoValidar: string; virtual; abstract;

    // Subclasse pode sobrescrever para logica adicional ao mudar nome
    procedure DoSetNome(const AValor: string); virtual;

  public
    // Factory: nao expor constructor diretamente
    constructor Create(AId: Integer; const ANome: string);

    function EhValido: Boolean;
    function Validar: string;

    property Id  : Integer read GetId;
    property Nome: string  read GetNome write SetNome;
  end;

// ---------------------------------------------------------------------------
// Implementacao concreta de exemplo
// ---------------------------------------------------------------------------
type
  TCliente = class(TEntidadeBase)
  private
    FEmail: string;
    FCPF  : string;
  protected
    function DoValidar: string; override;
  public
    class function Novo(AId: Integer; const ANome, AEmail, ACPF: string): IEntidade;
    property Email: string read FEmail write FEmail;
    property CPF  : string read FCPF   write FCPF;
  end;

implementation

// ---------------------------------------------------------------------------
// TEntidadeBase
// ---------------------------------------------------------------------------

constructor TEntidadeBase.Create(AId: Integer; const ANome: string);
begin
  inherited Create; // TInterfacedObject
  FId   := AId;
  FNome := ANome;
end;

function TEntidadeBase.GetId: Integer;   begin Result := FId;   end;
function TEntidadeBase.GetNome: string;  begin Result := FNome; end;

procedure TEntidadeBase.SetNome(const AValor: string);
begin
  DoSetNome(AValor);
end;

procedure TEntidadeBase.DoSetNome(const AValor: string);
begin
  FNome := AValor.Trim;
end;

function TEntidadeBase.EhValido: Boolean;
begin
  Result := Validar.IsEmpty;
end;

function TEntidadeBase.Validar: string;
begin
  Result := '';
  if FNome.Trim.IsEmpty then
    Result := Result + 'Nome e obrigatorio.' + sLineBreak;
  // Adicionar validacoes comuns da base aqui
  Result := Result + DoValidar;
end;

// ---------------------------------------------------------------------------
// TCliente
// ---------------------------------------------------------------------------

class function TCliente.Novo(AId: Integer; const ANome, AEmail, ACPF: string): IEntidade;
var
  C: TCliente;
begin
  C       := TCliente.Create(AId, ANome);
  C.FEmail := AEmail;
  C.FCPF   := ACPF;
  Result   := C; // retorna como interface — TInterfacedObject gerencia ciclo de vida
end;

function TCliente.DoValidar: string;
begin
  Result := '';
  if FEmail.Trim.IsEmpty then
    Result := Result + 'E-mail e obrigatorio.' + sLineBreak;
  if (not FEmail.IsEmpty) and (Pos('@', FEmail) = 0) then
    Result := Result + 'E-mail invalido.' + sLineBreak;
  if FCPF.Trim.IsEmpty then
    Result := Result + 'CPF e obrigatorio.' + sLineBreak;
end;

// ---------------------------------------------------------------------------
// USO:
//   var Cliente := TCliente.Novo(1, 'Maria', 'maria@email.com', '111.444.777-35');
//
//   if Cliente.EhValido then
//     FClienteRepo.Salvar(Cliente)
//   else
//     ShowMessage(Cliente.Validar);
//
//   // Trabalhar sempre pela interface:
//   procedure Processar(AEntidade: IEntidade);
//   begin
//     if AEntidade.EhValido then
//       // ...
//   end;
// ---------------------------------------------------------------------------

end.

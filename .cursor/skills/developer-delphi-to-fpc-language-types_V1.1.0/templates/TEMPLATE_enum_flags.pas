unit TEMPLATE_enum_flags;
{
  TEMPLATE: Enum + Set para flags bit-a-bit
  Uso: copie e renomeie. Substitua PERMISSAO.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.TypInfo;

// ---------------------------------------------------------------------------
// Enum de flags (cada valor = 1 bit)
// Convencao: prefixo perm*, flag*, opt*, etc.
// Max 8 valores para Byte, 16 para Word, 32 para LongWord
// ---------------------------------------------------------------------------
type
  TPermissao = (
    permLer      = 0,  // bit 0 = $01
    permGravar   = 1,  // bit 1 = $02
    permExcluir  = 2,  // bit 2 = $04
    permExportar = 3,  // bit 3 = $08
    permImportar = 4,  // bit 4 = $10
    permAdmin    = 5   // bit 5 = $20
  );
  TPermissoes = set of TPermissao;

// Conjunto de permissoes pre-definidos
const
  PERMS_NENHUMA  : TPermissoes = [];
  PERMS_SOMENTE_LEITURA : TPermissoes = [permLer];
  PERMS_OPERADOR : TPermissoes = [permLer, permGravar, permExcluir];
  PERMS_TOTAL    : TPermissoes = [permLer..permAdmin];

// Helper para converter set <-> Integer (persistencia em banco)
function PermissoesToInt(APerms: TPermissoes): Integer;
function IntToPermissoes(AInt: Integer): TPermissoes;
function PermissoesToStr(APerms: TPermissoes): string;

implementation

function PermissoesToInt(APerms: TPermissoes): Integer;
begin
  Result := 0;
  Move(APerms, Result, SizeOf(APerms));
end;

function IntToPermissoes(AInt: Integer): TPermissoes;
begin
  Result := [];
  Move(AInt, Result, SizeOf(Result));
end;

function PermissoesToStr(APerms: TPermissoes): string;
var
  P: TPermissao;
  Parts: TArray<string>;
begin
  Parts := [];
  for P := Low(TPermissao) to High(TPermissao) do
    if P in APerms then
    begin
      SetLength(Parts, Length(Parts) + 1);
      Parts[High(Parts)] := GetEnumName(TypeInfo(TPermissao), Ord(P));
    end;
  Result := '[' + String.Join(', ', Parts) + ']';
end;

// ---------------------------------------------------------------------------
// USO:
//
//   // Definir permissoes de um usuario
//   var Perms: TPermissoes := PERMS_OPERADOR;
//
//   // Verificar uma permissao
//   if permAdmin in Perms then
//     ShowMessage('Acesso admin liberado');
//
//   // Verificar multiplas
//   if [permLer, permGravar] <= Perms then
//     ExecutarOperacao;
//
//   // Adicionar permissao
//   Include(Perms, permExportar);
//
//   // Remover permissao
//   Exclude(Perms, permExportar);
//
//   // Persistir em banco (campo INTEGER)
//   var Bits := PermissoesToInt(Perms); // 7 = 0b00000111
//   Query.Params['perms'].AsInteger := Bits;
//
//   // Restaurar do banco
//   Perms := IntToPermissoes(Query.FieldByName('perms').AsInteger);
//
//   // Log
//   Writeln(PermissoesToStr(Perms)); // [permLer, permGravar, permExcluir]
// ---------------------------------------------------------------------------

end.

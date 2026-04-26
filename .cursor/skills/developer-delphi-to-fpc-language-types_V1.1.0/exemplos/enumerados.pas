unit enumerados;
{
  EXEMPLO: Enumerados e Sets em Delphi
  Compilavel: dcc32 / dcc64
  Demonstra:
    - Enum basico e com valor explicito
    - Set of Enum (flags bit a bit)
    - Operacoes em sets: inclusao, exclusao, uniao, intersecao
    - Ord/Low/High em enums
    - RTTI com enums: GetEnumName, GetEnumValue
    - Enum como mascara de bits (byte-sized)
}

interface

uses
  System.SysUtils, System.TypInfo;

// ---------------------------------------------------------------------------
// Enum basico (Ord: Seg=0, Ter=1, ...)
// ---------------------------------------------------------------------------
type
  TDiaSemana = (dsSeg, dsTer, dsQua, dsQui, dsSex, dsSab, dsDom);
  TDiasSemana = set of TDiaSemana;

// ---------------------------------------------------------------------------
// Enum com valores ordinais explicitados
// ---------------------------------------------------------------------------
type
  THttpStatus = (
    hsOK                  = 200,
    hsCreated             = 201,
    hsBadRequest          = 400,
    hsUnauthorized        = 401,
    hsForbidden           = 403,
    hsNotFound            = 404,
    hsInternalServerError = 500
  );

// ---------------------------------------------------------------------------
// Flags de permissao como set (cada bit = uma permissao)
// ---------------------------------------------------------------------------
type
  TPermissao = (
    permLer    = 0,  // bit 0 = 1
    permGravar = 1,  // bit 1 = 2
    permExcluir= 2,  // bit 2 = 4
    permAdmin  = 3   // bit 3 = 8
  );
  TPermissoes = set of TPermissao;

procedure DemonstrarEnumBasico;
procedure DemonstrarSets;
procedure DemonstrarPermissoes;
procedure DemonstrarRTTI;

implementation

procedure DemonstrarEnumBasico;
var
  Dia : TDiaSemana;
  D   : TDiaSemana;
begin
  Dia := dsSeg;

  // Valor ordinal
  Writeln('Ord(dsSeg) = ', Ord(dsSeg)); // 0
  Writeln('Ord(dsSab) = ', Ord(dsSab)); // 5

  // Range
  Writeln('Low  = ', Ord(Low(TDiaSemana)));  // 0 = dsSeg
  Writeln('High = ', Ord(High(TDiaSemana))); // 6 = dsDom

  // Iterar todos os valores
  for D := Low(TDiaSemana) to High(TDiaSemana) do
    Write(Ord(D), ' '); // 0 1 2 3 4 5 6
  Writeln;

  // Inc/Dec em enum
  Dia := dsSeg;
  Inc(Dia); // Dia = dsTer
  Dec(Dia); // Dia = dsSeg

  // Pred/Succ
  Writeln(Ord(Succ(dsSeg))); // 1 = dsTer
  Writeln(Ord(Pred(dsSab))); // 4 = dsSex

  // Case com enum (compilador avisa sobre valores nao cobertos)
  case Dia of
    dsSeg..dsSex: Writeln('Dia util');
    dsSab, dsDom: Writeln('Fim de semana');
  end;

  // THttpStatus: valores nao-sequenciais
  var Status := THttpStatus.hsOK;
  Writeln('HTTP OK = ', Ord(Status)); // 200
end;

procedure DemonstrarSets;
var
  DiasUteis  : TDiasSemana;
  FimSemana  : TDiasSemana;
  TodosDias  : TDiasSemana;
  Intersecao : TDiasSemana;
begin
  // Construir sets literais
  DiasUteis := [dsSeg, dsTer, dsQua, dsQui, dsSex];
  FimSemana := [dsSab, dsDom];

  // Verificar pertencimento
  if dsSeg in DiasUteis then Writeln('Segunda e dia util');

  // Uniao (OR)
  TodosDias := DiasUteis + FimSemana;

  // Intersecao (AND)
  Intersecao := DiasUteis * [dsQua, dsQui, dsSab]; // [dsQua, dsQui]

  // Diferenca
  var SemSegunda := DiasUteis - [dsSeg]; // remove Segunda

  // Adicionar/remover elemento
  Include(DiasUteis, dsSab);  // adiciona Sabado
  Exclude(DiasUteis, dsSab);  // remove Sabado

  // Verificar se set e subconjunto de outro
  if [dsQua] <= DiasUteis then
    Writeln('Quarta esta nos dias uteis');

  // Comparar sets
  if DiasUteis = [dsSeg..dsSex] then
    Writeln('Dias uteis completos');

  // Tamanho de um set em bytes: dependente do High(enum)
  // Set of (0..7) = 1 byte, (0..15) = 2 bytes, (0..31) = 4 bytes
  Writeln('SizeOf(TDiasSemana) = ', SizeOf(TDiasSemana)); // 1 byte (7 valores)
end;

procedure DemonstrarPermissoes;
var
  Perms: TPermissoes;
begin
  // Nenhuma permissao
  Perms := [];

  // Conceder permissoes
  Include(Perms, permLer);
  Include(Perms, permGravar);
  // Perms = [permLer, permGravar]

  // Verificar
  if permAdmin in Perms then
    Writeln('Tem permissao de admin')
  else
    Writeln('Sem permissao de admin');

  // Permissao total
  var Admin: TPermissoes := [permLer, permGravar, permExcluir, permAdmin];

  // Verificar se tem TODAS as permissoes requeridas
  if [permLer, permGravar] <= Perms then
    Writeln('Pode ler e gravar');

  // Converter set para integer (para salvar em banco)
  // Cada TPermissao ocupa 1 bit: permLer=bit0, permGravar=bit1, etc.
  // Para byte (set com ate 8 elementos):
  var Bits: Byte;
  Move(Perms, Bits, SizeOf(Bits));
  Writeln('Bits = ', Bits); // 3 = 0b00000011

  // Reconstruir set de integer
  Move(Bits, Perms, SizeOf(Perms));
end;

procedure DemonstrarRTTI;
begin
  // Obter nome do enum via RTTI (sem usar {$M+} — TypInfo sempre disponivel)
  Writeln(GetEnumName(TypeInfo(TDiaSemana), Ord(dsSeg))); // 'dsSeg'
  Writeln(GetEnumName(TypeInfo(TDiaSemana), 4));          // 'dsSex'

  // Converter string para enum
  var V := GetEnumValue(TypeInfo(TDiaSemana), 'dsQua');
  if V >= 0 then
    Writeln('dsQua = ', V); // 2

  // Valor invalido
  V := GetEnumValue(TypeInfo(TDiaSemana), 'dsXYZ');
  Writeln('Invalido = ', V); // -1
end;

end.

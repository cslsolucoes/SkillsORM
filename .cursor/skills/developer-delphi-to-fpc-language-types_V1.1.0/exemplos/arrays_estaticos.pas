unit arrays_estaticos;
{
  EXEMPLO: Arrays estaticos em Delphi
  Compilavel: dcc32 / dcc64
  Demonstra:
    - array[N..M] de T: declaracao e acesso
    - Low, High, Length em arrays estaticos
    - Arrays multidimensionais
    - Passar arrays para funcoes (const, var, open array)
    - Inicializacao com valores literais
    - SizeOf e acesso via ponteiro
}

interface

uses
  System.SysUtils;

procedure DemonstrarArrayBasico;
procedure DemonstrarMultidimensional;
procedure DemonstrarOpenArray;
procedure DemonstrarMemoria;

implementation

type
  // Tipo nomeado de array (preferido para reutilizacao)
  T10Inteiros = array[0..9]  of Integer;
  TMatriz3x3  = array[0..2, 0..2] of Double;

  // Array com indice nao-zero
  TNotaAlunos = array[1..40] of Byte; // notas de 40 alunos (indice 1..40)

procedure DemonstrarArrayBasico;
var
  A: array[0..4] of Integer;
  B: T10Inteiros;
  N: TNotaAlunos;
  I: Integer;
begin
  // Preencher
  for I := Low(A) to High(A) do
    A[I] := I * 2; // 0, 2, 4, 6, 8

  // Low/High corretos independente do indice base
  Writeln('Low(A)  = ', Low(A));  // 0
  Writeln('High(A) = ', High(A)); // 4
  Writeln('Length(A) = ', Length(A)); // 5

  // Array com indice baseado em 1
  for I := Low(N) to High(N) do
    N[I] := I * 2; // N[1]=2, N[2]=4, ...
  Writeln('Low(N)  = ', Low(N));  // 1
  Writeln('High(N) = ', High(N)); // 40

  // Inicializacao com literais (Delphi 10.3+)
  B := T10Inteiros.Create(10, 20, 30, 40, 50, 60, 70, 80, 90, 100);
  Writeln('B[0] = ', B[0]); // 10

  // Atribuicao de arrays do mesmo tipo (copia completa)
  var C: T10Inteiros := B;
  C[0] := 999; // nao afeta B

  // ERRO: nao se pode atribuir tipos anonimos diferentes
  // A := B; // ERRO — tipos distintos (mesmo que com mesmo tamanho)
end;

procedure DemonstrarMultidimensional;
var
  M: TMatriz3x3;
  L, C: Integer;
  Identidade: TMatriz3x3;
begin
  // Preencher
  for L := 0 to 2 do
    for C := 0 to 2 do
      M[L, C] := L * 3 + C; // M[0,0]=0 M[0,1]=1 ... M[2,2]=8

  // Acessar elemento
  Writeln('M[1,2] = ', M[1, 2]:4:2); // 5.0

  // Matriz identidade
  for L := 0 to 2 do
    for C := 0 to 2 do
      Identidade[L, C] := IfThen(L = C, 1.0, 0.0);

  // SizeOf de matriz
  Writeln('SizeOf(TMatriz3x3) = ', SizeOf(TMatriz3x3)); // 72 = 9 * 8

  // Dimensoes
  Writeln('Linhas   = ', Length(M));    // 3
  Writeln('Colunas  = ', Length(M[0])); // 3
end;

// Open array: aceita array de qualquer tamanho do mesmo tipo base
function SomarElementos(const A: array of Integer): Int64;
var
  I: Integer;
begin
  Result := 0;
  for I := Low(A) to High(A) do
    Inc(Result, A[I]);
end;

function MediaElementos(const A: array of Double): Double;
begin
  if Length(A) = 0 then
    Result := 0
  else
  begin
    var Soma: Double := 0;
    for var V in A do
      Soma := Soma + V;
    Result := Soma / Length(A);
  end;
end;

procedure DemonstrarOpenArray;
var
  X: array[0..4] of Integer;
  Y: array[1..10] of Integer;
  I: Integer;
begin
  for I := Low(X) to High(X) do X[I] := I + 1;
  for I := Low(Y) to High(Y) do Y[I] := I;

  // Open array aceita qualquer tamanho
  Writeln('Soma X = ', SomarElementos(X)); // 15
  Writeln('Soma Y = ', SomarElementos(Y)); // 55

  // Construtor de array anonimo passado diretamente
  Writeln('Soma literal = ', SomarElementos([10, 20, 30])); // 60

  // Media de doubles
  Writeln('Media = ', MediaElementos([1.5, 2.5, 3.0]):4:2); // 2.33
end;

procedure DemonstrarMemoria;
var
  A: array[0..4] of Integer;
  P: PInteger;
  I: Integer;
begin
  for I := 0 to 4 do A[I] := I * 10;

  // Ponteiro para primeiro elemento
  P := @A[0]; // ou: P := PInteger(@A);

  // Percorrer via ponteiro (aritmetica de ponteiro)
  for I := 0 to 4 do
  begin
    Writeln(P^);        // acessar valor
    Inc(P);             // avancar um Integer (4 bytes)
  end;

  // SizeOf
  Writeln('SizeOf(array[0..4] of Integer) = ', SizeOf(A)); // 20 = 5 * 4

  // Array e armazenado contiguamente na stack (arrays estaticos)
  // Os elementos estao em enderecos consecutivos
  P := @A[0];
  Writeln(Format('A[0] em %p, A[1] em %p', [@A[0], @A[1]]));
  // Diferenca = SizeOf(Integer) = 4
end;

end.

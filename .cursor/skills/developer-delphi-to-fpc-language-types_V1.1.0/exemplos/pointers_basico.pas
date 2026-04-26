unit pointers_basico;
{
  EXEMPLO: Ponteiros em Delphi — uso seguro
  Compilavel: dcc32 / dcc64
  Demonstra:
    - Pointer, PInteger, PByte, PChar, PWideChar
    - New/Dispose para alocacao tipada
    - @-operador e ^ (dereference)
    - nil check obrigatorio
    - GetMem/FreeMem para blocos de tamanho arbitrario
    - Quando usar ponteiros vs tipos gerenciados
}

interface

uses
  System.SysUtils;

procedure DemonstrarPonteirosBasicos;
procedure DemonstrarNewDispose;
procedure DemonstrarGetMem;
procedure DemonstrarPonteirosParaRecord;

implementation

procedure DemonstrarPonteirosBasicos;
var
  I  : Integer;
  PI : PInteger;   // ponteiro para Integer
  PB : PByte;      // ponteiro para Byte
  PV : Pointer;    // ponteiro generico (sem tipo)
begin
  I  := 42;

  // Obter endereco de variavel
  PI := @I;        // PI aponta para I

  // Dereferenciar (acessar valor via ponteiro)
  Writeln('Via ponteiro: ', PI^);   // 42

  // Modificar via ponteiro
  PI^ := 100;
  Writeln('I apos modificar via ponteiro: ', I); // 100

  // Aritmetica de ponteiros com Inc/Dec
  var A: array[0..4] of Integer := [10, 20, 30, 40, 50];
  PI := @A[0];
  Writeln(PI^); // 10
  Inc(PI);      // avanca SizeOf(Integer) bytes = 4
  Writeln(PI^); // 20
  Inc(PI, 2);   // avanca 2 * SizeOf(Integer) = 8
  Writeln(PI^); // 40

  // Ponteiro generico: nao pode ser dereferenciado diretamente
  PV := @I;
  // Writeln(PV^); // ERRO: Pointer nao tem tipo para dereferenciar
  PI := PInteger(PV); // cast para tipo especifico antes de dereferenciar
  Writeln(PI^);

  // nil: ponteiro invalido (sempre verificar antes de dereferenciar)
  PI := nil;
  if PI <> nil then
    Writeln(PI^) // seguro
  else
    Writeln('Ponteiro nulo'); // cai aqui
end;

procedure DemonstrarNewDispose;
type
  TProduto = record
    Codigo: Integer;
    Nome  : string;
    Preco : Double;
  end;
  PProduto = ^TProduto;

var
  P: PProduto;
begin
  // New: aloca memoria para um TProduto e retorna ponteiro tipado
  New(P);
  try
    // Preencher campos via ponteiro
    P^.Codigo := 1;
    P^.Nome   := 'Teclado';
    P^.Preco  := 250.0;

    // Alternativa: usar With para evitar P^ repetido
    with P^ do
    begin
      Codigo := 2;
      Nome   := 'Mouse';
      Preco  := 150.0;
    end;

    Writeln('Produto: ', P^.Nome, ' R$', P^.Preco:6:2);

  finally
    // Dispose: libera a memoria alocada por New
    Dispose(P); // P aponta para lixo apos isso
    P := nil;   // boa pratica: nilificar para evitar dangling pointer
  end;

  // ATENCAO: nao use Dispose em ponteiro nao alocado com New
  // nao use New para arrays — use SetLength
end;

procedure DemonstrarGetMem;
var
  P   : PByte;
  Tam : Integer;
begin
  Tam := 1024; // 1 KB de buffer

  // GetMem: aloca bloco de bytes sem inicializar
  GetMem(P, Tam);
  try
    // Inicializar com zero
    FillChar(P^, Tam, 0);

    // Usar como buffer de bytes
    P[0] := $42;
    P[1] := $FF;
    Writeln(Format('Byte[0] = $%2.2X', [P[0]])); // $42

    // Copiar bloco
    var Q: PByte;
    GetMem(Q, Tam);
    try
      Move(P^, Q^, Tam); // copia Tam bytes de P para Q
      Writeln(Format('Q[0] = $%2.2X', [Q[0]])); // $42
    finally
      FreeMem(Q, Tam);
      Q := nil;
    end;

  finally
    FreeMem(P, Tam); // libera exatamente o que foi alocado
    P := nil;
  end;
end;

type
  TNo = record
    Valor: Integer;
    Proximo: ^TNo; // ponteiro para o proprio tipo (lista encadeada)
  end;
  PNo = ^TNo;

procedure DemonstrarPonteirosParaRecord;
var
  Primeiro, Segundo, Terceiro, Atual: PNo;
begin
  // Construir lista encadeada simples
  New(Primeiro);  Primeiro^.Valor := 10; Primeiro^.Proximo := nil;
  New(Segundo);   Segundo^.Valor  := 20; Segundo^.Proximo  := nil;
  New(Terceiro);  Terceiro^.Valor := 30; Terceiro^.Proximo := nil;

  Primeiro^.Proximo := Segundo;
  Segundo^.Proximo  := Terceiro;

  // Percorrer
  Atual := Primeiro;
  while Atual <> nil do
  begin
    Writeln(Atual^.Valor);
    Atual := Atual^.Proximo;
  end;
  // Saida: 10, 20, 30

  // Liberar (de tras para frente nao e necessario aqui,
  // mas e boa pratica se houver referencias reversas)
  Dispose(Primeiro);
  Dispose(Segundo);
  Dispose(Terceiro);
end;

// ---------------------------------------------------------------------------
// QUANDO USAR PONTEIROS vs TIPOS GERENCIADOS
//
//   Usar ponteiros:
//   - Integrar com APIs C/WinAPI que esperam void*, LPBYTE, etc.
//   - Estruturas de dados de baixo nivel (lista encadeada, arvore)
//   - Aritmetica de ponteiro para performance critica
//   - Buffers binarios (GetMem/Move/FillChar)
//
//   EVITAR ponteiros quando ha alternativa gerenciada:
//   - Use TArray<T> em vez de GetMem + PByte para arrays
//   - Use TList<T> em vez de lista encadeada manual
//   - Use classes em vez de New/Dispose para objetos com ciclo de vida
// ---------------------------------------------------------------------------

end.

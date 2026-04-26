# Fundamentos da Linguagem Object Pascal

## Estrutura de programa/unit

```pascal
program NomeProjeto;       // executável
{$APPTYPE CONSOLE}
uses System.SysUtils;
begin
  Writeln('Olá');
end.

// OU

unit MinhaUnit;            // unit reutilizável
interface
  // declarações públicas

implementation
  // implementações

initialization
  // código executado ao carregar a unit (opcional)

finalization
  // código executado ao descarregar (opcional)
end.
```

## Tipos primitivos essenciais

```pascal
// Inteiros
var I: Integer;    // 32-bit signed: -2.1G..2.1G
var N: Int64;      // 64-bit signed
var U: Cardinal;   // 32-bit unsigned
var B: Byte;       // 8-bit unsigned: 0..255

// Ponto flutuante
var F: Single;     // 32-bit IEEE 754
var D: Double;     // 64-bit IEEE 754
var M: Currency;   // 64-bit fixed-point para dinheiro

// Texto
var S: string;     // UnicodeString (Delphi 2009+)
var C: Char;       // WideChar (2 bytes)

// Lógico
var Ok: Boolean;   // True / False

// Plataforma
var P: NativeInt;  // 32-bit em Win32, 64-bit em Win64
```

## Controle de fluxo

```pascal
// if / then / else
if Condicao then
  Acao1
else if OutraCondicao then
  Acao2
else
  Acao3;

// case / of
case Valor of
  1: Writeln('um');
  2, 3: Writeln('dois ou três');
  4..9: Writeln('quatro a nove');
else
  Writeln('outro');
end;

// for clássico
for I := 1 to 10 do Writeln(I);
for I := 10 downto 1 do Writeln(I);

// for-in (enumeração)
for var S in Lista do Writeln(S);

// while
while Condicao do Acao;

// repeat..until
repeat
  Acao;
until Condicao;  // executa pelo menos uma vez
```

## Blocos e exceções

```pascal
// begin..end — bloco de comandos
begin
  Comando1;
  Comando2;
end;

// try..finally — garantia de execução (cleanup)
var Obj := TStringList.Create;
try
  Obj.Add('item');
finally
  Obj.Free;  // sempre executado, mesmo em exceção
end;

// try..except — captura de exceção
try
  OperacaoArriscada;
except
  on E: EMinhaExcecao do
    Writeln('Minha: ', E.Message);
  on E: Exception do
    Writeln('Geral: ', E.Message);
end;

// raise — lançar exceção
raise EArgumentException.Create('Argumento inválido');
raise;  // relançar a exceção atual (dentro de except)
```

## Procedures e functions

```pascal
// Procedure — sem retorno
procedure FazerAlgo(AParam: Integer);
begin
  Writeln(AParam);
end;

// Function — com retorno
function Somar(A, B: Integer): Integer;
begin
  Result := A + B;
end;

// Passagem por referência
procedure Incrementar(var AValor: Integer);
begin Inc(AValor); end;

// Passagem somente leitura (const — mais rápido para strings/records)
function ComprimirNome(const ANome: string): string;
begin Result := ANome.Trim; end;

// Parâmetro de saída (out — não inicializado pelo caller)
procedure ObterValores(out AX, AY: Integer);
begin AX := 10; AY := 20; end;

// Valor padrão (overload ou default)
function CriarLabel(const ATexto: string;
  AFonte: Integer = 12): string;
begin Result := Format('[%d] %s', [AFonte, ATexto]); end;
```

## Strings — operações essenciais

```pascal
var S := 'Hello, World!';
Writeln(Length(S));           // 13
Writeln(S.Length);            // 13 (helper)
Writeln(S[1]);                // H (índice base 1)
Writeln(Copy(S, 1, 5));      // Hello
Writeln(Pos('World', S));    // 8
Writeln(S.Replace(',',''));   // Hello World!
Writeln(S.ToUpper);          // HELLO, WORLD!
Writeln(S.Trim);             // sem espaços nas bordas
Writeln(S.Contains('World')); // True
Writeln(S.StartsWith('He')); // True

// Concatenação
var R := S + ' Mais texto';
var R2 := Format('Nome: %s, Idade: %d', ['Maria', 30]);
```

## Ponteiros e nil

```pascal
// nil — ponteiro nulo / objeto não atribuído
var Obj: TObject := nil;
if Obj <> nil then Obj.Free;  // sempre checar antes de usar
FreeAndNil(Obj);              // libera E atribui nil

// Pointer básico
var P: Pointer := @MinhaVar;
var PI: ^Integer := @IntVar;
PI^ := 42;  // dereferência

// New / Dispose para records alocados no heap
type TPonto = record X, Y: Integer; end;
var Pt: ^TPonto;
New(Pt);
Pt^.X := 10;
Dispose(Pt);
```

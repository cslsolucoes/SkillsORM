unit records_avancados;
{
  EXEMPLO: Records avancados — variant record, packed record
  Compilavel: dcc32 / dcc64
  Demonstra:
    - Case variant record (union-like)
    - Packed record para protocolo de rede / arquivo binario
    - Alinhamento de memoria e SizeOf
    - Record com parte fixa + parte variante
}

interface

uses
  System.SysUtils;

// ---------------------------------------------------------------------------
// Variant Record: mesma memoria para tipos diferentes (discriminated union)
// ---------------------------------------------------------------------------
type
  TValorKind = (vkInteger, vkFloat, vkBoolean, vkString);

  TValor = record
    Kind: TValorKind; // discriminante (sempre presente)
    case Integer of   // Delphi usa Integer como tipo do case em variant records
      0: (AsInt    : Integer);
      1: (AsFloat  : Double);
      2: (AsBoolean: Boolean);
      // Strings NAO podem estar em parte variante — usar campo separado
  end;

// ---------------------------------------------------------------------------
// Packed Record: sem padding — uso em protocolos binarios
// ---------------------------------------------------------------------------
type
  // SEM packed: compilador pode adicionar bytes de padding
  THeaderNormal = record
    Magic  : Byte;    // offset 0, 1 byte
    // 3 bytes de padding aqui (alinhamento de Integer = 4)
    Version: Integer; // offset 4, 4 bytes
    Size   : Integer; // offset 8, 4 bytes
  end; // SizeOf = 12 (com padding)

  // COM packed: sem padding — compativel com arquivo/rede
  THeaderPacked = packed record
    Magic  : Byte;    // offset 0, 1 byte
    Version: Integer; // offset 1, 4 bytes
    Size   : Integer; // offset 5, 4 bytes
  end; // SizeOf = 9 (sem padding)

// ---------------------------------------------------------------------------
// Parte fixa + parte variante
// ---------------------------------------------------------------------------
type
  TShapeKind = (skCircle, skRect, skTriangle);

  TShape = record
    Kind   : TShapeKind; // parte fixa — sempre presente
    Color  : Cardinal;   // parte fixa — sempre presente
    case TShapeKind of  // parte variante — interpretacao depende de Kind
      skCircle  : (Radius: Single);
      skRect    : (Width, Height: Single);
      skTriangle: (Base, Alt: Single);
  end;

procedure DemonstrarVariantRecord;
procedure DemonstrarPackedRecord;
procedure DemonstrarShapeRecord;

implementation

procedure DemonstrarVariantRecord;
var
  V: TValor;
begin
  // Usar como Integer
  V.Kind   := vkInteger;
  V.AsInt  := 42;
  Writeln('Int: ', V.AsInt);

  // Reutilizar a mesma memoria como Float
  V.Kind    := vkFloat;
  V.AsFloat := 3.14;
  Writeln('Float: ', V.AsFloat:8:4);

  // ATENCAO: acessar campo errado e comportamento indefinido
  // V.Kind := vkFloat;
  // Writeln(V.AsInt); // lixo — Float e Int compartilham mesma memoria

  // Tamanho: maximo entre todos os campos variantes + campos fixos
  Writeln('SizeOf(TValor) = ', SizeOf(TValor));
  // = SizeOf(TValorKind) + SizeOf(Double) com alinhamento

  // Padrao seguro: sempre usar discriminante antes de acessar campo
  case V.Kind of
    vkInteger: Writeln('E inteiro: ', V.AsInt);
    vkFloat  : Writeln('E float: ',   V.AsFloat:8:4);
    vkBoolean: Writeln('E boolean: ', V.AsBoolean);
  end;
end;

procedure DemonstrarPackedRecord;
var
  H: THeaderPacked;
  Bytes: array[0..8] of Byte; // 9 bytes = SizeOf(THeaderPacked)
begin
  H.Magic   := $42; // 'B'
  H.Version := 1;
  H.Size    := 1024;

  Writeln('SizeOf(Normal) = ', SizeOf(THeaderNormal)); // 12 (com padding)
  Writeln('SizeOf(Packed) = ', SizeOf(THeaderPacked)); // 9 (sem padding)

  // Serializar para bytes (ex.: escrever em arquivo)
  Move(H, Bytes[0], SizeOf(H));
  Writeln(Format('Byte[0] = $%2.2X', [Bytes[0]])); // $42

  // Deserializar de bytes
  var H2: THeaderPacked;
  Move(Bytes[0], H2, SizeOf(H2));
  Writeln('Version = ', H2.Version);

  // ATENCAO: packed records podem ser mais lentos em leitura
  // porque o CPU precisa de acesso nao-alinhado.
  // Use apenas quando o layout binario for obrigatorio (protocolo, arquivo).
end;

procedure DemonstrarShapeRecord;
var
  Circulo, Retangulo: TShape;
begin
  // Circulo
  Circulo.Kind   := skCircle;
  Circulo.Color  := $FF0000; // vermelho
  Circulo.Radius := 5.0;

  // Retangulo
  Retangulo.Kind   := skRect;
  Retangulo.Color  := $0000FF;
  Retangulo.Width  := 10.0;
  Retangulo.Height := 20.0;

  // Processar polimorficamente
  var Shapes: array of TShape := [Circulo, Retangulo];
  for var S in Shapes do
  begin
    Write('Shape: ');
    case S.Kind of
      skCircle  : Writeln('Circulo, raio=', S.Radius:4:2);
      skRect    : Writeln('Retangulo, ', S.Width:4:2, 'x', S.Height:4:2);
      skTriangle: Writeln('Triangulo, base=', S.Base:4:2);
    end;
  end;

  // SizeOf: tamanho maximo dentre os campos variantes
  Writeln('SizeOf(TShape) = ', SizeOf(TShape));
end;

end.

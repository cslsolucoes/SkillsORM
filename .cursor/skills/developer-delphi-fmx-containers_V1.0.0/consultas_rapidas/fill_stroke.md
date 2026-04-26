# Fill e Stroke — Referência Rápida

## TBrushKind

| Valor | Descrição |
|-------|-----------|
| `Solid` | Cor sólida (padrão) |
| `None` | Sem preenchimento (transparente) |
| `Gradient` | Gradiente linear ou radial |
| `Bitmap` | Imagem como preenchimento |
| `Resource` | Brush de resource file |

## Cores FMX (formato ARGB)

```pascal
// Formato: $AARRGGBB  (Alpha, Red, Green, Blue — cada 2 dígitos hex = 0..FF)
$FFFFFFFF   // branco opaco
$FF000000   // preto opaco
$80000000   // preto 50% transparente (A=$80=128)
$00000000   // totalmente transparente
$FF2C3E50   // azul escuro (cor header GestorERP)
$FF27AE60   // verde
$FFE74C3C   // vermelho
$FF3498DB   // azul médio
$FFF2F2F2   // cinza claro (fundo body)

// Constantes nomeadas:
claWhite    claBlack    claRed      claBlue    claGreen
claGray     claYellow   claOrange   claSilver  claNull (transparente)
```

## Fill — receitas

```pascal
// Cor sólida
Rec.Fill.Kind  := TBrushKind.Solid;
Rec.Fill.Color := $FF2C3E50;

// Sem preenchimento
Rec.Fill.Kind := TBrushKind.None;

// Gradiente vertical (topo para base)
Rec.Fill.Kind := TBrushKind.Gradient;
Rec.Fill.Gradient.Style := TGradientStyle.Linear;
Rec.Fill.Gradient.Points[0].Color := $FF1A1A2E; Rec.Fill.Gradient.Points[0].Offset := 0;
Rec.Fill.Gradient.Points[1].Color := $FF16213E; Rec.Fill.Gradient.Points[1].Offset := 1;
Rec.Fill.Gradient.StartPosition.Point := TPointF.Create(0, 0);
Rec.Fill.Gradient.StopPosition.Point  := TPointF.Create(0, 1);

// Gradiente horizontal
Rec.Fill.Gradient.StartPosition.Point := TPointF.Create(0, 0);
Rec.Fill.Gradient.StopPosition.Point  := TPointF.Create(1, 0);

// Gradiente diagonal
Rec.Fill.Gradient.StartPosition.Point := TPointF.Create(0, 0);
Rec.Fill.Gradient.StopPosition.Point  := TPointF.Create(1, 1);
```

## Stroke — receitas

```pascal
// Sem borda (mais comum em containers)
Rec.Stroke.Kind := TBrushKind.None;

// Borda sólida
Rec.Stroke.Kind      := TBrushKind.Solid;
Rec.Stroke.Color     := $FFD0D0D0;
Rec.Stroke.Thickness := 1.0;  // espessura em pontos

// Borda tracejada
Rec.Stroke.Dash := TStrokeDash.Dash;      // - - - -
Rec.Stroke.Dash := TStrokeDash.Dot;       // . . . .
Rec.Stroke.Dash := TStrokeDash.DashDot;   // -.-.-.-
Rec.Stroke.Dash := TStrokeDash.Solid;     // ────── (padrão)

// Estilo de extremidade (caps)
Rec.Stroke.Cap := TStrokeCap.Flat;    // corte reto
Rec.Stroke.Cap := TStrokeCap.Round;   // arredondado
Rec.Stroke.Cap := TStrokeCap.Square;  // quadrado

// Estilo de junção
Rec.Stroke.Join := TStrokeJoin.Miter;  // pontudo
Rec.Stroke.Join := TStrokeJoin.Round;  // arredondado
Rec.Stroke.Join := TStrokeJoin.Bevel;  // cortado
```

## XRadius e YRadius

```pascal
Rec.XRadius := 12;  // arredondamento horizontal
Rec.YRadius := 12;  // arredondamento vertical

// Apenas os cantos superiores
Rec.Corners := [TCorner.TopLeft, TCorner.TopRight];

// Apenas os cantos inferiores
Rec.Corners := [TCorner.BottomLeft, TCorner.BottomRight];

// Tipo de canto
Rec.CornerType := TCornerType.Round;      // arredondado (padrão)
Rec.CornerType := TCornerType.Bevel;      // chanfrado
Rec.CornerType := TCornerType.InnerRound; // côncavo
Rec.CornerType := TCornerType.InnerLine;  // recortado reto
```

## No .fmx (design-time)

```
object RectCard: TRectangle
  Fill.Color  = $FFFFFFFF
  Fill.Kind   = Solid
  Stroke.Kind = None
  XRadius     = 12.000000000000000000
  YRadius     = 12.000000000000000000
end
```

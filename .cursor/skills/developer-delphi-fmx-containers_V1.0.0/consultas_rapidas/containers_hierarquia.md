# Containers — Hierarquia de Tipos FMX

## Hierarquia de herança (simplificada)

```
TObject
└── TPersistent
    └── TComponent
        └── TFmxObject
            └── TControl                  ← base de tudo que aparece na tela
                ├── TStyledControl        ← herda estilo de TStyleBook
                │   ├── TButton
                │   ├── TEdit
                │   ├── TLabel
                │   ├── TComboBox
                │   └── ...
                └── TShape                ← formas geométricas (sem estilo)
                    └── TRectangle        ← container mais usado ★
                    └── TCircle
                    └── TEllipse
                    └── TLine
                    └── TPath
                    └── TArc              ← usado como progressbar no GestorERP
```

## Containers principais e quando usar cada um

| Tipo | Herança | Tem Fill/Stroke | Aceita filhos | Uso principal |
|------|---------|-----------------|---------------|---------------|
| `TRectangle` | TShape | Sim | Sim | Container visual: card, header, fundo |
| `TLayout` | TControl direto | Não | Sim | Organizador invisível |
| `TPanel` | TStyledControl | Via estilo | Sim | Container com estilo |
| `TScrollBox` | TScrollBox | Não | Sim | Área scrollável |
| `TVertScrollBox` | TScrollBox | Não | Sim | Scroll vertical |
| `THorzScrollBox` | TScrollBox | Não | Sim | Scroll horizontal |
| `TFrame` | TFrame | Via internal | Sim | Componente reutilizável |
| `TForm` | TCommonCustomForm | Via estilo | Sim | Janela raiz |

## Propriedades universais (herdam de TControl)

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `Parent` | TFmxObject | Container pai |
| `Align` | TAlignLayout | Alinhamento automático |
| `Position.X/Y` | Single | Posição relativa ao pai (quando Align=None) |
| `Width` / `Height` | Single | Dimensões |
| `Padding` | TBounds | Espaço interno (entre borda e filhos) |
| `Margins` | TBounds | Espaço externo (entre este e vizinhos) |
| `Opacity` | Single | 0.0 (invisível) a 1.0 (opaco) |
| `Visible` | Boolean | Visibilidade |
| `Enabled` | Boolean | Habilitado/desabilitado |
| `ClipChildren` | Boolean | Cortar filhos que saem do bounds |
| `HitTest` | Boolean | False = ignora clique (passa para baixo) |
| `Cursor` | TCursor | Cursor do mouse sobre o componente |
| `RotationAngle` | Single | Rotação em graus |
| `Scale.X/Y` | Single | Escala (1.0 = original) |
| `Anchors` | TAnchors | Âncoras para posicionamento relativo |

## TRectangle — propriedades exclusivas

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `Fill` | TBrush | Preenchimento interno |
| `Stroke` | TStrokeBrush | Borda |
| `XRadius` | Single | Arredondamento horizontal |
| `YRadius` | Single | Arredondamento vertical |
| `Corners` | TCorners | Quais cantos são arredondados |
| `CornerType` | TCornerType | Round / Bevel / InnerRound / InnerLine |
| `Sides` | TSides | Quais lados da borda são desenhados |

## TLayout vs TRectangle — regra de decisão

```
Precisa de Fill/Stroke/XRadius?
  SIM → TRectangle
  NÃO → TLayout (mais leve, sem overhead de renderização GPU do fill)

Tem Padding obrigatório?
  Em ambos: Padding funciona igual

Quer que seja clicável?
  TRectangle com OnClick
  TLayout com HitTest=True + OnClick (menos usual)
```

## TScrollBox — configuração essencial

```pascal
// Scroll vertical com conteúdo dinâmico
var Scroll := TVertScrollBox.Create(Self);
Scroll.Parent := RecBody;
Scroll.Align  := TAlignLayout.Client;
Scroll.ShowScrollBars := True;

// Container de conteúdo dentro do scroll
var Layout := TLayout.Create(Self);
Layout.Parent := Scroll;
Layout.Align  := TAlignLayout.Top;  // cresce para baixo
Layout.Height := 0;                 // será calculado pelos filhos

// IMPORTANTE: adicionar filhos com Align=Top no Layout, não no Scroll direto
// Cada filho deve ter Height definido; Layout.Height não precisa ser setado manualmente
// quando os filhos têm Align=Top — o scroll calcula o tamanho do ContentBounds
```

## TBounds — Padding e Margins

```pascal
// Padding (interno) — empurra filhos para dentro
RecCard.Padding.Left   := 16;
RecCard.Padding.Top    := 16;
RecCard.Padding.Right  := 16;
RecCard.Padding.Bottom := 16;

// Margins (externo) — cria espaço entre este e seus vizinhos/pai
RecItem.Margins.Top    := 8;
RecItem.Margins.Bottom := 8;
RecItem.Margins.Left   := 4;
RecItem.Margins.Right  := 4;

// Definir todos de uma vez via SetBounds (não existe helper direto)
// Alternativa: usar construtor inline em .fmx design-time
```

## ClipChildren — comportamento de recorte

```pascal
// ClipChildren=True (padrão para TRectangle):
// Filhos que ultrapassam o bounds do pai são cortados (não aparecem fora)
RecCard.ClipChildren := True;

// ClipChildren=False:
// Filhos podem aparecer fora do bounds (ex: sombra que ultrapassa a borda)
// Necessário quando TShadowEffect precisa extrapolar o container
RecCard.ClipChildren := False; // para usar com TShadowEffect
```

## Eventos de interação em containers

```pascal
RecCard.OnClick     := OnCardClick;    // clique simples
RecCard.OnDblClick  := OnCardDblClick; // duplo clique
RecCard.OnMouseEnter := OnHoverEnter;  // mouse entrou (hover)
RecCard.OnMouseLeave := OnHoverLeave;  // mouse saiu
RecCard.OnMouseDown := OnMouseDown;    // botão pressionado
RecCard.OnMouseUp   := OnMouseUp;      // botão solto

// IMPORTANTE: HitTest deve ser True (padrão) para receber eventos de mouse
RecCard.HitTest := True;
```

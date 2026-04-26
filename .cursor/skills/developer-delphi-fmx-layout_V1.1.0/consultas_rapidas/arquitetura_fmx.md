# Arquitetura FMX — Rendering GPU e Scene Graph

## Como o FMX renderiza

O FireMonkey usa rendering acelerado por GPU:

| Plataforma | Backend gráfico |
|------------|-----------------|
| Windows | Direct2D / GDI+ (fallback) |
| macOS | Metal / Quartz |
| iOS | Metal |
| Android | OpenGL ES |
| Linux | OpenGL |

O resultado: animações e efeitos são executados na GPU sem custo de CPU.
Isso significa que TShadowEffect, TBlurEffect, TColorAnimation são baratos de usar.

## Scene Graph

Cada controle FMX é um **nó no scene graph**. O rendering percorre a árvore de pais → filhos.

```
TForm (raiz)
  └── TRectangle          [Z-order: fundo]
        ├── TRectangle    [Z-order: header]
        │     ├── TLabel
        │     └── TButton
        └── TVertScrollBox [Z-order: conteúdo]
              └── TLayout
                    ├── TRectangle  [Z-order: card 1]
                    └── TRectangle  [Z-order: card 2]
```

**Regra do Z-order:** o último filho declarado no `.fmx` fica na camada mais à frente.

## Hierarquia de classes FMX

```
TFmxObject
│
├── TComponent
│     └── TControl                  ← Visible, HitTest, Opacity, Cursor, ClipParent
│           │
│           ├── TShape              ← TRectangle, TEllipse, TLine, TArc, TPath
│           │     └── TCustomShape
│           │
│           ├── TStyledControl      ← StyleLookup, ApplyStyle, TStyleBook
│           │     ├── TTextControl  ← TLabel, TText
│           │     ├── TCustomEdit   ← TEdit, TMemo, TNumberBox
│           │     ├── TButton       ← TButton, TSpeedButton
│           │     └── TListView
│           │
│           ├── TScrollBox          ← TVertScrollBox, THorzScrollBox
│           ├── TLayout             ← sem visual, só organiza filhos
│           └── TImage              ← TBitmap via MultiResBitmap
│
├── TEffect                         ← TShadowEffect, TBlurEffect, TGlowEffect, etc.
├── TAnimation                      ← TFloatAnimation, TColorAnimation, TPathAnimation
└── TBindingsList                   ← LiveBindings

TFrame                              ← TControl com .fmx próprio (reutilizável)
TForm                               ← janela raiz
```

## Propriedades universais de TControl

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `Position.X/Y` | `Single` | Posição relativa ao pai |
| `Size.Width/Height` | `Single` | Tamanho em pontos (não pixels) |
| `Align` | `TAlignLayout` | Modo de alinhamento automático |
| `Margins` | `TBounds` | Espaço externo (entre borda e pai) |
| `Padding` | `TBounds` | Espaço interno (entre borda e filhos) |
| `Opacity` | `Single` (0..1) | Transparência global |
| `Visible` | `Boolean` | Visibilidade (Hidden não ocupa espaço) |
| `HitTest` | `Boolean` | Recebe eventos de mouse/touch |
| `ClipParent` | `Boolean` | Clipa ao bounds do pai |
| `RotationAngle` | `Single` | Rotação em graus |
| `Scale.X/Y` | `Single` | Escala (1.0 = normal) |
| `Effects` | `TEffectsList` | Lista de efeitos GPU aplicados |

## Coordenadas e DPI

FMX usa pontos (não pixels). O fator de escala é `Screen.Scale`:
- Tela 1x: 1 ponto = 1 pixel
- Tela 2x (Retina): 1 ponto = 2 pixels

Nunca use valores em pixels diretamente — use pontos e deixe o FMX escalar.

```pascal
// Errado: hardcode em pixels
Rec.Height := 76;  // funciona em 1x, fica minúsculo em 2x

// Certo: usar pontos — FMX escala automaticamente
Rec.Height := 76;  // 76 pontos = 76px em 1x, 152px em Retina
// (o próprio FMX aplica Screen.Scale internamente)
```

## Performance: o que é barato e o que é caro

| Operação | Custo | Observação |
|----------|-------|------------|
| TColorAnimation | Baixo | GPU, sem CPU |
| TShadowEffect | Baixo | GPU, shader |
| TBlurEffect | Médio | GPU, mas pesado para muitos controles |
| TFloatAnimation (Position) | Baixo | GPU transform |
| Criar controles em runtime | Médio | Allocação de objetos |
| Criar muitos controles em loop | Alto | Usar TListView ao invés de loop manual |
| RTTI em hot path | Alto | Evitar em OnResize/OnPaint |

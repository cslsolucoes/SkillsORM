---
name: developer-delphi-fmx-containers
description: Containers FMX: TRectangle, TLayout, TAlignLayout, Fill/Stroke, XRadius, Padding/Margins, tipografia FMX (TLabel, TText, TextSettings). Fundamentos de layout visual no FireMonkey — pré-requisito para todas as outras skills FMX.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-fmx-containers

## Versão interna

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Família** | A — FMX Layout |
| **Orquestradora** | `developer-delphi-fmx-layout_V1.1.0` |

## Responsabilidade

Containers, alinhamento automático, preenchimento visual (Fill/Stroke), cantos arredondados, espaçamento (Padding/Margins) e tipografia FMX. Esta skill é o **pré-requisito** de toda a Família A — entender TAlignLayout é obrigatório antes de usar animações, efeitos ou frames.

## When to use

- Criar estrutura de uma tela (header + conteúdo + footer)
- Configurar cor, gradiente, borda de um container
- Ajustar espaçamento interno/externo de um controle
- Configurar fontes e alinhamento de texto
- Criar layout responsivo ao resize

---

## §1 — TRectangle vs TLayout: regra fundamental

| Componente | Visual | Uso |
|------------|--------|-----|
| `TRectangle` | Sim (Fill, Stroke, XRadius, Effects) | Container com aparência visual |
| `TLayout` | Não | Container de organização pura (sem cor, sem borda) |
| `TPanel` | Mínimo | Legado — preferir TRectangle |

**Regra:** Use `TRectangle` quando quiser cor, borda ou efeito. Use `TLayout` quando só quiser organizar filhos.

```pascal
// Container visual (card, sidebar, toolbar):
RecCard := TRectangle.Create(Self);
RecCard.Parent := RecFundo;
RecCard.Fill.Color := $FFFFFFFF;       // branco
RecCard.XRadius := 12;                 // cantos arredondados
RecCard.Stroke.Kind := TBrushKind.None; // sem borda

// Container organizacional (grid de botões, área de campos):
LayoutBotoes := TLayout.Create(Self);
LayoutBotoes.Parent := RecCard;
LayoutBotoes.Align := TAlignLayout.Bottom;
LayoutBotoes.Height := 48;
```

---

## §2 — TAlignLayout: todos os valores

| Valor | Comportamento | Uso típico |
|-------|---------------|------------|
| `Client` | Preenche todo o espaço restante | Container principal de conteúdo |
| `Top` | Largura total, altura fixa, ancora ao topo | Header, toolbar, barra de busca |
| `Bottom` | Largura total, altura fixa, ancora à base | Footer, barra de ações |
| `Left` | Altura total, largura fixa, ancora à esquerda | Sidebar, coluna de ícones |
| `Right` | Altura total, largura fixa, ancora à direita | Painel de detalhes, ações |
| `Center` | Centralizado, sem redimensionar | Ícones, avatares, logos |
| `Contents` | Sobreposição total sobre o pai | Overlay, fundo de modal |
| `Scale` | Escala mantendo proporção | Imagens de fundo |
| `Fit` | Ajusta para caber mantendo proporção | Imagens em cards |
| `None` | Posicionamento manual (Position.X/Y) | Elementos flutuantes, animados |
| `HorzCenter` | Centraliza horizontalmente, respeita Y | Títulos centralizados |
| `VertCenter` | Centraliza verticalmente, respeita X | Ícones em linha |
| `MostTop` | Empilha no topo com prioridade máxima | Notificações sobrepostas |
| `MostBottom` | Empilha na base com prioridade máxima | Teclado virtual |
| `Horizontal` | Distribui horizontalmente (filhos lado a lado) | Barras de ferramentas |
| `Vertical` | Distribui verticalmente (filhos empilhados) | Listas de controles |

### 2.1 Padrão Top + Client (layout vertical com header fixo)

```pascal
// No .fmx (declarativo):
// TRectangle (Client, Fill=#FF181818)  ← fundo
//   TRectangle (Top, H=76)             ← toolbar fixa
//   TVertScrollBox (Client)            ← conteúdo scrollável

RecToolbar := TRectangle.Create(Self);
RecToolbar.Parent := RecFundo;
RecToolbar.Align  := TAlignLayout.Top;
RecToolbar.Height := 76;

ScrollConteudo := TVertScrollBox.Create(Self);
ScrollConteudo.Parent := RecFundo;
ScrollConteudo.Align  := TAlignLayout.Client;
```

### 2.2 Padrão Left + Client (layout horizontal com sidebar)

```pascal
RecSidebar := TRectangle.Create(Self);
RecSidebar.Parent := RecFundo;
RecSidebar.Align  := TAlignLayout.Left;
RecSidebar.Width  := 227;

RecConteudo := TRectangle.Create(Self);
RecConteudo.Parent := RecFundo;
RecConteudo.Align  := TAlignLayout.Client;
```

### 2.3 Padrão Top + Bottom + Client (header + footer + conteúdo)

```pascal
// Ordem de criação importa: Top e Bottom antes de Client
RecHeader.Align  := TAlignLayout.Top;    RecHeader.Height := 76;
RecFooter.Align  := TAlignLayout.Bottom; RecFooter.Height := 60;
RecBody.Align    := TAlignLayout.Client; // ocupa o restante
```

---

## §3 — Fill (preenchimento)

### 3.1 Cores sólidas

```pascal
Rec.Fill.Color := claWhite;       // constante nomeada
Rec.Fill.Color := $FFFFFFFF;      // ARGB hex: A=FF (opaco), R=FF, G=FF, B=FF
Rec.Fill.Color := $80FFFFFF;      // 50% transparente (A=80)
Rec.Fill.Color := $00000000;      // totalmente transparente
Rec.Fill.Kind  := TBrushKind.None; // sem preenchimento (transparente + sem overhead)
```

### 3.2 Gradiente linear

```pascal
Rec.Fill.Kind := TBrushKind.Gradient;
Rec.Fill.Gradient.Style := TGradientStyle.Linear;

// Cor inicial (offset 0)
Rec.Fill.Gradient.Points[0].Color  := $FF1A1A2E;
Rec.Fill.Gradient.Points[0].Offset := 0;
// Cor final (offset 1)
Rec.Fill.Gradient.Points[1].Color  := $FF16213E;
Rec.Fill.Gradient.Points[1].Offset := 1;

// Direção (de (0,0) para (1,1) = diagonal)
Rec.Fill.Gradient.StartPosition.X := 0;
Rec.Fill.Gradient.StartPosition.Y := 0;
Rec.Fill.Gradient.StopPosition.X  := 1;
Rec.Fill.Gradient.StopPosition.Y  := 1;
// Vertical: Start=(0,0) Stop=(0,1)
// Horizontal: Start=(0,0) Stop=(1,0)
```

### 3.3 Bitmap (imagem de fundo)

```pascal
Rec.Fill.Kind := TBrushKind.Bitmap;
Rec.Fill.Bitmap.WrapMode := TWrapMode.TileStretch; // ou Tile, TileOriginal
Rec.Fill.Bitmap.Bitmap.LoadFromFile('background.png');
```

---

## §4 — Stroke (borda)

```pascal
// Borda sólida colorida
Rec.Stroke.Kind      := TBrushKind.Solid;
Rec.Stroke.Color     := $FFD0D0D0;    // cinza claro
Rec.Stroke.Thickness := 1.5;          // espessura em pontos
Rec.Stroke.Cap       := TStrokeCap.Round;    // extremidades arredondadas
Rec.Stroke.Join      := TStrokeJoin.Round;   // cantos de encontro arredondados
Rec.Stroke.Dash      := TStrokeDash.Dash;    // tracejado

// Sem borda (padrão para a maioria dos containers):
Rec.Stroke.Kind := TBrushKind.None;
```

---

## §5 — XRadius, YRadius e Corners

```pascal
// Cantos arredondados
Rec.XRadius := 12;  // raio horizontal
Rec.YRadius := 12;  // raio vertical (igual = círculo perfeito)

// Só o topo arredondado (tab superior):
Rec.Corners := [TCorner.TopLeft, TCorner.TopRight];
Rec.CornerType := TCornerType.Round;  // Round (padrão), Bevel, InnerRound, InnerLine

// Todos os cantos (padrão):
Rec.Corners := AllCorners;
```

---

## §6 — Padding e Margins

```pascal
// Padding: espaço INTERNO (empurra filhos para dentro)
Rec.Padding.Left   := 20;
Rec.Padding.Top    := 16;
Rec.Padding.Right  := 20;
Rec.Padding.Bottom := 16;

// Margins: espaço EXTERNO (empurra o controle para dentro do pai)
Rec.Margins.Left   := 12;
Rec.Margins.Top    := 8;
Rec.Margins.Right  := 12;
Rec.Margins.Bottom := 8;
```

```
// Visualização:
// ┌─────────────────────────────┐  ← pai
// │   [Margins]                 │
// │   ┌─────────────────────┐   │
// │   │   [Padding]         │   │  ← TRectangle
// │   │   ┌─────────────┐   │   │
// │   │   │  filho      │   │   │
// │   │   └─────────────┘   │   │
// │   └─────────────────────┘   │
// └─────────────────────────────┘
```

---

## §7 — Tipografia FMX

### 7.1 TLabel (texto simples)

```pascal
Lbl := TLabel.Create(Self);
Lbl.Parent := RecHeader;
Lbl.Align  := TAlignLayout.Client;
Lbl.Text   := 'Dashboard';

// Fonte via TextSettings:
Lbl.TextSettings.Font.Family := 'Segoe UI';
Lbl.TextSettings.Font.Size   := 18;
Lbl.TextSettings.Font.Style  := [TFontStyle.fsBold];
Lbl.TextSettings.FontColor   := $FFFFFFFF;  // branco
Lbl.TextSettings.HorzAlign   := TTextAlign.Center;
Lbl.TextSettings.VertAlign   := TTextAlign.Center;
Lbl.TextSettings.WordWrap    := True;
Lbl.AutoSize := False;  // necessário quando Align <> None
```

### 7.2 TText (texto com styling mais rico)

```pascal
// TText é mais flexível que TLabel para texto decorativo
Txt := TText.Create(Self);
Txt.Parent := RecCard;
Txt.Text   := 'Título do Card';
Txt.TextSettings.Font.Size := 14;
Txt.TextSettings.FontColor := $FF222222;
Txt.AutoSize := True;  // ajusta tamanho ao texto
```

### 7.3 Paleta tipográfica do GestorERP

```pascal
// Hierarquia de tamanhos usada no projeto:
const
  FONT_TITULO    = 22;  // títulos de tela
  FONT_SUBTITULO = 16;  // subtítulos, KPI labels
  FONT_CORPO     = 13;  // texto de corpo, listas
  FONT_CAPTION   = 11;  // rodapés, metadados

// Cores de texto:
const
  COR_TEXTO_PRINCIPAL  = $FF222222;  // dark (fundo claro)
  COR_TEXTO_SECUNDARIO = $FF999999;  // muted
  COR_TEXTO_CLARO      = $FFFFFFFF;  // branco (fundo escuro)
  COR_TEXTO_DESTAQUE   = $FF4A90E2;  // azul link/ação
```

---

## §8 — TVertScrollBox e THorzScrollBox

```pascal
Scroll := TVertScrollBox.Create(Self);
Scroll.Parent := RecFundo;
Scroll.Align  := TAlignLayout.Client;
Scroll.ShowScrollBars := True;     // False para touch-only
Scroll.AniCalculations.TouchTracking := [ttVertical]; // scroll vertical touch
Scroll.DisableMouseWheel := False; // habilitar scroll por roda do mouse
```

---

## §9 — TImage

```pascal
Img := TImage.Create(Self);
Img.Parent := RecCard;
Img.Align  := TAlignLayout.Center;
Img.Width  := 48;
Img.Height := 48;
Img.Bitmap.LoadFromFile('icon.png');
Img.WrapMode := TImageWrapMode.Fit;  // Fit, Stretch, Center, Tile, Original
```

---

## Consultas rápidas desta skill

- `consultas_rapidas/alignlayout_tabela.md` — todos os valores TAlignLayout com descrição
- `consultas_rapidas/fill_stroke.md` — TBrush, TBrushKind, gradientes, bitmap
- `consultas_rapidas/containers_hierarquia.md` — TControl hierarchy completa
- `consultas_rapidas/padding_margins_diff.md` — diferença visual entre Padding e Margins

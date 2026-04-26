---
name: developer-delphi-fmx-layout
description: Orquestradora da Família A — FMX Layout. Delega para 6 micro-skills especializadas. Cobre hierarquia de containers, Align, Fill/Stroke, animações, efeitos GPU, componentes, frames herdáveis, LiveBindings, TMultiView e padrões de layout prontos para produção.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-fmx-layout (Orquestradora)

## Versão interna

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |
| **Família** | A — FMX Layout |
| **Papel** | Orquestradora — delega para micro-skills |

## Responsabilidade

Ponto de entrada único para qualquer tarefa visual FMX. Identifica o domínio da tarefa e delega para a micro-skill adequada. Mantém contexto leve: toda a profundidade técnica está nas micro-skills referenciadas.

---

## Mapa de delegação — quando usar cada micro-skill

| Tarefa | Micro-skill a invocar |
|--------|-----------------------|
| Containers, TRectangle, TLayout, Align, Fill, Stroke, Padding, Margins, tipografia | `developer-delphi-fmx-containers_V1.0.0` |
| Animações: TAnimator, TFloatAnimation, TColorAnimation, interpolações, hover, transitions | `developer-delphi-fmx-animations_V1.0.0` |
| Efeitos GPU: TShadowEffect, TBlurEffect, TGlowEffect, TReflectionEffect, overlay fosco | `developer-delphi-fmx-effects_V1.0.0` |
| Componentes: TMultiView, TListView, TEdit, TArc, TDialogService, LiveBindings | `developer-delphi-fmx-components_V1.0.0` |
| Frames: TFrame, herança visual, lazy-load, DestruirTudo pattern, CarregarDados | `developer-delphi-fmx-frames_V1.0.0` |
| Padrões prontos: drag sem titlebar, TStyleBook, arc progress, CRUD completo, temas | `developer-delphi-fmx-patterns_V1.0.0` |

---

## Quando NÃO usar esta família

- Build/deploy → `developer-delphi-to-fpc-build`
- Lógica de negócio, queries → `developer-delphi-to-fpc-architecture-and-design`
- Publicação iOS → `developer-delphi-ios-publishing`
- Testes/qualidade → `developer-delphi-testing-and-quality`

---

## §1 — Arquitetura FMX: visão geral para orientar delegação

### 1.1 Rendering GPU e Scene Graph

FMX usa rendering via GPU (DirectX no Windows, Metal no iOS/macOS, OpenGL no Android/Linux).
Cada controle é um nó no **scene graph** — hierarquia de objetos que herdam transformações do pai.
Posições são em `Single` (ponto flutuante), não pixels — o FMX escala por `TCanvas.Scale` (DPI-aware).

```
TForm / TFrame
  └── TRectangle  ← nó com Fill + Stroke + Effects
        └── TLayout  ← nó de organização (sem visual)
              ├── TLabel
              ├── TEdit
              └── TRectangle
                    └── TImage
```

### 1.2 Hierarquia de classes relevante

```
TFmxObject
  └── TComponent
        └── TControl          ← Visible, HitTest, Opacity, Cursor
              └── TStyledControl  ← StyleLookup, TStyleBook
                    ├── TShape       ← TRectangle, TEllipse, TLine, TArc
                    ├── TTextControl ← TLabel, TText
                    ├── TScrollBox   ← TVertScrollBox, THorzScrollBox
                    └── TCustomEdit  ← TEdit, TMemo
```

### 1.3 Princípios de composição FMX

1. **Visual** → `TRectangle` (Fill, Stroke, XRadius, Effects)
2. **Organização** → `TLayout` (sem aparência, só alinha filhos)
3. **Scroll** → `TVertScrollBox` / `THorzScrollBox` (wrapping de conteúdo scrollável)
4. **Texto** → `TLabel` (rótulo) / `TText` (texto styled) / `TEdit` (input)
5. **Imagem** → `TImage` com `TBitmap`
6. **Frame** → `TFrame` (componente reutilizável com `.fmx` próprio)

### 1.4 Regras de Align — resumo

| Valor | Comportamento |
|-------|---------------|
| `Client` | Preenche todo o espaço restante do pai |
| `Top` | Largura total, altura fixa, ancorando ao topo |
| `Bottom` | Largura total, altura fixa, ancorando à base |
| `Left` | Altura total, largura fixa, ancorando à esquerda |
| `Right` | Altura total, largura fixa, ancorando à direita |
| `Contents` | Sobreposição total — overlay/modal background |
| `None` | Posicionamento manual (Position.X/Y) |

> Ver tabela completa: `developer-delphi-fmx-containers_V1.0.0/consultas_rapidas/alignlayout_tabela.md`

---

## §2 — Workflow de construção de tela FMX

```
1. Identificar a tarefa visual
   ↓
2. Selecionar micro-skill adequada (tabela acima)
   ↓
3. Ler SKILL.md da micro-skill + consultas_rapidas/ relevante
   ↓
4. Usar templates/ da micro-skill como ponto de partida
   ↓
5. Adaptar ao contexto do projeto
```

### 2.1 Padrão de tela completa (layout típico GestorERP)

```pascal
// Estrutura declarativa (.fmx) — padrão do projeto:
// TRectangle (Client, Fill=#FF181818)         ← fundo escuro
//   TRectangle (Top, H=76)                    ← toolbar
//     TLabel (Left, text=título)
//     TButton (Right, text=ação)
//   TVertScrollBox (Client)                   ← conteúdo scrollável
//     TLayout (Top, H=auto)                   ← conteúdo dinâmico

procedure TFrmBase.CriarEstrutura;
begin
  RecFundo := TRectangle.Create(Self);
  RecFundo.Parent := Self;
  RecFundo.Align  := TAlignLayout.Client;
  RecFundo.Fill.Color := $FF181818;
  RecFundo.Stroke.Kind := TBrushKind.None;
end;
```

### 2.2 Padrão lazy-load (performance)

Carregar controles pesados somente quando o frame fica visível:
```pascal
procedure TFrmConteudo.RecFundoResize(Sender: TObject);
begin
  if RecFundo.ControlsCount = 0 then
    CriarControles; // inicializa só na primeira vez
end;
```

---

## §3 — Referências rápidas para contexto de orquestração

### 3.1 Animação — ponto de entrada

```pascal
// Animação simples de opacity — ver fmx-animations para detalhes:
TAnimator.AnimateFloat(Componente, 'Opacity', 1.0, 0.3);

// Cor — AnimateColor:
TAnimator.AnimateColor(Rec, 'Fill.Color', claWhite, 0.2);
```

### 3.2 Efeito de sombra — ponto de entrada

```pascal
// Criar TShadowEffect em runtime — ver fmx-effects para detalhes:
var Sombra := TShadowEffect.Create(Rec);
Sombra.Parent    := Rec;
Sombra.Softness  := 0.5;
Sombra.Direction := 90;
Sombra.Distance  := 5;
Sombra.Color     := $40000000;  // preto 25% opacidade
```

### 3.3 Frame modal — ponto de entrada

```pascal
// Padrão CarregarDados (auto-map edt* ↔ txt*) — ver fmx-frames para detalhes:
procedure TFrmModal.CarregarDados(const AId: Integer);
var Ctrl: TControl;
    I: Integer;
begin
  for I := 0 to ControlsCount - 1 do
  begin
    Ctrl := Controls[I];
    if Ctrl.Name.StartsWith('edt') then
      // mapear campo correspondente 'txt' + sufixo
      TEdit(Ctrl).Text := GetCampo(Ctrl.Name.Substring(3));
  end;
end;
```

---

## §4 — Padrões do projeto GestorERP

Padrões identificados no código real do projeto:

| Padrão | Localização | Micro-skill |
|--------|-------------|-------------|
| Drag sem titlebar | `UnitLogin.pas`: FArrastando, OnMouseMove | `fmx-patterns` |
| Arc progress (KPI) | `FrmDasboard.pas`: TArc, ConfigurarQualquerGrafico | `fmx-patterns` |
| Hover color em lista | `FrmListagem.pas`: TAnimator.AnimateColor | `fmx-animations` |
| Modal auto-map | `FrmModal.pas`: CarregarDados, edt*↔txt* | `fmx-frames` |
| Lazy-load | `FrmDasboard.pas`: RecFundoResize + ControlsCount=0 | `fmx-frames` |
| DestruirTudo | `FrmModeloCrud.pas`: limpar frames filhos | `fmx-frames` |
| FundoFosco overlay | `FrmModeloCrud.pas`: TBlurEffect + TRectangle | `fmx-effects` |
| TDialogService confirm | `FrmModeloCrud.pas`: OnDelete | `fmx-components` |

---

## Consultas rápidas desta orquestradora

- `consultas_rapidas/mapa_skills_fmx.md` — tabela de decisão: qual micro-skill para cada tarefa
- `consultas_rapidas/arquitetura_fmx.md` — scene graph, GPU rendering, hierarquia de classes
- `consultas_rapidas/checklist_layout.md` — checklist antes de publicar uma tela FMX

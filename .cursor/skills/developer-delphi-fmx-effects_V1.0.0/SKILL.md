---
name: developer-delphi-fmx-effects
description: Efeitos GPU FMX — sombras, blur, glow, reflexo e overlay fosco para modais. Família A — FMX Layout.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-fmx-effects_V1.0.0

## O que é esta skill

Cobre efeitos GPU do FireMonkey (FMX): sombras, blur, glow, reflexo, inner glow e o padrão de overlay fosco usado em modais. Parte da Família A — FMX Layout.

**Skill orquestradora:** `developer-delphi-fmx-layout_V1.1.0`

---

## Hierarquia de efeitos FMX

```
TEffect (base)
├── TBlurEffect          — desfoque gaussiano
├── TShadowEffect        — sombra projetada
├── TGlowEffect          — brilho externo
├── TInnerGlowEffect     — brilho interno
├── TReflectionEffect    — reflexo abaixo do componente
├── TBevelEffect         — relevo/chanfro
├── TPixelShaderEffect   — shader customizado
└── TColorMatrixEffect   — transformação de cor (saturação, brilho)
```

Todos herdam de `TEffect` e são adicionados como **filhos** do componente alvo.

---

## §1 — TShadowEffect

```pascal
uses FMX.Effects;

var Shadow: TShadowEffect;
Shadow := TShadowEffect.Create(RecCard);
Shadow.Parent    := RecCard;      // filho do componente
Shadow.Softness  := 0.3;          // 0=nítida, 1=muito difusa
Shadow.Distance  := 4;            // deslocamento em pixels
Shadow.Direction := 315;          // ângulo em graus (315 = nordeste)
Shadow.ShadowColor := $40000000; // ARGB: A=25% opaco, preto
Shadow.Enabled   := True;
```

**IMPORTANTE:** `ClipChildren := False` no componente pai para a sombra não ser cortada.

Propriedades animáveis:
- `'Shadow.Distance'` — Single
- `'Shadow.Softness'` — Single
- `'Shadow.ShadowColor'` — TAlphaColor (via `TAnimator.AnimateColor`)

---

## §2 — TBlurEffect

```pascal
var Blur: TBlurEffect;
Blur := TBlurEffect.Create(RecFundo);
Blur.Parent   := RecFundo;
Blur.Softness := 8; // 0=nítido até ~15=muito borrado
```

**Uso principal:** fundo fosco atrás de modais/overlays.

**Custo GPU:** alto — evitar em componentes que se movem rapidamente.

Propriedade animável: `'Blur.Softness'`

---

## §3 — TGlowEffect / TInnerGlowEffect

```pascal
// Glow externo
var Glow: TGlowEffect;
Glow := TGlowEffect.Create(RecBotao);
Glow.Parent    := RecBotao;
Glow.GlowColor := $FF3498DB;
Glow.Softness  := 5;

// Glow interno
var IGlow: TInnerGlowEffect;
IGlow := TInnerGlowEffect.Create(RecDestaque);
IGlow.Parent    := RecDestaque;
IGlow.GlowColor := $FFFF9800;
IGlow.Softness  := 8;
```

Propriedades animáveis: `'Glow.Softness'`, `'Glow.GlowColor'`

---

## §4 — Padrão Fundo Fosco (overlay modal)

```pascal
// 1. TRectangle semitransparente sobre TUDO (bloqueio de cliques)
RecOverlay.Fill.Color := $88000000; // 53% preto
RecOverlay.HitTest    := True;
RecOverlay.Opacity    := 0;
RecOverlay.Visible    := True;
TAnimator.AnimateFloat(RecOverlay, 'Opacity', 1.0, 0.20);

// 2. TBlurEffect aplicado ao CONTEÚDO ABAIXO (não ao overlay)
var Blur: TBlurEffect;
Blur := TBlurEffect.Create(RecConteudoPrincipal);
Blur.Parent   := RecConteudoPrincipal;
Blur.Softness := 0;
TAnimator.AnimateFloat(Blur, 'Softness', 6, 0.20);
// Salvar referência para remover depois:
FBlurFundo := Blur;
```

---

## §5 — Múltiplos efeitos e performance

```pascal
// Aplicar sombra + glow juntos (possível, mas custoso)
var S := TShadowEffect.Create(Rec); S.Parent := Rec;
var G := TGlowEffect.Create(Rec);  G.Parent := Rec;

// Habilitar/desabilitar por performance:
S.Enabled := False; // desabilitar quando não visível
```

**Ordem de custo GPU (menor → maior):**
1. TShadowEffect (mais leve)
2. TReflectionEffect
3. TGlowEffect / TInnerGlowEffect
4. TBlurEffect (mais pesado)

---

## §6 — Remover efeito em runtime

```pascal
// Remover efeito salvo em variável:
FBlurFundo.Free;
FBlurFundo := nil;

// Remover efeito pelo índice (Effects collection):
if RecCard.Effects.Count > 0 then
  RecCard.Effects[0].Free;
```

---

## Arquivos desta skill

### exemplos/
- [shadow_effect.pas](exemplos/shadow_effect.pas) — TShadowEffect completo
- [blur_effect.pas](exemplos/blur_effect.pas) — TBlurEffect e fundo fosco
- [glow_effect.pas](exemplos/glow_effect.pas) — TGlowEffect e TInnerGlowEffect
- [inner_glow.pas](exemplos/inner_glow.pas) — TInnerGlowEffect em botões
- [reflexo_effect.pas](exemplos/reflexo_effect.pas) — TReflectionEffect
- [fundo_fosco_overlay.pas](exemplos/fundo_fosco_overlay.pas) — overlay modal completo

### consultas_rapidas/
- [effects_hierarquia.md](consultas_rapidas/effects_hierarquia.md) — hierarquia e múltiplos efeitos
- [shadow_parametros.md](consultas_rapidas/shadow_parametros.md) — parâmetros do TShadowEffect
- [blur_vs_glow.md](consultas_rapidas/blur_vs_glow.md) — quando usar cada; impacto GPU
- [effects_animaveis.md](consultas_rapidas/effects_animaveis.md) — propriedades animáveis

### templates/
- [TEMPLATE_card_sombra.pas](templates/TEMPLATE_card_sombra.pas) — card com sombra runtime
- [TEMPLATE_overlay_fosco.pas](templates/TEMPLATE_overlay_fosco.pas) — overlay com blur
- [TEMPLATE_glow_button.pas](templates/TEMPLATE_glow_button.pas) — botão com glow animado

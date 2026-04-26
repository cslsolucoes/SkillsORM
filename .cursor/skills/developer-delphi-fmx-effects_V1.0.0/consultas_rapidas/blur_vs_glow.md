# Blur vs Glow — Quando usar cada um e impacto GPU

## Tabela de decisão rápida

| Situação | Efeito recomendado | Motivo |
|----------|--------------------|--------|
| Fundo de modal (frosted glass) | TBlurEffect no conteúdo abaixo | Simula vidro fosco |
| Botão selecionado/ativo | TGlowEffect externo | Indica estado |
| Input em foco | TInnerGlowEffect | Brilho interno sutil |
| Badge de status | TInnerGlowEffect | Cor de destaque interno |
| Card hover | TShadowEffect (não glow) | Menos custoso, mais natural |
| Alerta crítico | TGlowEffect com cor vermelha | Chama atenção sem blur |
| Loading state | TBlurEffect + Opacity | Desativa interação visualmente |
| Premium/spotlight | TGlowEffect dourado | Visual de destaque |

---

## TBlurEffect

**O que faz:** aplica desfoque gaussiano ao conteúdo do próprio componente.

```pascal
Blur := TBlurEffect.Create(RecFundo);
Blur.Parent   := RecFundo;
Blur.Softness := 8;
```

**Softness range:**
| Valor | Visual |
|-------|--------|
| 0 | nítido (sem blur) |
| 2 | leve (foco suave) |
| 5 | médio |
| 8 | fundo fosco de modal |
| 12 | desfoque total |

**Custo GPU:** ALTO — evitar em listas, grids, ou componentes em movimento.

**Armadilha comum:** blur aplicado ao overlay/modal não desfoca o conteúdo abaixo.
Aplicar no RecConteudoPrincipal (o conteúdo abaixo), não no overlay.

---

## TGlowEffect (externo)

**O que faz:** adiciona brilho difuso ao redor do componente.

```pascal
Glow := TGlowEffect.Create(RecBotao);
Glow.Parent    := RecBotao;
Glow.GlowColor := $FF3498DB;  // azul
Glow.Softness  := 5;
```

**Softness range:**
| Valor | Visual |
|-------|--------|
| 0 | invisível |
| 2 | toque sutil |
| 5 | normal |
| 8 | pronunciado |
| 12+ | muito intenso |

**Custo GPU:** médio — ok em componentes estáticos.

**Requer:** `AControl.ClipChildren := False` para não ser cortado.

---

## TInnerGlowEffect (interno)

**O que faz:** adiciona brilho difuso dentro das bordas do componente.

```pascal
IGlow := TInnerGlowEffect.Create(RecInput);
IGlow.Parent    := RecInput;
IGlow.GlowColor := $FF3498DB;
IGlow.Softness  := 6;
```

**Diferença do TGlowEffect:**
- TGlowEffect: brilha para FORA (além das bordas)
- TInnerGlowEffect: brilha para DENTRO (dentro das bordas)
- TInnerGlowEffect não precisa de ClipChildren=False

**Uso típico:** inputs em foco, badges, botões de estado.

---

## Comparativo de custo GPU

```
TBlurEffect        ALTO    — rasteriza toda a área + convolução gaussiana
TGlowEffect        MÉDIO   — rasteriza área + difusão para fora
TInnerGlowEffect   MÉDIO   — similar ao Glow, dentro das bordas
TShadowEffect      BAIXO   — offset simples + blur de baixa resolução
TReflectionEffect  BAIXO-M — espelho com fade
```

---

## Regras de performance

1. **TBlurEffect:** máximo 1 por tela visível, apenas em componentes estáticos
2. **TGlowEffect:** ok em até 3-4 componentes simultaneamente
3. **Desabilitar quando invisível:**
   ```pascal
   Glow.Enabled := not AControl.Visible;
   ```
4. **Nunca combinar Blur + Glow no mesmo componente** em dispositivos lentos
5. **Mobile:** reduzir Softness pela metade para compensar GPU menos potente

---

## Animação de efeitos

```pascal
// Glow animado no hover:
TAnimator.AnimateFloat(Glow, 'Softness', 8, 0.20,
  TAnimationType.Out, TInterpolationType.Cubic);

// Blur animado na abertura de modal:
TAnimator.AnimateFloat(Blur, 'Softness', 8, 0.20,
  TAnimationType.Out, TInterpolationType.Cubic);

// Cor do glow animada:
TAnimator.AnimateColor(Glow, 'GlowColor', $FFE74C3C, 0.15);
```

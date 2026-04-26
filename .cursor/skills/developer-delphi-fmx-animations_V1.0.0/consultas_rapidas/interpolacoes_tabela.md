# TInterpolationType — Tabela Completa

## Todos os valores com descrição e timing recomendado

| Tipo | TAnimationType.Out (mais comum) | TAnimationType.In | TAnimationType.InOut | Uso recomendado |
|------|--------------------------------|-------------------|----------------------|-----------------|
| `Linear` | Velocidade constante | Idem | Idem | barras de progresso, contadores |
| `Quadratic` | Desacelera suavemente no fim | Acelera suavemente | Suave nos dois lados | movimentos gerais |
| `Cubic` | Desacelera com curva cúbica | Acelera com cúbica | Muito suave | **padrão recomendado ★** |
| `Quartic` | Desacelera abruptamente no fim | Inicia lento, explode | Muito dramático | entradas de impacto |
| `Quintic` | Extremamente abrupto | Extremamente lento | Raramente usado | efeitos especiais |
| `Sinusoidal` | Curva senoidal suave | Senoidal inversa | Oscilatório | oscilações naturais |
| `Exponential` | Cai exponencialmente | Sobe exponencialmente | Muito suave → brusco | zoom out, expansão |
| `Circular` | Baseado em arco (quarter circle) | Idem invertido | Muito suave | movimentos naturais |
| `Elastic` | Oscila como mola após atingir | Oscila antes de partir | Oscila nos dois lados | **alertas, notificações** |
| `Back` | Ultrapassa o alvo e volta | Recua antes de partir | Overshoots nos dois | **botões interativos ★** |
| `Bounce` | Quica ao chegar no destino | Quica ao partir | Quica nos dois | gamification, sucesso |

## TAnimationType — significado exato

| Tipo | Comportamento |
|------|---------------|
| `In` | A curva afeta o **início** da animação (aceleração) |
| `Out` | A curva afeta o **fim** da animação (desaceleração) → **mais natural ★** |
| `InOut` | A curva afeta **ambos os extremos** (suave início e fim) |

## Combinações mais usadas no GestorERP

| Situação | Interpolação | AnimationType | Duração |
|----------|-------------|---------------|---------|
| Entrada de tela (fade+slide) | Cubic | Out | 0.30–0.40s |
| Saída de tela | Cubic | In | 0.20–0.25s |
| Abertura de modal | Back | Out | 0.25–0.30s |
| Fechamento de modal | Cubic | In | 0.18–0.22s |
| Hover de card (cor) | Linear | — | 0.12–0.18s |
| Hover de card (escala) | Back | Out | 0.15–0.20s |
| Tab switch (fade) | Linear | — | 0.15s |
| Sidebar (largura) | Cubic | Out | 0.25s |
| Notificação pop | Elastic | Out | 0.40–0.50s |
| Barra de progresso | Linear | — | variável |
| Rotação de ícone | Cubic | InOut | 0.30s |
| Cascata de itens (stagger) | Cubic | Out | 0.25–0.35s + 0.06s/item |

## Timing guidelines

| Tipo de animação | Duração ideal |
|-----------------|---------------|
| Micro-interações (hover, click feedback) | 80–180ms |
| Transições de estado (modal, drawer) | 200–300ms |
| Entrada de tela, carregamento | 300–450ms |
| Animações decorativas (loop) | 600ms–2s |
| Nunca use mais de 500ms para interações de usuário | |

## Exemplo de código

```pascal
uses FMX.Ani;

// Back + Out = ultrapassa o alvo e volta (efeito "pop")
TAnimator.AnimateFloat(RecModal, 'Scale.X', 1.0, 0.28,
  TAnimationType.Out, TInterpolationType.Back);

// Elastic + Out = mola (bom para notificações)
TAnimator.AnimateFloat(RecNotif, 'Position.Y', TargetY, 0.45,
  TAnimationType.Out, TInterpolationType.Elastic);

// Bounce + Out = quica (feedback de sucesso)
TAnimator.AnimateFloat(RecCheck, 'Scale.X', 1.0, 0.50,
  TAnimationType.Out, TInterpolationType.Bounce);

// Linear = constante (barras de progresso)
TAnimator.AnimateFloat(RecBarra, 'Width', NovaLargura, 0.3,
  TAnimationType.InOut, TInterpolationType.Linear);
```

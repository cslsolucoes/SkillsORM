# TShadowEffect — Parâmetros completos

## Declaração e criação

```pascal
uses FMX.Effects;

var Shadow: TShadowEffect;
Shadow := TShadowEffect.Create(RecCard);
Shadow.Parent      := RecCard;       // filho do componente — obrigatório
Shadow.Softness    := 0.3;
Shadow.Distance    := 4;
Shadow.Direction   := 315;
Shadow.ShadowColor := $40000000;
Shadow.Enabled     := True;

// CRITICO: sem isto a sombra é cortada pelo container pai
RecCard.ClipChildren := False;
```

---

## Tabela de propriedades

| Propriedade | Tipo | Range | Padrão | Descrição |
|-------------|------|-------|--------|-----------|
| `Softness` | Single | 0.0 – 1.0 | 0.3 | Difusão: 0=nítida, 1=muito difusa |
| `Distance` | Single | 0 – ∞ | 4 | Deslocamento em pixels |
| `Direction` | Single | 0 – 360 | 315 | Ângulo em graus (0=direita, 90=baixo) |
| `ShadowColor` | TAlphaColor | ARGB | $40000000 | Cor + opacidade da sombra |
| `Enabled` | Boolean | True/False | True | Habilitar/desabilitar sem destruir |

---

## Direções comuns

| Valor | Direção visual | Uso recomendado |
|-------|----------------|-----------------|
| `0` | direita | laterais |
| `90` | baixo | mais natural (luz de cima) |
| `180` | esquerda | laterais |
| `270` | cima | |
| `315` | nordeste (↗) | padrão Material Design |

---

## Opacidade via ShadowColor (canal Alpha)

O canal A (alpha) de `ShadowColor` controla a intensidade:

| Alpha hex | Alpha % | Efeito visual |
|-----------|---------|---------------|
| `$20` | 12% | sombra quase invisível |
| `$30` | 19% | sombra muito sutil |
| `$40` | 25% | sutil (cards normais) |
| `$60` | 37% | média (hover) |
| `$80` | 50% | pronunciada |
| `$A0` | 62% | forte |
| `$C0` | 75% | muito forte |

```pascal
// Exemplos práticos:
Shadow.ShadowColor := $30000000; // sutil, fundo branco
Shadow.ShadowColor := $60000000; // média, card em hover
Shadow.ShadowColor := $403498DB; // azul translúcido (destaque)
```

---

## Softness vs Distance

```
Softness baixo (0.1) + Distance alto (8):
  → sombra nítida e deslocada — "flat design" com sombra dura

Softness alto (0.5) + Distance baixo (2):
  → sombra difusa e próxima — "material design" / elevação suave

Softness médio (0.3) + Distance médio (4):
  → sombra equilibrada — uso geral
```

---

## Propriedades animáveis

```pascal
// Via TAnimator.AnimateFloat
TAnimator.AnimateFloat(Shadow, 'Softness', 0.5, 0.20);
TAnimator.AnimateFloat(Shadow, 'Distance', 8, 0.20);

// Via TAnimator.AnimateColor
TAnimator.AnimateColor(Shadow, 'ShadowColor', $60000000, 0.20);
```

Atenção: o caminho é `'Softness'`, `'Distance'`, `'ShadowColor'` — sem prefixo `Shadow.`.

---

## Presets por contexto

```pascal
// Card repouso
Shadow.Softness := 0.15; Shadow.Distance := 2; Shadow.ShadowColor := $30000000;

// Card hover (elevado)
Shadow.Softness := 0.40; Shadow.Distance := 8; Shadow.ShadowColor := $50000000;

// Card selecionado / ativo
Shadow.Softness := 0.3;  Shadow.Distance := 4; Shadow.ShadowColor := $403498DB; // azul

// Dropdown / popover
Shadow.Softness := 0.5;  Shadow.Distance := 6; Shadow.Direction := 90; Shadow.ShadowColor := $60000000;

// Botão primário
Shadow.Softness := 0.3;  Shadow.Distance := 3; Shadow.ShadowColor := $501A6B9A; // azul escuro
```

# Effects — Propriedades animáveis via TFloatAnimation / TAnimator

## Referência rápida

| Efeito | Propriedade | Tipo | Path para TAnimator |
|--------|-------------|------|---------------------|
| TShadowEffect | Softness | Single | `'Softness'` |
| TShadowEffect | Distance | Single | `'Distance'` |
| TShadowEffect | ShadowColor | TAlphaColor | `'ShadowColor'` (via AnimateColor) |
| TBlurEffect | Softness | Single | `'Softness'` |
| TGlowEffect | Softness | Single | `'Softness'` |
| TGlowEffect | GlowColor | TAlphaColor | `'GlowColor'` (via AnimateColor) |
| TInnerGlowEffect | Softness | Single | `'Softness'` |
| TInnerGlowEffect | GlowColor | TAlphaColor | `'GlowColor'` (via AnimateColor) |
| TReflectionEffect | Length | Single | `'Length'` |
| TReflectionEffect | Opacity | Single | `'Opacity'` |
| Qualquer TEffect | Enabled | Boolean | n/a — alterar diretamente |

**Nota:** o path é relativo ao objeto efeito, não ao controle pai.

---

## Padrão AnimateFloat sobre efeito

```pascal
// Animar Softness de um glow de 0 para 8 em 0.20s
TAnimator.AnimateFloat(Glow, 'Softness', 8, 0.20,
  TAnimationType.Out, TInterpolationType.Cubic);

// Animar Distance de uma sombra
TAnimator.AnimateFloat(Shadow, 'Distance', 8, 0.20,
  TAnimationType.Out, TInterpolationType.Cubic);

// Animar Length de um reflexo
TAnimator.AnimateFloat(Reflexo, 'Length', 0.6, 0.30,
  TAnimationType.Out, TInterpolationType.Sinusoidal);
```

---

## Padrão AnimateColor sobre efeito

```pascal
// Mudar cor do glow de azul para vermelho em 0.15s
TAnimator.AnimateColor(Glow, 'GlowColor', $FFE74C3C, 0.15);

// Mudar cor da sombra
TAnimator.AnimateColor(Shadow, 'ShadowColor', $603498DB, 0.20);
```

---

## TFloatAnimation como objeto (com OnFinish)

```pascal
// Útil quando precisa de callback ao fim ou de controle preciso
var Anim := TFloatAnimation.Create(Blur);
Anim.Parent       := Blur;
Anim.PropertyName := 'Softness';
Anim.StartValue   := Blur.Softness;
Anim.StopValue    := 0;
Anim.Duration     := 0.20;
Anim.OnFinish := procedure(Sender: TObject)
begin
  Blur.Free;     // liberar blur após animação
  Anim.Free;     // liberar a própria animação
end;
Anim.Start;
```

---

## Animação de efeito via path composto (acesso indireto)

Para animar um efeito através do controle pai, use o path composto:

```pascal
// Animar sombra acessando pelo controle pai
TAnimator.AnimateFloat(RecCard, 'Shadow.Distance', 8, 0.20);
TAnimator.AnimateFloat(RecCard, 'Shadow.Softness', 0.4, 0.20);
```

O path `'Shadow.Distance'` funciona se o TRectangle tiver um filho `TShadowEffect`
cujo nome seja `Shadow`. Para garantir o nome:

```pascal
Shadow := TShadowEffect.Create(RecCard);
Shadow.Parent := RecCard;
Shadow.Name   := 'Shadow'; // nome para acesso via path composto
```

---

## TColorAnimation declarativo (design-time) em efeito

No `.fmx`, é possível declarar TColorAnimation filho de um efeito:

```
object RecCard: TRectangle
  ...
  object SombraCard: TShadowEffect
    Softness = 0.2
    Distance = 3
    ShadowColor = clBlack  // $40000000
    object AnimSombraHover: TColorAnimation
      PropertyName = 'ShadowColor'
      StartValue = $30000000
      StopValue  = $60000000
      Duration   = 0.150
      Trigger = 'MouseEnter=true'
      TriggerInverse = 'MouseEnter=false'
    end
  end
end
```

---

## Interrupção de animação em efeito

```pascal
// Parar animação em andamento em um efeito
TAnimator.StopAnimation(Glow, 'Softness');
TAnimator.StopAnimation(Shadow, 'Distance');

// Parar todas as animações de um efeito
TAnimator.StopAllAnimation(Glow);
```

# AnimateColor (runtime) vs TColorAnimation (design-time)

## Visão geral

O FMX oferece duas formas de animar cores:

| Aspecto | `TAnimator.AnimateColor` | `TColorAnimation` (objeto) |
|---------|--------------------------|----------------------------|
| Estilo | Imperativo — uma linha de código | Declarativo — objeto com propriedades |
| Criação | Runtime, inline | Runtime ou design-time (.fmx) |
| Ciclo de vida | Gerenciado automaticamente | Você gerencia (ou cria como filho) |
| OnFinish | Não diretamente (usar `AnimateColorDelay` encadeado) | ✅ `OnFinish` nativo |
| Loop | Não | ✅ `Loop := True` |
| AutoReverse | Não | ✅ `AutoReverse := True` |
| Pausa/Retomada | Via `StopAnimation` | Via `Stop` / `Start` |
| Uso típico | Hover, click feedback, transição simples | Animação pulsante, loop, encadeamento |

---

## TAnimator.AnimateColor — uso

```pascal
uses FMX.Ani;

// Animar cor de fundo — simples e direto
TAnimator.AnimateColor(RecCard, 'Fill.Color', $FFF0F7FF, 0.15);

// Com duração e sem outros parâmetros (Linear por padrão para cores)
TAnimator.AnimateColor(RecCard, 'Stroke.Color', $FF3498DB, 0.15);

// Com delay
TAnimator.AnimateColorDelay(RecCard, 'Fill.Color', $FFFFFFFF, 0.15, 0.05);
```

**Quando usar:** hover, click feedback, transições simples de estado.

**Limitações:**
- Não há callback OnFinish nativo
- Não tem loop nativo
- Se chamar AnimateColor em uma propriedade que já está sendo animada,
  a animação anterior é sobrescrita (sem conflito, mas sem sequenciamento)

---

## TColorAnimation — uso

```pascal
uses FMX.Ani;

// Animação pulsante em loop
var Anim: TColorAnimation;
Anim := TColorAnimation.Create(RecAlerta);
Anim.Parent       := RecAlerta;   // filho do controle — alvo automático
Anim.PropertyName := 'Fill.Color';
Anim.StartValue   := $FFFFFFFF;   // branco
Anim.StopValue    := $FFFF5252;   // vermelho
Anim.Duration     := 0.80;
Anim.Loop         := True;
Anim.AutoReverse  := True;         // vai e volta — efeito "pulsar"
Anim.Interpolation := TInterpolationType.Sinusoidal;
Anim.AnimationType := TAnimationType.InOut;
Anim.Start;

// Para parar:
Anim.Stop;
// Ou:
TAnimator.StopAnimation(RecAlerta, 'Fill.Color');
```

**OnFinish para encadeamento:**

```pascal
var Anim: TColorAnimation;
Anim := TColorAnimation.Create(RecCard);
Anim.Parent       := RecCard;
Anim.PropertyName := 'Fill.Color';
Anim.StartValue   := $FFFFFFFF;
Anim.StopValue    := $FF3498DB;
Anim.Duration     := 0.30;
Anim.OnFinish := procedure(Sender: TObject)
begin
  // Executar próxima etapa após a cor terminar de animar
  IniciarProximaAnimacao;
  Anim.Free; // liberar se não for reutilizar
end;
Anim.Start;
```

---

## Configuração em design-time (.fmx)

No Form Designer, selecione um TRectangle e adicione um filho `TColorAnimation`:

```xml
<!-- No arquivo .fmx -->
<TRectangle Name="RecCard" ...>
  <TColorAnimation Name="AnimHover"
    PropertyName="Fill.Color"
    StartValue="$FFFFFFFF"
    StopValue="$FFF0F7FF"
    Duration="0.15"
    Trigger="MouseEnter"
    TriggerInverse="MouseLeave"
  />
</TRectangle>
```

**Trigger values:**
- `MouseEnter` — inicia ao entrar com mouse
- `MouseLeave` — inicia ao sair com mouse
- `IsMouseOver=true` — enquanto mouse está sobre
- `IsFocused=true` — quando recebe foco

---

## Tabela de decisão

| Necessidade | Usar |
|-------------|------|
| Hover simples (cor muda ao entrar/sair) | `TAnimator.AnimateColor` no OnMouseEnter/Leave |
| Animação pulsante ou loop | `TColorAnimation` com `Loop=True, AutoReverse=True` |
| Executar código após a cor mudar | `TColorAnimation` com `OnFinish` |
| Configurar visualmente no designer | `TColorAnimation` (design-time) |
| Sequenciar: cor A → cor B → cor C | `TColorAnimation` encadeadas via `OnFinish` |
| Rápido one-shot sem overhead | `TAnimator.AnimateColor` |

---

## Limitação importante: Fill.Kind deve ser Solid

```pascal
// ANTES de animar Fill.Color, garantir que Fill.Kind = Solid
if ACard.Fill.Kind <> TBrushKind.Solid then
  ACard.Fill.Kind := TBrushKind.Solid;

// Se Fill.Kind = Gradient, AnimateColor não tem efeito!
TAnimator.AnimateColor(ACard, 'Fill.Color', $FFF0F7FF, 0.15);
```

---

## Parar animação em andamento

```pascal
// Parar animação específica de propriedade
TAnimator.StopAnimation(RecCard, 'Fill.Color');

// Parar todas as animações do controle
TAnimator.StopAllAnimation(RecCard);

// Via objeto TColorAnimation:
MinhaAnim.Stop;
```

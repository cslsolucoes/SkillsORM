---
name: developer-delphi-fmx-animations
version: 1.0.0
description: >
  Animações FMX no Delphi: TAnimator (runtime), TFloatAnimation / TColorAnimation
  (design-time e runtime), todos os TInterpolationType, padrões de cascade, hover,
  modal, tab-switch e lazy-load. Foco em GestorERP.
tags: [delphi, fmx, animations, interpolation, gesture, gestorerp]
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-fmx-animations — V1.0.0

## Escopo

Cobre **toda a API de animações do FMX**: `TAnimator` (animação programática de qualquer
propriedade publicada `Single`, `TAlphaColor`, `TRectF`), classes declarativas
`TFloatAnimation` / `TColorAnimation` / `TRectAnimation` / `TPathAnimation`, e padrões de uso
no projeto GestorERP (entrada de tela, hover, modal, tab-switch, lazy-load).

Para containers e layout → `developer-delphi-fmx-containers_V1.0.0`.
Para efeitos GPU (shadow, blur, glow) → `developer-delphi-fmx-effects_V1.0.0`.

---

## § 1 — TAnimator: animação programática (runtime)

```pascal
uses FMX.Ani;

// AnimateFloat — anima propriedade Single publicada
TAnimator.AnimateFloat(
  Target,          // componente alvo
  'Opacity',       // nome da propriedade (published, tipo Single)
  1.0,             // valor final
  0.3,             // duração em segundos
  TAnimationType.InOut,       // tipo de easing (In / Out / InOut)
  TInterpolationType.Cubic    // curva de interpolação
);

// AnimateColor — anima TAlphaColor
TAnimator.AnimateColor(
  RecCard,
  'Fill.Color',    // propriedade aninhada: caminho com ponto
  $FF3498DB,
  0.2
);

// AnimateFloatDelay — com delay inicial
TAnimator.AnimateFloatDelay(RecCard, 'Opacity', 1.0, 0.3, 0.1); // delay 0.1s

// Parar animação em andamento
TAnimator.StopAnimation(RecCard, 'Opacity');

// Parar TODAS as animações do componente
TAnimator.StopAllAnimation(RecCard);
```

**Propriedades animáveis mais comuns:**

| Caminho | Tipo | Exemplo |
|---------|------|---------|
| `'Opacity'` | Single | fade in/out |
| `'Position.X'` | Single | deslizar horizontal |
| `'Position.Y'` | Single | deslizar vertical |
| `'Width'` | Single | expandir/colapsar |
| `'Height'` | Single | expandir/colapsar |
| `'RotationAngle'` | Single | rotação |
| `'Scale.X'` / `'Scale.Y'` | Single | zoom |
| `'Fill.Color'` | TAlphaColor | mudança de cor |
| `'Stroke.Color'` | TAlphaColor | cor da borda |

---

## § 2 — Animações declarativas (TFloatAnimation, TColorAnimation)

```pascal
uses FMX.Ani;

// TFloatAnimation — criação em runtime (equivalente ao design-time)
var Anim := TFloatAnimation.Create(RecCard);
Anim.Parent       := RecCard;       // OBRIGATÓRIO: pai = componente que anima
Anim.PropertyName := 'Opacity';
Anim.StartValue   := 0;
Anim.StopValue    := 1;
Anim.Duration     := 0.3;
Anim.Delay        := 0;
Anim.Interpolation := TInterpolationType.Cubic;
Anim.AnimationType := TAnimationType.Out;
Anim.Loop         := False;
Anim.AutoReverse  := False;
Anim.Trigger      := '';            // vazio = disparar via Start
Anim.TriggerInverse := '';
Anim.OnFinish     := OnAnimacaoFim;
Anim.Start;

// TColorAnimation — idêntico mas para TAlphaColor
var AnimCor := TColorAnimation.Create(RecCard);
AnimCor.Parent       := RecCard;
AnimCor.PropertyName := 'Fill.Color';
AnimCor.StartValue   := $FFF0F0F0;
AnimCor.StopValue    := $FF3498DB;
AnimCor.Duration     := 0.2;
AnimCor.Start;
```

### Triggers declarativos (design-time / .fmx)
```
// No .fmx: animação disparada automaticamente por Trigger
object AnimFade: TFloatAnimation
  Parent = RecCard          // pai = componente alvo
  PropertyName = 'Opacity'
  Duration = 0.300000000000000000
  StartValue = 0.000000000000000000
  StopValue = 1.000000000000000000
  Trigger = 'IsVisible=true'   // dispara quando Visible ficar True
  TriggerInverse = 'IsVisible=false'
end
```

---

## § 3 — TInterpolationType — todas as curvas

| Tipo | Comportamento | Uso recomendado |
|------|---------------|----------------|
| `Linear` | Velocidade constante | barras de progresso |
| `Quadratic` | Suave aceleração/desaceleração | movimentos gerais |
| `Cubic` | Mais acentuado que Quadratic | padrão recomendado ★ |
| `Quartic` | Muito acentuado | entradas dramáticas |
| `Quintic` | Extremamente acentuado | raramente usado |
| `Sinusoidal` | Curva senoidal suave | oscilações |
| `Exponential` | Aceleração exponencial | zoom out → parar |
| `Circular` | Baseado em arco de círculo | movimentos naturais |
| `Elastic` | Mola com oscilação | alertas, notificações |
| `Back` | Ultrapassa o target e volta | botões interativos ★ |
| `Bounce` | Quica como bola | gamification, sucesso |

### TAnimationType — entrada, saída, ou ambos

| Tipo | Comportamento |
|------|---------------|
| `In` | Acelera no início |
| `Out` | Desacelera no final (mais natural) ★ |
| `InOut` | Suave nos dois extremos |

---

## § 4 — Padrões prontos GestorERP

### Animação de entrada de tela (fade + slide)
```pascal
// Chamar no AfterShow ou após carregar dados
procedure AnimarEntradaTela(AControl: TControl);
begin
  AControl.Opacity := 0;
  AControl.Position.Y := AControl.Position.Y + 20; // começa 20px abaixo

  TAnimator.AnimateFloat(AControl, 'Opacity', 1.0, 0.35,
    TAnimationType.Out, TInterpolationType.Cubic);
  TAnimator.AnimateFloat(AControl, 'Position.Y', AControl.Position.Y - 20, 0.35,
    TAnimationType.Out, TInterpolationType.Cubic);
end;
```

### Hover em card (cor de fundo)
```pascal
RecCard.OnMouseEnter := procedure(Sender: TObject)
begin
  TAnimator.AnimateColor(Sender as TControl, 'Fill.Color',
    $FFF0F7FF, 0.15); // azul muito claro
end;

RecCard.OnMouseLeave := procedure(Sender: TObject)
begin
  TAnimator.AnimateColor(Sender as TControl, 'Fill.Color',
    $FFFFFFFF, 0.15); // volta ao branco
end;
```

### Modal: entrada com scale + opacity
```pascal
procedure AbrirModal(AModal: TControl);
begin
  AModal.Visible := True;
  AModal.Opacity := 0;
  AModal.Scale.X := 0.85;
  AModal.Scale.Y := 0.85;

  TAnimator.AnimateFloat(AModal, 'Opacity', 1.0, 0.25,
    TAnimationType.Out, TInterpolationType.Cubic);
  TAnimator.AnimateFloat(AModal, 'Scale.X', 1.0, 0.25,
    TAnimationType.Out, TInterpolationType.Back);
  TAnimator.AnimateFloat(AModal, 'Scale.Y', 1.0, 0.25,
    TAnimationType.Out, TInterpolationType.Back);
end;

procedure FecharModal(AModal: TControl);
begin
  TAnimator.AnimateFloat(AModal, 'Opacity', 0, 0.2,
    TAnimationType.In, TInterpolationType.Cubic);
  TAnimator.AnimateFloatWait(AModal, 'Scale.X', 0.85, 0.2); // bloqueante
  AModal.Visible := False;
end;
```

### Tab-switch (troca de painel ativo)
```pascal
procedure TrocarTab(APainelAtivo, APainelNovo: TControl);
begin
  // Fade out do ativo
  TAnimator.AnimateFloat(APainelAtivo, 'Opacity', 0, 0.15);
  TAnimator.AnimateFloatDelay(APainelNovo, 'Opacity', 1.0, 0.15, 0.15);
  // Após 0.15s: mostrar novo, esconder antigo
  APainelNovo.Visible := True;
  APainelNovo.Opacity := 0;
  APainelAtivo.Visible := False;
end;
```

### Animação em cascata (stagger)
```pascal
// Animar N itens com delay crescente
for I := 0 to LayoutItens.ControlsCount - 1 do
begin
  var Ctrl := LayoutItens.Controls[I];
  Ctrl.Opacity := 0;
  Ctrl.Position.Y := Ctrl.Position.Y + 16;
  TAnimator.AnimateFloatDelay(Ctrl, 'Opacity', 1.0, 0.3, I * 0.06);
  TAnimator.AnimateFloatDelay(Ctrl, 'Position.Y',
    Ctrl.Position.Y - 16, 0.3, I * 0.06);
end;
```

---

## § 5 — OnFinish: encadeamento de animações

```pascal
var Anim := TFloatAnimation.Create(RecCard);
Anim.Parent := RecCard;
Anim.PropertyName := 'Opacity';
Anim.StartValue   := 0;
Anim.StopValue    := 1;
Anim.Duration     := 0.3;
Anim.OnFinish := procedure(Sender: TObject)
begin
  // Segunda animação ao terminar a primeira
  TAnimator.AnimateFloat(RecCard, 'Position.X', 100, 0.2);
  Anim.Free; // liberar a animação declarativa após uso
end;
Anim.Start;
```

---

## § 6 — Lazy-load + animação (padrão GestorERP)

```pascal
// Carregar e animar conteúdo apenas na primeira exibição
procedure TFormTela.RecFundoResize(Sender: TObject);
begin
  if (RecFundo.ControlsCount = 0) then
  begin
    CarregarConteudo;                    // criar os controles
    AnimarEntradaItens;                  // animar logo após criar
  end;
end;

procedure TFormTela.AnimarEntradaItens;
var I: Integer;
begin
  for I := 0 to LayoutItens.ControlsCount - 1 do
  begin
    var C := LayoutItens.Controls[I];
    C.Opacity := 0;
    TAnimator.AnimateFloatDelay(C, 'Opacity', 1.0, 0.25, I * 0.05);
  end;
end;
```

---

## Arquivos de referência

| Arquivo | Conteúdo |
|---------|----------|
| `exemplos/animacoes_basicas.pas` | AnimateFloat, AnimateColor, delay, stop |
| `exemplos/animacoes_cor.pas` | TColorAnimation, hover, estado ativo |
| `exemplos/interpolacoes.pas` | Demo visual de todos os TInterpolationType |
| `exemplos/animacoes_declarativas.pas` | TFloatAnimation como objeto, TriggerInverse |
| `exemplos/animacao_cascata.pas` | stagger de N itens com delay crescente |
| `exemplos/hover_animation.pas` | hover card completo com color + scale |
| `exemplos/tab_switch_animation.pas` | tab com fade entre painéis |
| `exemplos/lazy_load_pattern.pas` | RecFundoResize + animate após load |
| `consultas_rapidas/interpolacoes_tabela.md` | todos os tipos com timing |
| `consultas_rapidas/propriedades_animaveis.md` | lista completa de caminhos |
| `consultas_rapidas/animatecolor_vs_tanimation.md` | quando usar cada abordagem |
| `consultas_rapidas/padroes_prontos.md` | copy-paste: modal, tab, hover, cascade |
| `templates/TEMPLATE_animacao_entrada.pas` | animação de entrada reutilizável |
| `templates/TEMPLATE_animacao_saida.pas` | saída com callback para destruir |
| `templates/TEMPLATE_hover_card.pas` | card completo com hover + scale |

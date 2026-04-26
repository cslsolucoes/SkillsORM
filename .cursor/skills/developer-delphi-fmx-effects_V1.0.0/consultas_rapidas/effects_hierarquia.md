# Effects — Hierarquia e múltiplos efeitos

## Hierarquia TEffect

```
TFmxObject
└── TEffect (base abstrata)
    ├── TBlurEffect          — desfoque gaussiano (Softness: Single)
    ├── TShadowEffect        — sombra projetada (Distance, Direction, ShadowColor)
    ├── TGlowEffect          — brilho externo (GlowColor, Softness)
    ├── TInnerGlowEffect     — brilho interno (GlowColor, Softness)
    ├── TReflectionEffect    — reflexo espelhado abaixo (Length, Opacity)
    ├── TBevelEffect         — relevo/chanfro (Width)
    ├── TColorMatrixEffect   — transformação de cor (ColorMatrix: TColorMatrix)
    ├── TPixelShaderEffect   — shader HLSL customizado
    └── TMonochromeEffect    — escala de cinza
```

Todos os efeitos herdam de `TEffect` e são adicionados como **filhos** do controle alvo.

---

## Como adicionar um efeito em runtime

```pascal
uses FMX.Effects;

// Padrão: criar → Parent := AControl → configurar → pronto
var Shadow := TShadowEffect.Create(RecCard);
Shadow.Parent := RecCard;  // OBRIGATÓRIO — não usar Owner
Shadow.Softness := 0.3;
Shadow.Distance := 4;
```

**Propriedade `Parent`** é obrigatória — sem ela o efeito não é renderizado.

---

## Múltiplos efeitos no mesmo controle

```pascal
// Sombra + glow no mesmo componente (possível, mas custoso)
var S := TShadowEffect.Create(Rec);  S.Parent := Rec;
var G := TGlowEffect.Create(Rec);   G.Parent := Rec;
```

Ordem de renderização: os efeitos são aplicados na ordem de inserção (índice 0 primeiro).

---

## Iteração sobre Effects collection

```pascal
// Verificar se já existe um efeito de determinado tipo
var I: Integer;
for I := 0 to AControl.Effects.Count - 1 do
  if AControl.Effects[I] is TBlurEffect then
    Exit; // já existe

// Remover efeito pelo índice
if RecCard.Effects.Count > 0 then
  RecCard.Effects[0].Free;

// Remover efeito por tipo
for I := AControl.Effects.Count - 1 downto 0 do
  if AControl.Effects[I] is TGlowEffect then
  begin
    AControl.Effects[I].Free;
    Break;
  end;
```

Iterar em **ordem reversa** ao remover para evitar index shift.

---

## Habilitar/desabilitar por performance

```pascal
Shadow.Enabled := False;  // desabilita sem destruir
Shadow.Enabled := True;   // reabilita
```

Usar `Enabled := False` quando o componente está fora da área visível.

---

## Custo GPU (menor → maior)

| Posição | Efeito | Custo relativo |
|---------|--------|----------------|
| 1 | TShadowEffect | baixo |
| 2 | TReflectionEffect | baixo-médio |
| 3 | TGlowEffect / TInnerGlowEffect | médio |
| 4 | TBlurEffect | alto |

**Regras práticas:**
- Máximo 2 efeitos por controle visível
- TBlurEffect: evitar em listas ou componentes que se movem
- TShadowEffect: custo proporcional ao Distance e Softness
- Desabilitar efeitos de controles fora da viewport

---

## ClipChildren — regra crítica

```pascal
// OBRIGATÓRIO para sombra, glow e reflexo não serem cortados
AControl.ClipChildren := False;
```

`ClipChildren = True` (padrão em alguns containers) corta qualquer renderização
fora dos limites do controle — isso inclui sombras e glows externos.

Não é necessário para TBlurEffect (blur ocorre dentro dos limites).

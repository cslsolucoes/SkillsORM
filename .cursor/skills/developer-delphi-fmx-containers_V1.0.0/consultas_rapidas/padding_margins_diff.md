# Padding vs Margins — Diferença Completa

## Conceito fundamental

```
┌─────────────────────────────────────────┐
│           MARGINS (externo)             │
│  ┌───────────────────────────────────┐  │
│  │        COMPONENTE ATUAL           │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │      PADDING (interno)      │  │  │
│  │  │  ┌───────────────────────┐  │  │  │
│  │  │  │    ÁREA DOS FILHOS    │  │  │  │
│  │  │  └───────────────────────┘  │  │  │
│  │  └─────────────────────────────┘  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## Tabela comparativa

| Aspecto | Padding | Margins |
|---------|---------|---------|
| **Onde age** | Dentro do componente | Fora do componente |
| **Quem é afetado** | Os filhos deste componente | Os vizinhos / o pai |
| **Background preenchido** | Sim (inclui o padding) | Não (fora do componente) |
| **Propriedade** | `Padding.Left/Top/Right/Bottom` | `Margins.Left/Top/Right/Bottom` |
| **Tipo** | `TBounds` | `TBounds` |
| **Efeito em Align=Client** | Reduz a área disponível para o filho | Reduz o espaço que este ocupa no pai |
| **Efeito em Align=Top** | —— | Adiciona espaço acima e abaixo |
| **Análogo CSS** | `padding` | `margin` |

## Exemplos visuais

### Padding — espaço interno

```pascal
RecCard.Width  := 200;
RecCard.Height := 100;
RecCard.Fill.Color := $FF3498DB;  // azul

RecCard.Padding.Left   := 16;
RecCard.Padding.Top    := 16;
RecCard.Padding.Right  := 16;
RecCard.Padding.Bottom := 16;

// Filho com Align=Client ocupa 168x68 (200-32 x 100-32)
// O azul aparece em toda a área do card, incluindo as bordas de 16px
var Filho := TRectangle.Create(Self);
Filho.Parent := RecCard;
Filho.Align  := TAlignLayout.Client;  // 168x68
```

### Margins — espaço externo

```pascal
// 3 retângulos com Align=Top empilhados
RecA.Align  := TAlignLayout.Top;
RecA.Height := 40;
RecA.Margins.Bottom := 8;  // 8px de espaço ABAIXO do RecA

RecB.Align  := TAlignLayout.Top;
RecB.Height := 40;
RecB.Margins.Left  := 20;  // recua 20px da esquerda
RecB.Margins.Right := 20;  // recua 20px da direita
// RecB ficará mais estreito e deslocado — Margins REDUZEM o espaço disponível

RecC.Align  := TAlignLayout.Top;
RecC.Height := 40;
// sem Margins — ocupa a largura total disponível
```

## Quando usar cada um

### Use Padding quando:
- Quer espaço interno em um container (card, header, panel)
- Quer que o fundo colorido apareça até as bordas
- Os filhos devem ficar afastados das bordas do pai

```pascal
// Card com espaçamento interno
RecCard.Padding.Left   := 16;
RecCard.Padding.Top    := 12;
RecCard.Padding.Right  := 16;
RecCard.Padding.Bottom := 12;
```

### Use Margins quando:
- Quer espaço entre componentes irmãos (em uma lista)
- Quer deslocar um componente sem mudar sua posição absoluta
- Está usando Align != None e precisa de espaçamento

```pascal
// Lista de items com espaço entre eles
RecItem.Align          := TAlignLayout.Top;
RecItem.Height         := 48;
RecItem.Margins.Top    := 4;
RecItem.Margins.Bottom := 4;
```

## Caso especial: Padding no Scroll

```pascal
// TVertScrollBox com Padding aplicado ao conteúdo
var Scroll := TVertScrollBox.Create(Self);
Scroll.Parent := Self;
Scroll.Align  := TAlignLayout.Client;

// Padding no Scroll cria espaço interno ANTES do conteúdo começar
// (menos comum — preferir Padding no container de conteúdo interno)
Scroll.Padding.Left  := 16;
Scroll.Padding.Right := 16;

// Alternativa mais controlada: Padding no TLayout interno
var Layout := TLayout.Create(Self);
Layout.Parent := Scroll;
Layout.Align  := TAlignLayout.Top;
Layout.Padding.Left   := 16;
Layout.Padding.Top    := 16;
Layout.Padding.Right  := 16;
Layout.Padding.Bottom := 16;
```

## Combinando Padding + Margins

```pascal
// Container externo com Padding
RecLista.Padding.Left  := 12;
RecLista.Padding.Right := 12;

// Item com Margins (espaço entre itens)
RecItem.Align          := TAlignLayout.Top;
RecItem.Height         := 56;
RecItem.Margins.Bottom := 8;  // espaço entre itens

// Resultado: item fica 12px afastado das laterais (Padding do pai)
//            + 8px de espaço abaixo (Margin do próprio item)
```

## No .fmx (design-time)

```
object RecCard: TRectangle
  Padding.Left   = 16.000000000000000000
  Padding.Top    = 16.000000000000000000
  Padding.Right  = 16.000000000000000000
  Padding.Bottom = 16.000000000000000000
  ...
  object RecItem: TRectangle
    Margins.Bottom = 8.000000000000000000
    Align = Top
    Height = 48.000000000000000000
  end
end
```

## Observações importantes

1. **Padding não tem efeito em filhos com Align=None** — a posição manual ignora o Padding do pai; use Position.X/Y considerando o Padding manualmente
2. **Margins em Align=None** — também ignoradas; use Position.X/Y
3. **Margins.Left em Align=Top** — funciona! Reduz a largura disponível do lado esquerdo
4. **ClipChildren e Padding** — Padding não afeta o clip; filhos com Align=None podem sair do bounds mesmo com Padding

# TAlignLayout — Tabela Completa

## Valores e comportamento

| Valor | Ocupa Largura | Ocupa Altura | Comportamento | Uso típico |
|-------|---------------|--------------|---------------|------------|
| `None` | Não | Não | Position.X/Y manual | Elementos flutuantes, drag-and-drop, animados por Position |
| `Top` | Total do pai | Fixa (Height) | Ancora ao topo, largura automática | Header, toolbar, barra de busca, título |
| `Bottom` | Total do pai | Fixa (Height) | Ancora à base, largura automática | Footer, barra de ações, status bar |
| `Left` | Fixa (Width) | Total do pai | Ancora à esquerda, altura automática | Sidebar, coluna de ícones, menu lateral |
| `Right` | Fixa (Width) | Total do pai | Ancora à direita, altura automática | Painel de detalhes, ações contextuais |
| `Client` | Restante | Restante | Preenche tudo após Top/Bottom/Left/Right | Conteúdo principal, área de trabalho |
| `Center` | Fixa (Width) | Fixa (Height) | Centraliza no pai sem redimensionar | Ícones, avatares, badges, logos |
| `Contents` | Total do pai | Total do pai | Sobreposição completa (ignora outros Align) | Overlay, fundo de modal, fundo fosco |
| `Scale` | Proporcional | Proporcional | Escala mantendo aspect ratio | Imagens de fundo, wallpapers |
| `Fit` | Ajustada | Ajustada | Cabe dentro do pai mantendo proporção | Thumbnails, imagens em cards |
| `FitLeft` | Ajustada | Ajustada | Fit + alinha à esquerda | Imagem à esquerda de um card |
| `FitRight` | Ajustada | Ajustada | Fit + alinha à direita | Imagem à direita de um card |
| `HorzCenter` | Total do pai | Fixa (Height) | Centraliza horizontalmente, respeita Y | Títulos centralizados com Y fixo |
| `VertCenter` | Fixa (Width) | Total do pai | Centraliza verticalmente, respeita X | Ícones em barra vertical |
| `Horizontal` | Distribui | Fixa (Height) | Filhos lado a lado da esquerda p/ direita | Barras de ferramentas, tabs |
| `Vertical` | Fixa (Width) | Distribui | Filhos empilhados de cima p/ baixo | Listas de campos, formulários |
| `MostTop` | Total do pai | Fixa (Height) | Prioridade máxima no topo (sobre outros Top) | Notificações, avisos sobrepostos |
| `MostBottom` | Total do pai | Fixa (Height) | Prioridade máxima na base | Teclado virtual, banners |
| `MostLeft` | Fixa (Width) | Total do pai | Prioridade máxima à esquerda | Painéis fixos importantes |
| `MostRight` | Fixa (Width) | Total do pai | Prioridade máxima à direita | Painéis fixos importantes |

## Ordem de avaliação do Align

O FMX avalia o Align na seguinte ordem dentro de um pai:
1. `Contents` (sobreposição total)
2. `MostTop`, `MostBottom`, `MostLeft`, `MostRight`
3. `Top`, `Bottom`, `Left`, `Right`
4. `Client` (ocupa o restante)
5. `Center`, `HorzCenter`, `VertCenter`
6. `None` (manual)

**Implicação:** sempre crie componentes com `Top`/`Bottom`/`Left`/`Right` antes de `Client`.

## Receitas de layouts comuns

### Header fixo + Conteúdo scrollável
```pascal
RecHeader.Align  := TAlignLayout.Top;    // Height = 76
Scroll.Align     := TAlignLayout.Client;
```

### Sidebar + Conteúdo
```pascal
RecSidebar.Align := TAlignLayout.Left;   // Width = 227
RecBody.Align    := TAlignLayout.Client;
```

### Header + Footer + Conteúdo
```pascal
RecHeader.Align  := TAlignLayout.Top;    // Height = 76
RecFooter.Align  := TAlignLayout.Bottom; // Height = 60  — ANTES de Client
RecBody.Align    := TAlignLayout.Client;
```

### Modal overlay (sobre tudo)
```pascal
RecOverlay.Align := TAlignLayout.Contents;
RecOverlay.Fill.Color := $80000000; // preto 50% opaco
```

### Card centralizado
```pascal
RecCard.Align  := TAlignLayout.Center;
RecCard.Width  := 400;
RecCard.Height := 300;
```

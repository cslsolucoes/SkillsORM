# Propriedades Animáveis no FMX — Referência Completa

## Regra geral

**Qualquer propriedade `published` do tipo `Single` ou `TAlphaColor` pode ser animada.**

```pascal
// TAnimator.AnimateFloat(Target, 'NomeDaPropriedade', ValorFinal, Duracao)
// TAnimator.AnimateColor(Target, 'NomeDaPropriedade', CorFinal, Duracao)
```

Propriedades aninhadas são acessadas via ponto: `'Fill.Color'`, `'Scale.X'`.

## Propriedades Single (AnimateFloat)

### Posição e tamanho
| Caminho | Tipo | Exemplo de uso |
|---------|------|----------------|
| `'Position.X'` | Single | slide horizontal |
| `'Position.Y'` | Single | slide vertical |
| `'Width'` | Single | expandir/colapsar sidebar |
| `'Height'` | Single | expandir/colapsar panel |

### Visibilidade
| Caminho | Tipo | Exemplo de uso |
|---------|------|----------------|
| `'Opacity'` | Single (0.0–1.0) | fade in/out |

### Transformação
| Caminho | Tipo | Exemplo de uso |
|---------|------|----------------|
| `'RotationAngle'` | Single (graus) | girar ícone de loading |
| `'Scale.X'` | Single (fator) | zoom horizontal |
| `'Scale.Y'` | Single (fator) | zoom vertical |
| `'RotationCenter.X'` | Single (0.0–1.0) | pivô de rotação |
| `'RotationCenter.Y'` | Single (0.0–1.0) | pivô de rotação |

### Borda
| Caminho | Tipo | Exemplo de uso |
|---------|------|----------------|
| `'Stroke.Thickness'` | Single | engrossar/afinar borda no hover |
| `'XRadius'` | Single | mudar arredondamento de canto |
| `'YRadius'` | Single | mudar arredondamento de canto |

### Efeitos
| Caminho | Tipo | Exemplo de uso |
|---------|------|----------------|
| `'Shadow.Distance'` | Single | sombra cresce no hover |
| `'Shadow.Softness'` | Single | sombra mais difusa |
| `'Blur.Softness'` | Single | aumentar/diminuir blur |
| `'Glow.Softness'` | Single | brilho animado |

### Layout
| Caminho | Tipo | Exemplo de uso |
|---------|------|----------------|
| `'Padding.Left'` | Single | animar padding interno |
| `'Padding.Right'` | Single | idem |
| `'Margins.Top'` | Single | animar margem superior |

## Propriedades TAlphaColor (AnimateColor)

| Caminho | Tipo | Exemplo de uso |
|---------|------|----------------|
| `'Fill.Color'` | TAlphaColor | hover background |
| `'Stroke.Color'` | TAlphaColor | hover border color |
| `'TextSettings.FontColor'` | TAlphaColor | texto muda de cor (TLabel) |
| `'Shadow.ShadowColor'` | TAlphaColor | sombra muda de cor |
| `'Glow.GlowColor'` | TAlphaColor | glow muda de cor |

## Propriedades NÃO animáveis diretamente

| Propriedade | Tipo | Por que não anima |
|-------------|------|-------------------|
| `'Visible'` | Boolean | não é Single/Color |
| `'Align'` | TAlignLayout | enum, não numérico |
| `'Text'` | string | não numérico |
| `'Fill.Kind'` | TBrushKind | enum |
| `'Parent'` | TFmxObject | referência |

**Workaround para `Visible`**: animar `Opacity` de 1 → 0, depois setar `Visible := False` no `OnFinish`.

## Animação de propriedades aninhadas — profundidade ilimitada

```pascal
// Até 3 níveis de profundidade são suportados via string de caminho
TAnimator.AnimateFloat(RecCard, 'Fill.Gradient.Points[0].Offset', 0.5, 0.3);
TAnimator.AnimateFloat(RecItem, 'Margins.Top', 8, 0.2);
TAnimator.AnimateFloat(RecModal, 'Scale.X', 1.0, 0.25);
```

## Limitações conhecidas

1. **Gradientes**: animação de `Fill.Color` não funciona quando `Fill.Kind = Gradient` — precisa mudar para `Solid` antes
2. **Propriedades calculadas**: `Width` em Align=Client é ignorada (gerenciada pelo layout)
3. **Thread safety**: `TAnimator` deve ser chamado apenas da main thread (UI thread)
4. **Múltiplas animações**: chamadas simultâneas na mesma propriedade sobrescrevem a anterior — use delay para sequenciar

# FMX Scaling e DPI — Guia Rápido

## Como FMX trata scaling

FMX usa um sistema de coordenadas **independente de DPI**. Você define posições
e tamanhos em unidades lógicas; o engine escala para pixels físicos.

| Propriedade | Descrição |
|-------------|-----------|
| `Screen.Scale` | Fator de escala da tela (1.0 em 96dpi, 2.0 em 192dpi/Retina) |
| `Form.Scale` | Escala aplicada ao form (normalmente 1,1,1 — não alterar) |
| `Control.AbsoluteScale` | Escala efetiva do controle (inclui transforms pai) |

## Converter coordenadas lógicas ↔ físicas

```pascal
// Logico -> Fisico (para APIs nativas)
var FisicoX := Round(ControleX * Screen.Scale);

// Fisico -> Logico (de eventos de touch)
var LogicoX := PhysX / Screen.Scale;
```

## ScreenScale no GestorERP

```pascal
// Verificar escala para renderizacao de bitmaps
var Scale := Screen.Scale; // 1.0, 1.5, 2.0, 3.0

// Criar bitmap no tamanho fisico correto
var Bmp := TBitmap.Create(Round(100 * Scale), Round(100 * Scale));
Bmp.BitmapScale := Scale;
```

## NativeDrawing — desenho direto via canvas nativo

```pascal
// Disponivel em Windows/macOS para performance maxima
// No TControl.OnPaint:
procedure TFrmEx.FormPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
  Canvas.BeginScene;
  try
    Canvas.Fill.Color := $FF3498DB;
    Canvas.FillRect(ARect, 6, 6, AllCorners, 1.0);
    Canvas.DrawRect(ARect, 6, 6, AllCorners, 1.0);
  finally
    Canvas.EndScene;
  end;
end;
```

## Fontes e DPI

```pascal
// FMX escala fontes automaticamente com Screen.Scale
// Nao multiplicar tamanho por Scale — o engine ja faz isso
Label.TextSettings.Font.Size := 14; // 14pt logicos — correto

// ERRADO: calcular em pixels manualmente
Label.TextSettings.Font.Size := Round(14 * Screen.Scale); // duplica escala
```

## Imagens em diferentes densidades

FMX suporta sufixos para imagens multi-densidade:

| Sufixo | Densidade |
|--------|----------|
| (sem sufixo) | 1x (96dpi) |
| `@1.5x` | 1.5x (144dpi) |
| `@2x` | 2x (192dpi / Retina) |
| `@3x` | 3x (288dpi / mobile HD) |

```
icone.png       ← 32x32 px
icone@2x.png    ← 64x64 px (Retina)
```

FMX escolhe automaticamente baseado em `Screen.Scale`.

## Checklist DPI/Scaling

- [ ] Nunca hardcodar tamanhos em pixels — usar unidades lógicas
- [ ] Imagens críticas fornecer versão `@2x`
- [ ] Bitmaps criados via código: multiplicar por `Screen.Scale`
- [ ] Não multiplicar `Font.Size` por `Scale`
- [ ] Testar em dispositivo Retina / Windows com 150% DPI

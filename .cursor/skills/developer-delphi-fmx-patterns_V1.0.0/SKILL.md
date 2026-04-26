---
name: developer-delphi-fmx-patterns
description: Padrões visuais e de interação FMX no GestorERP — responsividade, modais, feedback e navegação.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-fmx-patterns_V1.0.0

## O que é esta skill

Skill especializada em **padrões visuais e de interação FMX** do GestorERP:
drag sem titlebar, TStyleBook, arc progress, CRUD completo com confirmação.

Estes padrões aparecem repetidamente no projeto e são implementados de forma
específica — diferente do que a documentação oficial sugere.

---

## Quando usar esta skill

- Implementar **drag de form sem titlebar** (login, splash, modais flutuantes)
- Aplicar **TStyleBook** para theming em runtime
- Criar **indicador de progresso circular** com `TArc` + `TAnimator`
- Implementar **CRUD completo** com `TDialogService` para confirmação de exclusão
- Entender **DPI/scaling** no FMX (ScreenScale, NativeDrawing)

---

## Padrões do GestorERP

### 1. Drag sem titlebar
```pascal
var FDragPos: TPointF;

// MouseDown no header
FDragPos := TPointF.Create(X, Y);

// MouseMove no header
if ssLeft in Shift then
begin
  Left := Left + Round(X - FDragPos.X);
  Top  := Top  + Round(Y - FDragPos.Y);
end;
```

### 2. Arc Progress circular
```pascal
Arc1.StartAngle := -90;
Arc1.EndAngle   := -90 + (Percentual / 100) * 360;
// Animar:
TAnimator.AnimateFloat(Arc1, 'EndAngle',
  -90 + (NovoPercentual / 100) * 360, 0.5,
  TAnimationType.Out, TInterpolationType.Cubic);
```

### 3. Confirmação de exclusão (TDialogService)
```pascal
TDialogService.MessageDialog('Excluir este registro?',
  TMsgDlgType.mtConfirmation, [mbYes, mbNo], mbNo, 0,
  procedure(const AResult: TModalResult)
  begin
    if AResult = mrYes then ExecutarExclusao;
  end);
```

### 4. TStyleBook em runtime
```pascal
StyleBook1.LoadFromFile('MeuEstilo.fsf');
Application.Style := StyleBook1;
```

---

## Arquivos desta skill

| Arquivo | Conteúdo |
|---------|---------|
| `exemplos/drag_sem_titlebar.pas` | Drag de form sem titlebar completo |
| `exemplos/estilo_customizado.pas` | TStyleBook em runtime |
| `exemplos/arcprogress_chart.pas` | TArc como progressbar circular |
| `exemplos/crud_padrao.pas` | CRUD com TDialogService confirm |
| `consultas_rapidas/stylebook_guia.md` | Como criar e aplicar TStyleBook |
| `consultas_rapidas/scaling_dpi.md` | FMX scaling: ScreenScale, DPI, NativeDrawing |
| `consultas_rapidas/padroes_gestorerp.md` | Catálogo de padrões do projeto |
| `templates/TEMPLATE_drag_form.pas` | Form draggável sem titlebar |
| `templates/TEMPLATE_crud_completo.pas` | CRUD com listagem + modal + confirmação |
| `templates/TEMPLATE_arc_progress.pas` | Arco de progresso animado |

---

## Skills relacionadas da Família A FMX

| Skill | Uso |
|-------|-----|
| `developer-delphi-fmx-layout_V1.1.0` | Orquestradora — visão geral FMX |
| `developer-delphi-fmx-animations_V1.0.0` | TAnimator, TFloatAnimation, TColorAnimation |
| `developer-delphi-fmx-frames_V1.0.0` | TFrame, herança visual, DestruirTudo |
| `developer-delphi-fmx-components_V1.0.0` | TListView, TMultiView, LiveBindings |

# Padrões do GestorERP — Catálogo de Padrões FMX

## 1. Drag sem Titlebar

**Onde usar:** Login, splash, modais flutuantes, forms decorativos

```pascal
type TFrmDrag = class(TForm)
private
  FDragPos: TPointF;
  procedure HeaderMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Single);
  procedure HeaderMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
end;

procedure TFrmDrag.HeaderMouseDown(...);
begin
  FDragPos := TPointF.Create(X, Y);
end;

procedure TFrmDrag.HeaderMouseMove(...);
begin
  if ssLeft in Shift then
  begin
    Left := Left + Round(X - FDragPos.X);
    Top  := Top  + Round(Y - FDragPos.Y);
  end;
end;
```

**Config do form:** `BorderStyle := TFmxFormBorderStyle.None`

---

## 2. DestruirTudo — Trocar Frames

**Onde usar:** Form principal ao navegar entre seções

```pascal
for I := RecConteiner.ControlsCount - 1 downto 0 do
  RecConteiner.Controls[I].Free;

FFrameAtivo := nil;
```

**SEMPRE downto 0** — forward delete causa AV.

---

## 3. Arc Progress Circular

**Onde usar:** Dashboard KPIs, indicadores percentuais

```pascal
Arc.StartAngle := -90;                          // topo
Arc.EndAngle   := -90 + (Percent / 100) * 360;

TAnimator.AnimateFloat(Arc, 'EndAngle',
  -90 + (NovoPercent / 100) * 360, 0.5,
  TAnimationType.Out, TInterpolationType.Cubic);
```

---

## 4. Confirmação de Exclusão

**Onde usar:** Qualquer operação destrutiva irreversível

```pascal
TDialogService.MessageDialog('Confirmar exclusao?',
  TMsgDlgType.mtConfirmation, [mbYes, mbNo], mbNo, 0,
  procedure(const AResult: TModalResult)
  begin
    if AResult = mrYes then ExecutarExclusao;
  end);
```

**Usar TDialogService** (async), não `MessageDlg` (bloqueia em mobile).

---

## 5. Modal com Overlay + Animação

**Onde usar:** Formulários de edição sem abrir nova janela

```pascal
// Criar frame com overlay semi-transparente
FrameModal := TFrameModalEdicao.Create(Self);
FrameModal.Parent := Self;
FrameModal.Align  := TAlignLayout.Client;
FrameModal.BringToFront;

// Fade in
TAnimator.AnimateFloat(FOverlay, 'Opacity', 1, 0.2);
```

---

## 6. Hover em Cards/Linhas

**Onde usar:** Listagens, cartões de dashboard

```pascal
procedure TLinhaItem.MouseEnter(Sender: TObject);
begin
  TAnimator.AnimateColor(Self, 'Fill.Color', $FFF0F4FF, 0.15);
end;

procedure TLinhaItem.MouseLeave(Sender: TObject);
begin
  TAnimator.AnimateColor(Self, 'Fill.Color', $FFFFFFFF, 0.15);
end;
```

**Não esquecer:** `Cursor := crHandPoint` em elementos clicáveis.

---

## 7. Automap edt* ↔ txt*

**Onde usar:** Formulários com muitos campos, modo leitura/edição

```pascal
// Modo leitura: ocultar TEdit, exibir TLabel com mesmo sufixo
if Comp.Name.StartsWith('edt') then
begin
  NomeLbl := 'txt' + Copy(Comp.Name, 4, MaxInt);
  Lbl := Frame.FindComponent(NomeLbl) as TLabel;
  Lbl.Text    := TEdit(Comp).Text;
  Lbl.Visible := True;
  Comp.Visible := False;
end;
```

---

## 8. Lazy-Load de Frames em Abas

**Onde usar:** TTabControl com dados pesados em cada aba

```pascal
procedure TabCtrlChange(Sender: TObject);
begin
  if TabCtrl.ActiveTab.ControlsCount = 0 then
    CriarFrameParaAba(TabCtrl.ActiveTab);
end;
```

---

## Checklist de padrões antes de produção

- [ ] Forms sem titlebar usam `BorderStyle = bsNone` + drag implementado
- [ ] Todas as exclusões passam por `TDialogService.MessageDialog`
- [ ] Troca de frames usa `DestruirTudo` (downto 0)
- [ ] Linhas clicáveis têm `Cursor = crHandPoint` + hover animado
- [ ] Arcos de progresso iniciam com `StartAngle = -90`
- [ ] Modais têm animação de entrada (fade + slide)
- [ ] Nenhum `MessageDlg` síncrono em código que rode em mobile

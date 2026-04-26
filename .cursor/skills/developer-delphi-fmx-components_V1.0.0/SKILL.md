---
name: developer-delphi-fmx-components
description: Componentes FMX avançados — TMultiView, LiveBindings, inputs especializados e padrões GestorERP.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-fmx-components_V1.0.0

## O que é esta skill

Cobre componentes FMX além dos básicos de layout: TMultiView, LiveBindings, inputs
(TEdit/TMemo/TComboBox), TListView customizado, TArc como progressbar, e diálogos
cross-platform com TDialogService. Parte da Família A — FMX Layout.

**Skill orquestradora:** `developer-delphi-fmx-layout_V1.1.0`

---

## §1 — TMultiView

```pascal
uses FMX.MultiView;

// Configuração básica em runtime
MultiView1.Mode := TMultiViewMode.Drawer;
MultiView1.DrawerOptions.Placement := TPlacement.Left;

// Abrir/fechar programaticamente
MultiView1.ShowMaster;
MultiView1.HideMaster;

// Verificar estado
if MultiView1.IsShown then
  MultiView1.HideMaster;
```

**Propriedades principais:**

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `Mode` | TMultiViewMode | Drawer, Panel, Popover, PlatformBehaviour |
| `MasterButton` | TControl | Botão hambúrguer que abre/fecha |
| `DrawerOptions.Placement` | TPlacement | Left, Right, Top, Bottom |
| `DrawerOptions.Overlap` | Boolean | Drawer sobrepõe conteúdo ou empurra |
| `DrawerOptions.TouchAreaSize` | Single | Largura da área de swipe para abrir |
| `ShadowOptions.Enabled` | Boolean | Sombra sob o drawer |

---

## §2 — LiveBindings

```pascal
uses Data.Bind.Components, Data.Bind.ObjectScope, Fmx.Bind.Editors;

// Binding simples: campo de objeto → Edit
var Binding: TLinkPropertyToField;
Binding := TLinkPropertyToField.Create(Self);
Binding.ComponentProperty := 'Text';
Binding.DataSource := BindSourceDB1;
Binding.FieldName  := 'Nome';

// Ativar todos os bindings
BindingsList1.Active := True;
```

**Componentes de LiveBindings:**
- `TBindingsList` — container de todos os bindings
- `TLinkControlToField` — bidirecional: Edit ↔ Field
- `TLinkPropertyToField` — unidirecional: propriedade ↔ field
- `TBindSourceDB` — data source para TDataSet

---

## §3 — Inputs: TEdit, TMemo, TComboBox, TDateEdit

```pascal
// TEdit — campo de texto
Edit1.Text        := 'valor';
Edit1.Password    := True;        // ocultar com *
Edit1.MaxLength   := 50;
Edit1.TextPrompt  := 'Digite aqui...'; // placeholder
Edit1.OnChange    := ProcOnChange;
Edit1.OnValidate  := ProcOnValidate;

// TMemo — texto multilinha
Memo1.Lines.Text  := 'texto\nmais texto';
Memo1.Lines.Add('nova linha');
Memo1.ScrollBy(0, Memo1.ContentBounds.Height); // scroll para o fim

// TComboBox — dropdown
ComboBox1.Items.Add('Item 1');
ComboBox1.Items.Add('Item 2');
ComboBox1.ItemIndex := 0;
var Sel: string := ComboBox1.Items[ComboBox1.ItemIndex];

// TDateEdit — seletor de data
DateEdit1.Date    := Now;
DateEdit1.Format  := 'dd/mm/yyyy';
var D: TDate := DateEdit1.Date;
```

---

## §4 — TListView com ItemAppearance customizado

```pascal
uses FMX.ListView, FMX.ListView.Types, FMX.ListView.Appearances;

// Configuração básica
ListView1.ItemAppearance.ItemAppearance := 'ImageListItem';
// Ou: 'ListItem', 'ImageListItem', 'ImageListItemRightButton'

// Adicionar itens programaticamente
var Item := ListView1.Items.Add;
Item.Text    := 'Título do item';
Item.Detail  := 'Detalhe secundário';

// Acessar item por índice
var Txt: string := ListView1.Items[0].Text;

// Item selecionado
if ListView1.ItemIndex >= 0 then
  ShowMessage(ListView1.Items[ListView1.ItemIndex].Text);
```

---

## §5 — TArc como progressbar circular

```pascal
uses FMX.Objects;

// TArc: StartAngle + SweepAngle = arco desenhado
Arc1.StartAngle := -90;          // começa do topo
Arc1.EndAngle   := -90 + 270;    // cobre 75% do círculo

// Calcular ângulo para porcentagem
procedure SetarProgresso(AArc: TArc; APct: Single);
begin
  AArc.EndAngle := AArc.StartAngle + (360 * APct / 100);
end;

// Animar progressbar
procedure AnimarProgresso(AArc: TArc; APercent: Single; ADuracao: Single = 0.40);
var
  AlvoAngulo: Single;
begin
  AlvoAngulo := AArc.StartAngle + (360 * APercent / 100);
  TAnimator.AnimateFloat(AArc, 'EndAngle', AlvoAngulo, ADuracao,
    TAnimationType.Out, TInterpolationType.Cubic);
end;
```

---

## §6 — TDialogService (cross-platform)

```pascal
uses FMX.DialogService;

// MessageDialog (não bloqueia — callback)
TDialogService.MessageDialog(
  'Deseja excluir este registro?',
  TMsgDlgType.mtConfirmation,
  [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
  TMsgDlgBtn.mbNo,
  0,
  procedure(const AResult: TModalResult)
  begin
    if AResult = mrYes then
      ExcluirRegistro;
  end);

// ShowMessage simples
TDialogService.ShowMessage('Salvo com sucesso!');

// InputQuery (pedir texto ao usuário)
TDialogService.InputQuery('Nome', ['Digite seu nome:'], [''],
  procedure(const AResult: Boolean; const AValues: array of string)
  begin
    if AResult and (AValues[0] <> '') then
      ProcessarNome(AValues[0]);
  end);
```

**Por que usar TDialogService:**
- Thread-safe: pode ser chamado de qualquer thread
- Cross-platform: funciona em Windows, macOS, iOS, Android
- Não bloqueia a UI thread (usa callback)
- `Application.MessageBox` é Windows-only e bloqueia

---

## §7 — progressbar_arc.pas — padrão GestorERP

O GestorERP usa arcos coloridos como indicadores de progresso em dashboards.
Ver exemplo completo em `exemplos/progressbar_arc.pas`.

Padrão de cores por domínio:
- Vendas: `$FF3498DB` (azul)
- Estoque: `$FF27AE60` (verde)
- Financeiro: `$FFD4AC0D` (dourado)
- Alertas: `$FFE74C3C` (vermelho)

---

## Arquivos desta skill

### exemplos/
- [tmultiview_uso.pas](exemplos/tmultiview_uso.pas) — TMultiView: modos, eventos, swipe
- [livebindings_basico.pas](exemplos/livebindings_basico.pas) — TBindingsList, TLinkControlToField
- [edit_components.pas](exemplos/edit_components.pas) — TEdit, TMemo, TComboBox, TDateEdit
- [listview_custom.pas](exemplos/listview_custom.pas) — TListView com ItemAppearance customizado
- [dialogs_fmx.pas](exemplos/dialogs_fmx.pas) — TDialogService.MessageDialog thread-safe
- [progressbar_arc.pas](exemplos/progressbar_arc.pas) — TArc como progressbar circular animado

### consultas_rapidas/
- [tmultiview_modos.md](consultas_rapidas/tmultiview_modos.md) — Drawer, Panel, Popover, PlatformBehaviour
- [livebindings_resumo.md](consultas_rapidas/livebindings_resumo.md) — TBindingsList, componentes e uso
- [dialogs_crossplatform.md](consultas_rapidas/dialogs_crossplatform.md) — TDialogService vs MessageBox

### templates/
- [TEMPLATE_multiview_drawer.pas](templates/TEMPLATE_multiview_drawer.pas) — drawer lateral com TMultiView
- [TEMPLATE_listview_items.pas](templates/TEMPLATE_listview_items.pas) — TListView com itens customizados
- [TEMPLATE_form_binding.pas](templates/TEMPLATE_form_binding.pas) — form com LiveBindings

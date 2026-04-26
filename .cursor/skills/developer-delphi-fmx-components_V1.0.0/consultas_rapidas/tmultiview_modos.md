# TMultiView — Modos, Placement e Propriedades

## Modos (TMultiViewMode)

| Modo | Comportamento | Plataforma típica |
|------|---------------|-------------------|
| `Drawer` | Painel desliza por cima/lado do conteúdo | Mobile (todas) |
| `Panel` | Painel fixo sempre visível ao lado | Desktop (grande) |
| `Popover` | Balão flutuante ancorado a um controle | iPad/Tablet |
| `PlatformBehaviour` | Automático: Drawer em mobile, Panel em desktop | Cross-platform |

```pascal
MultiView1.Mode := TMultiViewMode.Drawer;
MultiView1.Mode := TMultiViewMode.Panel;
MultiView1.Mode := TMultiViewMode.Popover;
MultiView1.Mode := TMultiViewMode.PlatformBehaviour; // recomendado
```

---

## DrawerOptions

| Propriedade | Tipo | Padrão | Descrição |
|-------------|------|--------|-----------|
| `Placement` | TPlacement | Left | Left, Right, Top, Bottom |
| `Overlap` | Boolean | True | True=sobrepõe, False=empurra conteúdo |
| `TouchAreaSize` | Single | 16 | Largura da área de swipe (px) |
| `DurationSliding` | Single | 0.2 | Duração da animação de abertura (s) |

```pascal
MultiView1.DrawerOptions.Placement     := TPlacement.Left;
MultiView1.DrawerOptions.Overlap       := True;
MultiView1.DrawerOptions.TouchAreaSize := 16;
```

---

## ShadowOptions

```pascal
MultiView1.ShadowOptions.Enabled := True;
MultiView1.ShadowOptions.Color   := $60000000; // preto 37%
MultiView1.ShadowOptions.Opacity := 0.5;
```

---

## Controle programático

```pascal
// Abrir
MultiView1.ShowMaster;

// Fechar
MultiView1.HideMaster;

// Verificar estado
if MultiView1.IsShown then
  MultiView1.HideMaster;

// Toggle
if MultiView1.IsShown then MultiView1.HideMaster
else MultiView1.ShowMaster;
```

---

## MasterButton (hambúrguer)

Configurar o botão que controla o drawer:
```pascal
MultiView1.MasterButton := BtnHamburguer;
// O MultiView gerencia automaticamente o click do botão
```

O MasterButton pode ser qualquer TControl com HitTest=True.
Se não quiser usar MasterButton, chamar ShowMaster/HideMaster no OnClick do botão.

---

## Eventos

```pascal
// Antes de mostrar/esconder
MultiView1.OnBeforeShowMaster  := ProcAntesMostrar;
MultiView1.OnAfterShowMaster   := ProcDepoisMostrar;
MultiView1.OnBeforeHideMaster  := ProcAntesEsconder;
MultiView1.OnAfterHideMaster   := ProcDepoisEsconder;
```

---

## Padrão de uso: fechar ao navegar

```pascal
procedure TFormPrincipal.ItemMenuClick(Sender: TObject);
begin
  // 1. Fechar drawer
  MultiView1.HideMaster;
  // 2. Navegar (pode animar a transição de conteúdo aqui)
  CarregarModulo((Sender as TListBoxItem).Tag);
end;
```

---

## Estrutura .fmx recomendada

```
TForm1
+-- TMultiView (MultiView1)
|   Width = 220, Align = Left
|   +-- TLayout (menu lateral)
|       Align = Client
|       +-- RecMenuHeader (avatar/logo)
|       +-- TListBox (itens de menu)
+-- TLayout (Master — área principal)
    Align = Client
    +-- RecHeader (toolbar topo)
    |   +-- BtnHamburguer
    |   +-- LblTituloPagina
    +-- RecConteudoPrincipal (conteúdo que muda)
```

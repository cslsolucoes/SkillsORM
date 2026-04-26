# TFrame vs TForm vs TPopup vs TLayout — Quando usar cada um

## Comparação rápida

| | TFrame | TForm | TPopup | TLayout/TRectangle |
|---|--------|-------|--------|-------------------|
| Janela própria | Não | Sim | Sim (flutuante) | Não |
| Embutível | Sim | Não | Não | Sim |
| Arquivo .fmx | Sim | Sim | Não (in-line) | Não |
| Herança visual | Sim | Sim | Não | Não |
| Tamanho independente | Não (depende do parent) | Sim | Sim | Não |
| Uso típico | Secções trocáveis | Telas principais | Dropdowns, tooltips | Containers de layout |

## TFrame — use quando

- Precisar trocar de "página" dentro de um container (`DestruirTudo + criar novo`)
- Tiver layout que se repete em vários lugares (reutilização)
- Quiser herança visual (base → especializado)
- A "página" precisa de seu próprio arquivo `.fmx` editável no designer

```pascal
// Trocar secoes do sistema
Frame := TFrameClientes.Create(Self);
Frame.Parent := RecAreaPrincipal;
Frame.Align  := TAlignLayout.Client;
```

## TForm — use quando

- Precisar de janela independente (dialog, editor)
- Precisar de `ShowModal` / `Close`
- A tela precisa existir fora do contexto do form principal

```pascal
var Frm := TFrmEdicaoProduto.Create(Application);
try
  Frm.ShowModal;
finally
  Frm.Free;
end;
```

## TPopup — use quando

- Precisar de dropdown, autocomplete, menu contextual
- O conteúdo flutua sobre outros controles
- Não precisa bloquear interação (diferente de ShowModal)

```pascal
Popup1.IsOpen := True;  // abre
Popup1.IsOpen := False; // fecha
```

## TLayout / TRectangle — use quando

- For apenas um container de organização visual (não precisa de arquivo .fmx próprio)
- Criar widgets simples inline (card, linha, separador)
- Não precisar de reutilização fora do contexto atual

```pascal
// Card simples, criado inline:
var Card := TRectangle.Create(Self);
Card.Parent := ScrollBox;
Card.Height := 80;
Card.XRadius := 8;
```

## Regra prática do GestorERP

```
Secao principal trocável   → TFrame  (DestruirTudo + criar novo)
Editor/dialog isolado       → TForm   (ShowModal)
Dropdown/menu contextual    → TPopup
Container de layout simples → TRectangle / TLayout
```

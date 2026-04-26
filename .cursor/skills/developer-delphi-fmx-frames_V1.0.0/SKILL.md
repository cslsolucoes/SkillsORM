---
name: developer-delphi-fmx-frames
description: TFrame no FireMonkey — criação, embedding, herança visual, ciclo de vida e padrões GestorERP.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-fmx-frames_V1.0.0

## O que é esta skill

Skill especializada em **TFrame no FireMonkey (FMX)**: criação, embedding, herança visual, ciclo de vida, padrões de uso real do GestorERP.

TFrame é o principal mecanismo de composição de UI em FMX. Diferente de TForm, um TFrame pode ser embutido dentro de outro controle, herdado visualmente, e reutilizado em múltiplos contextos.

---

## Quando usar esta skill

- Criar um frame reutilizável que será carregado dinamicamente em runtime
- Implementar herança visual: `TFrameBase → TFrameCRUD → TFrameClientesCRUD`
- Passar parâmetros para um frame (via constructor ou properties)
- Implementar o padrão **DestruirTudo** (trocar frames sem memory leak)
- Criar frames com lazy-load (só criar quando container fica visível)
- Implementar frame como modal com `CarregarDados` + `Salvar`/`Cancelar`

---

## Hierarquia FMX relevante

```
TFmxObject
  └─ TControl
       └─ TStyledControl
            └─ TCustomForm
                 ├─ TForm
                 └─ TFrame   ← ponto de entrada desta skill
```

TFrame em FMX herda de `TCustomForm` (não de `TPanel` como VCL), portanto tem:
- Arquivo `.fmx` próprio (designer visual)
- Suporte completo a `Align`, `Padding`, `Margins`
- Eventos `OnCreate`, `OnShow`, `OnHide`, `OnClose` (via `OnResize` e `CanFocus`)

---

## Padrões do GestorERP

### 1. Criar e Embutir Frame
```pascal
var Frame: TFrameMeuFrame;
Frame := TFrameMeuFrame.Create(Self);
Frame.Parent := RecConteiner;
Frame.Align  := TAlignLayout.Client;
```

### 2. DestruirTudo (trocar de frame sem leak)
```pascal
procedure TFrmPrincipal.DestruirTudo;
var I: Integer;
begin
  for I := RecConteiner.ControlsCount - 1 downto 0 do
    RecConteiner.Controls[I].Free;
end;
```

### 3. Parâmetros via Property
```pascal
// No frame: expor property pública
property CodigoCliente: Integer read FCodigoCliente write SetCodigoCliente;

// No form pai: definir antes de mostrar
Frame.CodigoCliente := 42;
Frame.CarregarDados;
```

### 4. Lazy-Load (criar só quando necessário)
```pascal
procedure TFrmPrincipal.RecContainerResized(Sender: TObject);
begin
  if RecConteiner.ControlsCount = 0 then
    CriarFrameFilho;
end;
```

### 5. Herança Visual FMX
```pascal
// TFrameBase define layout + eventos virtuais abstratos
// TFrameCRUD herda e implementa os abstratos
// No .fmx filho: a diretiva `inherited` preserva componentes da base
```

---

## Arquivos desta skill

| Arquivo | Conteúdo |
|---------|---------|
| `exemplos/frame_basico.pas` | Criar e embutir TFrame em runtime |
| `exemplos/frame_heranca.pas` | Herança visual: base → CRUD |
| `exemplos/frame_parametros.pas` | Parâmetros via constructor e property |
| `exemplos/frame_modal.pas` | Frame como modal com CarregarDados |
| `exemplos/frame_lazy_create.pas` | Lazy-load com ControlsCount=0 |
| `exemplos/frame_destruir_tudo.pas` | Padrão DestruirTudo sem leak |
| `consultas_rapidas/frame_lifecycle.md` | Eventos: create/show/hide/destroy |
| `consultas_rapidas/heranca_visual.md` | FMX herança visual, inherited, overrides |
| `consultas_rapidas/frame_vs_form.md` | TFrame vs TForm vs TPopup vs TPanel |
| `consultas_rapidas/automap_pattern.md` | Padrão edt*↔txt* com FindComponent |
| `templates/TEMPLATE_frame_crud.pas` | Frame base CRUD com eventos abstratos |
| `templates/TEMPLATE_frame_listagem.pas` | Frame de listagem com hover |
| `templates/TEMPLATE_frame_modal.pas` | Frame modal com salvar/cancelar |

---

## Skills relacionadas da Família A FMX

| Skill | Uso |
|-------|-----|
| `developer-delphi-fmx-layout_V1.1.0` | Orquestradora — visão geral FMX |
| `developer-delphi-fmx-containers_V1.0.0` | TLayout, TScrollBox, TRectangle |
| `developer-delphi-fmx-animations_V1.0.0` | TAnimator, TFloatAnimation |
| `developer-delphi-fmx-effects_V1.0.0` | TShadowEffect, TBlurEffect |
| `developer-delphi-fmx-components_V1.0.0` | TListView, TMultiView, LiveBindings |
| `developer-delphi-fmx-patterns_V1.0.0` | Drag form, TStyleBook, arc progress |

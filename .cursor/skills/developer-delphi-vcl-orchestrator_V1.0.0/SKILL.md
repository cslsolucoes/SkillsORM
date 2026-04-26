---
name: developer-delphi-vcl-orchestrator
description: >
  Orquestrador da família VCL (Visual Component Library) — coordena forms, componentes e
  controles data-aware. Ativar quando o usuário mencionar: VCL, formulário Delphi, TForm,
  aplicação Windows Delphi, componentes visuais, dfm, VCL Application, MDI, SDI,
  design de tela Delphi, interface gráfica Delphi.
model: sonnet
thinking: none
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-vcl-orchestrator

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Criado** | 2026-04-24 |
| **Família** | VCL — Visual Component Library |

## Responsabilidade única

Ponto de entrada da família VCL. Identifica o contexto do usuário e roteia para a skill
especializada correta. Não implementa detalhes técnicos — delega.

## Mapa da família VCL

| Skill | Escopo |
|-------|--------|
| `developer-delphi-vcl-forms` | TForm, lifecycle, MDI/SDI, modais, estilos, ações, exceções |
| `developer-delphi-vcl-components` | TEdit, TButton, TComboBox, TGrid, TDBGrid, TPageControl, data-aware |

## Quando ativar cada skill

```
Usuário quer → criar/configurar formulário, janela, modal, MDI child, estilo visual
  → developer-delphi-vcl-forms

Usuário quer → usar componente específico (botão, grid, combo, listbox, dbgrid, edit)
  → developer-delphi-vcl-components

Usuário quer → conectar FireDAC a controles visuais (TDBGrid, TDBEdit, TDataSource)
  → developer-delphi-vcl-components + developer-delphi-firedac-queries

Usuário quer → layout geral, arquitetura de telas, padrões VCL
  → esta skill (orientação geral) → delegar conforme necessidade
```

## Arquitetura VCL — visão geral

A VCL (Visual Component Library) é o framework UI nativo do Delphi para Windows.
Hierarquia base: `TObject → TPersistent → TComponent → TControl → TWinControl → TCustomForm → TForm`.

### Namespaces principais

| Unit | Conteúdo |
|------|----------|
| `Vcl.Forms` | TForm, TApplication, TScreen |
| `Vcl.Controls` | TControl, TWinControl, TGraphicControl |
| `Vcl.StdCtrls` | TEdit, TButton, TLabel, TComboBox, TListBox, TMemo |
| `Vcl.ExtCtrls` | TPanel, TGroupBox, TScrollBox, TImage, TTimer |
| `Vcl.Grids` | TStringGrid, TDrawGrid |
| `Vcl.DBGrids` | TDBGrid |
| `Vcl.DBCtrls` | TDBEdit, TDBText, TDBComboBox, TDBNavigator |
| `Vcl.ComCtrls` | TPageControl, TTabSheet, TTreeView, TListView, TStatusBar |
| `Vcl.Menus` | TMainMenu, TPopupMenu |
| `Vcl.ActnList` | TActionList, TAction |
| `Vcl.Styles` | TStyleManager, VCL Themes |
| `Data.DB` | TDataSource, TDataSet |

### Separação VCL × RTL × FireDAC

```
RTL (System.*)      → tipos base, strings, coleções, streams
VCL (Vcl.*)         → componentes visuais, formulários, eventos
FireDAC (FireDAC.*) → acesso a banco de dados
Data.DB             → interface entre VCL data-aware e datasets
```

## Padrões arquiteturais VCL recomendados

### 1 — Separação de responsabilidades

```pascal
// EVITAR: lógica de negócio no form
procedure TfrmCliente.btnSalvarClick(Sender: TObject);
begin
  if edtNome.Text = '' then raise Exception.Create('Nome obrigatório');
  FDQuery1.ExecSQL('INSERT INTO ...');  // ❌ SQL no form
end;

// PREFERIR: form chama service, service tem a lógica
procedure TfrmCliente.btnSalvarClick(Sender: TObject);
begin
  FClienteService.Salvar(BuildDtoFromForm);  // ✅
end;
```

### 2 — Criação dinâmica de forms

```pascal
// Modal com resultado
var LForm: TfrmSelecao;
begin
  LForm := TfrmSelecao.Create(Application);
  try
    if LForm.ShowModal = mrOk then
      ProcessarSelecao(LForm.ItemSelecionado);
  finally
    LForm.Free;
  end;
end;

// Modeless (não bloqueante)
if not Assigned(GfrmLog) then
begin
  GfrmLog := TfrmLog.Create(Application);
  GfrmLog.Show;
end
else
  GfrmLog.BringToFront;
```

### 3 — TDataSource como ponte VCL ↔ FireDAC

```
TFDConnection → TFDQuery → TDataSource → TDBGrid / TDBEdit / TDBNavigator
```

## Checklist de início de projeto VCL

- [ ] Criar VCL Application via File > New > VCL Application
- [ ] Renomear form: Name=`frmMain`, Caption=`Título do Sistema`
- [ ] Definir Application.Title no Project Options
- [ ] Criar DataModule separado para componentes de dados
- [ ] Configurar TApplication.OnException para tratamento global de erros
- [ ] Ativar estilos VCL se necessário (TStyleManager)

## Referências cruzadas

- `developer-delphi-vcl-forms` — forms, MDI, modais, estilos, ações
- `developer-delphi-vcl-components` — componentes individuais e data-aware
- `developer-delphi-firedac-connection` — conexão ao banco
- `developer-delphi-firedac-queries` — queries e datasets para data-aware

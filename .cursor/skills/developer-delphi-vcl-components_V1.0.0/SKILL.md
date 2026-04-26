---
name: developer-delphi-vcl-components
description: >
  Componentes VCL individuais e data-aware: TEdit, TButton, TComboBox, TListBox,
  TMemo, TPanel, TPageControl, TTabSheet, TTreeView, TListView, TStringGrid,
  TDBGrid, TDBEdit, TDBNavigator, TDataSource, TStatusBar, TMainMenu, TPopupMenu,
  TImageList, TTimer. Ativar quando o usuário mencionar: componente VCL, TEdit,
  TButton, TComboBox, TListBox, TMemo, TPanel, TPageControl, TDBGrid, TDBEdit,
  TDBNavigator, TDataSource, TStringGrid, TListView, TTreeView, TStatusBar,
  TMainMenu, TPopupMenu, TImageList, TTimer, data-aware, LiveBinding, binding.
model: sonnet
thinking: none
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-vcl-components

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Criado** | 2026-04-24 |
| **Família** | VCL — Visual Component Library |

## Responsabilidade única

Usar, configurar e integrar componentes VCL individuais e data-aware: inputs,
grids, menus, navegadores de dados e utilitários visuais. Cobre a ponte entre
componentes visuais e datasets FireDAC via TDataSource.

## When to use

- Configurar TEdit, TComboBox, TListBox, TMemo para entrada de dados
- Usar TDBGrid, TDBEdit, TDBNavigator com TDataSource + FireDAC
- Montar TPageControl com TTabSheets dinamicamente
- Preencher TTreeView e TListView com dados hierárquicos e em lista
- Configurar TStringGrid para grades editáveis sem banco
- Montar TMainMenu, TPopupMenu e atalhos de teclado
- Gerenciar TImageList e ícones de botões/menus
- Usar TTimer para tarefas periódicas na UI

## When NOT to use

- Criar ou configurar formulários (TForm, MDI) → `developer-delphi-vcl-forms`
- Visão geral da VCL → `developer-delphi-vcl-orchestrator`
- Queries e conexão FireDAC → `developer-delphi-firedac-queries` / `developer-delphi-firedac-connection`

---

## §1 — Controles de entrada (StdCtrls)

```pascal
uses Vcl.StdCtrls;

// TEdit — entrada de texto simples
procedure TfrmCliente.ConfigurarEdits;
begin
  edtNome.MaxLength  := 100;
  edtNome.CharCase   := ecUpperCase;   // maiúsculas automáticas
  edtSenha.PasswordChar := '*';        // campo senha
  edtCPF.NumbersOnly := False;         // aceita qualquer char (validar manualmente)
end;

// TMemo — texto multilinha
procedure TfrmCliente.ConfigurarMemo;
begin
  mmoObservacao.ScrollBars   := ssVertical;
  mmoObservacao.WordWrap     := True;
  mmoObservacao.Lines.Clear;
  mmoObservacao.Lines.Add('Linha inicial');
  ShowMessage(mmoObservacao.Lines.Text);  // texto completo
end;

// TComboBox — lista suspensa
procedure TfrmCliente.CarregarCombo;
begin
  cboEstado.Items.Clear;
  cboEstado.Items.AddStrings(['SP', 'RJ', 'MG', 'RS']);
  cboEstado.ItemIndex := 0;   // seleciona o primeiro
  // Obter valor selecionado
  ShowMessage(cboEstado.Items[cboEstado.ItemIndex]);
end;

// TListBox — lista simples
procedure TfrmCliente.CarregarLista;
var I: Integer;
begin
  lstItens.Items.BeginUpdate;
  try
    lstItens.Items.Clear;
    for I := 0 to 9 do
      lstItens.Items.Add(Format('Item %d', [I]));
  finally
    lstItens.Items.EndUpdate;
  end;
end;
```

---

## §2 — Contêineres e layout (ExtCtrls / ComCtrls)

```pascal
uses Vcl.ExtCtrls, Vcl.ComCtrls;

// TPanel — contêiner com bordas
procedure TfrmPrincipal.ConfigurarPanels;
begin
  pnlTopo.Align       := alTop;
  pnlTopo.Height      := 48;
  pnlTopo.BevelOuter  := bvNone;
  pnlRodape.Align     := alBottom;
  pnlConteudo.Align   := alClient;
end;

// TPageControl — abas
procedure TfrmPrincipal.ConfigurarAbas;
var LSheet: TTabSheet;
begin
  // Adicionar aba dinamicamente
  LSheet := TTabSheet.Create(pgcPrincipal);
  LSheet.PageControl := pgcPrincipal;
  LSheet.Caption     := 'Nova Aba';
  pgcPrincipal.ActivePage := LSheet;
end;

procedure TfrmPrincipal.pgcPrincipalChange(Sender: TObject);
begin
  // Evento ao trocar de aba
  case pgcPrincipal.ActivePageIndex of
    0: CarregarAba0;
    1: CarregarAba1;
  end;
end;

// TStatusBar — barra de status
procedure TfrmPrincipal.InicializarStatusBar;
begin
  // sbr.Panels[0] criado no DFM com Style = psOwnerDraw ou psText
  sbrStatus.Panels[0].Text  := 'Pronto';
  sbrStatus.Panels[1].Width := 120;
  sbrStatus.Panels[1].Text  := 'Usuário: Admin';
end;
```

---

## §3 — TStringGrid — grade editável

```pascal
uses Vcl.Grids;

procedure TfrmRelatorio.ConfigurarGrid;
begin
  // Colunas e linhas
  sgdDados.ColCount := 4;
  sgdDados.RowCount := 1 + 10;   // 1 cabeçalho + 10 dados
  sgdDados.FixedRows := 1;
  sgdDados.FixedCols := 0;

  // Cabeçalhos
  sgdDados.Cells[0, 0] := 'Código';
  sgdDados.Cells[1, 0] := 'Descrição';
  sgdDados.Cells[2, 0] := 'Qtd';
  sgdDados.Cells[3, 0] := 'Valor';

  // Larguras
  sgdDados.ColWidths[0] := 60;
  sgdDados.ColWidths[1] := 200;
  sgdDados.ColWidths[2] := 60;
  sgdDados.ColWidths[3] := 100;

  // Opções
  sgdDados.Options := sgdDados.Options
    + [goEditing, goRowSelect]
    - [goRangeSelect];
end;

procedure TfrmRelatorio.PreencherGrid(AItens: TArray<TItemDTO>);
var I: Integer;
begin
  sgdDados.RowCount := 1 + Length(AItens);
  for I := 0 to High(AItens) do
  begin
    sgdDados.Cells[0, I + 1] := AItens[I].Codigo.ToString;
    sgdDados.Cells[1, I + 1] := AItens[I].Descricao;
    sgdDados.Cells[2, I + 1] := AItens[I].Quantidade.ToString;
    sgdDados.Cells[3, I + 1] := FormatFloat('#,##0.00', AItens[I].Valor);
  end;
end;
```

---

## §4 — TListView e TTreeView

```pascal
uses Vcl.ComCtrls;

// TListView — modo relatório (colunas)
procedure TfrmPrincipal.ConfigurarListView;
begin
  lvwClientes.ViewStyle  := vsReport;
  lvwClientes.ReadOnly   := True;
  lvwClientes.RowSelect  := True;
  lvwClientes.GridLines  := True;

  with lvwClientes.Columns.Add do begin Caption := 'Código';  Width := 70; end;
  with lvwClientes.Columns.Add do begin Caption := 'Nome';    Width := 200; end;
  with lvwClientes.Columns.Add do begin Caption := 'Cidade';  Width := 120; end;
end;

procedure TfrmPrincipal.AdicionarItemListView(ACod: Integer; ANome, ACidade: string);
var LItem: TListItem;
begin
  LItem := lvwClientes.Items.Add;
  LItem.Caption := ACod.ToString;
  LItem.SubItems.Add(ANome);
  LItem.SubItems.Add(ACidade);
  LItem.Data := Pointer(ACod);   // ponteiro de dados arbitrário
end;

// TTreeView — hierarquia
procedure TfrmPrincipal.CarregarArvore(ACategories: TList<TCategoriaDTO>);
var
  LCategoria: TCategoriaDTO;
  LNoPai, LNoFilho: TTreeNode;
begin
  tvwMenu.Items.BeginUpdate;
  try
    tvwMenu.Items.Clear;
    for LCategoria in ACategories do
    begin
      LNoPai := tvwMenu.Items.AddChild(nil, LCategoria.Nome);
      for var LSub in LCategoria.SubItens do
        LNoFilho := tvwMenu.Items.AddChild(LNoPai, LSub.Nome);
    end;
    tvwMenu.FullExpand;
  finally
    tvwMenu.Items.EndUpdate;
  end;
end;

procedure TfrmPrincipal.tvwMenuDblClick(Sender: TObject);
begin
  if Assigned(tvwMenu.Selected) and not Assigned(tvwMenu.Selected.Parent) then
    Exit;  // ignorar nós pai
  AbrirModulo(tvwMenu.Selected.Text);
end;
```

---

## §5 — Componentes data-aware (DBCtrls / DBGrids)

```pascal
uses Vcl.DBGrids, Vcl.DBCtrls, Data.DB;

// Cadeia de componentes:
// TFDConnection → TFDQuery → TDataSource → TDBGrid / TDBEdit / TDBNavigator

procedure TfrmClientes.ConfigurarDataAware;
begin
  // DataSource aponta para o dataset
  dsClientes.DataSet := FQuery;    // FQuery: TFDQuery injetado via construtor

  // DBGrid vinculado ao DataSource
  grdClientes.DataSource := dsClientes;

  // DBEdit — edita campo do dataset atual
  edtNomeDB.DataSource := dsClientes;
  edtNomeDB.DataField  := 'NOME';

  // DBNavigator — botões Primeiro/Anterior/Próximo/Último/Inserir/Editar/Salvar/Cancelar/Excluir
  navClientes.DataSource := dsClientes;
  navClientes.VisibleButtons :=
    [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbPost, nbCancel, nbRefresh];
end;

// Personalizar colunas do TDBGrid
procedure TfrmClientes.PersonalizarGrid;
begin
  grdClientes.Columns.Clear;
  with grdClientes.Columns.Add do begin
    FieldName := 'ID';     Title.Caption := 'Código'; Width := 70;
    ReadOnly  := True;
  end;
  with grdClientes.Columns.Add do begin
    FieldName := 'NOME';   Title.Caption := 'Nome';   Width := 220;
  end;
  with grdClientes.Columns.Add do begin
    FieldName := 'ATIVO';  Title.Caption := 'Ativo';  Width := 60;
    // Checkbox para campos booleanos
    ButtonStyle := cbsCheckbox;
  end;
end;

// Evento OnDrawColumnCell — colorir linhas
procedure TfrmClientes.grdClientesDrawColumnCell(
  Sender: TObject; const Rect: TRect; DataCol: Integer;
  Column: TColumn; State: TGridDrawState);
begin
  if not (grdClientes.DataSource.DataSet.FieldByName('ATIVO').AsBoolean) then
    grdClientes.Canvas.Brush.Color := $00D0D0D0;  // cinza para inativos
  grdClientes.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;
```

---

## §6 — TMainMenu e TPopupMenu

```pascal
uses Vcl.Menus;

// Criar menu em tempo de execução (complemento ao DFM)
procedure TfrmPrincipal.CriarMenuDinamico;
var
  LMenu: TMenuItem;
  LItem: TMenuItem;
begin
  LMenu := TMenuItem.Create(mnuPrincipal);
  LMenu.Caption := '&Relatórios';
  mnuPrincipal.Items.Add(LMenu);

  LItem := TMenuItem.Create(LMenu);
  LItem.Caption    := '&Clientes por Cidade';
  LItem.ShortCut   := TextToShortCut('Ctrl+R');
  LItem.OnClick    := RelClientesCidadeClick;
  LMenu.Add(LItem);

  // Separador
  LItem := TMenuItem.Create(LMenu);
  LItem.Caption := '-';
  LMenu.Add(LItem);
end;

// PopupMenu programático
procedure TfrmPrincipal.grdClientesContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
  // Ajustar itens antes de exibir
  miEditar.Enabled  := grdClientes.DataSource.DataSet.RecordCount > 0;
  miExcluir.Enabled := miEditar.Enabled;
  popClientes.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
  Handled := True;
end;
```

---

## §7 — TImageList e TTimer

```pascal
uses Vcl.ImgList, Vcl.ExtCtrls;

// TImageList — ícones centralizados (vinculado a buttons/menus no DFM)
procedure TfrmPrincipal.ConfigurarImageList;
begin
  // imlIcones.Width/Height = 16 (definido no DFM)
  // ImageIndex referenciado em TButton.ImageIndex, TMenuItem.ImageIndex etc.
  btnSalvar.Images    := imlIcones;
  btnSalvar.ImageIndex := 0;
  btnExcluir.Images   := imlIcones;
  btnExcluir.ImageIndex := 1;
end;

// TTimer — tarefa periódica na thread principal
procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  tmrAtualizacao.Interval := 30000;  // 30 segundos
  tmrAtualizacao.Enabled  := True;
end;

procedure TfrmPrincipal.tmrAtualizacaoTimer(Sender: TObject);
begin
  // Roda na thread principal — seguro para UI
  AtualizarIndicadores;
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  tmrAtualizacao.Enabled := False;
end;
```

---

## §8 — Checklist de qualidade — Componentes VCL

- [ ] Componentes data-aware vinculados ao `TDataSource` (não ao dataset diretamente)
- [ ] `Items.BeginUpdate` / `EndUpdate` em listas com muitos itens
- [ ] Colunas do `TDBGrid` configuradas via `Columns` (não auto-geradas)
- [ ] `TTimer.Enabled := False` no `OnDestroy` do form
- [ ] `TStringGrid.RowCount` ajustado antes de preencher células
- [ ] `TListView.Items.BeginUpdate` / `EndUpdate` ao carregar muitos itens
- [ ] Ícones carregados via `TImageList` (não via `Glyph` direto em botões)
- [ ] Menus com `ShortCut` definidos e `ActionList` como alternativa ao `OnClick` direto

## Referências cruzadas

- `developer-delphi-vcl-forms` — TForm, lifecycle, MDI/SDI, modal
- `developer-delphi-vcl-orchestrator` — visão geral VCL e namespaces
- `developer-delphi-firedac-queries` — TFDQuery para datasets data-aware
- `developer-delphi-firedac-connection` — TFDConnection

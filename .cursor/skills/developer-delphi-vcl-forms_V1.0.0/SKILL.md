---
name: developer-delphi-vcl-forms
description: >
  TForm, ciclo de vida de formulários VCL, MDI/SDI, modais, formulários dinâmicos,
  estilos VCL (themes), ActionList, exceções VCL, threading na UI. Ativar quando
  o usuário mencionar: criar form, TForm, ShowModal, MDI child, MDI parent, VCL style,
  tema Delphi, ActionList, OnCreate, OnDestroy, form dinâmico, modal, modeless,
  formulário principal, splash screen, tela de login.
model: sonnet
thinking: none
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-vcl-forms

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Criado** | 2026-04-24 |
| **Família** | VCL — Visual Component Library |

## Responsabilidade única

Criar e gerenciar formulários VCL: lifecycle, tipos (SDI/MDI/modal/modeless), criação
dinâmica, estilos visuais, ActionList, tratamento de exceções na UI e thread safety.

## When to use

- Criar novo TForm (qualquer tipo)
- Configurar MDI parent + MDI child
- Exibir form modal (`ShowModal`) ou modeless (`Show`)
- Aplicar VCL Styles (temas visuais)
- Configurar ActionList e ações centralizadas
- Tratar exceções em aplicações VCL
- Chamar UI a partir de thread secundária

## When NOT to use

- Componentes específicos (TDBGrid, TEdit, TComboBox) → `developer-delphi-vcl-components`
- Conexão ao banco → `developer-delphi-firedac-connection`
- Visão geral da família VCL → `developer-delphi-vcl-orchestrator`

---

## §1 — Anatomia de um TForm

```pascal
unit ufrm.Principal;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmPrincipal = class(TForm)
    pnlTopo: TPanel;
    btnAcao: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAcaoClick(Sender: TObject);
  private
    FServico: IAlgumServico;   // dependência injetada
    procedure ConfigurarUI;
  public
    constructor Create(AOwner: TComponent; AServico: IAlgumServico); reintroduce;
  end;

implementation

{$R *.dfm}

constructor TfrmPrincipal.Create(AOwner: TComponent; AServico: IAlgumServico);
begin
  inherited Create(AOwner);
  FServico := AServico;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  ConfigurarUI;
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  // FServico é interface — liberado automaticamente
end;

procedure TfrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;  // libera ao fechar (para forms criados dinamicamente)
end;
```

### Ciclo de vida dos eventos

```
OnCreate → OnShow → [OnActivate / OnDeactivate (foco)] → OnClose → OnDestroy
```

| Evento | Uso correto |
|--------|-------------|
| `OnCreate` | Inicializar dependências, configurar UI |
| `OnShow` | Carregar dados que podem mudar entre exibições |
| `OnClose` | Decidir `Action` (caHide / caFree / caNone / caMinimize) |
| `OnDestroy` | Liberar recursos não-gerenciados |
| `OnCloseQuery` | Confirmar com o usuário antes de fechar |

---

## §2 — Tipos de aplicação

### SDI (Single Document Interface)

```pascal
// Padrão — um formulário principal, forms filhos são modais ou modeless
Application.CreateForm(TfrmPrincipal, frmPrincipal);
Application.Run;
```

### MDI (Multiple Document Interface)

```pascal
// Form pai: FormStyle = fsMDIForm
type
  TfrmMDIPai = class(TForm)
    // FormStyle definido no DFM como fsMDIForm
  end;

// Form filho: FormStyle = fsMDIChild
type
  TfrmDocumento = class(TForm)
    // FormStyle = fsMDIChild no DFM
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  end;

procedure TfrmDocumento.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;  // obrigatório em MDI child
end;

// Criar MDI child
procedure TfrmMDIPai.AbrirDocumento(const ANome: string);
var LDoc: TfrmDocumento;
begin
  LDoc := TfrmDocumento.Create(Application);
  LDoc.Caption := ANome;
  LDoc.Show;  // não usar ShowModal em MDI child
end;
```

---

## §3 — Forms modais e modeless

### Modal (bloqueia a janela chamadora)

```pascal
procedure TfrmPrincipal.btnSelecionarClick(Sender: TObject);
var LSelecao: TfrmSelecao;
begin
  LSelecao := TfrmSelecao.Create(Application);
  try
    LSelecao.FiltroInicial := edtFiltro.Text;
    case LSelecao.ShowModal of
      mrOk:     ProcessarSelecao(LSelecao.IdSelecionado);
      mrCancel: ; // usuário cancelou
    end;
  finally
    LSelecao.Free;
  end;
end;

// No form de seleção — fechar com resultado
procedure TfrmSelecao.btnOkClick(Sender: TObject);
begin
  FIdSelecionado := ObterIdDaLinha;
  ModalResult := mrOk;  // fecha e retorna mrOk
end;
```

### Modeless (não bloqueante — instância global guardada)

```pascal
// Variável global (ou campo do form principal)
var GfrmLog: TfrmLog;

procedure TfrmPrincipal.AbrirLog;
begin
  if not Assigned(GfrmLog) then
  begin
    GfrmLog := TfrmLog.Create(Application);
    GfrmLog.OnClose := procedure(Sender: TObject; var Action: TCloseAction)
    begin
      Action := caFree;
      GfrmLog := nil;
    end;
  end;
  GfrmLog.Show;
  GfrmLog.BringToFront;
end;
```

---

## §4 — VCL Styles (temas visuais)

```pascal
// No .dpr, antes de Application.Run:
uses Vcl.Themes, Vcl.Styles;

// Aplicar estilo no início
TStyleManager.TrySetStyle('Windows11 Modern Light');

// Listar estilos disponíveis (compilados no projeto)
procedure ListarEstilos;
var LNome: string;
begin
  for LNome in TStyleManager.StyleNames do
    Memo1.Lines.Add(LNome);
end;

// Verificar estilo ativo
if TStyleManager.IsCustomStyleActive then
  Caption := 'Estilo: ' + TStyleManager.ActiveStyle.Name;
```

**Ativar estilo no Project Options:** Project > Options > Application > Appearance > Custom Styling.

---

## §5 — ActionList — ações centralizadas

```pascal
// Vantagem: um TAction atualiza botão + menu + toolbar simultaneamente
type
  TfrmPrincipal = class(TForm)
    ActionList1: TActionList;
    actSalvar: TAction;
    actExcluir: TAction;
    btnSalvar: TButton;    // Action = actSalvar
    miSalvar: TMenuItem;   // Action = actSalvar
  private
    procedure actSalvarExecute(Sender: TObject);
    procedure actSalvarUpdate(Sender: TObject);
    procedure actExcluirExecute(Sender: TObject);
    procedure actExcluirUpdate(Sender: TObject);
  end;

procedure TfrmPrincipal.actSalvarUpdate(Sender: TObject);
begin
  // Habilitar/desabilitar automaticamente
  actSalvar.Enabled := FDadosModificados;
end;

procedure TfrmPrincipal.actSalvarExecute(Sender: TObject);
begin
  FServico.Salvar(ObterDadosDoForm);
  FDadosModificados := False;
end;
```

---

## §6 — Tratamento de exceções VCL

```pascal
// Global — no .dpr ou no form principal
Application.OnException := procedure(Sender: TObject; E: Exception)
begin
  // Log centralizado
  TLogger.Instance.Error(E.Message, E.ClassName);
  MessageDlg(
    'Erro inesperado: ' + E.Message,
    mtError, [mbOK], 0
  );
end;

// Local — em event handlers críticos
procedure TfrmPrincipal.btnSalvarClick(Sender: TObject);
begin
  Screen.Cursor := crHourglass;
  try
    FServico.Salvar(ObterDadosDoForm);
    ShowMessage('Salvo com sucesso!');
  except
    on E: EValidacao do
      MessageDlg(E.Message, mtWarning, [mbOK], 0);
    on E: Exception do
    begin
      Application.ShowException(E);
      raise;  // re-raise para o handler global logar
    end;
  end;
finally
  Screen.Cursor := crDefault;
end;
```

---

## §7 — Thread safety na UI VCL

> A VCL **não é thread-safe**. Toda atualização de componente visual deve ocorrer na thread principal.

```pascal
// ❌ ERRADO — atualizar UI de thread secundária
procedure TMinhaThread.Execute;
begin
  frmPrincipal.lblStatus.Caption := 'Processando...'; // crash!
end;

// ✅ CORRETO — usar TThread.Synchronize ou Queue
procedure TMinhaThread.Execute;
begin
  TThread.Synchronize(nil, procedure
  begin
    frmPrincipal.lblStatus.Caption := 'Processando...';
  end);
end;

// ✅ Queue (não bloqueia a thread — fire-and-forget)
procedure TMinhaThread.AtualizarProgresso(AValor: Integer);
begin
  TThread.Queue(nil, procedure
  begin
    frmPrincipal.ProgressBar1.Position := AValor;
  end);
end;
```

---

## §8 — Checklist de qualidade — TForm

- [ ] `Name` do form segue prefixo `frm` (ex.: `frmCliente`, `frmRelatorio`)
- [ ] Construtor com injeção de dependência quando necessário
- [ ] `OnClose` define `caFree` para forms criados dinamicamente
- [ ] Lógica de negócio **fora** do form — forms só coordenam UI
- [ ] `Screen.Cursor := crHourglass` em operações longas
- [ ] Atualizações de UI de threads secundárias via `TThread.Synchronize` ou `Queue`
- [ ] Exceções tratadas no event handler ou delegadas ao `Application.OnException`
- [ ] Forms modais liberados no `finally` do bloco que os criou

unit crud_padrao;
{
  EXEMPLO: CRUD completo com TDialogService (FMX / GestorERP)
  Compilavel: dcc32 / dcc64
  Demonstra:
    - Listagem com selecao
    - Abrir modal de edicao
    - Confirmacao de exclusao async via TDialogService
    - Notificacao de sucesso/erro (TDialogService.ShowMessage)
    - Recarregar lista apos operacao
}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs,
  FMX.Layouts, FMX.StdCtrls, FMX.Objects, FMX.Edit;

// ---------------------------------------------------------------------------
// VO (Value Object) do item
// ---------------------------------------------------------------------------
type
  TProduto = record
    Codigo: Integer;
    Nome  : string;
    Preco : Currency;
  end;

// ---------------------------------------------------------------------------
// Frame principal de CRUD — listagem + edicao inline
// ---------------------------------------------------------------------------
type
  TFrmCrudPadrao = class(TForm)
  private
    // Layout
    RecLista   : TRectangle;
    ScrollLista: TVertScrollBox;
    BtnNovo    : TButton;
    BtnEditar  : TButton;
    BtnExcluir : TButton;

    // Edicao inline (simplificado — na pratica usar modal)
    RecEdicao  : TRectangle;
    EdtNome    : TEdit;
    EdtPreco   : TEdit;
    BtnSalvar  : TButton;
    BtnCancelar: TButton;

    // Estado
    FProdutos    : TList<TProduto>;
    FItemSelecionado: TProduto;
    FModoNovo   : Boolean;

    procedure ConstruirLayout;
    procedure CarregarLista;
    procedure RenderizarLista;
    procedure SelecionarItem(const AItem: TProduto);

    procedure BtnNovoClick(Sender: TObject);
    procedure BtnEditarClick(Sender: TObject);
    procedure BtnExcluirClick(Sender: TObject);
    procedure BtnSalvarClick(Sender: TObject);
    procedure BtnCancelarClick(Sender: TObject);

    procedure ExecutarExclusao;
    procedure ExibirAreaEdicao(AVisivel: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

constructor TFrmCrudPadrao.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FProdutos := TList<TProduto>.Create;
  Width  := 600;
  Height := 400;
  Fill.Color := $FFFAFAFA;
  ConstruirLayout;
  CarregarLista;
end;

destructor TFrmCrudPadrao.Destroy;
begin
  FProdutos.Free;
  inherited;
end;

procedure TFrmCrudPadrao.ConstruirLayout;
var
  BarraBotoes: TRectangle;
begin
  // Barra de acoes superior
  BarraBotoes := TRectangle.Create(Self);
  BarraBotoes.Parent := Self;
  BarraBotoes.Align  := TAlignLayout.Top;
  BarraBotoes.Height := 48;
  BarraBotoes.Fill.Color  := $FFF0F0F0;
  BarraBotoes.Stroke.Kind := TBrushKind.None;
  BarraBotoes.Padding.Rect := TRectF.Create(8, 6, 8, 6);

  BtnNovo := TButton.Create(Self);
  BtnNovo.Parent  := BarraBotoes;
  BtnNovo.Align   := TAlignLayout.Left;
  BtnNovo.Width   := 80;
  BtnNovo.Text    := 'Novo';
  BtnNovo.Margins.Right := 4;
  BtnNovo.OnClick := BtnNovoClick;

  BtnEditar := TButton.Create(Self);
  BtnEditar.Parent  := BarraBotoes;
  BtnEditar.Align   := TAlignLayout.Left;
  BtnEditar.Width   := 80;
  BtnEditar.Text    := 'Editar';
  BtnEditar.Margins.Right := 4;
  BtnEditar.Enabled := False;
  BtnEditar.OnClick := BtnEditarClick;

  BtnExcluir := TButton.Create(Self);
  BtnExcluir.Parent  := BarraBotoes;
  BtnExcluir.Align   := TAlignLayout.Left;
  BtnExcluir.Width   := 80;
  BtnExcluir.Text    := 'Excluir';
  BtnExcluir.Enabled := False;
  BtnExcluir.OnClick := BtnExcluirClick;

  // Lista
  ScrollLista := TVertScrollBox.Create(Self);
  ScrollLista.Parent := Self;
  ScrollLista.Align  := TAlignLayout.Client;
  ScrollLista.Padding.Rect := TRectF.Create(8, 8, 8, 8);

  // Area de edicao (inicialmente oculta)
  RecEdicao := TRectangle.Create(Self);
  RecEdicao.Parent := Self;
  RecEdicao.Align  := TAlignLayout.Bottom;
  RecEdicao.Height := 120;
  RecEdicao.Fill.Color  := $FFF8F8F8;
  RecEdicao.Stroke.Color := $FFD0D0D0;
  RecEdicao.Padding.Rect := TRectF.Create(12, 10, 12, 10);
  RecEdicao.Visible := False;

  EdtNome := TEdit.Create(Self);
  EdtNome.Parent := RecEdicao;
  EdtNome.Align  := TAlignLayout.Top;
  EdtNome.Height := 36;
  EdtNome.Placeholder.Text := 'Nome do produto';
  EdtNome.Margins.Bottom := 6;

  EdtPreco := TEdit.Create(Self);
  EdtPreco.Parent := RecEdicao;
  EdtPreco.Align  := TAlignLayout.Top;
  EdtPreco.Height := 36;
  EdtPreco.Placeholder.Text := 'Preco';
  EdtPreco.KeyboardType := TVirtualKeyboardType.NumbersAndPunctuation;

  BtnSalvar := TButton.Create(Self);
  BtnSalvar.Parent  := RecEdicao;
  BtnSalvar.Align   := TAlignLayout.Right;
  BtnSalvar.Width   := 80;
  BtnSalvar.Text    := 'Salvar';
  BtnSalvar.OnClick := BtnSalvarClick;

  BtnCancelar := TButton.Create(Self);
  BtnCancelar.Parent  := RecEdicao;
  BtnCancelar.Align   := TAlignLayout.Right;
  BtnCancelar.Width   := 80;
  BtnCancelar.Text    := 'Cancelar';
  BtnCancelar.Margins.Right := 6;
  BtnCancelar.OnClick := BtnCancelarClick;
end;

procedure TFrmCrudPadrao.CarregarLista;
var P: TProduto;
begin
  // Dados de exemplo — na pratica: FProdutos := FProdutoService.Listar
  FProdutos.Clear;
  P.Codigo := 1; P.Nome := 'Notebook Dell XPS';   P.Preco := 8500; FProdutos.Add(P);
  P.Codigo := 2; P.Nome := 'Mouse Logitech MX';   P.Preco := 350;  FProdutos.Add(P);
  P.Codigo := 3; P.Nome := 'Teclado Mecanico';    P.Preco := 650;  FProdutos.Add(P);
  RenderizarLista;
end;

procedure TFrmCrudPadrao.RenderizarLista;
var
  I: Integer;
  Item: TProduto;
  Linha: TRectangle;
  LblNome, LblPreco: TLabel;
  ItemCapturado: TProduto;
begin
  for I := ScrollLista.ControlsCount - 1 downto 0 do
    ScrollLista.Controls[I].Free;

  for Item in FProdutos do
  begin
    ItemCapturado := Item; // capturar para closure

    Linha := TRectangle.Create(ScrollLista);
    Linha.Parent := ScrollLista;
    Linha.Align  := TAlignLayout.Top;
    Linha.Height := 44;
    Linha.Margins.Bottom := 2;
    Linha.Fill.Color  := $FFFFFFFF;
    Linha.Stroke.Color := $FFE8E8E8;
    Linha.Padding.Rect := TRectF.Create(12, 0, 12, 0);
    Linha.Cursor  := crHandPoint;

    LblNome := TLabel.Create(Linha);
    LblNome.Parent := Linha;
    LblNome.Align  := TAlignLayout.Client;
    LblNome.Text   := Item.Nome;
    LblNome.HitTest := False;

    LblPreco := TLabel.Create(Linha);
    LblPreco.Parent := Linha;
    LblPreco.Align  := TAlignLayout.Right;
    LblPreco.Width  := 100;
    LblPreco.Text   := FormatCurr('#,##0.00', Item.Preco);
    LblPreco.TextSettings.HorzAlign := TTextAlign.Trailing;
    LblPreco.HitTest := False;

    Linha.OnClick := procedure(Sender: TObject)
    begin
      SelecionarItem(ItemCapturado);
    end;
  end;
end;

procedure TFrmCrudPadrao.SelecionarItem(const AItem: TProduto);
begin
  FItemSelecionado := AItem;
  BtnEditar.Enabled  := True;
  BtnExcluir.Enabled := True;
end;

procedure TFrmCrudPadrao.BtnNovoClick(Sender: TObject);
begin
  FModoNovo := True;
  EdtNome.Text  := '';
  EdtPreco.Text := '';
  ExibirAreaEdicao(True);
  EdtNome.SetFocus;
end;

procedure TFrmCrudPadrao.BtnEditarClick(Sender: TObject);
begin
  FModoNovo := False;
  EdtNome.Text  := FItemSelecionado.Nome;
  EdtPreco.Text := FormatCurr('#,##0.00', FItemSelecionado.Preco);
  ExibirAreaEdicao(True);
  EdtNome.SetFocus;
end;

procedure TFrmCrudPadrao.BtnExcluirClick(Sender: TObject);
begin
  // PADRAO GESTORERP: confirmacao async com TDialogService
  TDialogService.MessageDialog(
    Format('Excluir "%s"?', [FItemSelecionado.Nome]),
    TMsgDlgType.mtConfirmation,
    [mbYes, mbNo],
    mbNo,
    0,
    procedure(const AResult: TModalResult)
    begin
      if AResult = mrYes then
        ExecutarExclusao;
    end);
end;

procedure TFrmCrudPadrao.ExecutarExclusao;
var I: Integer;
begin
  for I := FProdutos.Count - 1 downto 0 do
    if FProdutos[I].Codigo = FItemSelecionado.Codigo then
    begin
      FProdutos.Delete(I);
      Break;
    end;

  BtnEditar.Enabled  := False;
  BtnExcluir.Enabled := False;
  RenderizarLista;

  TDialogService.ShowMessage('Produto excluido com sucesso.');
end;

procedure TFrmCrudPadrao.BtnSalvarClick(Sender: TObject);
var
  P: TProduto;
  I: Integer;
begin
  if EdtNome.Text.Trim.IsEmpty then
  begin
    TDialogService.ShowMessage('Nome e obrigatorio.');
    Exit;
  end;

  if FModoNovo then
  begin
    P.Codigo := FProdutos.Count + 1; // na pratica: ID do banco
    P.Nome   := EdtNome.Text;
    P.Preco  := StrToCurrDef(EdtPreco.Text.Replace(',', '.'), 0);
    FProdutos.Add(P);
  end
  else
  begin
    for I := 0 to FProdutos.Count - 1 do
      if FProdutos[I].Codigo = FItemSelecionado.Codigo then
      begin
        P := FProdutos[I];
        P.Nome  := EdtNome.Text;
        P.Preco := StrToCurrDef(EdtPreco.Text.Replace(',', '.'), 0);
        FProdutos[I] := P;
        Break;
      end;
  end;

  ExibirAreaEdicao(False);
  RenderizarLista;
end;

procedure TFrmCrudPadrao.BtnCancelarClick(Sender: TObject);
begin
  ExibirAreaEdicao(False);
end;

procedure TFrmCrudPadrao.ExibirAreaEdicao(AVisivel: Boolean);
begin
  RecEdicao.Visible := AVisivel;
end;

end.

unit TEMPLATE_crud_completo;
{
  TEMPLATE: CRUD completo — listagem + modal + confirmacao (FMX / GestorERP)
  Uso: copie e renomeie. Substitua ENTIDADE / TItemEntidade.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Ani,
  FMX.Layouts, FMX.StdCtrls, FMX.Objects, FMX.Edit;

// ---------------------------------------------------------------------------
// VO — ajustar campos conforme a entidade real
// ---------------------------------------------------------------------------
type
  TItemEntidade = record
    Codigo: Integer;
    Nome  : string;
    // Adicionar campos extras aqui
    class function Vazio: TItemEntidade; static;
    class function Novo(ACodigo: Integer; const ANome: string): TItemEntidade; static;
  end;

// ---------------------------------------------------------------------------
// Modal de edicao
// ---------------------------------------------------------------------------
type
  TModalEntidadeCallback = reference to procedure(ASalvou: Boolean;
    ACodigoSalvo: Integer);

  TFrameEntidadeModal = class(TFrame)
  private
    FOverlay   : TRectangle;
    FCartao    : TRectangle;
    FLblTitulo : TLabel;
    FEdtNome   : TEdit;
    FBtnSalvar : TButton;
    FBtnCancelar: TButton;
    FCodigoAtual: Integer;
    FCallback   : TModalEntidadeCallback;

    procedure ConstruirLayout;
    procedure AnimarEntrada;
    procedure AnimarSaida(ASalvou: Boolean; ACodigo: Integer);
    procedure BtnSalvarClick(Sender: TObject);
    procedure BtnCancelarClick(Sender: TObject);
    procedure OverlayClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Abrir(APai: TFmxObject; const AItem: TItemEntidade;
      ACallback: TModalEntidadeCallback);
  end;

// ---------------------------------------------------------------------------
// Frame de listagem com CRUD completo
// ---------------------------------------------------------------------------
type
  TFrameEntidadeCRUD = class(TFrame)
  private
    FPesquisa  : TEdit;
    FScrollBox : TVertScrollBox;
    FBtnNovo   : TButton;
    FItens     : TList<TItemEntidade>;
    FItemAtual : TItemEntidade;

    procedure ConstruirLayout;
    procedure Renderizar(const AFiltro: string = '');
    procedure AbrirModal(const AItem: TItemEntidade);
    procedure ConfirmarExclusao(const AItem: TItemEntidade);
    procedure BtnNovoClick(Sender: TObject);
    procedure PesquisaChange(Sender: TObject);

  protected
    // IMPLEMENTAR NA SUBCLASSE:
    function DoCarregar: TArray<TItemEntidade>; virtual; abstract;
    function DoSalvar(const AItem: TItemEntidade): Integer; virtual; abstract;
    procedure DoExcluir(ACodigo: Integer); virtual; abstract;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Carregar;
  end;

implementation

// ---------------------------------------------------------------------------
// TItemEntidade
// ---------------------------------------------------------------------------

class function TItemEntidade.Vazio: TItemEntidade;
begin
  Result.Codigo := 0;
  Result.Nome   := '';
end;

class function TItemEntidade.Novo(ACodigo: Integer;
  const ANome: string): TItemEntidade;
begin
  Result.Codigo := ACodigo;
  Result.Nome   := ANome;
end;

// ---------------------------------------------------------------------------
// TFrameEntidadeModal
// ---------------------------------------------------------------------------

constructor TFrameEntidadeModal.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ConstruirLayout;
end;

procedure TFrameEntidadeModal.ConstruirLayout;
var
  BarraBotoes: TRectangle;
begin
  FOverlay := TRectangle.Create(Self);
  FOverlay.Parent := Self;
  FOverlay.Align  := TAlignLayout.Client;
  FOverlay.Fill.Color  := $BB000000;
  FOverlay.Stroke.Kind := TBrushKind.None;
  FOverlay.Opacity  := 0;
  FOverlay.OnClick  := OverlayClick;

  FCartao := TRectangle.Create(Self);
  FCartao.Parent  := FOverlay;
  FCartao.Align   := TAlignLayout.Center;
  FCartao.Width   := 400;
  FCartao.Height  := 220;
  FCartao.XRadius := 12;
  FCartao.YRadius := 12;
  FCartao.Fill.Color := $FFFFFFFF;

  FLblTitulo := TLabel.Create(Self);
  FLblTitulo.Parent := FCartao;
  FLblTitulo.Align  := TAlignLayout.Top;
  FLblTitulo.Height := 48;
  FLblTitulo.Padding.Left  := 20;
  FLblTitulo.Padding.Right := 20;
  FLblTitulo.TextSettings.Font.Size  := 15;
  FLblTitulo.TextSettings.Font.Style := [TFontStyle.fsBold];
  FLblTitulo.TextSettings.FontColor  := $FF2C3E50;

  FEdtNome := TEdit.Create(Self);
  FEdtNome.Parent := FCartao;
  FEdtNome.Align  := TAlignLayout.Top;
  FEdtNome.Height := 44;
  FEdtNome.Margins.Rect := TRectF.Create(20, 0, 20, 12);
  FEdtNome.Placeholder.Text := 'Nome';

  BarraBotoes := TRectangle.Create(Self);
  BarraBotoes.Parent := FCartao;
  BarraBotoes.Align  := TAlignLayout.Bottom;
  BarraBotoes.Height := 56;
  BarraBotoes.Fill.Color  := $FFF5F5F5;
  BarraBotoes.Stroke.Kind := TBrushKind.None;
  BarraBotoes.Padding.Rect := TRectF.Create(16, 8, 16, 8);

  FBtnSalvar := TButton.Create(Self);
  FBtnSalvar.Parent  := BarraBotoes;
  FBtnSalvar.Align   := TAlignLayout.Right;
  FBtnSalvar.Width   := 90;
  FBtnSalvar.Text    := 'Salvar';
  FBtnSalvar.OnClick := BtnSalvarClick;

  FBtnCancelar := TButton.Create(Self);
  FBtnCancelar.Parent  := BarraBotoes;
  FBtnCancelar.Align   := TAlignLayout.Right;
  FBtnCancelar.Width   := 90;
  FBtnCancelar.Text    := 'Cancelar';
  FBtnCancelar.Margins.Right := 8;
  FBtnCancelar.OnClick := BtnCancelarClick;
end;

procedure TFrameEntidadeModal.Abrir(APai: TFmxObject; const AItem: TItemEntidade;
  ACallback: TModalEntidadeCallback);
begin
  FCodigoAtual := AItem.Codigo;
  FCallback    := ACallback;
  FLblTitulo.Text := IfThen(AItem.Codigo = 0, 'Novo Registro', 'Editar Registro');
  FEdtNome.Text   := AItem.Nome;

  Parent := APai;
  Align  := TAlignLayout.Client;
  BringToFront;
  AnimarEntrada;
end;

procedure TFrameEntidadeModal.AnimarEntrada;
begin
  FCartao.Position.Y := -30;
  TAnimator.AnimateFloat(FOverlay, 'Opacity', 1, 0.2);
  TAnimator.AnimateFloat(FCartao, 'Position.Y', 0, 0.25,
    TAnimationType.Out, TInterpolationType.Back);
end;

procedure TFrameEntidadeModal.AnimarSaida(ASalvou: Boolean; ACodigo: Integer);
begin
  TAnimator.AnimateFloat(FOverlay, 'Opacity', 0, 0.15,
    TAnimationType.In, TInterpolationType.Linear,
    procedure
    begin
      if Assigned(FCallback) then FCallback(ASalvou, ACodigo);
      Free;
    end);
end;

procedure TFrameEntidadeModal.BtnSalvarClick(Sender: TObject);
begin
  if FEdtNome.Text.Trim.IsEmpty then
  begin
    TDialogService.ShowMessage('Nome e obrigatorio.');
    Exit;
  end;
  AnimarSaida(True, FCodigoAtual);
end;

procedure TFrameEntidadeModal.BtnCancelarClick(Sender: TObject);
begin
  AnimarSaida(False, 0);
end;

procedure TFrameEntidadeModal.OverlayClick(Sender: TObject);
begin
  AnimarSaida(False, 0);
end;

// ---------------------------------------------------------------------------
// TFrameEntidadeCRUD
// ---------------------------------------------------------------------------

constructor TFrameEntidadeCRUD.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItens := TList<TItemEntidade>.Create;
  ConstruirLayout;
end;

destructor TFrameEntidadeCRUD.Destroy;
begin
  FItens.Free;
  inherited;
end;

procedure TFrameEntidadeCRUD.ConstruirLayout;
var
  BarraTopo: TRectangle;
begin
  BarraTopo := TRectangle.Create(Self);
  BarraTopo.Parent := Self;
  BarraTopo.Align  := TAlignLayout.Top;
  BarraTopo.Height := 52;
  BarraTopo.Fill.Color  := $FFF5F5F5;
  BarraTopo.Stroke.Kind := TBrushKind.None;
  BarraTopo.Padding.Rect := TRectF.Create(12, 6, 12, 6);

  FBtnNovo := TButton.Create(Self);
  FBtnNovo.Parent  := BarraTopo;
  FBtnNovo.Align   := TAlignLayout.Right;
  FBtnNovo.Width   := 80;
  FBtnNovo.Text    := '+ Novo';
  FBtnNovo.OnClick := BtnNovoClick;

  FPesquisa := TEdit.Create(Self);
  FPesquisa.Parent := BarraTopo;
  FPesquisa.Align  := TAlignLayout.Client;
  FPesquisa.Margins.Right := 8;
  FPesquisa.Placeholder.Text := 'Pesquisar...';
  FPesquisa.OnChangeTracking := PesquisaChange;

  FScrollBox := TVertScrollBox.Create(Self);
  FScrollBox.Parent := Self;
  FScrollBox.Align  := TAlignLayout.Client;
  FScrollBox.Padding.Rect := TRectF.Create(12, 8, 12, 8);
  FScrollBox.AniCalculations.AutoShowing := False;
end;

procedure TFrameEntidadeCRUD.Carregar;
var Itens: TArray<TItemEntidade>; Item: TItemEntidade;
begin
  Itens := DoCarregar;
  FItens.Clear;
  for Item in Itens do FItens.Add(Item);
  Renderizar;
end;

procedure TFrameEntidadeCRUD.Renderizar(const AFiltro: string);
var
  I: Integer; Item: TItemEntidade;
  Linha: TRectangle; Lbl, LblEdit, LblDel: TLabel;
  ItemCap: TItemEntidade;
begin
  for I := FScrollBox.ControlsCount - 1 downto 0 do
    FScrollBox.Controls[I].Free;

  for Item in FItens do
  begin
    if (AFiltro <> '') and
       (not Item.Nome.ToLower.Contains(AFiltro.ToLower)) then Continue;

    ItemCap := Item;

    Linha := TRectangle.Create(FScrollBox);
    Linha.Parent := FScrollBox;
    Linha.Align  := TAlignLayout.Top;
    Linha.Height := 48;
    Linha.Margins.Bottom := 2;
    Linha.Fill.Color  := $FFFFFFFF;
    Linha.Stroke.Color := $FFE8E8E8;
    Linha.Padding.Rect := TRectF.Create(12, 0, 8, 0);

    Lbl := TLabel.Create(Linha);
    Lbl.Parent  := Linha;
    Lbl.Align   := TAlignLayout.Client;
    Lbl.Text    := Item.Nome;
    Lbl.HitTest := False;

    // Botao excluir
    LblDel := TLabel.Create(Linha);
    LblDel.Parent := Linha;
    LblDel.Align  := TAlignLayout.Right;
    LblDel.Width  := 60;
    LblDel.Text   := 'Excluir';
    LblDel.TextSettings.FontColor := $FFE74C3C;
    LblDel.Cursor  := crHandPoint;
    LblDel.OnClick := procedure(Sender: TObject) begin ConfirmarExclusao(ItemCap); end;

    // Botao editar
    LblEdit := TLabel.Create(Linha);
    LblEdit.Parent := Linha;
    LblEdit.Align  := TAlignLayout.Right;
    LblEdit.Width  := 55;
    LblEdit.Text   := 'Editar';
    LblEdit.TextSettings.FontColor := $FF3498DB;
    LblEdit.Cursor  := crHandPoint;
    LblEdit.Margins.Right := 4;
    LblEdit.OnClick := procedure(Sender: TObject) begin AbrirModal(ItemCap); end;
  end;
end;

procedure TFrameEntidadeCRUD.AbrirModal(const AItem: TItemEntidade);
var Modal: TFrameEntidadeModal;
begin
  Modal := TFrameEntidadeModal.Create(Self);
  Modal.Abrir(Self, AItem,
    procedure(ASalvou: Boolean; ACodigoSalvo: Integer)
    begin
      if ASalvou then Carregar;
    end);
end;

procedure TFrameEntidadeCRUD.ConfirmarExclusao(const AItem: TItemEntidade);
begin
  TDialogService.MessageDialog(
    Format('Excluir "%s"?', [AItem.Nome]),
    TMsgDlgType.mtConfirmation, [mbYes, mbNo], mbNo, 0,
    procedure(const AResult: TModalResult)
    begin
      if AResult = mrYes then
      begin
        DoExcluir(AItem.Codigo);
        Carregar;
      end;
    end);
end;

procedure TFrameEntidadeCRUD.BtnNovoClick(Sender: TObject);
begin
  AbrirModal(TItemEntidade.Vazio);
end;

procedure TFrameEntidadeCRUD.PesquisaChange(Sender: TObject);
begin
  Renderizar(FPesquisa.Text);
end;

end.

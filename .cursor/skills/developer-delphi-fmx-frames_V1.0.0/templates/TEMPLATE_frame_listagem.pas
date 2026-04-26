unit TEMPLATE_frame_listagem;
{
  TEMPLATE: Frame de listagem com hover e selecao (FMX / GestorERP)
  Uso: copie e renomeie. Substitua ENTIDADE pelo nome real.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Ani,
  FMX.Layouts, FMX.StdCtrls, FMX.Objects, FMX.Edit;

// VO para cada linha da listagem
type
  TItemEntidade = record
    Codigo: Integer;
    Nome  : string;
    // Adicionar outros campos da entidade
    class function Novo(ACodigo: Integer; const ANome: string): TItemEntidade; static;
  end;

// Componente de linha da listagem
type
  TLinhaEntidade = class(TRectangle)
  private
    FItem: TItemEntidade;
    LblCodigo: TLabel;
    LblNome  : TLabel;
    FOnSelecionar: TProc<TItemEntidade>;
    procedure MouseEnter(Sender: TObject);
    procedure MouseLeave(Sender: TObject);
    procedure Click(Sender: TObject);
  public
    constructor Criar(AOwner: TComponent; const AItem: TItemEntidade;
      AOnSelecionar: TProc<TItemEntidade>); reintroduce;
    property Item: TItemEntidade read FItem;
  end;

// Frame principal de listagem
type
  TFrameEntidadeListagem = class(TFrame)
  private
    FPesquisa   : TEdit;
    FScrollBox  : TVertScrollBox;
    FBtnNovo    : TButton;
    FItens      : TList<TItemEntidade>;
    FItemSelecionado: TItemEntidade;
    FOnAbrir    : TProc<TItemEntidade>;

    procedure ConstruirLayout;
    procedure PesquisaChange(Sender: TObject);
    procedure BtnNovoClick(Sender: TObject);
    procedure SelecionarItem(const AItem: TItemEntidade);
    procedure RenderizarLista(const AFiltro: string = '');
  protected
    // IMPLEMENTAR NA SUBCLASSE:
    // Retornar lista de itens (banco, servico, etc.)
    function DoCarregarItens: TArray<TItemEntidade>; virtual; abstract;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Carregar;
    procedure Recarregar;

    property OnAbrir   : TProc<TItemEntidade> read FOnAbrir    write FOnAbrir;
    property ItemSelecionado: TItemEntidade   read FItemSelecionado;
  end;

implementation

// ---------------------------------------------------------------------------
// TItemEntidade
// ---------------------------------------------------------------------------

class function TItemEntidade.Novo(ACodigo: Integer;
  const ANome: string): TItemEntidade;
begin
  Result.Codigo := ACodigo;
  Result.Nome   := ANome;
end;

// ---------------------------------------------------------------------------
// TLinhaEntidade
// ---------------------------------------------------------------------------

constructor TLinhaEntidade.Criar(AOwner: TComponent; const AItem: TItemEntidade;
  AOnSelecionar: TProc<TItemEntidade>);
begin
  inherited Create(AOwner);
  FItem         := AItem;
  FOnSelecionar := AOnSelecionar;

  Height := 52;
  Align  := TAlignLayout.Top;
  Margins.Bottom := 1;
  Fill.Color   := $FFFFFFFF;
  Stroke.Color := $FFE8E8E8;
  XRadius := 6;
  YRadius := 6;
  Padding.Rect := TRectF.Create(12, 0, 12, 0);
  Cursor := crHandPoint;

  OnMouseEnter := MouseEnter;
  OnMouseLeave := MouseLeave;
  OnClick      := Click;

  LblCodigo := TLabel.Create(Self);
  LblCodigo.Parent := Self;
  LblCodigo.Align  := TAlignLayout.Left;
  LblCodigo.Width  := 60;
  LblCodigo.Text   := '#' + AItem.Codigo.ToString;
  LblCodigo.TextSettings.FontColor := $FF95A5A6;
  LblCodigo.TextSettings.Font.Size := 12;

  LblNome := TLabel.Create(Self);
  LblNome.Parent := Self;
  LblNome.Align  := TAlignLayout.Client;
  LblNome.Text   := AItem.Nome;
  LblNome.TextSettings.FontColor := $FF2C3E50;
end;

procedure TLinhaEntidade.MouseEnter(Sender: TObject);
begin
  TAnimator.AnimateColor(Self, 'Fill.Color', $FFF0F4FF, 0.15);
end;

procedure TLinhaEntidade.MouseLeave(Sender: TObject);
begin
  TAnimator.AnimateColor(Self, 'Fill.Color', $FFFFFFFF, 0.15);
end;

procedure TLinhaEntidade.Click(Sender: TObject);
begin
  if Assigned(FOnSelecionar) then
    FOnSelecionar(FItem);
end;

// ---------------------------------------------------------------------------
// TFrameEntidadeListagem
// ---------------------------------------------------------------------------

constructor TFrameEntidadeListagem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItens := TList<TItemEntidade>.Create;
  ConstruirLayout;
end;

destructor TFrameEntidadeListagem.Destroy;
begin
  FItens.Free;
  inherited;
end;

procedure TFrameEntidadeListagem.ConstruirLayout;
var
  BarraTopo: TRectangle;
begin
  // Barra superior: pesquisa + novo
  BarraTopo := TRectangle.Create(Self);
  BarraTopo.Parent := Self;
  BarraTopo.Align  := TAlignLayout.Top;
  BarraTopo.Height := 56;
  BarraTopo.Fill.Color  := $FFF8F8F8;
  BarraTopo.Stroke.Kind := TBrushKind.None;
  BarraTopo.Padding.Rect := TRectF.Create(12, 8, 12, 8);

  FBtnNovo := TButton.Create(Self);
  FBtnNovo.Parent  := BarraTopo;
  FBtnNovo.Align   := TAlignLayout.Right;
  FBtnNovo.Width   := 80;
  FBtnNovo.Text    := '+ Novo';
  FBtnNovo.OnClick := BtnNovoClick;

  FPesquisa := TEdit.Create(Self);
  FPesquisa.Parent := BarraTopo;
  FPesquisa.Align  := TAlignLayout.Client;
  FPesquisa.Placeholder.Text := 'Pesquisar...';
  FPesquisa.Margins.Right := 8;
  FPesquisa.OnChangeTracking := PesquisaChange;

  // Area de scroll para as linhas
  FScrollBox := TVertScrollBox.Create(Self);
  FScrollBox.Parent := Self;
  FScrollBox.Align  := TAlignLayout.Client;
  FScrollBox.Padding.Rect := TRectF.Create(12, 8, 12, 8);
  FScrollBox.AniCalculations.AutoShowing := False;
end;

procedure TFrameEntidadeListagem.Carregar;
var
  Itens: TArray<TItemEntidade>;
  Item: TItemEntidade;
begin
  Itens := DoCarregarItens;
  FItens.Clear;
  for Item in Itens do
    FItens.Add(Item);
  RenderizarLista;
end;

procedure TFrameEntidadeListagem.Recarregar;
begin
  Carregar;
end;

procedure TFrameEntidadeListagem.RenderizarLista(const AFiltro: string);
var
  I: Integer;
  Item: TItemEntidade;
  Linha: TLinhaEntidade;
  Filtro: string;
begin
  // Limpar linhas existentes
  for I := FScrollBox.ControlsCount - 1 downto 0 do
    FScrollBox.Controls[I].Free;

  Filtro := AFiltro.ToLower;

  for Item in FItens do
  begin
    // Filtrar por texto de pesquisa
    if (Filtro <> '') and
       (not Item.Nome.ToLower.Contains(Filtro)) and
       (not Item.Codigo.ToString.Contains(Filtro)) then
      Continue;

    Linha := TLinhaEntidade.Criar(FScrollBox, Item,
      procedure(AItem: TItemEntidade)
      begin
        SelecionarItem(AItem);
      end);
    Linha.Parent := FScrollBox;
  end;
end;

procedure TFrameEntidadeListagem.SelecionarItem(const AItem: TItemEntidade);
begin
  FItemSelecionado := AItem;
  if Assigned(FOnAbrir) then
    FOnAbrir(AItem);
end;

procedure TFrameEntidadeListagem.PesquisaChange(Sender: TObject);
begin
  RenderizarLista(FPesquisa.Text);
end;

procedure TFrameEntidadeListagem.BtnNovoClick(Sender: TObject);
var
  ItemVazio: TItemEntidade;
begin
  ItemVazio := TItemEntidade.Novo(0, '');
  if Assigned(FOnAbrir) then
    FOnAbrir(ItemVazio);
end;

end.

unit TEMPLATE_frame_crud;
{
  TEMPLATE: Frame base CRUD com eventos abstratos (FMX / GestorERP)
  Uso: copie e renomeie. Substitua ENTIDADE pelo nome real (ex.: Cliente, Produto).
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Layouts, FMX.StdCtrls, FMX.Objects, FMX.Edit, FMX.Dialogs;

type
  TFrameEntidadeCRUD = class(TFrame)
  private
    // --- Layout ---
    FScrollBox: TVertScrollBox;
    FRecBotoes: TRectangle;
    FBtnNovo   : TButton;
    FBtnSalvar : TButton;
    FBtnCancelar: TButton;
    FBtnExcluir: TButton;

    // --- Estado ---
    FCodigoAtual: Integer; // 0 = novo registro
    FModoEdicao : Boolean;

    // --- Layout interno ---
    procedure ConstruirLayout;
    procedure AtualizarEstadoBotoes;

    // --- Handlers ---
    procedure BtnNovoClick(Sender: TObject);
    procedure BtnSalvarClick(Sender: TObject);
    procedure BtnCancelarClick(Sender: TObject);
    procedure BtnExcluirClick(Sender: TObject);

  protected
    // IMPLEMENTAR NA SUBCLASSE:

    // Limpar todos os campos para novo registro
    procedure DoNovo; virtual; abstract;

    // Salvar os dados (INSERT se FCodigoAtual=0, UPDATE caso contrario)
    // Retornar o codigo do registro salvo (para FCodigoAtual)
    function DoSalvar: Integer; virtual; abstract;

    // Restaurar campos com dados do FCodigoAtual (desfaz edicao)
    procedure DoCancelar; virtual; abstract;

    // Excluir o registro FCodigoAtual
    procedure DoExcluir; virtual; abstract;

    // Preencher campos com dados do codigo informado
    procedure DoCarregar(ACodigo: Integer); virtual; abstract;

    // Validar antes de salvar — retorna mensagem de erro ou vazio
    function DoValidar: string; virtual;

    // Container de campos (para subclasses adicionarem TEdit, etc.)
    property AreaCampos: TVertScrollBox read FScrollBox;

  public
    constructor Create(AOwner: TComponent); override;

    // API publica
    procedure Novo;
    procedure Carregar(ACodigo: Integer);

    property CodigoAtual: Integer read FCodigoAtual;
    property ModoEdicao: Boolean read FModoEdicao;
  end;

implementation

constructor TFrameEntidadeCRUD.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ConstruirLayout;
end;

procedure TFrameEntidadeCRUD.ConstruirLayout;
begin
  // Area de campos (scrollavel)
  FScrollBox := TVertScrollBox.Create(Self);
  FScrollBox.Parent := Self;
  FScrollBox.Align  := TAlignLayout.Client;
  FScrollBox.Padding.Rect := TRectF.Create(16, 16, 16, 8);
  FScrollBox.AniCalculations.AutoShowing := False;

  // Barra de botoes na parte inferior
  FRecBotoes := TRectangle.Create(Self);
  FRecBotoes.Parent := Self;
  FRecBotoes.Align  := TAlignLayout.Bottom;
  FRecBotoes.Height := 56;
  FRecBotoes.Fill.Color  := $FFF8F8F8;
  FRecBotoes.Stroke.Color := $FFE0E0E0;
  FRecBotoes.Padding.Rect := TRectF.Create(12, 8, 12, 8);

  FBtnNovo := TButton.Create(Self);
  FBtnNovo.Parent  := FRecBotoes;
  FBtnNovo.Align   := TAlignLayout.Left;
  FBtnNovo.Width   := 80;
  FBtnNovo.Text    := 'Novo';
  FBtnNovo.OnClick := BtnNovoClick;
  FBtnNovo.Margins.Right := 4;

  FBtnExcluir := TButton.Create(Self);
  FBtnExcluir.Parent  := FRecBotoes;
  FBtnExcluir.Align   := TAlignLayout.Left;
  FBtnExcluir.Width   := 80;
  FBtnExcluir.Text    := 'Excluir';
  FBtnExcluir.OnClick := BtnExcluirClick;
  FBtnExcluir.Margins.Right := 4;

  FBtnCancelar := TButton.Create(Self);
  FBtnCancelar.Parent  := FRecBotoes;
  FBtnCancelar.Align   := TAlignLayout.Right;
  FBtnCancelar.Width   := 90;
  FBtnCancelar.Text    := 'Cancelar';
  FBtnCancelar.OnClick := BtnCancelarClick;
  FBtnCancelar.Margins.Left := 4;

  FBtnSalvar := TButton.Create(Self);
  FBtnSalvar.Parent  := FRecBotoes;
  FBtnSalvar.Align   := TAlignLayout.Right;
  FBtnSalvar.Width   := 80;
  FBtnSalvar.Text    := 'Salvar';
  FBtnSalvar.OnClick := BtnSalvarClick;
  FBtnSalvar.Margins.Left := 4;

  AtualizarEstadoBotoes;
end;

procedure TFrameEntidadeCRUD.AtualizarEstadoBotoes;
begin
  FBtnSalvar.Enabled   := FModoEdicao;
  FBtnCancelar.Enabled := FModoEdicao;
  FBtnExcluir.Enabled  := (not FModoEdicao) and (FCodigoAtual > 0);
  FBtnNovo.Enabled     := not FModoEdicao;
end;

function TFrameEntidadeCRUD.DoValidar: string;
begin
  Result := ''; // sem validacao por padrao — subclasse pode sobrescrever
end;

procedure TFrameEntidadeCRUD.Novo;
begin
  FCodigoAtual := 0;
  FModoEdicao  := True;
  DoNovo;
  AtualizarEstadoBotoes;
end;

procedure TFrameEntidadeCRUD.Carregar(ACodigo: Integer);
begin
  FCodigoAtual := ACodigo;
  FModoEdicao  := False;
  DoCarregar(ACodigo);
  AtualizarEstadoBotoes;
end;

procedure TFrameEntidadeCRUD.BtnNovoClick(Sender: TObject);
begin
  Novo;
end;

procedure TFrameEntidadeCRUD.BtnSalvarClick(Sender: TObject);
var
  Erro: string;
begin
  Erro := DoValidar;
  if not Erro.IsEmpty then
  begin
    TDialogService.ShowMessage(Erro);
    Exit;
  end;

  FCodigoAtual := DoSalvar;
  FModoEdicao  := False;
  AtualizarEstadoBotoes;
end;

procedure TFrameEntidadeCRUD.BtnCancelarClick(Sender: TObject);
begin
  FModoEdicao := False;
  DoCancelar;
  AtualizarEstadoBotoes;
end;

procedure TFrameEntidadeCRUD.BtnExcluirClick(Sender: TObject);
begin
  TDialogService.MessageDialog('Confirmar exclusao?',
    TMsgDlgType.mtConfirmation, [mbYes, mbNo], mbNo, 0,
    procedure(const AResult: TModalResult)
    begin
      if AResult = mrYes then
      begin
        DoExcluir;
        Novo; // apos excluir, preparar para novo registro
      end;
    end);
end;

end.

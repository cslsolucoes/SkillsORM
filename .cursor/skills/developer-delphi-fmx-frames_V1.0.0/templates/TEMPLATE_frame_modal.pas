unit TEMPLATE_frame_modal;
{
  TEMPLATE: Frame modal com overlay, animacao, Salvar/Cancelar (FMX / GestorERP)
  Uso: copie e renomeie. Substitua ENTIDADE pelo nome real.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Ani,
  FMX.Layouts, FMX.StdCtrls, FMX.Objects, FMX.Edit, FMX.Dialogs;

type
  TModalEntidadeCallback = reference to procedure(ASalvou: Boolean;
    ACodigoSalvo: Integer);

type
  TFrameEntidadeModal = class(TFrame)
  private
    // Layout
    FOverlay   : TRectangle;
    FCartao    : TRectangle;
    FBtnSalvar : TButton;
    FBtnCancelar: TButton;
    FLblTitulo : TLabel;

    // Estado
    FCodigoAtual: Integer;
    FCallback   : TModalEntidadeCallback;

    procedure ConstruirLayout;
    procedure AnimarEntrada;
    procedure AnimarSaida(ASalvou: Boolean; ACodigoSalvo: Integer);
    procedure BtnSalvarClick(Sender: TObject);
    procedure BtnCancelarClick(Sender: TObject);
    procedure OverlayClick(Sender: TObject);

  protected
    // Area de campos — subclasse adiciona TEdit aqui
    property AreaCampos: TRectangle read FCartao;

    // IMPLEMENTAR NA SUBCLASSE:

    // Preencher campos com dados do ACodigo (0 = novo)
    procedure DoCarregar(ACodigo: Integer); virtual; abstract;

    // Validar campos — retorna mensagem de erro ou ''
    function DoValidar: string; virtual;

    // Persistir dados — retornar codigo do registro salvo
    function DoSalvar: Integer; virtual; abstract;

    // Limpar campos para novo registro
    procedure DoNovo; virtual; abstract;

  public
    constructor Create(AOwner: TComponent); override;

    // Abrir o modal sobre o form/frame pai
    procedure Abrir(APai: TFmxObject; ACodigo: Integer;
      ACallback: TModalEntidadeCallback);

    // Fechar programaticamente (ex.: ESC)
    procedure Fechar(ASalvou: Boolean = False);
  end;

implementation

constructor TFrameEntidadeModal.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ConstruirLayout;
end;

procedure TFrameEntidadeModal.ConstruirLayout;
var
  BarraBotoes: TRectangle;
begin
  // Overlay escurecido — cobre tudo
  FOverlay := TRectangle.Create(Self);
  FOverlay.Parent := Self;
  FOverlay.Align  := TAlignLayout.Client;
  FOverlay.Fill.Color  := $BB000000;
  FOverlay.Stroke.Kind := TBrushKind.None;
  FOverlay.Opacity  := 0;
  FOverlay.OnClick  := OverlayClick;

  // Card central
  FCartao := TRectangle.Create(Self);
  FCartao.Parent := FOverlay;
  FCartao.Align  := TAlignLayout.Center;
  FCartao.Width  := 420;
  FCartao.Height := 320;
  FCartao.XRadius := 12;
  FCartao.YRadius := 12;
  FCartao.Fill.Color := $FFFFFFFF;

  // Titulo do modal
  FLblTitulo := TLabel.Create(Self);
  FLblTitulo.Parent := FCartao;
  FLblTitulo.Align  := TAlignLayout.Top;
  FLblTitulo.Height := 48;
  FLblTitulo.Text   := 'Cadastro de Entidade';
  FLblTitulo.TextSettings.Font.Size  := 16;
  FLblTitulo.TextSettings.Font.Style := [TFontStyle.fsBold];
  FLblTitulo.TextSettings.FontColor  := $FF2C3E50;
  FLblTitulo.Padding.Left  := 20;
  FLblTitulo.Padding.Right := 20;

  // Barra de botoes na base do card
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
  FBtnSalvar.Width   := 100;
  FBtnSalvar.Text    := 'Salvar';
  FBtnSalvar.OnClick := BtnSalvarClick;

  FBtnCancelar := TButton.Create(Self);
  FBtnCancelar.Parent  := BarraBotoes;
  FBtnCancelar.Align   := TAlignLayout.Right;
  FBtnCancelar.Width   := 90;
  FBtnCancelar.Text    := 'Cancelar';
  FBtnCancelar.Margins.Right := 8;
  FBtnCancelar.OnClick := BtnCancelarClick;

  // Subclasse adiciona TEdit entre FLblTitulo e BarraBotoes
  // usando FCartao como Parent e TAlignLayout.Top
end;

function TFrameEntidadeModal.DoValidar: string;
begin
  Result := '';
end;

procedure TFrameEntidadeModal.Abrir(APai: TFmxObject; ACodigo: Integer;
  ACallback: TModalEntidadeCallback);
begin
  FCodigoAtual := ACodigo;
  FCallback    := ACallback;

  Parent := APai;
  Align  := TAlignLayout.Client;
  BringToFront;

  if ACodigo = 0 then
    DoNovo
  else
    DoCarregar(ACodigo);

  AnimarEntrada;
end;

procedure TFrameEntidadeModal.AnimarEntrada;
begin
  FCartao.Position.Y := -30;
  TAnimator.AnimateFloat(FOverlay, 'Opacity', 1, 0.2);
  TAnimator.AnimateFloat(FCartao, 'Position.Y', 0, 0.25,
    TAnimationType.Out, TInterpolationType.Back);
end;

procedure TFrameEntidadeModal.AnimarSaida(ASalvou: Boolean;
  ACodigoSalvo: Integer);
begin
  TAnimator.AnimateFloat(FOverlay, 'Opacity', 0, 0.15,
    TAnimationType.In, TInterpolationType.Linear,
    procedure
    begin
      if Assigned(FCallback) then
        FCallback(ASalvou, ACodigoSalvo);
      Free;
    end);
end;

procedure TFrameEntidadeModal.BtnSalvarClick(Sender: TObject);
var
  Erro: string;
  Codigo: Integer;
begin
  Erro := DoValidar;
  if not Erro.IsEmpty then
  begin
    TDialogService.ShowMessage(Erro);
    Exit;
  end;

  Codigo := DoSalvar;
  AnimarSaida(True, Codigo);
end;

procedure TFrameEntidadeModal.BtnCancelarClick(Sender: TObject);
begin
  AnimarSaida(False, 0);
end;

procedure TFrameEntidadeModal.OverlayClick(Sender: TObject);
begin
  AnimarSaida(False, 0);
end;

procedure TFrameEntidadeModal.Fechar(ASalvou: Boolean);
begin
  AnimarSaida(ASalvou, FCodigoAtual);
end;

// ---------------------------------------------------------------------------
// COMO USAR:
//
//   var Modal := TFrameEntidadeModal.Create(Self);
//   Modal.Abrir(Self, CodigoParaEditar,
//     procedure(ASalvou: Boolean; ACodigoSalvo: Integer)
//     begin
//       if ASalvou then
//         FrameListagem.Recarregar;
//     end);
//
// ---------------------------------------------------------------------------

end.

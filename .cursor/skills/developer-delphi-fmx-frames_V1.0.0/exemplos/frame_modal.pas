unit frame_modal;
{
  EXEMPLO: Frame como modal — CarregarDados + Salvar/Cancelar (GestorERP)
  Compilavel: dcc32 / dcc64
  Demonstra:
    - Frame exibido sobre um overlay semi-transparente
    - Callback de confirmacao (Salvar / Cancelar)
    - Animacao de entrada (fade + slide)
    - Fechar com ESC ou clique no overlay
}

interface

uses
  System.SysUtils, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Ani,
  FMX.Layouts, FMX.StdCtrls, FMX.Objects, FMX.Edit;

type
  TModalResultado = (mrSalvo, mrCancelado);
  TModalCallback  = reference to procedure(AResultado: TModalResultado);

// ---------------------------------------------------------------------------
// Frame modal: edicao de um item
// ---------------------------------------------------------------------------
type
  TFrameModalEdicao = class(TFrame)
  private
    FOverlay : TRectangle;   // fundo escurecido
    FCartao  : TRectangle;   // card branco central
    EdtNome  : TEdit;
    BtnSalvar  : TButton;
    BtnCancelar: TButton;
    FCallback: TModalCallback;
    FCodigoItem: Integer;

    procedure ConstruirLayout;
    procedure AnimarEntrada;
    procedure AnimarSaida(AResultado: TModalResultado);
    procedure BtnSalvarClick(Sender: TObject);
    procedure BtnCancelarClick(Sender: TObject);
    procedure OverlayClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;

    // Abrir o modal sobre o form pai
    procedure Abrir(AFormPai: TFmxObject; ACodigoItem: Integer;
      ACallback: TModalCallback);

    // Fechar programaticamente
    procedure Fechar(AResultado: TModalResultado);
  end;

// ---------------------------------------------------------------------------
// Form de exemplo que usa o modal
// ---------------------------------------------------------------------------
type
  TFrmListagem = class(TForm)
  private
    procedure BtnEditarClick(Sender: TObject);
  end;

implementation

// ---------------------------------------------------------------------------
// TFrameModalEdicao
// ---------------------------------------------------------------------------

constructor TFrameModalEdicao.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ConstruirLayout;
end;

procedure TFrameModalEdicao.ConstruirLayout;
begin
  // Overlay semi-transparente sobre tudo
  FOverlay := TRectangle.Create(Self);
  FOverlay.Parent := Self;
  FOverlay.Align  := TAlignLayout.Client;
  FOverlay.Fill.Color := $CC000000; // preto 80% opaco
  FOverlay.Stroke.Kind := TBrushKind.None;
  FOverlay.Opacity := 0; // sera animado
  FOverlay.OnClick := OverlayClick;

  // Card branco centralizado
  FCartao := TRectangle.Create(Self);
  FCartao.Parent := FOverlay;
  FCartao.Align  := TAlignLayout.Center;
  FCartao.Width  := 360;
  FCartao.Height := 200;
  FCartao.XRadius := 12;
  FCartao.YRadius := 12;
  FCartao.Fill.Color := $FFFFFFFF;
  FCartao.Position.Y := -40; // posicao inicial para animacao slide
  FCartao.Padding.Rect := TRectF.Create(20, 20, 20, 20);

  // Campo de edicao
  EdtNome := TEdit.Create(Self);
  EdtNome.Parent := FCartao;
  EdtNome.Align  := TAlignLayout.Top;
  EdtNome.Height := 44;
  EdtNome.Placeholder.Text := 'Nome do item';
  EdtNome.Margins.Bottom := 12;

  // Botao Salvar
  BtnSalvar := TButton.Create(Self);
  BtnSalvar.Parent  := FCartao;
  BtnSalvar.Align   := TAlignLayout.Right;
  BtnSalvar.Width   := 100;
  BtnSalvar.Height  := 40;
  BtnSalvar.Text    := 'Salvar';
  BtnSalvar.OnClick := BtnSalvarClick;

  // Botao Cancelar
  BtnCancelar := TButton.Create(Self);
  BtnCancelar.Parent  := FCartao;
  BtnCancelar.Align   := TAlignLayout.Left;
  BtnCancelar.Width   := 100;
  BtnCancelar.Height  := 40;
  BtnCancelar.Text    := 'Cancelar';
  BtnCancelar.OnClick := BtnCancelarClick;
end;

procedure TFrameModalEdicao.Abrir(AFormPai: TFmxObject; ACodigoItem: Integer;
  ACallback: TModalCallback);
begin
  FCodigoItem := ACodigoItem;
  FCallback   := ACallback;

  // Embutir no form pai cobrindo tudo
  Parent := AFormPai;
  Align  := TAlignLayout.Client;

  // Trazer para frente
  BringToFront;

  AnimarEntrada;
end;

procedure TFrameModalEdicao.AnimarEntrada;
begin
  // Fade in do overlay
  TAnimator.AnimateFloat(FOverlay, 'Opacity', 1, 0.2);

  // Slide down do card
  TAnimator.AnimateFloat(FCartao, 'Position.Y', 0, 0.25,
    TAnimationType.Out, TInterpolationType.Back);
end;

procedure TFrameModalEdicao.AnimarSaida(AResultado: TModalResultado);
begin
  TAnimator.AnimateFloat(FOverlay, 'Opacity', 0, 0.15,
    TAnimationType.In, TInterpolationType.Linear,
    procedure
    begin
      if Assigned(FCallback) then
        FCallback(AResultado);
      Free; // auto-destruir apos animacao
    end);
end;

procedure TFrameModalEdicao.BtnSalvarClick(Sender: TObject);
begin
  // Validar
  if EdtNome.Text.Trim.IsEmpty then
    Exit;
  // Salvar dados: FItemService.Salvar(FCodigoItem, EdtNome.Text);
  AnimarSaida(TModalResultado.mrSalvo);
end;

procedure TFrameModalEdicao.BtnCancelarClick(Sender: TObject);
begin
  AnimarSaida(TModalResultado.mrCancelado);
end;

procedure TFrameModalEdicao.OverlayClick(Sender: TObject);
begin
  AnimarSaida(TModalResultado.mrCancelado);
end;

procedure TFrameModalEdicao.Fechar(AResultado: TModalResultado);
begin
  AnimarSaida(AResultado);
end;

// ---------------------------------------------------------------------------
// TFrmListagem
// ---------------------------------------------------------------------------

procedure TFrmListagem.BtnEditarClick(Sender: TObject);
var
  Modal: TFrameModalEdicao;
begin
  Modal := TFrameModalEdicao.Create(Self);
  Modal.Abrir(Self, 42,
    procedure(AResultado: TModalResultado)
    begin
      if AResultado = TModalResultado.mrSalvo then
      begin
        // Recarregar listagem apos salvar
        // CarregarLista;
      end;
    end);
end;

end.

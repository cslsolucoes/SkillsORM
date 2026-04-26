unit frame_basico;
{
  EXEMPLO: Criar e embutir TFrame em runtime (FMX)
  Compilavel: dcc32 / dcc64
  Demonstra:
    - Definicao minima de TFrame
    - Criar frame via constructor
    - Embutir em container (Parent + Align)
    - Destruir frame corretamente
}

interface

uses
  System.SysUtils, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Layouts,
  FMX.StdCtrls, FMX.Objects;

// ---------------------------------------------------------------------------
// Frame reutilizavel: exibe um cartao com titulo e descricao
// ---------------------------------------------------------------------------
type
  TFrameCartao = class(TFrame)
    RecFundo: TRectangle;
    LblTitulo: TLabel;
    LblDescricao: TLabel;
  private
    procedure Configurar;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Preencher(const ATitulo, ADescricao: string);
  end;

// ---------------------------------------------------------------------------
// Form principal que embute o frame
// ---------------------------------------------------------------------------
type
  TFrmExemploFrame = class(TForm)
    RecConteiner: TRectangle;  // container onde o frame sera embutido
    BtnCriar: TButton;
    BtnDestruir: TButton;
  private
    FFrame: TFrameCartao;
    procedure BtnCriarClick(Sender: TObject);
    procedure BtnDestruirClick(Sender: TObject);
  end;

implementation

// ---------------------------------------------------------------------------
// TFrameCartao
// ---------------------------------------------------------------------------

constructor TFrameCartao.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Configurar;
end;

procedure TFrameCartao.Configurar;
begin
  // Dimensoes padrao (podem ser sobrescritas por Align no parent)
  Width  := 300;
  Height := 120;

  // Fundo com borda arredondada
  RecFundo := TRectangle.Create(Self);
  RecFundo.Parent := Self;
  RecFundo.Align  := TAlignLayout.Client;
  RecFundo.Fill.Color := $FFFFFFFF;
  RecFundo.Stroke.Color := $FFD0D0D0;
  RecFundo.XRadius := 8;
  RecFundo.YRadius := 8;
  RecFundo.Padding.Rect := TRectF.Create(12, 12, 12, 12);

  // Label titulo
  LblTitulo := TLabel.Create(Self);
  LblTitulo.Parent := RecFundo;
  LblTitulo.Align  := TAlignLayout.Top;
  LblTitulo.Height := 28;
  LblTitulo.Text   := 'Titulo';
  LblTitulo.TextSettings.Font.Size   := 14;
  LblTitulo.TextSettings.Font.Style  := [TFontStyle.fsBold];
  LblTitulo.TextSettings.FontColor   := $FF2C3E50;

  // Label descricao
  LblDescricao := TLabel.Create(Self);
  LblDescricao.Parent    := RecFundo;
  LblDescricao.Align     := TAlignLayout.Client;
  LblDescricao.Text      := 'Descricao aqui';
  LblDescricao.WordWrap  := True;
  LblDescricao.TextSettings.FontColor := $FF7F8C8D;
end;

procedure TFrameCartao.Preencher(const ATitulo, ADescricao: string);
begin
  LblTitulo.Text    := ATitulo;
  LblDescricao.Text := ADescricao;
end;

// ---------------------------------------------------------------------------
// TFrmExemploFrame
// ---------------------------------------------------------------------------

procedure TFrmExemploFrame.BtnCriarClick(Sender: TObject);
begin
  // Evita criar duplicado
  if Assigned(FFrame) then
    Exit;

  // 1. Criar frame passando o form como Owner (para gestao de memoria)
  FFrame := TFrameCartao.Create(Self);

  // 2. Definir o container como Parent — aqui o frame sera exibido
  FFrame.Parent := RecConteiner;

  // 3. Alinhar para preencher o container
  FFrame.Align := TAlignLayout.Client;

  // 4. Preencher com dados
  FFrame.Preencher('Produto #42', 'Mesa de escritorio premium, madeira mogno, 160x80cm');
end;

procedure TFrmExemploFrame.BtnDestruirClick(Sender: TObject);
begin
  // FreeAndNil garante que FFrame fica nil apos destruicao
  FreeAndNil(FFrame);
end;

end.

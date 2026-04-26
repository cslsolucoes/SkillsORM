unit frame_heranca;
{
  EXEMPLO: Heranca visual FMX — TFrameBase -> TFrameCRUD
  Compilavel: dcc32 / dcc64
  Demonstra:
    - TFrameBase com metodos virtuais abstratos
    - TFrameCRUD implementando os abstratos
    - Polimorfismo: form pai trabalha com TFrameBase
    - Padrao do GestorERP: Novo/Salvar/Cancelar/Excluir abstratos
}

interface

uses
  System.SysUtils, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Layouts, FMX.StdCtrls, FMX.Objects, FMX.Edit;

// ---------------------------------------------------------------------------
// CLASSE BASE: define contrato visual + eventos abstratos
// ---------------------------------------------------------------------------
type
  TFrameBase = class(TFrame)
  protected
    // Metodos virtuais que subclasses devem implementar
    procedure DoNovo;     virtual; abstract;
    procedure DoSalvar;   virtual; abstract;
    procedure DoCancelar; virtual; abstract;
    procedure DoExcluir;  virtual; abstract;
    procedure DoCarregar; virtual; abstract;
  public
    // API publica — o form pai chama esses
    procedure Novo;
    procedure Salvar;
    procedure Cancelar;
    procedure Excluir;
    procedure CarregarDados;
  end;

// ---------------------------------------------------------------------------
// SUBCLASSE: implementa operacoes de CRUD para Clientes
// ---------------------------------------------------------------------------
type
  TFrameClientesCRUD = class(TFrameBase)
  private
    FCodigoCliente: Integer;
    EdtNome: TEdit;
    EdtEmail: TEdit;
    procedure ConstruirLayout;
  protected
    procedure DoNovo;     override;
    procedure DoSalvar;   override;
    procedure DoCancelar; override;
    procedure DoExcluir;  override;
    procedure DoCarregar; override;
  public
    constructor Create(AOwner: TComponent); override;
    property CodigoCliente: Integer read FCodigoCliente write FCodigoCliente;
  end;

// ---------------------------------------------------------------------------
// FORM PAI: trabalha com TFrameBase (polimorfico)
// ---------------------------------------------------------------------------
type
  TFrmPrincipal = class(TForm)
  private
    FFrame: TFrameBase;
    procedure AbrirFrameClientes;
  public
    procedure BtnNovoClick(Sender: TObject);
    procedure BtnSalvarClick(Sender: TObject);
  end;

implementation

// ---------------------------------------------------------------------------
// TFrameBase
// ---------------------------------------------------------------------------

procedure TFrameBase.Novo;
begin
  DoNovo;
end;

procedure TFrameBase.Salvar;
begin
  DoSalvar;
end;

procedure TFrameBase.Cancelar;
begin
  DoCancelar;
end;

procedure TFrameBase.Excluir;
begin
  DoExcluir;
end;

procedure TFrameBase.CarregarDados;
begin
  DoCarregar;
end;

// ---------------------------------------------------------------------------
// TFrameClientesCRUD
// ---------------------------------------------------------------------------

constructor TFrameClientesCRUD.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ConstruirLayout;
end;

procedure TFrameClientesCRUD.ConstruirLayout;
var
  Layout: TVertScrollBox;
begin
  Layout := TVertScrollBox.Create(Self);
  Layout.Parent := Self;
  Layout.Align  := TAlignLayout.Client;
  Layout.Padding.Rect := TRectF.Create(16, 16, 16, 16);

  EdtNome := TEdit.Create(Self);
  EdtNome.Parent := Layout;
  EdtNome.Align  := TAlignLayout.Top;
  EdtNome.Height := 40;
  EdtNome.Placeholder.Text := 'Nome do cliente';
  EdtNome.Margins.Bottom := 8;

  EdtEmail := TEdit.Create(Self);
  EdtEmail.Parent := Layout;
  EdtEmail.Align  := TAlignLayout.Top;
  EdtEmail.Height := 40;
  EdtEmail.Placeholder.Text := 'E-mail';
  EdtEmail.KeyboardType := TVirtualKeyboardType.EmailAddress;
end;

procedure TFrameClientesCRUD.DoNovo;
begin
  FCodigoCliente := 0;
  EdtNome.Text  := '';
  EdtEmail.Text := '';
  EdtNome.SetFocus;
end;

procedure TFrameClientesCRUD.DoSalvar;
begin
  // Validacao basica
  if EdtNome.Text.Trim.IsEmpty then
    raise Exception.Create('Nome e obrigatorio');

  if FCodigoCliente = 0 then
    // INSERT: FClienteService.Inserir(EdtNome.Text, EdtEmail.Text)
  else
    // UPDATE: FClienteService.Atualizar(FCodigoCliente, EdtNome.Text, EdtEmail.Text)
    ;
end;

procedure TFrameClientesCRUD.DoCancelar;
begin
  DoCarregar; // restaura campos com os dados originais
end;

procedure TFrameClientesCRUD.DoExcluir;
begin
  if FCodigoCliente = 0 then Exit;
  // FClienteService.Excluir(FCodigoCliente);
end;

procedure TFrameClientesCRUD.DoCarregar;
begin
  if FCodigoCliente = 0 then Exit;
  // var Cliente := FClienteService.BuscarPorCodigo(FCodigoCliente);
  // EdtNome.Text  := Cliente.Nome;
  // EdtEmail.Text := Cliente.Email;
end;

// ---------------------------------------------------------------------------
// TFrmPrincipal
// ---------------------------------------------------------------------------

procedure TFrmPrincipal.AbrirFrameClientes;
var
  FrameClientes: TFrameClientesCRUD;
begin
  // Criar a subclasse concreta
  FrameClientes := TFrameClientesCRUD.Create(Self);
  FrameClientes.CodigoCliente := 0;

  // Armazenar como TFrameBase (polimorfico)
  FFrame := FrameClientes;
  FFrame.Parent := Self;
  FFrame.Align  := TAlignLayout.Client;
end;

procedure TFrmPrincipal.BtnNovoClick(Sender: TObject);
begin
  if Assigned(FFrame) then
    FFrame.Novo;
end;

procedure TFrmPrincipal.BtnSalvarClick(Sender: TObject);
begin
  if Assigned(FFrame) then
    FFrame.Salvar;
end;

end.

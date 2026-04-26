unit estilo_customizado;
{
  EXEMPLO: TStyleBook — theming em runtime (FMX)
  Compilavel: dcc32 / dcc64
  Demonstra:
    - Carregar estilo de arquivo .fsf em runtime
    - Aplicar estilo a form especifico ou a toda a aplicacao
    - Criar estilos customizados por componente (inline)
    - Troca de tema claro/escuro
}

interface

uses
  System.SysUtils, System.Classes, System.IOUtils,
  FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Layouts, FMX.StdCtrls, FMX.Objects, FMX.Styles;

type
  TFrmEstilo = class(TForm)
  private
    StyleBook: TStyleBook; // componente de estilo
    BtnClaro : TButton;
    BtnEscuro: TButton;
    BtnArquivo: TButton;

    procedure BtnClaroClick(Sender: TObject);
    procedure BtnEscuroClick(Sender: TObject);
    procedure BtnArquivoClick(Sender: TObject);
    procedure AplicarEstiloFromArquivo(const ACaminho: string);
    procedure ConstruirLayout;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

constructor TFrmEstilo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width  := 400;
  Height := 300;

  // Criar StyleBook (sem carregar estilo — usa o padrao do sistema)
  StyleBook := TStyleBook.Create(Self);

  ConstruirLayout;
end;

destructor TFrmEstilo.Destroy;
begin
  // StyleBook e liberado pelo Owner (Self)
  inherited;
end;

procedure TFrmEstilo.ConstruirLayout;
var
  Layout: TLayout;
begin
  Layout := TLayout.Create(Self);
  Layout.Parent := Self;
  Layout.Align  := TAlignLayout.Center;
  Layout.Width  := 280;
  Layout.Height := 130;

  BtnClaro := TButton.Create(Self);
  BtnClaro.Parent  := Layout;
  BtnClaro.Align   := TAlignLayout.Top;
  BtnClaro.Height  := 40;
  BtnClaro.Text    := 'Tema Claro (padrao)';
  BtnClaro.Margins.Bottom := 4;
  BtnClaro.OnClick := BtnClaroClick;

  BtnEscuro := TButton.Create(Self);
  BtnEscuro.Parent  := Layout;
  BtnEscuro.Align   := TAlignLayout.Top;
  BtnEscuro.Height  := 40;
  BtnEscuro.Text    := 'Tema Escuro';
  BtnEscuro.Margins.Bottom := 4;
  BtnEscuro.OnClick := BtnEscuroClick;

  BtnArquivo := TButton.Create(Self);
  BtnArquivo.Parent  := Layout;
  BtnArquivo.Align   := TAlignLayout.Top;
  BtnArquivo.Height  := 40;
  BtnArquivo.Text    := 'Carregar de arquivo .fsf';
  BtnArquivo.OnClick := BtnArquivoClick;
end;

procedure TFrmEstilo.BtnClaroClick(Sender: TObject);
begin
  // Remover estilo customizado — volta ao padrao
  StyleBook := nil;
  Self.StyleBook := nil;
end;

procedure TFrmEstilo.BtnEscuroClick(Sender: TObject);
begin
  // Modo: construir estilo escuro programaticamente
  // Na pratica, use um arquivo .fsf criado no StyleDesigner do Delphi
  // Este exemplo simula carregando de um recurso
  {
    StyleBook.LoadFromResource('ESTILO_ESCURO'); // se embarcado como resource
    Self.StyleBook := StyleBook;
  }

  // Alternativa simples: apenas mudar Fill.Color do form
  Self.Fill.Color := $FF1E1E2E;
end;

procedure TFrmEstilo.BtnArquivoClick(Sender: TObject);
var
  Caminho: string;
begin
  // Para exemplo, procura arquivo .fsf na pasta do executavel
  Caminho := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), 'MeuEstilo.fsf');
  AplicarEstiloFromArquivo(Caminho);
end;

procedure TFrmEstilo.AplicarEstiloFromArquivo(const ACaminho: string);
begin
  if not TFile.Exists(ACaminho) then
  begin
    // Arquivo nao encontrado — nao alterar estilo
    Exit;
  end;

  // Carregar estilo no StyleBook
  StyleBook.LoadFromFile(ACaminho);

  // Aplicar ao form especifico
  Self.StyleBook := StyleBook;

  // Para aplicar a TODA a aplicacao:
  // Application.Style := StyleBook;
end;

// ---------------------------------------------------------------------------
// COMO CRIAR UM ARQUIVO .fsf:
//
//   1. No Delphi IDE: File > New > Other > FireMonkey > Style
//   2. Use o StyleDesigner para customizar
//   3. Salve como .fsf (FireMonkey Style File)
//   4. Embuta no projeto: Project > Resources and Images
//      Tipo: STYLE, Nome: MEUESTILO
//      Uso: StyleBook.LoadFromResource('MEUESTILO')
//
// ESTILOS DISPONIVEIS NO DELPHI:
//   - Windows11Modern.fsf   (Windows 11, padrao)
//   - CustomBlack.fsf       (tema escuro)
//   - MacOS.fsf
//   - Android.fsf
//   - iOS.fsf
//   Pasta: C:\Program Files (x86)\Embarcadero\Studio\XX.0\Redist\styles\fmx\
// ---------------------------------------------------------------------------

end.

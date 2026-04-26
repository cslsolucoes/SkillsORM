unit uWindowsStore;
{
  TEMPLATE: uWindowsStore.pas — Servico de Licenca e Compras da Windows Store
  =============================================================================
  Unit completa para gerenciar licencas e compras in-app na Microsoft Store.

  COMO USAR:
  1. Copiar esta unit para seu projeto em src/Modulos/WindowsStore/
  2. Substituir os placeholders {{PLACEHOLDER}} pelos valores reais
  3. Registrar o IWindowsStoreService no seu container DI (se houver)
  4. Chamar NewWindowsStoreService para obter a interface

  REQUISITOS:
  - RAD Studio 12 Athens ou superior
  - Plataforma: Win64 (MSIX / Microsoft Store)
  - App publicado na Store (para modo RELEASE)
  - StoreSimulator.xml configurado (para modo DEBUG)

  COMPILACAO:
    dcc64 uWindowsStore.pas

  REFERENCIAS:
  - TWindowsStore (Delphi): Doc-Delphi/delphi12-topics_chm_decompiled/Using_the_WindowsStore_Component.htm
  - API WinRT: https://learn.microsoft.com/windows/uwp/monetize/
  - CurrentAppSimulator: https://learn.microsoft.com/windows/uwp/monetize/test-apps-and-in-app-products

  AVISO: A API Windows.Services.Store pode mudar com atualizacoes do
  Windows SDK. Validar compatibilidade com a versao do SDK utilizada.
}

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  Winapi.Windows,
  FMX.Dialogs;

{ ------------------------------------------------------------------ }
{ Constantes de Product IDs                                           }
{ Substituir pelos IDs reais cadastrados no Partner Center            }
{ Partner Center: Apps and games > Seu app > In-app products         }
{ ------------------------------------------------------------------ }
const
  { Produtos duraveis (Durable) — compra permanente, nao consome }
  STORE_PRODUCT_PREMIUM_MODULE   = '{{PRODUCT_ID_PREMIUM}}';       { Ex.: 'modulo_premium_v1' }
  STORE_PRODUCT_REMOVE_ADS       = '{{PRODUCT_ID_REMOVE_ADS}}';   { Ex.: 'remover_anuncios' }
  STORE_PRODUCT_ADVANCED_REPORTS = '{{PRODUCT_ID_REPORTS}}';      { Ex.: 'relatorios_avancados' }

  { Produtos consumiveis (Consumable) — gasto ao usar }
  STORE_PRODUCT_CREDITS_10       = '{{PRODUCT_ID_CREDITS_10}}';   { Ex.: 'pacote_10_creditos' }
  STORE_PRODUCT_CREDITS_100      = '{{PRODUCT_ID_CREDITS_100}}';  { Ex.: 'pacote_100_creditos' }

  { Assinaturas (Subscription) }
  STORE_PRODUCT_PLAN_MONTHLY     = '{{PRODUCT_ID_MONTHLY}}';      { Ex.: 'plano_mensal' }
  STORE_PRODUCT_PLAN_ANNUAL      = '{{PRODUCT_ID_ANNUAL}}';       { Ex.: 'plano_anual' }

type
  { ------------------------------------------------------------------ }
  { Tipos de resultado de compra                                        }
  { ------------------------------------------------------------------ }
  TStorePurchaseResult = (
    sprSuccess,          { Compra realizada com sucesso }
    sprAlreadyPurchased, { Usuario ja possui o produto }
    sprCancelled,        { Usuario cancelou a compra }
    sprNetworkError,     { Erro de rede }
    sprServerError,      { Erro no servidor da Store }
    sprUnknown           { Erro desconhecido }
  );

  { ------------------------------------------------------------------ }
  { Informacao de licenca                                               }
  { ------------------------------------------------------------------ }
  TStoreLicenseInfo = record
    IsActive: Boolean;
    IsTrial: Boolean;
    ExpirationDate: TDateTime; { 0 se nao e trial ou nao tem expiracao }
    TrialDaysRemaining: Integer;
  end;

  { ------------------------------------------------------------------ }
  { Callback para resultado de compra assincrona                        }
  { ------------------------------------------------------------------ }
  TStorePurchaseCallback = procedure(const AResult: TStorePurchaseResult;
    const AProductId: string) of object;

  { ------------------------------------------------------------------ }
  { Interface principal do servico de Windows Store                     }
  { ------------------------------------------------------------------ }
  IWindowsStoreService = interface
    ['{B1C2D3E4-F5A6-7890-BCDE-F12345678901}']

    { === LICENCA DO APP === }

    /// <summary>
    /// Retorna informacoes completas sobre a licenca atual do app.
    /// </summary>
    function GetLicenseInfo: TStoreLicenseInfo;

    /// <summary>
    /// Atalho: retorna True se a licenca do app esta ativa.
    /// </summary>
    function IsLicenseActive: Boolean;

    /// <summary>
    /// Atalho: retorna True se o app esta em modo trial.
    /// </summary>
    function IsTrial: Boolean;

    /// <summary>
    /// Solicita a compra do app (converte trial para licenca paga).
    /// Abre o dialogo de pagamento da Store.
    /// </summary>
    /// <param name="ACallback">Callback chamado apos resultado (pode ser nil)</param>
    procedure RequestAppPurchase(const ACallback: TStorePurchaseCallback);

    { === PRODUTOS IN-APP === }

    /// <summary>
    /// Verifica se um produto in-app especifico foi adquirido.
    /// </summary>
    /// <param name="AProductId">ID do produto (cadastrado no Partner Center)</param>
    function IsProductPurchased(const AProductId: string): Boolean;

    /// <summary>
    /// Solicita a compra de um produto in-app.
    /// Abre o dialogo de pagamento da Store.
    /// </summary>
    /// <param name="AProductId">ID do produto (cadastrado no Partner Center)</param>
    /// <param name="ACallback">Callback chamado apos resultado (pode ser nil)</param>
    procedure RequestProductPurchase(const AProductId: string;
      const ACallback: TStorePurchaseCallback);

    /// <summary>
    /// Para produtos consumiveis: registra o consumo apos uso.
    /// Obrigatorio para que o usuario possa comprar o mesmo produto novamente.
    /// </summary>
    procedure ReportProductFulfillment(const AProductId: string);

    { === MODO DE OPERACAO === }

    /// <summary>
    /// Retorna True se estiver rodando com o simulador (modo DEBUG).
    /// </summary>
    function IsSimulatorMode: Boolean;
  end;

  { ------------------------------------------------------------------ }
  { Implementacao concreta                                              }
  { ------------------------------------------------------------------ }
  TWindowsStoreService = class(TInterfacedObject, IWindowsStoreService)
  private
    FIsSimulatorMode: Boolean;
    FLock: TCriticalSection;

    { Helpers internos }
    function InternalIsLicenseActive: Boolean;
    function InternalIsTrial: Boolean;
    function InternalGetExpirationDate: TDateTime;
    function InternalIsProductPurchased(const AProductId: string): Boolean;
    procedure InternalRequestPurchase(const AProductId: string;
      const AIsAppPurchase: Boolean;
      const ACallback: TStorePurchaseCallback);

  public
    constructor Create;
    destructor Destroy; override;

    { IWindowsStoreService }
    function GetLicenseInfo: TStoreLicenseInfo;
    function IsLicenseActive: Boolean;
    function IsTrial: Boolean;
    procedure RequestAppPurchase(const ACallback: TStorePurchaseCallback);
    function IsProductPurchased(const AProductId: string): Boolean;
    procedure RequestProductPurchase(const AProductId: string;
      const ACallback: TStorePurchaseCallback);
    procedure ReportProductFulfillment(const AProductId: string);
    function IsSimulatorMode: Boolean;
  end;

{ Factory — retorna a interface sem expor a classe }
function NewWindowsStoreService: IWindowsStoreService;

implementation

{ ------------------------------------------------------------------ }
{ Factory                                                              }
{ ------------------------------------------------------------------ }

function NewWindowsStoreService: IWindowsStoreService;
begin
  Result := TWindowsStoreService.Create;
end;

{ ------------------------------------------------------------------ }
{ TWindowsStoreService — Lifecycle                                     }
{ ------------------------------------------------------------------ }

constructor TWindowsStoreService.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;

  {$IFDEF DEBUG}
    FIsSimulatorMode := True;
    {
      SIMULADOR ATIVO (modo DEBUG)
      ============================
      O CurrentAppSimulator usa o arquivo StoreSimulator.xml para
      simular estados da Store sem necessidade de publicacao real.

      Localizar/criar StoreSimulator.xml em:
        C:\Windows\System32\StoreSimulator.xml

      Para alterar o estado da licenca no XML:
        IsActive=true, IsTrial=true   -> trial ativo
        IsActive=true, IsTrial=false  -> licenca comprada
        IsActive=false                -> licenca expirada

      Ver exemplo de StoreSimulator.xml na documentacao do RAD Studio:
      Doc-Delphi/delphi12-topics_chm_decompiled/Using_the_WindowsStore_Component.htm
    }
  {$ELSE}
    FIsSimulatorMode := False;
    {
      PRODUCAO (modo RELEASE)
      =======================
      Conecta ao CurrentApp real via API Windows.Services.Store.
      O app DEVE estar publicado na Store (mesmo que seja uma pre-release)
      para que as APIs de licenca funcionem corretamente.

      Em desenvolvimento: publicar como "Hidden" na Store para testes
      sem aparecer para usuarios publicos.
    }
  {$ENDIF}
end;

destructor TWindowsStoreService.Destroy;
begin
  FLock.Free;
  inherited Destroy;
end;

{ ------------------------------------------------------------------ }
{ Helpers Internos                                                     }
{ ------------------------------------------------------------------ }

function TWindowsStoreService.InternalIsLicenseActive: Boolean;
begin
  {$IFDEF DEBUG}
    {
      SIMULADOR: CurrentAppSimulator.LicenseInformation.IsActive
      Retorna o valor configurado em StoreSimulator.xml.

      Para testes: retornar True para nao bloquear o desenvolvimento.
      Alterar aqui para simular licenca inativa se necessario.
    }
    Result := True;
  {$ELSE}
    {
      PRODUCAO: CurrentApp.LicenseInformation.IsActive
      Via TWindowsStore (componente da paleta Windows):
        WindowsStore1.LicenseInformation.IsActive

      Esta implementacao e um stub seguro.
      Integrar com o componente TWindowsStore no form principal.
    }
    Result := True; // SUBSTITUIR: WindowsStore1.LicenseInformation.IsActive
  {$ENDIF}
end;

function TWindowsStoreService.InternalIsTrial: Boolean;
begin
  {$IFDEF DEBUG}
    Result := True; // Simulador: trial ativo por padrao em DEBUG
  {$ELSE}
    Result := False; // SUBSTITUIR: WindowsStore1.LicenseInformation.IsTrial
  {$ENDIF}
end;

function TWindowsStoreService.InternalGetExpirationDate: TDateTime;
begin
  {$IFDEF DEBUG}
    Result := Now + 30; // Simulador: 30 dias de trial
  {$ELSE}
    Result := 0; // SUBSTITUIR: WindowsStore1.LicenseInformation.ExpirationDate
  {$ENDIF}
end;

function TWindowsStoreService.InternalIsProductPurchased(
  const AProductId: string): Boolean;
begin
  {$IFDEF DEBUG}
    {
      SIMULADOR: CurrentAppSimulator.LicenseInformation.ProductLicenses[AProductId].IsActive
      Configurar em StoreSimulator.xml:
      <ProductLicense>
        <ProductId>modulo_premium_v1</ProductId>
        <IsActive>true</IsActive>
        <IsConsumable>false</IsConsumable>
      </ProductLicense>
    }
    Result := False; // Simulador: produto nao comprado por padrao
  {$ELSE}
    {
      PRODUCAO: CurrentApp.LicenseInformation.ProductLicenses[AProductId].IsActive
      Via TWindowsStore:
        WindowsStore1.LicenseInformation.ProductLicenses[AProductId].IsActive
    }
    Result := False; // SUBSTITUIR com chamada real
  {$ENDIF}
end;

procedure TWindowsStoreService.InternalRequestPurchase(
  const AProductId: string;
  const AIsAppPurchase: Boolean;
  const ACallback: TStorePurchaseCallback);
begin
  {$IFDEF DEBUG}
    {
      SIMULADOR:
      - App purchase: CurrentAppSimulator.RequestAppPurchaseAsync(False)
      - Product purchase: CurrentAppSimulator.RequestProductPurchaseAsync(AProductId)
      O resultado e controlado por StoreSimulator.xml (S_OK = sucesso simulado).
    }
    if AIsAppPurchase then
      ShowMessage('[SIMULADOR] Compra do app solicitada.' + sLineBreak +
                  'Em producao: abre dialogo de pagamento da Store.')
    else
      ShowMessage('[SIMULADOR] Compra do produto "' + AProductId + '" solicitada.' + sLineBreak +
                  'Em producao: abre dialogo de pagamento da Store.');

    // Simular resultado de sucesso para testes
    if Assigned(ACallback) then
      ACallback(sprSuccess, AProductId);
  {$ELSE}
    {
      PRODUCAO:
      - App purchase: CurrentApp.RequestAppPurchaseAsync(False)
      - Product purchase: CurrentApp.RequestProductPurchaseAsync(AProductId)
      Via TWindowsStore:
        WindowsStore1.RequestAppPurchaseAsync(False);
        WindowsStore1.RequestProductPurchaseAsync(AProductId);

      O resultado e retornado via evento do TWindowsStore.
      Mapear o resultado para TStorePurchaseResult no callback.
    }
    // SUBSTITUIR com chamada real ao TWindowsStore
    if Assigned(ACallback) then
      ACallback(sprUnknown, AProductId);
  {$ENDIF}
end;

{ ------------------------------------------------------------------ }
{ IWindowsStoreService — Implementacao Publica                        }
{ ------------------------------------------------------------------ }

function TWindowsStoreService.GetLicenseInfo: TStoreLicenseInfo;
begin
  FLock.Enter;
  try
    Result.IsActive := InternalIsLicenseActive;
    Result.IsTrial  := Result.IsActive and InternalIsTrial;

    if Result.IsTrial then
    begin
      Result.ExpirationDate    := InternalGetExpirationDate;
      Result.TrialDaysRemaining := Trunc(Result.ExpirationDate - Now);
      if Result.TrialDaysRemaining < 0 then
        Result.TrialDaysRemaining := 0;
    end
    else
    begin
      Result.ExpirationDate    := 0;
      Result.TrialDaysRemaining := 0;
    end;
  finally
    FLock.Leave;
  end;
end;

function TWindowsStoreService.IsLicenseActive: Boolean;
begin
  FLock.Enter;
  try
    Result := InternalIsLicenseActive;
  finally
    FLock.Leave;
  end;
end;

function TWindowsStoreService.IsTrial: Boolean;
begin
  FLock.Enter;
  try
    if not InternalIsLicenseActive then
      Exit(False);
    Result := InternalIsTrial;
  finally
    FLock.Leave;
  end;
end;

procedure TWindowsStoreService.RequestAppPurchase(
  const ACallback: TStorePurchaseCallback);
begin
  InternalRequestPurchase('', True, ACallback);
end;

function TWindowsStoreService.IsProductPurchased(const AProductId: string): Boolean;
begin
  if AProductId.IsEmpty then
    Exit(False);

  FLock.Enter;
  try
    Result := InternalIsProductPurchased(AProductId);
  finally
    FLock.Leave;
  end;
end;

procedure TWindowsStoreService.RequestProductPurchase(
  const AProductId: string;
  const ACallback: TStorePurchaseCallback);
begin
  if AProductId.IsEmpty then
  begin
    if Assigned(ACallback) then
      ACallback(sprUnknown, AProductId);
    Exit;
  end;
  InternalRequestPurchase(AProductId, False, ACallback);
end;

procedure TWindowsStoreService.ReportProductFulfillment(const AProductId: string);
begin
  {
    Para produtos consumiveis: chamar apos o produto ser "entregue" ao usuario.
    Isso permite que o usuario compre o mesmo produto novamente.

    PRODUCAO: CurrentApp.ReportConsumableFulfillmentAsync(AProductId, quantity, trackingId)
    Via TWindowsStore: WindowsStore1.ReportConsumableFulfillmentAsync(...)

    SIMULADOR: CurrentAppSimulator.ReportConsumableFulfillmentAsync(...)
  }
  {$IFDEF DEBUG}
    ShowMessage('[SIMULADOR] Fulfillment reportado para: ' + AProductId);
  {$ELSE}
    // SUBSTITUIR com chamada real ao TWindowsStore
  {$ENDIF}
end;

function TWindowsStoreService.IsSimulatorMode: Boolean;
begin
  Result := FIsSimulatorMode;
end;

end.

{
  =====================================================================
  EXEMPLO DE USO EM FORMUL�RIO PRINCIPAL
  =====================================================================

  unit ufrm.Main;

  interface

  uses
    ...,
    uWindowsStore;

  type
    TfrmMain = class(TForm)
      btnComprar: TButton;
      btnModuloPremium: TButton;
      procedure FormCreate(Sender: TObject);
      procedure btnComprarClick(Sender: TObject);
      procedure btnModuloPremiumClick(Sender: TObject);
    private
      FStore: IWindowsStoreService;
      procedure VerificarLicenca;
      procedure OnPurchaseResult(const AResult: TStorePurchaseResult;
        const AProductId: string);
    end;

  implementation

  procedure TfrmMain.FormCreate(Sender: TObject);
  begin
    FStore := NewWindowsStoreService;
    VerificarLicenca;
  end;

  procedure TfrmMain.VerificarLicenca;
  var
    LInfo: TStoreLicenseInfo;
  begin
    LInfo := FStore.GetLicenseInfo;

    if not LInfo.IsActive then
    begin
      ShowMessage('Sua licenca expirou. Adquira o app na Microsoft Store.');
      Application.Terminate;
      Exit;
    end;

    if LInfo.IsTrial then
      ShowMessage(Format('Versao trial. %d dias restantes. Compre agora!',
        [LInfo.TrialDaysRemaining]));
  end;

  procedure TfrmMain.OnPurchaseResult(const AResult: TStorePurchaseResult;
    const AProductId: string);
  begin
    case AResult of
      sprSuccess:
        ShowMessage('Compra realizada com sucesso! Produto: ' + AProductId);
      sprAlreadyPurchased:
        ShowMessage('Voce ja possui este produto.');
      sprCancelled:
        { Nao mostrar mensagem — usuario cancelou conscientemente };
      sprNetworkError:
        ShowMessage('Erro de rede. Verifique sua conexao e tente novamente.');
    else
      ShowMessage('Erro ao processar a compra. Tente novamente.');
    end;
  end;

  procedure TfrmMain.btnComprarClick(Sender: TObject);
  begin
    FStore.RequestAppPurchase(OnPurchaseResult);
  end;

  procedure TfrmMain.btnModuloPremiumClick(Sender: TObject);
  begin
    if FStore.IsProductPurchased(STORE_PRODUCT_PREMIUM_MODULE) then
      AbrirModuloPremium
    else
      FStore.RequestProductPurchase(STORE_PRODUCT_PREMIUM_MODULE, OnPurchaseResult);
  end;

  =====================================================================
}

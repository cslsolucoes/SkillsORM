unit uWindowsStoreExample;
{
  Exemplo de uso do componente TWindowsStore no Delphi (RAD Studio 12+).

  REQUISITOS:
  - RAD Studio 12 Athens ou superior
  - Plataforma alvo: Win64 (MSIX / Microsoft Store)
  - Componente TWindowsStore disponivel na paleta "Windows"
  - App publicado na Microsoft Store (ou usar CurrentAppSimulator em DEBUG)

  COMO USAR:
  - Em modo DEBUG ({$IFDEF DEBUG}): usa CurrentAppSimulator
    Configurar o estado da licenca via StoreSimulator.xml
    (localizado em Windows\System32\StoreSimulator.xml por padrao)
  - Em modo RELEASE: usa CurrentApp (conecta a Store real)

  COMPILACAO:
    dcc32 uWindowsStoreExample.pas   <- Win32 (apenas para referencia)
    dcc64 uWindowsStoreExample.pas   <- Win64 (producao)

  AVISO: A API Windows.Services.Store muda com atualizacoes do Windows SDK.
  Validar em: https://learn.microsoft.com/windows/uwp/monetize/
}

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  FMX.Dialogs;

type
  { ------------------------------------------------------------------ }
  { Interface de servico de licenca e compras da Windows Store          }
  { ------------------------------------------------------------------ }
  IWindowsStoreService = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    /// <summary>
    /// Retorna True se a licenca do app esta ativa (comprado ou trial valido).
    /// </summary>
    function IsLicenseActive: Boolean;

    /// <summary>
    /// Retorna True se o app esta em modo trial (periodo gratuito).
    /// </summary>
    function IsTrial: Boolean;

    /// <summary>
    /// Solicita a compra do app completo (converte trial para licenca paga).
    /// </summary>
    procedure RequestAppPurchase;

    /// <summary>
    /// Verifica se um produto in-app especifico foi adquirido.
    /// AProductId = ID definido no Partner Center (In-app products).
    /// </summary>
    function IsProductPurchased(const AProductId: string): Boolean;

    /// <summary>
    /// Solicita a compra de um produto in-app.
    /// AProductId = ID definido no Partner Center.
    /// </summary>
    procedure RequestProductPurchase(const AProductId: string);

    /// <summary>
    /// Retorna a data de expiracao do trial. Retorna 0 se nao e trial.
    /// </summary>
    function GetTrialExpirationDate: TDateTime;
  end;

  { ------------------------------------------------------------------ }
  { Implementacao concreta do servico de Store                          }
  { Em DEBUG: usa CurrentAppSimulator                                   }
  { Em RELEASE: usa CurrentApp                                         }
  { ------------------------------------------------------------------ }
  TWindowsStoreService = class(TInterfacedObject, IWindowsStoreService)
  private
    FIsSimulatorMode: Boolean;

    { Metodos internos para acesso a API da Store }
    function GetIsLicenseActiveInternal: Boolean;
    function GetIsTrialInternal: Boolean;
    function GetTrialExpirationInternal: TDateTime;
  public
    constructor Create;
    destructor Destroy; override;

    { IWindowsStoreService }
    function IsLicenseActive: Boolean;
    function IsTrial: Boolean;
    procedure RequestAppPurchase;
    function IsProductPurchased(const AProductId: string): Boolean;
    procedure RequestProductPurchase(const AProductId: string);
    function GetTrialExpirationDate: TDateTime;
  end;

{ Factory function — retorna a interface sem expor a classe concreta }
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
{ TWindowsStoreService — Constructor / Destructor                     }
{ ------------------------------------------------------------------ }

constructor TWindowsStoreService.Create;
begin
  inherited Create;
  {$IFDEF DEBUG}
    FIsSimulatorMode := True;
  {$ELSE}
    FIsSimulatorMode := False;
  {$ENDIF}
end;

destructor TWindowsStoreService.Destroy;
begin
  inherited Destroy;
end;

{ ------------------------------------------------------------------ }
{ Metodos internos — acesso a API Windows Store                       }
{ ------------------------------------------------------------------ }

function TWindowsStoreService.GetIsLicenseActiveInternal: Boolean;
begin
  {$IFDEF DEBUG}
    {
      MODO SIMULADOR (DEBUG):
      CurrentAppSimulator.LicenseInformation.IsActive

      O estado e controlado pelo arquivo StoreSimulator.xml.
      Por padrao, o simulador retorna IsActive = True e IsTrial = True.

      Para testar diferentes cenarios, editar:
      C:\Windows\System32\StoreSimulator.xml

      Exemplo de StoreSimulator.xml para licenca ativa (nao trial):
      <CurrentApp>
        <ListingInformation>
          <App>
            <AppId>00000000-0000-0000-0000-000000000000</AppId>
            <LinkUri>http://apps.microsoft.com/webpdp/app/xxx</LinkUri>
            <CurrentMarket>pt-BR</CurrentMarket>
            <AgeRating>3</AgeRating>
            <MarketData xml:lang="pt-BR">
              <Name>GestorERP</Name>
              <Description>Sistema de gestao empresarial</Description>
              <Price>0.00</Price>
              <CurrencySymbol>R$</CurrencySymbol>
            </MarketData>
          </App>
        </ListingInformation>
        <LicenseInformation>
          <App>
            <IsActive>true</IsActive>
            <IsTrial>false</IsTrial>
          </App>
        </LicenseInformation>
      </CurrentApp>
    }
    Result := True; { Simulador: sempre ativo em DEBUG para nao bloquear desenvolvimento }
  {$ELSE}
    {
      MODO PRODUCAO (RELEASE):
      Aqui seria invocado o CurrentApp.LicenseInformation.IsActive
      via WinRT / Windows.Services.Store.

      Em Delphi, o TWindowsStore (paleta Windows) encapsula essa chamada.
      Adicionar o componente TWindowsStore ao form principal e chamar:
        WindowsStore1.LicenseInformation.IsActive

      Esta implementacao e um stub — integrar com TWindowsStore real no form.
    }
    Result := True; { Placeholder — substituir pela chamada real ao TWindowsStore }
  {$ENDIF}
end;

function TWindowsStoreService.GetIsTrialInternal: Boolean;
begin
  {$IFDEF DEBUG}
    { Simulador: retornar True para testar fluxo de trial }
    Result := True;
  {$ELSE}
    { Producao: CurrentApp.LicenseInformation.IsTrial }
    Result := False; { Placeholder — substituir pela chamada real }
  {$ENDIF}
end;

function TWindowsStoreService.GetTrialExpirationInternal: TDateTime;
begin
  {$IFDEF DEBUG}
    { Simulador: 30 dias de trial a partir de hoje }
    Result := Now + 30;
  {$ELSE}
    { Producao: CurrentApp.LicenseInformation.ExpirationDate }
    Result := 0; { Placeholder }
  {$ENDIF}
end;

{ ------------------------------------------------------------------ }
{ IWindowsStoreService — Implementacao publica                        }
{ ------------------------------------------------------------------ }

function TWindowsStoreService.IsLicenseActive: Boolean;
begin
  Result := GetIsLicenseActiveInternal;
end;

function TWindowsStoreService.IsTrial: Boolean;
begin
  if not IsLicenseActive then
    Exit(False);
  Result := GetIsTrialInternal;
end;

procedure TWindowsStoreService.RequestAppPurchase;
begin
  {$IFDEF DEBUG}
    {
      SIMULADOR: CurrentAppSimulator.RequestAppPurchaseAsync(False)
      O resultado e configuravel via StoreSimulator.xml (S_OK = sucesso).
    }
    ShowMessage('[SIMULADOR] Solicitacao de compra do app enviada.' + sLineBreak +
                'Em producao, abre o dialogo de pagamento da Microsoft Store.');
  {$ELSE}
    {
      PRODUCAO: CurrentApp.RequestAppPurchaseAsync(False)
      Abre o dialogo nativo da Store para o usuario completar a compra.
      Implementar via TWindowsStore no form:
        WindowsStore1.RequestAppPurchaseAsync(False);
    }
    ShowMessage('Funcionalidade disponivel apenas quando publicado na Store.');
  {$ENDIF}
end;

function TWindowsStoreService.IsProductPurchased(const AProductId: string): Boolean;
begin
  {$IFDEF DEBUG}
    {
      SIMULADOR: CurrentAppSimulator.LicenseInformation.ProductLicenses[AProductId].IsActive
      Configurar via StoreSimulator.xml:
      <ProductLicense>
        <ProductId>premium_module</ProductId>
        <IsActive>true</IsActive>
        <IsConsumable>false</IsConsumable>
      </ProductLicense>
    }
    Result := False; { Simulador: produto nao comprado por padrao }
  {$ELSE}
    {
      PRODUCAO:
        CurrentApp.LicenseInformation.ProductLicenses[AProductId].IsActive
    }
    Result := False; { Placeholder }
  {$ENDIF}
end;

procedure TWindowsStoreService.RequestProductPurchase(const AProductId: string);
begin
  {
    AProductId deve corresponder ao ID cadastrado no Partner Center:
    Apps and games → Seu app → In-app products → Add-on

    Tipos de produto:
    - Durable (nao consome): compra permanente, ex.: "modulo_premium"
    - Consumable (consome): gasto ao usar, ex.: "pacote_100_creditos"
    - Subscription: assinatura recorrente, ex.: "plano_anual"
  }
  {$IFDEF DEBUG}
    ShowMessage('[SIMULADOR] Solicitando compra do produto: ' + AProductId + sLineBreak +
                'Em producao, abre o dialogo de pagamento da Microsoft Store.');
  {$ELSE}
    {
      PRODUCAO:
        CurrentApp.RequestProductPurchaseAsync(AProductId)
      Via TWindowsStore:
        WindowsStore1.RequestProductPurchaseAsync(AProductId);
    }
    ShowMessage('Abrindo Store para compra de: ' + AProductId);
  {$ENDIF}
end;

function TWindowsStoreService.GetTrialExpirationDate: TDateTime;
begin
  if not IsTrial then
    Exit(0);
  Result := GetTrialExpirationInternal;
end;

end.

{
  =====================================================================
  EXEMPLO DE USO EM UM FORM (frmMain.pas)
  =====================================================================

  uses
    uWindowsStoreExample;

  var
    FStoreService: IWindowsStoreService;

  procedure TfrmMain.FormCreate(Sender: TObject);
  begin
    FStoreService := NewWindowsStoreService;
    VerificarLicenca;
  end;

  procedure TfrmMain.VerificarLicenca;
  var
    dtExpiracao: TDateTime;
  begin
    if not FStoreService.IsLicenseActive then
    begin
      ShowMessage('Sua licenca expirou ou o app nao foi adquirido.' + sLineBreak +
                  'Acesse a Microsoft Store para comprar.');
      Application.Terminate;
      Exit;
    end;

    if FStoreService.IsTrial then
    begin
      dtExpiracao := FStoreService.GetTrialExpirationDate;
      ShowMessage('Voce esta usando o GestorERP em modo trial.' + sLineBreak +
                  'Expiracao: ' + DateToStr(dtExpiracao) + sLineBreak +
                  'Clique em Comprar para acesso completo.');
    end;
  end;

  procedure TfrmMain.btnComprarClick(Sender: TObject);
  begin
    FStoreService.RequestAppPurchase;
  end;

  procedure TfrmMain.btnModuloPremiumClick(Sender: TObject);
  const
    PRODUCT_ID_PREMIUM = 'modulo_relatorios_avancados';
  begin
    if FStoreService.IsProductPurchased(PRODUCT_ID_PREMIUM) then
      AbrirModuloPremium
    else
    begin
      if MessageDlg('Modulo Relatorios Avancados nao adquirido.' + sLineBreak +
                    'Deseja comprar agora?', TMsgDlgType.mtConfirmation,
                    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
        FStoreService.RequestProductPurchase(PRODUCT_ID_PREMIUM);
    end;
  end;

  =====================================================================
}

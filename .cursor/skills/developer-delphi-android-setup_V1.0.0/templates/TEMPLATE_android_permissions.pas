unit TEMPLATE_android_permissions;
{
  TEMPLATE: Solicitacao de Permissoes Android em Runtime

  INSTRUCOES:
  1. Copiar este template para seu projeto
  2. Renomear a unit e a classe conforme convencao do projeto
  3. Substituir [PERMISSION_CONSTANT] pelas permissoes reais necessarias
  4. Adicionar todas as permissoes no AndroidManifest.template.xml (Nivel 1)
  5. Chamar os metodos de solicitacao antes de usar o recurso protegido

  COMPATIBILIDADE:
  - Delphi 12 Alexandria ou superior
  - Target: Android 64-bit (API 26+)
  - Condicional {$IFDEF ANDROID} garante compilacao segura para outras plataformas
}

interface

uses
  System.SysUtils,
  System.Classes,
  FMX.Dialogs;

type
  { Template de helper para permissoes Android.
    Renomear para TPermissionsHelper ou integrar ao Form/ViewModel. }
  T[NomeHelper] = class
  private
    { Callback apos resultado de permissao }
    class procedure HandlePermissionResult(
      const APermissions: TArray<string>;
      const AGrantResults: TArray<TPermissionStatus>;
      const AOnGranted: TProc;
      const AOnDenied: TProc);
  public
    { Verificar sem solicitar }
    class function IsGranted(const APermission: string): Boolean;

    { Solicitar permissao simples }
    class procedure Request(
      const APermission: string;
      const AOnGranted: TProc;
      const AOnDenied: TProc = nil);

    { Solicitar multiplas permissoes — todas devem ser concedidas }
    class procedure RequestAll(
      const APermissions: TArray<string>;
      const AOnAllGranted: TProc;
      const AOnAnyDenied: TProc = nil);

    { === METODOS ESPECIALIZADOS POR FUNCIONALIDADE === }
    { Adaptar conforme as necessidades do projeto      }

    { [FUNCIONALIDADE_1] — ex.: Camera }
    class procedure RequestForCamera(
      const AOnGranted: TProc;
      const AOnDenied: TProc = nil);

    { [FUNCIONALIDADE_2] — ex.: Localizacao }
    class procedure RequestForLocation(
      const AOnGranted: TProc;
      const AOnDenied: TProc = nil);
  end;

implementation

{$IFDEF ANDROID}
uses
  FMX.Platform.Android,
  Androidapi.Helpers;
{$ENDIF}

{ T[NomeHelper] }

class function T[NomeHelper].IsGranted(const APermission: string): Boolean;
begin
{$IFDEF ANDROID}
  Result := PermissionsService.IsPermissionGranted(APermission);
{$ELSE}
  Result := True;
{$ENDIF}
end;

class procedure T[NomeHelper].HandlePermissionResult(
  const APermissions: TArray<string>;
  const AGrantResults: TArray<TPermissionStatus>;
  const AOnGranted: TProc;
  const AOnDenied: TProc);
var
  I: Integer;
  LAllGranted: Boolean;
begin
  LAllGranted := Length(AGrantResults) > 0;
  for I := 0 to High(AGrantResults) do
  begin
    if AGrantResults[I] <> TPermissionStatus.Granted then
    begin
      LAllGranted := False;
      Break;
    end;
  end;

  if LAllGranted then
  begin
    if Assigned(AOnGranted) then
      AOnGranted()
  end
  else
  begin
    if Assigned(AOnDenied) then
      AOnDenied()
    else
      ShowMessage('Permissao negada. Verifique as configuracoes do app.');
  end;
end;

class procedure T[NomeHelper].Request(
  const APermission: string;
  const AOnGranted: TProc;
  const AOnDenied: TProc);
begin
{$IFDEF ANDROID}
  // Verificar se ja concedida antes de solicitar
  if IsGranted(APermission) then
  begin
    if Assigned(AOnGranted) then
      AOnGranted();
    Exit;
  end;

  PermissionsService.RequestPermissions(
    [APermission],
    procedure(const APermissions: TArray<string>;
              const AGrantResults: TArray<TPermissionStatus>)
    begin
      HandlePermissionResult(APermissions, AGrantResults, AOnGranted, AOnDenied);
    end);
{$ELSE}
  if Assigned(AOnGranted) then
    AOnGranted();
{$ENDIF}
end;

class procedure T[NomeHelper].RequestAll(
  const APermissions: TArray<string>;
  const AOnAllGranted: TProc;
  const AOnAnyDenied: TProc);
begin
{$IFDEF ANDROID}
  PermissionsService.RequestPermissions(
    APermissions,
    procedure(const APerms: TArray<string>;
              const AGrantResults: TArray<TPermissionStatus>)
    begin
      HandlePermissionResult(APerms, AGrantResults, AOnAllGranted, AOnAnyDenied);
    end);
{$ELSE}
  if Assigned(AOnAllGranted) then
    AOnAllGranted();
{$ENDIF}
end;

class procedure T[NomeHelper].RequestForCamera(
  const AOnGranted: TProc;
  const AOnDenied: TProc);
begin
  Request('android.permission.CAMERA', AOnGranted, AOnDenied);
end;

class procedure T[NomeHelper].RequestForLocation(
  const AOnGranted: TProc;
  const AOnDenied: TProc);
begin
  RequestAll(
    ['android.permission.ACCESS_FINE_LOCATION',
     'android.permission.ACCESS_COARSE_LOCATION'],
    AOnGranted,
    AOnDenied);
end;

end.

{
  === EXEMPLO DE USO NO FORM ===

  // Antes de tirar foto:
  procedure TfrmMain.BtnCameraClick(Sender: TObject);
  begin
    TPermissionsHelper.RequestForCamera(
      procedure
      begin
        OpenCamera; // Permissao concedida
      end,
      procedure
      begin
        ShowMessage('Acesso a camera negado.');
      end);
  end;

  // Verificar sem solicitar (para UI condicional):
  procedure TfrmMain.UpdateUI;
  begin
    BtnCamera.Enabled :=
      TPermissionsHelper.IsGranted('android.permission.CAMERA');
  end;

  // Solicitar multiplas de uma vez:
  procedure TfrmMain.BtnStartClick(Sender: TObject);
  begin
    TPermissionsHelper.RequestAll(
      ['android.permission.CAMERA',
       'android.permission.RECORD_AUDIO'],
      procedure begin StartRecording end,
      procedure begin ShowMessage('Permissoes necessarias nao concedidas.') end);
  end;

  === PERMISSOES NO MANIFESTO (obrigatorio para todas acima) ===
  Adicionar em AndroidManifest.template.xml antes de <application>:

  <uses-permission android:name="android.permission.CAMERA"/>
  <uses-permission android:name="android.permission.RECORD_AUDIO"/>
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
}

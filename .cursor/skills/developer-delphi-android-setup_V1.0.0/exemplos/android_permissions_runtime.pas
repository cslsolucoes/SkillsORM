unit uPermissionsHelper;
{
  Exemplo completo de solicitacao de permissoes Android em runtime (API 23+)
  via PermissionsService do Delphi FMX.

  Compativel com: Delphi 12 Alexandria, Android 64-bit

  IMPORTANTE:
  - As permissoes DEVEM estar declaradas no AndroidManifest.template.xml (Nivel 1)
  - A solicitacao em runtime (Nivel 2) e obrigatoria para "dangerous permissions"
  - Verificar se a permissao ja foi concedida antes de solicitar novamente
}

interface

uses
  System.SysUtils,
  System.Classes,
  FMX.Forms,
  FMX.Dialogs;

type
  TPermissionsHelper = class
  public
    { Solicita permissao de Camera }
    class procedure RequestCameraPermission(
      const AOnGranted: TProc;
      const AOnDenied: TProc = nil);

    { Solicita permissao de Localizacao (precisa e aproximada) }
    class procedure RequestLocationPermissions(
      const AOnGranted: TProc;
      const AOnDenied: TProc = nil);

    { Solicita multiplas permissoes de uma vez }
    class procedure RequestMultiplePermissions(
      const APermissions: TArray<string>;
      const AOnAllGranted: TProc;
      const AOnAnyDenied: TProc = nil);

    { Verifica se uma permissao ja foi concedida (sem solicitar) }
    class function IsPermissionGranted(const APermission: string): Boolean;

    { Solicita permissao de microfone }
    class procedure RequestMicrophonePermission(
      const AOnGranted: TProc;
      const AOnDenied: TProc = nil);

    { Solicita permissoes de armazenamento (API 26-32) }
    class procedure RequestStoragePermissions(
      const AOnGranted: TProc;
      const AOnDenied: TProc = nil);

    { Solicita permissao de notificacoes (API 33+) }
    class procedure RequestNotificationPermission(
      const AOnGranted: TProc;
      const AOnDenied: TProc = nil);
  end;

implementation

{$IFDEF ANDROID}
uses
  FMX.Platform.Android,
  Androidapi.Helpers,
  Androidapi.JNI.Os;
{$ENDIF}

{ TPermissionsHelper }

class procedure TPermissionsHelper.RequestCameraPermission(
  const AOnGranted: TProc;
  const AOnDenied: TProc);
begin
{$IFDEF ANDROID}
  { Exemplo do subplano SP-K2:
    uses FMX.Platform.Android, Androidapi.Helpers; }
  PermissionsService.RequestPermissions(
    ['android.permission.CAMERA'],
    procedure(const APermissions: TArray<string>;
              const AGrantResults: TArray<TPermissionStatus>)
    begin
      if (Length(AGrantResults) > 0) and
         (AGrantResults[0] = TPermissionStatus.Granted) then
      begin
        if Assigned(AOnGranted) then
          AOnGranted()
      end
      else
      begin
        if Assigned(AOnDenied) then
          AOnDenied()
        else
          ShowMessage('Permissao de camera negada.');
      end;
    end);
{$ELSE}
  // Plataforma nao-Android: conceder diretamente (desktop/iOS nao usa este fluxo)
  if Assigned(AOnGranted) then
    AOnGranted();
{$ENDIF}
end;

class procedure TPermissionsHelper.RequestLocationPermissions(
  const AOnGranted: TProc;
  const AOnDenied: TProc);
begin
{$IFDEF ANDROID}
  PermissionsService.RequestPermissions(
    ['android.permission.ACCESS_FINE_LOCATION',
     'android.permission.ACCESS_COARSE_LOCATION'],
    procedure(const APermissions: TArray<string>;
              const AGrantResults: TArray<TPermissionStatus>)
    var
      LFineGranted, LCoarseGranted: Boolean;
    begin
      LFineGranted  := (Length(AGrantResults) > 0) and
                       (AGrantResults[0] = TPermissionStatus.Granted);
      LCoarseGranted := (Length(AGrantResults) > 1) and
                       (AGrantResults[1] = TPermissionStatus.Granted);

      // Pelo menos localizacao aproximada e suficiente para muitos casos
      if LFineGranted or LCoarseGranted then
      begin
        if Assigned(AOnGranted) then
          AOnGranted()
      end
      else
      begin
        if Assigned(AOnDenied) then
          AOnDenied()
        else
          ShowMessage('Permissao de localizacao negada.');
      end;
    end);
{$ELSE}
  if Assigned(AOnGranted) then
    AOnGranted();
{$ENDIF}
end;

class procedure TPermissionsHelper.RequestMultiplePermissions(
  const APermissions: TArray<string>;
  const AOnAllGranted: TProc;
  const AOnAnyDenied: TProc);
begin
{$IFDEF ANDROID}
  PermissionsService.RequestPermissions(
    APermissions,
    procedure(const APerms: TArray<string>;
              const AGrantResults: TArray<TPermissionStatus>)
    var
      I: Integer;
      LAllGranted: Boolean;
    begin
      LAllGranted := True;
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
        if Assigned(AOnAllGranted) then
          AOnAllGranted()
      end
      else
      begin
        if Assigned(AOnAnyDenied) then
          AOnAnyDenied()
        else
          ShowMessage('Uma ou mais permissoes foram negadas.');
      end;
    end);
{$ELSE}
  if Assigned(AOnAllGranted) then
    AOnAllGranted();
{$ENDIF}
end;

class function TPermissionsHelper.IsPermissionGranted(
  const APermission: string): Boolean;
begin
{$IFDEF ANDROID}
  Result := PermissionsService.IsPermissionGranted(APermission);
{$ELSE}
  Result := True; // Sempre concedida em plataformas nao-Android
{$ENDIF}
end;

class procedure TPermissionsHelper.RequestMicrophonePermission(
  const AOnGranted: TProc;
  const AOnDenied: TProc);
begin
{$IFDEF ANDROID}
  PermissionsService.RequestPermissions(
    ['android.permission.RECORD_AUDIO'],
    procedure(const APermissions: TArray<string>;
              const AGrantResults: TArray<TPermissionStatus>)
    begin
      if (Length(AGrantResults) > 0) and
         (AGrantResults[0] = TPermissionStatus.Granted) then
      begin
        if Assigned(AOnGranted) then
          AOnGranted()
      end
      else
      begin
        if Assigned(AOnDenied) then
          AOnDenied()
        else
          ShowMessage('Permissao de microfone negada.');
      end;
    end);
{$ELSE}
  if Assigned(AOnGranted) then
    AOnGranted();
{$ENDIF}
end;

class procedure TPermissionsHelper.RequestStoragePermissions(
  const AOnGranted: TProc;
  const AOnDenied: TProc);
begin
{$IFDEF ANDROID}
  // API 33+: usar READ_MEDIA_* em vez de READ_EXTERNAL_STORAGE
  // Para simplicidade, solicitamos READ_EXTERNAL_STORAGE (funciona ate API 32)
  // Para API 33+: ajustar para READ_MEDIA_IMAGES, READ_MEDIA_VIDEO, READ_MEDIA_AUDIO
  PermissionsService.RequestPermissions(
    ['android.permission.READ_EXTERNAL_STORAGE',
     'android.permission.WRITE_EXTERNAL_STORAGE'],
    procedure(const APermissions: TArray<string>;
              const AGrantResults: TArray<TPermissionStatus>)
    begin
      if (Length(AGrantResults) >= 2) and
         (AGrantResults[0] = TPermissionStatus.Granted) and
         (AGrantResults[1] = TPermissionStatus.Granted) then
      begin
        if Assigned(AOnGranted) then
          AOnGranted()
      end
      else
      begin
        if Assigned(AOnDenied) then
          AOnDenied()
        else
          ShowMessage('Permissoes de armazenamento negadas.');
      end;
    end);
{$ELSE}
  if Assigned(AOnGranted) then
    AOnGranted();
{$ENDIF}
end;

class procedure TPermissionsHelper.RequestNotificationPermission(
  const AOnGranted: TProc;
  const AOnDenied: TProc);
begin
{$IFDEF ANDROID}
  // POST_NOTIFICATIONS requerido apenas em Android 13+ (API 33+)
  // Em versoes anteriores, notificacoes sao permitidas automaticamente
  PermissionsService.RequestPermissions(
    ['android.permission.POST_NOTIFICATIONS'],
    procedure(const APermissions: TArray<string>;
              const AGrantResults: TArray<TPermissionStatus>)
    begin
      if (Length(AGrantResults) > 0) and
         (AGrantResults[0] = TPermissionStatus.Granted) then
      begin
        if Assigned(AOnGranted) then
          AOnGranted()
      end
      else
      begin
        if Assigned(AOnDenied) then
          AOnDenied()
        else
          ShowMessage('Permissao de notificacoes negada.');
      end;
    end);
{$ELSE}
  if Assigned(AOnGranted) then
    AOnGranted();
{$ENDIF}
end;

end.

{
  EXEMPLO DE USO (em um Form):

  // Solicitar camera ao clicar botao
  procedure TfrmMain.BtnCameraClick(Sender: TObject);
  begin
    TPermissionsHelper.RequestCameraPermission(
      procedure
      begin
        StartCamera; // Permissao concedida
      end,
      procedure
      begin
        ShowMessage('Sem acesso a camera. Verifique as permissoes do app.');
      end);
  end;

  // Solicitar multiplas permissoes antes de iniciar uma feature
  procedure TfrmMain.BtnStartFeatureClick(Sender: TObject);
  begin
    TPermissionsHelper.RequestMultiplePermissions(
      ['android.permission.CAMERA',
       'android.permission.RECORD_AUDIO',
       'android.permission.ACCESS_FINE_LOCATION'],
      procedure
      begin
        StartFeature; // Todas concedidas
      end,
      procedure
      begin
        ShowMessage('Permissoes necessarias nao foram concedidas.');
      end);
  end;

  // Verificar antes de executar (sem solicitar novamente)
  procedure TfrmMain.SomeMethod;
  begin
    if TPermissionsHelper.IsPermissionGranted('android.permission.CAMERA') then
      UseCamera
    else
      ShowMessage('Permissao de camera necessaria. Abra as configuracoes do app.');
  end;
}

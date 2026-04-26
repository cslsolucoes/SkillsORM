# Referência Rápida: Lista Completa de Permissões Android

## Classificação de Permissões

| Tipo | Comportamento | Exemplo |
|------|---------------|---------|
| **Normal** | Concedidas automaticamente ao instalar | INTERNET, VIBRATE |
| **Perigosas** | Requerem confirmação do usuário em runtime (API 23+) | CAMERA, LOCATION |
| **Signature** | Concedidas apenas a apps do mesmo certificado | — |

---

## Tabela Completa por Categoria

### Rede e Conectividade

| Permissão | Tipo | Declarar no Manifesto | Solicitar Runtime |
|-----------|------|----------------------|-------------------|
| `android.permission.INTERNET` | Normal | Sim | Nao |
| `android.permission.ACCESS_NETWORK_STATE` | Normal | Sim | Nao |
| `android.permission.ACCESS_WIFI_STATE` | Normal | Sim | Nao |
| `android.permission.CHANGE_NETWORK_STATE` | Normal | Sim | Nao |
| `android.permission.CHANGE_WIFI_STATE` | Normal | Sim | Nao |

### Câmera e Mídia

| Permissão | Tipo | API | Solicitar Runtime |
|-----------|------|-----|-------------------|
| `android.permission.CAMERA` | Perigosa | Todas | Sim |
| `android.permission.READ_MEDIA_IMAGES` | Perigosa | 33+ | Sim |
| `android.permission.READ_MEDIA_VIDEO` | Perigosa | 33+ | Sim |
| `android.permission.READ_MEDIA_AUDIO` | Perigosa | 33+ | Sim |
| `android.permission.RECORD_AUDIO` | Perigosa | Todas | Sim |

### Localização

| Permissão | Precisão | Tipo | Solicitar Runtime |
|-----------|----------|------|-------------------|
| `android.permission.ACCESS_FINE_LOCATION` | GPS (~1m) | Perigosa | Sim |
| `android.permission.ACCESS_COARSE_LOCATION` | Wi-Fi/Cell (~50m) | Perigosa | Sim |
| `android.permission.ACCESS_BACKGROUND_LOCATION` | Background | Perigosa | Sim (separada) |

> Nota: A partir do Android 10, localização em background requer permissão separada.

### Armazenamento

| Permissão | API | Tipo | Solicitar Runtime |
|-----------|-----|------|-------------------|
| `android.permission.READ_EXTERNAL_STORAGE` | Até 32 | Perigosa | Sim |
| `android.permission.WRITE_EXTERNAL_STORAGE` | Até 29 | Perigosa | Sim |
| `android.permission.MANAGE_EXTERNAL_STORAGE` | 30+ | Perigosa | Sim (via intent) |

> Android 13+: usar `READ_MEDIA_*` em vez de `READ_EXTERNAL_STORAGE`.

### Bluetooth

| Permissão | API | Tipo | Solicitar Runtime |
|-----------|-----|------|-------------------|
| `android.permission.BLUETOOTH` | Até 30 | Normal | Nao |
| `android.permission.BLUETOOTH_ADMIN` | Até 30 | Normal | Nao |
| `android.permission.BLUETOOTH_CONNECT` | 31+ | Perigosa | Sim |
| `android.permission.BLUETOOTH_SCAN` | 31+ | Perigosa | Sim |
| `android.permission.BLUETOOTH_ADVERTISE` | 31+ | Perigosa | Sim |

### Contatos e Calendário

| Permissão | Tipo | Solicitar Runtime |
|-----------|------|-------------------|
| `android.permission.READ_CONTACTS` | Perigosa | Sim |
| `android.permission.WRITE_CONTACTS` | Perigosa | Sim |
| `android.permission.READ_CALENDAR` | Perigosa | Sim |
| `android.permission.WRITE_CALENDAR` | Perigosa | Sim |

### Telefonia e SMS

| Permissão | Tipo | Solicitar Runtime |
|-----------|------|-------------------|
| `android.permission.READ_PHONE_STATE` | Perigosa | Sim |
| `android.permission.CALL_PHONE` | Perigosa | Sim |
| `android.permission.READ_CALL_LOG` | Perigosa | Sim |
| `android.permission.SEND_SMS` | Perigosa | Sim |
| `android.permission.RECEIVE_SMS` | Perigosa | Sim |
| `android.permission.READ_SMS` | Perigosa | Sim |

### Notificações e Sistema

| Permissão | API | Tipo | Solicitar Runtime |
|-----------|-----|------|-------------------|
| `android.permission.POST_NOTIFICATIONS` | 33+ | Perigosa | Sim |
| `android.permission.VIBRATE` | Todas | Normal | Nao |
| `android.permission.WAKE_LOCK` | Todas | Normal | Nao |
| `android.permission.RECEIVE_BOOT_COMPLETED` | Todas | Normal | Nao |
| `android.permission.FOREGROUND_SERVICE` | 28+ | Normal | Nao |
| `android.permission.SCHEDULE_EXACT_ALARM` | 31+ | Normal | Nao |

---

## Snippet: Solicitar Permissao Individual

```pascal
uses FMX.Platform.Android, Androidapi.Helpers;

PermissionsService.RequestPermissions(
  ['android.permission.CAMERA'],
  procedure(const APermissions: TArray<string>;
            const AGrantResults: TArray<TPermissionStatus>)
  begin
    if (Length(AGrantResults) > 0) and
       (AGrantResults[0] = TPermissionStatus.Granted) then
      StartCamera
    else
      ShowMessage('Permissao negada.');
  end);
```

## Snippet: Verificar Permissao Sem Solicitar

```pascal
if PermissionsService.IsPermissionGranted('android.permission.CAMERA') then
  UseCamera
else
  RequestCameraPermission;
```

## Declaracao no Manifesto (obrigatoria para todas)

```xml
<!-- AndroidManifest.template.xml, antes de <application> -->
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

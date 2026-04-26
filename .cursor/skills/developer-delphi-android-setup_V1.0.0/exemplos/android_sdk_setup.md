# Guia: Configuração do Android SDK para Delphi

## Visão Geral

O RAD Studio precisa do Android SDK e NDK para compilar apps Android. A forma recomendada de instalar e manter o SDK é via Android Studio, que gerencia versões e atualizações automaticamente.

## Opção 1: Instalar via Android Studio (Recomendado)

### 1. Baixar e instalar Android Studio

- URL: `https://developer.android.com/studio`
- Executar o installer e seguir o assistente de configuração
- Android Studio instala o SDK automaticamente em: `C:\Users\<usuario>\AppData\Local\Android\Sdk\`

### 2. Instalar componentes necessários via SDK Manager

Abrir Android Studio → **SDK Manager** (Tools > SDK Manager):

**Aba SDK Platforms:**
- Android 14.0 (API 34) — marcar
- Android 8.0 (API 26) — marcar (mínimo suportado pelo Delphi)

**Aba SDK Tools:**
- Android SDK Build-Tools (versão mais recente)
- Android SDK Command-line Tools
- Android Emulator (opcional, para testes sem dispositivo físico)
- Android SDK Platform-Tools (`adb.exe`)
- NDK (Side by side) — versão compatível com RAD Studio 12: `25.x`
- CMake (requerido pelo NDK)

Clicar **Apply** para instalar.

### 3. Verificar caminhos instalados

```
C:\Users\<usuario>\AppData\Local\Android\Sdk\
  build-tools\34.0.0\           ← Build Tools
  ndk\25.2.9519653\             ← NDK (numero varia por versao)
  platforms\android-34\         ← SDK Platform API 34
  platform-tools\               ← adb.exe, fastboot.exe
  tools\                        ← avdmanager, sdkmanager
```

### 4. Configurar no RAD Studio

**Tools > Options > Deployment > SDK Manager > + (Add SDK)**:

| Campo | Valor (ajustar conforme instalação) |
|-------|-------------------------------------|
| Platform | `Android 64-bit` |
| Android SDK | `C:\Users\<usuario>\AppData\Local\Android\Sdk` |
| Android NDK | `C:\Users\<usuario>\AppData\Local\Android\Sdk\ndk\25.2.9519653` |
| Java JDK | `C:\Program Files\Java\jdk-11.0.X` ou JDK do Android Studio |

Clicar **Update Local File Cache**.

## Opção 2: Instalar SDK via Command Line Tools (avançado)

```bash
# Baixar command line tools de: developer.android.com/studio#command-tools
# Extrair em C:\Android\cmdline-tools\latest\

# Instalar SDK, NDK e Build Tools
sdkmanager "platforms;android-34" "platforms;android-26"
sdkmanager "build-tools;34.0.0"
sdkmanager "ndk;25.2.9519653"
sdkmanager "platform-tools"
```

## Java JDK

O RAD Studio requer JDK 11+. Opções de instalação:

**OpenJDK (gratuito):**
```
https://adoptium.net/
# Baixar Temurin 11 ou 17 LTS
```

**Oracle JDK:**
```
https://www.oracle.com/java/technologies/downloads/
```

Após instalar, verificar:
```cmd
java -version
# java version "11.x.x"
```

## Conectar Dispositivo Físico para Testes

### Habilitar Developer Options e USB Debugging

1. Settings > About Phone > Build Number → tocar 7 vezes
2. Settings > Developer Options:
   - **USB Debugging** → ON
   - **Install via USB** → ON (opcional, algumas marcas)

### Verificar conexão com ADB

```cmd
cd C:\Users\<usuario>\AppData\Local\Android\Sdk\platform-tools
adb devices
# Deve mostrar o dispositivo listado como "device"
```

Se aparecer `unauthorized`: desbloquear a tela do dispositivo e aceitar o diálogo de autorização USB.

### Driver USB no Windows

Alguns dispositivos precisam de driver USB:
- Samsung: Samsung USB Driver
- Outros: driver genérico Google USB Driver (no SDK Manager)
- Ou instalar via Windows Update / Device Manager

## Emulador (alternativa a dispositivo físico)

Criar AVD (Android Virtual Device) no Android Studio:
1. **Tools > Device Manager > Create Device**
2. Selecionar hardware profile (ex.: Pixel 6)
3. Selecionar system image com API 34
4. Configurar RAM/Storage

Iniciar AVD e verificar com ADB:
```cmd
adb devices
# emulator-5554    device
```

## Troubleshooting

| Problema | Causa | Solução |
|----------|-------|---------|
| "SDK not found" no RAD Studio | Caminho incorreto | Verificar caminho exato do SDK |
| "NDK not compatible" | Versão do NDK errada | Usar versão listada como compatível no SDK Manager do RAD Studio |
| "adb: device not found" | USB Debugging desabilitado | Habilitar em Developer Options |
| Build error "ld.exe failed" | NDK corrompido | Reinstalar NDK via SDK Manager |
| "java: command not found" | JDK não no PATH | Adicionar `%JAVA_HOME%\bin` ao PATH do sistema |

# Guia: Configuração do PAServer para iOS

## O que é o PAServer

O Platform Assistant Server (PAServer) é o agente que roda no Mac e que permite ao RAD Studio Windows:
- Compilar código para iOS (cross-compile via Xcode toolchain)
- Deployar o app no simulador ou dispositivo físico
- Fazer debug remoto via IDE Windows

## Pré-requisitos

- Mac com macOS 12+ (Monterey recomendado) e Xcode instalado
- Xcode Command Line Tools instalados: `xcode-select --install`
- Conta Apple Developer (gratuita para desenvolvimento, paga para distribuição)
- Windows com RAD Studio 12+ instalado
- Mesma rede local (ou VPN) entre Windows e Mac

## Instalação do PAServer no Mac

### Via Installer do RAD Studio (recomendado)

1. No Windows, localizar o installer do RAD Studio
2. Copiar o arquivo `PAServer-<versao>.pkg` para o Mac
   - Caminho típico: `C:\Program Files (x86)\Embarcadero\Studio\23.0\PAServer\`
3. No Mac, executar o `.pkg` e seguir as instruções

### Localização padrão após instalação

```
/Applications/PAServer-<versao>/
  paserver        ← executável principal
  readme.txt
```

## Iniciando o PAServer

### Modo manual (terminal)

```bash
cd /Applications/PAServer-23.0/
./paserver -port 64211 -password MinhaSenh@123
```

### Opções disponíveis

```
-port <N>       Porta TCP (padrão: 64211)
-password <S>   Senha de autenticação (obrigatória para RAD Studio)
-logfile <path> Arquivo de log
```

### Manter rodando em background (launchd)

Criar arquivo `/Library/LaunchDaemons/com.embarcadero.paserver.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.embarcadero.paserver</string>
  <key>ProgramArguments</key>
  <array>
    <string>/Applications/PAServer-23.0/paserver</string>
    <string>-port</string>
    <string>64211</string>
    <string>-password</string>
    <string>MinhaSenh@123</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
</dict>
</plist>
```

Ativar o serviço:

```bash
sudo launchctl load /Library/LaunchDaemons/com.embarcadero.paserver.plist
```

## Configurar Connection Profile no RAD Studio

1. Abrir RAD Studio no Windows
2. **Project > Options > Connection Profile** (ou Tools > Options > Connection Profile)
3. Clicar **Add**:

| Campo | Valor |
|-------|-------|
| Profile Name | `MacLocal` |
| Platform | iOS Device |
| Host name / IP | `192.168.1.10` (IP do Mac) |
| Port | `64211` |
| Password | senha definida no PAServer |

4. Clicar **Test Connection**
5. Se OK: mensagem de sucesso com versão do PAServer

## Troubleshooting

| Problema | Causa provável | Solução |
|----------|----------------|---------|
| Connection refused | PAServer não está rodando | Iniciar PAServer no Mac |
| Wrong password | Senha incorreta | Verificar senha no PAServer |
| Timeout | Firewall bloqueando | Liberar porta 64211 no Mac (System Settings > Firewall) |
| SDK not found | SDK Manager não sincronizado | Tools > SDK Manager > Get From Remote Machine |
| Compilation fails | Xcode não instalado | Instalar Xcode e Command Line Tools |

## Verificação de rede

No Windows, verificar conectividade:

```cmd
ping 192.168.1.10
telnet 192.168.1.10 64211
```

No Mac, verificar que PAServer escuta na porta:

```bash
lsof -i :64211
# Deve mostrar paserver como processo
```

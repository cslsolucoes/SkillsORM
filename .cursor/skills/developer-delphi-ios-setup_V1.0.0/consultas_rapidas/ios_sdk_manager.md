# Referência Rápida: SDK Manager iOS

## Caminho no IDE

**Tools > Options > Deployment > SDK Manager**

## Adicionar SDK iOS (primeiro uso)

1. Clicar **+** (Add SDK)
2. **Platform**: `iOS Device 64-bit`
3. **Remote machine**: selecionar connection profile (PAServer ativo no Mac)
4. Clicar **Get From Remote Machine**
5. Aguardar sincronização dos headers e frameworks

## Estrutura após sincronização (Windows)

```
C:\Users\<user>\AppData\Roaming\Embarcadero\BDS\23.0\SDKs\iPhoneOS<versao>\
  usr\
    include\   ← headers C/Obj-C
    lib\       ← bibliotecas
  System\Library\
    Frameworks\  ← frameworks iOS
```

## Atualizar SDK existente

Após atualizar Xcode ou iOS no Mac:

1. SDK Manager → selecionar SDK existente
2. Clicar **Update Local File Cache**
3. Aguardar resync

## Verificar SDK instalado

| Campo | O que verificar |
|-------|----------------|
| **SDK Version** | Deve coincidir com a versão iOS no Mac |
| **Xcode Version** | Versão do Xcode no Mac |
| **Sysroot** | Caminho do SDK no Mac |

## Comandos de diagnóstico no Mac

```bash
# Listar SDKs disponíveis
xcodebuild -showsdks

# SDK path atual
xcrun --sdk iphoneos --show-sdk-path

# Versão do Xcode
xcodebuild -version
```

## Problemas comuns

| Problema | Causa | Solução |
|----------|-------|---------|
| "Cannot connect to remote machine" | PAServer inativo | Iniciar PAServer no Mac |
| "SDK outdated" | Xcode atualizado sem sync | Update Local File Cache |
| Build error "framework not found" | SDK incompleto | Remover e recriar o SDK |
| Slow sync | Primeira sincronização (muitos arquivos) | Aguardar; usar cabo Ethernet em vez de Wi-Fi |

## Dica: IP Fixo no Mac

Para não precisar reconfigurar o connection profile após cada reinicialização:

**macOS:** System Settings > Network > Wi-Fi/Ethernet > Details > TCP/IP → Configure IPv4: **Manually**
- IP: `192.168.1.X` (fora do range DHCP do roteador)
- Subnet: `255.255.255.0`
- Router: IP do roteador

# Erros Comuns em MSIX — Causa e Solucao

## Erros de assinatura

| Erro | Codigo | Causa | Solucao |
|------|--------|-------|---------|
| `The publisher of the package...does not match...` | 0x80080204 | Publisher no manifest difere do Subject DN do certificado | Sincronizar `MSIX_PackagePublisher` com o Subject exato do certificado |
| `A certificate chain could not be built to a trusted root` | 0x800B010A | Certificado nao esta no Trusted Root da maquina | Instalar o `.cer` em `Cert:\LocalMachine\Root` |
| `The signature file is not valid` | 0x80080206 | MSIX corrompido ou assinado com algoritmo invalido | Reasinar com `/fd SHA256 /td SHA256` |
| `signtool: No certificates were found...` | - | Subject name errado ou certificado nao instalado | Verificar `/n "Subject"` ou usar `/sha1 THUMBPRINT` |

---

## Erros de versao

| Erro | Causa | Solucao |
|------|-------|---------|
| Submissao rejeitada na Store: versao invalida | Quarto componente da versao != 0 (ex: `1.0.0.1`) | Corrigir para `1.0.0.0`, `1.0.1.0` etc. |
| `Add-AppxPackage` falha: versao menor ou igual | Tentando instalar versao igual ou inferior a instalada | Incrementar a versao antes de empacotar |
| Versao do manifest nao coincide com o .dproj | Editou manualmente um dos dois sem atualizar o outro | Manter `MSIX_PackageVersion` e `<Version>` no AppxManifest.xml sincronizados |

---

## Erros de instalacao (Add-AppxPackage)

| Erro | Codigo | Causa | Solucao |
|------|--------|-------|---------|
| `App cannot be installed because it requires a newer version of Windows` | 0x80073CF9 | MinVersion no manifest superior ao Windows do usuario | Reduzir MinVersion ou atualizar o Windows |
| `The deployment operation failed` (sem detalhe) | - | Varios; ver log detalhado | `Get-AppxLog | Where-Object {$_.EventId -eq 404}` |
| `ERROR_INSTALL_POLICY_FAILURE` | 0x8007064A | Sideloading nao habilitado | Habilitar Developer Mode em Settings > For Developers |
| `The package could not be registered` | - | DLL ausente ou conflito de versao | Verificar Deployment Manager; testar em VM limpa |
| `An error occurred while signing...` (no RAD Studio) | - | signtool nao encontrado no PATH | Configurar PATH com diretorio do Windows SDK |

---

## Erros no WACK

| Erro WACK | Categoria | Causa | Solucao |
|-----------|-----------|-------|---------|
| `APIs proibidas: RegOpenKey` | Supported APIs | API legada sem sufixo Ex | Substituir por `RegOpenKeyEx` |
| `APIs proibidas: GetVersion` | Supported APIs | API deprecated no Win8.1+ | Usar `RtlGetVersion` ou `VersionHelper.h` |
| `App nao iniciou em 5s` | App Launch Test | Inicializacao lenta ou crash | Otimizar startup; verificar dependencias |
| `Capability nao declarada` | Supported APIs | App usa recurso sem declarar | Adicionar capability no manifest |
| `Icone com fundo nao transparente` | App Manifest | PNG com background solido | Recriar com alpha=0 no background |
| `DLL ausente` | Binaries Analysis | Dependencia nao no pacote | Adicionar ao Deployment Manager |
| `Assembly x86 em pacote x64` | Platform | Mismatch de arquitetura | Usar DLL x64 correspondente |

---

## Erros do AppxManifest.xml

| Erro | Causa | Solucao |
|------|-------|---------|
| `The manifest root element must be Package` | XML malformado ou namespace errado | Verificar declaracao XML e namespaces |
| `The identity element is missing` | Elemento `<Identity>` ausente ou mal-formado | Adicionar `<Identity Name= Publisher= Version= ProcessorArchitecture=/>` |
| `The value of the Publisher attribute...` | Publisher no formato errado | Usar formato DN completo: `CN=..., O=..., C=...` |
| `The Package/Properties/Logo element is missing` | Elemento `<Logo>` ausente | Adicionar `<Logo>Assets\StoreLogo.png</Logo>` |
| `Could not find file Assets\StoreLogo.png` | Asset nao incluido no pacote | Adicionar PNG ao Deployment Manager |
| `Namespace rescap nao reconhecido` | Namespace nao declarado no elemento Package | Adicionar `xmlns:rescap=...` e `IgnorableNamespaces="rescap"` |

---

## Erros de build no RAD Studio

| Erro | Causa | Solucao |
|------|-------|---------|
| `MakeAppx.exe not found` | Windows SDK nao instalado | Instalar Windows 10/11 SDK via Visual Studio Installer |
| `MSIX_PackageVersion nao definido` | PropertyGroup Win64 ausente no .dproj | Adicionar PropertyGroup com condicao `'$(Platform)'=='Win64'` |
| `Access denied` ao gerar .msix | Pasta `dist` sem permissao de escrita | Alterar permissoes da pasta ou trocar `MSIX_OutputDir` |
| Build ok mas .msix nao gerado | `MSIX_Packaging` = false na config Release | Verificar PropertyGroup com condicao `'$(Cfg_2)'!=''` |

---

## Ferramenta de diagnostico

```powershell
# Ver ultimas mensagens de erro do AppX subsystem
Get-EventLog -LogName Application -Source "Microsoft-Windows-AppxPackagingOM" -Newest 20 |
  Where-Object { $_.EntryType -eq "Error" } |
  Select-Object TimeGenerated, Message

# Ver logs de instalacao AppX
Get-AppxLog | Select-Object -Last 50 | Format-List

# Verificar integridade de MSIX sem instalar
$makeappx = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\makeappx.exe"
& $makeappx unpack /p "GestorERP_1.0.0.0_x64.msix" /d ".\msix_inspect" /v
```

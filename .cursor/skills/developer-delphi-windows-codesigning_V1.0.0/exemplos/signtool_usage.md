# signtool.exe — Guia de Uso

## Localizacao

```
C:\Program Files (x86)\Windows Kits\10\bin\10.0.{build}.0\x64\signtool.exe
```

Descobrir o caminho automaticamente via PowerShell:

```powershell
Get-ChildItem "C:\Program Files (x86)\Windows Kits\10\bin\*\x64\signtool.exe" |
    Sort-Object FullName -Descending |
    Select-Object -First 1 -ExpandProperty FullName
```

---

## Comando: `sign` — Assinar arquivo

### Forma basica com PFX

```batch
signtool sign ^
  /fd SHA256 ^
  /f "caminho\para\certificado.pfx" ^
  /p "SenhaDoPfx" ^
  /tr http://timestamp.digicert.com ^
  /td SHA256 ^
  "arquivo.msix"
```

### Assinar com certificado do store (por subject)

```batch
signtool sign ^
  /fd SHA256 ^
  /n "Empresa LTDA" ^
  /tr http://timestamp.digicert.com ^
  /td SHA256 ^
  "arquivo.msix"
```

### Assinar com certificado do store (por thumbprint)

```batch
signtool sign ^
  /fd SHA256 ^
  /sha1 "A1B2C3D4E5F6..." ^
  /tr http://timestamp.digicert.com ^
  /td SHA256 ^
  "arquivo.msix"
```

### Assinar multiplos arquivos

```batch
signtool sign ^
  /fd SHA256 ^
  /f "cert.pfx" /p "senha" ^
  /tr http://timestamp.digicert.com ^
  /td SHA256 ^
  "arquivo1.exe" "arquivo2.dll" "arquivo3.msix"
```

### Assinar com verbose (para debug)

```batch
signtool sign ^
  /fd SHA256 ^
  /f "cert.pfx" /p "senha" ^
  /tr http://timestamp.digicert.com ^
  /td SHA256 ^
  /v ^
  "arquivo.msix"
```

---

## Comando: `verify` — Verificar assinatura

### Verificacao basica

```batch
signtool verify /pa "arquivo.msix"
```

### Verificacao detalhada (verbose)

```batch
signtool verify /pa /v "arquivo.msix"
```

### Verificar todos os signatarios (co-sign)

```batch
signtool verify /pa /all "arquivo.exe"
```

### Verificar por catalogo

```batch
signtool verify /a /v "arquivo.exe"
```

---

## Comando: `timestamp` — Adicionar timestamp retroativamente

```batch
signtool timestamp ^
  /tr http://timestamp.digicert.com ^
  /td SHA256 ^
  "arquivo.msix"
```

---

## Flags completos — Referencia rapida

| Flag | Valor | Descricao |
|------|-------|-----------|
| `/fd` | `SHA256` | File Digest Algorithm. Sempre SHA256 para novos projetos. |
| `/f` | `caminho.pfx` | Arquivo PFX com certificado e chave privada |
| `/p` | `senha` | Senha do arquivo PFX |
| `/sha1` | `THUMBPRINT` | Thumbprint do certificado no store do Windows |
| `/n` | `"Subject CN"` | Subject Name do certificado no store |
| `/tr` | `URL` | URL do servidor de timestamp RFC 3161 |
| `/t` | `URL` | URL do servidor de timestamp Authenticode legado (nao recomendado) |
| `/td` | `SHA256` | Timestamp Digest Algorithm. Sempre SHA256. |
| `/v` | - | Verbose: mostra detalhes completos da operacao |
| `/q` | - | Quiet: suprime saida (bom para CI/CD) |
| `/as` | - | Append Signature: adiciona uma segunda assinatura (dual-sign) |
| `/ac` | `cert.cer` | Adiciona certificado intermediario (cross-certificate) |
| `/ph` | - | Gera e verifica hashes de pagina |
| `/kp` | - | Usar Kernel Mode Driver Signing Policy |
| `/a` | - | Seleciona automaticamente o melhor certificado |
| `/all` | - | Verifica todos os signatarios |
| `/pa` | - | Usa Default Authentication Verification Policy |
| `/r` | `RootSubject` | Verifica que a cadeia termina neste root |
| `/tw` | - | Gera aviso se nao houver timestamp |

---

## Codigos de saida

| Codigo | Significado |
|--------|-------------|
| `0` | Sucesso |
| `1` | Falha (ver mensagem de erro) |
| `2` | Aviso (arquivo ja assinado, etc.) |

---

## Erros comuns e solucoes

| Erro | Causa | Solucao |
|------|-------|---------|
| `The file is not signed.` | Arquivo sem assinatura | Verificar se o sign foi bem-sucedido |
| `No certificates were found...` | Certificado nao encontrado no store | Verificar subject ou thumbprint |
| `The specified PFX file...` | Senha incorreta ou PFX corrompido | Verificar senha e reexportar PFX |
| `A certificate chain could not be built...` | CA intermediaria nao instalada | Instalar chain completa com /ac |
| `Error: The timestamp server...` | Servidor de timestamp offline | Tentar outro servidor da lista |
| `SignerSign() failed.` (0x80880253) | Certificado nao tem EKU de Code Signing | Recriar certificado com TextExtension correto |

---

## Exemplo completo — Script PowerShell para assinar MSIX

```powershell
$signtool = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\signtool.exe"
$pfxPath  = ".\certs\MeuApp_signing.pfx"
$pfxPass  = $env:PFX_PASSWORD   # Lido de variavel de ambiente, nunca hardcoded
$msixFile = ".\dist\GestorERP_1.0.0.0_x64.msix"
$tsServer = "http://timestamp.digicert.com"

# Assinar
& $signtool sign /fd SHA256 /f $pfxPath /p $pfxPass /tr $tsServer /td SHA256 /v $msixFile
if ($LASTEXITCODE -ne 0) { throw "Falha na assinatura: codigo $LASTEXITCODE" }

# Verificar
& $signtool verify /pa /v $msixFile
if ($LASTEXITCODE -ne 0) { throw "Falha na verificacao: codigo $LASTEXITCODE" }

Write-Host "Assinatura e verificacao concluidas com sucesso."
```

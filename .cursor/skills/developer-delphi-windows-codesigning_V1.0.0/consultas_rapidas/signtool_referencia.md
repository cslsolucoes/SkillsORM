# signtool.exe — Referencia de Flags

## Flags do comando `sign`

| Flag | Argumento | Descricao | Exemplo |
|------|-----------|-----------|---------|
| `/fd` | algoritmo | File Digest Algorithm. Sempre `SHA256` para novos projetos. | `/fd SHA256` |
| `/f` | caminho.pfx | Arquivo PFX com certificado + chave privada | `/f "cert.pfx"` |
| `/p` | senha | Senha do arquivo PFX | `/p "Senha@2026"` |
| `/sha1` | thumbprint | Thumbprint do certificado no Windows store | `/sha1 "A1B2C3..."` |
| `/n` | subject | Subject Name (CN) do certificado no store | `/n "Empresa LTDA"` |
| `/tr` | URL | Servidor de timestamp RFC 3161 (recomendado) | `/tr http://timestamp.digicert.com` |
| `/t` | URL | Servidor de timestamp Authenticode legado (nao usar em novos projetos) | `/t http://...` |
| `/td` | algoritmo | Timestamp Digest Algorithm. Sempre `SHA256`. | `/td SHA256` |
| `/as` | - | Append Signature: adiciona segunda assinatura sem remover a primeira | `/as` |
| `/ac` | cert.cer | Adiciona certificado intermediario (cross-certificate para drivers) | `/ac "cross.cer"` |
| `/v` | - | Verbose: exibe detalhes completos | `/v` |
| `/q` | - | Quiet: sem saida (ideal para CI/CD silencioso) | `/q` |
| `/d` | descricao | Descricao do software (aparece em dialogo UAC) | `/d "GestorERP"` |
| `/du` | URL | URL para mais informacoes sobre o software | `/du "https://empresa.com"` |
| `/ph` | - | Gerar e verificar hashes de pagina (page hashes) | `/ph` |
| `/kp` | - | Usar Kernel Mode Driver Signing Policy | `/kp` |
| `/a` | - | Selecionar automaticamente o melhor certificado disponivel | `/a` |
| `/u` | OID | Uso adicional de chave (Enhanced Key Usage OID) | `/u 1.3.6.1.5.5.7.3.3` |
| `/uw` | - | Uso adicional de chave para Windows System Component | `/uw` |

---

## Flags do comando `verify`

| Flag | Argumento | Descricao |
|------|-----------|-----------|
| `/pa` | - | Usa Default Authentication Verification Policy |
| `/v` | - | Verbose: exibe detalhes da cadeia de certificacao e timestamp |
| `/a` | - | Localiza assinatura por catalogo automaticamente |
| `/all` | - | Verifica todos os signatarios (dual-sign) |
| `/r` | RootSubject | Verifica que a cadeia termina neste subject de root |
| `/tw` | - | Gera aviso se o arquivo nao tiver timestamp |
| `/kp` | - | Verifica usando Kernel-Mode Driver Signing Policy |
| `/ad` | - | Verifica usando Default Driver Signing Policy |
| `/u` | OID | Verifica que o certificado tem este EKU OID |
| `/c` | catalog.cat | Especifica arquivo de catalogo para verificacao |

---

## Flags do comando `timestamp`

| Flag | Argumento | Descricao |
|------|-----------|-----------|
| `/tr` | URL | Servidor RFC 3161 |
| `/td` | algoritmo | Digest Algorithm do timestamp |
| `/tp` | index | Indice do signatario para aplicar timestamp |

---

## Combinacoes mais comuns

### Assinar MSIX para sideload (desenvolvimento)

```batch
signtool sign /fd SHA256 /f "dev.pfx" /p "senha" /tr http://timestamp.digicert.com /td SHA256 /v "app.msix"
```

### Assinar EXE para distribuicao publica (OV/EV)

```batch
signtool sign /fd SHA256 /n "Empresa LTDA" /tr http://timestamp.digicert.com /td SHA256 /d "GestorERP" /du "https://empresa.com" /v "GestorERP.exe"
```

### Dual-sign (SHA1 legado + SHA256 moderno)

```batch
REM Primeira assinatura SHA256
signtool sign /fd SHA256 /f "cert.pfx" /p "senha" /tr http://timestamp.digicert.com /td SHA256 "app.exe"

REM Segunda assinatura SHA1 (append, sem remover a primeira)
signtool sign /fd SHA1 /f "cert.pfx" /p "senha" /t http://timestamp.digicert.com /as "app.exe"
```

### Verificar com todos os detalhes

```batch
signtool verify /pa /v /all "app.msix"
```

---

## Codigos de retorno

| Codigo | Significado | Acao |
|--------|-------------|------|
| `0` | Sucesso | Continuar |
| `1` | Erro (falha na operacao) | Verificar mensagem de erro e corrigir |
| `2` | Aviso (ex.: ja assinado) | Avaliar se e aceitavel |

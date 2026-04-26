# Servidores de Timestamp Gratuitos

## Por que usar timestamp?

Sem timestamp, a assinatura digital expira junto com o certificado.
Com timestamp, o arquivo permanece valido mesmo apos o certificado expirar,
pois o timestamp prova que foi assinado enquanto o certificado era valido.

**Regra:** sempre usar `/tr` + `/td SHA256` em todos os comandos `signtool sign`.

---

## Lista de servidores gratuitos

| Provedor | URL RFC 3161 | URL Authenticode Legado | Notas |
|---------|--------------|------------------------|-------|
| DigiCert | `http://timestamp.digicert.com` | `http://timestamp.digicert.com` | Mais usado, alta disponibilidade |
| Sectigo (Comodo) | `http://timestamp.sectigo.com` | `http://timestamp.comodoca.com` | Boa alternativa |
| GlobalSign | `http://timestamp.globalsign.com/scripts/timstamp.dll` | - | Disponivel para clientes |
| Entrust | `http://timestamp.entrust.net/TSS/RFC3161sha2TS` | - | SHA-256 nativo |
| SSL.com | `http://ts.ssl.com` | - | Suporta RFC 3161 |

---

## Flags no signtool

### RFC 3161 (recomendado — SHA-256)

```batch
/tr http://timestamp.digicert.com /td SHA256
```

### Authenticode legado (SHA-1, apenas para compatibilidade com sistemas antigos)

```batch
/t http://timestamp.digicert.com
```

> Nunca usar `/t` em novos projetos. `/tr` com SHA256 e o padrao atual.

---

## Fallback em scripts (tentar servidores alternativos)

```powershell
$timestampServers = @(
    "http://timestamp.digicert.com",
    "http://timestamp.sectigo.com",
    "http://timestamp.entrust.net/TSS/RFC3161sha2TS"
)

$signed = $false
foreach ($ts in $timestampServers) {
    Write-Host "Tentando timestamp server: $ts"
    & $signtool sign /fd SHA256 /f $pfxPath /p $pfxPassword /tr $ts /td SHA256 $fileToSign
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Sucesso com: $ts"
        $signed = $true
        break
    }
    Write-Host "Falhou com $ts, tentando proximo..."
}

if (-not $signed) {
    throw "Nenhum servidor de timestamp disponivel. Verificar conectividade."
}
```

---

## Verificar se o timestamp foi aplicado

```batch
signtool verify /pa /v "arquivo.msix"
```

Na saida, procurar por:
```
The signature is timestamped: Sat Apr 11 10:00:00 2026
Timestamp Verified by:
    Issued to: DigiCert Timestamp 2023
```

Se nao houver linha `The signature is timestamped`, o timestamp nao foi aplicado.

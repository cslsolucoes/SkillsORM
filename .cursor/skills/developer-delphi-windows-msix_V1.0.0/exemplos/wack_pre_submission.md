# WACK — Windows App Certification Kit

## O que e o WACK

O Windows App Certification Kit (WACK) e a ferramenta oficial da Microsoft para
validar se um MSIX atende aos requisitos da Microsoft Store ANTES de submeter.
Executar o WACK e obrigatorio para evitar rejeicao automatica na Store.

---

## Localizacao e pre-requisitos

### Instalacao do WACK

Incluido no **Windows Assessment and Deployment Kit (ADK)** ou disponivel junto ao **Windows SDK**.

Caminho tipico apos instalacao:
```
C:\Program Files (x86)\Windows Kits\10\App Certification Kit\
```

Executavel principal:
```
C:\Program Files (x86)\Windows Kits\10\App Certification Kit\appcert.exe
```

### Pre-requisitos para execucao

1. Windows 10/11 (a mesma versao que o MinVersion do manifest ou superior)
2. O MSIX deve estar assinado (mesmo com certificado de teste)
3. Executar como Administrador (recomendado)
4. Fechar outros aplicativos durante o teste (o WACK instala e executa o app)

---

## Passo a passo

### PASSO 1 — Preparar o MSIX

```powershell
# Garantir que o MSIX esta assinado
signtool verify /pa /v "GestorERP_1.0.0.0_x64.msix"
# Se falhar, assinar primeiro (ver skill developer-delphi-windows-codesigning_V1.0.0)
```

### PASSO 2 — Executar WACK via CLI

```batch
REM Navegue ate a pasta do App Certification Kit
cd "C:\Program Files (x86)\Windows Kits\10\App Certification Kit"

REM Executar teste completo
appcert.exe test ^
  -apptype DesktopApp ^
  -setuppath "C:\caminho\para\GestorERP_1.0.0.0_x64.msix" ^
  -setuptype store ^
  -reportoutputpath "C:\wack_reports\wack_report.xml"
```

**Parametros explicados:**

| Parametro | Valor | Descricao |
|-----------|-------|-----------|
| `-apptype` | `DesktopApp` | Tipo de aplicativo. Para MSIX Win32 classico: `DesktopApp` |
| `-setuppath` | caminho do .msix | Caminho completo para o arquivo MSIX |
| `-setuptype` | `store` | Tipo de pacote. Use `store` para MSIX destinado a Store |
| `-reportoutputpath` | caminho do .xml | Onde salvar o relatorio de resultado |

### PASSO 3 — Aguardar a execucao

O WACK vai:
1. Instalar o MSIX na maquina de teste
2. Iniciar o aplicativo
3. Executar os testes automatizados (pode levar 5-15 minutos)
4. Desinstalar o aplicativo
5. Gerar o relatorio XML

### PASSO 4 — Analisar o relatorio XML

```powershell
# Resumo rapido: passar ou falhar
[xml]$report = Get-Content "C:\wack_reports\wack_report.xml"
$overallResult = $report.REPORT.OVERALL_RESULT
Write-Host "Resultado geral: $overallResult"

# Listar todos os testes com falha
$report.REPORT.REQUIREMENTS.REQUIREMENT | Where-Object { $_.RESULT -eq "FAIL" } | ForEach-Object {
    Write-Host ""
    Write-Host "FALHA: $($_.NAME)" -ForegroundColor Red
    Write-Host "  Descricao: $($_.DESCRIPTION)"
    if ($_.MESSAGES) {
        Write-Host "  Mensagem: $($_.MESSAGES.MESSAGE)"
    }
}

# Listar avisos
$report.REPORT.REQUIREMENTS.REQUIREMENT | Where-Object { $_.RESULT -eq "WARN" } | ForEach-Object {
    Write-Host "AVISO: $($_.NAME)" -ForegroundColor Yellow
}
```

---

## Erros mais frequentes e solucoes

| Erro WACK | Causa | Solucao |
|-----------|-------|---------|
| **APIs proibidas detectadas** `RegOpenKey` | API Windows legada; versao sem sufixo Ex/Ex2 | Substituir por `RegOpenKeyEx` / `RegOpenKeyExW` |
| **APIs proibidas** `GetVersion` | API deprecated no Windows 8.1+ | Usar `VersionHelper.h` ou `RtlGetVersion` |
| **Capabilities nao declaradas** | App usa recurso nao listado no manifest | Adicionar capability no AppxManifest.xml |
| **Ícone com fundo nao transparente** | PNG com cor de fundo solida | Recriar assets com fundo transparente (alpha=0) |
| **DLL ausente no pacote** | Dependencia nao incluida no Deployment Manager | Adicionar DLL via Project > Deployment |
| **Versao invalida** (`1.0.0.1`) | Quarto componente != 0 | Corrigir para formato `M.m.b.0` |
| **Publisher nao coincide** | CN do cert diferente do Publisher no manifest | Sincronizar Subject DN do cert com MSIX_PackagePublisher |
| **App nao inicia em 5 segundos** | Inicializacao lenta ou erro de startup | Otimizar inicializacao; verificar dependencias |
| **Crash durante testes WACK** | Excecao nao tratada ou DLL ausente | Testar instalacao manual primeiro; verificar logs de evento |

---

## Interpretar o relatorio XML — estrutura

```xml
<REPORT>
  <OVERALL_RESULT>PASS</OVERALL_RESULT>   <!-- PASS, FAIL ou WARN -->
  <REQUIREMENTS>
    <REQUIREMENT>
      <NAME>App Capabilities Test</NAME>
      <RESULT>PASS</RESULT>               <!-- PASS, FAIL, WARN ou NOT_RUN -->
      <DESCRIPTION>Verifica capabilities declaradas no manifest</DESCRIPTION>
      <MESSAGES>
        <MESSAGE>Nenhuma capability nao declarada encontrada.</MESSAGE>
      </MESSAGES>
    </REQUIREMENT>
    <!-- ... mais REQUIREMENT ... -->
  </REQUIREMENTS>
</REPORT>
```

---

## WACK via GUI (alternativa)

1. Abrir `appcertui.exe` em `C:\Program Files (x86)\Windows Kits\10\App Certification Kit\`
2. Selecionar **"Validate Store App"**
3. Selecionar o arquivo MSIX
4. Clicar em **"Run tests"**
5. Aguardar e exportar o relatorio

---

## Dica: testar em VM limpa

Para evitar falsos positivos causados pelo ambiente de desenvolvimento:
- Criar VM Windows 11 limpa (sem Visual Studio, sem Delphi instalado)
- Instalar apenas o certificado de teste
- Copiar e instalar o MSIX
- Executar o WACK nessa VM limpa

Isso simula o ambiente do usuario final e detecta DLLs ausentes que passariam despercebidas na maquina de desenvolvimento.

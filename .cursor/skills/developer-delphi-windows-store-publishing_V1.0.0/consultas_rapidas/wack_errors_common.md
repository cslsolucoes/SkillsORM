# Erros WACK Frequentes — Causas e Correcoes

**WACK (Windows App Certification Kit):** ferramenta que simula os testes
de certificacao da Microsoft Store antes da submissao.

**Executar:**
```batch
appcert.exe test "caminho\SeuApp.msix" "C:\Temp\relatorio_wack.xml"
```

> **AVISO:** A lista de testes do WACK muda com atualizacoes do Windows SDK.
> Verificar erros nao listados em:
> `https://learn.microsoft.com/windows/uwp/debug-test-perf/windows-app-certification-kit`

---

## Tabela de Erros Comuns

| # | Teste WACK | Erro / Sintoma | Causa | Como Corrigir |
|---|-----------|---------------|-------|---------------|
| 1 | **App Manifest** | "The app manifest is not valid" | AppxManifest.xml invalido: XML malformado, namespace errado ou campo faltando | Validar o manifest com `MakeAppx.exe` validate. Verificar schema em `https://learn.microsoft.com/uwp/schemas/appxpackage/` |
| 2 | **Package Identity** | "The package identity does not match the product registered in the Store" | `Name` ou `Publisher` no manifest divergem dos valores do Partner Center | Copiar EXATAMENTE os valores de Product Identity do Partner Center para o `.dproj` |
| 3 | **Supported APIs** | "The app uses APIs that are not supported in the app container" | Chamada de API de kernel ou Win32 nao permitida em apps MSIX da Store | Substituir pela API equivalente de WinRT ou Windows App SDK. Ou solicitar excecao de capacidade no manifest |
| 4 | **Windows Security Features** | "The executable does not opt into Windows security features" | Binario compilado sem ASLR, DEP ou SafeSEH | Recompilar com flags de seguranca: `/DYNAMICBASE` (ASLR), `/NXCOMPAT` (DEP), `/SAFESEH` — habilitados por padrao no dcc64 com opcoes corretas |
| 5 | **File Encoding** | "The app contains files that are not supported" | Arquivo com extensao proibida (.bat, .cmd, .ps1, .vbs) incluido no pacote | Remover arquivos de script do pacote. Ver lista em Store Policies. Manter apenas binarios e recursos |
| 6 | **Package Signing** | "The package is not signed or the signature is invalid" | MSIX sem assinatura digital | Para submissao a Store: NAO assinar (a Microsoft assina). Para sideload/teste: assinar com certificado auto-assinado. Ver skill MSIX (SP-L1) |
| 7 | **Supported Architecture** | "The package targets an architecture not supported" | Build gerado para x86 em vez de x64, ou ARM sem suporte | Compilar para Win64 (`dcc64`) para submissao a Store. Adicionar suporte ARM64 se necessario |
| 8 | **Capabilities** | "The app declares capabilities that are not approved" | Declaracao de `rescap:` (restricted capabilities) sem aprovacao previa da Microsoft | Remover capabilities restritas ou solicitar aprovacao antes da submissao via Partner Center. Ver `https://learn.microsoft.com/windows/uwp/packaging/app-capability-declarations` |
| 9 | **DLL Dependencies** | "The app has unresolved DLL dependencies" | DLL de terceiro referenciada mas nao incluida no pacote | Incluir todas as DLLs necessarias no MSIX via Deployment Manager. Verificar com Dependency Walker |
| 10 | **App Crash on Launch** | "The app failed to launch" | App crasha no startup durante o teste do WACK | Testar sideload manualmente. Verificar logs em Event Viewer → Applications. Remover chamadas a APIs bloqueadas no startup |
| 11 | **Direct3D Feature Level** | "The app requires a Direct3D feature level not available on certification machines" | App exige GPU especifica (ex.: DX12) mas maquinas do WACK podem nao ter | Adicionar fallback graceful para hardware sem suporte. Ou declarar `dx12` como requirement no manifest |
| 12 | **Privacy** | "The app accesses user data without declaring the appropriate capability" | Acesso a camera, microfone, localizacao sem declarar no manifest | Adicionar a capability correta no AppxManifest.xml: `<Capability Name="webcam"/>`, `<DeviceCapability Name="microphone"/>`, etc. |

---

## Como Interpretar o Relatorio WACK

O relatorio gerado em XML tem esta estrutura:

```xml
<REPORT>
  <TEST NAME="App manifest test" RESULT="PASS" />
  <TEST NAME="Supported API test" RESULT="FAIL">
    <FAILURE>
      <DETAIL>
        App uses blocked API: CreateFile (kernel32.dll)
        File: GestorERP.exe
      </DETAIL>
    </FAILURE>
  </TEST>
</REPORT>
```

**Niveis de resultado:**
- `PASS` — teste aprovado
- `FAIL` — erro critico; deve ser corrigido antes de submeter
- `WARNING` — aviso; nao bloqueia submissao mas deve ser investigado

---

## Dicas de Diagnostico

### Para erros de "Supported API"

Identificar quais APIs estao sendo chamadas:
```batch
rem Listar imports do executavel
dumpbin /IMPORTS GestorERP.exe > imports.txt
```

Verificar se alguma API da lista de proibidas esta sendo usada.

### Para erros de "App Crash on Launch"

Analisar logs no Event Viewer:
```
eventvwr.msc
  → Windows Logs
    → Application
      → Source: Application Error
```

Ou via PowerShell:
```powershell
Get-EventLog -LogName Application -Source "Application Error" -Newest 5 |
  Where-Object { $_.Message -like "*GestorERP*" } |
  Format-List
```

### Para erros de "Package Identity"

Verificar o manifest dentro do MSIX:
```batch
rem MSIX e um ZIP; renomear para .zip e abrir
copy GestorERP.msix GestorERP.zip
rem Abrir AppxManifest.xml e verificar:
rem <Identity Name="..." Publisher="..." Version="..." />
```

---

## Comandos WACK Uteis

```batch
rem Executar WACK completo (demora varios minutos)
appcert.exe test "C:\Build\GestorERP.msix" "C:\Temp\wack_report.xml"

rem Executar apenas testes especificos (mais rapido)
appcert.exe test "C:\Build\GestorERP.msix" "C:\Temp\wack_report.xml" /testid "Supported API test"

rem Listar todos os testes disponiveis
appcert.exe listtest

rem Abrir o WACK com interface grafica
appcert.exe
```

**Localizar o appcert.exe:**
```
C:\Program Files (x86)\Windows Kits\10\App Certification Kit\appcert.exe
```

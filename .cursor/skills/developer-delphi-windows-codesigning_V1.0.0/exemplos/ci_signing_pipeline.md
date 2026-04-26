# Code Signing em CI/CD

## Principio fundamental

Nunca armazenar PFX ou senha em texto plano no repositorio.
Usar secret vaults da plataforma CI/CD. O fluxo e sempre:

1. PFX convertido para Base64 (uma vez, localmente)
2. Base64 armazenado como secret na plataforma
3. Senha do PFX armazenada como secret separado
4. Pipeline reconstitui o PFX em runtime, usa e apaga imediatamente

---

## Preparacao (executar uma vez, localmente)

```powershell
# Converter PFX para Base64
$pfxBytes = [IO.File]::ReadAllBytes(".\certs\MeuApp_signing.pfx")
$base64 = [Convert]::ToBase64String($pfxBytes)

# Salvar em arquivo temporario para copiar manualmente
$base64 | Out-File ".\pfx_base64_TEMP.txt" -Encoding ascii
Write-Host "Arquivo gerado: pfx_base64_TEMP.txt"
Write-Host "Copie o conteudo para o secret PFX_BASE64 da plataforma CI."
Write-Host "APAGUE o arquivo pfx_base64_TEMP.txt apos copiar!"
```

---

## GitHub Actions

### Configurar secrets

Em `Settings > Secrets and variables > Actions`:
- `PFX_BASE64` — conteudo Base64 do arquivo .pfx
- `PFX_PASSWORD` — senha do arquivo .pfx

### Workflow completo

```yaml
# .github/workflows/build-sign-release.yml
name: Build, Sign and Release

on:
  push:
    tags:
      - 'v*.*.*'

permissions:
  contents: write

jobs:
  build-and-sign:
    runs-on: windows-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Delphi (exemplo com dcc64 no PATH)
        # Adaptar ao metodo de instalacao do Delphi no runner
        run: echo "Delphi configurado"

      - name: Build Release (Win64)
        run: |
          dcc64.exe @dcc64.cfg GestorERP.dpr
        shell: cmd

      - name: Find signtool
        id: signtool
        run: |
          $path = Get-ChildItem "C:\Program Files (x86)\Windows Kits\10\bin\*\x64\signtool.exe" |
            Sort-Object FullName -Descending |
            Select-Object -First 1 -ExpandProperty FullName
          echo "path=$path" >> $env:GITHUB_OUTPUT
        shell: pwsh

      - name: Sign MSIX
        env:
          PFX_BASE64: ${{ secrets.PFX_BASE64 }}
          PFX_PASSWORD: ${{ secrets.PFX_PASSWORD }}
        run: |
          # Reconstituir PFX
          $pfxBytes = [Convert]::FromBase64String($env:PFX_BASE64)
          $pfxPath = Join-Path $env:RUNNER_TEMP "signing.pfx"
          [IO.File]::WriteAllBytes($pfxPath, $pfxBytes)

          # Localizar MSIX gerado pelo RAD Studio
          $msix = Get-ChildItem ".\dist\*.msix" | Select-Object -First 1 -ExpandProperty FullName

          # Assinar
          $st = "${{ steps.signtool.outputs.path }}"
          & $st sign /fd SHA256 /f $pfxPath /p $env:PFX_PASSWORD `
            /tr http://timestamp.digicert.com /td SHA256 /v $msix

          if ($LASTEXITCODE -ne 0) { throw "signtool falhou com codigo $LASTEXITCODE" }

          # Verificar
          & $st verify /pa /v $msix
          if ($LASTEXITCODE -ne 0) { throw "verificacao falhou" }

          # Limpar PFX
          Remove-Item $pfxPath -Force
          Write-Host "Assinatura concluida. PFX removido."
        shell: pwsh

      - name: Upload MSIX as artifact
        uses: actions/upload-artifact@v4
        with:
          name: msix-signed-${{ github.ref_name }}
          path: dist\*.msix

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          files: dist\*.msix
```

---

## Azure DevOps

### Configurar variaveis secretas

Em `Library > Variable Groups` ou diretamente nas variaveis do pipeline:
- `PFX_BASE64` (secret) — Base64 do .pfx
- `PFX_PASSWORD` (secret) — senha do .pfx

### Pipeline completo (azure-pipelines.yml)

```yaml
trigger:
  tags:
    include:
      - 'v*'

pool:
  vmImage: 'windows-latest'

variables:
  - group: 'codesigning-secrets'   # Library group com PFX_BASE64 e PFX_PASSWORD
  - name: BuildConfig
    value: Release
  - name: BuildPlatform
    value: Win64

stages:
  - stage: BuildAndSign
    displayName: 'Build e Assinatura'
    jobs:
      - job: BuildSignJob
        displayName: 'Build, Sign, Verify'
        steps:
          - checkout: self

          - task: PowerShell@2
            displayName: 'Build Release Win64'
            inputs:
              targetType: inline
              script: |
                dcc64.exe @dcc64.cfg GestorERP.dpr
              errorActionPreference: stop

          - task: PowerShell@2
            displayName: 'Sign MSIX'
            env:
              PFX_BASE64: $(PFX_BASE64)
              PFX_PASSWORD: $(PFX_PASSWORD)
            inputs:
              targetType: inline
              errorActionPreference: stop
              script: |
                # Localizar signtool
                $signtool = Get-ChildItem `
                  "C:\Program Files (x86)\Windows Kits\10\bin\*\x64\signtool.exe" |
                  Sort-Object FullName -Descending |
                  Select-Object -First 1 -ExpandProperty FullName

                Write-Host "signtool: $signtool"

                # Reconstituir PFX
                $pfxBytes = [Convert]::FromBase64String($env:PFX_BASE64)
                $pfxPath = Join-Path "$(Agent.TempDirectory)" "signing.pfx"
                [IO.File]::WriteAllBytes($pfxPath, $pfxBytes)

                # Localizar MSIX
                $msix = Get-ChildItem "$(Build.SourcesDirectory)\dist\*.msix" |
                  Select-Object -First 1 -ExpandProperty FullName

                # Assinar
                & $signtool sign /fd SHA256 /f $pfxPath /p $env:PFX_PASSWORD `
                  /tr http://timestamp.digicert.com /td SHA256 /v $msix

                if ($LASTEXITCODE -ne 0) {
                  throw "Assinatura falhou: codigo $LASTEXITCODE"
                }

                # Verificar
                & $signtool verify /pa /v $msix
                if ($LASTEXITCODE -ne 0) {
                  throw "Verificacao falhou: codigo $LASTEXITCODE"
                }

                # Limpar PFX imediatamente
                Remove-Item $pfxPath -Force
                Write-Host "PFX removido. Assinatura OK."

          - task: PublishBuildArtifacts@1
            displayName: 'Publicar MSIX assinado'
            inputs:
              PathtoPublish: '$(Build.SourcesDirectory)\dist'
              ArtifactName: 'msix-signed'
              publishLocation: 'Container'
```

---

## Boas praticas CI/CD

| Pratica | Motivo |
|---------|--------|
| Usar `Agent.TempDirectory` para o PFX | Pasta limpa e isolada, apagada apos o job |
| Remover PFX com `Remove-Item -Force` | Garantir que nao persiste no agente |
| Separar secrets por ambiente | DEV usa cert auto-assinado; PROD usa cert OV/EV |
| Fazer `verify` logo apos `sign` | Detectar falhas antes de publicar |
| Logar thumbprint e timestamp | Auditoria e rastreabilidade |
| Nunca imprimir `PFX_PASSWORD` em logs | Evitar vazamento mesmo em logs protegidos |

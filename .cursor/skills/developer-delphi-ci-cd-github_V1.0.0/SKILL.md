---
name: developer-delphi-ci-cd-github
description: >
  CI/CD para projetos Delphi no GitHub Actions: workflows YAML, compilação com
  dcc32/dcc64, FPC/Lazarus, execução de DUnitX em CI, versionamento automático,
  geração de release, upload de artefatos, self-hosted runners Windows,
  cache de dependências, secrets de ambiente. Ativar quando o usuário mencionar:
  CI/CD Delphi, GitHub Actions Delphi, workflow Delphi, pipeline Delphi,
  compilar Delphi automaticamente, dcc32 CI, dcc64 CI, FPC CI, DUnitX CI,
  self-hosted runner Delphi, release automático Delphi, versão automática Delphi,
  GitHub Actions YAML Delphi.
model: sonnet
thinking: none
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-ci-cd-github

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Criado** | 2026-04-24 |
| **Família** | DevOps / CI-CD |

## Responsabilidade única

Configurar pipelines de CI/CD para projetos Delphi no GitHub Actions usando
self-hosted runners Windows com RAD Studio ou FPC/Lazarus instalado.

## When to use

- Criar workflow GitHub Actions para compilar projeto Delphi
- Configurar self-hosted runner Windows com RAD Studio
- Rodar testes DUnitX automaticamente em PR/push
- Gerar release e upload de executável compilado
- Gerenciar versão do projeto automaticamente
- Cache de dependências no CI

## When NOT to use

- Outros CI (GitLab CI, Jenkins, Azure DevOps) — adaptar manualmente
- Testes DUnitX em si → `developer-delphi-testing-dunitx`

---

## §1 — Estrutura de workflows recomendada

```
.github/
  workflows/
    build.yml          ← compilação em PR e push para main
    release.yml        ← geração de release em tag v*.*.*
    tests.yml          ← execução de DUnitX (opcional — pode ser parte do build)
```

---

## §2 — Workflow de build (RAD Studio / dcc32 + dcc64)

```yaml
# .github/workflows/build.yml
name: Build Delphi

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: self-hosted   # runner Windows com RAD Studio instalado
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0   # necessário para versionamento por git tags

      - name: Build Win32
        run: |
          dcc32.exe ProvidersORM.dpr @dcc32.cfg
        shell: cmd

      - name: Build Win64
        run: |
          dcc64.exe ProvidersORM.dpr @dcc64.cfg
        shell: cmd

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: binaries-${{ github.run_number }}
          path: |
            Win32/Release/*.exe
            Win64/Release/*.exe
          retention-days: 30
```

---

## §3 — Workflow de build (FPC / Lazarus)

```yaml
# .github/workflows/build-fpc.yml
name: Build FPC/Lazarus

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: self-hosted   # runner Windows com FPC instalado

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Build Win32 (FPC)
        run: |
          D:\fpc\fpc\bin\i386-win32\fpc.exe @fpc32.opts ProvidersORM.lpr
        shell: cmd

      - name: Build Win64 (FPC)
        run: |
          D:\fpc\fpc\bin\x86_64-win64\fpc.exe @fpc64.opts ProvidersORM.lpr
        shell: cmd

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: fpc-binaries-${{ github.run_number }}
          path: "*.exe"
```

---

## §4 — Workflow de testes DUnitX

```yaml
# .github/workflows/tests.yml
name: DUnitX Tests

on:
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: self-hosted

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Build test project
        run: |
          dcc32.exe tests\ProvidersORMTests.dpr @dcc32.cfg
        shell: cmd

      - name: Run DUnitX tests
        run: |
          Win32\Release\ProvidersORMTests.exe --exit-behavior:exitcode
        shell: cmd
        # O executável retorna exit code != 0 se algum teste falhar
        # GitHub Actions marca o step como failed automaticamente

      - name: Upload test results (XML)
        if: always()   # executar mesmo se testes falharem
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: "*.xml"   # DUnitX gera XML quando configurado com TXMLTestListener
```

---

## §5 — Workflow de release automático

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*.*.*'   # disparado em tags como v1.2.3

jobs:
  release:
    runs-on: self-hosted

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Extrair versão da tag
        id: version
        run: |
          $TAG = "${{ github.ref_name }}"
          $VER = $TAG.TrimStart('v')
          echo "version=$VER" >> $env:GITHUB_OUTPUT
        shell: pwsh

      - name: Build Win32
        run: dcc32.exe ProvidersORM.dpr @dcc32.cfg
        shell: cmd

      - name: Build Win64
        run: dcc64.exe ProvidersORM.dpr @dcc64.cfg
        shell: cmd

      - name: Compactar artefatos
        run: |
          Compress-Archive -Path Win32\Release\ProvidersORM.exe `
            -DestinationPath "ProvidersORM-${{ steps.version.outputs.version }}-win32.zip"
          Compress-Archive -Path Win64\Release\ProvidersORM.exe `
            -DestinationPath "ProvidersORM-${{ steps.version.outputs.version }}-win64.zip"
        shell: pwsh

      - name: Criar GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ github.ref_name }}
          name: "Release ${{ steps.version.outputs.version }}"
          body: |
            ## O que mudou
            Ver [CHANGELOG.md](CHANGELOG.md) para detalhes.
          files: |
            *.zip
          draft: false
          prerelease: false
```

---

## §6 — Configuração do Self-Hosted Runner

```powershell
# No servidor Windows com RAD Studio instalado:

# 1. Criar diretório do runner
New-Item -ItemType Directory -Path C:\actions-runner
Set-Location C:\actions-runner

# 2. Baixar runner (versão mais recente em github.com/actions/runner/releases)
Invoke-WebRequest -Uri "https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-win-x64-2.317.0.zip" -OutFile runner.zip
Expand-Archive runner.zip -DestinationPath .

# 3. Configurar (token obtido em: Settings > Actions > Runners > New self-hosted runner)
.\config.cmd --url https://github.com/SEU_ORG/SEU_REPO --token SEU_TOKEN_AQUI

# 4. Instalar como serviço Windows (reinicia automaticamente)
.\svc.cmd install
.\svc.cmd start
```

### Adicionar dcc32/dcc64 ao PATH do runner

```powershell
# No servidor do runner — adicionar ao System PATH:
$RadPath = "C:\Program Files (x86)\Embarcadero\Studio\23.0\bin"
[Environment]::SetEnvironmentVariable("Path",
    [Environment]::GetEnvironmentVariable("Path", "Machine") + ";$RadPath",
    "Machine")
```

---

## §7 — Secrets e variáveis de ambiente no CI

```yaml
# No workflow, referenciar secrets configurados em Settings > Secrets
steps:
  - name: Configurar conexão de teste
    env:
      DB_HOST:     ${{ secrets.TEST_DB_HOST }}
      DB_DATABASE: ${{ secrets.TEST_DB_DATABASE }}
      DB_USER:     ${{ secrets.TEST_DB_USER }}
      DB_PASSWORD: ${{ secrets.TEST_DB_PASSWORD }}
    run: |
      # Os secrets ficam disponíveis como variáveis de ambiente
      # O executável de teste pode lê-los via GetEnvironmentVariable
      Win32\Release\ProvidersORMTests.exe
    shell: cmd
```

---

## §8 — Checklist de qualidade — CI/CD Delphi

- [ ] Self-hosted runner configurado como serviço Windows (reinicio automático)
- [ ] `dcc32.exe` e `dcc64.exe` no PATH do runner
- [ ] Secrets do banco de teste configurados em Settings > Secrets (nunca no YAML)
- [ ] Workflow de PR compila E roda testes antes do merge
- [ ] Release workflow disparado por tag `v*.*.*` com versionamento semântico
- [ ] Artefatos (`*.exe`) disponíveis para download por 30 dias no GitHub
- [ ] Exit code do executável DUnitX configura o status do step (0 = sucesso)
- [ ] `if: always()` nos steps de upload de resultados (garantir upload mesmo com falha)

## Referências cruzadas

- `developer-delphi-testing-dunitx` — configurar DUnitX com TXMLTestListener
- `developer-delphi-build-toolchain` — dcc32.cfg, dcc64.cfg, fpc.opts

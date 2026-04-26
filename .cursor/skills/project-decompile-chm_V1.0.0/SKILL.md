---
name: project-decompile-chm
description: >-
  Descompila ficheiros Microsoft Compiled HTML Help (.chm) para pastas de HTML legíveis por
  ferramentas de texto e por agentes. Entrada canónica multiplataforma: decompile_chm.py
  (Windows: hh.exe; Linux/macOS: 7-Zip ou extract_chmLib). PowerShell só Windows (hh.exe).
  Use quando o utilizador pedir descompilar CHM, extrair ajuda HTML do RAD Studio/Delphi,
  ler documentação .chm no Cursor, ou converter CHM para HTML em Windows/Linux/macOS.
  Gatilhos: descompilar chm, decompile chm, hh -decompile, 7z chm, ajuda compilada,
  Compiled HTML Help, extrair data.chm/fmx.chm/vcl.chm.
model: haiku
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# project-decompile-chm

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Orientar a descompilação de `.chm` (Microsoft HTML Help) para HTML de forma reprodutível **em Windows, Linux e macOS**, usando o script canónico `.cursor/scripts/decompile_chm.py` (backends: `hh`, `7z`, `chmlib`, ou `auto`). O `.cursor/scripts/decompile-chm.ps1` permanece como atalho **só Windows** (`hh.exe`). Não edita o conteúdo HTML resultante nem resolve links `ms-its:` para outros CHMs.

## Backends (`decompile_chm.py`)

| Backend | SO típico | Ferramenta | Notas |
|---------|-----------|------------|--------|
| **auto** | todos | Ordem: no Windows, `hh.exe` se existir; senão `7zz`/`7z`/`7za` (e `Program Files\7-Zip\7z.exe`); senão `extract_chmLib`. | Predefinição. |
| **hh** | Windows | `%SystemRoot%\hh.exe -decompile` | Resultado mais alinhado ao help oficial. |
| **7z** | Linux, macOS, Windows | CLI 7-Zip (`p7zip`, 7-Zip instalado) | Extrai o arquivo composto; estrutura pode diferir ligeiramente de `hh`. |
| **chmlib** | Linux (sobretudo) | `extract_chmLib` (pacote `chmlib-utils` ou equivalente) | Terceira opção em `auto` se 7z não estiver no PATH. |

Instalação rápida de dependências:

- **Linux (Debian/Ubuntu):** `sudo apt install p7zip-full` (e opcionalmente pacote com `extract_chmLib`).
- **macOS:** `brew install p7zip`
- **Windows:** `hh.exe` costuma existir; alternativa: [7-Zip](https://www.7-zip.org/) (o script procura `7z.exe` em Program Files).

## When to use

- Pedido explícito para descompilar, extrair ou converter `.chm` em qualquer SO suportado.
- Documentação RAD Studio / Delphi em HTML no repositório (após descompilação).
- Referência a `hh.exe`, `7z`, `extract_chmLib`, `-decompile`, ou pastas `*_chm_decompiled`.

## When NOT to use

- Leitura direta do binário `.chm` no editor — primeiro descompilar.
- Ambiente **sem** `hh` (Windows mínimo), **sem** 7-Zip no PATH e **sem** `extract_chmLib` — instalar uma das ferramentas ou passar `--seven-zip-exe`.

## Script canónico

| Artefacto | Caminho |
|-----------|---------|
| **Python (multiplataforma)** | `.cursor/scripts/decompile_chm.py` |
| **PowerShell (Windows, hh apenas)** | `.cursor/scripts/decompile-chm.ps1` |

## Comportamento predefinido (pastas)

- **Um ficheiro** (`--chm-path` / `-ChmPath`): saída = `{NomeSemExtensao}{suffix}` junto ao `.chm`, suffix predefinido `_chm_decompiled`.
- **Vários** (`--chm-directory` + `--filter`): cada `foo.chm` → `foo_chm_decompiled` na mesma pasta.

## Comandos (copiar e executar)

Auto (recomendado):

```bash
python ".cursor/scripts/decompile_chm.py" --chm-path "./Doc-Delphi/delphi13-data.chm"
```

Forçar 7-Zip (ex.: Linux/macOS ou CI):

```bash
python ".cursor/scripts/decompile_chm.py" --chm-path "./data.chm" --backend 7z
```

7-Zip em caminho custom:

```bash
python ".cursor/scripts/decompile_chm.py" --chm-path "./data.chm" --backend 7z --seven-zip-exe "/usr/bin/7zz"
```

Lote:

```bash
python ".cursor/scripts/decompile_chm.py" --chm-directory "./Doc-Delphi" --filter "delphi13-*.chm" --continue-on-error
```

PowerShell (só Windows):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".cursor/scripts/decompile-chm.ps1" -ChmPath "E:\GestorERP\Doc-Delphi\delphi13-data.chm"
```

Equivalente manual **hh** (Windows):

```text
C:\Windows\hh.exe -decompile "PastaSaida" "Caminho\Para\ficheiro.chm"
```

## Regras para o agente

1. Preferir **`decompile_chm.py`** em Linux/macOS e em fluxos multiplataforma; `decompile-chm.ps1` apenas quando o utilizador estiver em Windows PowerShell e quiser só `hh.exe`.
2. Se `auto` falhar por falta de ferramentas, indicar instalação de **p7zip** ou 7-Zip antes de desistir.
3. Após descompilar, apontar para os `.htm`/recursos na pasta de saída; avisar que **7z** vs **hh** pode alterar ligeiramente a árvore de ficheiros.
4. Links `ms-its:outro.chm::/...` continuam a referir outros CHMs; pode ser necessário descompilar esses ficheiros também.

## Limitações

- Não existe descompilação CHM “pura” estável só com stdlib Python; o script depende de **ferramentas externas** (hh, 7z ou chmlib).
- Pastas grandes e tempos de execução elevados; não renomear em massa `.htm` internos sem analisar links relativos.

## Referências cruzadas

| Recurso | Path |
|---------|------|
| Scripts | `.cursor/scripts/decompile_chm.py`, `.cursor/scripts/decompile-chm.ps1` |
| Documentação Delphi local (exemplo) | `Doc-Delphi/` (quando existir no projeto) |

## Changelog (este ficheiro)

- 1.0.2 (10/04/2026): Multiplataforma — backends `auto` / `hh` / `7z` / `chmlib` em `decompile_chm.py`.
- 1.0.1 (10/04/2026): Documentado `decompile_chm.py` (paridade com PowerShell).
- 1.0.0 (10/04/2026): Criação — skill + script `decompile-chm.ps1`.

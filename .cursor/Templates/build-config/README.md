# Templates de configuração de build — CLI Delphi/FPC

**Localização:** `.cursor/Templates/build-config/`

Templates para gerar os arquivos de configuração de compilação CLI na raiz do projeto.
Estes arquivos são **copiados** (não symlinked) pois contêm paths locais de ambiente.

---

## Templates disponíveis

| Template | Destino (raiz) | Descrição |
| -------- | -------------- | --------- |
| `dcc32.cfg.template` | `dcc32.cfg` | Delphi Win32 (dcc32.exe) |
| `dcc64.cfg.template` | `dcc64.cfg` | Delphi Win64 (dcc64.exe) |
| `fpc32.opts.template` | `fpc32.opts` | FPC i386-win32 |
| `fpc64.opts.template` | `fpc64.opts` | FPC x86_64-win64 |
| `{PROJECT_NAME}.dpr.template` | `{PROJECT_NAME}.dpr` | Fonte principal Delphi (VCL) |
| `{PROJECT_NAME}.dproj.template` | `{PROJECT_NAME}.dproj` | Projeto MSBuild Delphi (Win32+Win64, VCL) |
| `{PROJECT_NAME}.lpr.template` | `{PROJECT_NAME}.lpr` | Fonte principal FPC/Lazarus (LCL) |
| `{PROJECT_NAME}.lpi.template` | `{PROJECT_NAME}.lpi` | Projeto Lazarus (configuracoes e units) |
| `{PROJECT_NAME}.lps.template` | `{PROJECT_NAME}.lps` | Sessao Lazarus (estado da IDE — nao versionar) |

> O nome dos arquivos gerados corresponde ao `program` declarado no fonte:
> `program ProvidersORM;` → `ProvidersORM.dpr` / `ProvidersORM.dproj` / `ProvidersORM.lpr` / `ProvidersORM.lpi` / `ProvidersORM.lps`

### Arquivos binarios (.ico e .res)

- **`{PROJECT_NAME}.ico`** — ícone do executável. Não é gerado por template (arquivo binário).
  Copiar manualmente um `.ico` para a raiz e renomear para `{PROJECT_NAME}.ico`.
- **`{PROJECT_NAME}.res`** — recurso compilado. **Gerado automaticamente** pelo Lazarus/`lazbuild`
  a partir do `.ico` na primeira compilação. Não editar manualmente.

---

## Placeholders

| Placeholder | Descrição | Exemplo |
| ----------- | --------- | ------- |
| `{PROJECT_NAME}` | Nome do projeto (igual ao `program`) | `ProvidersORM` |
| `{PROJECT_DPR}` | Arquivo `.dpr` principal | `ProvidersORM.dpr` |
| `{PROJECT_GUID}` | GUID MSBuild do projeto (gerado automaticamente) | `{A1B2C3...}` |
| `{PROJECT_VERSION}` | Versão do formato do projeto Delphi | `20.3` |
| `{CONDITIONAL_DEFINES}` | Defines condicionais (separados por `;`) | `FRAMEWORK_VCL;USE_FIREDAC` |
| `{MAIN_FORM_UNIT}` | Unit do formulario principal (sem extensao) | `ufrm.Main` |
| `{MAIN_FORM_CLASS}` | Classe do formulario (sem o `T`) | `frmMain` |
| `{MAIN_FORM_INSTANCE}` | Nome da instancia do formulario | `frmMain` |
| `{REPO_ROOT}` | Caminho absoluto da raiz do repositorio | `E:\CSL\ProvidersORM` |
| `{STUDIO_VERSION}` | Versão do RAD Studio / Embarcadero | `23.0` |
| `{ZEOS_ROOT}` | Raiz da instalacao Zeos | `P:\PACOTE\zeosdbo` |
| `{DATASET_SERIALIZE_ROOT}` | Raiz do DataSet.Serialize | `P:\PACOTE\dataset-serialize` |
| `{SYNAPSE_ROOT}` | Raiz do Synapse (email/HTTP) | `P:\PACOTE\synapse` |
| `{UNIDAC_ROOT}` | Raiz do UniDAC (Devart) | `P:\PACOTE\Unidac` |
| `{FPC_ROOT}` | Raiz da instalacao FPC (`fpc/fpc/`) | `D:\fpc\fpc` |
| `{LAZARUS_ROOT}` | Raiz da instalacao Lazarus | `D:\fpc\lazarus` |
| `{FPC_OPM_ROOT}` | Raiz dos pacotes do OPM do Lazarus | `D:\fpc\config_lazarus\onlinepackagemanager\packages` |

---

## Como usar

### Automático (bootstrap)

O script `bootstrap-mirror-symlinks.ps1` (ou regra `project-autostart-bootstrap_V1.0.1.mdc`)
copia os templates para a raiz do projeto quando os arquivos ainda não existem,
substituindo os `{PLACEHOLDERS}` pelos valores do ambiente local.

Comando de geracao via PowerShell (executar na raiz do projeto):

```powershell
powershell -ExecutionPolicy Bypass -File ".cursor/scripts/bootstrap-build-config.ps1"
```

### Manual

1. Copiar o template para a raiz do projeto com o nome final (ex.: `dcc32.cfg`).
2. Substituir todos os `{PLACEHOLDER}` pelos valores reais do ambiente.
3. Verificar se os paths de dependências externas existem antes de compilar.

---

## Quando copiar vs quando usar symlink

- **Copiar:** arquivos de config de build (paths locais de compilador e dependências).
- **Symlink:** conteudo partilhado de `.cursor/` (rules, skills, agents, templates).

---

## Versão interna (ficheiro)

| Campo | Valor |
| ----- | ----- |
| **FileVersion** | 1.0.2 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.0.2 (31/03/2026): Adicionados templates FPC/Lazarus (.lpr, .lpi, .lps); nota sobre .ico e .res; placeholders adicionais documentados.
- 1.0.1 (31/03/2026): Adicionados templates .dpr e .dproj; separadores de tabela com espaços (MD060).
- 1.0.0 (31/03/2026): Criação — templates de configuração de build CLI (dcc32/dcc64/fpc32/fpc64).

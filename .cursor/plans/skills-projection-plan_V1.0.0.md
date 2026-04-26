# Plano de Projeção e Qualidade do Pack de Skills
**FileVersion:** 1.1.0 · **Data:** 24/04/2026 · **Status:** AGUARDANDO APROVAÇÃO

---

## Sumário executivo

Este plano foi gerado a partir de análise vetorial semântica (ChromaDB / `gen_vector_index.py`) sobre as **181 skills** do pack `.cursor/skills/`. A ferramenta calculou embeddings de 384 dimensões para cada skill usando o modelo `all-MiniLM-L6-v2` (ONNX, local) e executou:

- Busca de gaps por tema (similaridade máxima < 40% = gap confirmado)
- Detecção de duplicatas (pares com similaridade ≥ 80%)
- Distribuição por categoria/família

**Resultados brutos:**

| Métrica | Valor |
|---------|-------|
| Skills no pack | 181 |
| Skills sem `category` no frontmatter | 68 |
| Pares com 100% de similaridade | 38 |
| Pares com 80–99% de similaridade | 26 |
| Gaps confirmados (< 40%) | 3 temas |
| Cobertura parcial (40–65%) | 4 temas |

**Resultado esperado ao final:** ~188 skills, 0 duplicatas 100%, 68 categories corrigidas, 7 novas skills criadas.

---

## Impacto nas áreas protegidas

> **ATENÇÃO — ÁREA PROTEGIDA:** `.cursor/skills/` exige plano completo e aprovação explícita antes de qualquer criação, modificação ou remoção de arquivos (regra `documentation-migration-plan-mode_V1.0.0.mdc`).

| Fase | Área protegida tocada | Tipo de operação |
|------|-----------------------|-----------------|
| F1 | `.cursor/skills/` | Edição de SKILL.md existentes (frontmatter) |
| F2 | `.cursor/skills/` | Criação de novas pastas + SKILL.md |
| F3 | `.cursor/skills/` | Criação de novas pastas + SKILL.md |
| F4 | `.cursor/skills/` | Edição de SKILL.md existentes (descriptions) |
| F5 | `.cursor/scripts/`, `.cursor/skills/skills-pack-manifest_V1.17.0.md` | Edição de manifests |

---

## FASE 1 — Diagnóstico e correção de qualidade do índice

### Problema identificado

A varredura de duplicatas revelou **38 pares com 100% de similaridade** — todos na família `documentation-*`. Isso significa que o ChromaDB gerou vetores idênticos para essas skills, o que só ocorre quando o texto embedado é literalmente igual ou praticamente vazio. A causa provável é que esses SKILL.md têm os campos `name` e/ou `description` do frontmatter YAML idênticos ou não preenchidos, fazendo com que o documento construído para embedding seja o mesmo.

Além disso, **68 skills** não têm o campo `category` preenchido, o que impede filtragem por domínio e torna as estatísticas imprecisas.

### Skills afetadas pelos 100% de similaridade (9 da família documentation)

| Skill | Investigar |
|-------|-----------|
| `documentation-business-rules_V3.1.0` | frontmatter `description` |
| `documentation-class-analysis-generator_V1.1.0` | frontmatter `description` |
| `documentation-migration-backup_V1.1.0` | frontmatter `description` |
| `documentation-overview-architecture_V1.1.0` | frontmatter `description` |
| `documentation-project-structure_V1.0.0` | frontmatter `description` |
| `documentation-readme-hub_V1.1.0` | frontmatter `description` |
| `documentation-rules_creator_V1.1.0` | frontmatter `description` |
| `documentation-portal-html_V1.2.0` | frontmatter `description` |
| `documentation-project-expert_V1.0.0` | frontmatter `description` |
| `documentation-versioning-changelog_V1.1.0` | frontmatter `description` |

### Etapas detalhadas

**E1.1 — Inspecionar frontmatter das 10 skills documentation**

Para cada uma das 10 skills acima, ler o SKILL.md e verificar:
- O campo `description` está preenchido com texto específico (não genérico)?
- O campo `name` bate com o nome da pasta?
- O campo `category` está preenchido com `documentation`?

Critério de correção: a `description` deve descrever o que a skill faz de forma única e diferenciada das demais. Exemplo ruim: `"Skill de documentação"`. Exemplo bom: `"Gera documentação de regras de negócio a partir de código Pascal, extraindo pré/pós-condições e invariantes por classe"`.

**E1.2 — Listar e corrigir as 68 skills sem `category`**

Executar varredura automatizada com script auxiliar para listar todas as skills com `category: ""` ou `category` ausente. Para cada uma, determinar a categoria correta dentre as válidas:

```
documentation | project | developer-delphi | developer-web |
governance-spec | governance-process | governance-people |
governance-artifact | quality | version | developer-delphi-assembly
```

Estratégia: usar a família do nome da pasta como proxy (ex.: pasta `governance-*` → category `governance-process` ou subcategoria correspondente).

**E1.3 — Re-indexar e validar**

Após correções:
```
C:\Python\Python314\python.exe .cursor\scripts\gen_vector_index.py index
C:\Python\Python314\python.exe .cursor\scripts\gen_vector_index.py duplicates --threshold 85
C:\Python\Python314\python.exe .cursor\scripts\gen_vector_index.py stats
```

Critério de sucesso: zero pares com 100% de similaridade; categorias sem valor vazio.

### Entregáveis da Fase 1

- Frontmatter corrigido nos SKILL.md afetados
- Campo `category` preenchido nas 68 skills
- Banco vetorial re-indexado
- Print do `stats` confirmando distribuição correta

---

## FASE 2 — Criação de skills: gaps confirmados

Estes três temas têm similaridade máxima abaixo de 40% — o threshold de gap confirmado. Nenhuma skill existente cobre sequer tangencialmente esses domínios.

### E2.1 — `developer-delphi-indy-networking_V1.0.0`

**Gap medido:** 32.7% (melhor match: `developer-delphi-horse-client_V1.0.0`)

**Justificativa:** O pack cobre HTTP via Horse (servidor) e REST-DataWare, mas não cobre o protocolo de rede de baixo nível via Indy. São casos de uso completamente diferentes: Indy é usado para clientes HTTP (consumir APIs externas sem Horse), TCP raw, SMTP (envio de e-mail), FTP, SSH, e implementações de protocolo customizadas.

**Escopo da nova skill:**

| Componente | Conteúdo |
|-----------|---------|
| `TIdHTTP` | GET/POST/PUT com headers, autenticação Basic/Bearer, upload multipart |
| `TIdTCPServer` / `TIdTCPClient` | Servidor TCP assíncrono, framing de mensagens, OnExecute thread-safe |
| `TIdSMTP` + `TIdMessage` | Envio de e-mail com anexos, SSL/TLS, OAuth2 App Password |
| `TIdFTP` | Upload/download, listagem de diretório, modos ativo/passivo |
| SSL/TLS via Indy | `TIdSSLIOHandlerSocketOpenSSL`, versões TLS, `libeay32.dll` / `ssleay32.dll` |
| Tratamento de erros | `EIdException`, timeout (`ConnectTimeout`, `ReadTimeout`), reconexão automática |
| Compatibilidade | Delphi 23.0 + FPC (alternativa: `fphttpclient` para FPC) |

**Categoria:** `developer-delphi`
**Modelo sugerido:** `sonnet`
**Thinking:** `normal`
**Dependências de skills:** `developer-delphi-exception-handling_V*`

**Pasta destino:** `.cursor/skills/developer-delphi-indy-networking_V1.0.0/`

---

### E2.2 — `developer-delphi-cicd-pipeline_V1.0.0`

**Gap medido:** 29.3% (melhor match: `developer-web-packaging-deployment_V1.0.0`)

**Justificativa:** O pack tem skills de compilação CLI (`project-compile-database-docs`) e build manual, mas nada sobre automação em pipelines CI/CD para projetos Delphi/FPC. Com a migração do ecossistema para ProvidersORM/ActiveDirectoryORM como libs standalone, CI/CD se torna crítico.

**Escopo da nova skill:**

| Componente | Conteúdo |
|-----------|---------|
| GitHub Actions | Workflow `.yml` para Delphi (Windows runner + RAD Studio via `rsvars.bat`) |
| GitLab CI | `.gitlab-ci.yml` equivalente, runner Windows self-hosted |
| MSBuild / dcc32 CLI | Invocação headless, flags `-B` (rebuild), output para `Compiled/` |
| FPC CLI | `fpc.exe @fpc64.opts` em pipeline, verificação de erros via exit code |
| Versionamento automático | Bump de `FileVersion` em `.dproj` via script PowerShell/Python pré-build |
| Artefato de release | Zip do `.exe` + DLLs, upload para GitHub Releases / S3 |
| Matriz de build | Win32 + Win64 em paralelo, fail-fast, cache de DLLs |
| Secrets | `DELPHI_LICENSE`, variáveis de ambiente para `database.ini` em testes |

**Categoria:** `developer-delphi`
**Modelo sugerido:** `sonnet`
**Thinking:** `normal`
**Dependências de skills:** `project-compile-database-docs_V1.0.1`

**Pasta destino:** `.cursor/skills/developer-delphi-cicd-pipeline_V1.0.0/`

---

### E2.3 — `developer-delphi-cryptography-security_V1.0.0`

**Gap medido:** 34.2% (melhor match: `developer-delphi-horse-compression_V1.0.0`)

**Justificativa:** Segurança e criptografia estão presentes apenas de forma incidental em skills de compressão e HTTP. Não existe skill dedicada para hash, criptografia simétrica/assimétrica, armazenamento seguro de credenciais ou geração de tokens, todos cenários comuns em aplicações Delphi que acessam bancos de dados ou expõem APIs.

**Escopo da nova skill:**

| Componente | Conteúdo |
|-----------|---------|
| Hash | `THashSHA2` (256/512), `THashMD5`, `THashBobJenkins`; uso correto para integridade vs senha |
| Senhas | PBKDF2 via `THashSHA2` + salt aleatório; armazenamento em banco como `hash:salt` |
| Criptografia simétrica | AES-256-CBC via `DECCipher` (DelphiEncryptionCompendium); IV aleatório |
| Codificação | `TNetEncoding.Base64`, `TNetEncoding.URL`; diferença encode vs encrypt |
| JWT | Decode/validate de payload (sem lib externa, parse manual de Base64Url + verificação de `exp`) |
| TLS/HTTPS | Configuração de `TSSLSocketHandler` no lado cliente; pinning de certificado |
| Geração de tokens | UUID v4 via `TGUID.NewGuid`; CSPRNG com `TRandomizer` |
| Compatibilidade | Delphi 23.0; `{$IFDEF FPC}` com alternativas `SHA256` da RTL Free Pascal |

**Categoria:** `developer-delphi`
**Modelo sugerido:** `opus`
**Thinking:** `extended`
**Dependências de skills:** nenhuma obrigatória

**Pasta destino:** `.cursor/skills/developer-delphi-cryptography-security_V1.0.0/`

---

## FASE 3 — Criação de skills: cobertura parcial

Estes quatro temas têm similaridade entre 40–65% — existe algo tangencialmente relacionado no pack, mas sem skill dedicada, o assistente confunde o contexto.

### E3.1 — `developer-delphi-vcl-forms_V1.0.0`

**Gap medido:** 45.8% (melhor match: `developer-delphi-fmx-components_V1.0.0`)

**Justificativa crítica:** O pack tem 8 skills FMX detalhadas mas zero skills VCL. VCL é a framework de UI padrão para aplicações Windows desktop em Delphi, usada amplamente em GestorERP e aplicações legadas. FMX é cross-platform mas tem comportamento distinto. Sem uma skill VCL, o assistente aplica padrões FMX em contexto VCL e vice-versa.

**Escopo da nova skill:**

| Componente | Conteúdo |
|-----------|---------|
| Ciclo de vida de `TForm` | `OnCreate`, `OnShow`, `OnActivate`, `OnClose`/`OnCloseQuery`, ordem de eventos |
| Herança de formulários | `TBaseForm` → `TChildForm`, override de métodos virtuais, `inherited` |
| `TDataModule` | Criação, referência cruzada entre forms, DataModule como repositório de componentes de dados |
| Componentes essenciais | `TButton`, `TEdit`, `TLabel`, `TMemo`, `TComboBox`, `TListBox`, `TPageControl`, `TTabSheet` |
| Componentes de dados | `TDBGrid`, `TDBEdit`, `TDBComboBox`, `TDataSource` — binding com `TDataSet` |
| `TActionList` | Centralização de lógica em `TAction`, `OnExecute`, `OnUpdate`, desabilitação automática |
| Layout e resize | `Anchors`, `Align`, `Constraints`, `OnResize` — formulários responsivos |
| DPI awareness | `ScaleBy`, `PixelsPerInch`, `Scaled`, manifesto `dpiAware` — Windows 10/11 |
| Estilos VCL | `TStyleManager`, aplicação em runtime, compatibilidade com componentes de terceiros |
| Modal vs Modeless | `ShowModal` + `ModalResult`, `Show` + callbacks, hierarquia Owner |

**Categoria:** `developer-delphi`
**Modelo sugerido:** `sonnet`
**Thinking:** `normal`
**Dependências de skills:** nenhuma obrigatória

**Pasta destino:** `.cursor/skills/developer-delphi-vcl-forms_V1.0.0/`

---

### E3.2 — `developer-delphi-firedac_V1.0.0`

**Gap medido:** 46.7% (melhor match: `governance-artifact-dependency-map_V1.0.0` — resultado incongruente, confirma ausência total)

**Justificativa:** FireDAC é a camada de acesso a dados padrão do Delphi (substituiu dbExpress e BDE). O ProvidersORM abstrai FireDAC via `IConnection`, mas skills de uso direto são necessárias para debugging, configurações avançadas e cenários fora do ORM.

**Escopo da nova skill:**

| Componente | Conteúdo |
|-----------|---------|
| `TFDConnection` | `DriverID`, `Params`, `Connected`, `LoginPrompt := False`; strings de conexão por engine |
| `TFDQuery` | `SQL.Text`, `Params[]`, `Open`/`ExecSQL`, `FieldByName`, iteração com `Next` |
| `TFDTable` | `TableName`, filtros `Filter`/`Filtered`, `IndexFieldNames` para ordenação |
| Parâmetros tipados | `ParamByName('x').AsInteger`, `AsString`, `AsDateTime`, `AsVariant`; `ftBlob` |
| Transações explícitas | `StartTransaction`/`Commit`/`Rollback`; `TFDTransaction`; isolamento `ReadCommitted` |
| Batch updates | `CachedUpdates`, `ApplyUpdates`, `CancelUpdates`; resolução de conflitos |
| Macros FireDAC | `MacroByName`, substituição de nomes de tabela/schema em tempo de execução |
| Pool de conexões | `TFDManager`, `FDManager.AddConnectionDef`, reutilização de conexões |
| Multi-engine | SQL Server (`MSSQL`), MySQL (`MySQL`), SQLite (`SQLite`), Firebird (`FB`), PostgreSQL (`PG`) |
| Monitoramento | `TFDMonitorConsole`, log de SQL em debug, `TFDEventAlerter` |
| Compatibilidade FPC | Alternativa `sqldb` + `TSQLConnector` para Free Pascal; diferenças de API |

**Categoria:** `developer-delphi`
**Modelo sugerido:** `sonnet`
**Thinking:** `normal`
**Dependências de skills:** `developer-delphi-providers-orm-usage_V1.0.0` (contexto do ORM)

**Pasta destino:** `.cursor/skills/developer-delphi-firedac_V1.0.0/`

---

### E3.3 — `developer-delphi-json-serialization_V1.0.0`

**Gap medido:** 44.6% (melhor match: `developer-delphi-horse-serialization_V1.0.0` — cobre JSON no contexto Horse/HTTP, não JSON genérico)

**Justificativa:** Serialização JSON é necessária em qualquer troca de dados moderna. O pack tem `horse-serialization` (JSON em contexto HTTP) mas não cobre: manipulação direta de JSON, mapeamento RTTI automático, streaming de JSON grande, ou diferenças entre as várias APIs JSON do Delphi.

**Escopo da nova skill:**

| Componente | Conteúdo |
|-----------|---------|
| API nativa `System.JSON` | `TJSONObject`, `TJSONArray`, `TJSONString/Number/Bool/Null`; criação e parsing |
| Leitura segura | `.GetValue<T>`, tratamento de null, `TryGetValue`, `FindValue` com path `a.b.c` |
| Escrita fluente | Builder pattern com `AddPair`, `Add`; serialização de estruturas aninhadas |
| `TJsonSerializer` (Delphi 10.3+) | `Serialize<T>`/`Deserialize<T>` com RTTI; atributos `[JsonName]`, `[JsonIgnore]` |
| Streaming (`TJsonWriter`/`TJsonReader`) | Leitura incremental de JSONs grandes sem alocar árvore completa em memória |
| Records e arrays | Serialização de `TArray<T>`, records com campos aninhados, generics |
| Datas | `ISO 8601` via `TJSONHelper`, `TJSONDateConverter`; timezone |
| Compatibilidade FPC | `fpjson` + `jsonparser`; mapeamento `TJSONObject` FPC vs Delphi |
| Diferenças de bibliotecas | `System.JSON` vs `mORMot JSON` vs `SuperObject` — quando usar cada um |

**Categoria:** `developer-delphi`
**Modelo sugerido:** `sonnet`
**Thinking:** `normal`
**Dependências de skills:** nenhuma obrigatória

**Pasta destino:** `.cursor/skills/developer-delphi-json-serialization_V1.0.0/`

---

### E3.4 — `developer-delphi-reports-fastreport_V1.0.0`

**Gap medido:** 41.9% (melhor match: `documentation-project-scan_V1.1.0` — resultado sem relação, confirma ausência)

**Justificativa:** FastReport é o gerador de relatórios mais usado no ecossistema Delphi brasileiro. Aplicações ERP como GestorERP necessitam de relatórios, NF-e, boletos e dashboards. Sem skill dedicada, o assistente não sabe como integrar, configurar bandas ou exportar.

**Escopo da nova skill:**

| Componente | Conteúdo |
|-----------|---------|
| Arquitetura básica | `TfrxReport`, `TfrxDBDataset`, `TfrxBand` (Header/Detail/Footer/GroupHeader) |
| Data binding | Conectar `TDataSet` ao `TfrxDBDataset`; campos `[Table."Campo"]` no designer |
| Relatório master-detail | Dois `TfrxDBDataset` com `MasterDataset` + `MasterFields` |
| Subrelatórios | `TfrxSubreport`, passagem de parâmetros via `OnBeforePrint` |
| Scripts Pascal | Editor de scripts interno; `OnBeforePrint`, `OnAfterPrint`, variáveis de sessão |
| Parâmetros de relatório | `Report.Variables`, passagem via código: `Report.Variables['Filtro'].Value := ...` |
| Exportação | `TfrxPDFExport`, `TfrxXLSExport`, `TfrxHTMLExport`; export sem preview |
| Preview e impressão | `Report.ShowReport`, `Report.PrintReport`, configuração de impressora |
| NF-e / DANFE | Integração com ACBr via `TACBrNFe` + template FastReport do ACBr |
| Compatibilidade | FastReport VCL 6.x / Community Edition; Delphi 23.0 |

**Categoria:** `developer-delphi`
**Modelo sugerido:** `sonnet`
**Thinking:** `normal`
**Dependências de skills:** `developer-delphi-vcl-forms_V1.0.0` (E3.1, formulário host do relatório)

**Pasta destino:** `.cursor/skills/developer-delphi-reports-fastreport_V1.0.0/`

---

## FASE 4 — Resolução de redundâncias

### E4.1 — Família `documentation-project-templates` (86–87% de similaridade)

**Pares identificados:**

| Par | Similaridade |
|-----|-------------|
| `documentation-project-fundamentals-template_V1.1.0` × `documentation-project-structure-template_V1.1.0` | 87.0% |
| `documentation-project-examples-template_V1.1.0` × `documentation-project-fundamentals-template_V1.1.0` | 86.6% |
| `documentation-project-fundamentals-template_V1.1.0` × `documentation-project-roadmap-template_V1.1.0` | 86.5% |
| `documentation-project-roadmap-template_V1.1.0` × `documentation-project-structure-template_V1.1.0` | 85.4% |

**Ação:** Ler o conteúdo real dos 4 SKILL.md e avaliar se:
- Opção A: As descriptions são genéricas → diferenciar com texto específico ao tipo de template que cada uma gera
- Opção B: O conteúdo do SKILL.md é realmente idêntico → fusão em `documentation-project-templates-suite_V1.0.0` com seções internas por tipo

Decisão somente após leitura do conteúdo real. Não executar sem aprovação.

---

### E4.2 — Família `governance-team` (83–85% de similaridade)

**Pares identificados:**

| Par | Similaridade |
|-----|-------------|
| `governance-team-ai-human-workflow_V1.0.0` × `governance-team-raci-matrix_V1.0.0` | 85.0% |
| `governance-team-ai-human-workflow_V1.0.0` × `governance-team-onboarding_V1.0.0` | 83.4% |
| `governance-team-onboarding_V1.0.0` × `governance-team-raci-matrix_V1.0.0` | 81.0% |

**Ação:** Provavelmente problema de description genérica ("gestão de equipe"). Revisar e diferenciar:
- `ai-human-workflow` → descrever fluxo de aprovação humano/AI, checkpoints de revisão
- `raci-matrix` → descrever geração de tabelas RACI para processos específicos
- `onboarding` → descrever checklist de integração de novo membro

---

### E4.3 — Família `developer-delphi-active-directory` (82–84% de similaridade)

**Pares identificados:**

| Par | Similaridade |
|-----|-------------|
| `developer-delphi-active-directory-orchestrator_V1.0.0` × `developer-delphi-active-directory-roteiro_V1.0.0` | 84.3% |
| `developer-delphi-active-directory-expert_V1.0.0` × `developer-delphi-active-directory-roteiro_V1.0.0` | 82.9% |
| `developer-delphi-active-directory-expert_V1.0.0` × `developer-delphi-active-directory-orchestrator_V1.0.0` | 81.9% |

**Ação:** Investigar se `expert`, `orchestrator` e `roteiro` têm realmente escopos distintos:
- `expert` → conhecimento técnico profundo de LDAP/AD
- `orchestrator` → coordena múltiplas skills AD em fluxo maior
- `roteiro` → passo-a-passo de implementação

Se os escopos se confirmarem distintos → apenas diferenciar descriptions. Se o conteúdo se sobrepuser → considerar fusão mantendo só `expert` + `orchestrator`.

---

## FASE 5 — Atualização da infraestrutura do pack

### E5.1 — Registrar `gen_vector_index.py` no scripts-pack-manifest

**Arquivo:** `.cursor/scripts/scripts-pack-manifest_V*.md` (localizar versão atual)

Adicionar entrada:

```
| `gen_vector_index.py` | 1.0.0 | 24/04/2026 | Indexador vetorial semântico — ChromaDB/ONNX; modos: index, query, duplicates, gaps, stats |
```

### E5.2 — Bump do `skills-pack-manifest_V1.17.0.md`

Após conclusão das Fases 2 e 3, bump para `V1.18.0`:
- Delta: +7 skills novas (3 gaps + 4 cobertura parcial)
- Changelog: listar cada nova skill com justificativa de criação
- Atualizar contagem total de `181` para `188`

### E5.3 — Re-indexação final do banco vetorial

```powershell
C:\Python\Python314\python.exe .cursor\scripts\gen_vector_index.py index
C:\Python\Python314\python.exe .cursor\scripts\gen_vector_index.py stats
```

Verificar que as 7 novas skills aparecem no índice e têm categoria correta.

---

## Sequência de execução recomendada

```
F1 (diagnóstico/correção) → re-index → validar
    ↓
F4 (redundâncias) → ajuste descriptions → re-index
    ↓
F2.1 (Indy) → F2.2 (CI/CD) → F2.3 (Criptografia)
    ↓
F3.1 (VCL) → F3.4 (FastReport, depende de VCL)
F3.2 (FireDAC) → F3.3 (JSON) [paralelo]
    ↓
F5 (manifests + re-index final)
```

**Justificativa da ordem:** F1 deve vir primeiro para garantir que o índice vetorial esteja correto antes de criar skills (evita criar duplicatas que passariam despercebidas). F4 é feita antes das criações para liberar "espaço semântico" na família documentation/governance. F3.4 depende de E3.1 porque `developer-delphi-reports-fastreport` referencia a skill de VCL Forms.

---

## Inventário de arquivos a criar/modificar

### Criações (requer aprovação)

| Arquivo | Operação | Fase |
|---------|----------|------|
| `.cursor/skills/developer-delphi-indy-networking_V1.0.0/SKILL.md` | CRIAR | F2.1 |
| `.cursor/skills/developer-delphi-cicd-pipeline_V1.0.0/SKILL.md` | CRIAR | F2.2 |
| `.cursor/skills/developer-delphi-cryptography-security_V1.0.0/SKILL.md` | CRIAR | F2.3 |
| `.cursor/skills/developer-delphi-vcl-forms_V1.0.0/SKILL.md` | CRIAR | F3.1 |
| `.cursor/skills/developer-delphi-firedac_V1.0.0/SKILL.md` | CRIAR | F3.2 |
| `.cursor/skills/developer-delphi-json-serialization_V1.0.0/SKILL.md` | CRIAR | F3.3 |
| `.cursor/skills/developer-delphi-reports-fastreport_V1.0.0/SKILL.md` | CRIAR | F3.4 |

### Modificações (requer aprovação)

| Arquivo | Operação | Fase |
|---------|----------|------|
| Até 10 SKILL.md de `documentation-*` (duplicatas 100%) | EDITAR frontmatter | F1.1 |
| Até 68 SKILL.md sem `category` | EDITAR frontmatter | F1.2 |
| Até 4 SKILL.md de `documentation-project-templates-*` | EDITAR description | F4.1 |
| 3 SKILL.md de `governance-team-*` | EDITAR description | F4.2 |
| 3 SKILL.md de `developer-delphi-active-directory-*` | EDITAR description | F4.3 |
| `.cursor/scripts/scripts-pack-manifest_V*.md` | EDITAR tabela de scripts | F5.1 |
| `.cursor/skills/skills-pack-manifest_V1.17.0.md` | BUMP + changelog | F5.2 |

---

## Estratégia de backup

Antes de modificar qualquer SKILL.md existente (Fases 1 e 4):

1. Registrar o conteúdo atual no changelog interno do próprio SKILL.md (seção `## Changelog`)
2. O controle de versão Git funciona como backup implícito — commit antes de iniciar cada fase
3. Nenhum arquivo é excluído — apenas editado (descriptions/frontmatter)

---

## Critérios de sucesso globais

| Critério | Como medir |
|---------|-----------|
| Zero pares com 100% de similaridade | `gen_vector_index.py duplicates --threshold 99` retorna 0 pares |
| Todas as skills com `category` preenchida | `gen_vector_index.py stats` mostra `0` na linha de categoria vazia |
| 7 novas skills criadas | `gen_vector_index.py stats` mostra total = 188 |
| Gaps F2 cobertos | `gaps "Indy networking"`, `gaps "CI/CD pipeline"`, `gaps "criptografia"` retornam > 65% |
| Pack manifest atualizado | `skills-pack-manifest` em V1.18.0 com changelog completo |

---

## Referências

- Script de análise: `.cursor/scripts/gen_vector_index.py`
- Banco vetorial: `.cursor/vector.db/`
- Template de skills: `.cursor/Templates/SKILL_TEMPLATE_V2.0.md`
- Regra de áreas protegidas: `.cursor/rules/documentation-migration-plan-mode_V1.0.0.mdc`
- Manifesto atual: `.cursor/skills/skills-pack-manifest_V1.17.0.md`

---

---

## FASE 6 — Integração de `E:\.docs` (Documentação oficial RAD Studio 12/13)

### Diagnóstico da pasta

| Item | Valor |
|------|-------|
| Caminho | `E:\.docs\` |
| Subpastas | `Assembly/` (vazia), `Delphi/12/`, `Delphi/13/` |
| Delphi 12 (RAD Studio 23) | **152.668 arquivos** — `.htm` (144.108), `.png` (8.178), `.jpg`, `.gif` |
| Delphi 13 (RAD Studio 24) | **155.586 arquivos** — `.htm` (146.713), `.png` (8.494), `.jpg`, `.gif` |
| Subpastas por versão | `codeexamples/`, `data/`, `fmx/`, `libraries/`, `system/`, `topics/`, `vcl/` |
| `index.db` | Schema criado (`artefacts` + FTS5), mas **0 registros** — nunca foi populado |
| `Assembly/` | Diretório existe mas está **vazio** (0 arquivos) |

**Implicação crítica:** a skill `project-query-docs-index_V1.0.0` (criada em 18/04/2026) aponta para `E:\.docs\index.db` como fonte de busca offline, mas o banco tem 0 registros. Toda consulta a essa skill retorna vazio. **A skill está funcional mas sem dados.**

As .htm do Delphi 12/13 são a **documentação oficial completa do RAD Studio** — cada `.htm` é a página de um componente, propriedade, evento ou método. Exemplos de nomes encontrados: `ActiveControl_(Delphi).htm`, `TFDConnection_(Delphi).htm`, `TForm_(Delphi).htm`, `ADOQuery_(Delphi).htm`. É a referência mais autoritativa disponível localmente.

### Etapas

**E6.1 — Popular `E:\.docs\index.db` com as HTMs do Delphi 12 e 13**

O banco já tem o schema correto (`artefacts` + FTS5). Falta o script de ingestão das HTMs. A abordagem é:

1. Para cada `.htm` nas subpastas `vcl/`, `fmx/`, `system/`, `libraries/`, `topics/`:
   - Extrair título da tag `<title>` (nome do componente/propriedade)
   - Extrair texto plano do `<body>` (remover tags HTML)
   - Limitar snippet a 4 KB (padrão do `_build_index.py`)
   - Inferir `scope` pelo path: `Delphi/12` → `delphi12`, `Delphi/13` → `delphi13`
   - Inferir `category` pela subpasta: `vcl` → `vcl`, `fmx` → `fmx`, `system` → `rtl`, etc.

2. Criar script `E:\SkillsORM\.cursor\scripts\index_delphi_docs.py` (separado do `gen_vector_index.py` — foco em texto, não vetores).

3. Executar e confirmar com `SELECT count(*) FROM artefacts` → esperado: ~290k registros (ambas as versões).

**E6.2 — Estender `gen_vector_index.py` com coleção `delphi-docs`**

Após E6.1, criar uma segunda coleção ChromaDB `delphi-docs` indexando as HTMs mais relevantes (seleção por subpasta e tamanho mínimo para evitar páginas stub):

- Escopo inicial: apenas `vcl/` + `fmx/` + `system/` das versões 12 e 13 (estimativa: ~50k páginas úteis)
- Estratégia de seleção: páginas com `<body>` > 2 KB (descartar stubs e redirecionamentos)
- Novo modo CLI: `gen_vector_index.py index-docs` — indexa apenas a coleção `delphi-docs`
- Novo modo CLI: `gen_vector_index.py query-docs "TFDConnection pool"` — busca cruzada skills + docs

**E6.3 — Criar skill `developer-delphi-docs-oficial-query_V1.0.0`**

Skill dedicada para consultar a documentação offline do RAD Studio 12/13 via FTS5. Substitui/complementa `project-query-docs-index` especificamente para documentação Delphi.

| Campo frontmatter | Valor |
|-------------------|-------|
| `name` | `developer-delphi-docs-oficial-query` |
| `description` | Busca offline na documentação HTML oficial do RAD Studio 12/13 (152k + 155k páginas). Retorna definição, assinatura, parâmetros e exemplos de qualquer componente, propriedade, evento ou método Delphi. |
| `category` | `developer-delphi` |
| `model` | `sonnet` |
| `thinking` | `minimal` |

Dependência: `E:\.docs\index.db` populado (E6.1).

**Nota sobre `Assembly/`:** a pasta está vazia. Se houver intenção de popular com os 53 MDs mencionados no histórico (`E:\.docs\Assembly/`), isso deve ser feito manualmente antes de executar E6.1. O script de ingestão já contemplará essa subpasta se os arquivos estiverem lá.

---

## FASE 7 — Integração de `E:\.Biblioteca` (Biblioteca técnica)

### Diagnóstico da pasta

| Item | Valor |
|------|-------|
| Caminho | `E:\.Biblioteca\` |
| `index.db` | **2.222 registros** indexados, FTS5 funcional |
| `library/` | **1.960 arquivos** — 1.819 PDFs técnicos |
| `Documentação não classificadas/` | **331 arquivos** — 147 MDs, subpastas: `CRM/`, `IA/`, `pdfs/` |
| `_build_index.py` | Script de ingestão já existe e funcional |

**Categorias já indexadas no `index.db`:**

| Categoria | Docs |
|-----------|------|
| `01-Arquitetura_de_Computadores` | 558 |
| `03-Linguagens_de_Programacao` | 527 |
| `02-Sistemas_Operacionais` | 167 |
| `08-Inteligencia_Artificial` | 134 |
| `04-Algoritmos_e_Estruturas_de_Dados` | 195 |
| `05-Banco_de_Dados` | 67 |
| `06-Redes_e_Distribuidos` | 42 |
| `09-Matematica_e_Teoria` | 47 |
| `07-Seguranca_e_Engenharia_Reversa` | 19 |
| `10-Ferramentas_e_Guias` | 43 |
| `11-Documentos_Diversos` | 66 |
| `Documentação não classificadas` | 356 |

**Conteúdo notável em `library/`:**
- `Inside IO Completion Ports` — deep dive Windows async I/O
- `Microsoft Windows NT Server 4.0 versus UNIX` — comparativo OS
- `Windows Exceptions - MSDN Journal` — exceções Win32
- `Windows Kernel Development Articles (2016-03-30)` — internals do kernel
- `x86asm.net` — referência completa de opcodes x86/x64
- 1.819 PDFs técnicos adicionais (Arquitetura, SO, Algoritmos, BD, Redes, IA)

**Conteúdo notável em `Documentação não classificadas/IA/`:**
- `agent-skills source code/agent-skills-main/` — repositório público de skills externas (React, deploy-to-vercel, web-design-guidelines, composition-patterns, react-native-skills). Útil como **referência de padrões** de skill writing para comparar com o pack SkillsORM.

### Etapas

**E7.1 — Criar skill `developer-biblioteca-query_V1.0.0`**

O `index.db` da Biblioteca já está populado e funcional. A skill envolve apenas documentar como consultá-lo:

| Campo frontmatter | Valor |
|-------------------|-------|
| `name` | `developer-biblioteca-query` |
| `description` | Busca FTS5 na biblioteca técnica local (E:\.Biblioteca — 2.222 documentos: PDFs de Assembly, OS, Kernel, Algoritmos, IA, Segurança). Retorna path, categoria e snippet para localizar documentação de referência em português e inglês. |
| `category` | `project` |
| `model` | `haiku` |
| `thinking` | `minimal` |

Workflow da skill: usar `sqlite3` com FTS5 MATCH contra `E:\.Biblioteca\index.db`, filtrar por `category` opcional, retornar `path_rel`, `name`, `category`, `snippet`.

**E7.2 — Investigar skills externas como referência de padrão**

A pasta `E:\.Biblioteca\Documentação não classificadas\IA\agent-skills source code\agent-skills-main\skills\` contém 5 skills externas:
- `composition-patterns/`
- `deploy-to-vercel/`
- `react-best-practices/`
- `react-native-skills/`
- `web-design-guidelines/`

Ação: ler os arquivos de regras (subpasta `rules/`) dessas skills para comparar estrutura, completude e padrões de escrita com o template V2.0 do pack. Identificar boas práticas ausentes no `SKILL_TEMPLATE_V2.0.md`.

**E7.3 — Cross-reference PDFs de Assembly com skills `developer-delphi-assembly-*`**

O pack tem 7 skills de Assembly (`developer-delphi-assembly-*`). A biblioteca tem:
- `x86asm.net` — referência de opcodes
- `Windows Kernel Development Articles` — uso de Assembly em kernel mode
- `Windows Exceptions` — estrutura de exceções SEH (relevante para Assembly + Delphi)

Ação: para cada skill `developer-delphi-assembly-*`, verificar se a seção `## Referências` aponta para os materiais disponíveis localmente em `E:\.Biblioteca`. Se não, adicionar referências.

**E7.4 — Verificar se `_build_index.py` precisa ser re-executado**

Os 356 documentos em `Documentação não classificadas` estão indexados mas sem `category` adequada (categoria literal = `'Documentação não classificadas'`). Avaliar se vale executar `_build_index.py --full` após classificar manualmente ou criar regras de auto-classificação por subpasta.

---

## Sequência de execução atualizada (todas as fases)

```
F1 (corrigir frontmatter 68 skills) → re-index vetorial
    ↓
F4 (redundâncias descriptions) → re-index vetorial
    ↓
F2.1 (Indy) → F2.2 (CI/CD) → F2.3 (Criptografia)
    ↓
F3.1 (VCL Forms) → F3.4 (FastReport)     ← F3.4 depende de F3.1
F3.2 (FireDAC)   → F3.3 (JSON)           ← paralelo
    ↓
F6.1 (popular index.db Delphi docs) → F6.2 (coleção vetorial delphi-docs) → F6.3 (skill query-docs)
    ↓
F7.1 (skill biblioteca-query) → F7.2 (análise skills externas) → F7.3 (cross-ref Assembly)
    ↓
F5 (bump manifests + re-indexação final)
```

**Justificativa:** F6 e F7 ficam após as criações de skills (F2/F3) porque as skills novas podem referenciar materiais da biblioteca/docs. F5 fecha tudo.

---

## Inventário de arquivos atualizado

### Criações adicionais (Fases 6 e 7)

| Arquivo | Operação | Fase |
|---------|----------|------|
| `.cursor/scripts/index_delphi_docs.py` | CRIAR | F6.1 |
| `.cursor/skills/developer-delphi-docs-oficial-query_V1.0.0/SKILL.md` | CRIAR | F6.3 |
| `.cursor/skills/developer-biblioteca-query_V1.0.0/SKILL.md` | CRIAR | F7.1 |

### Fontes de dados externas (leitura, sem modificação)

| Pasta | Descrição | Status |
|-------|-----------|--------|
| `E:\.docs\Delphi\12\` | Documentação HTML RAD Studio 23 — 152.668 arquivos .htm | Disponível, não indexado |
| `E:\.docs\Delphi\13\` | Documentação HTML RAD Studio 24 — 155.586 arquivos .htm | Disponível, não indexado |
| `E:\.docs\index.db` | Banco FTS5 para docs Delphi — schema OK, 0 registros | Precisa ser populado (E6.1) |
| `E:\.Biblioteca\index.db` | Banco FTS5 biblioteca técnica — 2.222 registros, FTS funcional | Pronto para uso |
| `E:\.Biblioteca\library\` | 1.819 PDFs técnicos (Assembly, Kernel, x86asm, Algoritmos) | Disponível |
| `E:\.Biblioteca\Documentação não classificadas\IA\agent-skills source code\` | Skills externas React/web (referência) | Disponível |

---

## Sumário executivo atualizado

| Fase | Ação | Entregável | Depende de |
|------|------|-----------|------------|
| F1 | Corrigir frontmatter (category + description) | 68 SKILL.md corrigidos | — |
| F2 | 3 skills gaps confirmados | +3 novas skills | F1 |
| F3 | 4 skills cobertura parcial | +4 novas skills | F1, F3.1→F3.4 |
| F4 | Revisão redundâncias | 8–10 SKILL.md com descriptions melhoradas | F1 |
| F5 | Atualizar manifests + re-index | skills-pack-manifest V1.18.0 | F2, F3 |
| F6 | Integrar docs RAD Studio 12/13 | index.db populado + skill query | F5 |
| F7 | Integrar Biblioteca técnica | skill biblioteca-query + cross-refs Assembly | F6 |

**Total de skills ao final:** ~190 skills (181 atual + 7 novas F2/F3 + 2 novas F6/F7).

---

## Changelog (este arquivo)

- 1.1.0 (24/04/2026): Adicionadas Fases 6 e 7 — integração de `E:\.docs` (docs HTML RAD Studio 12/13: 308k arquivos .htm, index.db vazio a popular) e `E:\.Biblioteca` (2.222 docs indexados em FTS5, 1.819 PDFs, skills externas como referência). Inventário e sequência atualizados. Total esperado: ~190 skills.
- 1.0.0 (24/04/2026): Versão inicial. Gerado a partir de análise vetorial sobre 181 skills com ChromaDB/ONNX (all-MiniLM-L6-v2, 384 dim). 38 duplicatas 100% detectadas, 3 gaps confirmados, 4 temas com cobertura parcial, 68 frontmatters sem category.

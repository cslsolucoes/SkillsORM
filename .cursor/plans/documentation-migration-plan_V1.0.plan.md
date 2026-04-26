# Plano de Migração Documental — {PROJECT_NAME}

**Versão:** 1.0
**Data:** DD/MM/AAAA
**Projecto:** {PROJECT_NAME}
**Caminho fonte:** {SRC_PATH} (ex.: `src/`)
**Pasta documental:** `Documentation/`

> **REGRA OBRIGATÓRIA:** Antes de executar qualquer etapa deste plano, o agente
> **DEVE entrar em plan mode** (verificar, revisar e confirmar o plano com o
> utilizador). Execução directa sem plan mode é **proibida**.

---

## Índice

| # | Secção | Descrição |
|---|--------|-----------|
| 1 | [Pré-requisitos](#1-pré-requisitos) | Backup, reset, condições iniciais |
| 2 | [Fase de Descoberta](#2-fase-de-descoberta) | Scan de `{SRC_PATH}` e `Documentation/` |
| 3 | [Análise de Lacunas](#3-análise-de-lacunas) | O que existe vs. o que deveria existir |
| 4 | [Checklist de Migração por Módulo](#4-checklist-de-migração-por-módulo) | Analise/, Regras de Negocio/, Arquitetura/ |
| 5 | [Bootstrap da Estrutura Documentation/](#5-bootstrap-da-estrutura-documentation) | 13 subpastas obrigatórias |
| 6 | [Checklist de Validação](#6-checklist-de-validação) | Verificação cruzada código vs. docs |
| 7 | [Verificação Pós-Migração](#7-verificação-pós-migração) | Testes finais e aceite |
| 8 | [Propagação para Outros Projectos](#8-propagação-para-outros-projectos) | Replicar o plano |

---

<a id="1-pré-requisitos"></a>

## 1. Pré-requisitos

### 1.1 Backup obrigatório

- [ ] Criar backup completo da pasta `Documentation/` actual:
  ```
  Documentation/ -> backup/documentation_pre_migration_YYYYMMDD/
  ```
- [ ] Registar hash/data do backup no changelog deste plano.
- [ ] Confirmar que o backup está legível e completo.

### 1.2 Condições iniciais

- [ ] Verificar que `{SRC_PATH}` existe e contém código-fonte.
- [ ] Verificar existência de entrypoint de build (`{PROJECT_NAME}.dpr` ou `{PROJECT_NAME}.lpr`).
- [ ] Confirmar acesso aos templates em `.cursor/Templates/`.
- [ ] Garantir que `.cursor/rules/`, `.cursor/skills/` e `.cursor/agents/` estão operacionais.

### 1.3 Reset de estado (se necessário)

- [ ] Arquivar documentos obsoletos para `Documentation/Backup/ciclo_anterior/`.
- [ ] Limpar ficheiros duplicados ou órfãos identificados em ciclos anteriores.
- [ ] Actualizar `Documentation/README.md` (hub) para reflectir o estado pré-migração.

---

<a id="2-fase-de-descoberta"></a>

## 2. Fase de Descoberta

### 2.1 Scan de `{SRC_PATH}` — Inventário de módulos reais

Executar scan recursivo de `{SRC_PATH}` para identificar todos os módulos, subpastas e units.

**Comando sugerido (PowerShell):**
```powershell
Get-ChildItem -Path "{SRC_PATH}" -Directory -Recurse | Select-Object FullName
```

**Resultado esperado — preencher tabela:**

| # | Módulo | Caminho em `{SRC_PATH}` | Units (.pas) | Observação |
|---|--------|-------------------------|--------------|------------|
| M01 | {MODULE_NAME_01} | {SRC_PATH}/{path} | {N} units | |
| M02 | {MODULE_NAME_02} | {SRC_PATH}/{path} | {N} units | |
| ... | ... | ... | ... | |

> **{MODULE_LIST}** — Lista completa de módulos descobertos. Preencher após scan.

### 2.2 Scan de `Documentation/` — Documentos existentes

Executar scan recursivo de `Documentation/` para identificar toda a documentação actual.

**Comando sugerido:**
```powershell
Get-ChildItem -Path "Documentation" -Recurse -File -Filter "*.md" | Select-Object FullName
```

**Resultado esperado — preencher tabela:**

| Subpasta | Ficheiros encontrados | Formato | Versão |
|----------|-----------------------|---------|--------|
| Analise/ | {lista} | .md | Vx.y |
| Analise/{Domain}/ | {lista} | .md | Vx.y |
| Regras de Negocio/ | {lista} | .md | Vx.y |
| Regras de Negocio/RN-M{xx}/ | {lista} | .md | Vx.y |
| Arquitetura/ | {lista} | .md | Vx.y |
| {outra subpasta}/ | {lista} | .md | Vx.y |

### 2.3 Extracção do entrypoint de build

- [ ] Extrair lista de `uses` de `{PROJECT_NAME}.dpr` (ou `.lpr`).
- [ ] Cruzar units listadas no `uses` com ficheiros físicos em `{SRC_PATH}`.
- [ ] Identificar units no `uses` sem ficheiro correspondente (erro de build).
- [ ] Identificar ficheiros em `{SRC_PATH}` não listados no `uses` (units órfãs).

---

<a id="3-análise-de-lacunas"></a>

## 3. Análise de Lacunas (Gap Analysis)

### 3.1 Matriz de cobertura: Módulos vs. Documentação

Para cada módulo identificado na Fase 2.1, verificar:

| Módulo | `Analise/{Domain}/` | `Regras de Negocio/RN-M{xx}/` | `Arquitetura/` | Status |
|--------|---------------------|-------------------------------|----------------|--------|
| {MODULE_NAME_01} | [ ] Existe / [ ] Falta | [ ] Existe / [ ] Falta | [ ] Referido / [ ] Falta | {Completo / Parcial / Ausente} |
| {MODULE_NAME_02} | [ ] Existe / [ ] Falta | [ ] Existe / [ ] Falta | [ ] Referido / [ ] Falta | {Completo / Parcial / Ausente} |
| ... | ... | ... | ... | ... |

**Legenda de status:**
- **Completo:** Analise + RN + Arquitetura presentes e actualizados.
- **Parcial:** Pelo menos uma das três áreas documentada.
- **Ausente:** Nenhuma documentação encontrada para o módulo.

### 3.2 Lacunas críticas

| ID | Tipo | Módulo | Descrição da lacuna | Prioridade |
|----|------|--------|---------------------|------------|
| GAP-01 | {Analise / RN / Arq} | {módulo} | {descrição} | Alta / Média / Baixa |
| GAP-02 | ... | ... | ... | ... |

### 3.3 Documentos órfãos (existem em Documentation/ mas sem módulo correspondente em src/)

| Ficheiro | Caminho | Acção recomendada |
|----------|---------|-------------------|
| {ficheiro} | Documentation/{path} | Arquivar / Eliminar / Manter |

### 3.4 Resumo executivo de lacunas

```
Total de módulos em {SRC_PATH}: ___
Módulos com documentação completa: ___
Módulos com documentação parcial: ___
Módulos sem documentação: ___
Documentos órfãos: ___
```

---

<a id="4-checklist-de-migração-por-módulo"></a>

## 4. Checklist de Migração por Módulo

> Repetir esta secção para **cada módulo** listado em `{MODULE_LIST}`.
> Utilizar os templates de `.cursor/Templates/` como base.

### 4.x — Módulo: {MODULE_NAME} (M{xx})

**Caminho fonte:** `{SRC_PATH}/{module_path}/`
**Units:** {lista de .pas}

#### 4.x.1 Analise/

- [ ] Verificar existência de `Documentation/Analise/{Domain}/`
- [ ] Se ausente, criar pasta `Documentation/Analise/{Domain}/`
- [ ] Criar ou actualizar `README.md` do domínio (template: `TEMPLATE_Docs_Analise.md`)
- [ ] Para cada classe/tipo relevante, verificar `{ClassName}.md`
  - [ ] Se ausente, gerar scaffold com template `TEMPLATE_Unit_ClassName.md` ou `TEMPLATE_ClassName_Full_Documentation.md`
  - [ ] Se existente, validar que reflecte o código actual
- [ ] Verificar inventário vs. `uses` do entrypoint (Cap. 4 do diagnóstico)
- [ ] Actualizar `ANALISE_DIAGNOSTICO_ORGANIZACAO.md` se existir (template: `TEMPLATE_ANALISE_DIAGNOSTICO_ORGANIZACAO.md`)

#### 4.x.2 Regras de Negocio/

- [ ] Verificar existência de `Documentation/Regras de Negocio/RN-M{xx}/`
- [ ] Se ausente, criar pasta `Documentation/Regras de Negocio/RN-M{xx}/`
- [ ] Criar `README.md` do módulo RN com índice das regras
- [ ] Para cada regra de negócio identificada no código:
  - [ ] Criar `RN-M{xx}-{nnn}.md` (template: `TEMPLATE_Docs_RN.md`)
  - [ ] Preencher: pré-condições, fluxo principal, excepções, validações
  - [ ] Preencher: tabelas/campos do banco de dados
  - [ ] Preencher: impacto em outras RNs
  - [ ] Definir status: Proposto / Em detalhamento / Aprovado / Implementado / Testado
- [ ] Verificar rastreabilidade: cada RN referencia o código-fonte correspondente
- [ ] Verificar rastreabilidade inversa: código com lógica de negócio tem RN documentada

#### 4.x.3 Arquitetura/

- [ ] Verificar se o módulo está referido em `Documentation/Arquitetura/`
- [ ] Se ausente, acrescentar secção ao documento de arquitectura
  - [ ] Descrever interfaces (`I*`), implementações (`T*`), factories (`New`)
  - [ ] Documentar dependências entre módulos
  - [ ] Registar padrões utilizados (fluent, observer, factory, etc.)
- [ ] Validar que o diagrama de camadas (se existir) inclui o módulo
- [ ] Verificar compatibilidade Delphi + FPC documentada

#### 4.x.4 Validação cruzada com código

- [ ] Todas as interfaces públicas do módulo estão documentadas
- [ ] Todas as classes públicas do módulo estão documentadas
- [ ] Métodos factory (`New*`) documentados com assinatura e exemplo
- [ ] Tipos enumerados e records documentados
- [ ] Excepções específicas do módulo documentadas (cross-ref com `src/Modulos/Exceptions/`)

---

<a id="5-bootstrap-da-estrutura-documentation"></a>

## 5. Bootstrap da Estrutura Documentation/

### 5.1 As 13 subpastas obrigatórias

Toda pasta `Documentation/` de projecto deve conter, no mínimo, estas subpastas:

| # | Subpasta | Finalidade | Template base | Status |
|---|----------|-----------|---------------|--------|
| 01 | `Analise/` | Análises, scans, lacunas | `TEMPLATE_Docs_Analise.md` | [ ] |
| 02 | `Analise/{Domain}/` | Uma subpasta por domínio/módulo de `{SRC_PATH}` | `TEMPLATE_Unit_ClassName.md` | [ ] |
| 03 | `Arquitetura/` | Documentação de arquitectura e camadas | `TEMPLATE_Docs_Arquitetura.md` | [ ] |
| 04 | `Regras de Negocio/` | Hub de regras de negócio | `TEMPLATE_Docs_RN.md` | [ ] |
| 05 | `Regras de Negocio/RN-M{xx}/` | Uma subpasta por módulo com RNs | `TEMPLATE_Docs_RN.md` | [ ] |
| 06 | `Esboco_Telas/` | Esboços e documentação de telas | `TEMPLATE_Docs_EsbocTelas.md` | [ ] |
| 07 | `Roadmap/` | Roadmap por fases e entregas | `TEMPLATE_Docs_Roadmap.md` | [ ] |
| 08 | `Versionamento/` | Changelog e histórico de versões | `TEMPLATE_Docs_Changelog.md` | [ ] |
| 09 | `Backup/` | Backups documentais de ciclos anteriores | `TEMPLATE_Docs_Backup_README.md` | [ ] |
| 10 | `html/` | Portal estático (index.html, docs-data.js) | `TEMPLATE_Docs_html_index.html` | [ ] |
| 11 | `Overview/` | Visão geral do projecto | `TEMPLATE_Docs_Overview.md` | [ ] |
| 12 | `Diagramas/` | Diagramas técnicos (UML, ER, fluxos) | (sem template; criar README.md) | [ ] |
| 13 | `Glossario/` | Glossário de termos do domínio | (sem template; criar README.md) | [ ] |

### 5.2 Ficheiros obrigatórios na raiz de Documentation/

| Ficheiro | Template | Finalidade | Status |
|----------|----------|-----------|--------|
| `README.md` (hub) | `TEMPLATE_Docs_README_Hub.md` | Ponto de entrada | [ ] |
| `ROTEIROS_CONSOLIDADO.md` | `TEMPLATE_Docs_ROTEIROS_CONSOLIDADO.md` | Bootstrap, modos de uso | [ ] |
| `LOGICA_DATABASE.md` | `TEMPLATE_Docs_LOGICA_DATABASE.md` | Semântica da camada de dados | [ ] |

### 5.3 Procedimento de criação

1. Criar cada subpasta ausente.
2. Para cada subpasta criada, gerar o `README.md` interno a partir do template.
3. Para `Analise/`, criar subpastas por domínio conforme `{MODULE_LIST}`.
4. Para `Regras de Negocio/`, criar subpastas `RN-M{xx}` conforme `{MODULE_LIST}`.
5. Preencher o hub `Documentation/README.md` com links para todas as subpastas.
6. Confirmar que todos os templates utilizados vêm de `.cursor/Templates/`.

---

<a id="6-checklist-de-validação"></a>

## 6. Checklist de Validação

### 6.1 Validação estrutural

- [ ] Todas as 13 subpastas obrigatórias existem em `Documentation/`.
- [ ] Cada subpasta contém pelo menos um `README.md`.
- [ ] O hub `Documentation/README.md` tem links para todas as subpastas.
- [ ] Não existem ficheiros soltos na raiz de `Documentation/` sem justificação.

### 6.2 Validação de cobertura: `{SRC_PATH}` vs. `Documentation/`

Para cada módulo em `{SRC_PATH}`:

| Módulo | Pasta em Analise/ | Pasta em RN/ | Secção em Arquitetura/ | Resultado |
|--------|-------------------|--------------|------------------------|-----------|
| {MODULE_NAME} | [ ] Pass | [ ] Pass | [ ] Pass | {OK / FALHA} |

### 6.3 Validação de conteúdo por módulo

Para cada módulo, verificar que os documentos:

- [ ] Reflectem as interfaces e classes actuais do código.
- [ ] Não contêm referências a código eliminado ou renomeado.
- [ ] Seguem o formato do template correspondente.
- [ ] Possuem versionamento (`Vx.y`) e data.
- [ ] Têm changelog interno.

### 6.4 Validação de rastreabilidade

- [ ] Cada RN (`RN-M{xx}-{nnn}`) referencia o código-fonte que a implementa.
- [ ] Cada documento de análise referencia os ficheiros de `{SRC_PATH}` analisados.
- [ ] O documento de arquitectura lista todos os módulos de `{SRC_PATH}`.
- [ ] O entrypoint de build (`uses`) está alinhado com o inventário documental.

### 6.5 Validação de conformidade com templates

- [ ] Todos os documentos de análise seguem `TEMPLATE_Docs_Analise.md`.
- [ ] Todos os documentos RN seguem `TEMPLATE_Docs_RN.md`.
- [ ] O hub segue `TEMPLATE_Docs_README_Hub.md`.
- [ ] O diagnóstico segue `TEMPLATE_ANALISE_DIAGNOSTICO_ORGANIZACAO.md`.

---

<a id="7-verificação-pós-migração"></a>

## 7. Verificação Pós-Migração

### 7.1 Teste de integridade

- [ ] Nenhum ficheiro do backup foi perdido (comparar contagem e nomes).
- [ ] Links internos entre documentos funcionam (sem 404 / broken links).
- [ ] O portal `html/` (se existir) reflecte a nova estrutura.

### 7.2 Teste de completude

- [ ] Executar novamente a Fase 2 (Discovery) e confirmar que a Fase 3 (Gap Analysis) retorna zero lacunas críticas.
- [ ] Comparar totais:
  ```
  Módulos em {SRC_PATH}: ___
  Módulos documentados:  ___ (esperado: 100%)
  RNs identificadas:     ___
  RNs documentadas:      ___ (esperado: 100%)
  ```

### 7.3 Revisão humana

- [ ] Utilizador revisou o hub `Documentation/README.md`.
- [ ] Utilizador confirmou que a estrutura está correcta.
- [ ] Utilizador aprovou a lista de documentos órfãos para arquivo/eliminação.

### 7.4 Actualização de referências

- [ ] `CLAUDE.md` actualizado se a árvore de arquitectura mudou.
- [ ] `.cursor/rules/` actualizadas se houve mudança de convenções.
- [ ] `O_QUE_FALTA_100_PORCENTO.md` (se existir) actualizado com novo estado.
- [ ] Changelog deste plano actualizado com data de conclusão.

### 7.5 Limpeza

- [ ] Remover ficheiros temporários de scan.
- [ ] Mover backup para `Documentation/Backup/` com README descritivo.
- [ ] Arquivar este plano preenchido em `.cursor/plans/` ou `Documentation/Backup/`.

---

<a id="8-propagação-para-outros-projectos"></a>

## 8. Propagação para Outros Projectos

### 8.1 Procedimento de replicação

1. Copiar este ficheiro (`documentation-migration-plan_V1.0.md`) para o novo projecto em `.cursor/plans/`.
2. Substituir todos os placeholders:
   - `{PROJECT_NAME}` pelo nome do projecto.
   - `{SRC_PATH}` pelo caminho da pasta de código-fonte (ex.: `src/`).
   - `{MODULE_LIST}` pela lista de módulos do novo projecto (após Fase 2).
   - `{MODULE_NAME_xx}` pelos nomes reais dos módulos.
   - `{Domain}` pelos nomes de domínio correspondentes.
   - `M{xx}` pelos identificadores numéricos dos módulos.
3. Executar as Fases 1 a 7 no novo projecto.
4. Adaptar a secção 5 (Bootstrap) se o novo projecto tiver subpastas adicionais.

### 8.2 Adaptações por framework

| Framework | Entrypoint | Ajuste |
|-----------|-----------|--------|
| Delphi (VCL) | `{PROJECT_NAME}.dpr` | Extrair `uses` para inventário |
| FPC/Lazarus (LCL) | `{PROJECT_NAME}.lpr` | Extrair `uses` para inventário |
| Ambos | `.dpr` + `.lpr` | Inventário unificado; marcar units exclusivas por framework |

### 8.3 Checklist de propagação

- [ ] Plano copiado e placeholders substituídos.
- [ ] Templates de `.cursor/Templates/` disponíveis no projecto alvo.
- [ ] Scripts de bootstrap (`.cursor/scripts/`) disponíveis.
- [ ] Fase 1 (pré-requisitos) validada no novo projecto.
- [ ] Plan mode activado antes da primeira execução.

---

## Placeholders — Referência Rápida

| Placeholder | Significado | Exemplo |
|-------------|------------|---------|
| `{PROJECT_NAME}` | Nome do projecto (usado em `program X;`) | ProvidersORM |
| `{SRC_PATH}` | Caminho relativo à raiz do código-fonte | src/ |
| `{MODULE_LIST}` | Lista de módulos descobertos na Fase 2 | Commons, Connections, Database, ... |
| `{MODULE_NAME_xx}` | Nome individual de um módulo | Connections |
| `{Domain}` | Nome do domínio documental (pode = MODULE_NAME) | Connections |
| `M{xx}` | Identificador numérico do módulo (01, 02, ...) | M01 |
| `RN-M{xx}-{nnn}` | ID da regra de negócio | RN-M03-001 |

---

## Regras Operacionais

1. **SEMPRE entrar em plan mode** antes de executar qualquer etapa deste plano.
2. **Nunca eliminar** documentos sem backup prévio e confirmação do utilizador.
3. **Nunca executar** modo `full` de scaffolding sem confirmação explícita.
4. **Manter precedência:** `src/` (código) > `.cursor/` (canônicos) > `Documentation/`.
5. **Um módulo por vez:** completar todas as etapas de um módulo antes de avançar.
6. **Actualizar este plano** à medida que cada etapa é concluída (marcar `[X]`).
7. **Templates são obrigatórios:** não criar documentos de raiz; usar `.cursor/Templates/`.

---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.0.0 (04/04/2026): Criação do plano genérico de migração documental. Template reutilizável com placeholders `{PROJECT_NAME}`, `{SRC_PATH}`, `{MODULE_LIST}`. Secções: pré-requisitos, descoberta, análise de lacunas, checklist por módulo (Analise/RN/Arquitetura), bootstrap de 13 subpastas, validação, pós-migração, propagação.

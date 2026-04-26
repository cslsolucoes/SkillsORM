---
name: spec
description: Gera documento de especificação de software (SPEC) por engenharia reversa do código-fonte Delphi. Quest de clarificação define escopo, nível, destino e marcação de inferências antes de executar.
---

Inicie a geração da especificação de software do projeto Delphi.

**Idioma:** Detecte o idioma do usuário e responda sempre nesse idioma.
Padrão: pt-BR. Idiomas suportados: pt-BR, en-US.
Honre overrides: "respond in English" / "responda em português".

---

## Quest — Clarificação inicial

Faça as perguntas abaixo **uma por mensagem**, aguardando resposta antes de enviar
a próxima. Se o usuário responder "padrão" ou "default" em qualquer etapa, use o
valor indicado entre parênteses e avance para a próxima pergunta.

---

**Q1 — Escopo:**

> O que será especificado?
> 1. Projeto inteiro — todos os módulos identificados no `.dpr` *(padrão)*
> 2. Módulo de negócio específico → informe o nome ou caminho (ex.: `src/Modulos/Database/`)
> 3. Conjunto de units → cole os caminhos `.pas`

---

**Q2 — Nível da SPEC:**

> Qual profundidade para o documento gerado?
> 1. SPEC técnica completa — atores, RF, RNF, regras de negócio, casos de uso, modelo de dados, integrações, restrições *(padrão)*
> 2. SPEC executiva — visão geral, objetivos, principais funcionalidades e restrições técnicas (~2 páginas)
> 3. SPEC de módulo — foco em RF + regras de negócio + modelo de dados de um módulo específico

---

**Q3 — Destino e nome do arquivo:**

> Onde salvar e como nomear?
> 1. `SPEC.md` na raiz do projeto *(padrão)*
> 2. `Documentation/SPEC_<NomeProjeto>.md`
> 3. Outro caminho/nome → informe

---

**Q4 — Finalidade:**

> Para que será usada a SPEC?
> 1. Base para desenvolvimento — onboarding da equipe ou início de novo ciclo *(padrão)*
> 2. Entrega para cliente — linguagem formal, sem detalhes de implementação interna
> 3. Documentação para venda / auditoria — ênfase em valor de negócio e cobertura funcional
> 4. Insumo para refatoração — foco em regras de negócio e acoplamentos a preservar

---

Ao receber as respostas, confirme antes de executar:

> "Vou gerar **[nível]** com escopo **[escopo]**, salvar em **[destino]** para **[finalidade]**. Posso prosseguir?"

---

## Execução — Protocolo de 6 etapas

Após confirmação, acione `developer-delphi-agent-spec-writer` e carregue a skill
`developer-delphi-project-spec`. Execute sem interromper o usuário com perguntas adicionais.

Selecione o template conforme idioma:
- pt-BR → `references/spec-template.md` · inferências marcadas com `[INFERIDO]`
- en-US → `references/spec-template.en.md` · inferências marcadas com `[INFERRED]`

### 1 — SCAN
Localizar todos os arquivos `.pas`, `.dfm`, `.dpr`, `.dproj` no escopo definido.
Identificar: projeto principal, forms, services, repositories, entities, datamodules.

### 2 — READ
Ler os arquivos relevantes priorizando: units de domínio, services, repositories,
forms principais e datamodules com regras de negócio.

### 3 — EXTRACT
Mapear diretamente do código:
- Atores (forms e permissões)
- Requisitos Funcionais (métodos públicos, ações, eventos)
- Requisitos Não Funcionais (tecnologia, banco, plataforma)
- Regras de Negócio (validações, guards, if/raise)
- Casos de Uso (fluxos de tela, ações principais)
- Modelo de Dados (entidades, records, queries)
- Integrações (HTTP, COM, DLL, WebService)
- Restrições Técnicas (versão Delphi, banco, SO alvo)

### 4 — GENERATE
Preencher todas as seções do template selecionado.
Adaptar profundidade e linguagem ao nível e finalidade informados no Quest.
Nunca deixar seções em branco — usar `"Não identificado no código-fonte."` se necessário.

### 5 — SAVE
Gravar o documento no destino confirmado no Quest.

### 6 — REPORT
Informar ao usuário:
- Caminho do arquivo gerado
- Seções preenchidas com dados reais vs. inferidas (`[INFERIDO]`)
- Arquivos não analisados (se houver) com motivo
- Próximo passo sugerido: `/audit` para avaliar qualidade do código antes de refatorar

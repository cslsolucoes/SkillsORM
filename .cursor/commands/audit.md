---
name: audit
description: Gera laudo técnico profissional de um projeto Delphi — 8 dimensões com score e plano de modernização. Quest de clarificação define tipo, escopo, dimensões e finalidade antes de executar.
---

Inicie o processo de auditoria técnica do projeto Delphi.

**Idioma:** Detecte o idioma do usuário e responda sempre nesse idioma.
Padrão: pt-BR. Idiomas suportados: pt-BR, en-US.
Honre overrides: "respond in English" / "responda em português".

---

## Quest — Clarificação inicial

Faça as perguntas abaixo **uma por mensagem**, aguardando resposta antes de enviar
a próxima. Se o usuário responder "padrão" ou "default" em qualquer etapa, use o
valor indicado entre parênteses e avance para a próxima pergunta.

---

**Q1 — Tipo de laudo:**

> Qual profundidade para o laudo?
> 1. Diagnóstico executivo — resumo rápido por dimensão, sem aprofundamento (~1 página)
> 2. Laudo completo — 8 dimensões com score 1–5, análise detalhada e plano de modernização *(padrão)*
> 3. Laudo direcionado — escolho quais dimensões aprofundar → informe quais

---

**Q2 — Escopo:**

> O que será auditado?
> 1. Projeto inteiro — todos os arquivos `.pas`/`.dfm`/`.dpr` *(padrão)*
> 2. Módulo específico → informe o caminho (ex.: `src/Modulos/Database/`)
> 3. Arquivos selecionados → cole os caminhos `.pas`

---

**Q3 — Finalidade:**

> Para que será usado o laudo?
> 1. Uso interno da equipe — diagnóstico e melhoria contínua *(padrão)*
> 2. Relatório para cliente — linguagem formal, foco em riscos e recomendações
> 3. Documentação para venda / aquisição — ênfase em valor, maturidade e esforço de migração
> 4. Auditoria externa / compliance — rigor máximo, rastreabilidade de evidências

---

**Q4 — Contexto técnico** *(opcional — Enter para pular)*:

> Informe se souber: versão do Delphi, banco de dados, componente de acesso (FireDAC/ADO/UniDAC),
> tipo do sistema (ERP / API / Desktop / Híbrido).
> *(Se não informado, será levantado durante a análise)*

---

Ao receber as respostas, confirme antes de executar:

> "Vou gerar **[tipo]** com escopo **[escopo]** para **[finalidade]**. Posso prosseguir?"

---

## Execução — Protocolo de auditoria

Após confirmação, acione `developer-delphi-agent-auditor` e carregue a skill
`developer-delphi-project-audit`. Execute conforme o tipo selecionado:

### Tipo 1 — Diagnóstico executivo
Varredura rápida: identificar os 3 maiores riscos por dimensão sem aprofundamento.
Saída: tabela de dimensões com semáforo (🟢/🟡/🟠/🔴) e top-3 recomendações imediatas.

### Tipo 2 — Laudo completo *(padrão)*

Carregue o template do idioma:
- pt-BR → `references/estrutura-laudo.md`
- en-US → `references/estrutura-laudo.en.md`

Execute as 4 etapas:

1. **Levantamento** — confirmar ou coletar: versão Delphi, banco, componente de acesso,
   tipo do sistema, objetivo (já informado no Quest Q3 e Q4).

2. **Análise** — avaliar as 8 dimensões:
   Arquitetura · Clean Code · Code Smells · SOLID · Memória · Acesso a Dados · Segurança · Manutenibilidade.

3. **Pontuação** — score 1–5 por dimensão, média ponderada final:
   - 4,0–5,0 = 🟢 BOM
   - 3,0–3,9 = 🟡 REGULAR
   - 2,0–2,9 = 🟠 CRÍTICO
   - 1,0–1,9 = 🔴 INVIÁVEL

4. **Relatório** — gerar laudo completo com: resumo executivo, análise por dimensão,
   pontos críticos, recomendações (imediatas / curto prazo / médio prazo / estratégico)
   e estimativa de esforço para modernização.
   Adaptar linguagem à finalidade informada no Quest Q3.

### Tipo 3 — Laudo direcionado
Executar apenas as dimensões escolhidas com profundidade máxima.
Incluir na saída: justificativa de por que as demais dimensões foram omitidas.

---

## Saída esperada

Ao final, informar:
- Arquivo salvo (se gerado): `Laudo_<NomeProjeto>_<data>.md`
- Score final e classificação
- Top-3 ações imediatas recomendadas
- Próximo passo sugerido: `/spec` para documentar o sistema antes de refatorar

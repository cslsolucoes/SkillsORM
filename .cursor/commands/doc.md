---
name: doc
description: Gera documentação completa de classes/interfaces/métodos do projeto Delphi por engenharia reversa do código-fonte. Aciona o pipeline class-scanner → class-writer → class-indexer produzindo {ClassName}.md por tipo em Analise/.
---

Inicie o pipeline de documentação de código-fonte.

**Idioma:** Detecte o idioma do usuário e responda sempre nesse idioma.
Padrão: pt-BR. Idiomas suportados: pt-BR, en-US.

---

## Quest — Clarificação inicial

Faça as perguntas abaixo **uma por mensagem**, aguardando resposta antes de enviar
a próxima. Se o usuário responder "padrão" ou "default" em qualquer etapa, use o
valor indicado entre parênteses e avance para a próxima pergunta.

---

**Q1 — Escopo:**

> Qual parte do projeto documentar?
> 1. Projeto inteiro — todas as units em `src/` *(padrão)*
> 2. Módulo específico → informe o caminho (ex.: `src/Modulos/Database/`)
> 3. Lista de arquivos → cole os caminhos `.pas`

---

**Q2 — Nível de detalhe por classe:**

> Qual profundidade para cada tipo documentado?
> 1. Completo — 7 seções (O que é · Características · Engine · Funcionalidades · Aplicabilidades · Exemplos de uso · Relacionamentos) *(padrão)*
> 2. Resumido — 3 seções (O que é · Características · Relacionamentos)
> 3. Só índice — apenas o `README.md` e `FLOWCHART.md` sem arquivos por classe

---

**Q3 — Destino:**

> Onde salvar a documentação gerada?
> 1. `Analise/` na raiz do projeto *(padrão)*
> 2. `Documentation/Analise/`
> 3. Outro caminho → informe

---

**Q4 — Pastas a excluir:**

> Alguma pasta deve ser ignorada no scan?
> 1. Padrão — excluir `Views/`, `Tests/`, `__history/` *(padrão)*
> 2. Personalizar → informe as pastas a excluir
> 3. Nenhuma — escanear tudo

---

Ao receber as 4 respostas, confirme antes de executar:

> "Vou documentar **[escopo]** com nível **[detalhe]**, salvando em **[destino]**,
> excluindo **[pastas]**. Posso prosseguir?"

---

## Execução — Pipeline de 3 fases

Após confirmação, execute as fases em sequência:

### Fase 0 — Scaffold (se necessário)
Verificar se a estrutura de pastas `Analise/` já existe no destino informado.
Se não existir, acionar a skill `documentation-paste_analysis_unit_class_method`
para criar o scaffold canônico derivado de `src/`.

### Fase 1 — Scan
Acionar `documentation-agent-class-scanner` para varrer o escopo definido e
produzir o inventário estruturado de todos os tipos encontrados.
Reportar ao usuário: quantas classes, interfaces, records e enums foram encontrados.

### Fase 2 — Write
Acionar `documentation-agent-class-writer` com o inventário da Fase 1.
Gerar `{ClassName}.md` (sem prefixo T/I no nome do arquivo) para cada tipo,
no nível de detalhe selecionado, no destino confirmado.

### Fase 3 — Index
Acionar `documentation-agent-class-indexer` para gerar:
- `README.md` — índice completo de todos os tipos documentados
- `FLOWCHART.md` — diagrama Mermaid de relacionamentos entre tipos

### Relatório final
Ao concluir, informar:
- Total de arquivos `{ClassName}.md` gerados
- Tipos não parseáveis (se houver) com motivo
- Caminho do `README.md` e `FLOWCHART.md`
- Próximo passo sugerido: `/consolidar documentação` para verificar consistência

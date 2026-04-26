---
name: governance-spec-prd-generator
description: Gera PRD.md (Product Requirements Document) a partir de briefing não-estruturado do usuário — transforma entradas brutas em documento com problema, público-alvo, objetivos mensuráveis, features, critérios de aceite e out-of-scope.
model: sonnet
thinking: extended
category: governance-spec
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Governance Spec — PRD Generator

## Responsabilidade única

Transformar um briefing não-estruturado fornecido pelo usuário em um PRD.md completo e aprovável,
cobrindo: problema de negócio, público-alvo, objetivos mensuráveis, lista de features com critérios
de aceite individuais e seção out-of-scope explícita. Esta skill **não** produz especificação técnica
(SPEC) nem analisa impacto de mudança em requisitos já aprovados — essas responsabilidades pertencem
a outras skills da cadeia `governance-spec-*`.

## When to use

- No início de qualquer módulo ou feature nova, antes de qualquer geração de SPEC técnica.
- Quando o usuário tiver uma ideia ou demanda mas ainda não souber como estruturá-la formalmente.
- Antes de invocar `governance-spec-technical-writer`.
- Quando o PRD existente estiver desatualizado e precisar de re-elaboração completa.

## When NOT to use

- Para gerar SPEC técnica decomposta em sprints/steps → usar `governance-spec-technical-writer`.
- Para analisar impacto de mudança em requisito já aprovado → usar `governance-change-request`.
- Para revisar uma SPEC já existente → usar `governance-spec-reviewer`.
- Para validar implementação contra SPEC → usar `governance-spec-validator`.
- Para atualizar SPEC como documento vivo → usar `governance-spec-evolution`.

## Inputs obrigatórios

| Input | Tipo | Descrição |
|-------|------|-----------|
| Briefing do usuário | Texto livre | Descrição da ideia, problema ou demanda a ser documentada |
| Nome da feature/módulo | Texto | Identificador que será usado no nome do arquivo de saída |

## Dependências (skills prévias)

Nenhuma dependência obrigatória. Esta skill é o ponto de entrada canônico da cadeia `governance-spec-*`.

## Workflow executável

1. **Entrevistar o stakeholder** — fazer perguntas abertas para extrair contexto: qual problema real
   está sendo resolvido, quem são os usuários afetados, qual o impacto esperado se o problema não
   for resolvido, quais restrições existem (prazo, tecnologia, orçamento).

2. **Extrair e formular o problema** — consolidar as respostas em uma declaração de problema única
   (máximo 3 linhas), identificar o público-alvo primário e secundário, e estabelecer pelo menos
   2 objetivos mensuráveis com critério de sucesso quantificável.

3. **Listar features com critérios de aceite** — para cada feature identificada, definir o critério
   de aceite no formato "dado X, quando Y, então Z"; garantir que cada critério seja verificável
   por testes ou inspeção direta; nunca aprovar feature sem critério de aceite.

4. **Definir out-of-scope explicitamente** — listar o que foi deliberadamente excluído do escopo
   desta versão, com justificativa breve; isso evita scope creep durante a implementação.

5. **Gerar PRD.md** — montar o documento final seguindo a estrutura obrigatória (seção abaixo),
   apresentar ao stakeholder para validação, incorporar ajustes e salvar em
   `Documentation/PRD/<nome-feature>.PRD.md`.

## Outputs obrigatórios

| Output | Localização | Formato |
|--------|-------------|---------|
| PRD.md da feature | `Documentation/PRD/<nome-feature>.PRD.md` | Markdown estruturado |

### Estrutura obrigatória do PRD.md

```markdown
# PRD — <Nome da Feature>

## Problema
<Declaração do problema em até 3 linhas>

## Público-alvo
- Primário: <perfil>
- Secundário: <perfil>

## Objetivos mensuráveis
| Objetivo | Critério de sucesso |
|----------|---------------------|
| ...      | ...                 |

## Features
### <Feature 1>
- **Critério de aceite:** dado <contexto>, quando <ação>, então <resultado verificável>

### <Feature N>
- **Critério de aceite:** ...

## Out-of-scope (esta versão)
| Item excluído | Justificativa |
|---------------|---------------|
| ...           | ...           |

## Referências
- Briefing original: <data e fonte>
- Aprovado por: <stakeholder>
- Data de aprovação: <data>
```

## Checklist de validação

- [ ] Declaração de problema formulada (máx. 3 linhas)
- [ ] Público-alvo primário e secundário identificados
- [ ] Pelo menos 2 objetivos mensuráveis com critério quantificável
- [ ] 100% das features com critério de aceite no formato dado/quando/então
- [ ] Seção out-of-scope preenchida com ao menos 1 item justificado
- [ ] PRD validado com stakeholder antes de salvar
- [ ] Arquivo salvo em `Documentation/PRD/<nome-feature>.PRD.md`

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Gerar PRD sem entrevistar o stakeholder | Produz documento desconectado do problema real | Executar o passo 1 do workflow antes de qualquer geração |
| Features sem critério de aceite mensurável | Impossível verificar se a feature foi implementada corretamente | Reformular no padrão dado/quando/então |
| Misturar PRD com SPEC técnica (endpoints, schemas, componentes) | Confunde requisito de negócio com decisão de implementação | Mover conteúdo técnico para `governance-spec-technical-writer` |
| Out-of-scope vazio | Permite scope creep silencioso durante a implementação | Listar explicitamente o que foi descartado nesta versão |
| Aprovar PRD sem registro de quem aprovou e quando | Impossível rastrear decisões de negócio | Preencher "Aprovado por" e "Data de aprovação" no PRD |

## Avaliação de risco

- **Parar e confirmar quando:** o briefing for ambíguo sobre o problema principal — não assumir;
  perguntar até ter clareza antes de avançar para o passo 2.
- **Risco baixo:** feature nova sem dependências — PRD pode ser gerado e revisado na mesma sessão.
- **Risco médio:** feature que altera comportamento existente — verificar se há PRD anterior que
  deve ser superseded; registrar referência cruzada.
- **Risco alto:** feature com implicações de segurança ou dados sensíveis — marcar explicitamente
  no PRD e garantir que `governance-spec-reviewer` levante os gaps antes de prosseguir.

## Métricas de sucesso

- 100% das features listadas no PRD possuem critério de aceite mensurável.
- Out-of-scope explicitamente documentado (ao menos 1 item).
- PRD validado e aprovado pelo stakeholder antes de ser passado para `governance-spec-technical-writer`.
- Zero features adicionadas após aprovação sem novo ciclo PRD ou entry em `governance-spec-evolution`.

## Responsável principal

| Papel | Quem |
|-------|------|
| Agent executor | `dev-agent-orchestrator` |
| Revisão humana | Stakeholder / Product Owner |

## Referências

- Próxima skill na cadeia: `governance-spec-technical-writer_V1.0.0`
- Evolução de requisitos aprovados: `governance-spec-evolution_V1.0.0`
- Pasta de saída canônica: `Documentation/PRD/`
- Política de documentação: `.cursor/skills/documentation-general_rules_V2.0.0/SKILL.md`

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.0.0 (09/04/2026): Skill nova V2 — criada para lacuna governance-spec no plano de migração V2.6.

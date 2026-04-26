---
name: governance-team-ai-human-workflow
description: Define e documenta a política de autonomia do agent — quais ações o agent executa automaticamente, quais requerem confirmação humana e quais são exclusivamente humanas no Providers.2.1.0.
model: sonnet
thinking: normal
category: governance-people
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Governance People — AI-Human Workflow

## Responsabilidade única

Documentar e aplicar a política de autonomia do agent no projeto Providers.2.1.0: classificar cada
tipo de ação por nível de autonomia (automático / confirmação / humano apenas), garantir que agents
não tomam decisões de alto impacto sem aprovação, e treinar novos agents com exemplos concretos do
projeto. Esta skill **não** define a matriz RACI operacional por tipo de tarefa
(→ `governance-team-raci-matrix`) nem conduz o onboarding técnico completo
(→ `governance-team-onboarding`).

## When to use

- Ao configurar um novo agent para o projeto Providers.2.1.0.
- Ao revisar a política de autonomia após incidente ou mudança de processo.
- Ao fazer onboarding de novo agent para garantir que ele conhece seus limites de atuação.
- Quando houver dúvida sobre se determinada ação requer ou não aprovação humana.

## When NOT to use

- Para definir RACI operacional por tipo de tarefa → usar `governance-team-raci-matrix`.
- Para onboarding técnico completo de dev ou agent → usar `governance-team-onboarding`.
- Para gestão de mudança específica → usar `governance-change-request`.

## Inputs obrigatórios

| Input | Tipo | Descrição |
|-------|------|-----------|
| Lista de ações do agent | Lista | Ações que o agent realiza ou pode realizar no projeto |
| Contexto do projeto | Texto | Nome, versão, ambiente (dev/produção) |

## Dependências (skills prévias)

| Skill | Motivo |
|-------|--------|
| `governance-team-raci-matrix_V1.0.0` | Contexto de responsabilidades por tipo de tarefa |

## Workflow executável

1. **Classificar ações por nível de autonomia** — para cada ação identificada, atribuir um nível:

   **Automático** (agent executa sem confirmação):
   - Scaffold de código a partir de template
   - Leitura e análise de documentação e código
   - Geração de checklist, relatório ou inventário
   - Migração de formato de arquivo (ex.: .pas → markdown, JSON → tabela)
   - Geração de testes unitários em ambiente de desenvolvimento
   - Execução de compilação local para verificação de erros

   **Confirmação** (agent propõe, humano aprova antes de executar):
   - Renomear ou mover API pública (interfaces `I*`, métodos públicos)
   - Criar pull request ou fazer push para branch compartilhado
   - Modificar arquivo de configuração de build (`.dpr`, `.lpr`, `.lpi`)
   - Enviar notificação ou email para a equipe
   - Modificar arquivos em ambiente de produção
   - Criar nova branch a partir de main
   - Atualizar dependência externa

   **Humano apenas** (agent não executa; apenas apresenta análise):
   - Aprovar pull request para branch main
   - Executar deploy em produção
   - Tomar decisões financeiras ou contratuais
   - Demitir, contratar ou alterar permissões de acesso
   - Aprovar breaking change em API pública
   - Autorizar rollback em produção

2. **Documentar a política** — gerar `Documentation/AI-Human-Policy.md` com a tabela de autonomia,
   exemplos concretos do Providers.2.1.0 para cada nível, e critério de escalação quando a ação não
   se encaixar claramente em nenhum nível.

3. **Treinar agents com exemplos** — incluir na política exemplos explícitos do projeto:
   - "Gerar `TConnection` a partir de interface `IConnection` → Automático"
   - "Renomear método público `Connect` para `Open` → Confirmação (breaking change)"
   - "Fazer merge de PR para main → Humano apenas"

## Outputs obrigatórios

| Output | Localização | Formato |
|--------|-------------|---------|
| Política de autonomia | `Documentation/AI-Human-Policy.md` | Markdown estruturado |

### Estrutura obrigatória da política

```markdown
# Política de Autonomia IA-Humano — Providers.2.1.0

## Níveis de autonomia

### Automático (agent executa sem confirmação)
| Ação | Exemplo no projeto |
|------|--------------------|
| ...  | ...                |

### Confirmação (agent propõe, humano aprova)
| Ação | Exemplo no projeto | Quem aprova |
|------|--------------------|-------------|
| ...  | ...                | ...         |

### Humano apenas (agent não executa)
| Ação | Justificativa |
|------|---------------|
| ...  | ...           |

## Critério de escalação
<Quando uma ação não se encaixar claramente, o agent deve: ...>
```

## Checklist de validação

- [ ] Todas as ações recorrentes do agent classificadas por nível
- [ ] Exemplos concretos do Providers.2.1.0 para cada nível
- [ ] Critério de escalação para ações ambíguas documentado
- [ ] Política validada com Tech Lead
- [ ] `Documentation/AI-Human-Policy.md` criado/atualizado
- [ ] Agents do projeto informados da política

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Agent executando push sem confirmação | Código não revisado pode entrar em branch compartilhado | Mover push para nível "Confirmação" |
| Humano aprovando sem revisar o que está aprovando | Aprovação sem valor; agent pode cometer erros não detectados | Humano deve ler o diff ou resumo antes de aprovar |
| Regras de autonomia não documentadas | Cada interação depende da interpretação do momento | Documentar política explícita e treinável |
| Nível de autonomia mal definido para ação crítica | Agent age além do autorizado; humano fica alheio | Revisitar a classificação na dúvida; default é "Confirmação" |
| Política nunca revisada | Fica desatualizada após mudanças de processo ou incidentes | Revisar após cada incidente P0/P1 e a cada release major |

## Avaliação de risco

- **Parar e confirmar quando:** ação não se encaixar claramente em nenhum nível — default é
  sempre "Confirmação"; nunca assumir autonomia plena na dúvida.
- **Risco baixo:** novas ações automáticas sem impacto em artefatos compartilhados.
- **Risco alto:** qualquer ação que modifique artefatos públicos ou acione sistemas externos —
  mover para "Confirmação" ou "Humano apenas".

## Métricas de sucesso

- Toda ação de alto impacto com nível de confirmação documentado.
- Zero decisões classificadas como "Humano apenas" executadas pelo agent.
- Política revisada após cada incidente P0/P1.
- Todos os agents do projeto treinados com a política vigente.

## Responsável principal

| Papel | Quem |
|-------|------|
| Executor (geração da política) | Agent (com supervisão) |
| Proprietário e aprovador | Humano (Tech Lead) |

## Referências

- RACI por tipo de tarefa: `governance-team-raci-matrix_V1.0.0`
- Onboarding: `governance-team-onboarding_V1.0.0`
- Incidente (revisão de política): `governance-incident-response_V1.0.0`
- Pasta de saída: `Documentation/`
- Política de documentação: `.cursor/skills/documentation-general_rules_V2.0.0/SKILL.md`

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.0.0 (09/04/2026): Skill nova V2 — criada para lacuna governance no plano de migração V2.6.

---
name: governance-team-onboarding
description: Onboarding de desenvolvedor e agent no projeto Providers.2.1.0 — checklist e guia de setup do ambiente, estrutura do projeto, convenções, skills e agents disponíveis, e primeiro task guiado.
model: haiku
thinking: minimal
category: governance-people
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Governance People — Team Onboarding

## Responsabilidade única

Conduzir o processo de integração de novo desenvolvedor ou novo agent no projeto Providers.2.1.0:
guiar o setup do ambiente de desenvolvimento, apresentar a estrutura do projeto e suas convenções,
listar skills e agents disponíveis, executar checklist de verificação e acompanhar o primeiro task
prático. Esta skill **não** cobre a matriz RACI (→ `governance-team-raci-matrix`) nem a política
de autonomia do agent (→ `governance-team-ai-human-workflow`).

## When to use

- Ao integrar novo desenvolvedor humano ao projeto Providers.2.1.0.
- Ao configurar novo agent IA para atuar no projeto.
- Ao retornar ao projeto após longa ausência (refresh de contexto).

## When NOT to use

- Para definir RACI operacional → usar `governance-team-raci-matrix`.
- Para política de autonomia do agent → usar `governance-team-ai-human-workflow`.
- Para setup de compilação detalhado → usar `developer-delphi-build-toolchain`.

## Inputs obrigatórios

| Input | Tipo | Descrição |
|-------|------|-----------|
| Tipo de membro | Texto | "desenvolvedor humano" ou "agent IA" |
| Nome/identificador | Texto | Nome do dev ou identificador do agent |

## Dependências (skills prévias)

| Skill | Motivo |
|-------|--------|
| `project-estrutura_V1.1.0` | Apresentar estrutura de diretórios e módulos |
| `project-expert_V1.2.0` | Responder perguntas técnicas durante onboarding |

## Workflow executável

1. **Setup do ambiente** — verificar e configurar o ambiente de desenvolvimento:
   - Instalar/verificar RAD Studio ou FPC/Lazarus conforme configuração do projeto
   - Clonar/abrir o repositório no workspace correto
   - Executar `bootstrap-mirror-symlinks.ps1 -ValidateOnly` para validar symlinks
   - Executar `bootstrap-build-config.ps1 -ValidateOnly` para validar arquivos de build
   - Realizar primeira compilação de verificação (Delphi e/ou FPC conforme disponível)

2. **Ler documentação base** — garantir leitura dos documentos fundamentais antes de qualquer
   código:
   - `CLAUDE.md` — regras e fluxos do workspace
   - `.cursor/README.md` — hub de skills e agents disponíveis
   - `Documentation/` — documentação canônica do projeto
   - Estrutura de diretórios via `documentation-project-structure`

3. **Executar checklist de verificação** — validar cada item antes de declarar onboarding concluído:

   **Para desenvolvedor humano:**
   - [ ] Compilação Delphi Win32 funcional (se RAD Studio instalado)
   - [ ] Compilação FPC Win64 funcional (se FPC instalado)
   - [ ] IDE configurada (RAD Studio / Lazarus)
   - [ ] `CLAUDE.md` lido e compreendido
   - [ ] `.cursor/README.md` lido — skills e agents conhecidos
   - [ ] Primeiro build ok sem erros
   - [ ] Estrutura `src/` compreendida (Commons, Main, Modulos, Views)
   - [ ] Convenções do projeto conhecidas (interfaces `I*`, impl `T*`, factory `New`)
   - [ ] RACI consultado para entender responsabilidades

   **Para agent IA:**
   - [ ] `CLAUDE.md` lido — regras absolutas e fases conhecidas
   - [ ] `.cursor/README.md` lido — skills disponíveis conhecidas
   - [ ] Política de autonomia lida (`governance-team-ai-human-workflow`)
   - [ ] RACI consultado (`governance-team-raci-matrix`)
   - [ ] Convenções do projeto internalizadas
   - [ ] Primeiro task executado com sucesso sem erro de contexto

4. **Primeiro task guiado** — executar uma tarefa prática simples supervisionada pelo Tech Lead:
   - Para dev humano: compilar o projeto e explicar a estrutura de um módulo existente
   - Para agent IA: gerar um relatório de estrutura via `documentation-project-structure` e responder 3 perguntas
     sobre o código usando `documentation-project-expert`

## Outputs obrigatórios

| Output | Localização | Formato |
|--------|-------------|---------|
| Registro de onboarding | `Documentation/Onboarding/<nome>-onboarding.md` | Markdown com checklist assinado |

## Checklist de validação

- [ ] Tipo de membro identificado (dev humano / agent IA)
- [ ] Setup de ambiente concluído e validado
- [ ] Documentação base lida (CLAUDE.md, .cursor/README.md, Documentation/)
- [ ] Todos os itens do checklist do tipo de membro marcados
- [ ] Primeiro task guiado concluído com sucesso
- [ ] Registro de onboarding salvo em `Documentation/Onboarding/`

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Onboarding sem verificar compilação | Dev/agent não sabe se ambiente funciona; falhas aparecem tarde | Compilar o projeto como passo 1, não como passo opcional |
| Skip da documentação base | Dev/agent viola convenções por desconhecimento | Ler CLAUDE.md e .cursor/README.md antes de qualquer código |
| Onboarding sem task prática | Checklist teórico não valida que o ambiente realmente funciona | Executar passo 4 obrigatoriamente |
| Agent sem política de autonomia no onboarding | Agent age além do autorizado por desconhecimento | Incluir `governance-team-ai-human-workflow` no checklist do agent |
| Registro de onboarding não salvo | Impossível auditar quem foi integrado e quando | Criar arquivo em `Documentation/Onboarding/` antes de encerrar |

## Avaliação de risco

- **Parar e confirmar quando:** compilação falhar no passo 1 — resolver antes de prosseguir;
  onboarding sem compilação funcional não é onboarding.
- **Risco baixo:** dev/agent retornando ao projeto — executar checklist resumido e verificar
  mudanças desde a última participação.
- **Risco médio:** agent novo com autonomia expandida — validar política de autonomia com Tech
  Lead antes do primeiro task independente.

## Métricas de sucesso

- Dev compila o projeto sem ajuda após onboarding concluído.
- Agent executa o primeiro task sem erro de contexto (convenção/estrutura).
- 100% dos itens do checklist marcados antes de declarar onboarding completo.
- Registro de onboarding salvo para auditoria.

## Responsável principal

| Papel | Quem |
|-------|------|
| Condutor do onboarding | Agent (com supervisão) |
| Aprovador e validador | Humano (Tech Lead) |

## Referências

- Estrutura do projeto: `project-estrutura_V1.1.0`
- Especialista técnico: `project-expert_V1.2.0`
- RACI: `governance-team-raci-matrix_V1.0.0`
- Política de autonomia: `governance-team-ai-human-workflow_V1.0.0`
- Compilação: `developer-delphi-build-toolchain_V1.0.0`
- Hub de skills: `.cursor/README.md`
- Política de documentação: `.cursor/skills/documentation-general_rules_V2.0.0/SKILL.md`

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.0.0 (09/04/2026): Skill nova V2 — criada para lacuna governance no plano de migração V2.6.

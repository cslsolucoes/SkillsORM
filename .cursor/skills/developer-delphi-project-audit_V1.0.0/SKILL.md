---
name: developer-delphi-project-audit
description: >
  Laudo técnico profissional completo de projetos Delphi: análise de arquitetura, Clean Code,
  Code Smells, SOLID, memória, acesso a dados, segurança e manutenibilidade em 8 dimensões,
  com score 1-5 e plano de modernização. Bilíngue pt-BR/en-US.
  Ativar quando o usuário mencionar: laudo técnico, auditoria de código, análise de sistema Delphi,
  diagnóstico de projeto, avaliação de qualidade, análise de código legado, revisão de arquitetura,
  "analise este projeto", "analise esta pasta", "faça um laudo", modernização ou migração Delphi,
  arquivos .pas/.dfm/.dpr para análise, Code Smells, Clean Code, SOLID, memory leaks, God Class,
  Long Method, acoplamento, refatoração em Delphi.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-project-audit

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |
| **Criado** | 2026-04-24 |
| **Família** | Quality / Audit |

## Responsabilidade única

Gerar laudos técnicos profissionais e completos de projetos Delphi, cobrindo 8 dimensões de
qualidade com score, flags automáticos e plano de modernização por fases. Suporte bilíngue pt-BR/en-US.

## When to use

- Auditoria técnica completa de projeto Delphi (legado ou atual)
- Geração de laudo para decisão de modernização ou venda de sistema
- Detecção de Code Smells, violações SOLID e riscos de segurança
- Estimativa de esforço para modernização

## When NOT to use

- Revisão rápida de trecho isolado de código → `quality-code-review`
- Padrões de codificação e Style Guide → `developer-delphi-coding-standards`
- Testes unitários → `developer-delphi-testing-dunitx`

---

## §1 — Idioma e template

Detecte o idioma da primeira mensagem do usuário:
- pt-BR (padrão) → use `references/estrutura-laudo.md`
- en-US → use `references/estrutura-laudo.en.md`

Labels de severidade por idioma:
- pt-BR: `🚨 CRÍTICO / ⚠️ ATENÇÃO / 🟢 BOM / 🟡 REGULAR / 🟠 CRÍTICO / 🔴 INVIÁVEL`
- en-US: `🚨 CRITICAL / ⚠️ WARNING / 🟢 GOOD / 🟡 FAIR / 🟠 CRITICAL / 🔴 NOT VIABLE`

---

## Quest — Clarificação de intenção

> **Disparar este Quest** quando a ativação ocorrer por termos genéricos/ambíguos:
> "analise", "analise este projeto", "analise esta pasta", "faça uma análise",
> "avalie o sistema", "avalie este código", "examine o projeto", "verifique".
>
> **Ignorar** (ir direto ao §2) quando o usuário mencionar explicitamente:
> laudo, auditoria, Code Smells, SOLID, memory leak, diagnóstico técnico,
> score de qualidade, refatoração, modernização Delphi, DIM-*.

**Q0 — O que deseja gerar?**

> 1. **Laudo técnico de qualidade** — 8 dimensões: arquitetura, Clean Code, Code Smells,
>    SOLID, memória, dados, segurança, manutenibilidade *(esta skill)*
> 2. **Documentação de classes/units** — análise detalhada classe por classe,
>    método por método → use o comando `/doc`
> 3. **Ambos** — laudo técnico completo + documentação (executa em sequência)

Aguardar resposta antes de prosseguir.

- Se **1** → seguir para §2 (coleta inicial do laudo)
- Se **2** → informar: *"Para documentação detalhada de classes e units, use o comando `/doc` —
  ele guia o pipeline completo com escolha de escopo, nível e destino."* Encerrar esta skill.
- Se **3** → concluir o laudo completo (§2 em diante) → ao final, sugerir executar `/doc`

---

## §2 — Coleta inicial (Passo 1)

Antes de analisar, coletar (perguntar se não informado):
- Versão do Delphi (IDE e compilador)
- Tipo do sistema (ERP, CRM, financeiro, PDV, industrial...)
- Banco de dados e componente de acesso (BDE, ADO, FireDAC, Zeos...)
- Objetivo do laudo (modernização, auditoria, venda, continuidade)
- Escopo (completo ou amostragem)

---

## §3 — Oito dimensões de análise

| # | Dimensão | Referência |
|---|----------|-----------|
| DIM-1 | Arquitetura e Organização | — |
| DIM-2 | Clean Code e Nomenclatura | `references/clean-code-delphi.md` |
| DIM-3 | Code Smells | `references/code-smells-delphi.md` |
| DIM-4 | Arquitetura Limpa / SOLID | — |
| DIM-5 | Gestão de Memória | — |
| DIM-6 | Acesso a Dados | — |
| DIM-7 | Segurança | `references/style-guide.md` |
| DIM-8 | Manutenibilidade e Continuidade | `references/tecnologias-delphi.md` |

### DIM-1 — Arquitetura

- Padrão: Cliente/Servidor puro, MVC, MVP, Camadas
- Separação de responsabilidades (regras de negócio em Forms = Big Ball of Mud → CRÍTICO)
- DataModules para centralizar conexões e datasets
- Presença de interfaces `IInterface` no design
- Uso de packages e DLLs

### DIM-2 — Clean Code e Nomenclatura

Leia `references/clean-code-delphi.md`. Prefixos obrigatórios:

| Escopo | Prefixo | Correto | Errado |
|--------|---------|---------|--------|
| Parâmetro | `A` | `AValor` | `p`, `P`, sem prefixo |
| Variável local | `L` | `LQryAux` | `w`, `p`, sem prefixo |
| Field de classe | `F` | `FValor` | sem prefixo |
| Constante | `C_` + MAIÚSC | `C_MAX_ITER` | `cMax`, `MAX` |

Detectar: sem prefixos, componentes padrão (`Button1`), `with`, `Break`, `Continue`.

### DIM-3 — Code Smells

| Smell | Severidade | Limite |
|-------|-----------|--------|
| Long Method | CRÍTICO Alto | >50L tolerado, >100L crítico |
| God Method | CRÍTICO Crítico | >300L múltiplas responsabilidades |
| God Class | CRÍTICO Crítico | unit >2000L múltiplos domínios |
| Duplicate Code | ATENÇÃO Médio | mesma lógica em 2+ lugares |
| Long Parameter List | ATENÇÃO Alto | 4+ parâmetros |
| Magic Numbers | ATENÇÃO Médio | literais sem constante nomeada |
| RecordCount p/ testar vazio | CRÍTICO Alto | usar `IsEmpty` |

### DIM-4 — SOLID

- SRP, OCP, DIP aplicados?
- SQL centralizado em units dedicadas ou espalhado em Forms?
- Alto acoplamento (CBO) entre units?

### DIM-5 — Memória

- Objetos sem `try..finally` para garantir `.Free`
- Múltiplos recursos em único `try..finally`
- `Application.CreateForm` em eventos de Forms

### DIM-6 — Acesso a Dados

| Tecnologia | Status |
|-----------|--------|
| BDE | CRÍTICO — descontinuado |
| ADO | ATENÇÃO |
| FireDAC | OK |
| Zeos | OK |

Detectar: SQL com concatenação (SQL Injection), `RecordCount` para testar vazio.

### DIM-7 — Segurança

- Credenciais hardcoded (senha, IP, usuário de BD)
- Controle de acesso e autenticação
- Criptografia de dados sensíveis

### DIM-8 — Manutenibilidade

- Ausência de padrão consistente
- Nomes sem intenção revelada
- Alta dependência de desenvolvedores específicos

---

## §4 — Sistema de pontuação

| Score | Classificação | Recomendação |
|-------|--------------|-------------|
| 4,0–5,0 | BOM | Manutenção direta |
| 3,0–3,9 | REGULAR | Refatoração progressiva |
| 2,0–2,9 | CRÍTICO | Modernização urgente |
| 1,0–1,9 | INVIÁVEL | Reescrita recomendada |

Pontuação por dimensão (1–5), média ponderada = Score Final.

---

## §5 — Flags automáticos

### CRÍTICO (bloqueador de release)
- BDE em Windows 10/11
- Credenciais hardcoded
- SQL Injection evidente
- Ausência total de tratamento de exceções
- Memory leaks sistêmicos (Create sem `try..finally`)
- God Methods com 500+ linhas
- Units com 10.000+ linhas

### ATENÇÃO
- `RecordCount` para testar vazio
- Componentes sem suporte ativo
- Ausência de interfaces / alto acoplamento
- SQL espalhado nos Forms

---

## §6 — Estrutura do laudo (17 seções)

Preencher usando o template do idioma selecionado (`references/estrutura-laudo.md` ou `.en.md`):

1. Identificação do Sistema · 2. Resumo Executivo · 3. Escopo da Análise
4. Ambiente Tecnológico · 5. Análise de Arquitetura · 6. Clean Code e Padrões
7. Code Smells Detectados · 8. Arquitetura Limpa / SOLID · 9. Gestão de Memória
10. Acesso a Dados · 11. Segurança · 12. Pontos Positivos · 13. Pontos Críticos
14. Recomendações · 15. Estimativa de Esforço · 16. Classificação Geral · 17. Conclusão

---

## §7 — Saídas disponíveis

- Laudo completo `.docx` — usar skill `docx` para formatar profissionalmente
- Resumo executivo — 1 página para gestores não técnicos
- Checklist técnico — para equipe de desenvolvimento
- Plano de modernização — roadmap por fases com prioridades e esforço

Ver `references/estimativas-modernizacao.md` para tabela de esforços por tipo.

---

## §8 — Checklist de qualidade — Laudo

- [ ] Idioma detectado e template correto carregado
- [ ] Coleta inicial (Passo 1) completa
- [ ] Todas as 8 dimensões avaliadas
- [ ] Flags CRÍTICO e ATENÇÃO identificados
- [ ] Score calculado com média ponderada
- [ ] Recomendações em 4 horizontes (imediato / curto / médio / estratégico)
- [ ] Estimativa de esforço presente

## Referências cruzadas

- `developer-delphi-coding-standards` — Style Guide e prefixos
- `developer-delphi-testing-dunitx` — cobertura de testes
- `quality-security-audit` — auditoria de segurança OWASP

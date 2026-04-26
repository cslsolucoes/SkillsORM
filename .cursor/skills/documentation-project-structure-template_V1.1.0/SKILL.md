---
name: documentation-project-structure-template
description: Template genérico e portátil para documentação da estrutura de arquivos de um projecto — árvore de directórios do repositório, pacotes e dependências de terceiros organizados por categoria, API pública e encapsulamento, configuração de compilação com saídas, acesso a dados e configuração de runtime incluindo CLI de bancos de dados, módulos externos integrados e documentação relevante com paths canónicos. Inclui placeholders {PLACEHOLDER} e comentários EXAMPLE (ORM) para orientar o preenchimento.
model: haiku
thinking: minimal
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation — Project Structure Template

## Responsabilidade única

Esta skill fornece o template portátil para documentar a estrutura de arquivos e diretórios de qualquer projeto, incluindo árvore de diretórios, dependências de terceiros, API pública, configuração de compilação e acesso a dados. Ela não analisa o código-fonte nem infere a estrutura automaticamente — entrega o esqueleto com placeholders e exemplos ORM para orientar o preenchimento. O escopo é estritamente estrutural: convenções de nomenclatura, padrões de design e roadmap são responsabilidades de outras skills. A portabilidade é garantida pelos placeholders `{PLACEHOLDER}` que isolam as partes específicas do projeto das seções genéricas.

Template portátil para documentação da estrutura de ficheiros e directórios de um projecto.

## When to use

- Ao documentar a estrutura de um projecto novo.
- Ao padronizar a documentação de paths e dependências.
- Como referência para as secções obrigatórias de documentação estrutural.

## When NOT to use

- Quando o objetivo for documentar fundamentos, nomenclatura e padrões de design — use `documentation-project-fundamentals-template`.
- Quando o objetivo for criar o roadmap estratégico — use `documentation-project-roadmap-template`.
- Quando for necessário primeiro escanear o projeto para descobrir a estrutura real — execute `documentation-project-scan` antes desta skill.
- Quando o projeto já tem documentação estrutural e o objetivo for atualizar — use `documentation-project-update`.
- Quando o objetivo for documentar a API HTTP/REST — use `documentation-api-openapi`.

## Estrutura do template

O template contém as seguintes secções:

1. **Responsabilidade** — separação de preocupações entre regras
2. **Pacotes e dependências de terceiros** — localização base e categorias
3. **Árvore de directórios do repositório** — mapa completo com código-fonte, análise, dados, docs, build, libs
4. **API pública e encapsulamento** — interfaces, implementações, módulos integrados
5. **Configuração de compilação** — arquivos de config e saídas
6. **Acesso a dados e configuração de runtime** — config files e CLI de bancos
7. **Módulos externos integrados** — repositórios-fonte e diretivas
8. **Documentação relevante** — paths canónicos

## Dependências (skills prévias)

| Skill | Quando executar antes |
| --- | --- |
| `documentation-project-scan` | Quando a estrutura real do projeto não for conhecida — executar scan para mapear diretórios e arquivos antes de preencher o template |

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| --- | --- | --- |
| Documentar a estrutura sem fazer scan prévio do repositório | Gera documento com árvore de diretórios fictícia ou incompleta | Executar `documentation-project-scan` antes para obter a estrutura real |
| Listar apenas src/ e omitir diretórios de build, docs e config | Documentação estrutural incompleta; desenvolvedores não encontram artefatos de build | Incluir todas as categorias do template: code, docs, build, libs, config |
| Misturar estrutura de arquivos com regras de nomenclatura no mesmo documento | Viola separação de responsabilidades; dificulta manutenção | Manter estrutura neste documento; nomenclatura em `documentation-project-fundamentals-template` |

## Métricas de sucesso

- O documento gerado contém todas as 8 seções da estrutura do template com placeholders identificáveis.
- A árvore de diretórios reflete a estrutura real do repositório (verificada por scan ou fornecida pelo usuário).
- Nenhum path fictício ou inventado foi incluído no documento.

## Responsável principal

| Papel | Quem |
| --- | --- |
| Agent executor | `doc-agent-orchestrator` |
| Revisão humana | Desenvolvedor responsável pela organização do repositório |
| Aprovação final | Tech Lead / Arquiteto do projeto |

---

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.1.0 |

## Changelog (este arquivo)

- 1.1.0 (09/04/2026): Migração V2 — adicionadas seções Responsabilidade única, When NOT to use, Dependências, Anti-padrões, Métricas de sucesso, Responsável principal; frontmatter expandido com thinking: minimal e category: documentation.
- 1.0.0 (04/04/2026): Versão inicial — conteúdo portátil extraído de `project-estrutura_V1.0.1.mdc` durante migração Fase 1.

---
name: documentation-api-openapi
description: Cria ou atualiza documentação de API no formato de referência OpenAPI/Swagger (resumo acionável) dentro do padrão `Documentation/` (preferencialmente em `Documentation/Analise/`).
model: sonnet
thinking: extended
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation API (OpenAPI/Swagger)

## Responsabilidade única

Esta skill é responsável exclusivamente por criar e atualizar documentação de contratos de API no formato OpenAPI/Swagger, produzindo artefatos acionáveis com exemplos, erros e fluxos de sequência. Ela transforma especificações de endpoints dispersas em um documento canônico estruturado dentro do padrão `Documentation/Analise/`. Não executa geração de código-fonte, validação de runtime ou testes de integração — seu escopo é documental. A skill garante que cada endpoint documentado possua exemplos concretos e cobertura de erros, tornando o contrato compreensível para desenvolvedores sem acesso ao código.

## When to use

- Quando o usuário pedir documentação de API, contratos, endpoints, payloads e fluxos (OpenAPI/Swagger).
- Quando o scan identificar lacunas/contratos sem documentação clara.

## When NOT to use

- Quando o objetivo for gerar código-cliente ou SDK a partir do contrato — use a skill de geração de código.
- Quando a necessidade for documentar regras de negócio internas, não contratos HTTP — use `documentation-business-rules`.
- Quando o usuário precisar de documentação de arquitetura de sistema (não de API) — use `documentation-architecture`.
- Quando o contrato já estiver documentado e a necessidade for apenas atualizar changelog — use `documentation-versioning-changelog`.
- Quando o escopo for análise de classes/units internas sem exposição HTTP — use `documentation-class-analysis-generator`.

## Inputs

1. `<topico>`: tópico da API (padrão: `OpenAPI`).
2. `<versao_docs>`: `Vx.y`.
3. `<fontes>`: contratos/rutas/handlers já existentes (pode ser lista textual ou links).
4. `<contexto>`: público, autenticação (quando aplicável), erros e exemplos.

## Outputs

- Arquivo canônico sugerido: `Documentation/Analise/Analise_<topico>_Vx.y.md` (ex.: `Analise_OpenAPI_V1.0.md`)
- Atualização do hub se aplicável (orquestrador).

**Base (ficheiro-modelo):** copiar **`../documentation-analysis-index_V1.1.0/templates/TEMPLATE_Docs_Analise.md`** para o path canônico (ajustar tópico/versão) e adaptar secções ao contrato OpenAPI.

## Passos executáveis

1. Consolidar endpoints/rotas e agrupar por recurso (tags/recursos).
2. Para cada endpoint, registrar:
   - método, path e objetivo
   - parâmetros (query/path/body)
   - respostas (200/4xx/5xx) com exemplos
   - autenticação/autorizações quando necessário
3. Incluir um resumo "fluxo completo":
   - do request ao response
   - exemplos de sequência (quando houver dependência entre chamadas)
4. Validar:
   - não inventar caminhos (usar somente fontes ou explicitar incerteza)
   - fornecer critérios de aceite (ex.: "cada endpoint possui exemplos e erros")

## Critérios de aceite

- Documentação do contrato é acionável com exemplos e erros (não apenas "lista de endpoints").
- Naming/versioning conforme skill `documentation-general_rules` (naming conventions).
- Linguagem e seções seguem o padrão do template.

## Template de saída (arquivo)

O arquivo `Analise_<topico>_Vx.y.md` deve conter:

1. Cabeçalho + escopo
2. Modelo de contrato (resumo do que é a API)
3. Endpoints (por recurso):
   - Endpoint: `<GET/POST/...> <path>`
   - Entradas
   - Saídas (respostas)
   - Erros/validações
   - Exemplos
4. Fluxo de uso (sequência)
5. Checklist final

## Exemplo de referência canônica

- **`../documentation-analysis-index_V1.1.0/templates/TEMPLATE_Docs_Analise.md`**
- `EXEMPLO DE DOCUMENTAÇÃO/Docs/Analise/` (quando existir)

## Dependências (skills prévias)

| Skill | Quando executar antes |
| --- | --- |
| `documentation-general_rules` | Sempre — confirmar naming conventions e padrão de versioning antes de criar o arquivo |
| `documentation-project-scan` | Quando as fontes (endpoints/handlers) não estiverem consolidadas — executar scan antes para identificar contratos existentes |

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| --- | --- | --- |
| Listar endpoints sem exemplos de request/response | Documentação não acionável; desenvolvedor não consegue integrar sem testes | Incluir exemplos concretos (JSON/form) para cada endpoint |
| Inventar paths ou parâmetros não confirmados nas fontes | Introduz contratos fictícios que causam erros de integração | Usar somente fontes fornecidas; marcar explicitamente como "a confirmar" quando incerto |
| Documentar apenas casos de sucesso (200) | Oculta falhas esperadas; integradores não sabem tratar erros | Mapear pelo menos 400, 401/403 e 500 com exemplos de payload de erro |
| Criar arquivo fora do path canônico `Documentation/Analise/` | Quebra rastreabilidade e referências cruzadas do hub | Sempre usar `Documentation/Analise/Analise_<topico>_Vx.y.md` |

## Métricas de sucesso

- Cada endpoint documentado possui pelo menos um exemplo de request, um de response 2xx e um de erro (4xx/5xx).
- O arquivo gerado segue o naming convention `Analise_<topico>_Vx.y.md` e está no diretório `Documentation/Analise/`.
- Critérios de aceite verificáveis listados no checklist final do documento.

## Responsável principal

| Papel | Quem |
| --- | --- |
| Agent executor | `doc-agent-orchestrator` |
| Revisão humana | Desenvolvedor responsável pelo módulo de API |
| Aprovação final | Tech Lead / Arquiteto do projeto |

---

**Changelog (este arquivo):**

- 1.1.0 (09/04/2026): Migração V2 — adicionadas seções Responsabilidade única, When NOT to use, Dependências, Anti-padrões, Métricas de sucesso, Responsável principal; frontmatter expandido com thinking: extended e category: documentation.
- 1.0.1 (27/03/2026): Base física **`../documentation-analysis-index_V1.1.0/templates/TEMPLATE_Docs_Analise.md`** (adaptável a OpenAPI).
- 1.0.0 (27/03/2026): Versão inicial publicada neste repositório.

---

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.1.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.1.0 (09/04/2026): Migração V2 — adicionadas seções Responsabilidade única, When NOT to use, Dependências, Anti-padrões, Métricas de sucesso, Responsável principal; frontmatter expandido com thinking: extended e category: documentation.
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).

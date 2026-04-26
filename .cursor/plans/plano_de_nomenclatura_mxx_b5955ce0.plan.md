---
name: Plano de Nomenclatura MXX
overview: Definir e institucionalizar o padrão de nomenclatura `Modulo.Feature.SubFeature.pas` em inglês, atualizando primeiro a documentação e os artefatos de governança (rules/skills/agents), deixando a renomeação física dos arquivos para fase posterior controlada.
todos:
  - id: spec-naming-format
    content: Especificar formalmente o padrão `Modulo.Feature.SubFeature.pas` e regras de aplicação por camada
    status: completed
  - id: update-documentation-governance
    content: Atualizar documentação do projeto e artefatos em rules/skills/agents responsáveis pela nomenclatura
    status: completed
  - id: prepare-physical-rename-wave
    content: Preparar matriz técnica para renomeação física posterior (arquivo antigo->novo e impactos em uses/build)
    status: completed
isProject: false
---

# Plano de Nomenclatura MXX

## Resumo
Padronizar a nomenclatura de units Pascal do backend para o formato canônico em inglês: `Modulo.Feature.SubFeature.pas` (com subfeature opcional quando fizer sentido). A execução será em duas etapas: primeiro documentação + governança (`rules/skills/agents`), depois renomeação física dos arquivos no código. O objetivo é evitar nomes inconsistentes e preparar uma migração segura com baixo risco de quebra.

## Objectivos
- Formalizar uma convenção única para todos os módulos `MXX-*`.
- Atualizar documentação do projeto para refletir a convenção e exemplos reais.
- Atualizar os artefatos responsáveis de governança em `.cursor/rules`, `.cursor/skills` e `.cursor/agents`.
- Preparar fase 2 com checklist técnico de renomeação física (`.pas`, `uses`, `.dpr`, `.dproj`).

## Âmbito e exclusões
- Em âmbito (Fase 1): documentos em `Documentation/` e governança em `.cursor/`.
- Em âmbito (Fase 2 planejada): renomeação física de arquivos e atualização de referências.
- Fora de âmbito agora: executar a renomeação física imediata no código-fonte.

## Inventário de ficheiros / artefactos
- [e:/GestorERP/Documentation/Estrutura/GestorERP_Estrutura_PROJETO_V1_4_0.md](e:/GestorERP/Documentation/Estrutura/GestorERP_Estrutura_PROJETO_V1_4_0.md) — incluir seção canônica de naming de units com exemplos por camada.
- [e:/GestorERP/Documentation/README.md](e:/GestorERP/Documentation/README.md) — adicionar referência curta para a política de nomenclatura.
- [e:/GestorERP/.cursor/rules/scripts-nomenclature_V1.2.0.mdc](e:/GestorERP/.cursor/rules/scripts-nomenclature_V1.2.0.mdc) — consolidar regra oficial para Pascal backend (`Modulo.Feature.SubFeature`).
- [e:/GestorERP/.cursor/skills/developer-delphi-programming-oop-naming_V1.0.0/SKILL.md](e:/GestorERP/.cursor/skills/developer-delphi-programming-oop-naming_V1.0.0/SKILL.md) — alinhar skill com padrão de nomenclatura por arquivo e por unit.
- [e:/GestorERP/.cursor/skills/documentation-project-structure_V1.0.0/SKILL.md](e:/GestorERP/.cursor/skills/documentation-project-structure_V1.0.0/SKILL.md) — incluir convenção para exemplos de paths/nomes em `MXX-*`.
- [e:/GestorERP/.cursor/agents/developer-delphi-agent-orchestrator_V1.3.0.md](e:/GestorERP/.cursor/agents/developer-delphi-agent-orchestrator_V1.3.0.md) — reforçar handoff de nomenclatura obrigatória nos fluxos Delphi.
- [e:/GestorERP/.cursor/agents/developer-delphi-agent-modules-orchestrator_V1.3.0.md](e:/GestorERP/.cursor/agents/developer-delphi-agent-modules-orchestrator_V1.3.0.md) — reforçar política para `src/Modulos` e módulos `MXX-*`.

## Passos / fases
1. Inventariar nomes atuais em `M01-Seguranca_Acesso` e classificar padrões divergentes.
2. Definir especificação curta da convenção:
   - Formato: `Modulo.Feature.SubFeature.pas`
   - Idioma: inglês
   - Regras para camadas (`Core`, `Commons`, `Modulos`) e sufixos permitidos.
3. Atualizar `Documentation/Estrutura` com seção de nomenclatura + exemplos válidos e inválidos.
4. Atualizar `Documentation/README.md` com link para a seção canônica.
5. Atualizar `scripts-nomenclature` (regra) com critérios mandatórios e exceções.
6. Atualizar skills responsáveis (`developer-delphi-programming-oop-naming`, `documentation-project-structure`) para orientar geração/refatoração.
7. Atualizar agents orquestradores Delphi para exigir a convenção em tarefas futuras.
8. Preparar plano técnico da Fase 2 (renomeação física): matriz `antigo -> novo`, impacto em `uses`, `.dpr/.dproj`, e testes de compilação.

## Dependências e riscos
- Dependência de consenso sobre granularidade de `Feature` vs `SubFeature`.
- Risco de regras conflitantes entre documentação e `.cursor/*` se a atualização não for sincronizada.
- Risco alto na Fase 2 (futura): quebra de `uses` e paths de build após renomeação física.

## Critérios de conclusão
- Convenção `Modulo.Feature.SubFeature.pas` documentada e publicada em `Documentation/`.
- Regra e skills/agents responsáveis atualizados e coerentes.
- Backlog técnico da renomeação física criado com matriz de impacto por arquivo.
- Equipe consegue derivar nome de arquivo/unit de forma determinística para novos módulos `MXX-*`.

## Rollback
- Reverter alterações documentais e de governança para as versões anteriores caso haja divergência operacional.
- Manter a renomeação física fora da execução desta etapa para minimizar risco imediato.

## Referências
- [e:/GestorERP/projects/backend/M01-Seguranca_Acesso](e:/GestorERP/projects/backend/M01-Seguranca_Acesso)
- [e:/GestorERP/projects/modules/ProvidersORM](e:/GestorERP/projects/modules/ProvidersORM)
- [d:/Users/claiton.linhares/.cursor/plans/reestruturacao-mxx-modulos_9d56b638.plan.md](d:/Users/claiton.linhares/.cursor/plans/reestruturacao-mxx-modulos_9d56b638.plan.md)
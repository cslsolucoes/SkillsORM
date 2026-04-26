---
name: developer-delphi-documentation-governance
description: Governança documental das skills e artefatos: padrão de conteúdo, changelog, rastreabilidade e fontes.
model: haiku
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-documentation-governance

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## Responsabilidade única

Esta skill governa a criação e manutenção de documentação técnica das skills e artefatos do projeto: aplica padrões de conteúdo, valida changelogs, mantém rastreabilidade de fontes e atualiza o hub documental consolidado (`.cursor/SKILLS_DOCUMENTATION_vX.Y.Z.md`). Ela NÃO compila código, NÃO implementa features e NÃO define arquitetura de módulos — seu escopo é exclusivamente a qualidade e consistência da documentação técnica do pack.

## When to use

- Criação/manutenção de documentação técnica e governança das skills.
- Atualização do hub documental consolidado após alterações de skills.
- Validação de changelog por arquivo e por versão de pack.

## When NOT to use

- Não usar para compilar código → use `developer-delphi-to-fpc-build`.
- Não usar para implementar módulos a partir de documentação → use `developer-delphi-docs-to-structured-code`.
- Não usar para migrar arquivos de documentação de área protegida sem plan mode → seguir regra de áreas protegidas do CLAUDE.md.
- Não usar para criar regras `.mdc` do Cursor → use `documentation-rules_creator`.
- Não usar para gerar documentação de negócio (RN, arquitetura, roadmap) → use as skills `documentation-*` correspondentes.

## Inputs

- Estrutura de skills, mudanças recentes, fontes utilizadas.

## Workflow executável

1. Atualizar documentação consolidada (`.cursor/SKILLS_DOCUMENTATION_vX.Y.Z.md` — ex.: `SKILLS_DOCUMENTATION_v3.0.8.md`; SemVer do nome = versão do cabeçalho; ver `documentation-general_rules` e `.cursor/VERSION.md`).
2. Validar changelog por arquivo.
3. Atualizar seção de fontes e sublinks por conclusão.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `governance-pack-versioning-policy` | Antes de bumpar versão de skill ou do pack; define as regras SemVer do `.cursor/` |
| `governance-pack-checklist-validation` | Antes de fechar uma migração de pack; valida integridade do conjunto de skills |

## Checklist Delphi+FPC

- [ ] Compilação sem hints/warnings em Delphi (dcc32 + dcc64)
- [ ] Compilação sem hints/warnings em FPC (fpc32 + fpc64)
- [ ] Memory management: Create/Free em try..finally; sem leaks (ReportMemoryLeaksOnShutdown)
- [ ] Tratamento de exceções: hierarquia do projeto (EProviderError ou equivalente)
- [ ] Nomenclatura: prefixos T/I/E/F/A conforme documentation-project-expert
- [ ] Diretivas {$IFDEF} conforme developer-delphi-programming-conditional-defines; sem mistura com paths
- [ ] Separação UI/lógica: zero SQL ou regras de negócio em event handlers
- [ ] Plano inclui validação cross-compiler
- [ ] Referências a compile.md e diretivas_compilacao.md verificadas quando aplicável
- [ ] Diretrizes de compatibilidade presentes nas skills relevantes.
- [ ] Referências operacionais para build/diretivas atualizadas.

## Exemplo mínimo compilável

**Delphi (dcc32 / dcc64):**

```pascal
program SampleDocGovernanceDelphi;
{$APPTYPE CONSOLE}
begin
  WriteLn('OK -- developer-delphi-documentation-governance');
end.
```

**Free Pascal (fpc32 / fpc64):**

```pascal
program SampleDocGovernanceFPC;
{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}
begin
  WriteLn('OK -- developer-delphi-documentation-governance');
end.
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|------------------|---------------|
| Alterar política de execução/risco sem changelog | Torna impossível rastrear quando e por quê a regra mudou | Adicionar entrada de changelog com data, versão e descrição da mudança antes de aplicar |
| Hub documental com SemVer do nome diferente do cabeçalho interno | Cria confusão sobre qual versão está ativa | Garantir que o nome do arquivo `SKILLS_DOCUMENTATION_vX.Y.Z.md` coincide exatamente com o campo `Version` no cabeçalho |
| Skills sem seção de fontes/referências | Dificulta verificação de dados; promove invenção de paths | Adicionar seção `## Referencias` com todos os documentos canônicos consultados |
| Documentação desatualizada após migração de skills | Pack inconsistente; referências quebradas | Executar esta skill como parte do workflow de migração V2 |
| Ignorar a regra de áreas protegidas ao editar `Documentation/` | Viola o plan mode obrigatório do CLAUDE.md | Sempre apresentar plano completo e aguardar aprovação antes de qualquer alteração em área protegida |

## Métricas de sucesso

- Hub documental consolidado com SemVer de nome idêntico ao cabeçalho interno.
- Cada skill com changelog atualizado e referências de fontes completas.
- Zero referências quebradas no hub após migração ou atualização de skills.
- Validação de integridade do pack (`validate_pack.py` ou `governance-pack-checklist-validation`) sem erros.

## Responsável principal

| Papel | Quem |
|-------|------|
| Guardião do pack | Mantenedor principal do `.cursor/` |
| Revisor de changelog | Líder técnico do projeto |

## Avaliacao de risco e confirmacao

- Se alteração documental mudar política de execução/risco do time, confirmar antes.

## Referencias

- `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md`
- `.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md`
- Regras de changelog do plano
- `.cursor/VERSION.md`
- `documentation-general_rules`

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `developer-delphi-documentation-and-governance`; novo prefixo canônico `developer-delphi`. Conteúdo V2 preservado (FileVersion 1.1.0 da origem). Referências a `pack-versioning-policy` e `pack-checklist-validation` atualizadas para `governance-pack-versioning-policy` e `governance-pack-checklist-validation`.

---
name: developer-delphi-packaging-delivery
description: Empacotamento, versionamento e entrega de artefatos Delphi/FPC com critérios de release.
model: haiku
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-packaging-delivery

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## Responsabilidade única

Esta skill cobre o ciclo de empacotamento e entrega de artefatos Delphi/FPC: padronização de nomes e diretórios de artefatos por target (Win32/Win64), validação de build e testes antes do release, geração de pacotes e notas de release com rastreabilidade de versão. Ela NÃO faz modelagem de linguagem, NÃO executa build de compilação e NÃO define testes unitários — apenas orquestra a entrega final após todos os gates anteriores aprovados.

## When to use

- Definição de release, naming de artefatos, checklist de entrega.
- Preparação de pacotes para distribuição com notas de release.
- Validação final de build e testes antes de publicação.

## When NOT to use

- Não usar para modelagem de linguagem → use `developer-delphi-to-fpc-language-core`.
- Não usar para execução do build de compilação → use `developer-delphi-to-fpc-build`.
- Não usar para definir estratégia de testes → use `developer-delphi-testing-and-quality`.
- Não usar para publicação em App Store / Google Play → use `developer-delphi-ios-publishing` (quando aplicável).
- Não usar para gerenciar versão de skills/pack → use `governance-pack-versioning-policy`.

## Inputs

- Versão alvo, plataforma, outputs de build e testes.

## Workflow executável

1. Padronizar nomes e diretórios de artefatos.
2. Validar build e testes.
3. Gerar pacote e notas de release.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-to-fpc-build` | Build Delphi e FPC deve estar limpo (zero erros/warnings) antes do empacotamento |
| `developer-delphi-testing-and-quality` | Gates de testes devem estar aprovados antes de gerar o pacote de release |

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
- [ ] Artefatos Delphi/FPC identificados por target (Win32/Win64).
- [ ] Rastreabilidade de versão e changelog incluídos no pacote.

## Exemplo mínimo compilável

**Delphi (dcc32 / dcc64):**

```pascal
program SampleReleaseTagDelphi;
{$APPTYPE CONSOLE}
const
  RELEASE_TAG = 'v1.0.0';
begin
  WriteLn('OK -- developer-delphi-packaging-delivery: ' + RELEASE_TAG);
end.
```

**Free Pascal (fpc32 / fpc64):**

```pascal
program SampleReleaseTagFPC;
{$IFDEF FPC}{$mode delphi}{$ENDIF}
const
  RELEASE_TAG = 'v1.0.0';
begin
  WriteLn('OK -- developer-delphi-packaging-delivery: ' + RELEASE_TAG);
end.
```

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|------------------|---------------|
| Publicar sem build limpo em ambos compiladores | Artefatos com erros silenciosos chegam ao usuário final | Sempre executar dcc32, dcc64, fpc32, fpc64 e verificar exit code antes de empacotar |
| Naming de artefato sem identificador de target | Impossível distinguir Win32 de Win64 em repositório de releases | Incluir target no nome: `NomeProjeto_v1.0.0_Win64.zip` |
| Release sem notas de mudança | Usuários e operações não sabem o que mudou; rollback sem referência | Gerar `RELEASE_NOTES_vX.Y.Z.md` com changelog e lista de artefatos incluídos |
| Misturar artefatos de debug com release | Binários de debug são maiores e expõem informações internas | Separar diretórios: `dist/debug/` e `dist/release/` |
| Publicar em produção sem confirmação explícita | Implantações não autorizadas em ambientes críticos | Exigir confirmação do responsável antes de qualquer publicação em produção |

## Métricas de sucesso

- Artefatos de release nomeados com versão e target (Win32/Win64).
- Notas de release com changelog versionado geradas para cada entrega.
- Build e testes aprovados (zero erros) antes de qualquer empacotamento.
- Publicação em produção realizada somente após confirmação explícita do responsável.

## Responsável principal

| Papel | Quem |
|-------|------|
| Release manager | Líder técnico do projeto |
| Validador de artefatos | Desenvolvedor responsável pelo módulo |

## Avaliacao de risco e confirmacao

- Publicação em ambiente de produção ou repositório oficial exige confirmação prévia.

## Referencias

- `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md`
- `.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md`
- Changelog do projeto

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `developer-delphi-packaging-and-delivery`; novo prefixo canônico `developer-delphi`. Conteúdo V2 preservado (FileVersion 1.1.0 da origem). Referências internas atualizadas para nomes canônicos.

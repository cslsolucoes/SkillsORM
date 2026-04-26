---
name: developer-delphi-master-orchestrator
description: Orquestra as skills do kit Delphi/FPC por cenário de desenvolvimento, mapeando todas as famílias A—K, com árvore de decisão, guia de quando usar cada skill e rastreabilidade.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-master-orchestrator

## Versão interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.1.0 |

## Responsabilidade única

Esta skill atua como ponto central de coordenação para tarefas multi-etapa no kit Delphi/FPC. Classifica o cenário de desenvolvimento, seleciona e ordena as skills especializadas necessárias, aplica gates de risco antes de ações destrutivas e consolida evidências de build, testes e documentação ao final do fluxo. Não executa implementações diretas — delega a skills especializadas com rastreabilidade explícita de cada etapa.

## When to use

- Tarefas multi-etapa que envolvem mais de uma skill.
- Quando não se sabe qual skill especializada usar — esta skill orienta via árvore de decisão.

## When NOT to use

- Mudanças pequenas de um único domínio — usar a skill especializada diretamente (ex.: `developer-delphi-to-fpc-language-core` para ajuste de sintaxe).
- Consultas pontuais sobre uma API ou unit específica — usar `developer-delphi-to-fpc-rtl-and-units`.
- Análise isolada de performance sem impacto em arquitetura — usar `developer-delphi-to-fpc-performance-and-memory`.
- Publicação iOS sem etapas de build/testes adicionais — usar `developer-delphi-ios-publishing` diretamente.
- Geração de documentação standalone — usar `developer-delphi-documentation-governance`.

## Inputs

- Objetivo da tarefa, escopo técnico e restrições.

---

## Mapa completo de skills — Famílias A—K

### Família A — FMX Layout (UI Desktop)

| Skill | Versão | Responsabilidade |
| ----- | ------ | ---------------- |
| `developer-delphi-fmx-layout` | V1.1.0 | **Orquestradora FMX** — coordena layout, anchors, alinhamento, responsividade |
| `developer-delphi-fmx-containers` | V1.0.0 | TLayout, TScrollBox, TGridLayout, TFlowLayout, TVertScrollBox |
| `developer-delphi-fmx-animations` | V1.0.0 | TAnimation, TFloatAnimation, TColorAnimation, triggers de animação |
| `developer-delphi-fmx-effects` | V1.0.0 | TShadowEffect, TBlurEffect, TGlowEffect, TBevelEffect |
| `developer-delphi-fmx-components` | V1.0.0 | TButton, TEdit, TLabel, TComboBox, TListView, TTreeView e demais |
| `developer-delphi-fmx-frames` | V1.0.0 | TFrame, composição e reutilização de frames em FMX |
| `developer-delphi-fmx-patterns` | V1.0.0 | Padrões reutilizáveis: cards, modais, CRUD screens, master-detail |

### Família B — Linguagem Core (Pascal/Delphi)

| Skill | Versão | Responsabilidade |
| ----- | ------ | ---------------- |
| `developer-delphi-to-fpc-language-core` | V1.1.0 | **Orquestradora Linguagem** — sintaxe, estrutura de units, compatibilidade Delphi+FPC |
| `developer-delphi-to-fpc-language-types` | V1.1.0 | Tipos primitivos, records, enums, sets, type aliases, variant records |
| `developer-delphi-to-fpc-language-oop` | V1.1.0 | Classes, herança, interfaces, visibilidade, construtores, destrutores |
| `developer-delphi-to-fpc-language-generics` | V1.1.0 | TList\<T\>, TDictionary\<K,V\>, constraints, generic methods |
| `developer-delphi-to-fpc-language-rtti` | V1.1.0 | TRttiContext, atributos, inspeção de propriedades/métodos em runtime |
| `developer-delphi-to-fpc-language-advanced` | V1.1.0 | Closures, anonymous methods, operator overloading, helpers, ARC |

### Família C — Patterns (Design Patterns)

| Skill | Versão | Responsabilidade |
| ----- | ------ | ---------------- |
| `developer-delphi-to-fpc-patterns-composition` | V1.1.0 | **Orquestradora Patterns** — composição, DI, IoC, seleção de padrão correto |
| `developer-delphi-to-fpc-patterns-creational` | V1.1.0 | Factory, Abstract Factory, Builder, Singleton, Prototype |
| `developer-delphi-to-fpc-patterns-structural` | V1.1.0 | Adapter, Bridge, Composite, Decorator, Facade, Proxy |
| `developer-delphi-to-fpc-patterns-behavioral` | V1.1.0 | Observer, Strategy, Command, Chain of Responsibility, Visitor, State |

### Família D — RTL (Runtime Library)

| Skill | Versão | Responsabilidade |
| ----- | ------ | ---------------- |
| `developer-delphi-to-fpc-rtl-and-units` | V1.1.0 | **Orquestradora RTL** — SysUtils, Math, DateUtils, IOUtils, System.* |
| `developer-delphi-to-fpc-rtl-collections` | V1.1.0 | TList, TObjectList, TDictionary, TQueue, TStack, THashSet |
| `developer-delphi-to-fpc-rtl-streams-io` | V1.1.0 | TStream, TFileStream, TMemoryStream, TReader, TWriter, JSON/XML I/O |
| `developer-delphi-to-fpc-rtl-strings` | V1.1.0 | TStringHelper, TStringBuilder, TRegEx, encoding, format, parse |

### Família E — Concorrência e Performance

| Skill | Versão | Responsabilidade |
| ----- | ------ | ---------------- |
| `developer-delphi-to-fpc-threading-basics` | V1.1.0 | TThread, Synchronize, Queue, seções críticas, mutexes básicos |
| `developer-delphi-to-fpc-threading-advanced` | V1.1.0 | TTask, PPL (Parallel Programming Library), TParallel.For, futures |
| `developer-delphi-to-fpc-performance-profiling` | V1.0.0 | AQTime, Sampling Profiler, instrumentação, gargalos de CPU/memória |
| `developer-delphi-to-fpc-performance-and-memory` | V1.0.0 | **Orquestradora Memória** — FastMM, leaks, alocações, gerenciamento ARC/manual |
| `developer-delphi-to-fpc-performance-and-architecture` | V1.0.0 | **Orquestradora Arquitetura de Performance** — cache, I/O assíncrono, pooling |

### Família F — Qualidade e Testes

| Skill | Versão | Responsabilidade |
| ----- | ------ | ---------------- |
| `developer-delphi-testing-and-quality` | V1.0.0 | **Orquestradora Qualidade** — estratégia, cobertura, CI, code review |
| `developer-delphi-testing-dunitx` | V1.0.0 | DUnitX: TestFixture, Test, Setup, TearDown, Assert, mocks |
| `developer-delphi-testing-integration` | V1.0.0 | Testes de integração: banco, API REST, serviços externos, fixtures |

### Família G — Build e Entrega

| Skill | Versão | Responsabilidade |
| ----- | ------ | ---------------- |
| `developer-delphi-to-fpc-build` | V1.0.0 | dcc32, dcc64, fpc32, fpc64, cfg/opts, defines, flags CLI |
| `developer-delphi-packaging-delivery` | V1.0.0 | Instaladores, pacotes BPL, deploy, versionamento de release |

### Família H — Diagnóstico e Debug

| Skill | Versão | Responsabilidade |
| ----- | ------ | ---------------- |
| `developer-delphi-to-fpc-error-handling-and-diagnostics` | V1.0.0 | Hierarquia de exceções, try/except/finally, logging, relatórios de erro |
| `developer-delphi-debugging-techniques` | V1.0.0 | Breakpoints condicionais, watch, call stack, CodeSite, MadExcept |

### Família I — Arquitetura

| Skill | Versão | Responsabilidade |
| ----- | ------ | ---------------- |
| `developer-delphi-to-fpc-architecture-and-design` | V1.0.0 | DDD, Clean Architecture, SOLID, camadas, migração de monólito |
| `developer-delphi-to-fpc-architecture-modules` | V1.0.0 | Packages BPL, módulos runtime/designtime, dependências entre packages |

### Família J — Assembly (x86/x64)

| Skill | Versão | Responsabilidade |
| ----- | ------ | ---------------- |
| `developer-delphi-assembly-orchestrator` | V1.1.0 | **Orquestradora Assembly** — decide quando e qual skill assembly invocar |
| `developer-assembly-x86-fundamentals` | V1.0.0 | Fundamentos x86: modos real/protegido, segmentos, endereçamento |
| `developer-assembly-registers` | V1.0.0 | Registradores gerais, de segmento, de controle (EAX..R15, flags) |
| `developer-assembly-instructions` | V1.0.0 | MOV, ADD, SUB, CMP, JMP, CALL, LEA e conjunto completo de instruções |
| `developer-assembly-stack-call` | V1.0.0 | Stack frame, PUSH/POP, ESP/EBP, prologue/epilogue de funções |
| `developer-delphi-assembly-calling-conventions` | V1.0.0 | register, pascal, cdecl, stdcall, fastcall — como Delphi/FPC escolhe |
| `developer-delphi-assembly-inline` | V1.0.0 | Bloco `asm...end` inline em Delphi, restrições e boas práticas |
| `developer-delphi-assembly-functions` | V1.0.0 | Funções puras em assembly, linkagem externa, exports |
| `developer-delphi-assembly-simd-avx` | V1.0.0 | SSE, SSE2, AVX, AVX2 — vetorização de loops e operações SIMD |
| `developer-delphi-assembly-expressions` | V1.0.0 | Expressões de endereçamento, operadores de assembly, offsets |
| `developer-delphi-assembly-debugging` | V1.0.0 | Debug de código assembly: CPU view, disassembly, breakpoints em ASM |

### Família K — Mobile (iOS e Android)

| Skill | Versão | Responsabilidade |
| ----- | ------ | ---------------- |
| `developer-delphi-mobile-orchestrator` | V1.1.0 | **Orquestradora Mobile** — seleciona plataforma, configura SDK, coordena deploy |
| `developer-delphi-ios-setup` | V1.0.0 | Configuração PAServer, certificados, provisioning profiles, entitlements |
| `developer-delphi-android-setup` | V1.0.0 | Android SDK, NDK, ADB, configuração de device, permissões de manifesto |
| `developer-delphi-ios-publishing` | V1.0.0 | App Store Connect, TestFlight, ipa assinado, submissão e revisão |
| `developer-delphi-android-publishing` | V1.0.0 | Google Play Console, APK/AAB assinado, trilha de testes, publicação |

---

## Matriz de roteamento rápido

| Cenário | Skill de entrada |
| ------- | ---------------- |
| Linguagem/sintaxe | `developer-delphi-to-fpc-language-core` |
| RTL/units | `developer-delphi-to-fpc-rtl-and-units` |
| Build/CLI | `developer-delphi-to-fpc-build` |
| Arquitetura/DI/migração | `developer-delphi-to-fpc-architecture-and-design` |
| Qualidade/testes | `developer-delphi-testing-and-quality` |
| Exceções/diagnóstico | `developer-delphi-to-fpc-error-handling-and-diagnostics` |
| Performance/memória | `developer-delphi-to-fpc-performance-and-memory` |
| Packaging/release | `developer-delphi-packaging-delivery` |
| UI FMX | `developer-delphi-fmx-layout` |
| Assembly inline | `developer-delphi-assembly-inline` |
| Assembly geral | `developer-delphi-assembly-orchestrator` |
| Mobile iOS | `developer-delphi-ios-setup` ’ `developer-delphi-ios-publishing` |
| Mobile Android | `developer-delphi-android-setup` ’ `developer-delphi-android-publishing` |

---

## Workflow executável

1. Classificar o cenário (UI, linguagem, build, arquitetura, testes, assembly, mobile, etc.).
2. Selecionar a família e a skill de entrada (matriz acima ou `consultas_rapidas/arvore_decisao.md`).
3. Verificar risco antes de qualquer execução destrutiva.
4. Consolidar evidências ao final de cada etapa (build log, resultado de testes, changelog).

## Dependências (skills prévias)

| Skill | Quando executar antes |
| ----- | --------------------- |
| `developer-delphi-to-fpc-build` | Antes de qualquer execução de build no fluxo orquestrado |
| `documentation-project-expert` | Quando houver dúvida sobre nomenclatura, prefixos ou padrões |
| `governance-refactoring-compatibility-policy` | Antes de renomear classes, métodos ou units no fluxo |

## Checklist Delphi+FPC

- [ ] Compilação sem hints/warnings em Delphi (dcc32 + dcc64)
- [ ] Compilação sem hints/warnings em FPC (fpc32 + fpc64)
- [ ] Memory management: Create/Free em try..finally; sem leaks (`ReportMemoryLeaksOnShutdown`)
- [ ] Tratamento de exceções: hierarquia do projeto (`EProviderError` ou equivalente)
- [ ] Nomenclatura: prefixos `T`/`I`/`E`/`F`/`A` conforme `documentation-project-expert`
- [ ] Diretivas `{$IFDEF}` conforme `developer-delphi-programming-conditional-defines`; sem mistura com paths
- [ ] Separação UI/lógica: zero SQL ou regras de negócio em event handlers
- [ ] Plano inclui validação cross-compiler
- [ ] Referências a `compile.md` e `diretivas_compilacao.md` verificadas quando aplicável

## Exemplo mínimo compilável

**Delphi (dcc32/dcc64):**

```pascal
program SampleOrchestrator;
{$APPTYPE CONSOLE}
begin
  WriteLn('OK -- developer-delphi-master-orchestrator V1.1.0');
end.
```

**Free Pascal (fpc):**

```pascal
program SampleOrchestratorFPC;
{$IF DEFINED(FPC)}
  {$mode delphi}
{$ENDIF}
begin
  WriteLn('OK -- developer-delphi-master-orchestrator V1.1.0');
end.
```

## Avaliacao de risco e confirmacao

- Qualquer ação destrutiva/irreversível ou de alto impacto deve ser confirmada com o usuário antes da execução.

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| ----------- | ---------------- | ------------- |
| Executar múltiplas skills sem plano de ordem | Gera conflitos entre etapas e dificulta rollback | Montar matriz de dependências antes de iniciar; documentar ordem explícita |
| Pular gate de risco para "economizar tempo" | Ações destrutivas sem confirmação podem causar perda irreversível de dados ou código | Apresentar resumo de impacto e aguardar aprovação antes de qualquer ação de risco |
| Consolidar evidências apenas ao final | Falhas intermediárias ficam sem rastreio e o rollback parcial se torna impossível | Registrar evidência (build log, resultado de teste) ao completar cada etapa |
| Usar a orquestradora para tarefas de domínio único | Overhead desnecessário de classificação | Acionar a skill especializada diretamente |

## Métricas de sucesso

- Todas as skills invocadas produzem artefatos sem erros/warnings de compilação em ambos os compiladores.
- Cada etapa do fluxo possui evidência registrada (log de build, resultado de teste, changelog atualizado).
- Nenhuma ação de alto risco foi executada sem confirmação explícita do usuário.

## Responsável principal

| Papel | Quem |
| ----- | ---- |
| Executor | `developer-delphi-master-orchestrator` (esta skill) |
| Revisor de código | `developer-delphi-testing-and-quality` |
| Governança/changelog | `developer-delphi-documentation-governance` |

## Consultas rápidas

- `consultas_rapidas/mapa_completo.md` — tabela: família | skill | responsabilidade
- `consultas_rapidas/arvore_decisao.md` — "O que quero fazer?" ’ qual skill consultar
- `consultas_rapidas/quando_usar_cada.md` — cenários comuns + skills recomendadas

## Referencias

- skill `developer-delphi-build-toolchain` (exemplos: `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md`)
- skill `developer-delphi-programming-conditional-defines` (exemplos: `.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md`)

---

## Changelog (este arquivo)

- 1.1.0 (11/04/2026): Expansão para famílias A—K (39+ skills); adicionadas famílias J (Assembly, 11 skills) e K (Mobile, 5 skills); atualizada matriz de roteamento; criados arquivos de consulta rápida em `consultas_rapidas/`.
- 1.0.0 (09/04/2026): Versão inicial. Prefixo canônico `developer-delphi`. Famílias A—I.
- 1.2.0 (24/04/2026): Rename E5a — `developer-delphi-master-orchestrator` -> `developer-delphi-master-orchestrator`. Motivo: diferenciar master-orchestrator de sub-orchestrators (regra N3 do plano de refactor).

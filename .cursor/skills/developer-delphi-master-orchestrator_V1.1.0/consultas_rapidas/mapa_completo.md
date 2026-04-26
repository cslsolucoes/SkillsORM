# Mapa completo de skills — developer-delphi

> Referência rápida: família, skill, versão e responsabilidade principal.
> Atualizado em: 11/04/2026 — FileVersion 1.1.0

---

## Família A — FMX Layout (UI Desktop)

| Família | Skill | Versão | Tipo | Responsabilidade principal |
| ------- | ----- | ------ | ---- | -------------------------- |
| A | `developer-delphi-fmx-layout` | V1.1.0 | Orquestradora | Coordena layout, anchors, alinhamento, responsividade FMX |
| A | `developer-delphi-fmx-containers` | V1.0.0 | Especialista | TLayout, TScrollBox, TGridLayout, TFlowLayout, TVertScrollBox |
| A | `developer-delphi-fmx-animations` | V1.0.0 | Especialista | TAnimation, TFloatAnimation, TColorAnimation, triggers |
| A | `developer-delphi-fmx-effects` | V1.0.0 | Especialista | TShadowEffect, TBlurEffect, TGlowEffect, TBevelEffect |
| A | `developer-delphi-fmx-components` | V1.0.0 | Especialista | TButton, TEdit, TLabel, TComboBox, TListView, TTreeView |
| A | `developer-delphi-fmx-frames` | V1.0.0 | Especialista | TFrame, composição e reutilização de frames FMX |
| A | `developer-delphi-fmx-patterns` | V1.0.0 | Especialista | Padrões reutilizáveis: cards, modais, CRUD, master-detail |

---

## Família B — Linguagem Core

| Família | Skill | Versão | Tipo | Responsabilidade principal |
| ------- | ----- | ------ | ---- | -------------------------- |
| B | `developer-delphi-to-fpc-language-core` | V1.1.0 | Orquestradora | Sintaxe, estrutura de units, compatibilidade Delphi+FPC |
| B | `developer-delphi-to-fpc-language-types` | V1.1.0 | Especialista | Tipos primitivos, records, enums, sets, type aliases |
| B | `developer-delphi-to-fpc-language-oop` | V1.1.0 | Especialista | Classes, herança, interfaces, visibilidade, construtores |
| B | `developer-delphi-to-fpc-language-generics` | V1.1.0 | Especialista | TList\<T\>, TDictionary\<K,V\>, constraints, generic methods |
| B | `developer-delphi-to-fpc-language-rtti` | V1.1.0 | Especialista | TRttiContext, atributos, inspeção de propriedades/métodos |
| B | `developer-delphi-to-fpc-language-advanced` | V1.1.0 | Especialista | Closures, anonymous methods, operator overloading, helpers |

---

## Família C — Patterns (Design Patterns)

| Família | Skill | Versão | Tipo | Responsabilidade principal |
| ------- | ----- | ------ | ---- | -------------------------- |
| C | `developer-delphi-to-fpc-patterns-composition` | V1.1.0 | Orquestradora | Composição, DI, IoC, seleção do padrão correto |
| C | `developer-delphi-to-fpc-patterns-creational` | V1.1.0 | Especialista | Factory, Abstract Factory, Builder, Singleton, Prototype |
| C | `developer-delphi-to-fpc-patterns-structural` | V1.1.0 | Especialista | Adapter, Bridge, Composite, Decorator, Facade, Proxy |
| C | `developer-delphi-to-fpc-patterns-behavioral` | V1.1.0 | Especialista | Observer, Strategy, Command, Chain of Responsibility, State |

---

## Família D — RTL (Runtime Library)

| Família | Skill | Versão | Tipo | Responsabilidade principal |
| ------- | ----- | ------ | ---- | -------------------------- |
| D | `developer-delphi-to-fpc-rtl-and-units` | V1.1.0 | Orquestradora | SysUtils, Math, DateUtils, IOUtils, System.* |
| D | `developer-delphi-to-fpc-rtl-collections` | V1.1.0 | Especialista | TList, TObjectList, TDictionary, TQueue, TStack, THashSet |
| D | `developer-delphi-to-fpc-rtl-streams-io` | V1.1.0 | Especialista | TStream, TFileStream, TMemoryStream, JSON/XML I/O |
| D | `developer-delphi-to-fpc-rtl-strings` | V1.1.0 | Especialista | TStringHelper, TStringBuilder, TRegEx, encoding, format |

---

## Família E — Concorrência e Performance

| Família | Skill | Versão | Tipo | Responsabilidade principal |
| ------- | ----- | ------ | ---- | -------------------------- |
| E | `developer-delphi-to-fpc-threading-basics` | V1.1.0 | Especialista | TThread, Synchronize, Queue, seções críticas, mutexes |
| E | `developer-delphi-to-fpc-threading-advanced` | V1.1.0 | Especialista | TTask, PPL, TParallel.For, futures, continuações |
| E | `developer-delphi-to-fpc-performance-profiling` | V1.0.0 | Especialista | AQTime, Sampling Profiler, gargalos de CPU/memória |
| E | `developer-delphi-to-fpc-performance-and-memory` | V1.0.0 | Orquestradora | FastMM, leaks, alocações, gerenciamento ARC/manual |
| E | `developer-delphi-to-fpc-performance-and-architecture` | V1.0.0 | Orquestradora | Cache, I/O assíncrono, pooling, arquitetura de performance |

---

## Família F — Qualidade e Testes

| Família | Skill | Versão | Tipo | Responsabilidade principal |
| ------- | ----- | ------ | ---- | -------------------------- |
| F | `developer-delphi-testing-and-quality` | V1.0.0 | Orquestradora | Estratégia de testes, cobertura, CI, code review |
| F | `developer-delphi-testing-dunitx` | V1.0.0 | Especialista | DUnitX: TestFixture, Test, Setup, TearDown, Assert, mocks |
| F | `developer-delphi-testing-integration` | V1.0.0 | Especialista | Integração: banco, API REST, serviços externos, fixtures |

---

## Família G — Build e Entrega

| Família | Skill | Versão | Tipo | Responsabilidade principal |
| ------- | ----- | ------ | ---- | -------------------------- |
| G | `developer-delphi-to-fpc-build` | V1.0.0 | Especialista | dcc32, dcc64, fpc32, fpc64, cfg/opts, defines, flags CLI |
| G | `developer-delphi-packaging-delivery` | V1.0.0 | Especialista | Instaladores, pacotes BPL, deploy, versionamento de release |

---

## Família H — Diagnóstico e Debug

| Família | Skill | Versão | Tipo | Responsabilidade principal |
| ------- | ----- | ------ | ---- | -------------------------- |
| H | `developer-delphi-to-fpc-error-handling-and-diagnostics` | V1.0.0 | Especialista | Hierarquia de exceções, try/except/finally, logging |
| H | `developer-delphi-debugging-techniques` | V1.0.0 | Especialista | Breakpoints condicionais, watch, CodeSite, MadExcept |

---

## Família I — Arquitetura

| Família | Skill | Versão | Tipo | Responsabilidade principal |
| ------- | ----- | ------ | ---- | -------------------------- |
| I | `developer-delphi-to-fpc-architecture-and-design` | V1.0.0 | Especialista | DDD, Clean Architecture, SOLID, camadas, migração |
| I | `developer-delphi-to-fpc-architecture-modules` | V1.0.0 | Especialista | Packages BPL, módulos runtime/designtime, dependências |

---

## Família J — Assembly (x86/x64)

| Família | Skill | Versão | Tipo | Responsabilidade principal |
| ------- | ----- | ------ | ---- | -------------------------- |
| J | `developer-delphi-assembly-orchestrator` | V1.1.0 | Orquestradora | Decide quando e qual skill assembly invocar |
| J | `developer-assembly-x86-fundamentals` | V1.0.0 | Especialista | Fundamentos x86: modos, segmentos, endereçamento |
| J | `developer-assembly-registers` | V1.0.0 | Especialista | Registradores gerais, de segmento, de controle, flags |
| J | `developer-assembly-instructions` | V1.0.0 | Especialista | MOV, ADD, SUB, CMP, JMP, CALL, LEA — conjunto completo |
| J | `developer-assembly-stack-call` | V1.0.0 | Especialista | Stack frame, PUSH/POP, ESP/EBP, prologue/epilogue |
| J | `developer-delphi-assembly-calling-conventions` | V1.0.0 | Especialista | register, pascal, cdecl, stdcall, fastcall |
| J | `developer-delphi-assembly-inline` | V1.0.0 | Especialista | Bloco `asm...end` inline, restrições, boas práticas |
| J | `developer-delphi-assembly-functions` | V1.0.0 | Especialista | Funções puras em assembly, linkagem externa, exports |
| J | `developer-delphi-assembly-simd-avx` | V1.0.0 | Especialista | SSE, SSE2, AVX, AVX2 — vetorização e operações SIMD |
| J | `developer-delphi-assembly-expressions` | V1.0.0 | Especialista | Expressões de endereçamento, operadores, offsets |
| J | `developer-delphi-assembly-debugging` | V1.0.0 | Especialista | CPU view, disassembly, breakpoints em código ASM |

---

## Família K — Mobile (iOS e Android)

| Família | Skill | Versão | Tipo | Responsabilidade principal |
| ------- | ----- | ------ | ---- | -------------------------- |
| K | `developer-delphi-mobile-orchestrator` | V1.1.0 | Orquestradora | Seleciona plataforma, configura SDK, coordena deploy mobile |
| K | `developer-delphi-ios-setup` | V1.0.0 | Especialista | PAServer, certificados, provisioning profiles, entitlements |
| K | `developer-delphi-android-setup` | V1.0.0 | Especialista | Android SDK, NDK, ADB, device, permissões de manifesto |
| K | `developer-delphi-ios-publishing` | V1.0.0 | Especialista | App Store Connect, TestFlight, ipa assinado, submissão |
| K | `developer-delphi-android-publishing` | V1.0.0 | Especialista | Google Play Console, APK/AAB assinado, publicação |

---

## Totais por família

| Família | Nome | Skills | Orquestradoras |
| ------- | ---- | ------ | -------------- |
| A | FMX Layout | 7 | 1 |
| B | Linguagem Core | 6 | 1 |
| C | Patterns | 4 | 1 |
| D | RTL | 4 | 1 |
| E | Concorrência/Performance | 5 | 2 |
| F | Qualidade/Testes | 3 | 1 |
| G | Build/Entrega | 2 | 0 |
| H | Diagnóstico/Debug | 2 | 0 |
| I | Arquitetura | 2 | 0 |
| J | Assembly | 11 | 1 |
| K | Mobile | 5 | 1 |
| **Total** | | **51** | **9** |

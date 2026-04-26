# Arvore de decisao — developer-delphi

> Use esta arvore para identificar rapidamente qual skill (ou familia) consultar.
> Atualizado em: 11/04/2026 — FileVersion 1.1.0

---

```
Quero fazer UI?
  |
  +-- FMX Desktop
  |     --> Familia A: fmx-layout (orquestradora)
  |           |
  |           +-- Preciso de containers/scroll?
  |           |     --> fmx-containers
  |           |
  |           +-- Preciso de animacoes?
  |           |     --> fmx-animations
  |           |
  |           +-- Preciso de sombra/blur/glow?
  |           |     --> fmx-effects
  |           |
  |           +-- Preciso de botoes, edits, listas?
  |           |     --> fmx-components
  |           |
  |           +-- Preciso de frames reutilizaveis?
  |           |     --> fmx-frames
  |           |
  |           +-- Preciso de cards/modais/CRUD screens?
  |                 --> fmx-patterns
  |
  +-- FMX Mobile
        --> Familia K: mobile-orchestrator (orquestradora)
              |
              +-- iOS
              |     --> ios-setup --> ios-publishing
              |
              +-- Android
                    --> android-setup --> android-publishing


Quero escrever codigo Pascal?
  |
  +-- Tipos, records, enums, sets
  |     --> Familia B: language-types
  |
  +-- Classes, heranca, interfaces, OOP
  |     --> Familia B: language-oop
  |
  +-- Generics (TList<T>, TDictionary<K,V>)
  |     --> Familia B: language-generics
  |
  +-- RTTI, atributos, inspecao em runtime
  |     --> Familia B: language-rtti
  |
  +-- Closures, anonymous methods, helpers
  |     --> Familia B: language-advanced
  |
  +-- Duvida geral sobre sintaxe/compatibilidade
        --> Familia B: language-core (orquestradora)


Quero aplicar padroes de projeto?
  |
  +-- Criar objetos (Factory, Builder, Singleton)
  |     --> Familia C: patterns-creational
  |
  +-- Compor estruturas (Adapter, Decorator, Facade)
  |     --> Familia C: patterns-structural
  |
  +-- Comportamentos (Observer, Strategy, Command)
  |     --> Familia C: patterns-behavioral
  |
  +-- Duvida sobre qual padrao usar / DI / IoC
        --> Familia C: patterns-composition (orquestradora)


Quero manipular dados, strings ou I/O?
  |
  +-- Colecoes (listas, dicionarios, filas)
  |     --> Familia D: rtl-collections
  |
  +-- Streams, arquivos, JSON, XML
  |     --> Familia D: rtl-streams-io
  |
  +-- Strings, regex, encoding, formatacao
  |     --> Familia D: rtl-strings
  |
  +-- Duvida sobre RTL geral (SysUtils, Math, DateUtils)
        --> Familia D: rtl-and-units (orquestradora)


Quero concorrencia ou melhorar performance?
  |
  +-- Threads simples (TThread, Synchronize)
  |     --> Familia E: threading-basics
  |
  +-- PPL / TTask / TParallel.For
  |     --> Familia E: threading-advanced
  |
  +-- Medir gargalos de CPU/memoria (profiling)
  |     --> Familia E: performance-profiling
  |
  +-- Gerenciar memoria, FastMM, leaks
  |     --> Familia E: performance-and-memory (orquestradora)
  |
  +-- Arquitetura de performance (cache, pooling, I/O async)
        --> Familia E: performance-and-architecture (orquestradora)


Quero qualidade e testes?
  |
  +-- Testes unitarios com DUnitX
  |     --> Familia F: testing-dunitx
  |
  +-- Testes de integracao (banco, API, servicos)
  |     --> Familia F: testing-integration
  |
  +-- Estrategia geral, cobertura, CI
        --> Familia F: testing-and-quality (orquestradora)


Quero fazer build ou deploy?
  |
  +-- Compilar (dcc32, dcc64, fpc32, fpc64)
  |     --> Familia G: build-cross-compiler
  |
  +-- Gerar instalador / pacotes BPL / release
        --> Familia G: packaging-delivery


Quero depurar ou tratar erros?
  |
  +-- Excecoes, logging, relatorios de erro
  |     --> Familia H: error-handling-and-diagnostics
  |
  +-- Debug no IDE (breakpoints, watch, call stack)
        --> Familia H: debugging-techniques


Quero decidir arquitetura?
  |
  +-- DDD, Clean Arch, SOLID, camadas, migracao
  |     --> Familia I: architecture-and-design
  |
  +-- Packages BPL, modulos, dependencias
        --> Familia I: architecture-modules


Quero escrever Assembly?
  |
  +-- Nao sei por onde comecar
  |     --> Familia J: assembly-orchestrator (orquestradora)
  |
  +-- Fundamentos x86 (modos, segmentos)
  |     --> Familia J: assembly-x86-fundamentals
  |
  +-- Registradores (EAX..R15, flags)
  |     --> Familia J: assembly-registers
  |
  +-- Conjunto de instrucoes (MOV, ADD, JMP...)
  |     --> Familia J: assembly-instructions
  |
  +-- Stack frame / calling conventions
  |     +-- Prologue/epilogue, ESP/EBP --> assembly-stack-call
  |     +-- register, cdecl, stdcall   --> assembly-calling-conventions
  |
  +-- Assembly inline no Delphi (asm...end)
  |     --> Familia J: assembly-delphi-inline
  |
  +-- Funcoes puras em assembly / exports
  |     --> Familia J: assembly-delphi-functions
  |
  +-- SIMD / vetorizacao (SSE, AVX)
  |     --> Familia J: assembly-simd-avx
  |
  +-- Expressoes de enderecamento
  |     --> Familia J: assembly-expressions
  |
  +-- Debug de codigo assembly (CPU view, disassembly)
        --> Familia J: assembly-debugging


Quero publicar app mobile?
  |
  +-- iOS
  |     +-- Configuracao inicial  --> Familia K: ios-setup
  |     +-- Publicar na App Store --> Familia K: ios-publishing
  |
  +-- Android
  |     +-- Configuracao inicial  --> Familia K: android-setup
  |     +-- Publicar no Google Play --> Familia K: android-publishing
  |
  +-- Duvida sobre plataforma / SDK / PAServer
        --> Familia K: mobile-orchestrator (orquestradora)
```

---

## Regra de ouro

> Se a tarefa envolver **mais de uma familia**, usar `developer-delphi-master-orchestrator` como ponto de entrada.
> Se a tarefa for de **dominio unico**, ir direto a skill especializada da familia correspondente.
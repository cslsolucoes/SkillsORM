---
name: developer-delphi-to-fpc-patterns-behavioral
description: Padrões comportamentais em Delphi — Strategy, Observer, Command, Chain of Responsibility, Mediator, State.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-patterns-behavioral_V1.1.0

## Propósito

Dominar padrões comportamentais em Delphi: Strategy, Observer, Command+Undo, Chain of Responsibility, Mediator, State e Iterator. Foco em comunicação desacoplada entre objetos via interface.

## Quando usar esta skill

- Algoritmos intercambiáveis em runtime (Strategy)
- Notificação automática de mudanças de estado (Observer)
- Operações reversíveis com histórico (Command + Undo)
- Processamento sequencial com responsabilidade distribuída (Chain of Responsibility)
- Desacoplar componentes que se comunicam entre si (Mediator)
- Comportamento que muda conforme estado interno (State)
- Iterar sobre coleção customizada com `for..in` (Iterator)

## Conteúdo

### exemplos/

| Arquivo | Tema |
|---------|------|
| `strategy.pas` | ISortStrategy: BubbleSort, QuickSort, MergeSort intercambiáveis |
| `observer.pas` | IObserver/ISubject; multicast com TList<IObserver> |
| `command.pas` | ICommand com Execute/Undo; TCommandHistory com desfazer |
| `chain_of_resp.pas` | Pipeline de handlers: aprovação de crédito por alçada |
| `mediator.pas` | TMediator desacopla componentes UI que se afetam mutuamente |
| `state.pas` | Máquina de estados: IState + TContext (pedido: aguardando/processando/entregue) |
| `iterator.pas` | IEnumerator<T>; for..in em coleção filtrada customizada |

### consultas_rapidas/

| Arquivo | Tema |
|---------|------|
| `behavioral_quando.md` | Tabela: qual pattern para qual problema comportamental |
| `observer_vs_events.md` | TNotifyEvent vs Observer pattern vs anonymous method |
| `command_undo.md` | Undo/Redo com TStack<ICommand>; macro commands |

### templates/

| Arquivo | Uso |
|---------|-----|
| `TEMPLATE_strategy.pas` | Strategy com registro dinâmico + context |
| `TEMPLATE_observer_multicast.pas` | Observer com lista thread-safe + weak refs |
| `TEMPLATE_command_undo.pas` | Command + Undo/Redo stack completo |

## Fontes

- `Doc-Delphi/ObjectPascalHandbook_AlexandriaVersion.pdf` — Cap. Patterns
- GoF — Design Patterns (Gamma et al.)

## Changelog

- V1.1.0 (2026-04-11): Criação inicial com 7 exemplos, 3 consultas_rapidas, 3 templates

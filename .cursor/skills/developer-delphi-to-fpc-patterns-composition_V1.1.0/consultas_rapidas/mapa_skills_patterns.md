# Mapa de Skills de Patterns — quando usar cada skill

## Decisão por intenção

```
Preciso criar objetos de forma flexível?
  → developer-delphi-to-fpc-patterns-creational_V1.1.0

Preciso estruturar objetos em hierarquias ou wrappers?
  → developer-delphi-to-fpc-patterns-structural_V1.1.0

Preciso distribuir responsabilidade ou comunicação entre objetos?
  → developer-delphi-to-fpc-patterns-behavioral_V1.1.0
```

---

## Tabela completa de padrões por skill

### Creational — `patterns-creational_V1.1.0`

| Pattern | Quando | Arquivo |
|---------|--------|---------|
| Factory Method | Tipo decidido em runtime (string, config) | `factory_method.pas` |
| Abstract Factory | Família de produtos coerentes por engine | `abstract_factory.pas` |
| Builder | Objeto complexo com muitos parâmetros opcionais | `builder_pattern.pas` |
| Singleton | Instância única global (config, log, event bus) | `singleton.pas` |
| Prototype | Clonar objeto preservando estado | `prototype.pas` |
| Object Pool | Reutilizar objetos caros de criar (conexões, buffers) | `object_pool.pas` |

### Structural — `patterns-structural_V1.1.0`

| Pattern | Quando | Arquivo |
|---------|--------|---------|
| Composite | Hierarquia parte-todo com operação uniforme | `composite.pas` |
| Decorator | Adicionar comportamento empilhável (log, timestamp, filtro) | `decorator.pas` |
| Adapter | Integrar interface legada/externa com interface nova | `adapter.pas` |
| Proxy | Lazy loading, cache, proteção de acesso | `proxy.pas` |
| Facade | Simplificar subsistema complexo com múltiplas classes | `facade.pas` |
| Bridge | Variar abstração E implementação independentemente | `bridge.pas` |

### Behavioral — `patterns-behavioral_V1.1.0`

| Pattern | Quando | Arquivo |
|---------|--------|---------|
| Strategy | Algoritmo intercambiável em runtime | `strategy.pas` |
| Observer | N objetos reagem a mudança de estado | `observer.pas` |
| Command | Operações reversíveis, Undo/Redo, macro | `command.pas` |
| Chain of Resp. | Responsabilidade distribuída em handlers hierárquicos | `chain_of_resp.pas` |
| Mediator | Eliminar dependências cruzadas entre N componentes | `mediator.pas` |
| State | Comportamento diferente por fase/status interno | `state.pas` |
| Iterator | Percorrer coleção customizada com `for..in` | `iterator.pas` |

---

## Combinações frequentes

| Problema | Patterns combinados |
|----------|---------------------|
| Logger configurável | Decorator (chain) + Factory Method |
| Sistema de plugins | Factory + Registry + Strategy |
| Editor com Undo | Command + Composite (macro) |
| UI reativa | Observer + Mediator |
| Pipeline de validação | Chain of Responsibility + Strategy (cada handler) |
| Cache de serviço | Proxy (cache) + Singleton |
| Relatórios configuráveis | Builder + Strategy (formato) + Facade |

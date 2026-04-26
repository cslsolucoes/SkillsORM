# 23 Padrões GoF — tabela de referência com contexto Delphi

## Creational (5)

| # | Pattern | Intenção | Delphi idiom |
|---|---------|----------|-------------|
| 1 | Abstract Factory | Criar famílias de objetos relacionados sem especificar classes | `IDBFactory.NewConnection/NewQuery` por engine |
| 2 | Builder | Construir objetos complexos passo a passo | `TQueryBuilder.From.Select.Where.Build` |
| 3 | Factory Method | Subclasse decide qual objeto criar | `class function New: IAnimal` + registry |
| 4 | Prototype | Clonar objetos preservando estado | `ICloneable.Clone` com cópia profunda |
| 5 | Singleton | Garantir instância única thread-safe | Double-Checked Locking + `class var FInst` |

**Extensões não-GoF usadas em Delphi:**
- Object Pool (reutilizar objetos caros)
- Service Locator (registry de singletons — use com cuidado)

---

## Structural (7)

| # | Pattern | Intenção | Delphi idiom |
|---|---------|----------|-------------|
| 6 | Adapter | Converter interface incompatível | `TLegacyAdapter(TInterfacedObject, IModernDB)` wraps `ILegacyDB` |
| 7 | Bridge | Desacoplar abstração de implementação | `TShape` + `IRenderer` independentes |
| 8 | Composite | Tratar objetos e composições uniformemente | `IUIComponent`: `TLabel`(leaf), `TPanel`(composite) |
| 9 | Decorator | Adicionar responsabilidade dinamicamente | `TLoggerDecorator` wraps `ILogger` |
| 10 | Facade | Interface simplificada para subsistema | `TRelatorioFacade` orquestra DAL+Formatter+Export |
| 11 | Flyweight | Compartilhar objetos para economizar memória | Pools de strings, ícones — raramente implementado explicitamente |
| 12 | Proxy | Intermediário controlado | `TLazyProxy`, `TCacheProxy`, `TSecurityProxy` |

---

## Behavioral (11)

| # | Pattern | Intenção | Delphi idiom |
|---|---------|----------|-------------|
| 13 | Chain of Responsibility | Passar request por cadeia até ser tratado | `TAprovadorBase.PassarAdiante` |
| 14 | Command | Encapsular request como objeto | `ICommand.Execute/Undo` + `TCommandHistory` |
| 15 | Interpreter | Definir gramática para linguagem | Parsers simples — raramente usado em app |
| 16 | Iterator | Percorrer coleção sem expor estrutura | `GetEnumerator` → `for..in` |
| 17 | Mediator | Centralizar comunicação entre objetos | `TLoginMediator.Notificar` |
| 18 | Memento | Capturar/restaurar estado interno | `TSnapshot` record com estado + restore |
| 19 | Observer | Notificar múltiplos dependentes | `IObserver.Update` + `TSubjectBase.Notificar` |
| 20 | State | Alterar comportamento conforme estado | `IEstado` + `TContext.SetEstado` |
| 21 | Strategy | Família de algoritmos intercambiáveis | `ISortStrategy.Sort` + `TSorter.SetStrategy` |
| 22 | Template Method | Esqueleto de algoritmo com passos variáveis | Método virtual abstract + base com Template Method |
| 23 | Visitor | Operação sobre elementos de estrutura | `PercorrerArvore` com `TUIVisitor` anon method |

---

## Anti-patterns comuns em Delphi

| Anti-pattern | Problema | Solução GoF |
|-------------|----------|-------------|
| Switch/case por tipo em vários métodos | Duplicação quando novo tipo é adicionado | Factory Method + Polymorphism |
| Herança para reutilizar comportamento | Acoplamento rígido, hierarquias profundas | Decorator + Composition |
| Singleton para tudo | Testa mal, esconde dependências | Dependency Injection + Factory |
| `if Status = X then Y` em vários métodos | Lógica de estado espalhada | State Pattern |
| Callbacks encadeados (Callback Hell) | Ilegível | Command + Chain of Responsibility |

# Mapa de Skills — Família B: Linguagem Core

## Quando usar cada micro-skill

| Situação | Skill |
|----------|-------|
| Declarar tipo numérico, string, enum, set | `language-types` |
| Definir record com campos e métodos | `language-types` |
| Criar DTO para transferência de dados | `language-types` (TEMPLATE_record_dto) |
| Trabalhar com array dinâmico ou TArray<T> | `language-types` |
| Usar ponteiros (Pointer, ^T, New/Dispose) | `language-types` |
| Criar classe com constructor/destructor | `language-oop` |
| Definir interface (IFoo) | `language-oop` |
| Usar herança, virtual, override, abstract | `language-oop` |
| Implementar TInterfacedObject | `language-oop` |
| Operator overloading em classe | `language-oop` |
| Class helper / Record helper | `language-oop` |
| Usar TList<T>, TDictionary<K,V> | `language-generics` |
| Criar classe genérica TFoo<T> | `language-generics` |
| Constraints de tipo (class, constructor) | `language-generics` |
| Nullable<T>, Result<T,E> | `language-generics` |
| Repository pattern genérico | `language-generics` |
| Ler propriedades de objeto por nome (reflexão) | `language-rtti` |
| Invocar método por nome | `language-rtti` |
| Custom TCustomAttribute | `language-rtti` |
| Mapper JSON↔objeto genérico | `language-rtti` |
| Auto-bind form fields ↔ objeto | `language-rtti` |
| DI automático via attributes | `language-rtti` |
| Anonymous method (procedure sem nome) | `language-advanced` |
| Closure (captura variável local) | `language-advanced` |
| TProc<T>, TFunc<T,R> como parâmetro | `language-advanced` |
| Operator overloading em record | `language-advanced` |
| Função `inline` | `language-advanced` |
| Guard clause / Exit(valor) | `language-advanced` |
| Pipeline funcional | `language-advanced` |

## Fluxo de decisão

```
Preciso trabalhar com...
│
├─ tipo de dado primitivo/string/array/record/enum → language-types
│
├─ objeto, interface, herança, polimorfismo → language-oop
│
├─ coleção genérica ou algoritmo genérico → language-generics
│
├─ reflexão, attributes, JSON mapper, DI → language-rtti
│
└─ callback, closure, inline, operator → language-advanced
```

## Combinações comuns

| Tarefa | Skills envolvidas |
|--------|-----------------|
| DTO + validação | types + rtti (attributes) |
| Repository genérico | generics + oop (interface) |
| Mapper ORM genérico | rtti + generics |
| Pipeline funcional | advanced (TFunc) + generics (TList) |
| Auto-bind form | rtti + advanced (event handler) |
| DI container | rtti + generics + advanced |
